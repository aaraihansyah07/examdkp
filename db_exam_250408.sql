--
-- PostgreSQL database dump
--

-- Dumped from database version 15.5
-- Dumped by pg_dump version 15.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: generate_kode_guru(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_kode_guru() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    last_number integer;
    new_number text;
BEGIN
    -- Ambil 3 digit terakhir dari kode_guru terbesar
    SELECT COALESCE(
        MAX(CAST(SUBSTRING(kode_guru FROM 8 FOR 3) AS INTEGER)),
        0
    )
    INTO last_number
    FROM d_guru;

    -- Tambahkan 1
    new_number := LPAD((last_number + 1)::text, 3, '0');

    -- Set nilai kode_guru dengan format GSMADKPxxx
    NEW.kode_guru := 'GSMADKP' || new_number;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.generate_kode_guru() OWNER TO postgres;

--
-- Name: proc_generate_akun_siswa(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.proc_generate_akun_siswa()
    LANGUAGE plpgsql
    AS $$
DECLARE
    siswa RECORD;
    password_raw TEXT;
    password_hashed TEXT;
BEGIN
    FOR siswa IN SELECT * FROM d_siswa LOOP
        -- Cek apakah user sudah ada
        IF NOT EXISTS (
            SELECT 1 FROM users WHERE username = siswa.nis
        ) THEN
            -- Ambil tanggal lahir dan hash
            password_raw := to_char(siswa.tanggal_lahir, 'YYYY-MM-DD');
            password_hashed := crypt(password_raw, gen_salt('bf'));

            -- Insert user
            INSERT INTO users(uname, pwd, role, fname)
            VALUES (siswa.nis, password_hashed, '2', siswa.nama_siswa);
        END IF;
    END LOOP;
END;
$$;


ALTER PROCEDURE public.proc_generate_akun_siswa() OWNER TO postgres;

--
-- Name: sp_generate_akun_guru(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_generate_akun_guru()
    LANGUAGE plpgsql
    AS $$
DECLARE
    guru RECORD;
    password_raw TEXT;
    password_hashed TEXT;
BEGIN
    FOR guru IN SELECT * FROM d_guru LOOP
        -- Cek apakah user sudah ada
        IF NOT EXISTS (
            SELECT 1 FROM users WHERE uname = guru.nip
        ) THEN
            -- Ambil tanggal lahir dan hash
            password_raw := to_char(guru.tanggal_lahir, 'DDMMYYYY');
            password_hashed := crypt(password_raw, gen_salt('bf'));

            -- Insert user
            INSERT INTO users(uname, pword, role, fname, st_generate)
            VALUES (guru.nip, password_hashed, '1', guru.nama_guru, 'Y');
        END IF;
    END LOOP;
END;
$$;


ALTER PROCEDURE public.sp_generate_akun_guru() OWNER TO postgres;

--
-- Name: sp_generate_akun_guru_by_kode_guru(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_generate_akun_guru_by_kode_guru()
    LANGUAGE plpgsql
    AS $$
DECLARE
    guru RECORD;
    password_raw TEXT;
    password_hashed TEXT;
BEGIN
    FOR guru IN SELECT * FROM d_guru LOOP
        -- Cek apakah user sudah ada
        IF NOT EXISTS (
            SELECT 1 FROM users WHERE uname = guru.nip
        ) THEN
            -- Ambil tanggal lahir dan hash
            password_raw := guru.kode_guru;
            password_hashed := crypt(password_raw, gen_salt('bf'));

            -- Insert user
            INSERT INTO users(uname, pword, role, fname, st_generate)
            VALUES (guru.kode_guru, password_hashed, '1', guru.nama_guru, 'Y');
        END IF;
    END LOOP;
END;
$$;


ALTER PROCEDURE public.sp_generate_akun_guru_by_kode_guru() OWNER TO postgres;

--
-- Name: sp_generate_akun_siswa(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_generate_akun_siswa()
    LANGUAGE plpgsql
    AS $$
DECLARE
    siswa RECORD;
    password_raw TEXT;
    password_hashed TEXT;
BEGIN
    FOR siswa IN SELECT * FROM d_siswa LOOP
        -- Cek apakah user sudah ada
        IF NOT EXISTS (
            SELECT 1 FROM users WHERE uname = siswa.nis
        ) THEN
            -- Ambil tanggal lahir dan hash
            password_raw := to_char(siswa.tanggal_lahir, 'DDMMYYYY');
            password_hashed := crypt(password_raw, gen_salt('bf'));

            -- Insert user
            INSERT INTO users(uname, pword, role, fname, st_generate)
            VALUES (siswa.nis, password_hashed, '2', siswa.nama_siswa, 'Y');
        END IF;
    END LOOP;
END;
$$;


ALTER PROCEDURE public.sp_generate_akun_siswa() OWNER TO postgres;

--
-- Name: sp_generate_akun_siswa_by_nis(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_generate_akun_siswa_by_nis()
    LANGUAGE plpgsql
    AS $$
DECLARE
    siswa RECORD;
    password_raw TEXT;
    password_hashed TEXT;
BEGIN
    FOR siswa IN SELECT * FROM d_siswa LOOP
        -- Cek apakah user sudah ada
        IF NOT EXISTS (
            SELECT 1 FROM users WHERE uname = siswa.nis
        ) THEN
            -- Ambil tanggal lahir dan hash
            password_raw := siswa.nis;
            password_hashed := crypt(password_raw, gen_salt('bf'));

            -- Insert user
            INSERT INTO users(uname, pword, role, fname, st_generate)
            VALUES (siswa.nis, password_hashed, '2', siswa.nama_siswa, 'Y');
        END IF;
    END LOOP;
END;
$$;


ALTER PROCEDURE public.sp_generate_akun_siswa_by_nis() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: d_guru; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_guru (
    uuidguru character varying(40) DEFAULT gen_random_uuid() NOT NULL,
    nama_guru character varying(100) NOT NULL,
    gender character varying(5),
    tanggal_lahir date,
    tempat_lahir character varying(20),
    nip character varying(20),
    kode_mata_pelajaran character varying(20),
    kode_guru character varying(20)
);


ALTER TABLE public.d_guru OWNER TO postgres;

--
-- Name: d_kelas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_kelas (
    id integer NOT NULL,
    kode_kelas character varying(10),
    nama_kelas character varying(10)
);


ALTER TABLE public.d_kelas OWNER TO postgres;

--
-- Name: d_mata_pelajaran; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_mata_pelajaran (
    id integer NOT NULL,
    nama_mata_pelajaran character varying(50),
    kode_mata_pelajaran character varying(10)
);


ALTER TABLE public.d_mata_pelajaran OWNER TO postgres;

--
-- Name: d_penempatan_mapel_guru; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_penempatan_mapel_guru (
    uuidguru character varying(40),
    uuidpenempatanmapel character varying(40) DEFAULT gen_random_uuid() NOT NULL,
    kode_mata_pelajaran character varying(10),
    kode_guru character varying(20)
);


ALTER TABLE public.d_penempatan_mapel_guru OWNER TO postgres;

--
-- Name: d_penempatan_siswa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_penempatan_siswa (
    uuidpenempatansiswa character varying(40) NOT NULL,
    uuidsiswa character varying(40),
    nama_siswa character varying(100),
    kode_tahun_ajaran character varying(10),
    id_kelas integer,
    id_subkelas integer
);


ALTER TABLE public.d_penempatan_siswa OWNER TO postgres;

--
-- Name: d_siswa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_siswa (
    uuidsiswa character varying(40) DEFAULT gen_random_uuid() NOT NULL,
    nama_siswa character varying(100) NOT NULL,
    gender character varying(5) NOT NULL,
    nis character varying(10) NOT NULL,
    tanggal_lahir date,
    tempat_lahir character varying(20),
    st_active character varying(5),
    id_kelas integer,
    id_subkelas integer,
    kode_tahun_ajaran character varying(10),
    nisn character varying(20) NOT NULL
);


ALTER TABLE public.d_siswa OWNER TO postgres;

--
-- Name: d_subkelas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_subkelas (
    id integer NOT NULL,
    kode_subkelas character varying(10),
    nama_subkelas character varying(10),
    id_kelas integer
);


ALTER TABLE public.d_subkelas OWNER TO postgres;

--
-- Name: d_tahun_ajaran; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_tahun_ajaran (
    kode_tahun_ajaran character varying(10) NOT NULL,
    nama_tahun_ajaran character varying(30),
    keterangan character varying(100)
);


ALTER TABLE public.d_tahun_ajaran OWNER TO postgres;

--
-- Name: d_ujian; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d_ujian (
    id_ujian integer NOT NULL,
    nama_ujian character varying(150),
    deskripsi character varying(200),
    semester character varying(5),
    kode_tahun_ajaran character varying(10),
    kode_ujian character varying(30),
    jenis_ujian character varying(10),
    kode_mata_pelajaran character varying(10)
);


ALTER TABLE public.d_ujian OWNER TO postgres;

--
-- Name: f_jawaban_siswa_dtl; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.f_jawaban_siswa_dtl (
    seq_jawaban_siswa_dtl integer NOT NULL,
    id_jawaban_siswa integer,
    no_soal integer,
    kunci_jawaban character varying(50),
    nilai integer,
    jawaban_siswa character varying(50)
);


ALTER TABLE public.f_jawaban_siswa_dtl OWNER TO postgres;

--
-- Name: f_jawaban_siswa_hdr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.f_jawaban_siswa_hdr (
    id_jawaban_siswa integer NOT NULL,
    uuidsiswa character varying(40),
    id_ujian_hdr integer,
    id_kelas integer,
    id_subkelas integer,
    kode_mata_pelajaran character varying(20),
    uuidguru character varying(40),
    nis character varying(20)
);


ALTER TABLE public.f_jawaban_siswa_hdr OWNER TO postgres;

--
-- Name: f_soal_dtl; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.f_soal_dtl (
    seq_soal_dtl integer NOT NULL,
    option_a character varying(300) NOT NULL,
    option_b character varying(300) NOT NULL,
    option_c character varying(300) NOT NULL,
    option_d character varying(300) NOT NULL,
    option_e character varying(300) NOT NULL,
    no_soal integer NOT NULL,
    id_ujian_hdr integer NOT NULL,
    isi_soal text NOT NULL,
    gambar_soal_filename character varying(200),
    kunci_jawaban character varying(5) NOT NULL,
    nilai numeric
);


ALTER TABLE public.f_soal_dtl OWNER TO postgres;

--
-- Name: f_soal_hdr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.f_soal_hdr (
    id_ujian_hdr integer NOT NULL,
    id_ujian integer NOT NULL,
    kode_ujian character varying(50),
    id_kelas integer,
    id_subkelas integer,
    st_posting character varying(5),
    waktu_mulai timestamp without time zone,
    waktu_berakhir timestamp without time zone,
    nama_bab character varying(200),
    createuser character varying(100),
    createdate timestamp without time zone DEFAULT now(),
    updateuser character varying(100),
    updatedate timestamp without time zone,
    uuidguru character varying(50),
    kode_guru character varying(20),
    kode_mata_pelajaran character varying(20),
    durasi numeric,
    userposting character varying(100),
    token character varying(7),
    st_nonaktif_token character varying(5)
);


ALTER TABLE public.f_soal_hdr OWNER TO postgres;

--
-- Name: seq_id_mapel; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_id_mapel
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999
    CACHE 1;


ALTER TABLE public.seq_id_mapel OWNER TO postgres;

--
-- Name: seq_id_mapel; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seq_id_mapel OWNED BY public.d_mata_pelajaran.id;


--
-- Name: seq_id_ujian; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_id_ujian
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1;


ALTER TABLE public.seq_id_ujian OWNER TO postgres;

--
-- Name: seq_id_ujian; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seq_id_ujian OWNED BY public.d_ujian.id_ujian;


--
-- Name: seq_jawaban_siswa_dtl; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_jawaban_siswa_dtl
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999999999
    CACHE 1;


ALTER TABLE public.seq_jawaban_siswa_dtl OWNER TO postgres;

--
-- Name: seq_jawaban_siswa_dtl; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seq_jawaban_siswa_dtl OWNED BY public.f_jawaban_siswa_dtl.seq_jawaban_siswa_dtl;


--
-- Name: seq_jawaban_siswa_hdr; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_jawaban_siswa_hdr
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999999999
    CACHE 1;


ALTER TABLE public.seq_jawaban_siswa_hdr OWNER TO postgres;

--
-- Name: seq_jawaban_siswa_hdr; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seq_jawaban_siswa_hdr OWNED BY public.f_jawaban_siswa_hdr.id_jawaban_siswa;


--
-- Name: seq_kelas; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_kelas
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.seq_kelas OWNER TO postgres;

--
-- Name: seq_kelas; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seq_kelas OWNED BY public.d_kelas.id;


--
-- Name: seq_soal_dtl; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_soal_dtl
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999999999999
    CACHE 1;


ALTER TABLE public.seq_soal_dtl OWNER TO postgres;

--
-- Name: seq_soal_dtl; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seq_soal_dtl OWNED BY public.f_soal_dtl.seq_soal_dtl;


--
-- Name: seq_soal_hdr; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_soal_hdr
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999999999
    CACHE 1;


ALTER TABLE public.seq_soal_hdr OWNER TO postgres;

--
-- Name: seq_soal_hdr; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seq_soal_hdr OWNED BY public.f_soal_hdr.id_ujian_hdr;


--
-- Name: seq_subkelas; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_subkelas
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999
    CACHE 1;


ALTER TABLE public.seq_subkelas OWNER TO postgres;

--
-- Name: seq_subkelas; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seq_subkelas OWNED BY public.d_subkelas.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    uuiduser character varying(40) DEFAULT gen_random_uuid() NOT NULL,
    uname character varying(50) NOT NULL,
    pword character varying(100) NOT NULL,
    fname character varying(100),
    role character varying(5),
    nis character varying(10),
    nip character varying(20),
    st_generate character varying(5),
    createdate timestamp without time zone DEFAULT now(),
    updatedate timestamp without time zone,
    updateuser character varying(50),
    createuser character varying(50),
    kode_guru character varying(20)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: d_kelas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_kelas ALTER COLUMN id SET DEFAULT nextval('public.seq_kelas'::regclass);


--
-- Name: d_mata_pelajaran id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_mata_pelajaran ALTER COLUMN id SET DEFAULT nextval('public.seq_id_mapel'::regclass);


--
-- Name: d_subkelas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_subkelas ALTER COLUMN id SET DEFAULT nextval('public.seq_subkelas'::regclass);


--
-- Name: d_ujian id_ujian; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_ujian ALTER COLUMN id_ujian SET DEFAULT nextval('public.seq_id_ujian'::regclass);


--
-- Name: f_jawaban_siswa_dtl seq_jawaban_siswa_dtl; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_dtl ALTER COLUMN seq_jawaban_siswa_dtl SET DEFAULT nextval('public.seq_jawaban_siswa_dtl'::regclass);


--
-- Name: f_jawaban_siswa_hdr id_jawaban_siswa; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_hdr ALTER COLUMN id_jawaban_siswa SET DEFAULT nextval('public.seq_jawaban_siswa_hdr'::regclass);


--
-- Name: f_soal_dtl seq_soal_dtl; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_dtl ALTER COLUMN seq_soal_dtl SET DEFAULT nextval('public.seq_soal_dtl'::regclass);


--
-- Name: f_soal_hdr id_ujian_hdr; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_hdr ALTER COLUMN id_ujian_hdr SET DEFAULT nextval('public.seq_soal_hdr'::regclass);


--
-- Data for Name: d_guru; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.d_guru (uuidguru, nama_guru, gender, tanggal_lahir, tempat_lahir, nip, kode_mata_pelajaran, kode_guru) FROM stdin;
2abc901b-facb-4cfc-8929-6fc7cdb9a9f8	Ade Suratno, S.Pd.	L	\N	\N	\N	\N	GSMADKP003
e796d168-cfdd-47ff-a644-6c2717a36319	Adi Apandi, S.Pd.	L	\N	\N	\N	\N	GSMADKP004
0c33d480-5ad7-4263-8ca8-a20bf9f6c200	Adin Surachman, S.Pd.Kim.	L	\N	\N	\N	\N	GSMADKP005
54756b52-5c3c-4190-ae5e-2a00041fc901	Ahmad Zakki, S.Pd.	L	\N	\N	\N	\N	GSMADKP006
dbe3b902-f772-4931-accc-1f0c4c4ff22a	Ani Purwandani, SE	P	\N	\N	\N	\N	GSMADKP007
837775f9-95bd-40ca-ad8e-380b36e60ccc	Anikh Dewiyanti, S.Pd.	P	\N	\N	\N	\N	GSMADKP009
ce1f0282-2640-42e6-aaa5-125b6386173d	Annisah Nur Amaliyah, S.Sos, M.Pd.	P	\N	\N	\N	\N	GSMADKP011
37349a3d-a5ae-4bc0-acd5-6541884589c6	Ati Rosmiyati, M.Pd.	P	\N	\N	\N	\N	GSMADKP012
7ae5ab20-2ccd-4908-a65e-baf87d5bc466	Chaerih Nurlinda Sari, S.Pd	P	\N	\N	\N	\N	GSMADKP013
e2c63a2f-cd45-45b9-a800-de1b1f46f1ce	Dewi Puspitawati, S.Pd	P	\N	\N	\N	\N	GSMADKP014
b61eb852-bab2-462d-975d-5d664b480deb	Dinda Lovi	P	\N	\N	\N	\N	GSMADKP015
455ab601-1cd8-46e0-90ba-58489bcfc2ab	Dra. Hj. Juju Juhaeriah, M.M.	P	\N	\N	\N	\N	GSMADKP016
c5109e11-bdff-4ca2-89c7-ad0e13a57659	Dra. Rachmadiana Z.A	P	\N	\N	\N	\N	GSMADKP017
7ed50ee8-a0c6-44f0-be7e-07d8eb1ee0de	Dra. Wahyu Tresnani	L	\N	\N	\N	\N	GSMADKP018
4f76f47f-4dfa-42bd-9fc3-7e5cc43db4eb	Drs. Agus Mulyatno	L	\N	\N	\N	\N	GSMADKP019
484b7da3-87e8-4d66-855f-1091c3be88ea	Drs. Dadang Supardan	L	\N	\N	\N	\N	GSMADKP020
bbb4e085-c2dc-44ca-a128-1212423a72fe	Drs. Makbul	L	\N	\N	\N	\N	GSMADKP021
ac06b0ad-e88a-4aa5-8492-9d803bb15f77	Drs. Mohamad Rosidi, M.M.	L	\N	\N	\N	\N	GSMADKP022
e11fc966-e734-4f33-906d-a730d1f841db	Duha Yasin Al Asyari, S.PdI	L	\N	\N	\N	\N	GSMADKP023
b84a6544-6475-4b06-a687-0ae45ac05891	Dwesnita Lintang Langit, S.Pd	P	\N	\N	\N	\N	GSMADKP024
ff546b98-162e-4901-a323-89c157d83427	Eli Susilawati, S.Pd.	P	\N	\N	\N	\N	GSMADKP025
b53de3f2-fb15-47a2-a06e-b396b98c016a	Epih Purnamasari, M.Pd.	P	\N	\N	\N	\N	GSMADKP026
974e2ae1-1887-441b-a6a9-f6f48d30b582	Faturochman, S.Pd	L	\N	\N	\N	\N	GSMADKP029
296adbdd-eaa7-461d-be36-03b589d32764	Fifi Magfiroh, S.Sos., M.M.	P	\N	\N	\N	\N	GSMADKP030
14d5c145-5b06-4414-a241-e4eb258d45e2	H. Ali, S.Pd.	L	\N	\N	\N	\N	GSMADKP031
69bb7c49-b915-4e17-9c13-9a15162f945a	H. Dede Solikhin, S.Pd, M.Pd	L	\N	\N	\N	\N	GSMADKP032
aaa26356-7815-4556-9ce8-b3830beff8ca	H. Markana, M.Pd	L	\N	\N	\N	\N	GSMADKP033
c637725e-5202-4e6a-a453-9df8428d1db9	Hj. Asri Nopalia, S.H.	P	\N	\N	\N	\N	GSMADKP034
7b6e4dae-ab21-49d4-bccc-8e325c21bf8e	Hj. Fifi Fikriyah, S.Pd.	P	\N	\N	\N	\N	GSMADKP035
048353b0-e0e1-4772-8187-6a59db79c1ea	Hj. Nana Yohana, S.E., M.Pd.	P	\N	\N	\N	\N	GSMADKP036
e9de6186-32db-4ed4-8ca7-117daeea4875	Hj. Titi Atiyah Diniawati, S.Pd.	P	\N	\N	\N	\N	GSMADKP037
7237c82f-8066-458d-942a-e45f812f1f9a	Ima Halimatusyadiah, M.Pd	P	\N	\N	\N	\N	GSMADKP038
736f00a4-e6a6-4e61-9ff3-0e27e01c13d0	Iman Abdul Rahmat, S.Pd	L	\N	\N	\N	\N	GSMADKP040
4ed13fb5-ea1d-4c8e-8227-015796060b63	Indri Leomita, S.Pd	P	\N	\N	\N	\N	GSMADKP042
d937878e-1163-48e0-a887-9dd972a1e359	Indrie Sabatinie, S.Pd., M.Pd.	P	\N	\N	\N	\N	GSMADKP043
65435479-4781-4d05-9eed-7309ebdb49a6	Jujum Jumerah, M.Pd.	P	\N	\N	\N	\N	GSMADKP045
95645ff0-6a05-4373-8939-3b2628696231	Laely Mafruhah, S.Pd.	P	\N	\N	\N	\N	GSMADKP047
4e5f12bc-ba34-43bf-8c66-1c0cf49b2132	Luhur Riandi T, S.Pd.	L	\N	\N	\N	\N	GSMADKP048
d0ebedca-c866-4f34-9b19-1fe624119366	M. Dedi Manfaluthi, M.Pd	L	\N	\N	\N	\N	GSMADKP049
cd1f6c2f-24a7-48b8-82be-e13290986e98	Maysaroh, S.Pd.	P	\N	\N	\N	\N	GSMADKP050
2b5bcd6e-f77f-437d-ba33-7bcdb7fd1e3b	Melati Fitri, S.Pd.	P	\N	\N	\N	\N	GSMADKP052
d46cdcc3-4691-494e-9899-472aca9fd888	Mindah Wati, S.Pd	P	\N	\N	\N	\N	GSMADKP054
f27758a3-2f9a-4a94-a675-2c2beb6d3d73	Muhaimin, S.Pd.	L	\N	\N	\N	\N	GSMADKP055
aec5370e-265c-48ce-b5e7-51771c6534b2	Nartiya, S.Pd.	L	\N	\N	\N	\N	GSMADKP056
44237771-f75c-4119-b1ff-0cb9db8c8b14	Nukke Septhia Nugrawaty, S.Pd	P	\N	\N	\N	\N	GSMADKP057
3034cf0e-df4a-4dd3-82c1-6d08592eea8f	Nur Fitriyanti, S.Pd	P	\N	\N	\N	\N	GSMADKP059
e9221c4f-df89-4ce7-b11a-165bc50842dc	Nurjannah, S.Pd.I	P	\N	\N	\N	\N	GSMADKP060
4085280c-d3c9-48a3-8f8e-927c01fcfabb	Putri Wulandari, S.Pd.	P	\N	\N	\N	\N	GSMADKP061
f88ff622-4f14-4e18-9ca1-75935dcf7418	Rachmah Nazila, S.Pd.	P	\N	\N	\N	\N	GSMADKP062
f2b533d7-9118-475d-a89d-f443f2a88f0d	Reviana Irnayanti, S.Pd.	P	\N	\N	\N	\N	GSMADKP063
185e6514-7743-4fa6-8d3d-43e19230bf09	Salamah, S.Pd.I	P	\N	\N	\N	\N	GSMADKP064
71ce5b85-e7fa-44d6-b2a0-5b915a698ca6	Sari Henita, S.Pd.	P	\N	\N	\N	\N	GSMADKP065
9537e4be-baca-4d9f-9cd5-016cfb1ff0fb	Sigit Mulyoseno, S.Pd	L	\N	\N	\N	\N	GSMADKP066
a2b4b3c3-3dc0-452f-9d2b-a2d2b27ecd92	Sri Ningsih,S.PdI	P	\N	\N	\N	\N	GSMADKP067
8d986d90-4950-47aa-aded-7262ec07dc7d	Subagyo, S.Pd.	L	\N	\N	\N	\N	GSMADKP069
cfe3614f-a2f0-439e-a745-8ef9f42799b3	Suradi, S.Pd.	L	\N	\N	\N	\N	GSMADKP070
a29705a7-54a0-4433-bc24-be8639971d2e	Syaeful Apriyanto, M.Pd	L	\N	\N	\N	\N	GSMADKP071
3de0d938-d38e-4ebb-a42b-858d806f9424	Syamsul Kamal, S.Pd	L	\N	\N	\N	\N	GSMADKP073
7fcac6ef-fcf8-4ae7-8351-c725d4849933	Tarjodipuro, S.E.	L	\N	\N	\N	\N	GSMADKP074
5d2a855e-4398-4d08-ae89-4489ff566016	Titin Rohaeni, S.Pd.	P	\N	\N	\N	\N	GSMADKP075
fd0038e3-21b2-4c32-b716-03f0b1d5ad6e	Raihanza Yo	L	\N	Cirebon	G001	\N	GSMADKP001
5dd26824-1ab9-4d46-abd3-412e1271610e	Umul Mu'minin, S.Pd.	P	\N	\N	\N	\N	GSMADKP076
a0bbb2fb-0a6b-4c6a-91ec-539ed9de4739	Windari Pandanita, S.Pd.	P	\N	\N	\N	\N	GSMADKP077
d8217b1a-c911-4006-9f62-8dd978330e16	Yanti Nurmalasari, S.Pd.	P	\N	\N	\N	\N	GSMADKP078
3aee8394-419e-4f76-86c0-53ff4191b7eb	Yogi Ginanjar Jayagiri, M.Pd.	L	\N	\N	\N	\N	GSMADKP080
d015a2f1-2aed-4b9d-af0e-15bb9cadf92a	Yudi Agus Fauziansyah, M.Pd.	L	\N	\N	\N	\N	GSMADKP081
670938e2-6efb-4747-99dd-455bdb820be7	Yulianto, S.Pd	L	\N	\N	\N	\N	GSMADKP082
b512adaf-47f1-4706-b624-80e2e2a0ddd7	Zaenal Mutakin, ST	L	\N	\N	\N	\N	GSMADKP083
ef06e0a6-1daf-47cf-8e92-660ee48d890e	Annisa Maryam S.Pd	P	\N	\N		\N	GSMADKP010
0680ac93-509d-4c39-8309-7102d187bff3	A. Riyanto, S.Pd	L	\N	\N		\N	GSMADKP002
\.


--
-- Data for Name: d_kelas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.d_kelas (id, kode_kelas, nama_kelas) FROM stdin;
2	\N	11
3	\N	12
8	\N	10
\.


--
-- Data for Name: d_mata_pelajaran; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.d_mata_pelajaran (id, nama_mata_pelajaran, kode_mata_pelajaran) FROM stdin;
1	Informatika	INF
3	Kimia	KIM
4	Geografi	GEO
6	Biologi	BIO
9	Pendidikan Agama Islam	PAI
10	Pendidikan Kewarganegaraan	PKN
11	Bahasa Indonesia	IND
12	Bahasa Inggris	ING
13	Pendidikan Kewirausahaan	PKWU
14	Sosiologi	SOS
15	Ekonomi	EKO
16	Sejarah	SEJ
17	Fisika	FIS
18	Bahasa Arab	ARAB
19	Bahasa Sunda	SUNDA
20	Bimbingan Konseling	BK
21	Bahasa Indonesia Tingkat Lanjut	INDLJT
2	Matematika Umum	MTKUMUM
22	Matematika Tingkat Lanjut	MTKLJT
23	Sejarah Tingkat Lanjut	SEJLJT
7	Pendidikan Jasmani Olahraga dan Keterampilan	PJOK
8	Seni Budaya	SEN
\.


--
-- Data for Name: d_penempatan_mapel_guru; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.d_penempatan_mapel_guru (uuidguru, uuidpenempatanmapel, kode_mata_pelajaran, kode_guru) FROM stdin;
fd0038e3-21b2-4c32-b716-03f0b1d5ad6e	0f68b2b5-88f0-45c3-9524-9ffe87112ba5	ARAB	GSMADKP001
0680ac93-509d-4c39-8309-7102d187bff3	c690eab3-2a65-435a-95e4-c52966772cd9	PJOK	GSMADKP002
2abc901b-facb-4cfc-8929-6fc7cdb9a9f8	65346c53-d1e5-4422-b7e0-92372c2c0303	FIS	GSMADKP003
e796d168-cfdd-47ff-a644-6c2717a36319	11154d14-e2f9-4e96-b739-694d0fca11a4	SEJ	GSMADKP004
0c33d480-5ad7-4263-8ca8-a20bf9f6c200	81a1cd06-4371-432b-b053-c16f90ae6bd3	KIM	GSMADKP005
54756b52-5c3c-4190-ae5e-2a00041fc901	53233cd9-7116-40e1-b887-07355c50fe55	IND	GSMADKP006
dbe3b902-f772-4931-accc-1f0c4c4ff22a	c5dd3670-1fda-46d2-a53e-b4d86c447414	PKWU	GSMADKP007
dbe3b902-f772-4931-accc-1f0c4c4ff22a	f5802727-2212-4a0f-8531-b0b501ad67df	EKO	GSMADKP007
837775f9-95bd-40ca-ad8e-380b36e60ccc	2233b052-286e-42d8-abb3-333678d86043	BK	GSMADKP009
ef06e0a6-1daf-47cf-8e92-660ee48d890e	0981bd2d-aeac-45d3-b565-76addbbdf059	BIO	GSMADKP010
ce1f0282-2640-42e6-aaa5-125b6386173d	707ef163-25e1-4370-a39d-6edd854a91d7	BK	GSMADKP011
37349a3d-a5ae-4bc0-acd5-6541884589c6	64d53201-f5b9-4d71-b5df-e18a8173a021	IND	GSMADKP012
7ae5ab20-2ccd-4908-a65e-baf87d5bc466	c60adedb-7a28-4728-9e16-d5ad8b2933b1	SOS	GSMADKP013
e2c63a2f-cd45-45b9-a800-de1b1f46f1ce	71cde821-b368-4d8b-9079-33f30f15e86d	SOS	GSMADKP014
b61eb852-bab2-462d-975d-5d664b480deb	509e0787-fd65-42b9-ab3a-dda34cd4a804	ING	GSMADKP015
455ab601-1cd8-46e0-90ba-58489bcfc2ab	bf98258b-6428-4dd3-96a9-f4c865f1e386	MTKUMUM	GSMADKP016
c5109e11-bdff-4ca2-89c7-ad0e13a57659	f10615e1-2440-4a5a-bf95-e83897f862b9	PAI	GSMADKP017
7ed50ee8-a0c6-44f0-be7e-07d8eb1ee0de	46642625-366f-4722-a973-37fe272a61ac	ING	GSMADKP018
4f76f47f-4dfa-42bd-9fc3-7e5cc43db4eb	2fe7e27e-4e57-4c05-bd27-128e2cfe9ba5	IND	GSMADKP019
484b7da3-87e8-4d66-855f-1091c3be88ea	dbbc51de-ed4d-4d9a-817b-ae6373fc6394	SEN	GSMADKP020
bbb4e085-c2dc-44ca-a128-1212423a72fe	87190c04-1ca8-4b89-9520-66ebf9a7b49d	PKN	GSMADKP021
ac06b0ad-e88a-4aa5-8492-9d803bb15f77	586da305-e040-4dd6-bb23-8525f90020bb	ING	GSMADKP022
e11fc966-e734-4f33-906d-a730d1f841db	990fe1ed-b18f-4f57-9537-fe29752a9144	PAI	GSMADKP023
b84a6544-6475-4b06-a687-0ae45ac05891	0ca3f6ee-3c92-42bd-90b9-472b553d68a6	SEN	GSMADKP024
ff546b98-162e-4901-a323-89c157d83427	b923e60e-0f80-463c-9c36-66b0f27f20fd	PAI	GSMADKP025
b53de3f2-fb15-47a2-a06e-b396b98c016a	37093cd8-fdf5-425d-813d-d930cd2b8b55	SUNDA	GSMADKP026
b53de3f2-fb15-47a2-a06e-b396b98c016a	165e0b69-582b-4aff-8d57-2b8d46a86763	MTKLJT	GSMADKP026
b53de3f2-fb15-47a2-a06e-b396b98c016a	2d0d74cf-cba3-4fa6-8c03-1807780af3c1	MTKUMUM	GSMADKP026
974e2ae1-1887-441b-a6a9-f6f48d30b582	ff473d12-f239-4c33-9deb-fa01f8b2a97b	PJOK	GSMADKP029
296adbdd-eaa7-461d-be36-03b589d32764	5aa8ea59-b7b2-49f6-bd41-e4bc570ab373	SOS	GSMADKP030
14d5c145-5b06-4414-a241-e4eb258d45e2	5993d571-8672-4bd6-ba21-234ba0947fd2	FIS	GSMADKP031
69bb7c49-b915-4e17-9c13-9a15162f945a	29e2675d-b25a-402a-bb3f-9cd089d79c92	FIS	GSMADKP032
aaa26356-7815-4556-9ce8-b3830beff8ca	26944f5e-fca5-4d6e-9f06-840e46db4bb9	BIO	GSMADKP033
c637725e-5202-4e6a-a453-9df8428d1db9	453806d1-47e9-410f-af7d-dff1bb8cfe21	PKN	GSMADKP034
7b6e4dae-ab21-49d4-bccc-8e325c21bf8e	6d38e0b6-ef7c-4668-969c-f55398867d34	GEO	GSMADKP035
048353b0-e0e1-4772-8187-6a59db79c1ea	1049916c-619e-44bb-8cce-0d5bb437db89	EKO	GSMADKP036
e9de6186-32db-4ed4-8ca7-117daeea4875	212afa08-6977-4bea-b671-d5ffced8b2fb	KIM	GSMADKP037
7237c82f-8066-458d-942a-e45f812f1f9a	02361392-7abe-4cbd-83b9-1668b9a6b3be	EKO	GSMADKP038
7237c82f-8066-458d-942a-e45f812f1f9a	2511d51f-344f-4f45-bf1e-17eb659a0039	PKWU	GSMADKP038
736f00a4-e6a6-4e61-9ff3-0e27e01c13d0	75965e15-53b6-4d3f-b510-243c381e3288	SUNDA	GSMADKP040
736f00a4-e6a6-4e61-9ff3-0e27e01c13d0	4a47ada6-3097-47c9-9ec3-71674e1a78e3	MTKUMUM	GSMADKP040
4ed13fb5-ea1d-4c8e-8227-015796060b63	ca6f63f0-2e0d-4e17-9eaa-a19a62f29028	SEN	GSMADKP042
d937878e-1163-48e0-a887-9dd972a1e359	686feb8c-11f1-4e89-aadf-9f8eea5d4e48	KIM	GSMADKP043
d937878e-1163-48e0-a887-9dd972a1e359	07d3cabc-5ef8-4945-b489-ac3f6b9869f6	PKWU	GSMADKP043
65435479-4781-4d05-9eed-7309ebdb49a6	7df0743c-7758-4611-aca3-434cb0c87d10	BIO	GSMADKP045
95645ff0-6a05-4373-8939-3b2628696231	6d7196e5-a685-451b-ad64-f736167a51de	MTKLJT	GSMADKP047
95645ff0-6a05-4373-8939-3b2628696231	3217de0a-e177-4048-a8a1-57121bb09b60	MTKUMUM	GSMADKP047
4e5f12bc-ba34-43bf-8c66-1c0cf49b2132	38a36960-1cd2-41e0-bec5-99c9295aba65	BK	GSMADKP048
d0ebedca-c866-4f34-9b19-1fe624119366	3b1de9f5-e84b-423c-b2bb-7a4c9b11251a	ING	GSMADKP049
cd1f6c2f-24a7-48b8-82be-e13290986e98	44a6e1a4-1c1f-479c-90b7-a1fae4b66244	SEJ	GSMADKP050
cd1f6c2f-24a7-48b8-82be-e13290986e98	8c2e0284-dbb8-4a70-8367-0b24e701ffd1	SEJLJT	GSMADKP050
2b5bcd6e-f77f-437d-ba33-7bcdb7fd1e3b	8a6f75c8-6d9e-4d50-befc-999da7dbcc5b	MTKLJT	GSMADKP052
d46cdcc3-4691-494e-9899-472aca9fd888	e344138d-0c43-45ad-848d-274f00dc9b50	IND	GSMADKP054
d46cdcc3-4691-494e-9899-472aca9fd888	6ffe04b4-a87f-46d0-9145-e7dbabe8508c	INDLJT	GSMADKP054
f27758a3-2f9a-4a94-a675-2c2beb6d3d73	66ce67b1-48d8-4f8c-bca5-65c30fb4a113	KIM	GSMADKP055
aec5370e-265c-48ce-b5e7-51771c6534b2	0ba5e647-3b4a-4850-8cc4-8014fbefdcb6	FIS	GSMADKP056
44237771-f75c-4119-b1ff-0cb9db8c8b14	a23635c1-88f5-4cfc-81a4-731332b61117	ING	GSMADKP057
3034cf0e-df4a-4dd3-82c1-6d08592eea8f	be83d470-7e37-4599-875c-030412bd66db	SUNDA	GSMADKP059
3034cf0e-df4a-4dd3-82c1-6d08592eea8f	5a5153af-7126-4fa2-97de-f7521ea2ab76	MTKUMUM	GSMADKP059
e9221c4f-df89-4ce7-b11a-165bc50842dc	c9f4bca4-cca6-4654-95c9-9dc9dcb21a0b	MTKUMUM	GSMADKP060
4085280c-d3c9-48a3-8f8e-927c01fcfabb	bf107b3c-62c6-4b4e-b3cb-61aa420ee63e	SEJ	GSMADKP061
f88ff622-4f14-4e18-9ca1-75935dcf7418	c2dff03c-5b36-4a1a-9163-0a8adbe228b7	MTKUMUM	GSMADKP062
f2b533d7-9118-475d-a89d-f443f2a88f0d	a4e5fd9e-9fd4-4ebb-ade2-7f15d1b15223	BK	GSMADKP063
185e6514-7743-4fa6-8d3d-43e19230bf09	8cfc482a-6fe8-4807-a8ef-883548a080a8	PAI	GSMADKP064
71ce5b85-e7fa-44d6-b2a0-5b915a698ca6	01f0670d-460a-49d8-bc00-f0862b2e79b6	MTKUMUM	GSMADKP065
9537e4be-baca-4d9f-9cd5-016cfb1ff0fb	8ab4b08c-0caa-411a-8785-da5393576211	IND	GSMADKP066
a2b4b3c3-3dc0-452f-9d2b-a2d2b27ecd92	2ba9c83a-b29d-44da-8a08-5e951c276ea6	MTKLJT	GSMADKP067
a2b4b3c3-3dc0-452f-9d2b-a2d2b27ecd92	ae852a2f-0626-4270-95ad-b4a17f2b8335	MTKUMUM	GSMADKP067
8d986d90-4950-47aa-aded-7262ec07dc7d	a0997e96-ad6a-4139-ad57-2fab9e95dc24	BIO	GSMADKP069
cfe3614f-a2f0-439e-a745-8ef9f42799b3	c69241d9-babb-4bf4-9f0c-9fb169b54790	ARAB	GSMADKP070
a29705a7-54a0-4433-bc24-be8639971d2e	4f07358f-6438-45af-bbec-475a9152a334	IND	GSMADKP071
3de0d938-d38e-4ebb-a42b-858d806f9424	f61d13a0-69b0-439d-a6a3-a43128b040f4	PJOK	GSMADKP073
7fcac6ef-fcf8-4ae7-8351-c725d4849933	10948cfe-b3bc-4b65-8e79-dff61b9188aa	EKO	GSMADKP074
5d2a855e-4398-4d08-ae89-4489ff566016	fd031e59-8314-4787-859d-3567a668d334	SUNDA	GSMADKP075
5dd26824-1ab9-4d46-abd3-412e1271610e	2befba1c-d09c-42ea-8526-e70f86f36301	BK	GSMADKP076
a0bbb2fb-0a6b-4c6a-91ec-539ed9de4739	1da07bfa-6b12-467b-b592-7753d899f6bc	BK	GSMADKP077
d8217b1a-c911-4006-9f62-8dd978330e16	ca758bbd-a6d8-4ae0-ab84-cf5a5adf173b	GEO	GSMADKP078
d8217b1a-c911-4006-9f62-8dd978330e16	12e2be3f-e85b-41cb-a533-ab251d25e928	SEJ	GSMADKP078
3aee8394-419e-4f76-86c0-53ff4191b7eb	f933eb9d-f106-4f36-b256-e42fc5042867	PJOK	GSMADKP080
d015a2f1-2aed-4b9d-af0e-15bb9cadf92a	eab8f760-47f4-4625-87ad-2396a7eaf2f8	GEO	GSMADKP081
670938e2-6efb-4747-99dd-455bdb820be7	81a9abc0-52c2-4772-a381-eed545cad8f5	PKN	GSMADKP082
b512adaf-47f1-4706-b624-80e2e2a0ddd7	f1124b6a-a7ba-4333-8fdc-9d4f202a190e	INF	GSMADKP083
\.


--
-- Data for Name: d_penempatan_siswa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.d_penempatan_siswa (uuidpenempatansiswa, uuidsiswa, nama_siswa, kode_tahun_ajaran, id_kelas, id_subkelas) FROM stdin;
\.


--
-- Data for Name: d_siswa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.d_siswa (uuidsiswa, nama_siswa, gender, nis, tanggal_lahir, tempat_lahir, st_active, id_kelas, id_subkelas, kode_tahun_ajaran, nisn) FROM stdin;
a7ae64fa-5c1f-45fd-8e6b-6f276d2ecaaf	ABDUL BASYITH	L	242510073	\N	\N	\N	2	18	2526	0098517495
2df3041b-6f04-40a6-b013-a08fbf702401	AHMAD FAUZAN AZMI	L	242510397	\N	\N	\N	2	18	2526	0095742061
25cbd253-599c-4a25-bd0c-849230df8e7b	ALLIF RISKI MAULANA	L	242510362	\N	\N	\N	2	18	2526	0091332562
65e22b38-3506-4a02-aa61-0a5a18b71bd2	AUFAL MAROM	P	242510114	\N	\N	\N	2	18	2526	0095964047
603d968b-8353-4bbc-8951-96c25f13fd0a	AYUNITA	P	242510115	\N	\N	\N	2	18	2526	0088504403
f1cd5cf1-df7e-4513-8bf8-0bd56c37cc0f	BAGUS YUDA ADITIA	L	242510258	\N	\N	\N	2	18	2526	0088784688
9e4c59af-be64-44db-bb22-e9267184c5d1	CINTARA NURHANIPAH	P	242510116	\N	\N	\N	2	18	2526	0085503725
dab727fb-80fa-411f-ba0f-94c114efa26d	DEDEN WINDU MARDIKA	L	242510045	\N	\N	\N	2	18	2526	0086331996
64ff1297-5b75-4986-96bc-cb8bdbbb440a	DINI WAHYUNI	P	242510226	\N	\N	\N	2	18	2526	0085279535
515f358e-912f-4b9d-92dd-792e93ca3dac	EVA ADITYA	P	242510083	\N	\N	\N	2	18	2526	0086949432
d95ffa6b-30b9-4527-a0d0-1925dea89168	EVAN ARDIANSSA DAISMAN	L	242510048	\N	\N	\N	2	18	2526	0091760802
50aef286-ea97-467e-a4bd-d0311fc9c1e0	GEVISA AGNIE QWEEZEL AZELALITA	P	242510085	\N	\N	\N	2	18	2526	0094175708
7320e5a3-49ea-4d2c-8a0c-a0214de20e33	GIEFRIE TRI MULIA APRIANSYAH	L	242510014	\N	\N	\N	2	18	2526	0097833852
155783fb-b14d-4997-9841-b4e1f63b1f4d	HAWA RIZQINA SHOLIHA	P	252611	\N	\N	\N	2	18	2526	0095301272
7ac585d7-776e-4c15-b324-64d4872009d6	HAYKAL RIDJO PRATAMA	L	242510266	\N	\N	\N	2	18	2526	0096243954
8291d9aa-8394-4d0d-b08a-9a7799ee336f	JIHAN SYIFA TUSSA'DIYAH	P	242510195	\N	\N	\N	2	18	2526	0095762750
12054dad-d184-41be-b347-4b7789eb389a	LINDA RAHAYU	P	242510232	\N	\N	\N	2	18	2526	0084689125
f33bd6ee-b074-49f0-8dd4-2b41000fc09e	AAN MAHENDRA	L	252610001	\N	\N	\N	8	1	2526	3108809696
7dbfbad0-d538-4be2-9c80-517f3feaed86	ADHI PIRDAUS	L	242510181	\N	\N	\N	2	31	2526	0086262174
f2853eb6-cebe-4b44-88c8-ac8ed1b3a95d	AKHMAD FERIYANSYAH	L	242510183	\N	\N	\N	2	31	2526	0099170808
65bdd8db-d7f9-445e-9f27-1e6947ee509d	ARIEF ABDULLAH	L	242510041	\N	\N	\N	2	31	2526	0096790664
58b7b30d-ab4e-40a6-8a3b-89b21c1cb165	AURA ZAHRA KIRANI	P	242510365	\N	\N	\N	2	31	2526	0083148274
e44e6283-0c12-4cae-95de-d10495830a4b	CAHYA NINGRUM SUGHESTI	P	242510331	\N	\N	\N	2	31	2526	0091062736
998afd81-8dde-4432-b0ab-6cae1f134e5a	DAFA ALMER DZAKY	L	242510367	\N	\N	\N	2	31	2526	3090693079
27293d6c-f454-44d5-bc82-1c0211380891	DEWI SYILVA ANGGRAENI	P	242510404	\N	\N	\N	2	31	2526	0097848220
945e14e0-a058-4531-8b70-4f94414d0515	DIMAS AGUNG ABIMANYU	L	242510297	\N	\N	\N	2	31	2526	0082683179
70c0110f-ffc1-4c7c-9f6a-4d96c7d63a62	ELGA HALISKIYA	P	242510406	\N	\N	\N	2	31	2526	0073651382
18143463-2151-468b-99e1-1acf704099d9	FADILA ANA BAWIYAH	P	242510191	\N	\N	\N	2	31	2526	3096930081
4ffe4cd3-0454-41f0-ad93-6e5f6d32a6e0	FARUQ ARSALAN	L	242510228	\N	\N	\N	2	31	2526	0093946110
6c2b696e-392f-4f2d-8fb2-0cb79fb5a2b0	MOHAMAD AZHAR QOSHIDY	L	252610220	\N	\N	\N	8	4	2526	0099020018
f0fc28f2-86d3-47e5-aca9-053446c392dd	MUHAMAD FATHIR AL-FARIZKY	L	252610232	\N	\N	\N	8	4	2526	0096730698
2fb5fd19-17cd-4b9d-a402-f3180e65da80	MUHAMAD IQBAL DIPHDA	L	252610457	\N	\N	\N	8	4	2526	0102779302
5a0e333f-b046-487f-971c-724a934d5e95	MUHAMMAD RAIHAN	L	252610244	\N	\N	\N	8	4	2526	0092684357
4d1c4fd8-05f8-4cf2-9274-faace79bef46	NABILA SEPTIANI	P	252610256	\N	\N	\N	8	4	2526	0106625465
305e67ee-575f-4c0f-bf5a-8700d609ecd5	NANDIKA PRATAMA	L	252610268	\N	\N	\N	8	4	2526	0106890807
968aa1be-0333-425d-9562-df1c5e343868	NAZWA SAKINAH	P	252610548	\N	\N	\N	8	4	2526	3102084366
44ddd2c9-d06e-4944-89cf-4613d6801636	NOVITA SARI	P	252610280	\N	\N	\N	8	4	2526	3095166818
525d8aee-1fe0-44c2-9fb9-857a4b38ef92	PENGGALA PUTRA	L	252610292	\N	\N	\N	8	4	2526	3102502017
8591bffe-399a-4e58-8641-7819d648a3dd	RAHADIAN NAJMAH TOHA	P	252610304	\N	\N	\N	8	4	2526	3090266989
97800783-4345-40c0-9328-ca34e5b38dda	REHAN MUBAROKH	L	252610316	\N	\N	\N	8	4	2526	0094813007
420e3051-ead5-4116-903f-ce44f96fbaa6	RIYAHNI	P	252610328	\N	\N	\N	8	4	2526	0086577903
5754b92d-6038-4a39-aff7-017667a0c38b	SAFA NURMAULIDA	P	252610340	\N	\N	\N	8	4	2526	0101448202
9ef6ab17-2d42-4403-a19e-f71b194e6f9e	SELFFIA SUKMA AYU	P	252610352	\N	\N	\N	8	4	2526	0094354860
e0208a2e-b5ed-4147-83c4-787d2121da10	SELFI NOVIANTI	P	252610537	\N	\N	\N	8	4	2526	3093617935
3998f0f0-f8f3-4d05-93a1-c3b22e067bd5	SITI KHODIJAH	P	252610364	\N	\N	\N	8	4	2526	3104171168
995d7d6f-9637-4867-990f-a11cf53a43e8	SRI FADILAH	P	252610376	\N	\N	\N	8	4	2526	0091513092
5347255a-c21b-4405-8ef4-df2a9133ee66	SYERILL KAYYASAH NUR ROHMAN	P	252610388	\N	\N	\N	8	4	2526	3100877701
0bebd18c-fd99-49e4-acfa-9732d6813360	TEGUH ARDIANSYAH	L	252610513	\N	\N	\N	8	4	2526	0107540289
f8eba36a-ee20-48fb-b5df-9d8aa3acfcbe	TIYAS NUR AULIA	P	252610400	\N	\N	\N	8	4	2526	0093895498
2464652a-5654-4895-989f-465582377db3	VIRA PRIYANKA	P	252610412	\N	\N	\N	8	4	2526	0104517917
9a216deb-5fff-4420-a222-dd29d86e4ae3	ZAHRA	P	252610424	\N	\N	\N	8	4	2526	0104295901
55af53d7-fdb3-49ce-9b6f-1e91b9195332	MUKHAMMAD YAUMILAZHAR	L	252610249	\N	\N	\N	8	11	2526	0094181467
3a76cefe-3e60-4705-b9a7-3a63383d2d9a	NAESA AYU LISTIANINGSIH	P	252610261	\N	\N	\N	8	11	2526	0104951271
ebeea1b2-452a-490e-885f-f3ea0ddebc51	NAZWA AULIA AZZAHRA	P	252610273	\N	\N	\N	8	11	2526	0107217447
9f2f5ea4-9425-494a-b846-aa352f660fc4	NURHAYATI	P	252610285	\N	\N	\N	8	11	2526	0101701756
5fd1bc89-6f8c-4588-99de-53f68d87f9e0	QOIRUN NISA	P	252610297	\N	\N	\N	8	11	2526	0103950440
a00c8fc9-f80c-40b7-af77-6b6cddc00be9	RAFFIDHAN ISLAMI PASHA	P	252610521	\N	\N	\N	8	11	2526	0105510704
9243f95d-a3fc-45f5-ac0a-e1c299c85db1	RAHMA SAFFINA	P	252610309	\N	\N	\N	8	11	2526	0099256858
14f0f1d5-11ca-4b39-832d-196b5368d243	RIFKY MAULANA HAKIM	L	252610321	\N	\N	\N	8	11	2526	0105606714
6bfb9001-c757-4523-bdc4-7019c4403c14	RUKIYATUS SOLEKHA	P	252610333	\N	\N	\N	8	11	2526	0092412306
05662a4a-8e00-438d-912f-06a59e45fdb3	SALSABILA	P	252610345	\N	\N	\N	8	11	2526	0109015496
39cb86ac-34a8-48b8-a26e-b16235be5c57	SIGIT JAELANI	L	252610357	\N	\N	\N	8	11	2526	0094219998
41aa6b53-e274-4273-9845-81e72dbb3c65	SISKA AULIA	P	252610517	\N	\N	\N	8	11	2526	0092590960
8d657e2f-d598-4ab5-9df2-e03e245b4c81	SITI NAZMA NURVIA	P	252610369	\N	\N	\N	8	11	2526	3103294089
439ccbfe-69c4-4b4b-a00c-b17a4bcf34c0	SULAEMAN HIDAYAT PUTRA RAMADAN	L	252610381	\N	\N	\N	8	11	2526	0098856379
93c05079-1612-4364-aee7-df31009c03f1	TEGAR FIRMANSYAH	L	252610393	\N	\N	\N	8	11	2526	0101839518
7bf539de-b78d-4148-88f7-b07a50b76755	UBAE DIKA ZAENAL ABIDIN	L	252610405	\N	\N	\N	8	11	2526	0098837725
6decf5c9-bb79-4365-8bc1-bd15871cb36d	WIDIYA MAHARANI	P	252610417	\N	\N	\N	8	11	2526	0104521488
17fbf6a2-bd7d-4c7a-b2e7-ae55f3a00cda	WINARTI APRILIA REGINA PUTRI	P	252610533	\N	\N	\N	8	11	2526	0101059930
cf850060-dd93-43ec-85a5-8edf532ae4cf	ZHIWWA AULIA	L	252610429	\N	\N	\N	8	11	2526	3097417722
bf1d1410-ee08-43d2-acbb-59fe5f6afb00	SELINA	P	252610544	\N	\N	\N	8	5	2526	0101050636
acdca140-6d4b-40b9-a0cb-b62e36e6462f	SALMA AN NAFISAH	P	252610343	\N	\N	\N	8	8	2526	3090822508
1efb2ab8-2077-402d-8074-20ecf8643b69	SELVIA ROKANA	P	252610355	\N	\N	\N	8	8	2526	0103984384
1fa39d1b-6030-4e26-8f5a-eab67117352d	SHAFA SALSABILLA	P	252610522	\N	\N	\N	8	8	2526	0102409215
1b23f95f-f38a-424b-b7a7-a83ff95f799b	SITI MIRYANATUL MUAWANAH	P	252610367	\N	\N	\N	8	8	2526	0103269124
74e0bc75-1115-488c-b0ef-edd51195ca53	SRI WULAN	P	252610379	\N	\N	\N	8	8	2526	0114038648
718620e0-88dd-43b9-8ff2-2867a26ba5ad	TALITA AINIYA AZMI	P	252610391	\N	\N	\N	8	8	2526	0102934634
5f6d458c-1443-47e7-8740-446e6d7945ac	TRI HIZRIYANTI WAHYUNI	P	252610403	\N	\N	\N	8	8	2526	0108208999
69c28081-a3ee-41e2-8950-4f3ff19c15ff	VIKKI FIRMANSYAH	L	252610462	\N	\N	\N	8	8	2526	0094889231
6ed1f1f5-58b0-4acd-9d32-ee29ba9edd96	ADE SYIFA	P	252610010	\N	\N	\N	8	14	2526	0091852949
7960d064-a262-4349-8a28-0efb6ac76099	AFIVA SYAHIRA	P	252610022	\N	\N	\N	8	14	2526	0095837189
2ee3f9f4-fbed-473d-b1c9-f7fc65636939	AKBAR SANI	L	252610034	\N	\N	\N	8	14	2526	0103375259
ccadb49f-0b96-43ef-a3f8-022ac34467e8	ALINKA MAULANA HURAIYAH	P	252610496	\N	\N	\N	8	14	2526	0104644211
d990abf6-20bc-4d35-ae5b-0d65ad636d34	ANDIN DWI SAFITRI	P	252610046	\N	\N	\N	8	14	2526	0097000130
a33f5144-ef4c-475e-b5d9-f59e41caac6d	APRIZA	L	252610058	\N	\N	\N	8	14	2526	0092138280
43fa3ed3-d672-4876-8ad9-d5934ea5b9ff	AULIA RIZKY SALSABILA	P	252610484	\N	\N	\N	8	14	2526	0102024133
cc4b6d9a-48be-4705-aa6f-acf50b576ae7	AZKA AZIZAH ARISTAWIDYA	P	252610070	\N	\N	\N	8	14	2526	0102996499
7cf61d52-df27-4a76-94d7-ed1f9600adab	ABDUROHKMAN	L	252610465	\N	\N	\N	8	1	2526	0103216736
8458d685-db66-4047-864f-5dcbf98ce361	ADELIA REGINA PUTRI	P	252610013	\N	\N	\N	8	1	2526	3104009383
937e6a99-4174-4675-a64d-901d7d9e836e	AHMAD RIFAI	L	252610025	\N	\N	\N	8	1	2526	3105391446
8ea8fbb4-9f33-40f2-8469-42299b2450dd	ALIF AL FARIZI	L	252610037	\N	\N	\N	8	1	2526	0103272293
e4d3ab45-87c6-41b8-993e-717db297dfc7	ALYA NABILLAH ZAHRAN	P	252610502	\N	\N	\N	8	1	2526	0095096219
d0e9e787-e791-4117-91de-522cbe4f92e4	ANGEL KEY ATALLAH	P	252610049	\N	\N	\N	8	1	2526	0097547511
68b82203-9749-4db5-ac43-566e60892ce2	ASRI ROHMAH	P	252610061	\N	\N	\N	8	1	2526	0094720027
963c67f3-be60-4af4-bbf5-fcffba05a472	AZIZIAH YUANIAR	P	252610448	\N	\N	\N	8	1	2526	0111699333
24e38398-320c-4f13-b1b5-2016559fda15	CACA MEILIAH	P	252610073	\N	\N	\N	8	1	2526	0099006739
ab1c62c1-9068-4d3e-b812-17b8d450b8f7	DARA MANIS SINTA	P	252610085	\N	\N	\N	8	1	2526	0101066786
8e22de18-daac-46d1-9575-f37996f1083f	DIAN WALUYO	L	252610097	\N	\N	\N	8	1	2526	0108223876
dba36161-a9d4-4d38-8739-d693d99c1bf4	DINDA AYU AFRISYATI	P	252610444	\N	\N	\N	8	1	2526	0099662549
2894eaf0-a8f0-4aa7-a6ec-1e5a20be3dd9	ELISA RAHMAWATI	P	252610109	\N	\N	\N	8	1	2526	0106657897
f0b59ddf-2113-4494-9205-6a845de1ca87	FAIZ MAULANA IBRAHIM	L	252610121	\N	\N	\N	8	1	2526	0101684844
07179d3d-7afe-4e4f-a32e-bb7afdd21e71	FHIRENT SAFA ALZENA	L	252610451	\N	\N	\N	8	1	2526	0109027116
b0e328e3-e163-4474-b08c-84e809032b0d	FILZAH NAZIFA SUSANTO	P	252610133	\N	\N	\N	8	1	2526	0103610357
85785114-275f-4916-9a5b-e06ef29b639e	GATHAN GAULAMA ZACKY	L	252610145	\N	\N	\N	8	1	2526	0106852109
92260a63-52d5-4fa4-8cc1-008af7c7b420	HUSNUL KHOTIMAH	P	252610157	\N	\N	\N	8	1	2526	0107530887
673b296d-44f1-42bf-ada7-0966ead690c8	IQBAL MAULANA	L	252610169	\N	\N	\N	8	1	2526	0102711888
45ab5ea0-f25d-4cb1-bd0b-b5f0dc129f1a	KAYLA NURFITRIYA	P	252610181	\N	\N	\N	8	1	2526	0106450946
758cf2fa-af5d-4b12-b74b-1f314afef600	KRISHNA ABDULLAH	L	252610193	\N	\N	\N	8	1	2526	0104011378
cab0e94e-9f7f-45c4-bd57-e621ee38be45	MACHMUD ADUM	L	252610205	\N	\N	\N	8	1	2526	0102010762
0c74a5cd-7f9c-4432-a14e-3681da299ab7	MOH. IKHSAN SUGANDI	L	252610217	\N	\N	\N	8	1	2526	3108389685
7f54fc47-8cc5-43f6-aa07-86b8925425f4	MUHAMAD DZIKRY	L	252610542	\N	\N	\N	8	1	2526	0095623678
96c066fd-2067-4865-8b89-f3f6fd266f33	MUHAMAD EZAR PUTRA SUHARTONO	L	252610229	\N	\N	\N	8	1	2526	0108814855
27f49b88-20c3-4c18-9a6e-536bb68ac7ac	MUHAMMAD HAFIZH MAULANA	L	252610241	\N	\N	\N	8	1	2526	0095071743
991c6da2-bdf0-4f5a-95e9-b9d40b707b06	NABILA	P	252610253	\N	\N	\N	8	1	2526	0109950407
faf887c1-34d3-4606-8b70-fb242b1f3862	NABILA SRI RIZKI	P	252610461	\N	\N	\N	8	1	2526	3107762854
4b48bcc0-540e-4bd4-9429-5caa3e727824	NAILAH TUS SOLIHA	P	252610265	\N	\N	\N	8	1	2526	0093530054
fa651e78-cc0f-4c39-a4fd-2d37e1af56d1	NISA SHOPIA PUTRI	P	252610277	\N	\N	\N	8	1	2526	0105344801
2becba10-fccc-4836-bec9-422c406996e6	NURUL JULIANTI	P	252610289	\N	\N	\N	8	1	2526	0106234277
0ebafb0d-be4a-4958-b7df-aa0556f77974	RAFAEL FAJAR SATRIA	L	252610301	\N	\N	\N	8	1	2526	0095160153
37d19528-78c1-4b49-8fee-0fa4b437ccdc	RATINI	P	252610313	\N	\N	\N	8	1	2526	0102395305
48f3b071-5cca-4bd8-b1c3-d45ddb9b97e5	RIRIN RHOUHATULHILMI	P	252610325	\N	\N	\N	8	1	2526	0101093677
7d7192a6-0fc0-4c2f-a1b9-d7ac8e8ebedf	SABRINA SYIAM AL QORY	P	252610337	\N	\N	\N	8	1	2526	0107586212
8efbe148-35e3-4531-9211-47d11321c42d	SAEFUL FADILAH	L	252610472	\N	\N	\N	8	1	2526	3108608920
972fe7d9-a5da-4224-bfc1-98d80c465479	SASMIKA ALFAZHIRAH	P	252610349	\N	\N	\N	8	1	2526	0103341511
76a880bb-f9dc-4c41-8f92-2e8079554d52	SITI AL ZAHRA	P	252610361	\N	\N	\N	8	1	2526	0105586668
e09cf0ab-b1e1-43ab-939f-9b5535180a8e	SITI NURHASANAH	P	252610463	\N	\N	\N	8	1	2526	3109597456
49db9b76-cacf-4fa6-9624-5e76895ff020	SOFI AQIELLA ZULFAH	P	252610373	\N	\N	\N	8	1	2526	3105174476
5827c51b-5c3f-4803-869d-277a9dde13da	SYAFA DWI RIZKY	P	252610385	\N	\N	\N	8	1	2526	0098482121
ad27d6d2-5c5c-47da-8d07-c2fa43c51a65	TIARA OLIVIA DWI PUTRI	P	252610397	\N	\N	\N	8	1	2526	0106738311
7f8e09f8-3a3e-4535-b0e7-25e11e24d3fd	UNIK WAHYUNI INDRAWATI	P	252610409	\N	\N	\N	8	1	2526	0104426879
b2d7d32d-d430-437e-9d38-255951b229d5	YULIA DAMAYANTI	P	252610421	\N	\N	\N	8	1	2526	3107099545
e984a309-3ff2-441c-b072-2055d187d6a8	ZAZKIA PUTRI	P	252610436	\N	\N	\N	8	1	2526	0108879564
e56b31b4-d1e3-4e21-b9f2-da5f3ed2b87c	AANG GUNAWAN	L	252610002	\N	\N	\N	8	2	2526	0098440250
0f9d4e36-4474-4ecb-8273-f8c8488f886c	ADE DIVA ANGGARA	L	252610530	\N	\N	\N	8	2	2526	0105623908
035c7ac2-ea4d-4205-af3b-89dd6ddda287	ADELIA TREE ALISKIYA	P	252610014	\N	\N	\N	8	2	2526	3119784635
9bccb460-fa23-4404-a203-504603a2c544	AHMAD YAZID	L	252610026	\N	\N	\N	8	2	2526	0094702040
8744b7af-ae30-405a-a005-cecde0e9d7a5	ALIF NURFAIZ	L	252610038	\N	\N	\N	8	2	2526	0119128944
7a362c60-c979-4586-9d15-3bd579c3594d	ANASYA NUR FADILAH	P	252610460	\N	\N	\N	8	2	2526	0092195727
b1faa29c-aea6-4d83-84ed-2f6c7b3b99a5	ANGGI DWI RAMADAN	L	252610050	\N	\N	\N	8	2	2526	0108476540
39c8a91c-980c-4f56-a269-c9f2c6832665	ATIKA DWI AMALIATUSSOLIKHA	P	252610062	\N	\N	\N	8	2	2526	0094551850
fd4740f5-8c2c-4e2f-bb10-0a68a8c76a7d	AZKIYATU QOLBIYAH	P	252610543	\N	\N	\N	8	2	2526	3102025029
52d48fd2-c989-4cb0-a22e-b77e3d680657	CALYSTA PUTRI ERLINDA	P	252610074	\N	\N	\N	8	2	2526	0102629731
c603ed40-4a77-4a9a-aa84-7768237e176b	DAVID NUR ALAM	L	252610086	\N	\N	\N	8	2	2526	0105696045
e3ea4aca-e7da-4345-85f4-6cbb7c0a1742	DINARA CANTIKA	P	252610098	\N	\N	\N	8	2	2526	0107438819
0493330d-a6c9-4ebc-9a3d-2d5eff91f227	DINDA PUTRI LESTARI	P	252610501	\N	\N	\N	8	2	2526	0093431840
a41ab5f8-4bc3-43ae-a589-882a888e668c	ELVAN RUSTIAWAN	L	252610110	\N	\N	\N	8	2	2526	0095497855
160ff2fe-6c60-4de0-8a24-b1095841078b	FAREL NAUVAL NUGRAHA	L	252610122	\N	\N	\N	8	2	2526	0102430720
10dfba4c-fc37-4b35-93dd-5d1c0c649d1c	FITRI AWALIYAH	P	252610474	\N	\N	\N	8	2	2526	0082732474
af1f8638-815d-4c2a-88cb-fd5a1760242b	FITRI DARA FATNI	P	252610134	\N	\N	\N	8	2	2526	0091708622
9d794109-b5d5-470a-be66-f0b2ae7e6345	GAYATRI NURHAFZA	P	252610146	\N	\N	\N	8	2	2526	0096354293
51894874-84c9-4269-b1ad-a3ac55e71624	IBNU ALMUZAKIR	L	252610158	\N	\N	\N	8	2	2526	0093127310
3500ebf8-7dc8-44df-838a-2fdf7ca0740a	IRMA KARTIKA ANGGRAENI	P	252610170	\N	\N	\N	8	2	2526	0102515150
9dc1c294-3118-4941-83fa-0eee294dbb15	KAYNOVA LIYANI NINGSIH	P	252610453	\N	\N	\N	8	2	2526	0094177184
98572850-9135-4509-ba15-b2926a988c6d	KEYSA APRILIANI	P	252610182	\N	\N	\N	8	2	2526	0108731421
6b164498-1cab-4956-9c01-11ee7a37c0a5	LELY WULANDARI	P	252610194	\N	\N	\N	8	2	2526	3090742987
b1e5ff83-da72-43e5-8237-ce7413310d6c	MAR'ATUSSHOLIKHA	P	252610206	\N	\N	\N	8	2	2526	3100287330
94910eba-4c0c-4777-a1f1-138031ded07e	MOHAMAD ALENDRA AL HAQIE	L	252610218	\N	\N	\N	8	2	2526	3103719550
ac172105-c106-4e5a-80eb-2b218844810a	MUHAMAD FAHAD MUGHNI LABIB	L	252610230	\N	\N	\N	8	2	2526	0108999813
7d319817-0143-496b-a6e7-b4a0aa7e2ca5	MUHAMAD ILHAM	L	252610440	\N	\N	\N	8	2	2526	3109718991
fd48a9a8-696c-4e8f-8dd5-5fc90734faae	MUHAMMAD IBRAHIM	L	252610242	\N	\N	\N	8	2	2526	0103466469
05c11d5f-b00b-44e3-9b6c-826109a91904	NABILA AULIA SAKINAH	P	252610254	\N	\N	\N	8	2	2526	3071766537
574dec41-56b1-47d8-a68b-151d57d29c02	NAILATUL IBRIZIYYAH	P	252610491	\N	\N	\N	8	2	2526	0106863807
fb591aa0-4947-4802-b975-c76793cdc420	NAJWA NASUHAH FEBRIAN	L	252610266	\N	\N	\N	8	2	2526	0103668499
54638668-9d64-40c1-9468-285590278604	NITA AYU SALAMA	P	252610278	\N	\N	\N	8	2	2526	0104861778
d8711b37-e4ac-4049-826a-f9344660f4f6	NYAI ANITA PUTRI	P	252610290	\N	\N	\N	8	2	2526	0109036639
b061853c-0394-45e5-9066-4a2d9e1df44c	RAFINSA KHOIRUL AJAM	L	252610302	\N	\N	\N	8	2	2526	0107259811
877fefc2-e93b-4e01-9c5d-aae8d4ea3f10	RAYA NOVIANTI	P	252610314	\N	\N	\N	8	2	2526	0094567318
e19b0218-9dfe-4f19-9908-c4452a20861e	RISKA FEBRIANI	P	252610326	\N	\N	\N	8	2	2526	0101026664
46380619-f195-4640-a201-62298971d83f	SAEFUDIN	L	252610338	\N	\N	\N	8	2	2526	0097667840
ff2a1586-ee82-47ce-978d-3bae223420bc	SALSA BILA AZZAHRA ATHARIYAH	L	252610504	\N	\N	\N	8	2	2526	0108448831
7c43b2b7-c19e-47ab-882e-dfcdf59b84f2	SAVIRA PRANITA SARI	P	252610350	\N	\N	\N	8	2	2526	0095281860
1337f9d8-f6e0-4b1a-9603-83144b0e55b1	SITI ILJI'I KHUSNUL KHOTIMAH	P	252610362	\N	\N	\N	8	2	2526	0101662839
e846014b-6c1e-41f8-9d52-d679e27cb310	SITI NURHAYATI	P	252610435	\N	\N	\N	8	2	2526	0105040192
ca2d7d95-d965-4fd8-b079-e99f66acc209	SOFIE FATHUR RIZKI	L	252610374	\N	\N	\N	8	2	2526	0093978433
74604287-a0a3-4e45-868e-fd46094c53cf	SYAFARIA	P	252610386	\N	\N	\N	8	2	2526	0108220944
665d01dc-bce5-4262-91d1-8df5fafc7895	TIFFANI PUSPA ADZDINI	P	252610398	\N	\N	\N	8	2	2526	0101355574
fd45f689-dd5d-41e0-968d-67eec230fc34	VIKRI ARDIANTO	L	252610410	\N	\N	\N	8	2	2526	0105438675
db3dc81f-d8be-4e55-a16a-8493b159fd03	YUSUF FADHIL	L	252610422	\N	\N	\N	8	2	2526	0094524435
d7be03c6-9a12-4512-b8da-56c91d880fb4	ABDUL KOHARUDIN	L	252610003	\N	\N	\N	8	3	2526	0098705164
ab68912f-8a0d-4cdb-b4f2-29fb849ce83f	ADESTA RAFKA FAIRUS	L	252610015	\N	\N	\N	8	3	2526	0093838116
c6569891-6610-4b37-84e0-bc673781c1de	ADILULLAH ASSYAFI	L	252610466	\N	\N	\N	8	3	2526	0089877497
cd711d58-dd09-4cd5-8231-8fa2bcd1f39b	AHMIYATI	P	252610027	\N	\N	\N	8	3	2526	0107978420
3120f24b-fc09-419b-9854-7714b141b1b0	ALIFIA LAYINA	P	252610039	\N	\N	\N	8	3	2526	0098009253
a6be5194-0ace-48dd-b3b5-c4326b3c172b	ANGGI LAILATUSSA'ADAH	P	252610051	\N	\N	\N	8	3	2526	0097864758
011db8ad-4f9d-4f73-bb22-88fd5dc34675	ANINDYA JULIA ROCHMAN	P	252610434	\N	\N	\N	8	3	2526	0107600025
17739877-63e5-459f-ac23-5ef25195922b	AUFA BRILIANTY ASAFA	P	252610063	\N	\N	\N	8	3	2526	0107596720
cb2ba417-7dfe-450e-943b-29a3e7963f0d	BAROKAH	P	252610476	\N	\N	\N	8	3	2526	0093687936
06fc0657-2931-417e-a4c9-a8395c42c659	CICIH RAHMAWATI DEWI	P	252610079	\N	\N	\N	8	3	2526	0099230883
049478bf-8339-4683-9976-bfcb6bcfa800	DEA NURAHMA	P	252610087	\N	\N	\N	8	3	2526	0119655974
2645a377-f524-46a2-9e04-abb2fb2efa72	DINDA HERINAWATI	P	252610099	\N	\N	\N	8	3	2526	0092760326
0e948b83-1c6e-4e9d-a44e-e316c0f89339	DINI OLIVIANSAH	P	252610552	\N	\N	\N	8	3	2526	0107924982
174bba09-2320-4044-9994-014bc6a5b5f1	ENDAH LESTARI	P	252610111	\N	\N	\N	8	3	2526	0106812831
28562eb3-a73b-4e2a-b6a5-1a081e6ffb38	FARIDAH RAHMAWATI	P	252610123	\N	\N	\N	8	3	2526	0097270953
ac0f57a1-fc75-4a0e-9d4b-9c063dc19b1d	FITRI DWI MAYSAROH	P	252610135	\N	\N	\N	8	3	2526	0109530551
a0827b05-b6ec-47c8-acc2-751c31dfdbdb	GALANG SHOLEHUDIN	L	252610438	\N	\N	\N	8	3	2526	3106030582
01e08e53-17e1-4fc6-8a1f-ae5c8dd166f5	GILANG PRATAMA PUTRA	L	252610147	\N	\N	\N	8	3	2526	3102279339
9ae95e01-e601-43eb-9fcc-a02bc0f8f2bf	IDAM KHOLID	L	252610159	\N	\N	\N	8	3	2526	0103455932
72b51c4a-5612-4504-ba91-247d2d80b7c9	IRMALA	P	252610171	\N	\N	\N	8	3	2526	3103630516
5ff9f8c2-f6bd-4b62-a7f6-7f5dc7764f59	KEYSHA AYUDYA PRATAMA BUDIANI	P	252610183	\N	\N	\N	8	3	2526	0104382392
d3cab31d-862f-484a-961d-ac873aaeab53	KHAERUL AZAM	L	252610464	\N	\N	\N	8	3	2526	0105333765
ae49b150-0155-4f5e-8497-c34ec35fff82	LEVINA DITRI	P	252610195	\N	\N	\N	8	3	2526	0099377410
5601e44a-98f2-4413-9816-00dae50a2c65	MARISA RINJIANI	P	252610207	\N	\N	\N	8	3	2526	0105667702
2e998279-724f-46d3-9cb2-6f8a56a6ed1c	MOHAMAD ARYA RAHMAT HIDAYAT	L	252610219	\N	\N	\N	8	3	2526	0108040390
2dcb2d8f-1159-47f8-af72-8f8007ca4efc	MUHAMAD FAHRIZA	L	252610231	\N	\N	\N	8	3	2526	0109493743
c68b96d0-fc14-4ae8-a38e-bc709417e70b	MUHAMAD ILHAM SOLAH	L	252610546	\N	\N	\N	8	3	2526	0111672650
43e1de83-e0ea-4fd6-8f33-42a676899ff2	MUHAMMAD IKHSAN MAULANA	L	252610243	\N	\N	\N	8	3	2526	3105510750
c3c73456-13fd-4dca-8853-1c6b02de7752	NABILA DEWIANTI	P	252610255	\N	\N	\N	8	3	2526	0094055871
cf485d59-b3b0-4c63-aa22-5feb331b0731	NAJWA TUNNISA	P	252610267	\N	\N	\N	8	3	2526	0105611103
06a5cc75-37b8-4434-abd2-9a4c2b510aa9	NAOMI ASHR KURNIAWAN	P	252610437	\N	\N	\N	8	3	2526	0106648223
9202499c-dcec-4f1d-a059-8ccc9eed11ac	NOVA AYU NINGSIH	P	252610279	\N	\N	\N	8	3	2526	3099369723
417d1722-14a6-4a05-8ce1-8f3c2dacaecf	PASYA SAPUTRA	L	252610291	\N	\N	\N	8	3	2526	0097274023
7be2eb66-1556-4d4f-ab05-721e1a2b840d	RAFY HANDOYO	L	252610303	\N	\N	\N	8	3	2526	0104535153
b938d4ec-d012-4a72-9198-c7749c0e9a90	REHAN FEBRIYAN	L	252610315	\N	\N	\N	8	3	2526	0094781475
79d27980-9989-4fe2-877d-3ff91ab72f18	RITA ARLITA	P	252610327	\N	\N	\N	8	3	2526	0098041063
6dae297b-6902-4c8c-a545-f5bce54b8299	SAEFUR ROHMAN	L	252610339	\N	\N	\N	8	3	2526	0091753683
4cc65ffd-90c2-4f29-8ea9-19f30eb4088a	SASI KIRANA	P	252610458	\N	\N	\N	8	3	2526	0104641201
53f72534-430e-4ef2-ac79-1c37f3848a3d	SEFIA NISADATILA	P	252610351	\N	\N	\N	8	3	2526	0098051063
d81b2912-2def-4cff-b689-852d92e544af	SITI JULAEHA	P	252610363	\N	\N	\N	8	3	2526	3103882964
6a07d7db-8ad7-4c74-9c7d-bd2af10c55ed	SRI DEWI RAHAYU	P	252610375	\N	\N	\N	8	3	2526	3106661365
7638bc62-ced5-4ac6-86d5-e41c5b924937	SYARIF ROHMATUN	L	252610387	\N	\N	\N	8	3	2526	3093582982
c7da389a-c941-4c40-8845-13359d24829f	SYINTA SAHLA	P	252610514	\N	\N	\N	8	3	2526	0108813393
899696f7-8ca7-4e94-aad3-2738b335b643	TIO ADITIA RAMADHAN	L	252610399	\N	\N	\N	8	3	2526	0095883687
a10b49e1-09fd-43db-9176-6fbd4930d718	VIONA NURUL AZIZAH	P	252610411	\N	\N	\N	8	3	2526	0103262632
b0ab19e8-1a1b-4a00-baad-9325ad9fab56	ZAHIRA NOVITA PUTRI	P	252610423	\N	\N	\N	8	3	2526	0109293591
7723019c-12c4-4487-ad42-f2808cc20ca2	ABDUL RAHMAN	L	252610004	\N	\N	\N	8	4	2526	0108133721
20c6af27-12d3-4028-9220-e11e5196e2ad	ADINDA PUTRI JAENUDIN	P	252610016	\N	\N	\N	8	4	2526	0093431199
65040a5d-6c3f-4f6b-b6a6-bc5b0430b052	AGUNG	L	252610547	\N	\N	\N	8	4	2526	0099576018
d84f04de-399f-42ac-a636-4bfb3df77f71	AINUR ROFIK	L	252610028	\N	\N	\N	8	4	2526	0092225089
6b89fef9-67d8-43fb-970f-d9f421595b0e	ALIN NATASYA	P	252610040	\N	\N	\N	8	4	2526	3106314202
ed380cc4-5173-49cb-a4a9-dca14dba69ae	ANGGUN MAHARANI	P	252610052	\N	\N	\N	8	4	2526	0092320477
767c582c-45d1-4aa9-9328-0774b9cb4e58	ANISA AMALIA	P	252610536	\N	\N	\N	8	4	2526	0106292457
179c3129-ad89-44e5-8702-2c81d0aa1cd5	AULIA RAHMAENI	P	252610064	\N	\N	\N	8	4	2526	0104326290
c024a06f-b0b0-4498-ad97-3d60a91e1e9a	BUNGA SABRINA	L	252610492	\N	\N	\N	8	4	2526	0094797276
9b62d922-e47a-4186-9683-bd7cfd350942	CHANDRA PUTRA DINATA	L	252610076	\N	\N	\N	8	4	2526	0101137380
17c77ab0-45e2-4003-8f89-3a3e1630aebe	DEFIS ROSELA	P	252610088	\N	\N	\N	8	4	2526	0107298836
2b1b5e23-c18a-4794-ab70-c6b55f3afa34	DINDA LESTARI	P	252610100	\N	\N	\N	8	4	2526	0093770785
62d9ddbe-6485-4e5c-8807-503ba221dcc8	DZAKWAN ALFARIZA AKBAR	L	252610516	\N	\N	\N	8	4	2526	0108542649
4c403f28-498b-4530-b6e0-fd7d1db0ea1b	ERIN DIAN NOVITA	P	252610112	\N	\N	\N	8	4	2526	3106896119
c1071c22-d592-4c38-9fd0-cc6215e43115	FARIKHAH AULIA PUTRI	P	252610124	\N	\N	\N	8	4	2526	0102055296
27556c23-03bb-4b40-b15e-e0c90da12941	FITRI SEPTIYANI	P	252610136	\N	\N	\N	8	4	2526	0098060022
570a0448-e5e7-46a7-b335-b1419480fea9	GIMRIS WILDHAN FADILLAH	L	252610148	\N	\N	\N	8	4	2526	0103650062
28a42b55-10c2-47a5-b8f7-6ff3cda53d2a	GISELA OKTOVIANA	P	252610446	\N	\N	\N	8	4	2526	0105102962
27b37812-d0d2-4328-b0d1-60c2c3082d10	IHDINA INTI RAHMA	P	252610160	\N	\N	\N	8	4	2526	0108925394
e765df15-9054-4c5c-90a2-1164a6310deb	ISTI NURHAYATI	P	252610172	\N	\N	\N	8	4	2526	0106820578
ec88f8e4-530c-44cb-a9da-7c4d2939c5c5	KEYSHA JULLIA RUKMANA	P	252610184	\N	\N	\N	8	4	2526	0106971436
31ceb4fe-187d-4ec2-9075-24d8d3c8c75f	KHOTIMATUL KHUSNAH	P	252610494	\N	\N	\N	8	4	2526	0084833893
4ddd9d10-4cda-48e4-bb3a-de40479c1b11	LINA FEBRIYANTI	P	252610196	\N	\N	\N	8	4	2526	0106965128
b9e7064e-d6fa-4327-8f4b-d089afd8ff21	MARWAH ALI CASOFA	P	252610208	\N	\N	\N	8	4	2526	0105948695
40a5a3e8-6a14-4b93-a60d-cd50f986e457	ABDULLAH DZULKARNAEN	L	252610005	\N	\N	\N	8	5	2526	0104429647
6e94b669-7c02-4cd8-b4f7-fb5d6a779297	ADITHYA PUTRA ALFAREZ	L	252610017	\N	\N	\N	8	5	2526	0096412568
ef41bbaa-36fe-482c-93f1-bbc4acbe3e7f	AGUS WARDANA SAPUTRA	L	252610459	\N	\N	\N	8	5	2526	0107931771
461447e1-8010-4122-ad6a-feb3e1caaa78	AIRA DEWI TUHZAHRA	P	252610029	\N	\N	\N	8	5	2526	0107914820
7dcc3784-ec6b-430b-931a-d59a33abcc73	ALMIRA SASIKIRANA	P	252610041	\N	\N	\N	8	5	2526	3098032170
5d9a63e3-2ed2-4e88-898c-c6db4dfc1ed0	ANGGUN WANGI DWI PUTRI	P	252610053	\N	\N	\N	8	5	2526	0108296433
6915cf8a-585f-472d-8d9b-ef930b3cfc6d	ANISA RIZKY LESTARI	P	252610473	\N	\N	\N	8	5	2526	0106399349
d2a45e14-b0d6-4a84-8b5a-80e95cd3ae15	AURATUS SYIFA AZZAHRA	P	252610065	\N	\N	\N	8	5	2526	3100003078
5d18972c-acc0-46ad-9868-a85034af0dad	CHAERUL NAZWAR	L	252610498	\N	\N	\N	8	5	2526	0095288153
5aaa3212-a34a-4772-b76c-3ad34fa13ae6	CHELSYA ANGEL PUTRI	P	252610077	\N	\N	\N	8	5	2526	0101084234
7f664b44-ba80-4ce0-bc80-5285cc7a5d97	DELA APRILIA	P	252610089	\N	\N	\N	8	5	2526	0105639041
3f5a8a56-bc81-473f-851f-a69560e0127a	DINDA MAULIDAH	P	252610101	\N	\N	\N	8	5	2526	0102334236
d0e1e5c1-fa8a-4a4a-96c8-2a8f2c3904c2	DZIKRUL AKBAR	L	252610508	\N	\N	\N	8	5	2526	0095530886
c1de3818-42a2-4a86-a952-8c63c8f99c95	EUIS LISNAWATI	P	252610113	\N	\N	\N	8	5	2526	0107194795
6523b8bf-a8bb-4110-8971-ec6532c7ff36	FATIHAH NURRAHMAH	P	252610125	\N	\N	\N	8	5	2526	0097655659
e2e6a46d-18b9-40a4-acc5-e1cc73e5e50a	FITRI ZASKYA MECCA	P	252610137	\N	\N	\N	8	5	2526	0093985582
e0cb4245-2090-4283-9760-4d0cfcea3c3e	GINA LAELATUS SUROYA	P	252610149	\N	\N	\N	8	5	2526	0113309149
8a09a1b6-d159-4b3d-abfe-8e06e859a635	HAFIZ HAIDAR FAZRI	L	252610549	\N	\N	\N	8	5	2526	0104398973
9beda4de-da59-432c-bfc4-19a49c358313	ILHAM SAFARRUDIN	L	252610161	\N	\N	\N	8	5	2526	0102210192
225f2a17-724c-4405-9a3e-aaf7874548a0	ITHAN AZZAM MIHARJA	L	252610173	\N	\N	\N	8	5	2526	3106695150
734f68e7-4224-47d3-b43a-9549a74e056c	KEYSYA KEN DODO	P	252610185	\N	\N	\N	8	5	2526	0103887109
9f8f8de4-7726-49a5-a5db-64389abebe88	LINDA WIDIANI	P	252610500	\N	\N	\N	8	5	2526	0106764494
75aa344a-366b-45f5-96b7-389bcaad50da	LUCKY ADITYA AL RAFEZA	L	252610197	\N	\N	\N	8	5	2526	0097540241
754def3b-8bc5-4058-bf24-d0fb3e2c786d	MEGA ROHAYANI	P	252610209	\N	\N	\N	8	5	2526	0099196711
666841bb-8d94-471f-ae4b-dbe9f05d83bb	MOHAMAD RAFA	L	252610221	\N	\N	\N	8	5	2526	0091508060
e8fae18c-aa9c-46bf-88f3-0f2430cdf288	MUHAMAD HANAFI	L	252610233	\N	\N	\N	8	5	2526	0099787754
fcb779b9-5338-42cf-80f6-c8610e667379	MUHAMAD SAYIPUDIN	L	252610523	\N	\N	\N	8	5	2526	3103405484
07b6a0c4-423b-4469-bc5c-d5bf189e7a82	MUHAMMAD RIZKI AFANDI	L	252610245	\N	\N	\N	8	5	2526	0101828522
1140e8ee-14fe-43d1-b072-a98dd08f9c5c	NABILAH AZZAHRA	P	252610257	\N	\N	\N	8	5	2526	0109236448
f1cf96c4-407f-4910-9a1a-57414e4ea2ca	NASWA AFRIL LIA	P	252610269	\N	\N	\N	8	5	2526	3096414870
fc3a99ba-3273-488b-a485-53fce89549f3	NOVA MARLINA	P	252610488	\N	\N	\N	8	5	2526	0107304835
fad21806-4752-4f8b-8124-ae024bdc7f81	NUR AISAH	P	252610281	\N	\N	\N	8	5	2526	0106521437
e3310168-004a-4c2f-bd0b-ce92ec41b51c	PUTRI ARISKIA NIZWAH	P	252610293	\N	\N	\N	8	5	2526	0108465998
524384b9-5be5-49df-8908-ecabc7eb3a99	RAHEL NIHAAYATUN	P	252610305	\N	\N	\N	8	5	2526	0096684728
30e2050f-0927-4696-a8b2-9e5f755281cc	REZA PRANA WIJAYANTO	L	252610317	\N	\N	\N	8	5	2526	0105598063
fe48b287-f0b4-41fb-888d-739310824e1c	RIYANTI SELVIA ZAHRA	P	252610329	\N	\N	\N	8	5	2526	3105521424
4d1c1fbe-2d8a-46cb-8529-9e04a5575f01	SAFARUDIN	L	252610341	\N	\N	\N	8	5	2526	0107853691
6d31e5b4-4f20-4414-a638-5ade90e06e7f	SELLAH WANGI AMALIAH	P	252610353	\N	\N	\N	8	5	2526	0095393058
90a2450e-8bbf-4bea-b461-9da127a9fb01	SITI KHOERIYAH	P	252610365	\N	\N	\N	8	5	2526	0098744225
45b851ea-7897-4942-9794-e3cbc779c645	SRI HANDAYANI	P	252610377	\N	\N	\N	8	5	2526	0091086476
2f4bdbcf-1703-4091-8520-63b87d698102	SYFA FAUZIAH	P	252610389	\N	\N	\N	8	5	2526	3095816331
b695bb3d-6e2b-4d9a-9603-c94fd728ef98	TIARA MAULIDA	P	252610478	\N	\N	\N	8	5	2526	0096761609
0eb6283b-ed19-41c2-9e2d-0956cf805b1e	TIYAS TARI	P	252610401	\N	\N	\N	8	5	2526	0099131982
570cfef2-a41f-4993-b7c9-6765324e6634	VITA PUSPITASARI	P	252610413	\N	\N	\N	8	5	2526	3108038923
a9562638-e03e-4c13-9c6f-5e393e57009d	DZIKRUL AKBAR	L	252610425	\N	\N	\N	8	5	2526	3101186947
ecabba80-9916-4fae-8780-d1689beb1a04	ABDURRAHMAN JAMALUDIN	L	252610006	\N	\N	\N	8	6	2526	3100968398
b4fd5b9b-c27b-42c2-9273-e043dfeff3fc	ADITYA AL FARIDZI	L	252610018	\N	\N	\N	8	6	2526	0106532250
231ac7e7-d36d-4a70-8399-51ebcafed97d	AHMAD DANU REZA	L	252610506	\N	\N	\N	8	6	2526	0099664824
51bd075a-3afe-4f52-815f-a1901d991edc	AIS SYAHARA	P	252610030	\N	\N	\N	8	6	2526	0106072639
9342d0e6-00ab-4835-9d2a-f17de4d9869d	ALONA MULIA SARI	P	252610042	\N	\N	\N	8	6	2526	3115436591
2c2261a5-62e7-4c13-ad25-ffeac37ed03d	ANISA JUNIAR	P	252610054	\N	\N	\N	8	6	2526	0105898875
9fb76de5-56c1-49b5-a070-9cc110eb21ed	ARIANI SABRINA PUTRI	P	252610447	\N	\N	\N	8	6	2526	3105620613
0b57399a-e9e1-4859-a112-5123eacd0e76	AYU ALFIANI	P	252610066	\N	\N	\N	8	6	2526	0108605805
5d12ee9f-ed85-4f5b-a3c3-63f1b78e6aa9	CHILLA OCTHA VIANKIY	P	252610078	\N	\N	\N	8	6	2526	0092105100
dcb72af1-385c-4a70-a847-bd16e3f68d32	DEDI RUSDIANA	L	252610477	\N	\N	\N	8	6	2526	0103204898
357c639c-26d6-44e7-a452-def1308af3c6	DEVA ROBI SETIAWAN	L	252610090	\N	\N	\N	8	6	2526	0093749418
438f5b4a-6f6f-4f05-aa78-6c05441e2c89	DINDA NAJALY AZZURRAH	P	252610102	\N	\N	\N	8	6	2526	0103116256
478ce81d-a52a-43f1-801f-2fd8fac38683	EKASABILAH	P	252610468	\N	\N	\N	8	6	2526	0091118071
2a6ad070-dfbf-4555-a2ce-f18c0edc4f4e	EVA KHAERUNISA	P	252610114	\N	\N	\N	8	6	2526	0109307245
86d82158-1619-40e9-835c-2a004aade5c7	FAZIZATUL HAZANAH	P	252610126	\N	\N	\N	8	6	2526	0096343947
4f350d58-0da9-4cfd-9460-d13340cee690	FITRIA NUR QOLBI	P	252610138	\N	\N	\N	8	6	2526	3106093166
b02f85dd-13d0-404b-8d6d-e90010ab5640	GLORY MARIA KAYA	P	252610150	\N	\N	\N	8	6	2526	0104630781
ce8e7c3a-527b-4eaf-9fef-c2105ea9e235	HAURA HANUM MAHYA	P	252610439	\N	\N	\N	8	6	2526	3104522018
a2f3df9b-f65d-4b19-b04b-62d77b25bd48	IMANI NATASA MACHMUD	P	252610162	\N	\N	\N	8	6	2526	0102814530
b3b92a33-6575-47e8-baf7-c8901d2bdb71	JAHRATUS SIFA	P	252610174	\N	\N	\N	8	6	2526	0104007741
24d34322-0e76-4600-8eda-20ed0d6a89df	KHAERUN NISA	P	252610186	\N	\N	\N	8	6	2526	0107815697
b5718df9-b554-43e0-91d8-4a1d91915013	LISA AMELIA	P	252610445	\N	\N	\N	8	6	2526	0106514838
8c035414-e97c-43c4-9575-844862d65d32	LUTHFI KHAIRUL UMAM	L	252610198	\N	\N	\N	8	6	2526	0101337399
85622590-4228-4c76-b899-2c369ca0e298	MEKKAR WATIPUTRI	P	252610210	\N	\N	\N	8	6	2526	0107086494
1a9b250b-c452-42c6-9f02-19d26a03cb79	MOHAMMAD ZIDAN SETYO NUGROHO	L	252610222	\N	\N	\N	8	6	2526	0109065239
57986aa4-0b95-430f-acc3-51a4ed0dae3b	MUHAMAD RAFA AWLIAH FARIZZ	L	252610234	\N	\N	\N	8	6	2526	0098540864
19616cfc-ad65-4c16-ade0-d28875d247f4	MUHAMAD SUHAEL	L	252610490	\N	\N	\N	8	6	2526	0108174046
d6df539c-cab2-4b09-ba5b-87102ee7818e	MUHAMMAD RIZKI ALAMSYAH	L	252610246	\N	\N	\N	8	6	2526	3099942572
5cc07044-49be-4db5-add3-82d525419c91	NADIAH	P	252610258	\N	\N	\N	8	6	2526	0107059423
b5449834-4911-452b-af08-b7bcbd0ffd36	NAURA AZELIA	P	252610270	\N	\N	\N	8	6	2526	3091654635
e5bec9b0-15ff-48f2-86b1-a06220b5ca68	NUR FAREKHA	P	252610282	\N	\N	\N	8	6	2526	0104605995
e76708e1-7b06-4187-81d3-5f083f9bf9e9	NUR SUKMA	P	252610452	\N	\N	\N	8	6	2526	0098532869
1cf62b6c-c609-43b2-aadf-c1d30e6c12e0	PUTRI LINA	P	252610294	\N	\N	\N	8	6	2526	0108373784
bfb42b59-bcdd-4b29-a3f8-d529f6aeb465	RAHMA AYU DIA	P	252610306	\N	\N	\N	8	6	2526	3105497796
55562856-8a07-495b-9843-a95d76abbc6b	RIAZ MAULADI SOFYAN	L	252610318	\N	\N	\N	8	6	2526	0109687865
70b8fd8b-da15-4ce7-9c36-d88778ef1b07	RIZKI HAMDAN SYAKIRO	L	252610330	\N	\N	\N	8	6	2526	3093622637
cb92f91e-706e-42bb-8f6e-f9f39a35885d	SAFIRA AUDILIA PUTRI	P	252610342	\N	\N	\N	8	6	2526	0107792728
dca0063b-7d4e-4cc0-9308-d4e686027351	SELLY DWI AMANDA	P	252610354	\N	\N	\N	8	6	2526	0091027275
3dd0625b-4ee8-4b30-aa68-6ae6fa062dd6	SEVINA ASTI ZANUELA	P	252610520	\N	\N	\N	8	6	2526	0113486457
744ca18a-d9ca-46fd-b58e-badbf0595e52	SITI KHOEROTIN	P	252610366	\N	\N	\N	8	6	2526	0105711525
49960b5d-bbf1-4c5e-bde6-6c86a81567ca	SRI WULAN	P	252610378	\N	\N	\N	8	6	2526	0109433965
97632059-ec4c-48b4-813d-a32f3fc36811	SYIFA NUR ADHWAA	P	252610390	\N	\N	\N	8	6	2526	0104432808
ebb9c83a-483f-454f-9565-30b9e428c612	TRI DEWI NURAISYAH	P	252610402	\N	\N	\N	8	6	2526	0105640586
00c06a8c-e0f4-4c6f-979b-db8f37464385	VAZRIYATUL AULIA	P	252610467	\N	\N	\N	8	6	2526	0101365247
65bec35e-51fa-417b-882f-daabe9454977	WASUL ARIFIN	L	252610414	\N	\N	\N	8	6	2526	0088432589
f119aa06-f7a1-4e2e-8d76-ec611a9a6842	ZAHROTUS SITHA KASIH	P	252610426	\N	\N	\N	8	6	2526	0091740166
42fcbc15-6277-452a-9439-51d5d827e28f	ABEL RAHMAWATI	P	252610007	\N	\N	\N	8	8	2526	0108981227
969e1026-f5d2-436b-aee4-0c115e5ecf89	ADZRA RAHAJENG MALANDY	P	252610019	\N	\N	\N	8	8	2526	0107889609
9108b81c-9e7c-41a4-98b9-46c06d18bce1	AHMAD FATIH	L	252610526	\N	\N	\N	8	8	2526	0109557202
40338b58-4589-476f-99fa-841dfb08dcca	AISYAH	P	252610031	\N	\N	\N	8	8	2526	3084503064
62e671cd-2342-494a-9d15-3bcc32e74210	ALEA MILADIA RAHMAH	P	252610450	\N	\N	\N	8	8	2526	0107708572
55f3a2cd-ba10-4a57-91fa-b5d0fa69200a	ANISSA AYU LESTARI	P	252610055	\N	\N	\N	8	8	2526	0104569727
c441f9f4-c8a1-4a7f-b053-3ba201b14db7	ASIH APRILIANI	P	252610443	\N	\N	\N	8	8	2526	0091332074
016a99d2-fdf4-48ac-aadd-baba4ace9245	AYU DIA SYAFA DWIYANA	P	252610067	\N	\N	\N	8	8	2526	3094630916
b42c54bf-3a4a-425a-afeb-0c0ce68aa74c	CANTIKA MAUDI BUNGA FERDIANA	P	252610075	\N	\N	\N	8	8	2526	0105072031
35c91af1-f36d-48e6-b34c-c38c6207bf9d	DEFATUN NISA	P	252610524	\N	\N	\N	8	8	2526	0107985341
cf098bda-8080-4c8c-a5e9-987c18e10c3a	DEVARA AZKIYA RAKHA	L	252610091	\N	\N	\N	8	8	2526	0108698531
672a1790-782f-4902-b981-8163ed7b6fcc	DINDA SHOLIHATUNNISA ARYAPUTRI	P	252610103	\N	\N	\N	8	8	2526	0109490738
d5c9f879-6a8e-45b5-b783-3786f78c643b	ERVA FITROTUNNISA	P	252610539	\N	\N	\N	8	8	2526	0104712128
a1d7571b-d5f5-40e2-95ef-5c3d222cb8fe	EVI NURAFIAH	P	252610115	\N	\N	\N	8	8	2526	0092759924
fff513d7-8a60-436c-b7f3-41fd375e5718	FAZRI PERMANA	L	252610127	\N	\N	\N	8	8	2526	0097369007
49949e51-f57a-4320-86dd-04c3ed90c19b	FITRIA SEPTIANY	P	252610139	\N	\N	\N	8	8	2526	3102018031
04357a67-11f6-47fb-911d-b1dd442b1cc6	HAFIZ JIAN BATSYA	L	252610151	\N	\N	\N	8	8	2526	3091068189
bfe1d919-0b52-459b-b42a-28b2e8381d90	HILDA NURFADILLAH	P	252610495	\N	\N	\N	8	8	2526	0109109881
b15477ae-2117-4f71-a42e-95f741880d5c	IMELDA MAYRANI	P	252610163	\N	\N	\N	8	8	2526	0104309341
448c4a58-299f-49b0-a7f0-71e7b031e662	JIHAN AULIA	P	252610175	\N	\N	\N	8	8	2526	0103317222
f26dae5c-def8-42d5-b32d-893e8fac4f78	KHAERUNNISAH	P	252610187	\N	\N	\N	8	8	2526	0098815643
a1b65f66-1067-4091-8303-7e4f54745efd	M  ADITIA BINTANG PRATAMA	L	252610199	\N	\N	\N	8	8	2526	0107050873
456414f1-cf2e-4b2a-9645-ca32ccf93a0a	MARSYA AYU ANANDITA	P	252610481	\N	\N	\N	8	8	2526	0109330909
81c65f92-5eff-440f-af55-c0b89fc3cc1e	MELANI PUTRI	P	252610211	\N	\N	\N	8	8	2526	0103572906
29ea60e9-b47b-4739-b9d7-f91f1d6576c0	MOZZA NURFADILLA	P	252610223	\N	\N	\N	8	8	2526	0096882568
cc32f59c-8409-4880-852c-6f178e683300	MUHAMAD RAFI	L	252610235	\N	\N	\N	8	8	2526	0096624253
b25566f8-6b48-41df-9c98-60e7a24ee56d	MUHAMMAD ABI AL FARISI	L	252610497	\N	\N	\N	8	8	2526	0103800549
87ceb0e4-9988-4b41-bc74-56f7d012bd1a	MUHAMMAD ZAENAL FARIZ	L	252610247	\N	\N	\N	8	8	2526	0092311886
11d5db2e-0a33-45cc-a701-9ad3e18dbe9f	NADZIROH ZULFA	P	252610259	\N	\N	\N	8	8	2526	0106096416
01f5a525-9872-46ff-9bb6-8715493ba471	NAYLA LESTARI	P	252610271	\N	\N	\N	8	8	2526	0092062361
3cabe3b0-7260-41e0-8dfa-48518859c765	NUR KHALIFAH	P	252610283	\N	\N	\N	8	8	2526	0103732640
9cc36b84-bbda-47f6-a5de-4c7575b3df6b	PANGERSA FERNANDO PUTRA FERLIANA	L	252610531	\N	\N	\N	8	8	2526	0109810538
961c5cb1-b65b-4d7d-ba04-6af690e221dd	PUTRI NAWA	P	252610295	\N	\N	\N	8	8	2526	0114648674
18b5f4a1-651b-4298-a9ee-25fb1d1d0f7e	RAHMA DENIA	P	252610307	\N	\N	\N	8	8	2526	0109730768
e071da3a-8239-490c-a8d0-7c0d2c587c5e	RIBHAH MAUFUROH	P	252610319	\N	\N	\N	8	8	2526	0109281978
85dd7b66-0f83-49c6-a596-68406f6ba8c6	RIZKY ADI FIRMANSYAH	L	252610331	\N	\N	\N	8	8	2526	0101898170
5ff99ae7-2627-464d-99dc-c9bbbece0fe5	WENI NATALIYA	P	252610415	\N	\N	\N	8	8	2526	3095372541
c8ca8188-5770-4281-b3f0-67b5e8b4570f	ZAHWA NUR SYAFA'AH	P	252610427	\N	\N	\N	8	8	2526	0094082964
3042b4dc-4a9f-4dbf-b151-610c26d6289f	ADE NISA RAHMALIA	P	252610008	\N	\N	\N	8	9	2526	3101012296
c336b2ae-4b57-47e1-a971-647d4e5261f6	AERRA RIZHUKI RAMADHANI	P	252610020	\N	\N	\N	8	9	2526	0097616939
70829e70-ff81-47ab-8075-0239bab2183a	AJAHRA AUDYA FITRIYANI	P	252610032	\N	\N	\N	8	9	2526	0108799498
f5452380-eb99-4492-9384-40a7e01aec06	AKHMAD RAMADHAN	L	252610486	\N	\N	\N	8	9	2526	0107558791
59c04ad8-1079-49f3-a29a-e538aa932678	ANDIKA BAGUS SETIAWAN	L	252610044	\N	\N	\N	8	9	2526	3109172210
2b752672-b1e6-4fed-ab76-bb46a178303d	ANITA ANGGRAENI	P	252610056	\N	\N	\N	8	9	2526	0107103507
f272e55c-6202-404d-937f-a789e76a64df	ASNA MUDA'I	P	252610532	\N	\N	\N	8	9	2526	0097036510
5704d70f-06a5-4616-84fa-6dcc7e6b50c9	AYUNING TYAS PUTRI KEN UTAMI	P	252610068	\N	\N	\N	8	9	2526	0109036471
790bc1e5-d027-45e1-84c0-f7ed14595b9d	CINDY ABELIA AZAHRA	P	252610080	\N	\N	\N	8	9	2526	0107474621
bd452782-afce-4ca5-b68f-2e4b320dea51	DEVANI PUTRIA AZAHRA	P	252610528	\N	\N	\N	8	9	2526	0093102856
66361cfc-fb5a-42f7-b444-96eed9009561	DEWI AYUNI	P	252610092	\N	\N	\N	8	9	2526	0106992512
130da32b-9301-4839-94a4-834fb55ddbde	DWI ADHISTY	P	252610104	\N	\N	\N	8	9	2526	0096426241
19b4cf53-0550-436b-b44d-ad1e85c6acf1	EVLYN CANTIKA AINUNISSA	P	252610116	\N	\N	\N	8	9	2526	3108810290
a14e91a8-c1fe-4717-894d-65dbd0dd022b	FAHRI AGUSTIANTO	P	252610507	\N	\N	\N	8	9	2526	0098694366
f0017abe-0332-4949-ab68-cf33b38d84d2	FEBIYOLA	P	252610128	\N	\N	\N	8	9	2526	0104143826
d7f08a95-6238-461d-8fb3-6c3ffb5ee38f	FITRIYA	P	252610140	\N	\N	\N	8	9	2526	0108369567
75eaf2df-216a-4c29-99cd-60f7368da714	HANU PATUN ZADIDAH	P	252610152	\N	\N	\N	8	9	2526	3095584955
5924a775-8d79-44e4-9ec3-4063c6eeb722	IBNU HIDAYAT	L	252610541	\N	\N	\N	8	9	2526	0105376615
64a7eec5-1c85-4cea-9798-884f7e82c381	IMTIKHANA FEBRIANI	P	252610164	\N	\N	\N	8	9	2526	3101824651
bcee9c9a-cd68-49d8-a7f8-e924110aedc5	JOEL AKHMAD REZA	L	252610176	\N	\N	\N	8	9	2526	0105341803
9fddd4b9-a150-43d6-b85d-a6f3f2caa434	KHAIRUNISYAH	P	252610188	\N	\N	\N	8	9	2526	0092925685
90cc15ef-5aad-413b-a422-01742ca96b02	M DAVIN KHIBATULLAH	L	252610200	\N	\N	\N	8	9	2526	0092920390
f16000d9-1688-4681-8c2d-24c16fbd4104	MASTIM	L	252610534	\N	\N	\N	8	9	2526	0107928287
25fd00d3-27fc-429b-babb-594c752a7fdc	MELANIE POETRI	P	252610212	\N	\N	\N	8	9	2526	0102084941
33954275-9c56-485a-bcea-d5b784014a28	MUFRIKHA	P	252610224	\N	\N	\N	8	9	2526	0094403438
3baf5128-02b5-422f-9737-0c4607f23303	LUKMAN NUR ROKHIM	L	242510233	\N	\N	\N	2	18	2526	0096831340
942ebc83-7050-4513-b2e7-02f35843a2d8	MEILIA HERMAWAN	P	242510198	\N	\N	\N	2	18	2526	0092508771
403fe288-d880-4c9e-9b64-069eab7b51e9	MUHAMAD ARIF MAULANA	L	242510165	\N	\N	\N	2	18	2526	0095366057
4e215aed-511e-472c-a9c1-5b4538208699	MUHAMAD IMAM SUBKHI	L	242510128	\N	\N	\N	2	18	2526	3099960751
4e136e98-8c78-46b0-99e2-c4df887d1cdb	MUHAMAD TEGUH	L	242510022	\N	\N	\N	2	18	2526	0093193099
8e31b2f8-0ceb-48ee-8bac-da70125e9e45	MUHAMMAD RIZKINA	L	242510023	\N	\N	\N	2	18	2526	0095732191
c6df54de-4140-4a73-9868-60c7547a5267	NOVITA SARI	P	242510204	\N	\N	\N	2	18	2526	0095811494
49f00ac0-0249-4680-8156-78a8d5913509	PUTRI AYU YULIANINGSIH	P	242510277	\N	\N	\N	2	18	2526	0082617313
9560a5d4-a384-4941-a8bd-683a061b9467	PUTUH ARIFIN	L	242510385	\N	\N	\N	2	18	2526	3087071858
be9bfab5-dc43-4c5b-bfb7-97ff0afc0c1c	RAHMA FADILAH	P	242510175	\N	\N	\N	2	18	2526	0086635193
8ec868a4-56e3-4aa3-b218-798ef50fcbe7	RANANDA ANGKATA	L	242510278	\N	\N	\N	2	18	2526	0082844259
8a890704-6ab3-4224-a6c2-e7710904d610	RIDWANTO	L	242510208	\N	\N	\N	2	18	2526	0096243752
7dc9786f-75cb-4bf9-a761-5dc597e34498	RISKA AULIA WATI	P	242510388	\N	\N	\N	2	18	2526	0099294213
83886252-0a14-43f4-9128-e45f57083a88	SADAM SINATHRYA	L	242510389	\N	\N	\N	2	18	2526	0098074697
7650bf01-9ce0-4c8c-9cf0-654717104fad	SALMA ALMAGINA	P	242510390	\N	\N	\N	2	18	2526	0082221493
bc5ba049-d88b-49b1-8acf-306b0c32068f	SIFA AULIA	P	242510319	\N	\N	\N	2	18	2526	0099775452
60788b06-e893-452f-acf0-094c6b032eae	TUTI ALWIYAH	P	242510107	\N	\N	\N	2	18	2526	0085040837
78fc4689-a8ba-4854-8c74-3496a319d8b1	ZAHARA	P	242510252	\N	\N	\N	2	18	2526	0099848923
8bbdb5cd-7db7-464c-aeff-67519decb159	NABILA ZAHARA	P	242510095	\N	\N	\N	2	18	2526	0082059835
8cbc69eb-d124-4464-a880-008a002fb308	ABDUL KAFI NANDES	L	242510109	\N	\N	\N	2	19	2526	3087342519
02d517b2-69e5-43c3-8dd9-18916b28d017	ADE NURSYIFAA'	P	242510038	\N	\N	\N	2	19	2526	0094992806
a227ce75-0eca-4b0a-a4fa-33d5fc975b3a	ANDIKA DWI GUNAWAN	L	242510399	\N	\N	\N	2	19	2526	0081234208
bb0278fa-6190-4442-b108-f9663ce407a1	AUFI FILLAH	P	242510149	\N	\N	\N	2	19	2526	0095289179
25325de9-69a5-4558-89d1-973ea8a9deb1	BANYU ANANDA PRATAMA	L	242510294	\N	\N	\N	2	19	2526	0099689872
ea49f6a5-75d5-45e0-bf2a-2046bfcd569c	BILKIS ILMIATUS SHOLEHAH	P	242510259	\N	\N	\N	2	19	2526	0098075367
5612bd53-8580-4fb2-bda3-4de32b68ed96	DAIVA ISVANATUN AZKA	P	242510188	\N	\N	\N	2	19	2526	0091240347
2572309a-65d3-493a-8c29-f2183fd32dec	DEZAN RAFFI ADZIKRA	L	242510154	\N	\N	\N	2	19	2526	0094172424
165b9260-219f-40fe-8f46-db064e2233f9	DLIYA'NAJMAH FAHDIYANA RAMADHANI	P	242510262	\N	\N	\N	2	19	2526	0092689835
663ed008-98dd-4c47-ae81-bb5a590f7b0c	EVI RAHMAWATI	P	242510119	\N	\N	\N	2	19	2526	3098879456
4e121285-f8b0-4e60-aaf9-ab9851dd45ef	FAHRI ABAS	L	242510084	\N	\N	\N	2	19	2526	0091986455
5cc74bd0-a042-4f8c-a116-a042efa78f54	HAFIZ MAULANA	L	242510050	\N	\N	\N	2	19	2526	0094067680
786a95b2-ac1e-43fd-a880-a3b8018e4686	HAWA NABIL TRI NANDIYA	P	242510265	\N	\N	\N	2	19	2526	0087090688
f738f566-1f59-486b-a32a-1221cb22bee3	HILMI MAULANA ISHAQ	L	242510337	\N	\N	\N	2	19	2526	0099380599
4c42c1c6-fb8c-46e9-b9eb-0755e7bdb63c	KAYSHA	P	242510267	\N	\N	\N	2	19	2526	0093099341
49bf97c8-6c79-4efb-b902-f7906bdc1d87	LUKMANUL HAKIM	L	242510269	\N	\N	\N	2	19	2526	0085225472
27ec8474-1002-419b-a089-b1b50292c18e	LULAN APRILLIYA	P	242510304	\N	\N	\N	2	19	2526	0072113557
e56029b5-2a2a-458b-8c9d-d2fbb81e73b4	MEKA WARDANA PUTRI	P	242510234	\N	\N	\N	2	19	2526	3094273846
a55699b5-582e-434e-a5ce-b8c0309042e7	MUHAMAD DAFFA FIRDAUS	L	242510307	\N	\N	\N	2	19	2526	3107054835
7fe948eb-f1ee-4ba0-b8d9-d80aeba0d380	MUHAMAD MAHER AFRIANTO	L	242510166	\N	\N	\N	2	19	2526	0091243194
92ace892-0f61-413e-8ae6-7bae98dbf6d7	MUHAMMAD BAGUS ALFIN	L	242510129	\N	\N	\N	2	19	2526	0081129662
c9678ba8-fc1a-4f94-bab5-f24b841250fd	MUHAMMAD RIZAL ARRIZQIE	L	242510417	\N	\N	\N	2	19	2526	3086356178
4f5570a6-059a-4ca9-98a2-525623d8bf7c	MUHAMMAD SHOHIBUL ANDRI	L	242510058	\N	\N	\N	2	19	2526	0099011135
8cc2ed16-35f8-4cd5-a286-e4a20d4f5b9d	NAHWA QURROTA A'YUNN	P	242510203	\N	\N	\N	2	19	2526	0084121150
455644d8-026b-4250-b193-942a1311ab2f	NURHALISAH	P	242510347	\N	\N	\N	2	19	2526	0093121572
fdb22259-3070-4dd1-a3ed-958563891444	PUTRI BUNGA MARBEL	P	242510313	\N	\N	\N	2	19	2526	0093126944
7cd26674-dbf0-4a69-b4db-873ca67f51fe	RADEN RIZKY ARHAM FIRDAUS	L	242510028	\N	\N	\N	2	19	2526	0085447797
e00eb41d-7907-4efa-b202-b9bbf981434d	RANDI MAULANA HAPIDZ	L	242510314	\N	\N	\N	2	19	2526	0081263985
0a10fa95-5ce2-4823-8b23-48607c51737f	RAYA AGISTIA ANJANI	P	242510243	\N	\N	\N	2	19	2526	0095657285
f92bbbf4-30f8-47a4-8e77-09776e0bd7b7	RIFKI ANWAR MUSADAD	L	242510244	\N	\N	\N	2	19	2526	0098484327
4bc59a40-c6ec-439f-9386-c871e13eb443	RIYANA ALFARIZI	P	242510031	\N	\N	\N	2	19	2526	0095613700
2a6b4f66-828b-46af-985d-8a0f039b4dd2	SINDY NOVIANTI	P	242510391	\N	\N	\N	2	19	2526	0091630226
ce056d50-9121-4cf1-a360-0b4dff4aea98	SYIFA AMANDA	P	242510106	\N	\N	\N	2	19	2526	0096705142
a06740db-f3a5-4090-b2ce-dd673b7ae57c	TAFFAKUR RATU	P	242510180	\N	\N	\N	2	19	2526	0097087577
bd99163e-4fc5-4e34-806b-eba3b8f61f87	VEMMY SHOLIHATUL HAQ	P	242510251	\N	\N	\N	2	19	2526	0094602696
7d2932af-5ddd-4103-acf1-907d0e39f30d	ZAHRA SALSABILAH	P	242510360	\N	\N	\N	2	19	2526	0083705774
5c5df2d7-16e4-4cc4-8adc-735285fbd43c	ABDUL KHALIM	L	242510145	\N	\N	\N	2	20	2526	0095438072
21f7ea80-d968-455b-9287-d79871ff6715	AKBAR MAULANA	L	242510147	\N	\N	\N	2	20	2526	3095882667
b0cada09-d906-4aba-a021-afd08bf6cdac	ALIFATUS SAHLA	P	242510291	\N	\N	\N	2	20	2526	0088272094
5cf819d8-4516-4d75-a969-6a7aeabc3540	ANDIKA RIZKI MULYANA	L	242510005	\N	\N	\N	2	20	2526	0096925696
d20b629a-ff91-4583-8208-d5d93b34656b	ANGGITA PUTRI SYAHRANI	P	242510220	\N	\N	\N	2	20	2526	0087876740
ae9d80b5-f162-49f6-8f3f-7dfcefd9f3ea	AURA DIEWANTY MAHARANY	P	242510329	\N	\N	\N	2	20	2526	0095659348
3c31f7c4-670a-488a-99cb-72a2a2884fdb	BIMA MUSOFA	L	242510330	\N	\N	\N	2	20	2526	0093252272
21df9f1c-26c0-4b66-b3d3-05eb6acda3ab	CAHYA INDAH LESTARI	P	242510152	\N	\N	\N	2	20	2526	0085719719
690bca00-e345-4683-9640-43ba7d294126	DEA NOVITA KURNIA DEWI	P	242510296	\N	\N	\N	2	20	2526	3083708957
c71a60b7-bd5d-454a-b87d-e039672602fb	DICKI SHASSAY SINAR PRATAMA	L	242510225	\N	\N	\N	2	20	2526	0097127385
7c80515c-42bc-4ef9-ab72-2510b0d43ee4	EGIS DWI APRILIA HASAN	P	242510298	\N	\N	\N	2	20	2526	3096754404
041aa0e4-2ca0-4230-b1d8-b2c34a50c285	EVINSA NUR SAHRUDIN	P	242510156	\N	\N	\N	2	20	2526	0081055500
de9aebca-bdd9-4eac-afcb-9fb85c55937a	FARID PRATAMA	L	242510192	\N	\N	\N	2	20	2526	0095956993
dbd724e0-e55b-46a9-a5db-af6f3d7966f4	HAIDAR LUTHFI KHOLILULLAH	L	242510122	\N	\N	\N	2	20	2526	0097968207
9a4c85b2-23b3-43a8-8482-28f3554d8e68	HIKMATUL ALIYAH	P	242510301	\N	\N	\N	2	20	2526	0084145412
635a2fe5-24b0-414f-bba6-91dd7d6a2ae8	IBNU SHINA AL-FARIZY	L	242510373	\N	\N	\N	2	20	2526	0097287655
0b8ac2b3-b429-46d7-9887-f6254ca29788	KEYLA PUTRI ADHISTI	P	242510339	\N	\N	\N	2	20	2526	0094268198
438ad9f6-4c9d-438e-932d-6f5b8a658a5b	M. RIDHO ALFAJRI	L	242510341	\N	\N	\N	2	20	2526	0097153736
c566d550-09a2-4ccc-bb3c-4d70903f03d2	MADINAH NUR MULTAZAH	P	242510377	\N	\N	\N	2	20	2526	0088206688
f0a516f6-74ad-44d9-b330-5a059247bb52	MELITA RAHMAYANTI	P	242510270	\N	\N	\N	2	20	2526	0099253489
71cbbd4d-de68-407b-9911-b622281241b9	MUHAMAD DIKA	L	242510343	\N	\N	\N	2	20	2526	0089022404
3ea7cc7a-007b-4573-b539-c559ba24c07b	MUHAMAD NAZRIL IBRAHIM	L	242510167	\N	\N	\N	2	20	2526	0087984986
941da965-ed80-472a-9402-3ff59a2f67f6	MUHAMMAD FAKHRI HABIBUR ROHMAN	L	242510168	\N	\N	\N	2	20	2526	3095889791
b8f41c98-4487-4e1e-b46b-56e96be27901	MUHAMMAD ZAINAL AKBAR	L	242510094	\N	\N	\N	2	20	2526	0087230205
a61094ef-3584-4dc7-864e-4266b6cbac41	NAILA RISMAY CHIKA	P	242510238	\N	\N	\N	2	20	2526	0096940456
359d4052-4c6f-4497-b10a-a7938f5b7c68	NURLATIFAH	P	242510383	\N	\N	\N	2	20	2526	0109573748
2474371a-cd33-445a-9317-1e5f39a178b7	PUTRI DIANA QAMARIYAH	P	242510349	\N	\N	\N	2	20	2526	0088087648
279b8920-190e-4995-a7f4-227c0399cd14	RADIT FEBRIANSYAH	L	242510063	\N	\N	\N	2	20	2526	0087013900
484fa979-2d37-40dd-bde4-689960f32dae	RANGGA	L	242510386	\N	\N	\N	2	20	2526	0087899394
9dcb96a1-cea4-4385-827d-e607c040bcbb	REHANA FAUZAH	P	242510315	\N	\N	\N	2	20	2526	0094809878
7d722795-b1e7-4caf-af97-a135c786f97b	RIFQI AKHMADI	L	242510280	\N	\N	\N	2	20	2526	0093070495
2ce75ffe-47ea-4a72-98c7-0acc04316c2e	ROKHAMA PUTRI PRATAMA	P	242510066	\N	\N	\N	2	20	2526	0092586185
4bd45f3a-34d2-4e9e-8ba4-c37e5fb76c9e	SALSABILA RAMADANTI	P	242510426	\N	\N	\N	2	20	2526	0089223550
5da2f798-4bac-4c2b-8186-f465dbaccc53	SITI AISYAH	P	242510034	\N	\N	\N	2	20	2526	0098411082
da3e5543-b87e-4cab-9f1f-726df721088b	TASYA PUTRI APRILIANI	P	242510214	\N	\N	\N	2	20	2526	0092006314
bbbef69d-62df-48d7-869d-7c870b702d8e	VIRGIN RAMADANI	P	242510287	\N	\N	\N	2	20	2526	0088544533
1b9de9cb-df2d-4253-a481-839fa269e45c	HALIM LUTFI	L	242510159	\N	\N	\N	2	31	2526	0098536043
5803daa0-3756-4f25-9580-987c54cc68dc	IIM DAIMAH	P	242510374	\N	\N	\N	2	31	2526	3082042334
32ad0152-5598-45ad-bcb0-7152fa8daca8	IRAWAN SANTOSO	L	242510016	\N	\N	\N	2	31	2526	0088367229
7e7ba09f-9bdc-49db-9998-7d85ad4ec64d	KEYSHA FADILLA ANGGRIAWAN	P	242510411	\N	\N	\N	2	31	2526	0087959169
45d02ef8-840d-4efc-980c-7605f6258e40	MARWATUS SABILLAH	P	242510054	\N	\N	\N	2	31	2526	0097587359
ce3b2217-4ee2-4c93-a9c8-9c8e84c37ffa	MELIYANA ASTUTI	P	242510306	\N	\N	\N	2	31	2526	0085830649
bf50b69b-8497-4ec9-8bdf-9f84744eea06	MOCHAMAD RIFQI FAUZI	L	242510414	\N	\N	\N	2	31	2526	3085871807
e487100d-3a99-4c0c-8bff-0311e4fa18cc	MUHAMAD DIMAS	L	242510379	\N	\N	\N	2	31	2526	0093203442
84f748f2-151a-43b6-819f-1cf1593b8529	MUHAMAD RAMADHAN	L	242510200	\N	\N	\N	2	31	2526	3089066062
e463c5cf-3863-45dd-87d2-303ed0f77411	MUHAMMAD FAQIH IBROHIM	L	242510237	\N	\N	\N	2	31	2526	0094259071
0ed8933b-8d2a-4fd5-b179-15bd5c5e1fa8	MUKHAMAD FAHRI	L	242510169	\N	\N	\N	2	31	2526	0082998459
520db6d3-63ca-40ae-b85a-0b76a099607a	NAYLA FAIZAH	P	242510418	\N	\N	\N	2	31	2526	0091467080
aaa84c0e-5a45-4e91-a173-a7569beebee5	OPI FARHATUL FAJRIYAH	P	242510097	\N	\N	\N	2	31	2526	0094799892
ac2bc74a-e111-4ddd-8b6f-88adcc602ca2	PUTRI NOV ALITA	P	242510420	\N	\N	\N	2	31	2526	0095493405
1aebb557-4a0b-46f4-bb0d-805d1789e87b	RAFIQ WARDIYAN	L	242510174	\N	\N	\N	2	31	2526	0099590626
b4a4ae79-a235-40d4-9c44-b2d12946d9a2	REFI APRIANTO	L	242510029	\N	\N	\N	2	31	2526	0093173895
65c72209-fc72-4aae-a5c0-eaf9ccd151ff	RENA AGUSTINA	P	242510351	\N	\N	\N	2	31	2526	0088421014
aabe7041-28c2-4db5-92ac-873c560687e8	RIVALDO MEDRIAN AGUSTAF	L	242510317	\N	\N	\N	2	31	2526	0086447693
e082dedc-63b7-410f-9854-258085f37258	ROKHIMI DWI PUTRI	P	242510102	\N	\N	\N	2	31	2526	0092623203
e144a1c2-fb00-47b4-b06c-812de9f1d2dc	SAHARA	P	242510318	\N	\N	\N	2	31	2526	0092567071
99a551c5-c7de-47f1-a8b3-5168ec926e78	SASKIA SAPITRI	P	242510139	\N	\N	\N	2	31	2526	0095411500
cc1b047c-69d9-42da-b094-b8353a6cfc41	SITI ALISAH	P	242510069	\N	\N	\N	2	31	2526	0083333423
ffcba6c1-2eb3-41e5-9955-48c7bce68e6c	TIARA NURPADILAH	P	242510322	\N	\N	\N	2	31	2526	0084030589
17233c91-32f8-4798-94b5-dc1a68e8fe49	WIDI YANAWATI	P	242510323	\N	\N	\N	2	31	2526	3088098870
a8e282d4-733b-49e2-a25b-8ec38c9dcb59	ADE FHIRENILA	P	242510002	\N	\N	\N	2	32	2526	0091905873
63a4da8d-a1b9-4812-a51c-5fb3c5ada572	ADITIYA ZIYADY	L	242510217	\N	\N	\N	2	32	2526	0091037285
7e245cb6-e2d8-484b-819c-641206439cc7	ALDITIYA	L	242510219	\N	\N	\N	2	32	2526	0095765632
580401d0-189c-4823-b62b-e7f1acfafb1e	ARLETA CITRA ISLAMI	P	242510364	\N	\N	\N	2	32	2526	0096934431
3683af75-166e-4aee-b449-75130e13ffcb	ASSYIFA APRILIANTI	P	242510400	\N	\N	\N	2	32	2526	0092978824
ac80919f-b463-4db2-b209-fafe8d267853	BACHTIAR RAMADHAN	L	242510151	\N	\N	\N	2	32	2526	0088572134
cb808789-f6fa-4643-b188-97db17b34430	CELSEA	P	242510366	\N	\N	\N	2	32	2526	008599513
1f6b594a-4dd6-4a0e-bd0c-f0880516ea9d	DAFA ARIF MAULANA	L	242510403	\N	\N	\N	2	32	2526	0085279973
f325bcf6-efb3-4f0d-ba99-aa3372b97bda	DIANA	P	242510082	\N	\N	\N	2	32	2526	0091409601
6bd15f84-144d-4f02-bb5d-90835872bf96	DIVA LAYAKUSUMA	L	242510369	\N	\N	\N	2	32	2526	0087305226
41beec83-4985-4517-ab18-8a1a59a433cd	ELSA	P	242510012	\N	\N	\N	2	32	2526	0085700081
57ea9077-9f72-446e-abc6-a4006ca8d305	FARIHAH AULIA FITRI	P	242510227	\N	\N	\N	2	32	2526	0091289928
e309612e-7f6e-40d1-a3c4-b056b3a1848d	FEBRI MAULANA	L	242510299	\N	\N	\N	2	32	2526	0093535298
59cee3de-284e-48e6-b64a-620b203525a9	HAMIM SUKHARNA	L	242510194	\N	\N	\N	2	32	2526	0087824123
5de44b57-4f31-4897-bfc9-42d54ba1db50	INTAN SAFITRI	P	242510087	\N	\N	\N	2	32	2526	0071496908
efbfa092-44d6-4a91-bb8c-eebddb5dc4ca	KHANAN FAJRIAWAN	L	242510124	\N	\N	\N	2	32	2526	0091060972
89ab0ec8-e20e-4a1f-9981-62eb6094ac99	KINAYA FAUZIAH	P	242510089	\N	\N	\N	2	32	2526	0091511457
69844811-840f-43fa-8195-cc39e69078b1	MEGA AULIYA	P	242510126	\N	\N	\N	2	32	2526	0085395805
579378c7-bb7d-4cd3-a53e-fe55be795ca1	MIA OLIVIA HARTANTI	P	242510378	\N	\N	\N	2	32	2526	0085206346
b03140b3-d057-4052-b918-e99e1044ddf1	MUH. DIAZ TRI KUSUMA	L	242510055	\N	\N	\N	2	32	2526	0086973986
d3a0bfbc-5b83-45aa-9658-86e601fc73af	MUHAMAD FAIDAN AZHARI	L	242510415	\N	\N	\N	2	32	2526	0082651518
cddc0a81-895a-4346-b179-93febc10a405	MUHAMAD RIFQI RAHMANINO	L	242510344	\N	\N	\N	2	32	2526	0097259250
85475aa7-18c6-4398-9611-4e9091f2dee8	MUHAMMAD RAFFA ALFARIZI	L	242510345	\N	\N	\N	2	32	2526	0096688397
18192ff1-73c3-4df6-b352-254d7a7f0883	NABIL DWI SAPUTRA HAKIM	L	242510202	\N	\N	\N	2	32	2526	0092060158
34c4d75b-bc28-4c3c-9042-0fbe220ca88f	NESHEA AMELIA PUTRI	P	242510025	\N	\N	\N	2	32	2526	0089705637
b1b73557-d40c-4992-ad7d-88c3d463a2c6	NURUL AZKIYA AZ-AZHRA	P	242510026	\N	\N	\N	2	32	2526	3090064951
1d43c4b9-8484-48e9-bb9e-301cf8a0752f	PITRI	P	242510133	\N	\N	\N	2	32	2526	0079478222
978a07ac-1ea9-4802-90de-ecb29a281fab	PUTRI RAMDANI	P	242510027	\N	\N	\N	2	32	2526	0093116655
2bef0e1f-dd98-4d11-8ab3-6262344088a5	RAHMAN DANI	L	242510207	\N	\N	\N	2	32	2526	3087857345
c57ea8f2-cacc-4cc3-bb2e-2bd9e923026c	RENDI MARTIN	L	242510064	\N	\N	\N	2	32	2526	0088711913
1c4ee71e-171d-4e18-8a77-b15aa8d8b238	REVI MARISKA	P	242510101	\N	\N	\N	2	32	2526	0085240605
e883ca02-8b76-4dcf-921a-379e2a08f025	ROSITA	P	242510210	\N	\N	\N	2	32	2526	0089476954
bb5550fb-cebe-4f7e-8c6d-7a087deb9ca1	SEFIANA IRMADITA	P	242510178	\N	\N	\N	2	32	2526	0099008882
f7d255ad-48e4-43ee-892b-5bb79f2c3d35	SITI ALIYAH	P	242510105	\N	\N	\N	2	32	2526	0074686736
791d534b-3220-4666-a9e7-a7875e961683	TIAS NAZHWA MAULA	P	242510429	\N	\N	\N	2	32	2526	3092337075
933b05cc-778e-46f4-ba45-17b2560d4c34	WISMAYA REREN	P	242510394	\N	\N	\N	2	32	2526	0087484472
30d838ba-5c0b-4532-9fcf-3c4daca6352e	ADNIN SUGIH HARTO	L	242510253	\N	\N	\N	2	33	2526	0093347567
cb7af8b7-2ea3-4176-b83b-d3e92d4a6d29	ALLES SANDRO AXL PIERO	L	242510327	\N	\N	\N	2	33	2526	0098310351
752b68af-44a1-4933-a326-6537fd50ba46	AYU RAMADANI	P	242510079	\N	\N	\N	2	33	2526	0085470959
3f7a4ee9-e799-4c58-9d1f-f6f2d430214f	BAGAS TAUFIQURAHMAN	L	242510223	\N	\N	\N	2	33	2526	3088680758
5b987d27-89f0-4393-bc92-7ccf35e6926c	CHIKA YULIA NABILAH	P	242510008	\N	\N	\N	2	33	2526	3117261584
1d4f29db-dd27-4634-9a7a-22b13f9fa601	DAFID	L	242510009	\N	\N	\N	2	33	2526	0093150833
5fe53f5e-17b0-43b9-ba48-01b790b54536	DINI NOVIANI	P	242510190	\N	\N	\N	2	33	2526	0099978622
5ac296b5-6d51-4e00-b74e-6943fe23696f	EFAN SETIAWAN	L	242510405	\N	\N	\N	2	33	2526	0082615194
ab6d6b6b-c38b-4ca4-a4a7-688b36d3c788	ERNAWATI	P	242510047	\N	\N	\N	2	33	2526	3095655360
433663a1-346b-442e-aa2d-a665a2b0c122	FERDY FEBBY SAPUTRA	L	242510335	\N	\N	\N	2	33	2526	0094731262
e0433bfe-7e1b-43f6-a5be-0e415837d437	GALIH PUSPITASARI	P	242510049	\N	\N	\N	2	33	2526	0094384550
1c06c8b5-19b6-4d4d-8944-51e75dccedaf	HARLAN SAPUTRA	L	242510229	\N	\N	\N	2	33	2526	0093583004
a7844068-e402-48bc-b79e-d1c87ed5281f	ISMA NADIFAH	P	242510160	\N	\N	\N	2	33	2526	0099866291
9cff532c-0fd3-4387-aaa3-e66497cbaf5b	LABIB FAWAZ	L	242510161	\N	\N	\N	2	33	2526	0096086942
59ca6c9b-7973-4f4e-8331-a59038ea5fcf	LARAS FEBRIYANTI	P	242510162	\N	\N	\N	2	33	2526	0092838423
eae12e8b-2364-4ce5-9170-ea240d23976e	MEGA PUSPITASARI	P	242510163	\N	\N	\N	2	33	2526	0081684967
99b0a86e-1f26-426a-9361-86e61b087a3f	MUHAMAD HAKIM SAPUTRA	L	242510056	\N	\N	\N	2	33	2526	0093618522
51eb1025-78e0-41dc-a633-68a0650d98fb	MUHAMAD SATRIA	L	242510416	\N	\N	\N	2	33	2526	0096488346
cd4f27ac-fc85-47c2-a036-6bf00dd93396	MUHAMMAD RIFAT MAULANA	L	242510381	\N	\N	\N	2	33	2526	3095228537
afc52ff6-7c7a-44f4-9150-fc46cbfe022b	MUNIR ROHIMI S	P	242510024	\N	\N	\N	2	33	2526	0095971436
3ee53be4-2405-4830-8cdb-4bcfcbb871c0	NIVI	P	242510171	\N	\N	\N	2	33	2526	0098071155
c19bc35e-208e-4a73-9502-188041499793	PUSPITA SARI	P	242510205	\N	\N	\N	2	33	2526	0092144818
007df914-b5d9-4d86-b28e-986a524c0bcc	PUTRA RAMADAN	L	242510348	\N	\N	\N	2	33	2526	0091760122
3b0886a0-41e3-4c7d-8636-916846967674	RACHEL AMANDITA	P	242510098	\N	\N	\N	2	33	2526	0096105505
83b68811-9642-47ca-aea9-e51ac0b9263b	RAJWA IGNATIUS SAMUDRA	L	242510242	\N	\N	\N	2	33	2526	0083075772
bee19bcc-f302-4315-aeb3-b356bd6e0e9c	RENDI MAULANA YUSUF	L	242510100	\N	\N	\N	2	33	2526	0091190767
9e46e604-579a-4aba-89c0-33ddf67d27c4	RIKA ZAHWA	P	242510245	\N	\N	\N	2	33	2526	0086385457
655743d3-37e1-4162-9b74-e6dcbac1998d	SABRINA PRATIWI	P	242510246	\N	\N	\N	2	33	2526	0097189702
51024c24-9f11-41e0-b9b8-0fefacac1adb	SEKAR WULANDARI	P	242510211	\N	\N	\N	2	33	2526	0083182401
b24359f4-b808-448a-9c2d-382e8d50cf79	SHIHABUDDIN FASYA	L	242510068	\N	\N	\N	2	33	2526	0094798615
0c2860c2-c161-4de4-9d18-87bd24c22530	SIGIT ADITIYA PUTRA	L	242510104	\N	\N	\N	2	33	2526	0092906934
586d3e6c-872b-4d21-97e5-6d377f02a369	SITI SAFINA	P	242510356	\N	\N	\N	2	33	2526	0092625017
4fe61a43-9773-4524-aab3-90f2266df3fa	SYIFA ADIAYAKSA REJA	L	242510285	\N	\N	\N	2	33	2526	0084010347
79a61087-0241-4e96-a8dd-32d3f683aee6	TIYA ANDREA KIRANA	P	242510071	\N	\N	\N	2	33	2526	0085223757
3805fe13-77f0-46fa-8fe6-51d9d1e6426e	WIYAH SHOLEHATUN	P	242510430	\N	\N	\N	2	33	2526	0087995925
c54fb023-d684-430b-908e-160333e78ca4	YARES MULYANA	L	242510431	\N	\N	\N	2	33	2526	0096656706
9ff185a1-d007-49e0-813f-1eb2179f7767	ABBIYU DIMITRIES	L	242510001	\N	\N	\N	2	15	2526	0091646537
c1b41c62-d02c-4f93-9ad9-8d49418831b0	ADE SAFIRA	P	242510074	\N	\N	\N	2	15	2526	0096094215
a66e86d3-c0f4-4615-8f58-3ca0f95e3c0a	AHMAD MA'RUP YUSUP	L	242510039	\N	\N	\N	2	15	2526	0099795350
d5a79f03-2197-40c8-83b0-c6533d7b204f	AHYAN NABIL ESHAN	L	242510111	\N	\N	\N	2	15	2526	0088602395
2bc77990-737f-4cca-b94d-619efe8af01b	ALINZA ALDHAFINA	P	242510326	\N	\N	\N	2	15	2526	0091418285
964412d7-60e9-4d74-9fe8-48752198f0a2	ANGGI	P	242510112	\N	\N	\N	2	15	2526	0099621734
fbc84548-3c4d-4797-8a83-fc9071242b8b	ASYIFATUL ZANNAH	P	242510006	\N	\N	\N	2	15	2526	0098052069
2dbf304e-a650-438b-b396-3e3aae10f047	AURA AZZAHRA	P	242510293	\N	\N	\N	2	15	2526	0095268889
c020642d-e047-44f8-a2f2-34fb262a95ac	BUNGA DARA ANGGRAENI	P	242510295	\N	\N	\N	2	15	2526	00955762208
1d22c498-6a64-4181-b61f-4cd055e92994	DEA IMUT	P	242510260	\N	\N	\N	2	15	2526	0082486073
8b62d9a8-000c-43db-8dcc-0dff07ad7d5e	DEVALDO ALFIRANSYAH	L	242510081	\N	\N	\N	2	15	2526	0098471079
86f42358-8b6d-4b38-872a-5eee13928825	DINDA KEISYA WIHAPSARI	P	242510155	\N	\N	\N	2	15	2526	0091648655
36e8942b-db6a-4264-a907-6fc426f3eca8	FARDAN RIFA ANTONI	L	242510157	\N	\N	\N	2	15	2526	0878420767
8e1569e7-4ef5-400b-8b76-829a8326c426	FIRDA MAERYTA SARI	P	242510372	\N	\N	\N	2	15	2526	0089367133
1b5be0d8-09ff-462c-8f2d-6554bd6d8696	IMEYLINA AWALIYAH	P	242510409	\N	\N	\N	2	15	2526	0097416746
9b016a80-cc3e-4320-bd5e-5a46e8225126	IQWAN RAFIDI	L	242510410	\N	\N	\N	2	15	2526	0097455764
f7400cbc-a4fe-4e06-af2b-1e95497b6bd4	KEYLLA OKTAVIANI DARMAWAN	P	242510375	\N	\N	\N	2	15	2526	0099621624
4b55451e-b237-402e-9697-07f4d391aac5	LUTFIANA NURFADILLAH	P	242510340	\N	\N	\N	2	15	2526	0095221066
66168aa1-b90c-4c27-bbf1-c8dce7759407	MOCHAMMAD FEBRYAN ARFAN	L	242510020	\N	\N	\N	2	15	2526	0095990176
5982ea04-babb-4689-ac45-526f8487a8c6	MUHAMAD ANIQ	L	242510271	\N	\N	\N	2	15	2526	0097533001
6f736f04-44b2-4edd-bde0-a84f2fcf47b5	MUHAMAD SAPRUDIN	L	242510380	\N	\N	\N	2	15	2526	0081994439
f07dd997-ff0f-4de1-aeb5-8e65f10eeb76	NABILA SAFITRI	P	242510059	\N	\N	\N	2	15	2526	0098266897
3670f3d2-d36e-4f57-8c81-0f5ba6ca0b90	NIEGITA DWI SESYAH	P	242510060	\N	\N	\N	2	15	2526	0088600775
e9d0cc35-ffa7-4aef-9069-a0e4f89e226b	NURMAESAROH RAHMADANTI	P	242510419	\N	\N	\N	2	15	2526	0074669864
6125f77e-0486-4d98-9d84-1cf2b24f76e8	PUTRI NAILA SALSABILA	P	242510173	\N	\N	\N	2	15	2526	0093927684
df1e1ed5-dfc3-4d06-8d7b-e820fadce9ea	RAFA PUTRA KURNIAWAN	L	242510099	\N	\N	\N	2	15	2526	0097309306
0b1a661b-266e-4370-b264-6584b9360eba	RESTY YULIYANI	P	242510423	\N	\N	\N	2	15	2526	0091286133
fcbcd36d-9099-4e18-b064-23b787d5aa2c	RINDIANI CITRA SEMI	P	242510281	\N	\N	\N	2	15	2526	0096500184
33570ad7-01d0-4f87-a584-65be9b68e300	SAHAL RIZQI RAMADAN	L	242510425	\N	\N	\N	2	15	2526	0093192740
a2f4edb9-9d04-4b0e-a43d-738dd6add884	SAKHIRA RAHMA AULIA SALSA	P	242510354	\N	\N	\N	2	15	2526	0097133795
efb2a691-82bd-4af9-9b4b-ddf032ee6201	SHALSA AYU FADHILA	P	242510283	\N	\N	\N	2	15	2526	0081485015
fa211659-85e6-4736-ad8f-e97245902534	SITI MAEMUNAH	P	242510248	\N	\N	\N	2	15	2526	3092535428
2cfba4da-e86c-48b0-be55-949ea746e421	SYIFA AZKIA HASANAH	P	242510142	\N	\N	\N	2	15	2526	0096904734
44302aba-7c55-4b40-9564-20c772b6ff38	WIDIATUSSHOLIKHAH	P	242510358	\N	\N	\N	2	15	2526	0093692316
3feb226a-55c8-4645-aadb-fcb2ade978f4	WISNU PRAMANA AGUNG S.	L	242510395	\N	\N	\N	2	15	2526	0081819906
fb8e0543-ad0d-4843-a538-72134a969ae8	ZAHWA MALIKHA PUTRI NUGROHO	P	242510396	\N	\N	\N	2	15	2526	0099374794
286bdb65-c99c-4d41-9ded-3a4dc3a374d5	ABDI TRI YADI	L	242510037	\N	\N	\N	2	16	2526	0098330329
4a1410b6-185a-42bb-9eff-de1e71cdf05c	ADENSA LEVIE FILDAN HERYONO	P	242510110	\N	\N	\N	2	16	2526	0074533028
5f3f0ab9-6665-4528-9162-d52a73019eff	ALDIYANSAH	L	242510254	\N	\N	\N	2	16	2526	0089828808
c3ccf107-7e4b-4d48-87ec-692cc2c10e49	ALMA NUR FADHILAH	P	242510363	\N	\N	\N	2	16	2526	0095636200
aeb85091-8a6b-4195-9a5a-9e8b09e3ced0	ANGGI DWI PRIYANTI	P	242510148	\N	\N	\N	2	16	2526	0083082101
0fa38295-6e0c-4206-a420-5cc4ccfd7964	ATIKA CANDRANINGSIH	P	242510042	\N	\N	\N	2	16	2526	0085205529
93145156-8be4-4b37-a5ec-fe6e21c5e8ab	AUREL NURFADILAH	P	242510401	\N	\N	\N	2	16	2526	3095755164
d8b15360-0eef-44c6-82b2-2b82f34a1bbb	AYU FITRIYANI	P	242510043	\N	\N	\N	2	16	2526	0089709627
10378d6a-93a7-41bc-b826-e79cad1db758	CHIKA FATIMATUNZAHRO	P	242510402	\N	\N	\N	2	16	2526	0105770474
af7abcc9-ef65-4963-9eed-8dd5fbe8344e	DEAH FITRIANA	P	242510332	\N	\N	\N	2	16	2526	0091192012
15b534dd-1709-4d90-bb81-01b2b3d14e6b	DEVAN ALFARIZI	L	242510117	\N	\N	\N	2	16	2526	0097555621
7c0e8b58-dc37-47e4-b87d-9a23ff018336	EKA AMELIAWATI	P	242510334	\N	\N	\N	2	16	2526	0083314594
81ac826f-d67b-4c18-9350-10e1debd2d9d	FATHAN NUR FISABILILLAH	L	242510263	\N	\N	\N	2	16	2526	0083065523
cd3c1a33-5841-44c0-9d81-0dfb90897326	FITRIA ALMARANI	P	242510407	\N	\N	\N	2	16	2526	0087542593
a7f7c936-50d4-4641-a299-388b24a9c72a	INDAH TRI HAPSARI	P	242510015	\N	\N	\N	2	16	2526	0087920439
f14fec84-b2a7-4657-b0d0-a564ee366ab2	KEYMAL APRIANSYAH	L	242510052	\N	\N	\N	2	16	2526	0097383731
be43f2ec-2118-410b-894a-3d77c7f553b1	KHAERUNNISAH	P	242510017	\N	\N	\N	2	16	2526	3094345330
550f918a-e153-42ce-9b2e-03e6c50b3267	MAHMUDATUSSAROPAH	P	242510412	\N	\N	\N	2	16	2526	0089816700
6361577c-ea78-4c4d-a774-49729c348b67	MOCHAMMAD LUDY NUGRA SATIA	L	242510164	\N	\N	\N	2	16	2526	0094001738
7856c126-d23d-4f74-b880-c8dd2936b128	MUHAMAD HAIKAL AZIZ	L	242510021	\N	\N	\N	2	16	2526	3092467969
8dd43d33-d7b4-4566-a48b-8f35fc8851be	MUHAMMAD ARDAN	L	242510057	\N	\N	\N	2	16	2526	0083915853
c395d3e5-874e-4904-aa41-ca6fbafdcee7	MUHAMMAD ZIDAN	L	242510130	\N	\N	\N	2	16	2526	0089079136
848c1a26-c3c7-402b-a9c2-2004be9ad7cb	NABILAH ARTANTI	P	242510131	\N	\N	\N	2	16	2526	0093226745
0b4f092f-5aec-479d-8dee-15531ddec69f	NILNA AYU KHAERUNNISA	P	242510096	\N	\N	\N	2	16	2526	0097736637
fc9f1c69-96d2-404e-ac46-523803f22df7	QONITA TSAGITA	P	242510062	\N	\N	\N	2	16	2526	3095284514
fc9adc0a-7740-425f-a9fd-1a23ba3ccfcf	RAFI ALFALIKHI	L	242510134	\N	\N	\N	2	16	2526	0098712819
4fb22091-ba79-47a4-82b3-3391248d5d50	RETA ANGGRAENI	P	242510030	\N	\N	\N	2	16	2526	0093472544
76df4e6f-047b-43ac-9094-e19e2fb20a54	RISKA AGUSTINA	P	242510352	\N	\N	\N	2	16	2526	0092641368
2690e502-8325-4566-9d14-383bf978e902	SALWA RAYYANA ZAINA	P	242510032	\N	\N	\N	2	16	2526	0092126266
8480cca4-fb8c-42dd-a3a6-6eb8fa275ee1	SILVA APRILIA NOVISA	P	242510355	\N	\N	\N	2	16	2526	0091508881
6636ebff-2b4f-413a-b9ea-8c2bb87ead45	SITI MARIYAM	P	242510284	\N	\N	\N	2	16	2526	0095229575
c0d40a17-6624-4794-ac25-4aa0e079e66f	SURYA ELANG RAMADHAN	L	242510141	\N	\N	\N	2	16	2526	0095231406
81f9267f-965b-484c-b2e0-93609600f2d4	TIARA DESVITA WULANDARI	P	242510250	\N	\N	\N	2	16	2526	0087281638
10933322-2bd0-40c3-88d8-4b7facca1f88	WULAN SAFITRI	P	242510072	\N	\N	\N	2	16	2526	0095629558
cff9bfe0-869f-46b5-a471-98fc5754d460	ZAINATUL MILAH	P	242510432	\N	\N	\N	2	16	2526	0094787112
0ba1395f-fccd-458f-aa8e-fb93a7559b6d	ZICO JERICCO ARUMAN	L	242510036	\N	\N	\N	2	16	2526	0096384626
d5db27e3-3ef7-43fe-a5cb-894181f1d626	ADILA FUJIANI	P	242510146	\N	\N	\N	2	17	2526	0099712062
09287926-33bc-4ad7-9e7d-0a72764cddf0	AGUS SURYADI JAYA	L	242510289	\N	\N	\N	2	17	2526	0083869291
61fc6b33-a3fb-4369-b9a0-c9835abf2102	AILA RAISSA PARFANI	P	242510182	\N	\N	\N	2	17	2526	0096089379
69b885e7-289d-4c3a-9a30-d00286817209	ALDO RAMADHAN	L	242510290	\N	\N	\N	2	17	2526	0092498497
2935057c-d832-4372-9911-3f6cdaf4fc0c	ALMIRAH AZALIA	P	242510398	\N	\N	\N	2	17	2526	0089762812
8ec1952d-165d-4b5c-b99e-fabc5a6db127	ANGGITA CAHYANI	P	242510184	\N	\N	\N	2	17	2526	0108857253
4aa57d84-2d82-4e9b-85e5-ea53d65d95c8	AUFA REKA AYU BINTARI	P	242510078	\N	\N	\N	2	17	2526	0086501569
b1dcbcff-9e5b-4dcb-9863-c59bde4539c9	AUREL TITANIA	P	242510007	\N	\N	\N	2	17	2526	0093221491
dd74f1f6-f2e3-4a30-9ca2-c3012252c0da	CINTA OKTAVIANI	P	242510044	\N	\N	\N	2	17	2526	3092965589
49a190e7-78b8-4318-a60e-30141c083568	DENISA AFIFAH SALSABILA	P	242510368	\N	\N	\N	2	17	2526	0099951376
2c391dec-fa2a-4d9a-b9a2-c729ab1429fd	DIDIT ADITYA	L	242510261	\N	\N	\N	2	17	2526	0091263911
e382c27e-0ae2-4d18-a840-d789c008f130	EKA DININGRUM	P	242510370	\N	\N	\N	2	17	2526	0092863581
4d0b7552-346c-468c-aef4-9ff0574b4c05	FIKRY AYYASY ASY REFALDO	L	242510371	\N	\N	\N	2	17	2526	0089029113
45f9b96a-64f5-48bf-8aa1-4ebbf4522848	FONI ALFIANTI	P	242510013	\N	\N	\N	2	17	2526	0098075346
b94fa99a-cc82-4aed-8f3b-0c8c8d00dc11	INTAN MAHARANI RAHAYU	P	242510051	\N	\N	\N	2	17	2526	0095703959
4bbdd1ad-f1eb-4fac-b697-a20442a36742	INTAN TRIANA	P	000000000	\N	\N	\N	2	17	2526	0081135439
9489e9d7-3652-4bf9-bf96-f50fd2e0462a	KHAERUDIN	L	242510088	\N	\N	\N	2	17	2526	0096140801
ebece647-9b0c-4f15-b42b-c54cef7a33bf	KIARA UTAMI IVANIAR	P	242510053	\N	\N	\N	2	17	2526	0097872960
6a859c02-bdf5-4462-8be7-96eaecb40bdb	MAR'ATUS SHOLEKHA	P	242510019	\N	\N	\N	2	17	2526	0096546785
dd45098e-d334-4d77-a418-0a785795f23e	MOH. HABAJUDIN	L	242510091	\N	\N	\N	2	17	2526	0082187904
ba7fef37-c098-4443-a6a6-b75cad7a5c00	MUHAMAD HASAN	L	242510092	\N	\N	\N	2	17	2526	0093166954
f90621b6-0915-4bbc-8a10-3a4fa6e8c8ef	MUHAMMAD ARIEF FATHURAHMAN	L	242510093	\N	\N	\N	2	17	2526	0096729003
d381e6c5-a993-4641-93ff-5dfce3fd044a	NAJWA ARISIHAB	P	242510274	\N	\N	\N	2	17	2526	0091812329
cfe469ed-9f18-46e9-8a71-f3d41e0b98b5	NAZRIL ILHAM ARENDI	L	242510239	\N	\N	\N	2	17	2526	0097204864
5d81eae1-1220-47ca-b249-229168671f27	NINA LIANA PRATIWI	P	242510132	\N	\N	\N	2	17	2526	0094461994
c05d8249-d9ac-4083-b6a9-fd9cc19e3afb	NURZAHRA NASYA SYAHRANI	P	242510061	\N	\N	\N	2	17	2526	0094891757
18b732ec-cb27-4727-88a7-61eaab4c8af8	RAHIL SASKIA FEBRIYANI SALSABILA	P	242510135	\N	\N	\N	2	17	2526	0095616877
62aa7571-62ec-44da-9eb7-81fdd0c58db5	RANDY PRATAMA	L	242510350	\N	\N	\N	2	17	2526	0083096251
eaa07b51-25e5-4089-ba86-b34f17955fe6	REVALINA	P	242510065	\N	\N	\N	2	17	2526	0092796248
5efa7695-6ac0-46af-9464-648ed1d72055	RISMA AYU NITA	P	242510424	\N	\N	\N	2	17	2526	3091085880
a827a935-f1eb-4a90-bc6c-1c953ffc97f0	SANDZA ELVIANA AYU	P	242510067	\N	\N	\N	2	17	2526	0088557786
0ac67573-d5ac-4884-a955-e3392b58b53b	SINTIYAH BELA	P	242510427	\N	\N	\N	2	17	2526	0095380589
933448ae-91cb-4e6a-b027-91ec8d248f91	SITI NUR'AISYAH	P	242510320	\N	\N	\N	2	17	2526	3086647347
0bd0fa25-fe37-4f59-a2fb-bc9cbafbbb3e	TIARA HAZFA AZZAHRA	P	242510286	\N	\N	\N	2	17	2526	0096433110
98c36e54-5f13-4611-bece-ff5c3e08aa3a	YESI PUTRI ANJANI	P	242510108	\N	\N	\N	2	17	2526	0095098374
b7a81968-7741-4389-b0f4-297fc9555e7a	AHMAD FAQIH JUNIOR	L	242510361	\N	\N	\N	2	28	2526	0089652085
641b6576-e695-4b23-87ab-51584cdae3b5	AMELIA DWI PURNAMASARI	P	242510004	\N	\N	\N	2	28	2526	0097684353
28457ad5-cd67-45d8-a817-d6315eb56d2a	ANISA PUTRI PRATIWI	P	242510256	\N	\N	\N	2	28	2526	0097211916
872c15e4-f2ae-44de-a091-a2760556f316	ARIEL	L	242510077	\N	\N	\N	2	28	2526	0097997977
a695d361-c5c3-4ff1-baf7-2dea8ccce79f	AULIA KHOEROTUL JANAH	P	242510185	\N	\N	\N	2	28	2526	0094676462
681e4f97-b625-4520-82a5-0ab84a9d4585	AZKI AZKIYAH PUTRI	P	242510150	\N	\N	\N	2	28	2526	0094245411
cbe5670c-c414-4949-af5e-6fa1302f8852	CINTA RAMADAN	P	242510080	\N	\N	\N	2	28	2526	0094412271
ebb89b04-8749-4529-bff1-23acda3e1051	DHUROTUL MUFIDAH HAQ	P	242510010	\N	\N	\N	2	28	2526	3097048885
00df4244-72ef-4891-81ab-d77e30193371	DIMAS WAHYU PRASETYA	L	242510333	\N	\N	\N	2	28	2526	0084150345
8c247e63-abb4-4e02-9ccd-bc8022ec53b5	FEFI NURPADILLAH	P	242510264	\N	\N	\N	2	28	2526	0086609377
67876ada-8600-4985-8306-f1fd80c84730	GHADA AMUKTI HADI	L	242510408	\N	\N	\N	2	28	2526	0093587177
3c3f852c-39d6-43a5-bdda-2b7ae1173000	GHEVIRA RHOUDATUL JANNAH	P	242510121	\N	\N	\N	2	28	2526	0083127142
2ffebc5e-6986-4cc6-b4bb-142f393e727e	INTAN TRI OKTAVIANI	P	242510123	\N	\N	\N	2	28	2526	0099774044
d8524435-631f-49d1-baea-b498ce83d381	LABIB MAULANA GUSTI	L	242510196	\N	\N	\N	2	28	2526	0099790751
a335f772-f932-4e9b-b4d5-44361f0f4927	LIANA PATEHAH	P	242510197	\N	\N	\N	2	28	2526	3098985402
9ea39092-9e60-4f30-a473-6eea42e6406b	MAULA FITRI SHOLIHAH	P	242510090	\N	\N	\N	2	28	2526	0087118731
c9d4a707-2f52-4d6f-a332-3d2ad12ac17d	MOHAMAD ARFAN ARIYANSYAH	L	242510127	\N	\N	\N	2	28	2526	0099512020
4ff66959-ca7e-4e8c-ab03-0b03c88f7791	MUHAMAD RAYHAN ALFA REZA	L	242510236	\N	\N	\N	2	28	2526	0096987871
6e8ca42c-14dc-46d4-b0ae-6b45e222d65f	MUHAMMAD FALDAN AL AYUBI	L	242510201	\N	\N	\N	2	28	2526	0096584973
9a579728-1d75-4bc3-bd58-6269d3390fac	NANDA AURA	P	242510310	\N	\N	\N	2	28	2526	0092315103
4b0af8d8-c0a8-430b-9bad-7b3150cb9c6c	NEEZAM MAULANA ALMOUZA	L	242510275	\N	\N	\N	2	28	2526	0085041545
87e09539-1ec4-42e5-9688-50c6c79157e3	NUR FAUZIAH	P	242510240	\N	\N	\N	2	28	2526	0095213961
d8b63280-58db-4144-82a0-f6392672e82d	PRITA TRI APRIDA	P	242510172	\N	\N	\N	2	28	2526	0094176112
1702f159-80ca-4758-b5d5-f25be7f48bd3	PUTRA PRATAMA JAYA DININGRAT	L	000000001	\N	\N	\N	2	28	2526	3095563831
33f9fb19-6ecc-4089-a81b-479a7c2f40f1	RAHMAH SYAFAWI	P	242510206	\N	\N	\N	2	28	2526	0091826183
84c12a6b-9a6e-4a5d-b2f6-74ace0c26e9f	RAYIWINATA	L	242510422	\N	\N	\N	2	28	2526	0092073731
dc3229bd-998c-4202-82a1-1d5a974e803e	REY HANUN ELFARIANI	P	242510136	\N	\N	\N	2	28	2526	0082369094
611f5243-9030-482a-a863-3893cf862742	ROSA	P	242510138	\N	\N	\N	2	28	2526	0099265099
1a342120-0ae9-47d8-a2c3-c23e88067da5	SARAH ELLYCIA JOHAR	P	242510033	\N	\N	\N	2	28	2526	0087746303
c81de81b-5e60-47cd-bdaf-1efa7edc1aba	SITI FADILAH	P	242510140	\N	\N	\N	2	28	2526	0097808176
ff202465-dd4a-4b77-9075-c08a689165c0	SRI SUPRIYATIN	P	242510428	\N	\N	\N	2	28	2526	0087556000
81814349-883c-4e18-b34a-db83a152f5d8	SYAHRIL LADINA	L	242510213	\N	\N	\N	2	28	2526	0086958039
9ef87ccb-cc13-45bb-a7ab-a783cd640f21	SYAMSUL AHMAD SALUKI	L	242510249	\N	\N	\N	2	28	2526	0091407220
a162cd4e-bb62-4184-b2e5-16c71407c34e	TIARA NURUL HIKMAH	P	242510357	\N	\N	\N	2	28	2526	008486535
a43e288d-df9c-42e4-a886-2df6f0903982	YESSI AMALIA	P	242510144	\N	\N	\N	2	28	2526	0097171523
ed9f761e-39bf-404b-885c-d02efa11b18f	AHMAD FAZRIL HIDAYAH	L	242510003	\N	\N	\N	2	29	2526	0081442700
c6d21ec3-d3ba-4a9c-87e4-a801fd69b548	AISHA NURLAELA RAHMA	P	242510218	\N	\N	\N	2	29	2526	0094962626
01949448-b553-4784-a6f6-0f85ff02abdc	ALENA VIDRIANI PUTRI	P	242510255	\N	\N	\N	2	29	2526	0097131859
42b48fef-85dc-4a9d-934d-493a7ab8c224	AMELIYA	P	242510040	\N	\N	\N	2	29	2526	0093183558
5bb074ca-bab4-45bb-bb96-38c0076cb5b0	ANNISA PRATAMA	P	242510292	\N	\N	\N	2	29	2526	0099960993
96a43561-837d-4c79-b09b-23ae298e1a71	ARIFIN ILHAM	L	242510113	\N	\N	\N	2	29	2526	0091149125
525e9de7-62f7-40ce-92d7-95298f4a779b	AULYA FOREN DHINIATI	P	242510221	\N	\N	\N	2	29	2526	0097535300
7dd6eae1-b59c-42c5-ad01-362f0300bc03	AZNA AZKINA	P	242510186	\N	\N	\N	2	29	2526	0084057348
199d457c-2c05-468f-8c8a-cd89c7311780	CITRA WIDIYANINGSIH	P	242510153	\N	\N	\N	2	29	2526	0093607194
dfb699e6-0586-44f1-b689-94167ca869b4	DIAN MESA	P	242510046	\N	\N	\N	2	29	2526	0097521032
2ce946d7-67ba-4ebf-b02b-0164bfecb605	EKA SUMITRO	L	242510011	\N	\N	\N	2	29	2526	3085339609
acbe7e30-bec2-4d73-aabc-4dbd5fc54b7f	FIKRIYAH AULIA RAHMAH	P	242510300	\N	\N	\N	2	29	2526	3099310219
5f598463-7535-4daa-97d7-a1ece94c4557	HAFIZH FAIDURRAHMAN	L	242510086	\N	\N	\N	2	29	2526	0083705229
ada99e11-129f-48dd-9308-e56cbb95098e	HAFSAH MARA'TUS SOLAEHA	P	242510193	\N	\N	\N	2	29	2526	0096445850
df3cb8f2-31b5-45bb-95e0-91e96c3841ea	JUWITA	P	242510231	\N	\N	\N	2	29	2526	3099675462
1f07482a-fd20-41d7-b8d6-9a3879b4c163	LIZA NURHALIZA	P	242510018	\N	\N	\N	2	29	2526	0082141428
6ecd3b8b-f691-4baf-aab1-71de6ab7eca7	M. IZDIHAR TRIANTO	L	242510376	\N	\N	\N	2	29	2526	0098089126
8aa5ae40-f4e6-4adf-9c0a-61ce0d79ac68	MERILDA RAHMAWATI	P	242510342	\N	\N	\N	2	29	2526	0062561699
066862c8-d6de-4e98-8268-79ce5d73df6e	MOHAMAD FERDIANANT PUTRA	L	242510199	\N	\N	\N	2	29	2526	0082981301
74979929-b4a8-49eb-b959-91c8be060eb8	MUHAMAD FAHRI	L	000000002	\N	\N	\N	2	29	2526	0096386290
9d985856-6a7e-4431-92b4-de1c701546c7	MUHAMAD RENDY	L	242510272	\N	\N	\N	2	29	2526	3092294777
d2085c98-a063-4744-a4ca-af900e80617c	MUHAMMAD HARIS MAULANA	L	242510273	\N	\N	\N	2	29	2526	0096393113
93779964-047f-490f-a8fe-26b6611b2aa9	NASHA RAHMA SYABILA	P	242510346	\N	\N	\N	2	29	2526	3098578807
5067bb65-0a87-4ec7-9265-80ba45b086ce	NURAENI	P	242510276	\N	\N	\N	2	29	2526	0094229772
e50e753d-18d9-4514-b2c2-04196bb93230	ORIZAN ALAMSYAH	L	242510312	\N	\N	\N	2	29	2526	0096908252
717eaf95-c545-421d-a8bf-547ed8f414cc	PUTRI ANATASYA RAMADHANI	P	242510241	\N	\N	\N	2	29	2526	0096145494
87c8db0b-cc21-4678-ae1c-429a0fac0151	REGITA CAHAYA PUTRI RAMADHANI	P	242510279	\N	\N	\N	2	29	2526	0085743671
5e86356d-d832-4b0a-8e35-cf6c130198f7	RIAN FADLI NUGRAHA	L	242510137	\N	\N	\N	2	29	2526	3083671258
d839a9c2-2adc-4162-80bc-18586976d3d5	RIFQIYAH	P	242510176	\N	\N	\N	2	29	2526	0095050687
c6a43867-278e-44fc-b69f-7eeda5d0b823	ROSELLY TRIANDINI	P	242510177	\N	\N	\N	2	29	2526	0097501333
db01503f-838d-4fa4-8727-ca4b09f8dacc	SARAS SINTA KHLODIA	P	242510103	\N	\N	\N	2	29	2526	0093636518
56d6bf1a-aeb1-4efa-a933-5826b987010a	SITI FARHANNAH	P	242510179	\N	\N	\N	2	29	2526	0092878993
75ed62d9-3201-44f7-9fc8-c94550d59e4a	SULENY	P	242510035	\N	\N	\N	2	29	2526	0093204806
5c3e9849-afca-48f6-b52c-bc6a44346e4d	UNI AMELIAH	P	242510143	\N	\N	\N	2	29	2526	0093845265
a9675bd2-8ac5-47de-b1d4-272cd1d17107	ZAHRA AMELIA ZULKARNAIN	P	242510288	\N	\N	\N	2	29	2526	0087361029
dcb98d8a-72f2-41ce-be1a-e556fb783a96	AHMAD RAFI AL AMSORI	L	242510075	\N	\N	\N	2	30	2526	0089055838
5a25c5c5-97c5-4058-bb5c-bba0efcfc599	ANDINI AVRILEA	P	242510076	\N	\N	\N	2	30	2526	0096487681
f41f328f-74b5-4983-9230-1d1a67c53d4c	AQIS BILQISTY ALMUNAWAROH	P	242510328	\N	\N	\N	2	30	2526	0092313755
ed6f6a30-c408-45ba-a5f8-be92d6afbb18	AURA ALMAYGA SALSABILAH	P	242510257	\N	\N	\N	2	30	2526	0096229940
8fab6bbd-9b75-4012-b50c-2350acbe5e36	AZZAH NURSALSABILA	P	242510222	\N	\N	\N	2	30	2526	0089347152
a3fa23c9-ec93-413c-a0c8-e52673f14ae4	BAGAS ADAM EL FARID	L	242510187	\N	\N	\N	2	30	2526	00867088149
b6351488-02e8-425f-b017-72816e019898	DAVINA ROSSALIE ZAHRA	P	242510224	\N	\N	\N	2	30	2526	0091250192
4ef1586b-4265-4bc9-a119-2b9cd7a99a46	DIANA PUTRI	P	242510118	\N	\N	\N	2	30	2526	0084941902
97040a3e-b6e4-447e-8219-cbf84d2a6569	FAJAR AFFANTRI	L	242510120	\N	\N	\N	2	30	2526	0098309262
72fb8313-d9ce-4e44-9f3f-fbada881546f	FIONA RACHMAWATI SUKMA	P	242510336	\N	\N	\N	2	30	2526	0099325616
f4027f9a-8c1e-4b64-8a8a-1cbff12df6c4	HILMAN DWI PERMANA	L	242510302	\N	\N	\N	2	30	2526	0098687754
71315694-d94a-40a4-9aa0-5e8530edb4db	HILWA LABIBAH PUTRI AS SIDIK	P	242510338	\N	\N	\N	2	30	2526	3097674194
ec6137a7-6bf0-4891-a967-56e4c4310b56	KEISYA SHARLIZ RAMADHANI	P	242510303	\N	\N	\N	2	30	2526	008424310
2d17ae1a-25ec-447c-9249-89c2ce72c8e8	LUFIANA RAMADHANI	P	242510268	\N	\N	\N	2	30	2526	0095316254
52161968-6e5c-4082-ac01-04f09c2b2a81	M. MUDZAKI ALFARIZI	L	242510305	\N	\N	\N	2	30	2526	3083079913
65afadc3-54ac-43e5-acfc-51303f77f8a7	MILLAN OCTAVIANI	P	242510413	\N	\N	\N	2	30	2526	0097767603
160de822-56c7-499c-9831-97bf9cf78246	MOHAMMAD FALUTI	L	242510235	\N	\N	\N	2	30	2526	0083282045
b4210993-5dde-432d-91b2-82200898cf83	MUHAMAD RIFAI	L	242510308	\N	\N	\N	2	30	2526	0094628342
a5141dd7-d353-4e62-8f6c-aa7e08f179c4	MUHAMMAD LABIB SHAFWAN	L	242510309	\N	\N	\N	2	30	2526	0097105910
1f4f0d5b-cd32-4156-88f2-4c3c85d0fadd	NATASYA PUTRI RANGGITA	P	242510382	\N	\N	\N	2	30	2526	0096083406
22ffbbc7-a87b-4c06-8aad-541e41e55666	NURAINI	P	242510311	\N	\N	\N	2	30	2526	0093903376
0b4801da-4766-4da7-980a-eb3d87515feb	PUTRI INTAN AMALIA	P	242510384	\N	\N	\N	2	30	2526	0092488579
66a5dfbb-75ff-43c1-b00d-eea02b98fb07	R. PRABA ESA HERLAMBANG	L	242510421	\N	\N	\N	2	30	2526	0096843856
decb73a0-3b70-45c1-ac87-e2bf537614d0	REPI JULIKA AGESTI	P	242510387	\N	\N	\N	2	30	2526	0084639457
5e412ce1-12f9-4a1c-a34f-94fc71727031	RESTY AZZAHRA PUTRI HIDAYAT	P	000000003	\N	\N	\N	2	30	2526	0097193268
09800f6b-0207-4536-95c1-3a8983796044	RIKA AGUSTIN	P	242510209	\N	\N	\N	2	30	2526	3099355093
e8df4791-1ca4-4ccf-9fa0-4d945aa5656f	RIY ADUSSHOLIHIN	L	242510353	\N	\N	\N	2	30	2526	0086890080
733c743a-925d-4560-ac54-849b6a06dfcc	SAFARINA MUMTAZA	P	242510282	\N	\N	\N	2	30	2526	0094869744
5716368f-1e2b-4086-a271-5f8acb24ecb5	SELI RAHMAWATI	P	242510247	\N	\N	\N	2	30	2526	0091187329
8ad918ee-ad86-4329-85a9-03bb942ad98f	SITI HAWA	P	242510212	\N	\N	\N	2	30	2526	0082304108
7b4f2139-0db6-4c8e-b95c-1261ab82c726	SULISTIYA ANGGRAENI	P	242510070	\N	\N	\N	2	30	2526	0082513152
a3bd2fc5-8096-496f-8060-f36c5b580e26	TEGAR PRATAMA	L	242510321	\N	\N	\N	2	30	2526	3094364478
a5f0623a-517c-435f-872b-5c73e3a67a59	VANEZZA KHINARA BERLIANNA	P	242510215	\N	\N	\N	2	30	2526	3094229510
8762cdc1-ce50-46ee-923e-b4ac04751c72	WILDAN BAIHAKI	L	242510359	\N	\N	\N	2	30	2526	0096041885
63092e43-3b41-4cc2-835f-2b2ab61a3e77	ZAHRA KHOIRUN NUVUS	P	242510324	\N	\N	\N	2	30	2526	0087547745
33eaf319-b211-4853-82b8-908896f4648f	ABID HARDIANSYAH IRAWAN	L	000000004	\N	\N	\N	3	22	2526	0087873860
31a46af0-3053-4add-b5d4-f71378e84f3d	ADELIA CITRA SANDI	P	232410164	\N	\N	\N	3	22	2526	0085211882
40a9e0a0-d390-4002-bbac-1d367443950e	AHMAD ASRORI	L	232410074	\N	\N	\N	3	22	2526	0087082403
3ddd8faf-e85c-4837-aad9-36b60d796cfc	AINUN NURAENI	P	232410297	\N	\N	\N	3	22	2526	0086566653
db8d85b6-fb89-4bb5-b6d6-93fa0839da06	ANISAH OKTAVIANI	P	232410420	\N	\N	\N	3	22	2526	0085333211
ea28ad52-989f-476c-aa11-c454e577ff9e	ANTONIO SODIK IBROHIM	L	232410402	\N	\N	\N	3	22	2526	0083887492
7ae69b33-7eb9-482f-8dba-6c0f87b32a8f	ATIKAH	P	232410355	\N	\N	\N	3	22	2526	3085684523
93bea357-83f3-47cd-858c-488ae04a0515	BUNGA KENCANA DEWI	P	232410109	\N	\N	\N	3	22	2526	0082559104
16a95f78-c2c4-481c-9082-9f8719bd105f	DEVIANA NADIA PUTRI	P	232410277	\N	\N	\N	3	22	2526	0077685640
9b0834b3-e76b-4232-a77c-b30203350d02	EGA DWI ASTUTI	P	232410130	\N	\N	\N	3	22	2526	0079444578
45d00516-169b-4cf6-820a-9c1d0ea6943c	FAIS HARDIAWAN	L	232410312	\N	\N	\N	3	22	2526	0097149786
3e732d2a-d778-4da0-a8dd-dd58aafed33a	FINA NAILATUL IZZA	P	232410248	\N	\N	\N	3	22	2526	0074154719
6557af39-2609-4f5c-98f1-04b692df4262	HASNA ZAHROTUL HAYAH	P	232410344	\N	\N	\N	3	22	2526	0082620177
de9cf4ab-0640-4cd2-9082-237650053db8	INDIYANTI	P	232410076	\N	\N	\N	3	22	2526	3083733339
d2aa2bca-ae84-4193-8494-57991c1d35a2	JAMALUDIN	L	232410242	\N	\N	\N	3	22	2526	0075163563
dd0479c9-b3a7-4d26-9faa-5dbe1bcb8ccc	KHULAEFAH	P	232410397	\N	\N	\N	3	22	2526	0076595740
d90a2147-93f6-4448-8c81-4e0ce0650331	LOVPA MARGIATNA	L	232410070	\N	\N	\N	3	22	2526	0074558170
9df0cd4c-beff-49f1-a90c-ecba007189d5	M.FATHIR AL ZIQRI	L	232410204	\N	\N	\N	3	22	2526	0081090890
d0f7e269-1785-4830-8bce-34ef39f2ccab	MARSHA PEBRIANA RIDWAN	P	232410296	\N	\N	\N	3	22	2526	0083381649
dc523077-6781-4679-9d06-c3373a88856b	MOHAMAD PEBRIANTO	L	232410072	\N	\N	\N	3	22	2526	3088239821
92204eb9-15d7-4c94-a14d-6782027afdcb	MUHAMAD ARIFIN	L	232410050	\N	\N	\N	3	22	2526	0078389887
2767489f-f21f-4b7c-b0e2-632c4ff217a9	MUHAMAD ZALDI AKHYAR	L	232410166	\N	\N	\N	3	22	2526	0077866291
75832aa5-76f4-4af0-83db-b22f64a88981	MUHAMMAD RABBANI ILHAM	L	232410278	\N	\N	\N	3	22	2526	0086397433
dc923c0a-005b-45f8-aa30-ccb824c4c615	NELI FITRI SARI	P	232410098	\N	\N	\N	3	22	2526	0073643490
7670affd-aa93-436f-ba19-905807d8bd44	NUR PURI WULAN DARI	P	232410205	\N	\N	\N	3	22	2526	0074587649
2c36a95c-6f34-474f-80bd-53b6a1b5bbaf	PRABU YUDHISTIRA	L	232410190	\N	\N	\N	3	22	2526	0072957839
65c99931-0ddc-4236-bc42-9a3842f62e2f	PUTRI INDRAYANI	P	232410273	\N	\N	\N	3	22	2526	0091314760
7fb7736d-bfee-49c4-a502-1451221651ee	REVALDI	L	232410234	\N	\N	\N	3	22	2526	3073666738
200c400d-36c0-4831-b919-715869ba5dc1	REVAN HIFDI HIDAYANTO	L	232410406	\N	\N	\N	3	22	2526	0074902679
e833e6e2-2895-4954-9e2e-c311c23058f4	RIANA	P	232410113	\N	\N	\N	3	22	2526	0072194716
705740ce-38d3-4fb6-a29a-e5b8ae4ee882	SEFIANA KESUMA WARDANI	P	232410358	\N	\N	\N	3	22	2526	0087215631
3104b3cd-6cee-4ca1-873b-70e1ef31333f	SHOHIBUL ABI	L	232410379	\N	\N	\N	3	22	2526	0084604168
44a0d65b-2ba0-4c61-9f2d-3b268595a499	SIGIT	L	232410421	\N	\N	\N	3	22	2526	0082103598
10d6165a-4d1d-4519-995d-5fe24c852fcd	SITI ANNISAH TUSSA'DIYAH	P	232410202	\N	\N	\N	3	22	2526	0081837829
c02223a3-cfd9-4616-b6c1-39e67672261f	SITI ZAHRA	P	232410427	\N	\N	\N	3	22	2526	0098804452
36a7a6cd-8722-4d44-91e6-9a0c0faa8cc0	WULAN	P	232410158	\N	\N	\N	3	24	2526	0087164491
8d3a84cf-e90e-47ac-8de2-5c56104494e9	ADE SOFYAN RIPALDI	L	232410083	\N	\N	\N	3	24	2526	0068559918
29e825d3-53a8-4d7f-a362-6ab145fd2441	ADINDA MUTIARA HAMIDAH	P	232410233	\N	\N	\N	3	24	2526	0076271295
c1da2db2-d516-43b7-947a-e7ce6ee19486	ALFIAN PRATAMA	L	232410343	\N	\N	\N	3	24	2526	0086319929
ddf0e8a9-888b-4929-9cf6-98f5a1fc0e8b	AMELIYANI	P	232410186	\N	\N	\N	3	24	2526	0081933426
3259ae99-1eaa-4cb9-b2b4-b615e39d2e1f	ANITA ISABELLA	P	232410118	\N	\N	\N	3	24	2526	0087292309
50b87438-9271-4a1b-b67f-e724dfc323e7	ARMAN SAEPUL MILAH	L	232410264	\N	\N	\N	3	24	2526	0077060294
f61a4d0b-87bf-4d77-94e6-5dd48d38d24e	AULIA	P	232410025	\N	\N	\N	3	24	2526	0074946103
86d9ea32-439c-4ce6-85a8-98df0307ab5a	CITRA YANI	P	232410012	\N	\N	\N	3	24	2526	0073657889
7fd833f9-faba-4e5a-aecf-6753321c7e49	DIAN APRILLIA	P	232410129	\N	\N	\N	3	24	2526	0089164169
6ffa555e-f913-49d2-a21e-1c4b8df75d3d	EVELYN DESTY ADELLA	P	232410022	\N	\N	\N	3	24	2526	0076815424
b8d9aef0-8934-48c6-be15-606b89695caf	FAATHIR AWWIBI	L	232410322	\N	\N	\N	3	24	2526	0088378215
6e652814-c473-4376-9058-5c4782eecaab	FAQIH AL IDRUS	L	232410051	\N	\N	\N	3	24	2526	0083389672
08cdfd62-13b3-4a48-b159-a296f00c6076	GADIS SAFUJI NABILA	P	232410413	\N	\N	\N	3	24	2526	0088971730
85d6944f-88dd-46aa-bdfa-d45fbed1cdf8	GALUH PRASETIYA PRATAMA	L	232410222	\N	\N	\N	3	24	2526	3083675506
520adaf5-439d-4d0f-8e6d-6032ca36c6de	HAZIZAH ALVIAH	P	232410121	\N	\N	\N	3	24	2526	0088125540
1b9231c8-b527-49fa-a6f0-e18a37d69c3c	JUWITA KHAELA RAKHMA	P	232410208	\N	\N	\N	3	24	2526	0084406962
a584d538-cc72-45de-8ea3-f805df8181ac	KHUSNUL KHOTIMAH	P	232410243	\N	\N	\N	3	24	2526	0083247504
ee169153-2a15-42e9-b9e6-91a0e09cd37f	LUQMAN SYAHRI	L	232410377	\N	\N	\N	3	24	2526	0081118451
69fd02f4-50b1-41e9-bb5b-68f8bd7a9cf0	M.FERDIANSYAH	L	232410069	\N	\N	\N	3	24	2526	0063544042
3da9a343-31b7-428a-9009-f941f27040bd	MAULIDA	P	232410287	\N	\N	\N	3	24	2526	0082501038
4941758a-cae1-4a9e-a4a5-7f27b06bcc0f	MOHAMMAD RISKI	L	232410341	\N	\N	\N	3	24	2526	0076950830
01b01310-1729-47ba-b857-eccb0e7a3caa	MUHAMAD FATAN FAHMI	L	232410368	\N	\N	\N	3	24	2526	0087351640
bcda13cb-73cf-43ca-be6a-0a4762ddc259	MUHAMMAD CANDRA WIGUNA	L	232410307	\N	\N	\N	3	24	2526	0084320960
85a1ed7a-6349-4ae2-86a8-59a24719740a	NIZA AKIFAH	P	232410286	\N	\N	\N	3	24	2526	0087092557
8c21e707-ab83-4ec6-842d-beec2d2ba9fe	NURHAYATI	P	232410308	\N	\N	\N	3	24	2526	0072156607
e963ec20-5478-491b-ba37-f2fd90c5f406	PUTRI MARYANA	P	232410142	\N	\N	\N	3	24	2526	0087752114
4eb6d4ef-3d92-46fa-beb5-b92c5a658638	RAHMAT HIDAYAT	L	232410364	\N	\N	\N	3	24	2526	0079130149
721a3bf6-954a-4d44-b25a-dc6facef0175	REVANO CRISTIANTO	L	232410052	\N	\N	\N	3	24	2526	0087936193
98b082ae-0f75-4787-813f-805dde09a21b	RISKI	P	232410197	\N	\N	\N	3	24	2526	0089888357
25e64943-8cc2-45c8-a2c8-54c7ebeff7eb	SEKAR PURNAMA SARI	P	232410097	\N	\N	\N	3	24	2526	0077096812
a5f864d8-ad06-464a-945f-eb6104550b80	SITI ATIYA	P	232410371	\N	\N	\N	3	24	2526	0085233436
58853390-548c-4bc2-b1e4-cc3707326926	SOFI ROHFIATUL	P	232410376	\N	\N	\N	3	24	2526	0099085229
ccaecca2-5200-4ea3-9420-0bab9fe844f7	UBAEDILA	L	232410039	\N	\N	\N	3	24	2526	0089330311
7c55e0ef-e2b7-4707-aad7-54340bc0a6e0	VIANDRA YOAN PUTRA	L	000000005	\N	\N	\N	3	24	2526	0082046429
a30adc9a-b56c-4622-a69d-6ac3f6b17b93	WISNU NURHIDAYAT	L	232410323	\N	\N	\N	3	24	2526	0081168662
051caa83-a002-4903-ad6c-69078b28667f	WULAN MUTIARA	P	232410018	\N	\N	\N	3	24	2526	0079765008
cc053021-6b64-44a9-9f9a-2591295bd071	ADITIA RAHMAN	L	232410136	\N	\N	\N	3	25	2526	0074008718
88d64815-1542-40a4-b167-855f772c3a6e	AFNI TRI SULISTIYANI	P	232410114	\N	\N	\N	3	25	2526	0075886054
d5e5dd99-6aeb-4abd-b940-767820c47a76	ALGHIFARI	L	232410139	\N	\N	\N	3	25	2526	0078395285
0353b20a-c23d-41bb-b5a4-dc4af207c251	ANDIEN SYA HIRA DEVI	P	232410157	\N	\N	\N	3	25	2526	0088058605
2319b7c7-30f9-415c-8f41-327032e04d6e	ARINI RAHMAH SURYANTIKA	P	232410023	\N	\N	\N	3	25	2526	0081718196
b9617e7f-e54e-4dc8-accd-85c856726e0d	AYU LESTARI	P	232410195	\N	\N	\N	3	25	2526	0082129839
4528ecee-4ecf-4711-b62a-0db55e2f9c0d	CLARISSA FEBRY ANNAET	P	232410213	\N	\N	\N	3	25	2526	0082532320
97e0b6e9-b940-48a6-b9ac-e036984f98f1	DIANI MAYANG SARI	P	232410161	\N	\N	\N	3	25	2526	0086717456
97f0af97-430f-4eaa-b814-8b15ef747be3	FACHRI ARDIYANTO	L	232410053	\N	\N	\N	3	25	2526	3061531739
cfb647cf-b606-4c10-bcaf-707d01b65b66	FANI NUR FADILAH	P	232410094	\N	\N	\N	3	25	2526	0081146949
4f82a258-e641-4d5c-b8d2-4df0bbaa7ad8	FARIS RISWANTO	L	232410381	\N	\N	\N	3	25	2526	0089695583
b2a56122-1b37-45ba-8913-ad0366ff3ecc	GHINA DWI ASTUTI	P	232410123	\N	\N	\N	3	25	2526	0087157578
7bd77f01-ca3d-4a95-b7d7-9594d6723e72	HABIB RIJIK	L	232410269	\N	\N	\N	3	25	2526	0077515405
d853e20b-96fa-4898-8b61-7a375ae4fd58	ICHA FLANELA LESTARI	P	232410326	\N	\N	\N	3	25	2526	0075676539
028750e3-be42-4a24-b735-670afae8c4d6	KANA JELITA	P	232410336	\N	\N	\N	3	25	2526	0082132398
ba42947a-1be7-4f38-9621-c23eed9bfc0b	KIKI MUFAQIRO	P	232410061	\N	\N	\N	3	25	2526	0082515133
4aed6ecc-f24c-4d8c-832c-c79c59c6604a	M. ERWIN RAHMA WIJAYA RAKSA W.	L	232410227	\N	\N	\N	3	25	2526	0071533949
e09e3a8e-ead5-4222-82e0-140e8a972e72	MARVIN ADI ANTO HAVIZ PANJI PRAYOGA	L	232410167	\N	\N	\N	3	25	2526	0088993227
e51b1622-8b30-4627-8b46-3bb203b9f187	MAYSICKA AULIA	P	232410090	\N	\N	\N	3	25	2526	0081274226
3507e6db-04ad-4aba-bc75-6db9773a964a	MOHAMMAD SAVIK MAULANA	L	232410085	\N	\N	\N	3	25	2526	0066006877
759d7bf1-8b3a-4644-9cbc-de1f3ce36bb0	MUH SYAUKANI ROHMAN	L	232410350	\N	\N	\N	3	25	2526	0088392207
74f610aa-712c-4d71-8960-4c7be280e69e	MUHAMMAD FAIZ HAKIM	L	232410389	\N	\N	\N	3	25	2526	0081485177
629808b9-d7ed-4fd4-b24f-ca48f888e7e6	NAYO SUNARYO	L	232410354	\N	\N	\N	3	25	2526	0081901530
1fbc9efd-7cd6-4975-8f95-65aeea1b0154	NURHABI'I JUNIOR	L	242511433	\N	\N	\N	3	25	2526	0087785029
4ba6d61b-846a-4649-91cd-206b08c56a28	NURKASIRO	P	232410232	\N	\N	\N	3	25	2526	0081228822
75c7f464-1062-4850-be7f-3f06f3268848	RASYA SAYYIDINA ALI	L	232410410	\N	\N	\N	3	25	2526	0073984810
2f42dcf3-70eb-4b8e-a730-c022a0d9c6c5	RATIH SELA AGUSTIN	P	232410266	\N	\N	\N	3	25	2526	0086022719
d9bef24e-ce9b-43a6-ad5e-d2a02ba5e280	RIFKI NURPRATAMA	L	232410285	\N	\N	\N	3	25	2526	3083694841
39441b56-be11-4628-9587-c244834658c1	RUBI RAHMA YANTI	P	232410119	\N	\N	\N	3	25	2526	0063647468
1459908a-d4b8-491b-9b8c-7f9261f39ab5	SENIAWATI HARUN	P	232410003	\N	\N	\N	3	25	2526	0071568788
4a97cf1e-0c63-4af2-b3dd-1fbc495307a2	SITI FADILA	P	232410414	\N	\N	\N	3	25	2526	0078229741
6e8b2990-6409-44f9-a828-05ee98ccfbd7	SOFIYANTI RAMADANI	P	232410316	\N	\N	\N	3	25	2526	0087129224
078d6f02-cb51-42b8-8b91-1a7a3f140ae8	WAHYU SYAFIF RASIDI	L	232410002	\N	\N	\N	3	25	2526	0087974212
ff61a9eb-32e0-4f72-b55f-80df7363b456	ZAENAL ABIDIN	L	232410318	\N	\N	\N	3	25	2526	0085055210
d5f63c7c-389a-4864-a05c-5a6adf0315bc	ZAHRA ABELIA HAKIM	P	232410033	\N	\N	\N	3	25	2526	0081214071
29e1dc48-16d2-49c3-9140-d63048258abe	ADITIYA PRABOWO	L	232410255	\N	\N	\N	3	26	2526	0081372987
52deb54f-4269-4b35-8ca2-2ee65e266142	AI MARISKA HARAHAP	P	232410305	\N	\N	\N	3	26	2526	0086149709
d3897e7b-7c07-4082-adc3-7fe72c0decbf	ANDHIKA RIZQI KARTONO	L	232410007	\N	\N	\N	3	26	2526	0087394883
a74af69f-cc4e-4706-8874-9b2ccccf4345	ANGGI HARYANTI	P	232410107	\N	\N	\N	3	26	2526	0087320523
7749f92a-fc41-413b-a2bf-b3ae8ab776c0	ASYFATUL KAMILAH	P	232410372	\N	\N	\N	3	26	2526	0087846406
39ec19f8-bebe-4d0b-9e39-76b83bc1af6f	AYU SEKAR RANG RANG	P	232410327	\N	\N	\N	3	26	2526	0087737609
42aa5018-a3ee-40f8-95c5-6dcb3e43b2d2	DAFFA DHIMAS AL - ATTAR	L	232410182	\N	\N	\N	3	26	2526	0084344501
494cc52f-8a84-4ecc-a341-f2213bd83f54	DELLA ALFIANTI PUTRI	P	232410145	\N	\N	\N	3	26	2526	0072217286
4b796efc-1911-4931-aaba-2b486a115854	DINDA EKA PUTRI	P	232410027	\N	\N	\N	3	26	2526	0089298032
6024df48-45de-4fd5-a541-03abb865af7b	FAHRI RAMADANI	L	232410184	\N	\N	\N	3	26	2526	0089768933
2b01166e-7c85-4900-852b-fe0c2d792690	FATIKH RAMADHAN	L	232410220	\N	\N	\N	3	26	2526	0074183272
3d61a6cc-48dc-4160-89b6-be755b77484f	FAURA ASSAYIDHATUM MUTIA	P	232410317	\N	\N	\N	3	26	2526	0085339530
fef9b2fc-1ac5-4326-b568-bdcd9c7d2d15	GHIYAST LAYLAH AREZ	P	232410169	\N	\N	\N	3	26	2526	0084163762
126fbff2-e5af-4941-83ad-c67027b7aa02	ICHA FLORENCIA	P	232410031	\N	\N	\N	3	26	2526	0083247140
048e41da-9516-488d-a79e-32fce55f78e6	ISHAQUL MUBAROQ	L	232410135	\N	\N	\N	3	26	2526	0084672909
47ef4cbd-95de-444b-91f1-8d1ca9d9ed5e	KARTINI ZULFA INDANA	P	232410231	\N	\N	\N	3	26	2526	0086489581
3366b2e4-104a-4869-9bd8-c0041898fc35	LAUDYA CHINTYA BELLA	P	232410054	\N	\N	\N	3	26	2526	0078950700
733e71ac-85f9-41b9-9d89-86276c81dafc	M. PRADITA HABIBILLAH	L	232410268	\N	\N	\N	3	26	2526	3086781254
a0be2c9d-85a9-4a9b-884e-96b5cbc98f90	MEI LINDA	P	232410378	\N	\N	\N	3	26	2526	0086596396
c1741189-90a7-4368-82fa-b9cb10830227	MOCH FAISAL ASSIDQI	L	232410131	\N	\N	\N	3	26	2526	0071368721
7d6e7561-3157-4154-806f-338c1a4d14e1	MUHAMAD FEBRIO RIZKI	L	232410418	\N	\N	\N	3	26	2526	0081839452
fb5fe8d4-9bc7-44ee-8ada-7a288c8f6a01	MUHAMAD GALIH HERDIYANTO	L	232410352	\N	\N	\N	3	26	2526	0086982978
85b805e7-b7aa-497c-b8c3-5147eacad4a3	MUHAMMAD FALIH ARIQ YANUAR	L	232410383	\N	\N	\N	3	26	2526	0084404696
3d653d7f-0707-4124-9940-f898861e0b90	NUNIK HANDAYANI	P	232410398	\N	\N	\N	3	26	2526	0074698410
a964d256-9b05-44c1-9bf8-e4bc7efcfa4f	NURMALA	P	232410120	\N	\N	\N	3	26	2526	0087087470
a56d1090-c4f7-4c41-8081-fcf0565f21fc	OKAN SYAUKANI ROHMAN	L	232410171	\N	\N	\N	3	26	2526	0077237807
5a1539a1-8f3a-4943-8569-f2fb4ecca1c7	REINKA PERTIWI	P	232410036	\N	\N	\N	3	26	2526	0072396616
6419ae25-a443-46db-ba9e-80cff8fe8713	RENOV AROFI	L	232410068	\N	\N	\N	3	26	2526	0073859076
e74710fd-fd2b-4aa9-a13f-8f2c8460ceeb	SALMA WISHESA	P	232410137	\N	\N	\N	3	26	2526	0082926904
cb4ce64e-a30a-4c5d-bf5d-fc26813c078b	SERUNI DININGRUM	P	232410301	\N	\N	\N	3	26	2526	0079834532
a0cc11fa-1af2-4826-a478-5e6675ce9018	SITI HALIMAH TUSA'DIYAH	P	232410337	\N	\N	\N	3	26	2526	0088595236
e8c03c58-09fa-40df-8344-bd5236a84788	SUCI DEWI KINASIH	P	232410238	\N	\N	\N	3	26	2526	0085767043
fb7bd566-d80b-4c14-997a-84a8b75f6193	WULAN NURHASANAH	P	232410112	\N	\N	\N	3	26	2526	0082381010
6ac026a2-3bdc-4c2d-9008-87db9a1f6f22	ZAHRATUS SITA	P	232410218	\N	\N	\N	3	26	2526	0078399626
9b2f6efa-cccb-4f1b-925d-7392843d242c	ZAHROTUL HIM'MAH	P	232410102	\N	\N	\N	3	26	2526	0082338029
45bb7406-dcb3-4660-ac6d-1b0cebde9373	AGUS SUWANTO	L	232410048	\N	\N	\N	3	34	2526	0086864945
f50b71fd-562e-48c6-8bce-5883684fd278	AIDAH GHINACAHYANI	P	232410134	\N	\N	\N	3	34	2526	0082752482
97201993-0790-43b6-89a0-3df052a06d4a	ANDREAN RAMADANI	L	232410346	\N	\N	\N	3	34	2526	0075536477
4e43653b-4b50-4107-a03c-4a58b2b3d645	ANGGUN DIANISA	P	232410240	\N	\N	\N	3	34	2526	0085867277
80946c2d-7d0b-4650-9333-92c39f786272	ANIS SABILAH	P	242511434	\N	\N	\N	3	34	2526	NNNNNNNNN1
d27d9594-c803-4e13-9c49-f0e0f3c9b5b5	ATHA NABILA AUFAA	P	232410276	\N	\N	\N	3	34	2526	0084711165
82e0d074-411c-4330-8aeb-9bea7bc32bf6	AZMI ALMER ZAMIL	L	242511435	\N	\N	\N	3	34	2526	NNNNNNNNN2
e2af5742-257a-4d0c-92e8-ca49700bed47	BELLA SAFITRI	P	232410320	\N	\N	\N	3	34	2526	0083614664
8590fb4a-9875-43c1-972a-e23e4b8b6441	DANU ARDANA	L	232410210	\N	\N	\N	3	34	2526	0076639301
944679fd-5203-4a09-a2fc-c8606c366bbb	DESTI NUR WANTI	P	232410127	\N	\N	\N	3	34	2526	0089843182
e180f92f-802d-416f-afe3-db7af7d928b1	DILLA RAJALINGGIH	L	232410356	\N	\N	\N	3	34	2526	0075574983
7dcc9243-8b72-4909-9c33-f48cb2e61040	DINI ANDAYANI	P	232410230	\N	\N	\N	3	34	2526	0081321759
4eea6da2-bde0-4e4f-ba55-2ba298d602e3	FAHRI RIZKI DWI PUTRA	L	232410422	\N	\N	\N	3	34	2526	0081893671
d383f335-9466-4817-a98a-1f76fa9ca45b	FEBRIAN DWI ANDIKA	L	232410293	\N	\N	\N	3	34	2526	0085861156
dcacfaf4-a11c-4762-94fc-ca4a4c36ee44	FERENNIKA ADILLAH SARI	P	232410146	\N	\N	\N	3	34	2526	0087900721
adaa1054-0da4-43b7-9215-a2ae03704a92	FIRGIE ADINDA DAMAYANTA	L	232410156	\N	\N	\N	3	34	2526	0087961706
20906a6c-b0ea-472a-9df1-6c40e3b617e5	HAFIZZA NUR SYAFA'AH	P	232410199	\N	\N	\N	3	34	2526	0089267968
4a1e79b4-8550-4e97-9f6e-25e3f25aa078	IMAS MASRIYA	P	232410177	\N	\N	\N	3	34	2526	0084452526
948a4158-584d-425e-b43c-e129aab6afff	KEILA SYAFA AZZAHRA	P	232410079	\N	\N	\N	3	34	2526	0087564666
2127acf5-4453-4cee-9ff8-00b3d7481b5c	LUNA AFWA MUNTAZAH	P	232410148	\N	\N	\N	3	34	2526	0095060367
81e24e0f-1fcc-45a9-be26-8c1a63f9a406	M.ABDUL KODIR JAELANI	L	232410078	\N	\N	\N	3	34	2526	0079675664
e0a888de-f0e9-438d-861d-406f5deff1e4	MOCHAMAD FAUZAN NABHAN	L	232410143	\N	\N	\N	3	34	2526	0083562275
27826b26-b3cf-4ff2-b921-822e9288c844	MUHAMAD ANDI MAULANA	L	232410151	\N	\N	\N	3	34	2526	0085925859
790524c8-0058-47ce-b72b-90867b59d9dc	MUHAMAD RIZKI ALFIANSYAH	L	232410115	\N	\N	\N	3	34	2526	0075058970
dfab5385-f3c1-46f0-b301-06a4924fcd9b	MUHAMMAD NAJIB	L	232410058	\N	\N	\N	3	34	2526	0085112441
29a2450a-663c-4a65-8e3b-86307ff29add	NAZWA ALI NURFAKHSYAH	P	232410333	\N	\N	\N	3	34	2526	0047272374
a4ca6943-8be3-41d2-ab12-5be60440bed8	NUR NAJMA JAMILA	P	232410360	\N	\N	\N	3	34	2526	3079847058
4257d843-12f1-4f6c-aae0-618da4132a20	PANDU MULYAWAN	L	232410091	\N	\N	\N	3	34	2526	0081887324
497b325d-fd6e-4049-9201-c397f43f81ee	PUTRI ABILLAH	P	232410108	\N	\N	\N	3	34	2526	0084138351
4c3397ec-6de3-4416-accb-bf6f5962cb95	RESTI AGUSTIN	P	232410385	\N	\N	\N	3	34	2526	0082395881
c46dd628-1435-42b5-95a2-eda9a4deb02d	SALWATUZZALFA	P	232410198	\N	\N	\N	3	34	2526	0086125140
0c08dcc8-d9e8-4154-87cb-e25ba48fa1ac	SHEVILLA NUWI APRILASYANNI	P	232410064	\N	\N	\N	3	34	2526	0083141181
653997ec-ace9-4a30-8970-fcd145ec5b20	SITI KHODIJAH	P	232410089	\N	\N	\N	3	34	2526	0071523643
b20bddda-36f2-46a0-b139-6f105880e404	SUCI NUR MAULUDIA	P	232410407	\N	\N	\N	3	34	2526	0089385096
22efe098-ddc5-4a80-ad01-6dc15ee1fd46	ZAHRA NAYLA SALSABILA	P	232410284	\N	\N	\N	3	34	2526	0082745612
9f8ce72d-d932-4acc-bbc2-c88ff403728f	ZASKIYAH NURROHMAH	P	232410067	\N	\N	\N	3	34	2526	0078441146
75558eb0-5aa3-4257-aa8f-6ce8f340ebb5	AGISNA AULIA RAMADHANI	P	232410324	\N	\N	\N	3	35	2526	0082040356
814733dc-ae55-4593-a3aa-4833336f5db2	AIKO ISLAMI PUTRA NUGROHO	L	232410282	\N	\N	\N	3	35	2526	0083656476
da07306f-247c-486c-9ff2-c9c42d79d83a	ANALIN LUMANDA	P	232410004	\N	\N	\N	3	35	2526	0076540621
8972f1fd-095e-4466-bb10-a286695dddc2	ANDHIKA GIART AKHMAD	L	232410357	\N	\N	\N	3	35	2526	0082742457
6f2f11c5-b520-45c0-8c40-a2b474d93793	ANISA	P	232410313	\N	\N	\N	3	35	2526	3089551744
9c79e66f-5e36-45b7-ace5-5aa09d6feaf6	CANTIK OCTAVYANITA	P	232410056	\N	\N	\N	3	35	2526	0085885426
d1abd306-8928-4024-a319-b2fdfc9f6e91	DAFA BAKHITS OTOREOS	L	232410001	\N	\N	\N	3	35	2526	0084177067
0fb0501b-33d3-4037-838f-e421acd0609f	DELA SABRINA	P	232410189	\N	\N	\N	3	35	2526	0083110934
61f5dd5f-33c6-47a7-b052-718dff2641ba	DINDA CITRA LESTARI	P	232410125	\N	\N	\N	3	35	2526	0071569787
84205ce8-58e0-4da6-be33-6b2da81432ef	DJAGAT AWAN WANGSADWIPRADJA	L	232410428	\N	\N	\N	3	35	2526	0088851170
29eaf3f0-9056-4934-907a-c349f8cf5409	ERLANGGA	L	232410416	\N	\N	\N	3	35	2526	0086501802
ac619bbb-4a54-4429-8061-f76eaddc2aea	FIKRI SANI MUHAMMAD	L	232410179	\N	\N	\N	3	35	2526	0071909702
0e5436fb-d080-4ab1-9c5e-1c81cf997464	GELBY GRAISYLA DILFINA MILSY	P	232410082	\N	\N	\N	3	35	2526	0068793569
8e30f71d-8f01-4bd5-8dc2-a8bb7df3ca5f	IMAM SIBLI	L	232410016	\N	\N	\N	3	35	2526	0087468241
373c036b-6ba0-4ce1-a15b-8631e3b7f8c8	INTAN	P	232410298	\N	\N	\N	3	35	2526	0082886755
879cc26a-c461-4a62-9ed5-1e92a4f0694b	IRNA SARI	P	232410035	\N	\N	\N	3	35	2526	0079406314
d07f0fb9-127a-41fc-9591-e3e279ed0c07	KHAYLA SARY	P	232410043	\N	\N	\N	3	35	2526	0085645427
95cb7abd-ebdc-4f6d-88ca-e80d18cd747f	LUSI ANDRIANI	P	232410147	\N	\N	\N	3	35	2526	3080958073
374e0b69-8882-4e87-85ba-e1a77899048e	MIQDAD ATHIF	L	232410219	\N	\N	\N	3	35	2526	0071057533
741d99e5-011c-4e1b-98aa-edf42f98c11a	MOHAMMAD RACHMAN ADITYA	L	232410259	\N	\N	\N	3	35	2526	0081418970
f8fc875f-628b-43da-8d60-9ebf48ee7d8d	MUHAMAD RAYHAN ADITHIA P.	L	232410044	\N	\N	\N	3	35	2526	0078997626
2caf20a1-c679-4741-a147-66242234301a	MUHAMAD SIGIT MAULANA	L	232410013	\N	\N	\N	3	35	2526	0076766629
891870b5-efdd-4fd3-86a1-6c6c9cc7dcfc	MUHAMMAD FARHAN HANAFI	L	232410021	\N	\N	\N	3	35	2526	0085189570
3c4c2aab-b6cb-4aef-9342-6c8bf7decf73	NADIA RAHMATUL MAULIDA	P	232410150	\N	\N	\N	3	35	2526	0094379653
58fad956-779d-4156-a2c6-e0276822901d	NATASA	P	232410110	\N	\N	\N	3	35	2526	0082752970
142347b2-cf71-4cb1-aa1c-d99f3feab16b	NAYLA RIKA HARIYANTO	P	232410155	\N	\N	\N	3	35	2526	0084079407
694992d1-db23-402c-b7e3-6ff7a64a133b	NEZA APRILIA ANITA	P	232410084	\N	\N	\N	3	35	2526	0079963350
745875cc-ae77-4e49-a554-6b98353296d4	OKTAVIA AMFELI	P	232410152	\N	\N	\N	3	35	2526	0088137613
dfbf3127-84b1-408f-8ce9-d56ed9487a0a	REIHAN MAULANA	L	232410246	\N	\N	\N	3	35	2526	0087656292
ca1668a0-758a-4b34-b89b-aeda42a95aa5	SEPTIA RAMADHANI	P	232410138	\N	\N	\N	3	35	2526	0083422181
8beb008f-a9b7-40cb-a868-29b4840091a7	SHILLA DWI ALZAHRA	P	232410245	\N	\N	\N	3	35	2526	0084188702
b822a5e6-6766-4cd0-bc1a-aad6610742c4	SOFIA LAZIBA	P	232410303	\N	\N	\N	3	35	2526	0072578279
610560a5-d442-4707-8977-f3cc4a3507ea	SYIFA ANGGRAENI	P	232410244	\N	\N	\N	3	35	2526	0086530982
873cdf09-6307-4430-a31d-8b9286b1f70b	TAJRIUL ZIDDAN	L	232410104	\N	\N	\N	3	35	2526	0074178988
f5d5af9f-9f5e-441f-a4b4-02eddd7c10a3	TIARA	P	232410014	\N	\N	\N	3	35	2526	0087081330
29e70d04-a84c-4007-9a30-197d5288ec10	VEGA DWI FELICIA	P	232410093	\N	\N	\N	3	35	2526	0072433844
393c5ca1-7df6-4c88-aec0-649973dc1fb1	ADINDA FITRI OCTAVIANI RUSWANDI	P	232410394	\N	\N	\N	3	36	2526	0079256781
c04180f3-454b-4e37-9e4b-a857f1143993	AL KHAIRA RAMADHANI SUKARNA	P	232410209	\N	\N	\N	3	36	2526	0084379066
49cac82e-40a6-4aa5-a5b1-cd9a33d16341	ALPHASYA ALIF ABDI WIBAWA DARAJAT	L	232410126	\N	\N	\N	3	36	2526	0072178256
272dc1b5-8b2e-43d0-8143-4ea68ab29ea0	ANASTASYA PUTRI SASIKIRANA	P	232410294	\N	\N	\N	3	36	2526	0084386154
ab2e9127-eeb4-476c-b5c4-6042a51dade4	ARRUM LESTARI	P	232410030	\N	\N	\N	3	36	2526	0081763856
b1b9a7f5-d2e4-4f87-ba5b-82f48cb4cd8c	AYUNDA SELANINGRUM	P	232410040	\N	\N	\N	3	36	2526	0088948134
0fc0e2f7-375b-4970-8786-f93d45c14de7	BRILLIAN FITRA IBNA MUKHIBULLOH	L	232410431	\N	\N	\N	3	36	2526	0087461827
832a391a-bb17-4d91-86a2-762c3dbba677	DAVID	L	232410334	\N	\N	\N	3	36	2526	0079385687
86dae81f-dd95-4343-9bf5-03030804a79a	DESI RAHAYU SAPUTRI	P	232410403	\N	\N	\N	3	36	2526	0074464003
24c0895d-48fc-44c0-a116-1fd0bd669ca8	EGA AGUNG PRATAMA	L	232410206	\N	\N	\N	3	36	2526	0073336908
c0e5bc2e-09e0-45c8-bb7f-e48b4074df39	FANJI	L	232410103	\N	\N	\N	3	36	2526	0061910811
210f34e9-5a31-4120-8a35-70c3e283e766	FARELIA GUSTIANA	P	232410365	\N	\N	\N	3	36	2526	3081158741
59dda801-d369-42e9-9640-c4b278111c87	FARHAT FATHI ALGIFARY	L	242511436	\N	\N	\N	3	36	2526	NNNNNNNNN3
380e21b8-20b4-4524-a62f-6246ebc6f0f2	FILDA AURIYAH	L	232410348	\N	\N	\N	3	36	2526	0073776177
4a160c50-5e68-49b0-b383-5cc8b9040b88	JELITA SAVIRA MAHARANI AGUSTIN	P	232410405	\N	\N	\N	3	36	2526	0082616981
8fedab0d-6aca-4c70-849b-207f4dacc390	KHAYYARAH ALIMAH	P	232410280	\N	\N	\N	3	36	2526	0075548719
4e67036a-a842-4d16-a614-9747a7280fa6	LAYUNG SEGARA	L	232410214	\N	\N	\N	3	36	2526	0073785388
6ba73481-6752-4913-851f-94f64ad6f054	MUHAMAD ARIS ALAMSYAH	L	232410309	\N	\N	\N	3	36	2526	0076584211
181833f1-4588-4bde-97ec-ef88956befe5	MUHAMAD RIZKI	L	232410302	\N	\N	\N	3	36	2526	0074154129
855f71b4-c09b-4752-8699-dd5efda86470	MUHAMMAD AZIZ ZAHRAN	L	232410181	\N	\N	\N	3	36	2526	0083010268
4817423e-cf7b-476e-976a-3f8c05b7526f	MUTIYA ALFATILLAH	P	232410260	\N	\N	\N	3	36	2526	0075100858
c2908544-422a-4440-a6b2-968b3cacb863	NADINE DWI APRILIA	P	232410359	\N	\N	\N	3	36	2526	0067976517
47ce2e94-ef28-46e2-9013-0a532f496a7c	NAYLA DIVA AMANDA LAURA	P	232410408	\N	\N	\N	3	36	2526	0079785083
334ffc46-65d5-4983-bf58-bb7edae58376	NAZWA NURKOMARIAH	P	232410247	\N	\N	\N	3	36	2526	0073203343
2b147503-4e81-46da-9b78-7dcfac2bd8ae	NURUL AENI	P	232410005	\N	\N	\N	3	36	2526	3082682642
2d98ec0d-b0b4-4e54-a49e-0e9e1cc01f92	PUTRA ADITIYA	L	232410165	\N	\N	\N	3	36	2526	0087642402
09b38ab2-f4a0-44c0-82e6-1618a4b7c0b2	RISYA ASHIFAH	P	232410321	\N	\N	\N	3	36	2526	0087018264
eceb0018-9902-4f05-ae94-682f29d0164f	SHESSA AZZAHRA	P	232410080	\N	\N	\N	3	36	2526	0071533766
460b6731-8e4e-4e86-8a6b-692c41b77bc9	SITI ANELISA PATIMAH	P	232410117	\N	\N	\N	3	36	2526	0079300680
5f6c7954-1b0b-4278-9ed7-40d9596fa524	SULAEHA SARI ASIH	P	232410032	\N	\N	\N	3	36	2526	0085288898
2e5af463-ccb1-4a1a-8dde-623877fffc6a	SYDNEY JULIAN ASY'HAR	L	232410258	\N	\N	\N	3	36	2526	0082477436
c5df4b7e-8c5b-40fc-a90f-e77df6cd6070	SYIFA KIRANI	P	232410250	\N	\N	\N	3	36	2526	0089869071
bbdaa643-542b-4415-b72a-fd8d2aefce5d	TARUDI	L	232410077	\N	\N	\N	3	36	2526	0063673519
0b7c7ad1-26a3-4596-8492-f9844dca83cf	TIARA NUR AZKIA	P	232410335	\N	\N	\N	3	36	2526	0071651981
2aad1220-cb38-4983-984f-3bc06b3adb79	YASA OKTAVIANA	P	232410311	\N	\N	\N	3	36	2526	3072817745
3fcd3625-cf40-4453-b362-7adeeb82e541	AHMAD IJAZIYA KAROMI	L	232410252	\N	\N	\N	3	37	2526	0081075873
aad1a373-fb3c-4a64-b678-da9da1517489	ALDO WIDIANTORO	L	232410262	\N	\N	\N	3	37	2526	0071025638
5472c5ee-be2e-4320-a931-5ba9e2c010e4	ALIYYU LIUNI LISTIAWARMAN	P	232410122	\N	\N	\N	3	37	2526	0088319628
e2b847b3-dd48-48cf-92af-0343dc381128	ANITA SAHRANI	P	232410390	\N	\N	\N	3	37	2526	0089039382
db7c387f-df9a-4466-b1cb-3b86a5893343	AYANG DWI NOVIANI	P	232410009	\N	\N	\N	3	37	2526	0087733285
104858fe-bac3-45ec-844f-a6a6b85cd9c8	DARINI	P	232410201	\N	\N	\N	3	37	2526	0087140932
8336b5d0-949c-4e91-bf2c-3478a78ed874	DAVA SANDI PRATAMA	L	232410291	\N	\N	\N	3	37	2526	0078837454
51fe8da4-e92f-4c10-889b-98e252b2238b	DIAR MAULANI	P	232410111	\N	\N	\N	3	37	2526	0081977289
d9086b31-9512-44df-8f3c-b966bf8a6c34	ELIS OCTAVIANI	P	232410045	\N	\N	\N	3	37	2526	0081045415
9e5262ac-ef6b-44e0-ab1b-2e1afffc71b2	FELISYAH PUTRI	P	232410092	\N	\N	\N	3	37	2526	0081338144
763cc489-9dd1-4dd6-b36e-3f198d6600d8	GITA AULIYANI	P	232410105	\N	\N	\N	3	37	2526	0084009381
04d920b1-6dc6-4006-bc2e-2a9c8820d2e9	HILYATI FADILAH	P	232410203	\N	\N	\N	3	37	2526	0084102017
a521bd5b-674e-4a06-a3eb-a78a387f5359	IBNU AENUROFIQ	L	232410170	\N	\N	\N	3	37	2526	0072950558
3e8e92c9-7e3d-43bc-bc75-4c6392bcabb7	IVONA RAHMANIA	P	232410279	\N	\N	\N	3	37	2526	0084192290
aa2eb56f-5a9e-452d-a8eb-4b8eec404cc6	KEYSHA LING LILIAN	P	232410124	\N	\N	\N	3	37	2526	0083497363
79dd6f7d-d221-493e-96a9-385c97c74221	LATIFATUL AZMA	P	232410274	\N	\N	\N	3	37	2526	0085663985
2378bc80-d20d-4668-a353-dd1dd737d301	MAULANA AGIS ANTAREZA	L	232410174	\N	\N	\N	3	37	2526	0082646869
f025fa59-1b42-4544-b260-aad70e37995f	MAYLAFFAYZA ANDANIAH	P	232410400	\N	\N	\N	3	37	2526	0086767023
97c5f054-efe5-4378-a7cb-065c2c8d58c0	MUHAMAD IMAM NURUDIN	L	232410374	\N	\N	\N	3	37	2526	3082553808
5c290476-47a2-4be3-ae48-3bb1a7cd6296	MUHAMMAD ZAHID HUNAFA	L	232410063	\N	\N	\N	3	37	2526	0083626956
384a3a4e-51c8-4997-8e3e-a6626e644fdd	NAHRASSYA KHAERANI	P	232410029	\N	\N	\N	3	37	2526	0089181200
207d4b8a-2b26-41ae-9dab-fa3ffad7270c	NAURA WAFA ALMAULIDA	P	232410081	\N	\N	\N	3	37	2526	0086037486
def37458-27f3-4d02-9372-c083c6f60c16	NUNU NURDJANAH	P	232410038	\N	\N	\N	3	37	2526	3076552253
d8e190b4-bf86-44ae-b398-0b51e2fd562e	NURUL SYA'ADIYAH	P	232410015	\N	\N	\N	3	37	2526	0071667361
dba01f50-f6b6-42b3-91b3-921e323468e7	NYAI KHOLIFAH	P	232410154	\N	\N	\N	3	37	2526	0077466398
14906fcc-34d6-447f-b4aa-3fa35807db77	RAHAYU	P	232410332	\N	\N	\N	3	37	2526	0072639954
37d3a32d-cc8d-49a7-b1dc-4c5f5fa7a530	RAYA SYAFIRALAYLATUL FIDZRIYAH	P	232410034	\N	\N	\N	3	37	2526	0087864271
0adc5c04-d39d-4880-9ce2-c2575fffeec4	REFA AGUSTIAWAN	L	232410065	\N	\N	\N	3	37	2526	0088902026
418ea8fe-bdae-4b2d-ad24-41a128246652	RISMA NUR RAHMAWATI	P	232410011	\N	\N	\N	3	37	2526	0072771971
ee75c677-9d35-4946-93f1-3bf31f0beb74	RIZKHULOH HUSAM	L	232410363	\N	\N	\N	3	37	2526	0083716287
b6d67976-ca91-4173-b216-8c296dd8c5dc	SARTIKA HURUL AIN	P	232410010	\N	\N	\N	3	37	2526	0074486060
2a4e9c4c-a918-42bc-8bf6-3c625f2474b3	SISI NENA CAHYANI	P	232410375	\N	\N	\N	3	37	2526	0071576379
2f02f820-9234-4a75-9e8c-a8e31e8590a1	SITI MUNAWAROH	P	232410173	\N	\N	\N	3	37	2526	0094841800
dd2322e4-31c6-41bd-8cbb-82d562411642	TIARA YULIYANTI AULIYAH	P	232410275	\N	\N	\N	3	37	2526	0089942509
ff54d052-e40b-4d2c-9456-953bbfd10f83	WULAN ANDITA SARI	P	232410086	\N	\N	\N	3	37	2526	0073056642
77cd9668-8f51-40da-b10c-4e3ae8be6433	YAYANG MANDALA ERLY	L	232410168	\N	\N	\N	3	37	2526	0084795963
90c802c1-31c7-4558-96a4-1428f7dc7afc	ABDUL MUKHYI ASYIROZI	L	232410351	\N	\N	\N	3	38	2526	0081922883
8404d92d-54d4-40ac-867c-3023d2033f19	AGIS SAHARA	P	232410017	\N	\N	\N	3	38	2526	0078568433
03e1f235-e8bb-4595-95ed-c551d362347e	AHMAD NURZAKI	L	232410224	\N	\N	\N	3	38	2526	0084400400
950a61ed-46d1-4fbb-b935-3bcff30bd720	AMANDA AYU MOZZA'IYAH	P	232410241	\N	\N	\N	3	38	2526	0076388355
d2e436f6-ba61-4441-b703-09b09851a8df	ARIEL BAYU SETIAWAN	L	232410315	\N	\N	\N	3	38	2526	0086007043
346176ae-cfa0-4e31-84b4-2545437156d7	ASTI NURYA NINGSI	P	232410362	\N	\N	\N	3	38	2526	3083594012
a89975fa-f8a6-48a9-bc76-9918a2e2b4a7	AYU PUTRI LESTARI	P	232410024	\N	\N	\N	3	38	2526	0082293103
8baefb0b-d2d3-45a6-955c-1a8ef9db0158	DEA AMANTA ZAHRA	P	232410041	\N	\N	\N	3	38	2526	0081927590
632ba133-909d-4e7e-ae0d-02122fd02e34	DIARA QONITA MAYSUN	P	232410087	\N	\N	\N	3	38	2526	0072017781
f95648f6-4a9f-4ab8-9f49-3e73af42e379	DWI ANDIKA	L	232410253	\N	\N	\N	3	38	2526	0081616281
a404992e-6a84-471f-91a2-6bdb0d308fcd	EUIS ZASKIA NUR FAJRIATI DEWI	P	232410229	\N	\N	\N	3	38	2526	0073938579
7b12972f-8e2e-4521-a7d4-7f7f59f949d7	FIFI AZQIA RAMADANI	P	232410251	\N	\N	\N	3	38	2526	0089614517
4250f002-5992-46b2-b7df-29115f207a06	HAMIDAH NUROHMAH	P	232410133	\N	\N	\N	3	38	2526	3087523640
f1829085-2576-4ba3-b37d-a3489821def4	IMELDA RAMADHANI	P	232410060	\N	\N	\N	3	38	2526	0085023390
2032d31f-a86b-44bc-a843-26cc0eb0dedd	JAZMYNE MAHADAYACINTA ROELL R.	P	232410306	\N	\N	\N	3	38	2526	0089495169
8873a89f-c413-40b1-9b14-7ad4d1f88b7a	KEVIN MUKHAMMAD M. F	L	232410340	\N	\N	\N	3	38	2526	0088237077
9ef468d6-824c-4baa-8773-6662087bc8e7	KEYZA AZAHRA	P	232410345	\N	\N	\N	3	38	2526	0081712148
6c944a67-3705-48b7-ae6b-c1ffc943b0d5	LENI FADILAH MULYATI	P	232410149	\N	\N	\N	3	38	2526	0085906334
dd42c378-576c-4c19-8cd3-4601545a4258	MELY AMELIA	P	232410211	\N	\N	\N	3	38	2526	0089087495
9fcf7554-ae22-44e0-85ea-d0fe981b43e0	MOCHAMAD DAVA SAPUTRA	L	232410429	\N	\N	\N	3	38	2526	0085451203
f5651381-ca2e-4a1c-afa5-7f83657fe809	MUHAMAD RAFA AL WAHID	L	REDU00001	\N	\N	\N	3	38	2526	0078013480
3ccdf810-9573-4733-896b-a2c5da96cb43	NAILA AURANITA	P	232410099	\N	\N	\N	3	38	2526	0074070104
c3d0c17c-2352-4f7a-98b5-627235001420	NAWANG WULAN	P	232410141	\N	\N	\N	3	38	2526	0081810545
f742e1a4-f4dd-4795-ba38-202a8c1acf87	NUR HERLINTANG	P	232410095	\N	\N	\N	3	38	2526	0078462702
8b1c2ca1-d02d-4499-b0cc-2883e86ba882	PUTRA ADITIYA	L	232410338	\N	\N	\N	3	38	2526	0074007487
e8ea8c49-bbd9-46b0-86ee-f8d939093b85	PUTRI ANANDA	P	232410116	\N	\N	\N	3	38	2526	0072601258
395da60c-a1fb-4654-bc27-c7beb5f095d0	RAHMAWATI SEPTIANI	P	232410272	\N	\N	\N	3	38	2526	0088264039
91692a57-6bab-4d7f-b2f7-4de58b33245e	RISMA RAMADHANI	P	232410366	\N	\N	\N	3	38	2526	0083022983
d080b1a2-23a6-4d80-afcf-a39324c78ba4	SASKIA PITALOKA	P	232410228	\N	\N	\N	3	38	2526	0088290968
f22e98ae-edf1-4967-90b0-59e338fad016	SITI AFIYA	P	232410331	\N	\N	\N	3	38	2526	0084317227
cc4e0b7e-56dc-46eb-a180-bc5254a3ea4d	SITI NURLAILA	P	232410187	\N	\N	\N	3	38	2526	0089097736
50011859-3c7e-4e00-abe8-dbe9a6ef7ae6	SOFYAN AL AFRIZAL	L	232410066	\N	\N	\N	3	38	2526	0071680590
28cfb75b-1825-4962-8af6-3008c1806ebf	SULISTIA NINGRUM	P	232410223	\N	\N	\N	3	38	2526	0073075617
2b748fe6-4fe0-428e-a302-fa9151d63211	ULTHUFI LUTHFIATUL F.	P	232410196	\N	\N	\N	3	38	2526	0082537912
eb1288fa-c317-407c-90bb-31a0cd447425	ZAHRA ISTIQORIAH	P	232410300	\N	\N	\N	3	38	2526	0079966963
72dbf2d6-7404-45b3-8be0-1b8a6a791400	ZIRUN AL FARIZ	L	232410353	\N	\N	\N	3	38	2526	0086519654
14da2105-98d1-49ca-93d3-fbf346e0eaf7	ADITYA	L	232410163	\N	\N	\N	3	39	2526	0081465840
1f743371-254a-4bd4-a95f-c05b3000d532	AHMAD RIZAL NUROFIQ	L	232410325	\N	\N	\N	3	39	2526	3060926246
736b57bb-5293-4732-a268-15a04398e9a7	AISYAH CAHAYA PELANGI	P	232410200	\N	\N	\N	3	39	2526	0089385622
8a98ade3-dee5-4ef0-a902-a35659760aba	AMANDA FAUZIYATIN	P	232410028	\N	\N	\N	3	39	2526	0073341986
fb30e793-ffba-4484-88b8-b22f207d831d	ARIFIN ILHAM	L	232410265	\N	\N	\N	3	39	2526	3134646553
f3a46135-a6e7-4b9f-95d5-b26b3526478c	ATIKAH GHINA FAUZIYYAH	P	232410106	\N	\N	\N	3	39	2526	0073803921
af0161d3-d308-4e75-b915-ada086f12447	AZZAHRA AULIA SYINKY	P	232410267	\N	\N	\N	3	39	2526	0076612778
fdd991e3-f2f4-4d6f-8c72-6b14df271492	DEDE AYU LESTARI	P	232410062	\N	\N	\N	3	39	2526	0077730516
6a428844-2fb6-4a74-895f-6eff141bb6b4	DINA APRILIA	P	232410008	\N	\N	\N	3	39	2526	0073757674
1c065027-671e-4fae-8655-8ca96d8daa53	EVA RIYANI	P	232410295	\N	\N	\N	3	39	2526	0081842726
f9e520a5-3a3b-4483-be99-62a6de193305	FARLAN FIRMANSYAH	L	232410396	\N	\N	\N	3	39	2526	0082006007
a80f650b-4caa-4e17-9d41-fec4768816c8	FIDA JAZILAH	P	242511437	\N	\N	\N	3	39	2526	NNNNNNNNN4
6822b51e-34cf-478f-8d64-ab5534e2f73d	FITRI RAHMAYANTI	P	232410101	\N	\N	\N	3	39	2526	0089413839
5ceb654b-7805-45d7-af70-aea12375ab84	HANI NUR FADILAH	P	232410271	\N	\N	\N	3	39	2526	0084790881
e49e9fc2-ff91-46c5-8033-48de5395dcb9	INDRIYANI SRI WAHYUNINGSIH	P	232410292	\N	\N	\N	3	39	2526	0085450859
9000c709-e688-46c2-84d5-a59853e8cd2a	KAHFIATUS SYIFANI	P	232410180	\N	\N	\N	3	39	2526	0074501383
04ba3bfc-b6de-4318-a9f0-24994629bcc0	KHARISMA YOGI ANGGRAENI	P	232410020	\N	\N	\N	3	39	2526	0081740115
f61693e6-a625-40d8-ad4d-0a584818d42f	LIFA DEWI	P	232410290	\N	\N	\N	3	39	2526	3087871033
ce8669b7-b83b-495a-805d-bb1487d6177b	LUTHFI KHAIRULLAH	L	232410176	\N	\N	\N	3	39	2526	0088022616
ae71555d-54bd-4f41-b7cb-1421c7ea1440	MIA MARSHA TIANTI	P	232410257	\N	\N	\N	3	39	2526	0089963418
51e8b215-5cd1-4bad-819e-fb9cc5947a66	MOH. FARIZ RAMDANI	L	232410299	\N	\N	\N	3	39	2526	0082706503
dd0cd115-0cf8-4f46-81dc-4de336402b49	MUHAMAD REVAN SUMBADA	L	232410330	\N	\N	\N	3	39	2526	0078834555
7a2f75e7-956d-41c3-b3b4-6afad79da0dc	NAILA AZZAHRA	P	232410047	\N	\N	\N	3	39	2526	0086040058
9cb30e2b-2fa6-4e12-ab9d-68994ffe4bc4	NAZWA FITRI AULIA	P	232410361	\N	\N	\N	3	39	2526	0072458859
81e056e9-0c5d-467c-ba99-9c821aaf6d44	NURUL KHUMAYROH	P	232410380	\N	\N	\N	3	39	2526	0084446726
c7ee91fb-c338-4316-84b2-ac6ea1a2d50c	RAFLY HENDRIAN	L	232410304	\N	\N	\N	3	39	2526	0075510156
793a5638-3a8d-43fd-a942-83682657eaaf	RAIYA ARLA DESTRIANTI	P	232410239	\N	\N	\N	3	39	2526	0074329481
0b988441-81ae-47f6-be7d-190822399689	RISNA SELVIANA	P	232410401	\N	\N	\N	3	39	2526	0089346044
aeb1ced2-8fdd-44a5-b254-dec88bcd42f9	ROSIHAN ANWAR	L	242511438	\N	\N	\N	3	39	2526	NNNNNNNNN5
8f8dd8cf-8534-4ece-8bf0-e807afb9698b	SASKIYA VINANDA PUTRI	P	232410071	\N	\N	\N	3	39	2526	0073384367
4c652ed7-ca06-4bb5-a70d-e3950830ec0f	SITI ANISAH	P	232410373	\N	\N	\N	3	39	2526	0098730529
3bc60acd-99eb-4356-bde7-9319a277558e	SITI UMAEROH	P	232410261	\N	\N	\N	3	39	2526	0073882911
ffd275fc-b196-4b8f-9c80-85313df9b254	SYAHROTUL AENI	P	232410342	\N	\N	\N	3	39	2526	0086924303
9017b5cc-7238-4d1e-85ec-60557b9a717f	TIO PRATAMA	L	232410235	\N	\N	\N	3	39	2526	3083894978
cc965d7f-3cba-4404-b48f-951af053c866	WIDIYA APRIYANTI	P	232410153	\N	\N	\N	3	39	2526	0071892233
7e6d209a-96bb-4827-a857-aa4142eed456	ZAHRATUS SIFA	P	232410057	\N	\N	\N	3	39	2526	0086833234
41e633ef-c11c-499d-a9bd-a3ceba76f25c	ABDUL BASIRUN	L	232410221	\N	\N	\N	3	40	2526	0082882714
05d6f43e-b021-47e7-bcbc-557b2f1a15c1	AFIF NUR ILYAS	L	232410369	\N	\N	\N	3	40	2526	0088259566
84d14a94-2b66-45d1-abd6-766e4780e1cf	ALIFATUL HIKMAH	P	232410144	\N	\N	\N	3	40	2526	0089843624
2e11bf51-e849-4087-b0a3-926253146c07	ANA MARLINA	P	232410075	\N	\N	\N	3	40	2526	0077520827
a5279831-d02b-4248-9232-bb85b41a82a6	ANDRE MAULANA	L	232410192	\N	\N	\N	3	40	2526	0093640767
f9370d6c-1880-4bc8-ad8c-e28863688e12	AULIA MERVI YONNI	P	232410212	\N	\N	\N	3	40	2526	0082609039
0145a4f8-d487-45dc-8355-75c10f2f0776	AZHRUL UMAM ALFARIZKI	L	232410100	\N	\N	\N	3	40	2526	0088268176
a572916f-9b72-4e70-8387-b545021c69a5	CHIBI RUHMA MAIA ANGARINI	P	232410393	\N	\N	\N	3	40	2526	3088395976
6901f54f-8e06-4ebd-a9c0-0380869f47d7	DEWI NURWULAN SARI	P	232410236	\N	\N	\N	3	40	2526	0079611899
64cb8b13-b445-400a-b8c3-dc7bfa95c295	DINDA ARISTIA OVIANI	P	232410183	\N	\N	\N	3	40	2526	3081585091
c71f9c1f-3d97-4ff1-8bbb-c7455f7a6d01	ELANG ARDHAN BRATANINGRAT	L	242511439	\N	\N	\N	3	40	2526	NNNNNNNNN6
0dcc6c7b-1936-4c65-ad8d-bcd03dfc579d	EVA YULIYASWATI	P	232410419	\N	\N	\N	3	40	2526	0085640516
bdf27c2c-7d26-4923-95b7-2e57ae007a02	GAYATRI HARNUM MENTARI	P	232410347	\N	\N	\N	3	40	2526	0082524972
3b85e043-85fd-4b42-9a9d-0d214167b3ef	GILANG RAMADHAN	L	232410339	\N	\N	\N	3	40	2526	0072103569
3293e7eb-f64a-41ac-bce7-85238175964a	HELEN PUTRI NUR AFIAH	P	232410006	\N	\N	\N	3	40	2526	0081564007
d5eb3f2a-d305-4fa3-b209-2c3507467b74	INTAN FEBRI DWI ANJANI	P	232410289	\N	\N	\N	3	40	2526	3088576249
52d8cbbb-c892-4063-9fd6-99c46e56dc19	KESYA APRILIA	P	232410370	\N	\N	\N	3	40	2526	0082782891
2558ffad-a7db-47c6-a058-32c97bda1b78	KHOLIFAH	P	232410328	\N	\N	\N	3	40	2526	0085231357
c3be4c48-d9cb-4d83-b6ef-3c295ad6b990	LISYANA AZZAHRA	P	232410388	\N	\N	\N	3	40	2526	0074837456
9558b837-e324-490d-910a-6d7b9868cbff	M. KHAFKA KHAIRULLAH	L	232410417	\N	\N	\N	3	40	2526	0084093630
9fc8ebcd-4f1a-4bd7-9767-28af5e5a7263	MIRZAINI SYIFA DJATY	P	232410384	\N	\N	\N	3	40	2526	0088382800
fa117ae3-a7f4-43a3-93ac-905abcf4a6c8	MUHAMAD ARI LUKMAN	L	232410178	\N	\N	\N	3	40	2526	0083285353
f12bd61a-db11-411e-8867-7a6ce59ef27c	MUHAMAD SATRIA PRATAMA K	L	232410172	\N	\N	\N	3	40	2526	0072907091
ec9f48e2-2834-4096-a833-9cc5cc5bad96	NAILAH RAHMAH RAMADHANI	P	232410387	\N	\N	\N	3	40	2526	0085151203
f15ca584-775b-4808-bbd3-4a2cca4d167a	NIGITA ANGGRAENI	P	232410096	\N	\N	\N	3	40	2526	0089287751
bf159df3-4b7e-4647-a125-142af6b067dc	NURUL MAULIDI	P	232410409	\N	\N	\N	3	40	2526	0085311598
f4c8dbc7-6770-49b9-a61a-0e89d4b92876	PUTRI SELFIYANA	P	232410185	\N	\N	\N	3	40	2526	0089686150
9041c8a9-4146-45da-88a8-69ad9f402678	RIMAS SA'IDAH MUHAMMAD	P	232410046	\N	\N	\N	3	40	2526	0079982662
12a79af2-4d63-4b2f-bfe9-c3d50c9a331a	SALSAH DEFATIHAH	P	232410426	\N	\N	\N	3	40	2526	0077464295
496cb780-a335-461e-aa38-d332e24ae3f9	SINTA ELIYANA LESTARI	P	232410037	\N	\N	\N	3	40	2526	0087739599
2f4020de-801e-41d3-8f9d-4a1fb21552a9	SITI MAESAROH	P	232410175	\N	\N	\N	3	40	2526	0082047206
4ed789ab-28b0-4cd3-8681-5a6e172c3474	SRI MULYANI	P	232410404	\N	\N	\N	3	40	2526	0088270332
737e1592-e0f8-4654-ae5e-444ce2b0fe69	SYAHROTUS SHITA	P	232410412	\N	\N	\N	3	40	2526	0075213234
7ced9e37-28e2-45d6-ab58-35f536e51cdd	WINDI AYU KOMALASARI	P	232410319	\N	\N	\N	3	40	2526	0089209570
b4cbfbc6-4487-40f6-a9b3-48ed4537eb7d	ZAKIYYATU SA'DIYYAH	P	232410391	\N	\N	\N	3	40	2526	0087116877
ca4d5e4a-da6f-4a65-8542-c5232f8c8b7d	AGUNG PURNAMA	L	232410217	\N	\N	\N	3	41	2526	0073300915
028922ae-90b8-47a9-a344-af7e06fbb4fd	ALIN FUJI NINGRUM	P	232410249	\N	\N	\N	3	41	2526	0076409993
3a44f7a3-4437-44f9-833d-e6d93b9a4de0	ANANDA FARDHAN	L	232410424	\N	\N	\N	3	41	2526	0085593143
6d59081c-ac1a-4dc4-888a-fc17e20650a4	ANGGUN NAZIKHAH	P	232410191	\N	\N	\N	3	41	2526	0082731775
842e59a5-b715-4de4-8dd3-bef97eb46535	AULIA PUTRI	P	232410386	\N	\N	\N	3	41	2526	0088297649
279fb56a-10e1-424e-a879-8bf580d0d1cd	BAMBANG TRI PRASETYO	L	232410430	\N	\N	\N	3	41	2526	0079509219
d0147888-aa85-4e75-b153-fd57866d0d1d	CLARA RIZKY WIDIAWAN	P	232410207	\N	\N	\N	3	41	2526	0083868888
7bdc7079-97e0-4712-bc21-4f88dbb844ca	DIAN NIRMALASARI	P	232410159	\N	\N	\N	3	41	2526	0076168298
0c2e7367-a9fe-43c3-91e8-79cb7e8b2eb0	ELFATICHA VELIANSYAH A.	P	232410026	\N	\N	\N	3	41	2526	0086922568
454e9a2c-bc4c-4720-819a-945568c108c4	FAHMI NURUL HIDAYAT	L	242511440	\N	\N	\N	3	41	2526	NNNNNNNNN7
562a0837-02b9-45ba-a5fd-c9688789c47d	FATIMAH AZ ZAHRA	P	232410254	\N	\N	\N	3	41	2526	0073070084
6970a0bd-1e7a-4c22-bca4-5e5f2f58a73d	GEA SYERLA CITRA AMANDA	P	232410049	\N	\N	\N	3	41	2526	0084775859
049a43b4-2657-472d-aac2-d5df1e527ad9	HILDA NAFISA	P	232410073	\N	\N	\N	3	41	2526	0073766646
fbba75cf-d813-4a6b-acb3-57de34f721c9	HILMI HABIBI	L	232410367	\N	\N	\N	3	41	2526	0086158407
ac9eecd7-b108-4a6d-9a73-e81a8bddd811	ITA SEFTIA NINGSIH	P	232410059	\N	\N	\N	3	41	2526	0088446398
6c297c68-a061-4aef-8d87-bfea25603de1	KEYSHA GIRI PUTRI	P	232410415	\N	\N	\N	3	41	2526	0093992000
f545ba9c-316e-47f9-9393-b60965f46265	KIRANA AZAHRA ARYTONI	P	232410411	\N	\N	\N	3	41	2526	0071289326
d3025df0-ad4e-40f8-a632-3959ac6ef22b	MALIKAH BALQIES	P	232410270	\N	\N	\N	3	41	2526	0076520893
e677a0ed-ff2c-4489-bee4-6af632147c67	MARIO AGATHA MAULANA	L	232410263	\N	\N	\N	3	41	2526	0088823740
d26774d7-0d17-4968-98c5-7ea292cd57ba	MUHAMAD ATAN	L	232410216	\N	\N	\N	3	41	2526	0072850932
f9c2b863-b12d-4763-8557-6a7d4d8cfe74	MUHAMMAD RIZKI	L	232410226	\N	\N	\N	3	41	2526	0086146621
0ceaf095-76a7-4809-b231-53e0ab3003d8	NADIA SHIFA NUR AZZAHRA	P	232410055	\N	\N	\N	3	41	2526	0081079568
3ff484fd-68e9-46a7-a229-f7091f691ca7	NATHASYA HOZAWA	P	232410395	\N	\N	\N	3	41	2526	0083391287
814e76b6-14dc-45fe-a4ef-1ced5e8991dd	NISA FADILA	P	232410132	\N	\N	\N	3	41	2526	0076366620
bd06e16b-96f0-4ff3-8f0e-ef7936f259b9	NURUL SAFITRI	P	232410042	\N	\N	\N	3	41	2526	0074250924
919b3511-0fb0-4b4d-8d56-f70565c226c8	PUTRIA RIDHA AMILIA	P	232410225	\N	\N	\N	3	41	2526	0088687590
d87d50be-ecae-443e-9e27-f589b4b5b227	REZA ADITYA	L	232410215	\N	\N	\N	3	41	2526	0087574938
d9adacf8-7aa6-4b22-874b-31fc6f105b7e	RINDU ALICHA NURJAMAN	P	232410019	\N	\N	\N	3	41	2526	0089358863
bfe0f8d6-923b-4127-92c4-13bbc7934006	ROBIATUL ADAWIYAH	P	232410188	\N	\N	\N	3	41	2526	0071496908
0ac789bf-31ce-4a64-8947-80636510dd07	SANTI YULIANA	P	232410128	\N	\N	\N	3	41	2526	0089365255
249c0cfd-bfb8-4de0-a0cd-67d7517c5f22	SIS ANTAWATI	P	232410088	\N	\N	\N	3	41	2526	0084948966
290fcc19-9db8-476f-9a6c-d65bcaef984d	SITI MARIYA	P	232410194	\N	\N	\N	3	41	2526	0042903867
dc0f09a2-b13f-4638-90e6-04b3446371c3	SUCI RAMADHANI UMASANGAJI	P	232410283	\N	\N	\N	3	41	2526	0083199204
77d41f4f-ee5f-4f80-93a8-046060119294	TIARA CAHYA SHALSHABYLA	P	232410193	\N	\N	\N	3	41	2526	0081790397
56a927f3-e17d-4397-8eb7-27d77693cfd3	WIYAN FIYANDI	L	232410288	\N	\N	\N	3	41	2526	0076247489
abd2039d-4a9c-47ff-98b7-8b07d5fda441	ZULQIFLY RAHMADIN	L	232410314	\N	\N	\N	3	41	2526	0083302843
1a628d25-9337-4390-842c-91b63c83245e	MUHAMAD RAFIE BADRUTTAMAM	L	252610236	\N	\N	\N	8	9	2526	0094075989
dfc462e8-c2b7-4105-a003-93811359c1de	MUHAMMAD DAVA DWIJAYA	L	252610511	\N	\N	\N	8	9	2526	0097617332
8f81b90c-dca1-431c-8931-d2c6d25404da	MUKAMAD RIZKY	L	252610248	\N	\N	\N	8	9	2526	0101498591
b53d9a19-74be-437e-98e0-e7405ecf95c0	NADZWA SANDI ORIVA	P	252610260	\N	\N	\N	8	9	2526	0109270874
d9c35bee-3cec-4ad2-82a2-f76be27ce316	NAZELYA GIZA HUMAIRA SANJAYA	P	252610272	\N	\N	\N	8	9	2526	3104302518
c2802ef5-a784-4de3-8e28-c7b2fd4edc3d	NUR'ALIM	L	252610284	\N	\N	\N	8	9	2526	0093045851
c946429a-2f7c-4812-b5b4-f48e63a13781	PUTRI NURAZIZAH	P	252610296	\N	\N	\N	8	9	2526	0095088588
cc9b814a-ff33-4e43-94bf-b32a24fe4956	RADEN CHERYL DIWIYANTO	L	252610487	\N	\N	\N	8	9	2526	0113639486
67104e2f-b01a-4322-961a-0f063f2ab444	RAHMA FEBRIYANTI	P	252610308	\N	\N	\N	8	9	2526	0102267133
7fef6015-76a3-4dea-a1ff-9d9b3a7e8a6b	RIFA APRILIANA	P	252610320	\N	\N	\N	8	9	2526	0109173039
6d3a386b-d820-4790-8536-2df4915e4654	ROSADIANA	P	252610332	\N	\N	\N	8	9	2526	0102060072
bbdef1a0-4aa1-4a80-a49c-9f6180f1fcaa	SALSA ABILA RAMADHANI	P	252610344	\N	\N	\N	8	9	2526	0093075140
f8c0d5ac-a220-48b0-8e7e-c91f44e62703	SIFA NUR ROHMAH	P	252610356	\N	\N	\N	8	9	2526	0104182261
18638970-061d-4e8e-a83f-6fb4513c3b41	SINTA PUJA LESTARI	P	252610479	\N	\N	\N	8	9	2526	0099781497
4b31ce90-7b4e-4e1b-b825-ccfa5619809e	SITI NAELUN NI'MAH	P	252610368	\N	\N	\N	8	9	2526	3106620792
59d47ccd-f089-41f8-a4eb-cb061706fa58	SRI YULIANTI	P	252610380	\N	\N	\N	8	9	2526	3093362520
958e82ea-70d3-4042-8fcf-9ce1587cc402	TANIA DAMARA IRTHANTY	P	252610392	\N	\N	\N	8	9	2526	0102113275
0048c335-404e-4be3-b5bb-887c4735e739	TRI YANI OKTAPIYA	P	252610404	\N	\N	\N	8	9	2526	0093360375
e242bde6-1e77-427d-bcbc-04d30b54f15d	VITYA PRAMESTI SUHARDU	P	252610527	\N	\N	\N	8	9	2526	0096986160
cf403ede-0a89-46b5-b117-349b7efb034f	WIDA KOMALASARI	P	252610416	\N	\N	\N	8	9	2526	0107747660
6e8c682b-cd47-4f6e-bc0c-cc38a707ccff	ZASKIA DWI YULIYANTI	P	252610428	\N	\N	\N	8	9	2526	0109393983
628d38c6-b237-4d16-a1af-be2aebb1b225	ADE PRIYANTO	L	252610009	\N	\N	\N	8	11	2526	0109950906
c7ec0010-149a-42ff-91c0-e3ec5c310669	AFGAN JABAR ALBUCHORI	L	252610021	\N	\N	\N	8	11	2526	0092377984
94ecf3e0-23d0-4254-8d0d-237f44519453	AKBAR MUZAKY	L	252610033	\N	\N	\N	8	11	2526	0101353673
454e4f27-9da1-48b7-b554-80644fe523db	ANA SEPTIANA	P	252610043	\N	\N	\N	8	11	2526	0092281113
1e93ca5c-8224-4fc0-b031-cc69b438cea0	ANITA WIDYANINGSIH	P	252610057	\N	\N	\N	8	11	2526	0109955365
9f096697-18b9-4e39-abb4-51fe00d36b22	AQRIZ OKTOBRIYANA	L	252610045	\N	\N	\N	8	11	2526	0099466549
73e87122-fc31-4e39-9cad-64a5b41f6660	AULIA CITRA RAMADHANI	P	252610545	\N	\N	\N	8	11	2526	0093564209
b41e753a-3283-443d-9f86-dbbb7dd0c34f	AZIZAH KHUMAEDI	P	252610069	\N	\N	\N	8	11	2526	0103727857
32c91e15-b10c-463a-9d4a-6d9e08130247	CINDY MAULYDAH	P	252610081	\N	\N	\N	8	11	2526	0108077425
7f50dbb6-30f6-4f9c-a74b-ae144dab3450	DEWI KHAERUNISA SARASWATI	P	252610093	\N	\N	\N	8	11	2526	0103740563
8479bf10-c76b-4c64-b440-25fbf6f88ed4	DEWI MUSTIKA	P	252610455	\N	\N	\N	8	11	2526	0102735771
5ab32ee0-e0ed-4022-8618-68419003693e	DWI ZULFA NIRMALA	P	252610105	\N	\N	\N	8	11	2526	0109098969
d14a20b6-7097-46ee-a3d2-a0e6277e8a24	FABIO ESA KUSUMA	L	252610117	\N	\N	\N	8	11	2526	0101291915
20e48d9e-39c8-4ea8-9d16-f0fafb7f54f8	FAIZZATUL WIRDANI	P	252610525	\N	\N	\N	8	11	2526	0105174051
53a5f90b-b60d-4091-96bf-b88b472ede6b	FEBRIANSYAH	L	252610129	\N	\N	\N	8	11	2526	0092374964
55631ef4-087c-4abe-a326-d805b08ead7c	FITRIYANI RODATUL JANNAH	P	252610141	\N	\N	\N	8	11	2526	0102681533
58e8a60a-d05e-4fab-b76d-bdb4219a1fce	HANUM SAFITRI	P	252610153	\N	\N	\N	8	11	2526	0108698874
d0c7100c-4f84-41ec-939d-d2e6b6893753	IBRAHIM ALAMSYAH	L	252610519	\N	\N	\N	8	11	2526	0111996804
8693ae96-9a1e-40a6-9787-14a1a542ae52	INDAH AULIYA WATI	P	252610165	\N	\N	\N	8	11	2526	0093835588
c3afbdb5-5175-4967-aa77-98cde80d23ea	JULIA MAHARANI	P	252610177	\N	\N	\N	8	11	2526	0092228731
0ce702f5-ca15-491e-80f5-b800dddd07bd	KHOIRUL ANAM	L	252610189	\N	\N	\N	8	11	2526	0106556797
cb8f684a-98d0-4d06-aa99-f4629bfeaee9	M RAHMATULLAH GUSMAN BAIHAQI	L	252610201	\N	\N	\N	8	11	2526	0096992013
8614c0d8-6f2f-408a-b145-34fea17ee904	MELISA PELITA PURNAMA	P	252610213	\N	\N	\N	8	11	2526	0094139650
99e04bb5-8ede-42a5-a680-202398aebcf7	MELVI SALSA DILA	P	252610550	\N	\N	\N	8	11	2526	0102987550
78368162-957a-4204-814f-c98784190158	MUHAMAD ADAM	L	252610225	\N	\N	\N	8	11	2526	0103013985
a25b30a8-fcc8-45f9-bf1f-7844a4119504	MUHAMAD RIFA'I	L	252610237	\N	\N	\N	8	11	2526	0094595084
da0434fa-ca0a-4b09-b321-c43a38628cd6	MUHAMMAD DILFI ASSYIBLI RAMADHAN	L	252610499	\N	\N	\N	8	11	2526	0104010939
c831a21b-8e69-45bc-9877-c68a5a103ac1	CITRA OKTAVIANI	P	252610082	\N	\N	\N	8	14	2526	0091217578
2eb32662-b75a-45f6-96cc-498f52b0285e	DEWI SULISTIA NINGSIH	P	252610512	\N	\N	\N	8	14	2526	0107439998
be2ef2ca-443c-4ba3-bcdb-3c5c66ff0db8	DEYA NIJAR RAHMAWATI	P	252610094	\N	\N	\N	8	14	2526	0108204933
31c00a8e-659f-4113-8da1-05f443e4c97c	DZAKA UL AFKAR	L	252610106	\N	\N	\N	8	14	2526	0084043544
91c4ba34-d8df-4604-b894-f851baa37541	FAHRI FERDIANSAH	L	252610118	\N	\N	\N	8	14	2526	3097501715
744ec860-f6c5-4260-b282-99318203c260	FAJRIN WIDIYATI	P	252610505	\N	\N	\N	8	14	2526	0098980683
0a44af3a-f8aa-464e-bee2-4b4d52a12c02	FERDI FIRMANSYAH	L	252610130	\N	\N	\N	8	14	2526	0096913528
d3f8d145-c47b-4712-a915-d35b26576fd9	FIZZA AZZAM MADANIA	P	252610142	\N	\N	\N	8	14	2526	3102569374
7c322652-0ef0-4491-bff2-6597ada677e4	HASNA SAKHI	P	252610154	\N	\N	\N	8	14	2526	0102011550
1432a6b3-026a-4b62-ab30-a815eb5b2dde	IKE DWI RAHMAH SARI	P	252610510	\N	\N	\N	8	14	2526	0092337045
cdd95de8-d72c-4c1a-b639-f8c5682be5ab	INDRI YANI	P	252610166	\N	\N	\N	8	14	2526	0103946625
019e677d-2017-4afe-af9e-48c884f930da	KAFKA AGHISNA MIKAEIL	L	252610178	\N	\N	\N	8	14	2526	0103826402
71cdf649-093f-4fc6-bea3-d8620246c378	KHOLIDIYAH AUFARULA	P	252610190	\N	\N	\N	8	14	2526	0104050012
734d042e-9176-4703-b731-fb4fc9837341	M. ILHAM PUTRA ARTONO	L	252610202	\N	\N	\N	8	14	2526	3103597308
f6a378f3-d5d0-46cf-96b1-ce017b13867b	MESSI AULIA ZAHRA	P	252610214	\N	\N	\N	8	14	2526	0102751207
891633ce-4336-4ba0-8342-94588030d666	MOH. AZRUL LANANDA	L	252610509	\N	\N	\N	8	14	2526	0103325672
559c6b52-be16-46f1-9dc9-84185eceed8c	MUHAMAD AMIRUDIN	L	252610226	\N	\N	\N	8	14	2526	3092803305
25142130-633f-4586-9267-f24d06346ec2	MUHAMAD ROZIN BIHAR	L	252610238	\N	\N	\N	8	14	2526	0089878416
fcb65fdf-2c14-43c1-af23-639dbe182899	MUHAMMAD HASBY	L	252610475	\N	\N	\N	8	14	2526	0101873773
681e2f74-1838-4187-bf22-a5c9e5be40e8	MUSA	L	252610250	\N	\N	\N	8	14	2526	0097156223
35d50158-a7f9-46b4-bc8c-2ab832f8e540	NAILA PRATIWI	P	252610262	\N	\N	\N	8	14	2526	0102886602
fa60c935-6071-426f-8c0b-62c444bb72c6	NAZWA AZAHRA	P	252610274	\N	\N	\N	8	14	2526	0097096415
424ba4b9-e64b-4256-a846-2c50c48d86ca	NURMISLAENI	P	252610286	\N	\N	\N	8	14	2526	0095317545
3a67f8ac-97ce-4600-91bb-3b51027914e9	RACHEL NURFARIDHA	P	252610298	\N	\N	\N	8	14	2526	0102706922
670aef14-491c-4ef4-b68c-1c832d8c66a1	RAHMANIA RIZQITA	P	252610310	\N	\N	\N	8	14	2526	0096038995
646cacb8-8365-4bf8-8449-0d6c67eff729	RAHMAT WIJAYA	L	252610515	\N	\N	\N	8	14	2526	0098747009
e63482de-5503-4e29-9f1c-8500c3db465a	RIFQY AQIL MUHADZIB	L	252610322	\N	\N	\N	8	14	2526	3104400030
10b1e618-1da2-4b4b-92fc-b08ae89874f9	SABILA PUTRI TASYA	P	252610334	\N	\N	\N	8	14	2526	0106179061
dac8dc01-5e4b-4716-b1b1-5263b2d8c43b	SALSABILA RAHDATUL AISYAH	P	252610346	\N	\N	\N	8	14	2526	0112661853
3cbd5b53-9800-41a9-88a9-352988c6d11f	SILVI NUR ANDRIYANI	P	252610358	\N	\N	\N	8	14	2526	0105665363
f2cce3a9-aeb5-4b2e-9e54-1042a4959762	SITI AISAH	P	252610483	\N	\N	\N	8	14	2526	0097716884
8d8e9e60-9ffc-494b-9753-0b7d35db453b	SITI ROSDIANA	P	252610370	\N	\N	\N	8	14	2526	0109436404
5b0c50df-be15-43d8-a1c7-4b5a410b15c0	SULIS SURAHMAN	P	252610382	\N	\N	\N	8	14	2526	0103145606
38e67c8e-bfc5-4f4d-a726-42769cd5c42d	TEGAR SUNJAYA	L	252610394	\N	\N	\N	8	14	2526	0094292236
356afd86-bb66-46ed-ba59-79664678dd8e	UJANG DADI UTAMA	L	252610406	\N	\N	\N	8	14	2526	3105717139
7c4556cb-7d09-4b1c-9634-871f679821ef	WULAN	P	252610418	\N	\N	\N	8	14	2526	0103478869
3f568e02-ff06-4491-9e8e-17662d6bbd3a	YUNI SAKHI TALITA	P	252610441	\N	\N	\N	8	14	2526	3109727000
e0673e12-d0ac-4ac3-8497-6b5c13cb3a1b	ZIO PRANATA	L	252610430	\N	\N	\N	8	14	2526	0098278155
3d448861-b0d6-405d-b7ef-26a6974f6fad	ADE TIARA	P	252610011	\N	\N	\N	8	42	2526	0095329138
e46e3bfe-f32f-4aa6-a7b3-b081506d0df2	AGUS FATONI	L	252610023	\N	\N	\N	8	42	2526	0096793602
fdd03d65-990b-4f7e-89e2-952b1d383ebd	ALFIYANI NUR FADILA	P	252610035	\N	\N	\N	8	42	2526	0105367691
d47e03ff-327b-4aeb-935d-2a39657d902c	ALISA NADIYA AZZAHRA	L	252610529	\N	\N	\N	8	42	2526	0108152412
a1abda29-33a1-492f-93cc-a35996a63291	ANDINI CHIKA APRILIANI	P	252610047	\N	\N	\N	8	42	2526	3103627249
b4ea0941-5e53-4035-a172-e60160958e57	ANDIKA SAPUTRA ADISUPARDI	L	252610059	\N	\N	\N	8	42	2526	0097513467
549d2b2d-3cf8-447c-a09e-a9addb4dd30f	AVGANNISTAN	L	252610442	\N	\N	\N	8	42	2526	0093354154
ae25fa4d-bc0f-4da8-9eb4-f732763b1795	BELVANA ADZRIL IGNAKIA	P	252610071	\N	\N	\N	8	42	2526	0105710959
d1d85324-bb58-47d4-bb29-9fdeb18ca2c2	DAFFA AMALI RIZQI	L	252610083	\N	\N	\N	8	42	2526	3090456891
8ccc54e8-dc09-460a-ab00-5aefa6e09632	DHAFA MUSHADAD	L	252610095	\N	\N	\N	8	42	2526	0094666620
e6e079ec-bbc6-4a86-a53d-5f8cc2059726	DIAN ANGGRAINI	P	252610489	\N	\N	\N	8	42	2526	0104615440
27a7200d-3c2e-403e-8a15-8cf6800edd28	EGI NADIA PUTRI	P	252610107	\N	\N	\N	8	42	2526	3104809853
06431ffb-1d98-400d-be16-b49e13140b8f	FAISAL BHAKTI	L	252610119	\N	\N	\N	8	42	2526	0096122047
1c8eaf1f-faa8-4d55-b563-26baa10ecc4a	FAKHRIE ZHAFRAN KHAIRY	L	252610538	\N	\N	\N	8	42	2526	0105116916
5bd532ef-4b7d-473d-92b4-39821cc45934	FERDIANSYAH	L	252610131	\N	\N	\N	8	42	2526	0094865703
0af2f5c8-af1e-4e42-a5fd-c11795d797f5	GANENDRA ELANGGA PUTRO SARTONO	L	252610143	\N	\N	\N	8	42	2526	0095103787
a949ad87-6331-4e90-8bc4-33e091000067	HESTI NURUL KHOTIMAH	P	252610155	\N	\N	\N	8	42	2526	0083544893
5d79283a-d2c2-486d-b01a-bd7437a160e8	INTAN NUR AISYAH	P	252610167	\N	\N	\N	8	42	2526	3098389354
7ae75832-38cf-43ee-92d2-c706258527bd	JAHRATUNISA	P	252610454	\N	\N	\N	8	42	2526	0099581592
76f05f36-0982-498b-a7b6-5893d4f59e8c	KAYLA ISTIKOMAH	P	252610179	\N	\N	\N	8	42	2526	0092143777
40ff2613-15c3-4d11-a66a-8765aafc5d86	KHOLISHOTUN NAJDIYAH	P	252610191	\N	\N	\N	8	42	2526	0097599509
ca687804-d44d-4324-ba3d-c0d4e2b0753c	M. REHAN DWI ERLANGGA	L	252610203	\N	\N	\N	8	42	2526	0108902852
c36858ed-da89-42a7-912a-ec9a7b7b8c73	MEYLANI PUTRI	P	252610215	\N	\N	\N	8	42	2526	0091932582
a837e748-e7ab-42c0-a935-3d74c9b1b1a2	MOHAMAD REYHAN MAULANA RIYADI	L	252610503	\N	\N	\N	8	42	2526	0094185065
d18e7844-a3d0-4e6d-a684-d2ee66d3a91f	MUHAMAD ANDIKA FIQRI	L	252610227	\N	\N	\N	8	42	2526	0107944218
f788b0da-cfb3-4273-ad90-e4ff270bef78	MUHAMMAD AZRIL BIMA SATRIA	L	252610239	\N	\N	\N	8	42	2526	0091402664
14a52f03-8aa6-4508-b2f1-435a94f7ba20	MUHAMMAD IRFAN NUR RAMADHANI	L	252610493	\N	\N	\N	8	42	2526	0107478352
9d8c56e0-9b42-400c-ae67-d66361111297	MUSLIM	L	252610251	\N	\N	\N	8	42	2526	0096638988
f40ba698-9c66-4ca5-8e36-a99b64aecbfe	NAILA PUTRI	P	252610263	\N	\N	\N	8	42	2526	0108086004
248c202b-40d0-43d5-ae17-149b2bb8ed93	NAZWA PUTRI AMRULLAH	P	252610275	\N	\N	\N	8	42	2526	0108756220
b6456cb4-499c-49e8-aa82-ed64969e415c	NURUL ARIFKA	P	252610287	\N	\N	\N	8	42	2526	3103673934
db2246f9-6ab2-46ba-9356-f672abcfd940	RADITYA ARDIE AZUCENA	L	252610299	\N	\N	\N	8	42	2526	0107945236
ac102a47-6f55-4141-855f-7985e469f54a	RASYA DIVANI	P	252610311	\N	\N	\N	8	42	2526	3090056023
06f1437a-bc38-42ce-84dd-952382794818	RAZKA ATMA DEVA	P	252610518	\N	\N	\N	8	42	2526	0102700924
fede17ed-9618-4ef3-8f40-065b367623f5	RIKA AVRILLIA	P	252610323	\N	\N	\N	8	42	2526	0103275755
a9b2011c-1e5e-48d6-bb44-8e66182d8ec6	SABRINA GEA ALFIANA	P	252610335	\N	\N	\N	8	42	2526	0105893866
a0bf4e00-b810-41da-b1a4-2a1ba9393733	SASKIA SALSABILA	P	252610347	\N	\N	\N	8	42	2526	0101330507
006e62fb-ee45-4f31-a8a3-46973fec19d2	SINTA	P	252610359	\N	\N	\N	8	42	2526	0106309535
5987c052-d427-49c5-b388-fdb9ee875003	SITI FATIMATUZAHRA	P	252610535	\N	\N	\N	8	42	2526	0094602096
f7925952-e041-48fc-915c-dd347128e6c1	SITI ZULEHA	P	252610371	\N	\N	\N	8	42	2526	3101542633
f12565d4-df5a-42b2-8767-14f87150c517	SUNNI MAULANA LUTFI	L	252610383	\N	\N	\N	8	42	2526	0106643426
8b1af036-1162-4679-aa58-2e0095c08c96	THALITA PUTRI VIRLIYANTI	P	252610395	\N	\N	\N	8	42	2526	0095726440
3202bb54-e6b1-477f-a524-dba552e7e426	ULFATUL LATIFAH	P	252610407	\N	\N	\N	8	42	2526	3099870683
50063026-b9ba-40df-9fbd-8c4e2a745631	YASMIN AULIA	P	252610419	\N	\N	\N	8	42	2526	0105534206
d83b51d1-c607-473f-9ee9-fbdb1e3b9375	ZAHRANI DWI PRIHARTINI	P	252610471	\N	\N	\N	8	42	2526	0107335214
9c54313d-974d-409b-82c4-d9b42a6f72cc	ZORA JENAR MAJID ZIDANE	L	252610431	\N	\N	\N	8	42	2526	0098815506
3e1843ec-e57b-483e-bd1f-02bb38e0c4a1	ADELA NOVIANA	P	252610012	\N	\N	\N	8	43	2526	0094421081
f9bbb5f1-20a1-476a-a0ad-843b7a1abe18	AHMAD NURHASYIM	L	252610024	\N	\N	\N	8	43	2526	0109196821
0b38340f-2b7f-44f9-8fdc-53a61267103a	ALI MAHRUF AL CAPAR	L	252610036	\N	\N	\N	8	43	2526	0109940357
103446e4-df83-4a15-b89e-c238f1ccc64d	ALVI SYAHRIN	P	252610485	\N	\N	\N	8	43	2526	0096821336
3a5e4308-f5c7-43fc-a54f-08a8da8b4709	ANDINI ERLIN TASYANI	P	252610048	\N	\N	\N	8	43	2526	0095691831
9c0ab096-7128-40cf-8c78-32fa76347e00	ARLAVINDA REZQITA	P	252610060	\N	\N	\N	8	43	2526	0091844132
3aa5c3f7-d922-44cf-842b-4e43ff09fcab	AZIDAN	L	252610433	\N	\N	\N	8	43	2526	0107127230
3b88157f-d9fa-412d-8abc-3205d5c8989d	BUNGA RUSTIANA	P	252610072	\N	\N	\N	8	43	2526	0097605900
e4a3ca12-4ddf-452e-872e-e29ad2f4ecc2	DANIA NIDAUR RAHMAH	P	252610084	\N	\N	\N	8	43	2526	0107547092
2a32b1f3-0647-42d1-8310-6e66b832b404	DIAN MAHARANI	P	252610096	\N	\N	\N	8	43	2526	0112911109
b1ce6052-c615-4113-8f0b-8464d6fbfa7a	DIKI	L	252610449	\N	\N	\N	8	43	2526	0107723963
c356bf76-11d5-4df0-8c30-5f72d8047757	ELFADYA ARSHAVIANA	P	252610108	\N	\N	\N	8	43	2526	0097102122
d62b73fb-b5c4-44c4-bff2-27e5ef5465f9	FAIZ KHAERUL AKBAR	L	252610120	\N	\N	\N	8	43	2526	0102058376
d4745c87-93bd-4ccb-a332-fad47e3f72f5	FARRIJ PERMANA	L	252610553	\N	\N	\N	8	43	2526	0096879616
0040fe81-4aa0-4f67-8a08-ce2b3100de01	FIFI RAFEYFA	P	252610132	\N	\N	\N	8	43	2526	0102424314
b5008f21-c450-44c1-9d30-2652a639c6c1	GANESA PRATAMA	L	252610144	\N	\N	\N	8	43	2526	0094561244
049837f6-2151-4c8a-bd38-823167052ca5	HIJRAH YAOMI	P	252610156	\N	\N	\N	8	43	2526	3092844722
c12d3e51-0973-4474-8e21-c6a979440616	INTAN NUR FEBRIANTI	P	252610168	\N	\N	\N	8	43	2526	0107660738
8b123910-b932-4bb9-827c-2489690edf96	JULIANSYAH SETIA RIZKY PRATAMA	L	252610480	\N	\N	\N	8	43	2526	0108129094
a140df8d-bf32-4b98-8132-62e44367e58e	KAYLA NISWATHUN ZAHRANI	P	252610180	\N	\N	\N	8	43	2526	0103410823
8eef02e4-1bd6-4da0-b4f4-a56b3bdcba6d	KIRANA KEIZIA AULIA REMARA	P	252610192	\N	\N	\N	8	43	2526	0097965412
1e4c22c4-5779-4922-9ae0-01e91f5036c6	M. RIZIK	L	252610204	\N	\N	\N	8	43	2526	3105590798
4c09d8aa-dd07-4aa7-8c77-a9d61ba8db7e	MITA NURFADILAH	P	252610216	\N	\N	\N	8	43	2526	0092328754
24c0b46b-fb72-41ab-aaa5-38883f5f91dd	MUHAMAD BAKHRUDIN	L	252610228	\N	\N	\N	8	43	2526	3101810151
90cce401-e973-470d-95fb-ea800b03612f	MUHAMAD DAPA SOLEHUDIN	L	252610540	\N	\N	\N	8	43	2526	0098891324
bbf5816c-938e-4282-ac80-1c1b09da7474	MUHAMMAD DANISH NORIZA RAHARJA	L	252610240	\N	\N	\N	8	43	2526	0107461885
ceaad337-9dd1-450a-aef5-c7a7bfdceb1d	MUHAMMAD ZAKKI MUBAROK	L	252610482	\N	\N	\N	8	43	2526	0102301762
883e547f-39db-4e7b-8058-14c1c54eea81	MUTIARA	P	252610252	\N	\N	\N	8	43	2526	3106837139
2d7d55b3-9cde-4b93-8730-a799186a7624	NAILA SYIFA RAHMAWATI	P	252610264	\N	\N	\N	8	43	2526	0107786196
e36949cb-c2d6-4a57-972e-cfbc01d18c7b	NAZWA ZACKIA	P	252610276	\N	\N	\N	8	43	2526	0094605839
b8ba7bdd-8da3-4f06-a217-7d7ea922a31d	NURUL HIDAYAH	P	252610288	\N	\N	\N	8	43	2526	0108588768
cc2e92e9-c2ef-40c6-a3f5-dd8eb14e6f5f	RAFA RAMADAN NURFADILAH	L	252610300	\N	\N	\N	8	43	2526	3104895729
edbe8939-f27f-42f9-9acc-494e779d0b2e	RASYA FIRDAUS NUR SIDDIQ	L	252610312	\N	\N	\N	8	43	2526	0106709119
41788f25-1b04-4763-8d7b-8b11df56d6d3	RENI ANGGRAENI	P	252610551	\N	\N	\N	8	43	2526	0093654141
7470c047-5e50-47a4-9873-30adb21eae45	RIO FIRMANSYAH	L	252610324	\N	\N	\N	8	43	2526	0092185678
772bdd19-c151-419c-8dde-88111606630a	SABRINA PUTRI MAHARANI	P	252610336	\N	\N	\N	8	43	2526	0104378545
baf73dba-8299-4152-98c7-f18a202412a4	SASKIYA PUTRI RAMADANI	P	252610348	\N	\N	\N	8	43	2526	0106396056
91b5498d-365f-4940-9387-85c5d76a5c4b	SITI AISYA NABILA	P	252610360	\N	\N	\N	8	43	2526	0103298276
e1d3e6e3-e232-4c3c-aba6-397dd4b34d54	SITI MARWAH	P	252610456	\N	\N	\N	8	43	2526	0108066064
6e032689-5ea9-41c9-9c85-5a2a4c9c82d3	SOFA NURFAOZAH	P	252610372	\N	\N	\N	8	43	2526	0094237243
d6207360-26fa-487d-b5d6-63bc60b15a23	SURYA PURNAMA AGUSTINA RAMDANI	P	252610384	\N	\N	\N	8	43	2526	0101769748
c1b92285-14d6-4728-8622-a081b70395f0	TIARA AURA JULIPAH	P	252610396	\N	\N	\N	8	43	2526	3100406400
d605ffb8-e641-4ae6-9ea2-b0a0b1595f2b	ULLIA BELA	P	252610408	\N	\N	\N	8	43	2526	0095992296
a9d5cee1-ee99-4526-af1d-b675f8357c97	YAYAH CHOERIYAH	P	252610420	\N	\N	\N	8	43	2526	0106710523
19a59001-ccb9-4466-958a-03b05e24c821	ZASKIYA PITRI RAMADANI	P	252610469	\N	\N	\N	8	43	2526	0104099887
7c4c6317-6380-4301-b547-2f4d23b536ce	ZULFATUL MEIGINA PUTRI	P	252610432	\N	\N	\N	8	43	2526	0103489346
\.


--
-- Data for Name: d_subkelas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.d_subkelas (id, kode_subkelas, nama_subkelas, id_kelas) FROM stdin;
1	\N	10-1	8
2	\N	10-2	8
3	\N	10-3	8
4	\N	10-4	8
5	\N	10-5	8
6	\N	10-6	8
8	\N	10-7	8
9	\N	10-8	8
11	\N	10-9	8
14	\N	10-10	8
18	\N	11-IPS-1	2
19	\N	11-IPS-2	2
20	\N	11-IPS-3	2
15	\N	11-IPA-1	2
16	\N	11-IPA-2	2
17	\N	11-IPA-3	2
28	\N	11-IPA-4	2
29	\N	11-IPA-5	2
30	\N	11-IPA-6	2
31	\N	11-IPS-4	2
32	\N	11-IPS-5	2
33	\N	11-IPS-6	2
22	\N	12-1	3
24	\N	12-2	3
25	\N	12-3	3
26	\N	12-4	3
34	\N	12-5	3
35	\N	12-6	3
36	\N	12-7	3
37	\N	12-8	3
38	\N	12-9	3
39	\N	12-10	3
40	\N	12-11	3
41	\N	12-12	3
42	\N	10-11	8
43	\N	10-12	8
\.


--
-- Data for Name: d_tahun_ajaran; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.d_tahun_ajaran (kode_tahun_ajaran, nama_tahun_ajaran, keterangan) FROM stdin;
2526	2025-2026	\N
2627	2026-2027	\N
\.


--
-- Data for Name: d_ujian; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.d_ujian (id_ujian, nama_ujian, deskripsi, semester, kode_tahun_ajaran, kode_ujian, jenis_ujian, kode_mata_pelajaran) FROM stdin;
20	UH Bahasa Arab Semester 1 2025-2026	\N	1	2526	UH.ARAB.SMT1.2526	UH	ARAB
21	UH Bahasa Indonesia Semester 1 2025-2026	\N	1	2526	UH.IND.SMT1.2526	UH	IND
22	UH Bahasa Indonesia Tingkat Lanjut Semester 1 2025-2026	\N	1	2526	UH.INDLJT.SMT1.2526	UH	INDLJT
23	UH Bahasa Inggris Semester 1 2025-2026	\N	1	2526	UH.ING.SMT1.2526	UH	ING
24	UH Bahasa Sunda Semester 1 2025-2026	\N	1	2526	UH.SUNDA.SMT1.2526	UH	SUNDA
25	UH Bimbingan Konseling Semester 1 2025-2026	\N	1	2526	UH.BK.SMT1.2526	UH	BK
26	UH Biologi Semester 1 2025-2026	\N	1	2526	UH.BIO.SMT1.2526	UH	BIO
27	UH Ekonomi Semester 1 2025-2026	\N	1	2526	UH.EKO.SMT1.2526	UH	EKO
28	UH Fisika Semester 1 2025-2026	\N	1	2526	UH.FIS.SMT1.2526	UH	FIS
29	UH Geografi Semester 1 2025-2026	\N	1	2526	UH.GEO.SMT1.2526	UH	GEO
30	UH Informatika Semester 1 2025-2026	\N	1	2526	UH.INF.SMT1.2526	UH	INF
31	UH Kimia Semester 1 2025-2026	\N	1	2526	UH.KIM.SMT1.2526	UH	KIM
32	UH Matematika Tingkat Lanjut Semester 1 2025-2026	\N	1	2526	UH.MTKLJT.SMT1.2526	UH	MTKLJT
33	UH Matematika Umum Semester 1 2025-2026	\N	1	2526	UH.MTKUMUM.SMT1.2526	UH	MTKUMUM
34	UH Pendidikan Agama Islam Semester 1 2025-2026	\N	1	2526	UH.PAI.SMT1.2526	UH	PAI
35	UH Pendidikan Jasmani Olahraga dan Keterampilan Semester 1 2025-2026	\N	1	2526	UH.PJOK.SMT1.2526	UH	PJOK
36	UH Pendidikan Kewarganegaraan Semester 1 2025-2026	\N	1	2526	UH.PKN.SMT1.2526	UH	PKN
37	UH Pendidikan Kewirausahaan Semester 1 2025-2026	\N	1	2526	UH.PKWU.SMT1.2526	UH	PKWU
38	UH Sejarah Semester 1 2025-2026	\N	1	2526	UH.SEJ.SMT1.2526	UH	SEJ
39	UH Sejarah Tingkat Lanjut Semester 1 2025-2026	\N	1	2526	UH.SEJLJT.SMT1.2526	UH	SEJLJT
40	UH Seni Budaya Semester 1 2025-2026	\N	1	2526	UH.SEN.SMT1.2526	UH	SEN
41	UH Sosiologi Semester 1 2025-2026	\N	1	2526	UH.SOS.SMT1.2526	UH	SOS
42	UTS Kimia Semester 1 2025-2026	\N	1	2526	UTS.KIM.SMT1.2526	UTS	KIM
\.


--
-- Data for Name: f_jawaban_siswa_dtl; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.f_jawaban_siswa_dtl (seq_jawaban_siswa_dtl, id_jawaban_siswa, no_soal, kunci_jawaban, nilai, jawaban_siswa) FROM stdin;
529	72	2	B	0	D. D
531	72	3	C	0	C. C
532	72	4	D	0	C. C
533	72	5	E	0	D. D
534	72	6	A	0	D. D
\.


--
-- Data for Name: f_jawaban_siswa_hdr; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.f_jawaban_siswa_hdr (id_jawaban_siswa, uuidsiswa, id_ujian_hdr, id_kelas, id_subkelas, kode_mata_pelajaran, uuidguru, nis) FROM stdin;
72	e56b31b4-d1e3-4e21-b9f2-da5f3ed2b87c	130	8	2	KIM	f27758a3-2f9a-4a94-a675-2c2beb6d3d73	252610002
\.


--
-- Data for Name: f_soal_dtl; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.f_soal_dtl (seq_soal_dtl, option_a, option_b, option_c, option_d, option_e, no_soal, id_ujian_hdr, isi_soal, gambar_soal_filename, kunci_jawaban, nilai) FROM stdin;
350	A	B	C	D	E	1	129	Soal 1	soal_688fa218c6aa4.png	B	20
351	A	B	C	D	E	2	129	Soal 2	\N	B	20
353	A	B	C	D	E	4	129	Soal 4	\N	C	20
354	A	B	C	D	E	5	129	Soal 5	\N	C	20
355	A	B	C	D	E	1	130	Soal 1	soal_688fa218c6aa4.png	B	20
356	A	B	C	D	E	2	130	Soal 2	\N	B	20
357	A	B	C	D	E	3	130	Soal 3	soal_688fa218cb398.png	C	20
358	A	B	C	D	E	4	130	Soal 4	\N	C	20
359	A	B	C	D	E	5	130	Soal 5	\N	C	20
360	A	B	C	D	E	1	131	Soal 1	soal_688fa218c6aa4.png	B	20
361	A	B	C	D	E	2	131	Soal 2	\N	B	20
362	A	B	C	D	E	3	131	Soal 3	soal_688fa218cb398.png	C	20
363	A	B	C	D	E	4	131	Soal 4	\N	C	20
364	A	B	C	D	E	5	131	Soal 5	\N	C	20
352	A	B	C	D	E	3	129	Soal 3	soal_688fa218cb398.png	C	20
\.


--
-- Data for Name: f_soal_hdr; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.f_soal_hdr (id_ujian_hdr, id_ujian, kode_ujian, id_kelas, id_subkelas, st_posting, waktu_mulai, waktu_berakhir, nama_bab, createuser, createdate, updateuser, updatedate, uuidguru, kode_guru, kode_mata_pelajaran, durasi, userposting, token, st_nonaktif_token) FROM stdin;
129	31	UH.KIM.SMT1.2526	8	1	\N	\N	\N	Unsur	GSMADKP055	2025-08-04 00:53:28.73746	\N	\N	f27758a3-2f9a-4a94-a675-2c2beb6d3d73	GSMADKP055	KIM	90	\N	M2LNHFD	\N
131	31	UH.KIM.SMT1.2526	8	3	\N	\N	\N	Unsur	GSMADKP055	2025-08-04 00:53:28.879616	\N	\N	f27758a3-2f9a-4a94-a675-2c2beb6d3d73	GSMADKP055	KIM	90	\N	GTV62W3	\N
130	31	UH.KIM.SMT1.2526	8	2	Y	\N	\N	Unsur	GSMADKP055	2025-08-04 00:53:28.860812	GSMADKP055	2025-08-04 00:53:54	f27758a3-2f9a-4a94-a675-2c2beb6d3d73	GSMADKP055	KIM	90	GSMADKP055	2WNQDM7	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (uuiduser, uname, pword, fname, role, nis, nip, st_generate, createdate, updatedate, updateuser, createuser, kode_guru) FROM stdin;
85573a27-b986-4886-bdef-3b6b95181ba8	admin	$2y$10$J9Nn1WL.a1iWY5AaJj5qpO8xjq6CxH2HvTEwCgjvADbMWgUu/WSq2	Admin	3	\N	\N	\N	2025-07-08 01:39:39.075768	2025-07-12 05:13:51	johnson	\N	\N
7d0c3e1d-ff73-4834-81f2-746cfa038a7b	GSMADKP002	$2a$06$Zv381Vl99dxxFSecOGAJBOfcY7Mx8P29Rs6KcKDU6gqjA1mTZD70K	A. Riyanto, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
f669431a-1fe7-4727-8148-0ce896d448fc	GSMADKP003	$2a$06$rDUTQYlIK/wwX29StT93iuSlx9Sq1wTUl3Wi.6bi9Etd4OjyWcH7q	Ade Suratno, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
719f53bc-757a-431e-8077-572fac7d94da	GSMADKP004	$2a$06$jYoowWJ/eYvXm190uP3NruLhJnKNSEkzDMxeG1ir23W/TaTshrmuW	Adi Apandi, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
82f86188-ec88-4003-9e54-25cce0a13983	GSMADKP005	$2a$06$M/9lsjLL1Kfz840ZiCnym.Iee3HHF48eanZeLAMfdGc0WGqFaVyca	Adin Surachman, S.Pd.Kim.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
270e5001-e43f-4ba4-8932-4a568d489061	GSMADKP006	$2a$06$6g.gJSWYX33gq6F3pvN6cujQhubJxegQKlDAuHVN/4giQEV8mxX5u	Ahmad Zakki, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
b9c69267-ae33-4b82-96cb-f5b75e9b43ed	GSMADKP007	$2a$06$oNERqcVCBmwazWvl64IIjOHXL.9wDJk3GgpUYQhMHH1NBZprrTdSO	Ani Purwandani, SE	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
35a26890-238a-43ac-972e-b02ff034ca21	GSMADKP009	$2a$06$hd43UBkrGcQM3Ta5a3hihuL/gbmUZP6YGjLeOqvdQWA/mPNH/4fui	Anikh Dewiyanti, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
35d8142d-7e9b-42a2-93d3-3fa1503519f8	GSMADKP011	$2a$06$pM8FYLsdTDTJO.XM.pIrIuhXdtTL51h45AHrtlY.W8wwhsUX4dJTO	Annisah Nur Amaliyah, S.Sos, M.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
da400fc8-08e7-49fc-ab51-7504338ddf6a	GSMADKP029	$2a$06$.dAXxHPc8yAesK4pZPrnO.NczVOpck37tN950ds.mCu4VEUiHApTK	Faturochman, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
c77da499-488b-42d5-ab74-460d2a42d8b7	GSMADKP012	$2a$06$T6BOKt3zDKqmsb4hf/4HP.wZU3vA/jE85KOqpBi/T9EgYJr6XBGYe	Ati Rosmiyati, M.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
501348b3-b0ac-4345-9283-98911a4bf72d	GSMADKP013	$2a$06$cFkkHmBJQYJ.ZVySJ7tgfuW3zupuLdTtbFiiS5CLwfsYERijpOD26	Chaerih Nurlinda Sari, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
d286a994-afcb-465f-84d2-9cfe39e63740	GSMADKP014	$2a$06$TrojDaGW4k6W.r/zGSH6X.VliFM5VLvIv21uS/a6jvBE3bEpbFm/a	Dewi Puspitawati, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
a4cb2268-ec30-4d8d-9d93-517c69ae6aa9	GSMADKP015	$2a$06$B9g9nUWrXchztwbTCj6A7eT.B2tok6GOpUmvGndNOBpPzstqY3mIq	Dinda Lovi	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
463641dc-d1a4-4da5-b109-1649005dc36c	GSMADKP016	$2a$06$nvK7EvNqKUdqNPwdIKacqut/7oxlggTEJWd0.M4lUl32n8fY62HXe	Dra. Hj. Juju Juhaeriah, M.M.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
635da25e-4afd-44d8-97c6-c9e8a2f4337a	GSMADKP017	$2a$06$cR0lmqFDgnnYtrddn.ZLDesdzGyUYFk02nPozXHxW/TfpgWPIFKDa	Dra. Rachmadiana Z.A	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
1f7ecfc9-24cd-4270-b511-335a527d7c3c	GSMADKP018	$2a$06$G53xiWgu5eDJNryyy8DwkusvkFVbeF06ftj0gWS/5Vzb6CyH6m7pa	Dra. Wahyu Tresnani	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
b51458f1-26eb-4d64-a542-2d851d14d9bb	GSMADKP019	$2a$06$NyOOm1aSg0WrGe02ELNcSOrq024oGlEKY4PyB0mm0GI5hs/diG/Ju	Drs. Agus Mulyatno	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
5953a8f5-a2a8-4a3a-9c45-04e0fe03af1b	GSMADKP020	$2a$06$Xwur7vN3GLyOlwwgyR45se7aUZoL.er8Msd8QB4JKZFCnSnuH57N2	Drs. Dadang Supardan	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
be25ad21-3454-4785-b2de-b43a832601cc	GSMADKP021	$2a$06$QE7O.gqRpNJHi9nrl1amleiRtsMl7wWGzCkUJIns2dis4zvS6mbq2	Drs. Makbul	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
246e5034-f4a9-4dc5-a7e4-65ce7224d09d	GSMADKP022	$2a$06$CdI6qrNexK76foctRPrCI.l839gXITVxmuCsa9.PgiVt2brHKlffW	Drs. Mohamad Rosidi, M.M.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
36f7d4c1-aad0-4c86-b127-a8ce66f60bb3	GSMADKP023	$2a$06$Pg/x9nUxYUy7VRWTH3Xu1u9Sx83uWjKohyyL/N775XqjNZbpKdx8m	Duha Yasin Al Asyari, S.PdI	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
96a9322b-5cea-4765-b962-debc9f98c93f	GSMADKP024	$2a$06$cnmV368LIOPJnDY5LzH4xeVe1hdMTjKE78Wivtif6sHzED1a2nk7i	Dwesnita Lintang Langit, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
a6bd0a24-8a2e-4a0c-9f63-27d06477acc9	GSMADKP025	$2a$06$Nk9OrRXWMiYOeiG/6nmgI.NqtoMMUAerLunKMdQfi5W5nhtaIR1L.	Eli Susilawati, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
fca436e2-214f-4136-bf10-8f08550355aa	GSMADKP026	$2a$06$sFwE4UxfdJG5n7brAE0U4unz/5TeIcrZ5rgmKvKe.TmFlNnL0ILTe	Epih Purnamasari, M.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
fb3f816a-af91-450b-82b4-686b6c1217ea	GSMADKP030	$2a$06$0j3COe5/.yNWMVIXasxZ6.MZ7cr2rc9jkVnO3V83H4HnxnNj8VOua	Fifi Magfiroh, S.Sos., M.M.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
b183b3af-b1a6-4115-a689-14258dbc21f7	GSMADKP031	$2a$06$4klOXPZVcCqM8l2DN25cqOIRuv8QVZtUnINGqRT5yT0zHRjL3bDZq	H. Ali, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
572cdcb2-cb44-4460-bbaa-8803605c2350	GSMADKP032	$2a$06$vu7Gg6EYsP6H9iqFZpVXPOZPHC5CkWSdf.cwtNjQ9HAqHVFm/nUyi	H. Dede Solikhin, S.Pd, M.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
f43210a4-1567-4669-b394-0326b124d46f	GSMADKP033	$2a$06$HDKQdjD7f5oDnT1DECdOe.OPASSVRz8zVnKiCAbV1ZlGIic6ixI4y	H. Markana, M.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
65e1047d-d6fe-48d6-bae8-b088c708f2b9	GSMADKP034	$2a$06$xTeEKHzoHnoQ4YeRly.ry.kN2gbDlVaUGdQiNZS4xU0Q6xlr1Szpy	Hj. Asri Nopalia, S.H.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
19e4aa0a-9a92-4c45-bd1b-f573d9503cf3	GSMADKP035	$2a$06$MrmBVt6av8yKvYIFpj7V3OX.MY7VvEAj88Sf7D4iws7qZbjBRpk3u	Hj. Fifi Fikriyah, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
e2fcd0e5-8b78-483f-8464-94e0294842fa	GSMADKP036	$2a$06$sQd5TinxCJrUDmlw8v4preSKm/18F9XgpihafxmbOj15hUhLCsrfK	Hj. Nana Yohana, S.E., M.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
49e5d165-6a52-49ae-9c74-a93053b2cbfe	GSMADKP037	$2a$06$8rCjN4LyYevGS4PpLb6nDuWrCLCY638FolTxGfX963inRkax9E9Zm	Hj. Titi Atiyah Diniawati, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
714b16b9-dcff-4ecd-bdae-53e1be11862b	GSMADKP038	$2a$06$m8kDRR7iy9n3h1/FcCGHFOW4JYCMIXRHjQqJrDMSlvRj3aeTY4JxK	Ima Halimatusyadiah, M.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
a829384f-183f-4998-93c3-a837f02643c7	GSMADKP040	$2a$06$mP/lEfbU4dL.DbYK.SQO9OGhaS6gwtpGwhHsGbc0v0coOoMG1/61S	Iman Abdul Rahmat, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
65262d56-6d95-4be4-b253-92f20491fdd5	GSMADKP042	$2a$06$Gqow33o5s66bB.oMVGkyZOHn./4FdXoY0jS0fnKgJrHjMvgvsJ.9y	Indri Leomita, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
2b6db571-4bb4-4582-8be4-ded2a6eceb43	GSMADKP043	$2a$06$tu8MsyIrbjkMUWy7r0/ZauEId7UfFGC8liZOC6BkH5PZz.oynnL2u	Indrie Sabatinie, S.Pd., M.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
1d73bc7f-5cd7-4c50-a874-d49bb64c092c	johnson	$2y$10$INhJZNcKsRGXSdlxi1awyONPtZJKJzJFFkzxIryGtxpca8KxXLCWO	Johnson Marco	3	\N	\N	\N	2025-07-12 16:46:43.929861	2025-07-20 01:01:48	admin	admin	\N
37d18722-a5d6-475f-8502-d1840fcf21b4	GSMADKP045	$2a$06$zU38GHG7HdICOPfawOeOUOMle2pQ5Vz/qgNzpenBg33BLPNfzDbhS	Jujum Jumerah, M.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
3908aed2-d87d-4ce6-8433-c73745459b9d	GSMADKP047	$2a$06$XpiNLADmPJ6EWZLv6h1C1uBreUvKPSAB9tMoIHJ6CnJBoD2lEILF6	Laely Mafruhah, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
6ffd954f-7e94-44b1-ad2f-b66ff0c5208a	GSMADKP048	$2a$06$vOi7RnyFZF0S59qK83EVOOOjkaMiiWoUUwl3rvwabL90DdRDRfFPG	Luhur Riandi T, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
0134231b-da66-44ba-ac2b-a80a26bed1c9	GSMADKP049	$2a$06$9GN8vdyNio3woNWvnwNtJ.AfByH91x8MpcrRD63PXffMPOmX5OQ5W	M. Dedi Manfaluthi, M.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
69765295-8d62-4580-8a56-8f9971232228	GSMADKP050	$2a$06$XBuUjfyHCmPsSXg4B3fE4.YL7k3ABtRheOg5kJ8ED8iTyWTLylNSm	Maysaroh, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
3ea5411d-e46b-4536-9bf9-25acf985250c	GSMADKP052	$2a$06$7SY3BrtnQ8Cqx.5OUbIo9uM.nZDAXwe0u0I6XuTAwkxF4tIrm7NZa	Melati Fitri, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
5b3a04ec-e4dd-451b-9f3d-60c7b680591b	GSMADKP054	$2a$06$Ytfmal8x2N.8FHg9B.Z9Z.Z8L.qN5b4L7JV60BZF3BZ4lczbm8SFu	Mindah Wati, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
20b31cdc-8875-4e64-9db0-866d7a4a8b5c	GSMADKP055	$2a$06$TZe8W/.1M/xm3YxV048jjuzC8.Nx/WuSl2/uh1rB3xRZ7DsuI8jmC	Muhaimin, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
a394e93f-1aa9-482d-946c-8a383bd048b4	GSMADKP056	$2a$06$zaJRyIUSQLlTVqy.CWq8reK6pbhcXVoTWqCbrX9CiTMY2bIYAeoQG	Nartiya, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
fb677924-d2f4-4179-8193-49534cd7fe42	GSMADKP057	$2a$06$0dAG7U25hevelHYtkHph/utQo02pzJ.BdnHcTtI6EOePGPD4DVNrS	Nukke Septhia Nugrawaty, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
109bb720-4d32-4134-8dd8-c900b4939454	GSMADKP059	$2a$06$xSWC5HcBT6V0Rfg9f7NH.eupH4Gno19ASg2xDaRest8UqKTOjHPxm	Nur Fitriyanti, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
4970d82c-821c-4b65-a57f-2861d1f8cdd6	GSMADKP060	$2a$06$/AWSCCPHTfCj4yZ2WOAkPe.wLI3dnNyE2nDFQZFwfThG.oNl/LOvy	Nurjannah, S.Pd.I	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
8294395b-199f-4cbf-99e5-9103348f9a1f	GSMADKP061	$2a$06$H2DTRaOlinH9x9LNDQogQuwuNsrxCTnn6mIFCQG/U4MiGtuRYkCIW	Putri Wulandari, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
72ce6cbe-d117-4441-9c15-c521c35420ba	GSMADKP062	$2a$06$7GVV7HEVfHbyvsGzkuwxyOiX.mJfkb4mwrGUaAvblSnCBa4dO3Dy2	Rachmah Nazila, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
725d7dae-ddbf-41d3-9fec-639301fac0ab	GSMADKP063	$2a$06$zgDtqcAo4XH9fLuHGmd24ON5hYsAC4eSH0IZuqF7VrPmWodN.SKoO	Reviana Irnayanti, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
8397b735-1b32-4c77-b9c2-838fa150cbfd	GSMADKP064	$2a$06$ZGXgPyG3ayTcopf.RE3BpOoCciknoSRuBFbnmyiLzjROFVVqRLroe	Salamah, S.Pd.I	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
c7242748-93fd-462d-bb52-a0fea9cb63af	GSMADKP065	$2a$06$e.rhne2oO6YXoZxe36a7kOb2TJS9muRTV4QhxIFuVeIQmDPD1Zi9G	Sari Henita, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
6818f8ef-b2d8-4800-86ca-0c8e600f4e6e	GSMADKP066	$2a$06$y7.o7u2ZtBf3YbHkzK7MKOpnNUx5rYLyi.1t2qCtw.sjSgP509k/W	Sigit Mulyoseno, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
4c1c865b-6600-4fec-ab34-37f1878d668c	GSMADKP067	$2a$06$qGCQHslZIUtty5oRPIBIOenA/WNI0OKJnsPp029KghIC9JuW6mUSa	Sri Ningsih,S.PdI	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
cbbd4999-60c4-44fb-9793-f11fee379298	GSMADKP069	$2a$06$aBjs5PMt.xYFYcJhYYOhguWgTVCTN0QGEtgoxXKvu6iaRIR3t18Oa	Subagyo, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
6cd4b1b8-2480-4ca2-b4c2-067e19494c5b	GSMADKP070	$2a$06$rDi82VdPZTPJxTK4LVl1D.url8WvwqWx1Rb.OQnqL7fhMY2vNTeWe	Suradi, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
afe3b0ed-78c9-48ab-ad16-de3d4fd975ac	GSMADKP071	$2a$06$nNGDbzN89SlgNvjBXDjshePfylsSGAfe30PICs3I531Nz8e3FuLPu	Syaeful Apriyanto, M.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
959cf51a-87e7-4495-8fd6-9f6853d79fd6	GSMADKP073	$2a$06$ZNkJrWDh0u9A1MKd02xHeOr1d1e7WVJ2VWBJMtws591oL7/Srh9x6	Syamsul Kamal, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
0364e0b9-6c7f-4ffc-bd8e-9865a3a413f0	GSMADKP074	$2a$06$hcsrs9hHKTd8QBKqWiNC1e7m8KyPdLUnpVMtGrarShgobaSOqa/qm	Tarjodipuro, S.E.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
067e91f2-408a-4036-9a55-d2222a47f48a	GSMADKP075	$2a$06$x2OE2T0bgp/EJfVj9g9gK.iZlmdhBMoO3cdd8fyzJpRn2TVfoWqUS	Titin Rohaeni, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
a0ab3c64-7279-4dd6-9d7f-bfae836ad657	GSMADKP076	$2a$06$Oj7ae3700G/RDD9vQ3qNDeWS85/SHfrTDpL1HGBOsboVIFA1.R8PO	Umul Mu'minin, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
4cb7ec3c-c5f4-430c-a234-b2095340dd70	GSMADKP077	$2a$06$yIaMAjFgqbuFfIEr48aeS.4jPR/wKEqL8nED5uhznnjK3Ut.Yv7gG	Windari Pandanita, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
c760065b-0f31-4cec-a480-b4ab977b00c9	GSMADKP078	$2a$06$rT1mYrjjIqJAAHj0VkRmIOQki4lS7UTY9jjHFpTI/hmxHaGFXyOmu	Yanti Nurmalasari, S.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
a8f57ce5-5309-4bae-9ddc-14b95adc2efe	GSMADKP080	$2a$06$cyRlelv6GLaqaZUbk6ehLeE96Wj2mFfHnzT2SjTNNlnfVzevqkT7q	Yogi Ginanjar Jayagiri, M.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
3a263307-b670-48d4-b7cd-40e15af503a7	GSMADKP081	$2a$06$Wb/7dnxfHuLR7YtPyzOaue6siRtFgVkAZjR1xo.MbWEbLqs9TkOra	Yudi Agus Fauziansyah, M.Pd.	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
378311a3-3e62-466a-afcd-ef968b9106fa	GSMADKP082	$2a$06$EYsZukfz88Hr9uxwGN/Br./M4XXFghRXSyFB6lyvE/q6829.SLqoC	Yulianto, S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
d47b0961-2792-42ad-a8c4-f02e2ba4b811	GSMADKP083	$2a$06$Ao9Y88KXFl2swSJmhQNZZekvFBBkyGpJ.trRbZDYG9zK2yjCUE6k2	Zaenal Mutakin, ST	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
d3f75cb1-cbd4-4476-97af-8db397590c00	GSMADKP010	$2a$06$LhVQj0srZygSo01FmEYTouavZEflf8dQU2AUbrnyh6tigWxSkcC/y	Annisa Maryam S.Pd	1	\N	\N	Y	2025-07-16 00:58:06.782619	\N	\N	\N	\N
229cba0f-9cb9-45eb-bc37-bdbda8dab526	GSMADKP001	$2y$10$pTzDNQ6B0zTty4DYhIhgcusJoLQzcR/9xfuVpLJ4K7wSV5LkM6z7.	Raihanza Yo	1	\N	\N	\N	2025-07-16 01:12:27.915031	2025-07-16 01:18:26	admin	admin	\N
dd270142-7e46-44fd-b723-a049930d347a	242510073	$2a$06$V4UgaGbT6BaLCdbGvAqOBOifh/5EIFHAAyqa14ll4MZnZaskCy2va	ABDUL BASYITH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1774b63b-e45c-4334-af2a-547bdef80b0a	242510397	$2a$06$vA3JYlgfTlgFce283/sNUOsW5cTrORlGK/SvvFQIapf0.pMKGdYCe	AHMAD FAUZAN AZMI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e0fe2463-63fa-4aeb-be18-f24adb78ae57	242510362	$2a$06$tjV2eLjEW4qclCdk2EL34eHBsmRBDrBlsdnP62ou0F7WIwIVCvO.m	ALLIF RISKI MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
59c90494-9598-4091-8ce8-bcf4d14925c5	242510114	$2a$06$rPeY1AgvgtU.uYvhR4hB3.G2ansKCBjf3q/dVZl0UNm9ePCU0YUEO	AUFAL MAROM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e069b233-ce61-467a-aa41-c3b43e5bbc3f	242510115	$2a$06$h0/GbfXGmZfSUo3a/Lc5XO7n8PdCFAh5bJannS.u3ahqr9ikNbSgu	AYUNITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3c0647e8-6552-45b0-8a53-e73f80711400	242510258	$2a$06$lOAfcSdY67eTSrgOn6BOP.T/8fYjMyqRfAQGzOt9.SBI/cvYvGibO	BAGUS YUDA ADITIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c9f05d39-8007-403b-9065-6d9e6c7cc2ef	242510116	$2a$06$QeNpZinpFbLbIH9BOcT17uFiAA8Sa3PvUsgRL4KzO5SH613swPIP2	CINTARA NURHANIPAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e495b438-f57f-40f6-a181-1484fcbd9db6	242510045	$2a$06$ZwNUg3KS6vCXYr1fXUP2MOKfdhOHMDb/D3L.JfZ.JhfEswWZHeCAO	DEDEN WINDU MARDIKA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
683312b7-147e-4f3a-b945-4df5597c0a37	242510226	$2a$06$rPSwEhFfccB7xORuz28/xOAeBRIpncX1y4YyKG.Vf.gSAalXUtOOq	DINI WAHYUNI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1eecfd86-1d20-41a7-bd2b-fa82f9842f6d	242510083	$2a$06$1pJa6b6lPH0Bkfhr8bwtXOPjrPPDMeVq/pfIHBnDhPMlQsJDWjOJ6	EVA ADITYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4a0a41ae-bcaa-40e8-b1f8-bcf4395f7c2f	242510048	$2a$06$h97puw/oyARUlFpXx6Fk8.wm1aiWF0DMq4gIGgmItMkfpYB.jp/qW	EVAN ARDIANSSA DAISMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
20135351-79fb-4959-bc34-72e94ce55d0d	242510085	$2a$06$Jl0eP13Ge7GQtw3Rk0e31ORLo8yc7suQe3em75tpSLxWqtwKWxisW	GEVISA AGNIE QWEEZEL AZELALITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cb7c2160-af19-4954-a43b-40cbe9f0840c	242510014	$2a$06$joyJBjsZQF4OWoPiHeMsIuz/lj7Cl9Tf7NzYBB6O.gloijbl7t9n.	GIEFRIE TRI MULIA APRIANSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6ab6e203-c41e-479d-9a7a-8072f769c92c	252611	$2a$06$FAlrX8Ad9UXV7PZ7wWmG.e6l1NWnp/fM9CrWlc7qOSAAWFXdlT1yK	HAWA RIZQINA SHOLIHA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
049ba05d-b694-452e-9c4d-67519d8e1c05	242510266	$2a$06$QjvMFqOV/MVjNRtE54W8MOAMOedgM1VGatCj4Ek1tf2PkUVnSyQIq	HAYKAL RIDJO PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
77cdb5a6-640d-4ef3-805a-f6bdbb1d304b	242510195	$2a$06$wtaE/BtcNfm4mOpeMcOsnOuuSQYxn88u/GV0rt7.pe99t/l8MQ8b6	JIHAN SYIFA TUSSA'DIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
bd2718e8-36ef-4ebe-b531-134604f2498c	242510232	$2a$06$6Ksx10XT9Z/k85G7wb1TrevoaFN9dcwthENRUtbzdBf4DKFTNkFx.	LINDA RAHAYU	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
31777d07-d80c-4d22-bbe1-08735ec52bb6	242510181	$2a$06$G/l.xfCP7utUbwDaVeeHMuIcdNpcPKqTpRJV6Ak4m0wxJF98u2GNu	ADHI PIRDAUS	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
15fd644e-3d64-4c16-b80b-fdbd89db837b	242510183	$2a$06$8vj1zyl0N.Josa9V3HlibOTA/gpF33p8y20XVNpV1ySUXOzYDxeDS	AKHMAD FERIYANSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2b6f50b7-f045-4c5e-af91-64799ee7b996	242510041	$2a$06$7NZhLAl8ZBIAww9X1yPCSuqage1v69Ad7Vmwu34cHU8URkIvoGhnW	ARIEF ABDULLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9b5ae602-7358-4418-9a41-0686682b3f8a	242510365	$2a$06$fREi3D.wPQ3CYDY2.DtFEeJDDsgN2eZ/a29rJXXhcdgiN8C60AR..	AURA ZAHRA KIRANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a5dd1f07-4b72-49e8-8ec0-483b96413f1b	242510331	$2a$06$Sgy9802.eyJxkLYqOxJ0Vu3slh87eodhotYO2jTrbELfZ62ta0Jsq	CAHYA NINGRUM SUGHESTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4833f14d-5c01-4dc0-99b6-d40357cdcf4a	242510367	$2a$06$NgCDTUlL6rAHFklGWw/ZgOISNI55jIO2pLbrWYdYnWG1JBGo2hofW	DAFA ALMER DZAKY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b10ae3d4-3d55-4f12-b556-0a4dd3218c1c	242510404	$2a$06$LjnliXh9n5aSZUFz/nCnFerCh.c6AbNxMm7v/F.AYnQ2rCNFIWPPa	DEWI SYILVA ANGGRAENI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7f85db28-7250-4f80-a218-8dcdf90ad85a	242510297	$2a$06$8oMrGP6AKVFhtnyQ4DPp4e80QKjJPyVnUbJEY/KAYbsz/rQBo18Kq	DIMAS AGUNG ABIMANYU	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d5001288-561d-40b6-9686-931627fb8543	242510406	$2a$06$tpm5G/Z/TI3EFrw.XwgLG.tCE//oSanSDSPjRr.yx4PJHH/5uYmBi	ELGA HALISKIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3c2a7072-1745-4ba3-b016-dde30bb9936a	242510191	$2a$06$bESANNG0AiOZQbQcbRQc4um.OzlIskyk6V6A21ruDcNtyX49Gu9Qy	FADILA ANA BAWIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2805d907-540e-4cdc-9a6b-23c3252fb2f8	242510228	$2a$06$JhyyQSd1MfslXeJ1W6FgXegWrUudOgiKC5c/xCScUZRsjMFBdexHa	FARUQ ARSALAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8ebf02bf-a83c-45ed-ab37-18780d9b740a	242510233	$2a$06$BPw6L.Jo7KskI8TV5AMMp.usIZIh84T2tSLqoToUBZ6b0cZD1LVCu	LUKMAN NUR ROKHIM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f2d742e7-6373-4ef5-b9ee-584bcbd94fde	242510198	$2a$06$O4VELqo..kVOOPy03GtXC.4OXvIPLaVAF9.YMlSSy1upPxIOl6lN.	MEILIA HERMAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
65eb9a23-180d-4abd-92fa-0de776b303ee	242510165	$2a$06$XywUvpDOZOQaMLhmCpzga.quTg/.FaCLLC6q4OsOrpvlOGXjpqKLS	MUHAMAD ARIF MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
524e3688-a50a-4787-bc98-136486c3e56f	242510128	$2a$06$.08EbvD2/zh5fcrO36pmcODixUtOqk/xy5hj66BRKtLvzDhqdcP4C	MUHAMAD IMAM SUBKHI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
36c0d8b0-f14a-4860-8e63-6ad7f8c9626d	242510022	$2a$06$CHLCoXqQmwel64SjO9tVJuy2xvbdgYE6e.ZOAfpd4nfmKY//GQT9a	MUHAMAD TEGUH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
66079df5-79ff-4896-aa4d-cd2685dd6313	242510023	$2a$06$zA/fLGgdjmaecErVMYINOu8Tr6WHz6Kh8ya2VU7oHVGvRxMon.LDq	MUHAMMAD RIZKINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3648333b-2651-4592-99ae-60ee5caa50fe	242510204	$2a$06$qngmd/yyBywA0rUERR6t6O1olKeO17TEgmzeTfiKILLefJ8iPo3sW	NOVITA SARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0f8e6455-6900-445b-b159-25b69fc9db04	242510277	$2a$06$6D/5atHecJJNVq16clHH7ejIiQVgN8oYBARYpBMT6ARrIW461awMG	PUTRI AYU YULIANINGSIH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
de3086be-ed02-474d-9fe4-90bc5cdabc8e	242510385	$2a$06$7m/qXcU.r6hHj2GP2W.C..bIWc3jZJ47qSiHOO5oFsXUkwESycD/G	PUTUH ARIFIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8413bf0a-8463-451d-a43f-9478d93b7ba9	242510175	$2a$06$koLZZPRf2S8ZefJY6bN9eOnfV6L4wxMCVPL7RjMNnDcv2Pme9.hT2	RAHMA FADILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3d249e52-ebfd-419c-be64-1d13fcaa6c68	242510278	$2a$06$mWq01tLOE/sj0MYmuPu/WuN8e5gyZfyWj4c0wQWa7Y53b1PYMPWRS	RANANDA ANGKATA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2b058a70-a324-4508-a63c-224040aa7a3c	242510208	$2a$06$HzeAd/M1yJFObZKVl53k/.ZIGQXnN94MVGCTHywrGzRZzEnkjc4Km	RIDWANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
22f2b5e9-0216-43e8-abec-a2eb22cb7a16	242510388	$2a$06$W0eeZWJ1e.6syOH5671Z0OEkpzLkCkpZatisrmiAn4ediCt7qv/c2	RISKA AULIA WATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
503160ae-6194-4010-ad5b-4c1cd430b93c	242510389	$2a$06$h6Tq5s.mL4YoVUpKbB7FyOJSZps21mHceIFwrwuBBauWNc9tenH5i	SADAM SINATHRYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1e962dd6-47f1-4c1d-a7aa-4f45b62e0da9	242510390	$2a$06$E/G0MXpiWY7QwjFAU/v64.ue3ylpZIUievJ9S7M9jQMLEUE48EEb.	SALMA ALMAGINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
707d3d9c-8684-4ece-a1a6-e2617a530ac9	242510319	$2a$06$iG0HZnHFrN4Mt/QChI7RZe0SLeSEVno9TWUjo4VdzuSG1trBWNK72	SIFA AULIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
38b71f8c-d566-45bf-b54d-d66dfc7bec58	242510107	$2a$06$RbE8lpsBeXqrrClA.oUGUuJNdLWa5Z2VokT4S62xba4HOeNYDw.Pq	TUTI ALWIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0e429723-d9f2-4212-a05d-906a26bc875b	242510252	$2a$06$CBMHHl01wa8ItTRWwUjqlO/7Y0Xyxz6xwEm1l0Zc6uMsqVS7uSz7u	ZAHARA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
376ef2a8-32fb-4d2e-a079-0efa3eca150e	242510095	$2a$06$g99aN1O5yftpLJWDE.EUbeM6MPz0wcMUy6YgJhuUN5BtMgS9xsiTu	NABILA ZAHARA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3d69e340-4749-447d-bc04-c6cff4307b2e	242510109	$2a$06$y4h4LNEXWzT8uWELmHW2TuTJ/cF7nFfksxoY3QA7iOpq1SkGcUXlO	ABDUL KAFI NANDES	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5614f881-2ae4-4e89-a1a0-a3f7ed8f9a4e	242510038	$2a$06$ZjqyGXOn4FyN6WMUOywz7.H/lf30qOq.Idzt4Yj/wh3Jzp5qiE2FW	ADE NURSYIFAA'	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2af649eb-ef5c-4c52-acbf-55dd789352fa	242510399	$2a$06$fy7IvsrT9xFvft/LF3gL.ewVkIoLnZO7vWRzcJMBo5K/Y0T3rcY52	ANDIKA DWI GUNAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
357c89e2-3dfa-42c8-822a-48f5c14fb64e	242510149	$2a$06$GRPDkgcUWiAzwKKKNxV.Zu/DYoS5lXYHztWMoqatiEsmEUD/RfyLC	AUFI FILLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9a182b60-df89-41ad-ac1a-d94386af2ced	242510294	$2a$06$6QZ9vL3FuYfcKbmAsOsod.YkaB8SeWUeB5a4qkaDf8b/3.XCo2B4y	BANYU ANANDA PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
47f49c1e-006a-4735-b0e0-b0d25bd97439	242510259	$2a$06$ycSpB.uja5CNO9SHj1reRus7tMEuRV7rULYUJE3UUCckBufY3U8F6	BILKIS ILMIATUS SHOLEHAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
481a66ca-981e-4505-9fcc-0b707218176b	242510188	$2a$06$rFie0CjEcsnPTKrITFuVQuZXnx3ZZocQ4QCEsD.v1mm64Y4XHjLIW	DAIVA ISVANATUN AZKA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8065b512-4a87-4a4b-a428-d2cc074f28fa	242510154	$2a$06$dPaZ9iT1jMkVbx4esFvbeeSrOrCnFmG9Q2oaYmUN3L2JmJRzaAZnG	DEZAN RAFFI ADZIKRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cf9216b1-5296-4c8c-aa90-22622fe19f9d	242510262	$2a$06$KmVWUdnAoJVa7kOFcWo5vuinnOvo4pXi0UD423SwWEDqPhlJmQAgm	DLIYA'NAJMAH FAHDIYANA RAMADHANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b001d9ac-1c16-4e68-ba47-7c5a532c5840	242510119	$2a$06$VwYlhPLR/fGsl1rPmyoS9.cuEugc49pLjEK1wN3wqpvRsYiMdJ31q	EVI RAHMAWATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0ac15efe-4dd5-47c6-9084-93efaf3efd79	242510084	$2a$06$LafeAGRTi1Q2j2zI/JID2.zFm0b.7TSu/DXSgz/7tUnzkEFdcW9la	FAHRI ABAS	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
dc72b9a2-5c1f-4366-a61d-ffaf576e677f	242510050	$2a$06$3hJ7hYvDitgucjM6lBoNMe.wetYzxLkEN.p3clRbb1M6.B/EQv/8O	HAFIZ MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
59242220-c9b1-40a6-a631-f949ea7efc2b	242510265	$2a$06$WFgOGgQs9Xi8SVQOrZMOx.DBVAiwaVhfmhZwbSWhCAaDFyCF1b6Yy	HAWA NABIL TRI NANDIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
24e81168-1b55-45bc-99d9-9cfbb113f773	242510337	$2a$06$l9iIkfibwaih6vW6/jPmHuuYtf9B.6tiEspBN.644IWBt5/IvAei2	HILMI MAULANA ISHAQ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3da2d344-5de5-4581-81cb-6b7f446714e3	242510267	$2a$06$JNpsVfVWB0b1RiLjcwTfL.QhAMZJ9YTSrDBBmg4EMhA.c9YOiiTlC	KAYSHA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b8684db9-6bc5-4ad0-ac05-dc9fd878ad2d	242510269	$2a$06$uWYJ6WD5Cp5zlENkEmRa/OHejnJND27wT1LN.fa4O5lyZs5/LHXPC	LUKMANUL HAKIM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a1b09588-6e41-4c33-8339-b20437a83271	242510304	$2a$06$iUgQmyl0e0el8qKmLZ9wueCiuECkB4oZHWDiwDiC9eJ7QSONc6Omu	LULAN APRILLIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
70471d9c-912d-4938-9f32-b85c8a11e120	242510234	$2a$06$VZbi/nPV2KqtaGzXvh.fF.PijrzK.aKfD9mglRCeSpOKcJspfpvO6	MEKA WARDANA PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e99f08fb-9ba6-43b9-99a5-7f865e14c9e3	242510307	$2a$06$SF/NiwUtbthZdJacwCvXJeYd1nM9rcWYb1xps4YWtd9fvl1IwgRm6	MUHAMAD DAFFA FIRDAUS	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
dc601cba-8fee-4ac1-a886-4f412a2817dc	242510166	$2a$06$adZShnZALkNZiSmPnY/OauyUFvoTP0i5/I0t7n472iKReRVgQ183G	MUHAMAD MAHER AFRIANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
19d25eb6-6c5b-492a-962f-b3ee15b86407	242510129	$2a$06$4AYDk/tylSFDFbuAVzf3CeYlBgoaU/7IcdMsyUgGYcETA1WPVuMjy	MUHAMMAD BAGUS ALFIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6aa5bfa9-bd1b-489d-9278-2c2916cb81c0	242510417	$2a$06$m011Ur9axp0Jxj6Ujw7Na.rx/c0kmHBL2h0B0WYK2SJ8NNs/ZnjVG	MUHAMMAD RIZAL ARRIZQIE	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f7d870f0-1453-41aa-8447-13aba8b0e1b1	242510058	$2a$06$u64b2bT/YUZSEUir/nUTcuvcd4xfmOtzIIvDvl4vXDm5VuPZWpQlm	MUHAMMAD SHOHIBUL ANDRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c2a75e80-ecde-4e34-8dce-496fae9ab40d	242510203	$2a$06$bIiFtWbCWM8zXjgEgpJHne25W46FrVgpRyf3MB2JKiMYauo0GvuVS	NAHWA QURROTA A'YUNN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d3448064-edeb-43d3-9337-b5d01a98c07f	242510347	$2a$06$.K9kdLXLWdED0MiDT/ubVeGbfwc1pG.f5AYzk8WmeRtzHjcHaXlYW	NURHALISAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
92170ac6-93cd-4649-a9fd-9e2f5f02b32e	242510313	$2a$06$c.qwsXusu3WAcaTDME3gseEvshWEM01prk.X0e5WmnczRCjdSFM7e	PUTRI BUNGA MARBEL	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c7c14d3b-0c44-4560-adcf-7ca4b3fefab4	242510028	$2a$06$BsOpQXB6u8NLdHaeJT1NH.qjMj6pd8lEbr/XxxDJzVIFkpJuO1bAi	RADEN RIZKY ARHAM FIRDAUS	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c7a29a79-4316-42be-a0a9-50493dcf017d	242510314	$2a$06$hDWXvVJJC2wRkocZgq.pNu5GbZjvovcDBC0KezTwC.dsQoWmR9jce	RANDI MAULANA HAPIDZ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4c0293aa-c6ac-4630-b2f9-31b7dc534165	242510243	$2a$06$itzHgqV0AskZnhlGta9Tc.DabkZN6pICP.5iFmpk7hXS4ZHlUTidG	RAYA AGISTIA ANJANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
420f0a56-1034-45dc-8be2-701feaea2d2a	242510244	$2a$06$5KWV6xS2hRSZPmQqClQSqOjORDvNfCYhOy1dPrEUhVryo76PRS2EC	RIFKI ANWAR MUSADAD	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
58e1510a-72d2-44a0-b6ec-54b3714cd223	242510031	$2a$06$m1rxaWhvFhoHZ.oiaZ2aJe80fQbP5pRplrDlEvjdTHSVsOdhcbRZ2	RIYANA ALFARIZI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ad8d2343-d763-440f-a3c4-f1b0ce2be1b0	242510391	$2a$06$Qg75nH3UzGtBLSlgxpze8eWtU5QdKe./JvC5PF93mtBK60VbfHq.i	SINDY NOVIANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2a5542ea-03ca-4775-99ca-718ebb5252d3	242510106	$2a$06$FfULXzeXztMCMPypzptBrO1KmrifM45Hho.MuesR1Cg2Vd0OEWRSK	SYIFA AMANDA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
21222604-712d-491b-addf-9a3078edf52d	242510180	$2a$06$ApsYL1DWEyc72WJ.piovA.VmH8tJjTxC8xKXXWYHMrX2WnFvEFkMC	TAFFAKUR RATU	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fa0cfd96-88c6-45af-9fb9-03100a9330d9	242510251	$2a$06$Ht/zP0iK6v2oIIlmt8tNVuFathdlQh.BLXzrZrjzonwoMjQP5F7EG	VEMMY SHOLIHATUL HAQ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5c780bae-7e23-409a-913c-ada2ec474e34	242510360	$2a$06$GI6/qcZtM5E33qTIjyFvtuQ08iBW6JyrcPUo93MNl/TadB8Ok.5ya	ZAHRA SALSABILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
38487573-e999-431b-9125-e68f1d2c92d0	242510145	$2a$06$guw8BJlLi4MEn//6bmuMh.K2v1AVBTHZpy1W91mUlBodzfD6jx.MC	ABDUL KHALIM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
673e45ef-c54b-4ba8-b91e-0357a3b56847	242510147	$2a$06$sRV1dpnSG0birTcr2F8GzulSXEldcNt6u.XQd7mshXNpbXshmFKTC	AKBAR MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3d098a8d-2c86-4598-8bf3-f424b7a6e084	242510291	$2a$06$Txr/AwBZLAxX73spPbrO3ed.EUoKhr.qmhXZQt789pUUxVsUI.rEe	ALIFATUS SAHLA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
23800bb9-4b9c-4af3-8ddd-2a374dbdff8f	242510005	$2a$06$hpfkGJsotFA0tz0gaBBDz.yACuUyCgVaKVVkof3IWAKH8OFEaRs1i	ANDIKA RIZKI MULYANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
67db50f0-d0cf-4c7c-84ac-f147caa75127	242510220	$2a$06$4cGM9dBnJ7Z8NrqrxBgi1ue9rR857XaCJKVPhhVZJrhSAEb5ybpLa	ANGGITA PUTRI SYAHRANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
17dd55fc-34fa-490d-9eb9-0ff51895ab1a	242510329	$2a$06$QOvAYb0wnHp9jCVAPfXXs.hmaFDxyf.3HnEsoCuUq2qwkIAX6guL2	AURA DIEWANTY MAHARANY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5b6bc5a7-bbf6-45fc-af1e-97ae826d7e04	242510330	$2a$06$E/vAI9sF7uYcCO8cHet/zO/KHzIjrq5zAyF3lrONXXdTPfmqnB5CK	BIMA MUSOFA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ad7e282e-2830-42b9-b93c-995495f5b402	242510152	$2a$06$dk2N4iW4W6MMT3aZV9z4T.15kRIDLR6zZuIx1Poo5ELmeuLymJPfm	CAHYA INDAH LESTARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
60092d31-782c-4783-8529-81f4bdd5e8af	242510296	$2a$06$UiKZj/C9Dlvun.kCNaIyle8hRVn5EmJERw4vhccFqUVNMJZmx6y96	DEA NOVITA KURNIA DEWI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5623e95f-84dc-4a10-9b08-b3fba99bf1d8	242510225	$2a$06$Pft3gFN1zkyh5Ry7FbOWPuuD/jwHpMP9Bv7WivgOAyAw2XG3RXx1i	DICKI SHASSAY SINAR PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9693cb2a-c181-43c9-817f-0d528c8d8649	242510298	$2a$06$hEvMGan9xLkYyLEuh4KlW.bKh8xtaa3FsSTzrMyuEIAdsZxs9Ziom	EGIS DWI APRILIA HASAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
57f01fcb-76fe-44c7-a38c-c5b0b6944456	242510156	$2a$06$x3ay6y7AgvJDOM3ZqVOKwuuA9/UdiOd3eyxI2xlURt9Z7SI6iFIh6	EVINSA NUR SAHRUDIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e70f0394-58de-4244-be00-4567a92658e7	242510192	$2a$06$EfaVZtf/E5yRYbPqNg8.KuCBsfzL/P5bEi6Zp.6Omvt4xkYLkZ4ma	FARID PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
54013fac-5b55-40fb-9b61-b5e4e46c8623	242510122	$2a$06$uFpfdegRM/OjFHoPoFtlY.3I/AzuXs0qLI0.JgNbs9Xr.OJQxGKNm	HAIDAR LUTHFI KHOLILULLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
70c6e633-fa58-4cec-866b-8193f6bb3120	242510301	$2a$06$CN1SKmDPuCgFBaG3IJvx0ekq3To9asv6qZvmSMEmZVly0eZXSQL/O	HIKMATUL ALIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5f0c1cc8-4db7-4167-8410-dd4b58c9aa22	242510373	$2a$06$8Tsya5JNZd3Wy5D1NlApt.MAH5aX1Vcx1r6J0bjXcaQzVZU.U/fIa	IBNU SHINA AL-FARIZY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
04cf7c4d-bb89-4e88-8ab5-45331ecbfa1d	242510339	$2a$06$9zkSkZEdSIYvUX3EBqF1kuP5I05C9HFqFG7Z8w3yNvYMfj2RSSCra	KEYLA PUTRI ADHISTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
255fc8f3-4a82-4d76-86fd-618be106ab4d	242510341	$2a$06$JqE5oVDCZwoMrro1umvbteYJH1JPSjuaJ7GQ4.OKikVQ.U6NC/7vW	M. RIDHO ALFAJRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b8c6eb42-964f-4c55-8390-a07bbaa1b137	242510377	$2a$06$5TrWHJMzMEmPECb.ipVht.1quNfHMFDV.WXjUS1ALbS603bkokjiC	MADINAH NUR MULTAZAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4a266ed8-ce32-4ff2-81ff-fdc349f29b5f	242510270	$2a$06$ZkX8kck5NahFr7TXRmVHu.la415ACAF42i0L42TaLfv8q84ADIuJq	MELITA RAHMAYANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
082d8f8d-112b-466e-a652-7203f67b69b0	242510343	$2a$06$KOuUvh2FwpIlhzpVpPxccO5oIlogZhoG2Iuhpegb9K46GXfcQLLr.	MUHAMAD DIKA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b4f61984-0ca9-46ad-9c1a-80626fa0fd45	242510167	$2a$06$2jr86C/9CbTSSqawistzFOCJ0DHinPgyXf1XxajZwDyCbuJo7eWRa	MUHAMAD NAZRIL IBRAHIM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1e39c246-332a-433b-8466-bd9c568699dd	242510168	$2a$06$8bROvUNmpGW6vZc0yP.KVeJSCYXepy481QtZOP3Bref9qO3gTJWS6	MUHAMMAD FAKHRI HABIBUR ROHMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
487546ba-7222-437b-8b57-805d5cb8be1e	242510094	$2a$06$f/.fttq9SnGKkh8SDDzhdehLMpx4yt3/biQCu/uNPhFxF3tvIoCFm	MUHAMMAD ZAINAL AKBAR	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e125c958-64cd-4dd3-9fa4-de6dfb43d173	242510238	$2a$06$rXZKchft5rfJ50g73DF1Helk/JOVMb1hVq1mMaR4Xx/ZFLnhUlFEO	NAILA RISMAY CHIKA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
eda9208d-ead5-4624-9d85-001f8de90efe	242510383	$2a$06$ZVDQXsLU9s86ZRjfglYxtOHyuepS1YRo3HGOgaGEF9FAtZ1emQbdu	NURLATIFAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
32277b06-2ba5-4216-af60-3580af206b55	242510349	$2a$06$pjLQD5AkOr7ZK1.18No3l.oUUNVlUvQG9ibW952GQRGHNEFSA585G	PUTRI DIANA QAMARIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f8714b6a-5d78-46c1-aa54-a278a64d4627	242510063	$2a$06$uRT1uTNrj5Z420KJBRARQuymShDf0YrYA.RVrks88xY0z3dWFH8Ci	RADIT FEBRIANSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2b58a350-228a-4c6e-9a27-8116b9ef7bb3	242510386	$2a$06$QS6l5ILAyII4GHJM34Afp.P8n3bvs531OY2aWo2jsAxnc1uq3WPza	RANGGA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a60d284f-05c5-4750-b747-4c2ebe1cba74	242510315	$2a$06$sn7.EUiaOfq8tjib.kJUregXFaSdcKz15OpdF43G3cNTVMPBzP4La	REHANA FAUZAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
25b51cac-627a-4d45-bd02-e120374aa09e	242510280	$2a$06$oy2sA0VIOmsYM5H0E2BPEO8Z2nbylYEfEUAtuO4NFUfCw6dCzkuqe	RIFQI AKHMADI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a5c3394a-29be-49fc-942b-b7c8fd41b7c8	242510066	$2a$06$oq7mmpw13lOrbtZ7bSJ1JOr4r9yIWkX/.PwSuZaAHjcSl1XGJwNfy	ROKHAMA PUTRI PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
706c6d6b-ccb8-43a2-82a3-f88427a61593	242510426	$2a$06$7krWb9TuR1mYK4E15Quh/e3vwfrNXtx9QmplNlVCnHCXyc/Fg9DI6	SALSABILA RAMADANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
221cb23a-399a-43cf-8998-8385096585e4	242510034	$2a$06$n3a8gCvah/laujFLoRsq8uBvXQQSgOykrYTl24uU3QVTdPL6whhRK	SITI AISYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b65a96c5-5f21-44d4-8c28-f063b110216c	242510214	$2a$06$G07S7OsmEEv4trtA.5AP9eT9yDaVM2SUv4GPdduq.nXDjhPG99gYS	TASYA PUTRI APRILIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0f945af9-833e-4f9f-b1d2-0306dcde1cfe	242510287	$2a$06$UoFRtJWZPUZDiL.Aa.gALuy82JdgUQ34vju3KNy8P12dRIZUrjmOS	VIRGIN RAMADANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8195eb81-46cc-483a-a8e7-6f72c4c814e5	242510159	$2a$06$o7TWQ9nsm73YE2liJyLDTu2WNduAqZuyVb35pCIaeMQVknQvwFPWi	HALIM LUTFI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
97912574-bbe9-4ec0-8b66-c7e4e3f686bb	242510374	$2a$06$f6JL7TbnPXBsK4jxkCQ2nOOOsGZ8sXRrUlRQPnldd9JdmrnLnnQYm	IIM DAIMAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9bbd3e06-5d1b-47c1-b6d6-aaf456cfcd30	242510016	$2a$06$VERUSHly4N19mBG3a35mR.QQRsstVxlx5zajXAfBjavDgFyrMm3XS	IRAWAN SANTOSO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5cb50607-dca5-4ac7-91e4-891b0a39e1fd	242510411	$2a$06$KZOn6WmuJ4cGeShpTQjyP.MuiRS9WBuOz56OMBBCRfBXth4yLx7iK	KEYSHA FADILLA ANGGRIAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cbded270-0f8a-4540-a16c-3478b8b6cbd0	242510054	$2a$06$s.a8fJsEfJpHPuvktch7D.0Iw2zXwBg3xYHG2tHc0q941hxwq0ma.	MARWATUS SABILLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2f2706a7-6a48-4760-938f-305adcdbe81e	242510306	$2a$06$.JoYNF9r0yFD8Cw9XOKEauHryYJnc8mwj36eJ4YE7kvnyMqXkKPay	MELIYANA ASTUTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8674576d-c114-47b2-be7b-7c3009837b92	242510414	$2a$06$SAePa2NcmcFLYfj2Q0Vq/O7R904MmA7T1hG/4SVcIKA0asdFjNA0S	MOCHAMAD RIFQI FAUZI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
25418b27-67ef-451d-bf56-4004057f6517	242510379	$2a$06$ogcl8.ly8LGuJH1l/XMG9.rzIt6AaY0yNhDlDL5krGDOtrWyGhF4u	MUHAMAD DIMAS	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3502f46d-48ea-4031-97bb-90ddb50d5a87	242510200	$2a$06$0suO4ssmpu/wV29HASgBv.fMTFL253PLrQIZ4eNP/yaQtb8jrzkqq	MUHAMAD RAMADHAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c44c5308-fdb6-4543-bfa4-ba85f1b0fab1	242510237	$2a$06$vmfPQM.Rvgnd8tpeGpvao.mYJBBMXeD6pmfcLAxBY/MB.cXrPiwLW	MUHAMMAD FAQIH IBROHIM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c01d5e54-6120-4a33-8d41-0e448a7c32d5	242510169	$2a$06$CZdOqRXmiO/wOWezctISLugSNMhpCrmNyWauDEOglqAhPPKBober6	MUKHAMAD FAHRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
17c48be5-fb46-4b3d-acfa-87018567eafb	242510418	$2a$06$b8PXFOhk9ECNGHnD5YoRbelXsAlOydQJGsQPUML5CJgMGKo.Byfbm	NAYLA FAIZAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b4d2e99d-7b45-4bed-b123-8ad65c2f5b67	242510097	$2a$06$DwZ.Mm/44YqG6DzX.HoRr.erif3bHjUhUgdSslNtJf.68DpHnJ98K	OPI FARHATUL FAJRIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
08955657-530e-40a0-acb5-9a943e552da2	242510420	$2a$06$JgfPgqhsVZRG/ibkt8UDmevYj4pJVF3Uaz7e7zLGLvOjZTKiel4l2	PUTRI NOV ALITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7cbff489-9b97-44b5-87c3-011afe757c4a	242510174	$2a$06$10ei7Sst3tBi6WtLzm6aZOykix4JMDPH6Pyzgzxd7MdNFwYxbs5em	RAFIQ WARDIYAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
75780f90-a65f-49d1-bce4-d4e5b1215526	242510029	$2a$06$/oL/FBKILFNJvQko82Hhx.Gal.LAQ75SakgBKxYPAkqaURNFEgx2O	REFI APRIANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
abf2147f-e559-4ed4-9df3-b9bdcd249335	242510351	$2a$06$4fDBmfMFJzOw25aIeBJ8v.6P0/odWDjbXfPXuYAAioHvQT9zDu6Qy	RENA AGUSTINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
030b0755-41af-4e95-a333-597505426afa	242510317	$2a$06$jgQd0DN127kw4uQFZ5x.3.l.IRALyui75pgENRptGru84qVezyTCG	RIVALDO MEDRIAN AGUSTAF	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a6806ed3-924d-4b57-94ab-142d82bb55e0	242510102	$2a$06$xG7CKULZ3OwVZJj0Vm2RJe3d7D8nxHxyQdwtZ5hRAdUxG7OKb6PFC	ROKHIMI DWI PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2d490350-6dec-4623-8ab5-c13a3514b84d	242510318	$2a$06$h475WTxqYwp4onGfBvlVCeXdtn9LjRrBZB2cqCg9u2mwTuQi2F8n6	SAHARA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9ffc6b8b-b503-43fe-826f-dffe5f5f245d	242510139	$2a$06$3i6sCpbQNXr/DSIBNL3rEOiY.rCNJ3s2nIf6zTQPXC4Memgpp8YlC	SASKIA SAPITRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5cc92ae8-524d-4924-9c18-2d786934da1a	242510069	$2a$06$oz.Ku40oDFhymCb8/I/X3e0kARk2OYyCZkcx8Cz3K2H3G2prpI/OS	SITI ALISAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cd998579-1be7-407f-8304-3b995fd4cee5	242510322	$2a$06$/ITt7rH5Jjx3SOI3OGyLwOSxkvH7V4AygU0cWxca/FLysZ8Wi67Ba	TIARA NURPADILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c0f323d6-cd75-4683-9ebd-9585d4f27edd	242510323	$2a$06$pmcb9Z9vRi7SHjdMoX2gpO9rPSCSFbASnsEAsDQvFcJs0V3MItoxK	WIDI YANAWATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7fe96d28-9a18-4e79-a734-6272128fb208	242510002	$2a$06$W53vV7Aa3Na7bbIc2h/8peBg1gd1aVc/8MiYDi7hzg2qgmIhOfEVO	ADE FHIRENILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a1675ba3-f5cd-441f-a66c-1322f61b183b	242510217	$2a$06$bJLX1SP6kqrkcId7pUjGyuikbA.n.52zrE5xt8KKtTfecSPs595/6	ADITIYA ZIYADY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0e894dac-3f3a-449e-9bcb-42b8becabf79	242510219	$2a$06$0yXMS9EngI8SYHwPH6EBf.HO8ZDpPBDJvjK3xmgE0Dxlzeu5.bAMC	ALDITIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d2408473-bac3-4e12-8266-c20a5e92fb8f	242510364	$2a$06$tqilrmURcYR7BEd05y4PduQBx3Nm.p9HK8MFHjTnLc5.na8B0pAC6	ARLETA CITRA ISLAMI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
531102c0-27e2-4b0f-92be-6b824959b488	242510400	$2a$06$wvWoIaj87E1twzsXZjIUhuXY3Yy3os.wQ13X1RAgFop4b4L4ghkZC	ASSYIFA APRILIANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0a308735-ad87-46d9-b39e-ad09b8bec2ea	242510151	$2a$06$dLOqZoBLgfBQI2DPE1juxeJSc4l9um8woB0oiur0ufL1EkoKXj/lW	BACHTIAR RAMADHAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
58333903-5c4c-4595-b6b2-355380147be3	242510366	$2a$06$I8IeHQcLNGaNN80ernZ5I.cWgzl0oxzci.81oeWwwRuYAu85gRngy	CELSEA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fc7f6e97-fb0f-4555-9100-bfaa96722ff7	242510403	$2a$06$odMMytSxtRnHeTZbp.7bVufQxchLFhYPjheTohysYAKpuo5hfiqx6	DAFA ARIF MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e09e0f00-3ff0-4bb4-a08c-d08f52b0daa2	242510082	$2a$06$cQLG0hZorqXWgcQJD89a4.08ZmtZkjD9ygHb6m3n/5wsPRv7mDvt.	DIANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c7d9d7ce-9048-4e49-b251-82563bdb9db1	242510369	$2a$06$1xKEJ/PqtG9L/tT4.lnDm.BZOfnJdZ79odlGiCJyb0sLozhsbmJWO	DIVA LAYAKUSUMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
54542fd0-077e-41f5-901d-ee78c0de2e40	242510012	$2a$06$Xyc4Ek6qqpmbRb8uHNWCVOzSusgEvg27GplIFOJiz6KpdyjnKUBIm	ELSA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3565a436-a005-48ee-88b3-61db438f8065	242510227	$2a$06$ILdjPAGukV0MF/KzBwsgT.znhB9XX.18OYSH7Te2eUvaNZHGpBMD6	FARIHAH AULIA FITRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3af154d6-12e9-400f-b189-abfd09fa654d	242510299	$2a$06$TVsofnUH1GJne/OJLzp.vu9RHJtQ0jaWENHnf.mBX674SMwpgkVwi	FEBRI MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7e360cc3-b3ba-4323-943c-67c23fda7ea5	242510194	$2a$06$2h2.KS9acMZuBS8oJFm8P.YXor2ld2GOK0mfOv3SI6MsLRErOLBNW	HAMIM SUKHARNA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2753e81f-186e-4a8b-a878-ba745a0dea3a	242510087	$2a$06$EQOx2JP7QrHr/V5C4fl/geg43gAY.ncwGQ5Sh2NimT66G/j./L0Ry	INTAN SAFITRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8810018f-e537-4090-b94b-35b4072113ba	242510124	$2a$06$bTHh9Imvz7lO0uGD78woW.jgZR/EYw5RP4ujc9xMO68U8I1gRTuGa	KHANAN FAJRIAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a1221b56-d595-42a4-a13e-0fc943c942e2	242510089	$2a$06$P67c81ZloP5Ul7jFEerdiOYcPEjfrudh5xCjUOTZ/CCSfzd0GvgwK	KINAYA FAUZIAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
59dd167f-d3f0-4a96-8070-1767a7c55d63	242510126	$2a$06$dKvVsDg6WdhY5YClyeIOHezUTC6YSgnI4kdyR9xsQ7tr/1.WV0YlG	MEGA AULIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1e732dfd-b8ef-40a3-aab5-86c2778cfc97	242510378	$2a$06$ur7DfPWiCTLq4csf3PJ6DeYdw78KqqHJtPmxWBnTpLyQFbGg9sooK	MIA OLIVIA HARTANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8bb643ce-6c1e-4c88-a84b-b60ad30f3b6d	242510055	$2a$06$ZokaWIkHkg1Py.jUR/PDCerv7gQd/IWGN9DqqocOioulLd1B.53Qm	MUH. DIAZ TRI KUSUMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9f06cc3c-9041-4a41-b776-f51a79334602	242510415	$2a$06$2T5tnjCxg4fH6edj15u57O/5sVpBEEYjKzlN88jBmrZwiTIbLWF8O	MUHAMAD FAIDAN AZHARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cf32784c-81ab-4097-8c0c-1152171fc708	242510344	$2a$06$.9vImE1qRCFRMR4RL1jYRejyoONnT/t5Gzb.X3Zw/M86AvdYHVhxO	MUHAMAD RIFQI RAHMANINO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fd5976b9-5589-45f8-a8fe-47acce8565a3	242510345	$2a$06$FnM9hd3SwlrpeM/CI0hDo.C3u.cofNzY5E18sjJO8exyi2t/NdZxe	MUHAMMAD RAFFA ALFARIZI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a114dfb5-a80d-4076-8dac-27e3a84764af	242510202	$2a$06$9npw0SZk/lifCnSyp4Y4FOPWHWgrpxLCJWMOnqeAAGEQfvN62dfSC	NABIL DWI SAPUTRA HAKIM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a1f08ec2-8ea4-42be-8b3a-63ab04fd04a0	242510025	$2a$06$C01zV1fOKRwB9k1bUZgyrus0GlYELd7Zyes7TPvHzBOW1BErHNBY.	NESHEA AMELIA PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e183be36-873b-4941-8052-97014ccb9d84	242510026	$2a$06$yqmEWsI6TSwhf3fEIKckE.0EBNZREcH/uEKqU1IDYCqnPfiSGycwm	NURUL AZKIYA AZ-AZHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
04801056-e6d2-4b1f-ae0c-41b4e23eb98d	242510133	$2a$06$hRbL/reBL.NMDmbPqUaDv.csQww/SkS3iUAG03Wa/sxwQwClpowt2	PITRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7089e796-f9a6-4bc6-a396-7cb7d69ed7fc	242510027	$2a$06$Ha9aNQg845NTrKK3mef7fuoaxlidlVPfAXmyy9u8S8FhZKvdCaQuu	PUTRI RAMDANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
37aa6910-826b-45cb-9149-f2add04c075b	242510207	$2a$06$CkHAz4c0Uy03KYWo3V1/ue5pqJnE9Vb7YgphR5NdaH6yguyYKabne	RAHMAN DANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
723dfaca-4a34-41df-90b0-1d83ee23d4ab	242510064	$2a$06$T2meR6wHzR0jXBpbABWJO.3InxGHIbrcYzKViLClIfqEEc3PqBYEG	RENDI MARTIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e18250ab-4ab5-4e50-baba-2a2fbf205c39	242510101	$2a$06$iCeVsyin9/7RBCThICZijOcy7bFrLRFIaM3N7PwtFvMUw8jGxmZb2	REVI MARISKA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8c20962c-53f0-47bb-9c6e-19a92422bfd1	242510210	$2a$06$0UjZtGyuyAPKua8SbsqN9e4AnCuynzjU8cgEmU8SU4hPOhmx7tpR6	ROSITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2849216b-5e42-4a69-9bf7-948859bad9ab	242510178	$2a$06$AZgUHrtEq/obhaoZl4FRtuuHsvotIp.3UMUcRumpgNgWD/1VV6YSO	SEFIANA IRMADITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
dd6efbef-ea09-4abd-9072-de78a78292a9	242510105	$2a$06$zyLFVmdYjo3z5dSwtvHJXuvaJPKkDYyJ88pMyNcOE31SnfM.HGWNm	SITI ALIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0a62a8fe-406b-4c64-833b-21699c221845	242510429	$2a$06$.ykR54BTsNz2QJZhU9qevuUBsohuA0fjIk1LHkFIvubpFWtl4KpsS	TIAS NAZHWA MAULA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7d5f6949-b61c-444a-9c6f-2a1f887e3ee1	242510394	$2a$06$ylSgwC5coAlgr2OQ3nqew.BI6YDEQReDNL0GDxZvdywszTVEMoqdW	WISMAYA REREN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0366084b-44ac-4ce0-b382-aeeabbc70760	242510253	$2a$06$iKq24WOSAYZ1M8swmxKaH.ngIH5n5grjsTGOZfzhQd7GHhKsLooZS	ADNIN SUGIH HARTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d28e10a0-0a71-4c15-b16d-9f4ffe8a8232	242510327	$2a$06$fdP7TTllWwd.XEx5QmTTIO.q21VplhljYQMFf.yGQMcezQRs01gB.	ALLES SANDRO AXL PIERO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fcb40ea2-d805-4115-bcfb-5e8380373114	242510079	$2a$06$CzE4sWxYCH2BOF9EhCdZiu4hbWQEZe..UDUTSC9ak9ZIxX5jfiHLG	AYU RAMADANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
719a50fd-86b7-4b2b-90a1-9f27e012dfb2	242510223	$2a$06$E/PNlvfATbiQ1V7ilxLK.uNbuT0dsbb1bu0VGB75AJ3QaGFcFGM32	BAGAS TAUFIQURAHMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9631db0e-4054-4b0d-8870-0656402b302b	242510008	$2a$06$A2r5aCqtcyjWemhB6mos9.jjBPW2FcYRI2pg8r.RbknIXz2d9vsDC	CHIKA YULIA NABILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2f9e47ef-cbdb-4388-a131-90fac74da4e9	242510009	$2a$06$iYBgMAuxhymBXgvTWcgYDuMCsjo.iohHOYsfBDtiLJ7u7nKUzIK4y	DAFID	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
36637aad-ced3-4814-8675-a1f8433d188e	242510190	$2a$06$aBGu0huXdT37EVSMP9IrJuBQSXzOkpTqk3k64e3M/G.6vs0vgY2lm	DINI NOVIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
05fbdc7b-645b-4aac-8177-f624ab2fd3b6	242510405	$2a$06$W0/kRpHGE5wf46HF/KfzFeHibWNEM23FgyWx/HbAPOGXaHl4adM5y	EFAN SETIAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ce1fa287-dd1c-449d-ae3e-1d866523c241	242510047	$2a$06$BKWqBr4Uxqd6OkYKW1rcDeyDfCJU8e9eEQ19FuRIq3o/DNnqLFzhy	ERNAWATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d90415f8-c025-403f-824d-e446b51e626d	242510335	$2a$06$Uyh9jp4NULCgp.gFYMOvEO.7ZLx86Ypxi85OkFzNwSHA5HAD2crfa	FERDY FEBBY SAPUTRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ab5266e5-6fab-4ce9-b18b-0dd874c722a0	242510049	$2a$06$m401Js7/UwO22XrIDjeWmOTtawuC5JnbskndK6U3wjpmMg2TSrosK	GALIH PUSPITASARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f3881db4-e7bf-40e4-946c-43ce03a85d1e	242510229	$2a$06$VkUuj0SRHAYKVVcQ9a/Q1OUtS8nx30xGBS5Yle.xbuS7NlwENAoOS	HARLAN SAPUTRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b2ac35c6-69ee-457b-8362-4b5d0f147cac	242510160	$2a$06$chLPKNzMuB11L72Fy8DL5ubB26FiJUKVIow3hnW7rhXm4pQceW22u	ISMA NADIFAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fb9cb7f6-734f-4ce9-9a30-47773faac66a	242510161	$2a$06$VzAos26XfeUiVxLVeuQZx.RkpYP5Q.0Tpi9xJCaOIOklGicT9//lO	LABIB FAWAZ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a860356e-43cc-47f3-86ca-2436d9555f0a	242510162	$2a$06$nmhCV/Xs08s/J.SKD70mNOvlIsZZ5en1wiJv1twSHL7ZZ2zu/B0XK	LARAS FEBRIYANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
17d656fe-a85c-4a0f-94a4-f07e2a89c7ff	242510163	$2a$06$PTQ1Hn3bKpYn96YRVC48h.XbiPRP3u95qNly5K2n0/zp/a7FmgAaq	MEGA PUSPITASARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b956daab-2522-4879-9b78-4469687f8984	242510056	$2a$06$8DXPI9FvErhlGmYAkkox1OVT2AfGgJv5M1VEHP.niyMEPbJZok9FK	MUHAMAD HAKIM SAPUTRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a1518e8a-bec4-4395-b5b6-510327f46c15	242510416	$2a$06$54nNTtsv./fc953.W7tljuqhSe4V8aMXvM950vsYEnUeFHl0WP8pa	MUHAMAD SATRIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e807182f-59f5-45e5-9db0-d8ef8a0c906f	242510381	$2a$06$/mmepOMSN09l4UuxC6gw4uZdnKrutYAXj8HzwpmeKMVc5GAQPjL1C	MUHAMMAD RIFAT MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
27bcd86b-df9e-48d8-abef-97367451e72e	242510024	$2a$06$/ZTY/O0jWDDqPSf3l9.Hv.li1Llirb8Tsu29Z17Rbp2r9qgczhwie	MUNIR ROHIMI S	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4319d045-706a-4c5d-9046-aae040ab47c1	242510171	$2a$06$Ws60pgi1EEx88HppF1bsbOWn0e1rNP4WC2z7mGuUC8QxXGe.fJGGy	NIVI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d2f21b8e-f3a4-402d-83a5-ef51eea421d9	242510205	$2a$06$DJdDik9Reo.y.gn6a/Hp/OB8LhrMXm2.gDhsn/0SjPO2mBbebZrQ2	PUSPITA SARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
dbcb1f7f-554a-4df6-b65c-f0da02f69101	242510348	$2a$06$rdcmsxpTqpUVvW4Z4SZyxeinQRWhekC4s8ZFgPhj.j8apZZwW.2iK	PUTRA RAMADAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
abfef04f-802f-4139-bf90-ea0620314f01	242510098	$2a$06$t6azGoZg6gDpyhQjSsoICuw/wc9tZdR2U6.WCOQvNyVYGi2jZzL..	RACHEL AMANDITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d2555f6d-5387-4224-aa60-62aef87aeefd	242510242	$2a$06$UBd1EPUyr7R2OPpD2jfzPeWgxLIdlYsoW5c4HSyHufLO9flBPT1Aa	RAJWA IGNATIUS SAMUDRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
19b291a0-d990-4933-a5eb-aabc006fe9bc	242510100	$2a$06$MHmh7VXR25.gsra9NpuituNLEfxU5OES6gkFzz3XUAflrd02PMeCC	RENDI MAULANA YUSUF	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e3450215-04c6-417c-be50-91228e586315	242510245	$2a$06$006xT5tiRguNNdhtchUEcOHfGPmclTwnbIOUk/RZD21Dz2IynjiZ.	RIKA ZAHWA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
78c25de1-e07f-46df-9f12-3f14494a7bd1	242510246	$2a$06$UADOTXyOt/VYq1nf2A/CW.7N/YN1bxB7C2QakP5RzNM4vqqAluoPS	SABRINA PRATIWI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1228d3cc-b69c-4d1a-b094-d172bc3bf295	242510211	$2a$06$PqSN9xnzEOlMjK9tMJ00LuetYNtGSTlvNnMbqo6Px50EBhYFRLsXG	SEKAR WULANDARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ea63a45c-959e-44ce-8c4b-1186e785d531	242510068	$2a$06$vnW9oWS.lHVyUgvh2LvvaOVSrg7lqNGBGgFZqmY.2Sz0Nfg8H8yGS	SHIHABUDDIN FASYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
94bbcec1-e851-460d-b2b3-58c6c7cd88d5	242510104	$2a$06$Zdn7kL0zHoAr7WjT5QGgme7TlHmzTkhkQTTuBoTvf5ufLFoGIlrBe	SIGIT ADITIYA PUTRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9099557e-d92e-4137-afb7-69ebe7b60daa	242510356	$2a$06$Sbno9dA2boTFbTUHNv8iHOCh1s9V/AinTxLH2LKaZsihOyuspuwDK	SITI SAFINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a365615b-7f09-4693-a280-5fa79afbe7f9	242510285	$2a$06$R14n3in4.0LRY8ggOP.Sn.d3yzLvNk7XghVHSsnMgojE5DPqWjGBu	SYIFA ADIAYAKSA REJA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
242c78ca-a387-48fb-b6f0-35fac7b070e9	242510071	$2a$06$CDRjGSw3ER79UUxtT.zxTeT4vB2kraO2cH9bvmqlb0hGKEw0DTEOK	TIYA ANDREA KIRANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ecac6d51-1c22-4973-88ef-67088b390788	242510430	$2a$06$jE6L95tIhG4XOYCfCtb07eT.0iKVr3nxkx8OFKpMSHC7aKkWwf7wi	WIYAH SHOLEHATUN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
efa335a8-787f-448f-bb40-064bc08116c7	242510431	$2a$06$plOr6wUyPx9EVAWWSbVQJeenN2uo382xZ7KEKR2d5jXzzvHdP2e/2	YARES MULYANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8aec7f80-c37a-46d9-abda-2ec7a56af574	242510001	$2a$06$a.G5E5VVVeBKKI.zTY9mneollIuFTzws9JaDtTI0tfe8Pzcx4bUOK	ABBIYU DIMITRIES	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
19cd282f-17d2-44c5-ba1b-5c76bed0d7e2	242510074	$2a$06$/cqi3nftRowmPZSXuZ2vX.Q/TSx.W3Zvptldcg831EIkrXgWTvI..	ADE SAFIRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
88b249fb-81ee-46e9-8fde-767582e8f182	242510039	$2a$06$.z36Py5YnXzVGHZRdGUm6udvWSgiBdnMORNw28cYt6u44m5QocWYW	AHMAD MA'RUP YUSUP	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4e57b171-6376-4534-9ea3-95cf47159087	242510111	$2a$06$ktwGChLarEQYesGU70nRfeItlQ3yEPcnai6D8T4R5lkF7vE/0/OFK	AHYAN NABIL ESHAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
97c6b4d7-6441-4d14-819e-6d95b32656c3	242510326	$2a$06$5.HzP59saKTqkyqNaudUp./HOvx56BLFDC2xuanPLzlWEuONgHyxi	ALINZA ALDHAFINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
19c95ca0-6f0e-42b2-b38f-17094354c27e	242510112	$2a$06$wHx8EDRT8NHHvqmuIOnyVO9wrq6w.U2lzyrNFioDzln3EveyEn1Oi	ANGGI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2144b112-eeb4-4317-9f76-53003aebfd76	242510006	$2a$06$TBxmT8GsLfSVNa7NOmaMue61gu9gDk058v1u8YAmgo4LpHpzoWdp6	ASYIFATUL ZANNAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9dc3266a-9135-4905-983c-723811324d57	242510293	$2a$06$enTrqF2/o2z95gFiomq/yOrH..TuvBZRj14/z3NxS41m1t4gR3ewO	AURA AZZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b8c2921c-6575-4be3-89f9-dd99c57c388a	242510295	$2a$06$oO1RTVVGSIlQX/IMJH5A7OFGHh5AZ.CJjIo3jYIObC45IDvcXZLMG	BUNGA DARA ANGGRAENI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
858e4bfe-3201-4ef4-a038-7cd84a44d69a	242510260	$2a$06$.BbFrqYDQGyyG1Bq5OBP9e73InlUx2P1DyxfIs6MS90LjPrm6MrMO	DEA IMUT	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a5000a66-f75c-45a2-9f5d-7a07376547b5	242510081	$2a$06$NyNzWWXfKaUboRXohbcsXeW/LdmQfVpKyitzlthlHg/Ck4U9D29CO	DEVALDO ALFIRANSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a5e72163-a8b1-4070-8132-1f7fcbee3e98	242510155	$2a$06$mGVJTycE0mLQePpRz5p0fOFNe3vgvgnVNX0UfwMh0wv.GqmGUfEwC	DINDA KEISYA WIHAPSARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
35cb63e5-c02e-4d8c-a70b-99c512848621	242510157	$2a$06$qqegRqUe5svZ23bsoBcgYujcURUe7VTw11YRaT0jWCbHP/4SIaJ/G	FARDAN RIFA ANTONI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6c788077-85dc-4760-ba7b-4ad8c787c886	242510372	$2a$06$uuMNSpi6BjF97eqh8qYuZ.OFq3asCAbBAPVVmzyp9uAEocWLC7/cq	FIRDA MAERYTA SARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
175f66fe-7a64-4c28-909e-aefaf887a815	242510409	$2a$06$Tq4sMYsS.DYTApsq2AAh0.w4tkgZUEQk2a5zsu9VmwmDRvVu2V4yS	IMEYLINA AWALIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b31bec6e-44d9-4ff6-aee8-1f766d7d4410	242510410	$2a$06$sUIFgUsjPAw3u11qYIdPx.2vzP9SvVmEZYrBZxxRuReCU6C8ZO5DS	IQWAN RAFIDI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1f6cdf37-3057-45f3-a866-1148a343a570	242510375	$2a$06$BykfQ6o8dt5LoSdK./vEUu7ojkH4O98OedK1ftj0xy4JctsuCuNPS	KEYLLA OKTAVIANI DARMAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9f14eaaa-4eb8-4688-b12a-80d70c2e1a97	242510340	$2a$06$4Sru5gP0Hu9DlyGNRN72KeD2MABT9fFjcfrvSaori586KSz96c10G	LUTFIANA NURFADILLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b05b14b2-b50c-4e95-9267-1c8510fce0d7	242510020	$2a$06$Q7/qV9HMCCDd5l.o1jHCDe.pgnlw/jCplmo.feNdAqV.bve9Shgmq	MOCHAMMAD FEBRYAN ARFAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0e8ff225-abac-46d6-9f9c-40818baf2023	242510271	$2a$06$V1mtRZaYqunS0xWcP7Mm/.9mkz6fWjPoG5CkkHFsn3yukekt.zL56	MUHAMAD ANIQ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ad631032-bae3-4ced-a55e-4bd4674c7a4a	242510380	$2a$06$kzBu45PrrKmgZeQnfQxoFODKbVclhVrsBHpTX6Xj1pqc3VHUAznaa	MUHAMAD SAPRUDIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c34978f7-948f-462d-be26-53395941c096	242510059	$2a$06$1122GTdY0al8g9to/svgS.ssPsofdXEupSxDuVSmCw81kduL897ci	NABILA SAFITRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4ab1c407-2b5c-4a48-8d7b-e8bc2b42ff1d	242510060	$2a$06$cQOIG9TcdlEq8x3.c1B7uu62FPGnmwlo2WUCwLchVB4VzQO67Ja2K	NIEGITA DWI SESYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c40d0ef7-c2f6-4c28-833b-c756aca376c3	242510419	$2a$06$yQ.8i8GcYsICBEkqRLLmMuJIEeP.u/bZ0emj.c7hM7wGqLqrVllfG	NURMAESAROH RAHMADANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4382a003-96ad-4457-ac89-d2608c859bff	242510173	$2a$06$RaV83z9I4W.Ez5Dm5XCiPu/qNFBDrH9FUdlStdnDvBWjpcJqmq./G	PUTRI NAILA SALSABILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e99ed384-a0eb-43bb-a995-36bbef384e1d	242510099	$2a$06$o4J/ZbI/nLAtDdG9J5nc8uDeW8Nc.KQoPgfUCAPAkm0YmJo3kqK6u	RAFA PUTRA KURNIAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3c30ce17-7150-4489-8413-ed38a917b48c	242510423	$2a$06$nchvpacR5lAW2G8fXmQgde.6eaS44vUMy.O.t1lXGHK.v7.fplraq	RESTY YULIYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0f92e3f1-a4f6-45d2-8d3f-c101080cc7ed	242510281	$2a$06$dnAcS6tDLyHOYhPudMBa9.horSsEI5DMyLegmxlP80FTtudwUiuq.	RINDIANI CITRA SEMI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
20dc6955-05fd-48e2-bc66-4ec803d4bba5	242510425	$2a$06$hQHxBIH7oV940uWZB6RdteMwTjMQPrVAB1qYUdRgl31fqYku1zB7S	SAHAL RIZQI RAMADAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
947c0790-2768-4c46-9e8a-c0c727154a09	242510354	$2a$06$AKtu/mIYi7tlgF4PC4ZA3eq9VKgthX0Eg6erMk7M3W/KDCkn4m2/S	SAKHIRA RAHMA AULIA SALSA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
88866fc9-0502-4d7c-a6e0-cabaae247bfc	242510283	$2a$06$z51HHgQYE0ro3CEdsZbCIOG5/iULhmUHFgADgREvfaqjsgpW4bCwm	SHALSA AYU FADHILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9aac6a48-4e15-45e2-9490-e3481429dc8f	242510248	$2a$06$p/LUV4qlvj8Y7hheeMXBCuAL1V48TSEjIJzIxXy03UNIbHyzpycOS	SITI MAEMUNAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0411cdac-0b0d-4ba9-a3d1-a919154c6c6b	242510142	$2a$06$q9TCsjJ4ZJf7jiPNZEn.kOA6Od2NiK8arjNlbQBjx3Vh9baBfqicO	SYIFA AZKIA HASANAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0536de11-c107-439f-8fd4-d9d5f52ec575	242510358	$2a$06$sACkSijKH/IXClM3u5rjR.c.zjWUiGe88tDaks2ezBuF0GwA1NYG6	WIDIATUSSHOLIKHAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2da2c077-5a72-4c77-b0c1-6da3312fb921	242510395	$2a$06$AdWK2kpo8cHvJeyEmrQvCOEusLhvZGa3MQwroD..ql15tUiY4Dbem	WISNU PRAMANA AGUNG S.	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b8fd0ce8-48f8-4277-b92e-d1544bfb3735	242510396	$2a$06$RGfikI9yuCHIemfBmQ9B2OPMo9fPN.KgC/2M3koh4u0PHlGaENp8K	ZAHWA MALIKHA PUTRI NUGROHO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c9cf64cd-cc33-4511-9e8f-5968b4284a9a	242510037	$2a$06$p9ks5nYPCGXjBh5ziudXxelAnzzSQGL2QzJbvxCaQ9UMXcczBkaKy	ABDI TRI YADI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
471adb6f-66e4-4b11-89c0-3adf9a9294bb	242510110	$2a$06$R9XniEQuYidqxA79tLijJe/OyPUEuGNbv/yF.qrWWlGqE1IxyMsne	ADENSA LEVIE FILDAN HERYONO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3ac2790e-ea07-4e5e-b6ee-1ef0d9b95517	242510254	$2a$06$sG/HtFpbNAJ7HA.QzcsZsOGj7u73H5fIxsZCIRNgygORUrTgnCidy	ALDIYANSAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
90d6eb94-3161-4f23-bbd7-db0bf04c1845	242510363	$2a$06$EmZzerHeJSUwI2vS.o5SKujMeye0uvO63m2AtEVPnBOfZMxRouv4e	ALMA NUR FADHILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8898c00c-4225-4105-8ac1-9971617905f4	242510148	$2a$06$iCT7WulKfusK5g9ib4X2yeEBp.Leus70eIbgIyIHgHW5vqE5/A5E.	ANGGI DWI PRIYANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5f36109c-e9a9-4c46-8649-7a4c98a7d9c9	242510042	$2a$06$8ldjcNH2Z/dGx3vlm5gES.gwDSwoqqlRujwduVc1jP7wzLxKKAGYa	ATIKA CANDRANINGSIH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f03300ba-f0d2-49db-8f1d-24124295f764	242510401	$2a$06$5LBaHkhVR0bwAjSvxLvmhe1irHDZFeJ.q/pJREdAL8RqvYyyMVeYa	AUREL NURFADILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5a753b36-3e0b-4452-ba0c-c0f6f2acfad6	242510043	$2a$06$nK9PCSgX0GeLSdfs1iJz1.JIM.0Y0/hmmZcmpQdvCWddpgUPhu0Ia	AYU FITRIYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f5ed1650-2904-4243-ba04-c7a7448abe73	242510402	$2a$06$B.5C9JB.BViucFq.AUgtiuG/pgf5Kotj93UjXoHAzNsJYo/5Z.58G	CHIKA FATIMATUNZAHRO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7436561b-449b-49c1-af6a-6f8692b0be05	242510332	$2a$06$nWcw3AEEuNfcvylgda64Vu6cgQy/Kz0sb4lTwbF/Ev1bewgfBzfPW	DEAH FITRIANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a58cc07c-a4fa-4fde-b702-622667e3f17c	242510117	$2a$06$2HuUy0J4v77nYxmO9CudDOPmWy/kj7P7nQl2G7l.PCNp/qZglcHES	DEVAN ALFARIZI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
53963dfa-1a7d-4863-9e36-8d08c73c0aa1	242510334	$2a$06$Ar6FCKdmDStpiPZd3dfNYOTc4rHQHeGUG0k/dQzcoiRJolGKAN//K	EKA AMELIAWATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
172520c5-6164-4183-b6ce-e166c9293a96	242510263	$2a$06$osTPmQmdCp1WKk7Nv9AZZOI2z6YoUdg2CPpOzjaW8xtQncuY26MRC	FATHAN NUR FISABILILLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e17cadf3-8440-4b7f-ab98-bc63bf5f6f80	242510407	$2a$06$3A3aW7qJF5d/Lgl0RUUhreUofLNj.FKO.K04d5tzyCm/u3892K3wC	FITRIA ALMARANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3d69bf44-1c89-4e38-86fe-4a15e97cc8cd	242510015	$2a$06$RMd5vLnkTdMOsYRYVCqdZuwqkSlv1bwLP/BZx3PaVrsAZLgzxoj1O	INDAH TRI HAPSARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f3b7c6ab-a9a6-4520-9afc-8a7f3f86ca4b	242510052	$2a$06$h5K.c3iAaXnV6jKOJb7yKOVyucMluWQuBPmTbHXfATtSyLnJ9fxKq	KEYMAL APRIANSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
60b6bd2b-0384-46d4-b132-e37300cd67ed	242510017	$2a$06$e5DZYRN/CI7IuGaTy9wxTuFh9Thu2pX9D.G6CdOkyLgm2ZkVebGLq	KHAERUNNISAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7f8f4beb-a626-4332-a357-f83d14b0184b	242510412	$2a$06$5Aze7F2OnjEdIXvouawPp.IoVnvo6HAFhhrZ4cZ4.h9/2/XkhL6xC	MAHMUDATUSSAROPAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
78fc28dc-c3f2-4c91-9962-29bd42431f28	242510164	$2a$06$WpkfBrB9FNNfna8s8Q/q.uFWyZCKEfVYNrGBh5kXxCr/abW7P5BOS	MOCHAMMAD LUDY NUGRA SATIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
340fd4e0-665c-4f27-a142-febb6e4b20ea	242510021	$2a$06$LiC.sUy1gz9Ib7FcrakmiOyRS0tcsfnpHOVNdgUH8OX4AZu1FWXiy	MUHAMAD HAIKAL AZIZ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0d5e3540-9493-4fc4-874c-5fc9e70391ce	242510057	$2a$06$GRlB539ysWk8NoFusk4mhuFmw7jovTPs80fbWbM5KRSVXhxpctqSi	MUHAMMAD ARDAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f610ece3-75e8-48a1-a68e-60b7c9a6ee33	242510130	$2a$06$.Se33H2zhZVyYcf038.pHeSTeFiq1SNBbk6UUn2dqCKiZxmDTNg2C	MUHAMMAD ZIDAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f05c033f-fc28-404e-9899-f4e18c08c6b9	242510131	$2a$06$ThLAdUgybrvNNSPbmQ7qY.rs2xMw1M07DUNfg0D.iFvBmg/72zg0u	NABILAH ARTANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
78213d75-a4e0-4586-b06b-d8ed6a32f827	242510096	$2a$06$0oDAstYoszYSpctuQJOneeojK6rmp62mnWvrN9XTbSzqj5aVoUMyK	NILNA AYU KHAERUNNISA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f38c1fee-a2f8-4392-a561-373e08be56a9	242510062	$2a$06$FLz/lraIkisnMcX224K2D.a9hNFk0Y.EdGo2LBywkp6KPlNvwhUf2	QONITA TSAGITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8917a7f5-5d9d-4cf3-ab0e-7a2344f94918	242510134	$2a$06$ES13OYSPwninSOO2CyqvXen0vHPM8Y.nHblsKIh2I.WORYcaZ/h42	RAFI ALFALIKHI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3ca3df62-0ac6-4d03-ab41-81f04537f364	242510030	$2a$06$7BRRS94Msk1bHVAivXlrBe1lmUAWouzZTxYnl2LjwzRCRe1ZhJS9.	RETA ANGGRAENI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
97f9b284-d614-41e2-bc56-ff1314133485	242510352	$2a$06$D8q8nR7bdsAaF22UTruFce2l4k5OSnLRCKTvZwVwBLsF7ON0Wxoz6	RISKA AGUSTINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
efc2b31d-8c6a-49e8-9111-cec245dea3d5	242510032	$2a$06$Qb8eT4.rFdiCSpTlEKMPSeoB5aGaZz2sZJOdTPdZaddOHXfDsKGwa	SALWA RAYYANA ZAINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5de85b1f-7b54-494d-8469-5c79b99de41b	242510355	$2a$06$CYMCIIBMoal0vlBFvzMQhem2mtvZ7jN4Jwvhu5tcZqpHNjjWQixwq	SILVA APRILIA NOVISA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7f413758-3aec-4bfb-b417-51e0d930db71	242510284	$2a$06$Qm4t9.A6dUrn6MK7k3.yv.h7wVCVqJBPt4t8DK6eZ9JfL/eW2YVlW	SITI MARIYAM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
18e82f17-6231-4c83-9c71-62513b92b778	242510141	$2a$06$xZvF8OS4a7Fv.sixRD2Qj.4eyuSvEOWwLcWBJoiWvT5HXkTANuhXi	SURYA ELANG RAMADHAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3813009e-93c5-4a46-9648-729ef729fb61	242510250	$2a$06$EkPcjdg4j4Sz1wZ30k/DdOuiVrLY9sVy7uW/Cn4TfrX4dnYyy65de	TIARA DESVITA WULANDARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
246f5af8-81b2-4e46-8e91-b9fa77a00eee	242510072	$2a$06$A6iEstgNLqnUi.L2U4.j6.VVGWZka.ustB4wKx7Ydd7VaCZDyzHYa	WULAN SAFITRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
29872d1d-0637-482e-8d23-5c3db79f6f6c	242510432	$2a$06$zGMmiU6HHbgDF/iK.Pu/GejF.ZM1gaTz5KHzArd1mlXKeYaPqzPUC	ZAINATUL MILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f05496f8-db17-489a-ba6a-089be4b5997c	242510036	$2a$06$64Dwt2xjB2lOCm2WUTpOruVnOWZUz/fKroEGd8yng6C63j7bqRqL6	ZICO JERICCO ARUMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b77f0547-f9da-43c2-b5a4-b775ded6cd97	242510146	$2a$06$uAYQvspWzBZHIBq2x6Mr4Om4KfOO2kn6jhrPeIb4JcqhvWqqysYRW	ADILA FUJIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
98f956f3-9cd3-46cd-acae-be7d09d13c83	242510289	$2a$06$bcgfA6I1d8o1k1K0Ca8kjewBTPwjqn6iO2YwxFtjM5kCxOhaq0juC	AGUS SURYADI JAYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
de685d73-fde4-46db-bf77-dc394d9aca51	242510182	$2a$06$/Y.vB5CFKNE0Z7jdy7irq.ZnVXQCtPqQPe74uWqCIIidezC38r.fe	AILA RAISSA PARFANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cd69ef75-8a3d-42b5-9815-247a2f746911	242510290	$2a$06$qKrc.VjbjLfkXLNjIJr4fOuljMkF6srtCIYGhDKiEWsBSQOHW334a	ALDO RAMADHAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f1225f81-9455-4580-b33d-1c2d7a65eba3	242510398	$2a$06$XjJVYro5fBEsID7R3OBAmuxNAsNvCcNUwNgafOlo2XDWcPJPlzSq.	ALMIRAH AZALIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
be1d0201-3261-40a9-8904-240bcb614b14	242510184	$2a$06$qhBONrxlnWVQ1GNW7sodoucsaF6d7gjSh2gCK0caN0vXtHbZQI6mi	ANGGITA CAHYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cf57ad6b-564f-4405-afcb-d9ceda241e68	242510078	$2a$06$TUDyzjeCv/6eDFn7to15Let2qwYCVqF8Qj49OIB7QPYA5byimWkly	AUFA REKA AYU BINTARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cca4650a-dfa5-4a0e-a83e-74d14b686b11	242510007	$2a$06$plwntYUEAKOQD.tgbWMeBuo7EgD2wf.U6BWWwEv0M5Jyb0/wd2CJK	AUREL TITANIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
49cba21b-41bb-4459-b395-e7e9b20dc0aa	242510044	$2a$06$I9j5ldrvnjqtIbbUI.teluLPOamlxaJOjdxXdSejnz0bRPe/UO3O.	CINTA OKTAVIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
94ca0317-02fa-451a-b455-9fdf26556539	242510368	$2a$06$u/0kQW7FRGG0LesXinR2QOtlKNCwt2.eaDk31dGVZZ4Z6sok5A6t6	DENISA AFIFAH SALSABILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
42328c71-5b12-4c7d-ad08-959024b588ec	242510261	$2a$06$MUejxtnfoBOuK/Qj61hjfuLPvG3eGctZjhMi0hNrr5jtnRK.u9D4W	DIDIT ADITYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fd3d64a1-2dfa-4432-87ad-4f79237b2940	242510370	$2a$06$vT9i79b8L7sHBME0xMzR9uGRDnwUh6S9UYWP3lbDmj6hsXGJNwS1a	EKA DININGRUM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
61c9c4be-95da-467b-b9eb-f3a21f82a135	242510371	$2a$06$6pAk8uJJgpI8KTN3R95R/uvo5mTGX2QSltSLuw05dX51kp5GQRYD6	FIKRY AYYASY ASY REFALDO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
87bba6f2-8bca-4498-9012-280dc8aeecdb	242510013	$2a$06$xsMtcHGS9nUbT7eStIs4I.rryCCdMH3lEAEL5LeKmHqsSNfbLVI6C	FONI ALFIANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6e559d5f-f4d7-4856-8742-28421a58d469	242510051	$2a$06$RaxcGfqgdAxOhNj5rGecgedbF/Tdlq8AuWbBSHoRVbz9tWaCQEMPK	INTAN MAHARANI RAHAYU	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
dc967595-89db-4e06-89d0-090817392ca1	000000000	$2a$06$dsTipvQY6VIt/u4.xjb3iOtBZcmQLmqm3Wt4UHmGNSHqwDCIWUlqu	INTAN TRIANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e4583343-8436-470c-8625-0c3ef37b8b26	242510088	$2a$06$APmptTLK2b2awoWybaVBeOcD2/onv82JriteQcad44jYomh9PUPsW	KHAERUDIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
78dd0171-fb9c-4f57-bf1f-ea1d1cb35676	242510053	$2a$06$7k6YMfg0YuqOkDVgP3QW/.aG1J7OrsPAZYOuDZCYK06LM4otuO3F2	KIARA UTAMI IVANIAR	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f613d439-26a1-4246-9eff-4c1be61daa78	242510019	$2a$06$Q4b.pl2PUD.PjEU3zoFOm.92BifxjVmz341kwFquPT828hKurY2XG	MAR'ATUS SHOLEKHA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
53f95d47-f05b-474c-8884-bd1f6b2a3324	242510091	$2a$06$s3N3mTnoOOP8kRA6OU9XOO0ZUNhNUpSvW4L3ScOY0sNNPzwLz6nxm	MOH. HABAJUDIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fe65e995-54d4-4157-af8e-8b2ce643f519	242510092	$2a$06$ExNR7F7khOsk9NfBsi6XO.N3DWDepCjFHO.7zNWOdHE5TYRFQulm6	MUHAMAD HASAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
95818180-00c1-4ded-b648-698815d1e9ab	242510093	$2a$06$e2o4vKZqbfUF1vKr8sp1aOZzJb2MwopScSuSbjztKZ4BvgBR6jorW	MUHAMMAD ARIEF FATHURAHMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e3804775-55f1-4c0d-a378-822a25a7ab09	242510274	$2a$06$Lv/ecZp0THVXQa3d62jbVeLn6Pc9Z49y2tiSUeU8I.wzm6w2rKtPi	NAJWA ARISIHAB	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
518bf1c0-548c-4783-98b0-fbcf1c73abce	242510239	$2a$06$ccFrflc88y220LnjhS2JEOs8wBnvyp9xo0tSerCpY.dpPNVE23svC	NAZRIL ILHAM ARENDI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e4fece01-4db9-443b-ac26-d7e484306a33	242510132	$2a$06$Tr8VNXHoVUmkpIn7UHa1Cu3pYNP82niOcR51Bs2Do5LUrirbh0rAS	NINA LIANA PRATIWI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
43ab2867-c0d1-4ee9-8fa7-2f1555def47b	242510061	$2a$06$LzUu2RXngaPJ5bgsxASDNOWpT4gSmdmdFj88YD7dd3Al.S5rdbK8G	NURZAHRA NASYA SYAHRANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
dc2547b2-43a0-48b8-a251-3c7fa492d71c	242510135	$2a$06$uI/ZMAkDkp8n8xQKpl6fD.5nbxWmQlBzrukp84Fxee0/09/.tflIO	RAHIL SASKIA FEBRIYANI SALSABILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5c83957e-f0a5-4488-b4c7-5e3f544b1fca	242510350	$2a$06$9ZJnP83vNoFgw9Kdc7g61OWjuEtmHNaIRNM/o42FC656Lnbq53JD.	RANDY PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5b24b899-ef1c-4fa4-a491-d3890a5a5854	242510065	$2a$06$nWp37FNjvPjPJq2v8c.n/u99unnZP.D26pf3b4NKSlronU/EjzMMS	REVALINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
44d249de-ecc3-4876-a203-b640ae650f3a	242510424	$2a$06$nKa.KbEcx3UkPwCDe7NQy.su8PGxj3ztmiia/Ax/BKJWoVOgje03S	RISMA AYU NITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2639b27d-f1e7-40bd-b14f-20f1aab8bf28	242510067	$2a$06$INdNs7SaFnWLcaf72fjQWetI4Cl37.S.zTiNFI63PwTo0CYTXYfsG	SANDZA ELVIANA AYU	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
89d57909-c6b3-4f4e-9369-b8dfa784cc7a	242510427	$2a$06$8uBW1HMRdknAKSvIgEnO8exyisqtSmUfkIvzTOXm9miqzLa8IN.TK	SINTIYAH BELA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
715d376f-09d5-400a-b640-8775b9e1e396	242510320	$2a$06$NdmsR47tbU7eS.8ypBVVdOc2fhnsHjgbsXMdSLYP26T.5Lzxqj2cS	SITI NUR'AISYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7de9868b-6334-4e96-9280-8cb45943242e	242510286	$2a$06$ITszAbRRizfkSLFyXx4IfehEiCngn7jtBB8SnNUbynNVetzcOYmaa	TIARA HAZFA AZZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cca083d0-52e4-44ed-9cac-e7e96037d6d2	242510108	$2a$06$zWFYQjIca7zSur6Y1Yqdm.DlSCcNafRqxENRRkaNF6KqB39tyzmTq	YESI PUTRI ANJANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c002f021-c776-42da-8127-d27ac580e12b	242510361	$2a$06$7cb.UsM/oN5jxVUr9ub2wutpuwm/K5CShGVKID7J3LQ6DQI1.a0Ri	AHMAD FAQIH JUNIOR	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b30631c2-34da-43dc-b490-7fd3e239cfa9	242510004	$2a$06$isnSQi6gWWUIV78d67LC1O8P5iakPQCr84qtHYnYHuEY7vprRTNSa	AMELIA DWI PURNAMASARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8e06e262-b21d-4e2e-9ad6-ee875657f5bb	242510256	$2a$06$T4df3SP0ywmHRgzr2BVg8.FWXyg3uHyZ0F7ub2RqFWrUP8Lbt1QUK	ANISA PUTRI PRATIWI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f87ccdef-1d3c-4004-878b-7244d0820dd7	242510077	$2a$06$k9/Ji11XNV2zKopFRZBplel0d9SdQbk8HjXG.Hyrgbbgs2Cko0AB2	ARIEL	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
31ba1a12-1bec-4fc2-91c7-cb98bd59c06e	242510185	$2a$06$Pr.6eNuqeXV3N3HVB9Yj.OhR0DLhd2.SzOuRSiq0kU0r8JIoii9iG	AULIA KHOEROTUL JANAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
dbe466f5-af88-4dc8-b40b-c3edbd08ec50	242510150	$2a$06$iBe0hejWv/3aMsbYsll5h.R.BFLcwN0onDUkNOuzdkczxAqMPnLuW	AZKI AZKIYAH PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f5a958d5-5891-46dc-a9c9-70240c37ced3	242510080	$2a$06$8Vh9.QygDq1YTMF9qUfxd.wlECp31tMc76TvoUaLKLJ7vrIIc5Zm.	CINTA RAMADAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
aedf4b36-ce87-4d58-95e6-e2ceb4661a3c	242510010	$2a$06$BFRBrzYUhyoylGfjk2zYhuFmxUrP0u2SN8JqFjsWxeVPrxV5MXMR.	DHUROTUL MUFIDAH HAQ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
61f285eb-5167-411b-b1c4-5dbee8adcff4	242510333	$2a$06$i6CS2hsDhVFAzSgzgkqDx.3IelmzJTBf8kBdfsUuQsuFl48ism/Tu	DIMAS WAHYU PRASETYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a06d070c-fa64-49c3-96b8-bfd8b378e005	242510264	$2a$06$m4Z0G8Y7pMQmzWYsydHIJ.BI/54Wiu6FP7wOGPJ7eP5HOe3LP12NO	FEFI NURPADILLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ba7b3a1f-8bf7-498c-8e5c-84ca540665f5	242510408	$2a$06$RnAE24Zw9zLCkcw0Vr8dpO38ccj9zqg6Qq1fMV4iufAQ8b6fORjlW	GHADA AMUKTI HADI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e57337ec-e1c7-4ab3-9d06-892188cf8263	242510121	$2a$06$N/oEBwX98Y1uoCohwf7S7u1sxabLkyMSzqy7FXoWsJl3H4zX2V1OO	GHEVIRA RHOUDATUL JANNAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
069123f6-8fdf-4a2c-8151-364343b18d8f	242510123	$2a$06$UHD4YpM6A28F2sElKvMtU./xM8u7l.9b75IZPGNGVltkyTEaFtrXW	INTAN TRI OKTAVIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a9589f54-9615-41da-a332-c78fe4f8ee66	242510196	$2a$06$HsNGbiMxkwblX.VGhVw5Mu.6aIYLrP/zgFwEM7ScgFv2RB/GoQFsi	LABIB MAULANA GUSTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d3197354-9a76-479d-bcb3-58847cd740b5	242510197	$2a$06$OQR8SsqmdJtc.6ercYVUjOOlH/TrcJFoPkvmwf2Oc2XBeXWNlOwx2	LIANA PATEHAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
30886cb1-b995-414f-9636-d10729d41eaf	242510090	$2a$06$M2xlSzolSmlDOgj6Nl3sEupXx.AEp.lEK3NvjnBmfkeegcZeLmaRi	MAULA FITRI SHOLIHAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5f55ead4-5727-4bc7-b095-4ec52ddb845a	242510127	$2a$06$fYFQ3E56xwNmtZis9kQgI.dgzDNR47oIpBlOVc7d6AFfRm4m21clO	MOHAMAD ARFAN ARIYANSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ded90dcf-3551-45eb-8e2d-6f7fa96a6959	242510236	$2a$06$YQCy2hD8ucC9IH3hWnTqbudEIqdNc8eybPj7E2XAQ0GRyT2W7Wy/q	MUHAMAD RAYHAN ALFA REZA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
20747a86-995f-4214-9f47-5d7c2a284e51	242510201	$2a$06$d3WI2Ardm34mplrdrVmU6.Lvl6C4rzLX8mNAzhKK0nO2AnpFsodmC	MUHAMMAD FALDAN AL AYUBI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ed398ce8-f9d5-42e9-8b4d-322dc8aac90b	242510310	$2a$06$LyY1d0L.vO2KV5v06zP7ge.fG5Lkzwlc53omSFmcGZ.GkQbZYvU2G	NANDA AURA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fd7f2d77-0f01-43b6-a304-8c372eb442bf	242510275	$2a$06$dfDvg5iW3fJRyme6qHZx6O7mUiI2gKNyrZoyeopo0WGNux/YNMQYi	NEEZAM MAULANA ALMOUZA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2ec7d015-f4c7-4c63-9ece-a6324ca5c536	242510240	$2a$06$e096r7iwX.7eoRwaRkv/7OAfez.wINDhJOEvChU0QIYRVCmsFd7yO	NUR FAUZIAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8433037b-12e0-4c12-9150-8343da45852d	242510172	$2a$06$h7bnPYCtfdrNiFPNE2Hd6uoWWEj/kVmtmOU5yghRGnX7pWaoGAuLG	PRITA TRI APRIDA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
86e36d58-dab8-43e0-92fa-2998af93af93	000000001	$2a$06$Ed0nzwfffWCJpGEODLSUE.NXLuudnr.kiaQ.jVmAFk9P9Kr742Owu	PUTRA PRATAMA JAYA DININGRAT	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
91b31777-9f42-486c-898c-3b26326c2b56	242510206	$2a$06$PQZYeQ/mSy1lMQmBRhFmiOcihF5aauTGwKR/NaBv2ivFrzocXlQP2	RAHMAH SYAFAWI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8f16aa3a-f8bb-4442-986c-b41f14f91a9f	242510422	$2a$06$YNdGQaftVI/9FunBbriCNuixOa/CtGsnXRFHUXuCamEZzqDcUSLGi	RAYIWINATA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fe65dce3-038b-4a11-b0db-32fb6381b7d5	242510136	$2a$06$Qq/tM1ZoRn2P2l9LBQFfxOthQMLFa.8hYF3SisBdtVf8EE9kHqx7W	REY HANUN ELFARIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2df24fcc-96cb-4c9c-a13d-a17db7e799b0	242510138	$2a$06$X2wrwtgimHjd.jdf3MEz3OqDdqhI7cdR1UZEL.deIMY2XAIJwhccG	ROSA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f7d09199-31a0-4157-aff7-129d2602409b	242510033	$2a$06$BUQ/H02U86RyY.h7IPls.e.Lg5J94HC.qQklxkDsTdTP5/e2Oy2ui	SARAH ELLYCIA JOHAR	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c8322ae9-5dbc-449a-bfc0-e109960bfbee	242510140	$2a$06$h0XMWwvkpCJ1MOtw8H.hzeFdaKNpo8tZZ2..HD15zMFXUr/L3zs1y	SITI FADILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
bdaed8df-8072-40b7-886c-d4aa930abe7f	242510428	$2a$06$Nj92Pxv7gq7MoJoEXWwEMubAKYiTACkFijPK.o.XE5uH4Yzdm85gO	SRI SUPRIYATIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
176e20fd-90a0-4f84-b748-9e9261abd402	242510213	$2a$06$5JVyBqjS0LfgooZL22EGjOk0pAzME8BTF5qvzx94BifqLkVLjW4iK	SYAHRIL LADINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9ea140f3-3d75-49d7-b5a0-99fd010f8114	242510249	$2a$06$TlLS/BuzcXagdPExjr9sBOWeY.9lvJjH/OAgKKdOdBUCRssVIZ/qi	SYAMSUL AHMAD SALUKI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
41bdfc84-7a85-4957-b3dd-42d195503cae	242510357	$2a$06$qzmj1wKrd/8nsSCR/I08.OAA6iqG.sErdQ5ehE4HIx4D8RQ.w5cru	TIARA NURUL HIKMAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
04def23a-104f-4e76-b097-542b3a081e33	242510144	$2a$06$Ax3AeE4Yx27Z2QShMYTzUefHDwce6FWQlfy9xCeGDyKiqS.NYJnoS	YESSI AMALIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8b812323-7409-43a8-8a9e-28fd13b4db05	242510003	$2a$06$BgomQj1AbN/Yyx6Ktjq3w.FcRt4zCe7VRusVzwt9IZ.WlgQX8Dboa	AHMAD FAZRIL HIDAYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fcc2b672-c2f1-453c-9921-20e5755a92c3	242510218	$2a$06$AzPq0JuCfEJKG6tz6SMZd.t/IwBMMAhYv3GaDV0/pTrd4hazvLHcC	AISHA NURLAELA RAHMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ee1c539b-06d5-48e0-bd97-8e46f3711850	242510255	$2a$06$Jxfg5XvFnTsp.TbFaQeLaeLei.4dGtg6x1O6wDawOwwG.2h1KRa5m	ALENA VIDRIANI PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5b966da9-6b0f-4027-9e34-830007ae9b59	242510040	$2a$06$yTcnSIc7JtiUtQR7if2nU.PV2/fbJf4jCa/eFaQ94kcYIM1kFHgoy	AMELIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a44bee59-959c-482a-981d-7b496b020cc9	242510292	$2a$06$UlW62T9/wfoQ/KqQD74F.O/wb1sVI8vQoyZhXSfk3aLh316pMt0we	ANNISA PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
07ea0be2-2aaa-4539-817b-ddf0cbe4d030	242510113	$2a$06$w8Be5LBLiweS.5xlmzHgBugLCLm.w4u2YORN24WG8TlKJk3OXrQ0O	ARIFIN ILHAM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
20db3659-9102-4fa4-8552-2a4b4965770a	242510221	$2a$06$9ILE372rroQB3nIorGac.uh31gy9dQid0cX/TcbzoUcwnvhb5Efge	AULYA FOREN DHINIATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
64971d06-fb3a-451f-893b-081f81aa4cde	242510186	$2a$06$f2IO3rw2bBa.wiM4CyZ8TORQxe3cbgh1lqykDQVuwOE4uIjVRir0W	AZNA AZKINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
488a23e0-493b-4c49-9b1f-f4e3ac3feb05	242510153	$2a$06$jxJfL7npG72vfQ7sk45jd.F3tjB5wPTu05n23naUbc6UrIAiccf.C	CITRA WIDIYANINGSIH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a3f403ec-7de8-413f-bf5e-738331303975	242510046	$2a$06$UYUR.rHlgx5BblAnvJX.zeumZ60l4UlzXiCiZy25BR1B77NI94P3.	DIAN MESA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
137945a6-a8fd-403a-af1d-8902f82ea0e3	242510011	$2a$06$bHMDSR8V.DnLh8lEnC/KNelWTOTP3LbKaC/insNlNBOxnnqVwcRgi	EKA SUMITRO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
91e11f3d-c73d-4f38-bb10-78057b401790	242510300	$2a$06$9BF2uGjE9NWg.pOkqO1IzuDuENiC/YNtX1z.Z2Y7tSASfLgMqrK6S	FIKRIYAH AULIA RAHMAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f206781a-0f4c-41fc-9e98-0a9f6cf1ff27	242510086	$2a$06$eG7JdhXNBk7mVaNPu4UYcerq79vnHUHj02APq5F3mo7p4QUKdcIny	HAFIZH FAIDURRAHMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2e1493c7-f67e-46c8-b147-8215b849cb44	242510193	$2a$06$9iuYTZLeDRSykHGzabWm3uXYLz.fVQLgWuNXVgEU99vxTN2XNqtpS	HAFSAH MARA'TUS SOLAEHA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
eb1e0410-0215-4189-ad34-f742ed718759	242510231	$2a$06$1Sb1m.7TxJSXoC3ggzHdGexoUfCbIiWpTffN7w/QWwW0jdLLbCV7C	JUWITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1a1c6f2d-370d-426b-be23-1894c56baa35	242510018	$2a$06$OlKVTx4n15nZx3EppaGZ1uDI0EdJILesKa/QQlRfIeQSHq5K3XD26	LIZA NURHALIZA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7271c703-9f76-4f17-9264-72dce51266df	242510376	$2a$06$VxBeC0StiBVVAsumXqqYy.sYSkhpfy3tX9T3w6fCTfbgIsUWDrjq2	M. IZDIHAR TRIANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b8ad66ee-c605-4104-8122-ed242ef11370	242510342	$2a$06$GyYsKpLMy9/5dCiDaOyC8On/.RJ2Lg7d4oxsEzFU8iUM1KAD2MdLW	MERILDA RAHMAWATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9374deb1-e7aa-47d1-ac53-6d7ad0dbc3c8	242510199	$2a$06$8YCJLtL7efvtB2UbuRvi.uk/eP.MQoLnOUsGBB.Kp0a/Sw7S1W7D2	MOHAMAD FERDIANANT PUTRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
718503f7-e461-4f78-9888-ceea1a788474	000000002	$2a$06$HZdhxV2ALXMPMrEOcD1oXuq0cm42X1eCzbhCx9hCTzKgz8n0iwLl.	MUHAMAD FAHRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2544d162-413c-4ccf-8c85-2a5fb1705587	242510272	$2a$06$oKTEy.pf7wgjHsG9R1UFkOh9ftQKOwJ.HCupbkJvzmrLNcHU7AanK	MUHAMAD RENDY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
88e50d8d-4d67-4a0b-b30f-d94f15a456ba	242510273	$2a$06$D.SUp./TgDA.oM24h1AZbOBsqYvRO1eqNEwQKZcFsnNO8yxZ48MqG	MUHAMMAD HARIS MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7ab3d175-e2fc-44ea-91db-9c9e83ab2b71	242510346	$2a$06$gtnBq3ktpO0ttfAXNWJZQu93ZDhgaVGhEfn8EmUIENIDntecT/V1i	NASHA RAHMA SYABILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ae87e323-98f1-464a-9480-de56924f5d08	242510276	$2a$06$mG6BGwxKvLPgRjRnwDssquswhfkwqhOP/2vRHb9RDn1..Ej7QA4zy	NURAENI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b7c58489-4c83-4efc-aa41-4e30e8968da4	242510312	$2a$06$ecgyH.QCrGwn.5wSIY8XFe3XsOeG6VMU35Z/Qqrzk/X16N63Gib8u	ORIZAN ALAMSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
84b38204-7500-4898-bc55-0174569a34ff	242510241	$2a$06$cXP3y/Z4zGLiZeXHQHXsJ.9gQyoeRuxl8adHBR.qD1S6GTCxv69ey	PUTRI ANATASYA RAMADHANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2ef4e216-0b95-4cef-9c15-0a958e93cc90	242510279	$2a$06$aoaS6rUxa/cx75SpXyMLeO9LQLrSVOAass6AvMYQyOuZrkEPKUSVm	REGITA CAHAYA PUTRI RAMADHANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0a421063-da1a-4f00-9bfc-6c57ac32ba60	242510137	$2a$06$BZEPVmI2S/276saEnYVBhOTg21pDP4REkhcyIAMZDbu6Wvt/AesBm	RIAN FADLI NUGRAHA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d0dee914-5a6e-42d4-ae14-c7650a47091b	242510176	$2a$06$kOF/zv.lHUZE8YzX93Z4LOqhXVTgCQa.Jlj7mH8gIYFJx.A5crN0a	RIFQIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
69e41238-b269-4ab6-ac75-1ac6ab292c50	242510177	$2a$06$9dBwquddMEkI7BbRlj6azOTIczn8dZTAJELCeJ2O9A5yLV2/bZsu.	ROSELLY TRIANDINI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
31936dfc-1310-4fb6-bdb9-f3091e30f8da	242510103	$2a$06$GeyLUiRIML.PlYaDfoQrA.ZwbQP5/xYZXsBSl4SiXz3gdl/lOdMUS	SARAS SINTA KHLODIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fedaa837-044a-432c-8a11-6c128fc63a31	242510179	$2a$06$c9MFRth.dsFib1iqmhJAyum9kEiPA2CqGbcrWNHHPbZciv8QsBfw2	SITI FARHANNAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9ad5c68c-8947-4e7f-b2bf-226ce4357de2	242510035	$2a$06$Sa524o85kSmKWqiDJUa7g.xVqIDgNCRkHhxUSteAA3imIg0NfzshS	SULENY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
97c40828-d1b0-4863-ae2a-6217f4133a95	242510143	$2a$06$MPSrXp9vZDrSW0VyxzPYRO3AgWtZm1KnunSMN8WUn6yr4qF8Ep4EW	UNI AMELIAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9d67d757-c62c-4ff5-ae4f-492ac3c8ffde	242510288	$2a$06$sBVzk306qy3Z0qq5Hr.J..ph1AghUgM3HHDnF5YAzxjAhWm1b.E9K	ZAHRA AMELIA ZULKARNAIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
123aa332-c532-42c4-af07-d5698010f6f9	242510075	$2a$06$K/n8y5Yg.F6lkkBNkFetEOzrmnbiY22.5A1x3Ay/0N.dE4PwgcA6a	AHMAD RAFI AL AMSORI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1432e432-6623-4661-b6fa-3a1ef527e61c	242510076	$2a$06$ooDZpG/Jk.gFf.wBGf649eeyWMi/SbQVjbCnwM.KCX3Gbnrbm947C	ANDINI AVRILEA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d9bd959a-d678-48da-8f92-56289e477c7d	242510328	$2a$06$X0p5g7e4/IfitdRc7LS8vu5v5eggTJ2hliJbYiiIKEBoWt8Jc3aYi	AQIS BILQISTY ALMUNAWAROH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c32668fa-e8a4-47c2-8f03-e72b023e8acb	242510257	$2a$06$V4vgw/z7lO.YITROY8xKQOGofHTiDQY2TlGRQxTPkJPDmLrlioe0W	AURA ALMAYGA SALSABILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b5885045-f649-4182-9daa-fb474f63a8c0	242510222	$2a$06$le1HwPrQ/dUGsy6HR3M4Seob1TZe0bN1fKT/Y.m09K67rzgb05dPW	AZZAH NURSALSABILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
707b72e0-f7dd-4bab-b40c-6f95c90a2a95	242510187	$2a$06$i62RGJsq6E5h4tA2mb4UKO2vp0OPq9FgEHqDxoc3.UZ2oamK9gsI2	BAGAS ADAM EL FARID	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c5824700-60f1-48c0-bfd7-f7bfe54093b1	242510224	$2a$06$Yq2zgvdM9NK18yBrpJrIwuwcZ8vtjSBPPtS4x2qqYx2JXiZS7Cz42	DAVINA ROSSALIE ZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5985af8d-9825-4e51-8524-efdcc73cce08	242510118	$2a$06$bxM3m8vjnifyFy3FaDzXXO/5gaQEMtcKh7wH1Bpu2U2fXulST6cLa	DIANA PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
82d5c742-9d7a-4fa6-a87b-77f640f20d07	242510120	$2a$06$5K9DVYb0qAV3Rw5stXThR.6RlW3bI6Okd5vYm05w5Lb4/2xqIukgi	FAJAR AFFANTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9be66178-a7c4-4ab7-a260-d7fa159a61fa	242510336	$2a$06$pd0xafbMPcZ/yP2NbNjMNebudTwljc/RE4mPuKDwL8u1HVErOMl3S	FIONA RACHMAWATI SUKMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e995ea3a-2c39-4884-babe-f7601162862c	242510302	$2a$06$nBjFni/nGtFtsGkvwNSv5uy6X1ptgFVLeNnINHbidN4c.8.AtasYa	HILMAN DWI PERMANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0f5a8fdb-df05-4409-a678-5bfe38a1c78a	242510338	$2a$06$KWZ7I7pe6ssS177BD8FsWOx6.zyHCdGc9VbEi6f.PnSD8l1e.9fCC	HILWA LABIBAH PUTRI AS SIDIK	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2953802f-38d6-460c-8682-ef182d69be38	242510303	$2a$06$25HvjawuqyyFaRwrDWSBoOMlfA0.RE1WFyGk6fDkB2rKBpArZ/siW	KEISYA SHARLIZ RAMADHANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d04d9e7e-641c-4418-a1ed-17e89a37c5c6	242510268	$2a$06$2.r4QpFqA4tAof/7P88OS.dKhHjJjg1AYVZYnK9aki4Zm/PldrTZi	LUFIANA RAMADHANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
81e06cbd-130a-4181-bb6e-59670c6da91e	242510305	$2a$06$6Hx3FTx5PPM2F75MllYszur.lO6cM1yhbpx92OfQ6TuM55xtC5OV2	M. MUDZAKI ALFARIZI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f97a6cf7-7484-4161-829f-348ca714439d	242510413	$2a$06$AIJkHA/DeJrgGGlqhNdSluPPI1/J56Szrvvfw5LuZag3ZJWQCpUUu	MILLAN OCTAVIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0de6b64f-f154-4031-a1b1-f08257f2a5d7	242510235	$2a$06$/vr4iWQ0R40OIHeq.dH0KuW8dJ1OIGgBocDz.zdK1H4l2tktQVeJu	MOHAMMAD FALUTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c0b6b3df-29e5-4e47-b644-5e0a7a77cde6	242510308	$2a$06$X3MFtZ9w75tcMnMEa.saDeYx4EmSAdlLVtF/9G5zu5h8/GFeONJgi	MUHAMAD RIFAI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0c739571-acf3-4a92-b66d-b303e9d77a76	242510309	$2a$06$ExuO25/LkCocDbx1RrwAhuthuQd9mVQKctIYqs76uG83m5qiG8NzK	MUHAMMAD LABIB SHAFWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
babc4ab7-29de-478e-ba93-5449685b26b5	242510382	$2a$06$kPG5lX4reqZj3z3b6DWEu.Berga8K2PzNndhDwrC0EfBCU0kL3S.6	NATASYA PUTRI RANGGITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1a8f8e57-7661-4eb7-aeb1-9635c9590f80	242510311	$2a$06$J1nTX6.jOKftcpHKQD4.0.XktVNUbc5zMoyUM90qd4Z8nQJFuq0G.	NURAINI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f000df7d-a1d0-407a-9def-6aa3cb27676e	242510384	$2a$06$OS1mPEMnf9EAGgNUWu5ly.dQqyVF1vHyfTveQ/kQaY72tqx/WRUV6	PUTRI INTAN AMALIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a283268a-c3a8-4648-a324-5897c918a872	242510421	$2a$06$Z4tVmcdgwscJuBxT0cY0X.WIxthXolitrAC.J/bvN7xX18FP1vraS	R. PRABA ESA HERLAMBANG	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5cec86e7-b3b4-473c-bfdf-fbbe44226478	242510387	$2a$06$B1uEhYB9QNZih4e8sAn47uLA/gZ1QfnX8kcv1aPybVB./pbdazDiC	REPI JULIKA AGESTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2d614705-67b1-4c67-a66b-033262b20dc4	000000003	$2a$06$B7z9Pqu/zpRuFYgG9j9/ge8uBd1YsYVLAh/8K7OvXYeRtwgzvh7Uy	RESTY AZZAHRA PUTRI HIDAYAT	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b7f3fbd9-30a9-41ea-82f6-2aa80aaf2d13	242510209	$2a$06$7AgE8Ozdjn9U13HBO7V0oOBoXrp1F4wtbQlRIpX7Ef9ddtUGkxuX2	RIKA AGUSTIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
86dd33d8-a243-4236-83b5-34dbb7f6ea1a	242510353	$2a$06$HVeKfYOK1J2R7Q9cdsPKVOTIMY6o23TohJZQEaGPVwowhgMlQHaEK	RIY ADUSSHOLIHIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e4f4daf8-8b6c-4f33-b060-59dcd61c105b	242510282	$2a$06$TMBCtdcZry/AwUQt0VR3/uXp/wg7WE82cofa5cxpoGXYXizLHXB5a	SAFARINA MUMTAZA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
07e1d090-4a95-4d44-bd56-0b3dd5c4fa7e	242510247	$2a$06$y1CTaVmoFkRXyKqFy8WrvuuB7UMtpg8CiEicneyQKopb3vv.xyNOW	SELI RAHMAWATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4fea08cd-3ee7-457f-96c8-3b1a7d2d4389	242510212	$2a$06$Qw88/SQai3kHNCTmanbLsOlgvwUzinJI7EuyvlXwM6.Mo4HZU53Mq	SITI HAWA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fb3b0826-8509-4d35-98e6-4e3b1246d900	242510070	$2a$06$ts68Z3t0NUbVlXlDlPe5i.MZvA5/eIV9ssGV94HqfWaLXR1cNa8MC	SULISTIYA ANGGRAENI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c6b06c3d-f283-4f5d-8b43-b47f48e851eb	242510321	$2a$06$qqBIkAhyQxfh78i3tKQjMePQ/P0nSu3R9fpKV7T1zc8/yuTzzUuOu	TEGAR PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
665ec1db-b96b-49ed-b391-9f454e3081c2	242510215	$2a$06$08PgyZqcfTe.FGd0wgVeFulqKP/eVYwvHOdfRmR7UOlDveoR8Nzem	VANEZZA KHINARA BERLIANNA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
bd526c57-9e8d-49ae-a285-95bb3541ef87	242510359	$2a$06$w/FgYg4aZWlcro9jItbLiOOIBe80YQB8CxenEhmUXtJpZtY2zE6By	WILDAN BAIHAKI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
afedc302-8355-40e5-ad9b-4ddf56384715	242510324	$2a$06$7sInhO3DuQgVcHkPPx3ci.kb4hNyI/oNVNlAz6cQANLPffD0ObybO	ZAHRA KHOIRUN NUVUS	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
35041588-db01-4ac6-aa35-7eb009a37bbb	000000004	$2a$06$8PxoQVqcFP2ixkNhxMptX.9McqqifKNLiWZBXLA3OyenzbOBXNBsi	ABID HARDIANSYAH IRAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
502234a7-ddf4-4e56-a03c-f63e3d489fc6	232410164	$2a$06$MWeZ2K3Xm.tEVAoN9Wn60Oc9D/hC..SnIS3F1HmNn5y4Q590XRjDC	ADELIA CITRA SANDI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6b868d83-c2e7-4cef-bac2-b28050fb9589	232410074	$2a$06$pyLwJoXW/76s/cLqn9mObu5uaULBKdQXsPCtrLJRmgfF/Z.TVouMG	AHMAD ASRORI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3050fe20-038c-47e6-b679-ef8d1fbe3a1f	232410297	$2a$06$q6S8WH/X9CiIinzpxR1g3uCBVwPyAzR7YXiGRQG8nrGcNMtkYS216	AINUN NURAENI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ad6fe4e6-a309-4223-81f8-560fbb90bfad	232410420	$2a$06$gDFVbPqj/2Z7MGJ88d2I4etf0QQMucSegrPn64Ix0sMG7lPquUaDO	ANISAH OKTAVIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
48f07b68-118a-4693-9742-339afdf6a0fe	232410402	$2a$06$MDQ7HQKZCF9X2YI.Yo6oSuT3nK6xtk2qvbWzXgmFwoLbshuZE3lWO	ANTONIO SODIK IBROHIM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
57bf6e34-17b5-4855-86b7-d76990a99267	232410355	$2a$06$HHWsM4by2NrQJo8ImWL2te0H9MPlVSNVq6uv.qgiUOf8FjeOTkoAW	ATIKAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a07141a9-d1b1-441b-ab3a-ebde08b848de	232410109	$2a$06$cf5OBeAShWtojgpWS89DjOo.hYfY5wLWIxA/hounLhkgKMXVVnOc2	BUNGA KENCANA DEWI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7d0d893f-2145-4ef0-b417-fc7e605785fa	232410277	$2a$06$N0L8INhzqfVX3scVfrnVUuigpATLc0uADYafIYJ/UUYlE4CbT3DjO	DEVIANA NADIA PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6d6b79c0-62bd-408e-9e65-d9b8d6a40ce1	232410130	$2a$06$9K3m0bdt.fXvT3IhX0QCmOhVO5yx3A0rgZmz/F8GlOQVTx2X9zo5a	EGA DWI ASTUTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
49c94e87-ea98-4501-994c-a45863a78ac6	232410312	$2a$06$BZMqIA/MEAlQckVdJNH/MOfeODN5KBjDMLH4VFP9OKuWunCe5ICxq	FAIS HARDIAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5e3ae3c8-fdd4-4a49-b0ad-1d8f9da62d2d	232410248	$2a$06$r/9ej2L..GqSfwDvI6lcu.5czhQ96FgMJjTtbQy5b./.X3jS1jfYW	FINA NAILATUL IZZA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7677b836-62a6-4eab-85d3-2bfd2b84949f	232410344	$2a$06$.D/omVGFEqBbCscSMVyipuG3S9NGmvVSNJDuImWiOof6hCdEYsteO	HASNA ZAHROTUL HAYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
82320cda-42b1-4ac2-8b30-8808ad1fd6ce	232410076	$2a$06$2xWEm3K4CKBYAhhlvkHgcOaiPEMbAClIjePRRi0S1MC88Mqfovnb.	INDIYANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8f7b369e-adc8-4452-8733-fce627ef01f8	232410242	$2a$06$B6hFBBxcab104sYchBIX3.EtFqWYjsFre9uTW5zGXy.wj8rmRcxaa	JAMALUDIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c1711668-aeb3-4e63-ba5a-bf2845201ab7	232410397	$2a$06$UWdayZDw1szxoADqN7E81u4O2/05xCTQ5aSo4I6GURII9qkCQo6D2	KHULAEFAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0505a66a-4bf7-4f9d-830b-2061ad4bc278	232410070	$2a$06$WBxZ2MgUdjjwB4BWUkNwx.OvfQCrnd3PFLilNyvhw30aXDlJ3UqHC	LOVPA MARGIATNA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6fcd6263-1520-47b6-b7cc-709057d52310	232410204	$2a$06$20z0pAlQHXFMWh/efoQwmeues9zpM4BMSIY.VXR5YbVm6nQkJHBZy	M.FATHIR AL ZIQRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
db482753-de29-4d6f-990a-19c26a1cd0db	232410296	$2a$06$LnYjLMTR3pX5RlCc6QpHtOsDKC2ID4YEijojHrx0fLBOavH8eFl7i	MARSHA PEBRIANA RIDWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
65276440-ab85-4c38-a8c2-8ddb78ee59d3	232410072	$2a$06$IiafEU6VOw22NmCrgU0J4.HU9s8A6uFt/CGMMVLFUgqrXUQkZmQDK	MOHAMAD PEBRIANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d7a5262a-94a1-4cdd-b3e9-9f6361e877fa	232410050	$2a$06$Nr.99XAbzmXBimL0bup3h.KrH16uzOD5cTBNt5cfZpwMSmw9c/8ja	MUHAMAD ARIFIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4a2a0890-380a-4675-8944-c683baf00729	232410166	$2a$06$LIdegqKe/MowsmEYuGofJO4S3hQEsIba/6anIn2eE1ZVNJ63gwfBS	MUHAMAD ZALDI AKHYAR	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f19cdaee-7458-4321-b9b5-35eda3775e62	232410278	$2a$06$TD76DIu3jbua4vXoKwh/oObDn95tXcqvRpvSR4c4NfCFLtJx4A/V.	MUHAMMAD RABBANI ILHAM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8dafa312-81e7-4adb-94b6-900da568e419	232410098	$2a$06$hs9ymzGnPyhNU.bAz50tU.YxHbxOjUW8Jan7eBjjLN2Y//33XHXgC	NELI FITRI SARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b0525e3b-1744-49f9-b70a-58dc4177dfbc	232410205	$2a$06$gkChdU31wcFbl3/1zlfV0.Lud8tCxMraT/WdQ3fyMBVOWx/V4Er5C	NUR PURI WULAN DARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5871955d-9148-47f6-9c17-6ad1a355ef42	232410190	$2a$06$P6gVXUwl2VQDlYcoXhHr6eUR0101k.DrM5kWmwLUmAYt2qsGrN1U6	PRABU YUDHISTIRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
23ff6366-b6ca-4d81-82c7-b3ed600c2049	232410273	$2a$06$EAepVJI4lJnmPqMYG1G75O1JYA8Ec3RnktbFlFEgkdo43Ee650J7G	PUTRI INDRAYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f4843ad7-02f1-4165-b695-62bc4dd65b05	232410234	$2a$06$mKZXc0occV2F9zhXvmAJaeDSoLU6anfP7ec6bgoxgclJHnEda6zDm	REVALDI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
27006e0d-57ab-49de-82e7-c8384e6588ac	232410406	$2a$06$PEEQtEyiXY9SuRdXsheGXuHYpvzCu6Gjxe.JW5tQyxKm/rBBY4mjC	REVAN HIFDI HIDAYANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f7698764-8629-4d72-b27c-e735672b9c75	232410113	$2a$06$I2IQST5aFg1PQY4yVSDrC.IXpUqdrOIFZWbvlpmi7OXRXaK1WcNmC	RIANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
aa626a9c-9cac-4fa0-b441-26eb0dd58f4d	232410358	$2a$06$/83R3e4bNwD38x09LqqkOO2calMeibSMBHX6XZXaUzBZ98xAls/S2	SEFIANA KESUMA WARDANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5392e937-ec45-4ff4-bc6d-c6ae050758e5	232410379	$2a$06$71ulQqMfEDp9MGa1cx3zwerGzrPdEkCrr9bunL68/Or8ZBfwomby6	SHOHIBUL ABI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fda7edc2-3066-4885-9bed-cdf08cd5be20	232410421	$2a$06$GYfpPYAklaE56uXkeWSgPOSFuNULVbGShE/1qXM0y7TwAPxUvbGQa	SIGIT	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2d49b15b-3a34-4861-ba44-27d53ad28922	232410202	$2a$06$gcb4/zHJ4VPQ5e1xnh2xx.YBPrcpfnIvi7xnvNjufFHskjnI8Um1C	SITI ANNISAH TUSSA'DIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
34b85e68-1e33-47d4-91a8-7071ee5b3d2d	232410427	$2a$06$RhF6b/BBUFJYCP5j/cft1ux3XV7xre0g0FSHWOfyBMh45IZWSD9xe	SITI ZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
770a72ac-b78a-4fe8-8400-65645ca6a3e5	232410158	$2a$06$Orw2O63QghwswbLRRhbsPu4Ye/RxBesNZe/3efAYRl0CGrH1lkYvy	WULAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2d2733a4-6bdf-490b-89b1-5ba3a1b4c277	232410083	$2a$06$rX6IcDfviylv9NN6JfhsoOwAhxB2adyViEUAK7tdjuWDYH15yfGZ2	ADE SOFYAN RIPALDI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c2c8f34e-91dc-4941-9f80-d56ee34bdd07	232410233	$2a$06$q4lSo3fJTKPcg.aqjJ4U2.3hsLIZ0.vvVV.OjQEi8/bq9ukVwAelu	ADINDA MUTIARA HAMIDAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d9e8aca2-3a53-4af4-9e6d-71d524078595	232410343	$2a$06$2snsD5t6QI.PNrEV.j.rb.24dTTFBS4v/W0k9U57w7zWklrHRJ55G	ALFIAN PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0c3c7f4f-f192-43fa-8eec-bd2fdcfe4dca	232410186	$2a$06$siQWOly/zdFHdZfWyT29CeS//40KxZBcP/JweT0WnaPSGFJjwF/GK	AMELIYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8a04afe8-879b-43cb-81b2-ec8155eedf7f	232410118	$2a$06$gcLS2Ck5eHje6jWi63TRDulrxA3q7UsTlOR4aUCuH4QWVxlolAEQS	ANITA ISABELLA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3cce0c0e-3e1e-4c8d-bda0-61475d0cc4e4	232410264	$2a$06$9fMvkBqRmKTvPj10dI8mdO/ctlsOw4EnbBfCf7M5Yp2soApjgu2Xq	ARMAN SAEPUL MILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6265395c-8ff6-4ca4-bfc5-46c31afc1671	232410025	$2a$06$j9iVuXDXQRvfVWzhKW1YB.DTJlZJlARsZETeJfgDM/t.rEwk10JeO	AULIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
81811377-f48e-4c8e-bd77-e4245eddf77a	232410012	$2a$06$kIcBro9peq8HStLRRv0eeuV/rZXinjIhxbBZZwpXNKHLjcyH8gb4G	CITRA YANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fd08b44a-720c-4a97-9a37-724d9d6ee100	232410129	$2a$06$pEY7E4h.5vVtEP3h0PaPfuyVu8xHbQ0Jx.v1Be9To7ldw3DiWTcXe	DIAN APRILLIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6a368a31-e320-4282-953f-3284c610bc8d	232410022	$2a$06$4SWyESuPAtvYXWCS0RU6W.3UI5RBKwhmrbo1nGNhLmsX4x/csYtSe	EVELYN DESTY ADELLA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0ff4e052-a1fd-4d51-9131-2e185d5ac219	232410322	$2a$06$8411slmcO0/ysT1Q94jS7u9qQK2TRSdVTGaSPc.SEVyQAfwI74Fm6	FAATHIR AWWIBI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4b50cc00-0df7-49c4-ab0c-59bf5e48b0dc	232410051	$2a$06$03biElBh4A5g1ynP/1kwCOsc6ANI8NHfav577lhuBjIxuZtaPp2TW	FAQIH AL IDRUS	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
35b5cfac-1d7f-4a9d-b7f8-a47caf00d094	232410413	$2a$06$2G6ejyTHcdX/4iX8BUjFDOaVMxgudlLXyBkfEss5rwVkPE8Mo/CYu	GADIS SAFUJI NABILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
88b60519-1280-401f-8b13-fb78f7bd89d6	232410222	$2a$06$HRFVDZgIYcXyJSciQF7Vq.76LFPUpGjuYo5dphFeXEfo33IoKmuOy	GALUH PRASETIYA PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ec35da2e-fe35-4b50-ba8b-fd87c738d721	232410121	$2a$06$EJ0NV8vCzwGvnyJmk3dKbeLH9rtva7pQdEuy8LXma446ykLYFyssa	HAZIZAH ALVIAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1b25b9f5-7e90-4415-ad8b-06289133fee7	232410208	$2a$06$3CAqHyIVW/5DumrGhug9T.4NS0TgsGJshZegrG2il9.3P3rMRlSsm	JUWITA KHAELA RAKHMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f5abe0c1-0f4d-445f-b41d-13ef9e7dd5ce	232410243	$2a$06$eHZyWnAUJEzwak5lR/iQC.umTq5bIhPPEQWf8zdufN2Szwsu/L95q	KHUSNUL KHOTIMAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2e86ab72-ddb4-4087-8bf2-d903f4deee22	232410377	$2a$06$1pIVE0YzSbkgICmNrlYJF.x1QAOWYcwBpEU7ov8yAkQRrodFYj4cq	LUQMAN SYAHRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d39ac0b2-cfa5-4a99-a81e-38be3e09aa2b	232410069	$2a$06$DLL4InfkFXDWFKZl.IyGHuK.f9zr6IKU/7WUa7DNlr2aJ5Bx3rN/e	M.FERDIANSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cf6e3fe4-1218-4768-be74-1fb79d24971c	232410287	$2a$06$IvuVAnXSmofG.AupAhKyZe.tv1l/saoKu1PrfrweEiXY04Tw95qzS	MAULIDA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
73594688-5491-4833-afb3-d4b013b93924	232410341	$2a$06$riSQ3X/PRc43Xureduoq0uv2uNuZcRrBcP.MrsvDXTgkwLDKArNkW	MOHAMMAD RISKI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a97b08a2-72cb-4f3c-a5a0-1740e74cc30a	232410368	$2a$06$7hEVzwdJTlrer6wQaLjQE.JHwfcDURFSSHhv72PEhz52Yuyal7jnq	MUHAMAD FATAN FAHMI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
616a26da-e579-4fba-a875-ee64f2b3bde1	232410307	$2a$06$q3opJdKuDASPvMXxvnNzze1wg.IqsAVcbmjyWBu2WrsiYVrEim0Xe	MUHAMMAD CANDRA WIGUNA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
27bdcc15-3cc8-4c53-bf57-f715e6e456a1	232410286	$2a$06$cPEQRpJBKR8efYxHReB6MumqOSVfudHzizKgkRBCPlV7qvfx3dsia	NIZA AKIFAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5ec7787b-67a0-4ddc-ab74-3436f1d5a6d2	232410308	$2a$06$tCn.NdAQMh/4.jYEeJarXuiDVtKA56rWLOubDjmSYME5zyXy3.O3G	NURHAYATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2b0b760c-4565-4ca4-b5cd-78aa61f707c1	232410142	$2a$06$Ae1fQm3Os/mGunnKf0WvXeoaN716kp3QKPal76H2pllzZk7uSdtG6	PUTRI MARYANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5ba3ea85-df73-47e1-a9ff-98f4b0a527a8	232410364	$2a$06$CZo78B1MhjpNGEn1vJG39.ehvUtJwciwpavEcmwHzc9/FambOHBPu	RAHMAT HIDAYAT	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e2faf811-70b0-4f26-bfbb-2a9aab4a2ace	232410052	$2a$06$MQoEvTor4w2EOaBc/1zYV.0bIJY2yJ2rQ8uEdCdIRIgaUmgrStd0G	REVANO CRISTIANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7454ca4e-82cb-440d-b3c7-a9d91f873997	232410197	$2a$06$M3taxaFyIwRZ3WqID1OYwe.kzwqhi9E1Rd3JsXXvDtgaeDHxN9KSa	RISKI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
eb9d2c3a-51e6-488e-b1ea-9e99faa81a90	232410097	$2a$06$ncbF5HZ6FFp8c6Xf8RJwDuv1L6IOkG.pL68SuauMSwILna4JQbKR.	SEKAR PURNAMA SARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f1f9fd2c-3be0-4c2a-a084-95f6a9daad34	232410371	$2a$06$Dx2st2ZoaQ4qqhZ.EMTlmOt.XS2HVtgesjQifl4ZzUc6vXHwDSy2i	SITI ATIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ff9b0ec8-ec12-4536-a302-4295b7493a00	232410376	$2a$06$8gh4vGO01o0.XZsmZKnTC.SO.Rno5jVdQktTQJv1Z/j/rltFsJBBG	SOFI ROHFIATUL	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
56fc645a-a5f6-4fca-b24b-9088607aaedc	232410039	$2a$06$v1pH7w4eOBt9TJUCCD5CnefS6.p/QwQOKSvAd5fr4DmN7hvu/dOT.	UBAEDILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
51f1fe8e-3237-40bc-85e5-7b642afbf7a0	000000005	$2a$06$yC0zYoI6M902mR4hxkjqF.9HqYIimSGaRGb/Ou0cWAjY9DKoNVRGy	VIANDRA YOAN PUTRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8c685026-4a35-43a4-988c-84c78a9bede2	232410323	$2a$06$/BuHQ5zKat/8gXwvHU.fL.iTPTSPPwpxg4dJdAwBlOLepLy3drKZe	WISNU NURHIDAYAT	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
99aa33c5-ac48-44cd-87a7-dd6c83108c83	232410018	$2a$06$RUKL2xt1RUHXBJcd6qAz9.YU.jkkRxJQztY21CoA6uC5PSwoU2e2a	WULAN MUTIARA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6d98e475-82c6-4bb6-a679-9c5d4253a93e	232410136	$2a$06$eLnQLTzB.iC2oCbC6hqW7umhvCjom71b9a2cnC2Fj4smJvzzBszd2	ADITIA RAHMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7b20543e-1516-4433-8244-3116d8907894	232410114	$2a$06$OtHkSLplPesWQFB6gp55s.queTg9/scAXkmkNVHgfN87NR7QT9HBe	AFNI TRI SULISTIYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7601ebf3-f355-4395-8494-ec35d2edd102	232410139	$2a$06$bQHfXJQ2TVayJozkE1qTkeyXb0Y6HOnbU5ZGpaYnMBYe3xwnLbgVW	ALGHIFARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
088d89aa-0e66-4598-81bb-9f36d936ab82	232410157	$2a$06$VrUiQWR9Lch.qtAAGkf9k.ddiLutNJYP6Z0ZIIDFR/BnmIRFIHC02	ANDIEN SYA HIRA DEVI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b663cc1c-ca4e-46df-9626-cbc57e6bbeac	232410023	$2a$06$26CE82MJOXmOboGkWO7PNe5CN/CAzThneRUrX5zlFTjNBVM/4hera	ARINI RAHMAH SURYANTIKA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
bf368a4e-1dc2-4e20-9887-010d2425029d	232410195	$2a$06$DEHywxffO7JZRuycNVovTeqqvqgOohrqlDYxLARrK4mlsJa.ViNSi	AYU LESTARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3440b3bb-d653-4787-a28a-361521c7c3af	232410213	$2a$06$YBl4lc.IN6Bo3Dov0..hBu6PW/3szDSRMdClrtWrjQ9470t7hltTm	CLARISSA FEBRY ANNAET	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ba32ff9b-c43d-47e0-ab9a-affa71c4fd1f	232410161	$2a$06$ZQxfnhYHInXfyqJnsRByTeaocU98SPtq9RoJhqr.6Qt5QEM6YvdS.	DIANI MAYANG SARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9000c6b1-1c06-4e40-8dd9-e5d818080f10	232410053	$2a$06$B74A.kc5XLhhUwxVwzALWOLSr2a3.pZ4zMtGnbfKB845hsbHP80uG	FACHRI ARDIYANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ae61649d-dff2-4eb2-a043-1280cf5f7f98	232410094	$2a$06$8tG.WHxbmcP7KsID9fazne8QahnL22NWSFi.IlRRskfNszrz5tsGK	FANI NUR FADILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b7e80b44-cd2f-45d0-8d43-2e6d5594f7cc	232410381	$2a$06$3cpISRA.s.4q8UYunMHjgOfu626KZpllM/CmqiL1zdhMh.MDwQe26	FARIS RISWANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
82d2f78a-21de-4635-9a2e-4f2b2e334527	232410123	$2a$06$VwxzTSpm1zsf9OQZwRHgn.9b.EBVhrP1Eya4ekl8XXQg0TLrs7n1e	GHINA DWI ASTUTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
640b2658-3afa-4f02-8c0a-cab7193f07f8	232410269	$2a$06$8KiUFSkAdTOefdss3Pgd.uy9/0gN5NfT/Dcq0CO22gCxBD9XXc5Je	HABIB RIJIK	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9cbb2cb3-02a5-4d0e-86e6-9076a21d2bf3	232410326	$2a$06$JcNJlo3BonNCmoJ82QLsVOLPGpPey4mC/FOg2N22sXZ0OujQzW0ES	ICHA FLANELA LESTARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1e0a6dd2-e0dd-4068-b275-b8ff959b380c	232410336	$2a$06$lkFNACqW4DxnujfyNBKv4ugq.gB22JvRXRQEGxRkv8qBILoBMi786	KANA JELITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ac26b5b7-882b-4f52-a4b0-3b76df630a4b	232410061	$2a$06$PB1xsYnM339zfrD4tqG1feOeEopDAoXxpXo20GdmNO7B8ORPy8Mm2	KIKI MUFAQIRO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c88c6373-ede8-4b49-96ad-1acf32304ae1	232410227	$2a$06$V2RkWHAzZ6fDAI..xniisu3n7UZRLS.xwq1opPjcfoGhosjWxA5fC	M. ERWIN RAHMA WIJAYA RAKSA W.	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e5dd7086-57ef-4970-a885-e4e1b11e4a75	232410167	$2a$06$sRWuaJvVzB6hxxsPv6U76.cTpo35h2g3zxi0CB0lf28v92NiqxIoy	MARVIN ADI ANTO HAVIZ PANJI PRAYOGA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
12616c77-5ebf-4c2f-b116-1fad5b944963	232410090	$2a$06$17gHu2h3otkey68EkYXzmO78O21LVAfw/6WhrXhBPkLaEIJbOZDpO	MAYSICKA AULIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7ce7d1ba-8a1d-486d-b0e0-de21b8a23915	232410085	$2a$06$3ogQ0FJGARodaefouCpvdeeE.aIAbj7HRIqNIPKaQ.GVbm1d9uqxq	MOHAMMAD SAVIK MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4c23ff4c-8006-4f00-b444-860f91849174	232410350	$2a$06$yT.w9p.ZHUCpPU7hGOz8wONIVcJTdKpSWjB9nILdRi6GxSJzSJFP6	MUH SYAUKANI ROHMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6828e802-753f-438b-8fb6-82dd96aa5044	232410389	$2a$06$GxANQyz.KqeJijdQY5ugBeqTNCnQQQ4GOS93/yqufkEGeHz1GV1rO	MUHAMMAD FAIZ HAKIM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7f0da600-c18f-4d6d-a24c-b20ac382276d	232410354	$2a$06$bprsdgDtblGnhvo5TdX4NO2QkTDx4grdQrnAp4lotZwn64joeNSmu	NAYO SUNARYO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
daceaaf5-4a0b-4084-a29d-c130afc6ddfc	242511433	$2a$06$oyTGLmERXY3xRUCswzMRJerVH66.Dro5emUS.hFS203XfrUK/ze7W	NURHABI'I JUNIOR	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
44ad6b61-bb6b-4ef1-8ca0-797f501688e2	232410232	$2a$06$R4ruaj0I84h76VRXBtWZY.o0JoRFKl.Falu8VFXsMRdHB.6npwcdm	NURKASIRO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
44e970e9-0289-44af-abdb-c1b5ffafa830	232410410	$2a$06$oNIkz92hkedywiEo/Mbr9.zAAHUqnajjCK1BJbrzDk40jttQb9/1O	RASYA SAYYIDINA ALI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fa339f5b-6c35-4082-97ee-735b51405060	232410266	$2a$06$tAfsjd/TXyjiSnvpGlYr4.lgLlJBg23gwAEV.83njvlQsm/.sKE9O	RATIH SELA AGUSTIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d5072421-20e0-4898-ade0-50af53e97e78	232410285	$2a$06$0cYhQnSQkBHpSMKUezolTO8qbA8KQqdICwNgRzdUUxm9BM2FDA0S6	RIFKI NURPRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
32e45750-9e14-46d5-9669-c8612301d980	232410119	$2a$06$YULcQ5ykXe8scu6QPOoyreSguT2Fmk0iYnHXlJcj7H/fmRDIJdwjq	RUBI RAHMA YANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8f8708b4-63c3-4ce2-8035-a9a71f0861d2	232410003	$2a$06$oZ4Gb.wY3xAOx2ouPjxwnOPNhoVZqLFtmbTTMkOzWgvRp/1Pd7Z1y	SENIAWATI HARUN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
917c9dd8-d30f-4665-b847-e7ed9ade17ff	232410414	$2a$06$oWbepVwgmuVGB4FTuxa06.ZZIvEi/LLKZMbMoV8EyId0AEONdbBg6	SITI FADILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9e926c3b-142c-438f-97fc-227d3aad37c4	232410316	$2a$06$.QjSGAqAZWq46wv5MkyVKuWRF3LvHaK.PKFD8Gu3I5vbmdeEUP.S.	SOFIYANTI RAMADANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
aac949b7-6b97-4cc0-9d5d-3b6a127a2856	232410002	$2a$06$LbwS3.UJufmOtxa6VCJXmeD4O4fU6Yd3LiD80rvQ6xmExsTYCRORC	WAHYU SYAFIF RASIDI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5adf1cca-3339-4de6-b0e6-aa65f078f8c6	232410318	$2a$06$isHiHSXltjeXN5NDN13SdudLJ69mxIiXQpsHBESj/.bki9C9rGytW	ZAENAL ABIDIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
681bb432-ecbf-4755-a95f-ac24ce5d1d06	232410033	$2a$06$0ZzNSkP2kpCICeWVzFyRROVgn6b6Nnpl7dqu./jfm5X22K0OnAGDC	ZAHRA ABELIA HAKIM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e1f818ce-d9cd-43be-81df-b9772698e5c6	232410255	$2a$06$/AdieVkd.0qFEpwyh0NfRuLWqCX9y1Te.Pg3XLuV6Xe19PBIs1XGm	ADITIYA PRABOWO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e8752dc7-2b86-477a-ab5f-b81b92f97e61	232410305	$2a$06$NgIl0OKTlUNmqs8RNsRal.pFZYQAu1ECLEnrs5et5mJ.FqMlpl/sa	AI MARISKA HARAHAP	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3a01aece-4fe3-4ef6-857d-e89469498a7e	232410007	$2a$06$RI8X2fddGPc7W9Y2Sa71aeznXJ1mKamryICA/YedadFJPQHTY749.	ANDHIKA RIZQI KARTONO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
aa248280-fbcf-467a-bfd6-41d9dde7ed76	232410107	$2a$06$eXvQSSmQ50gLg9yyWlXGfO3G2NDNx7uZxSxoJJqRImSzXg5IAym.W	ANGGI HARYANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
67a19a1e-6740-4884-8ee1-31200f07a079	232410372	$2a$06$pKtXSitWK6LrgZNDBsXQ1OtA0pAxffxH5o/y02.thY2uHBINpgxHe	ASYFATUL KAMILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7784cab2-6722-486b-b3e3-2609806e10a5	232410327	$2a$06$Bmy/BwRXSRjckh0AGr4Xou8ISc456oIBZwaIgKSvKdPnUGaBG9uo.	AYU SEKAR RANG RANG	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e3d58db1-0671-4160-82cd-e01d3408ee7b	232410182	$2a$06$8NF0fBKFiHtwlbEE8sPcAe4iE6bY48r/X7MDOzCwPlIZs4Vj.ZUhO	DAFFA DHIMAS AL - ATTAR	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3010b69e-a42f-4c94-b947-e63ef95114f4	232410145	$2a$06$daIwmK5ImnhBbxG0E59fm.yxg/Azvf3W6UEBkeYuksGVbe932bZ76	DELLA ALFIANTI PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b4279b91-79a3-4074-99fb-9c4de67ae3a6	232410027	$2a$06$iPKvCEq8JcXGVW.pY4AMQuXttF6R2mPrCuOhlZ2ge8sF2EVrq1R1q	DINDA EKA PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9f33f33d-bf18-47e4-847b-de29d05d550c	232410184	$2a$06$eUckVICcKZA295pE1FixMebwx1UM3z2LVPovNi/lh/zaWd8y2RiXC	FAHRI RAMADANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d6cc783c-1041-44e6-b3d7-592a20c4bdd7	232410220	$2a$06$jdsKvt96joi/LnXbFnlcge3CpqkdFUNspADE0T6MqjrrxKnCfTik.	FATIKH RAMADHAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1eea9bfc-cc77-4985-b21b-10012c8989ed	232410317	$2a$06$lfDgctoqKROVsqAA9/Srm.RP8mbl5KYXiorutnOd5kitu.YlIZs9.	FAURA ASSAYIDHATUM MUTIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
dfb16539-6fbf-4a17-89c9-cf0e5c6c8afb	232410169	$2a$06$u1TNX9Up7G6X5Gw03ol1t.Jfcf/uctA2NqK2cUVGlG15httA8M3DC	GHIYAST LAYLAH AREZ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a794c5b1-1fcf-4fb8-bf61-34ae8ce77a8a	232410031	$2a$06$jU..3.haxl/VdJrZi6Cj4eDMVkoqX.Wtna9VvZ79QIb.frWEPYFYe	ICHA FLORENCIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
38123355-f28b-4434-92f7-414f6f93c2f1	232410135	$2a$06$nR3lY/7aBpYd66rnYvce7ekYAEVlhfPcelPYgACdX9/Ic9pODIQxy	ISHAQUL MUBAROQ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6e8e070c-93a8-42b9-b830-d5817ba22b1d	232410231	$2a$06$D3356RbMtbfsTjPwf9yz1ObfAmaEQAVW8YGvRXVmqok5hBUuMjT7.	KARTINI ZULFA INDANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5a418d43-e128-4663-82a9-997092545d28	232410268	$2a$06$0xIWG7kv1Sax9r39nT5VaewH.flAI8vYxUNOOeIgAoQJUf0QsOa/K	M. PRADITA HABIBILLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1bf99b84-aff9-4c58-95df-127446ad43d8	232410378	$2a$06$Ywtkd1BP4AMGuGB/mBUhduayuIb4mf7zbAtwpsXGUJ3OFLw0rReES	MEI LINDA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9d3aa582-088a-4280-9562-9c7463227b24	232410131	$2a$06$PSlFyftzqpF9ackahy6MceXEe7qIhlApYc3e/tv7YxLMkCf5yQW2q	MOCH FAISAL ASSIDQI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
16de9188-5c29-4a30-ae44-a9d5acc530d1	232410418	$2a$06$sUATRnATZ96p6rE1Dwn2VOKoqcxG7ddHhJGMR6PWiz6aSOw21yGom	MUHAMAD FEBRIO RIZKI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
334c083d-da4b-4abf-a245-6700eceb8f5f	232410352	$2a$06$R7yzXHNi3NNZgcT9GmzjLu9bszgn7Be3fNxe4vRlAQh.EmoSMNDte	MUHAMAD GALIH HERDIYANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
491242f5-795c-4cfb-a8aa-1f644d698045	232410383	$2a$06$cgqMW5HhU02vpHOJQmGLTetsLVMZ.dtUV4lmCJ3RGDdyyeE8FoEJ2	MUHAMMAD FALIH ARIQ YANUAR	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
afaf55ce-400d-445a-87f4-55ee2ad71cac	232410398	$2a$06$/AsqLqsS2xxhdhp1XK4rUeIfVcLODK.HJAeIlT/S0Buv5Y0RElWv6	NUNIK HANDAYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ca84cce7-c589-4601-87c7-327aecab5676	232410120	$2a$06$hfyiAguxBrdwdPlpm6/X5eHq2dhDTJxPDqCuPs.M43xWSqpnkdnwq	NURMALA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
37417581-cb56-4844-a85d-4ddc4f2d4a68	232410171	$2a$06$vBzWPB2EXxPXWgv8ug6V9eFZQ93WxsJN2RsiM8KxrJ.YaYguuiKwy	OKAN SYAUKANI ROHMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b47bcf29-1c7d-4471-b30c-dd0f5374aa5d	232410036	$2a$06$MQI/T52.DZPUKnJYJN.yyOVbw23GMM/U/iY0t6SP2wy9zzMxkVwSC	REINKA PERTIWI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6429f329-445d-43dc-bf79-630eb4703901	232410068	$2a$06$Svu5cRB6HJA5o10AEYwliuebBYzybjPIWxM1GYbKlRat4C70x4ROS	RENOV AROFI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1dc5c308-0512-4b4f-9537-6016e0a8609c	232410137	$2a$06$epGqqKnJmRtRL1QcDB/5.OLXvU0oUPIBgnbkG16XAN/C20dNFyAJa	SALMA WISHESA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8a25d36c-4a63-495f-8b64-dc978151177d	232410301	$2a$06$Uv/16IwdRvOc7jMa3EzLHu66Jnj.HlV90lV5GFpeS7QSO1hYtDsWG	SERUNI DININGRUM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3f70f0b6-900b-4641-8b14-32b37bbfe5a5	232410337	$2a$06$yb6xgzkHtNFm75MmhJTfi.Src2AEtjngLpCNfpq9FRWW9z/5c5vJq	SITI HALIMAH TUSA'DIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
28ae50e6-0023-4122-af69-287a410700be	232410238	$2a$06$IPEGawC08Jav2TI0sZUFNOucnQKad3aN64KE0jgFK9Z0KZd5Rx8hS	SUCI DEWI KINASIH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
49b183d5-8387-451f-93b2-41cd7e56d904	232410112	$2a$06$O8NsY8y97ppko292pktwruHAseMT1PjyemZwJPYYAg3T5MdGVwaAi	WULAN NURHASANAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
42f2c928-fe17-4255-a161-a87cc6621c62	232410218	$2a$06$VVh2WhQOisxESqREyg45.unU0yLjqV2OKagv230iAuyaxrlHQi1ce	ZAHRATUS SITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5e7fb606-bb69-4387-9f21-05990c5435bd	232410102	$2a$06$Y5w2SlzxhjHn03KWikLB1.lYuMkEwC2voGFlauPif0jnBwnaQfhtS	ZAHROTUL HIM'MAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d34572ec-69e2-40a9-b118-472f7050b0e3	232410048	$2a$06$0WLAOdFEm7bzr7O1GQpx/OslWedLwkSR6uOtDawu2V8iEp0Qj6bHa	AGUS SUWANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e18bb35e-d515-49ee-a7b8-c361b242a13d	232410134	$2a$06$JVmskJo5/OIapYknJP6dge23JNtYb5GsXGktecF05fDd9TFZbLOeS	AIDAH GHINACAHYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2c973ca0-d752-4d17-92fe-c749d5dda471	232410346	$2a$06$gS0FoQ/bvJ2mOvPxa/4v8eGevN9Uaqahhbf/YvucPbdzRs7VvS596	ANDREAN RAMADANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
56c3d84f-bbb0-49f4-95f3-fdf6a230bf72	232410240	$2a$06$1ttEvuJsKuAlbUHY54rZvOlX7SIFNXX4qSWvLyesK81C/1tNs9ri.	ANGGUN DIANISA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
978bcad8-00a0-499b-bef2-57b6e1fbba1e	242511434	$2a$06$Shz59A7j29pVGWtRe4QR6OFtz27vi8.7r3BBRtqdB0Dfvh/UcJu82	ANIS SABILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b39e7fc1-e045-479e-b15e-a8e06f92af4e	232410276	$2a$06$KewwQIxvE/mxynu8cVZGXuBtyYKJHAGYBB5U3bORWz4SNVssBiTvq	ATHA NABILA AUFAA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1e23698e-a4ea-4694-b770-788d29f124b5	242511435	$2a$06$VXnmFE9qfTWQgT8pTjUmROsxiOuGaD6O.Q0nr1AhcEyZCy9A2f4RS	AZMI ALMER ZAMIL	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2bea75e7-0265-4de6-8d3e-2c4f5c5874f7	232410320	$2a$06$oR655JX8xoAxdl4yHycnzeuhpr/zqMMKX28DtR6gpCCLZxoqfMvEu	BELLA SAFITRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3936519d-a2a6-4525-b5a6-2ed22316fc1c	232410210	$2a$06$rKmvzcn5YA0jkIZQYdFyVOhbMmig4I41eknvcRO77jBHIZV8lndM.	DANU ARDANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9bfdbe74-13ec-44d3-b433-423fdbc66af0	232410127	$2a$06$JumA8Wlaa2zo549a9LRxReAf.z/.3OT.FSeOBV1LLNKKMha85IwBS	DESTI NUR WANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
05390052-6fe0-42c0-ae96-9621c987130d	232410356	$2a$06$tcRv1Q8PjH77eOWs9FslQ.4m4zlabsRCqmnrakYtJChHiFgRNmn1e	DILLA RAJALINGGIH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
41167499-9aa1-41c8-a307-96011b9a5702	232410230	$2a$06$mfDLFphROV1ElwlgVWDwtelOsA0Fs1tI0Qm7PY9.JRwQd7B2EtsGC	DINI ANDAYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
84210cf5-a27b-4f25-bd2a-5dbc394c6f18	232410422	$2a$06$3e/TKn55M/hpJBBzuInBueFDpMObd33NXPQIuqBNcdTe/xf00dVcK	FAHRI RIZKI DWI PUTRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a4c1811c-21e0-4c59-b5d7-f491e9d74fed	232410293	$2a$06$HOoDJQdI58y0zJnDI.TXU.8cU6Cf4wtORylOA0OxhJ7EFPD.L672m	FEBRIAN DWI ANDIKA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
687204e2-9a75-4cca-bdb1-a51f429906fb	232410146	$2a$06$c2C5twxO6lHdrtqo6D0XuOrRthlqmPS3x5zGk4UNMM0HYaxZwmnLe	FERENNIKA ADILLAH SARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fb11fd16-c607-41ca-be9c-a7916114f953	232410156	$2a$06$Oe48pf3SrfwHUzRENZ7Jkugk.03sbyBiyIUwjSI48dos98s.F6s0q	FIRGIE ADINDA DAMAYANTA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6a33a29d-00a7-42f4-81e9-e87be63ee7ee	232410199	$2a$06$kZh7SkzpVhxpgitwSITe1uLSNlr66F4uPfAm0IaTZ2aSTQdLtdgLq	HAFIZZA NUR SYAFA'AH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
82a792e0-c4e6-4af1-952a-133757ee27b6	232410177	$2a$06$b3lXr6p7ADSs7Oe/DhsSS.4k1zQLQPP3sOVsU57nIGGz0aw4g/QLG	IMAS MASRIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
45684b6d-255b-4ade-953a-aef2cedf98b9	232410079	$2a$06$SqS2K5dwN9uBmiUsApVvuu/jSBP3iK3UD9eLH7TjhdE6Aq/9dkFyK	KEILA SYAFA AZZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fedef338-f40a-4463-aa89-87c9a841b1cf	232410148	$2a$06$oGs2S3rTXeNIvUGfGc7sMOL/o.AHVbF8kw27oLBwMaNsjCJkr29Um	LUNA AFWA MUNTAZAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cfc6d496-7580-42d0-ad08-2e91a8e58beb	232410078	$2a$06$sdSxTwykqJOF2UB67ulAR.xCA0ekajM9KKJ7xn/mAVQZM/u6GYWI2	M.ABDUL KODIR JAELANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
51d397a1-a15c-4251-ae39-95ed2bf1bcbb	232410143	$2a$06$5pXrGBHQDrZRHkDQ9NyyxuttAUmjFlBIVUTL7Cop6BiuRjNy2oEd2	MOCHAMAD FAUZAN NABHAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a5fe3fe9-5013-410e-9270-3bee04bc3aae	232410151	$2a$06$cJj5BoljWXjSsut0anEkUu358fvRjnu8G.cfSTqyfB1mRJ1E5JOHC	MUHAMAD ANDI MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
17bcfede-1a73-4755-b398-892351361b57	232410115	$2a$06$XiF93Es2b8QVluBa1ZLIee3gpM1VsIJLo8C02zjbanps.OoO53x7G	MUHAMAD RIZKI ALFIANSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9b7d36e1-8735-4573-bb51-ce4af0773c61	232410058	$2a$06$jUzP.yw3br9oPz3pkw7IG.KpKS0xdvl1Xz1XHBq89dxCI0pPfF2H6	MUHAMMAD NAJIB	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1c995ba6-9b6f-49d4-97aa-f246ecc19f4b	232410333	$2a$06$.MKsBTcLj7E08Yw4irIC/e0YwexOJgaOyLMYzKTQC5vbluULowpC6	NAZWA ALI NURFAKHSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0c205e19-2965-4900-8f95-915be03c1068	232410360	$2a$06$9xIZFb0.gpHcZOc7qicLWOkbdrLEjpo6cO/6ZFuXAK49u1ATqwsm.	NUR NAJMA JAMILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7f744c1c-adcb-4331-873b-cf4a0ca522f7	232410091	$2a$06$bNPEGlvpX4gGPX7.ty5y9uoUCopB84uDf1d3cPjuu34L1RH94kM4G	PANDU MULYAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7aa6a67e-9d28-407d-b554-3b3869cb9e14	232410108	$2a$06$y/x5KR3.Gk2omthLlVNGwe4BHpMORI56X3U.tAnxsnUOlf0bHebMO	PUTRI ABILLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4b15d10d-7c86-440f-b193-9cc583e134bb	232410385	$2a$06$XzibDIWLGQSKXYubrZk5B.e3V14k8nRwlJualpgNi3bZyrqrdtEr2	RESTI AGUSTIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a62ca23b-ed4f-448d-ab9e-abaabcb9934c	232410198	$2a$06$/p1Jfz5/emxWq6QOaujPcu8/orTDfJpCEG08yotpJGatH11jP4zNS	SALWATUZZALFA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
576f22e8-24d8-4aeb-b3e8-7a5ff70b8f66	232410064	$2a$06$nIrPrv/uaq/J.emd0.DssunY0anOG6KQw3mE2TVjRar6XfauiKFEy	SHEVILLA NUWI APRILASYANNI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0d5cffbf-6b9e-4564-9c84-ed1f62b727e0	232410089	$2a$06$DAqCBHh0PxtaMUa6j9zZmuXGGk3pBHIw5SWlLoVn7t/JPQDVDC40C	SITI KHODIJAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4c443130-0bf3-4bbc-8122-594fdf55ce56	232410407	$2a$06$d7kwaLB8lw4jvU9dHJXoLOnLUJriQ/1WpJ89dw2.p1gCXoJ0gFb0.	SUCI NUR MAULUDIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c57efd4f-14a6-4743-96ad-709269ea6187	232410284	$2a$06$hVa16ubmu/ylTQ9iR79tHOrlIhyDSKAglBE6yS3qd8KGf9se.tQLC	ZAHRA NAYLA SALSABILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5869aef7-2782-4f3d-b3ae-ba450ad53985	232410067	$2a$06$jEPWmOK1sL3EZQJkvzw20e1zTCgcm8cu/TV/acjLdbKIliRqMTjEO	ZASKIYAH NURROHMAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
38401c9e-a0c2-4bfc-8af7-d50040261d27	232410324	$2a$06$7PSIpW8TEB/icQKzp32J1eW/HU95ASRaZW0fy9qjty4V7SShaxfXe	AGISNA AULIA RAMADHANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
37adaac5-e357-44ae-bd99-19cbcb08a6c3	232410282	$2a$06$qS/0JcsbxSyE2jwb.LToveQbv.k/Qc4NMGWbt5Ep4aPpm/XEf2JD6	AIKO ISLAMI PUTRA NUGROHO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
49c5f228-1475-4713-944f-aa83e5a092c6	232410004	$2a$06$UQeauBOTd/udEYbsXPl1XOkDWa1yFNS4tNWDJicHOUqa6dTe23Fe2	ANALIN LUMANDA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5fc4ee66-8473-4946-a8ec-9e061239a117	232410357	$2a$06$x/3E4nhHwEYj5RvT/2MNk.RfFpBZmknEOLJILuz/Q0XcnneeM4O9.	ANDHIKA GIART AKHMAD	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5d0d9605-47ea-4567-a681-be362e6dc100	232410313	$2a$06$cG8.3flAMkNL.wTPFohkzuOghg9ihfAtS4c8qwDizMStiUQPTRhSS	ANISA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8c32480e-68ee-4634-9d77-d9f04504ef78	232410056	$2a$06$H5n2/IRkNOPHXzC4XEkC2.8umKa/P2oLUvumvBUP1dIxJuZjrUEUq	CANTIK OCTAVYANITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
99513535-0923-40cf-a346-e2098fca7acb	232410001	$2a$06$TPWxUDaI4L8v8gx7C0zHyOXABfx60cgZlH4.qWc3Cp7dCQ6IpYxBa	DAFA BAKHITS OTOREOS	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
24d10c09-9956-4134-9e25-c0459baddef1	232410189	$2a$06$3OgrHHJAzlaPdGtVH7Nlf.tFWDuS46DiLIGP/d3JdGpVAiIUkb362	DELA SABRINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
632f5997-ec5b-4f67-9d3f-4d11f9d4c960	232410125	$2a$06$qeowY9zjwfxsZG5YfnbBQuO3/V9wJMSz5StwvUm2Ge29HfNDKXEZu	DINDA CITRA LESTARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7c9a1971-38e5-4b5a-a1d8-001e186eb324	232410428	$2a$06$pxbbNcvy0bz83ZCuviRfi.P1MWkllAUe9suIlBtUB5SCG3tnV1EWm	DJAGAT AWAN WANGSADWIPRADJA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5a8a07a8-828a-44ac-a214-2ec64abd4a3b	232410416	$2a$06$lwfdvJC317J6qWhMn20SV.SvD6T4luKvO7BwaW5StC5JkhJ2yH.ri	ERLANGGA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7639bd28-2246-4182-bf5f-09800139dcbf	232410179	$2a$06$wI8jggqpLgmIDMCEbrwl2OrTmjhCi3xrmlHa0ZKzUf.WkKfc1ddEC	FIKRI SANI MUHAMMAD	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d38c1c64-47c9-4794-b796-8cab6c469ffb	232410082	$2a$06$P473xNB5V212JTbEHaYJC.HDVQMNmn1.UnrPiVHRb1wPafjXeprae	GELBY GRAISYLA DILFINA MILSY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b6d0d9a4-7863-428f-8ac8-04f9a75f3fbf	232410016	$2a$06$2ZXQxYohoMUhUbJibdwiXerIxb8LBdlv0bFfE0unMXv57YfhpjxyK	IMAM SIBLI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2d62d023-4237-425b-8674-99f6e5c38013	232410298	$2a$06$Mf5XEXlk7u/cbrmYhar7Vu/FwgEtNcg81zetONCrb9xYTXez7C5P6	INTAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
88031d15-00a0-4827-9f81-9166b126e69b	232410035	$2a$06$x0Nawzr9ezW5abNurJeqJeOqctJ3NssPginMbdoicEF2M/SccNi8G	IRNA SARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
75017d2a-41cd-4020-abc2-f57c38ded1f9	232410043	$2a$06$VbZ9PszhX88EwQj.QMMCxeph/8Pmr1.k00382FQM57qqJuYKygWMm	KHAYLA SARY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
691e5892-f136-4161-80c8-c269e162ac13	232410147	$2a$06$496G3ZbHgBzag.O9mgC6HuudWtVAxD9cB06YmGES/ffAx2K9SovSu	LUSI ANDRIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0f732cc8-6cdb-456d-90fb-a1148d88385e	232410219	$2a$06$GUX53FjiBPM0MtAuWo4kH.I85cL4lI3Mu1jWv3G1lvlcsA6yu1fVC	MIQDAD ATHIF	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c2e2fbcf-5e10-4a4f-997c-5360f8fb5eb6	232410259	$2a$06$GTzpTnjsPPqkOpiznGUJ5uUrzVyyWlLj1w2dT0E/XaL06m97IHHmK	MOHAMMAD RACHMAN ADITYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
54d61627-97a8-4378-953c-db096aa034a2	232410044	$2a$06$BX5OfcmOJDYXlpIWb0ms6Oma2f7W3Hk101agXnLyIO5NazRE8a17a	MUHAMAD RAYHAN ADITHIA P.	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
bcfe85d1-98ef-4766-bde4-bc371e8737d3	232410013	$2a$06$.l5QKh4QxNOyT93y5Q5kqOlx56SahGGQgC.ZhVW8LDQjKV8pSYxAG	MUHAMAD SIGIT MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2a1b0514-b0f5-42f4-9440-3b5b733753c3	232410021	$2a$06$ayKYeBDPjq3dTbhtvlZjk.mcp/ad9Tw84mRohoyQkudmAu5ktsfC.	MUHAMMAD FARHAN HANAFI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0a61877e-6d59-427d-9a3b-7ba4d547c603	232410150	$2a$06$psF93Ni8TqJIx6Ob4IzzCOeaFjvwea13aBfoU2.DOSJAad3bZI/3G	NADIA RAHMATUL MAULIDA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1efca2fc-907d-4365-903d-e7681ca5aa57	232410110	$2a$06$8Q0.CxwJ5dMRlVjGgENiW.Z9kLSAbL5UGj40.UY6hOMeIH5V18WOC	NATASA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
dff75417-1074-44d1-b0d2-08c70c8043f5	232410155	$2a$06$ewtFGIdLPSMxUSsbTS3fmuL32z8ByscLSLB4PPSliLbHnyrpHHMKu	NAYLA RIKA HARIYANTO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
75b8e05c-690f-4fc8-bc82-e9022805ac38	232410084	$2a$06$i09WzKdQKWgTHaSj2QZHKOc4AhQAqo8bypCgyUlmQ5/O2/jeJbkQm	NEZA APRILIA ANITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c1d632b5-d745-4f0e-bb9e-3e0c60dd8693	232410152	$2a$06$fAzWgGJqavQrOrHMA6SvH.v3GnJiRkB3mBQ6daKQWqtcuDrJVJ4TO	OKTAVIA AMFELI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
109fc578-7856-406e-a6bf-bf770bb8834a	232410246	$2a$06$snPR6G4P1tWzBWQ0iJLii.Yo/HK5cXkMqLlnLMgDMAeD4ZX1Cu7Na	REIHAN MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ff13b0e9-f540-4cc4-9343-246cd1032313	232410138	$2a$06$y0tgJgTcjkgF/eO3hc46MOw/YGgSl.apjoMltTKFDzCV9bXUwDQ5K	SEPTIA RAMADHANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5e18fb56-4a5a-4f67-84d0-adb751f37250	232410245	$2a$06$AzrZfxyqC7Qkq6bM4cNXt.EX.Prw0L3B4LnKSEw5WVi4TSSDh5Ba2	SHILLA DWI ALZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8cc33bf9-3536-4811-8c31-db30c2c1c60d	232410303	$2a$06$F27n33KDzmSsLm0qwHHWD.yhApzKqSCnm3qENDPJBtEfJtqKWHihC	SOFIA LAZIBA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
449a7772-8e61-4e83-b20c-313833a20604	232410244	$2a$06$gcf0darfBJHggFUZVkdOTunvmtZM6IouQQQqoGaNp7OG.i5eqZ3m.	SYIFA ANGGRAENI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b2b9a025-c3fa-47b5-87fb-15efe43af9aa	232410104	$2a$06$U26coVN8g8.IGA7EgfQAKO/8Wuekru2qszDEQQAmmszlSey11WPaK	TAJRIUL ZIDDAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
83f7af41-8375-4715-bc44-994656ea36a4	232410014	$2a$06$GsZ4Xl/AlAjrxd6eP6vtg.am6A7U21oNOqQDP1kwKfp7FrZMifWpC	TIARA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
87bb1f3d-eaec-49c7-ac91-3fda10b33a3f	232410093	$2a$06$Ic10XBaVe8W.hipZJgyS/uu9xgdIg/n5VKiU3dpT9gxULgxP5i0iO	VEGA DWI FELICIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e389ea37-f4fe-4f33-a8c2-25b5d24c4627	232410394	$2a$06$4KiNJ52bZdEsAist7.OmPeZrFERodkvys21.KJ6YYGoYdUT8YHkAu	ADINDA FITRI OCTAVIANI RUSWANDI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
87222553-4f48-4773-b9d9-55acd726edbd	232410209	$2a$06$sFBJaeQ9aLQmwFTh70BLe.ZH5Ec.qXanma18jwBglBk54zLgcr5RS	AL KHAIRA RAMADHANI SUKARNA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
be659bdb-7837-4b92-9c99-248e247cb684	232410126	$2a$06$9WyHWS4iZiCVuEtl0jRPlOPLX0xBE12kePD5iUmU7DuuxxaXSP77.	ALPHASYA ALIF ABDI WIBAWA DARAJAT	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1b18d3b7-5e95-49a9-884e-d2d87df98b9a	232410294	$2a$06$Vjvp6k2rzXD7cxx7qk927uHjuUS7ES1S72IGyUNei9HsavqjdYwom	ANASTASYA PUTRI SASIKIRANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
bff92cb8-5c76-4a68-b0f0-66e1a541d52a	232410030	$2a$06$ztPb1A44h8YdvNlqFfuUgOJmeA7z7jcqUIB3PoJDWC/itLiGeRnb2	ARRUM LESTARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
27eb1239-080c-48a5-8242-73ff01765066	232410040	$2a$06$qmxTuzYx1CfpGWUBeXbP/eBN9TELlLygWpGA5fR0v0zpPA2UGP1.K	AYUNDA SELANINGRUM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
111d53f5-540d-498a-9667-74513a1e711e	232410431	$2a$06$wF9DS/1FnmW/6JivXPKjc.vMMVTq6P9SzDRt2UbouHHm.cD7beWHK	BRILLIAN FITRA IBNA MUKHIBULLOH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f16f7d75-7d71-4d31-b75b-d4fca99e2352	232410334	$2a$06$mcAMfhsVQ9eHBdjXrzF7jOEac5naEx0Gsfc85nem6swak.9CE/keW	DAVID	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
52846663-fa30-476d-b131-70cb3b073b56	232410403	$2a$06$II9Bfso7cWeOWJO53odW2ee5myqyw8DISpApQIznVI6WYtfoNL4CC	DESI RAHAYU SAPUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
908fb1d6-0978-4b2f-b653-6fbf75bdd109	232410206	$2a$06$SNGd0yGWcfCX/IITrzFd.OeN7KeYzChFHRrm3do3yp2RconlsQOKy	EGA AGUNG PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
57ee8c4f-79ac-4427-bee5-c555cb77c9d2	232410103	$2a$06$.h5tagKBoTGVQ2l8eOyVx./642UNKBn2r7I9kyRVOIs0WU6GQNlDu	FANJI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
808ba4b8-604f-4bf9-bbf3-95349c2cf363	232410365	$2a$06$gDq09XcN3kTtm.BO8FyOZOFTshP/6vKSJCPtbmbzd27BBiZkuXcma	FARELIA GUSTIANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4b457543-4b36-418d-8b9d-6d2eb84ddda4	242511436	$2a$06$yGN8MEw391fU8o0z2zAwkeM0hnJRUyXLwio1RRa1Xx.1ux/C4mG06	FARHAT FATHI ALGIFARY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
79d1bbb6-97da-48cd-99f7-60ff00fb7e37	232410348	$2a$06$QesvLAOPC37hiTy3PDu8QO40levct9wl6zEolRueGuik3UCHxhJ6.	FILDA AURIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5743b1e5-e7d9-4f9b-bf77-0502522a2197	232410405	$2a$06$UcuAdGVsaWg56M9T7ZnhOuEG.3KQEuzawh3OkLzPxWqdckTHWlaMe	JELITA SAVIRA MAHARANI AGUSTIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cc029751-727c-46af-819a-0349c43cd230	232410280	$2a$06$4n9GRNlOuYZnUAG.kalEkux/VmTrW2fOE7cPM6C1gRKljmW8aQAS.	KHAYYARAH ALIMAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ce3d9817-dc7e-407e-81dd-61b916aed89c	232410214	$2a$06$K5Cmg3ziirX9LKrwFEqluOo1WAL4ZwjuL4cHIL07dhJ1X8zOpHRkG	LAYUNG SEGARA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
64127a34-d91c-4603-8401-a99bb414d0ea	232410309	$2a$06$2jculRZh4hbHsLlWyDIhiugJxp35Ml5ZT7yc3bMcSu40wiqiYKVKu	MUHAMAD ARIS ALAMSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5910e1de-d3cb-4196-82ae-9f7280e05b32	232410302	$2a$06$EqITQA5QVB.m.1UYN5O2TuHB1c4bTazkNXdzkLOvUGnFe0OGPLh6S	MUHAMAD RIZKI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a3d76058-5269-4bf4-b0ce-8c6531b55c32	232410181	$2a$06$8SkBv57a18GT0FPRtEEIg.FkTB6pxr9ffAr0eNMdaKAN3mZ4Zeb3i	MUHAMMAD AZIZ ZAHRAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
43fad26a-0aef-451f-869f-429cc27e3636	232410260	$2a$06$IBznvq1fL9vsco7nR6UkQul5EJRNgZmVOFEsb64L.YH78RfbitxCa	MUTIYA ALFATILLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
01fe5994-747d-442c-a34f-eca86e9dcae6	232410359	$2a$06$xfTFO5fvR.TC1MU1kj9p9efqb8hQduFatfSftsRjBockHraJ85TUO	NADINE DWI APRILIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8c2d3261-70f1-4ea7-babe-a99b78024b4e	232410408	$2a$06$wrgWK3s//j6o49v3o6ItDOfuthMYCJKoKLbl3YYCH9GeFKufTGHfu	NAYLA DIVA AMANDA LAURA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3ce55974-3e0e-44e5-9359-2d83e1336f92	232410247	$2a$06$OKP4Zg7GoFwXav4ifNyD5uDNPzFm0whE869VyZICGqPz1OkfNhssC	NAZWA NURKOMARIAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c8c7a26e-f3c6-446d-83a7-6dc288c36bdd	232410005	$2a$06$22mBWlmqZUaEBzhupcIxJOdrkC8NegV9o7d78XLoIq40F2I3CD/Ke	NURUL AENI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f057742d-c72e-4758-aa53-4b06d4170431	232410165	$2a$06$yAmmk97rqza5eBO6ySe3Xe54kdkq7Pq5xRsqWolCcqD06crHJ6Moi	PUTRA ADITIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
20cf987a-dc45-4078-bd54-ceec164229de	232410321	$2a$06$vjLe3UFhlvdU0hZhbzZENOGj3QsLwCMUcbBm8bCWvITezSNtOZw/q	RISYA ASHIFAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b6853146-31eb-4914-9ad4-c8e34e5714ca	232410080	$2a$06$tYMseR7Lq3oLZymnuSquPuDhMGMYVKROIQ/1LBAuQcJQuOH044BM2	SHESSA AZZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ead2960a-a3bf-446f-818e-cbd32f7bcfbe	232410117	$2a$06$eMtqf8M6fybNqBeMU8uxNOFgDD1Nvh9URXUnKTo2jo/PvvNM1Wjl.	SITI ANELISA PATIMAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
84333188-1b1f-4a37-887f-453bdd01e28a	232410032	$2a$06$aUo3TBYPqctHgStJFWNNbucNB9K/0FkQwbNolAKSsfpsWz1HZ6Fpq	SULAEHA SARI ASIH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
29903823-c90c-4e10-b2f1-b7818409de2e	232410258	$2a$06$00nImaUKXZCJmFyZxouldeKAkSFPniEy4fY8R27lmweT.7zfmiFxy	SYDNEY JULIAN ASY'HAR	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1a3efe91-a501-459d-b407-9d5935b58a03	232410250	$2a$06$eBeyRH5yJMOm9jC3FMc7DOBIjCRhnvwull.gHz7cC5CE8jmh6jfFq	SYIFA KIRANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
35b57edd-3aaa-4a43-8632-f6854f32c63e	232410077	$2a$06$yS8rT0I.qlE7Gf6UKJ9/5.um1uHgSpPv2I2rKW04ddifiRwAlvGwy	TARUDI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b16e523c-83e5-442a-b002-ed57a8cab705	232410335	$2a$06$Z.GG6oF3O0kj3C16U0An/.h77AoUPxdb78EQ8UbMMFaUR8mU87/zO	TIARA NUR AZKIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9b65c1c4-25e4-4960-a572-f67482d5f2c8	232410311	$2a$06$k3U9Qhv7cxmgimXz7xFitOYIEFD37W2lxzTrcXf1.1tRPVQZiYS5S	YASA OKTAVIANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d9fdbd72-ead1-4a0f-a1fd-e9b3e2a562d8	232410252	$2a$06$NRe0DjN4hLe3/Msp0fQXqOjgWfIAztPNtjg4cTEF1UTFahOFa06pi	AHMAD IJAZIYA KAROMI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0db27829-c37f-4f62-b6b1-5d26d9961b23	232410262	$2a$06$aGjvp7w3y6q1pKWX46GXMOjpdf/qayXK4djn9RwqRcYeLx4qSMcAi	ALDO WIDIANTORO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ea46f398-733a-4a2f-9689-4cc4cf358de0	232410122	$2a$06$8W9cBN77.MbQvJGLq7H1ieEAYtGpHfhsaTkbsd1LX.yrAduH2OSQi	ALIYYU LIUNI LISTIAWARMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4c91423f-664b-4b0a-929f-b96630d6a4ac	232410390	$2a$06$mMxXAu3SP4PbXv6TMVTvaO90a1kJPWNDxlYE2Jz4cgNUuacRN7.8q	ANITA SAHRANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d106943e-e631-4dc9-8ad3-132eee5b6c95	232410009	$2a$06$eib60uDpM3pMyp0PJUb8UO5x/X76KzRzLK/vj2oyARUKQj/z.detu	AYANG DWI NOVIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1e1427ac-2ce8-4940-8f23-a329b8504a69	232410201	$2a$06$VB2zKzs1cXhUI4yJO1yVbuNoODNGv3sg3uJleTULvbx5O.rWSkaG.	DARINI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
42b524c0-d3e3-4bc7-9aeb-1d5095bd8e54	232410291	$2a$06$3OvS4j8Qsy.mSYkSP4iDa.AnSnnV92FxSlZW5WKLZj3gzsGCaXVJe	DAVA SANDI PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
227f8687-775f-4803-86bc-260e5d0efdc5	232410111	$2a$06$wukl91aM9wz7qDmRcNhGTOAMto0oquB//iwwHZBljkuesPT/za5L6	DIAR MAULANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
212aec36-fe59-4a67-b80c-b81398f523eb	232410045	$2a$06$CgQ07RcRkKsALqLgm8jxgOQZizF2OQqnOl8TAm5p5YsN5Ure1oQiS	ELIS OCTAVIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a60a698a-2111-4875-800d-dc37e35fb205	232410092	$2a$06$VS73oabmOISiRZGQAeKhV.yns0MCw6YTgVqchb/VFVN.kmYDxTm76	FELISYAH PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
483d22d2-7e19-43ed-9a83-6d7f53162035	232410105	$2a$06$JazUfWk4p6DynXx65HD7UuaRCKDcEX3rhL4dIv58OG7O9zN3YGizC	GITA AULIYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
61f595a1-e6ad-488e-b337-1f208958f735	232410203	$2a$06$g16u/G/KIWkbv9XnFZAHV.pHoeUqgUkM1.cJSvm65mJ7Uj0asAd5G	HILYATI FADILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7bac45b8-7795-45b2-b35c-b3e70764cf61	232410170	$2a$06$9lIR7/MHCsojKDl5OMe9W.Lq7D3oEGGgFjXIYCmcrTwZC5lRgnnrS	IBNU AENUROFIQ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
683addaa-b01a-4838-bf72-449408016608	232410279	$2a$06$/Tj2VyiuI2ErUriR0zgcBu/12rDOgSlx.k9T9uADbqH6ldBhI1vau	IVONA RAHMANIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0b937d1c-702d-4dc6-9193-5bccb496f906	232410124	$2a$06$HRPnCDIkVyNMvq04stsn.eXin0xvA.iP.liMa4mYCNtriN.4xKSBu	KEYSHA LING LILIAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ce5d15af-46de-4cd8-8a30-21c9f2efeb2e	232410274	$2a$06$SF0gbapc.6d5ctOX0WMAGOZYqLXPuhmvmd8HMVY4gKBBukMLCxCKC	LATIFATUL AZMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c3cde68a-11f9-4def-a73c-dec97a366685	232410174	$2a$06$spP0um6ARrJWDaiojHn/DuANpRrbQS904FhJGQKUW0nJNENp9lS.O	MAULANA AGIS ANTAREZA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
06facd01-07e1-41cd-9a18-c2e775cce8a5	232410400	$2a$06$auiA.OpWNBERXYhXhzDooucXTKAPCsG0VA./gxUnck4EXrOFosYui	MAYLAFFAYZA ANDANIAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4632093b-bdbe-41e1-b328-c0aad86faf50	232410374	$2a$06$1ydwB1WgR3lB5IpgLwl4OujRSZRWUQi7llngZoImfWRSDcDFP2iFG	MUHAMAD IMAM NURUDIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6944177f-1c79-45ba-a54f-77c441c28268	232410063	$2a$06$cllV52TkSUk.ydWOWHEFuexG59r18aHut7asWuzgmV1CDt7X/e0vO	MUHAMMAD ZAHID HUNAFA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
994bd4af-73ce-47cd-8b85-3150ace4dd67	232410029	$2a$06$UmjBXOq.anNmS0PiLvNGP.BnrQvg6qg/kMlPMNvTMT0zVEPqs6vXW	NAHRASSYA KHAERANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4fa56fa3-2fa1-4043-b0b9-7644daf3ac42	232410081	$2a$06$SKEQJMhTTMF/Rz/SCYTkRuiEz7yjq5DzaUtk5kxjG9gTIcivf8LY.	NAURA WAFA ALMAULIDA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
91745edc-f30e-4e26-bbb4-c7646964bcc0	232410038	$2a$06$Nc9cfEjh4VWKd/G5KnjT9.eSzOxJ4bsh9sRgG2ZGn7J8b7LgtCUXu	NUNU NURDJANAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2db406f9-a06f-4480-ae84-af3dabc4950e	232410015	$2a$06$ODa.mPi0hIN0VOMpKfENteh1yL7OXxnZ3NOvtcxJq9DCFu4VBcDlu	NURUL SYA'ADIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
064918bb-fbc6-4649-bd46-39036796d36d	232410154	$2a$06$/eVtC5tiCxQgTYkix2Lc5OUGsmGsoplZmb2WDWtmR4yDxkgTQPpay	NYAI KHOLIFAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
38c9628d-d2c8-4958-9f75-fdfa4942d2ea	232410332	$2a$06$v9UbsNaldFpEm2aSmo7w7ewrWJUHl1ekFcUluOPA2uUDI20niIYFO	RAHAYU	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7822b2f7-304f-49ec-800d-6dd96aec5918	232410034	$2a$06$qjIdCRYjx5T.wcKJheF.jOMx2zEUNA.rYnnjfZh5EJlYDJ34lYUOC	RAYA SYAFIRALAYLATUL FIDZRIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1de355b9-2a51-4a98-826f-fd861d5090e6	232410065	$2a$06$/GVI2ffy0Or8Q3LdppeNK.a8quHz9gtGGuL3k2ZXGP7dLXMPOSnRG	REFA AGUSTIAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8cc901fa-0e1a-4a51-bec0-8d4821dd6205	232410011	$2a$06$fJIzT0HMqI2V0KbLW9Fcvuj.wII9gfpMCwqx2P6k1GyvXMqcNGjEm	RISMA NUR RAHMAWATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0dfdf807-0d26-400e-9177-b6eb22fefc71	232410363	$2a$06$kKr.Ymsd3SliGw8lJNy56.N.2t7vx0htukUQP9/xgMWaz/2pbtVkG	RIZKHULOH HUSAM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
efae9927-802c-4aa2-8669-c4c03061f2e2	232410010	$2a$06$dAtK6ZRQIMAI2YbnGvFfROQM1MgJe8NVbdDr/pfwFivLmvHuxGkJm	SARTIKA HURUL AIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8ea9908f-215b-44b9-96b1-04be6b3b379c	232410375	$2a$06$f1j0QT12sXMERx6t9UXKguDTqQ6rIBAdeufL1A6JrxUvKIIHwXNcG	SISI NENA CAHYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2c90fce7-7cf9-438b-8a13-c946dd42f512	232410173	$2a$06$3cZnM22lpglu1uqkezG.OeXQ2hL/ywk/hhOTApoeuj35By9z8g1eW	SITI MUNAWAROH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
132ebc16-dee0-4efc-b21e-471aacbe9751	232410275	$2a$06$T5wml9mjBfZxnL8vAh1/luYJPwmg8tCF.UFf1I/Tr/I52JmYQmVpG	TIARA YULIYANTI AULIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1c4b54ae-d05d-416f-87d4-5dc7d511c3b0	232410086	$2a$06$Nu/vHJU985Ig4gA1KzN5A..eN6AtGMNJCVGh.fZKF3PHfOc9bsUW2	WULAN ANDITA SARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9aa896a8-85e1-45f6-9764-2f292a0dd2a7	232410168	$2a$06$8/LDKpl7AUrKEaxwhXHdR.85qPNqGKksVmxp36Ctt46TCqrWGHXyK	YAYANG MANDALA ERLY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2cdbac97-e4c3-44c5-98ed-d6713478c90b	232410351	$2a$06$uD/aqszqTX/PreqnG1LQ9uxRPeDRbKOzXlaiHiCyEsghA/1m56T1.	ABDUL MUKHYI ASYIROZI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1cccae3c-f7e5-4da2-a1c1-dec27b003030	232410017	$2a$06$6n1HexQiPeVNp1.vNFAkgOgMhGTF0Dpp/1MR96yvy3KWZl3Fz69dy	AGIS SAHARA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1b57f1ac-baf1-40d0-b01c-830af168d5ed	232410224	$2a$06$9glzuWoqT05KPFvNz8bVKu9UwyUG0gCYXcq/HK721soH0iDiZvRkW	AHMAD NURZAKI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c993b2fa-5654-44ac-891b-54f45d935305	232410241	$2a$06$S48.oQQYKrnNnKV6FpMt8ObE.kwsDXzOK7pA8lTCw.dgySWOsNv76	AMANDA AYU MOZZA'IYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
57cc6892-7e77-4a67-879a-d67ea9a77606	232410315	$2a$06$8ZAYPz.Lf5nLUnMIhFq.oOerICLU0J7b6EjK462M4yehO2GxBhc5K	ARIEL BAYU SETIAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ce3b6d6d-3048-4ff7-b80b-22dff60e3e19	232410362	$2a$06$O2T.EPKoRzIhQ6pBr/fhX.ONxUGdrhw3FIacuMpa78YrfoY29WR3O	ASTI NURYA NINGSI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3b7fc2f9-e17e-4de9-bf04-78e8138ae1c5	232410024	$2a$06$gh5YBNR43qFDmAXvUoSFSOFV32pZLUw1c7mVqg.yrJDO0oQROZddi	AYU PUTRI LESTARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ec94162c-c7ce-41a9-93cc-bc90eddab7b3	232410041	$2a$06$i0LaiUtwLefflu3nV8fPnu2IaXPl01xH2qPPSb3fZ0LHKyoVyZH4a	DEA AMANTA ZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
019d6b53-b461-434c-93ec-35de3de6937f	232410087	$2a$06$kEZqw/S/O6p2Ir9d6DvjwOCjo90aHiO4h5TOm/U/ESP1B6C4XSaqS	DIARA QONITA MAYSUN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6a64955c-f4b9-4ef8-84e8-53a0f931e8d4	232410253	$2a$06$9HhWeIc20Tx9ixCsPHyZ9ekSxmGa9ok4fYeMs/PkKHcEN/0HjJZQe	DWI ANDIKA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2c288679-81a5-43a8-b988-2d8ade03d8bc	232410229	$2a$06$3jF5AJufg5dJTdGuwwuAme4BVtazxuKeGZ0ZgUoO1kgzRsSIg1nlC	EUIS ZASKIA NUR FAJRIATI DEWI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
296e19bd-9f39-494c-88ce-f04b6d5155c5	232410251	$2a$06$JYMULR6VOdVXfx/EiX55ue1CLvszOSysWF5kQHTLMHVLyCytTkR/y	FIFI AZQIA RAMADANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ef355e80-e077-4eb1-9d8f-b78d25997ed6	232410133	$2a$06$dENQUwabvrhPotpn43rPEOcot5hetUgcjxRLlJX7AFbp/uOqUz.nG	HAMIDAH NUROHMAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
61c5bf18-837d-4443-8b6f-2bc811bfdb01	232410060	$2a$06$QzjpUqObTmbBknoDQ8RIH.W8uE0iQi8NEdGp8xGcppzpaDxX/4.Na	IMELDA RAMADHANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0bfa0383-fed4-4ee0-b787-ac673f36faf8	232410306	$2a$06$/cbad.hBD8jG1FhlyGYBI.mAa9KSVgDeXzGug.2tP8EgXDSgKOqcm	JAZMYNE MAHADAYACINTA ROELL R.	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ffddd403-f5cf-4c13-9ee1-b9ad7a6c4461	232410340	$2a$06$AjgXydnUONauBTk2bBq/q.iv6NXtbzDRjtBy.j3Nn8NwzpgZWBQ82	KEVIN MUKHAMMAD M. F	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0792b3aa-bdd4-432b-973e-4bac69565493	232410345	$2a$06$UWOmOTu4PTIdKXb./uBJZuTECb1MMqUzfDhInzkmJiN3zamIold56	KEYZA AZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
065b1ff8-4198-4ade-85cb-62eb635ee970	232410149	$2a$06$5JNfYrGtPeuFwEC2uYNU6.iEDR2JJk.eQKXfanBIi4L0oUInMhGEi	LENI FADILAH MULYATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7e442b1c-b2aa-4f0b-a73a-6e25ac269eb3	232410211	$2a$06$ZXrq68N7coRUU951egnxOexHECCYIQME7adAx1KW18Hrnpctm2RPe	MELY AMELIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8020245b-0b2b-48ce-9cb8-1cd4c777ad88	232410429	$2a$06$DTjKE1RCuZee1MrizPRcH.Twbiw9O3e35QU0A3VdfmOjeFS1ow6XS	MOCHAMAD DAVA SAPUTRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e063a80a-bac9-48a3-9436-20106e7719ed	REDU00001	$2a$06$Ymz18XXFwlc9W8lQCEiQteyQGwP.4MYyc6fwfMEBmYtRqJ9pwg46y	MUHAMAD RAFA AL WAHID	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
645ef6bf-ce75-465c-9b31-4eb0723c90ee	232410099	$2a$06$IPSO54sJA4VwBD/T2L.gMOTIuT/Kkbb7oNN4jYXNclxYSNo7geCTO	NAILA AURANITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b1b36aa6-4af0-4f91-9208-56c6b43b974b	232410141	$2a$06$socgG66ZE2kAPr33uYIu3eRSR3LTUPB8qsC6DWsCFdcDglJbP6Hha	NAWANG WULAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
94dcf092-62bb-434f-b426-b562a4bfe83e	232410095	$2a$06$kI0nRi8WCh9AVukiSezXMeRGHI4XM28tvKJUxIiIiYEvF0LpKGMdy	NUR HERLINTANG	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
dd9cb0da-da73-413d-a9fe-893924273a2f	232410338	$2a$06$Cl9VvodWf/yEEG0NkC70e.w6wO2dZ/BZ116Tm96IBmstEQZ6RRiqq	PUTRA ADITIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
64f8069d-7289-4452-bdcf-178df659c0fb	232410116	$2a$06$zAr9JFx92AiME4JwkPUX9Oi9y8n/WiCVrozDcx6B0fDJ2URh4uFtm	PUTRI ANANDA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a35c2a1e-0299-4ef0-9ab3-0ff925345b89	232410272	$2a$06$2elulUvGkJYtLthVK.nSNOWHmi6xYOs5i2Tp25TY6khyPeBmA/S4W	RAHMAWATI SEPTIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b5649441-05f9-45e9-b8fa-7b62119edd87	232410366	$2a$06$S6.1OjEcX/DXR61wheAo0.zys0HUJGm2V3zYL22WcQa45knpkM8Tm	RISMA RAMADHANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c07fb9c4-14b1-4304-ad2b-0d57e16c4279	232410228	$2a$06$BKYSG7Hi1FACT4HakLvDJuvCT2rSIALpx.WY/Fk8KnT79NJtKfKDq	SASKIA PITALOKA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ed6a059a-f5c5-4ec8-a125-10648d295c73	232410331	$2a$06$4d7PMK8ubtDDbpI9aptTwOb49f0i54.eGtqZx/rwjRAy0ln7wVqu2	SITI AFIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7282b1fa-6445-4f80-9c31-d7ef8c7ce459	232410187	$2a$06$HgAU/ZAXQ6QWNsewA/l.vub6rwWqg4kBATO0nbuT/PGIH2Vi2jw9.	SITI NURLAILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e16f9d83-d497-4bc9-b5c6-cddcc0e4b3f1	232410066	$2a$06$eN1B2hea1tFRbS6FOh2ZEu7VeHp78anvC3JW5blxJECI9l8wobZpu	SOFYAN AL AFRIZAL	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7c9055bd-9148-4e0c-b5f3-9d0dc10abe3e	232410223	$2a$06$oDWN6NYZIM5foFYlpQBBo.NLBVYEFj7GLFL78frFvnFTKG/MIuBdK	SULISTIA NINGRUM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
63dc559d-d059-4212-837f-c47c4d0855ad	232410196	$2a$06$kea5ihyFyoGgDuSCNaMphuYJa6LuuhheiaGanTJDmnoQHzvtepjBK	ULTHUFI LUTHFIATUL F.	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
bf1ff2b0-1af2-4fb6-9c4e-6503cfb04234	232410300	$2a$06$/8y11tCdL41IGaHp.6/qq.hAbuv.NCqFCFibF.yTsPr/vPYrE3sMC	ZAHRA ISTIQORIAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
05c68ff7-d270-48a7-9a24-a4f7194130ef	232410353	$2a$06$PlIuLnnTchboyERsVuXzB.8XG1K2jIh41GUDyM986xcE5Uvx0GLDi	ZIRUN AL FARIZ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
73614c47-dbc1-49f8-abae-07448df10fdb	232410163	$2a$06$/YgGmZhhHNFgj1XtDFrM3Oyyy1BMWt.I5YEkYjmDuqYqx69vqwGEm	ADITYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4c2ad0ac-f23c-47b1-9715-aaeab58ef28c	232410325	$2a$06$jbGuBAE2k8xgHE97cmznQ.T.D/.uUaIUC6fRVmN3kdPc/sZFPm/GK	AHMAD RIZAL NUROFIQ	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6a7087f1-12f7-431c-9b72-7f2783394be1	232410200	$2a$06$BVuaUMzzPZ604fsFFKUxKuyG4D3xsOaHwATjJj0VwcMpg4WQFByiK	AISYAH CAHAYA PELANGI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a68ccae5-3ac3-4df9-9150-94b52e310563	232410028	$2a$06$4OV6b/Sn2VgDQJL8WR3csuSlFXjtsR.YZyVDDAESAnHx7WCKrFMfy	AMANDA FAUZIYATIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
53a903aa-3b43-4bb2-b24b-f6717aa98eee	232410265	$2a$06$aMh5PMTeyKe2WiKjWjSW9utWlnq8s9pEo6NSCDgwjImHTmzjzNQCm	ARIFIN ILHAM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
575aadb4-6286-4de6-ad79-60d8799a20c5	232410106	$2a$06$HaedB8BJtl4MjaH9zuBRZerq7xlV9szwE6P0BoYp8hErWUiSyZQiG	ATIKAH GHINA FAUZIYYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2f2186c5-4971-459a-92ab-1603ab30f885	232410267	$2a$06$ZJAxxx.rI7DDhKqOkr5tyOQZ0BitO7EBIq4leo1v7HOZkJ6Im0wHu	AZZAHRA AULIA SYINKY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c6b12955-5f54-48e7-9033-4dbfe0fee95d	232410062	$2a$06$FbwQ.NSU16xH.efx3.nxgOWwLXFswdj/lR.iBLDbonm2HmjMHd5pm	DEDE AYU LESTARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1283dd8a-86cd-46b9-866f-a690771dfe3c	232410008	$2a$06$2hDj34uiOBOtUchy5e5YK.eixxnmzmueDB/I.Pjr3mJwmtoF5D9GK	DINA APRILIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
27fe6edd-3d5b-467f-8fc4-ac173590af7e	232410295	$2a$06$LOlFRilISe08lpCTxjHuuO1JzcJQUXpNOt8SwkR0ps3mGh6Q8zLsu	EVA RIYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
376a43d1-04b7-4ed2-a5dd-06f07354eb2d	232410396	$2a$06$1C9ig9yKOGu389rA2Czg7uyB2cwv2L5GFuWqsXJ3ABErowQtk0Eiu	FARLAN FIRMANSYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7f3d45bb-e2a3-434c-910d-10f01bb6c56b	242511437	$2a$06$kwD86NG4V2TYWZI1u9ZDy.fozJPml2uLG8uPwqmifHf9L/9EE7Hpi	FIDA JAZILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
272bdf91-a5c9-4b7d-8967-9ab225e2217d	232410101	$2a$06$x2MKBNTS0R9QsUyBlEdxm.S0/9FHG64sUnv6pm4P8adQKn8ZA2Ole	FITRI RAHMAYANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
bb1391ef-b0ec-43d8-87fb-d5459345db36	232410271	$2a$06$gsQLV1zMgFi2ihe5E/LomO.gQNspLipqF.zps53K0l6iFcVbTjIHO	HANI NUR FADILAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
08659fc4-2faf-410d-a99a-3661d7aeae40	232410292	$2a$06$4FAPWYTZEbgkqrKlEokxduC6cZ0SR.HxdiqXergiiEOJsfib6IrBG	INDRIYANI SRI WAHYUNINGSIH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
387cadd7-5208-4f44-85ff-f0d8ab46e2d6	232410180	$2a$06$15.KEp29/GJswNhd.9wWruAgE9rcQenVqIr7fLkPniXqaq0.fqUMO	KAHFIATUS SYIFANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
72c913ea-9c0d-4990-ae26-6f7c083881ca	232410020	$2a$06$F6q5PtSnjjuE13No.g/SOeiae344.uIKrQ/.nGQu32Y8rTVB.gQpe	KHARISMA YOGI ANGGRAENI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0e47a80a-7655-41b8-a160-92f8255118e1	232410290	$2a$06$I.DflyfR06DyCVNzXEtsfeuTik4zrqtMj7kFo2f//roi06DLUXLym	LIFA DEWI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1c3aa59f-d28d-4b26-9f80-4de00ad7c618	232410176	$2a$06$EZjkBwdhJNPabGRAuym2FOwMtpLFz7b96S.mDBBmpy/dRU9NaD7LG	LUTHFI KHAIRULLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5d66683b-a3cf-40cf-84f0-fb46c4770e40	232410257	$2a$06$GDNyDBeUDildXTAxpriE9.BoInp5FC3Fn85uopEsKcouJ64pAugfm	MIA MARSHA TIANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f9b6be49-9e94-4b1c-9ba3-e44b3a0f5a8e	232410299	$2a$06$2RfMWx9pH0II5kwfXT.kyOuRDjB98jU8iOlWgZrSDcP4IwHpOlOpm	MOH. FARIZ RAMDANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1870e567-f513-428a-9a90-88b390976305	232410330	$2a$06$OHbbvblfR15tMlxspsQscOYmHwLZ7H8ObNxjafBBw81HnJhIXy3kW	MUHAMAD REVAN SUMBADA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
307a2b23-1b43-40a8-b549-11131f3472ec	232410047	$2a$06$Kk30DCRZjtCb2se8IKqRdOZYGxElb3sDRByK0L4HJBj0BsAf43aXm	NAILA AZZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5a65d538-ca54-4ff3-a576-bccfc7ce390f	232410361	$2a$06$W44C1fwJmnlqoMfAa9NHQeFufIohFCXYEDYBNsYlDaGtQjdThSEp2	NAZWA FITRI AULIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c1b53e52-8cce-460a-9560-9398594dc324	232410380	$2a$06$It2ScvCoLjbtyLHQdoyPoO0LNu.2H5xNN0wlcEUgDpdlp01uyAh7q	NURUL KHUMAYROH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
07bbd587-3df2-49a6-9a71-81bb6b7419a0	232410304	$2a$06$aW3QmD7rmdLLPv2nI3z5ceyDh9jdVNTY3LdBNAppY5kPF7CB0gCGi	RAFLY HENDRIAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
dae168c3-20f2-411f-abf1-e5043a28f65a	232410239	$2a$06$NZlY3eFwwBuOq8tAD9K9l.d13xHiSJ3dLMoTWdSW/HoOgup/.4Cri	RAIYA ARLA DESTRIANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a2ac81d7-3783-49f2-a42c-f29227845db0	232410401	$2a$06$9T5dlPfvlytuJ82xElL.k.25Yy0klomNuDNWqsAzf97q1rtBL48pe	RISNA SELVIANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
59218e84-f50f-4245-961c-855a53fad617	242511438	$2a$06$wwg1bJ1LDpL91orTsG1AhOHf8fWU94wkTMzrjcUkf88yLZ.OdjN.K	ROSIHAN ANWAR	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
448bc62f-97ea-46c1-9bb9-6937d2a243c0	232410071	$2a$06$mjhqEdNw6VKZCqlrBr/xHOiUh6.A7OVIcFgX2UlBCT2Nu24iBpLXG	SASKIYA VINANDA PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
23114a53-5a5c-4038-ace0-6adcc66db011	232410373	$2a$06$CcYcoOQWabsyNcxVUZhF3uTkyMUwssFZaWkzUuIAXH/TceKxMXSUe	SITI ANISAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fc3815ee-635d-4d36-9361-f46b95cfdf4a	232410261	$2a$06$octeN2hfEQLHr/EmPjltAuP7hQzBFM9xMQMYscEEArcS0ZkgLz6Ae	SITI UMAEROH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f58d862f-c802-4a5a-9e03-70091d09f0e3	232410342	$2a$06$YiOhmujreRTHPO9ne328aemitueEEfHFZ3rSCISd//UKsPWRkAblK	SYAHROTUL AENI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
671a14aa-511a-4b48-b14d-eb5e1ec185dd	232410235	$2a$06$R54oUQdn9oH9N7ymEEImy.k9sTZ1pXXSjAHrLIRjm.jF7hkCNxO7u	TIO PRATAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e83720ee-ac34-419f-9274-2f4854188e61	232410153	$2a$06$xLhob1.nzUi0qAHK.YblQ.vnD.vVFSVxulNIoQ6HWQ0H7QzwGpZ9m	WIDIYA APRIYANTI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4ee66047-b2e8-454d-a27d-ac2341379797	232410057	$2a$06$1nWw9/BRzWboEFq5Y/5ak.Ens7P.SKqil3Cws/.7ftfdDrW17yzFm	ZAHRATUS SIFA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
2e02cc31-9d0a-4216-97df-c077deedb18b	232410221	$2a$06$Tg990jcYIep6GBU8YvQ8reWabpREiBINBdvwudZZ8OGHyuO3lHx6K	ABDUL BASIRUN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
85ee3312-368e-47d6-bc0e-967754d24c12	232410369	$2a$06$LiSZ5PuMnM9qjmDoig6.teAt1PGdQVZUC0boQbwCCAVB/DUseOe16	AFIF NUR ILYAS	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
686e322e-ea8d-4615-85a8-434c2f4a909c	232410144	$2a$06$/YegfHoMYFJMzaxUUeYRhu6ah.LMoN/H.6En3sl3RBjowaNM4gBAy	ALIFATUL HIKMAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9a20144d-5dcb-42af-b0ef-f10445646b5b	232410075	$2a$06$jTQIfR6LabPMwdf4oAb14.u6Ga4t5rQYdDknjLFwIxm9Bm6.fLFuC	ANA MARLINA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b74e8815-08a3-4c22-bfb1-259129036f91	232410192	$2a$06$qkKPtx52759nOleLvJFVoOtSh1rJkHG3A.GSSDApozfOzKPAAkJ2O	ANDRE MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6a2b5ce6-ba52-4e22-ba6e-77ac82b8787a	232410212	$2a$06$cLzwZwtSCSFmhnnvW/3rdeZPbn6kFlTVmkQcuIPuHQzi6XkG.G0WW	AULIA MERVI YONNI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
143e746a-e924-4e81-8bd5-51101293bdb9	232410100	$2a$06$Sv6fltLKjnbGbdLC6q6um.MDfOmHd497K9BZE0PkzhepCbmjpIGPe	AZHRUL UMAM ALFARIZKI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e9ecd949-f407-4966-b225-aa4d21b3af5c	232410393	$2a$06$ydUy7PCbFKq3XwEeUNH3wOYqTKs4wADkUx3DzqEKf9h0dNzQnzY9e	CHIBI RUHMA MAIA ANGARINI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
bc1717d1-d08a-40ee-b730-e3806ee49df4	232410236	$2a$06$fWNtvDnJh/W6c51pbbsDQOUmpQt8zkaVYoG0g3k8vdiEpYEZkosle	DEWI NURWULAN SARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3499a2ee-f5c9-42b4-a701-d55e84059718	232410183	$2a$06$DvKrvpRKcRlZxS/GImIeq.2Rp0FASmRvHsbpoGI8boujH6a5B7Tzi	DINDA ARISTIA OVIANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
13f8494c-c018-4141-af93-2d4a5e396ceb	242511439	$2a$06$tx63YGgaFoY3ZyNDK5Qns.qJaH4Hl2M7i7QPi8Z8rA9m/cO7/bItu	ELANG ARDHAN BRATANINGRAT	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b90bc1c5-6e8f-47a5-839a-71bab8e8ec68	232410419	$2a$06$9QDueFh1k4XwlyflMklyBe8gywToDENNb0dSIf5NlJ8JiZc8PkI6.	EVA YULIYASWATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
404f372c-c9d4-4810-98f4-1e34d7701c9d	232410347	$2a$06$bG2MwixIRdFOd202X66OB.crY.NZyLJumUFfJ2wuv8DltdrLLt1v6	GAYATRI HARNUM MENTARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7dc12900-01b4-451b-ba61-769bd3ddafaf	232410339	$2a$06$e6g/zp06BosIB.1/b7cgL.Dssa3TXS3/OG/5yBbGYjGiAhMRvfoF2	GILANG RAMADHAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3fa3005a-369f-49bc-98fb-49c39c509e68	232410006	$2a$06$cRJU5TpZRV4QmvporT7Dcuo2LLCF72Cgn/dnqMIGwwNz6M.ayhg42	HELEN PUTRI NUR AFIAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
75ba519c-34fb-4aa9-8f85-1aa7578bade6	232410289	$2a$06$GvrZSTYbQt1mMXAOrGEZwO/hA5JJUNt/JaRQiU8WfCiElVAGBgWXO	INTAN FEBRI DWI ANJANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3373a6bb-2461-4e16-8bd9-34b10226d935	232410370	$2a$06$YB7UrhXg5HuiX0s40DGVzO6M7GUgWrtBCchS7zG9RqscfcZlW3vK2	KESYA APRILIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cb54929f-a51a-427e-a903-1f516ecce00f	232410328	$2a$06$vaI6sG/D2/EqF8882SF2q.S/u3J/AuM.arlc5eJKxIM5PXhBEfaDG	KHOLIFAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7c3afc63-0e77-45cc-9afe-e41263be3bf5	232410388	$2a$06$kQxMy4YBDTzfyjYdHyUF6ebfD0YgZyda4D19Y.1SVNcOOmQkwI566	LISYANA AZZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
028c5f6c-1af1-410f-ae81-c4a1a89a05e8	232410417	$2a$06$w5V5/R23nzKMsXuapxNjPe9zfV7CSIPk5NnV1IzJurfEIqlB77/kW	M. KHAFKA KHAIRULLAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9d9e414a-a164-448e-8eca-4b2bbee172fe	232410384	$2a$06$mLK3lTrg8NzlBLzCwQKFkuVA78j5B1sfsZ5MNmcp1AZ8Y1UZjNqym	MIRZAINI SYIFA DJATY	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f06a38a0-62a3-423f-990f-12ca159ff693	232410178	$2a$06$gaelzbeurswUf.iU66Cr3OwLml0XFNhESVyMXKx6oP5Nhcs6rUBMu	MUHAMAD ARI LUKMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1ebd7a73-8ace-42b1-bd61-005b11c3c1d1	232410172	$2a$06$egqjVdUM8FWo88PnGJzkneXfBOAe/JlfSWSzVClqEr2xMGrGoPpvi	MUHAMAD SATRIA PRATAMA K	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f86af7fc-de4e-4f6b-b5fd-799b8b481e95	232410387	$2a$06$Y7p81WfgHsk6wyHhoelPAuC7z3aybPTkDq/lWg6prCOTND0RNTJJG	NAILAH RAHMAH RAMADHANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
f48cea36-c363-4516-a95b-e19afe8f7fb3	232410096	$2a$06$vVKLBhAD.pm5ojttc0wP2uTzaA65JYBu0B8q6UdT5nUoYQeRJo1Ky	NIGITA ANGGRAENI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e17a175e-77e1-41b1-b95f-c673648eee42	232410409	$2a$06$x/z/RSx9g.nXaQ4b9gmb5eQGT4QjEzgN9h2HzkpIxek0G6zFzAMUO	NURUL MAULIDI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
250c950a-6be2-4e01-aa39-c2cb04a3db88	232410185	$2a$06$xC45mHYAbYzas1ZZ7HC9v.pYe2loga6w47x/Qq2QYiL.qWDwsQ7Ly	PUTRI SELFIYANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
05977b83-22a6-4faa-ad7e-5a89be7133eb	232410046	$2a$06$8nBVu4lcZQtPUsTk7xu0P.XtlW.L3cQBcFqF3Vp6oX/HBsHrZBtyq	RIMAS SA'IDAH MUHAMMAD	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5de73337-412c-4ec6-b817-45b8c85aa30b	232410426	$2a$06$Jp3/JqAfmftcVXHRBYUPmO1mJoMH/POS//ujDkqcMj9wNImRSsNqS	SALSAH DEFATIHAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6b226cc0-02ef-45fc-8655-935fcad39842	232410037	$2a$06$1YvTsyIR6niSKxbOIz9L7eTm8lu/AJjeMTEKWvCAXascT.OKtvT46	SINTA ELIYANA LESTARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0d7a87b4-353a-4e66-a33d-ffba751aad2c	232410175	$2a$06$4iNXJ4UhDx7JLqCcVTF5XeptE7CIrpTEn8.v1wRCidM8WAiIIe/.6	SITI MAESAROH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
24334c84-60de-4c6a-87e5-0b674fa60fe1	232410404	$2a$06$sAb8m795JbhVE45dEokk.eKgRsu//9D32PRL1r0k1AIj9CnxOscnO	SRI MULYANI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
14c36695-4393-4854-bbd3-f39c10ce8201	232410412	$2a$06$3oZglK6.RkXLU.irBDwXf.m.RYuY85G69b.L/01ig5SIWMvzhxWRm	SYAHROTUS SHITA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
d1c41a99-ebc3-4d6a-91ba-7a213e2237b6	232410319	$2a$06$uI0cPcxeasC/xue42WS3KOanAmr7Sj1tEy.O2PY.xXS4QLG9ukqDq	WINDI AYU KOMALASARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
432a061e-07ee-441b-9fb5-b4804e31669e	232410391	$2a$06$f2eTPAK76L40ddHGhASvBO7ZX0UhV5U1dCozfLBMHp02cXsMdflB2	ZAKIYYATU SA'DIYYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a2187cb1-c88f-4f5d-8d7a-69d0bfead536	232410217	$2a$06$WqrxA0HAmak8oUS2mkh/EuimU9kfk55Nfmr6GkSm5JyNPmqw7nG6y	AGUNG PURNAMA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
96f96f26-28e7-431e-b32c-654589a3ab4e	232410249	$2a$06$8c95C5DTIU9bFeGLG8FTIOOcgITsf7dqpJ5s7lzIcPLozs3Ti87gy	ALIN FUJI NINGRUM	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
841f5fe1-b957-446d-92bc-ad06779ca6a4	232410424	$2a$06$cZz4SRSwHFAJ.iW1T7fEheXyNgXhrZ8RwI/8GEzx2UwIEky5ajst.	ANANDA FARDHAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
27c50f24-549b-400e-ba5b-2aff717c10a5	232410191	$2a$06$Fix5yr8PUCy7Ki8PvaLOTu8JGuMnMXkhIaCzNSyoZP2vqf6idGR.6	ANGGUN NAZIKHAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
fae7ff58-630f-4096-a18b-bb535f50a10b	232410386	$2a$06$Uq3EyxZLr86EBc.WKAHmduLPUWHNJ3egK/CpUAJXaUsDmgHJgGFHO	AULIA PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
71ec9e2c-419d-4742-9066-9f925316cab4	232410430	$2a$06$tQwY67PEW3djhrSnpTOGs.uDaEvrhajql/X18K9eTgGjVUb3U2fCe	BAMBANG TRI PRASETYO	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
38df1bff-cbd0-4fd5-a705-8082780add13	232410207	$2a$06$mMdvdvI6U7S/gP57sAOz9OGnz7TT2Fvlq9jb0ZZnFFtCmzSHkL7aa	CLARA RIZKY WIDIAWAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
5cd6c35e-b6bb-4de3-a152-d200dff92122	232410159	$2a$06$nDnjJIsqEGqNLXQP8wAvZubeuRLt4V.W.dHvMQdXss6j3E2S1syGS	DIAN NIRMALASARI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
18423a6c-4aec-4ec8-a127-eca09ae9bcd7	232410026	$2a$06$.Ml9HBV8Pof7JRmD4pd6Te5XlKCty6eIaeW4lLJx14DZroYCzIIgy	ELFATICHA VELIANSYAH A.	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c6ebbc10-d37c-40ff-9e13-800a81abf51a	242511440	$2a$06$usjinebKvSNY35HU5qKURe/Xs04mEKogkRqyM37l6rT3vdGu2JI9.	FAHMI NURUL HIDAYAT	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0d6df5be-2015-4f4e-87e5-d7a083eb5a3a	232410254	$2a$06$Alg72x4WOTTntqMGQ46kROFQ8IVDfcC3y.sGX2ico9K8wgJmNu6K6	FATIMAH AZ ZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
ecb245c1-588d-4727-8d0e-a1ea4ee09f0c	232410049	$2a$06$4thQ9rjceUmpeDrHaoAo/.UHezj.NjYHt8Fc7YA3./7JsbKcc5V1a	GEA SYERLA CITRA AMANDA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c32fadbb-f1f1-43e0-8ef1-0e6c2342d003	232410073	$2a$06$USSFZMmQv.xU1NRwjCKf8OXm/v3ncL5dKoSMqydcyB1LQAexvX4PW	HILDA NAFISA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
0879e77f-9a04-40b2-ade4-cd34bb00ae77	232410367	$2a$06$LoINXZnRV.IzorstFtgEUuN7jY77j1SNjYeZdIn100Yp00.K7p0Wq	HILMI HABIBI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
12e1aac6-53e2-49c1-ac51-030d0d3f7762	232410059	$2a$06$r4aVZnLlYFqpb8g6zQHVW.Oimz6gTsgd9uLcs2pOOJTi74zBUlt4i	ITA SEFTIA NINGSIH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
6383a697-8211-4aee-bd41-87856980800c	232410415	$2a$06$03Jrvd5GIZIIceec0bPL3enuf9rx0Wpb4tP1kRoxO29DyKDEmVufu	KEYSHA GIRI PUTRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3115c037-038a-40a8-b211-70e33b5e3c83	232410411	$2a$06$h2Vm0aJhydryQxjK5AQUkef/HC1ZiX5vhCBqkMbZhMMq1ORr7d6Vy	KIRANA AZAHRA ARYTONI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
3f5fe802-c2e1-45a4-adf2-d1757e24a97c	232410270	$2a$06$FZWM27cQyqOQxnImsI4mQ.7XkS3bHn0jArJPrwvt8bcNXDE1xM0Ce	MALIKAH BALQIES	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
000f0032-82a5-4df1-92c0-9f01bbea08b2	232410263	$2a$06$D53VMkVmraHd2o0DtTysVeThMNXdJeoX3DxLpMn8UT7UEk6318YSK	MARIO AGATHA MAULANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
cea6ef48-82b3-49ca-84fd-c26aff42065f	232410216	$2a$06$3KGZ4gd4EyNEwOgv3/FVv.RVafn60kEvYmDj2ozGtAjEzqIhDsoLG	MUHAMAD ATAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
780955c4-993f-4d4c-b9d0-66fe76743d31	232410226	$2a$06$GGiK.OFfDUXiOGjrnlYdDOhW7ce3vHyKUC9YtG9UOi/qYqErm9YIy	MUHAMMAD RIZKI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4f7038f4-0a8d-40bb-94a6-a3ae7ccdc276	232410055	$2a$06$YygPX7vgoEso.w9LqPqjLuMf5KFPmqa2d2/kO0ppaGlg4JTGSIbVy	NADIA SHIFA NUR AZZAHRA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
a541817d-e50c-4d12-b040-4284a1d37d72	232410395	$2a$06$AY3CPwupiaAZ6scLyAirj.n/w/x6dsrrllPtyXMkPNiFVen4gWpPa	NATHASYA HOZAWA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
16fce22d-8b0d-4009-b41a-16addf9d27e8	232410132	$2a$06$7FahmthjLiq8l215aHD1VegniDc6MKQdMbUSex52C/jumojVKOeKG	NISA FADILA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
812f343c-f225-42ac-b9d2-5fb2faffefb4	232410042	$2a$06$WV.YuR5tRaP5607cL6FG2OkB5FibE69afl5XCLodesAmSsOMTJc56	NURUL SAFITRI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
bdbee647-bf6f-4e13-83ec-3d5b6ccb578e	232410225	$2a$06$vCyKA5A0E9GMfZzMVOCohO.2BybQMYah.Fc5qqC19RTUYjqdyVgPC	PUTRIA RIDHA AMILIA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
4796361a-0f2b-4dcb-b219-2964a6958b46	232410215	$2a$06$eSDpSV8QUYSf.N2NSiG29OJZIpQ.C/Dmn4xs5pOQ9xi9hoSRL9aQ2	REZA ADITYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
b6a63b60-3592-4798-9e54-bd31878710b8	232410019	$2a$06$YYKmmW722O4fscgI6TiVVeOaskHM0YD5XzBLuy/zpZwge.FJO1cnS	RINDU ALICHA NURJAMAN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
1cc9100b-8994-4cce-83df-1c1519a93e7d	232410188	$2a$06$FOH0IpgngZBgNBTYoRKtY.KyQFjINliwuFkRKhN2q1BOi2q/Lq/pe	ROBIATUL ADAWIYAH	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9d7af861-d4ce-40bd-803c-d5919f9a8c2d	232410128	$2a$06$OWr85fK4sP0AMxMDoQlbquFZSeADYJiMHGumM7HeVB7skGFgoh0Rm	SANTI YULIANA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
7555adc5-b42a-44e5-9d91-c5c66080e512	232410088	$2a$06$gluUB3EZ78q/1IgcsU8XXeb71l6U/ZKrQfb5MfYLCYbrfM.l3wW4K	SIS ANTAWATI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
32e5e360-0482-4c17-86bc-be523243e508	232410194	$2a$06$Ez3gl5F/XZGs5TXrRygYQuUC5JHN4.8X5EBfNY5GLGnYKdPkYAnv2	SITI MARIYA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
e6b9a606-debb-4ce6-8a4c-3a042ba551c2	232410283	$2a$06$NDIOsS2hBX9944sUnhqFvuIHKQBWBhU2qDTGgxbRT08oF0ULSWjO6	SUCI RAMADHANI UMASANGAJI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
9db27a93-641e-4bb6-9bc1-dac71594b03c	232410193	$2a$06$y3G/oDaOzDzLgf89v0GHUeuSjaTHnYvIObWvBsE9/D88Xny6jO.Ce	TIARA CAHYA SHALSHABYLA	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
8e30d5c4-96f6-4850-b6f2-2d39a87ce011	232410288	$2a$06$myUiZAihXyiKd/3FxS8mJ.eSl6XdJXBWhr8Hxb2I0Gj8wCyq.kTU.	WIYAN FIYANDI	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
303cefe9-a492-4cdf-b25c-5f729f742f64	232410314	$2a$06$7UnQpoGElTo1rMHtANUPN.hCd4esfT7dmpBUJD2KiPr/tqdtclSN6	ZULQIFLY RAHMADIN	2	\N	\N	Y	2025-07-17 02:45:32.553899	\N	\N	\N	\N
c3e0f7ae-4808-41a3-b0c2-d7e00402ec91	232410054	$2y$10$6CPhQUCmKTAwbyRDpYF5PetOHfIPAMExX6I5W3K6HjNFv5yEKXXVa	LAUDYA CHINTYA BELLA	2	\N	\N	\N	2025-07-17 02:45:32.553899	2025-07-17 02:48:37	admin	\N	\N
718f86c1-79bd-4382-9f36-c0ac98a9b404	252610001	$2a$06$981oafGJrb3em7T6u8nzo.O1NvomJeHRrzM9notiVsJbPVx2.bYre	AAN MAHENDRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0c9acf97-2120-4aef-a273-d748e63f2859	252610220	$2a$06$cY/y3PW4UmAijnoenRZCS.LyaikP1PHwA.Wtpts3XaIe0X/rPvNEm	MOHAMAD AZHAR QOSHIDY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e5ba9495-a8dd-4857-b4a1-891494262688	252610232	$2a$06$S0P/Vpi3ZArZFJJVsCOksOWzuFbqzMdPeQe2a9S3zDRKvgu1k/tn.	MUHAMAD FATHIR AL-FARIZKY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
25027f76-62a4-41f0-a6a5-236767b8dabb	252610457	$2a$06$Smggd1J63gxC/QsNSMzRIO361y12O6mtmu.uA1S8lXtUZ0jE.czH2	MUHAMAD IQBAL DIPHDA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
265a0bf5-a2d0-4d7c-a447-06a91b1b93dc	252610244	$2a$06$cvgMSL1D1FeulaRqRpvr3uF6qFqcDJAgatw70wtsVKNRlg2ZfRAri	MUHAMMAD RAIHAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
22e303dd-ea93-4af4-bb04-c72595185d98	252610256	$2a$06$lR6cfLXKx.gnq76AkHfSRevFthc.62G2xWR.hrRSSg.R.LPlnY9x6	NABILA SEPTIANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4c19b79f-442b-48d9-abc1-bd3c15aa57e4	252610268	$2a$06$Ceg7Dk8A5pw74KQUDI.8Duat2B6nR/w0l0dEEJ5vofgOIh2/kEXx6	NANDIKA PRATAMA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
78a39c4f-208c-4392-af21-2457f2d5d404	252610548	$2a$06$7ykWjtJp2nrfOgxungnbjO6fYTUf1JyMBlkRwaRbLOwlEe35TOcn2	NAZWA SAKINAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c9a025f9-9f25-4682-99d0-4330ee67e66f	252610280	$2a$06$/aY8t4ewsSRM9O7eLiTCvuToqbhUuQmV1s7zEL7aDHIK6R7XPlZne	NOVITA SARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
99551f2d-9f5d-4f30-b0a1-c9f8332849e0	252610292	$2a$06$ZLDOAvwD7iBJ7s5xZgGa7u9ceHg/pjeVa6VkV1L0FtVi0/awCCBhK	PENGGALA PUTRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6726e1af-6334-4ad6-ade2-6fbe1e50737a	252610304	$2a$06$YiV6ol4MwBOaVFf2rYmgJ.1sGh4Q7Zc9Hi/1bfkzoeCplVU5vb78O	RAHADIAN NAJMAH TOHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a682f0de-bf27-46c8-ad92-65dc511179f4	252610316	$2a$06$ZR7Tzo0eyQA2RP3OOw9fNevYrGbY3Fc1CO30qs09AxIkEdOLMEDJO	REHAN MUBAROKH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
23a0f598-5e44-493b-9070-452a743534aa	252610328	$2a$06$slzYlYO.A1Da67MFnLKGtug.BDtcRiwWYQbzk8a7O/dSkH.tDoFxq	RIYAHNI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8053b018-dc47-42d5-a83f-734e6628e70f	252610340	$2a$06$WzjRV2vVboxauZD/X5eK..IWrupFUeup0XT9zHQe7XWmFI7ChBdcW	SAFA NURMAULIDA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
fea94e6b-4634-4caa-91c1-127618e63733	252610352	$2a$06$h7rKcRZJ/CxBqkRWS0AAtet3uRSQwpGbhuwW2KEm7SYTETvMORK.O	SELFFIA SUKMA AYU	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
85d449ec-687d-4c14-83fd-fa1df623df67	252610537	$2a$06$EeASd75XRtYGRLjkq3/kR.qYq8nKjggtbDAlasNLZNuiPL.1IY.fC	SELFI NOVIANTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8894b726-eadd-4a9a-bcf1-32a3e343fc70	252610364	$2a$06$tum2vFcAT9BqjAi.ICZSdufFUSQJ9E/fRvTT3NdbHeSgakCW4ci8O	SITI KHODIJAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
35e79170-a5bc-4bb0-8616-4cb3f9b8fe35	252610376	$2a$06$RdgOyC7ASLmDiz2Az/BpD.P4SyeY8lpOCbbfDlM1rwV9CjNQebqAa	SRI FADILAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
517a7f48-ad05-4c96-b8b9-e26672f4f547	252610388	$2a$06$D6dKKDBnECKK.n5Z7XTJeO.6WQwABTMBbNlOhfm3WGAY5XDlezi.C	SYERILL KAYYASAH NUR ROHMAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
71530656-8478-4a0a-a4e7-a069df30f34e	252610513	$2a$06$N12nAGDJJJgcC7JlHtkJN.HH.1Ug8N0ToV5YC/yCYcfws5Wx6RAmS	TEGUH ARDIANSYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a4219606-547b-4b30-b401-5f7c34f6a619	252610400	$2a$06$s2lYZV5KzHvOZ6BZrkqW1.PfoL8zbiUQrXtyvAF9CRf8hCg/NNGhK	TIYAS NUR AULIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c33b241f-1021-4ce1-96e4-6adb9c1ffbac	252610412	$2a$06$iN7jHvfzGVnLfnV7uCyB5.wrMq/o3zyH/pX/PiPaJfSjNw9iHK6Cq	VIRA PRIYANKA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cbea207b-3ae6-4607-949e-1f2bb8318d82	252610424	$2a$06$tVLSFr1tJ0IfQ0y1U8896.tbAXOvTWJpvLKaAhUb8RViCYV1uJ1n.	ZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
35037918-2db4-4c57-a454-933ddf8cca32	252610249	$2a$06$PWb2f6oHLknJ4WZSeQtYYu5zRo6g2.7UYS6F4thEQf.l9KNMolvai	MUKHAMMAD YAUMILAZHAR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6e0721ef-88ad-4ddb-848e-32c55a0bfad8	252610261	$2a$06$rawxnuJwMYWeXVEYNPGsnucVFObudh4lXp98IsZIZJGuIZd/fOxii	NAESA AYU LISTIANINGSIH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cfed5352-2d80-456e-a1bd-4a69b84665df	252610273	$2a$06$D5OfUQslCDADlxajSejvxO/1NYwStQed5eSiE0hB9LvCvKBeFMhQG	NAZWA AULIA AZZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
db3cb027-dcb6-4565-9423-b54fdcf5bd8f	252610285	$2a$06$rRRjkkMQZCrHFEysHf4MAuYvdKFdh03UShduYL6Yruf4Ss4aOlGXm	NURHAYATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2839b157-082b-4af6-bb2e-f5c8c5d7081d	252610297	$2a$06$kwq/Xx3ZZ1vuFfoEwssB0u5RQgytmEu3V1MRxxSM4nRNQOLKfEW0K	QOIRUN NISA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
331fdc7f-8c0c-44a6-9517-0f993f10f74d	252610521	$2a$06$FFxOb63R3AfdFr36qo0tOemmxDdP5JzEQFkRPkEq4F3bSoxZozeZu	RAFFIDHAN ISLAMI PASHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
83d9896e-e63b-4ba9-a2c7-173e67d0ec5a	252610309	$2a$06$HIZVxeFFdbxhlWfiiSGHV.uvP11kUNSSLJ.PjCVXA8i7VUQddORy6	RAHMA SAFFINA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
506e2f34-cca3-4540-b611-40c541b971ef	252610321	$2a$06$MzahjADo5b3ukLk6XsBTWOim9vZTrNvO8gW0a.sA5oBulS7ArRjnm	RIFKY MAULANA HAKIM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
93f67c40-1997-490c-b6b0-b242ea9bf5ce	252610333	$2a$06$iE0H4eqvaP9L9CrdGKWDO.ePxB/pfhAeWqaDjRrSACUtG4w1rkHz.	RUKIYATUS SOLEKHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
165c5a22-2291-468d-9476-57a045515ebf	252610345	$2a$06$MtrDYHg8Is42J9EMu/WXc.HLdjI53qCLSroJBmDNao5HMIf1LYklq	SALSABILA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4b3d61f9-db3a-46a0-b539-151f81968c16	252610357	$2a$06$jFKbh13jIUwcFiPyTY4Vbubxv/0Cj14mjCSG8.yFqQQUt4GmOkyKK	SIGIT JAELANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
19c90cd5-6596-47f8-910b-e538d127f34b	252610517	$2a$06$gpMhfykhlbO43k5T.t9zZeYHltqRaHSMEzPBJ8PJOqBhI2FZz92JS	SISKA AULIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8828ba35-8c9d-4965-af33-92595549b37c	252610369	$2a$06$XjsKpWDIRZA81CfD8WKDDOs0S8urUsXENDA5N6xh6Lo1GNUUFahce	SITI NAZMA NURVIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
59b7726f-30dc-4da9-90d4-ecbd87ad0b26	252610381	$2a$06$9fY7tsZst0910/t5wxRHPOnGhhVBAvz7M82ka0ggmPIbMA6YHb6YG	SULAEMAN HIDAYAT PUTRA RAMADAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3924a1ca-f424-4308-81fd-a820e04df9c3	252610393	$2a$06$GKXkc0l/oqzU6fAYLT7l8OO1MjUkAXNvbMEm9255k6PhG8P/eVZq2	TEGAR FIRMANSYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1f17c671-5819-45f3-9463-12d03f8a4f43	252610405	$2a$06$NwHZYKpc7Geek9NFJnRCu.M60OacXKFqqtQEnew85xHOFX1A3QDku	UBAE DIKA ZAENAL ABIDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
db333f12-57d9-4a35-9720-3d2a56e40be6	252610417	$2a$06$moyRyjPwvmgWh6/aUYJA6e0lXA30Z0m03T6t.SxyUZKWdklATgAXi	WIDIYA MAHARANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
08b461a2-b1b4-43b6-b9b3-238ae78131ba	252610533	$2a$06$dutDMeAcJfgT8y4foddoe.kFUj91jaEqctbafE8sRkDuqQbHTtELK	WINARTI APRILIA REGINA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ee614f55-effe-4c07-9f0e-53e57c87279a	252610429	$2a$06$llCMimyT5OxkDGGYDjNOq.e/9uPuG0dLPLkpD/fk2PbNOWLwkhhpS	ZHIWWA AULIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
05793f83-7dab-455d-aefa-45444a7d9a6d	252610544	$2a$06$DCWQM93u8zHQqJuC/kkqZe7KUT/TA4Ihf99TI0.8l6HNcjSQAFOy.	SELINA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8e17910d-8f9a-471e-b6cc-0617ff029427	252610343	$2a$06$9r5sNzP6Nz4ygsdC4RHXyenEfqa1lav4pitc4ACt5ihYgBx4OCSP6	SALMA AN NAFISAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
738bcefb-0ea3-468d-9f8f-e20bad383d75	252610355	$2a$06$MrmUM5zsdk5d8biy8I7HaeDX6r.UteTiKvbJkHcZZILPfYXX3Hc6i	SELVIA ROKANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0dd7e556-c115-4c10-bf65-89cf8e26c977	252610522	$2a$06$vr6fEvD9NkO66WKnRYyDKOdTFHAUHjcqJnRoGbKEi2YYO2pxBaOIK	SHAFA SALSABILLA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cb5e7432-7f2c-4579-aa43-69b15cd8c53e	252610367	$2a$06$fS1.r0mAeAf0F6rpAjAWqeKmx5hrA2/jlRasbG1.br/x3vSKWFtFq	SITI MIRYANATUL MUAWANAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
82484c61-b26b-44e6-82ea-acb486924b0e	252610379	$2a$06$pu/Da6hrye88qoG1IpGcuewLmJ/9wkvKRlRDP/lUvYqOSgLJUKcbG	SRI WULAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ea383a81-40ae-4bb7-9729-cf29c0f38ee5	252610391	$2a$06$wbQ2FEbfA4v.WzuojBndvuYiAtIg8wARwzo0J5jl2U4.winVJ/MSm	TALITA AINIYA AZMI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8d03d441-ef69-4235-978b-4006abad3cb3	252610403	$2a$06$PFe2H20ttC6xus/3HJylv.lAd.SDlW8zUGImtHgdmr1uKaORMBE16	TRI HIZRIYANTI WAHYUNI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
352b82cc-f9b8-4262-bffe-ef1acafe5006	252610462	$2a$06$HS9HBXyn6plair04Mf/w9e5kM6f1hivw3O5RqZ2vsXMEwZCqAzjWC	VIKKI FIRMANSYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cb253a4f-c6de-493c-beb1-7c98f85da372	252610010	$2a$06$CEw/jWoQ/zIOEuAvL52PD.v.mmsf4GEZNxY.Ssqz9QCgWlX7z2Z82	ADE SYIFA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
98c8329e-1b26-4f2e-a2a3-a9903017be7e	252610022	$2a$06$qpr9wb6f6iTOzTZASPyVTeqEHwYAkZnuN8QKF4nDw1jfMtCv5xY7m	AFIVA SYAHIRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d6a82008-6051-446e-8810-0fe7d611d25c	252610034	$2a$06$qzoH66/0rYAvgjBgssgnLOqzlA8bFBzsOk565MNabvjF/t/WRWE/W	AKBAR SANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
75354d73-3f89-4c35-9e55-dc9f82f403a3	252610496	$2a$06$FABepWPT48RLu0sQCwGGAem89.qkh5WcfYRlmX2.7JZO1372JrmkC	ALINKA MAULANA HURAIYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1cbcfffc-7243-47a4-a4f9-966891165620	252610046	$2a$06$230MTCCN91YWm3tu4Zfk3O8rta5IqCNLluzqTDXIKaEfGYtgUOFVe	ANDIN DWI SAFITRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
064fa003-9ead-4175-a4f9-97f024a4be5c	252610058	$2a$06$iUOd3cgNl5fpn2eg7PIP9.7k8ExmKn3c7RJn1MaH8SMbwwO3clGKq	APRIZA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0ab1f5f1-967e-4a81-88f1-5583e1788687	252610484	$2a$06$84dJsNOkDZpUppt0gzDx2uCiLinoVZp8vmboyTi68vuem5vNFRaGG	AULIA RIZKY SALSABILA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ae9564ef-abb5-4d68-a1f0-256538da8c9b	252610070	$2a$06$8Lzb7sOZpvDXrB6e2PHLPeTrin3Q28HxeQciQKijgbm24wAhGCMGG	AZKA AZIZAH ARISTAWIDYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d2cfb7b2-d36a-4b1d-9427-1d6c64f7e2f0	252610465	$2a$06$n1x57nSLHG..hWJH.RARBejgZxjwz11ozLHgiwuvx5P7E.R64tIAS	ABDUROHKMAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e0480b25-1f11-4569-8d98-f9f45866965a	252610013	$2a$06$EgVjI6wTUBcnR5g3t6QQVu84zsWwB5TRKiE/KFrxyB5D30BWIh9mK	ADELIA REGINA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2d1b8f6e-b7b9-4297-8818-3926c6d6754f	252610025	$2a$06$KSmPbUTR5Z4Rj9SX.XMu3OU2G/bzAny/ywEtEgvF2P8yTgOr3SQEy	AHMAD RIFAI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
75b4005f-c858-4eec-bf89-26f6f2d9efd1	252610037	$2a$06$W1LLi0NdjvmhOh6GHCdYkO5V0yqv1VSK9VwwJgXabpFo2jaKgtbly	ALIF AL FARIZI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
190a758b-2746-4cbd-93df-74fee122ba0d	252610502	$2a$06$SvM5xZ8mEnYyRkaLy0FoeeBNkqLdhI/M54VNNtRs60daVoZ534fOm	ALYA NABILLAH ZAHRAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
624df803-aee8-47b8-901c-ebf57fe09330	252610049	$2a$06$0k0BBR8PPa8JjyGHbrVd5.EXJHTNrG6lNLakOuSg6MjiMi9zK3rZ.	ANGEL KEY ATALLAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e11468a8-7ca8-4fd3-acda-a06ef0857209	252610061	$2a$06$38Y7Zv.GYnwc5M6c4xaRRexsoEcOwk/Rz9ppdbQ4lUi7lbe8f.K46	ASRI ROHMAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
944e9c92-419a-44a8-85f2-08d56c907ede	252610448	$2a$06$/8dds/B8Ls86PWHLZ1r.jeynXhIvq5dvKuleSzvwSYo2NJp0u6V.G	AZIZIAH YUANIAR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
bc37d8cc-ac4a-4a88-a697-b3e23ce21be6	252610073	$2a$06$oNPhOFabWyuYzNkJivFQEO0iAvChEuQmh6yylUnsTBIQ/kNhHbske	CACA MEILIAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
453353da-8fa4-4f31-89b5-c80854f4696f	252610085	$2a$06$np9ad8F4QQOkrOeeePPPzOfW.HLYW6bR9y.9qyGGiO.Fe5pOe6sgy	DARA MANIS SINTA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c253f22a-8e57-4752-a5fe-7868cd47e5db	252610097	$2a$06$q8rZp7ZItjtrBTDIUqkS4.p8TJLnw.Rc0ulmQ6r9lLkhJPQSv0H3W	DIAN WALUYO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
692d16f1-6b12-4c5a-bd40-c12b914bd7a5	252610444	$2a$06$QHr8dTWOjS47CvshymNtluan7aUFiFXGLjeMf2YAvcoB6w5BLv3uC	DINDA AYU AFRISYATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
55be2821-baba-41fd-a72f-e515b0d05062	252610109	$2a$06$24wxnch/n0vp4Oe2ri0HVe7VqNAwvSmk2RUeZlvucuHKzX6YgK1fy	ELISA RAHMAWATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
bac1d14e-d99c-49ca-9512-f0b0f06e2949	252610121	$2a$06$dLBP9Qr04x9S2tSfizH.dueBPYo9I5Kij7YMsmXC.KZFqk.2EFqT.	FAIZ MAULANA IBRAHIM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d32a99f3-025e-478a-9967-6e90533088c6	252610451	$2a$06$CFG01DuEjQnhjJcALnqrJO9KZHOvh5EmLNTNkE6CdB3CU/f5VeMUm	FHIRENT SAFA ALZENA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
aa88e795-32d7-4c49-abd4-78b793f4d6cc	252610133	$2a$06$8exrudrS45jxg8Rwl8VEpeWWa9hrtsq33NQ.qppkOenrskJ0CFAf6	FILZAH NAZIFA SUSANTO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6e92ffef-6a6a-4740-80d9-3f793b98cb20	252610145	$2a$06$1e9CsvJZicBoC7VOB2lqeuH13rc7ZJc2tQc2x9CV.MCBQl8qNJJ1.	GATHAN GAULAMA ZACKY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ed0a9f40-7487-4d41-8db8-5d5f15615ba7	252610157	$2a$06$pEHNpDwku/8jezby0AURquBMcnBZcnx/bjUYdbQRR/zZ7Ydmlqpei	HUSNUL KHOTIMAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cead1d9f-e2ca-4add-b8c4-6be83dd4e389	252610169	$2a$06$wtQ/eWQYuSbXuWrmdNyOxObY6utaf7.XQvSO5XyAyNvsQpyIwR5BS	IQBAL MAULANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f8258da2-eccc-4bba-ac66-b593f6d0b860	252610181	$2a$06$REb9/hw0vFON9VWK35swXOPxMtpfehlZCBImdGN1.DUL20An6IujO	KAYLA NURFITRIYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
73e58aba-d715-442a-ae9f-34ea255514e0	252610193	$2a$06$/D7jZX9KtebPmmQfo6VFfeOJyJ9pAT1uP72Vr1w2RzUS9/5Et44.K	KRISHNA ABDULLAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0d271108-f02c-4ff8-a5bb-419c08f9484c	252610205	$2a$06$VmFJmewb8DWfdpQjoErxIej5gO2TaoWPyIfknCY2jNtTIcwMYxfXS	MACHMUD ADUM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d586a813-d91b-46fc-8696-73430c3cda54	252610217	$2a$06$ilsB/PzMZQeEpfLnEagrauu.cADaD875B1OpxHTY4DHGTob7Bmx/6	MOH. IKHSAN SUGANDI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
66b4f63e-de57-47ad-833c-14ba82d0a179	252610542	$2a$06$G4Yl/lShoq8DlzhRyqEBUOzsG6emAJ98OhdaXAs8QPlzA3qJZSYOS	MUHAMAD DZIKRY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
160fd933-4de5-4935-a967-94cc87506c61	252610229	$2a$06$pXshAmbu35BOnV6RG7HzROlFXZ7J3AvocCCGHRuRwTCTdpAy.LQsK	MUHAMAD EZAR PUTRA SUHARTONO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8ed4196d-889c-4b42-99a0-baf3a39fb06c	252610241	$2a$06$9yWCsD7QT2RzVKlcsQdt2.vx74oCf3kEV/LGXT8ue2rpLAhf4WZ8W	MUHAMMAD HAFIZH MAULANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
079a83e1-f34c-47d8-8698-708dd0ffdbd1	252610253	$2a$06$a7YTHMIAwNPT6Zm5vGXSTuJOP5.B3yLS8tSrBopH.R0R.nBXC7R8W	NABILA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ce455c35-5d72-41ff-ad72-33553295b88c	252610461	$2a$06$8ITE1SQgkwNpiirxiTP8Q.3H59b8Rgzi.p2AGwy76bHwFP5H4tfLC	NABILA SRI RIZKI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a2aa844d-363c-47f5-a293-11715330c59a	252610265	$2a$06$77jsl3olCfG94KsuKBRHyOPwD79h1sR3LHOJxMEs9N8meSrcHCgV2	NAILAH TUS SOLIHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5196155b-6241-40e1-9061-3a123651ba53	252610277	$2a$06$QCF/YYM50s0IZGQctKRuC.WWIIxW/sBuUYpUcdxSwjKFmVw5LY.Hm	NISA SHOPIA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
74bdcf58-721d-46bd-870c-3e70a284d1e1	252610289	$2a$06$bg8aZ.tWCiWBX0o9bx6ru.2Ap2M9ZRBUg.eISuwg9ivkbPya7XXki	NURUL JULIANTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5197d757-3499-41c3-90ae-eab11d375b77	252610301	$2a$06$Wkk2zSN5p5/61ComnLzMV.OIgrPSgUI0hIkPq8aSFuKs8d8F.YYQK	RAFAEL FAJAR SATRIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0b131a47-bad9-4f4f-92b7-605df5a2a9dd	252610313	$2a$06$iZYljL7TmF0phbw3LHCjce00PlBZSqxhMBO91jiSNSb7AGtBJ43i6	RATINI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a51db6c2-fae9-438b-b73d-6f89e0bbbdf4	252610325	$2a$06$T6NEgBeRYSrmUagxA6oX6OLMt51zkroTw1Mi0hOstwTFVt.CLihjW	RIRIN RHOUHATULHILMI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
752a11fc-067d-417e-bd2f-8d9070fec725	252610337	$2a$06$5tLoRctxVNDf3Dqmi8YWVuM344vDgolQjKYxgixqhKpHrVXXGMwFq	SABRINA SYIAM AL QORY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
54ad7f15-3ffa-4e8c-8e65-6c4870671bbe	252610472	$2a$06$irQmeVHuoKxtlJiLfltFD.4YLrzxZXiuEWQ6bDAJQLKPnqh4cDYs6	SAEFUL FADILAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a4a32b9d-b5ba-420f-8871-1b96a019f610	252610349	$2a$06$ug2m6udjj3xGbFLrZGTUd.daHd6AW5jksmNyRRRe8d0ZDgKFYybDW	SASMIKA ALFAZHIRAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4bec56ed-99e2-4ba9-9d90-471bd2e8b2e2	252610361	$2a$06$bEeM2JO1.5frVxyFQKpanuPyoqsjZGIakahT3c4YRSmFkDlL.6whO	SITI AL ZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
49565314-b29b-4d45-8829-71af0209590d	252610463	$2a$06$D7iThYR/.3CGlOlJi49TPe2IhxJiCe3uXwvcPBrcswbMp9sTsmVKK	SITI NURHASANAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2e8ae4d2-cdb0-4b7f-b062-9a33b156d019	252610373	$2a$06$J4fCGK9UFDvdsMU99qGbveXHz9ihiHhEC2e7kyK3XjZBpFoAImMA6	SOFI AQIELLA ZULFAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
374d0500-3e54-428d-b969-cd8ef3f91610	252610385	$2a$06$eJuo.nZL.UcrNnY2LP1CHuV9haSBxpbK84sFsZlDOhsRNrT3uuJoO	SYAFA DWI RIZKY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
183bc5d9-caed-4110-b467-bef171dbe6d5	252610397	$2a$06$HIoCII8KQ9t3qvxpV1mKPe2tGWhuJcvyecoWsbAHjMr2SjKq5ymmK	TIARA OLIVIA DWI PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d74ff420-ad79-4c22-8d29-7ca261b7e701	252610409	$2a$06$wQZdst1wbxNBWamiUKgH5OK8KAHizq5zFIhv6MARzjlsQKpnsc3Wy	UNIK WAHYUNI INDRAWATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
fdc13fc1-60c5-4ee1-8b94-adc897900cde	252610421	$2a$06$hxNENcWaoKOPam17X91eoOYj1cOdc/E9ElmKNUWcifZBKlJhK5EQe	YULIA DAMAYANTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
336e3f18-b0e0-4608-9822-28d1c56efbed	252610436	$2a$06$VRGS96JllcDHwMfBkD0lVOZFNW41xquQAYSpDan6.23hOeomF/IK.	ZAZKIA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
80a531e3-1921-4b59-b683-a3488ecacd73	252610002	$2a$06$HUV/DqOqz1vZ2xi/A5Lkyuz84okflbYd84FKr41IIIUZWv52wjYy2	AANG GUNAWAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
603fd38d-fe99-40d9-95ed-4d4531ce5c50	252610530	$2a$06$wYLwC5/s8m.FkJrStG2pEebG8zqFpSb87uM2Q0614pJq7mygWrCem	ADE DIVA ANGGARA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5bec91c5-165b-44e5-a305-3a1725aeb4fa	252610014	$2a$06$.n1xXi0U1n9oiRzeDKiNguvtIOEJMVJpcWNy/lEv195hzWkaE2Qe6	ADELIA TREE ALISKIYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b45cedbf-7ca4-41cb-a8ef-5a175bdb4a6b	252610026	$2a$06$z0pvuKJxmlO.LM4W9PPg2Oxj6JQKAhJgXGf6bPTeHQtkqKwzIAcXi	AHMAD YAZID	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
eb859d7b-83c6-432d-89a3-70d39c027b53	252610038	$2a$06$oMZgAyzMe6i29czW4q85l.vBpTwoi1ixf6emKdA6NQdJ6AokxrCdm	ALIF NURFAIZ	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
dbd7b08a-669f-46d7-9361-140ff622be16	252610460	$2a$06$pPNlDBiFaPFRlgewg4yYJ.cXSVl7Qz5.zPnLkfEPpY68BYzYVCy6m	ANASYA NUR FADILAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8a4e115e-c820-49f2-8c88-fd619f0a4ee2	252610050	$2a$06$lvYWIKYGDDG2bimNDtAvAO2iPnC8HLc9QdKh.9X246TmbQN3z.BlS	ANGGI DWI RAMADAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ff292fec-4a10-4673-9f82-d8de77e5fda8	252610062	$2a$06$YcwWVaD0P2cp0EFUJ.bZ6OGPBeC6ndHzqI44zU/OwtF.cCd0/ZVnW	ATIKA DWI AMALIATUSSOLIKHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
946427c0-3141-495f-bec7-46fbab324a18	252610543	$2a$06$j/f8yaUEcFsEPIUZfmG8m.AUlteTCndBSfFXGz5gibEVMrdvCPIIS	AZKIYATU QOLBIYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
afded0d2-973c-4c24-9da3-b9031cc23b8a	252610074	$2a$06$wAs5AFlO4VSNWyPlM7uPTOSnYcZGpgU3Zfzvsv6.8D1QFSwFyAlr6	CALYSTA PUTRI ERLINDA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
149aa6b1-e331-4c38-ac3f-9a698a1f7de2	252610086	$2a$06$VhWg2Wf6Cf7Xg0yOhDIMRO/s.flUtHlgQjFKtkDCyXAAAZ45gsxPK	DAVID NUR ALAM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8c794aaa-b794-4a39-adc3-b3c77bf3e3e1	252610098	$2a$06$9DI41NoDyzZaeB7FfY.GFuHyuWSF0KpscWtAy9ElrkzVr/.fenSjO	DINARA CANTIKA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
05324457-e7fd-442a-9c00-4a61ccc65c06	252610501	$2a$06$NNIudV7EtTTytJx7Ul.xsOYqguIgWfNvMpzwPm98HvRVhBdBgbLJC	DINDA PUTRI LESTARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8aa2535e-246c-47cb-b824-f5e3697a9df9	252610110	$2a$06$6Yf166MP3t/RubqdC0dSLuQerU/7GTIt20DmDDFyufj/TUUrsX0Ly	ELVAN RUSTIAWAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
09395392-b8e9-4ce0-b844-be4ef608a56d	252610122	$2a$06$r9v6BdeDFyhleO9MDUkTQekuwXvr5dRTExiujxu.Gm2CpUhQHnqt2	FAREL NAUVAL NUGRAHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e037514f-de9b-4d81-800b-a013bf9fca8d	252610474	$2a$06$MlduA4/j0WJIitiVYlMnVusj6.GB4G8nfA5D2vqpe908ORJVhG2Mu	FITRI AWALIYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
dbb35e11-1216-43cb-8ada-9587fd4c02fa	252610134	$2a$06$GhNckCjsUec3Mb8UEGjz8ep3K5IKl/5MZHEtUE64sFGHI9ioWQ30S	FITRI DARA FATNI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
58ffa8b7-a47d-456c-8c00-5a396d7cb18f	252610146	$2a$06$3ZiH7X3mVorE5p23awPoduPIrAK9By3.lG6ejwOyOJ1WHJ2ONK9Yy	GAYATRI NURHAFZA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ce525642-8f6e-4796-940a-fbf7af38c166	252610158	$2a$06$kUSVoHvuDBUaR1fbTSd7E.CbMkw3N567dRZHHMLOvrjbIyknXBYeK	IBNU ALMUZAKIR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
25f61467-69bf-4fcc-bffa-eb78a546a95e	252610170	$2a$06$o8utHYKsaPEcEkYye098feDjZJHgmTlzsiBH2s/DEhl2Skxud5pGG	IRMA KARTIKA ANGGRAENI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2bb0d53f-248e-49b2-b6c6-6b5f869bff2c	252610453	$2a$06$NBZqQhD6w7wMavxGNQqPOOvmIhdC89hDwqq2t4G3h2mONuLBeV8zC	KAYNOVA LIYANI NINGSIH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
af6d0f8a-6017-4c55-8e2c-dac2675ff9d3	252610182	$2a$06$TEytdciqcN0TKAHGZJnO0OdFB9cGVo5mL6bSIzsej83J6TQs2/pwi	KEYSA APRILIANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
efa40e8a-b388-4dfc-aeb6-3b5bc166053a	252610194	$2a$06$.lLt5RrdWChdQNCEVbL1OuBDVidc6gFNvCHHT.cDFETeSdaAB6r8S	LELY WULANDARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
12801aad-59d8-4444-9495-5eb0f8574eb2	252610206	$2a$06$oUE5evRroBCBFlgiN/aI2.akzZ5yHYSPnymYreWnGFAMYG4rAEKuW	MAR'ATUSSHOLIKHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e237a39c-aeaa-401b-aa77-2be07410f565	252610218	$2a$06$WA65A7d92bzx4prkhhcmYeyZd4E/0aGRQNUj0RNraZUlWpxjHboai	MOHAMAD ALENDRA AL HAQIE	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
dbb0e376-73e7-41e6-8f4d-eae2e32b722c	252610230	$2a$06$WETGqFAMFUzOWa80ftSKXOPeZ.tACcpkMY.Th0gW/LZL0ps/U.7/q	MUHAMAD FAHAD MUGHNI LABIB	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
472537e0-8100-4923-b749-be5764c0a4df	252610440	$2a$06$Rhqb3J9b0zNuqnCVUwmwd.2gC7cpvoGixwSx0F2IQ2RkOROqC81dO	MUHAMAD ILHAM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e7c0b8fb-369a-49a7-8e9e-b3a040e1e04e	252610242	$2a$06$MW7rDrkYO3IPFC3Pu9uLH.yGxXGJDG3h.HvknRdcDhySTb48dE/T2	MUHAMMAD IBRAHIM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
35333251-660b-4494-9380-6cb8813d7750	252610254	$2a$06$pDLqQ0Pft8Wibc2lpXE8h.IoDHw4J6aLtqdSV1QSQBBI/QqLZ0udK	NABILA AULIA SAKINAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
73380cac-b134-451f-89d3-5fa727772b08	252610491	$2a$06$feL5AFSS9eBQaqK70lzYz.ofhwMESlBidu6j4OQW5zjMsphEztcGO	NAILATUL IBRIZIYYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4a3f5234-8862-476a-9cbf-763ca3f3edda	252610266	$2a$06$r6B.PYeaYOmdK5E61ftbtO/RIcIABnQn6F1VoUv4aiAZ1ytmCT9ae	NAJWA NASUHAH FEBRIAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
bffd301a-da35-4ba0-809c-e7909b97cb1b	252610278	$2a$06$8OJnGIY7RWAfkMmvFpqqBuLJsGxyc5WiqzpJVNyg579xXgSKLa0Pa	NITA AYU SALAMA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cd0821d0-24f6-46bf-8a2d-8c163c7abd25	252610290	$2a$06$wh/ErVvG0duNvwOKgZxZaeqX0uC4ffLg0/KDzesB8z0GBJg0LgEsG	NYAI ANITA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f84bf879-451a-489e-86b1-6064695168df	252610302	$2a$06$ZO.bu2kCQ0bfLJfyZv6xGOb8AUa/KP93Xi5Cr6aBC2gYyMQEYnAeO	RAFINSA KHOIRUL AJAM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ae9aa9f2-32f7-449f-995b-467b748a539d	252610314	$2a$06$Ug1Xt1./7z6W6bnscQ0EteDCMrlj9O6rBNk8CJ9jIa8j6ZK/WD2X.	RAYA NOVIANTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b7254955-19f7-493a-951c-c49fe64a2055	252610326	$2a$06$IYqVUK0nTI5vQpVao3ol/efIFSUYSQrzjT6y9nkRDfikQvJMe2cPu	RISKA FEBRIANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a920a076-13bf-4ff3-a171-5fdf26362a89	252610338	$2a$06$HaH3EP0QsoLvByZrPU98Wuk921lA8sJw/oR5Z.IYjQTQn0SwzrhSO	SAEFUDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f430d3ff-61ec-497e-8c07-5ea96d82b42d	252610504	$2a$06$2ivehPqgTs0.tngzjlSyy.1Pa/L9d9fim8AKA0cdl9bpyXePZS9Ge	SALSA BILA AZZAHRA ATHARIYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
216cc85b-a731-4bfc-be34-6d303d1d0f2d	252610350	$2a$06$AXWMBdNhENu1aHqpMBdqpuuDy0055PW8kl3/O6vXLSJHqux.tHAKi	SAVIRA PRANITA SARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
67e2ebba-c858-44d0-87ee-214ff50def2b	252610362	$2a$06$563OVP4FV7iKxlnIYI.yLevrOnKDO4lon7IN/OLuslwsr/FqTFI4q	SITI ILJI'I KHUSNUL KHOTIMAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0df4c231-6438-4961-aef3-6ace70a01355	252610435	$2a$06$c8IObhUQfd6Pbja2C4vMRubSmqQ73ilDEfhgCkL5NLPrSTppFkxUO	SITI NURHAYATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2e824b1b-e40b-4024-8286-b98e76d07a32	252610374	$2a$06$B7HBc/Yk7X7TeTEgfI4HTORgQ36M/SJPJv6cTiT2rgcjQS.hIwnJ2	SOFIE FATHUR RIZKI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
105975f6-db59-4992-ba39-0ebfe758c5da	252610386	$2a$06$AeXLoL0Errq2kRPVzfJykeMi8FHvmOYaHM5ff2aNa045Oj59MKZ4S	SYAFARIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
84248841-7172-458a-afd7-234c10aaf1cf	252610398	$2a$06$6PrQlnSNtWOFzWqc6i6eGegQR9ptsIQ7iY15PxFixp9KyKypk6gDq	TIFFANI PUSPA ADZDINI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
82646204-d2c3-469e-ba1f-f8f91a8172c6	252610410	$2a$06$nNYQqvm7.fkM2ik4LiUCd.67b2NCmiLaTyNnI5NeWy3//C5QYszaW	VIKRI ARDIANTO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2a2f04ef-25dc-4360-94ee-a279397a1ca8	252610422	$2a$06$BIjbFuNL9MyQAIsLqKzd4.wER220rNctF/32xRCYheAPwkk/qZi6y	YUSUF FADHIL	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
62ec6d5a-083a-4f89-9660-483e057c139c	252610003	$2a$06$ew2qn59hAT0oprqTCrFU4uXph6qg8HFqq0yicGWo6c/EpjacSA9uO	ABDUL KOHARUDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b8943f83-fc68-40d3-9ecb-afcbe50df233	252610015	$2a$06$1YrVMzrqCnk7MG2JSdytSuoB6cWHHdtB2hHoj7YCUasQH3eu4GdWq	ADESTA RAFKA FAIRUS	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
af5b9edf-7e71-4d82-a675-edc045ec26cc	252610466	$2a$06$o3m8ceLq3a.sTcLydt28keS63VW9iml//MCMjNXBl7u4tqDe4RcIa	ADILULLAH ASSYAFI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
dde7ffcc-562d-4c0f-b69b-f16d2a103a10	252610027	$2a$06$jmAe9t56b0T7jD4JdyZrWOtM5eNRPw0rDncXZQLF3NdFTkXy3Q3By	AHMIYATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ba5d85d5-ce09-4e51-8e24-80b9594d9407	252610039	$2a$06$nfBut/QcMgqUODSaR.CSgOMPcSuRgEyCGWVZgwA.6QcIOQQI7Ov.y	ALIFIA LAYINA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8407eba5-0d82-4d2a-997c-55be3be98a56	252610051	$2a$06$b.Ykwzv3IHmhaiKY3POBC.c0nsMTLW5qe30R1WSBCsOiv/OKDBqCK	ANGGI LAILATUSSA'ADAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
aa1d2d37-38c7-4571-91a2-347db0bcfd21	252610434	$2a$06$bn4eZtGCP90Bcm72qtKKo.7h2SZyDKd3jJlQLX4sKb/fIYYg3j1AO	ANINDYA JULIA ROCHMAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
fa689428-acac-45fd-b062-34a4a84c8c9f	252610063	$2a$06$mJHXDHxE6ga8EceiQcO9mes5N5nVXrwJHoXOGa/1na/bZua23xa6O	AUFA BRILIANTY ASAFA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cc070e6d-885c-4729-8cb4-f0ab3323359b	252610476	$2a$06$2ZS0jvmxgak2.CPgOX3EW.0bpVqrYi4wEbsTcjriYVE29qWrWFB1q	BAROKAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
861f6802-9e51-44a7-83fe-cb1f3a41b7b8	252610079	$2a$06$A2jZbi4FaweJxqeKiGKSpOgp1Y/nFQdwKzrTyHJW7YIC3xXcrcyFK	CICIH RAHMAWATI DEWI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
175f7c4e-be80-4fc8-a929-46f7f32fe02d	252610087	$2a$06$TyBKDpmji8dAWb34eHOzIeJHNj4dCOkOWOG3sfxDJ9niL4PWArR7.	DEA NURAHMA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0b8fd97f-06f9-4bb9-9663-5f322d1df086	252610099	$2a$06$qUGm1GFy1WM8iqBLo.yFWeXCBJ3sCBOIQmuUOQbQ07qTzDmMcK0Ta	DINDA HERINAWATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e4bdabd3-6146-4c99-a449-725001b770cf	252610552	$2a$06$gSG/YoZZPRQ9QDkTifJQhOh5vguzYJKhuVQN5pJgmqKX7JvesOZG6	DINI OLIVIANSAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
211ded79-35b1-4ae8-879e-487424b2c653	252610111	$2a$06$ZO0tcdJdLVPewc2XtdV/auMC34Mqtyq43zDRRH.FpBYJRZFt8IRWG	ENDAH LESTARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
36e5c54e-4a26-4427-a31d-d89b2f5527d9	252610123	$2a$06$rVaSjndGEBa5lM/eyV0hKe6ggymObjQKUITcVf8p0.2dNbD..je2i	FARIDAH RAHMAWATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f201eb35-00b5-4958-9937-160acde7ab1f	252610135	$2a$06$o1CXdCiJUH7Qd.EjiJP.I.o.a2ykpGPPJvzSWBVEfVlUef7Erd9q.	FITRI DWI MAYSAROH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
741823a5-939a-48bb-9827-7f34288759f3	252610438	$2a$06$IqKTcuGt7Hi.mt4fF29Gb.6WliETllsSDSrR6iNeCLdTT78Myx.pO	GALANG SHOLEHUDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
182d6bb6-7dce-4b51-9575-eaf9511ef581	252610147	$2a$06$13rnvtDcs6xItctc2BU2PuRLZ9wcj1T6oe2acKbb1whaAkdHSwWZW	GILANG PRATAMA PUTRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
556ef444-013a-4e6f-9ae8-3355fc57c4ca	252610159	$2a$06$i9nHEgJ0VOVEGQalfBvPauJ4TSm6RgipW6gEcjCqnDGvKQiu06PYC	IDAM KHOLID	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e1d52abf-70b2-4d34-9030-50d1a0cbeb13	252610171	$2a$06$MGTD8e7S20xErBpl7ullL.edaW3Ek.tQ2npZtaNADonRK85flH0Ly	IRMALA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
fb7dbc33-7927-4dc2-a615-c6e1a0d3de2c	252610183	$2a$06$xaFjtiXtxLcUDKBSHsCgF.HghK26MUDdd4cAWM39Y8w2leVZX8J2q	KEYSHA AYUDYA PRATAMA BUDIANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3e6731bd-8865-4da1-b8dd-3444b2f39922	252610464	$2a$06$FFZBblZ36WROwaaaAq3cr.IWIvhxN7aGqK/4Nik7yTJLjA2Nzov8y	KHAERUL AZAM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
eb7cb9d9-45c0-4867-8e3e-449fe97dfdb7	252610195	$2a$06$eK6/rbXB4bTyUIYWNdb9/evZdWHajF0Mw/NsTselcAPizMnvvlV9O	LEVINA DITRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
44751582-8a50-4de9-96e1-cb8ba8cb6de4	252610207	$2a$06$zWa/.AfkkYmLvdkthTgqQOcORq.hDCzWVsMS.j5AN7F8GXtvyVDyq	MARISA RINJIANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9cbb89b3-06dd-40fb-9033-bafaa6adc718	252610219	$2a$06$TKbuclcvLpydjHvZGqmJIece.isP1hNL3LpR166UfQnSAojn7NUZS	MOHAMAD ARYA RAHMAT HIDAYAT	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2fcea1fe-a1d4-4783-9a03-405065cad1e2	252610231	$2a$06$OdQRAbE4S6PcHvH.2wJFC.5GZw5XkIbRKOkmFcWlPmJRziGZaqgfe	MUHAMAD FAHRIZA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
85c3904a-b3de-4f55-9734-b4040eea9c9d	252610546	$2a$06$JtPh16qiEXY9Uw5zWbU7gOsOsiOmL4y/VjHGl2ZgfuO8LkCg8bKMy	MUHAMAD ILHAM SOLAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f28cc6b8-1aeb-4b04-9016-7e194906a613	252610243	$2a$06$20KYURAow/Oy9GBxctCrGeUaYsUzlZyxzw0nspOTz6iulwACuydBi	MUHAMMAD IKHSAN MAULANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8b13019d-ec5b-4690-a9da-9c4ea11b80bb	252610255	$2a$06$O3EhV4XNg6kxdQAybeqyye7KB9vgCLU0KTAjGoJLOaY3k70WTw4dy	NABILA DEWIANTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4cb53297-a35f-4b50-b388-63b39eb8af6a	252610267	$2a$06$SyO3dM924lB6Ds1PRBqSPOKcsH0o/HMPFpxekoV7r.czw91gBckdC	NAJWA TUNNISA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
19c2b41b-36be-4786-b8cf-c5ee78dea07b	252610437	$2a$06$gZ432PN74zgcU6b7bqJiaeCiKfBXO3QJwUoPlMHvihLBvevgNgY7q	NAOMI ASHR KURNIAWAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3300139f-2bf8-4ecc-8065-fc86577cd2d1	252610279	$2a$06$WSIz4.dy8Dw5SISSVQrKI.gUUw0BtIZ0IARBDwwah0vgPnelS16l.	NOVA AYU NINGSIH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5e307a9c-6d95-4ce3-b844-26b011554960	252610291	$2a$06$GQdH9ZG6vw0I7muLl6ZUXeGsC2mtXWY4etmHUcQ2jBKMvhlUbodbO	PASYA SAPUTRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
636433c3-34f9-4063-8bc8-80b82f749460	252610303	$2a$06$eRIRb1oA4qbYZ6n3upqzqepoOTmF7oC9LZ.Nv/RECD2fm8PQzo9jC	RAFY HANDOYO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d91e21c2-0274-4fa0-aac5-a6959fd57bb2	252610315	$2a$06$EaoQZ4ECH66RlZL.WzsiIOM7GYsRAUj77k.H2atz3zzXwkynssXAq	REHAN FEBRIYAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1b8adca4-7240-4a3e-b7d5-ae3964a8f7b6	252610327	$2a$06$96laL8AEELYhgb1L1b3M.OdSMbgS2/8tAIUTFsmhFR75tXFvqe.RC	RITA ARLITA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9dfdc3eb-2588-4332-a8f1-1881ce18a0d3	252610339	$2a$06$L46xmIk0obJWndIIAB1n2.C2JMHPTavNPuobZfqj1vhdOeKkrl4LC	SAEFUR ROHMAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
766ab8a1-1d82-4bad-9bce-687359cf8c48	252610458	$2a$06$C5UqGzg67j.A9SZtoMf/6.ELs8RUbB.hyZuFSCWSf5Ufz14255pG2	SASI KIRANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
52c3ecea-e234-4086-99d7-1d6479488f1a	252610351	$2a$06$rBhnHh7DBnsi3uyUAuGjdeNI3uWJ/E3sYQ3ZmoR9sEvt91G5wfW/W	SEFIA NISADATILA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
819eb654-b7f6-4feb-a7b8-067ecaede9a1	252610363	$2a$06$4B3bkPn7t3LPgXn62ZmaP.TctF3ZHXvbw0drDrvLsbmeIQmbocdBq	SITI JULAEHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
24baf771-4bc0-4bce-a24d-f13f152d2e51	252610375	$2a$06$tu1EcGclMKBVBkMX9wfGruGShWBPa9KJradi/zwz6U2.tIgpkLAFG	SRI DEWI RAHAYU	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
87cb9c50-7d5a-42c2-86ff-8123c6cab4ed	252610387	$2a$06$jdzse.v3oT4nK5vb2tEZluobcyuTRVh5WQzC4Pv4IlCpHL4ymUgkO	SYARIF ROHMATUN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
907e1f16-fff5-4ba4-8cc9-bf81f24cda8f	252610514	$2a$06$TNyksYT2Y0KCQT21dX4wp.Ab4hguBgqKYrlecr.juEGEyNCjzRzbS	SYINTA SAHLA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f288774d-6a3b-472a-a38c-6afe594b8ea2	252610399	$2a$06$Ould5TlRW.NV7O5gOgp5AuAeFeuXQvTBoXJeP5RjBExo54Rb9sV6W	TIO ADITIA RAMADHAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
bdfaa70b-f5e2-4552-a36f-983dcd65258a	252610411	$2a$06$nJ/WLJ4F8C1t4upe3YTnd.W7YrvWgsWyx/mhhszUi9YyZJ0efsRha	VIONA NURUL AZIZAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
276c9116-48cb-48ca-8790-dd8dfa54d1e9	252610423	$2a$06$ugXJ6OucQVPTYv3MWkVAr.a.znIVYxPxfLUZPOqtJB8n7s09Ibn7O	ZAHIRA NOVITA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a1bb92ff-799d-4585-b8c8-5453a0bee9cd	252610004	$2a$06$EtW9v6bAr1gC2o7nxrrLHuVS8Q8wuO7fka0oDPjhGjItkZ1VZMP1q	ABDUL RAHMAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e88d350c-a554-4afc-9f8b-d92324436b13	252610016	$2a$06$UADVnc9evHxbPmuuJdlOHeSDc8zSRvg5ocbG79ItPJHuM9DXIfEV2	ADINDA PUTRI JAENUDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
13466274-7422-462f-9dd1-f112c942f9fb	252610547	$2a$06$GpOIGmvLLLpGKUtxSLFyreyMuLH3RxeVSy639JYAneDcqLILFCwD6	AGUNG	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
bf94a738-434c-4fbb-b87a-5ca97d4239c8	252610028	$2a$06$VPbQYq5JYR7Qc3TPnCdVlu9lJFQxRhRKs8ZnNpFhzFPFLKxExwX3q	AINUR ROFIK	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0542282f-4690-4c9c-961d-e3b2b1bc24ea	252610040	$2a$06$UQEearIPEfVsWf7cq8t59uM3Za08PKHB7mbTdie3Wh0TYayuS7hUS	ALIN NATASYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9d658f23-cb5c-45c7-a466-1673d3379ff1	252610052	$2a$06$WCiVs8LFHEyHkHwWBTRGYeYURB6e/raN3YZ95mY7540Ehi6bkLQQ6	ANGGUN MAHARANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a790b85d-88ee-4575-be62-e3701bcca19f	252610536	$2a$06$Dw6qA.TDF6XiitOhR9Tqzeq1//juQJPMY/56BFjiiy4B0r6u5Gg6C	ANISA AMALIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
93ea5ad4-ff39-4085-b951-0b5a02026715	252610064	$2a$06$QglDDEvp5yutkHgurP3BVOWRvYWchiHrAio/qBLhFvWZjIljWMOQu	AULIA RAHMAENI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d6459d85-86bb-4ad4-8d63-cbaf0912695e	252610492	$2a$06$GAbQmzg1l1nMPM3qD4.sY.XmI67JOh/nJacusjmTwoKc/P/s6FnsW	BUNGA SABRINA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
fd9f4730-4fc8-48ac-966f-2d46f9462576	252610076	$2a$06$5DIpDX4w6/9lzchdHXUyB.0UBXKKcTtZsosMDl8sea.wkktjfsUWO	CHANDRA PUTRA DINATA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8fcbc116-8861-4b0e-890b-74cd4f80becf	252610088	$2a$06$6CPVSZs3EP0SGwF8193EI.Zvv/66FCRwaWX4yUMH5DUH2SSLUi0oW	DEFIS ROSELA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f20f6ad8-5b18-479e-b802-c02062c6eed0	252610100	$2a$06$xhnoG3fiQx2OUOaEPuaAYe.EHYHhaludwwHPlKIIGKp7xKHTit6Wa	DINDA LESTARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8febf7f1-059c-48c6-8433-0e3e01ae8f88	252610516	$2a$06$BYQISk0/sqgS0aXXWVSKVe3RoxU6oosfkFYkneYoG85SlAYwwkc5e	DZAKWAN ALFARIZA AKBAR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0a6cb997-a9ac-4470-86fe-71827ba908cd	252610112	$2a$06$QrDn5zY4jYT4TQihRxZrUu0Ogiv.aaFOyy0Pxmgvy6y5s1wnoVmNe	ERIN DIAN NOVITA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4e7b6b34-5a77-41e4-b11e-d940f6377595	252610124	$2a$06$ccOe7NqQeOugFLMTguiwdOcxYj4oYgzi9ngUI9Uo1GayXfaOeLm2a	FARIKHAH AULIA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
10aa552e-63a2-403b-b804-171e92727a33	252610136	$2a$06$0Eg0XSGcKj94lVdKIRPqp.LCMUUBY6eVGhLCsS11cs03QxPOYAJsK	FITRI SEPTIYANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9eb1b553-10b0-45c0-af8a-ab9fbb1c4628	252610148	$2a$06$CexkK2Ncdw4ZtWv5LHJcB.K2rWZBOk4nz0n1U40.row7tWwBs4lGa	GIMRIS WILDHAN FADILLAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2a07be25-e388-4d13-88b6-c0b02a81539b	252610446	$2a$06$31uCZbXsGNWOZFtjl6HOMOXrAN3MPIT5bkBILKpIGRCq5n.XVamA.	GISELA OKTOVIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c82881e6-7c3c-4320-b5eb-f74baa3ddb07	252610160	$2a$06$RN/PE9G3tAVJRO7EQki5I.sk.HV74Wc/ZHGMyll9NiwkrqEN1iV96	IHDINA INTI RAHMA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f5d3bbe7-865d-4635-a9d4-b29a94e64055	252610172	$2a$06$hoX14FY10OK8/64REc1pHecFVrS1FfLJOam.sQchAV6/ixwuWzu7W	ISTI NURHAYATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1eca3b18-80dc-4565-ab62-1cd62eefbcf1	252610184	$2a$06$qY77CoErNRh92LcSnImK8ep.8TaO1E2IytAQqY3tviJZeZLp3n49y	KEYSHA JULLIA RUKMANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
fcdf164b-243c-42e1-be3e-fa13094cb419	252610494	$2a$06$Wc9ZiBoQ0gxMgXJ7QhcwkukxwOqXWih8cS7aj./D0QSBVT4dytGCG	KHOTIMATUL KHUSNAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
efc26640-d9fb-4f51-a351-e750a1b27177	252610196	$2a$06$MZb3xqnGnObdHumFaw2plO3T6EgGvhzd2nxBgo.S7e6TtF5PY.SM6	LINA FEBRIYANTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ec1ef93b-ccc5-4470-bc80-fe21ebdd39de	252610208	$2a$06$mPfCttIWPT6hXeVqOlGKiO1r9l.eVUWOWHix82MBLpcdVgrQ1hFMK	MARWAH ALI CASOFA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f9765d89-1c01-4029-bfca-132a69c57e05	252610005	$2a$06$2icMZufsH6XN4ivZ4gCNneGoqNN4/CuY3KJ7ZdPH1xqSTYpDmtSXK	ABDULLAH DZULKARNAEN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5f672284-5c19-47ce-8f99-3216d5aaf9d0	252610017	$2a$06$wkVL3tVKt2ks1XmjRJ6gE.X7QQjIzzmoSbJziMehe3CvuDIdvCWsC	ADITHYA PUTRA ALFAREZ	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
386e8caa-af49-44b0-a35d-80ceb9a2efec	252610459	$2a$06$tDFAgvpVwXSAn31E0TGGJOIkHX4y0I01D9br4eJQiAJt3Hh0N/Xz2	AGUS WARDANA SAPUTRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
640c25ef-c291-4aef-997b-491f5a0d6b1c	252610029	$2a$06$Tv/aOwoaCOhZc6/EmCX/Q.XXQCslAthcFsmzt036dgw8kLRqGQod.	AIRA DEWI TUHZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1eb5b583-a0d0-46b0-a577-dbdd2d8df972	252610041	$2a$06$/.AaCYGA9YYxJ/9KNpKqvOCb34h3Kg7wlw6fYqELOT7Ib4MSJTl.e	ALMIRA SASIKIRANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0399219e-e86b-49eb-8b37-3f6664a5c4a9	252610053	$2a$06$M7qw8OVnuMFzAQEq9ag0uefsAomA5IturFHhzNridR2JgfespKp6G	ANGGUN WANGI DWI PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
773b1f44-1496-4912-b4e9-4239d2430356	252610473	$2a$06$eN.vPY26uH1Ll0PXAfTZEe9KrDL38DeF1/ZFJ0OZRR82LA5MfWKAG	ANISA RIZKY LESTARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
221930bc-2282-4501-82c1-0924b9cd05d3	252610065	$2a$06$r8voLmh/2HYt3y/2ZK0kUuALIJ4.HmZQFOuyByj1hVHATObpig3N2	AURATUS SYIFA AZZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
96df97b5-5d7d-4c19-b933-a1750590680b	252610498	$2a$06$XA6IWDI6UNgju89wr3dOseZxzXG0wLs67/Zs/ugLQSzxxbApguXZi	CHAERUL NAZWAR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f3289208-d6b0-4e8e-a5d3-cf221d9402cc	252610077	$2a$06$u9b1OIGxmDmwrf7JXKHtseeVCoINwgembBAFmYD.p4PhO/XRTB/92	CHELSYA ANGEL PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0ef0a775-9af6-48bb-aac1-f010087f14a9	252610089	$2a$06$hwNUFYrQm9XHIrdihTmRYuN1DWTvgSf4FvcMXiS25Zgz7BjPsxOTW	DELA APRILIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3fe87c34-8f36-456a-be35-acd198bcc900	252610101	$2a$06$V2RnifwiD/kjn5wI.4egveSUDG6yREEobNScfKR6vBW3EK93Z3uKG	DINDA MAULIDAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
7fa17f1d-aa00-4207-9bea-8d3ed2ca620c	252610508	$2a$06$0P5NHC4hWZHabPoFCxP5eOPQ96KgM88sDyhiZaa4N8xYzFlwiuv1q	DZIKRUL AKBAR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
45b221fd-41fd-43e0-92ff-6c6236637941	252610113	$2a$06$vjCfSLt3y1Ze658DUGM6X.D.R6l2H/5DB.COneImGRb/FJcrluR2W	EUIS LISNAWATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0cd05f46-caa2-4259-9b76-8873b472f9eb	252610125	$2a$06$8qBLXjpKG5PHrqEIu6JdlusKRpXyAfDt1n269K5rxwAG84upa5CKK	FATIHAH NURRAHMAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
34c0a498-95f2-4741-9610-ec4b46b88385	252610137	$2a$06$zzgzWC67zu9jvgSdoEvV6eTb8jbtVRwLJ0yktjh1zdwnHe1eDRMaG	FITRI ZASKYA MECCA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e570b962-811d-4cb2-9628-5e942b9701d0	252610149	$2a$06$TNK5ZkD/QbpSdhXLOD5hhOHHmBjF3yJSgjCv3RTiD1fD/OrSIyiRi	GINA LAELATUS SUROYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
70b7d73c-f850-4ad4-8d83-b6da70142ed1	252610549	$2a$06$h2PlEjUSLZUdwmBhy7hXr.4PiUOx5REqgMr4ffPpAD.5kcZ642ypC	HAFIZ HAIDAR FAZRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e021b83f-76a0-4d6a-9412-2073e0988792	252610161	$2a$06$oA9fNLVzlGb8ouZmuMN6S.8JR1VkQQVObLPs.cw2ESO5jKSZdhtdq	ILHAM SAFARRUDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
19d39693-108b-49fc-b15b-20f4611d2f27	252610173	$2a$06$TKqq.9m1aj/MX41ezzSEv.IAoqmT0pMBDY1B5x5/KnYR/AdQIBf1i	ITHAN AZZAM MIHARJA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a018002b-b51e-4c6a-b455-0f2e06522cd9	252610185	$2a$06$nVkwBcx8XMt8Y9/.5f9hE.RV9Y4i5Ay1ynZFwl/Fmd4BVdapxGwma	KEYSYA KEN DODO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
771b3809-c179-4e56-8330-f141dd323eb7	252610500	$2a$06$2ALNaZ24VF3zbZxWmwah4ufnbfgnV28OM0Zxd/etV7KIDl4peUIfG	LINDA WIDIANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
14fcee2e-25f7-4727-87d5-49f19622b841	252610197	$2a$06$E1r0obB2bUwdD89vZ63C4uNVveZtVK4o0tXzx0VcLjCbjNITq8xDO	LUCKY ADITYA AL RAFEZA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
7a699ddf-961a-4818-bf7a-c616a1b2fbae	252610209	$2a$06$zPuZZa3XJYtZkLDsAyCOO.zXiHCnRvAcSmaijzqfg1rdOqRF82TxO	MEGA ROHAYANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
218147d9-4391-4a32-a094-2959884bd47a	252610221	$2a$06$A4efXmZa/TCUndsovAPPK.jVSBy.Z0SYTGQtpMwRT2/tocCGuf7me	MOHAMAD RAFA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b59b5759-4605-4fe7-9536-7bab6fec6fa0	252610233	$2a$06$UQMA7q.UKJ4zvUvSC3XUVeSDKF/JfcT9CiXVWF8na5oifEPHlFL7C	MUHAMAD HANAFI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
91df396b-fc40-4b07-ae85-9a0bbf49611c	252610523	$2a$06$dWb5ZjG2nykJwvFHcd1nrupzvAY82KoeSAO1peOJdoyVqIhxVJ.wa	MUHAMAD SAYIPUDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2a104252-33ac-4d7f-a979-7ba3fe7b3e65	252610245	$2a$06$aA6s1LOB4m8U4O8n2OQRDefQWK5a8f0xcSF52aIKyU2AuzNPVuVUS	MUHAMMAD RIZKI AFANDI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d12bcb08-3042-4f7b-aa2e-0b22358574d8	252610257	$2a$06$b8TOn0NzXytA1alvTIL84u27ebU/tHMP.xq526HjDsdpu1WH6FFdK	NABILAH AZZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ed28069a-312a-4931-abf4-67c9e1b13b5f	252610269	$2a$06$tjOsZ4LiJKDCi17PK3MxB.Z9YLvaOPxnmFxXqqn1fQLzBZ/UOzO0.	NASWA AFRIL LIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6fd70038-8a33-4e67-9267-ebe9a3b51218	252610488	$2a$06$.Rw5GpG66FXDlPEMpKUGn.cWSDxW8CMhQr93dOrJt3uK/Mux10j4W	NOVA MARLINA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5c5db008-2866-4e0b-aec6-feb2d8d8e270	252610281	$2a$06$vtIa4EZ9ojdxKJ2VIRFfCOHzTYn/mSfTxuS.MjptbIhTUMvoT1h0u	NUR AISAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b8b467bd-cfda-40d7-8450-fdbc3ddc4b7a	252610293	$2a$06$hKKRhevKniPKFmywSZugGugjszdEwsOnqfmwHgClJi5kXfWTJH11K	PUTRI ARISKIA NIZWAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
885725ad-0a2c-4457-a564-1fafff936619	252610305	$2a$06$DVq1rzTDfM4Dpsmom4JxbuJkxooGBg/vnkty/UL5Rqyh4w7rf0Za.	RAHEL NIHAAYATUN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
29e3877a-b396-48d3-adef-016a4781bd98	252610317	$2a$06$HEu5SxDrU25bP8n4YoBwZux6RyhMQ.jht5hC5cSFNxm44El.ID9mK	REZA PRANA WIJAYANTO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a086ebfa-acb3-470b-baca-42dcebced9ba	252610329	$2a$06$qkyq.W4qxprTVjKpLtYxf.QT1x09HEDllLYT2NtzUduc6JRxcqJP.	RIYANTI SELVIA ZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2dc97bee-2fc3-4fcd-b7be-f80fa1029a87	252610341	$2a$06$L/TVYEYW/dIQaD5peDO7AO2xhM0pfb8av93vyYelME3go1VQGF0km	SAFARUDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
223aabdb-8ccd-4731-9397-823566095834	252610353	$2a$06$uAOo4ZdOFPWjibG4E/KFTe5G4jT4P6m/yiZrPfansWby8A7ZqcIoq	SELLAH WANGI AMALIAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b214d259-a2b0-461c-b257-f9f2f321e03e	252610365	$2a$06$gYAcVW.0URhY9rZbDkfN7.ivSPuX1NNAadoOT9yV862ZRnEFKLxAO	SITI KHOERIYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b6b00c23-010c-4788-9329-7c907eac8c60	252610377	$2a$06$A/DY/9ryIk7GAHKcf2nf7u9GyumJ/./MxUcq6q3d7ATSasdIlKmb6	SRI HANDAYANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
46c00a65-20df-4bd6-8474-ef92178cc908	252610389	$2a$06$5QjaE.ezgQ9hKvbngZvYfe6n34nrSHKiUifymOQ5nk8FVms0OEG5K	SYFA FAUZIAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3786e610-cb63-4845-9f71-9daa1ea9dc72	252610478	$2a$06$H.LQo8FPoB6X3L0UeqQU0.21jHK/LWvSPQIVuTMwHjUF0iAOQs0Ua	TIARA MAULIDA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8d276e33-4803-4c6c-8e98-552ada7b7321	252610401	$2a$06$etPmRr4xKq8VCO3i6RT4aOk7/ZqiTn38EbZgPxPEiFeMnTORMeyDS	TIYAS TARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f6dc0f7a-d3de-42a1-90bb-fce6012d0f0d	252610413	$2a$06$3p4WmtcCi87gXYRiBo1asO8/jG7uTnzv58.8/dO0bN29Bt82JE5o2	VITA PUSPITASARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
18588247-7ae7-4fc5-9f8f-1e2b37611cd2	252610425	$2a$06$RF9KA8aa5AqrrRELJjALEuf2btyHKZ.cYWXg2R7Tpl0GvW3.CrnUy	DZIKRUL AKBAR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b602fb82-c6ab-4af5-8b02-d06e12a87a1a	252610006	$2a$06$j3JOA7831GKPxRYTTh77l.FeQhxfp3oXTFdpxzKRhxWwBXKDhdgme	ABDURRAHMAN JAMALUDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
db25073b-f733-4c53-9eaf-5c766af756cc	252610018	$2a$06$luf7un5vZF.RdQs2uiDTIer8eoKZsfZ/4tM.yupDWKUzpDm6Y96BO	ADITYA AL FARIDZI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b437d878-bd5d-47f0-abb8-b82656cdb8f2	252610506	$2a$06$ROpngV/CxBDHUE/7sJNVAeEWBOoxGhwMi7crtrnqbt0hiPVRuPhSu	AHMAD DANU REZA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
74ada3a8-a9eb-4206-9759-6c96895c144b	252610030	$2a$06$VIxP5umMGzN8wIXUUdhxYeIOjwZBKdZUdIlb6kT9xzyEW3wJLwY7y	AIS SYAHARA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ccc38f53-611a-4bbc-9c54-c5b403033c6b	252610042	$2a$06$LscptS8ftw/aOlshEV38lu2mF.OEg9wxYGnl1KJBaovNhZJus.AXy	ALONA MULIA SARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
66be6419-27ee-4df1-9c9c-e4f485ab985b	252610054	$2a$06$J3Fz11.4DdO48WcjfQ/26OAhvNkWnGV2FD3jlihoSGX7ylmXv/OFe	ANISA JUNIAR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f8b25ea4-230e-45d4-851c-4235a865c74c	252610447	$2a$06$b.ZFYkWTLfjBGmLRBIOHM.T7Qo9C6KJoPPjJvQ7vvs1IfW1UPrwvu	ARIANI SABRINA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
7b1a0640-7951-4ed5-84cf-dc0917f76e32	252610066	$2a$06$oaDfeQQvj76VGQ1w.dyVzekLO0GjkfyhDExi2HSVtmQpXrHw2gY46	AYU ALFIANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4d5edfc2-31a6-45b9-bed0-4552779e1380	252610078	$2a$06$ICYjLBjJDX6sc37maJKuJujRBCaOAFjQDRVHFlVbmGJIvnVXUEXkq	CHILLA OCTHA VIANKIY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2e0a1e6f-6eeb-49b7-b128-ca5eb1ac2c41	252610477	$2a$06$TENPQo3mu17/.LtjKmLXnO15cp.neuwMGwH3YsOD.75OUwPukWs1W	DEDI RUSDIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
03caea97-e741-472e-866a-45189ed3ffff	252610090	$2a$06$ebNOi/xqscncJbIxXmoxde0z3CAcxhvYRQXVCD/YZsKxwCe1qw9/G	DEVA ROBI SETIAWAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9f27a439-564a-40c9-b89d-4524cc5b9999	252610102	$2a$06$sD5dBrG0OfLmv2tw7vPdVuMlhwxcM0B7hQQLMLOw6T1Jlp.jgCQGO	DINDA NAJALY AZZURRAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
34a5374c-a2c6-444a-a2d0-8a2547517322	252610468	$2a$06$l7i.EHkyHK.l3lT6PKbqPOlwFKIYSf14KuS3LxQipQVR2fJQt5Pui	EKASABILAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
42807257-e6f9-470d-b5e2-e3fe7be9cd4c	252610114	$2a$06$IwH1K4L5LcUrYij2uHqbFeJB0wxYuDeZBdnPcq3jDR/IfF9rq9YDa	EVA KHAERUNISA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a40487a3-21b0-481a-83f5-6ee6d351a29a	252610126	$2a$06$MWztvYCqiwmAfgbBueENs.qQTU2dGeRdlwG7VYAdQq.0VBG3/VCYu	FAZIZATUL HAZANAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
85a8f2d5-0837-4ce3-9074-eb41759aea44	252610138	$2a$06$qbhTmvFP2uRId8hZH1L2LO1TmV.cAl8gVSsqpLw6cCrpPI0rOIH/a	FITRIA NUR QOLBI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
60593ad3-fd0e-4871-98c0-2c36c8cc1cb6	252610150	$2a$06$ly8sSSJUVlYQGFL.xZD8x.DAqacB/dvo.1Ua7GEA/g1KBGpYCCRHq	GLORY MARIA KAYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5e27be5b-ba77-46ea-afae-264a5417b1f8	252610439	$2a$06$1w1GW/O/C2rtL3o0qR75F.9K325I.U3lL2jJq49183niH3vXVz17q	HAURA HANUM MAHYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
95cd1d55-dea0-4cd9-b42c-c19c84102669	252610162	$2a$06$BTCOJQZlUYNHlrBLcmJ.w.pFIFfLWYUkF8K7DXUddXHU4XZ3y6eYy	IMANI NATASA MACHMUD	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6fa600ba-e27c-4fc9-a42b-3efef7b5e32e	252610174	$2a$06$uSTy8khCOJKm0EMMzRo50e3rXv0zc2MQjeGkxaCmY1q9h8h4AOzlq	JAHRATUS SIFA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b684cb6a-8f15-4d74-a89b-8c4c742e1d52	252610186	$2a$06$42SEc8.t6EsJsHOtK4EGWevkADE.SYyCD0cDP9OFlBG9rwO0cTes6	KHAERUN NISA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
31d0e597-08c9-4fdd-8e39-76c390462e31	252610445	$2a$06$0.01I7/N20Oh5FiJy1fj8.XeZv6kfWQQNNlEAu0fD0jFpbve.2IY2	LISA AMELIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
24dadae4-5106-4a01-aa66-d65eb71a5bdf	252610198	$2a$06$wpUAzt1eewuzMXS5ARrWw.KwCgrycbBJefjzAZTxnRL/ipen5haoy	LUTHFI KHAIRUL UMAM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
23dc2ce8-5d1d-4fc4-88c8-4d4851ed53e9	252610210	$2a$06$HmY9u1pRulx5Yse3qMet7eYAeN7uQ7K.pxnbRMt9bwnKoDpEbIiGO	MEKKAR WATIPUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
deef147f-05f9-465c-9b6b-74628524bc09	252610222	$2a$06$WyRPuA8Hxr6zQt7MRliTHOIM.DhxHD3sB.fqu6Qk7PSgtEfzCmXj6	MOHAMMAD ZIDAN SETYO NUGROHO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8ccd0d2a-8460-415b-8d93-6f97c9050a58	252610234	$2a$06$W.0Kzl5hFkQsBQUkitLQNuEuyY3ywgFOApQeD21SfM7IxkmowhT5W	MUHAMAD RAFA AWLIAH FARIZZ	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
42547955-bad0-49bd-99d3-61ede0535e92	252610490	$2a$06$lJXUom7bDYvURmGAeP2ogu9DeVy3hedh5wuO4fQ7dpGURAs1UTXOW	MUHAMAD SUHAEL	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f1b0c298-d001-4635-9830-b7145478029a	252610246	$2a$06$vlpgo58EUymH.EWX4ic0ouHBvxlOhSmm.kEFMu6YDs8hKjeODNljK	MUHAMMAD RIZKI ALAMSYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3c6bfd43-5cba-4336-9694-4306893a8fb0	252610258	$2a$06$D3l7DI/.yNXrU8shqFwwqe8fH2XMiyw81uQi71m.S8iQkEfoDgD4m	NADIAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
97d53068-4b51-47b3-97ee-384ba2a0e134	252610270	$2a$06$blbSDCrBqpEt6aLCBTfN6.tJWb23ibAWYT/OigglEiHdRJbFxs1eW	NAURA AZELIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0ff566ef-abc8-41e6-b360-04c1d819e585	252610282	$2a$06$HupzOo8fZweyx7yFJWldjedlop6lVajGKjSHI9a1SZiE8FG8ObiEe	NUR FAREKHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5c8b760d-9579-43fe-a765-c431bb92cf9e	252610452	$2a$06$L0zAbsV0ztU6SHSHjFJvKOFWA1jZLgtNAFaQR2jLKC84typo3anIu	NUR SUKMA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9627b51f-f650-429f-a545-783e67f0b45d	252610294	$2a$06$MACBz5FyZQzv8BkEt3pjS.mFvzMMxEYfAgwEN.juQidofwrvDZU/y	PUTRI LINA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
db34c3f4-2469-4385-ab38-822704e5feb0	252610306	$2a$06$SKjW0.QULPWNT/QmEFDPgucSf7eDzGDp2eizbXeLMyB0ydKhHKTKi	RAHMA AYU DIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4674494f-e68a-4d9d-b4ae-8a8410a4751f	252610318	$2a$06$SKvvd9W4zk0bwq4fcbZD7Of.kKoA1vabuNEtdMkosfu/3Wk/wPOeG	RIAZ MAULADI SOFYAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d63a07b8-dbe1-4227-a184-51663c0a0212	252610330	$2a$06$if3CwV.WscpaSNH9IgQU6edM0KecwPfjFcTXDE20np7bIv5sG6iR2	RIZKI HAMDAN SYAKIRO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8249a324-6063-4fa6-b623-35ae74bc428f	252610342	$2a$06$Y.l0uU2oV7bS8sxscijztuWH7absU716vuyBjoYN6gW3mpNs49FvC	SAFIRA AUDILIA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
19485482-b1a6-4fac-b675-919b0e6c4bc2	252610354	$2a$06$wiNHgyt59101BaxfMSJrP.kRnLTLKMbD7NTfmYTqdNv5ZhPvzH3qS	SELLY DWI AMANDA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cbb85541-ebe3-4bd6-9b3f-f0fb9528331b	252610520	$2a$06$W3TkeIrSpTlVs3pxMcOUhe2OoCctKuvJ/DsAeHXvs9qxhcLWWNJ76	SEVINA ASTI ZANUELA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ca334a12-bce2-4c8f-ae33-89cd51c4b18e	252610366	$2a$06$Jr33hNQjrbYW46JLYCJel.h96Vr4OlULOoZ2jwLeut94i.K.udn3e	SITI KHOEROTIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
41302fde-7613-4c89-b5e2-1cf288d3a52e	252610378	$2a$06$MY.arvATBRWSLiLGBQUEhOu8vHP1u0WI9M4aRA8pWsg2RDvu3XqpW	SRI WULAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6bcfb386-598f-4880-91d9-17a579b39102	252610390	$2a$06$aKwV7p3Zaatvc6DSu3lg9.u.2cchCL/l0CmFsjLAX0Qi6gatxaEMu	SYIFA NUR ADHWAA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
183c1d7f-3a38-43de-bdfa-71a2598442ac	252610402	$2a$06$yJpUyfWS9cHaAFvPFfDhOeAO1VUAD5PXKrkE8yvaRCeCh8fDSxALK	TRI DEWI NURAISYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8d47742e-9a9f-4bd9-9e29-d83be8de739c	252610467	$2a$06$0HfyoZ5vRS9hlMP..TyUWuYjBcmAT2dfXzL.GAmMR2Jglj4w6mXmC	VAZRIYATUL AULIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
960b11d1-76f3-4c71-ba1e-a36fb9a98395	252610414	$2a$06$1DlTSwUHX1jNa0p2pGGGsu/pDQGIaJ2RhM3VJRiFaigCLiTi2zMUS	WASUL ARIFIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
02f33466-4931-48dd-8220-ff5fa14a8cda	252610426	$2a$06$mISKQSuiiLFaHQIAuGxpL.1JSSxl.qLuBUw7I4E0b0y.N2YsZyShu	ZAHROTUS SITHA KASIH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
7fd9f9f7-e29d-48a0-a991-709a21771fec	252610007	$2a$06$olFNLLMq0JfEq.YLBaB1Wem.LH5D4E8POXWyWpBoIv2DPzeYb817e	ABEL RAHMAWATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8ea1a24f-6dff-4948-a701-4452d9e41bc8	252610019	$2a$06$U8GP9B3.Z8hk/7vPoNUg9eZFbJyOO/drH1SAd4KRWv46e2vZE7BFe	ADZRA RAHAJENG MALANDY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d53a4e73-d643-4ccf-8a29-852d3b4e1801	252610526	$2a$06$UMphQoGkfp8i011Cqs62leryhbO0/Q/8zOqSQBTXILIjFqaDVLwPa	AHMAD FATIH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
598fae5d-4d38-488f-a261-4ef2a5ff121b	252610031	$2a$06$rpSvQxZk0JH1cpMGY0Qkq.nx2/YvyqrLLbOVB9pLsVyaA9A2psCYu	AISYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3797b9ad-87ea-4f3d-9a10-af7faa52e681	252610450	$2a$06$25LIF3/.jJCwT5SbpsQE0ee/A2wHlEUSeSzICy8wWvV3I.IZgKewK	ALEA MILADIA RAHMAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4c5f6129-35c4-4544-9c82-572db2429adc	252610055	$2a$06$19NmWNFP/Ac6h6jWWvsgduZdLAo1GQjZbTk1u4AR092yJrvdNjL5m	ANISSA AYU LESTARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0f1c5c69-ba4b-49ba-8f8c-9efd0fa4c356	252610443	$2a$06$7oNPu2vV97vHy3B695p6wO.UJEi4qvKUL5CzrbUYH6FhPhg90zrVy	ASIH APRILIANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
25211dcb-095a-45f3-a431-7811a38103cf	252610067	$2a$06$uWbRHo//AApLsHzgOL0tdOFMovpeJnk01I7agMRs1dNoUd7VmGNqm	AYU DIA SYAFA DWIYANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ec664309-f061-4314-b962-43d13355d9a7	252610075	$2a$06$yzTKKAmjmd.ZktfjWO1ED.l4qvmcNmu/QUjzYZvhtG03NGQBcjTUW	CANTIKA MAUDI BUNGA FERDIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
84f0ad30-f52b-491f-b67c-cce296c583ab	252610524	$2a$06$5Ol4tPnlzNdVN0Zv5pCpzeEAhDv.qR1soX78Tn4wzu6I1iCR2wNN2	DEFATUN NISA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
121428c4-de0c-44e7-8e31-54971adea638	252610091	$2a$06$uXNkDseFfVrxjywx6Q9ERucyE7LZQtzlIDDedeG0UVeBxhYpYWM4C	DEVARA AZKIYA RAKHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cf758f2d-b865-4df8-990f-91d9b52d258b	252610103	$2a$06$TT.s4BIkgXAg9I6iK8wnme6aJr/Ec0kDsuolO71ZlL9lQeQvjf.OS	DINDA SHOLIHATUNNISA ARYAPUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6f920aab-2655-4fea-85b0-156ecb297184	252610539	$2a$06$x0i3C434Fvfy.Hwat6efm.431OQLqdobosSRbh4D82tL.zxa7Am5C	ERVA FITROTUNNISA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
99b55e24-45e6-4fba-a787-7d75718d6c2c	252610115	$2a$06$HXCYTz6BS/Ft86zZvdyPge5BrjE6tIf7onaBxWd/OK/j7oxJWyckG	EVI NURAFIAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
feec9326-0404-46c6-9ca2-963fb1243e77	252610127	$2a$06$.bawiH9W3sNrfSxE5QaAqOXexWwHmu0Eqtmq/coBgTRXLtvKTKx.6	FAZRI PERMANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
548569bd-00a2-422b-a5be-4ed73b29418b	252610139	$2a$06$JtNKTcFxVJSA3qbvUY.0/OBsb1pOpw.gIVs2Fr.hGiDcEsUWTsNWu	FITRIA SEPTIANY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
249c4596-0238-40a0-8273-a4af8843d6c3	252610151	$2a$06$90fj74QiXxXAueqIw1127eD55abYDXL289bz155lujl3m2nq5olGi	HAFIZ JIAN BATSYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
67a8897b-5c71-4bdf-bd8c-d015243b3fe0	252610495	$2a$06$Uo9EpwUiMoP01aApn4KrrOfQaRlnVZeIfzybPJYGZ8HV7AQiMb70C	HILDA NURFADILLAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e31e9db5-d2bc-4d07-ac8d-326bcafff604	252610163	$2a$06$q0VZG8ZRX7n9gjTPrEUEwed9px30PXgKNcf.2GkSo1a5r9ydrIwFm	IMELDA MAYRANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6cbbecaa-02a9-4b12-baf1-a840795055c8	252610175	$2a$06$UguJeGxb/Kc4wqjkzQ3KI.aJ6g697AnE981rG95Yt.I0Dri8xaApC	JIHAN AULIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
abf70017-3bfa-4265-9090-783c33194c70	252610187	$2a$06$bjtvRg0IUH4c5bd5tRiQ.u5BAOHwVLinpi76IbvBPOotpGDMfTsea	KHAERUNNISAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8ca6d0c4-513c-4cd3-bf6d-8d9ebe32755f	252610199	$2a$06$LlYdbEUAP7bgxh4D6.g95uJ/9ERMu3whZFGRUpgMIsBoPVIzV.A4i	M  ADITIA BINTANG PRATAMA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a244baf2-438f-485b-98c2-5a932e2b8182	252610481	$2a$06$RxL83ILuAKJ7dQuLAQO8u.f/yzLR79bBQJUyIZls5D60w95Vx0kd.	MARSYA AYU ANANDITA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cea2c393-0971-4401-a7f3-a8afde49b492	252610211	$2a$06$e69fUNtCMJJD/xsuGOz26OMGTiguqlzZI4Xg5SAeAbs9iEqWojqm2	MELANI PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6d29be7e-de8e-472e-a444-d9224c2a41bf	252610223	$2a$06$4ZjAHeAv58Sro45xHYIC9ubPenx0DeeGLTXXGN6pG5CVbBnUVCseO	MOZZA NURFADILLA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d527cb1d-4cb8-4a5c-b270-cc41e823f412	252610235	$2a$06$30SDdfHMVGjo9uFp3b0ItO.G6Uc1357ydGYXMkUgEkk56SN0rJi2C	MUHAMAD RAFI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
7dca3546-92d1-4ebe-aec3-63e0824a9543	252610497	$2a$06$jqCnc9fP0wN0rNQ7wEj3euIHvm5BAh6.8tpqwUEqWVD6mrZJ5K8yG	MUHAMMAD ABI AL FARISI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
afde3e7b-7963-4297-9e52-f3171583ac4c	252610247	$2a$06$IbVKBi7InMB.8.G/FCv/uuzHSEfB7KDLCDwcKI2UH6ngpU0K37KRO	MUHAMMAD ZAENAL FARIZ	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2f912e3d-f65a-47b5-b98a-95906897c831	252610259	$2a$06$HdlrCKKRtK5znxevnxk9w.n5EQW4NqYV5GajrECRs75sTWA0XmAci	NADZIROH ZULFA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1347131d-c70b-40d0-8d3c-7c8b7ad5e50e	252610271	$2a$06$DcwivltWViLQ6aOEVnN9xO.sJRar0Jq7qdYZZGaviqCywOAgD8s6S	NAYLA LESTARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d0d1811c-0e07-42cb-b632-2d15bcc79ab1	252610283	$2a$06$K04NS.Vkf5Z07gnXKQclsOyyTDrmmTjJyW7nBgP8OrusBe2S11tyW	NUR KHALIFAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
21155ed0-1e78-447b-bb59-367a018dda4d	252610531	$2a$06$4rg5H8HC6KjlPwZeD4L/GO/alXuRbs8aUkpMcFSXLCR.YwJzGTKAS	PANGERSA FERNANDO PUTRA FERLIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cbc5e389-d9cb-4042-988b-ca4e6712fc1d	252610295	$2a$06$DoJYdodE9wm19a48XKaJr.7UWFyl8F2bZQWSLFTslGsNEsjH.KhD2	PUTRI NAWA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9b86a96b-9189-4ad1-8c0e-9d25b2e19f2a	252610307	$2a$06$rVy9FtJNklPuhzfnsImgs.59N7FcgvlJ6A.XbJqhAq6zXkhUCjtnC	RAHMA DENIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5d21cfdd-48c1-4668-a918-a79c9d28b4ee	252610319	$2a$06$O6pUIgzKY0psm0GvSuTJJu6a4pvsF10FmdZLg5Q.kVH9.d3UIzfiS	RIBHAH MAUFUROH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3f5a41f0-1d8b-4f6f-91e8-43f153956b95	252610331	$2a$06$QttKFXEn1T.rKcDshAAX6e1tjh.u8Jph3hhQCyeosmYZGpxy5OnbC	RIZKY ADI FIRMANSYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f2fa27fa-d93c-418d-ab4d-9b24a9eebcd3	252610415	$2a$06$MZ0lvfGOyIN0OYHWHsTFeuUkouYsHLW.eFTy1/D6d/3fyDh.PPuYS	WENI NATALIYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8bae5b4c-f0b8-4623-a35f-a034e2a1280a	252610427	$2a$06$mkcBACNNlbyaBtvErRRKv..D3Pgy7J2ya58GpnCpwMN3/ra7202zu	ZAHWA NUR SYAFA'AH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f3a86dcc-357a-414b-9a48-b94bd14813ac	252610008	$2a$06$MxIVQ.5keAfWOYEj1gzsLuELe5f8kddaOCUpKLKm/bQxXh9G6w1sC	ADE NISA RAHMALIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f8d06c8d-7144-412a-a53a-248acc87a330	252610020	$2a$06$cwgquGtdJoSUE4qxJunAS.Iz7XENRBc4D3KiZ9Wa3HJWRAp1EFe3K	AERRA RIZHUKI RAMADHANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
de7e2636-6958-4db9-b9c9-b0ff6cbfb098	252610032	$2a$06$L/PJ4BCCLfFCfkK07wx7NeOfy5ooeAr3di3umP88/sUxBQAI4t84K	AJAHRA AUDYA FITRIYANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
40949ffc-d754-4bf5-bc5c-b4ba010a6819	252610486	$2a$06$d9vmqJQ08e2xTSGtBLtp8O/6POkCVfSolEOdH0Oe3YqTG7nyB3BQa	AKHMAD RAMADHAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
96f0d718-c87b-4724-a866-5a6754781c71	252610044	$2a$06$2B1vf.9ckOueZw5adtKfIOxfgJuQJruniZb83TxqBtlsGDOlT4eAK	ANDIKA BAGUS SETIAWAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6de98ace-7eec-42ad-b570-3cfdaf9468d0	252610056	$2a$06$vXAXjzdMTOQoWwgqiRRV3OGzJWc6qLSIdjVk3yTYkleHqZY23UYEe	ANITA ANGGRAENI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
7124336c-6e6b-4693-9383-1d60d7113b3c	252610532	$2a$06$Ms0jt4tTQm0YBJvY4xxwvujSqx9ne8zz8lJ1HsivGe9jwFP5k5o4m	ASNA MUDA'I	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
46842dc1-7a82-4a72-94ea-bd55ec269b91	252610068	$2a$06$hevC8xK0rTuiWtXras3gPeJapwqjk4Bz84iUsVlh2J/ammcwSoAPS	AYUNING TYAS PUTRI KEN UTAMI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b141930d-cd64-42d0-95f7-726137bdfa60	252610080	$2a$06$VDLWntAet12eX6huYEmq/unmg1yTsyhGudhGeQx1h2CAVAXOLaTUi	CINDY ABELIA AZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8ed668ab-14bc-4d0f-adf8-cdc003c8e996	252610528	$2a$06$cwcGEMa7pDFpLnS573RkT.vVJJMh85t64wGndy6KMhdjQ7JF3kPBG	DEVANI PUTRIA AZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e5d0a24a-1d43-48b7-80f2-c1611b151cdc	252610092	$2a$06$4ag8fSNfvnBmCQccPedwQeRbP4hs6aV91/cWxu4fP7FNdVX5zIdAu	DEWI AYUNI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ebaf506a-8240-42da-b574-bcd958c5284a	252610104	$2a$06$ovDm8ggkdGFBYkH6NMFXnuyJrjXoSAdISUctPKTQ2PeNxzexmb6m.	DWI ADHISTY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4db72489-2d82-4b94-b7de-fcebab3e65b2	252610116	$2a$06$ZqqJxPGtBLL.fZVrzDWM3.RdiJu7JlO4GNdP5k2CBrDFFB..S4y4i	EVLYN CANTIKA AINUNISSA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9b560720-fa10-4dff-9149-a4d1f096b8ff	252610507	$2a$06$DZciZ08UoM1DdjkTbcyqj.udPr6sfT/p8XkAMXxiPLVjwabLv3Flm	FAHRI AGUSTIANTO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a0b1fb2c-7b41-46c7-8164-d07891d4c529	252610128	$2a$06$m3YrbUlEBZw8pVzyPqvNY.mjJQI8J2HfmyIQQ8iDm3s0hgGRY5kXW	FEBIYOLA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9952cf8a-dedc-4c06-af47-0967a7952696	252610140	$2a$06$BYZkUCkzHS13f1j8BsKoBuGRAbluf9VHHSeIzApbrhJZr1cAKVywG	FITRIYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e8aa14d0-fe25-4f01-a093-6928dc49e9d2	252610152	$2a$06$hVO4iKoaS0JeUVBYDg.ZTeaJCamF38Xk3taPs00ZRRLsyhe0SP91W	HANU PATUN ZADIDAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
51d5876d-059e-4c09-abe3-197741eb9143	252610541	$2a$06$xLmT2rqI0aGwmIR.Id9oA.WIeyL/PhIRf2Ao9ftIJjeNvGGYdNnNC	IBNU HIDAYAT	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
bc36f698-2d1c-419c-be7c-def39538522e	252610164	$2a$06$4yQFZA3wKtQbgpLa2JuMy.Fr0GdTcBImHKnSr249tdADSXJS2TjqS	IMTIKHANA FEBRIANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a2dd7d9d-a529-4d9f-90cd-90574e9d87df	252610176	$2a$06$nQt5uhE/UEUn0a46.D6zGepoBgURL/AZLgcbomsXRslXjgyBAAxTq	JOEL AKHMAD REZA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9a4085c7-e6fc-4e1c-b893-df3c146a182a	252610188	$2a$06$PVRn5ZQK/gS.42WS.GJ/muakuif./pYtYve3so6UDyVwHFuN8LNFa	KHAIRUNISYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1f3b6345-9c5a-40f2-b26e-45b0a2fbc3a5	252610200	$2a$06$RK2OokCi.GnvVfQ4Ljt09eV4lBK5mnvzCiX6ddbtNpT3vBO7CdOLm	M DAVIN KHIBATULLAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
400348d9-fcdc-4807-aa29-13f1c7481085	252610534	$2a$06$bp.2RG2xTlXqTT2BO5tMTuz3q.gCASfJLyKZO/ljEyOcez5pvIB6m	MASTIM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e8727ab8-794a-48c1-8427-0a8a46b8d7af	252610212	$2a$06$ZducetyizALG5Ht1fW7.tObrj4zCM8k062HlNuOSj9hjQLDUOP1n2	MELANIE POETRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
94fbbdc6-0037-47a5-9c01-8c5a909d4d5d	252610224	$2a$06$JKqMFOCAfA6dTiRmFJlGL.jAEd1fYSLKKrPMea/NPAUChnn/Sv1y2	MUFRIKHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1fd5002f-ded0-4f76-8ef1-af8158173ca1	252610236	$2a$06$Gt8WXCo37DgiqtbwT4XYt.9ZtT6azO1B61jbE0FZZfRnpTc/pLGP2	MUHAMAD RAFIE BADRUTTAMAM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cbe04eb7-7d7e-4969-965f-46659f87021f	252610511	$2a$06$TZoEmP8.XuB.LazUrcBUQeieiRkNWB55MyMOiWbDXvn4FnuBZmQze	MUHAMMAD DAVA DWIJAYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f6be9c7f-c3d4-4441-8346-5aff85ce395f	252610248	$2a$06$NrVgMwDDsYkdXZlUXqCX0..2qrkd.1lXeSUOt.KOIxOKXT4b1vOVi	MUKAMAD RIZKY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6434b7fd-ec74-4291-b9e4-92b9f5772cd9	252610260	$2a$06$poEeM7g6oU9TOc.4Cc7f6.18ImWVJmjPXeTNhhoESm7ffe8YUU1Yy	NADZWA SANDI ORIVA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c5e1c59a-49fc-44c4-b8b1-fe21475ee1b7	252610272	$2a$06$2d.Ah3STIPP78qNeRMl.leCkyXnIxFKGyqNwUw1xO9.mYrIRAb08O	NAZELYA GIZA HUMAIRA SANJAYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f165d88c-8ebd-4102-b59f-c867c29f258e	252610284	$2a$06$BIsSZEw1DRj7UNtVJosayORn7s8v5KGs2Vi50SAV/T7HsZz61tOZi	NUR'ALIM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
22eb1927-3bde-412c-a565-f8d8bae675ec	252610296	$2a$06$cyPGN3Jb1ap8QBjDa7/Nj.5OSVOXYeWlVX5m3rMEhzziG8bjMpWWa	PUTRI NURAZIZAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c73631ff-cf6f-47ba-833f-dede5a958533	252610487	$2a$06$9DwVEvYr4Z7SWgIDQeIP2Ou8zTYlxqzSh3gceCqJ5BMdbgETrSTse	RADEN CHERYL DIWIYANTO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
46feba99-a7ab-4125-baf9-c4ba45f8f166	252610308	$2a$06$eGOuhU19C5frtrwvyHsbL.U.Th4RltGxSk/zHsowhfo1ZWxs1AvES	RAHMA FEBRIYANTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9ce6d2b9-d8b7-4a33-bb51-bbfe1e702b66	252610320	$2a$06$h17IN7uBrbQRhRPLAE2e2OsLHEN0PLR.xLrYpOulx4iTPRNohOJpK	RIFA APRILIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5e4bef56-c981-4bbb-a022-a107ebfd6cc4	252610332	$2a$06$i2/9n1zWkYbKWEaXTZaiVuEtRQEWK1HQmN/BlFzUBDAQF9Vmas2.W	ROSADIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a020b79e-6e8d-401f-9daf-d3757a515972	252610344	$2a$06$Rzu8LrlWqEntVH/59kHyqeeOnL2MxWWny.T9VoAt8iZ9jW5Y7YbEO	SALSA ABILA RAMADHANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c8d9c8e2-0325-44da-9fc6-b55ed0ad02c2	252610356	$2a$06$vOVf3z0nYtaEwZHBuP9tF.gOfcNIde0vNoTETH5ahZuzJfoniYc5m	SIFA NUR ROHMAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e6c7df7b-e7de-4a44-87dd-845a11fdc6b2	252610479	$2a$06$qpWKnuCjeULhYCab33Yff.B.SfVpegizU0zvlYAqgsQni/BpS8lyS	SINTA PUJA LESTARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
7473b009-98ab-4e83-a58d-0cc117ba0c3d	252610368	$2a$06$MwJ15efVpFVxLL.mS0s7e.7x8Fwww6gKN1LEOGCSykaUw4ISzIf1y	SITI NAELUN NI'MAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a1d878a9-753e-4391-8366-5f499ceac107	252610380	$2a$06$Nh2r8wuH4CQ4E0J91EY5tu7pXmhMsXaT9.l7vvl6FBvkDmYuSnnum	SRI YULIANTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
83e2c46d-b100-4750-bb8c-61bfc071e6f0	252610392	$2a$06$UIO9o21OSF5bcIGM9D2sA.anU95f8gFCF0qr8EPZhdiWqdAs1Rmoy	TANIA DAMARA IRTHANTY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
68fb5755-c0cd-471b-bd55-c757db74949e	252610404	$2a$06$JGUhYQDn8Ug.OntyxtRnx.1XQa3n.i4wXpaKF3pxx8/sjI/iOXs3e	TRI YANI OKTAPIYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d2a469e2-7293-43af-9da9-e23cfff8d155	252610527	$2a$06$K9qvmimcuT3IhwPEAJ4lkeCtA4KAOhSb7nZsCwRVTSgm7wCKJOFva	VITYA PRAMESTI SUHARDU	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9c85008a-563e-4d00-a5d0-db501056dbe4	252610416	$2a$06$.q6NAW5d74AYOiGvO2J99ugDlpsdXYU3j/ci.j9PvVeRCk.eGGZLi	WIDA KOMALASARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
be78b984-6161-4a63-af6a-d267ef7a2f69	252610428	$2a$06$aadU2KRjBLycPhXeqfZEF.DkwmODjCB2p59bEPax.HrBnA0RCuoVa	ZASKIA DWI YULIYANTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0d8f9f71-ec84-4fba-a336-ef07fd2fedc8	252610009	$2a$06$p2KlGK4b.Mqd49iUBiZKm.VHMxsw9Tipz0Krmbrm0WIe8xGRkw3zy	ADE PRIYANTO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d54198c7-630e-4b36-a612-6e6e9cef4624	252610021	$2a$06$E7SrdHsSmciVrRnZ3UJJ1.Pm4T0fWdtU/DPCx2DCW0HxNtC9TdTty	AFGAN JABAR ALBUCHORI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
47963311-8606-428b-9ad5-59f4de52daa7	252610033	$2a$06$gX0SLaFothalenErYf6To.1Bsr38mbTAFJIPAZrd0Thleywr1jDle	AKBAR MUZAKY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
afed8e51-de43-41f8-a408-68f039b1381f	252610043	$2a$06$zqiQdE4wVOwtLzLcSpvsSuntP8Kp3U/.zcd88P3O3iYLFtUUGDY.a	ANA SEPTIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
fbbe393a-8fcb-43a0-8f53-5bb7c10f12bd	252610057	$2a$06$Ue4EC806LiHWHl.PxnbtQOLhY8IeHymEGz5CpQN.T9XQX/xdGcX0C	ANITA WIDYANINGSIH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8ad7a8c7-3235-45ba-bde2-ace8867546a9	252610045	$2a$06$7qtU/ZcAAFGICpK/ur04ae2tZGBdkj2QQ60wItrOGb7khLc6YL8.S	AQRIZ OKTOBRIYANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8584d6a3-7a8c-4217-84c3-f47d1009116b	252610545	$2a$06$gUHeX3AIb5yxRBwwo9yc9e7sO2ERQZCLblTGceKUf2dD5A3tgvG76	AULIA CITRA RAMADHANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
fbdecfb8-26c3-4afe-9d4e-379dfbd5e28a	252610069	$2a$06$D9vWmwE2buLpSlCPEOh4wu8l4KUKnmr5hDkS9ZcxtRXMLj94mijXS	AZIZAH KHUMAEDI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
04cbba5d-c276-4015-8df9-67c53bf24056	252610081	$2a$06$4Hg19za9tGsxgI2JjahF3O.9Hq2ohBKPOJ3mW8z/RqCPe68oP4yWu	CINDY MAULYDAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
edb50787-a0da-4761-9ed5-de1ffdf9c44b	252610093	$2a$06$lAXAovVS/y0hbjQ7vxW8HuU.UNZMl0Rz4iI6rFLsJn2r6yam5t/Iy	DEWI KHAERUNISA SARASWATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
706e881d-fdf6-4d34-b467-879cfa015482	252610455	$2a$06$JtLexIcKzFsoF0nuQr47We6FCKOxwQ.Uc4Q7iZ6a/Aai1iwrw0S1G	DEWI MUSTIKA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
19068545-9696-405f-b84d-df78f11a646b	252610105	$2a$06$w2XUXofEFq4tfbyQZlEK8e6MD1FQd4GOkdbcIhlOQV6bnCJTk4sK2	DWI ZULFA NIRMALA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d286133c-8ff7-4735-8fdc-fe4b40b5db73	252610117	$2a$06$bg89etuqg/OShgHinMiefukML//1rj7XGuNVotL0V6oUo9Eo9oHsC	FABIO ESA KUSUMA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0808d581-01be-4284-8faa-28744bfe4a0d	252610525	$2a$06$zh4M.xm4g.VrjW3wLJphiOd8MswhserEXm8pv0XtOe5/W1fCEUGxq	FAIZZATUL WIRDANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d253a690-cb58-4273-87d1-e2c1bc662c36	252610129	$2a$06$GMIgGE9U8Ma86.4qyOHsY.JKBiqFSabsBjI4mAqciRe.kleBtDGgO	FEBRIANSYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
87db0fbe-de91-4157-83f7-ec49d7e348e0	252610141	$2a$06$09JRX/SLgaN0cxev.C0GsOvGbMzWxbGlbbsO1g4FmzfQxsl.aHNo2	FITRIYANI RODATUL JANNAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
dec5f2b5-b07a-4233-8c84-3e273bea2d8c	252610153	$2a$06$REEIdfcK4MfwRPLgwT6i0uPEEaucscPvYUAXpdaCiROPYqf7SQ0nC	HANUM SAFITRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
39901d8d-28a1-4f4e-9fcd-77d3bdc666c2	252610519	$2a$06$ihjzHJKmMM5OGtn8XHguqu5RozAgCL2jf76y5rHvmmv3NAUXI800.	IBRAHIM ALAMSYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f0249ba8-7b61-4e51-90f2-8527aabbd13f	252610165	$2a$06$w0lmLaIs9Sv/7CttEevUVur1xFQIwoeTTZvIz/awj9Crd6n6tQ0VS	INDAH AULIYA WATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b416c414-1813-46a8-bbb9-a34f6f8a6453	252610177	$2a$06$u/uS0WhYoM0LOWTXdC5iDOZRkZejdUyhV4eZwbVsmnPUx5O3D933m	JULIA MAHARANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
982494c3-21a5-4074-a6ab-81f26caacdfd	252610189	$2a$06$/xywvz6EE772Fl1BMR5AreuYapE5z2RKUjzukZ/IZK4hUNc95lCcC	KHOIRUL ANAM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ddf45d03-985a-4f36-ae66-bcdf8c960f5c	252610201	$2a$06$2KjRMJ8rIr.IaV66vf3f0ul3AskAOdyIdfNT6ol5IICoFEC9ZNnNi	M RAHMATULLAH GUSMAN BAIHAQI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
82a5ae47-a7df-4775-b809-906f3cd0fbbd	252610213	$2a$06$Wxybv1Gff.ooSkAsKuSGX.TpaCyrtLRxfd7ZnUWJAGH/c0HLhbk.6	MELISA PELITA PURNAMA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
710be1a4-f77a-406f-828e-4c6c6fc0e04a	252610550	$2a$06$8wXBv9IoeW.rw8jEzZzw9uMPDJnz9zBd.EVPLls/4NJk9/3OMgSWm	MELVI SALSA DILA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
31bb1dee-e446-4c79-81d0-ea0433ec1341	252610225	$2a$06$hv8WKO7AZ3L6h2/MPOxsOu3vcpRRxRM5mnbgE8.W.AIXGg8Rn2LFK	MUHAMAD ADAM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5c1ef407-e049-4373-aa16-681cc39a9186	252610237	$2a$06$5kv9LEY0QUEj36G763cHquDfsJZKgjX7brXJBOwHeR4RolJLJ7cym	MUHAMAD RIFA'I	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
760558d9-9b65-47e8-8e37-c128e4ceee33	252610499	$2a$06$GICAKJxTBLdYynpGTHjp/Og6O.lSfbnW0qFH.UjVC2Gq7maRnSzQG	MUHAMMAD DILFI ASSYIBLI RAMADHAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3cfa21a7-4725-4dd4-844c-1eb30e540cee	252610082	$2a$06$FzBzAf6vcVvK4zMtSuifu.TedrhJ5VOqswObnDFAVgjBsOLb1KTj2	CITRA OKTAVIANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
bffa3425-5e74-4bc4-b211-3134f8d8ea1f	252610512	$2a$06$dNJ3fQwlG9IrRCD5bHHjzeWS/jJKr3idNEsi28dFPu.eIrWn2aaFy	DEWI SULISTIA NINGSIH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8859be9b-4a03-4003-ac0b-4ac01312c96b	252610094	$2a$06$fMOVn17PJfGyU0gJX.26G.HvZirq9vbNGsZ3H50AwR9/j7.NIykOa	DEYA NIJAR RAHMAWATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3b1f3de1-f18d-46af-ae5e-6b1248389d06	252610106	$2a$06$Aq1Ak0sFClT0xPKQrlPwlef0fLLjdCATBgSNQhD6lPvGTZYV9So1W	DZAKA UL AFKAR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
10007087-7e2c-4102-a7f1-daf4083c24a4	252610118	$2a$06$kn/QMIDp5ixMRBqlrZIej.1x2Q9PO11utLgWk97fvZz9Sic/yO1/m	FAHRI FERDIANSAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0f95e72c-169e-4fae-821f-6aabfa8e5bcb	252610505	$2a$06$b29jraLOrpbnhVYrNj3dxuCNVKNongOctN9azwFJ3qp6EOAAoq7gq	FAJRIN WIDIYATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1a367569-5237-490f-b443-cfdef6689fc3	252610130	$2a$06$aB82mr0c9QVxhDWkWTRhWefA2rTkHi42uOjSYZe9bxp3Gu/3uLP5K	FERDI FIRMANSYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cbdf5c78-456e-40e1-9e56-5879ecff3c1f	252610142	$2a$06$rLQGtVXOLeBfB8WLURSeRO43OIYI3e4pPiDvB9QSzz3nz8oNR8US.	FIZZA AZZAM MADANIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8413ac37-c61e-49fd-8fca-62a135d7cfb8	252610154	$2a$06$4vI/aSos0inULeu4NqOz9.ZVjAJUF9HF8ZZZygzivmAgnial0MXPO	HASNA SAKHI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
751a8f7d-0578-4cce-aba5-ec4d11d181d1	252610510	$2a$06$YPIbtAhiclK1pgK8GGYlfu4b/s44n3XYeNFiCLZoVhBSrxy0Q2WGW	IKE DWI RAHMAH SARI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0cc79ebc-173f-4eb0-bb4d-7b23dbb658bb	252610166	$2a$06$RXzYP0AHeee/.itlBmZsgO0wwkk/KzPRRE1csX4jWiwTEhJ4hKxoO	INDRI YANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5d005508-38fd-4eb0-bf01-4cd1d6b5b9a1	252610178	$2a$06$TUn6WseTzIDp7Tsbe7LMKOsE3vQaqMW56MWJJj1BNvDFHo2x75f0S	KAFKA AGHISNA MIKAEIL	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d36f8b4d-13bb-410d-b481-34820e8c516f	252610190	$2a$06$/cLVjPJPQyQLvuLeDrn1lONuLbDzBZckVZ4XUrKpdy3EpX00adchK	KHOLIDIYAH AUFARULA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a5f1d4b1-1ad2-438d-ae8a-4993866d97bf	252610202	$2a$06$9Fs5QuJRygDrYnqvR50v9.MmtqCaHrI0mKes5hFgClNIA.DTylPhe	M. ILHAM PUTRA ARTONO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e055c5a7-c610-49fc-88f5-2d64b56a0a4c	252610214	$2a$06$TDPyUViKOj5u1gIo5EKbY.nCK1FmWRoPutkq7YaVKtLhuycBLsYWS	MESSI AULIA ZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
500847de-a46e-4e9f-82f9-97d246a4b145	252610509	$2a$06$3wc8ByniI4gLDH6FAjVkQumbE9RdNOcg5ETgZAp/XCnse0qk0TdT.	MOH. AZRUL LANANDA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0b1e3cf6-2845-4b3d-b3ef-9b759b2b820b	252610226	$2a$06$f.3LEjdhXxMIxuV4V8t1Du0QumrJXPBfF0H3lNshD/SNCWzPYcyj2	MUHAMAD AMIRUDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e098dfce-b338-40db-8384-321aae289ac3	252610238	$2a$06$AojeT9Wq8E03FL10deYihO7GxC6wqmObu4sxGAN0eHAer/3hz1sOm	MUHAMAD ROZIN BIHAR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b1fa10eb-a68a-40d0-a70e-16c1e421760b	252610475	$2a$06$BM3.wRkfwU5X1yQ.wQGv0uvwcg1GEGwXIjBxJhUOzYbxdpHcT3uGy	MUHAMMAD HASBY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d7dbeb99-01b5-44af-9dc8-22f723343b1c	252610250	$2a$06$8pnPmykSdVCN1NaI4eFxguEBOGdKRRWaHdcccTW1aaMzM0ktYAVLG	MUSA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
903622fd-bccb-46ca-ac60-35fb10fcbd7e	252610262	$2a$06$DrCXxHWkExbgVaqJjk0PvuLYz3hH3GowDh6sBS4qMi82fsMPzQW8.	NAILA PRATIWI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b58d2f21-3158-4e62-b247-5bbbba6d657a	252610274	$2a$06$nTHzoqp0MaW3esyRwgTjdOJb9y3yX1xbhwuYA.Pu.mFjQHEetgcNy	NAZWA AZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c6ea8e61-e867-4bc8-aa21-0f3800b6bb32	252610286	$2a$06$b.1nf43Q1FzvYWvs4mZ3uO5SDBEV/LgzAhr6DRVcCgE0q52Kx5UJe	NURMISLAENI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9401e3b3-be48-4511-bf24-60c2881c67e7	252610298	$2a$06$2u2.Y95LHn/0KYCTlkSCp.HWT8AyTGNHpqkuW2462Hx0MgON5xuhm	RACHEL NURFARIDHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8ec948da-c6ed-44b5-a9d9-8cc953f41a2d	252610310	$2a$06$qvYINsvoIwiiRDQcA/mWpOHiUKoQcfOksRrFLOENFe4y1sA5KUnJW	RAHMANIA RIZQITA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
05841e0d-ec7b-40ec-9c88-abef1cf68cc6	252610515	$2a$06$cwXXGKlSUAHP0SkTJYO8h.X4d8h0pRlLlfq6sH2O8WZK8Gj1cJ0PG	RAHMAT WIJAYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
12b22e0d-bfad-4b59-9361-374283bf7ab9	252610322	$2a$06$jtMEblZxsvwEiV.N2cKr.ezKKKVg.b3u3JaXgRD00cGZGm8ALSBiK	RIFQY AQIL MUHADZIB	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ba55fabc-63a3-4b2f-bf84-3a0cce67b90f	252610334	$2a$06$jLIrjDbBkfL0SQjJxqRv0OSHHqWfQVm1YAGdBaCGDqVud1caSWCVO	SABILA PUTRI TASYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d0a79de5-083a-40d1-8973-2174ea5c122e	252610346	$2a$06$MK.TJlqkSsfw84n2j/AEteJGsO3df7gddgwTQKkKvNvzMGM0zZl9O	SALSABILA RAHDATUL AISYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d6ad7f2c-68c7-48c0-9f2c-9a4ee74dc931	252610358	$2a$06$Xru4UugxestYh9cdDt47euorerxzHvPg3ttUwbXwL5ZEH/g048KOu	SILVI NUR ANDRIYANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
e0d1396a-d0d4-47f1-a25e-e1fc9770dc56	252610483	$2a$06$3LL2icLyupvuX/PhH1tH/.4WYK3OVM6yDzWECINA2Q/4tqcxQR7Ua	SITI AISAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d741979c-054d-4d68-8d0b-e922772dfc9c	252610370	$2a$06$4sPp8oL7ynRjnVVMf1e1gOFqTumPHQPs7bFLLGFMNKWH2oxPsBxWS	SITI ROSDIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b477f0f5-434c-48e3-a552-6f89e7204702	252610382	$2a$06$sILJXXkIMTB/fF8WrRiyO.Y2FrGmzZsb5qcB14p5Xs4mdWLTh9uQq	SULIS SURAHMAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
fe1d2058-c445-40d6-8f8c-73e628b362b9	252610394	$2a$06$apVaIPWbHyNzf3ZsxyFWiuWnI3UyjMnuttHawkJOO3GIQ3zAubUCu	TEGAR SUNJAYA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f03e279c-3eaf-4fb5-9295-cb669cd34316	252610406	$2a$06$u4KRiTeURW5cSfgD5sJg8OetQgvI74HcCIPFjOYXkeqDbx1Dh06Ue	UJANG DADI UTAMA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
008f3854-ffb1-4e16-83e1-f9b018de8f42	252610418	$2a$06$kf4yRt0wyawJkjfh0Kp4ae9RugdStbP3w.n2cGqkkDak8POfDRbh6	WULAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b0ee2d61-31c4-4cec-9e62-957b92749962	252610441	$2a$06$9BpkLe2iRq.WJK.fRWLdx.reSabsZ0nHuYTsTDcU4r1tG0zMYG7VK	YUNI SAKHI TALITA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
56b9e1c0-9177-4c74-82ef-ed4fd069ee92	252610430	$2a$06$acxrcaBVCRh5RJO2dtIYCOVoIPbTvdm60yK6elJFKI3Fl9aImxgYC	ZIO PRANATA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6502eebb-3962-495d-b0c2-4669aa639895	252610011	$2a$06$Jl5ebU3yCgRRrQhehTPtZOllUCccs/Y0pbiQDjhL4X8cpXXikton.	ADE TIARA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9337fa4e-626a-4293-b121-eb75406934fe	252610023	$2a$06$PewadxqmF14Bh6gOt75RpucMese9y81tWOvY6aUJlcB16XqzYOFDG	AGUS FATONI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c81aaf8e-eb0c-4ebe-b39d-17cc03cac7da	252610035	$2a$06$GUkkUir51uLj.igKa9GTIu82Yv0wuk6gbVn.5mpqUO7NdOTWW/8iS	ALFIYANI NUR FADILA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f4ee195a-6b61-48d1-907b-9a3c6c1b3dc5	252610529	$2a$06$ZJzJRFKFm9FXbxOmMXx3x.pGxqX05kCeuoAlBGj1yH9blYoW.V1J.	ALISA NADIYA AZZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d7f87ed1-1b4b-4acf-8ecf-22b7fe87d92f	252610047	$2a$06$bFksN8Df9BuJDKcb0Y3SiuUyd1hXIAUbUnANmh5q05EEDFhSljnTa	ANDINI CHIKA APRILIANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
54be2134-8d66-4275-9fd4-b00ba9894c64	252610059	$2a$06$va7xBGO6bJp8Ma0k0dsjou5C8JGdWkb1kKUFDf6Ge8AzGlJx1a0aC	ANDIKA SAPUTRA ADISUPARDI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
663e2f87-4ead-4e32-81a3-c6530103ce2f	252610442	$2a$06$.nbIAG.xgNI64eghpwILSeWuLDGHdpVdsGEjoq0uMcgzHLcypxbJK	AVGANNISTAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4998f185-7e0b-489c-82c7-318d54df652b	252610071	$2a$06$HqRSaqXFgRyNzCKO4GgH8OsAoAe2WZIQMoUQ2t7AUzc1JZWHGZxUC	BELVANA ADZRIL IGNAKIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
18003be9-6442-4e6d-86d2-6a348324dc36	252610083	$2a$06$nUSnCFcU2WBgfLF6lc/C6.kbC21fe8HBOYFDN7vfzkrKi/.aKTaha	DAFFA AMALI RIZQI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5f353cea-da36-4f5e-95ab-26192925add9	252610095	$2a$06$OokzmzyhhcdQpYlWG3ywZu2fM85nNn5yzxJB2vJw9JPOAa/WLbSFq	DHAFA MUSHADAD	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
80c7a4ad-f5a7-44e6-880e-d37988504fe6	252610489	$2a$06$JikDe8AgSDiSxk9lvCaC.OvAVMgAGt1vBItg.dg4sSumGMVejM4Da	DIAN ANGGRAINI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d1fcde27-b1a0-4198-abca-46a12d8b31c0	252610107	$2a$06$gFH2e7Sx8x/u7jTxw4cXduTNRNFEB1En.y4z55za7SDUJVQlCFs7C	EGI NADIA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
6eb533bf-0aaf-470a-be4d-e3dbed2253a3	252610119	$2a$06$2Zbfq1nLAOyX3CFc0h8z7OyPx4SI5mkBv0hjX6S8xR/6ATBZsUl/.	FAISAL BHAKTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4ce92a28-1836-4e00-86dd-ac151c634dc1	252610538	$2a$06$LI4lVxTgYaOrTBN6oZAeouA.2Qhg3LbGE2rkti3zfWT3cGumIY6qG	FAKHRIE ZHAFRAN KHAIRY	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c1a17c5b-6eba-4060-981e-914b04189e3f	252610131	$2a$06$iTISCXrVa2ScTX6AQlaSBuhdgS9puNArTxxeQvYizzRJBoE3kOTvS	FERDIANSYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
fb625670-db81-4899-a8f8-4b83f41a9dfc	252610143	$2a$06$9EBtcmDnjGMqpdHVxUYygu4vqsJwQipbK7YsC5yyoSfa7ZlK.2Ga.	GANENDRA ELANGGA PUTRO SARTONO	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9054490d-8981-4631-bd28-81c249d7abc6	252610155	$2a$06$itIbJFzS9Ztmcn5JzD2H4.GzzFl/6ggBygdEeiDxusn1f35knpCRu	HESTI NURUL KHOTIMAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
35537e1a-5722-4853-b2bb-8e3cae589ef7	252610167	$2a$06$Uqh30/wZw.7gX8ebyFbLvu9UbFXh.UOUYGikQKTneeDKFqS5gz2w6	INTAN NUR AISYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3f420015-3f0d-425f-8f39-4a6649acf968	252610454	$2a$06$2dqt9OLc9kXJb/8OXaFI6OzmOGNFvz.gufXY/Vsy3aZ.avoEwFVou	JAHRATUNISA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0cd27cac-3233-4827-bf57-fcea26892a64	252610179	$2a$06$BTErNQR9sHbSRqcS25kOle4my3pvVmnwF8aYjniBRjdGZgoeEfP7m	KAYLA ISTIKOMAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2e558470-feec-4557-929e-887da88cd614	252610191	$2a$06$RnRVBHY0oWOUaOrgxGIBLOdMS1f6mF23jWn915XJRZguE999TE4JO	KHOLISHOTUN NAJDIYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
294c8ad7-63ee-4709-ac6f-0b83ae52c145	252610203	$2a$06$9BGLs21o/GxErt2pxGevh.tjOMwYJQe6sxGGfZeVp0c2K3CGuQvZC	M. REHAN DWI ERLANGGA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
19b5a71c-5d37-45b5-8212-e26c3a491166	252610215	$2a$06$U3VfFt8lUOhCKU29U7uNaOv6Xoiwri42Nq5ZScB9uMtspM.AgnhkG	MEYLANI PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
61b77252-138a-40f4-a21e-d3365544d0e8	252610503	$2a$06$wb9G3v2B8DVrjO13YOtrKe.gtx8zwZB2wwwmMAd3rcLILYwehfYUq	MOHAMAD REYHAN MAULANA RIYADI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a372f778-6c18-48e6-ba5f-34b62690f0a9	252610227	$2a$06$TISqSNWDx0OoLdIgwNZPs.gCSjNyxQct6sn1/xcP.0qlp5X.P.BJC	MUHAMAD ANDIKA FIQRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
42157577-d672-4d38-aebe-64ff823899d8	252610239	$2a$06$3xImyPhII2Tloc6RlSxZ0elpDvJ7gogmjknj/Q69llx9YMikngstO	MUHAMMAD AZRIL BIMA SATRIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5b57d594-f2e7-458c-a794-b64feba88087	252610493	$2a$06$nmOq9chMRHIJRV0tX7IEkePvg8MM0eblFsSsuUah9zBCYQTZx8Sxm	MUHAMMAD IRFAN NUR RAMADHANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
a20be7a4-7311-4e36-a9e0-c42633aa1eef	252610251	$2a$06$ob.XtwHq.GSzqs8X7Zaj9.9mPYc6xeXG45/VAUYb/manVhLDRWW1e	MUSLIM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
85a1c758-f6f2-4962-b603-506b4a033533	252610263	$2a$06$g0Xe8cAP18CzKjAgBVZ3leGXg3VtTGhW6OwJnQKiKs9HIvuqgIlEK	NAILA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ae647115-3454-4979-8b05-0dcee61316b1	252610275	$2a$06$mXN7NwvVKb6FhjdTihK4V.yegRwMTWH.DHc/BfecIV1ePYR9nEpWe	NAZWA PUTRI AMRULLAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
eda226ae-5889-4006-971f-14f7f6877ee3	252610287	$2a$06$A39kyusMoT.M61ssZUFF7uGZQeDGENYAAEGEum.0axrRVfYtT6GX2	NURUL ARIFKA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3e7e2eb8-f6fb-458a-8b61-7d7bd39fe932	252610299	$2a$06$W17Ou5H8nLOK/0eHhD1QAOsXraHm9x3JOws9TG93nIC4dSK7GRiim	RADITYA ARDIE AZUCENA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
94b2f7d7-763d-403a-931e-d33589f765cb	252610311	$2a$06$44B3rckNfOsJ7nX2PO8FGu5.aialGqTk3ukA0Dx6/DppOw6Dpt8u2	RASYA DIVANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
7fb62739-612f-4493-afc5-ebfa139960ca	252610518	$2a$06$rD5oKToGNDFqoIGWe4TmmOTlNtd4gBhWTZFJkMl4CWdjNJhJlAuNm	RAZKA ATMA DEVA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
064f2277-f11c-4029-9dcb-e4e1ae9e7787	252610323	$2a$06$BUgwDWeoY59DyTxk9yjqFOEozh.T/b4x/gbkQ8cxzuP5gTgYn4lEG	RIKA AVRILLIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c6d0b526-17e6-46d5-a9e1-7ba76533eecd	252610335	$2a$06$Y/vleo8k.quXVcwQWFGffuqHBC.19xWSV2KeF3Mp0S.baWMdyysYi	SABRINA GEA ALFIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
f2b2eb78-8e59-4e7c-b48b-ad39d72bf307	252610347	$2a$06$nmwM6pLxOOyAiWpOWyuLoOmHQAdrLH09PindpIsZR6EOPLiusATq6	SASKIA SALSABILA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c92004e4-a594-4c27-aa87-1e01ed7b6c1f	252610359	$2a$06$bR123Zn9YIKRSvgSPCRKl.OKQw1dw5pTNcueFCrbqjLkqD5vnDLN6	SINTA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
06dae3f6-88c1-4c12-98e9-ec64730759f2	252610535	$2a$06$6DuuUGU.tuqeEfBkFAjFO.wOQhAiVAc6MHrya5lHg9wdxWQMBfE3G	SITI FATIMATUZAHRA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c80914a8-a63e-477c-a9fe-4d5cc390d0e9	252610371	$2a$06$7SEmV4vyctipYM6cK4QsS.b.vpfDuCq4SdikTlhcz0C93pmoA424K	SITI ZULEHA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4f8dcaaf-0e67-40c3-92cb-e876ed31a92b	252610383	$2a$06$q5/gQpLN59dlkQmQdr8ha.1aePiWaY3UCrP.tZoxoh9XJ5Nx5CHRm	SUNNI MAULANA LUTFI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2f9f2a1e-b63c-4275-90b3-aced8b8ad3c2	252610395	$2a$06$t92Oq6hYwFeX4ZHCrUfSjOiB8yrlBR9edQ6dI71U4.6ZKF4Ae4B52	THALITA PUTRI VIRLIYANTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
23cd2a80-400b-4fac-9552-7a74da706b49	252610407	$2a$06$ErDS49acTJAqs1k8qI.rK.Vdh3b17wZsgmhpE0Vagd7FJN8MdI3fi	ULFATUL LATIFAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3609999c-af9e-45c1-8daf-edf879538658	252610419	$2a$06$XsSCQlwl9DrtPIEwuAKhjeGDIMbTVYgonJDGkJ389IQT4blkOAf7K	YASMIN AULIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
77db09dd-8d1b-49d5-9991-3099b7b7aba4	252610471	$2a$06$239.ablNzFSSM3X2dxbpO.vDyGR.dot/TntUQrzIUV8MEulHvmaIC	ZAHRANI DWI PRIHARTINI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0528c22e-f016-4fb8-9777-6301235794f3	252610431	$2a$06$BgyhuOk336VducETge7tB.XeRd5ll4mExRGH5i6aaz/m.kB9drOlm	ZORA JENAR MAJID ZIDANE	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
82534996-d6fc-4178-92b2-a113587552f4	252610012	$2a$06$7u8nu584HvjProAfVCamJeX4II8Y3dRdm28/i4vrB1ZNsQI53w3uK	ADELA NOVIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
b3d5a02b-b232-4e2a-82e8-c2b3f43afc82	252610024	$2a$06$baiJdnYEhg2oJk..RrxxvOW57q/d0Fd78BrpssBkSISAKu58egh1u	AHMAD NURHASYIM	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
df927010-7390-4fde-a457-0d1765716d5c	252610036	$2a$06$RUQJg8u/Q7ZAytm..JCL5uVNB99J4dm6ESYnZSUW/R1eUuYndbLT2	ALI MAHRUF AL CAPAR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
80718e50-334c-42c1-8276-853136b3dc95	252610485	$2a$06$QpLjkLgj21/pOmnP98W18OgoMB9fuwZaSKfvHyatonoUxufERoZn2	ALVI SYAHRIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
dd766662-fd72-4166-a04a-8fd6b3a18730	252610048	$2a$06$eTVEs9kA.EWA5n.YkeqQsOUdmtQwiB.nA5TB8KeCFmjhCFC0S7uk.	ANDINI ERLIN TASYANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9f086301-a0d5-4429-9d1b-a523258baeb3	252610060	$2a$06$bmqXD8yYLYk.rX.tSF9CaeN95gtnMJ98UvfeX3e2RXme7aGkpeJ26	ARLAVINDA REZQITA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
15242a2f-8637-41dc-b041-641cefc7cd09	252610433	$2a$06$33HNC3SJuPtcf3EOF6JGPOBX2tvgV/ScZIKZecRh9Sqhn5ga9SzVu	AZIDAN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5daf7677-d209-4614-81cb-141094279531	252610072	$2a$06$fU6DsawJa5FwdVJPkxmYM.j2ESzP8vJc7JAcnu2pi0l5oAK6Z0VPi	BUNGA RUSTIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
832a8b77-3f96-4f76-a690-1f3a4370bc2c	252610084	$2a$06$O3cjQJnZ.IGdKbClSqSxWeGV5qfCSAloApe1VCamGN3L0IuRdtqz.	DANIA NIDAUR RAHMAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
684c5f81-c32b-4303-96c8-071cac33475a	252610096	$2a$06$9cqciiwvV/DRau5CVOsle.GAbUnN5WNMC02RWcvtPGsbJqlmtOCgu	DIAN MAHARANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ef51ef3d-7526-4da1-b08e-e00a3a593a1f	252610449	$2a$06$wQMlC45a10lWHTVSZzYQs.L5IqmvUdlmFVGKgvVGPccJ17Gz8DKM6	DIKI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2cb838d1-65c0-4421-8175-c16f9789585a	252610108	$2a$06$fmKlcgA8VEDV7Z95PE/ykugkZ1mD9tAmx7HxGJUQp2fc8/o1pbVZq	ELFADYA ARSHAVIANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8c8850d8-c03e-45e8-b259-6be568b61417	252610120	$2a$06$ME6QTCwvisZ7ZFUPmlFaAOV.i0K8UbLe6AfQPQKkaBlCB1go/Nwg6	FAIZ KHAERUL AKBAR	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
c39ca744-b0c1-4e42-b87e-502333e7f736	252610553	$2a$06$GOOziK/.m.iSFHtb0fRvlugkI4x2zPfd4VNBiWKu1Z8fhst697ph.	FARRIJ PERMANA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
eb5d5fb6-dc5d-4866-bdfd-5cdf3262f74b	252610132	$2a$06$.jpzMS4yxtqti9zOG3e3z.hI5W/WIiZQm/m8r9.oAi332RXpVdoQm	FIFI RAFEYFA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
64e2a324-d68b-41f4-9644-8823ef57977c	252610144	$2a$06$8RBYYURsFUmdAziL/SiKQ.KjzLVBsBHPD4x3RFl.mWlH.rjg4qCau	GANESA PRATAMA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
075ea9ee-dd9f-4b5c-8474-b7b0592a3834	252610156	$2a$06$gGnMvWjak694eF1QgMUWPeQw14/j2lx.P.vsO4axUi3oE7CmS25Ji	HIJRAH YAOMI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
5e6425bb-7ee8-4bf4-840a-462d9cdbd1b4	252610168	$2a$06$1V0lRJuMrieLU2Ys/MgfZeyZZIkLcOro8DJ4Df9bQAYRleGt.JgeK	INTAN NUR FEBRIANTI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1b1bfd41-8a59-4e3c-baae-47838ae318ad	252610480	$2a$06$3Z1SqxkGqnu.20gzVx3tPuHCc7H1E1FSbIM6ARZAgxkNX0qjlnJ.S	JULIANSYAH SETIA RIZKY PRATAMA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
7eb9f012-701c-479c-ad74-87376e65e08d	252610180	$2a$06$I0tvq6HuS4Db0lf8KOh1pOP9QlwHVWdZ02J3tRpZ63TGVjIe3ETPG	KAYLA NISWATHUN ZAHRANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
06d8fa0c-5a77-40e8-92c8-3f99c902d867	252610192	$2a$06$CFnS5pojRDuRUiZkFddaHu0C8gDA1q50ycmH0BollQZMrx5.t64PC	KIRANA KEIZIA AULIA REMARA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ee63bd0d-4501-4c65-9818-b4db8a6c2fd7	252610204	$2a$06$7gcwBnt7JNgKKIDrr4LzgeUc.6TDufhOmXVMIkXWYj/bt0QPwdb/y	M. RIZIK	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ce55bc7e-da71-4590-b142-6435a3217bc5	252610216	$2a$06$Pu8NTTNWgnbXEMO3ctDhK.LGwQbmdm5VhwM4YjBpfQarqugvSCW32	MITA NURFADILAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
926d4fb4-21bd-4c96-9ecb-3230d06f90d3	252610228	$2a$06$CeRcUo/xlwN1JX3vw4rJouXX2t1W7sVei4y2p7SRMNwJAazj4ln4C	MUHAMAD BAKHRUDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
620b572b-a48b-42aa-a060-0519fd7d7387	252610540	$2a$06$KXGEC11wzNFJjzljN2xz9eBZRhODX.4TTU2NnXi9YSdKNDOefR6Cq	MUHAMAD DAPA SOLEHUDIN	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
83fadd2a-2d38-45a0-a3f0-864d2ee0fa38	252610240	$2a$06$/S3FYBZSLQ87j.BIub84L.JEvEzBC3ck.p1a3z3d7DRbMO8L983Gy	MUHAMMAD DANISH NORIZA RAHARJA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
dc27a800-52db-48b1-988c-11b6318ad39f	252610482	$2a$06$EMNK.XY7Ixf/VR2J4m/hfu5LTOKvXhWXFws/Cg5yJIUSfomarDaOq	MUHAMMAD ZAKKI MUBAROK	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
7f33e120-fb05-4e8c-8215-2e293b858e04	252610252	$2a$06$G.JTqZAs0K3rbkDqYvpeiupZGg2d1uGvZD4r2cl0jYfdAUOlGVBcK	MUTIARA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
98bee673-13dd-48f5-b49d-6c575cc8884c	252610264	$2a$06$N5EbHp3m70yKrXnqVKZBke2pCd9ldCyuy6R4Cf6qdRAmt7yLePvTe	NAILA SYIFA RAHMAWATI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3bf2a40d-a74a-42a9-9d7e-2a1bb22218a8	252610276	$2a$06$BUisdzwS6MdCZ54p7gcRHesfuTwgCHgZ5kY/.8KipRz.ZFZ8zxx86	NAZWA ZACKIA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
9ed4b957-a4a3-4575-99d0-9b2a9752868f	252610288	$2a$06$ARA1a/ubrs0NthikTQPGEuoVJ48fxaoX.9TrB/v0pZfY9yUoAAQZG	NURUL HIDAYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
01203fdb-2e3c-4acb-8d33-8a2dfd096ab2	252610300	$2a$06$YeKHaXNRzw8XQ3pb.u2KWO4epFEDXUcihQl2X37YEMrxB73l87LfK	RAFA RAMADAN NURFADILAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
38b8a6fb-d980-4281-a6c0-89160873abdc	252610312	$2a$06$TZ3YmlSFJ1GpbzIfcOLdgeTaD3SIx70RlfUjmIJC7aDkEJbESAp.K	RASYA FIRDAUS NUR SIDDIQ	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
cca397e7-0e10-4a07-a34c-9fae96f9a34d	252610551	$2a$06$8TMuCzEsFSvAnpHRkQgAguso/Z0zk8DcXPyAIAOIEWK/9TN1Decie	RENI ANGGRAENI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
d503c01e-bb97-4383-8b0c-573b1392f282	252610324	$2a$06$hxU4FIy1J7siuYbLgd5p7e6llve3etWOf2DgvheDF5QaRomzBaokW	RIO FIRMANSYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
8f710e3a-be3f-4a93-90b6-744af54e6bde	252610336	$2a$06$xyRRrNPefZSeH6HF1zXh6OKAg6elYTa7yAAMUhlyzuznXSQMYVypG	SABRINA PUTRI MAHARANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
ea0af944-ca11-4f35-b439-741480cbc68d	252610348	$2a$06$hBYNRhen2/1Wo8zY4JRPleWJ8Wi7qRjP8IQSuKEAfH1ONaLG7guxG	SASKIYA PUTRI RAMADANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1b0ccb9c-d3ac-4ad9-acff-55438971c068	252610360	$2a$06$cgw62i3cBCnuNbWroKtvI.vfP5/.5pBCmXl.EkKUExBh/P4w8sNBq	SITI AISYA NABILA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
23aed279-d97f-47eb-a791-5d5475723403	252610456	$2a$06$94q355Lt.LgafEIsrsSDBui2nyZa7yyn5vtarosYhQl1xvtTLdDpq	SITI MARWAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
7cb43530-539f-435c-adaa-91e13500c350	252610372	$2a$06$EamXbWts.DiGB.pmRoEWbejN7N2LB1T9jpWvPzRMILSj7X/K3UAmq	SOFA NURFAOZAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
1db8bc7e-e25a-4966-962a-e4e2581c7152	252610384	$2a$06$C5XMdeGMqvd2viNb0K/24uxx9gIgLS/.Fnxn4Dc6XIZsnTViZzYwC	SURYA PURNAMA AGUSTINA RAMDANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
44fcb6c1-bf18-4742-b2d1-f1552df19c40	252610396	$2a$06$OMQ0qNaawYeCB8FojeOz7O2cflcmQIynFEMF7dCPcK03GF0s2zCL6	TIARA AURA JULIPAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
0c9073b3-d6f6-4ffd-9e10-7d38246a831e	252610408	$2a$06$GI/rws8jUOW9yEMeBtk60.vs/SOzwztqlJTBUdWfCOBbQ5XTVNvFq	ULLIA BELA	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
4ce671ef-981e-4e64-9ede-b5e83c73f88d	252610420	$2a$06$JovGGF7YP920cuTlfFliX.zvpBRK/D4ixBjFVZAi62vx7Vq39OEYm	YAYAH CHOERIYAH	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
2d3c2015-a3b9-4114-84cf-b44c77dd6f47	252610469	$2a$06$ybLi/uPAW4V3vWO97Spx6etZ.g9VZlXebQ.V3sveDZrOn5so5WMpS	ZASKIYA PITRI RAMADANI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
3cf24d98-7253-4820-b384-39afca3c31ee	252610432	$2a$06$OKsFiACSMBucKJuxXMgGpeq/c4Q/XAQf90tBCzrGbwW.4OHMZmPh6	ZULFATUL MEIGINA PUTRI	2	\N	\N	Y	2025-07-29 03:02:40.167699	\N	\N	\N	\N
\.


--
-- Name: seq_id_mapel; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_id_mapel', 23, true);


--
-- Name: seq_id_ujian; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_id_ujian', 42, true);


--
-- Name: seq_jawaban_siswa_dtl; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_jawaban_siswa_dtl', 551, true);


--
-- Name: seq_jawaban_siswa_hdr; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_jawaban_siswa_hdr', 72, true);


--
-- Name: seq_kelas; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_kelas', 11, true);


--
-- Name: seq_soal_dtl; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_soal_dtl', 364, true);


--
-- Name: seq_soal_hdr; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_soal_hdr', 131, true);


--
-- Name: seq_subkelas; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_subkelas', 43, true);


--
-- Name: d_guru d_guru_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_guru
    ADD CONSTRAINT d_guru_pkey PRIMARY KEY (uuidguru);


--
-- Name: d_kelas d_kelas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_kelas
    ADD CONSTRAINT d_kelas_pkey PRIMARY KEY (id);


--
-- Name: d_mata_pelajaran d_mata_pelajaran_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_mata_pelajaran
    ADD CONSTRAINT d_mata_pelajaran_pkey PRIMARY KEY (id);


--
-- Name: d_penempatan_mapel_guru d_penempatan_mapel_guru_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_penempatan_mapel_guru
    ADD CONSTRAINT d_penempatan_mapel_guru_pkey PRIMARY KEY (uuidpenempatanmapel);


--
-- Name: d_penempatan_siswa d_penempatan_siswa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_penempatan_siswa
    ADD CONSTRAINT d_penempatan_siswa_pkey PRIMARY KEY (uuidpenempatansiswa);


--
-- Name: d_siswa d_siswa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_siswa
    ADD CONSTRAINT d_siswa_pkey PRIMARY KEY (uuidsiswa);


--
-- Name: d_subkelas d_subkelas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_subkelas
    ADD CONSTRAINT d_subkelas_pkey PRIMARY KEY (id);


--
-- Name: d_tahun_ajaran d_tahun_ajaran_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_tahun_ajaran
    ADD CONSTRAINT d_tahun_ajaran_pkey PRIMARY KEY (kode_tahun_ajaran);


--
-- Name: d_ujian d_ujian_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_ujian
    ADD CONSTRAINT d_ujian_pkey PRIMARY KEY (id_ujian);


--
-- Name: f_jawaban_siswa_dtl f_jawaban_siswa_dtl_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_dtl
    ADD CONSTRAINT f_jawaban_siswa_dtl_pkey PRIMARY KEY (seq_jawaban_siswa_dtl);


--
-- Name: f_jawaban_siswa_hdr f_jawaban_siswa_hdr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_hdr
    ADD CONSTRAINT f_jawaban_siswa_hdr_pkey PRIMARY KEY (id_jawaban_siswa);


--
-- Name: f_soal_dtl f_soal_dtl_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_dtl
    ADD CONSTRAINT f_soal_dtl_pkey PRIMARY KEY (seq_soal_dtl);


--
-- Name: f_soal_hdr f_soal_hdr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_hdr
    ADD CONSTRAINT f_soal_hdr_pkey PRIMARY KEY (id_ujian_hdr);


--
-- Name: d_ujian uq_combination_ujian; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_ujian
    ADD CONSTRAINT uq_combination_ujian UNIQUE (semester, kode_tahun_ajaran, jenis_ujian, kode_mata_pelajaran);


--
-- Name: f_jawaban_siswa_dtl uq_jawaban_siswa_dtl; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_dtl
    ADD CONSTRAINT uq_jawaban_siswa_dtl UNIQUE (id_jawaban_siswa, no_soal);


--
-- Name: d_guru uq_kode_guru; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_guru
    ADD CONSTRAINT uq_kode_guru UNIQUE (kode_guru);


--
-- Name: d_kelas uq_kode_kelas; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_kelas
    ADD CONSTRAINT uq_kode_kelas UNIQUE (kode_kelas);


--
-- Name: d_mata_pelajaran uq_kode_mapel; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_mata_pelajaran
    ADD CONSTRAINT uq_kode_mapel UNIQUE (kode_mata_pelajaran);


--
-- Name: d_kelas uq_nama_kelas; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_kelas
    ADD CONSTRAINT uq_nama_kelas UNIQUE (nama_kelas);


--
-- Name: d_mata_pelajaran uq_nama_mapel; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_mata_pelajaran
    ADD CONSTRAINT uq_nama_mapel UNIQUE (nama_mata_pelajaran);


--
-- Name: d_subkelas uq_nama_subkelas; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_subkelas
    ADD CONSTRAINT uq_nama_subkelas UNIQUE (nama_subkelas);


--
-- Name: d_siswa uq_nis; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_siswa
    ADD CONSTRAINT uq_nis UNIQUE (nis);


--
-- Name: d_penempatan_siswa uq_penempatan_siswa; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_penempatan_siswa
    ADD CONSTRAINT uq_penempatan_siswa UNIQUE (uuidsiswa, kode_tahun_ajaran, id_kelas, id_subkelas);


--
-- Name: f_soal_hdr uq_soal_hdr; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_hdr
    ADD CONSTRAINT uq_soal_hdr UNIQUE (id_ujian, id_kelas, id_subkelas, nama_bab, kode_mata_pelajaran);


--
-- Name: f_soal_hdr uq_token; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_hdr
    ADD CONSTRAINT uq_token UNIQUE (token);


--
-- Name: d_ujian uq_ujian; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_ujian
    ADD CONSTRAINT uq_ujian UNIQUE (kode_ujian);


--
-- Name: users uq_uname; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_uname UNIQUE (uname);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (uuiduser);


--
-- Name: idx_dtl_id_hdr; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dtl_id_hdr ON public.f_jawaban_siswa_dtl USING btree (id_jawaban_siswa);


--
-- Name: idx_dtl_no_soal; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dtl_no_soal ON public.f_jawaban_siswa_dtl USING btree (no_soal);


--
-- Name: idx_f_soal_dtl_hdr; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_f_soal_dtl_hdr ON public.f_soal_dtl USING btree (id_ujian_hdr);


--
-- Name: idx_f_soal_hdr_idujian; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_f_soal_hdr_idujian ON public.f_soal_hdr USING btree (id_ujian);


--
-- Name: idx_f_soal_hdr_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_f_soal_hdr_token ON public.f_soal_hdr USING btree (token);


--
-- Name: idx_hdr_id_ujian_hdr; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hdr_id_ujian_hdr ON public.f_jawaban_siswa_hdr USING btree (id_ujian_hdr);


--
-- Name: idx_hdr_uuidsiswa; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hdr_uuidsiswa ON public.f_jawaban_siswa_hdr USING btree (uuidsiswa);


--
-- Name: d_guru trg_generate_kode_guru; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_generate_kode_guru BEFORE INSERT ON public.d_guru FOR EACH ROW EXECUTE FUNCTION public.generate_kode_guru();


--
-- Name: f_jawaban_siswa_hdr fk_guru_jawaban_siswa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_hdr
    ADD CONSTRAINT fk_guru_jawaban_siswa FOREIGN KEY (uuidguru) REFERENCES public.d_guru(uuidguru) NOT VALID;


--
-- Name: f_soal_hdr fk_id_kelas_soal; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_hdr
    ADD CONSTRAINT fk_id_kelas_soal FOREIGN KEY (id_kelas) REFERENCES public.d_kelas(id);


--
-- Name: d_penempatan_siswa fk_id_subkelas_penempatan_siswa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_penempatan_siswa
    ADD CONSTRAINT fk_id_subkelas_penempatan_siswa FOREIGN KEY (id_subkelas) REFERENCES public.d_subkelas(id) NOT VALID;


--
-- Name: f_soal_hdr fk_id_subkelas_soal; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_hdr
    ADD CONSTRAINT fk_id_subkelas_soal FOREIGN KEY (id_subkelas) REFERENCES public.d_subkelas(id) NOT VALID;


--
-- Name: f_soal_hdr fk_id_ujian; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_hdr
    ADD CONSTRAINT fk_id_ujian FOREIGN KEY (id_ujian) REFERENCES public.d_ujian(id_ujian);


--
-- Name: f_soal_dtl fk_id_ujian_hdr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_dtl
    ADD CONSTRAINT fk_id_ujian_hdr FOREIGN KEY (id_ujian_hdr) REFERENCES public.f_soal_hdr(id_ujian_hdr) NOT VALID;


--
-- Name: f_jawaban_siswa_dtl fk_jawaban_siswa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_dtl
    ADD CONSTRAINT fk_jawaban_siswa FOREIGN KEY (id_jawaban_siswa) REFERENCES public.f_jawaban_siswa_hdr(id_jawaban_siswa) NOT VALID;


--
-- Name: d_subkelas fk_kelas; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_subkelas
    ADD CONSTRAINT fk_kelas FOREIGN KEY (id_kelas) REFERENCES public.d_kelas(id) NOT VALID;


--
-- Name: f_jawaban_siswa_hdr fk_kelas_jawaban_siswa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_hdr
    ADD CONSTRAINT fk_kelas_jawaban_siswa FOREIGN KEY (id_kelas) REFERENCES public.d_kelas(id) NOT VALID;


--
-- Name: d_penempatan_siswa fk_kelas_penempatan_siswa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_penempatan_siswa
    ADD CONSTRAINT fk_kelas_penempatan_siswa FOREIGN KEY (id_kelas) REFERENCES public.d_kelas(id) NOT VALID;


--
-- Name: users fk_kode_guru; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_kode_guru FOREIGN KEY (kode_guru) REFERENCES public.d_guru(kode_guru) NOT VALID;


--
-- Name: f_soal_hdr fk_kode_guru_hdr_soal; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_hdr
    ADD CONSTRAINT fk_kode_guru_hdr_soal FOREIGN KEY (kode_guru) REFERENCES public.d_guru(kode_guru) NOT VALID;


--
-- Name: d_penempatan_mapel_guru fk_kode_guru_penempatan_mapel; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_penempatan_mapel_guru
    ADD CONSTRAINT fk_kode_guru_penempatan_mapel FOREIGN KEY (kode_guru) REFERENCES public.d_guru(kode_guru) NOT VALID;


--
-- Name: d_guru fk_kode_mapel_guru; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_guru
    ADD CONSTRAINT fk_kode_mapel_guru FOREIGN KEY (kode_mata_pelajaran) REFERENCES public.d_mata_pelajaran(kode_mata_pelajaran) NOT VALID;


--
-- Name: d_penempatan_mapel_guru fk_kode_mata_pelajaran; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_penempatan_mapel_guru
    ADD CONSTRAINT fk_kode_mata_pelajaran FOREIGN KEY (kode_mata_pelajaran) REFERENCES public.d_mata_pelajaran(kode_mata_pelajaran) NOT VALID;


--
-- Name: f_soal_hdr fk_kode_mata_pelajaran_hdr_soal; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_hdr
    ADD CONSTRAINT fk_kode_mata_pelajaran_hdr_soal FOREIGN KEY (kode_mata_pelajaran) REFERENCES public.d_mata_pelajaran(kode_mata_pelajaran) NOT VALID;


--
-- Name: d_penempatan_siswa fk_kode_tahun_ajaran; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_penempatan_siswa
    ADD CONSTRAINT fk_kode_tahun_ajaran FOREIGN KEY (kode_tahun_ajaran) REFERENCES public.d_tahun_ajaran(kode_tahun_ajaran) NOT VALID;


--
-- Name: f_soal_hdr fk_kode_ujian_soal; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_hdr
    ADD CONSTRAINT fk_kode_ujian_soal FOREIGN KEY (kode_ujian) REFERENCES public.d_ujian(kode_ujian);


--
-- Name: d_ujian fk_mapel_jenis_ujian; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_ujian
    ADD CONSTRAINT fk_mapel_jenis_ujian FOREIGN KEY (kode_mata_pelajaran) REFERENCES public.d_mata_pelajaran(kode_mata_pelajaran) NOT VALID;


--
-- Name: users fk_nis; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_nis FOREIGN KEY (nis) REFERENCES public.d_siswa(nis) NOT VALID;


--
-- Name: f_jawaban_siswa_hdr fk_nis_jawaban_siswa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_hdr
    ADD CONSTRAINT fk_nis_jawaban_siswa FOREIGN KEY (nis) REFERENCES public.d_siswa(nis) NOT VALID;


--
-- Name: f_jawaban_siswa_hdr fk_siswa_jawaban_siswa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_hdr
    ADD CONSTRAINT fk_siswa_jawaban_siswa FOREIGN KEY (uuidsiswa) REFERENCES public.d_siswa(uuidsiswa) NOT VALID;


--
-- Name: f_jawaban_siswa_hdr fk_subkelas_jawaban_siswa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_hdr
    ADD CONSTRAINT fk_subkelas_jawaban_siswa FOREIGN KEY (id_subkelas) REFERENCES public.d_subkelas(id) NOT VALID;


--
-- Name: d_ujian fk_tahun_ajaran_jenis_ujian; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_ujian
    ADD CONSTRAINT fk_tahun_ajaran_jenis_ujian FOREIGN KEY (kode_tahun_ajaran) REFERENCES public.d_tahun_ajaran(kode_tahun_ajaran) NOT VALID;


--
-- Name: f_jawaban_siswa_hdr fk_ujian_jawaban_siswa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_jawaban_siswa_hdr
    ADD CONSTRAINT fk_ujian_jawaban_siswa FOREIGN KEY (id_ujian_hdr) REFERENCES public.f_soal_hdr(id_ujian_hdr) NOT VALID;


--
-- Name: f_soal_hdr fk_uuid_guru_hdr_soal; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.f_soal_hdr
    ADD CONSTRAINT fk_uuid_guru_hdr_soal FOREIGN KEY (uuidguru) REFERENCES public.d_guru(uuidguru) NOT VALID;


--
-- Name: d_penempatan_mapel_guru fk_uuidguru; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.d_penempatan_mapel_guru
    ADD CONSTRAINT fk_uuidguru FOREIGN KEY (uuidguru) REFERENCES public.d_guru(uuidguru);


--
-- PostgreSQL database dump complete
--

