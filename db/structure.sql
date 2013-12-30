--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    name text NOT NULL,
    user_id integer NOT NULL,
    category_id integer NOT NULL,
    goal numeric NOT NULL,
    about text NOT NULL,
    headline text NOT NULL,
    video_url text,
    short_url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    about_html text,
    recommended boolean DEFAULT false,
    home_page_comment text,
    permalink text NOT NULL,
    video_thumbnail text,
    state character varying(255),
    online_days integer DEFAULT 0,
    online_date timestamp with time zone,
    how_know text,
    more_links text,
    first_backers text,
    uploaded_image character varying(255),
    video_embed_url character varying(255),
    CONSTRAINT projects_about_not_blank CHECK ((length(btrim(about)) > 0)),
    CONSTRAINT projects_headline_length_within CHECK (((length(headline) >= 1) AND (length(headline) <= 140))),
    CONSTRAINT projects_headline_not_blank CHECK ((length(btrim(headline)) > 0))
);


--
-- Name: expires_at(projects); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION expires_at(projects) RETURNS timestamp with time zone
    LANGUAGE sql
    AS $_$
     SELECT ((((($1.online_date AT TIME ZONE coalesce((SELECT value FROM configurations WHERE name = 'timezone'), 'America/Sao_Paulo') + ($1.online_days || ' days')::interval)  )::date::text || ' 23:59:59')::timestamp AT TIME ZONE coalesce((SELECT value FROM configurations WHERE name = 'timezone'), 'America/Sao_Paulo'))::timestamptz )               
    $_$;


--
-- Name: authorizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authorizations (
    id integer NOT NULL,
    oauth_provider_id integer NOT NULL,
    user_id integer NOT NULL,
    uid text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: authorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authorizations_id_seq OWNED BY authorizations.id;


--
-- Name: backers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE backers (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    reward_id integer,
    value numeric NOT NULL,
    confirmed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    anonymous boolean DEFAULT false,
    key text,
    credits boolean DEFAULT false,
    notified_finish boolean DEFAULT false,
    payment_method text,
    payment_token text,
    payment_id character varying(255),
    payer_name text,
    payer_email text,
    payer_document text,
    address_street text,
    address_number text,
    address_complement text,
    address_neighbourhood text,
    address_zip_code text,
    address_city text,
    address_state text,
    address_phone_number text,
    payment_choice text,
    payment_service_fee numeric,
    state character varying(255),
    CONSTRAINT backers_value_positive CHECK ((value >= (0)::numeric))
);


--
-- Name: rewards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rewards (
    id integer NOT NULL,
    project_id integer NOT NULL,
    minimum_value numeric NOT NULL,
    maximum_backers integer,
    description text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reindex_versions timestamp without time zone,
    row_order integer,
    days_to_delivery integer,
    CONSTRAINT rewards_maximum_backers_positive CHECK ((maximum_backers >= 0)),
    CONSTRAINT rewards_minimum_value_positive CHECK ((minimum_value >= (0)::numeric))
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email text,
    name text,
    nickname text,
    bio text,
    image_url text,
    newsletter boolean DEFAULT false,
    project_updates boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    admin boolean DEFAULT false,
    full_name text,
    address_street text,
    address_number text,
    address_complement text,
    address_neighbourhood text,
    address_city text,
    address_state text,
    address_zip_code text,
    phone_number text,
    locale text DEFAULT 'pt'::text NOT NULL,
    cpf text,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    twitter character varying(255),
    facebook_link character varying(255),
    other_link character varying(255),
    uploaded_image text,
    moip_login character varying(255),
    state_inscription character varying(255),
    CONSTRAINT users_bio_length_within CHECK (((length(bio) >= 0) AND (length(bio) <= 140)))
);


--
-- Name: backer_reports; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW backer_reports AS
    SELECT b.project_id, u.name, b.value, r.minimum_value, r.description, b.payment_method, b.payment_choice, b.payment_service_fee, b.key, (b.created_at)::date AS created_at, (b.confirmed_at)::date AS confirmed_at, u.email, b.payer_email, b.payer_name, COALESCE(b.payer_document, u.cpf) AS cpf, u.address_street, u.address_complement, u.address_number, u.address_neighbourhood, u.address_city, u.address_state, u.address_zip_code, b.state FROM ((backers b JOIN users u ON ((u.id = b.user_id))) LEFT JOIN rewards r ON ((r.id = b.reward_id))) WHERE ((b.state)::text = ANY ((ARRAY['confirmed'::character varying, 'refunded'::character varying, 'requested_refund'::character varying])::text[]));


--
-- Name: configurations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE configurations (
    id integer NOT NULL,
    name text NOT NULL,
    value text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT configurations_name_not_blank CHECK ((length(btrim(name)) > 0))
);


--
-- Name: backer_reports_for_project_owners; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW backer_reports_for_project_owners AS
    SELECT b.project_id, COALESCE(r.id, 0) AS reward_id, r.description AS reward_description, (b.confirmed_at)::date AS confirmed_at, b.value AS back_value, (b.value * (SELECT (configurations.value)::numeric AS value FROM configurations WHERE (configurations.name = 'catarse_fee'::text))) AS service_fee, u.email AS user_email, u.name AS user_name, b.payer_email, b.payment_method, COALESCE(b.address_street, u.address_street) AS street, COALESCE(b.address_complement, u.address_complement) AS complement, COALESCE(b.address_number, u.address_number) AS address_number, COALESCE(b.address_neighbourhood, u.address_neighbourhood) AS neighbourhood, COALESCE(b.address_city, u.address_city) AS city, COALESCE(b.address_state, u.address_state) AS state, COALESCE(b.address_zip_code, u.address_zip_code) AS zip_code, b.anonymous FROM ((backers b JOIN users u ON ((u.id = b.user_id))) LEFT JOIN rewards r ON ((r.id = b.reward_id))) WHERE ((b.state)::text = 'confirmed'::text);


--
-- Name: backers_by_periods; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW backers_by_periods AS
    WITH weeks AS (SELECT (generate_series.generate_series * 7) AS days FROM generate_series(0, 7) generate_series(generate_series)), current_period AS (SELECT 'current_period'::text AS series, sum(b.value) AS sum, (w.days / 7) AS week FROM (backers b RIGHT JOIN weeks w ON ((((b.confirmed_at)::date >= ((('now'::text)::date - w.days) - 7)) AND (b.confirmed_at < (('now'::text)::date - w.days))))) WHERE ((b.state)::text <> ALL ((ARRAY['pending'::character varying, 'canceled'::character varying, 'waiting_confirmation'::character varying, 'deleted'::character varying])::text[])) GROUP BY (w.days / 7)), previous_period AS (SELECT 'previous_period'::text AS series, sum(b.value) AS sum, (w.days / 7) AS week FROM (backers b RIGHT JOIN weeks w ON ((((b.confirmed_at)::date >= (((('now'::text)::date - w.days) - 7) - 56)) AND (b.confirmed_at < ((('now'::text)::date - w.days) - 56))))) WHERE ((b.state)::text <> ALL ((ARRAY['pending'::character varying, 'canceled'::character varying, 'waiting_confirmation'::character varying, 'deleted'::character varying])::text[])) GROUP BY (w.days / 7)), last_year AS (SELECT 'last_year'::text AS series, sum(b.value) AS sum, (w.days / 7) AS week FROM (backers b RIGHT JOIN weeks w ON ((((b.confirmed_at)::date >= (((('now'::text)::date - w.days) - 7) - 365)) AND (b.confirmed_at < ((('now'::text)::date - w.days) - 365))))) WHERE ((b.state)::text <> ALL ((ARRAY['pending'::character varying, 'canceled'::character varying, 'waiting_confirmation'::character varying, 'deleted'::character varying])::text[])) GROUP BY (w.days / 7)) (SELECT current_period.series, current_period.sum, current_period.week FROM current_period UNION ALL SELECT previous_period.series, previous_period.sum, previous_period.week FROM previous_period) UNION ALL SELECT last_year.series, last_year.sum, last_year.week FROM last_year ORDER BY 1, 3;


--
-- Name: backers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE backers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: backers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE backers_id_seq OWNED BY backers.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    name_pt text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name_en character varying(255),
    CONSTRAINT categories_name_not_blank CHECK ((length(btrim(name_pt)) > 0))
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: channels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channels (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    permalink character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    twitter character varying(255),
    facebook character varying(255),
    email character varying(255),
    image character varying(255),
    website character varying(255)
);


--
-- Name: channels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channels_id_seq OWNED BY channels.id;


--
-- Name: channels_projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channels_projects (
    id integer NOT NULL,
    channel_id integer,
    project_id integer
);


--
-- Name: channels_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channels_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channels_projects_id_seq OWNED BY channels_projects.id;


--
-- Name: channels_subscribers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channels_subscribers (
    id integer NOT NULL,
    user_id integer NOT NULL,
    channel_id integer NOT NULL
);


--
-- Name: channels_subscribers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channels_subscribers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_subscribers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channels_subscribers_id_seq OWNED BY channels_subscribers.id;


--
-- Name: channels_trustees; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channels_trustees (
    id integer NOT NULL,
    user_id integer,
    channel_id integer
);


--
-- Name: channels_trustees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channels_trustees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_trustees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channels_trustees_id_seq OWNED BY channels_trustees.id;


--
-- Name: configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE configurations_id_seq OWNED BY configurations.id;


--
-- Name: financial_reports; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW financial_reports AS
    SELECT p.name, u.moip_login, p.goal, expires_at(p.*) AS expires_at, p.state FROM (projects p JOIN users u ON ((u.id = p.user_id)));


--
-- Name: notification_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notification_types (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    layout text DEFAULT 'email'::text NOT NULL
);


--
-- Name: notification_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notification_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notification_types_id_seq OWNED BY notification_types.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer,
    dismissed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    notification_type_id integer NOT NULL,
    backer_id integer,
    update_id integer
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: oauth_providers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_providers (
    id integer NOT NULL,
    name text NOT NULL,
    key text NOT NULL,
    secret text NOT NULL,
    scope text,
    "order" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    strategy text,
    path text,
    CONSTRAINT oauth_providers_key_not_blank CHECK ((length(btrim(key)) > 0)),
    CONSTRAINT oauth_providers_name_not_blank CHECK ((length(btrim(name)) > 0)),
    CONSTRAINT oauth_providers_secret_not_blank CHECK ((length(btrim(secret)) > 0))
);


--
-- Name: oauth_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_providers_id_seq OWNED BY oauth_providers.id;


--
-- Name: payment_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_notifications (
    id integer NOT NULL,
    backer_id integer NOT NULL,
    extra_data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: payment_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_notifications_id_seq OWNED BY payment_notifications.id;


--
-- Name: paypal_payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE paypal_payments (
    data text,
    hora text,
    fusohorario text,
    nome text,
    tipo text,
    status text,
    moeda text,
    valorbruto text,
    tarifa text,
    liquido text,
    doe_mail text,
    parae_mail text,
    iddatransacao text,
    statusdoequivalente text,
    statusdoendereco text,
    titulodoitem text,
    iddoitem text,
    valordoenvioemanuseio text,
    valordoseguro text,
    impostosobrevendas text,
    opcao1nome text,
    opcao1valor text,
    opcao2nome text,
    opcao2valor text,
    sitedoleilao text,
    iddocomprador text,
    urldoitem text,
    datadetermino text,
    iddaescritura text,
    iddafatura text,
    "idtxn_dereferência" text,
    numerodafatura text,
    numeropersonalizado text,
    iddorecibo text,
    saldo text,
    enderecolinha1 text,
    enderecolinha2_distrito_bairro text,
    cidade text,
    "estado_regiao_território_prefeitura_republica" text,
    cep text,
    pais text,
    numerodotelefoneparacontato text,
    extra text
);


--
-- Name: project_totals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_totals AS
    SELECT backers.project_id, sum(backers.value) AS pledged, sum(backers.payment_service_fee) AS total_payment_service_fee, count(*) AS total_backers FROM backers WHERE ((backers.state)::text = ANY ((ARRAY['confirmed'::character varying, 'refunded'::character varying, 'requested_refund'::character varying])::text[])) GROUP BY backers.project_id;


--
-- Name: projects_by_periods; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW projects_by_periods AS
    WITH weeks AS (SELECT (generate_series.generate_series * 7) AS days FROM generate_series(0, 7) generate_series(generate_series)), current_period AS (SELECT 'current_period'::text AS series, count(*) AS count, (w.days / 7) AS week FROM (projects p RIGHT JOIN weeks w ON ((((p.created_at)::date >= ((('now'::text)::date - w.days) - 7)) AND (p.created_at < (('now'::text)::date - w.days))))) GROUP BY (w.days / 7)), previous_period AS (SELECT 'previous_period'::text AS series, count(*) AS count, (w.days / 7) AS week FROM (projects p RIGHT JOIN weeks w ON ((((p.created_at)::date >= (((('now'::text)::date - w.days) - 7) - 56)) AND (p.created_at < ((('now'::text)::date - w.days) - 56))))) GROUP BY (w.days / 7)), last_year AS (SELECT 'last_year'::text AS series, count(*) AS count, (w.days / 7) AS week FROM (projects p RIGHT JOIN weeks w ON ((((p.created_at)::date >= (((('now'::text)::date - w.days) - 7) - 365)) AND (p.created_at < ((('now'::text)::date - w.days) - 365))))) GROUP BY (w.days / 7)) (SELECT current_period.series, current_period.count, current_period.week FROM current_period UNION ALL SELECT previous_period.series, previous_period.count, previous_period.week FROM previous_period) UNION ALL SELECT last_year.series, last_year.count, last_year.week FROM last_year ORDER BY 1, 3;


--
-- Name: projects_curated_pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects_curated_pages (
    id integer NOT NULL,
    project_id integer,
    curated_page_id integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description_html text
);


--
-- Name: projects_curated_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_curated_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_curated_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_curated_pages_id_seq OWNED BY projects_curated_pages.id;


--
-- Name: projects_for_home; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW projects_for_home AS
    WITH recommended_projects AS (SELECT 'recommended'::text AS origin, recommends.id, recommends.name, recommends.user_id, recommends.category_id, recommends.goal, recommends.about, recommends.headline, recommends.video_url, recommends.short_url, recommends.created_at, recommends.updated_at, recommends.about_html, recommends.recommended, recommends.home_page_comment, recommends.permalink, recommends.video_thumbnail, recommends.state, recommends.online_days, recommends.online_date, recommends.how_know, recommends.more_links, recommends.first_backers, recommends.uploaded_image, recommends.video_embed_url FROM projects recommends WHERE (recommends.recommended AND ((recommends.state)::text = 'online'::text)) ORDER BY random() LIMIT 3), recents_projects AS (SELECT 'recents'::text AS origin, recents.id, recents.name, recents.user_id, recents.category_id, recents.goal, recents.about, recents.headline, recents.video_url, recents.short_url, recents.created_at, recents.updated_at, recents.about_html, recents.recommended, recents.home_page_comment, recents.permalink, recents.video_thumbnail, recents.state, recents.online_days, recents.online_date, recents.how_know, recents.more_links, recents.first_backers, recents.uploaded_image, recents.video_embed_url FROM projects recents WHERE ((((recents.state)::text = 'online'::text) AND ((now() - recents.online_date) <= '5 days'::interval)) AND (NOT (recents.id IN (SELECT recommends.id FROM recommended_projects recommends)))) ORDER BY random() LIMIT 3), expiring_projects AS (SELECT 'expiring'::text AS origin, expiring.id, expiring.name, expiring.user_id, expiring.category_id, expiring.goal, expiring.about, expiring.headline, expiring.video_url, expiring.short_url, expiring.created_at, expiring.updated_at, expiring.about_html, expiring.recommended, expiring.home_page_comment, expiring.permalink, expiring.video_thumbnail, expiring.state, expiring.online_days, expiring.online_date, expiring.how_know, expiring.more_links, expiring.first_backers, expiring.uploaded_image, expiring.video_embed_url FROM projects expiring WHERE ((((expiring.state)::text = 'online'::text) AND (expires_at(expiring.*) <= (now() + '14 days'::interval))) AND (NOT (expiring.id IN (SELECT recommends.id FROM recommended_projects recommends UNION SELECT recents.id FROM recents_projects recents)))) ORDER BY random() LIMIT 3) (SELECT recommended_projects.origin, recommended_projects.id, recommended_projects.name, recommended_projects.user_id, recommended_projects.category_id, recommended_projects.goal, recommended_projects.about, recommended_projects.headline, recommended_projects.video_url, recommended_projects.short_url, recommended_projects.created_at, recommended_projects.updated_at, recommended_projects.about_html, recommended_projects.recommended, recommended_projects.home_page_comment, recommended_projects.permalink, recommended_projects.video_thumbnail, recommended_projects.state, recommended_projects.online_days, recommended_projects.online_date, recommended_projects.how_know, recommended_projects.more_links, recommended_projects.first_backers, recommended_projects.uploaded_image, recommended_projects.video_embed_url FROM recommended_projects UNION SELECT recents_projects.origin, recents_projects.id, recents_projects.name, recents_projects.user_id, recents_projects.category_id, recents_projects.goal, recents_projects.about, recents_projects.headline, recents_projects.video_url, recents_projects.short_url, recents_projects.created_at, recents_projects.updated_at, recents_projects.about_html, recents_projects.recommended, recents_projects.home_page_comment, recents_projects.permalink, recents_projects.video_thumbnail, recents_projects.state, recents_projects.online_days, recents_projects.online_date, recents_projects.how_know, recents_projects.more_links, recents_projects.first_backers, recents_projects.uploaded_image, recents_projects.video_embed_url FROM recents_projects) UNION SELECT expiring_projects.origin, expiring_projects.id, expiring_projects.name, expiring_projects.user_id, expiring_projects.category_id, expiring_projects.goal, expiring_projects.about, expiring_projects.headline, expiring_projects.video_url, expiring_projects.short_url, expiring_projects.created_at, expiring_projects.updated_at, expiring_projects.about_html, expiring_projects.recommended, expiring_projects.home_page_comment, expiring_projects.permalink, expiring_projects.video_thumbnail, expiring_projects.state, expiring_projects.online_days, expiring_projects.online_date, expiring_projects.how_know, expiring_projects.more_links, expiring_projects.first_backers, expiring_projects.uploaded_image, expiring_projects.video_embed_url FROM expiring_projects;


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: recommendations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW recommendations AS
    SELECT recommendations.user_id, recommendations.project_id, recommendations.count FROM (SELECT b.user_id, recommendations.id AS project_id, count(DISTINCT recommenders.user_id) AS count FROM ((((backers b JOIN projects p ON ((p.id = b.project_id))) JOIN backers backers_same_projects ON ((p.id = backers_same_projects.project_id))) JOIN backers recommenders ON ((recommenders.user_id = backers_same_projects.user_id))) JOIN projects recommendations ON ((recommendations.id = recommenders.project_id))) WHERE ((((((((b.state)::text = 'confirmed'::text) AND ((backers_same_projects.state)::text = 'confirmed'::text)) AND ((recommenders.state)::text = 'confirmed'::text)) AND (b.user_id <> backers_same_projects.user_id)) AND (recommendations.id <> b.project_id)) AND ((recommendations.state)::text = 'online'::text)) AND (NOT (EXISTS (SELECT true AS bool FROM backers b2 WHERE ((((b2.state)::text = 'confirmed'::text) AND (b2.user_id = b.user_id)) AND (b2.project_id = recommendations.id)))))) GROUP BY b.user_id, recommendations.id UNION SELECT b.user_id, recommendations.id AS project_id, 0 AS count FROM ((backers b JOIN projects p ON ((b.project_id = p.id))) JOIN projects recommendations ON ((recommendations.category_id = p.category_id))) WHERE ((b.state)::text = 'confirmed'::text)) recommendations WHERE (NOT (EXISTS (SELECT true AS bool FROM backers b2 WHERE ((((b2.state)::text = 'confirmed'::text) AND (b2.user_id = recommendations.user_id)) AND (b2.project_id = recommendations.project_id))))) ORDER BY recommendations.count DESC;


--
-- Name: reward_ranges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reward_ranges (
    name text NOT NULL,
    lower numeric,
    upper numeric
);


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE states (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    acronym character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT states_acronym_not_blank CHECK ((length(btrim((acronym)::text)) > 0)),
    CONSTRAINT states_name_not_blank CHECK ((length(btrim((name)::text)) > 0))
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: statistics; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW statistics AS
    SELECT (SELECT count(*) AS count FROM users) AS total_users, backers_totals.total_backs, backers_totals.total_backers, backers_totals.total_backed, projects_totals.total_projects, projects_totals.total_projects_success, projects_totals.total_projects_online FROM (SELECT count(*) AS total_backs, count(DISTINCT backers.user_id) AS total_backers, sum(backers.value) AS total_backed FROM backers WHERE ((backers.state)::text <> ALL (ARRAY[('waiting_confirmation'::character varying)::text, ('pending'::character varying)::text, ('canceled'::character varying)::text, 'deleted'::text]))) backers_totals, (SELECT count(*) AS total_projects, count(CASE WHEN ((projects.state)::text = 'successful'::text) THEN 1 ELSE NULL::integer END) AS total_projects_success, count(CASE WHEN ((projects.state)::text = 'online'::text) THEN 1 ELSE NULL::integer END) AS total_projects_online FROM projects WHERE ((projects.state)::text <> ALL (ARRAY[('draft'::character varying)::text, ('rejected'::character varying)::text]))) projects_totals;


--
-- Name: subscriber_reports; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW subscriber_reports AS
    SELECT u.id, cs.channel_id, u.name, u.email FROM (users u JOIN channels_subscribers cs ON ((cs.user_id = u.id)));


--
-- Name: total_backed_ranges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE total_backed_ranges (
    name text NOT NULL,
    lower numeric,
    upper numeric
);


--
-- Name: unsubscribes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE unsubscribes (
    id integer NOT NULL,
    user_id integer NOT NULL,
    notification_type_id integer NOT NULL,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: unsubscribes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE unsubscribes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unsubscribes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE unsubscribes_id_seq OWNED BY unsubscribes.id;


--
-- Name: updates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE updates (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer NOT NULL,
    title text,
    comment text NOT NULL,
    comment_html text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    exclusive boolean DEFAULT false
);


--
-- Name: updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE updates_id_seq OWNED BY updates.id;


--
-- Name: user_totals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW user_totals AS
    SELECT b.user_id AS id, b.user_id, count(DISTINCT b.project_id) AS total_backed_projects, sum(b.value) AS sum, count(*) AS count, sum(CASE WHEN (((p.state)::text <> 'failed'::text) AND (NOT b.credits)) THEN (0)::numeric WHEN (((p.state)::text = 'failed'::text) AND b.credits) THEN (0)::numeric WHEN (((p.state)::text = 'failed'::text) AND ((((b.state)::text = ANY ((ARRAY['requested_refund'::character varying, 'refunded'::character varying])::text[])) AND (NOT b.credits)) OR (b.credits AND (NOT ((b.state)::text = ANY ((ARRAY['requested_refund'::character varying, 'refunded'::character varying])::text[])))))) THEN (0)::numeric WHEN ((((p.state)::text = 'failed'::text) AND (NOT b.credits)) AND ((b.state)::text = 'confirmed'::text)) THEN b.value ELSE (b.value * ((-1))::numeric) END) AS credits FROM (backers b JOIN projects p ON ((b.project_id = p.id))) WHERE ((b.state)::text = ANY ((ARRAY['confirmed'::character varying, 'requested_refund'::character varying, 'refunded'::character varying])::text[])) GROUP BY b.user_id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations ALTER COLUMN id SET DEFAULT nextval('authorizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY backers ALTER COLUMN id SET DEFAULT nextval('backers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels ALTER COLUMN id SET DEFAULT nextval('channels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_projects ALTER COLUMN id SET DEFAULT nextval('channels_projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_subscribers ALTER COLUMN id SET DEFAULT nextval('channels_subscribers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_trustees ALTER COLUMN id SET DEFAULT nextval('channels_trustees_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY configurations ALTER COLUMN id SET DEFAULT nextval('configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notification_types ALTER COLUMN id SET DEFAULT nextval('notification_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_providers ALTER COLUMN id SET DEFAULT nextval('oauth_providers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_notifications ALTER COLUMN id SET DEFAULT nextval('payment_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects_curated_pages ALTER COLUMN id SET DEFAULT nextval('projects_curated_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes ALTER COLUMN id SET DEFAULT nextval('unsubscribes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY updates ALTER COLUMN id SET DEFAULT nextval('updates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT authorizations_pkey PRIMARY KEY (id);


--
-- Name: backers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY backers
    ADD CONSTRAINT backers_pkey PRIMARY KEY (id);


--
-- Name: categories_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_name_unique UNIQUE (name_pt);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: channel_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channels
    ADD CONSTRAINT channel_profiles_pkey PRIMARY KEY (id);


--
-- Name: channels_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT channels_projects_pkey PRIMARY KEY (id);


--
-- Name: channels_subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT channels_subscribers_pkey PRIMARY KEY (id);


--
-- Name: channels_trustees_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channels_trustees
    ADD CONSTRAINT channels_trustees_pkey PRIMARY KEY (id);


--
-- Name: configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY configurations
    ADD CONSTRAINT configurations_pkey PRIMARY KEY (id);


--
-- Name: notification_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notification_types
    ADD CONSTRAINT notification_types_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_providers_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_providers
    ADD CONSTRAINT oauth_providers_name_unique UNIQUE (name);


--
-- Name: oauth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_providers
    ADD CONSTRAINT oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: payment_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_notifications
    ADD CONSTRAINT payment_notifications_pkey PRIMARY KEY (id);


--
-- Name: projects_curated_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects_curated_pages
    ADD CONSTRAINT projects_curated_pages_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: reward_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reward_ranges
    ADD CONSTRAINT reward_ranges_pkey PRIMARY KEY (name);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: states_acronym_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_acronym_unique UNIQUE (acronym);


--
-- Name: states_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_name_unique UNIQUE (name);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: total_backed_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY total_backed_ranges
    ADD CONSTRAINT total_backed_ranges_pkey PRIMARY KEY (name);


--
-- Name: unsubscribes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_pkey PRIMARY KEY (id);


--
-- Name: updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: fk__authorizations_oauth_provider_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__authorizations_oauth_provider_id ON authorizations USING btree (oauth_provider_id);


--
-- Name: fk__authorizations_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__authorizations_user_id ON authorizations USING btree (user_id);


--
-- Name: fk__channels_subscribers_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channels_subscribers_channel_id ON channels_subscribers USING btree (channel_id);


--
-- Name: fk__channels_subscribers_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channels_subscribers_user_id ON channels_subscribers USING btree (user_id);


--
-- Name: index_authorizations_on_uid_and_oauth_provider_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_authorizations_on_uid_and_oauth_provider_id ON authorizations USING btree (uid, oauth_provider_id);


--
-- Name: index_backers_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_backers_on_key ON backers USING btree (key);


--
-- Name: index_backers_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_backers_on_project_id ON backers USING btree (project_id);


--
-- Name: index_backers_on_reward_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_backers_on_reward_id ON backers USING btree (reward_id);


--
-- Name: index_backers_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_backers_on_user_id ON backers USING btree (user_id);


--
-- Name: index_categories_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_name ON categories USING btree (name_pt);


--
-- Name: index_channels_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_on_permalink ON channels USING btree (permalink);


--
-- Name: index_channels_projects_on_channel_id_and_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_projects_on_channel_id_and_project_id ON channels_projects USING btree (channel_id, project_id);


--
-- Name: index_channels_projects_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_channels_projects_on_project_id ON channels_projects USING btree (project_id);


--
-- Name: index_channels_subscribers_on_user_id_and_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_subscribers_on_user_id_and_channel_id ON channels_subscribers USING btree (user_id, channel_id);


--
-- Name: index_channels_trustees_on_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_channels_trustees_on_channel_id ON channels_trustees USING btree (channel_id);


--
-- Name: index_channels_trustees_on_user_id_and_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_trustees_on_user_id_and_channel_id ON channels_trustees USING btree (user_id, channel_id);


--
-- Name: index_configurations_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_configurations_on_name ON configurations USING btree (name);


--
-- Name: index_notification_types_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_notification_types_on_name ON notification_types USING btree (name);


--
-- Name: index_notifications_on_update_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_update_id ON notifications USING btree (update_id);


--
-- Name: index_payment_notifications_on_backer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payment_notifications_on_backer_id ON payment_notifications USING btree (backer_id);


--
-- Name: index_projects_on_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_category_id ON projects USING btree (category_id);


--
-- Name: index_projects_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_name ON projects USING btree (name);


--
-- Name: index_projects_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_permalink ON projects USING btree (permalink);


--
-- Name: index_projects_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_user_id ON projects USING btree (user_id);


--
-- Name: index_rewards_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rewards_on_project_id ON rewards USING btree (project_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_unsubscribes_on_notification_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_notification_type_id ON unsubscribes USING btree (notification_type_id);


--
-- Name: index_unsubscribes_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_project_id ON unsubscribes USING btree (project_id);


--
-- Name: index_unsubscribes_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_user_id ON unsubscribes USING btree (user_id);


--
-- Name: index_updates_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_updates_on_project_id ON updates USING btree (project_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_name ON users USING btree (name);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: backers_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY backers
    ADD CONSTRAINT backers_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: backers_reward_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY backers
    ADD CONSTRAINT backers_reward_id_reference FOREIGN KEY (reward_id) REFERENCES rewards(id);


--
-- Name: backers_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY backers
    ADD CONSTRAINT backers_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_authorizations_oauth_provider_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT fk_authorizations_oauth_provider_id FOREIGN KEY (oauth_provider_id) REFERENCES oauth_providers(id);


--
-- Name: fk_authorizations_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT fk_authorizations_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_channels_projects_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT fk_channels_projects_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channels_projects_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT fk_channels_projects_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_channels_subscribers_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT fk_channels_subscribers_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channels_subscribers_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT fk_channels_subscribers_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_channels_trustees_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_trustees
    ADD CONSTRAINT fk_channels_trustees_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channels_trustees_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_trustees
    ADD CONSTRAINT fk_channels_trustees_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: notifications_backer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_backer_id_fk FOREIGN KEY (backer_id) REFERENCES backers(id);


--
-- Name: notifications_notification_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_notification_type_id_fk FOREIGN KEY (notification_type_id) REFERENCES notification_types(id);


--
-- Name: notifications_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: notifications_update_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_update_id_fk FOREIGN KEY (update_id) REFERENCES updates(id);


--
-- Name: notifications_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: payment_notifications_backer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_notifications
    ADD CONSTRAINT payment_notifications_backer_id_fk FOREIGN KEY (backer_id) REFERENCES backers(id);


--
-- Name: projects_category_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_category_id_reference FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: projects_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: rewards_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: unsubscribes_notification_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_notification_type_id_fk FOREIGN KEY (notification_type_id) REFERENCES notification_types(id);


--
-- Name: unsubscribes_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: unsubscribes_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: updates_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: updates_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20121226120921');

INSERT INTO schema_migrations (version) VALUES ('20121227012003');

INSERT INTO schema_migrations (version) VALUES ('20121227012324');

INSERT INTO schema_migrations (version) VALUES ('20121230111351');

INSERT INTO schema_migrations (version) VALUES ('20130102180139');

INSERT INTO schema_migrations (version) VALUES ('20130104005632');

INSERT INTO schema_migrations (version) VALUES ('20130104104501');

INSERT INTO schema_migrations (version) VALUES ('20130105123546');

INSERT INTO schema_migrations (version) VALUES ('20130110191750');

INSERT INTO schema_migrations (version) VALUES ('20130117205659');

INSERT INTO schema_migrations (version) VALUES ('20130118193907');

INSERT INTO schema_migrations (version) VALUES ('20130121162447');

INSERT INTO schema_migrations (version) VALUES ('20130121204224');

INSERT INTO schema_migrations (version) VALUES ('20130121212325');

INSERT INTO schema_migrations (version) VALUES ('20130131121553');

INSERT INTO schema_migrations (version) VALUES ('20130201200604');

INSERT INTO schema_migrations (version) VALUES ('20130201202648');

INSERT INTO schema_migrations (version) VALUES ('20130201202829');

INSERT INTO schema_migrations (version) VALUES ('20130201205659');

INSERT INTO schema_migrations (version) VALUES ('20130204192704');

INSERT INTO schema_migrations (version) VALUES ('20130205143533');

INSERT INTO schema_migrations (version) VALUES ('20130206121758');

INSERT INTO schema_migrations (version) VALUES ('20130211174609');

INSERT INTO schema_migrations (version) VALUES ('20130212145115');

INSERT INTO schema_migrations (version) VALUES ('20130213184141');

INSERT INTO schema_migrations (version) VALUES ('20130218201312');

INSERT INTO schema_migrations (version) VALUES ('20130218201751');

INSERT INTO schema_migrations (version) VALUES ('20130221171018');

INSERT INTO schema_migrations (version) VALUES ('20130221172840');

INSERT INTO schema_migrations (version) VALUES ('20130221175717');

INSERT INTO schema_migrations (version) VALUES ('20130221184144');

INSERT INTO schema_migrations (version) VALUES ('20130221185532');

INSERT INTO schema_migrations (version) VALUES ('20130221201732');

INSERT INTO schema_migrations (version) VALUES ('20130222163633');

INSERT INTO schema_migrations (version) VALUES ('20130225135512');

INSERT INTO schema_migrations (version) VALUES ('20130225141802');

INSERT INTO schema_migrations (version) VALUES ('20130228141234');

INSERT INTO schema_migrations (version) VALUES ('20130304193806');

INSERT INTO schema_migrations (version) VALUES ('20130307074614');

INSERT INTO schema_migrations (version) VALUES ('20130307090153');

INSERT INTO schema_migrations (version) VALUES ('20130308200907');

INSERT INTO schema_migrations (version) VALUES ('20130311191444');

INSERT INTO schema_migrations (version) VALUES ('20130311192846');

INSERT INTO schema_migrations (version) VALUES ('20130312001021');

INSERT INTO schema_migrations (version) VALUES ('20130313032607');

INSERT INTO schema_migrations (version) VALUES ('20130313034356');

INSERT INTO schema_migrations (version) VALUES ('20130319131919');

INSERT INTO schema_migrations (version) VALUES ('20130410181958');

INSERT INTO schema_migrations (version) VALUES ('20130410190247');

INSERT INTO schema_migrations (version) VALUES ('20130410191240');

INSERT INTO schema_migrations (version) VALUES ('20130411193016');

INSERT INTO schema_migrations (version) VALUES ('20130419184530');

INSERT INTO schema_migrations (version) VALUES ('20130422071805');

INSERT INTO schema_migrations (version) VALUES ('20130422072051');

INSERT INTO schema_migrations (version) VALUES ('20130423162359');

INSERT INTO schema_migrations (version) VALUES ('20130424173128');

INSERT INTO schema_migrations (version) VALUES ('20130426204503');

INSERT INTO schema_migrations (version) VALUES ('20130429142823');

INSERT INTO schema_migrations (version) VALUES ('20130429144749');

INSERT INTO schema_migrations (version) VALUES ('20130429153115');

INSERT INTO schema_migrations (version) VALUES ('20130430203333');

INSERT INTO schema_migrations (version) VALUES ('20130502175814');

INSERT INTO schema_migrations (version) VALUES ('20130505013655');

INSERT INTO schema_migrations (version) VALUES ('20130506191243');

INSERT INTO schema_migrations (version) VALUES ('20130506191508');

INSERT INTO schema_migrations (version) VALUES ('20130514132519');

INSERT INTO schema_migrations (version) VALUES ('20130514185010');

INSERT INTO schema_migrations (version) VALUES ('20130514185116');

INSERT INTO schema_migrations (version) VALUES ('20130514185926');

INSERT INTO schema_migrations (version) VALUES ('20130515192404');

INSERT INTO schema_migrations (version) VALUES ('20130523144013');

INSERT INTO schema_migrations (version) VALUES ('20130523173609');

INSERT INTO schema_migrations (version) VALUES ('20130527204639');

INSERT INTO schema_migrations (version) VALUES ('20130529171845');

INSERT INTO schema_migrations (version) VALUES ('20130604171730');

INSERT INTO schema_migrations (version) VALUES ('20130604172253');

INSERT INTO schema_migrations (version) VALUES ('20130604175953');

INSERT INTO schema_migrations (version) VALUES ('20130604180503');

INSERT INTO schema_migrations (version) VALUES ('20130607222330');

INSERT INTO schema_migrations (version) VALUES ('20130617175402');

INSERT INTO schema_migrations (version) VALUES ('20130618175432');

INSERT INTO schema_migrations (version) VALUES ('20130626122439');

INSERT INTO schema_migrations (version) VALUES ('20130626124055');

INSERT INTO schema_migrations (version) VALUES ('20130702192659');

INSERT INTO schema_migrations (version) VALUES ('20130703171547');

INSERT INTO schema_migrations (version) VALUES ('20130705131825');

INSERT INTO schema_migrations (version) VALUES ('20130705184845');

INSERT INTO schema_migrations (version) VALUES ('20130710122804');

INSERT INTO schema_migrations (version) VALUES ('20130722222945');

INSERT INTO schema_migrations (version) VALUES ('20130730232043');

INSERT INTO schema_migrations (version) VALUES ('20130805230126');

INSERT INTO schema_migrations (version) VALUES ('20130812191450');

INSERT INTO schema_migrations (version) VALUES ('20130814174329');

INSERT INTO schema_migrations (version) VALUES ('20130815161926');

INSERT INTO schema_migrations (version) VALUES ('20130818015857');

INSERT INTO schema_migrations (version) VALUES ('20130822215532');

INSERT INTO schema_migrations (version) VALUES ('20130827210414');

INSERT INTO schema_migrations (version) VALUES ('20130828160026');

INSERT INTO schema_migrations (version) VALUES ('20130829180232');

INSERT INTO schema_migrations (version) VALUES ('20130905153553');

INSERT INTO schema_migrations (version) VALUES ('20130911180657');