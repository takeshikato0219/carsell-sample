--
-- PostgreSQL database dump
--

\restrict kAQI3d69yELj63PnjEgIxHMeZqPNIGHzA8ROGO5VIC3r1guLIRheFXEbjW0WpPj

-- Dumped from database version 15.15 (Homebrew)
-- Dumped by pg_dump version 15.15 (Homebrew)

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: deals_priority_enum; Type: TYPE; Schema: public; Owner: katomo
--

CREATE TYPE public.deals_priority_enum AS ENUM (
    'low',
    'medium',
    'high',
    'urgent'
);


ALTER TYPE public.deals_priority_enum OWNER TO katomo;

--
-- Name: deals_stage_enum; Type: TYPE; Schema: public; Owner: katomo
--

CREATE TYPE public.deals_stage_enum AS ENUM (
    'initial_contact',
    'hearing',
    'quote_sent',
    'negotiation',
    'contract',
    'awaiting_delivery',
    'delivered',
    'lost'
);


ALTER TYPE public.deals_stage_enum OWNER TO katomo;

--
-- Name: quotes_status_enum; Type: TYPE; Schema: public; Owner: katomo
--

CREATE TYPE public.quotes_status_enum AS ENUM (
    'draft',
    'sent',
    'approved',
    'rejected'
);


ALTER TYPE public.quotes_status_enum OWNER TO katomo;

--
-- Name: users_role_enum; Type: TYPE; Schema: public; Owner: katomo
--

CREATE TYPE public.users_role_enum AS ENUM (
    'admin',
    'manager',
    'sales'
);


ALTER TYPE public.users_role_enum OWNER TO katomo;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: contacts; Type: TABLE; Schema: public; Owner: katomo
--

CREATE TABLE public.contacts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    customer_id uuid NOT NULL,
    contact_type character varying(50) NOT NULL,
    subject character varying(200),
    content text,
    audio_file_url text,
    memo_file_url text,
    next_action text,
    next_contact_date date,
    contacted_at timestamp without time zone NOT NULL,
    created_by uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.contacts OWNER TO katomo;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: katomo
--

CREATE TABLE public.customers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    customer_number character varying,
    name character varying(100) NOT NULL,
    name_kana character varying(100),
    email character varying,
    phone character varying(20),
    mobile character varying(20),
    postal_code character varying(10),
    address text,
    company_name character varying(200),
    department character varying(100),
    "position" character varying(100),
    birthdate date,
    notes text,
    source character varying(50),
    assigned_sales_rep_id uuid,
    created_by uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.customers OWNER TO katomo;

--
-- Name: deals; Type: TABLE; Schema: public; Owner: katomo
--

CREATE TABLE public.deals (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    customer_id uuid NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    stage public.deals_stage_enum DEFAULT 'initial_contact'::public.deals_stage_enum NOT NULL,
    priority public.deals_priority_enum DEFAULT 'medium'::public.deals_priority_enum NOT NULL,
    estimated_amount numeric(12,2),
    probability integer,
    expected_close_date date,
    lost_reason text,
    assigned_to uuid,
    created_by uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    closed_at timestamp without time zone
);


ALTER TABLE public.deals OWNER TO katomo;

--
-- Name: quotes; Type: TABLE; Schema: public; Owner: katomo
--

CREATE TABLE public.quotes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    customer_id uuid NOT NULL,
    quote_number character varying NOT NULL,
    title character varying(200),
    vehicle_model character varying(100),
    vehicle_grade character varying(100),
    vehicle_color character varying(50),
    total_amount numeric(12,2),
    discount_amount numeric(12,2),
    final_amount numeric(12,2),
    excel_file_url text,
    pdf_file_url text,
    status public.quotes_status_enum DEFAULT 'draft'::public.quotes_status_enum NOT NULL,
    valid_until date,
    sent_at timestamp without time zone,
    approved_at timestamp without time zone,
    created_by uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.quotes OWNER TO katomo;

--
-- Name: users; Type: TABLE; Schema: public; Owner: katomo
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying NOT NULL,
    password_hash character varying NOT NULL,
    name character varying(100) NOT NULL,
    role public.users_role_enum DEFAULT 'sales'::public.users_role_enum NOT NULL,
    avatar_url character varying,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO katomo;

--
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: katomo
--

COPY public.contacts (id, customer_id, contact_type, subject, content, audio_file_url, memo_file_url, next_action, next_contact_date, contacted_at, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: katomo
--

COPY public.customers (id, customer_number, name, name_kana, email, phone, mobile, postal_code, address, company_name, department, "position", birthdate, notes, source, assigned_sales_rep_id, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: deals; Type: TABLE DATA; Schema: public; Owner: katomo
--

COPY public.deals (id, customer_id, title, description, stage, priority, estimated_amount, probability, expected_close_date, lost_reason, assigned_to, created_by, created_at, updated_at, closed_at) FROM stdin;
\.


--
-- Data for Name: quotes; Type: TABLE DATA; Schema: public; Owner: katomo
--

COPY public.quotes (id, customer_id, quote_number, title, vehicle_model, vehicle_grade, vehicle_color, total_amount, discount_amount, final_amount, excel_file_url, pdf_file_url, status, valid_until, sent_at, approved_at, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: katomo
--

COPY public.users (id, email, password_hash, name, role, avatar_url, is_active, created_at, updated_at) FROM stdin;
c28cd00c-b58e-4d1b-abcb-5e014e55e71c	admin@katomo.com	$2b$10$7rm2p2KjmXX1Mw48Nt2y9OwG9UVBe/Nd4l8WfGu1vPGBmtxOs2tg6	管理者	admin	\N	t	2025-12-08 22:59:35.504574	2025-12-08 22:59:35.504574
d1d595f7-b92b-4e23-8703-2c6b2811632b	manager@katomo.com	$2b$10$.0SMxpxYfVm1kyYjfdSEFeQhAay58RrVvkGasy2yW5DAHpEUPYAjC	目黒	manager	\N	t	2025-12-08 22:59:35.572054	2025-12-08 22:59:35.572054
b168e777-4738-4152-9e83-de4aafdeaa87	sales@katomo.com	$2b$10$LrZA.BZp/eT9mxgbFQozB.3GQDvDsczskVVugYeZNMjj2Oy3KgBvy	野島	sales	\N	t	2025-12-08 22:59:35.635792	2025-12-08 22:59:35.635792
4ce190d5-9ee6-4a5a-a768-0547cab4def2	ueyama@katomo.com	$2b$10$HxXeTH32M3vcZq7Y8W/zD.cYRGmaSGT2aUosGBL73GbVt9d0wJimq	ueyama	sales	\N	t	2025-12-09 01:01:04.443428	2025-12-09 01:01:04.443428
3724e007-ddff-4c5a-9935-80bf2425a76a	numao@katomo.com	$2b$10$ONxLiejvctJI/Nsn9kX6jOX07.9tEOJq1Luy5Un9sLJXCQtVyJgEC	numao	sales	\N	t	2025-12-09 01:01:04.521766	2025-12-09 01:01:04.521766
4da2648a-1510-435a-976b-65bdcc9ea843	tomomi@katomo.com	$2b$10$rqbx/ODEHqucPvYFWCIi8uNfSdT/30P3g6plX3DVaCHiZxA0hO3B6	tomomi	sales	\N	t	2025-12-09 01:01:04.585191	2025-12-09 01:01:04.585191
\.


--
-- Name: customers PK_133ec679a801fab5e070f73d3ea; Type: CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT "PK_133ec679a801fab5e070f73d3ea" PRIMARY KEY (id);


--
-- Name: deals PK_8c66f03b250f613ff8615940b4b; Type: CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT "PK_8c66f03b250f613ff8615940b4b" PRIMARY KEY (id);


--
-- Name: quotes PK_99a0e8bcbcd8719d3a41f23c263; Type: CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT "PK_99a0e8bcbcd8719d3a41f23c263" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: contacts PK_b99cd40cfd66a99f1571f4f72e6; Type: CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT "PK_b99cd40cfd66a99f1571f4f72e6" PRIMARY KEY (id);


--
-- Name: quotes UQ_0fe91de257e744a53b519b41a9c; Type: CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT "UQ_0fe91de257e744a53b519b41a9c" UNIQUE (quote_number);


--
-- Name: customers UQ_6fbe8c55d8dd968877d296493e3; Type: CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT "UQ_6fbe8c55d8dd968877d296493e3" UNIQUE (customer_number);


--
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE (email);


--
-- Name: contacts FK_06dcbcd88c5647753f0f0a4f1cc; Type: FK CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT "FK_06dcbcd88c5647753f0f0a4f1cc" FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: contacts FK_3857e3d5137fea5865651a1be75; Type: FK CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT "FK_3857e3d5137fea5865651a1be75" FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: deals FK_4488176723eb7a467cbfc397346; Type: FK CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT "FK_4488176723eb7a467cbfc397346" FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: quotes FK_7597d56df256df54e6fda6cd646; Type: FK CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT "FK_7597d56df256df54e6fda6cd646" FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: customers FK_8f138f284609b045dc64c91757a; Type: FK CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT "FK_8f138f284609b045dc64c91757a" FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: deals FK_9be56ac4039640667147157451a; Type: FK CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT "FK_9be56ac4039640667147157451a" FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: quotes FK_a11bdb4a739328d1009c0b47e83; Type: FK CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.quotes
    ADD CONSTRAINT "FK_a11bdb4a739328d1009c0b47e83" FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: customers FK_a5ee2fe2ca079a72cd87c48dde6; Type: FK CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT "FK_a5ee2fe2ca079a72cd87c48dde6" FOREIGN KEY (assigned_sales_rep_id) REFERENCES public.users(id);


--
-- Name: deals FK_a96c558d0ebee23c264dbe726fb; Type: FK CONSTRAINT; Schema: public; Owner: katomo
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT "FK_a96c558d0ebee23c264dbe726fb" FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict kAQI3d69yELj63PnjEgIxHMeZqPNIGHzA8ROGO5VIC3r1guLIRheFXEbjW0WpPj

