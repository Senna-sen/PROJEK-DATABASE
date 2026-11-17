const express = require('express');
const path = require('path');
const { Pool } = require('pg');

const app = express();

// Baca file .env dari folder yang sama dengan server.js
try {
  process.loadEnvFile(path.join(__dirname, '.env'));
} catch (err) {
  console.error('PERINGATAN: file .env tidak ditemukan di', __dirname);
}

if (!process.env.DB_PASSWORD) {
  console.error('PERINGATAN: DB_PASSWORD kosong. Cek nama file (harus ".env", bukan ".env.txt") dan isinya.');
}

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: String(process.env.DB_PASSWORD),
  database: process.env.DB_NAME,
});

// Tes koneksi saat server dinyalakan
pool.query('SELECT current_database()')
  .then(r => console.log('Terhubung ke database:', r.rows[0].current_database))
  .catch(e => console.error('Gagal terhubung ke database:', e.message));

// Membungkus query supaya error dikirim sebagai JSON
app.use(express.json());

const httpErr = (status, msg) => Object.assign(new Error(msg), { status });

const pesan = (err) =>
  err.status ? err.message
  : err.code === '23503' ? 'Data ini masih dipakai di tabel lain (stok atau transaksi), jadi tidak bisa dihapus.'
  : err.code === '23505' ? 'Barcode sudah dipakai produk lain.'
  : err.code === '23502' ? 'Ada kolom wajib yang masih kosong.'
  : err.message;

const api = (handler) => async (req, res) => {
  try {
    res.json(await handler(req));
  } catch (err) {
    res.status(err.status || 500).json({ error: pesan(err) });
  }
};

// Halaman utama
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Data stok per produk (dari view v_stok)
app.get('/api/stok', api(async () => {
  const r = await pool.query('SELECT * FROM v_stok ORDER BY id');
  return r.rows;
}));

// Daftar transaksi
app.get('/api/transaksi', api(async () => {
  const r = await pool.query(`
    SELECT t.id, t.tanggal, t.total, t.bayar,
           (SELECT COUNT(*) FROM detail_transaksi d WHERE d.id_transaksi = t.id) AS jumlah_item
    FROM transaksi t
    ORDER BY t.id DESC`);
  return r.rows;
}));

// Detail satu transaksi (isi struk)
app.get('/api/transaksi/:id', api(async (req) => {
  const head = await pool.query('SELECT * FROM transaksi WHERE id = $1', [req.params.id]);
  const items = await pool.query(`
    SELECT p.nama, d.jumlah, d.harga_satuan, d.jumlah * d.harga_satuan AS subtotal
    FROM detail_transaksi d
    JOIN batch_stok b ON b.id = d.id_batch
    JOIN produk p ON p.id = b.id_produk
    WHERE d.id_transaksi = $1
    ORDER BY d.id`, [req.params.id]);
  return { transaksi: head.rows[0], items: items.rows };
}));

// ================= CRUD =================

// Data pendukung untuk dropdown
app.get('/api/kategori', api(async () => (await pool.query('SELECT * FROM kategori ORDER BY id')).rows));
app.get('/api/supplier', api(async () => (await pool.query('SELECT * FROM supplier ORDER BY id')).rows));

// READ: semua produk (data mentah untuk form edit)
app.get('/api/produk', api(async () => (await pool.query('SELECT * FROM produk ORDER BY id')).rows));

// Validasi dan susun data produk
const dataProduk = (b) => {
  if (!b.nama || !b.kode_barcode) throw httpErr(400, 'Barcode dan nama wajib diisi.');
  if (!(Number(b.harga_jual) > 0) || !(Number(b.harga_beli) >= 0)) throw httpErr(400, 'Harga beli dan harga jual harus berupa angka.');
  return [b.kode_barcode, b.nama, b.id_kategori || null, b.satuan || 'pcs',
          Number(b.harga_beli), Number(b.harga_jual), Number(b.stok_minimum) || 0];
};

// CREATE produk
app.post('/api/produk', api(async (req) => {
  const r = await pool.query(
    `INSERT INTO produk (kode_barcode, nama, id_kategori, satuan, harga_beli, harga_jual, stok_minimum)
     VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`, dataProduk(req.body));
  return r.rows[0];
}));

// UPDATE produk
app.put('/api/produk/:id', api(async (req) => {
  const r = await pool.query(
    `UPDATE produk SET kode_barcode=$1, nama=$2, id_kategori=$3, satuan=$4,
            harga_beli=$5, harga_jual=$6, stok_minimum=$7 WHERE id=$8 RETURNING *`,
    [...dataProduk(req.body), req.params.id]);
  if (!r.rows[0]) throw httpErr(404, 'Produk tidak ditemukan.');
  return r.rows[0];
}));

// DELETE produk (gagal jika sudah punya riwayat stok/transaksi)
app.delete('/api/produk/:id', api(async (req) => {
  await pool.query('DELETE FROM produk WHERE id = $1', [req.params.id]);
  return { ok: true };
}));

// CREATE barang masuk (batch stok baru)
app.post('/api/batch', api(async (req) => {
  const b = req.body;
  if (!b.id_produk || !(Number(b.jumlah_masuk) > 0) || !b.tanggal_kadaluarsa) {
    throw httpErr(400, 'Produk, jumlah, dan tanggal kadaluarsa wajib diisi.');
  }
  const r = await pool.query(
    `INSERT INTO batch_stok (id_produk, id_supplier, jumlah_masuk, tanggal_masuk, tanggal_kadaluarsa)
     VALUES ($1,$2,$3,COALESCE($4::date, CURRENT_DATE),$5) RETURNING *`,
    [b.id_produk, b.id_supplier || null, b.jumlah_masuk, b.tanggal_masuk || null, b.tanggal_kadaluarsa]);
  return r.rows[0];
}));

// CREATE transaksi (kasir). Stok diambil dari batch yang paling dekat kadaluarsa,
// batch yang sudah kadaluarsa dilewati. Semua langkah dalam satu transaksi database.
app.post('/api/transaksi', api(async (req) => {
  const { items, bayar } = req.body;
  if (!Array.isArray(items) || !items.length) throw httpErr(400, 'Keranjang masih kosong.');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const id = (await client.query('INSERT INTO transaksi (total, bayar) VALUES (0, 0) RETURNING id')).rows[0].id;
    let total = 0;

    for (const it of items) {
      let perlu = parseInt(it.jumlah, 10);
      if (!(perlu > 0)) throw httpErr(400, 'Jumlah harus lebih dari 0.');

      // Kunci baris produk agar dua kasir tidak mengambil stok yang sama
      const p = (await client.query('SELECT nama, harga_jual FROM produk WHERE id = $1 FOR UPDATE', [it.id_produk])).rows[0];
      if (!p) throw httpErr(404, 'Produk tidak ditemukan.');

      const batches = (await client.query(
        `SELECT id_batch, sisa FROM v_batch
         WHERE id_produk = $1 AND sisa > 0 AND tanggal_kadaluarsa >= CURRENT_DATE
         ORDER BY tanggal_kadaluarsa, id_batch`, [it.id_produk])).rows;

      for (const b of batches) {
        if (perlu <= 0) break;
        const ambil = Math.min(perlu, Number(b.sisa));
        await client.query(
          'INSERT INTO detail_transaksi (id_transaksi, id_batch, jumlah, harga_satuan) VALUES ($1,$2,$3,$4)',
          [id, b.id_batch, ambil, p.harga_jual]);
        total += ambil * Number(p.harga_jual);
        perlu -= ambil;
      }
      if (perlu > 0) throw httpErr(400, `Stok ${p.nama} tidak cukup (kurang ${perlu}).`);
    }

    if (!(Number(bayar) >= total)) throw httpErr(400, 'Uang bayar kurang dari total.');
    await client.query('UPDATE transaksi SET total = $1, bayar = $2 WHERE id = $3', [total, bayar, id]);
    await client.query('COMMIT');
    return { id, total };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}));

// DELETE transaksi (detail ikut terhapus, stok otomatis kembali)
app.delete('/api/transaksi/:id', api(async (req) => {
  await pool.query('DELETE FROM transaksi WHERE id = $1', [req.params.id]);
  return { ok: true };
}));

app.listen(3000, () => {
  console.log('Server jalan di http://localhost:3000');
});