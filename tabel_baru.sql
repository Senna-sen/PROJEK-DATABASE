-- =====================================================
-- Penambahan 6 tabel baru (total jadi 12 tabel)
-- Aman dijalankan ulang: tidak menghapus data yang sudah ada.
-- Jalankan di Query Tool database "PROJEK DB LAB".
-- =====================================================

-- ---------- 1. Hak akses dan akun ----------
CREATE TABLE IF NOT EXISTS peran (
  id SERIAL PRIMARY KEY,
  nama_peran VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS pengguna (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(100) NOT NULL,
  nama_lengkap VARCHAR(100) NOT NULL,
  id_peran INT NOT NULL REFERENCES peran(id)
);

-- ---------- 2. Pembayaran dan pelanggan ----------
CREATE TABLE IF NOT EXISTS metode_pembayaran (
  id SERIAL PRIMARY KEY,
  nama_metode VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS pelanggan (
  id SERIAL PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  no_hp VARCHAR(20)
);

-- ---------- 3. Revisi tabel transaksi (3 kolom baru) ----------
ALTER TABLE transaksi
  ADD COLUMN IF NOT EXISTS id_pengguna INT REFERENCES pengguna(id),
  ADD COLUMN IF NOT EXISTS id_metode INT REFERENCES metode_pembayaran(id),
  ADD COLUMN IF NOT EXISTS id_pelanggan INT REFERENCES pelanggan(id);

-- ---------- 4. Pembuangan barang ----------
CREATE TABLE IF NOT EXISTS pembuangan_barang (
  id SERIAL PRIMARY KEY,
  id_batch INT NOT NULL REFERENCES batch_stok(id),
  jumlah INT NOT NULL CHECK (jumlah > 0),
  alasan VARCHAR(30) NOT NULL,
  tanggal DATE NOT NULL DEFAULT CURRENT_DATE,
  id_pengguna INT REFERENCES pengguna(id)
);

-- ---------- 5. Log aktivitas ----------
CREATE TABLE IF NOT EXISTS log_aktivitas (
  id SERIAL PRIMARY KEY,
  id_pengguna INT REFERENCES pengguna(id),
  aksi VARCHAR(100) NOT NULL,
  waktu TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ---------- 6. Data awal ----------
INSERT INTO peran (nama_peran) VALUES ('Admin'), ('Kasir'), ('Gudang')
ON CONFLICT (nama_peran) DO NOTHING;

INSERT INTO metode_pembayaran (nama_metode) VALUES ('Tunai'), ('QRIS'), ('Debit')
ON CONFLICT (nama_metode) DO NOTHING;

INSERT INTO pelanggan (nama, no_hp)
SELECT * FROM (VALUES
  ('Budi Santoso', '081200000001'),
  ('Siti Aminah',  '081200000002'),
  ('Rina Wijaya',  '081200000003')
) AS v(nama, no_hp)
WHERE NOT EXISTS (SELECT 1 FROM pelanggan);

-- Contoh pembuangan: ambil maksimal 2 batch yang sudah kadaluarsa dan masih bersisa
INSERT INTO pembuangan_barang (id_batch, jumlah, alasan)
SELECT id_batch, sisa, 'Kadaluarsa'
FROM v_batch
WHERE tanggal_kadaluarsa < CURRENT_DATE AND sisa > 0
ORDER BY id_batch
LIMIT 2
ON CONFLICT DO NOTHING;

-- ---------- 7. Stok yang dibuang ikut mengurangi sisa ----------
-- Kolom view tetap sama, hanya cara hitung "sisa" yang berubah.
CREATE OR REPLACE VIEW v_batch AS
SELECT b.id AS id_batch,
       b.id_produk,
       b.tanggal_masuk,
       b.tanggal_kadaluarsa,
       b.jumlah_masuk,
       COALESCE((SELECT SUM(d.jumlah) FROM detail_transaksi d WHERE d.id_batch = b.id), 0) AS terjual,
       b.jumlah_masuk
         - COALESCE((SELECT SUM(d.jumlah) FROM detail_transaksi d WHERE d.id_batch = b.id), 0)
         - COALESCE((SELECT SUM(p.jumlah) FROM pembuangan_barang p WHERE p.id_batch = b.id), 0) AS sisa
FROM batch_stok b;
