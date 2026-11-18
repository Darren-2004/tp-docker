--
-- PostgreSQL database dump
--

\restrict o5oWDFzTKxiAVDSQGDHUizytdFxp9OvMnXuyUrKuQrR7ntpW0JcHz24PWq44Mxc

-- Dumped from database version 16.16
-- Dumped by pg_dump version 16.16

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: visits; Type: TABLE; Schema: public; Owner: tp
--

CREATE TABLE public.visits (
    id integer NOT NULL,
    at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.visits OWNER TO tp;

--
-- Name: visits_id_seq; Type: SEQUENCE; Schema: public; Owner: tp
--

CREATE SEQUENCE public.visits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visits_id_seq OWNER TO tp;

--
-- Name: visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tp
--

ALTER SEQUENCE public.visits_id_seq OWNED BY public.visits.id;


--
-- Name: visits id; Type: DEFAULT; Schema: public; Owner: tp
--

ALTER TABLE ONLY public.visits ALTER COLUMN id SET DEFAULT nextval('public.visits_id_seq'::regclass);


--
-- Data for Name: visits; Type: TABLE DATA; Schema: public; Owner: tp
--

COPY public.visits (id, at) FROM stdin;
1	2026-11-18 09:19:36.276173
2	2026-11-18 09:19:36.41826
3	2026-11-18 09:22:25.755568
4	2026-11-18 09:23:13.50577
5	2026-11-18 09:34:59.627142
6	2026-11-18 09:34:59.918947
\.


--
-- Name: visits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tp
--

SELECT pg_catalog.setval('public.visits_id_seq', 6, true);


--
-- Name: visits visits_pkey; Type: CONSTRAINT; Schema: public; Owner: tp
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict o5oWDFzTKxiAVDSQGDHUizytdFxp9OvMnXuyUrKuQrR7ntpW0JcHz24PWq44Mxc

