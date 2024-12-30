--
-- PostgreSQL database dump
--

-- Dumped from database version 15.7
-- Dumped by pg_dump version 15.3

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: file_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.file_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.file_seq OWNER TO postgres;

--
-- Name: ia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.ia_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ia (
    ia_seq bigint DEFAULT nextval('public.ia_seq'::regclass) NOT NULL,
    ia_id text NOT NULL,
    depth1 character varying(50) NOT NULL,
    depth2 character varying(50) NOT NULL,
    depth3 character varying(50) NOT NULL,
    depth4 character varying(50) NOT NULL,
    ia_num integer
);


ALTER TABLE public.ia OWNER TO postgres;

--
-- Name: payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.payment_id_seq OWNER TO postgres;

--
-- Name: payment_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_history (
    payment_history_id bigint DEFAULT nextval('public.payment_id_seq'::regclass) NOT NULL,
    user_id character varying(50) NOT NULL,
    date date NOT NULL,
    plan character varying(255) NOT NULL,
    amount bigint NOT NULL,
    method character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    receipt_url character varying(255)
);


ALTER TABLE public.payment_history OWNER TO postgres;

--
-- Name: payment_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.payment_seq OWNER TO postgres;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    payment_id integer DEFAULT nextval('public.payment_seq'::regclass) NOT NULL,
    user_id integer,
    subscription_id integer,
    payment_date date,
    amount numeric(10,2),
    status character varying(50)
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: rfp_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rfp_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.rfp_seq OWNER TO postgres;

--
-- Name: rfp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rfp (
    rfp_seq bigint DEFAULT nextval('public.rfp_seq'::regclass) NOT NULL,
    pro_name character varying(255),
    pro_period character varying(20),
    pro_budget character varying(50),
    pro_service text,
    pro_output text,
    pro_reference text,
    pro_ia text,
    pro_wbs text,
    user_session character varying(100),
    expected_budget character varying(50),
    expected_period character varying(20),
    pro_agency text,
    user_id character varying(100),
    pro_funcdesc text,
    wbs_doc text
);


ALTER TABLE public.rfp OWNER TO postgres;

--
-- Name: rfp_temp_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rfp_temp_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.rfp_temp_seq OWNER TO postgres;

--
-- Name: rfp_temp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rfp_temp (
    rfp_temp_seq bigint DEFAULT nextval('public.rfp_temp_seq'::regclass) NOT NULL,
    pro_name character varying(255),
    pro_period character varying(30),
    pro_budget character varying(50),
    pro_agency text,
    pro_function text,
    pro_skill text,
    pro_description text,
    user_session character varying(100),
    pro_reference text,
    inserted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.rfp_temp OWNER TO postgres;

--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    sid character varying NOT NULL,
    sess json NOT NULL,
    expire timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: subscription_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subscription_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.subscription_seq OWNER TO postgres;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscriptions (
    subscription_id integer DEFAULT nextval('public.subscription_seq'::regclass) NOT NULL,
    user_id integer,
    start_date date,
    end_date date,
    amount numeric(10,2),
    status character varying(50)
);


ALTER TABLE public.subscriptions OWNER TO postgres;

--
-- Name: text_file_test; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.text_file_test (
    text_contents text,
    user_session character varying(100),
    inserted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.text_file_test OWNER TO postgres;

--
-- Name: thread_id; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.thread_id (
    thread_id character varying(100),
    user_session character varying(100),
    inserted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.thread_id OWNER TO postgres;

--
-- Name: user_info_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_info_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.user_info_seq OWNER TO postgres;

--
-- Name: user_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_info (
    user_info_seq bigint DEFAULT nextval('public.user_info_seq'::regclass) NOT NULL,
    user_id character varying(50),
    user_password character varying(200),
    user_phone character varying(50),
    user_email character varying(100),
    subscription_status character varying(50),
    subscription_end_date date,
    subscription_new character varying(5),
    subscription_start_date date,
    available_num character varying(100),
    billing_key character varying(255),
    customer_key character varying(255)
);


ALTER TABLE public.user_info OWNER TO postgres;

--
-- Name: voice_file; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.voice_file (
    file_seq bigint DEFAULT nextval('public.file_seq'::regclass) NOT NULL,
    file_name character varying(200),
    file_size character varying(200),
    user_session character varying(100)
);


ALTER TABLE public.voice_file OWNER TO postgres;

--
-- Name: wbs_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wbs_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;


ALTER TABLE public.wbs_seq OWNER TO postgres;

--
-- Name: wbs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wbs (
    wbs_seq bigint DEFAULT nextval('public.wbs_seq'::regclass) NOT NULL,
    wbs_id text NOT NULL,
    task_name character varying(255) NOT NULL,
    roles_involved character varying(255),
    start_month numeric(3,1) NOT NULL,
    end_month numeric(3,1),
    description text
);


ALTER TABLE public.wbs OWNER TO postgres;

--
-- Data for Name: ia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ia (ia_seq, ia_id, depth1, depth2, depth3, depth4, ia_num) FROM stdin;
12370	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	-	-	-	1
12371	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	미용사 선택	-	-	1
12372	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	미용사 선택	인구 대비 미용사 수 배치	-	1
12373	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	미용사 선택	거리 기반 미용사 매칭	-	1
12374	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	일정 예약	-	-	1
12375	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	일정 예약	미용사 일정 확인	-	1
12376	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	일정 예약	예약 시간 선택	-	1
12377	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	일정 예약	예약 옵션 선택	-	1
12378	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	일정 예약	예약 옵션 선택	반려동물 무게	1
12379	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	일정 예약	예약 옵션 선택	털의 종류와 상태	1
12380	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	일정 예약	예약 옵션 선택	특이사항	1
12381	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	결제하기	-	-	1
12382	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	결제하기	결제 수단 선택	-	1
12383	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	결제하기	결제 정보 입력	-	1
12384	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	결제하기	결제 확인 및 완료	-	1
12385	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	예약 확인 및 전달	-	-	1
12386	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	예약 확인 및 전달	예약 정보 카카오톡 전달	-	1
12387	6d6cd042-eca4-46b2-af20-8c88433638af	예약하기	예약 확인 및 전달	미용사와 고객에게 예약 확인	-	1
12388	6d6cd042-eca4-46b2-af20-8c88433638af	로그인 & 가입	-	-	-	2
12389	6d6cd042-eca4-46b2-af20-8c88433638af	로그인 & 가입	회원가입	-	-	2
12390	6d6cd042-eca4-46b2-af20-8c88433638af	로그인 & 가입	회원가입	이메일 가입	-	2
12391	6d6cd042-eca4-46b2-af20-8c88433638af	로그인 & 가입	회원가입	네이버, 카카오, 구글 소셜 가입	-	2
12392	6d6cd042-eca4-46b2-af20-8c88433638af	로그인 & 가입	로그인	-	-	2
12393	6d6cd042-eca4-46b2-af20-8c88433638af	로그인 & 가입	로그인	아이디/비밀번호 로그인	-	2
12394	6d6cd042-eca4-46b2-af20-8c88433638af	로그인 & 가입	로그인	소셜 로그인 (네이버, 카카오, 구글)	-	2
12395	6d6cd042-eca4-46b2-af20-8c88433638af	별점 & 평가	-	-	-	3
12396	6d6cd042-eca4-46b2-af20-8c88433638af	별점 & 평가	후기 작성	-	-	3
12397	6d6cd042-eca4-46b2-af20-8c88433638af	별점 & 평가	후기 작성	글 작성	-	3
12398	6d6cd042-eca4-46b2-af20-8c88433638af	별점 & 평가	후기 작성	이미지 업로드	-	3
12399	6d6cd042-eca4-46b2-af20-8c88433638af	별점 & 평가	후기 작성	동영상 업로드	-	3
12400	6d6cd042-eca4-46b2-af20-8c88433638af	별점 & 평가	후기 작성	미용사 칭찬점수 (1~5)	-	3
12401	6d6cd042-eca4-46b2-af20-8c88433638af	별점 & 평가	후기 관리	-	-	3
12402	6d6cd042-eca4-46b2-af20-8c88433638af	별점 & 평가	후기 관리	후기 댓글	-	3
12403	6d6cd042-eca4-46b2-af20-8c88433638af	별점 & 평가	후기 관리	좋아요	-	3
12404	6d6cd042-eca4-46b2-af20-8c88433638af	별점 & 평가	후기 관리	이모티콘 추가	-	3
12405	6d6cd042-eca4-46b2-af20-8c88433638af	회원 분류하기	-	-	-	4
12406	6d6cd042-eca4-46b2-af20-8c88433638af	회원 분류하기	기본 회원	-	-	4
12407	6d6cd042-eca4-46b2-af20-8c88433638af	회원 분류하기	단골 고객 등록	-	-	4
12408	6d6cd042-eca4-46b2-af20-8c88433638af	회원 분류하기	단골 고객 등록	단골 고객 등록 옵션	-	4
12409	6d6cd042-eca4-46b2-af20-8c88433638af	회원 분류하기	단골 고객 등록	단골 고객 관리	-	4
12410	6d6cd042-eca4-46b2-af20-8c88433638af	알림 보내기	-	-	-	5
12411	6d6cd042-eca4-46b2-af20-8c88433638af	알림 보내기	예약 알림	-	-	5
12412	6d6cd042-eca4-46b2-af20-8c88433638af	알림 보내기	예약 알림	예약 완료 알림	-	5
12413	6d6cd042-eca4-46b2-af20-8c88433638af	알림 보내기	예약 알림	예약 취소 알림	-	5
12414	6d6cd042-eca4-46b2-af20-8c88433638af	알림 보내기	후속 알림	-	-	5
12415	6d6cd042-eca4-46b2-af20-8c88433638af	알림 보내기	후속 알림	예약 임박 알림	-	5
12416	6d6cd042-eca4-46b2-af20-8c88433638af	알림 보내기	후속 알림	후기 작성 요청 알림	-	5
12417	6d6cd042-eca4-46b2-af20-8c88433638af	매칭	-	-	-	6
12418	6d6cd042-eca4-46b2-af20-8c88433638af	매칭	고객-미용사 매칭	-	-	6
12419	6d6cd042-eca4-46b2-af20-8c88433638af	매칭	고객-미용사 매칭	거리 기반 매칭	-	6
12420	6d6cd042-eca4-46b2-af20-8c88433638af	매칭	고객-미용사 매칭	일정 기반 매칭	-	6
12421	6d6cd042-eca4-46b2-af20-8c88433638af	팔로우	-	-	-	7
12422	6d6cd042-eca4-46b2-af20-8c88433638af	팔로우	단골 미용사 팔로우	-	-	7
12423	6d6cd042-eca4-46b2-af20-8c88433638af	팔로우	단골 미용사 팔로우	팔로우/언팔로우 기능	-	7
12424	6d6cd042-eca4-46b2-af20-8c88433638af	팔로우	단골 미용사 팔로우	팔로우한 미용사 목록	-	7
12425	6d6cd042-eca4-46b2-af20-8c88433638af	검색	-	-	-	8
12426	6d6cd042-eca4-46b2-af20-8c88433638af	검색	미용사 검색	-	-	8
12427	6d6cd042-eca4-46b2-af20-8c88433638af	검색	미용사 검색	이름 검색	-	8
12428	6d6cd042-eca4-46b2-af20-8c88433638af	검색	미용사 검색	지역 검색	-	8
12429	6d6cd042-eca4-46b2-af20-8c88433638af	검색	미용사 검색	예약 가능 시간대 검색	-	8
12430	6d6cd042-eca4-46b2-af20-8c88433638af	주문 관리	-	-	-	9
12431	6d6cd042-eca4-46b2-af20-8c88433638af	주문 관리	예약 취소	-	-	9
12432	6d6cd042-eca4-46b2-af20-8c88433638af	주문 관리	예약 취소	고객 예약 취소	-	9
12433	6d6cd042-eca4-46b2-af20-8c88433638af	주문 관리	예약 취소	미용사 예약 취소	-	9
12434	6d6cd042-eca4-46b2-af20-8c88433638af	주문 관리	예약 취소	취소 알림	-	9
12435	6d6cd042-eca4-46b2-af20-8c88433638af	주문 관리	환불 처리	-	-	9
12436	6d6cd042-eca4-46b2-af20-8c88433638af	주문 관리	환불 처리	수기 환불 처리	-	9
12437	6d6cd042-eca4-46b2-af20-8c88433638af	주문 관리	환불 처리	자동화 환불 처리 (옵션)	-	9
12438	6d6cd042-eca4-46b2-af20-8c88433638af	SEO 자동 연동	-	-	-	10
12439	6d6cd042-eca4-46b2-af20-8c88433638af	SEO 자동 연동	네이버 SEO	-	-	10
12440	6d6cd042-eca4-46b2-af20-8c88433638af	SEO 자동 연동	카카오 SEO	-	-	10
12441	6d6cd042-eca4-46b2-af20-8c88433638af	SEO 자동 연동	구글 SEO	-	-	10
12513	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	-	-	-	1
12514	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	회원가입	-	-	1
12515	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	회원가입	이메일 인증	-	1
12516	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	회원가입	SNS 로그인 (네이버, 카카오, 구글)	-	1
12517	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	로그인	-	-	1
12518	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	회원 분류하기	-	-	1
12519	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	회원 분류하기	미용사	-	1
12520	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	회원 분류하기	미용사	개인 일정 관리	1
12521	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	회원 분류하기	일반 고객	-	1
12522	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	단골고객 등록	-	-	1
12523	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	단골고객 등록	후기 남기기	-	1
12524	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	단골고객 등록	글, 이미지, 동영상 첨부	-	1
12525	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	단골고객 등록	미용사 칭찬점수 (1~5)	-	1
12526	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	로그인 & 회원관리	단골고객 등록	후기 댓글, 좋아요, 이모티콘 추가	-	1
12527	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약하기	-	-	-	2
12528	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약하기	예약 설정	-	-	2
12529	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약하기	예약 설정	미용사 선택	-	2
12530	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약하기	예약 설정	일정 선택	-	2
12531	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약하기	예약 설정	옵션 선택 (무게, 털의 종류와 상태, 특이사항 등)	-	2
12532	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약하기	결제하기	-	-	2
12533	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약하기	결제하기	온라인 결제 방식 지원	-	2
12534	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약하기	알림 보내기	-	-	2
12535	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약하기	알림 보내기	예약 완료 알림 (카톡 자동 전달)	-	2
12536	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약하기	알림 보내기	예약 취소 알림	-	2
12537	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	평가 & 리뷰 관리	-	-	-	3
12538	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	평가 & 리뷰 관리	별점 & 평가	-	-	3
12539	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	평가 & 리뷰 관리	별점 & 평가	고객 후기에 별점 추가	-	3
12540	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	평가 & 리뷰 관리	별점 & 평가	후기 댓글, 좋아요, 이모티콘 추가	-	3
12541	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	검색 기능	-	-	-	4
12542	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	검색 기능	미용사 검색	-	-	4
12543	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	검색 기능	미용사 검색	위치 기반 검색	-	4
12544	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	검색 기능	미용사 검색	평점 및 후기 기반 검색	-	4
12545	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	매칭 시스템	-	-	-	5
12546	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	매칭 시스템	위치 기반 매칭	-	-	5
12547	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	매칭 시스템	위치 기반 매칭	방문이 용이한 거리상의 미용사 매칭	-	5
12548	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	매칭 시스템	시장 규모 맞춤형 매칭	-	-	5
12549	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	매칭 시스템	시장 규모 맞춤형 매칭	지자체 읍면동 인구대비 매칭	-	5
12550	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	알림 관리	-	-	-	6
12551	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	알림 관리	예약 알림	-	-	6
12552	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	알림 관리	취소 알림	-	-	6
12553	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약 관리	-	-	-	7
12554	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약 관리	예약 취소	-	-	7
12555	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	예약 관리	예약 환불 처리	-	-	7
12556	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	기타 기능	-	-	-	8
12557	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	기타 기능	콘텐츠 관리	-	-	8
12558	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	기타 기능	콘텐츠 관리	글	-	8
12559	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	기타 기능	콘텐츠 관리	이미지	-	8
12560	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	기타 기능	콘텐츠 관리	동영상	-	8
12561	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	기타 기능	SEO 최적화	-	-	8
12562	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	기타 기능	SEO 최적화	네이버 연동	-	8
12563	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	기타 기능	SEO 최적화	카카오 연동	-	8
12564	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	기타 기능	SEO 최적화	구글 연동	-	8
12565	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	-	-	-	1
12566	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원가입 및 로그인	-	-	1
12567	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원가입 및 로그인	일반 회원가입	-	1
12568	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원가입 및 로그인	일반 회원가입	이메일 인증	1
12569	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원가입 및 로그인	일반 회원가입	비밀번호 생성 및 확인	1
12570	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원가입 및 로그인	소셜 로그인	-	1
12571	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원가입 및 로그인	소셜 로그인	네이버 로그인	1
12572	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원가입 및 로그인	소셜 로그인	카카오 로그인	1
12573	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원가입 및 로그인	소셜 로그인	구글 로그인	1
12574	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원 분류	-	-	1
12575	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원 분류	미용사 등록	-	1
12576	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원 분류	미용사 등록	온오프면접을 통한 등록	1
12577	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원 분류	미용사 등록	지자체 읍면동 인구비율에 따른 미용사 분류	1
12578	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원 분류	고객 등록	-	1
12579	d388d19c-d16b-4b44-af17-d41b88b26d5b	회원 시스템	회원 분류	고객 등록	단골 고객 등록 옵션	1
12580	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	-	-	-	2
12581	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 생성	-	-	2
12582	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 생성	미용사 선택	-	2
12583	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 생성	미용사 선택	거리 기반 미용사 선택	2
12584	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 생성	미용사 선택	미용사 일정 확인	2
12585	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 생성	예약 옵션 설정	-	2
12586	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 생성	예약 옵션 설정	반려동물 무게	2
12587	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 생성	예약 옵션 설정	털의 종류와 상태	2
12588	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 생성	예약 옵션 설정	특이사항	2
12589	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 결제	-	-	2
12590	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 결제	온라인 결제	-	2
12591	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 결제	온라인 결제	카드 결제	2
12592	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 결제	온라인 결제	계좌이체	2
12593	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 결제	온라인 결제	기타 결제 방식	2
12594	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 결제	결제 완료 알림	-	2
12595	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 결제	결제 완료 알림	미용사에게 알림	2
12596	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 결제	결제 완료 알림	예약고객에게 알림	2
12597	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 취소 및 환불	-	-	2
12598	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 취소 및 환불	미용사 취소	-	2
12599	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 취소 및 환불	미용사 취소	취소 알림	2
12600	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 취소 및 환불	미용사 취소	환불 처리	2
12601	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 취소 및 환불	고객 취소	-	2
12602	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 취소 및 환불	고객 취소	취소 알림	2
12603	d388d19c-d16b-4b44-af17-d41b88b26d5b	예약 시스템	예약 취소 및 환불	고객 취소	환불 처리	2
12604	d388d19c-d16b-4b44-af17-d41b88b26d5b	리뷰 및 평가	-	-	-	3
12605	d388d19c-d16b-4b44-af17-d41b88b26d5b	리뷰 및 평가	리뷰 작성	-	-	3
12606	d388d19c-d16b-4b44-af17-d41b88b26d5b	리뷰 및 평가	리뷰 작성	글 작성	-	3
12607	d388d19c-d16b-4b44-af17-d41b88b26d5b	리뷰 및 평가	리뷰 작성	이미지 업로드	-	3
12608	d388d19c-d16b-4b44-af17-d41b88b26d5b	리뷰 및 평가	리뷰 작성	동영상 업로드	-	3
12609	d388d19c-d16b-4b44-af17-d41b88b26d5b	리뷰 및 평가	리뷰 작성	미용사 칭찬점수(1~5점)	-	3
12610	d388d19c-d16b-4b44-af17-d41b88b26d5b	리뷰 및 평가	리뷰 상호작용	-	-	3
12611	d388d19c-d16b-4b44-af17-d41b88b26d5b	리뷰 및 평가	리뷰 상호작용	댓글 작성	-	3
12612	d388d19c-d16b-4b44-af17-d41b88b26d5b	리뷰 및 평가	리뷰 상호작용	좋아요	-	3
12613	d388d19c-d16b-4b44-af17-d41b88b26d5b	리뷰 및 평가	리뷰 상호작용	이모티콘 추가	-	3
12614	d388d19c-d16b-4b44-af17-d41b88b26d5b	알림 시스템	-	-	-	4
12615	d388d19c-d16b-4b44-af17-d41b88b26d5b	알림 시스템	예약 알림	-	-	4
12616	d388d19c-d16b-4b44-af17-d41b88b26d5b	알림 시스템	예약 알림	예약 완료 알림	-	4
12617	d388d19c-d16b-4b44-af17-d41b88b26d5b	알림 시스템	예약 알림	예약 취소 알림	-	4
12618	d388d19c-d16b-4b44-af17-d41b88b26d5b	알림 시스템	일반 알림	-	-	4
12619	d388d19c-d16b-4b44-af17-d41b88b26d5b	알림 시스템	일반 알림	정산 알림	-	4
12620	d388d19c-d16b-4b44-af17-d41b88b26d5b	알림 시스템	일반 알림	프로모션 및 이벤트 알림	-	4
12621	d388d19c-d16b-4b44-af17-d41b88b26d5b	커뮤니케이션 시스템	-	-	-	5
12622	d388d19c-d16b-4b44-af17-d41b88b26d5b	커뮤니케이션 시스템	채팅	-	-	5
12623	d388d19c-d16b-4b44-af17-d41b88b26d5b	커뮤니케이션 시스템	채팅	예약 고객과 미용사 간 채팅	-	5
12624	d388d19c-d16b-4b44-af17-d41b88b26d5b	커뮤니케이션 시스템	예약 관련 알림	-	-	5
12625	d388d19c-d16b-4b44-af17-d41b88b26d5b	커뮤니케이션 시스템	예약 관련 알림	카카오톡 알림	-	5
13070	5893b347-d8e5-4ed9-8174-e454836ceecb	채팅	-	-	-	5
12626	d388d19c-d16b-4b44-af17-d41b88b26d5b	결제 및 정산 시스템	-	-	-	6
12627	d388d19c-d16b-4b44-af17-d41b88b26d5b	결제 및 정산 시스템	결제 처리	-	-	6
12628	d388d19c-d16b-4b44-af17-d41b88b26d5b	결제 및 정산 시스템	결제 처리	자동 결제 처리	-	6
12629	d388d19c-d16b-4b44-af17-d41b88b26d5b	결제 및 정산 시스템	결제 처리	수동 결제 처리(복잡한 경우)	-	6
12630	d388d19c-d16b-4b44-af17-d41b88b26d5b	결제 및 정산 시스템	미용사와의 정산	-	-	6
12631	d388d19c-d16b-4b44-af17-d41b88b26d5b	결제 및 정산 시스템	미용사와의 정산	수작업 정산	-	6
12632	d388d19c-d16b-4b44-af17-d41b88b26d5b	결제 및 정산 시스템	미용사와의 정산	자동 정산 옵션(추가 가능 시)	-	6
12633	d388d19c-d16b-4b44-af17-d41b88b26d5b	콘텐츠 관리	-	-	-	7
12634	d388d19c-d16b-4b44-af17-d41b88b26d5b	콘텐츠 관리	홈 화면 구성	-	-	7
12635	d388d19c-d16b-4b44-af17-d41b88b26d5b	콘텐츠 관리	홈 화면 구성	주요 서비스 소개	-	7
12636	d388d19c-d16b-4b44-af17-d41b88b26d5b	콘텐츠 관리	홈 화면 구성	예약 홍보 콘텐츠	-	7
12637	d388d19c-d16b-4b44-af17-d41b88b26d5b	콘텐츠 관리	후기 및 리뷰 콘텐츠	-	-	7
12638	d388d19c-d16b-4b44-af17-d41b88b26d5b	콘텐츠 관리	후기 및 리뷰 콘텐츠	고객 후기	-	7
12639	d388d19c-d16b-4b44-af17-d41b88b26d5b	콘텐츠 관리	후기 및 리뷰 콘텐츠	리뷰 댓글	-	7
12640	d388d19c-d16b-4b44-af17-d41b88b26d5b	검색 엔진 최적화(SEO)	-	-	-	8
12641	d388d19c-d16b-4b44-af17-d41b88b26d5b	검색 엔진 최적화(SEO)	자동 연동	-	-	8
12642	d388d19c-d16b-4b44-af17-d41b88b26d5b	검색 엔진 최적화(SEO)	자동 연동	네이버 SEO	-	8
12643	d388d19c-d16b-4b44-af17-d41b88b26d5b	검색 엔진 최적화(SEO)	자동 연동	카카오 SEO	-	8
12644	d388d19c-d16b-4b44-af17-d41b88b26d5b	검색 엔진 최적화(SEO)	자동 연동	구글 SEO	-	8
12645	d388d19c-d16b-4b44-af17-d41b88b26d5b	단골 관리	-	-	-	9
12646	d388d19c-d16b-4b44-af17-d41b88b26d5b	단골 관리	단골 고객 등록	-	-	9
12647	d388d19c-d16b-4b44-af17-d41b88b26d5b	단골 관리	단골 고객 등록	미용사 즐겨찾기	-	9
12648	d388d19c-d16b-4b44-af17-d41b88b26d5b	단골 관리	단골 고객 등록	리뷰 작성 권한	-	9
12649	36ec7463-2785-4506-b809-38bfa1af9183	로그인 & 가입	-	-	-	1
12650	36ec7463-2785-4506-b809-38bfa1af9183	로그인 & 가입	회원가입	-	-	1
12651	36ec7463-2785-4506-b809-38bfa1af9183	로그인 & 가입	회원가입	이메일 인증	-	1
12652	36ec7463-2785-4506-b809-38bfa1af9183	로그인 & 가입	로그인	-	-	1
12653	36ec7463-2785-4506-b809-38bfa1af9183	로그인 & 가입	로그인	아이디/비밀번호 찾기	-	1
12654	36ec7463-2785-4506-b809-38bfa1af9183	로그인 & 가입	소셜 로그인	-	-	1
12655	36ec7463-2785-4506-b809-38bfa1af9183	로그인 & 가입	소셜 로그인	네이버 로그인	-	1
12656	36ec7463-2785-4506-b809-38bfa1af9183	로그인 & 가입	소셜 로그인	카카오 로그인	-	1
12657	36ec7463-2785-4506-b809-38bfa1af9183	로그인 & 가입	소셜 로그인	구글 로그인	-	1
12658	36ec7463-2785-4506-b809-38bfa1af9183	결제하기	-	-	-	2
12659	36ec7463-2785-4506-b809-38bfa1af9183	결제하기	결제 수단 선택	-	-	2
12660	36ec7463-2785-4506-b809-38bfa1af9183	결제하기	결제 수단 선택	신용카드 결제	-	2
12661	36ec7463-2785-4506-b809-38bfa1af9183	결제하기	결제 수단 선택	계좌이체	-	2
12662	36ec7463-2785-4506-b809-38bfa1af9183	결제하기	결제 수단 선택	간편결제	-	2
12663	36ec7463-2785-4506-b809-38bfa1af9183	결제하기	결제 확인	-	-	2
12664	36ec7463-2785-4506-b809-38bfa1af9183	별점 & 평가	-	-	-	3
12665	36ec7463-2785-4506-b809-38bfa1af9183	별점 & 평가	후기 작성	-	-	3
12666	36ec7463-2785-4506-b809-38bfa1af9183	별점 & 평가	후기 작성	글 후기 작성	-	3
12667	36ec7463-2785-4506-b809-38bfa1af9183	별점 & 평가	후기 작성	이미지 후기 업로드	-	3
12668	36ec7463-2785-4506-b809-38bfa1af9183	별점 & 평가	후기 작성	동영상 후기 업로드	-	3
12669	36ec7463-2785-4506-b809-38bfa1af9183	별점 & 평가	평점 매기기	-	-	3
12670	36ec7463-2785-4506-b809-38bfa1af9183	별점 & 평가	평점 매기기	미용사 칭찬 점수 (1-5점)	-	3
12671	36ec7463-2785-4506-b809-38bfa1af9183	알림 보내기	-	-	-	4
12672	36ec7463-2785-4506-b809-38bfa1af9183	알림 보내기	예약 알림	-	-	4
12673	36ec7463-2785-4506-b809-38bfa1af9183	알림 보내기	예약 알림	예약 완료 알림	-	4
12674	36ec7463-2785-4506-b809-38bfa1af9183	알림 보내기	예약 알림	예약 취소 알림	-	4
12675	36ec7463-2785-4506-b809-38bfa1af9183	알림 보내기	일정 알림	-	-	4
12676	36ec7463-2785-4506-b809-38bfa1af9183	알림 보내기	일정 알림	예약 전 리마인더	-	4
12677	36ec7463-2785-4506-b809-38bfa1af9183	회원 분류하기	-	-	-	5
12678	36ec7463-2785-4506-b809-38bfa1af9183	회원 분류하기	회원 관리	-	-	5
12679	36ec7463-2785-4506-b809-38bfa1af9183	회원 분류하기	회원 관리	일반 회원	-	5
12680	36ec7463-2785-4506-b809-38bfa1af9183	회원 분류하기	회원 관리	단골 고객	-	5
12681	36ec7463-2785-4506-b809-38bfa1af9183	회원 분류하기	회원 관리	단골 고객	단골 고객 혜택	5
12682	36ec7463-2785-4506-b809-38bfa1af9183	회원 분류하기	회원 관리	단골 고객	단골 고객 후기 작성	5
12683	36ec7463-2785-4506-b809-38bfa1af9183	팔로우	-	-	-	6
12684	36ec7463-2785-4506-b809-38bfa1af9183	팔로우	미용사 팔로우	-	-	6
12685	36ec7463-2785-4506-b809-38bfa1af9183	팔로우	미용사 팔로우	팔로우 목록 관리	-	6
12686	36ec7463-2785-4506-b809-38bfa1af9183	채팅	-	-	-	7
12687	36ec7463-2785-4506-b809-38bfa1af9183	채팅	실시간 채팅	-	-	7
12688	36ec7463-2785-4506-b809-38bfa1af9183	채팅	실시간 채팅	미용사와 채팅	-	7
12689	36ec7463-2785-4506-b809-38bfa1af9183	채팅	실시간 채팅	고객 지원 채팅	-	7
12690	36ec7463-2785-4506-b809-38bfa1af9183	채팅	실시간 채팅	알림 메시지 전송	-	7
12691	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	-	-	-	8
12692	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	미용사 선택	-	-	8
12693	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	미용사 선택	거리 기반 미용사 검색	-	8
12694	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	예약 일정 선택	-	-	8
12695	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	예약 세부 정보	-	-	8
12696	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	예약 세부 정보	애완동물 무게	-	8
12697	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	예약 세부 정보	털의 종류와 상태	-	8
12698	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	예약 세부 정보	특이사항	-	8
12699	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	예약 확정 후 알림	-	-	8
12700	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	예약 확정 후 알림	카카오톡 알림 전송	-	8
12701	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	예약 취소 및 환불	-	-	8
12702	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	예약 취소 및 환불	예약 취소 처리	-	8
12703	36ec7463-2785-4506-b809-38bfa1af9183	예약하기	예약 취소 및 환불	환불 절차 안내	-	8
12704	36ec7463-2785-4506-b809-38bfa1af9183	정산 관리	-	-	-	9
12705	36ec7463-2785-4506-b809-38bfa1af9183	정산 관리	예약 내역 확인	-	-	9
12706	36ec7463-2785-4506-b809-38bfa1af9183	정산 관리	예약 내역 확인	미용사별 예약 내역 조회	-	9
12707	36ec7463-2785-4506-b809-38bfa1af9183	정산 관리	정산 처리	-	-	9
12708	36ec7463-2785-4506-b809-38bfa1af9183	정산 관리	정산 처리	자동 정산	-	9
12709	36ec7463-2785-4506-b809-38bfa1af9183	정산 관리	정산 처리	수작업 정산	-	9
12710	36ec7463-2785-4506-b809-38bfa1af9183	SEO 최적화	-	-	-	10
12711	36ec7463-2785-4506-b809-38bfa1af9183	SEO 최적화	검색엔진 최적화 (SEO)	-	-	10
12712	36ec7463-2785-4506-b809-38bfa1af9183	SEO 최적화	검색엔진 최적화 (SEO)	네이버 SEO 연동	-	10
12713	36ec7463-2785-4506-b809-38bfa1af9183	SEO 최적화	검색엔진 최적화 (SEO)	카카오 SEO 연동	-	10
12714	36ec7463-2785-4506-b809-38bfa1af9183	SEO 최적화	검색엔진 최적화 (SEO)	구글 SEO 연동	-	10
12715	92748cdc-10c4-404f-b14c-fd3987ded5bc	로그인 & 가입	-	-	-	1
12716	92748cdc-10c4-404f-b14c-fd3987ded5bc	로그인 & 가입	회원가입	-	-	1
12717	92748cdc-10c4-404f-b14c-fd3987ded5bc	로그인 & 가입	회원가입	이메일 인증	-	1
12718	92748cdc-10c4-404f-b14c-fd3987ded5bc	로그인 & 가입	회원가입	휴대폰 인증	-	1
12719	92748cdc-10c4-404f-b14c-fd3987ded5bc	로그인 & 가입	로그인	-	-	1
12720	92748cdc-10c4-404f-b14c-fd3987ded5bc	로그인 & 가입	로그인	이메일 로그인	-	1
12721	92748cdc-10c4-404f-b14c-fd3987ded5bc	로그인 & 가입	로그인	소셜 로그인 (네이버, 카카오, 구글)	-	1
12722	92748cdc-10c4-404f-b14c-fd3987ded5bc	로그인 & 가입	비밀번호 찾기	-	-	1
12723	92748cdc-10c4-404f-b14c-fd3987ded5bc	결제하기	-	-	-	2
12724	92748cdc-10c4-404f-b14c-fd3987ded5bc	결제하기	결제 수단	-	-	2
12725	92748cdc-10c4-404f-b14c-fd3987ded5bc	결제하기	결제 수단	신용/체크 카드	-	2
12726	92748cdc-10c4-404f-b14c-fd3987ded5bc	결제하기	결제 수단	간편결제 (네이버페이, 카카오페이, 구글페이 등)	-	2
12727	92748cdc-10c4-404f-b14c-fd3987ded5bc	결제하기	결제 수단	무통장 입금	-	2
12728	92748cdc-10c4-404f-b14c-fd3987ded5bc	결제하기	결제 과정	-	-	2
12729	92748cdc-10c4-404f-b14c-fd3987ded5bc	결제하기	결제 과정	결제 정보 입력	-	2
12730	92748cdc-10c4-404f-b14c-fd3987ded5bc	결제하기	결제 과정	결제 확인 및 완료	-	2
12731	92748cdc-10c4-404f-b14c-fd3987ded5bc	결제하기	결제 내역 관리	-	-	2
12732	92748cdc-10c4-404f-b14c-fd3987ded5bc	별점 & 평가	-	-	-	3
12733	92748cdc-10c4-404f-b14c-fd3987ded5bc	별점 & 평가	후기 작성	-	-	3
12734	92748cdc-10c4-404f-b14c-fd3987ded5bc	별점 & 평가	후기 작성	텍스트 후기	-	3
12735	92748cdc-10c4-404f-b14c-fd3987ded5bc	별점 & 평가	후기 작성	이미지 후기	-	3
12736	92748cdc-10c4-404f-b14c-fd3987ded5bc	별점 & 평가	후기 작성	동영상 후기	-	3
12737	92748cdc-10c4-404f-b14c-fd3987ded5bc	별점 & 평가	별점 주기	-	-	3
12738	92748cdc-10c4-404f-b14c-fd3987ded5bc	별점 & 평가	별점 주기	1점부터 5점까지의 별점	-	3
12739	92748cdc-10c4-404f-b14c-fd3987ded5bc	별점 & 평가	후기 관리	-	-	3
12740	92748cdc-10c4-404f-b14c-fd3987ded5bc	별점 & 평가	후기 관리	후기 수정/삭제	-	3
12741	92748cdc-10c4-404f-b14c-fd3987ded5bc	회원 분류하기	-	-	-	4
12742	92748cdc-10c4-404f-b14c-fd3987ded5bc	회원 분류하기	단골 고객 등록	-	-	4
12743	92748cdc-10c4-404f-b14c-fd3987ded5bc	회원 분류하기	단골 고객 등록	일반 고객과 단골 고객 구분	-	4
12744	92748cdc-10c4-404f-b14c-fd3987ded5bc	회원 분류하기	단골 고객 혜택	-	-	4
12745	92748cdc-10c4-404f-b14c-fd3987ded5bc	회원 분류하기	단골 고객 혜택	단골 고객 전용 혜택 관리	-	4
12746	92748cdc-10c4-404f-b14c-fd3987ded5bc	알림 보내기	-	-	-	5
12747	92748cdc-10c4-404f-b14c-fd3987ded5bc	알림 보내기	카카오톡 알림	-	-	5
12748	92748cdc-10c4-404f-b14c-fd3987ded5bc	알림 보내기	이메일 알림	-	-	5
12749	92748cdc-10c4-404f-b14c-fd3987ded5bc	알림 보내기	SMS 알림	-	-	5
12750	92748cdc-10c4-404f-b14c-fd3987ded5bc	팔로우	-	-	-	6
12751	92748cdc-10c4-404f-b14c-fd3987ded5bc	팔로우	미용사 팔로우	-	-	6
12752	92748cdc-10c4-404f-b14c-fd3987ded5bc	팔로우	팔로우한 미용사 보기	-	-	6
12753	92748cdc-10c4-404f-b14c-fd3987ded5bc	검색	-	-	-	7
12754	92748cdc-10c4-404f-b14c-fd3987ded5bc	검색	미용사 검색	-	-	7
12755	92748cdc-10c4-404f-b14c-fd3987ded5bc	검색	미용사 검색	지역별 검색	-	7
12756	92748cdc-10c4-404f-b14c-fd3987ded5bc	검색	미용사 검색	조건별 검색 (예: 무게, 털의 종류와 상태 등)	-	7
12757	92748cdc-10c4-404f-b14c-fd3987ded5bc	검색	후기 검색	-	-	7
12758	92748cdc-10c4-404f-b14c-fd3987ded5bc	검색	후기 검색	텍스트 기반 검색	-	7
12759	92748cdc-10c4-404f-b14c-fd3987ded5bc	검색	예약 내역 검색	-	-	7
12760	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	-	-	-	8
12761	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 가능 미용사 보기	-	-	8
12762	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 가능 미용사 보기	지역별 미용사 보기	-	8
12763	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 가능 미용사 보기	미용사 일정 보기	-	8
12764	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 진행	-	-	8
12765	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 진행	예약 옵션 선택 (무게, 털의 종류와 상태, 특이사항 등)	-	8
12766	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 진행	예약 확인 및 완료	-	8
12767	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 진행	예약 취소	-	8
12768	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 알림	-	-	8
12769	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 알림	예약 확인 알림	-	8
12770	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 알림	예약 변경/취소 알림	-	8
12771	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 알림	예약 완료 알림	-	8
12772	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 관리	-	-	8
12773	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 관리	예약 내역 보기	-	8
12774	92748cdc-10c4-404f-b14c-fd3987ded5bc	예약하기	예약 관리	예약 내역 수정/취소	-	8
12775	92748cdc-10c4-404f-b14c-fd3987ded5bc	SEO 연동	-	-	-	9
12776	92748cdc-10c4-404f-b14c-fd3987ded5bc	SEO 연동	네이버 SEO	-	-	9
12777	92748cdc-10c4-404f-b14c-fd3987ded5bc	SEO 연동	네이버 SEO	메타 데이터 설정	-	9
12778	92748cdc-10c4-404f-b14c-fd3987ded5bc	SEO 연동	네이버 SEO	사이트맵 제출	-	9
12779	92748cdc-10c4-404f-b14c-fd3987ded5bc	SEO 연동	카카오 SEO	-	-	9
12780	92748cdc-10c4-404f-b14c-fd3987ded5bc	SEO 연동	카카오 SEO	메타 데이터 설정	-	9
12781	92748cdc-10c4-404f-b14c-fd3987ded5bc	SEO 연동	카카오 SEO	사이트맵 제출	-	9
12782	92748cdc-10c4-404f-b14c-fd3987ded5bc	SEO 연동	구글 SEO	-	-	9
12783	92748cdc-10c4-404f-b14c-fd3987ded5bc	SEO 연동	구글 SEO	메타 데이터 설정	-	9
12784	92748cdc-10c4-404f-b14c-fd3987ded5bc	SEO 연동	구글 SEO	사이트맵 제출	-	9
12785	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	-	-	-	10
12786	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	미용사 관리	-	-	10
12787	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	미용사 관리	미용사 등록	-	10
12788	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	미용사 관리	미용사 일정 관리	-	10
12789	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	예약 관리	-	-	10
12790	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	예약 관리	예약 내역 조회	-	10
12791	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	예약 관리	예약 내역 수정/취소	-	10
12792	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	결제 관리	-	-	10
12793	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	결제 관리	결제 내역 조회	-	10
12794	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	결제 관리	환불 처리	-	10
12795	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	정산 관리	-	-	10
12796	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	정산 관리	미용사별 수수료 정산	-	10
12797	92748cdc-10c4-404f-b14c-fd3987ded5bc	관리 시스템	정산 관리	정산 내역 조회	-	10
12798	92748cdc-10c4-404f-b14c-fd3987ded5bc	후기 시스템	-	-	-	11
12799	92748cdc-10c4-404f-b14c-fd3987ded5bc	후기 시스템	후기 작성	-	-	11
12800	92748cdc-10c4-404f-b14c-fd3987ded5bc	후기 시스템	후기 작성	후기 작성 권한 부여	-	11
12801	92748cdc-10c4-404f-b14c-fd3987ded5bc	후기 시스템	후기 관리	-	-	11
12802	92748cdc-10c4-404f-b14c-fd3987ded5bc	후기 시스템	후기 관리	후기 수정/삭제 권한 부여	-	11
12803	92748cdc-10c4-404f-b14c-fd3987ded5bc	UI/UX 디자인 최소화	-	-	-	12
12804	92748cdc-10c4-404f-b14c-fd3987ded5bc	UI/UX 디자인 최소화	이미지/동영상 최소화	-	-	12
12805	92748cdc-10c4-404f-b14c-fd3987ded5bc	UI/UX 디자인 최소화	간결한 인터페이스 제공	-	-	12
12806	92748cdc-10c4-404f-b14c-fd3987ded5bc	기본 기능	-	-	-	13
12807	92748cdc-10c4-404f-b14c-fd3987ded5bc	기본 기능	홈 화면 구성	-	-	13
12808	92748cdc-10c4-404f-b14c-fd3987ded5bc	기본 기능	홈 화면 구성	주요 기능 바로가기	-	13
12809	92748cdc-10c4-404f-b14c-fd3987ded5bc	기본 기능	사용자 프로필 관리	-	-	13
12810	92748cdc-10c4-404f-b14c-fd3987ded5bc	기본 기능	사용자 프로필 관리	프로필 정보 수정	-	13
12811	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	결제하기	-	-	-	1
12812	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	결제하기	예약 결제	-	-	1
12813	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	결제하기	예약 결제	결제 수단 선택	-	1
12814	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	결제하기	예약 결제	결제 수단 선택	신용카드	1
12815	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	결제하기	예약 결제	결제 수단 선택	계좌이체	1
12816	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	결제하기	예약 결제	결제 수단 선택	간편결제 (네이버 페이, 카카오페이 등)	1
12817	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	결제하기	예약 결제	결제 상태 확인	-	1
12818	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	결제하기	예약 결제	결제 영수증 발행	-	1
12819	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	로그인 & 가입	-	-	-	2
12820	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	로그인 & 가입	회원가입	-	-	2
12821	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	로그인 & 가입	회원가입	이메일 인증	-	2
12822	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	로그인 & 가입	회원가입	휴대폰 인증	-	2
12823	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	로그인 & 가입	로그인	-	-	2
12824	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	로그인 & 가입	로그인	이메일 로그인	-	2
12825	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	로그인 & 가입	로그인	소셜 로그인 (네이버, 카카오, 구글)	-	2
12826	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	로그인 & 가입	비밀번호 찾기	-	-	2
12827	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	로그인 & 가입	비밀번호 찾기	이메일 인증	-	2
12828	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	로그인 & 가입	비밀번호 찾기	휴대폰 인증	-	2
12829	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	별점 & 평가	-	-	-	3
12830	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	별점 & 평가	후기 작성	-	-	3
12831	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	별점 & 평가	후기 작성	텍스트 후기	-	3
12832	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	별점 & 평가	후기 작성	이미지 후기	-	3
12833	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	별점 & 평가	후기 작성	동영상 후기	-	3
12834	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	별점 & 평가	후기 작성	미용사 평가 (1-5점)	-	3
12835	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	별점 & 평가	후기 평가	-	-	3
12836	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	별점 & 평가	후기 평가	댓글 달기	-	3
12837	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	별점 & 평가	후기 평가	좋아요	-	3
12838	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	별점 & 평가	후기 평가	이모티콘	-	3
12839	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	회원 분류하기	-	-	-	4
12840	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	회원 분류하기	일반 회원	-	-	4
12841	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	회원 분류하기	단골 고객	-	-	4
12842	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	회원 분류하기	단골 고객	단골 등록	-	4
12843	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	회원 분류하기	단골 고객	단골 혜택	-	4
12844	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	회원 분류하기	단골 고객	단골 해제	-	4
12845	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	-	-	-	5
12846	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	예약 관련 알림	-	-	5
12847	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	예약 관련 알림	예약 확인 알림	-	5
12848	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	예약 관련 알림	예약 취소 알림	-	5
12849	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	예약 관련 알림	예약 변경 알림	-	5
12850	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	예약 관련 알림	예약 완료 알림	-	5
12851	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	결제 관련 알림	-	-	5
12852	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	결제 관련 알림	결제 확인 알림	-	5
12853	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	결제 관련 알림	결제 실패 알림	-	5
12854	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	기타 알림	-	-	5
12855	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	기타 알림	프로모션 알림	-	5
12856	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	알림 보내기	기타 알림	미용사 평가 알림	-	5
12857	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	팔로우	-	-	-	6
12858	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	팔로우	미용사 팔로우	-	-	6
12859	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	팔로우	미용사 팔로우	팔로우 추가	-	6
12860	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	팔로우	미용사 팔로우	팔로우 해제	-	6
12861	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	팔로우	팔로우 관리	-	-	6
12862	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	팔로우	팔로우 관리	팔로잉 목록	-	6
12863	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	팔로우	팔로우 관리	팔로워 목록	-	6
12864	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	검색	-	-	-	7
12865	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	검색	미용사 검색	-	-	7
12866	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	검색	미용사 검색	지역별 검색	-	7
12867	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	검색	미용사 검색	일정별 검색	-	7
12868	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	검색	후속 검색	-	-	7
12869	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	검색	후속 검색	미용사 이름 검색	-	7
12870	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	검색	후속 검색	미용 후기 검색	-	7
12871	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	-	-	-	8
12872	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	예약 생성	-	-	8
12873	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	예약 생성	미용사 선택	-	8
12874	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	예약 생성	날짜 및 시간 선택	-	8
12875	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	예약 생성	예약 옵션 선택	-	8
12876	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	예약 생성	예약 옵션 선택	반려동물 무게	8
12877	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	예약 생성	예약 옵션 선택	털의 종류와 상태	8
12878	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	예약 생성	예약 옵션 선택	특이사항	8
12879	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	예약 변경	-	-	8
12880	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	예약 취소	-	-	8
12881	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	예약 확인	-	-	8
12882	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	예약하기	예약 확인	예약 내역 조회	-	8
12883	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	관리자 기능	-	-	-	9
12884	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	관리자 기능	미용사 등록	-	-	9
12885	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	관리자 기능	미용사 등록	미용사 정보 입력	-	9
12886	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	관리자 기능	미용사 등록	온오프 면접 관리	-	9
12887	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	관리자 기능	예약 관리	-	-	9
12888	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	관리자 기능	예약 관리	예약 현황 조회	-	9
12889	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	관리자 기능	예약 관리	예약 취소 및 변경 요청 처리	-	9
12890	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	관리자 기능	정산 관리	-	-	9
12891	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	관리자 기능	정산 관리	정산 내역 조회	-	9
12892	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	관리자 기능	정산 관리	자동 정산 시스템	-	9
12893	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	관리자 기능	정산 관리	수기 정산 옵션	-	9
12894	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	SEO 최적화	-	-	-	10
12895	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	SEO 최적화	네이버 SEO	-	-	10
12896	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	SEO 최적화	카카오 SEO	-	-	10
12897	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	SEO 최적화	구글 SEO	-	-	10
12952	f8be9551-9680-445d-b79e-a6cd4b34e861	결제하기	-	-	-	1
12953	f8be9551-9680-445d-b79e-a6cd4b34e861	결제하기	결제 방법 선택	-	-	1
12954	f8be9551-9680-445d-b79e-a6cd4b34e861	결제하기	결제 방법 선택	신용카드 결제	-	1
12955	f8be9551-9680-445d-b79e-a6cd4b34e861	결제하기	결제 방법 선택	은행 계좌 이체	-	1
12956	f8be9551-9680-445d-b79e-a6cd4b34e861	결제하기	결제 방법 선택	전자 지갑 결제	-	1
12957	f8be9551-9680-445d-b79e-a6cd4b34e861	결제하기	결제 내역 확인	-	-	1
12958	f8be9551-9680-445d-b79e-a6cd4b34e861	결제하기	결제 내역 확인	거래 내역 리스트	-	1
12959	f8be9551-9680-445d-b79e-a6cd4b34e861	결제하기	결제 내역 확인	명세서 다운로드	-	1
12960	f8be9551-9680-445d-b79e-a6cd4b34e861	결제하기	결제 확인	-	-	1
12961	f8be9551-9680-445d-b79e-a6cd4b34e861	결제하기	결제 확인	실시간 결제 확인	-	1
12962	f8be9551-9680-445d-b79e-a6cd4b34e861	결제하기	결제 확인	이메일/문자 알림	-	1
12963	f8be9551-9680-445d-b79e-a6cd4b34e861	로그인 & 가입	-	-	-	2
12964	f8be9551-9680-445d-b79e-a6cd4b34e861	로그인 & 가입	회원가입	-	-	2
12965	f8be9551-9680-445d-b79e-a6cd4b34e861	로그인 & 가입	회원가입	이메일 인증	-	2
12966	f8be9551-9680-445d-b79e-a6cd4b34e861	로그인 & 가입	회원가입	휴대폰 인증	-	2
12967	f8be9551-9680-445d-b79e-a6cd4b34e861	로그인 & 가입	로그인	-	-	2
12968	f8be9551-9680-445d-b79e-a6cd4b34e861	로그인 & 가입	로그인	이메일 로그인	-	2
12969	f8be9551-9680-445d-b79e-a6cd4b34e861	로그인 & 가입	로그인	소셜 로그인	-	2
12970	f8be9551-9680-445d-b79e-a6cd4b34e861	로그인 & 가입	비밀번호 재설정	-	-	2
12971	f8be9551-9680-445d-b79e-a6cd4b34e861	로그인 & 가입	비밀번호 재설정	이메일을 통한 재설정 링크 발송	-	2
12972	f8be9551-9680-445d-b79e-a6cd4b34e861	로그인 & 가입	비밀번호 재설정	새로운 비밀번호 설정	-	2
12973	f8be9551-9680-445d-b79e-a6cd4b34e861	주문 관리	-	-	-	3
12974	f8be9551-9680-445d-b79e-a6cd4b34e861	주문 관리	주문 내역 조회	-	-	3
12975	f8be9551-9680-445d-b79e-a6cd4b34e861	주문 관리	주문 내역 조회	주문 상태 확인	-	3
12976	f8be9551-9680-445d-b79e-a6cd4b34e861	주문 관리	주문 내역 조회	상세 주문 내역 열람	-	3
12977	f8be9551-9680-445d-b79e-a6cd4b34e861	주문 관리	주문 변경 및 취소	-	-	3
12978	f8be9551-9680-445d-b79e-a6cd4b34e861	주문 관리	주문 변경 및 취소	주문 내역 변경	-	3
12979	f8be9551-9680-445d-b79e-a6cd4b34e861	주문 관리	주문 변경 및 취소	주문 취소 신청	-	3
12980	f8be9551-9680-445d-b79e-a6cd4b34e861	주문 관리	주문 알림	-	-	3
12981	f8be9551-9680-445d-b79e-a6cd4b34e861	주문 관리	주문 알림	주문 확인 알림	-	3
12982	f8be9551-9680-445d-b79e-a6cd4b34e861	주문 관리	주문 알림	배송 시작 알림	-	3
12983	f8be9551-9680-445d-b79e-a6cd4b34e861	검색	-	-	-	4
12984	f8be9551-9680-445d-b79e-a6cd4b34e861	검색	기본 검색	-	-	4
12985	f8be9551-9680-445d-b79e-a6cd4b34e861	검색	기본 검색	키워드 검색	-	4
12986	f8be9551-9680-445d-b79e-a6cd4b34e861	검색	기본 검색	필터 적용	-	4
12987	f8be9551-9680-445d-b79e-a6cd4b34e861	검색	기본 검색	필터 적용	카테고리별 필터	4
12988	f8be9551-9680-445d-b79e-a6cd4b34e861	검색	기본 검색	필터 적용	가격별 필터	4
12989	f8be9551-9680-445d-b79e-a6cd4b34e861	검색	고급 검색	-	-	4
12990	f8be9551-9680-445d-b79e-a6cd4b34e861	검색	고급 검색	다중 조건 검색	-	4
12991	f8be9551-9680-445d-b79e-a6cd4b34e861	검색	고급 검색	검색 결과 정렬	-	4
12992	f8be9551-9680-445d-b79e-a6cd4b34e861	검색	고급 검색	검색 결과 정렬	최신순 정렬	4
12993	f8be9551-9680-445d-b79e-a6cd4b34e861	검색	고급 검색	검색 결과 정렬	인기순 정렬	4
12994	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	-	-	-	1
12995	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	결제 수단 선택	-	-	1
12996	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	결제 수단 선택	신용카드	-	1
12997	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	결제 수단 선택	은행 계좌	-	1
12998	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	결제 수단 선택	모바일 결제	-	1
12999	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	결제 정보 입력	-	-	1
13000	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	결제 정보 입력	카드 번호 입력	-	1
13001	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	결제 정보 입력	유효 기간 입력	-	1
13002	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	결제 정보 입력	CVC 코드 입력	-	1
13003	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	결제 확인	-	-	1
13004	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	결제 확인	주문 내역 확인	-	1
13005	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	결제 확인	결제 금액 확인	-	1
13006	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	영수증 발행	-	-	1
13007	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	영수증 발행	이메일로 영수증 발급	-	1
13008	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제하기	영수증 발행	PDF 형태로 다운로드	-	1
13009	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	-	-	-	2
13010	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	회원가입	-	-	2
13071	5893b347-d8e5-4ed9-8174-e454836ceecb	채팅	1:1 채팅	-	-	5
13072	5893b347-d8e5-4ed9-8174-e454836ceecb	채팅	1:1 채팅	텍스트 메시지	-	5
13073	5893b347-d8e5-4ed9-8174-e454836ceecb	채팅	1:1 채팅	이미지 전송	-	5
13074	5893b347-d8e5-4ed9-8174-e454836ceecb	채팅	1:1 채팅	파일 전송	-	5
13075	5893b347-d8e5-4ed9-8174-e454836ceecb	채팅	그룹 채팅	-	-	5
13011	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	회원가입	이메일 회원가입	-	2
13012	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	회원가입	이메일 회원가입	이메일 인증	2
13013	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	회원가입	이메일 회원가입	비밀번호 설정	2
13014	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	회원가입	소셜 회원가입	-	2
13015	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	회원가입	소셜 회원가입	구글 계정으로 가입	2
13016	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	회원가입	소셜 회원가입	페이스북 계정으로 가입	2
13017	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	로그인	-	-	2
13018	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	로그인	이메일 로그인	-	2
13019	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	로그인	이메일 로그인	이메일 주소 입력	2
13020	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	로그인	이메일 로그인	비밀번호 입력	2
13021	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	로그인	소셜 로그인	-	2
13022	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	로그인	소셜 로그인	구글 계정으로 로그인	2
13023	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	로그인	소셜 로그인	페이스북 계정으로 로그인	2
13024	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	비밀번호 재설정	-	-	2
13025	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	비밀번호 재설정	비밀번호 재설정 요청	-	2
13026	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	비밀번호 재설정	비밀번호 재설정 요청	이메일 주소 입력	2
13027	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	비밀번호 재설정	비밀번호 재설정 요청	인증 코드 발송	2
13028	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	비밀번호 재설정	비밀번호 재설정	-	2
13029	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	비밀번호 재설정	비밀번호 재설정	새 비밀번호 입력	2
13030	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입	비밀번호 재설정	비밀번호 재설정	비밀번호 재입력	2
13031	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	-	-	-	1
13032	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	결제 방법 선택	-	-	1
13033	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	결제 방법 선택	신용카드	-	1
13034	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	결제 방법 선택	은행 계좌 이체	-	1
13035	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	결제 방법 선택	간편결제 (예: 카카오페이, 네이버페이)	-	1
13036	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	결제 정보 입력	-	-	1
13037	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	결제 정보 입력	카드 정보 입력	-	1
13038	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	결제 정보 입력	계좌 정보 입력	-	1
13039	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	결제 정보 입력	간편결제 계정 연동	-	1
13040	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	결제 확인 및 완료	-	-	1
13041	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	결제 확인 및 완료	결제 내역 확인	-	1
13042	5893b347-d8e5-4ed9-8174-e454836ceecb	결제하기	결제 확인 및 완료	결제 완료 알림	-	1
13043	5893b347-d8e5-4ed9-8174-e454836ceecb	로그인 & 가입	-	-	-	2
13044	5893b347-d8e5-4ed9-8174-e454836ceecb	로그인 & 가입	로그인	-	-	2
13045	5893b347-d8e5-4ed9-8174-e454836ceecb	로그인 & 가입	로그인	이메일 로그인	-	2
13046	5893b347-d8e5-4ed9-8174-e454836ceecb	로그인 & 가입	로그인	소셜 로그인 (예: 페이스북, 구글)	-	2
13047	5893b347-d8e5-4ed9-8174-e454836ceecb	로그인 & 가입	회원가입	-	-	2
13048	5893b347-d8e5-4ed9-8174-e454836ceecb	로그인 & 가입	회원가입	이메일 회원가입	-	2
13049	5893b347-d8e5-4ed9-8174-e454836ceecb	로그인 & 가입	회원가입	소셜 계정 회원가입	-	2
13050	5893b347-d8e5-4ed9-8174-e454836ceecb	로그인 & 가입	비밀번호 재설정	-	-	2
13051	5893b347-d8e5-4ed9-8174-e454836ceecb	로그인 & 가입	비밀번호 재설정	비밀번호 찾기	-	2
13052	5893b347-d8e5-4ed9-8174-e454836ceecb	로그인 & 가입	비밀번호 재설정	비밀번호 변경	-	2
13053	5893b347-d8e5-4ed9-8174-e454836ceecb	별점 & 평가	-	-	-	3
13054	5893b347-d8e5-4ed9-8174-e454836ceecb	별점 & 평가	별점 주기	-	-	3
13055	5893b347-d8e5-4ed9-8174-e454836ceecb	별점 & 평가	별점 주기	5점 만점 별점 주기	-	3
13056	5893b347-d8e5-4ed9-8174-e454836ceecb	별점 & 평가	리뷰 작성	-	-	3
13057	5893b347-d8e5-4ed9-8174-e454836ceecb	별점 & 평가	리뷰 작성	텍스트 리뷰 작성	-	3
13058	5893b347-d8e5-4ed9-8174-e454836ceecb	별점 & 평가	리뷰 작성	사진 첨부 리뷰	-	3
13059	5893b347-d8e5-4ed9-8174-e454836ceecb	별점 & 평가	리뷰 관리	-	-	3
13060	5893b347-d8e5-4ed9-8174-e454836ceecb	별점 & 평가	리뷰 관리	리뷰 삭제	-	3
13061	5893b347-d8e5-4ed9-8174-e454836ceecb	별점 & 평가	리뷰 관리	리뷰 수정	-	3
13062	5893b347-d8e5-4ed9-8174-e454836ceecb	회원 분류하기	-	-	-	4
13063	5893b347-d8e5-4ed9-8174-e454836ceecb	회원 분류하기	회원 등급 설정	-	-	4
13064	5893b347-d8e5-4ed9-8174-e454836ceecb	회원 분류하기	회원 등급 설정	일반 회원	-	4
13065	5893b347-d8e5-4ed9-8174-e454836ceecb	회원 분류하기	회원 등급 설정	프리미엄 회원	-	4
13066	5893b347-d8e5-4ed9-8174-e454836ceecb	회원 분류하기	회원 등급 설정	관리자	-	4
13067	5893b347-d8e5-4ed9-8174-e454836ceecb	회원 분류하기	회원 권한 관리	-	-	4
13068	5893b347-d8e5-4ed9-8174-e454836ceecb	회원 분류하기	회원 권한 관리	접근 권한 설정	-	4
13069	5893b347-d8e5-4ed9-8174-e454836ceecb	회원 분류하기	회원 권한 관리	권한 변경	-	4
13076	5893b347-d8e5-4ed9-8174-e454836ceecb	채팅	그룹 채팅	그룹 생성	-	5
13077	5893b347-d8e5-4ed9-8174-e454836ceecb	채팅	그룹 채팅	그룹 초대	-	5
13078	5893b347-d8e5-4ed9-8174-e454836ceecb	채팅	그룹 채팅	그룹 메시지	-	5
\.


--
-- Data for Name: payment_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_history (payment_history_id, user_id, date, plan, amount, method, status, receipt_url) FROM stdin;
7	fkaus4169	2024-06-01	건별 플랜	990	카드	성공	http://example.com/receipt/1
8	fkaus4169	2024-07-01	단기 플랜	4900	카드	성공	http://example.com/receipt/2
9	fkaus4169	2024-08-01	정기 플랜	49000	카드	성공	http://example.com/receipt/3
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (payment_id, user_id, subscription_id, payment_date, amount, status) FROM stdin;
\.


--
-- Data for Name: rfp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rfp (rfp_seq, pro_name, pro_period, pro_budget, pro_service, pro_output, pro_reference, pro_ia, pro_wbs, user_session, expected_budget, expected_period, pro_agency, user_id, pro_funcdesc, wbs_doc) FROM stdin;
353	프로메테우스	5개월	5000	- 결제하기\n- 로그인 & 가입\n- 별점 & 평가\n- 회원 분류하기\n- 알림 보내기\n- 매칭\n- 팔로우\n- 검색\n- 리뷰 및 평가 관리 시스템\n- 예약하기	- 요구사항 명세서\n- 시스템 아키텍처 다이어그램\n- 데이터베이스 설계 문서\n- 예약 및 결제 시스템 개발\n- 사용자 로그인 및 회원 관리 시스템 개발\n- 온오프 면접 및 미용사 등록 시스템 개발\n- 미용사 스케줄 관리 및 매칭 시스템 개발\n- 리뷰 및 평점 시스템 개발\n- 알림 및 통지 시스템 개발\n- SEO 최적화 및 연동 설정 문서	www.petshop.com	6d6cd042-eca4-46b2-af20-8c88433638af	6d6cd042-eca4-46b2-af20-8c88433638af	6d6cd042-eca4-46b2-af20-8c88433638af	3000	3	웹 개발	fkaus4169	1. 예약하기\n   1.1. 미용사 선택\n     1.1.1. 인구 대비 미용사 수 배치\n     1.1.2. 거리 기반 미용사 매칭\n   1.2. 일정 예약\n     1.2.1. 미용사 일정 확인\n     1.2.2. 예약 시간 선택\n     1.2.3. 예약 옵션 선택\n       1.2.3.1. 반려동물 무게\n       1.2.3.2. 털의 종류와 상태\n       1.2.3.3. 특이사항\n   1.3. 결제하기\n     1.3.1. 결제 수단 선택\n     1.3.2. 결제 정보 입력\n     1.3.3. 결제 확인 및 완료\n   1.4. 예약 확인 및 전달\n     1.4.1. 예약 정보 카카오톡 전달\n     1.4.2. 미용사와 고객에게 예약 확인\n\n2. 로그인 & 가입\n   2.1. 회원가입\n     2.1.1. 이메일 가입\n     2.1.2. 네이버, 카카오, 구글 소셜 가입\n   2.2. 로그인\n     2.2.1. 아이디/비밀번호 로그인\n     2.2.2. 소셜 로그인 (네이버, 카카오, 구글)\n\n3. 별점 & 평가\n   3.1. 후기 작성\n     3.1.1. 글 작성\n     3.1.2. 이미지 업로드\n     3.1.3. 동영상 업로드\n     3.1.4. 미용사 칭찬점수 (1~5)\n   3.2. 후기 관리\n     3.2.1. 후기 댓글\n     3.2.2. 좋아요\n     3.2.3. 이모티콘 추가\n\n4. 회원 분류하기\n   4.1. 기본 회원\n   4.2. 단골 고객 등록\n     4.2.1. 단골 고객 등록 옵션\n     4.2.2. 단골 고객 관리\n\n5. 알림 보내기\n   5.1. 예약 알림\n     5.1.1. 예약 완료 알림\n     5.1.2. 예약 취소 알림\n   5.2. 후속 알림\n     5.2.1. 예약 임박 알림\n     5.2.2. 후기 작성 요청 알림\n\n6. 매칭\n   6.1. 고객-미용사 매칭\n     6.1.1. 거리 기반 매칭\n     6.1.2. 일정 기반 매칭\n\n7. 팔로우\n   7.1. 단골 미용사 팔로우\n     7.1.1. 팔로우/언팔로우 기능\n     7.1.2. 팔로우한 미용사 목록\n\n8. 검색\n   8.1. 미용사 검색\n     8.1.1. 이름 검색\n     8.1.2. 지역 검색\n     8.1.3. 예약 가능 시간대 검색\n\n9. 주문 관리\n   9.1. 예약 취소\n     9.1.1. 고객 예약 취소\n     9.1.2. 미용사 예약 취소\n     9.1.3. 취소 알림\n   9.2. 환불 처리\n     9.2.1. 수기 환불 처리\n     9.2.2. 자동화 환불 처리 (옵션)\n\n10. SEO 자동 연동\n   10.1. 네이버 SEO\n   10.2. 카카오 SEO\n   10.3. 구글 SEO	- 기획 및 조사 팀(기획자, 데이터 분석가): 0~0.5개월\n- 디자인 팀(UI/UX 디자이너): 0.5~1.5개월\n- 프론트엔드 개발자: 1.5~3.5개월\n- 백엔드 개발자: 1.5~3.5개월\n- 결제 시스템 개발자: 2~3개월\n- QA 엔지니어: 3.5~4.5개월\n- SEO 전문가: 3.5~4개월\n- 마케팅 팀(SEO/디지털 마케터): 4~5개월
359	피피	4개월	4000	- 온라인 결제 기능\n- 로그인 및 회원가입 기능\n- 별점 및 평가 기능\n- 알림 전송 기능\n- 팔로우 기능\n- 채팅 기능\n- 회원 분류 및 관리 기능\n- 예약 및 취소 기능\n- 예약 옵션 설정 기능\n- 후기 및 댓글 기능	- 프로젝트 기획서\n- 앱 및 웹 화면 설계서(UI/UX 디자인)\n- 반려동물 미용사 등록 및 관리 시스템 개발\n- 고객 예약 및 결제 시스템 개발\n- 로그인 및 가입 시스템 개발 (소셜 로그인 포함)\n- 후기 및 평가 시스템 개발\n- 알림 및 통지 시스템 개발 (카카오톡 연동 포함)\n- 메인 페이지 및 단골고객 관리 기능 개발\n- 시스템 통합 테스트 계획서\n- SEO 최적화 구현 및 테스트	\N	d388d19c-d16b-4b44-af17-d41b88b26d5b	d388d19c-d16b-4b44-af17-d41b88b26d5b	d388d19c-d16b-4b44-af17-d41b88b26d5b	4000	4	앱 개발/웹 개발	fkaus4169	1. 회원 시스템\n   1.1. 회원가입 및 로그인\n       1.1.1. 일반 회원가입\n           1.1.1.1. 이메일 인증\n           1.1.1.2. 비밀번호 생성 및 확인\n       1.1.2. 소셜 로그인\n           1.1.2.1. 네이버 로그인\n           1.1.2.2. 카카오 로그인\n           1.1.2.3. 구글 로그인\n   1.2. 회원 분류\n       1.2.1. 미용사 등록\n           1.2.1.1. 온오프면접을 통한 등록\n           1.2.1.2. 지자체 읍면동 인구비율에 따른 미용사 분류\n       1.2.2. 고객 등록\n           1.2.2.1. 단골 고객 등록 옵션\n\n2. 예약 시스템\n   2.1. 예약 생성\n       2.1.1. 미용사 선택\n           2.1.1.1. 거리 기반 미용사 선택\n           2.1.1.2. 미용사 일정 확인\n       2.1.2. 예약 옵션 설정\n           2.1.2.1. 반려동물 무게\n           2.1.2.2. 털의 종류와 상태\n           2.1.2.3. 특이사항\n   2.2. 예약 결제\n       2.2.1. 온라인 결제\n           2.2.1.1. 카드 결제\n           2.2.1.2. 계좌이체\n           2.2.1.3. 기타 결제 방식\n       2.2.2. 결제 완료 알림\n           2.2.2.1. 미용사에게 알림\n           2.2.2.2. 예약고객에게 알림\n   2.3. 예약 취소 및 환불\n       2.3.1. 미용사 취소\n           2.3.1.1. 취소 알림\n           2.3.1.2. 환불 처리\n       2.3.2. 고객 취소\n           2.3.2.1. 취소 알림\n           2.3.2.2. 환불 처리\n\n3. 리뷰 및 평가\n   3.1. 리뷰 작성\n       3.1.1. 글 작성\n       3.1.2. 이미지 업로드\n       3.1.3. 동영상 업로드\n       3.1.4. 미용사 칭찬점수(1~5점)\n   3.2. 리뷰 상호작용\n       3.2.1. 댓글 작성\n       3.2.2. 좋아요\n       3.2.3. 이모티콘 추가\n\n4. 알림 시스템\n   4.1. 예약 알림\n       4.1.1. 예약 완료 알림\n       4.1.2. 예약 취소 알림\n   4.2. 일반 알림\n       4.2.1. 정산 알림\n       4.2.2. 프로모션 및 이벤트 알림\n\n5. 커뮤니케이션 시스템\n   5.1. 채팅\n       5.1.1. 예약 고객과 미용사 간 채팅\n   5.2. 예약 관련 알림\n       5.2.1. 카카오톡 알림\n\n6. 결제 및 정산 시스템\n   6.1. 결제 처리\n       6.1.1. 자동 결제 처리\n       6.1.2. 수동 결제 처리(복잡한 경우)\n   6.2. 미용사와의 정산\n       6.2.1. 수작업 정산\n       6.2.2. 자동 정산 옵션(추가 가능 시)\n\n7. 콘텐츠 관리\n   7.1. 홈 화면 구성\n       7.1.1. 주요 서비스 소개\n       7.1.2. 예약 홍보 콘텐츠\n   7.2. 후기 및 리뷰 콘텐츠\n       7.2.1. 고객 후기\n       7.2.2. 리뷰 댓글\n\n8. 검색 엔진 최적화(SEO)\n   8.1. 자동 연동\n       8.1.1. 네이버 SEO\n       8.1.2. 카카오 SEO\n       8.1.3. 구글 SEO\n\n9. 단골 관리\n   9.1. 단골 고객 등록\n       9.1.1. 미용사 즐겨찾기\n       9.1.2. 리뷰 작성 권한\n\n이 기능명세서를 바탕으로 프로젝트를 진행하시면 됩니다. 추가적인 문의 사항이 있으시면 언제든지 말씀해 주세요.	- 기획 팀(프로젝트 매니저, 비즈니스 분석가): 0~0.5개월\n- 디자인 팀(UI/UX 디자이너): 0.5~1개월\n- 프론트엔드 개발자: 1~2.5개월\n- 백엔드 개발자: 1~2.5개월\n- 데이터베이스 관리자: 2~2.5개월\n- QA 엔지니어: 2.5~3개월\n- 마케팅 팀(SEO 전문가, 콘텐츠 마케터): 3~3.5개월\n- IT 지원 팀(유지보수): 3.5~4개월
355	프프	6개월	4000	- 온라인 결제 시스템 구축\n- 사용자 로그인 및 회원가입 기능 구현\n- 별점 및 평가 시스템 제공\n- 회원 분류 관리 기능 제공\n- 미용사 예약 관리 시스템\n- 알림 전송 기능 (카카오톡 연동 포함)\n- 서비스 매칭 시스템 (사용자와 미용사)\n- 팔로우 기능 (단골고객 등록)\n- 검색 기능 (미용사 및 예약 가능 시간)\n- 예약 시스템 내 다양한 옵션 선택 기능 (무게, 털의 종류와 상태 등)	- 프로젝트 계획서\n- 기능 명세서\n- ERD(엔터티 관계 다이어그램)\n- UI/UX 디자인 목업\n- 백엔드 아키텍처 설계서\n- 프런트엔드 아키텍처 설계서\n- 테스트 시나리오 및 계획\n- 사용자 매뉴얼\n- SEO 설정 문서\n- 결제 시스템 연동 가이드	www.petshop.com	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	3000	3	앱 개발/웹 개발	fkaus4169	1. 로그인 & 회원관리\n  1.1. 회원가입\n    1.1.1. 이메일 인증\n    1.1.2. SNS 로그인 (네이버, 카카오, 구글)\n  1.2. 로그인\n  1.3. 회원 분류하기\n    1.3.1. 미용사\n      1.3.1.1. 개인 일정 관리\n    1.3.2. 일반 고객\n  1.4. 단골고객 등록\n    1.4.1. 후기 남기기\n    1.4.2. 글, 이미지, 동영상 첨부\n    1.4.3. 미용사 칭찬점수 (1~5)\n    1.4.4. 후기 댓글, 좋아요, 이모티콘 추가\n\n2. 예약하기\n  2.1. 예약 설정\n    2.1.1. 미용사 선택\n    2.1.2. 일정 선택\n    2.1.3. 옵션 선택 (무게, 털의 종류와 상태, 특이사항 등)\n  2.2. 결제하기\n    2.2.1. 온라인 결제 방식 지원\n  2.3. 알림 보내기\n    2.3.1. 예약 완료 알림 (카톡 자동 전달)\n    2.3.2. 예약 취소 알림\n\n3. 평가 & 리뷰 관리\n  3.1. 별점 & 평가\n    3.1.1. 고객 후기에 별점 추가\n    3.1.2. 후기 댓글, 좋아요, 이모티콘 추가\n\n4. 검색 기능\n  4.1. 미용사 검색\n    4.1.1. 위치 기반 검색\n    4.1.2. 평점 및 후기 기반 검색\n\n5. 매칭 시스템\n  5.1. 위치 기반 매칭\n    5.1.1. 방문이 용이한 거리상의 미용사 매칭\n  5.2. 시장 규모 맞춤형 매칭\n    5.2.1. 지자체 읍면동 인구대비 매칭\n\n6. 알림 관리\n  6.1. 예약 알림\n  6.2. 취소 알림\n\n7. 예약 관리\n  7.1. 예약 취소\n  7.2. 예약 환불 처리\n\n8. 기타 기능\n  8.1. 콘텐츠 관리\n    8.1.1. 글\n    8.1.2. 이미지\n    8.1.3. 동영상\n  8.2. SEO 최적화\n    8.2.1. 네이버 연동\n    8.2.2. 카카오 연동\n    8.2.3. 구글 연동	- 프로젝트 매니저: 0~6개월\n- 분석/설계 팀(비즈니스 분석가, 시스템 설계자): 0~1개월\n- UI/UX 디자이너: 1~2개월\n- 프론트엔드 개발자: 2~4개월\n- 백엔드 개발자: 2~4개월\n- 데이터베이스 관리자(DBA): 2~4개월\n- 결제 시스템 개발자: 3~4개월\n- QA 엔지니어(테스터): 4~5개월\n- 마케팅 팀(SEO 전문가): 4~6개월\n- 유지보수/IT 지원 팀: 5~6개월
358	이이	4개월	4000만원	- 온라인 결제 기능 구현\n- 로그인 및 회원가입 기능 구축\n- 별점 및 평가 시스템 개발\n- 회원 분류 기능 추가\n- 알림 기능 설정\n- 검색 기능 도입\n- 예약 시스템 구현\n- 그룹 분류 및 관리 기능 추가\n- 후기 및 댓글 시스템 구축\n- SEO 자동 연동 기능 구현	- 기능 명세서\n- 데이터베이스 설계서\n- API 설계서\n- 결제 시스템 구축 계획서\n- 예약 및 일정 관리 시스템 구축 계획서\n- 사용자 및 미용사 관리 시스템 설계문서\n- 알림(카톡) 전송 시스템 구축 계획서\n- 사용자 및 미용사 별점 및 후기에 대한 관리 시스템 설계문서\n- SEO 최적화 계획서\n- 프로젝트 통합 테스트 계획서	www.pet	0ea08000-110f-44ee-957d-9fb75fb6f685	0ea08000-110f-44ee-957d-9fb75fb6f685	0ea08000-110f-44ee-957d-9fb75fb6f685	4000	4	앱 개발/웹 개발	fkaus4169	1. 예약하기\n1.1. 예약 신청\n1.1.1. 미용사 선택\n1.1.2. 방문 거리 설정\n1.1.3. 예약 날짜 및 시간 선택\n1.1.4. 예약 옵션 선택\n1.1.4.1. 반려동물 무게\n1.1.4.2. 털의 종류와 상태\n1.1.4.3. 특이사항 입력\n1.1.5. 예약 결제\n1.1.5.1. 결제 수단 선택\n1.1.5.2. 결제 완료 및 확인\n\n1.2. 예약 관리\n1.2.1. 예약 확인\n1.2.2. 예약 취소\n1.2.2.1. 예약 취소 사유 입력\n1.2.2.2. 환불 처리\n1.2.3. 예약 일정 수정\n\n1.3. 예약 알림\n1.3.1. 카카오톡 예약 알림\n1.3.2. 이메일 예약 알림\n1.3.3. 문자 예약 알림\n\n2. 로그인 & 가입\n2.1. 회원가입\n2.1.1. 이메일 가입\n2.1.2. 소셜 로그인\n2.1.2.1. 네이버 로그인\n2.1.2.2. 카카오 로그인\n2.1.2.3. 구글 로그인\n\n2.2. 로그인\n2.2.1. 이메일 로그인\n2.2.2. 소셜 로그인\n\n2.3. 비밀번호 재설정\n\n3. 별점 & 평가\n3.1. 후기 작성\n3.1.1. 글 후기 작성\n3.1.2. 이미지 & 동영상 후기 업로드\n3.1.3. 미용사 칭찬 점수(1~5) 작성\n\n3.2. 후기 관리\n3.2.1. 후기 수정\n3.2.2. 후기 삭제\n\n3.3. 후기 반응\n3.3.1. 댓글 작성\n3.3.2. 좋아요 클릭\n3.3.3. 이모티콘 반응\n\n4. 알림 보내기\n4.1. 예약 알림\n4.2. 시스템 알림\n4.3. 프로모션 알림\n\n5. 검색\n5.1. 미용사 검색\n5.1.1. 이름 검색\n5.1.2. 위치 검색\n5.1.3. 평점 검색\n5.1.4. 예약 가능 여부 검색\n\n5.2. 서비스 검색\n5.2.1. 서비스 종류 검색\n5.2.2. 반려동물 유형 검색\n\n6. 회원 분류하기\n6.1. 일반 회원\n6.2. 단골 고객\n6.2.1. 단골 등록\n6.2.2. 단골 관리\n\n7. 결제하기\n7.1. 결제 수단\n7.1.1. 신용카드 결제\n7.1.2. 모바일 결제\n7.1.3. 무통장 입금\n\n7.2. 결제 내역 조회\n7.3. 환불 처리\n7.3.1. 예약 취소 및 환불\n\n8. 관리자 기능\n8.1. 미용사 등록 및 관리\n8.1.1. 미용사 정보 입력\n8.1.2. 일정 관리\n8.1.3. 미용사 평가 관리\n\n8.2. 고객 관리\n8.2.1. 회원 정보 관리\n8.2.2. 후기 관리\n\n8.3. 예약 관리\n8.3.1. 예약 현황 조회\n8.3.2. 예약 취소 및 환불 승인\n\n8.4. 정산 관리\n8.4.1. 매출 정산\n8.4.2. 수수료 정산\n\n8.5. 콘텐츠 관리\n8.5.1. 사이트 이미지 관리\n8.5.2. 동영상 관리\n8.5.3. 후기 글 관리\n\n9. SEO 관리\n9.1. 네이버 SEO 연동\n9.2. 카카오 SEO 연동\n9.3. 구글 SEO 연동	- 기획팀(프로젝트 매니저, 사업 분석가): 0~0.5개월\n- 디자인팀(UI/UX 디자이너): 0.5~1.5개월\n- 프론트엔드 개발자: 1~3.5개월\n- 백엔드 개발자: 1~3.5개월\n- QA 엔지니어: 3~4개월\n- 마케팅 팀(SEO 전문가): 3~4개월\n- 유지보수팀(IT 지원 팀): 3.5~4개월
361	미미	6개월	5500	- 사용자 로그인 & 가입 기능 제공\n- 사용자가 방문 미용사를 선택하고 예약할 수 있는 기능\n- 미용사 및 고객에게 예약 관련 알림 전송 기능\n- 고객이 예약한 서비스에 대해 결제할 수 있는 기능\n- 미용사와 고객 간의 채팅 기능 제공\n- 예약 취소 및 환불 처리 시스템 구현\n- 사용자가 방문한 미용사에 대해 별점 및 평가 기능 제공\n- 단골 고객 등록 및 후기를 남길 수 있는 기능\n- SEO(검색엔진최적화) 자동화 연동\n- 미용사 정보를 인구 대비 기준으로 관리 및 분류하는 기능	- 기능 명세서\n- UI/UX 스케치 및 프로토타입\n- DB 설계서\n- 백엔드 API 명세서\n- 결제 시스템 통합 문서\n- 예약 및 취소 관리 모듈\n- 알림 시스템 설계 및 구현서\n- 회원 관리 기능 설계서\n- 리뷰 및 평점 시스템 문서\n- SEO 최적화 계획서	\N	36ec7463-2785-4506-b809-38bfa1af9183	36ec7463-2785-4506-b809-38bfa1af9183	36ec7463-2785-4506-b809-38bfa1af9183	4000	4	앱 개발/웹 개발	fkaus4169	1. 로그인 & 가입\n  1.1. 회원가입\n    1.1.1. 이메일 인증\n  1.2. 로그인\n    1.2.1. 아이디/비밀번호 찾기\n  1.3. 소셜 로그인\n    1.3.1. 네이버 로그인\n    1.3.2. 카카오 로그인\n    1.3.3. 구글 로그인\n\n2. 결제하기\n  2.1. 결제 수단 선택\n    2.1.1. 신용카드 결제\n    2.1.2. 계좌이체\n    2.1.3. 간편결제\n  2.2. 결제 확인\n\n3. 별점 & 평가\n  3.1. 후기 작성\n    3.1.1. 글 후기 작성\n    3.1.2. 이미지 후기 업로드\n    3.1.3. 동영상 후기 업로드\n  3.2. 평점 매기기\n    3.2.1. 미용사 칭찬 점수 (1-5점)\n\n4. 알림 보내기\n  4.1. 예약 알림\n    4.1.1. 예약 완료 알림\n    4.1.2. 예약 취소 알림\n  4.2. 일정 알림\n    4.2.1. 예약 전 리마인더\n\n5. 회원 분류하기\n  5.1. 회원 관리\n    5.1.1. 일반 회원\n    5.1.2. 단골 고객\n      5.1.2.1. 단골 고객 혜택\n      5.1.2.2. 단골 고객 후기 작성\n\n6. 팔로우\n  6.1. 미용사 팔로우\n    6.1.1. 팔로우 목록 관리\n\n7. 채팅\n  7.1. 실시간 채팅\n    7.1.1. 미용사와 채팅\n    7.1.2. 고객 지원 채팅\n    7.1.3. 알림 메시지 전송\n\n8. 예약하기\n  8.1. 미용사 선택\n    8.1.1. 거리 기반 미용사 검색\n  8.2. 예약 일정 선택\n  8.3. 예약 세부 정보\n    8.3.1. 애완동물 무게\n    8.3.2. 털의 종류와 상태\n    8.3.3. 특이사항\n  8.4. 예약 확정 후 알림\n    8.4.1. 카카오톡 알림 전송\n  8.5. 예약 취소 및 환불\n    8.5.1. 예약 취소 처리\n    8.5.2. 환불 절차 안내\n\n9. 정산 관리\n  9.1. 예약 내역 확인\n    9.1.1. 미용사별 예약 내역 조회\n  9.2. 정산 처리\n    9.2.1. 자동 정산\n    9.2.2. 수작업 정산\n\n10. SEO 최적화\n  10.1. 검색엔진 최적화 (SEO)\n    10.1.1. 네이버 SEO 연동\n    10.1.2. 카카오 SEO 연동\n    10.1.3. 구글 SEO 연동	- 시장 조사 팀(연구원): 0~0.5개월\n- 브랜딩 팀(브랜드 전략, 커뮤니케이션): 0.5~1.5개월\n- 디자인 팀(UI/UX 디자이너): 1~2개월\n- 프론트엔드 개발자: 1~4개월\n- 백엔드 개발자: 1~4개월\n- 결제 시스템 개발자: 2~3개월\n- QA 엔지니어: 4~5개월\n- SEO 전문가: 4.5~5.5개월\n- 유지보수 팀(IT 지원): 5~6개월
363	이이	4개월	4000	- 로그인 & 가입 기능\n- 결제하기 기능\n- 별점 & 평가 기능\n- 회원 분류하기 기능\n- 알림 보내기 기능\n- 팔로우 기능\n- 검색 기능\n- 예약하기 기능 (반려동물 미용 서비스 예약)\n- 단골고객 관리 기능\n- 후기 작성 및 댓글/좋아요 기능	- 프로젝트 기획서\n- 기능 명세서\n- UI/UX 디자인 시안\n- 데이터베이스 설계서\n- 백엔드 API 설계서\n- 사용자 매뉴얼\n- 테스트 계획서\n- SEO 최적화 보고서\n- 코드베이스(documented)\n- 정산 자동화 스크립트 (추가 가능성 대비)	\N	afbf32a9-7113-4cf1-bce7-341b6039e8f0	afbf32a9-7113-4cf1-bce7-341b6039e8f0	afbf32a9-7113-4cf1-bce7-341b6039e8f0	4000	4	앱 개발/웹 개발	fkaus4169	1. 결제하기\n   1.1. 일반 결제\n       1.1.1. 신용카드 결제\n       1.1.2. 계좌 이체\n       1.1.3. 간편 결제 (카카오페이, 네이버페이 등)\n   1.2. 환불 처리\n       1.2.1. 예약 취소 시 환불\n       1.2.2. 환불 절차 안내 (수기로 처리 가능)\n\n2. 로그인 & 가입\n   2.1. 회원가입\n       2.1.1. 이메일 인증\n       2.1.2. 소셜 로그인 (네이버, 카카오, 구글)\n   2.2. 로그인\n       2.2.1. 이메일 로그인\n       2.2.2. 소셜 로그인 (네이버, 카카오, 구글)\n\n3. 별점 & 평가\n   3.1. 후기 작성\n       3.1.1. 글 후기\n       3.1.2. 이미지 후기\n       3.1.3. 동영상 후기\n       3.1.4. 미용사 칭찬 점수 (1~5점)\n   3.2. 후기 관리\n       3.2.1. 댓글 달기\n       3.2.2. 좋아요 기능\n       3.2.3. 이모티콘 추가\n   3.3. 단골고객 등록\n       3.3.1. 단골고객으로 등록하기\n       3.3.2. 단골고객 후기 작성\n\n4. 회원 분류하기\n   4.1. 미용사 분류\n       4.1.1. 지역별 분류\n       4.1.2. 일정별 분류\n   4.2. 고객 분류\n       4.2.1. 단골고객 분류\n\n5. 알림 보내기\n   5.1. 예약 알림\n       5.1.1. 예약 완료 알림\n       5.1.2. 예약 변경 알림\n       5.1.3. 예약 취소 알림\n   5.2. 일정 알림\n       5.2.1. 미용사 일정 알림\n   5.3. 기타 알림\n       5.3.1. 기타 중요 알림\n\n6. 팔로우\n   6.1. 미용사 팔로우\n       6.1.1. 미용사 팔로우하기\n       6.1.2. 팔로우 리스트 관리\n\n7. 검색\n   7.1. 미용사 검색\n       7.1.1. 지역별 검색\n       7.1.2. 일정별 검색\n       7.1.3. 미용사 이름 검색\n   7.2. 후기 검색\n       7.2.1. 후기 내용 검색\n       7.2.2. 미용사 별 후기 검색\n\n8. 예약하기\n   8.1. 예약 시스템\n       8.1.1. 미용사 일정 조회\n       8.1.2. 방문 가능한 미용사 선택\n       8.1.3. 예약 정보 입력 (무게, 털의 종류와 상태, 특이사항 등)\n   8.2. 예약 관리\n       8.2.1. 예약 확인 및 수정\n       8.2.2. 예약 취소\n   8.3. 예약 완료 알림\n       8.3.1. 고객에게 알림\n       8.3.2. 미용사에게 알림\n\n9. SEO\n   9.1. 자동 연동\n       9.1.1. 네이버 SEO 적용\n       9.1.2. 카카오 SEO 적용\n       9.1.3. 구글 SEO 적용	- 기획자(프로젝트 계획 및 요구사항 정의): 0~0.5개월\n- 디자이너(UI/UX 디자이너): 0.5~1개월\n- 프론트엔드 개발자: 1~3개월\n- 백엔드 개발자: 1~3개월\n- QA 엔지니어: 3~4개월\n- 마케터(SEO 최적화): 2~4개월\n- 시스템 관리자(서버 및 인프라 설정): 0.5~1.5개월\n- IT 지원 팀(유지보수): 3.5~4개월
364	flfl	4개월	4040	- 결제하기 기능 구현\n- 로그인 & 가입 기능 구현\n- 별점 & 평가 기능 구현\n- 회원 분류하기 기능 구현\n- 알림 보내기 기능 구현\n- 팔로우 기능 구현\n- 채팅 기능 구현\n- 온라인 예약 기능 구현 및 예약 옵션 제공\n- SEO 최적화 기능을 통한 네이버, 카카오, 구글 연동\n- 고객 후기 및 미용사 칭찬점수 시스템 구축	- 프로젝트 계획서\n- 기능 명세서\n- 데이터베이스 설계서\n- 웹 및 앱 UI/UX 디자인 문서\n- 소프트웨어 아키텍처 문서\n- 예약 및 결제 시스템 개발 코드\n- 사용자 매뉴얼\n- SEO 설정 및 연결 문서\n- 테스트 계획서\n- 유지보수 계획서	\N	929651f6-ac8c-4962-a435-a84a87b3bbac	929651f6-ac8c-4962-a435-a84a87b3bbac	929651f6-ac8c-4962-a435-a84a87b3bbac	4040	4	앱 개발/웹 개발	fkaus4169	1. 로그인 & 가입\n    1.1. 회원가입\n        1.1.1. 이메일 인증\n        1.1.2. SNS 계정 연동 (네이버, 카카오, 구글)\n    1.2. 로그인\n        1.2.1. 이메일 로그인\n        1.2.2. SNS 로그인 (네이버, 카카오, 구글)\n    1.3. 비밀번호 찾기\n        1.3.1. 이메일로 비밀번호 재설정 링크 발송\n\n2. 결제하기\n    2.1. 결제 수단 선택\n        2.1.1. 신용카드\n        2.1.2. 은행 송금\n        2.1.3. 간편결제 (네이버페이, 카카오페이 등)\n    2.2. 결제 확인\n        2.2.1. 결제 완료 시 자동 알림 발송 (SMS, 카톡)\n    \n3. 별점 & 평가\n    3.1. 리뷰 작성\n        3.1.1. 후기 글 작성\n        3.1.2. 이미지 업로드\n        3.1.3. 동영상 업로드\n        3.1.4. 미용사 칭찬 점수 (1~5점)\n    3.2. 리뷰 상호작용\n        3.2.1. 댓글 추가\n        3.2.2. 좋아요\n        3.2.3. 이모티콘 추가\n\n4. 회원 분류하기\n    4.1. 일반 회원\n    4.2. 단골고객\n        4.2.1. 단골고객 등록\n        4.2.2. 단골고객 후 혜택\n\n5. 알림 보내기\n    5.1. 예약 확인 알림\n        5.1.1. SMS 알림\n        5.1.2. 카카오톡 알림\n    5.2. 예약 취소 알림\n        5.2.1. SMS 알림\n        5.2.2. 카카오톡 알림\n    5.3. 결제 확인 알림\n        5.3.1. SMS 알림\n        5.3.2. 카카오톡 알림\n\n6. 팔로우\n    6.1. 미용사 팔로우\n    6.2. 팔로우한 미용사 업데이트\n        6.2.1. 새 일정 알림\n        6.2.2. 새로운 후기 알림\n\n7. 채팅\n    7.1. 실시간 채팅\n        7.1.1. 미용사와 실시간 상담\n        7.1.2. 예약 전 문의 및 상담\n    7.2. 예약 관련 채팅\n        7.2.1. 예약 변경 사항 상담\n        7.2.2. 취소 및 환불 문의\n\n8. 예약하기\n    8.1. 예약 절차\n        8.1.1. 미용사 선택\n        8.1.2. 일정 선택\n        8.1.3. 옵션 선택 (무게, 털의 종류와 상태, 특이사항 등)\n    8.2. 예약 확인\n        8.2.1. 예약 내역 확인\n        8.2.2. 예약 취소 및 변경\n    8.3. 예약 취소\n        8.3.1. 예약 취소 요청\n        8.3.2. 취소 시 환불 처리\n\n9. 검색\n    9.1. 미용사 검색\n        9.1.1. 지역별 검색\n        9.1.2. 미용사 평점 검색\n        9.1.3. 미용사 일정 검색\n\n10. 홈 화면 구성\n    10.1. 최소 구성\n        10.1.1. 준비된 이미지 및 동영상\n        10.1.2. 후기글 배너\n    10.2. SEO 연동\n        10.2.1. 네이버\n        10.2.2. 카카오\n        10.2.3. 구글\n\n11. 장바구니\n    11.1. 장바구니 추가\n        11.1.1. 예약 추가\n        11.1.2. 예약 삭제\n    11.2. 결제\n        11.2.1. 예약 결제 및 확인\n\n12. 통합 관리\n    12.1. 미용사 관리\n        12.1.1. 미용사 등록\n        12.1.2. 일정 관리\n        12.1.3. 예약 관리\n    12.2. 고객 관리\n        12.2.1. 회원 정보 관리\n        12.2.2. 예약 내역 관리\n    12.3. 정산 관리\n        12.3.1. 수동 정산\n        12.3.2. 자동 정산 (추가 가능 시)	- 시장 조사 및 컨설팅 팀(사업 전략가, 분석가): 0~0.5개월\n- UI/UX 디자인 팀: 0.5~1.5개월\n- 프론트엔드 개발자: 1~3개월\n- 백엔드 개발자: 1~3개월\n- 데이터베이스 관리자: 1.5~3개월\n- 결제 시스템 전문가: 2~3.2개월\n- QA 엔지니어: 3~3.5개월\n- 마케팅 및 SEO 전문가: 3.5~4개월\n- 유지보수 및 IT 지원 팀: 3.5~4개월
365	지지	6개월	5000	- 예약 기능: 고객이 반려동물 미용 서비스를 예약할 수 있는 기능. 예약 시 여러 옵션(무게, 털의 종류와 상태, 특이사항 등)을 선택할 수 있음.\n- 로그인 및 가입 기능: 고객이 사이트에 회원 가입 및 로그인을 할 수 있는 기능. \n- 결제 기능: 예약 완료 후 온라인 결제가 가능한 시스템. \n- 별점 및 평가 기능: 미용사에 대한 후기를 남기고, 평가 점수를 부여할 수 있는 기능. \n- 회원 분류하기: 단골 고객으로 등록할 수 있는 기능. \n- 알림 보내기: 예약 완료 후 담당 미용사와 고객에게 카카오톡으로 알림을 전송하는 시스템.\n- 팔로우 기능: 고객이 특정 미용사를 팔로우하여 이후 서비스 이용에 용이하도록 하는 시스템.\n- 검색 기능: 고객이 가까운 미용사를 검색하고 선택할 수 있는 기능.\n- 취소 및 환불 기능: 부득이한 경우 예약을 취소하고 환불 처리를 할 수 있는 시스템.\n- SEO 기능: 네이버, 카카오, 구글에서 SEO가 자동으로 연동되는 기능.	- 프로젝트 계획서\n- 기능 명세서\n- 데이터베이스 설계서\n- UI/UX 디자인 시안\n- 시스템 아키텍처 문서\n- 결제 시스템 통합 계획서\n- 예약 시스템 구현 계획서\n- 정산 및 환불 프로세스 정의서\n- 사용자 매뉴얼\n- SEO 전략 및 실행 계획	\N	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	4000	4	앱 개발/웹 개발	fkaus4169	기능명세서가 없습니다.	- 시장 조사 팀(연구원, 분석가): 0~1개월\n- 기획 팀: 0.5~1.5개월\n- UI/UX 디자인 팀: 1~2.5개월\n- 프론트엔드 개발자: 2~5개월\n- 백엔드 개발자: 2~5개월\n- 데이터베이스 관리자: 3~4.5개월\n- 소프트웨어 테스트 및 QA 엔지니어: 4.5~5.5개월\n- SEO 전문가: 4.5~5.5개월\n- 유지보수 팀: 5.5~6개월
366	비비	4개월	4000	- 회원가입 및 로그인 기능 구현\n- 결제 기능 구현\n- 별점 및 평가 시스템 적용\n- 회원 분류 기능 설정 (등록 및 단골 고객 분류)\n- 미용사와 고객 간 실시간 알림 기능 구현\n- 팔로우 기능 구현 (단골 미용사 팔로우)\n- 검색 기능 최적화 (미용사 및 서비스 검색)\n- 예약 시스템 구축 및 관리 기능 구현\n- 리뷰 및 댓글 시스템 구현 (글, 이미지, 동영상, 평점 등)\n- SEO(검색엔진 최적화) 설정 (네이버, 카카오, 구글 연동)	- 기능명세서\n- 시스템 아키텍처 설계서\n- 데이터베이스 설계서\n- 사용자 인터페이스(UI) 디자인 목업\n- 웹 애플리케이션 사용법 매뉴얼\n- 테스트 계획서\n- 개발 일정표\n- 유지보수 계획서\n- SEO 최적화 보고서	\N	92748cdc-10c4-404f-b14c-fd3987ded5bc	92748cdc-10c4-404f-b14c-fd3987ded5bc	92748cdc-10c4-404f-b14c-fd3987ded5bc	4000	4	앱 개발/웹 개발	fkaus4169	1. 로그인 & 가입\n   1.1. 회원가입\n      1.1.1. 이메일 인증\n      1.1.2. 휴대폰 인증\n   1.2. 로그인\n      1.2.1. 이메일 로그인\n      1.2.2. 소셜 로그인 (네이버, 카카오, 구글)\n   1.3. 비밀번호 찾기\n\n2. 결제하기\n   2.1. 결제 수단\n      2.1.1. 신용/체크 카드\n      2.1.2. 간편결제 (네이버페이, 카카오페이, 구글페이 등)\n      2.1.3. 무통장 입금\n   2.2. 결제 과정\n      2.2.1. 결제 정보 입력\n      2.2.2. 결제 확인 및 완료\n   2.3. 결제 내역 관리\n\n3. 별점 & 평가\n   3.1. 후기 작성\n      3.1.1. 텍스트 후기\n      3.1.2. 이미지 후기\n      3.1.3. 동영상 후기\n   3.2. 별점 주기\n      3.2.1. 1점부터 5점까지의 별점\n   3.3. 후기 관리\n      3.3.1. 후기 수정/삭제\n\n4. 회원 분류하기\n   4.1. 단골 고객 등록\n      4.1.1. 일반 고객과 단골 고객 구분\n   4.2. 단골 고객 혜택\n      4.2.1. 단골 고객 전용 혜택 관리\n\n5. 알림 보내기\n   5.1. 카카오톡 알림\n   5.2. 이메일 알림\n   5.3. SMS 알림\n\n6. 팔로우\n   6.1. 미용사 팔로우\n   6.2. 팔로우한 미용사 보기\n\n7. 검색\n   7.1. 미용사 검색\n      7.1.1. 지역별 검색\n      7.1.2. 조건별 검색 (예: 무게, 털의 종류와 상태 등)\n   7.2. 후기 검색\n      7.2.1. 텍스트 기반 검색\n   7.3. 예약 내역 검색\n\n8. 예약하기\n   8.1. 예약 가능 미용사 보기\n      8.1.1. 지역별 미용사 보기\n      8.1.2. 미용사 일정 보기\n   8.2. 예약 진행\n      8.2.1. 예약 옵션 선택 (무게, 털의 종류와 상태, 특이사항 등)\n      8.2.2. 예약 확인 및 완료\n      8.2.3. 예약 취소\n   8.3. 예약 알림\n      8.3.1. 예약 확인 알림\n      8.3.2. 예약 변경/취소 알림\n      8.3.3. 예약 완료 알림\n   8.4. 예약 관리\n      8.4.1. 예약 내역 보기\n      8.4.2. 예약 내역 수정/취소\n\n9. SEO 연동\n   9.1. 네이버 SEO\n      9.1.1. 메타 데이터 설정\n      9.1.2. 사이트맵 제출\n   9.2. 카카오 SEO\n      9.2.1. 메타 데이터 설정\n      9.2.2. 사이트맵 제출\n   9.3. 구글 SEO\n      9.3.1. 메타 데이터 설정\n      9.3.2. 사이트맵 제출\n\n10. 관리 시스템\n   10.1. 미용사 관리\n      10.1.1. 미용사 등록\n      10.1.2. 미용사 일정 관리\n   10.2. 예약 관리\n      10.2.1. 예약 내역 조회\n      10.2.2. 예약 내역 수정/취소\n   10.3. 결제 관리\n      10.3.1. 결제 내역 조회\n      10.3.2. 환불 처리\n   10.4. 정산 관리\n      10.4.1. 미용사별 수수료 정산\n      10.4.2. 정산 내역 조회\n\n11. 후기 시스템\n   11.1. 후기 작성\n      11.1.1. 후기 작성 권한 부여\n   11.2. 후기 관리\n      11.2.1. 후기 수정/삭제 권한 부여\n\n12. UI/UX 디자인 최소화\n   12.1. 이미지/동영상 최소화\n   12.2. 간결한 인터페이스 제공\n\n13. 기본 기능\n   13.1. 홈 화면 구성\n      13.1.1. 주요 기능 바로가기\n   13.2. 사용자 프로필 관리\n      13.2.1. 프로필 정보 수정\nt	- 기획 및 분석(프로젝트 매니저, 비즈니스 분석가): 0~0.5개월\n- UI/UX 디자인(디자이너): 0.5~1개월\n- 백엔드 개발자(결제 시스템, 예약 시스템, 정산 시스템): 1~3개월\n- 프론트엔드 개발자(웹앱 개발, 채팅, 리뷰 시스템): 1~3개월\n- 데이터베이스 관리자(DBA): 1~2개월\n- QA 엔지니어(테스트 및 품질 보증): 3~3.5개월\n- 디지털 마케팅(SEO 전문가, 마케터): 3~4개월\n- IT 지원 팀(유지보수): 3.5~4개월
368	디디	4개월	4000	- 결제하기\n- 로그인 & 가입\n- 별점 & 평가\n- 회원 분류하기\n- 알림 보내기\n- 팔로우\n- 검색\n- 리뷰 및 피드백 등록\n- 예약 관리\n- SEO 자동 연동	- 기능 명세서\n- 화면 설계서 (Wireframe)\n- 데이터베이스 모델링 문서\n- 사용자 매뉴얼\n- 테스트 계획서\n- 예약 및 결제 시스템 설계 문서\n- SEO 최적화 보고서\n- API 명세서\n- 반응형 웹 디자인 요소\n- 피드백 및 리뷰 시스템 구현 문서	\N	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	4000	4	앱 개발/웹 개발	fkaus4169	1. 결제하기\n    1.1. 예약 결제\n        1.1.1. 결제 수단 선택\n            1.1.1.1. 신용카드\n            1.1.1.2. 계좌이체\n            1.1.1.3. 간편결제 (네이버 페이, 카카오페이 등)\n        1.1.2. 결제 상태 확인\n        1.1.3. 결제 영수증 발행\n\n2. 로그인 & 가입\n    2.1. 회원가입\n        2.1.1. 이메일 인증\n        2.1.2. 휴대폰 인증\n    2.2. 로그인\n        2.2.1. 이메일 로그인\n        2.2.2. 소셜 로그인 (네이버, 카카오, 구글)\n    2.3. 비밀번호 찾기\n        2.3.1. 이메일 인증\n        2.3.2. 휴대폰 인증\n\n3. 별점 & 평가\n    3.1. 후기 작성\n        3.1.1. 텍스트 후기\n        3.1.2. 이미지 후기\n        3.1.3. 동영상 후기\n        3.1.4. 미용사 평가 (1-5점)\n    3.2. 후기 평가\n        3.2.1. 댓글 달기\n        3.2.2. 좋아요\n        3.2.3. 이모티콘\n\n4. 회원 분류하기\n    4.1. 일반 회원\n    4.2. 단골 고객\n        4.2.1. 단골 등록\n        4.2.2. 단골 혜택\n        4.2.3. 단골 해제\n\n5. 알림 보내기\n    5.1. 예약 관련 알림\n        5.1.1. 예약 확인 알림\n        5.1.2. 예약 취소 알림\n        5.1.3. 예약 변경 알림\n        5.1.4. 예약 완료 알림\n    5.2. 결제 관련 알림\n        5.2.1. 결제 확인 알림\n        5.2.2. 결제 실패 알림\n    5.3. 기타 알림\n        5.3.1. 프로모션 알림\n        5.3.2. 미용사 평가 알림\n\n6. 팔로우\n    6.1. 미용사 팔로우\n        6.1.1. 팔로우 추가\n        6.1.2. 팔로우 해제\n    6.2. 팔로우 관리\n        6.2.1. 팔로잉 목록\n        6.2.2. 팔로워 목록\n\n7. 검색\n    7.1. 미용사 검색\n        7.1.1. 지역별 검색\n        7.1.2. 일정별 검색\n    7.2. 후속 검색\n        7.2.1. 미용사 이름 검색\n        7.2.2. 미용 후기 검색\n\n8. 예약하기\n    8.1. 예약 생성\n        8.1.1. 미용사 선택\n        8.1.2. 날짜 및 시간 선택\n        8.1.3. 예약 옵션 선택\n            8.1.3.1. 반려동물 무게\n            8.1.3.2. 털의 종류와 상태\n            8.1.3.3. 특이사항\n    8.2. 예약 변경\n    8.3. 예약 취소\n    8.4. 예약 확인\n        8.4.1. 예약 내역 조회\n\n9. 관리자 기능\n    9.1. 미용사 등록\n        9.1.1. 미용사 정보 입력\n        9.1.2. 온오프 면접 관리\n    9.2. 예약 관리\n        9.2.1. 예약 현황 조회\n        9.2.2. 예약 취소 및 변경 요청 처리\n    9.3. 정산 관리\n        9.3.1. 정산 내역 조회\n        9.3.2. 자동 정산 시스템\n        9.3.3. 수기 정산 옵션\n\n10. SEO 최적화\n    10.1. 네이버 SEO\n    10.2. 카카오 SEO\n    10.3. 구글 SEO	- 요구사항 분석 팀(비즈니스 분석가, 시스템 분석가): 0~0.5개월\n- 설계 팀(UI/UX 디자이너, 아키텍트): 0.5~1개월\n- 프론트엔드 개발자: 1~3개월\n- 백엔드 개발자: 1~3개월\n- QA 팀(테스터, QA 엔지니어): 2.5~3.5개월\n- 마케팅 팀(SEO 전문가): 2~3개월\n- 유지보수 팀(IT 지원): 3~4개월
369	그래머 GPT	3개월	1500	- 메인 컬러 조정 및 중심부에 빨간색을 사용하는 새로운 로고 디자인\n- 클라이언트 기존 로고 디자인 유지\n- 온라인 결제 기능\n- 사용자 로그인 및 가입 기능\n- 주문 관리 시스템\n- 정보 검색 기능\n- 패턴 학습지 개발\n- 문장 형식 및 구조에 대한 학습 내용 포함\n- PDF 문법 강의 자료 제공\n- 노엄 촘스키의 생성형 문법 이론을 기반으로 한 교육 콘텐츠 디자인	- 프로젝트 계획서\n- 상세 기능 명세서\n- 디자인 가이드라인 문서\n- 로고 디자인 산출물\n- PDF 문법 강의 학습 자료\n- 학습지 디자인 시안\n- 패턴 학습지 샘플\n- 사용자 매뉴얼\n- 테스트 및 QA보고서	\N	f8be9551-9680-445d-b79e-a6cd4b34e861	f8be9551-9680-445d-b79e-a6cd4b34e861	f8be9551-9680-445d-b79e-a6cd4b34e861	1500	3	브랜딩/웹 개발	admin	1. 결제하기\n    1.1. 결제 방법 선택\n        1.1.1. 신용카드 결제\n        1.1.2. 은행 계좌 이체\n        1.1.3. 전자 지갑 결제\n    1.2. 결제 내역 확인\n        1.2.1. 거래 내역 리스트\n        1.2.2. 명세서 다운로드\n    1.3. 결제 확인\n        1.3.1. 실시간 결제 확인\n        1.3.2. 이메일/문자 알림\n\n2. 로그인 & 가입\n    2.1. 회원가입\n        2.1.1. 이메일 인증\n        2.1.2. 휴대폰 인증\n    2.2. 로그인\n        2.2.1. 이메일 로그인\n        2.2.2. 소셜 로그인\n    2.3. 비밀번호 재설정\n        2.3.1. 이메일을 통한 재설정 링크 발송\n        2.3.2. 새로운 비밀번호 설정\n\n3. 주문 관리\n    3.1. 주문 내역 조회\n        3.1.1. 주문 상태 확인\n        3.1.2. 상세 주문 내역 열람\n    3.2. 주문 변경 및 취소\n        3.2.1. 주문 내역 변경\n        3.2.2. 주문 취소 신청\n    3.3. 주문 알림\n        3.3.1. 주문 확인 알림\n        3.3.2. 배송 시작 알림\n\n4. 검색\n    4.1. 기본 검색\n        4.1.1. 키워드 검색\n        4.1.2. 필터 적용\n            4.1.2.1. 카테고리별 필터\n            4.1.2.2. 가격별 필터\n    4.2. 고급 검색\n        4.2.1. 다중 조건 검색\n        4.2.2. 검색 결과 정렬\n            4.2.2.1. 최신순 정렬\n            4.2.2.2. 인기순 정렬	- 시장 조사 팀(브랜딩 분석가, 연구원): 0~0.5개월\n- 디자인 팀(UI/UX 디자이너, 그래픽 디자이너): 0.5~1개월\n- 웹 개발자(프론트엔드, 백엔드): 1~2.5개월\n- QA 엔지니어: 2.5~3개월\n- 마케팅 팀: 2~3개월
371	이이	4개월	400	- 결제하기\n- 로그인 & 가입	- 프로젝트 계획서\n- 기능 명세서\n- UI/UX 디자인 시안\n- 데이터베이스 설계서\n- 초기 코드베이스 및 기본 기능 구현	\N	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	4	4	앱 개발/웹 개발	fkaus4169	1. 결제하기\n    1.1. 결제 수단 선택\n        1.1.1. 신용카드\n        1.1.2. 은행 계좌\n        1.1.3. 모바일 결제\n    1.2. 결제 정보 입력\n        1.2.1. 카드 번호 입력\n        1.2.2. 유효 기간 입력\n        1.2.3. CVC 코드 입력\n    1.3. 결제 확인\n        1.3.1. 주문 내역 확인\n        1.3.2. 결제 금액 확인\n    1.4. 영수증 발행\n        1.4.1. 이메일로 영수증 발급\n        1.4.2. PDF 형태로 다운로드\n\n2. 로그인 & 가입\n    2.1. 회원가입\n        2.1.1. 이메일 회원가입\n            2.1.1.1. 이메일 인증\n            2.1.1.2. 비밀번호 설정\n        2.1.2. 소셜 회원가입\n            2.1.2.1. 구글 계정으로 가입\n            2.1.2.2. 페이스북 계정으로 가입\n    2.2. 로그인\n        2.2.1. 이메일 로그인\n            2.2.1.1. 이메일 주소 입력\n            2.2.1.2. 비밀번호 입력\n        2.2.2. 소셜 로그인\n            2.2.2.1. 구글 계정으로 로그인\n            2.2.2.2. 페이스북 계정으로 로그인\n    2.3. 비밀번호 재설정\n        2.3.1. 비밀번호 재설정 요청\n            2.3.1.1. 이메일 주소 입력\n            2.3.1.2. 인증 코드 발송\n        2.3.2. 비밀번호 재설정\n            2.3.2.1. 새 비밀번호 입력\n            2.3.2.2. 비밀번호 재입력	- 요구사항 분석 및 계획(프로젝트 매니저, 비즈니스 분석가): 0~0.5개월\n- UI/UX 설계(UI/UX 디자이너): 0.5~1개월\n- 프론트엔드 개발자: 1~3개월\n- 백엔드 개발자: 1~3개월\n- 결제 시스템 통합(백엔드 개발자): 1.5~2.5개월\n- 로그인 & 가입 기능 개발(프론트엔드, 백엔드): 1.5~3개월\n- 테스트 및 품질 보증(QA 엔지니어): 3~4개월\n- 배포 및 유지보수(데브옵스 엔지니어): 3.5~4개월
372	프로젝트	4개월	4000	- 결제하기\n- 로그인 & 가입\n- 별점 & 평가\n- 회원 분류하기\n- 채팅	- 상세 프로젝트 계획서\n- 요구 사항 명세서\n- 시스템 설계서\n- 데이터베이스 설계서\n- 기능별 테스트 계획서\n- 소스 코드 저장소\n- 사용자 매뉴얼\n- 기능별 테스트 결과 보고서\n- 유지보수 계획서\n- 최종 보고서	\N	5893b347-d8e5-4ed9-8174-e454836ceecb	5893b347-d8e5-4ed9-8174-e454836ceecb	5893b347-d8e5-4ed9-8174-e454836ceecb	4000	4	앱 개발/웹 개발	fkaus4169	1. 결제하기\n   1.1. 결제 방법 선택\n   1.1.1. 신용카드\n   1.1.2. 은행 계좌 이체\n   1.1.3. 간편결제 (예: 카카오페이, 네이버페이)\n   1.2. 결제 정보 입력\n   1.2.1. 카드 정보 입력\n   1.2.2. 계좌 정보 입력\n   1.2.3. 간편결제 계정 연동\n   1.3. 결제 확인 및 완료\n   1.3.1. 결제 내역 확인\n   1.3.2. 결제 완료 알림\n\n2. 로그인 & 가입\n   2.1. 로그인\n   2.1.1. 이메일 로그인\n   2.1.2. 소셜 로그인 (예: 페이스북, 구글)\n   2.2. 회원가입\n   2.2.1. 이메일 회원가입\n   2.2.2. 소셜 계정 회원가입\n   2.3. 비밀번호 재설정\n   2.3.1. 비밀번호 찾기\n   2.3.2. 비밀번호 변경\n\n3. 별점 & 평가\n   3.1. 별점 주기\n   3.1.1. 5점 만점 별점 주기\n   3.2. 리뷰 작성\n   3.2.1. 텍스트 리뷰 작성\n   3.2.2. 사진 첨부 리뷰\n   3.3. 리뷰 관리\n   3.3.1. 리뷰 삭제\n   3.3.2. 리뷰 수정\n\n4. 회원 분류하기\n   4.1. 회원 등급 설정\n   4.1.1. 일반 회원\n   4.1.2. 프리미엄 회원\n   4.1.3. 관리자\n   4.2. 회원 권한 관리\n   4.2.1. 접근 권한 설정\n   4.2.2. 권한 변경\n\n5. 채팅\n   5.1. 1:1 채팅\n   5.1.1. 텍스트 메시지\n   5.1.2. 이미지 전송\n   5.1.3. 파일 전송\n   5.2. 그룹 채팅\n   5.2.1. 그룹 생성\n   5.2.2. 그룹 초대\n   5.2.3. 그룹 메시지	- 요구사항 분석 팀(비즈니스 분석가): 0~0.5개월\n- UI/UX 디자인 팀(UI/UX 디자이너): 0.5~1.5개월\n- 프론트엔드 개발자: 1~3개월\n- 백엔드 개발자: 1~3개월\n- 데이터베이스 관리자: 1.5~3개월\n- QA 엔지니어: 3~3.5개월\n- 마케팅 팀: 3.5~4개월\n- IT 지원 팀(유지보수): 3.5~4개월
\.


--
-- Data for Name: rfp_temp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rfp_temp (rfp_temp_seq, pro_name, pro_period, pro_budget, pro_agency, pro_function, pro_skill, pro_description, user_session, pro_reference, inserted_at) FROM stdin;
607	그래머 GPT	3	1500	2,4	3,6,15,22	0	기존 로고의 디자인은 유지하면서 메인 컬러 조정 및 중심부에 빨간색을 사용하는 새로운 로고 디자인. PDF 문법 강의를 바탕으로 문장 형식을 학습할 수 있는 패턴 학습지 개발 계획. 문장의 형식, 문장의 기본 구조, 부정사와 동명사 개념의 학습지 포함. 학습자는 1형식~5형식의 문장을 만들고, 다중 보기 문제를 통해 학습하게 됨. 해당 프로젝트는 뛰어난 확장성을 갖추고 있으며, 학원 연합체와 같은 플랫폼을 대상으로 할 예정. 클라이언트는 노엄 촘스키의 생성형 문법 이론을 참고했으며, 프로젝트의 철학적 근거를 강조.	f8be9551-9680-445d-b79e-a6cd4b34e861	\N	2024-09-04 07:29:56.655703
597	프로메테우스	3	3000	4	3,6,9,11,17,18,20,22	0	반려견/반려묘 방문 미용서비스이고, 지자체 읍면동 인구대비해서 미용사들이 몇명씩해서 50여명 있습니다. 아직 없는 지역이 많음. 최대 미용사 3000명 예상.\n1인 미용사가 개인 일정에 따라서 최대 일일 5건이내 오전에 1~2건 오후에 2~3건 처리합니다.미용사는 지자체 읍면동 인구대비 시장 규모에 맞춰 온오프면접을 거쳐서 수기로 등록합니다.\n고객은 방문이 용이한 거리상의 미용사를 선택하고 그 미용사의 일정에 맞춰서 예약을 하는 시스템 입니다.\n예약시 무게, 털의 종류와 상태, 특이사항 등 3~4가지(단계)의 옵션이 있을수 있습니다.\n예약은 통상적인 온라인 결제방식들을 거친 후 완료됩니다.\n완료된 예약은 담당 미용사와 예약고객에게 카톡으로 자동 전달됩니다.\n예약은 부득이하게 담당미용사 또는 예약고객이 취소할 수도 있습니다. 취소된 예약에 대해선 환불처리(복잡하면 수기로도 가능)\n완료된 거래에 대해서, 저희와 미용사(개인사업자) 간의 정산은 수작업을 할 예정입니다만, 혹시 자동화가 가능하면 추가해 주십시오.\n웹앱으로만 사용합니다.\n사이트 이미지는 최소화합니다. 사이트 제작에 이미 준비된 이미지, 동영상, 후기글들은 충분히 있습니다.\n예약한 고객은 언제든 사이트에 단골고객으로 등록할 숭 있습니다. Default 는 비등록. \n단골고객은 후기를 남길수 있고 글 and/or 이미지 and/or 동영상 and/or 미용사칭찬점수 1~5 를 업로드할 수 있습니다. \n후기에 대해서 댓글 좋아요 이모티콘 등등을 추가할 수도 있습니다.\n\n네이버, 카카오, 구글에서 SEO 가 자동으로 연동되게해 주십시오.	6d6cd042-eca4-46b2-af20-8c88433638af	www.petshop.com	2024-09-03 06:03:22.52791
598	프프	3	3000	3,4	3,6,9,11,17,18,20,22	0	반려견/반려묘 방문 미용서비스이고, 지자체 읍면동 인구대비해서 미용사들이 몇명씩해서 50여명 있습니다. 아직 없는 지역이 많음. 최대 미용사 3000명 예상.\n1인 미용사가 개인 일정에 따라서 최대 일일 5건이내 오전에 1~2건 오후에 2~3건 처리합니다.미용사는 지자체 읍면동 인구대비 시장 규모에 맞춰 온오프면접을 거쳐서 수기로 등록합니다.\n고객은 방문이 용이한 거리상의 미용사를 선택하고 그 미용사의 일정에 맞춰서 예약을 하는 시스템 입니다.\n예약시 무게, 털의 종류와 상태, 특이사항 등 3~4가지(단계)의 옵션이 있을수 있습니다.\n예약은 통상적인 온라인 결제방식들을 거친 후 완료됩니다.\n완료된 예약은 담당 미용사와 예약고객에게 카톡으로 자동 전달됩니다.\n예약은 부득이하게 담당미용사 또는 예약고객이 취소할 수도 있습니다. 취소된 예약에 대해선 환불처리(복잡하면 수기로도 가능)\n완료된 거래에 대해서, 저희와 미용사(개인사업자) 간의 정산은 수작업을 할 예정입니다만, 혹시 자동화가 가능하면 추가해 주십시오.\n웹앱으로만 사용합니다.\n사이트 이미지는 최소화합니다. 사이트 제작에 이미 준비된 이미지, 동영상, 후기글들은 충분히 있습니다.\n예약한 고객은 언제든 사이트에 단골고객으로 등록할 숭 있습니다. Default 는 비등록. \n단골고객은 후기를 남길수 있고 글 and/or 이미지 and/or 동영상 and/or 미용사칭찬점수 1~5 를 업로드할 수 있습니다. \n후기에 대해서 댓글 좋아요 이모티콘 등등을 추가할 수도 있습니다.\n\n네이버, 카카오, 구글에서 SEO 가 자동으로 연동되게해 주십시오.	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	www.petshop.com	2024-09-03 06:06:24.843254
599	이이	4	4000	3,4	3,6,9,11,17,22	0	반려견/반려묘 방문 미용서비스이고, 지자체 읍면동 인구대비해서 미용사들이 몇명씩해서 50여명 있습니다. 아직 없는 지역이 많음. 최대 미용사 3000명 예상.\n1인 미용사가 개인 일정에 따라서 최대 일일 5건이내 오전에 1~2건 오후에 2~3건 처리합니다.미용사는 지자체 읍면동 인구대비 시장 규모에 맞춰 온오프면접을 거쳐서 수기로 등록합니다.\n고객은 방문이 용이한 거리상의 미용사를 선택하고 그 미용사의 일정에 맞춰서 예약을 하는 시스템 입니다.\n예약시 무게, 털의 종류와 상태, 특이사항 등 3~4가지(단계)의 옵션이 있을수 있습니다.\n예약은 통상적인 온라인 결제방식들을 거친 후 완료됩니다.\n완료된 예약은 담당 미용사와 예약고객에게 카톡으로 자동 전달됩니다.\n예약은 부득이하게 담당미용사 또는 예약고객이 취소할 수도 있습니다. 취소된 예약에 대해선 환불처리(복잡하면 수기로도 가능)\n완료된 거래에 대해서, 저희와 미용사(개인사업자) 간의 정산은 수작업을 할 예정입니다만, 혹시 자동화가 가능하면 추가해 주십시오.\n웹앱으로만 사용합니다.\n사이트 이미지는 최소화합니다. 사이트 제작에 이미 준비된 이미지, 동영상, 후기글들은 충분히 있습니다.\n예약한 고객은 언제든 사이트에 단골고객으로 등록할 숭 있습니다. Default 는 비등록. \n단골고객은 후기를 남길수 있고 글 and/or 이미지 and/or 동영상 and/or 미용사칭찬점수 1~5 를 업로드할 수 있습니다. \n후기에 대해서 댓글 좋아요 이모티콘 등등을 추가할 수도 있습니다.\n\n네이버, 카카오, 구글에서 SEO 가 자동으로 연동되게해 주십시오.	0ea08000-110f-44ee-957d-9fb75fb6f685	www.pet	2024-09-03 06:38:22.261027
600	피피	4	4000	3,4	3,6,9,17,20,23,11	0	반려견/반려묘 방문 미용서비스이고, 지자체 읍면동 인구대비해서 미용사들이 몇명씩해서 50여명 있습니다. 아직 없는 지역이 많음. 최대 미용사 3000명 예상.\n1인 미용사가 개인 일정에 따라서 최대 일일 5건이내 오전에 1~2건 오후에 2~3건 처리합니다.미용사는 지자체 읍면동 인구대비 시장 규모에 맞춰 온오프면접을 거쳐서 수기로 등록합니다.\n고객은 방문이 용이한 거리상의 미용사를 선택하고 그 미용사의 일정에 맞춰서 예약을 하는 시스템 입니다.\n예약시 무게, 털의 종류와 상태, 특이사항 등 3~4가지(단계)의 옵션이 있을수 있습니다.\n예약은 통상적인 온라인 결제방식들을 거친 후 완료됩니다.\n완료된 예약은 담당 미용사와 예약고객에게 카톡으로 자동 전달됩니다.\n예약은 부득이하게 담당미용사 또는 예약고객이 취소할 수도 있습니다. 취소된 예약에 대해선 환불처리(복잡하면 수기로도 가능)\n완료된 거래에 대해서, 저희와 미용사(개인사업자) 간의 정산은 수작업을 할 예정입니다만, 혹시 자동화가 가능하면 추가해 주십시오.\n웹앱으로만 사용합니다.\n사이트 이미지는 최소화합니다. 사이트 제작에 이미 준비된 이미지, 동영상, 후기글들은 충분히 있습니다.\n예약한 고객은 언제든 사이트에 단골고객으로 등록할 숭 있습니다. Default 는 비등록. \n단골고객은 후기를 남길수 있고 글 and/or 이미지 and/or 동영상 and/or 미용사칭찬점수 1~5 를 업로드할 수 있습니다. \n후기에 대해서 댓글 좋아요 이모티콘 등등을 추가할 수도 있습니다.\n\n네이버, 카카오, 구글에서 SEO 가 자동으로 연동되게해 주십시오.	d388d19c-d16b-4b44-af17-d41b88b26d5b	\N	2024-09-03 08:39:33.689701
601	미미	4	4000	3,4	3,6,9,17,11,20,23	0	반려견/반려묘 방문 미용서비스이고, 지자체 읍면동 인구대비해서 미용사들이 몇명씩해서 50여명 있습니다. 아직 없는 지역이 많음. 최대 미용사 3000명 예상.\n1인 미용사가 개인 일정에 따라서 최대 일일 5건이내 오전에 1~2건 오후에 2~3건 처리합니다.미용사는 지자체 읍면동 인구대비 시장 규모에 맞춰 온오프면접을 거쳐서 수기로 등록합니다.\n고객은 방문이 용이한 거리상의 미용사를 선택하고 그 미용사의 일정에 맞춰서 예약을 하는 시스템 입니다.\n예약시 무게, 털의 종류와 상태, 특이사항 등 3~4가지(단계)의 옵션이 있을수 있습니다.\n예약은 통상적인 온라인 결제방식들을 거친 후 완료됩니다.\n완료된 예약은 담당 미용사와 예약고객에게 카톡으로 자동 전달됩니다.\n예약은 부득이하게 담당미용사 또는 예약고객이 취소할 수도 있습니다. 취소된 예약에 대해선 환불처리(복잡하면 수기로도 가능)\n완료된 거래에 대해서, 저희와 미용사(개인사업자) 간의 정산은 수작업을 할 예정입니다만, 혹시 자동화가 가능하면 추가해 주십시오.\n웹앱으로만 사용합니다.\n사이트 이미지는 최소화합니다. 사이트 제작에 이미 준비된 이미지, 동영상, 후기글들은 충분히 있습니다.\n예약한 고객은 언제든 사이트에 단골고객으로 등록할 숭 있습니다. Default 는 비등록. \n단골고객은 후기를 남길수 있고 글 and/or 이미지 and/or 동영상 and/or 미용사칭찬점수 1~5 를 업로드할 수 있습니다. \n후기에 대해서 댓글 좋아요 이모티콘 등등을 추가할 수도 있습니다.\n\n네이버, 카카오, 구글에서 SEO 가 자동으로 연동되게해 주십시오.	36ec7463-2785-4506-b809-38bfa1af9183	\N	2024-09-04 05:19:14.720565
602	이이	4	4000	3,4	3,6,9,11,17,20,22	0	반려견/반려묘 방문 미용서비스이고, 지자체 읍면동 인구대비해서 미용사들이 몇명씩해서 50여명 있습니다. 아직 없는 지역이 많음. 최대 미용사 3000명 예상.\n1인 미용사가 개인 일정에 따라서 최대 일일 5건이내 오전에 1~2건 오후에 2~3건 처리합니다.미용사는 지자체 읍면동 인구대비 시장 규모에 맞춰 온오프면접을 거쳐서 수기로 등록합니다.\n고객은 방문이 용이한 거리상의 미용사를 선택하고 그 미용사의 일정에 맞춰서 예약을 하는 시스템 입니다.\n예약시 무게, 털의 종류와 상태, 특이사항 등 3~4가지(단계)의 옵션이 있을수 있습니다.\n예약은 통상적인 온라인 결제방식들을 거친 후 완료됩니다.\n완료된 예약은 담당 미용사와 예약고객에게 카톡으로 자동 전달됩니다.\n예약은 부득이하게 담당미용사 또는 예약고객이 취소할 수도 있습니다. 취소된 예약에 대해선 환불처리(복잡하면 수기로도 가능)\n완료된 거래에 대해서, 저희와 미용사(개인사업자) 간의 정산은 수작업을 할 예정입니다만, 혹시 자동화가 가능하면 추가해 주십시오.\n웹앱으로만 사용합니다.\n사이트 이미지는 최소화합니다. 사이트 제작에 이미 준비된 이미지, 동영상, 후기글들은 충분히 있습니다.\n예약한 고객은 언제든 사이트에 단골고객으로 등록할 숭 있습니다. Default 는 비등록. \n단골고객은 후기를 남길수 있고 글 and/or 이미지 and/or 동영상 and/or 미용사칭찬점수 1~5 를 업로드할 수 있습니다. \n후기에 대해서 댓글 좋아요 이모티콘 등등을 추가할 수도 있습니다.\n\n네이버, 카카오, 구글에서 SEO 가 자동으로 연동되게해 주십시오.	afbf32a9-7113-4cf1-bce7-341b6039e8f0	\N	2024-09-04 05:22:05.016984
603	flfl	4	4040	3,4	3,6,9,11,17,20,23	0	반려견/반려묘 방문 미용서비스이고, 지자체 읍면동 인구대비해서 미용사들이 몇명씩해서 50여명 있습니다. 아직 없는 지역이 많음. 최대 미용사 3000명 예상.\n1인 미용사가 개인 일정에 따라서 최대 일일 5건이내 오전에 1~2건 오후에 2~3건 처리합니다.미용사는 지자체 읍면동 인구대비 시장 규모에 맞춰 온오프면접을 거쳐서 수기로 등록합니다.\n고객은 방문이 용이한 거리상의 미용사를 선택하고 그 미용사의 일정에 맞춰서 예약을 하는 시스템 입니다.\n예약시 무게, 털의 종류와 상태, 특이사항 등 3~4가지(단계)의 옵션이 있을수 있습니다.\n예약은 통상적인 온라인 결제방식들을 거친 후 완료됩니다.\n완료된 예약은 담당 미용사와 예약고객에게 카톡으로 자동 전달됩니다.\n예약은 부득이하게 담당미용사 또는 예약고객이 취소할 수도 있습니다. 취소된 예약에 대해선 환불처리(복잡하면 수기로도 가능)\n완료된 거래에 대해서, 저희와 미용사(개인사업자) 간의 정산은 수작업을 할 예정입니다만, 혹시 자동화가 가능하면 추가해 주십시오.\n웹앱으로만 사용합니다.\n사이트 이미지는 최소화합니다. 사이트 제작에 이미 준비된 이미지, 동영상, 후기글들은 충분히 있습니다.\n예약한 고객은 언제든 사이트에 단골고객으로 등록할 숭 있습니다. Default 는 비등록. \n단골고객은 후기를 남길수 있고 글 and/or 이미지 and/or 동영상 and/or 미용사칭찬점수 1~5 를 업로드할 수 있습니다. \n후기에 대해서 댓글 좋아요 이모티콘 등등을 추가할 수도 있습니다.\n\n네이버, 카카오, 구글에서 SEO 가 자동으로 연동되게해 주십시오.	929651f6-ac8c-4962-a435-a84a87b3bbac	\N	2024-09-04 05:26:41.84689
604	지지	4	4000	3,4	3,6,9,11,17,20,22	0	반려견/반려묘 방문 미용서비스이고, 지자체 읍면동 인구대비해서 미용사들이 몇명씩해서 50여명 있습니다. 아직 없는 지역이 많음. 최대 미용사 3000명 예상.\n1인 미용사가 개인 일정에 따라서 최대 일일 5건이내 오전에 1~2건 오후에 2~3건 처리합니다.미용사는 지자체 읍면동 인구대비 시장 규모에 맞춰 온오프면접을 거쳐서 수기로 등록합니다.\n고객은 방문이 용이한 거리상의 미용사를 선택하고 그 미용사의 일정에 맞춰서 예약을 하는 시스템 입니다.\n예약시 무게, 털의 종류와 상태, 특이사항 등 3~4가지(단계)의 옵션이 있을수 있습니다.\n예약은 통상적인 온라인 결제방식들을 거친 후 완료됩니다.\n완료된 예약은 담당 미용사와 예약고객에게 카톡으로 자동 전달됩니다.\n예약은 부득이하게 담당미용사 또는 예약고객이 취소할 수도 있습니다. 취소된 예약에 대해선 환불처리(복잡하면 수기로도 가능)\n완료된 거래에 대해서, 저희와 미용사(개인사업자) 간의 정산은 수작업을 할 예정입니다만, 혹시 자동화가 가능하면 추가해 주십시오.\n웹앱으로만 사용합니다.\n사이트 이미지는 최소화합니다. 사이트 제작에 이미 준비된 이미지, 동영상, 후기글들은 충분히 있습니다.\n예약한 고객은 언제든 사이트에 단골고객으로 등록할 숭 있습니다. Default 는 비등록. \n단골고객은 후기를 남길수 있고 글 and/or 이미지 and/or 동영상 and/or 미용사칭찬점수 1~5 를 업로드할 수 있습니다. \n후기에 대해서 댓글 좋아요 이모티콘 등등을 추가할 수도 있습니다.\n\n네이버, 카카오, 구글에서 SEO 가 자동으로 연동되게해 주십시오.	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	\N	2024-09-04 05:27:41.903891
605	비비	4	4000	3,4	3,6,9,11,17,20,22	0	반려견/반려묘 방문 미용서비스이고, 지자체 읍면동 인구대비해서 미용사들이 몇명씩해서 50여명 있습니다. 아직 없는 지역이 많음. 최대 미용사 3000명 예상.\n1인 미용사가 개인 일정에 따라서 최대 일일 5건이내 오전에 1~2건 오후에 2~3건 처리합니다.미용사는 지자체 읍면동 인구대비 시장 규모에 맞춰 온오프면접을 거쳐서 수기로 등록합니다.\n고객은 방문이 용이한 거리상의 미용사를 선택하고 그 미용사의 일정에 맞춰서 예약을 하는 시스템 입니다.\n예약시 무게, 털의 종류와 상태, 특이사항 등 3~4가지(단계)의 옵션이 있을수 있습니다.\n예약은 통상적인 온라인 결제방식들을 거친 후 완료됩니다.\n완료된 예약은 담당 미용사와 예약고객에게 카톡으로 자동 전달됩니다.\n예약은 부득이하게 담당미용사 또는 예약고객이 취소할 수도 있습니다. 취소된 예약에 대해선 환불처리(복잡하면 수기로도 가능)\n완료된 거래에 대해서, 저희와 미용사(개인사업자) 간의 정산은 수작업을 할 예정입니다만, 혹시 자동화가 가능하면 추가해 주십시오.\n웹앱으로만 사용합니다.\n사이트 이미지는 최소화합니다. 사이트 제작에 이미 준비된 이미지, 동영상, 후기글들은 충분히 있습니다.\n예약한 고객은 언제든 사이트에 단골고객으로 등록할 숭 있습니다. Default 는 비등록. \n단골고객은 후기를 남길수 있고 글 and/or 이미지 and/or 동영상 and/or 미용사칭찬점수 1~5 를 업로드할 수 있습니다. \n후기에 대해서 댓글 좋아요 이모티콘 등등을 추가할 수도 있습니다.\n\n네이버, 카카오, 구글에서 SEO 가 자동으로 연동되게해 주십시오.	92748cdc-10c4-404f-b14c-fd3987ded5bc	\N	2024-09-04 05:33:05.171727
606	디디	4	4000	3,4	3,6,9,11,17,20,22	0	반려견/반려묘 방문 미용서비스이고, 지자체 읍면동 인구대비해서 미용사들이 몇명씩해서 50여명 있습니다. 아직 없는 지역이 많음. 최대 미용사 3000명 예상.\n1인 미용사가 개인 일정에 따라서 최대 일일 5건이내 오전에 1~2건 오후에 2~3건 처리합니다.미용사는 지자체 읍면동 인구대비 시장 규모에 맞춰 온오프면접을 거쳐서 수기로 등록합니다.\n고객은 방문이 용이한 거리상의 미용사를 선택하고 그 미용사의 일정에 맞춰서 예약을 하는 시스템 입니다.\n예약시 무게, 털의 종류와 상태, 특이사항 등 3~4가지(단계)의 옵션이 있을수 있습니다.\n예약은 통상적인 온라인 결제방식들을 거친 후 완료됩니다.\n완료된 예약은 담당 미용사와 예약고객에게 카톡으로 자동 전달됩니다.\n예약은 부득이하게 담당미용사 또는 예약고객이 취소할 수도 있습니다. 취소된 예약에 대해선 환불처리(복잡하면 수기로도 가능)\n완료된 거래에 대해서, 저희와 미용사(개인사업자) 간의 정산은 수작업을 할 예정입니다만, 혹시 자동화가 가능하면 추가해 주십시오.\n웹앱으로만 사용합니다.\n사이트 이미지는 최소화합니다. 사이트 제작에 이미 준비된 이미지, 동영상, 후기글들은 충분히 있습니다.\n예약한 고객은 언제든 사이트에 단골고객으로 등록할 숭 있습니다. Default 는 비등록. \n단골고객은 후기를 남길수 있고 글 and/or 이미지 and/or 동영상 and/or 미용사칭찬점수 1~5 를 업로드할 수 있습니다. \n후기에 대해서 댓글 좋아요 이모티콘 등등을 추가할 수도 있습니다.\n\n네이버, 카카오, 구글에서 SEO 가 자동으로 연동되게해 주십시오.	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	\N	2024-09-04 05:38:18.463594
608	이이	4	4	3,4	3,6	0	ㅁㄴㅇ	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	\N	2024-09-04 07:41:39.29153
609	프로젝트	4	4000	3,4	3,6,9,11,23	0	프로젝트입니다	5893b347-d8e5-4ed9-8174-e454836ceecb	\N	2024-09-20 07:15:27.21741
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session (sid, sess, expire) FROM stdin;
7h2AmPVJheOSfm37xP0BylRIku6UBam-	{"cookie":{"originalMaxAge":3600000,"expires":"2024-11-20T05:28:17.299Z","secure":true,"httpOnly":true,"path":"/","sameSite":"None"}}	2024-11-20 05:28:18
orVkvHaYw4evdZL_Zj9w2fZ2ogd2IsjG	{"cookie":{"originalMaxAge":3600000,"expires":"2024-11-20T05:46:09.674Z","secure":true,"httpOnly":true,"path":"/","sameSite":"None"}}	2024-11-20 05:46:10
2AGdcJsLPyT6W8FtYf4_hApI7ZSDbHd3	{"cookie":{"originalMaxAge":3600000,"expires":"2024-11-20T05:27:22.778Z","secure":true,"httpOnly":true,"path":"/","sameSite":"None"}}	2024-11-20 05:27:23
PO3l76PLQMdOe7h9KidyG1pCESchunSw	{"cookie":{"originalMaxAge":3600000,"expires":"2024-11-20T05:42:19.639Z","secure":true,"httpOnly":true,"path":"/","sameSite":"None"}}	2024-11-20 05:42:20
v3P19N8gLxdMBJSF9D1lGfTPbih0xAqY	{"cookie":{"originalMaxAge":3600000,"expires":"2024-11-20T06:05:45.710Z","secure":true,"httpOnly":true,"path":"/","sameSite":"None"}}	2024-11-20 06:05:46
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscriptions (subscription_id, user_id, start_date, end_date, amount, status) FROM stdin;
\.


--
-- Data for Name: text_file_test; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.text_file_test (text_contents, user_session, inserted_at) FROM stdin;
프로젝트 이름은 프로메테우스이고 예산은 3천만 원 잡고 있습니다. 그리고 예상 기간은 3개월로 생각합니다.	\N	2024-09-03 06:03:12.011564
네 대표님 네 안녕하세요 네 안녕하세요 네 저희가 이제 그 로고가 계속 써왔던 로고니까 그러니까 색깔은 그렇게 크게 상관없는데 그러니까 그 앞에 이제 코어라는 개념이 이제 지구 핵 코 그런 개념이라서 보면은 빨갛게 표시한 게 이제 지구 핵이 빨갛다고 해서 그래서 이제 그렇게 된 거예요. 근데 크게 그 디자인만 유지가 되고 네 크게 상관없을 것 같아요. 그러니까 메인 컬러를 어떤 걸로 정해야 할지가 제일 중요하거든요. 사실 전체적으로 분위기가 맞아야 되겠죠. 그러니까 저희가 뭐 저야 그냥 아까 회색 제가 회색 계통에 까만색 회색 계통을 좋아해서 까만색 회색에 빨간색을 넣으면은 좀 눈에 튀어 보여서 그거를 좋아하긴 하는데 어떤 색깔을 생각하 기본적으로 지금 원래 이 홈페이지에 들어가 있는 이 컬러들 색감으로 가도 되겠네요. 에듀코어 점 co kr 여기에 있는 네네. 그렇게 해서 지금은 너무 까마니까 약간 눈에 너무 피로감을 안 줄 정도로 그냥 약간 회색 계통의 회색 계통의 가운데만 빨갛게 이렇게 하면은 더 예쁠 것 같긴 하네요. 회색 계통에 지금 제가 고른 색깔 보면은 그냥 깔끔하잖아요. 그렇게 깔끔해서 가운데로 이렇게 했을 때 사람들한테 눈에 부담 안 주게 네 그렇게 잡혀 있는 것 같아서 그걸로 골랐는데 그러면은 로고 모양만 골라주신 거죠. 그럼 참고하고 나머지는 회색 계통의 빨간색으로 계열을 잡고 진행을 해보도록 하겠습니다. 네 그러니까 그러니까 중심에 코에 5 그리고 지구 중심에 빨간색 그것만 딱 들어가면은 그 외에 나머지는 그렇게 크게 문제는 없을 것 같아요. 그러면 이름은 에듀코 아직 안 정하신 거죠? 그 이름은 그래m GPT가 맞는 것 같아요. 그래 GPT로 가는데 그냥 에듀코 그니까 밑에다가 에듀코 다 오다 kr 아직은 아직 정해지신 게 없으셔서 저희가 1번 이거는 로고 작업하면서 저희가 한번 보여드릴게요. 네네 그리고 이제 세부 사항도 사실은 일단 초안을 잡아주시면 거기서 몇 번 이제 수정하면은 그리고 패턴 학습지가 제가 아직 이해를 잘 못해서 이 패턴 학습지라는 게 사실 그냥 문제가 나오는 거잖아요. 사지선다라든지 아니면 턴 학습지라는 거는 그러니까 저희 혹시 지금 현재 컴퓨터 혹시 갖고 계세요? 거기 보시면 제가 이제 PDF로 저희가 문법 강의를 제가 보내드린 게 있어요. 문법 책 쓴 거 잠시만요. 코어 문법 교재라고 돼 있는 게 있잖아요. 거기 보시면은 저도 잠깐 그걸 좀 빼겠습니다. 네 거기 보시면은 이제 동사와 문장 구조라고 해서 막 뭐가 돼 있었잖아요. 그러니까 처음에 이제 도형으로 이렇게 돼 있는데 보시면은 거기 문장에 이런 식의 주로 쓰이는 동사들 쭉 나오고 그리고 보시면은 그 밑에 바로 다음에 보면 문장 형식 동사 뒤에 필요한 것은 히 댄시스 뷰티 플 이렇게 나온 게 있는데 그게 이제 1형식 문장의 예제입니다. 그래서 만약에 이제 사용자가 그러니까 이번에 만약에 문장의 형식에 대한 문제를 내고 싶다고 한다면 1형식부터 그러니까 이 범주가 1형식 2형식 3형식 범주를 이 범위를 잡고 1형식 2형식 3명씩 나는 문장을 뽑을래 이제 그게 이제 버튼 식으로 이렇게 클릭을 할 수 있겠죠. 버튼 식으로 1형식 2형식 3명씩 버튼 클릭을 하고 단어 개수 그러니까 이 문장에 쓸 수 있는 단어 개수를 5개로 제한한다든가 6개로 제한한다든가 네 이런 식으로 제안해서 몇 문장 30문장 30문장 1형식 2형식 3형식 혼합 이렇게 해서 딱 하면은 1형식 2형식 3형식 문장이 한 원하는 숫자가 33개가 맥스라고 한다면 33개 문장이 이렇게 쫙 만들어지는 거예요. 페이지로 보시면 어디냐 페이지로 보시면은 약 어디지 이 페이지 번호를 안 먹여놨구나 한 18페이지 보시면은 제가 문장을 막 따놓은 게 있어요. 해피 트레이 이거는 제가 하나 둘 셋 넷 다섯 여섯 6개에서 7 단어를 써가지고 이형식 문장을 표현해라 이런 식으로 해서 했더니 GPT가 이렇게 만들어주더라고요. 결과가 이렇게 나오면 되겠네요. 베탄 학습지는 네 그렇죠 패턴 하이 이런 식으로 나와서 대신 이제 원하는 게 이게 정답 그러니까 정답을 처리하는 데 있어서 그러니까 만약에 이제 문장의 형식에는 알고리즘이 어떤 식으로 들어가야 되냐 면 주어 동사 제가 만든 문장의 형식에 맞는 게 있잖아요. 주어 동사 주격보 고 이렇게 이런 것들을 아이들이 표현함으로써 패턴을 학습하는 기계가 되는 거죠. 이거는 그래서 각 단원별로 만약에 문장의 형식이라면은 이제 그런 형식의 어떤 문제가 출제가 될 거고 그리고 이런 게 1차로 그러니까 문장의 형식을 패턴을 알게 되는 형식이 있을 거고 페이지로 쭉 넘어가 보시면 동그라미 룩스 해피 해필리 이렇게 그게 있을 거예요. 가로가 있는 분 네 그래서 이제 2차로 만약에 이제 여기서 필요한 컨포넌트가 뭐냐를 고를 수 있는 그런 2차 문제가 형성이 되는 거죠. 그러니까 이게 만약에 아이들이 이제 패턴을 익혔다면 이 자리에는 형용사가 와야 되는데 형용사 형태가 해피하고 해필리 2개가 있는데 아이들은 이제 해필리가 와야 될지 해피가 와야 될지 둘 중에 하나를 고르는 네 그런 어떤 문제지가 나올 수 있겠죠. 이게 형식만 먼저 만들 형식 말고는 이렇게는 다른 거는 어떻게 해야 될까요? 그러니까 문장의 형식 문장의 형식이 나오면 이제 문장의 기본적인 문장이 나올 거고 그래서 문장에 관련돼서 이렇게 문장에 필요한 요소들이 다 나오게 되면 문장에 어떤 그럼 이 문장의 5형식을 얘가 이제 만약에 이런 어떤 문장 패턴을 쓸 수가 있게 되면 여기에 관련된 그러니까 이제 여기서 이제 목적어에 부정사가 들어가게 될 거고 목적어 4형식에는 문장에 뭐가 이렇게 들어가게 될 건데 그런 문장들을 뒤쪽에서는 그러니까 뒤쪽에서 이제 저희가 호출을 할 때 그러니까 부정사는 사형식이나 오형식에 쓰이니까 사형식이나 오형식 문장을 말할 때 부정사를 넣으라고 할 수가 있거든요. 네 그러니까 사실 그런 거는 이제 이해를 했는데 이제 챕터가 12개인데 이 중에 이제 문장의 형식 문장의 기본 구조라고 해야 되나요? 이게 네 맞습니다. 네 문장의 기본 구조는 이런 식으로 패턴 학습지가 나오는데 나머지들은 사실 어떻게 나오는지는 아직 안 되신 거잖아요. 그러니까 부정사랑 동명사 개념은 이제 잡혔고요. 부정사 동명사는 됐고 그리고 이제 이거에 따라서 그러니까 이게 1차로 이제 문장이 형성이 될 수 있으면 문장을 보기를 여러 가지를 줘서 보기에서 어떤 특정한 어떤 문장을 넣어서 보기를 10개로 다중 보기 형태의 문제를 만들려고 할 수가 있겠죠. 그러니까 예를 들어서 1형식부터 5형식까지 문장을 다 섞어라 단 5형식 문장은 3개만 넣어라 하면은 애들이 이제 10문장에서 5형식 문장만 골라내는 연습 문제를 할 수가 있게 되고 그게 다중 보기 문제죠. 네네 그게 다중 복기 문제인데 1차적으로 문장의 형식에서는 다중 보기 문제가 이렇게 될 건데 일단 문장의 형식에서 만약에 이제 어떤 문장이든 다 얘가 쓸 수 있게 되면은 문장의 형식에서 제가 거의 다 문장을 다 쓰게 해놨어요. 여기 처음에 보시면 부정서랑 이런 것도 다 여기 포함이 돼 있거든요. 그래서 네 그러니까 문장의 형식에서 문장의 형식에 들어가는 이게 블록이라고 생각하시면 돼요. 그러니까 주어 자리에 들어갈 수 있는 거는 명사 명사 상당어구는 그냥 일반 명사 부정사 대명사 동명사 이런 대절 이런 애들이 이제 주어에 들어갈 수 있으니까 이런 컴포넌트를 정의를 해놓으면 그러니까 이런 문장을 쓰는 어떤 컴포넌트를 정의를 해놓으면 그러니까 이 GPT가 만약에 이제 이런 부분에서 학습을 하게 되면은 문장에 5형식을 만들려고 할 때 5형식을 다양한 방식으로 만들 수가 있는 거예요. 그러니까 일단은 일단 1형식 문장을 만들 수 있는 1형식 문장을 이렇게 만들어라 2형식 문장을 이렇게 만들어라 3형식 문장을 어떻게 만들어라 하면 1 2 3 4 5형식 내에 어차피 영어 문장은 1 2 3, 4, 5형식으로 다 만들어져 있으니까 그 안에 이제 모든 문법 내용이 일단 포함이 돼 있거든 그를 이해했습니다. 네 그거를 이제 나중에 부정사 동명사 부분에서 부정사 동명사만 세분화해서 이제 공부를 하는데 일단 문장의 형식에서는 용법이 필요가 없으니까 이제 부정사에 들어가면 부정사의 일정 특정 용법들이 세 가지가 나오는데 그때는 이제 그 용법들을 정의를 해 주는 거 그러니까 GPT는 이미 알고는 있더라고요. 부정사 용법에 이런 용법이 있다는 건 알고 있는데 저희가 이제 용법을 제한을 해줘야죠. 그러니까 이거는 이런 거는 명사적 용법이고 주어에만 쓰여 이렇게 정의를 좀 해줘야 돼요. 왜냐하면 자기가 미국 사람들이 쓰는 방식으로 얘는 정의를 하더라고요. 그러니까 우리나라에서 쓰는 게 아니라 시험에서 출제되는 방식으로 제가 이제 그 범주를 정해주면 그 안에서만 얘가 이제 생성을 할 수 있게만 해주면은 그래서 만약에 부정사 같은 경우에 이제 부정사의 형용사 용법 5개 부정사 부사용법 3개 이렇게 섞어서 애들이 여기서 부사용법 3개만 골라내는 그런 훈련이 다중 보기 훈련이 되는 거죠. 이해했습니다. 네 그래서 일단은 1차로 좀 이게 복잡할 것 같긴 한데 일단 문장의 형식을 먼저 제가 제대로 해야겠네요. 네네. 그러니까 제가 그 툴에서 그러니까 그 툴에서 이제 익스텐션이 계속 생기는 거니까 처음에 문장의 형식을 그러니까 이게 저희가 이제 얘가 완전히 이해해서 문장의 형식에서 우리가 요구하는 문장들이 어떤 식으로 만들어질 수 있다라는 거를 알려주고 그리고 이제 그거를 통해서 거기서 이제 파생되는 게 각각 챕터로 갈 때 어차피 그런 형식을 적용해서 문장을 써야 되니까 제로베이스에서 이 문장의 형식을 얘가 익히고 그 안에서 우리가 부정사를 호출하면 부정사를 꺼내서 부정사 문장을 만들어주는 그런 형식으로 이제 알고리즘이 만들어져야 되겠죠. 이해했습니다. 그러니까 좀 복잡해요. 또 아마 만들다가도 여쭤볼 것 같은데 그러니까 복잡하긴 한데 일단은 이거 제로 베이스 툴만 제로 툴만 잘 만들어져 있으면 정말로 이거는 너무 확장성이 너무 좋아요. 이걸로 이제 문장도 쓸 수 있고 문제도 만들 수 있고 어떤 글도 어차피 글 쓰는 것도 이런 문 오형식이 엮여서 문장이 만들어지는 거니까 오케이 이해했습니다. 네 그래서 챕터 1번이 제일 중요합니다. 챕터 1번을 좀 더 세분화시킬 생각이 있는데 일단은 지금 현재 갖고 있는 거를 먼저 보내드려야 될 것 같아서 제가 지금 일단 수능 10년 치 수능 10년 치 도켓 일단 수능 10년 치 유형별 문제를 다 보내드렸어요. 그 파일이 아마 엄청나게 많을 겁니다. 거기 예 수능 10년 치랑 그리고 이제 그런 그래서 이제 만약에 이제 문장의 형식이 이거는 이제 랜덤하게 걔가 알아서 이제 출제를 해준 거고 만약에 이제 가능하다면 10년 치 내에서 출제된 어떤 그런 문장들이 있잖아요. 네네네. 그거를 통해서 거기 안에서 이 부분은 주어니까 주어 이렇게 따가지고 그 안에서 이제 추출해가지고 거기서 문장을 만들어주면 그러면 이제 이거는 정말로 수능을 학습한 어떤 GPT가 GPT가 문장을 형성해 주고 나중에는 이제 이거를 중요한 건 이제 이 문장을 만들 때 어법상 틀린 거 그 문장의 형식에서 문장의 형식에 여기 자리에는 동명사가 들어가야 되는데 그거를 이제 부정사로 바꿔 넣어놓고 이런 식으로 이제 그런 식으로 하면은 이제 어법상 오류 문제가 다중 보기 식으로 한 큰 어떤 10개 문장짜리에서 어디 어디 어디만 틀리게 해라 하면은 이제 그런 문장이 딱 멀티 문제가 또 나오게 되는 거죠. 그러니까 저는 거기까지만 되면 될 것 같아요. 그러니까 일단 중요한 거는 문장을 애들이 패턴을 그러니까 이게 실제적으로 제가 생각하는 어떤 모델이 정말 생성형 문법 문장이거든요. 생성형 문법 문장인데 이게 이제 이론이 있는 어떤 그런 거예요. 그러니까 그러니까 문장이 만들어질 때 어찌 됐거나 애들이 하나씩 더해가면서 문장을 길게 만들어져 가는 건데 그렇게 더해지는 어떤 현상들이 블록식으로 이렇게 하나씩 들어와서 애들이 부정사 개념을 모르다가 부정 사이 알면 부정사 개념이 들어와서 문장이 만들어지고 이런 이제 생성형 문법을 근간으로 진짜 만드는 거거든요. 그래서 정말로 생성형 모델하고 생성형 문법하고 2개가 엮이면은 아마 진짜로 1형식부터 5형식까지만 내가 잘 이해하고 그 안에 컴포넌트가 뭐라는 걸 블록식으로 이제 하나씩 어떤 식으로 호출해서 엮어야 된다라는 어떤 그런 것만 다 체계가 잡혀지면 어떤 문장이든 다 형성이 가능할 것 같아요. 열심히 만들어 보겠습니다. 네 근데 이제 데이터셋이 저희가 수능 10년 치 데이터셋을 쓴다고 했으니까 그걸 흉내내서 만들면 진짜 괜찮겠죠 네 알겠습니다. 그건 사실 그런 개발적인 부분들은 이제 추후에 이제 개발 백엔드를 개발을 하면서 또 조절을 해야 돼가지고 그것보다는 지금은 디자인이랑 이 기획 그러니까 이 ui와 UX를 어떻게 배치할지에 대해서 지금 정하는 시기여가지고 네 지금은 그래서 제가 계속 디자인에 대해서 여쭤봤던 거고 추후에 이제 그런 학습해야 되는 데이터들이나 아니면은 어떻게 어떤 형식으로 나와야 되는지나 이런 것들은 한 번 더 정리해가지고 여쭤보도록 하겠습니다. 그거는 제가 얼마든지 자료로 제공을 해드릴게요. 지금 저도 이제 이거를 최초로 드렸는데 네 사실 이것도 그러니까 이게 정말 철학적으로 근거가 있는 거니까 이게 사람들한테 먹힐 수도 있을 것 같거든요. 이게 굉장히 유명한 이론가가 만들어낸 이론이에요. 지금 그러니까 촘스키라는 사람이 있는데 촘스키라는 사람이 생성형 문법을 주장한 사람인데 저는 그러니까 제가 언어학과다 보니까 저는 그 사람을 너무 좋아했거든요. 그래서 그 사람 이론을 따라서 생성형 문법이 정말로 가능할 것 같더라고요. 지금 GPT가 나와서 예. 가능할 것 같아서 그렇게 이론적 베이스도 있다라고 광고할 때 이렇게 하면은 네 좋지 않을까요? 좋을 것 같아 촘스키씨 말은 좀 써야겠다. 알겠습니다. 네 그런 부분은 제가 카피 와잇은 제가 무한으로 제공해 드릴게요. 일단은 정말 이 철학적으로 이 부분만 해결이 되면 그러면은 진짜로 이게 이제 카피 라이트도 이렇게 더 이상 문법 제일 필요 없다 이제 학원에서 만들어 써라 이게 이제 카피로 해서 제가 학원들 저희가 학원 연합체들이 되게 많아요. 그리고 또 가장 큰 게 이제 학관노라고 해서 학원 원장들이 있는 거 있는데 거기서 이런 거 갖다가 광고하는 사람들이 엄청 많거든요. 네 그러니까 입점할 때 이게 온라인 오프라인 스토어 같이 입점할 때 얼마 내고 들어가서 광고를 하는 어떤 그렇고 학습도 시키고 이런 게 있어요. 거기만 입점해서 만약에 잘 되면은 그쪽으로 공격할 만할 것 같아요. 좋습니다. 알겠습니다. 또 혹시 또 모르는 게 생기면 또 연락드리도록 하겠습니다. 그리고 저도 한 개 부탁드릴 게 저희 보이스 플로우를 애들이 이제 대부분 만들었어요. 같이 이제 공동 네네네. 챗봇을 만들었더니 보이스 포가 기능이 진짜 엄청나더라고요. 생각보다 저 깜짝 놀랐어요. 그렇죠 괜찮죠 예 이 정도인 줄 몰랐어요. 아직 웹사이트가 아예 그냥 하나 생기던데요. 예 맞습니다. 그러니까 이거를 이제 블로그에다 입히는 방법도 가능한 거죠. 그러니까 이거를 저희가 만들어서 그 안에서 생성 API 불러가지고 여기서 생성시키고 다만 이제 이게 웹사이트가 보이스 플로그 어쩌고 저쩌고 이렇게 나오니까 이거를 딴 데로 입혀버릴 수도 있는 거죠. 다른 어떤 블로그 자체에다가 입힌다는 게 도메인을 바꾼다는 말인가요? 아니면 네 맞습니다. 도메인을 챗봇 자체를 다른 웹사이트 상에 올리는 걸 말씀하시는 건가요? 그냥 이 챗봇 자체로 너무 좋더라고요. 그냥 그 페이지 자체가 페이지 자체가 너무 좋아서 오히려 이게 더 생성형 문법 같이 보이더라고요. 그러니까 아예 이거를 그냥 생성형 GPT라고 해도 될 정도로 아주 좋던데 그래서 이거를 근데 이제 출품을 하려니까 보이스 블로그 어떻게 이렇게 출품하기 위해서 그거를 이제 블로그에다가 블로그를 그냥 후킹만 하면 되나요? 이거는 그냥 그렇게 연결시켜가지고 이걸 뭐라고 그러지 인베드 시키는 거를 원하시는 거 URL을 딸 때 URL을 이렇게 보이스 플로우를 안 따고 URL을 네이버 블로그 이런 식으로 그걸 제가 안 해봐서 잠깐 제가 한번 해보고 저도 알려드리겠습니다. 그리고 또 하나 더 궁금한 게 여기서 네이버 클로바 엑스도 호출이 가능한가요? 이쪽에서 안 될 거예요. 그거는 그게 아마 GPT만 API 넣을 수 있는 것만 돼가지고 클로바 스가 사실 이번에 이제 클로바 x에서 그러니까 네이버가 주최를 하는 거라서 혹시 클로바가 되면 좋으니까 네네 클로바 스를 썼다고 하면 그쪽도 오히려 자기들 광고도 되니까 더 고를 수 있는 어떤 여건을 주잖아요. 그래서 클로바 뭐 알겠습니다. 네 알겠습니다. 제가 이거 아까 이식할 수 있는 거 그거는 좀 알아보고 다시 알려. 네 알겠습니다. 네 네 알겠습니다. 네 감사합니다. 네 감사합니다. 네.	\N	2024-09-04 07:29:50.48922
\.


--
-- Data for Name: thread_id; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.thread_id (thread_id, user_session, inserted_at) FROM stdin;
thread_WpUpCXe1BFxrau3aSCUzI0mm	929651f6-ac8c-4962-a435-a84a87b3bbac	2024-09-04 05:26:54.329763
thread_pbPJZvHhgaWKQbULMDt1m4Kv	6d6cd042-eca4-46b2-af20-8c88433638af	2024-09-03 06:03:22.077553
thread_ItkQNCu8lJ8HTZLaEecObSeX	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	2024-09-04 05:27:56.185989
thread_7daUJgWULAHz4dK7fNmNdrTR	92748cdc-10c4-404f-b14c-fd3987ded5bc	2024-09-04 05:33:22.154501
thread_0vWUgC6GsrgBjBBWAsUsxIEa	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	2024-09-04 05:38:32.984928
thread_qr4VdEksApoWhRxHQhYXWYPC	f8be9551-9680-445d-b79e-a6cd4b34e861	2024-09-04 07:29:56.215357
thread_ysp6QNnH5M9fW4xyPOZ6pIAH	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	2024-09-03 06:06:38.541566
thread_60HJCiD4xJDFfY7RCcD55XnC	0ea08000-110f-44ee-957d-9fb75fb6f685	2024-09-03 06:38:44.027007
thread_PHry4RNGApqNirROIpHkLs9T	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	2024-09-04 07:41:55.286655
thread_v2QUbDYsIQTimCVcoBQsYH4J	5893b347-d8e5-4ed9-8174-e454836ceecb	2024-09-20 07:15:57.779288
thread_5qfzk4Ps50sxeZxU4DOTPuwn	d388d19c-d16b-4b44-af17-d41b88b26d5b	2024-09-03 08:39:48.636132
thread_EL5HzVWjHrxm0OpeJd7QBhhB	36ec7463-2785-4506-b809-38bfa1af9183	2024-09-04 05:19:32.527837
thread_Pb2QQ95LsUSbWy9bE9kwQ7ju	afbf32a9-7113-4cf1-bce7-341b6039e8f0	2024-09-04 05:22:17.061314
\.


--
-- Data for Name: user_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_info (user_info_seq, user_id, user_password, user_phone, user_email, subscription_status, subscription_end_date, subscription_new, subscription_start_date, available_num, billing_key, customer_key) FROM stdin;
13	fkaus4169	$2b$10$fMDPiPYdtCIz/YiMrEiYN.Q9wESP3z0DmkPoV.ZD07NHoodBmaFo2	01099704712	fkaus9811@gmail.com	Y	2024-07-11	N	2024-06-11	무제한	\N	fkaus4169
20	admin	$2b$10$iI8oa9CTrPUL2Rdc/joKCO85BLZMiIovp7mAFeSr4VpFlygGK77iK	01057788443	admin@wintopartners.com	Y	2024-07-11	N	2024-06-11	무제한	N	admin
21	195195	$2b$10$3qThWQTcOdAOVhiwrb8noOwhxsfhiXg9m1vCkYvDOD3DaJ/L/eYGK	01046041107	195915@naver.com	N	\N	N	\N	\N	N	195195
22	ssw2570	$2b$10$r5yc9fargoF6MRMGndJsJ.D8axcbSY7CMfC9oSEnkF3R25OH2x96m	01080109401	ssw2570@naver.com	N	\N	N	\N	\N	N	ssw2570
23	graymuse	$2b$10$jEBgDjY7nNlok8P06t7bJe.KMupiVDeN//AwADldIh3fMy78.8kKe	+82 10 3394 7463	seunghyeyoo@gmail.com	N	\N	N	\N	\N	N	graymuse
\.


--
-- Data for Name: voice_file; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voice_file (file_seq, file_name, file_size, user_session) FROM stdin;
457	íë¡ë©íì°ì¤ test.m4a	177697	\N
458	(ì½ì´ìê¸ë¦¬ì) ê¹ê· í ëí_01091305490_20240826_163538.aac	3522275	\N
\.


--
-- Data for Name: wbs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wbs (wbs_seq, wbs_id, task_name, roles_involved, start_month, end_month, description) FROM stdin;
2622	6d6cd042-eca4-46b2-af20-8c88433638af	기획 및 조사 팀	기획자, 데이터 분석가	0.0	0.5	
2623	6d6cd042-eca4-46b2-af20-8c88433638af	SEO 전문가	\N	3.5	4.0	
2624	6d6cd042-eca4-46b2-af20-8c88433638af	QA 엔지니어	\N	3.5	4.5	
2625	6d6cd042-eca4-46b2-af20-8c88433638af	디자인 팀	UI/UX 디자이너	0.5	1.5	
2626	6d6cd042-eca4-46b2-af20-8c88433638af	마케팅 팀	SEO/디지털 마케터	4.0	5.0	
2627	6d6cd042-eca4-46b2-af20-8c88433638af	프론트엔드 개발자	\N	1.5	3.5	
2628	6d6cd042-eca4-46b2-af20-8c88433638af	백엔드 개발자	\N	1.5	3.5	
2629	6d6cd042-eca4-46b2-af20-8c88433638af	결제 시스템 개발자	\N	2.0	3.0	
2644	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	프로젝트 매니저	\N	0.0	6.0	
2645	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	유지보수/IT 지원 팀	\N	5.0	6.0	
2646	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	데이터베이스 관리자	DBA	2.0	4.0	
2647	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	분석/설계 팀	비즈니스 분석가, 시스템 설계자	0.0	1.0	
2648	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	프론트엔드 개발자	\N	2.0	4.0	
2650	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	마케팅 팀	SEO 전문가	4.0	6.0	
2651	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	결제 시스템 개발자	\N	3.0	4.0	
2649	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	QA 엔지니어	테스터	4.0	5.0	
2652	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	UI/UX 디자이너	\N	1.0	2.0	
2653	43d2bdec-e1ec-49f6-a465-94b8cea9d3ec	백엔드 개발자	\N	2.0	4.0	
2654	0ea08000-110f-44ee-957d-9fb75fb6f685	기획팀	프로젝트 매니저, 사업 분석가	0.0	0.5	
2655	0ea08000-110f-44ee-957d-9fb75fb6f685	프론트엔드 개발자	\N	1.0	3.5	
2656	0ea08000-110f-44ee-957d-9fb75fb6f685	QA 엔지니어	\N	3.0	4.0	
2657	0ea08000-110f-44ee-957d-9fb75fb6f685	디자인팀	UI/UX 디자이너	0.5	1.5	
2658	0ea08000-110f-44ee-957d-9fb75fb6f685	백엔드 개발자	\N	1.0	3.5	
2659	0ea08000-110f-44ee-957d-9fb75fb6f685	마케팅 팀	SEO 전문가	3.0	4.0	
2660	0ea08000-110f-44ee-957d-9fb75fb6f685	유지보수팀	IT 지원 팀	3.5	4.0	
2672	d388d19c-d16b-4b44-af17-d41b88b26d5b	기획 팀	프로젝트 매니저, 비즈니스 분석가	0.0	0.5	
2673	d388d19c-d16b-4b44-af17-d41b88b26d5b	디자인 팀	UI/UX 디자이너	0.5	1.0	
2674	d388d19c-d16b-4b44-af17-d41b88b26d5b	QA 엔지니어	\N	2.5	3.0	
2675	d388d19c-d16b-4b44-af17-d41b88b26d5b	데이터베이스 관리자	\N	2.0	2.5	
2676	d388d19c-d16b-4b44-af17-d41b88b26d5b	백엔드 개발자	\N	1.0	2.5	
2677	d388d19c-d16b-4b44-af17-d41b88b26d5b	IT 지원 팀	유지보수	3.5	4.0	
2678	d388d19c-d16b-4b44-af17-d41b88b26d5b	프론트엔드 개발자	\N	1.0	2.5	
2679	d388d19c-d16b-4b44-af17-d41b88b26d5b	마케팅 팀	SEO 전문가, 콘텐츠 마케터	3.0	3.5	
2688	36ec7463-2785-4506-b809-38bfa1af9183	시장 조사 팀	연구원	0.0	0.5	
2689	36ec7463-2785-4506-b809-38bfa1af9183	QA 엔지니어	\N	4.0	5.0	
2690	36ec7463-2785-4506-b809-38bfa1af9183	프론트엔드 개발자	\N	1.0	4.0	
2691	36ec7463-2785-4506-b809-38bfa1af9183	디자인 팀	UI/UX 디자이너	1.0	2.0	
2692	36ec7463-2785-4506-b809-38bfa1af9183	결제 시스템 개발자	\N	2.0	3.0	
2693	36ec7463-2785-4506-b809-38bfa1af9183	백엔드 개발자	\N	1.0	4.0	
2694	36ec7463-2785-4506-b809-38bfa1af9183	유지보수 팀	IT 지원	5.0	6.0	
2695	36ec7463-2785-4506-b809-38bfa1af9183	SEO 전문가	\N	4.5	5.5	
2696	36ec7463-2785-4506-b809-38bfa1af9183	브랜딩 팀	브랜드 전략, 커뮤니케이션	0.5	1.5	
2697	afbf32a9-7113-4cf1-bce7-341b6039e8f0	기획자	프로젝트 계획 및 요구사항 정의	0.0	0.5	
2698	afbf32a9-7113-4cf1-bce7-341b6039e8f0	QA 엔지니어	\N	3.0	4.0	
2699	afbf32a9-7113-4cf1-bce7-341b6039e8f0	프론트엔드 개발자	\N	1.0	3.0	
2701	afbf32a9-7113-4cf1-bce7-341b6039e8f0	디자이너	UI/UX 디자이너	0.5	1.0	
2702	afbf32a9-7113-4cf1-bce7-341b6039e8f0	마케터	SEO 최적화	2.0	4.0	
2703	afbf32a9-7113-4cf1-bce7-341b6039e8f0	백엔드 개발자	\N	1.0	3.0	
2700	afbf32a9-7113-4cf1-bce7-341b6039e8f0	시스템 관리자	서버 및 인프라 설정	0.5	1.5	
2704	afbf32a9-7113-4cf1-bce7-341b6039e8f0	IT 지원 팀	유지보수	3.5	4.0	
2705	929651f6-ac8c-4962-a435-a84a87b3bbac	시장 조사 및 컨설팅 팀	사업 전략가, 분석가	0.0	0.5	
2706	929651f6-ac8c-4962-a435-a84a87b3bbac	QA 엔지니어	\N	3.0	3.5	
2707	929651f6-ac8c-4962-a435-a84a87b3bbac	데이터베이스 관리자	\N	1.5	3.0	
2708	929651f6-ac8c-4962-a435-a84a87b3bbac	프론트엔드 개발자	\N	1.0	3.0	
2709	929651f6-ac8c-4962-a435-a84a87b3bbac	UI/UX 디자인 팀	\N	0.5	1.5	
2710	929651f6-ac8c-4962-a435-a84a87b3bbac	백엔드 개발자	\N	1.0	3.0	
2711	929651f6-ac8c-4962-a435-a84a87b3bbac	유지보수 및 IT 지원 팀	\N	3.5	4.0	
2712	929651f6-ac8c-4962-a435-a84a87b3bbac	결제 시스템 전문가	\N	2.0	3.2	
2713	929651f6-ac8c-4962-a435-a84a87b3bbac	마케팅 및 SEO 전문가	\N	3.5	4.0	
2714	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	시장 조사 팀	연구원, 분석가	0.0	1.0	
2715	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	SEO 전문가	\N	4.5	5.5	
2716	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	기획 팀	\N	0.5	1.5	
2717	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	유지보수 팀	\N	5.5	6.0	
2718	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	프론트엔드 개발자	\N	2.0	5.0	
2719	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	UI/UX 디자인 팀	\N	1.0	2.5	
2720	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	백엔드 개발자	\N	2.0	5.0	
2721	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	소프트웨어 테스트 및 QA 엔지니어	\N	4.5	5.5	
2722	5e370d59-9972-4d72-bd4a-1e0bb1a95b3b	데이터베이스 관리자	\N	3.0	4.5	
2730	92748cdc-10c4-404f-b14c-fd3987ded5bc	기획 및 분석	프로젝트 매니저, 비즈니스 분석가	0.0	0.5	
2731	92748cdc-10c4-404f-b14c-fd3987ded5bc	백엔드 개발자	결제 시스템, 예약 시스템, 정산 시스템	1.0	3.0	
2732	92748cdc-10c4-404f-b14c-fd3987ded5bc	디지털 마케팅	SEO 전문가, 마케터	3.0	4.0	
2733	92748cdc-10c4-404f-b14c-fd3987ded5bc	프론트엔드 개발자	웹앱 개발, 채팅, 리뷰 시스템	1.0	3.0	
2734	92748cdc-10c4-404f-b14c-fd3987ded5bc	UI/UX 디자인	디자이너	0.5	1.0	
2735	92748cdc-10c4-404f-b14c-fd3987ded5bc	QA 엔지니어	테스트 및 품질 보증	3.0	3.5	
2736	92748cdc-10c4-404f-b14c-fd3987ded5bc	IT 지원 팀	유지보수	3.5	4.0	
2737	92748cdc-10c4-404f-b14c-fd3987ded5bc	데이터베이스 관리자	DBA	1.0	2.0	
2738	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	요구사항 분석 팀	비즈니스 분석가, 시스템 분석가	0.0	0.5	
2739	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	QA 팀	테스터, QA 엔지니어	2.5	3.5	
2740	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	프론트엔드 개발자	\N	1.0	3.0	
2741	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	유지보수 팀	IT 지원	3.0	4.0	
2742	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	설계 팀	UI/UX 디자이너, 아키텍트	0.5	1.0	
2743	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	마케팅 팀	SEO 전문가	2.0	3.0	
2744	6a3a8958-b39d-45c6-aaa0-bb49940c2a14	백엔드 개발자	\N	1.0	3.0	
2750	f8be9551-9680-445d-b79e-a6cd4b34e861	시장 조사 팀	브랜딩 분석가, 연구원	0.0	0.5	
2751	f8be9551-9680-445d-b79e-a6cd4b34e861	디자인 팀	UI/UX 디자이너, 그래픽 디자이너	0.5	1.0	
2752	f8be9551-9680-445d-b79e-a6cd4b34e861	QA 엔지니어	\N	2.5	3.0	
2753	f8be9551-9680-445d-b79e-a6cd4b34e861	마케팅 팀	\N	2.0	3.0	
2754	f8be9551-9680-445d-b79e-a6cd4b34e861	웹 개발자	프론트엔드, 백엔드	1.0	2.5	
2755	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	요구사항 분석 및 계획	프로젝트 매니저, 비즈니스 분석가	0.0	0.5	
2756	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	UI/UX 설계	UI/UX 디자이너	0.5	1.0	
2757	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	결제 시스템 통합	백엔드 개발자	1.5	2.5	
2758	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	배포 및 유지보수	데브옵스 엔지니어	3.5	4.0	
2760	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	프론트엔드 개발자	\N	1.0	3.0	
2762	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	백엔드 개발자	\N	1.0	3.0	
2759	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	로그인 & 가입 기능 개발	프론트엔드, 백엔드	1.5	3.0	
2761	02cb6a48-77e9-46fd-8bfa-dedb36ce905f	테스트 및 품질 보증	QA 엔지니어	3.0	4.0	
2763	5893b347-d8e5-4ed9-8174-e454836ceecb	요구사항 분석 팀	비즈니스 분석가	0.0	0.5	
2764	5893b347-d8e5-4ed9-8174-e454836ceecb	백엔드 개발자	\N	1.0	3.0	
2765	5893b347-d8e5-4ed9-8174-e454836ceecb	프론트엔드 개발자	\N	1.0	3.0	
2766	5893b347-d8e5-4ed9-8174-e454836ceecb	마케팅 팀	\N	3.5	4.0	
2767	5893b347-d8e5-4ed9-8174-e454836ceecb	UI/UX 디자인 팀	UI/UX 디자이너	0.5	1.5	
2768	5893b347-d8e5-4ed9-8174-e454836ceecb	IT 지원 팀	유지보수	3.5	4.0	
2769	5893b347-d8e5-4ed9-8174-e454836ceecb	데이터베이스 관리자	\N	1.5	3.0	
2770	5893b347-d8e5-4ed9-8174-e454836ceecb	QA 엔지니어	\N	3.0	3.5	
\.


--
-- Name: file_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.file_seq', 458, true);


--
-- Name: ia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ia_seq', 13078, true);


--
-- Name: payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_id_seq', 9, true);


--
-- Name: payment_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_seq', 1, false);


--
-- Name: rfp_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rfp_seq', 372, true);


--
-- Name: rfp_temp_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rfp_temp_seq', 609, true);


--
-- Name: subscription_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subscription_seq', 1, false);


--
-- Name: user_info_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_info_seq', 23, true);


--
-- Name: wbs_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wbs_seq', 2770, true);


--
-- Name: ia ia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ia
    ADD CONSTRAINT ia_pkey PRIMARY KEY (ia_seq);


--
-- Name: payment_history payment_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_history
    ADD CONSTRAINT payment_history_pkey PRIMARY KEY (payment_history_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: rfp pro_ia_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rfp
    ADD CONSTRAINT pro_ia_unique UNIQUE (pro_ia);


--
-- Name: rfp pro_wbs_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rfp
    ADD CONSTRAINT pro_wbs_unique UNIQUE (pro_wbs);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (subscription_id);


--
-- Name: voice_file text_file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voice_file
    ADD CONSTRAINT text_file_pkey PRIMARY KEY (file_seq);


--
-- Name: user_info user_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_info
    ADD CONSTRAINT user_info_pkey PRIMARY KEY (user_info_seq);


--
-- Name: thread_id user_session_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.thread_id
    ADD CONSTRAINT user_session_unique UNIQUE (user_session);


--
-- Name: rfp user_session_unique_rfp; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rfp
    ADD CONSTRAINT user_session_unique_rfp UNIQUE (user_session);


--
-- Name: wbs wbs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wbs
    ADD CONSTRAINT wbs_pkey PRIMARY KEY (wbs_seq);


--
-- Name: IDX_session_expire; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_session_expire" ON public.session USING btree (expire);


--
-- Name: ia ia_ia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ia
    ADD CONSTRAINT ia_ia_id_fkey FOREIGN KEY (ia_id) REFERENCES public.rfp(pro_ia);


--
-- Name: payments payments_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(subscription_id);


--
-- Name: wbs wbs_wbs_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wbs
    ADD CONSTRAINT wbs_wbs_id_fkey FOREIGN KEY (wbs_id) REFERENCES public.rfp(pro_wbs);


--
-- PostgreSQL database dump complete
--

