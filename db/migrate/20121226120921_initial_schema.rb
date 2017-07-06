# encoding: utf-8

class InitialSchema < ActiveRecord::Migration
  def up
    execute <<-SQL
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
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;

--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE active_admin_comments (
    id integer NOT NULL,
    resource_id integer NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    body text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    namespace character varying(255)
);


--
-- Name: admin_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_notes_id_seq OWNED BY active_admin_comments.id;


--
-- Name: institutional_videos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE institutional_videos (
    id integer NOT NULL,
    title character varying(255),
    description text,
    video_url character varying(255),
    visible boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: advert_videos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advert_videos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advert_videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advert_videos_id_seq OWNED BY institutional_videos.id;


--
-- Name: backers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE backers (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    reward_id integer,
    value numeric NOT NULL,
    confirmed boolean DEFAULT false NOT NULL,
    confirmed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    anonymous boolean DEFAULT false,
    key text,
    requested_refund boolean DEFAULT false,
    refunded boolean DEFAULT false,
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
    CONSTRAINT backers_value_positive CHECK ((value >= (0)::numeric))
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT categories_name_not_blank CHECK ((length(btrim(name)) > 0))
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    name text NOT NULL,
    user_id integer NOT NULL,
    category_id integer NOT NULL,
    goal numeric NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    about text NOT NULL,
    headline text NOT NULL,
    video_url text NOT NULL,
    image_url text,
    short_url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    can_finish boolean DEFAULT false,
    finished boolean DEFAULT false,
    about_html text,
    visible boolean DEFAULT false,
    rejected boolean DEFAULT false,
    recommended boolean DEFAULT false,
    home_page_comment text,
    successful boolean DEFAULT false,
    permalink character varying(255),
    video_thumbnail text,
    state character varying(255),
    online_days integer DEFAULT 0,
    CONSTRAINT projects_about_not_blank CHECK ((length(btrim(about)) > 0)),
    CONSTRAINT projects_headline_length_within CHECK (((length(headline) >= 1) AND (length(headline) <= 140))),
    CONSTRAINT projects_headline_not_blank CHECK ((length(btrim(headline)) > 0)),
    CONSTRAINT projects_video_url_not_blank CHECK ((length(btrim(video_url)) > 0))
);


--
-- Name: backers_by_category; Type: VIEW; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW backers_by_category AS 
 SELECT to_char(p.expires_at, 'yyyy'::text) AS year, c.name AS category, sum(b.value) AS total_backed, count(DISTINCT b.user_id) AS total_backers
   FROM backers b
   JOIN projects p ON p.id = b.project_id
   JOIN categories c ON c.id = p.category_id
  WHERE b.confirmed
  GROUP BY to_char(p.expires_at, 'yyyy'::text), c.name
  ORDER BY to_char(p.expires_at, 'yyyy'::text), c.name;

--
-- Name: backers_by_payment_choice; Type: VIEW; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW backers_by_payment_choice AS 
 SELECT to_char(p.expires_at, 'yyyy-mm'::text) AS month, backers.payment_method, backers.payment_choice, sum(backers.value) AS total_backed, sum(backers.value) / bbm.total_month_backed AS payment_choice_ratio, sum(
        CASE
            WHEN backers.refunded THEN backers.value
            ELSE NULL::numeric
        END) AS total_refunded, sum(
        CASE
            WHEN backers.refunded THEN backers.value
            ELSE NULL::numeric
        END) / bbm.total_month_backed AS refunded_ratio
   FROM projects p
   JOIN backers ON backers.project_id = p.id
   JOIN ( SELECT to_char(b2.created_at, 'yyyy-mm'::text) AS b2month, sum(b2.value) AS total_month_backed
      FROM backers b2
     WHERE b2.confirmed
     GROUP BY to_char(b2.created_at, 'yyyy-mm'::text)) bbm ON bbm.b2month = to_char(backers.created_at, 'yyyy-mm'::text)
  WHERE backers.confirmed
  GROUP BY to_char(p.expires_at, 'yyyy-mm'::text), bbm.total_month_backed, backers.payment_method, backers.payment_choice
  ORDER BY to_char(p.expires_at, 'yyyy-mm'::text), backers.payment_method, backers.payment_choice;

--
-- Name: backers_by_project; Type: VIEW; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW backers_by_project AS 
 SELECT backers.project_id, sum(backers.value) AS total_backed, max(backers.value) AS max_backed, count(DISTINCT backers.user_id) AS total_backers
   FROM backers
  WHERE backers.confirmed
  GROUP BY backers.project_id;

--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    primary_user_id integer,
    provider text NOT NULL,
    uid text NOT NULL,
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
    credits numeric DEFAULT 0,
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
    CONSTRAINT users_bio_length_within CHECK (((length(bio) >= 0) AND (length(bio) <= 140))),
    CONSTRAINT users_provider_not_blank CHECK ((length(btrim(provider)) > 0)),
    CONSTRAINT users_uid_not_blank CHECK ((length(btrim(uid)) > 0))
);


--
-- Name: backers_by_state; Type: VIEW; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW backers_by_state AS 
 SELECT to_char(p.expires_at, 'yyyy'::text) AS year, NULLIF(u.address_state, ''::text) AS state, sum(b.value) AS total_backed, count(DISTINCT b.user_id) AS total_backers
   FROM backers b
   JOIN projects p ON b.project_id = p.id
   JOIN users u ON u.id = b.user_id
  WHERE b.confirmed
  GROUP BY to_char(p.expires_at, 'yyyy'::text), NULLIF(u.address_state, ''::text)
  ORDER BY to_char(p.expires_at, 'yyyy'::text), NULLIF(u.address_state, ''::text);

--
-- Name: backers_by_year; Type: VIEW; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW backers_by_year AS 
 SELECT to_char(p.expires_at, 'yyyy'::text) AS year, sum(backers.value) AS total_backed, count(DISTINCT backers.user_id) AS total_backers, count(DISTINCT 
        CASE
            WHEN backers.reward_id IS NULL THEN backers.user_id
            ELSE NULL::integer
        END) AS total_backers_without_reward, count(DISTINCT 
        CASE
            WHEN backers.reward_id IS NULL THEN backers.user_id
            ELSE NULL::integer
        END)::numeric / count(DISTINCT backers.user_id)::numeric AS backers_without_reward_ratio, max(backers.value) AS maximum_back
   FROM backers
   JOIN projects p ON backers.project_id = p.id
  WHERE backers.confirmed
  GROUP BY to_char(p.expires_at, 'yyyy'::text);

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
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    title text,
    comment text NOT NULL,
    comment_html text,
    commentable_id integer NOT NULL,
    commentable_type character varying(255) NOT NULL,
    user_id integer NOT NULL,
    project_update boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT comments_comment_not_blank CHECK ((length(btrim(comment)) > 0))
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


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
-- Name: curated_pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE curated_pages (
    id integer NOT NULL,
    name character varying(255),
    description text,
    analytics_id character varying(255),
    logo character varying(255),
    video_url character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    permalink character varying(255),
    visible boolean DEFAULT false,
    site_url character varying(255)
);


--
-- Name: curated_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE curated_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: curated_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE curated_pages_id_seq OWNED BY curated_pages.id;


--
-- Name: notification_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notification_types (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: payment_logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_logs (
    id integer NOT NULL,
    backer_id integer,
    status integer,
    amount double precision,
    payment_status integer,
    moip_id integer,
    payment_method integer,
    payment_type character varying(255),
    consumer_email character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: payment_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_logs_id_seq OWNED BY payment_logs.id;


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
-- Name: paypal_pending; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW paypal_pending AS
    SELECT string_agg((b.id)::text, ','::text) AS string_agg FROM (backers b JOIN paypal_payments p ON ((lower(p.doe_mail) = b.payer_email))) WHERE ((((b.payment_method = 'PayPal'::text) AND (p.status = 'Concluído'::text)) AND (NOT b.confirmed)) AND (to_number(p.valorbruto, '9,99'::text) = b.value));


--
-- Name: project_totals; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_totals AS
    SELECT backers.project_id, sum(backers.value) AS pledged, count(*) AS total_backers FROM backers WHERE (backers.confirmed = true) GROUP BY backers.project_id;


--
-- Name: projects_by_category; Type: VIEW; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW projects_by_category AS 
 SELECT to_char(p.expires_at, 'yyyy'::text) AS year, c.name AS category, count(*) AS total_projects, count(NULLIF(p.successful, false)) AS successful_projects
   FROM projects p
   JOIN categories c ON c.id = p.category_id
  WHERE p.finished
  GROUP BY to_char(p.expires_at, 'yyyy'::text), c.name
  ORDER BY to_char(p.expires_at, 'yyyy'::text), c.name;

--
-- Name: projects_by_state; Type: VIEW; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW projects_by_state AS 
 SELECT to_char(p.expires_at, 'yyyy'::text) AS year, NULLIF(btrim(u.address_state), ''::text) AS uf, count(*) AS total_projects, count(NULLIF(p.successful, false)) AS successful_projects
   FROM projects p
   JOIN users u ON u.id = p.user_id
  WHERE p.finished
  GROUP BY to_char(p.expires_at, 'yyyy'::text), NULLIF(btrim(u.address_state), ''::text)
  ORDER BY to_char(p.expires_at, 'yyyy'::text), NULLIF(btrim(u.address_state), ''::text);

--
-- Name: total_backed_ranges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE total_backed_ranges (
    name text NOT NULL,
    lower numeric,
    upper numeric
);


--
-- Name: projects_by_total_backed_ranges; Type: VIEW; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW projects_by_total_backed_ranges AS 
 SELECT tbr.lower, tbr.upper, count(*) AS count, count(*)::numeric / (( SELECT count(*) AS count
           FROM backers_by_project))::numeric AS ratio
   FROM backers_by_project bp
   JOIN total_backed_ranges tbr ON bp.total_backed >= tbr.lower AND bp.total_backed <= tbr.upper
  GROUP BY tbr.lower, tbr.upper
  ORDER BY tbr.lower;

--
-- Name: projects_by_year; Type: VIEW; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW projects_by_year AS 
 SELECT to_char(p.expires_at, 'yyyy'::text) AS year, count(*) AS total_projects, count(NULLIF(p.successful, false)) AS successful_projects, sum(
        CASE
            WHEN p.successful THEN b.total_backed
            ELSE NULL::numeric
        END) AS successful_total_backed, max(b.total_backed) AS max_total_backed, max(b.max_backed) AS max_backed, max(b.total_backers) AS max_total_backers
   FROM projects p
   LEFT JOIN backers_by_project b ON b.project_id = p.id
  WHERE p.finished
  GROUP BY to_char(p.expires_at, 'yyyy'::text)
  ORDER BY to_char(p.expires_at, 'yyyy'::text);


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
-- Name: projects_managers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects_managers (
    user_id integer,
    project_id integer
);


--
-- Name: recurring_backers_by_year; Type: VIEW; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW recurring_backers_by_year AS 
 SELECT bby.year, trb.total_recurring_backed, bby.total_backed, trb.total_recurring_backed / bby.total_backed AS recurring_backed_ratio, trb.total_recurring_backers, bby.total_backers, trb.total_recurring_backers / bby.total_backers::numeric AS recurring_backers_ratio
   FROM ( SELECT rb.year, sum(rb.total_recurring_backed) AS total_recurring_backed, sum(rb.total_recurring_backers) AS total_recurring_backers
           FROM ( SELECT to_char(backers.created_at, 'yyyy'::text) AS year, sum(backers.value) AS total_recurring_backed, count(DISTINCT backers.user_id) AS total_recurring_backers
                   FROM backers
                  WHERE backers.confirmed
                  GROUP BY to_char(backers.created_at, 'yyyy'::text), backers.user_id
                 HAVING count(*) > 1) rb
          GROUP BY rb.year) trb
   JOIN backers_by_year bby USING (year);

--
-- Name: reward_ranges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reward_ranges (
    name text NOT NULL,
    lower numeric,
    upper numeric
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
    CONSTRAINT rewards_maximum_backers_positive CHECK ((maximum_backers >= 0)),
    CONSTRAINT rewards_minimum_value_positive CHECK ((minimum_value >= (0)::numeric))
);


--
-- Name: rewards_by_range; Type: VIEW; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW rewards_by_range AS 
 SELECT rr.name AS range, count(*) AS count, count(*)::numeric / (( SELECT count(*) AS count
           FROM backers
          WHERE backers.confirmed AND backers.reward_id IS NOT NULL))::numeric AS ratio
   FROM reward_ranges rr
   JOIN rewards r ON r.minimum_value >= rr.lower AND r.minimum_value <= rr.upper
   JOIN backers b ON b.reward_id = r.id
  WHERE b.confirmed
  GROUP BY rr.name, rr.lower
  ORDER BY rr.lower;


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
-- Name: static_contents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE static_contents (
    id integer NOT NULL,
    title character varying(255),
    body text,
    body_html text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: static_contents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE static_contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: static_contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE static_contents_id_seq OWNED BY static_contents.id;


--
-- Name: statistics; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW statistics AS
    SELECT (SELECT count(*) AS count FROM users WHERE (users.primary_user_id IS NULL)) AS total_users, backers_totals.total_backs, backers_totals.total_backers, backers_totals.total_backed, projects_totals.total_projects, projects_totals.total_projects_success, projects_totals.total_projects_online FROM (SELECT count(*) AS total_backs, count(DISTINCT backers.user_id) AS total_backers, sum(backers.value) AS total_backed FROM backers WHERE backers.confirmed) backers_totals, (SELECT count(*) AS total_projects, count(CASE WHEN projects.successful THEN 1 ELSE NULL::integer END) AS total_projects_success, count(CASE WHEN ((projects.finished = false) AND (projects.expires_at >= now())) THEN 1 ELSE NULL::integer END) AS total_projects_online FROM projects WHERE projects.visible) projects_totals;


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
    updated_at timestamp without time zone
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
    SELECT b.user_id AS id, b.user_id, sum(b.value) AS sum, count(*) AS count, sum(CASE WHEN (((NOT p.finished) OR p.successful) AND (NOT b.credits)) THEN (0)::numeric WHEN ((p.finished AND (NOT p.successful)) AND ((b.requested_refund AND (NOT b.credits)) OR (b.credits AND (NOT b.requested_refund)))) THEN (0)::numeric WHEN (((p.finished AND (NOT p.successful)) AND (NOT b.credits)) AND (NOT b.requested_refund)) THEN b.value ELSE (b.value * ((-1))::numeric) END) AS credits FROM (backers b JOIN projects p ON ((b.project_id = p.id))) WHERE (b.confirmed = true) GROUP BY b.user_id;


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
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('admin_notes_id_seq'::regclass);


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

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY configurations ALTER COLUMN id SET DEFAULT nextval('configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY curated_pages ALTER COLUMN id SET DEFAULT nextval('curated_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY institutional_videos ALTER COLUMN id SET DEFAULT nextval('advert_videos_id_seq'::regclass);


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

ALTER TABLE ONLY payment_logs ALTER COLUMN id SET DEFAULT nextval('payment_logs_id_seq'::regclass);


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

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY static_contents ALTER COLUMN id SET DEFAULT nextval('static_contents_id_seq'::regclass);


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
-- Name: admin_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT admin_notes_pkey PRIMARY KEY (id);


--
-- Name: advert_videos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY institutional_videos
    ADD CONSTRAINT advert_videos_pkey PRIMARY KEY (id);


--
-- Name: backers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY backers
    ADD CONSTRAINT backers_pkey PRIMARY KEY (id);


--
-- Name: categories_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_name_unique UNIQUE (name);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY configurations
    ADD CONSTRAINT configurations_pkey PRIMARY KEY (id);


--
-- Name: curated_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY curated_pages
    ADD CONSTRAINT curated_pages_pkey PRIMARY KEY (id);


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
-- Name: payment_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_logs
    ADD CONSTRAINT payment_logs_pkey PRIMARY KEY (id);


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
-- Name: static_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY static_contents
    ADD CONSTRAINT static_contents_pkey PRIMARY KEY (id);


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
-- Name: users_provider_uid_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_provider_uid_unique UNIQUE (provider, uid);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_backers_on_confirmed; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_backers_on_confirmed ON backers USING btree (confirmed);


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

CREATE INDEX index_categories_on_name ON categories USING btree (name);


--
-- Name: index_comments_on_commentable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_commentable_id ON comments USING btree (commentable_id);


--
-- Name: index_comments_on_commentable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_commentable_type ON comments USING btree (commentable_type);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_confirmed_backers_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_confirmed_backers_on_project_id ON backers USING btree (project_id) WHERE confirmed;


--
-- Name: index_curated_pages_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_curated_pages_on_permalink ON curated_pages USING btree (permalink);


--
-- Name: index_notification_types_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_notification_types_on_name ON notification_types USING btree (name);


--
-- Name: index_notifications_on_update_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_update_id ON notifications USING btree (update_id);


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
-- Name: index_users_on_primary_user_id_and_provider; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_primary_user_id_and_provider ON users USING btree (primary_user_id, provider);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_uid ON users USING btree (uid);


--
-- Name: users_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX users_email ON users USING btree (email) WHERE (provider = 'devise'::text);


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
-- Name: comments_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


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
-- Name: users_primary_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_primary_user_id_reference FOREIGN KEY (primary_user_id) REFERENCES users(id);

--
-- PostgreSQL database dump complete
--
    SQL
  end

  def down
  end
end
