--
-- PostgreSQL database dump
--

\restrict sgJ5SDePCkabP92WN4L0NOTnzn3XSJa8Jdw2HGkrUyUZ6xdzVKUkAwdcndR0Jav

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

-- Started on 2026-11-14 23:45:03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 226 (class 1259 OID 17794)
-- Name: batch_stok; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.batch_stok (
    id integer NOT NULL,
    id_produk integer NOT NULL,
    id_supplier integer,
    jumlah_masuk integer NOT NULL,
    tanggal_masuk date DEFAULT CURRENT_DATE NOT NULL,
    tanggal_kadaluarsa date NOT NULL,
    CONSTRAINT batch_stok_jumlah_masuk_check CHECK ((jumlah_masuk > 0))
);


ALTER TABLE public.batch_stok OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17793)
-- Name: batch_stok_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.batch_stok_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.batch_stok_id_seq OWNER TO postgres;

--
-- TOC entry 5088 (class 0 OID 0)
-- Dependencies: 225
-- Name: batch_stok_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.batch_stok_id_seq OWNED BY public.batch_stok.id;


--
-- TOC entry 230 (class 1259 OID 17832)
-- Name: detail_transaksi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detail_transaksi (
    id integer NOT NULL,
    id_transaksi integer NOT NULL,
    id_batch integer NOT NULL,
    jumlah integer NOT NULL,
    harga_satuan numeric(12,2) NOT NULL,
    CONSTRAINT detail_transaksi_jumlah_check CHECK ((jumlah > 0))
);


ALTER TABLE public.detail_transaksi OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17831)
-- Name: detail_transaksi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.detail_transaksi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.detail_transaksi_id_seq OWNER TO postgres;

--
-- TOC entry 5089 (class 0 OID 0)
-- Dependencies: 229
-- Name: detail_transaksi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.detail_transaksi_id_seq OWNED BY public.detail_transaksi.id;


--
-- TOC entry 220 (class 1259 OID 17738)
-- Name: kategori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kategori (
    id integer NOT NULL,
    nama_kategori character varying(50) NOT NULL
);


ALTER TABLE public.kategori OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17737)
-- Name: kategori_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kategori_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kategori_id_seq OWNER TO postgres;

--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 219
-- Name: kategori_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kategori_id_seq OWNED BY public.kategori.id;


--
-- TOC entry 224 (class 1259 OID 17758)
-- Name: produk; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produk (
    id integer NOT NULL,
    kode_barcode character varying(20) NOT NULL,
    nama character varying(100) NOT NULL,
    id_kategori integer,
    satuan character varying(20) DEFAULT 'pcs'::character varying NOT NULL,
    harga_beli numeric(12,2) NOT NULL,
    harga_jual numeric(12,2) NOT NULL,
    stok_minimum integer DEFAULT 10 NOT NULL
);


ALTER TABLE public.produk OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17757)
-- Name: produk_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.produk_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.produk_id_seq OWNER TO postgres;

--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 223
-- Name: produk_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.produk_id_seq OWNED BY public.produk.id;


--
-- TOC entry 222 (class 1259 OID 17747)
-- Name: supplier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier (
    id integer NOT NULL,
    nama character varying(100) NOT NULL,
    kontak character varying(20),
    alamat text
);


ALTER TABLE public.supplier OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17746)
-- Name: supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.supplier_id_seq OWNER TO postgres;

--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 221
-- Name: supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.supplier_id_seq OWNED BY public.supplier.id;


--
-- TOC entry 228 (class 1259 OID 17818)
-- Name: transaksi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaksi (
    id integer NOT NULL,
    tanggal timestamp without time zone DEFAULT now() NOT NULL,
    total numeric(12,2) DEFAULT 0 NOT NULL,
    bayar numeric(12,2) DEFAULT 0 NOT NULL
);


ALTER TABLE public.transaksi OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17817)
-- Name: transaksi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transaksi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transaksi_id_seq OWNER TO postgres;

--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 227
-- Name: transaksi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transaksi_id_seq OWNED BY public.transaksi.id;


--
-- TOC entry 231 (class 1259 OID 17872)
-- Name: v_batch; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_batch AS
 SELECT id AS id_batch,
    id_produk,
    tanggal_masuk,
    tanggal_kadaluarsa,
    jumlah_masuk,
    COALESCE(( SELECT sum(d.jumlah) AS sum
           FROM public.detail_transaksi d
          WHERE (d.id_batch = b.id)), (0)::bigint) AS terjual,
    (jumlah_masuk - COALESCE(( SELECT sum(d.jumlah) AS sum
           FROM public.detail_transaksi d
          WHERE (d.id_batch = b.id)), (0)::bigint)) AS sisa
   FROM public.batch_stok b;


ALTER VIEW public.v_batch OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 17876)
-- Name: v_stok; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_stok AS
SELECT
    NULL::integer AS id,
    NULL::character varying(20) AS kode_barcode,
    NULL::character varying(100) AS nama,
    NULL::character varying(50) AS nama_kategori,
    NULL::character varying(20) AS satuan,
    NULL::numeric(12,2) AS harga_jual,
    NULL::bigint AS stok_masuk,
    NULL::numeric AS stok_terjual,
    NULL::numeric AS stok_sisa,
    NULL::numeric AS stok_kadaluarsa,
    NULL::numeric AS stok_layak_jual,
    NULL::integer AS stok_minimum,
    NULL::date AS kadaluarsa_terdekat,
    NULL::text AS status;


ALTER VIEW public.v_stok OWNER TO postgres;

--
-- TOC entry 4894 (class 2604 OID 17797)
-- Name: batch_stok id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batch_stok ALTER COLUMN id SET DEFAULT nextval('public.batch_stok_id_seq'::regclass);


--
-- TOC entry 4900 (class 2604 OID 17835)
-- Name: detail_transaksi id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detail_transaksi ALTER COLUMN id SET DEFAULT nextval('public.detail_transaksi_id_seq'::regclass);


--
-- TOC entry 4889 (class 2604 OID 17741)
-- Name: kategori id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori ALTER COLUMN id SET DEFAULT nextval('public.kategori_id_seq'::regclass);


--
-- TOC entry 4891 (class 2604 OID 17761)
-- Name: produk id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produk ALTER COLUMN id SET DEFAULT nextval('public.produk_id_seq'::regclass);


--
-- TOC entry 4890 (class 2604 OID 17750)
-- Name: supplier id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier ALTER COLUMN id SET DEFAULT nextval('public.supplier_id_seq'::regclass);


--
-- TOC entry 4896 (class 2604 OID 17821)
-- Name: transaksi id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi ALTER COLUMN id SET DEFAULT nextval('public.transaksi_id_seq'::regclass);


--
-- TOC entry 5078 (class 0 OID 17794)
-- Dependencies: 226
-- Data for Name: batch_stok; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.batch_stok (id, id_produk, id_supplier, jumlah_masuk, tanggal_masuk, tanggal_kadaluarsa) FROM stdin;
1	1	1	100	2026-10-15	2027-09-10
2	1	1	50	2026-11-09	2028-01-08
3	2	1	80	2026-10-20	2027-08-21
4	3	1	40	2026-10-25	2027-04-13
5	4	2	120	2026-10-25	2028-03-28
6	5	2	48	2026-10-30	2027-06-02
7	6	2	36	2026-11-04	2027-07-22
8	7	2	60	2026-10-20	2026-12-29
9	7	2	40	2026-11-11	2027-03-14
10	8	2	24	2026-11-08	2026-11-20
11	9	3	20	2026-11-12	2026-11-18
12	10	3	15	2026-11-11	2026-11-19
13	11	4	30	2026-11-04	2027-04-13
14	12	4	100	2026-11-02	2027-07-12
15	13	4	40	2026-10-31	2027-05-13
16	14	4	60	2026-11-05	2027-03-14
17	15	1	24	2026-10-27	2027-11-14
18	16	1	30	2026-10-23	2027-12-19
19	17	1	20	2026-11-07	2026-11-28
20	18	1	18	2026-10-15	2027-10-10
21	19	5	36	2026-10-31	2028-10-14
22	20	5	24	2026-10-29	2028-07-06
23	21	5	12	2026-10-25	2028-05-17
24	22	5	18	2026-10-26	2028-03-28
25	23	5	20	2026-10-26	2028-04-17
26	24	5	30	2026-11-06	2029-01-22
27	9	3	10	2026-11-02	2026-11-12
28	8	2	12	2026-10-25	2026-11-13
\.


--
-- TOC entry 5082 (class 0 OID 17832)
-- Dependencies: 230
-- Data for Name: detail_transaksi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.detail_transaksi (id, id_transaksi, id_batch, jumlah, harga_satuan) FROM stdin;
1	1	1	10	3500.00
2	1	5	6	4000.00
3	1	14	10	2500.00
4	2	8	4	6500.00
5	2	13	3	11000.00
6	2	6	5	6000.00
7	3	11	5	16000.00
8	3	27	8	16000.00
9	3	12	4	12000.00
10	4	4	33	6500.00
11	4	3	10	3300.00
12	5	19	17	28000.00
13	6	28	9	9000.00
14	6	10	10	9000.00
15	6	21	5	4000.00
\.


--
-- TOC entry 5072 (class 0 OID 17738)
-- Dependencies: 220
-- Data for Name: kategori; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kategori (id, nama_kategori) FROM stdin;
1	Makanan Instan
2	Minuman
3	Susu & Olahan
4	Roti & Kue
5	Snack
6	Kebutuhan Dapur
7	Perawatan Diri
8	Kebersihan Rumah
\.


--
-- TOC entry 5076 (class 0 OID 17758)
-- Dependencies: 224
-- Data for Name: produk; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produk (id, kode_barcode, nama, id_kategori, satuan, harga_beli, harga_jual, stok_minimum) FROM stdin;
1	8990001	Indomie Goreng	1	bungkus	2800.00	3500.00	20
2	8990002	Mie Sedaap Soto	1	bungkus	2600.00	3300.00	20
3	8990003	Pop Mie Ayam	1	cup	5000.00	6500.00	10
4	8990004	Aqua 600ml	2	botol	3000.00	4000.00	24
5	8990005	Teh Botol Sosro 450ml	2	botol	4500.00	6000.00	12
6	8990006	Pocari Sweat 500ml	2	botol	6000.00	8000.00	12
7	8990007	Ultra Milk Coklat 250ml	3	kotak	5000.00	6500.00	12
8	8990008	Yogurt Cimory	3	botol	7000.00	9000.00	8
9	8990009	Sari Roti Tawar	4	bungkus	13000.00	16000.00	5
10	8990010	Roti Sobek Coklat	4	bungkus	9000.00	12000.00	5
11	8990011	Chitato Sapi Panggang	5	bungkus	9000.00	11000.00	10
12	8990012	Beng-Beng	5	pcs	1800.00	2500.00	20
13	8990013	Oreo Vanila	5	bungkus	7000.00	9000.00	10
14	8990014	Taro Net	5	bungkus	2500.00	3500.00	15
15	8990015	Minyak Goreng Bimoli 1L	6	botol	17000.00	20000.00	6
16	8990016	Gulaku 1kg	6	bungkus	15000.00	17500.00	8
17	8990017	Telur Ayam (10 butir)	6	pack	24000.00	28000.00	5
18	8990018	Kecap Bango 275ml	6	botol	9000.00	11500.00	6
19	8990019	Sabun Lifebuoy	7	pcs	3000.00	4000.00	10
20	8990020	Pepsodent 190g	7	pcs	11000.00	14000.00	8
21	8990021	Shampoo Clear 170ml	7	botol	17000.00	21000.00	6
22	8990022	Rinso 800g	8	bungkus	18000.00	22000.00	6
23	8990023	Sunlight 755ml	8	botol	12000.00	15000.00	6
24	8990024	Tisu Paseo	8	pack	9000.00	12000.00	8
\.


--
-- TOC entry 5074 (class 0 OID 17747)
-- Dependencies: 222
-- Data for Name: supplier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.supplier (id, nama, kontak, alamat) FROM stdin;
1	Grosir Sumber Pangan	081234567001	Malang
2	Distributor Minuman Segar	081234567002	Surabaya
3	Bakery Nusantara	081234567003	Malang
4	Snack Jaya	081234567004	Pasuruan
5	Sinar Kebersihan	081234567005	Sidoarjo
\.


--
-- TOC entry 5080 (class 0 OID 17818)
-- Dependencies: 228
-- Data for Name: transaksi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transaksi (id, tanggal, total, bayar) FROM stdin;
1	2026-11-08 23:21:14.026048	84000.00	90000.00
2	2026-11-09 23:21:14.026048	89000.00	90000.00
3	2026-11-10 23:21:14.026048	256000.00	260000.00
4	2026-11-11 23:21:14.026048	247500.00	250000.00
5	2026-11-12 23:21:14.026048	476000.00	480000.00
6	2026-11-13 23:21:14.026048	191000.00	200000.00
\.


--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 225
-- Name: batch_stok_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.batch_stok_id_seq', 28, true);


--
-- TOC entry 5095 (class 0 OID 0)
-- Dependencies: 229
-- Name: detail_transaksi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.detail_transaksi_id_seq', 15, true);


--
-- TOC entry 5096 (class 0 OID 0)
-- Dependencies: 219
-- Name: kategori_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kategori_id_seq', 8, true);


--
-- TOC entry 5097 (class 0 OID 0)
-- Dependencies: 223
-- Name: produk_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.produk_id_seq', 24, true);


--
-- TOC entry 5098 (class 0 OID 0)
-- Dependencies: 221
-- Name: supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.supplier_id_seq', 5, true);


--
-- TOC entry 5099 (class 0 OID 0)
-- Dependencies: 227
-- Name: transaksi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transaksi_id_seq', 6, true);


--
-- TOC entry 4912 (class 2606 OID 17806)
-- Name: batch_stok batch_stok_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batch_stok
    ADD CONSTRAINT batch_stok_pkey PRIMARY KEY (id);


--
-- TOC entry 4916 (class 2606 OID 17843)
-- Name: detail_transaksi detail_transaksi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detail_transaksi
    ADD CONSTRAINT detail_transaksi_pkey PRIMARY KEY (id);


--
-- TOC entry 4904 (class 2606 OID 17745)
-- Name: kategori kategori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori
    ADD CONSTRAINT kategori_pkey PRIMARY KEY (id);


--
-- TOC entry 4908 (class 2606 OID 17774)
-- Name: produk produk_kode_barcode_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produk
    ADD CONSTRAINT produk_kode_barcode_key UNIQUE (kode_barcode);


--
-- TOC entry 4910 (class 2606 OID 17772)
-- Name: produk produk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produk
    ADD CONSTRAINT produk_pkey PRIMARY KEY (id);


--
-- TOC entry 4906 (class 2606 OID 17756)
-- Name: supplier supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (id);


--
-- TOC entry 4914 (class 2606 OID 17830)
-- Name: transaksi transaksi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi
    ADD CONSTRAINT transaksi_pkey PRIMARY KEY (id);


--
-- TOC entry 5070 (class 2618 OID 17879)
-- Name: v_stok _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.v_stok AS
 SELECT p.id,
    p.kode_barcode,
    p.nama,
    k.nama_kategori,
    p.satuan,
    p.harga_jual,
    sum(v.jumlah_masuk) AS stok_masuk,
    sum(v.terjual) AS stok_terjual,
    sum(v.sisa) AS stok_sisa,
    COALESCE(sum(v.sisa) FILTER (WHERE (v.tanggal_kadaluarsa < CURRENT_DATE)), (0)::numeric) AS stok_kadaluarsa,
    COALESCE(sum(v.sisa) FILTER (WHERE (v.tanggal_kadaluarsa >= CURRENT_DATE)), (0)::numeric) AS stok_layak_jual,
    p.stok_minimum,
    min(v.tanggal_kadaluarsa) FILTER (WHERE ((v.sisa > 0) AND (v.tanggal_kadaluarsa >= CURRENT_DATE))) AS kadaluarsa_terdekat,
        CASE
            WHEN (COALESCE(sum(v.sisa) FILTER (WHERE (v.tanggal_kadaluarsa < CURRENT_DATE)), (0)::numeric) > (0)::numeric) THEN 'ADA YANG KADALUARSA'::text
            WHEN (COALESCE(sum(v.sisa) FILTER (WHERE (v.tanggal_kadaluarsa >= CURRENT_DATE)), (0)::numeric) <= (p.stok_minimum)::numeric) THEN 'STOK MENIPIS'::text
            WHEN (min(v.tanggal_kadaluarsa) FILTER (WHERE ((v.sisa > 0) AND (v.tanggal_kadaluarsa >= CURRENT_DATE))) <= (CURRENT_DATE + 7)) THEN 'HAMPIR KADALUARSA'::text
            ELSE 'AMAN'::text
        END AS status
   FROM ((public.produk p
     LEFT JOIN public.kategori k ON ((k.id = p.id_kategori)))
     JOIN public.v_batch v ON ((v.id_produk = p.id)))
  GROUP BY p.id, k.nama_kategori;


--
-- TOC entry 4918 (class 2606 OID 17807)
-- Name: batch_stok batch_stok_id_produk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batch_stok
    ADD CONSTRAINT batch_stok_id_produk_fkey FOREIGN KEY (id_produk) REFERENCES public.produk(id);


--
-- TOC entry 4919 (class 2606 OID 17812)
-- Name: batch_stok batch_stok_id_supplier_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batch_stok
    ADD CONSTRAINT batch_stok_id_supplier_fkey FOREIGN KEY (id_supplier) REFERENCES public.supplier(id);


--
-- TOC entry 4920 (class 2606 OID 17849)
-- Name: detail_transaksi detail_transaksi_id_batch_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detail_transaksi
    ADD CONSTRAINT detail_transaksi_id_batch_fkey FOREIGN KEY (id_batch) REFERENCES public.batch_stok(id);


--
-- TOC entry 4921 (class 2606 OID 17844)
-- Name: detail_transaksi detail_transaksi_id_transaksi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detail_transaksi
    ADD CONSTRAINT detail_transaksi_id_transaksi_fkey FOREIGN KEY (id_transaksi) REFERENCES public.transaksi(id) ON DELETE CASCADE;


--
-- TOC entry 4917 (class 2606 OID 17775)
-- Name: produk produk_id_kategori_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produk
    ADD CONSTRAINT produk_id_kategori_fkey FOREIGN KEY (id_kategori) REFERENCES public.kategori(id);


-- Completed on 2026-11-14 23:45:03

--
-- PostgreSQL database dump complete
--

\unrestrict sgJ5SDePCkabP92WN4L0NOTnzn3XSJa8Jdw2HGkrUyUZ6xdzVKUkAwdcndR0Jav

