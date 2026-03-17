--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

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
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tiger;


--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tiger_data;


--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA topology;


--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: address_standardizer; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS address_standardizer WITH SCHEMA public;


--
-- Name: EXTENSION address_standardizer; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION address_standardizer IS 'Used to parse an address into constituent elements. Generally used to support geocoding address normalization step.';


--
-- Name: address_standardizer_data_us; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS address_standardizer_data_us WITH SCHEMA public;


--
-- Name: EXTENSION address_standardizer_data_us; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION address_standardizer_data_us IS 'Address Standardizer US dataset example';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: h3; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS h3 WITH SCHEMA public;


--
-- Name: EXTENSION h3; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION h3 IS 'H3 bindings for PostgreSQL';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_raster; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;


--
-- Name: EXTENSION postgis_raster; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';


--
-- Name: h3_postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS h3_postgis WITH SCHEMA public;


--
-- Name: EXTENSION h3_postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION h3_postgis IS 'H3 PostGIS integration';


--
-- Name: ogr_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ogr_fdw WITH SCHEMA public;


--
-- Name: EXTENSION ogr_fdw; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION ogr_fdw IS 'foreign-data wrapper for GIS data access';


--
-- Name: pgrouting; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgrouting WITH SCHEMA public;


--
-- Name: EXTENSION pgrouting; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgrouting IS 'pgRouting Extension';


--
-- Name: pointcloud; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pointcloud WITH SCHEMA public;


--
-- Name: EXTENSION pointcloud; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pointcloud IS 'data type for lidar point clouds';


--
-- Name: pointcloud_postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pointcloud_postgis WITH SCHEMA public;


--
-- Name: EXTENSION pointcloud_postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pointcloud_postgis IS 'integration for pointcloud LIDAR data and PostGIS geometry data';


--
-- Name: postgis_sfcgal; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_sfcgal WITH SCHEMA public;


--
-- Name: EXTENSION postgis_sfcgal; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_sfcgal IS 'PostGIS SFCGAL functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    username character varying(150) NOT NULL,
    password character varying(128) NOT NULL,
    email character varying(254),
    first_name character varying(150),
    last_name character varying(150),
    is_active boolean DEFAULT true,
    is_staff boolean DEFAULT false,
    is_superuser boolean DEFAULT false,
    last_login timestamp without time zone,
    date_joined timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auth_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auth_user_id_seq OWNED BY public.auth_user.id;


--
-- Name: lkp_accessibility_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_accessibility_type (
    access_id integer NOT NULL,
    access_name character varying(50) NOT NULL,
    description text,
    requires_permit boolean DEFAULT false,
    requires_fee boolean DEFAULT false
);


--
-- Name: lkp_accessibility_type_access_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_accessibility_type_access_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_accessibility_type_access_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_accessibility_type_access_id_seq OWNED BY public.lkp_accessibility_type.access_id;


--
-- Name: lkp_activity_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_activity_category (
    category_id integer NOT NULL,
    category_name character varying(50) NOT NULL,
    description text,
    requires_special_skill boolean DEFAULT false
);


--
-- Name: lkp_activity_category_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_activity_category_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_activity_category_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_activity_category_category_id_seq OWNED BY public.lkp_activity_category.category_id;


--
-- Name: lkp_activity_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_activity_status (
    status_id integer NOT NULL,
    status_name character varying(50) NOT NULL,
    status_code character varying(10),
    description text,
    is_terminal boolean DEFAULT false,
    can_edit boolean DEFAULT true
);


--
-- Name: lkp_activity_status_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_activity_status_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_activity_status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_activity_status_status_id_seq OWNED BY public.lkp_activity_status.status_id;


--
-- Name: lkp_activity_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_activity_type (
    activity_type_id integer NOT NULL,
    activity_name character varying(100) NOT NULL,
    activity_name_amharic character varying(100),
    category_id integer,
    typical_duration_hours numeric(5,2),
    typical_crew_size integer,
    requires_supervision boolean DEFAULT true,
    safety_gear_required text,
    equipment_needed text,
    season_preference character varying(50),
    frequency_default_id integer
);


--
-- Name: lkp_activity_type_activity_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_activity_type_activity_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_activity_type_activity_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_activity_type_activity_type_id_seq OWNED BY public.lkp_activity_type.activity_type_id;


--
-- Name: lkp_budget_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_budget_category (
    category_id integer NOT NULL,
    category_name character varying(100) NOT NULL,
    category_code character varying(20),
    description text
);


--
-- Name: lkp_budget_category_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_budget_category_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_budget_category_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_budget_category_category_id_seq OWNED BY public.lkp_budget_category.category_id;


--
-- Name: lkp_budget_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_budget_source (
    source_id integer NOT NULL,
    source_name character varying(100) NOT NULL,
    source_type character varying(50),
    description text
);


--
-- Name: lkp_budget_source_source_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_budget_source_source_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_budget_source_source_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_budget_source_source_id_seq OWNED BY public.lkp_budget_source.source_id;


--
-- Name: lkp_citizen_report_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_citizen_report_status (
    status_id integer NOT NULL,
    status_name character varying(50) NOT NULL,
    status_name_amharic character varying(100),
    description text,
    is_visible_to_public boolean DEFAULT true
);


--
-- Name: lkp_citizen_report_status_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_citizen_report_status_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_citizen_report_status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_citizen_report_status_status_id_seq OWNED BY public.lkp_citizen_report_status.status_id;


--
-- Name: lkp_citizen_report_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_citizen_report_type (
    report_type_id integer NOT NULL,
    report_type_name character varying(100) NOT NULL,
    report_type_name_amharic character varying(100),
    category character varying(50),
    default_priority_id integer,
    estimated_response_days integer
);


--
-- Name: lkp_citizen_report_type_report_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_citizen_report_type_report_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_citizen_report_type_report_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_citizen_report_type_report_type_id_seq OWNED BY public.lkp_citizen_report_type.report_type_id;


--
-- Name: lkp_component_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_component_type (
    component_type_id integer NOT NULL,
    component_name character varying(100) NOT NULL,
    component_category character varying(50),
    typical_lifespan_years integer,
    requires_regular_inspection boolean DEFAULT true,
    inspection_frequency_days integer
);


--
-- Name: lkp_component_type_component_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_component_type_component_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_component_type_component_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_component_type_component_type_id_seq OWNED BY public.lkp_component_type.component_type_id;


--
-- Name: lkp_condition_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_condition_status (
    status_id integer NOT NULL,
    status_name character varying(50) NOT NULL,
    status_code character varying(10),
    description text,
    color_code character varying(7),
    requires_immediate_action boolean DEFAULT false,
    maintenance_priority integer
);


--
-- Name: lkp_condition_status_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_condition_status_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_condition_status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_condition_status_status_id_seq OWNED BY public.lkp_condition_status.status_id;


--
-- Name: lkp_ethiopia_ugi_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_ethiopia_ugi_type (
    ugi_type_id integer NOT NULL,
    type_name character varying(100) NOT NULL,
    type_category character varying(50),
    amharic_name character varying(100),
    description text,
    minimum_area_sq_m numeric(10,2),
    requires_fencing boolean DEFAULT false,
    requires_lighting boolean DEFAULT false,
    requires_irrigation boolean DEFAULT false,
    maintenance_priority integer DEFAULT 3
);


--
-- Name: lkp_ethiopia_ugi_type_ugi_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_ethiopia_ugi_type_ugi_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_ethiopia_ugi_type_ugi_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_ethiopia_ugi_type_ugi_type_id_seq OWNED BY public.lkp_ethiopia_ugi_type.ugi_type_id;


--
-- Name: lkp_finding_priority; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_finding_priority (
    priority_id integer NOT NULL,
    priority_name character varying(50) NOT NULL,
    response_time_hours integer,
    color_code character varying(7),
    requires_immediate_action boolean DEFAULT false
);


--
-- Name: lkp_finding_priority_priority_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_finding_priority_priority_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_finding_priority_priority_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_finding_priority_priority_id_seq OWNED BY public.lkp_finding_priority.priority_id;


--
-- Name: lkp_fiscal_year; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_fiscal_year (
    fiscal_year_id integer NOT NULL,
    fiscal_year_name character varying(9) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    is_current boolean DEFAULT false,
    description text
);


--
-- Name: lkp_fiscal_year_fiscal_year_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_fiscal_year_fiscal_year_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_fiscal_year_fiscal_year_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_fiscal_year_fiscal_year_id_seq OWNED BY public.lkp_fiscal_year.fiscal_year_id;


--
-- Name: lkp_frequency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_frequency (
    frequency_id integer NOT NULL,
    frequency_name character varying(50) NOT NULL,
    days_interval integer,
    times_per_year numeric(5,2),
    description text
);


--
-- Name: lkp_frequency_frequency_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_frequency_frequency_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_frequency_frequency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_frequency_frequency_id_seq OWNED BY public.lkp_frequency.frequency_id;


--
-- Name: lkp_inspection_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_inspection_status (
    status_id integer NOT NULL,
    status_name character varying(50) NOT NULL,
    description text,
    allows_editing boolean DEFAULT true
);


--
-- Name: lkp_inspection_status_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_inspection_status_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_inspection_status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_inspection_status_status_id_seq OWNED BY public.lkp_inspection_status.status_id;


--
-- Name: lkp_inspection_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_inspection_type (
    inspection_type_id integer NOT NULL,
    inspection_name character varying(100) NOT NULL,
    description text,
    typical_frequency_id integer,
    requires_tools boolean DEFAULT false,
    requires_certification boolean DEFAULT false
);


--
-- Name: lkp_inspection_type_inspection_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_inspection_type_inspection_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_inspection_type_inspection_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_inspection_type_inspection_type_id_seq OWNED BY public.lkp_inspection_type.inspection_type_id;


--
-- Name: lkp_issue_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_issue_category (
    category_id integer NOT NULL,
    category_name character varying(100) NOT NULL,
    description text,
    default_priority_id integer
);


--
-- Name: lkp_issue_category_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_issue_category_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_issue_category_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_issue_category_category_id_seq OWNED BY public.lkp_issue_category.category_id;


--
-- Name: lkp_issue_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_issue_status (
    status_id integer NOT NULL,
    status_name character varying(50) NOT NULL,
    description text,
    is_closed boolean DEFAULT false
);


--
-- Name: lkp_issue_status_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_issue_status_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_issue_status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_issue_status_status_id_seq OWNED BY public.lkp_issue_status.status_id;


--
-- Name: lkp_job_title; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_job_title (
    job_title_id integer NOT NULL,
    job_title_name character varying(100) NOT NULL,
    job_category character varying(50),
    pay_grade character varying(20),
    requires_certification boolean DEFAULT false,
    requires_license boolean DEFAULT false
);


--
-- Name: lkp_job_title_job_title_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_job_title_job_title_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_job_title_job_title_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_job_title_job_title_id_seq OWNED BY public.lkp_job_title.job_title_id;


--
-- Name: lkp_land_use_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_land_use_type (
    land_use_id integer NOT NULL,
    land_use_name character varying(100) NOT NULL,
    land_use_category character varying(50),
    description text
);


--
-- Name: lkp_land_use_type_land_use_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_land_use_type_land_use_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_land_use_type_land_use_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_land_use_type_land_use_id_seq OWNED BY public.lkp_land_use_type.land_use_id;


--
-- Name: lkp_leave_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_leave_type (
    leave_type_id integer NOT NULL,
    leave_name character varying(50) NOT NULL,
    description text,
    paid boolean DEFAULT true,
    days_per_year integer
);


--
-- Name: lkp_leave_type_leave_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_leave_type_leave_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_leave_type_leave_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_leave_type_leave_type_id_seq OWNED BY public.lkp_leave_type.leave_type_id;


--
-- Name: lkp_operational_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_operational_status (
    status_id integer NOT NULL,
    status_name character varying(50) NOT NULL,
    status_code character varying(10),
    description text,
    is_accessible_to_public boolean DEFAULT true
);


--
-- Name: lkp_operational_status_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_operational_status_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_operational_status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_operational_status_status_id_seq OWNED BY public.lkp_operational_status.status_id;


--
-- Name: lkp_ownership_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_ownership_type (
    ownership_id integer NOT NULL,
    ownership_name character varying(100) NOT NULL,
    description text
);


--
-- Name: lkp_ownership_type_ownership_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_ownership_type_ownership_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_ownership_type_ownership_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_ownership_type_ownership_id_seq OWNED BY public.lkp_ownership_type.ownership_id;


--
-- Name: lkp_parcel_document_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_parcel_document_type (
    doc_type_id integer NOT NULL,
    doc_type_name character varying(100) NOT NULL,
    description text
);


--
-- Name: lkp_parcel_document_type_doc_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_parcel_document_type_doc_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_parcel_document_type_doc_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_parcel_document_type_doc_type_id_seq OWNED BY public.lkp_parcel_document_type.doc_type_id;


--
-- Name: lkp_plan_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_plan_status (
    status_id integer NOT NULL,
    status_name character varying(50) NOT NULL,
    description text
);


--
-- Name: lkp_plan_status_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_plan_status_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_plan_status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_plan_status_status_id_seq OWNED BY public.lkp_plan_status.status_id;


--
-- Name: lkp_plan_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_plan_type (
    plan_type_id integer NOT NULL,
    plan_type_name character varying(50) NOT NULL,
    description text,
    planning_horizon_days integer,
    requires_approval boolean DEFAULT true
);


--
-- Name: lkp_plan_type_plan_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_plan_type_plan_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_plan_type_plan_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_plan_type_plan_type_id_seq OWNED BY public.lkp_plan_type.plan_type_id;


--
-- Name: lkp_skill; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_skill (
    skill_id integer NOT NULL,
    skill_name character varying(100) NOT NULL,
    skill_category character varying(50),
    certification_required boolean DEFAULT false
);


--
-- Name: lkp_skill_skill_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_skill_skill_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_skill_skill_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_skill_skill_id_seq OWNED BY public.lkp_skill.skill_id;


--
-- Name: lkp_ugi_lifecycle_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_ugi_lifecycle_status (
    lifecycle_id integer NOT NULL,
    lifecycle_name character varying(50) NOT NULL,
    description text,
    next_stage_id integer,
    typical_duration_days integer
);


--
-- Name: lkp_ugi_lifecycle_status_lifecycle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_ugi_lifecycle_status_lifecycle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_ugi_lifecycle_status_lifecycle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_ugi_lifecycle_status_lifecycle_id_seq OWNED BY public.lkp_ugi_lifecycle_status.lifecycle_id;


--
-- Name: lkp_zone_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkp_zone_type (
    zone_type_id integer NOT NULL,
    zone_type_name character varying(50) NOT NULL,
    description text
);


--
-- Name: lkp_zone_type_zone_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkp_zone_type_zone_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkp_zone_type_zone_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkp_zone_type_zone_type_id_seq OWNED BY public.lkp_zone_type.zone_type_id;


--
-- Name: lkq_city; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkq_city (
    city_id integer NOT NULL,
    city_name character varying(100) NOT NULL,
    region_id integer,
    municipality_code character varying(20),
    geometry public.geometry(MultiPolygon,20137)
);


--
-- Name: lkq_city_city_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkq_city_city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkq_city_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkq_city_city_id_seq OWNED BY public.lkq_city.city_id;


--
-- Name: lkq_kebele; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkq_kebele (
    kebele_id integer NOT NULL,
    kebele_number character varying(20) NOT NULL,
    kebele_name character varying(100),
    woreda_id integer,
    geometry public.geometry(MultiPolygon,20137)
);


--
-- Name: lkq_kebele_kebele_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkq_kebele_kebele_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkq_kebele_kebele_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkq_kebele_kebele_id_seq OWNED BY public.lkq_kebele.kebele_id;


--
-- Name: lkq_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkq_region (
    region_id integer NOT NULL,
    region_name character varying(100) NOT NULL,
    region_code character varying(10),
    geometry public.geometry(MultiPolygon,20137)
);


--
-- Name: lkq_region_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkq_region_region_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkq_region_region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkq_region_region_id_seq OWNED BY public.lkq_region.region_id;


--
-- Name: lkq_subcity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkq_subcity (
    subcity_id integer NOT NULL,
    subcity_name character varying(100) NOT NULL,
    city_id integer,
    administrative_code character varying(20),
    geometry public.geometry(MultiPolygon,20137)
);


--
-- Name: lkq_subcity_subcity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkq_subcity_subcity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkq_subcity_subcity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkq_subcity_subcity_id_seq OWNED BY public.lkq_subcity.subcity_id;


--
-- Name: lkq_woreda; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lkq_woreda (
    woreda_id integer NOT NULL,
    woreda_name character varying(100) NOT NULL,
    woreda_number character varying(20),
    subcity_id integer,
    geometry public.geometry(MultiPolygon,20137)
);


--
-- Name: lkq_woreda_woreda_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lkq_woreda_woreda_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lkq_woreda_woreda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lkq_woreda_woreda_id_seq OWNED BY public.lkq_woreda.woreda_id;


--
-- Name: ugims_activity_execution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_activity_execution (
    execution_id integer NOT NULL,
    plan_activity_id integer,
    ugi_id integer NOT NULL,
    activity_type_id integer NOT NULL,
    execution_number character varying(50),
    actual_start_datetime timestamp without time zone,
    actual_end_datetime timestamp without time zone,
    scheduled_start_datetime timestamp without time zone,
    duration_minutes integer GENERATED ALWAYS AS ((EXTRACT(epoch FROM (actual_end_datetime - actual_start_datetime)) / (60)::numeric)) STORED,
    start_location public.geometry(Point,20137),
    end_location public.geometry(Point,20137),
    work_area public.geometry(Polygon,20137),
    tracking_path public.geometry(LineString,20137),
    performed_by_user_id integer,
    performed_by_team_id integer,
    supervised_by_user_id integer,
    additional_workers jsonb,
    actual_man_days numeric(6,2),
    actual_man_hours numeric(6,2),
    actual_labor_cost numeric(12,2),
    actual_material_cost numeric(12,2),
    actual_equipment_cost numeric(12,2),
    total_actual_cost numeric(12,2),
    materials_used jsonb,
    materials_used_text text,
    equipment_used jsonb,
    work_performed text,
    work_notes text,
    challenges_encountered text,
    deviations_from_plan text,
    completion_status_id integer,
    completion_percentage integer DEFAULT 100,
    quality_rating integer,
    quality_notes text,
    before_photos text[],
    during_photos text[],
    after_photos text[],
    additional_documents text[],
    verified_by_user_id integer,
    verification_datetime timestamp without time zone,
    verification_notes text,
    verification_status character varying(50),
    issues_identified boolean DEFAULT false,
    issue_ids integer[],
    followup_required boolean DEFAULT false,
    followup_notes text,
    followup_date date,
    weather_conditions character varying(100),
    temperature_c numeric(4,1),
    precipitation boolean,
    wind_conditions character varying(50),
    recorded_datetime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    recorded_by_user_id integer,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    mobile_device_id character varying(100),
    mobile_app_version character varying(20),
    sync_datetime timestamp without time zone,
    offline_record boolean DEFAULT false,
    CONSTRAINT ugims_activity_execution_quality_rating_check CHECK (((quality_rating >= 1) AND (quality_rating <= 5)))
);


--
-- Name: ugims_activity_execution_execution_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_activity_execution_execution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_activity_execution_execution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_activity_execution_execution_id_seq OWNED BY public.ugims_activity_execution.execution_id;


--
-- Name: ugims_audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_audit_log (
    audit_id integer NOT NULL,
    table_name character varying(100) NOT NULL,
    record_id integer NOT NULL,
    action character varying(50) NOT NULL,
    old_data jsonb,
    new_data jsonb,
    changed_by_user_id integer,
    changed_datetime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ip_address inet,
    user_agent text
);


--
-- Name: ugims_audit_log_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_audit_log_audit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_audit_log_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_audit_log_audit_id_seq OWNED BY public.ugims_audit_log.audit_id;


--
-- Name: ugims_budget; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_budget (
    budget_id integer NOT NULL,
    budget_code character varying(50),
    budget_name character varying(255) NOT NULL,
    fiscal_year_id integer,
    budget_year character varying(9),
    start_date date,
    end_date date,
    budget_type character varying(50),
    budget_source_id integer,
    funding_source_details text,
    scope_type character varying(50),
    zone_id integer,
    ugi_id integer,
    department_id integer,
    project_name character varying(255),
    allocated_amount numeric(15,2) NOT NULL,
    committed_amount numeric(15,2) DEFAULT 0,
    expended_amount numeric(15,2) DEFAULT 0,
    remaining_amount numeric(15,2) GENERATED ALWAYS AS (((allocated_amount - committed_amount) - expended_amount)) STORED,
    currency character varying(3) DEFAULT 'ETB'::character varying,
    exchange_rate numeric(10,4),
    original_amount numeric(15,2),
    budget_status character varying(50),
    approval_status character varying(50),
    approved_by_user_id integer,
    approval_date timestamp without time zone,
    approval_document text,
    manager_user_id integer,
    finance_officer_user_id integer,
    category_breakdown jsonb,
    notes text,
    restrictions text,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    updated_by_user_id integer
);


--
-- Name: ugims_budget_budget_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_budget_budget_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_budget_budget_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_budget_budget_id_seq OWNED BY public.ugims_budget.budget_id;


--
-- Name: ugims_budget_line_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_budget_line_item (
    line_item_id integer NOT NULL,
    budget_id integer NOT NULL,
    line_number integer,
    category_id integer,
    description text NOT NULL,
    allocated_amount numeric(15,2) NOT NULL,
    committed_amount numeric(15,2) DEFAULT 0,
    expended_amount numeric(15,2) DEFAULT 0,
    is_recurring boolean DEFAULT false,
    recurring_frequency character varying(50),
    notes text,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ugims_budget_line_item_line_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_budget_line_item_line_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_budget_line_item_line_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_budget_line_item_line_item_id_seq OWNED BY public.ugims_budget_line_item.line_item_id;


--
-- Name: ugims_citizen_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_citizen_report (
    report_id integer NOT NULL,
    report_number character varying(50),
    reporter_name character varying(255),
    reporter_email character varying(255),
    reporter_phone character varying(50),
    is_anonymous boolean DEFAULT false,
    preferred_contact_method character varying(50),
    report_type_id integer,
    report_title character varying(255),
    report_description text NOT NULL,
    location_point public.geometry(Point,20137) NOT NULL,
    location_description text,
    ugi_id integer,
    address_text text,
    photo_urls text[],
    status_id integer DEFAULT 1,
    assigned_to_user_id integer,
    assigned_team_id integer,
    assigned_datetime timestamp without time zone,
    issue_id integer,
    inspection_id integer,
    response_message text,
    response_datetime timestamp without time zone,
    responded_by_user_id integer,
    resolved_datetime timestamp without time zone,
    resolution_notes text,
    resolution_photo_urls text[],
    satisfaction_rating integer,
    feedback_comments text,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    mobile_device_id character varying(100),
    app_version character varying(20),
    sync_datetime timestamp without time zone,
    CONSTRAINT ugims_citizen_report_satisfaction_rating_check CHECK (((satisfaction_rating >= 1) AND (satisfaction_rating <= 5)))
);


--
-- Name: ugims_citizen_report_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_citizen_report_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_citizen_report_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_citizen_report_report_id_seq OWNED BY public.ugims_citizen_report.report_id;


--
-- Name: ugims_expense; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_expense (
    expense_id integer NOT NULL,
    expense_number character varying(50),
    budget_id integer,
    line_item_id integer,
    expense_date date NOT NULL,
    description text NOT NULL,
    amount numeric(15,2) NOT NULL,
    category_id integer,
    expense_type character varying(50),
    vendor_name character varying(255),
    vendor_id character varying(100),
    invoice_number character varying(100),
    receipt_number character varying(100),
    ugi_id integer,
    activity_execution_id integer,
    plan_id integer,
    work_order_id integer,
    payment_method character varying(50),
    payment_status character varying(50),
    payment_date date,
    paid_by_user_id integer,
    supporting_documents text[],
    notes text,
    approved_by_user_id integer,
    approval_date timestamp without time zone,
    approval_notes text,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ugims_expense_expense_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_expense_expense_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_expense_expense_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_expense_expense_id_seq OWNED BY public.ugims_expense.expense_id;


--
-- Name: ugims_import_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_import_log (
    import_id integer NOT NULL,
    import_type character varying(20) NOT NULL,
    filename character varying(255) NOT NULL,
    records_processed integer DEFAULT 0,
    records_success integer DEFAULT 0,
    records_failed integer DEFAULT 0,
    import_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    imported_by_user_id integer,
    status character varying(20) DEFAULT 'pending'::character varying,
    error_log text
);


--
-- Name: ugims_import_log_import_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_import_log_import_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_import_log_import_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_import_log_import_id_seq OWNED BY public.ugims_import_log.import_id;


--
-- Name: ugims_import_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_import_mapping (
    mapping_id integer NOT NULL,
    mapping_name character varying(100) NOT NULL,
    import_type character varying(20) NOT NULL,
    field_mapping jsonb NOT NULL,
    created_by integer,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_default boolean DEFAULT false
);


--
-- Name: ugims_import_mapping_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_import_mapping_mapping_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_import_mapping_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_import_mapping_mapping_id_seq OWNED BY public.ugims_import_mapping.mapping_id;


--
-- Name: ugims_import_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_import_session (
    session_id integer NOT NULL,
    user_id integer,
    import_type character varying(20) NOT NULL,
    temp_dir character varying(255),
    shapefile_name character varying(255),
    total_records integer DEFAULT 0,
    field_mapping jsonb,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP + '02:00:00'::interval)
);


--
-- Name: ugims_import_session_session_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_import_session_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_import_session_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_import_session_session_id_seq OWNED BY public.ugims_import_session.session_id;


--
-- Name: ugims_inspection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_inspection (
    inspection_id integer NOT NULL,
    inspection_number character varying(50),
    inspection_type_id integer,
    ugi_id integer,
    component_id integer,
    inspection_area public.geometry(Polygon,20137),
    scheduled_date timestamp without time zone,
    scheduled_by_user_id integer,
    assigned_to_user_id integer,
    assigned_date timestamp without time zone,
    started_datetime timestamp without time zone,
    completed_datetime timestamp without time zone,
    inspector_user_id integer,
    inspector_notes text,
    inspection_path public.geometry(LineString,20137),
    start_location public.geometry(Point,20137),
    end_location public.geometry(Point,20137),
    overall_condition_id integer,
    overall_rating integer,
    findings_summary text,
    recommendations text,
    issues_found boolean DEFAULT false,
    critical_issues_found boolean DEFAULT false,
    issue_count integer DEFAULT 0,
    inspection_status_id integer,
    report_document_url text,
    photo_urls text[],
    video_urls text[],
    followup_required boolean DEFAULT false,
    followup_inspection_id integer,
    followup_date date,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    updated_by_user_id integer,
    mobile_device_id character varying(100),
    sync_datetime timestamp without time zone,
    offline_record boolean DEFAULT false,
    CONSTRAINT ugims_inspection_overall_rating_check CHECK (((overall_rating >= 1) AND (overall_rating <= 10)))
);


--
-- Name: ugims_inspection_finding; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_inspection_finding (
    finding_id integer NOT NULL,
    inspection_id integer NOT NULL,
    ugi_id integer,
    component_id integer,
    location_point public.geometry(Point,20137),
    location_description text,
    finding_type character varying(100),
    finding_description text NOT NULL,
    finding_priority_id integer,
    condition_before_id integer,
    condition_after_id integer,
    quantity_affected integer,
    severity integer,
    immediate_action_taken text,
    recommended_action text,
    recommended_action_date date,
    estimated_repair_cost numeric(12,2),
    estimated_repair_hours numeric(6,2),
    assigned_to_user_id integer,
    assigned_date date,
    work_order_created boolean DEFAULT false,
    work_order_id integer,
    resolved boolean DEFAULT false,
    resolved_date timestamp without time zone,
    resolved_by_user_id integer,
    resolution_notes text,
    photo_urls text[],
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ugims_inspection_finding_severity_check CHECK (((severity >= 1) AND (severity <= 5)))
);


--
-- Name: ugims_inspection_finding_finding_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_inspection_finding_finding_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_inspection_finding_finding_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_inspection_finding_finding_id_seq OWNED BY public.ugims_inspection_finding.finding_id;


--
-- Name: ugims_inspection_inspection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_inspection_inspection_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_inspection_inspection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_inspection_inspection_id_seq OWNED BY public.ugims_inspection.inspection_id;


--
-- Name: ugims_issue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_issue (
    issue_id integer NOT NULL,
    issue_number character varying(50),
    source_type character varying(50),
    source_reference_id integer,
    category_id integer,
    issue_type character varying(100),
    priority_id integer,
    ugi_id integer,
    component_id integer,
    location_point public.geometry(Point,20137),
    location_description text,
    title character varying(255) NOT NULL,
    description text NOT NULL,
    reported_by_name character varying(255),
    reported_by_contact character varying(100),
    reported_datetime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    severity integer,
    affects_safety boolean DEFAULT false,
    affects_accessibility boolean DEFAULT false,
    affects_operations boolean DEFAULT false,
    photo_urls text[],
    assigned_to_user_id integer,
    assigned_to_team_id integer,
    assigned_datetime timestamp without time zone,
    assigned_by_user_id integer,
    work_order_created boolean DEFAULT false,
    work_order_id integer,
    status_id integer,
    status_history jsonb,
    resolved_datetime timestamp without time zone,
    resolved_by_user_id integer,
    resolution_notes text,
    resolution_action_taken text,
    verified_by_user_id integer,
    verification_datetime timestamp without time zone,
    verification_notes text,
    estimated_cost numeric(12,2),
    actual_cost numeric(12,2),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    updated_by_user_id integer,
    CONSTRAINT ugims_issue_severity_check CHECK (((severity >= 1) AND (severity <= 5)))
);


--
-- Name: ugims_issue_comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_issue_comment (
    comment_id integer NOT NULL,
    issue_id integer NOT NULL,
    comment_text text NOT NULL,
    comment_type character varying(50),
    commented_by_user_id integer,
    commented_by_name character varying(255),
    commented_datetime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    attachments text[],
    is_public boolean DEFAULT false
);


--
-- Name: ugims_issue_comment_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_issue_comment_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_issue_comment_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_issue_comment_comment_id_seq OWNED BY public.ugims_issue_comment.comment_id;


--
-- Name: ugims_issue_issue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_issue_issue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_issue_issue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_issue_issue_id_seq OWNED BY public.ugims_issue.issue_id;


--
-- Name: ugims_maintenance_zone; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_maintenance_zone (
    zone_id integer NOT NULL,
    zone_name character varying(100) NOT NULL,
    zone_code character varying(20),
    zone_manager_user_id integer,
    subcity_id integer,
    geometry public.geometry(MultiPolygon,20137),
    area_sq_m numeric(12,2),
    priority_level integer DEFAULT 3,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    description text
);


--
-- Name: ugims_maintenance_zone_zone_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_maintenance_zone_zone_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_maintenance_zone_zone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_maintenance_zone_zone_id_seq OWNED BY public.ugims_maintenance_zone.zone_id;


--
-- Name: ugims_management_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_management_plan (
    plan_id integer NOT NULL,
    plan_number character varying(50),
    plan_name character varying(255) NOT NULL,
    plan_type_id integer,
    fiscal_year_id integer,
    scope_type character varying(50),
    ugi_ids integer[],
    zone_id integer,
    planned_start_date date,
    planned_end_date date,
    actual_start_date date,
    actual_end_date date,
    total_budget_allocated numeric(15,2),
    total_estimated_cost numeric(15,2),
    total_actual_cost numeric(15,2),
    budget_source character varying(255),
    budget_code character varying(100),
    total_estimated_man_days numeric(10,2),
    total_actual_man_days numeric(10,2),
    estimated_equipment_hours numeric(10,2),
    plan_status_id integer,
    approval_status_id integer,
    approved_by_user_id integer,
    approval_date timestamp without time zone,
    approval_notes text,
    prepared_by_user_id integer,
    prepared_date timestamp without time zone,
    reviewed_by_user_id integer,
    reviewed_date timestamp without time zone,
    goals_and_objectives text,
    success_criteria text,
    risks_and_assumptions text,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    updated_by_user_id integer,
    notes text,
    attachments text[]
);


--
-- Name: ugims_management_plan_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_management_plan_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_management_plan_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_management_plan_plan_id_seq OWNED BY public.ugims_management_plan.plan_id;


--
-- Name: ugims_monitoring_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_monitoring_log (
    log_id integer NOT NULL,
    log_number character varying(50),
    ugi_id integer,
    location_point public.geometry(Point,20137) NOT NULL,
    location_description text,
    monitor_user_id integer NOT NULL,
    log_datetime timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    log_type character varying(50),
    log_category character varying(50),
    observations text NOT NULL,
    issues_noted text,
    actions_taken text,
    observed_condition_id integer,
    visitor_count_estimate integer,
    weather_conditions character varying(100),
    temperature_c numeric(4,1),
    recent_rainfall boolean,
    photo_urls text[],
    is_urgent boolean DEFAULT false,
    requires_followup boolean DEFAULT false,
    followup_notes text,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    mobile_device_id character varying(100),
    sync_datetime timestamp without time zone,
    offline_record boolean DEFAULT false
);


--
-- Name: ugims_monitoring_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_monitoring_log_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_monitoring_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_monitoring_log_log_id_seq OWNED BY public.ugims_monitoring_log.log_id;


--
-- Name: ugims_parcel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_parcel (
    parcel_id integer NOT NULL,
    parcel_number character varying(50) NOT NULL,
    parcel_registration_number character varying(50),
    geometry public.geometry(MultiPolygon,20137) NOT NULL,
    region_id integer,
    city_id integer,
    subcity_id integer,
    woreda_id integer,
    kebele_id integer,
    maintenance_zone_id integer,
    street_name character varying(255),
    house_number character varying(50),
    landmark character varying(255),
    gps_coordinates public.geometry(Point,20137),
    land_use_type_id integer,
    ownership_type_id integer,
    owner_name character varying(255),
    owner_id_number character varying(50),
    owner_contact character varying(100),
    area_sq_m numeric(12,2),
    cadastral_zone character varying(50),
    registration_date date,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id integer,
    status_id integer,
    spatial_accuracy character varying(50),
    survey_date date,
    survey_method character varying(100)
);


--
-- Name: ugims_parcel_document; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_parcel_document (
    document_id integer NOT NULL,
    parcel_id integer NOT NULL,
    document_type_id integer,
    document_title character varying(255),
    document_number character varying(100),
    issue_date date,
    expiry_date date,
    issuing_authority character varying(255),
    file_url text,
    uploaded_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    uploaded_by_user_id integer,
    is_verified boolean DEFAULT false,
    verified_by_user_id integer,
    verification_date date
);


--
-- Name: ugims_parcel_document_document_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_parcel_document_document_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_parcel_document_document_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_parcel_document_document_id_seq OWNED BY public.ugims_parcel_document.document_id;


--
-- Name: ugims_parcel_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_parcel_history (
    history_id integer NOT NULL,
    parcel_id integer,
    change_type character varying(50),
    old_geometry public.geometry(MultiPolygon,20137),
    new_geometry public.geometry(MultiPolygon,20137),
    old_owner character varying(255),
    new_owner character varying(255),
    change_reason text,
    changed_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    changed_by_user_id integer,
    approved_by_user_id integer,
    approval_date timestamp without time zone,
    status character varying(50)
);


--
-- Name: ugims_parcel_history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_parcel_history_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_parcel_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_parcel_history_history_id_seq OWNED BY public.ugims_parcel_history.history_id;


--
-- Name: ugims_parcel_parcel_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_parcel_parcel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_parcel_parcel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_parcel_parcel_id_seq OWNED BY public.ugims_parcel.parcel_id;


--
-- Name: ugims_plan_activity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_plan_activity (
    plan_activity_id integer NOT NULL,
    plan_id integer NOT NULL,
    activity_number character varying(50),
    activity_type_id integer,
    activity_name character varying(255),
    activity_description text,
    ugi_id integer,
    component_id integer,
    target_area public.geometry(Polygon,20137),
    frequency_id integer,
    scheduled_start_date date,
    scheduled_end_date date,
    scheduled_start_month integer,
    scheduled_end_month integer,
    preferred_time_of_day character varying(50),
    duration_days integer,
    is_recurring boolean DEFAULT false,
    recurring_pattern jsonb,
    estimated_man_days numeric(8,2),
    estimated_labor_cost numeric(12,2),
    estimated_material_cost numeric(12,2),
    estimated_equipment_cost numeric(12,2),
    total_estimated_cost numeric(12,2),
    required_materials text,
    required_materials_list jsonb,
    required_equipment text,
    required_equipment_list jsonb,
    estimated_crew_size integer,
    required_skills text,
    assigned_team_id integer,
    assigned_team_lead integer,
    depends_on_activity_id integer,
    prerequisites text,
    priority integer DEFAULT 3,
    activity_status_id integer,
    weather_dependent boolean DEFAULT false,
    preferred_weather character varying(50),
    cannot_execute_in_rain boolean DEFAULT false,
    safety_requirements text,
    requires_supervision boolean DEFAULT true,
    expected_outcome text,
    quality_standards text,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    updated_by_user_id integer
);


--
-- Name: ugims_plan_activity_plan_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_plan_activity_plan_activity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_plan_activity_plan_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_plan_activity_plan_activity_id_seq OWNED BY public.ugims_plan_activity.plan_activity_id;


--
-- Name: ugims_public_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_public_feedback (
    feedback_id integer NOT NULL,
    ugi_id integer,
    feedback_type character varying(50),
    visitor_purpose character varying(100),
    overall_rating integer,
    cleanliness_rating integer,
    safety_rating integer,
    maintenance_rating integer,
    accessibility_rating integer,
    comments text,
    suggestions text,
    contact_email character varying(255),
    contact_phone character varying(50),
    visit_date date,
    feedback_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    source character varying(50),
    anonymous boolean DEFAULT true,
    CONSTRAINT ugims_public_feedback_accessibility_rating_check CHECK (((accessibility_rating >= 1) AND (accessibility_rating <= 5))),
    CONSTRAINT ugims_public_feedback_cleanliness_rating_check CHECK (((cleanliness_rating >= 1) AND (cleanliness_rating <= 5))),
    CONSTRAINT ugims_public_feedback_maintenance_rating_check CHECK (((maintenance_rating >= 1) AND (maintenance_rating <= 5))),
    CONSTRAINT ugims_public_feedback_overall_rating_check CHECK (((overall_rating >= 1) AND (overall_rating <= 5))),
    CONSTRAINT ugims_public_feedback_safety_rating_check CHECK (((safety_rating >= 1) AND (safety_rating <= 5)))
);


--
-- Name: ugims_public_feedback_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_public_feedback_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_public_feedback_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_public_feedback_feedback_id_seq OWNED BY public.ugims_public_feedback.feedback_id;


--
-- Name: ugims_purchase_requisition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_purchase_requisition (
    requisition_id integer NOT NULL,
    requisition_number character varying(50),
    requisition_date date DEFAULT CURRENT_DATE,
    requested_by_user_id integer,
    department_id integer,
    purpose text NOT NULL,
    ugi_id integer,
    activity_id integer,
    items jsonb NOT NULL,
    total_estimated_cost numeric(15,2),
    budget_id integer,
    budget_check_status character varying(50),
    budget_check_notes text,
    approval_status character varying(50),
    current_approver_level integer,
    approval_history jsonb,
    approved_by_user_id integer,
    approval_date timestamp without time zone,
    approval_notes text,
    purchase_order_id character varying(100),
    purchase_order_date date,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: ugims_purchase_requisition_requisition_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_purchase_requisition_requisition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_purchase_requisition_requisition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_purchase_requisition_requisition_id_seq OWNED BY public.ugims_purchase_requisition.requisition_id;


--
-- Name: ugims_spatial_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_spatial_metadata (
    metadata_id integer NOT NULL,
    table_name character varying(100) NOT NULL,
    column_name character varying(100) NOT NULL,
    srid integer DEFAULT 20137,
    geometry_type character varying(50),
    feature_count integer,
    last_updated timestamp without time zone,
    extent_geometry public.geometry(Polygon,20137),
    notes text
);


--
-- Name: ugims_spatial_metadata_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_spatial_metadata_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_spatial_metadata_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_spatial_metadata_metadata_id_seq OWNED BY public.ugims_spatial_metadata.metadata_id;


--
-- Name: ugims_team; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_team (
    team_id integer NOT NULL,
    team_name character varying(100) NOT NULL,
    team_code character varying(20),
    team_type character varying(50),
    assigned_zone_id integer,
    specialization character varying(100),
    team_lead_user_id integer,
    assistant_lead_user_id integer,
    min_members integer,
    max_members integer,
    current_member_count integer DEFAULT 0,
    shift character varying(50),
    work_days character varying(100),
    assigned_vehicles text[],
    assigned_equipment text[],
    is_active boolean DEFAULT true,
    status character varying(50),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    updated_by_user_id integer
);


--
-- Name: ugims_team_membership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_team_membership (
    membership_id integer NOT NULL,
    team_id integer NOT NULL,
    user_id integer NOT NULL,
    role_in_team character varying(50),
    assigned_date date NOT NULL,
    end_date date,
    is_active boolean DEFAULT true,
    notes text,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer
);


--
-- Name: ugims_team_membership_membership_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_team_membership_membership_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_team_membership_membership_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_team_membership_membership_id_seq OWNED BY public.ugims_team_membership.membership_id;


--
-- Name: ugims_team_team_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_team_team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_team_team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_team_team_id_seq OWNED BY public.ugims_team.team_id;


--
-- Name: ugims_ugi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_ugi (
    ugi_id integer NOT NULL,
    ugi_type_id integer NOT NULL,
    parcel_id integer NOT NULL,
    name character varying(255) NOT NULL,
    amharic_name character varying(255),
    alternate_names text,
    ugi_code character varying(50),
    geometry public.geometry(MultiPolygon,20137) NOT NULL,
    centroid public.geometry(Point,20137) GENERATED ALWAYS AS (public.st_centroid(geometry)) STORED,
    area_sq_m numeric(12,2) GENERATED ALWAYS AS (public.st_area(geometry)) STORED,
    perimeter_m numeric(12,2) GENERATED ALWAYS AS (public.st_perimeter(geometry)) STORED,
    region_id integer,
    city_id integer,
    subcity_id integer,
    woreda_id integer,
    kebele_id integer,
    maintenance_zone_id integer,
    street_address text,
    landmark_nearby character varying(255),
    google_maps_link text,
    what3words character varying(100),
    establishment_date date,
    inauguration_date date,
    designed_by character varying(255),
    constructed_by character varying(255),
    construction_cost numeric(15,2),
    accessibility_type_id integer,
    operating_hours_id integer,
    has_lighting boolean DEFAULT false,
    has_irrigation boolean DEFAULT false,
    has_fencing boolean DEFAULT false,
    has_parking boolean DEFAULT false,
    has_public_toilet boolean DEFAULT false,
    has_water_fountain boolean DEFAULT false,
    has_seating boolean DEFAULT false,
    has_wifi boolean DEFAULT false,
    has_security boolean DEFAULT false,
    has_handicap_access boolean DEFAULT false,
    visitor_capacity integer,
    peak_hours text,
    peak_season character varying(100),
    condition_status_id integer,
    operational_status_id integer,
    last_inspected_date date,
    next_inspection_due date,
    managing_department_id integer,
    maintenance_responsible_id integer,
    contact_person character varying(255),
    contact_phone character varying(50),
    contact_email character varying(255),
    tree_count integer,
    tree_species text,
    grass_type character varying(100),
    irrigation_source character varying(100),
    water_requirement_estimate numeric(10,2),
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    updated_by_user_id integer,
    CONSTRAINT ugi_geometry_valid CHECK (public.st_isvalid(geometry))
);


--
-- Name: ugims_ugi_component; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_ugi_component (
    component_id integer NOT NULL,
    ugi_id integer NOT NULL,
    component_type_id integer,
    component_code character varying(50),
    geometry public.geometry(Point,20137),
    location_description text,
    floor_number integer,
    manufacturer character varying(255),
    model_number character varying(100),
    serial_number character varying(100),
    installation_date date,
    material_type character varying(100),
    color character varying(50),
    dimensions character varying(100),
    weight_kg numeric(8,2),
    condition_status_id integer,
    last_inspected date,
    inspection_frequency character varying(50),
    warranty_expiry date,
    maintenance_instructions text,
    last_maintained date,
    next_maintenance_due date,
    operational_status_id integer,
    is_public boolean DEFAULT true,
    safety_rating integer,
    notes text,
    photo_urls text[],
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    updated_by_user_id integer,
    CONSTRAINT ugims_ugi_component_safety_rating_check CHECK (((safety_rating >= 1) AND (safety_rating <= 5)))
);


--
-- Name: ugims_ugi_component_component_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_ugi_component_component_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_ugi_component_component_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_ugi_component_component_id_seq OWNED BY public.ugims_ugi_component.component_id;


--
-- Name: ugims_ugi_ugi_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_ugi_ugi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_ugi_ugi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_ugi_ugi_id_seq OWNED BY public.ugims_ugi.ugi_id;


--
-- Name: ugims_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_users (
    user_id integer NOT NULL,
    username character varying(50) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(100),
    email character varying(100),
    role character varying(50) DEFAULT 'staff'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp without time zone
);


--
-- Name: ugims_users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_users_user_id_seq OWNED BY public.ugims_users.user_id;


--
-- Name: ugims_workforce_schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_workforce_schedule (
    schedule_id integer NOT NULL,
    user_id integer NOT NULL,
    schedule_date date NOT NULL,
    shift_start time without time zone,
    shift_end time without time zone,
    break_duration_minutes integer,
    assignment_type character varying(50),
    assigned_zone_id integer,
    assigned_task_id integer,
    clock_in_time timestamp without time zone,
    clock_out_time timestamp without time zone,
    clock_in_location public.geometry(Point,20137),
    clock_out_location public.geometry(Point,20137),
    actual_hours_worked numeric(5,2),
    status character varying(50),
    notes text,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer
);


--
-- Name: ugims_workforce_schedule_schedule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ugims_workforce_schedule_schedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ugims_workforce_schedule_schedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ugims_workforce_schedule_schedule_id_seq OWNED BY public.ugims_workforce_schedule.schedule_id;


--
-- Name: ugims_workforce_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ugims_workforce_user (
    user_id integer NOT NULL,
    employee_id character varying(50) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    amharic_name character varying(200),
    phone_number character varying(20),
    alternate_phone character varying(20),
    email character varying(255),
    emergency_contact_name character varying(200),
    emergency_contact_phone character varying(20),
    job_title_id integer,
    employment_type character varying(50),
    employment_status character varying(50),
    hire_date date,
    contract_start_date date,
    contract_end_date date,
    termination_date date,
    termination_reason text,
    assigned_zone_id integer,
    reports_to_user_id integer,
    department_id integer,
    education_level character varying(100),
    certifications text[],
    skills integer[],
    years_experience integer,
    shift_preference character varying(50),
    work_hours_per_week integer,
    overtime_eligible boolean DEFAULT true,
    assigned_equipment text[],
    vehicle_assigned character varying(100),
    training_completed text[],
    training_required text[],
    last_training_date date,
    next_training_due date,
    medical_clearance_date date,
    physical_capability_notes text,
    allergies text,
    can_access_mobile boolean DEFAULT true,
    mobile_device_assigned character varying(100),
    last_login timestamp without time zone,
    created_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id integer,
    updated_by_user_id integer,
    is_active boolean DEFAULT true
);


--
-- Name: auth_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user ALTER COLUMN id SET DEFAULT nextval('public.auth_user_id_seq'::regclass);


--
-- Name: lkp_accessibility_type access_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_accessibility_type ALTER COLUMN access_id SET DEFAULT nextval('public.lkp_accessibility_type_access_id_seq'::regclass);


--
-- Name: lkp_activity_category category_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_activity_category ALTER COLUMN category_id SET DEFAULT nextval('public.lkp_activity_category_category_id_seq'::regclass);


--
-- Name: lkp_activity_status status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_activity_status ALTER COLUMN status_id SET DEFAULT nextval('public.lkp_activity_status_status_id_seq'::regclass);


--
-- Name: lkp_activity_type activity_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_activity_type ALTER COLUMN activity_type_id SET DEFAULT nextval('public.lkp_activity_type_activity_type_id_seq'::regclass);


--
-- Name: lkp_budget_category category_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_budget_category ALTER COLUMN category_id SET DEFAULT nextval('public.lkp_budget_category_category_id_seq'::regclass);


--
-- Name: lkp_budget_source source_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_budget_source ALTER COLUMN source_id SET DEFAULT nextval('public.lkp_budget_source_source_id_seq'::regclass);


--
-- Name: lkp_citizen_report_status status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_citizen_report_status ALTER COLUMN status_id SET DEFAULT nextval('public.lkp_citizen_report_status_status_id_seq'::regclass);


--
-- Name: lkp_citizen_report_type report_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_citizen_report_type ALTER COLUMN report_type_id SET DEFAULT nextval('public.lkp_citizen_report_type_report_type_id_seq'::regclass);


--
-- Name: lkp_component_type component_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_component_type ALTER COLUMN component_type_id SET DEFAULT nextval('public.lkp_component_type_component_type_id_seq'::regclass);


--
-- Name: lkp_condition_status status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_condition_status ALTER COLUMN status_id SET DEFAULT nextval('public.lkp_condition_status_status_id_seq'::regclass);


--
-- Name: lkp_ethiopia_ugi_type ugi_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_ethiopia_ugi_type ALTER COLUMN ugi_type_id SET DEFAULT nextval('public.lkp_ethiopia_ugi_type_ugi_type_id_seq'::regclass);


--
-- Name: lkp_finding_priority priority_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_finding_priority ALTER COLUMN priority_id SET DEFAULT nextval('public.lkp_finding_priority_priority_id_seq'::regclass);


--
-- Name: lkp_fiscal_year fiscal_year_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_fiscal_year ALTER COLUMN fiscal_year_id SET DEFAULT nextval('public.lkp_fiscal_year_fiscal_year_id_seq'::regclass);


--
-- Name: lkp_frequency frequency_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_frequency ALTER COLUMN frequency_id SET DEFAULT nextval('public.lkp_frequency_frequency_id_seq'::regclass);


--
-- Name: lkp_inspection_status status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_inspection_status ALTER COLUMN status_id SET DEFAULT nextval('public.lkp_inspection_status_status_id_seq'::regclass);


--
-- Name: lkp_inspection_type inspection_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_inspection_type ALTER COLUMN inspection_type_id SET DEFAULT nextval('public.lkp_inspection_type_inspection_type_id_seq'::regclass);


--
-- Name: lkp_issue_category category_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_issue_category ALTER COLUMN category_id SET DEFAULT nextval('public.lkp_issue_category_category_id_seq'::regclass);


--
-- Name: lkp_issue_status status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_issue_status ALTER COLUMN status_id SET DEFAULT nextval('public.lkp_issue_status_status_id_seq'::regclass);


--
-- Name: lkp_job_title job_title_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_job_title ALTER COLUMN job_title_id SET DEFAULT nextval('public.lkp_job_title_job_title_id_seq'::regclass);


--
-- Name: lkp_land_use_type land_use_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_land_use_type ALTER COLUMN land_use_id SET DEFAULT nextval('public.lkp_land_use_type_land_use_id_seq'::regclass);


--
-- Name: lkp_leave_type leave_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_leave_type ALTER COLUMN leave_type_id SET DEFAULT nextval('public.lkp_leave_type_leave_type_id_seq'::regclass);


--
-- Name: lkp_operational_status status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_operational_status ALTER COLUMN status_id SET DEFAULT nextval('public.lkp_operational_status_status_id_seq'::regclass);


--
-- Name: lkp_ownership_type ownership_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_ownership_type ALTER COLUMN ownership_id SET DEFAULT nextval('public.lkp_ownership_type_ownership_id_seq'::regclass);


--
-- Name: lkp_parcel_document_type doc_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_parcel_document_type ALTER COLUMN doc_type_id SET DEFAULT nextval('public.lkp_parcel_document_type_doc_type_id_seq'::regclass);


--
-- Name: lkp_plan_status status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_plan_status ALTER COLUMN status_id SET DEFAULT nextval('public.lkp_plan_status_status_id_seq'::regclass);


--
-- Name: lkp_plan_type plan_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_plan_type ALTER COLUMN plan_type_id SET DEFAULT nextval('public.lkp_plan_type_plan_type_id_seq'::regclass);


--
-- Name: lkp_skill skill_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_skill ALTER COLUMN skill_id SET DEFAULT nextval('public.lkp_skill_skill_id_seq'::regclass);


--
-- Name: lkp_ugi_lifecycle_status lifecycle_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_ugi_lifecycle_status ALTER COLUMN lifecycle_id SET DEFAULT nextval('public.lkp_ugi_lifecycle_status_lifecycle_id_seq'::regclass);


--
-- Name: lkp_zone_type zone_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_zone_type ALTER COLUMN zone_type_id SET DEFAULT nextval('public.lkp_zone_type_zone_type_id_seq'::regclass);


--
-- Name: lkq_city city_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_city ALTER COLUMN city_id SET DEFAULT nextval('public.lkq_city_city_id_seq'::regclass);


--
-- Name: lkq_kebele kebele_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_kebele ALTER COLUMN kebele_id SET DEFAULT nextval('public.lkq_kebele_kebele_id_seq'::regclass);


--
-- Name: lkq_region region_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_region ALTER COLUMN region_id SET DEFAULT nextval('public.lkq_region_region_id_seq'::regclass);


--
-- Name: lkq_subcity subcity_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_subcity ALTER COLUMN subcity_id SET DEFAULT nextval('public.lkq_subcity_subcity_id_seq'::regclass);


--
-- Name: lkq_woreda woreda_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_woreda ALTER COLUMN woreda_id SET DEFAULT nextval('public.lkq_woreda_woreda_id_seq'::regclass);


--
-- Name: ugims_activity_execution execution_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution ALTER COLUMN execution_id SET DEFAULT nextval('public.ugims_activity_execution_execution_id_seq'::regclass);


--
-- Name: ugims_audit_log audit_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_audit_log ALTER COLUMN audit_id SET DEFAULT nextval('public.ugims_audit_log_audit_id_seq'::regclass);


--
-- Name: ugims_budget budget_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget ALTER COLUMN budget_id SET DEFAULT nextval('public.ugims_budget_budget_id_seq'::regclass);


--
-- Name: ugims_budget_line_item line_item_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget_line_item ALTER COLUMN line_item_id SET DEFAULT nextval('public.ugims_budget_line_item_line_item_id_seq'::regclass);


--
-- Name: ugims_citizen_report report_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report ALTER COLUMN report_id SET DEFAULT nextval('public.ugims_citizen_report_report_id_seq'::regclass);


--
-- Name: ugims_expense expense_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense ALTER COLUMN expense_id SET DEFAULT nextval('public.ugims_expense_expense_id_seq'::regclass);


--
-- Name: ugims_import_log import_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_import_log ALTER COLUMN import_id SET DEFAULT nextval('public.ugims_import_log_import_id_seq'::regclass);


--
-- Name: ugims_import_mapping mapping_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_import_mapping ALTER COLUMN mapping_id SET DEFAULT nextval('public.ugims_import_mapping_mapping_id_seq'::regclass);


--
-- Name: ugims_import_session session_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_import_session ALTER COLUMN session_id SET DEFAULT nextval('public.ugims_import_session_session_id_seq'::regclass);


--
-- Name: ugims_inspection inspection_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection ALTER COLUMN inspection_id SET DEFAULT nextval('public.ugims_inspection_inspection_id_seq'::regclass);


--
-- Name: ugims_inspection_finding finding_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection_finding ALTER COLUMN finding_id SET DEFAULT nextval('public.ugims_inspection_finding_finding_id_seq'::regclass);


--
-- Name: ugims_issue issue_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue ALTER COLUMN issue_id SET DEFAULT nextval('public.ugims_issue_issue_id_seq'::regclass);


--
-- Name: ugims_issue_comment comment_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue_comment ALTER COLUMN comment_id SET DEFAULT nextval('public.ugims_issue_comment_comment_id_seq'::regclass);


--
-- Name: ugims_maintenance_zone zone_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_maintenance_zone ALTER COLUMN zone_id SET DEFAULT nextval('public.ugims_maintenance_zone_zone_id_seq'::regclass);


--
-- Name: ugims_management_plan plan_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_management_plan ALTER COLUMN plan_id SET DEFAULT nextval('public.ugims_management_plan_plan_id_seq'::regclass);


--
-- Name: ugims_monitoring_log log_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_monitoring_log ALTER COLUMN log_id SET DEFAULT nextval('public.ugims_monitoring_log_log_id_seq'::regclass);


--
-- Name: ugims_parcel parcel_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel ALTER COLUMN parcel_id SET DEFAULT nextval('public.ugims_parcel_parcel_id_seq'::regclass);


--
-- Name: ugims_parcel_document document_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel_document ALTER COLUMN document_id SET DEFAULT nextval('public.ugims_parcel_document_document_id_seq'::regclass);


--
-- Name: ugims_parcel_history history_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel_history ALTER COLUMN history_id SET DEFAULT nextval('public.ugims_parcel_history_history_id_seq'::regclass);


--
-- Name: ugims_plan_activity plan_activity_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_plan_activity ALTER COLUMN plan_activity_id SET DEFAULT nextval('public.ugims_plan_activity_plan_activity_id_seq'::regclass);


--
-- Name: ugims_public_feedback feedback_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_public_feedback ALTER COLUMN feedback_id SET DEFAULT nextval('public.ugims_public_feedback_feedback_id_seq'::regclass);


--
-- Name: ugims_purchase_requisition requisition_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_purchase_requisition ALTER COLUMN requisition_id SET DEFAULT nextval('public.ugims_purchase_requisition_requisition_id_seq'::regclass);


--
-- Name: ugims_spatial_metadata metadata_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_spatial_metadata ALTER COLUMN metadata_id SET DEFAULT nextval('public.ugims_spatial_metadata_metadata_id_seq'::regclass);


--
-- Name: ugims_team team_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team ALTER COLUMN team_id SET DEFAULT nextval('public.ugims_team_team_id_seq'::regclass);


--
-- Name: ugims_team_membership membership_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team_membership ALTER COLUMN membership_id SET DEFAULT nextval('public.ugims_team_membership_membership_id_seq'::regclass);


--
-- Name: ugims_ugi ugi_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi ALTER COLUMN ugi_id SET DEFAULT nextval('public.ugims_ugi_ugi_id_seq'::regclass);


--
-- Name: ugims_ugi_component component_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi_component ALTER COLUMN component_id SET DEFAULT nextval('public.ugims_ugi_component_component_id_seq'::regclass);


--
-- Name: ugims_users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_users ALTER COLUMN user_id SET DEFAULT nextval('public.ugims_users_user_id_seq'::regclass);


--
-- Name: ugims_workforce_schedule schedule_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_schedule ALTER COLUMN schedule_id SET DEFAULT nextval('public.ugims_workforce_schedule_schedule_id_seq'::regclass);


--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_user (id, username, password, email, first_name, last_name, is_active, is_staff, is_superuser, last_login, date_joined) FROM stdin;
1	gardener1	pbkdf2_sha256$dummy	gardener1@example.com	\N	\N	t	f	f	\N	2026-03-11 01:16:10.882963
2	gardener2	pbkdf2_sha256$dummy	gardener2@example.com	\N	\N	t	f	f	\N	2026-03-11 01:16:10.882963
3	supervisor	pbkdf2_sha256$dummy	supervisor@example.com	\N	\N	t	f	f	\N	2026-03-11 01:16:10.882963
4	admin	admin	admin@example.com	\N	\N	t	f	f	\N	2026-03-11 01:16:10.882963
\.


--
-- Data for Name: lkp_accessibility_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_accessibility_type (access_id, access_name, description, requires_permit, requires_fee) FROM stdin;
1	Public - Free Access	Open to all without any restrictions	f	f
2	Public - Timed Access	Open to public during specific hours	f	f
3	Public - Fee Required	Open to public with entrance fee	f	t
4	Restricted - Permit Required	Access requires special permit	t	f
5	Restricted - Members Only	Only accessible to members	t	t
6	Private	Private property, no public access	t	f
7	Institutional	Access limited to institution members	t	f
\.


--
-- Data for Name: lkp_activity_category; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_activity_category (category_id, category_name, description, requires_special_skill) FROM stdin;
1	Vegetation Management	Activities related to plants and grass	f
2	Irrigation Management	Watering system operations	t
3	Infrastructure Maintenance	Repair of physical structures	t
4	Cleaning and Sanitation	Litter collection and cleaning	f
5	Safety and Security	Safety inspections and measures	t
6	Special Events	Event setup and support	f
7	Inspections	Regular condition assessments	t
8	Renovation	Major improvement projects	t
9	Pest Control	Pest management activities	t
10	Soil Management	Fertilizing and soil treatment	t
\.


--
-- Data for Name: lkp_activity_status; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_activity_status (status_id, status_name, status_code, description, is_terminal, can_edit) FROM stdin;
1	Planned	PLAN	Activity has been planned but not yet scheduled	f	t
2	Scheduled	SCHED	Activity has been assigned a specific date/time	f	t
3	Assigned	ASGN	Activity has been assigned to personnel	f	t
4	In Progress	PROG	Activity is currently being executed	f	f
5	Completed	COMP	Activity successfully completed	t	f
6	Cancelled	CANC	Activity was cancelled before completion	t	f
\.


--
-- Data for Name: lkp_activity_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_activity_type (activity_type_id, activity_name, activity_name_amharic, category_id, typical_duration_hours, typical_crew_size, requires_supervision, safety_gear_required, equipment_needed, season_preference, frequency_default_id) FROM stdin;
1	Grass Mowing	\N	1	2.00	2	t	\N	\N	Rainy	\N
2	Tree Pruning	\N	1	4.00	3	t	\N	\N	Dry	\N
3	Irrigation System Check	\N	2	1.00	1	t	\N	\N	Any	\N
4	Bench Repair	\N	3	1.50	1	t	\N	\N	Dry	\N
5	Litter Collection	\N	4	2.00	2	t	\N	\N	Any	\N
6	Routine Safety Inspection	\N	7	1.00	1	t	\N	\N	Any	\N
\.


--
-- Data for Name: lkp_budget_category; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_budget_category (category_id, category_name, category_code, description) FROM stdin;
1	Personnel - Salaries	PERS	Staff salaries and wages
2	Materials - Plants	MATP	Plants, trees, seeds, flowers
3	Equipment - Purchase	EQPP	New equipment purchase
4	Utilities - Water	UTLW	Water bills
5	Contract Services	CONTR	Outsourced services
6	Capital Projects	CAP	Major construction/renovation
\.


--
-- Data for Name: lkp_budget_source; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_budget_source (source_id, source_name, source_type, description) FROM stdin;
1	Municipal General Fund	Government	City general budget allocation
2	Federal Government Grant	Government	Grant from federal government
3	Donor - International	Donor	International aid/development funding
4	User Fees	Revenue	Fees collected from users
5	Sponsorships	Revenue	Corporate sponsorships
\.


--
-- Data for Name: lkp_citizen_report_status; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_citizen_report_status (status_id, status_name, status_name_amharic, description, is_visible_to_public) FROM stdin;
1	Submitted	\N	Report has been submitted	t
2	Under Review	\N	Staff is reviewing the report	t
3	Acknowledged	\N	Report has been acknowledged	t
4	Assigned	\N	Assigned to responsible team	t
5	In Progress	\N	Work on the issue has started	t
6	Resolved	\N	Issue has been resolved	t
7	Closed	\N	Report closed after verification	t
\.


--
-- Data for Name: lkp_citizen_report_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_citizen_report_type (report_type_id, report_type_name, report_type_name_amharic, category, default_priority_id, estimated_response_days) FROM stdin;
1	Broken Bench	\N	Infrastructure	3	7
2	Damaged Play Equipment	\N	Safety	2	3
3	Overgrown Vegetation	\N	Maintenance	4	14
4	Fallen Tree/Branch	\N	Safety	1	1
5	Broken Light	\N	Infrastructure	3	5
6	Trash Overflow	\N	Sanitation	4	2
\.


--
-- Data for Name: lkp_component_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_component_type (component_type_id, component_name, component_category, typical_lifespan_years, requires_regular_inspection, inspection_frequency_days) FROM stdin;
1	Park Bench	Seating	10	t	90
2	Street Light	Lighting	15	t	180
3	Public Toilet	Sanitation	15	t	7
4	Tree	Vegetation	50	t	180
5	Playground Equipment	Play	7	t	30
6	Fence	Boundary	15	t	180
7	Information Board	Signage	5	t	180
8	Sprinkler Head	Irrigation	3	t	30
9	Water Fountain	Water	8	t	30
10	Trash Can	Waste	3	t	7
\.


--
-- Data for Name: lkp_condition_status; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_condition_status (status_id, status_name, status_code, description, color_code, requires_immediate_action, maintenance_priority) FROM stdin;
1	Excellent	EXC	New or like-new condition, no maintenance needed	#00FF00	f	5
2	Good	GOOD	Minor wear only, routine maintenance sufficient	#90EE90	f	4
3	Fair	FAIR	Some deterioration, planned maintenance needed	#FFFF00	f	3
4	Poor	POOR	Significant deterioration, repair needed soon	#FFA500	f	2
5	Critical	CRIT	Unsafe or non-functional, immediate action required	#FF0000	t	1
6	Under Repair	REPR	Currently undergoing repair/maintenance	#0000FF	f	\N
7	Not Applicable	NA	Condition assessment not applicable	#808080	f	\N
8	Not Inspected	NINS	Has not been inspected recently	#C0C0C0	f	\N
\.


--
-- Data for Name: lkp_ethiopia_ugi_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_ethiopia_ugi_type (ugi_type_id, type_name, type_category, amharic_name, description, minimum_area_sq_m, requires_fencing, requires_lighting, requires_irrigation, maintenance_priority) FROM stdin;
1	Urban Park	Recreational	የከተማ መናፈሻ	Public park with recreational facilities, seating, and landscaping	1000.00	t	t	t	3
2	Sport Field	Recreational	የስፖርት ሜዳ	Designated area for athletic activities including football, athletics	5000.00	t	t	t	3
3	Cemetery	Cultural/Religious	የመቃብር ስፍራ	Burial grounds with vegetation and pathways	2000.00	t	f	f	3
4	Open Green Space	Recreational	ክፍት አረንጓዴ ቦታ	Unstructured grass and vegetation for recreation	500.00	f	f	f	3
5	Roadside Green Area	Transportation	የመንገድ ዳር አረንጓዴ	Vegetation along roads and highways	100.00	f	f	t	3
6	Road Divide/Median	Transportation	የመንገድ መከፋፈያ	Vegetated central reservations	50.00	f	f	t	3
7	Roundabout	Transportation	ክብ መንገድ	Circular intersection with central greenery	200.00	f	t	t	3
8	Urban Forest	Natural	የከተማ ደን	Dense vegetation area with trees and shrubs	5000.00	f	f	f	3
9	River/Riverside Green	Natural	የወንዝ ዳር አረንጓዴ	Riparian vegetation along water bodies	1000.00	f	f	f	3
10	Public Square/Plaza	Recreational	የህዝብ አደባባይ	Urban spaces with hardscape and greenery	500.00	f	t	t	3
11	Community Garden	Agricultural	የማህበረሰብ አትክልት ስፍራ	Cultivated lands for community agriculture	200.00	t	f	t	3
12	Botanical Garden	Educational	የእፅዋት አትክልት ስፍራ	Scientific collection of plants for research and education	2000.00	t	t	t	3
13	Children's Playground	Recreational	የህጻናት መጫወቻ	Area specifically designed for children with play equipment	300.00	t	t	t	3
14	Green Buffer Zone	Environmental	አረንጓዴ መከላከያ ቀጠና	Vegetated area separating different land uses	500.00	f	f	f	3
15	Institutional Grounds	Institutional	የተቋማት ግቢ	Green areas within schools, hospitals, government compounds	300.00	t	t	t	3
\.


--
-- Data for Name: lkp_finding_priority; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_finding_priority (priority_id, priority_name, response_time_hours, color_code, requires_immediate_action) FROM stdin;
1	Critical - Immediate	1	#FF0000	t
2	High - 24 Hours	24	#FFA500	t
3	Medium - 1 Week	168	#FFFF00	f
4	Low - 1 Month	720	#00FF00	f
5	Informational Only	\N	#0000FF	f
\.


--
-- Data for Name: lkp_fiscal_year; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_fiscal_year (fiscal_year_id, fiscal_year_name, start_date, end_date, is_current, description) FROM stdin;
1	2023-2024	2023-07-01	2024-06-30	f	\N
2	2024-2025	2024-07-01	2025-06-30	t	\N
3	2025-2026	2025-07-01	2026-06-30	f	\N
\.


--
-- Data for Name: lkp_frequency; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_frequency (frequency_id, frequency_name, days_interval, times_per_year, description) FROM stdin;
1	Daily	1	365.00	Every day
2	Weekly	7	52.00	Once per week
3	Bi-Weekly	14	26.00	Every two weeks
4	Monthly	30	12.00	Once per month
5	Bi-Monthly	60	6.00	Every two months
6	Quarterly	90	4.00	Every three months
7	Semi-Annually	180	2.00	Twice per year
8	Annually	365	1.00	Once per year
9	As Needed	\N	\N	On-demand, no fixed schedule
10	Seasonally - Dry Season	\N	1.00	Once during dry season
11	Seasonally - Rainy Season	\N	1.00	Once during rainy season
12	After Major Events	\N	\N	After storms, festivals, etc.
\.


--
-- Data for Name: lkp_inspection_status; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_inspection_status (status_id, status_name, description, allows_editing) FROM stdin;
1	Scheduled	Inspection has been scheduled	t
2	Assigned	Assigned to inspector	t
3	In Progress	Inspection is being conducted	t
4	Completed	Inspection completed, pending review	f
5	Approved	Inspection approved	f
\.


--
-- Data for Name: lkp_inspection_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_inspection_type (inspection_type_id, inspection_name, description, typical_frequency_id, requires_tools, requires_certification) FROM stdin;
1	Routine Maintenance Inspection	Regular check for maintenance needs	4	f	f
2	Safety Inspection	Check for safety hazards and risks	4	f	f
3	Tree Health Assessment	Detailed tree condition assessment	6	t	f
4	Playground Safety Inspection	Comprehensive playground equipment check	2	t	f
\.


--
-- Data for Name: lkp_issue_category; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_issue_category (category_id, category_name, description, default_priority_id) FROM stdin;
1	Safety Hazard	Issues that pose safety risks to public	1
2	Vandalism	Deliberate damage to property	2
3	Equipment Malfunction	Non-working equipment	3
4	Vegetation Problem	Issues with trees, grass, plants	3
5	Litter/Dumping	Illegal dumping or excessive litter	4
6	Lighting Issue	Non-functioning lights	3
\.


--
-- Data for Name: lkp_issue_status; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_issue_status (status_id, status_name, description, is_closed) FROM stdin;
1	Reported	Issue has been reported	f
2	Acknowledged	Issue has been acknowledged by staff	f
3	Assigned	Assigned to responsible person/team	f
4	In Progress	Work on issue has started	f
5	Resolved	Issue has been resolved	t
6	Closed	Issue closed after verification	t
\.


--
-- Data for Name: lkp_job_title; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_job_title (job_title_id, job_title_name, job_category, pay_grade, requires_certification, requires_license) FROM stdin;
1	UGI Director	Management	\N	f	f
2	UGI Deputy Director	Management	\N	f	f
3	Zone Manager	Management	\N	f	f
4	Senior Supervisor	Supervision	\N	f	f
5	Field Supervisor	Supervision	\N	f	f
6	Inspector	Inspection	\N	t	f
7	Senior Gardener	Field Staff	\N	t	f
8	Gardener	Field Staff	\N	f	f
9	Irrigation Technician	Technical	\N	t	f
10	Electrician	Technical	\N	t	f
11	Carpenter	Technical	\N	t	f
12	Mason	Technical	\N	t	f
13	Equipment Operator	Technical	\N	t	f
14	Laborer	Field Staff	\N	f	f
15	Tree Surgeon/Arborist	Specialist	\N	t	f
16	Pest Control Technician	Specialist	\N	t	f
17	Cleaner	Field Staff	\N	f	f
18	Security Guard	Security	\N	f	f
19	Administrative Assistant	Administrative	\N	f	f
20	GIS Specialist	Technical	\N	t	f
\.


--
-- Data for Name: lkp_land_use_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_land_use_type (land_use_id, land_use_name, land_use_category, description) FROM stdin;
1	Residential - Low Density	Residential	Single-family homes, villas
2	Residential - Medium Density	Residential	Apartment buildings, condominiums
3	Residential - Mixed Use	Residential	Residential with ground floor commercial
4	Commercial	Commercial	Shops, markets, offices
5	Industrial	Industrial	Factories, warehouses
6	Institutional	Public	Schools, hospitals, government offices
7	Recreational	Public	Parks, sports fields, public gardens
8	Religious	Public	Churches, mosques, monasteries
9	Cemetery	Public	Burial grounds
10	Transportation	Infrastructure	Roads, railways, airports
11	Agricultural	Rural	Farming land
12	Vacant	Undeveloped	Undeveloped land
13	Water Body	Natural	Lakes, rivers, ponds
14	Forest	Natural	Wooded areas, urban forests
15	Mixed Use	Commercial/Residential	Combined commercial and residential
\.


--
-- Data for Name: lkp_leave_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_leave_type (leave_type_id, leave_name, description, paid, days_per_year) FROM stdin;
1	Annual Leave	Regular vacation leave	t	20
2	Sick Leave	Medical leave	t	12
3	Emergency Leave	Family emergency	t	5
4	Maternity Leave	Maternity	t	90
5	Unpaid Leave	Leave without pay	f	\N
6	Public Holiday	Official holiday	t	\N
\.


--
-- Data for Name: lkp_operational_status; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_operational_status (status_id, status_name, status_code, description, is_accessible_to_public) FROM stdin;
1	Open - Fully Operational	OPEN	Fully open and functioning normally	t
2	Open - Limited Access	LIMIT	Open but with some areas restricted	t
3	Open - Reduced Hours	REDHR	Open with reduced operating hours	t
4	Temporarily Closed	TCLOS	Temporarily closed for maintenance or events	f
5	Closed - Seasonal	SEAS	Closed for the season	f
6	Closed - Under Construction	CONST	Closed for construction/renovation	f
7	Permanently Closed	PCLOS	Permanently closed/decommissioned	f
8	Under Maintenance	MAINT	Currently undergoing maintenance	f
9	Emergency Closure	EMERG	Closed due to emergency/safety issue	f
\.


--
-- Data for Name: lkp_ownership_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_ownership_type (ownership_id, ownership_name, description) FROM stdin;
1	Public - Federal Government	Owned by federal government of Ethiopia
2	Public - Regional Government	Owned by regional state government
3	Public - Municipal	Owned by city/municipal government
4	Public - Woreda	Owned by woreda administration
5	Private - Individual	Privately owned by individual
6	Private - Corporate	Owned by private company/organization
7	Religious Institution	Owned by religious organization
8	Community/Collective	Owned by community collectively
9	Mixed Ownership	Multiple owners/shareholders
10	Leasehold	Government land under long-term lease
11	Unregistered/Informal	Occupied without formal registration
\.


--
-- Data for Name: lkp_parcel_document_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_parcel_document_type (doc_type_id, doc_type_name, description) FROM stdin;
1	Title Deed	Official land ownership certificate
2	Lease Agreement	Contract for leased land
3	Survey Plan	Cadastral survey map
4	Tax Receipt	Proof of land/property tax payment
5	Transfer Deed	Document of ownership transfer
6	Court Order	Legal document affecting ownership
7	Mortgage Document	Loan security documentation
8	Zoning Certificate	Official zoning designation
9	Environmental Impact Assessment	EIA approval document
10	Building Permit	Construction approval
\.


--
-- Data for Name: lkp_plan_status; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_plan_status (status_id, status_name, description) FROM stdin;
1	Draft	\N
2	Submitted	\N
3	Approved	\N
4	Rejected	\N
5	In Progress	\N
6	Completed	\N
7	Cancelled	\N
\.


--
-- Data for Name: lkp_plan_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_plan_type (plan_type_id, plan_type_name, description, planning_horizon_days, requires_approval) FROM stdin;
1	Annual Maintenance Plan	Yearly plan for routine maintenance	365	t
2	Seasonal Plan	Plan for specific season (dry/rainy)	180	t
3	Capital Improvement Plan	Major renovation or new construction	730	t
4	Emergency Response Plan	Plan for emergencies and incidents	30	f
5	Event-Based Plan	Plan for specific events	60	t
6	Vegetation Management Plan	Specialized plan for vegetation	365	t
7	Irrigation Management Plan	Water management schedule	365	f
8	Pest Control Plan	Integrated pest management	180	t
9	5-Year Strategic Plan	Long-term strategic planning	1825	t
\.


--
-- Data for Name: lkp_skill; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_skill (skill_id, skill_name, skill_category, certification_required) FROM stdin;
1	Lawn Mowing	Grounds Maintenance	f
2	Hedge Trimming	Grounds Maintenance	f
3	Tree Pruning	Arboriculture	t
4	Pesticide Application	Pest Control	t
5	Irrigation Repair	Irrigation	t
6	Electrical Wiring	Electrical	t
7	Plumbing	Plumbing	t
8	Carpentry	Construction	f
9	Welding	Metalwork	t
10	First Aid	Safety	t
\.


--
-- Data for Name: lkp_ugi_lifecycle_status; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_ugi_lifecycle_status (lifecycle_id, lifecycle_name, description, next_stage_id, typical_duration_days) FROM stdin;
1	Planned	UGI has been planned but not yet established	\N	\N
2	Under Construction	Currently being developed/constructed	\N	180
3	Newly Established	Recently completed, in establishment phase	\N	365
4	Operational	Fully operational and mature	\N	\N
5	Under Renovation	Undergoing major renovation	\N	90
6	Decommissioned	No longer in use as UGI	\N	\N
7	Transferred	Ownership/management transferred	\N	\N
\.


--
-- Data for Name: lkp_zone_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkp_zone_type (zone_type_id, zone_type_name, description) FROM stdin;
1	Regular Maintenance Zone	Standard zones for routine maintenance activities
2	High-Profile Zone	Tourist areas, city centers requiring premium maintenance
3	Ecologically Sensitive Zone	Areas with protected species or sensitive ecosystems
4	Flood-Prone Zone	Areas requiring special drainage and flood management
5	New Development Zone	Recently developed areas with establishment-phase maintenance
6	Heritage Zone	Areas with historical or cultural significance
\.


--
-- Data for Name: lkq_city; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkq_city (city_id, city_name, region_id, municipality_code, geometry) FROM stdin;
1	Addis Ababa	1	\N	\N
2	Hawassa	2	\N	\N
3	Adama	3	\N	\N
4	Bahir Dar	4	\N	\N
5	Mekelle	5	\N	\N
\.


--
-- Data for Name: lkq_kebele; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkq_kebele (kebele_id, kebele_number, kebele_name, woreda_id, geometry) FROM stdin;
\.


--
-- Data for Name: lkq_region; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkq_region (region_id, region_name, region_code, geometry) FROM stdin;
1	Addis Ababa	AA	\N
2	Sidama	SD	\N
3	Oromia	OR	\N
4	Amhara	AM	\N
5	Tigray	TG	\N
6	Southern Nations Nationalities and Peoples	SNNP	\N
\.


--
-- Data for Name: lkq_subcity; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkq_subcity (subcity_id, subcity_name, city_id, administrative_code, geometry) FROM stdin;
1	Addis Ketema	1	\N	\N
2	Akaki Kaliti	1	\N	\N
3	Arada	1	\N	\N
4	Bole	1	\N	\N
5	Gulele	1	\N	\N
6	Kirkos	1	\N	\N
7	Kolfe Keranio	1	\N	\N
8	Lideta	1	\N	\N
9	Nifas Silk-Lafto	1	\N	\N
10	Yeka	1	\N	\N
11	Hawassa Tula	2	\N	\N
12	Hawassa Tabore	2	\N	\N
13	Hawassa Mehal	2	\N	\N
14	Hawassa Hayk Dar	2	\N	\N
15	Hawassa Adare	2	\N	\N
\.


--
-- Data for Name: lkq_woreda; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lkq_woreda (woreda_id, woreda_name, woreda_number, subcity_id, geometry) FROM stdin;
1	w	1	1	\N
\.


--
-- Data for Name: pointcloud_formats; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pointcloud_formats (pcid, srid, schema) FROM stdin;
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: ugims_activity_execution; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_activity_execution (execution_id, plan_activity_id, ugi_id, activity_type_id, execution_number, actual_start_datetime, actual_end_datetime, scheduled_start_datetime, start_location, end_location, work_area, tracking_path, performed_by_user_id, performed_by_team_id, supervised_by_user_id, additional_workers, actual_man_days, actual_man_hours, actual_labor_cost, actual_material_cost, actual_equipment_cost, total_actual_cost, materials_used, materials_used_text, equipment_used, work_performed, work_notes, challenges_encountered, deviations_from_plan, completion_status_id, completion_percentage, quality_rating, quality_notes, before_photos, during_photos, after_photos, additional_documents, verified_by_user_id, verification_datetime, verification_notes, verification_status, issues_identified, issue_ids, followup_required, followup_notes, followup_date, weather_conditions, temperature_c, precipitation, wind_conditions, recorded_datetime, recorded_by_user_id, last_updated, mobile_device_id, mobile_app_version, sync_datetime, offline_record) FROM stdin;
\.


--
-- Data for Name: ugims_audit_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_audit_log (audit_id, table_name, record_id, action, old_data, new_data, changed_by_user_id, changed_datetime, ip_address, user_agent) FROM stdin;
\.


--
-- Data for Name: ugims_budget; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_budget (budget_id, budget_code, budget_name, fiscal_year_id, budget_year, start_date, end_date, budget_type, budget_source_id, funding_source_details, scope_type, zone_id, ugi_id, department_id, project_name, allocated_amount, committed_amount, expended_amount, currency, exchange_rate, original_amount, budget_status, approval_status, approved_by_user_id, approval_date, approval_document, manager_user_id, finance_officer_user_id, category_breakdown, notes, restrictions, created_date, last_updated, created_by_user_id, updated_by_user_id) FROM stdin;
1	\N	Parks Maintenance	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	100000.00	0.00	0.00	ETB	\N	\N	Approved	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N
2	\N	Sports Facilities	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	50000.00	0.00	0.00	ETB	\N	\N	Approved	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N
\.


--
-- Data for Name: ugims_budget_line_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_budget_line_item (line_item_id, budget_id, line_number, category_id, description, allocated_amount, committed_amount, expended_amount, is_recurring, recurring_frequency, notes, created_date, last_updated) FROM stdin;
\.


--
-- Data for Name: ugims_citizen_report; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_citizen_report (report_id, report_number, reporter_name, reporter_email, reporter_phone, is_anonymous, preferred_contact_method, report_type_id, report_title, report_description, location_point, location_description, ugi_id, address_text, photo_urls, status_id, assigned_to_user_id, assigned_team_id, assigned_datetime, issue_id, inspection_id, response_message, response_datetime, responded_by_user_id, resolved_datetime, resolution_notes, resolution_photo_urls, satisfaction_rating, feedback_comments, created_date, last_updated, created_by_user_id, mobile_device_id, app_version, sync_datetime) FROM stdin;
1	RPT-20240315-001	Solomon Ayele	solomon@email.com	\N	f	\N	1	\N	Bench broken near the main entrance	0101000020A94E000000000000C0C81C4100000000C8872E41	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N	\N	\N
2	RPT-20240316-002	Meron Tadesse	meron@email.com	\N	f	\N	3	\N	Grass overgrown, needs mowing	0101000020A94E000000000000B0D31C4100000000408D2E41	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N	\N	\N
\.


--
-- Data for Name: ugims_expense; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_expense (expense_id, expense_number, budget_id, line_item_id, expense_date, description, amount, category_id, expense_type, vendor_name, vendor_id, invoice_number, receipt_number, ugi_id, activity_execution_id, plan_id, work_order_id, payment_method, payment_status, payment_date, paid_by_user_id, supporting_documents, notes, approved_by_user_id, approval_date, approval_notes, created_date, created_by_user_id, last_updated) FROM stdin;
1	\N	1	\N	2024-07-20	Grass cutting materials	1200.00	\N	\N	Green Supplies Co.	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-11 01:16:10.882963	\N	2026-03-11 01:16:10.882963
2	\N	1	\N	2024-08-05	Pruning tools	450.00	\N	\N	Garden World	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-11 01:16:10.882963	\N	2026-03-11 01:16:10.882963
3	\N	2	\N	2024-09-15	Track paint	3500.00	\N	\N	Sport Equipment Ltd	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-11 01:16:10.882963	\N	2026-03-11 01:16:10.882963
\.


--
-- Data for Name: ugims_import_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_import_log (import_id, import_type, filename, records_processed, records_success, records_failed, import_date, imported_by_user_id, status, error_log) FROM stdin;
1	parcel	parcels_20240315.shp	150	145	5	2026-03-11 01:16:10.882963	2	completed	\N
2	ugi	ugis_20240316.shp	75	72	3	2026-03-11 01:16:10.882963	3	completed	\N
\.


--
-- Data for Name: ugims_import_mapping; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_import_mapping (mapping_id, mapping_name, import_type, field_mapping, created_by, created_date, is_default) FROM stdin;
1	Default Parcel Mapping	parcel	{"field1": "column1", "field2": "column2"}	1	2026-03-11 01:16:10.882963	t
2	Default UGI Mapping	ugi	{"field1": "column1", "field2": "column2"}	1	2026-03-11 01:16:10.882963	t
\.


--
-- Data for Name: ugims_import_session; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_import_session (session_id, user_id, import_type, temp_dir, shapefile_name, total_records, field_mapping, created_date, expires_at) FROM stdin;
1	2	parcel	/tmp/import_123	parcels.shp	150	{"field1": "column1"}	2026-03-11 01:16:10.882963	2026-03-11 03:16:10.882963
2	3	ugi	/tmp/import_456	ugis.shp	75	{"field1": "column1"}	2026-03-11 01:16:10.882963	2026-03-11 03:16:10.882963
\.


--
-- Data for Name: ugims_inspection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_inspection (inspection_id, inspection_number, inspection_type_id, ugi_id, component_id, inspection_area, scheduled_date, scheduled_by_user_id, assigned_to_user_id, assigned_date, started_datetime, completed_datetime, inspector_user_id, inspector_notes, inspection_path, start_location, end_location, overall_condition_id, overall_rating, findings_summary, recommendations, issues_found, critical_issues_found, issue_count, inspection_status_id, report_document_url, photo_urls, video_urls, followup_required, followup_inspection_id, followup_date, created_date, last_updated, created_by_user_id, updated_by_user_id, mobile_device_id, sync_datetime, offline_record) FROM stdin;
1	INS-20240320-001	1	1	\N	\N	2024-03-20 10:00:00	\N	\N	\N	\N	\N	\N	Check all benches and lights	\N	\N	\N	\N	\N	\N	\N	f	f	0	1	\N	\N	\N	f	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N	\N	\N	f
2	INS-20240321-002	2	3	\N	\N	2024-03-21 14:00:00	\N	\N	\N	\N	\N	\N	Playground safety inspection	\N	\N	\N	\N	\N	\N	\N	f	f	0	1	\N	\N	\N	f	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N	\N	\N	f
\.


--
-- Data for Name: ugims_inspection_finding; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_inspection_finding (finding_id, inspection_id, ugi_id, component_id, location_point, location_description, finding_type, finding_description, finding_priority_id, condition_before_id, condition_after_id, quantity_affected, severity, immediate_action_taken, recommended_action, recommended_action_date, estimated_repair_cost, estimated_repair_hours, assigned_to_user_id, assigned_date, work_order_created, work_order_id, resolved, resolved_date, resolved_by_user_id, resolution_notes, photo_urls, created_date, last_updated) FROM stdin;
1	1	\N	\N	\N	\N	\N	Two benches have loose screws	3	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	\N	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963
2	1	\N	\N	\N	\N	\N	One light pole not working	2	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	\N	f	\N	f	\N	\N	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963
\.


--
-- Data for Name: ugims_issue; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_issue (issue_id, issue_number, source_type, source_reference_id, category_id, issue_type, priority_id, ugi_id, component_id, location_point, location_description, title, description, reported_by_name, reported_by_contact, reported_datetime, severity, affects_safety, affects_accessibility, affects_operations, photo_urls, assigned_to_user_id, assigned_to_team_id, assigned_datetime, assigned_by_user_id, work_order_created, work_order_id, status_id, status_history, resolved_datetime, resolved_by_user_id, resolution_notes, resolution_action_taken, verified_by_user_id, verification_datetime, verification_notes, estimated_cost, actual_cost, created_date, last_updated, created_by_user_id, updated_by_user_id) FROM stdin;
\.


--
-- Data for Name: ugims_issue_comment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_issue_comment (comment_id, issue_id, comment_text, comment_type, commented_by_user_id, commented_by_name, commented_datetime, attachments, is_public) FROM stdin;
\.


--
-- Data for Name: ugims_maintenance_zone; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_maintenance_zone (zone_id, zone_name, zone_code, zone_manager_user_id, subcity_id, geometry, area_sq_m, priority_level, is_active, created_date, description) FROM stdin;
\.


--
-- Data for Name: ugims_management_plan; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_management_plan (plan_id, plan_number, plan_name, plan_type_id, fiscal_year_id, scope_type, ugi_ids, zone_id, planned_start_date, planned_end_date, actual_start_date, actual_end_date, total_budget_allocated, total_estimated_cost, total_actual_cost, budget_source, budget_code, total_estimated_man_days, total_actual_man_days, estimated_equipment_hours, plan_status_id, approval_status_id, approved_by_user_id, approval_date, approval_notes, prepared_by_user_id, prepared_date, reviewed_by_user_id, reviewed_date, goals_and_objectives, success_criteria, risks_and_assumptions, created_date, last_updated, created_by_user_id, updated_by_user_id, notes, attachments) FROM stdin;
1	\N	Annual Park Maintenance 2024	1	2	\N	\N	\N	2024-07-01	2025-06-30	\N	\N	150000.00	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	Routine upkeep of all parks	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N	\N	\N
2	\N	Sport Field Renovation	3	2	\N	\N	\N	2024-09-01	2024-12-31	\N	\N	300000.00	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	Resurface running track	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N	\N	\N
\.


--
-- Data for Name: ugims_monitoring_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_monitoring_log (log_id, log_number, ugi_id, location_point, location_description, monitor_user_id, log_datetime, log_type, log_category, observations, issues_noted, actions_taken, observed_condition_id, visitor_count_estimate, weather_conditions, temperature_c, recent_rainfall, photo_urls, is_urgent, requires_followup, followup_notes, created_date, last_updated, created_by_user_id, mobile_device_id, sync_datetime, offline_record) FROM stdin;
\.


--
-- Data for Name: ugims_parcel; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_parcel (parcel_id, parcel_number, parcel_registration_number, geometry, region_id, city_id, subcity_id, woreda_id, kebele_id, maintenance_zone_id, street_name, house_number, landmark, gps_coordinates, land_use_type_id, ownership_type_id, owner_name, owner_id_number, owner_contact, area_sq_m, cadastral_zone, registration_date, last_updated, updated_by_user_id, status_id, spatial_accuracy, survey_date, survey_method) FROM stdin;
1	PARC-001	\N	0106000020A94E000001000000010300000001000000050000000000000030C71C410000000068882E410000000050CA1C410000000068882E410000000050CA1C4100000000D8862E410000000030C71C4100000000D8862E410000000030C71C410000000068882E41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	3	\N	\N	\N	\N	\N	\N	2026-03-11 01:16:10.882963	\N	\N	\N	\N	\N
2	PARC-002	\N	0106000020A94E000001000000010300000001000000050000000000000020D21C4100000000E08D2E410000000040D51C4100000000E08D2E410000000040D51C4100000000508C2E410000000020D21C4100000000508C2E410000000020D21C4100000000E08D2E41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	3	\N	\N	\N	\N	\N	\N	2026-03-11 01:16:10.882963	\N	\N	\N	\N	\N
3	PARC-003	\N	0106000020A94E000001000000010300000001000000050000000000000040BC1C4100000000C8782E410000000060BF1C4100000000C8782E410000000060BF1C410000000038772E410000000040BC1C410000000038772E410000000040BC1C4100000000C8782E41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	5	\N	\N	\N	\N	\N	\N	2026-03-11 01:16:10.882963	\N	\N	\N	\N	\N
4	PARC-2255	111111	0106000020A94E0000010000000103000000010000000600000048474B4BAB471C41D22D2D2DBDA22E41FBFAFFFF5F241C4177000000909C2E41AB0A0F0F6F3A1C41341F1E1E2EB22E41DF949696F6971C41E500000090AB2E4133D0D2D232781C41581E1E1E2E942E4148474B4BAB471C41D22D2D2DBDA22E41	1	1	\N	1	\N	\N	qqq	qq	qq	\N	3	4	aaa	123	qqq	\N	\N	2026-03-03	2026-03-11 01:57:49.658232	\N	\N	12	2026-05-14	www
\.


--
-- Data for Name: ugims_parcel_document; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_parcel_document (document_id, parcel_id, document_type_id, document_title, document_number, issue_date, expiry_date, issuing_authority, file_url, uploaded_date, uploaded_by_user_id, is_verified, verified_by_user_id, verification_date) FROM stdin;
\.


--
-- Data for Name: ugims_parcel_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_parcel_history (history_id, parcel_id, change_type, old_geometry, new_geometry, old_owner, new_owner, change_reason, changed_date, changed_by_user_id, approved_by_user_id, approval_date, status) FROM stdin;
\.


--
-- Data for Name: ugims_plan_activity; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_plan_activity (plan_activity_id, plan_id, activity_number, activity_type_id, activity_name, activity_description, ugi_id, component_id, target_area, frequency_id, scheduled_start_date, scheduled_end_date, scheduled_start_month, scheduled_end_month, preferred_time_of_day, duration_days, is_recurring, recurring_pattern, estimated_man_days, estimated_labor_cost, estimated_material_cost, estimated_equipment_cost, total_estimated_cost, required_materials, required_materials_list, required_equipment, required_equipment_list, estimated_crew_size, required_skills, assigned_team_id, assigned_team_lead, depends_on_activity_id, prerequisites, priority, activity_status_id, weather_dependent, preferred_weather, cannot_execute_in_rain, safety_requirements, requires_supervision, expected_outcome, quality_standards, created_date, last_updated, created_by_user_id, updated_by_user_id) FROM stdin;
1	1	\N	1	\N	\N	1	\N	\N	\N	2024-07-15	2024-07-20	\N	\N	\N	\N	f	\N	5.00	2500.00	500.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	1	f	\N	f	\N	t	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N
2	1	\N	2	\N	\N	1	\N	\N	\N	2024-08-01	2024-08-05	\N	\N	\N	\N	f	\N	3.00	1500.00	300.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	1	f	\N	f	\N	t	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N
3	2	\N	3	\N	\N	2	\N	\N	\N	2024-09-10	2024-09-30	\N	\N	\N	\N	f	\N	20.00	15000.00	5000.00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	1	f	\N	f	\N	t	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N
\.


--
-- Data for Name: ugims_public_feedback; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_public_feedback (feedback_id, ugi_id, feedback_type, visitor_purpose, overall_rating, cleanliness_rating, safety_rating, maintenance_rating, accessibility_rating, comments, suggestions, contact_email, contact_phone, visit_date, feedback_date, source, anonymous) FROM stdin;
\.


--
-- Data for Name: ugims_purchase_requisition; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_purchase_requisition (requisition_id, requisition_number, requisition_date, requested_by_user_id, department_id, purpose, ugi_id, activity_id, items, total_estimated_cost, budget_id, budget_check_status, budget_check_notes, approval_status, current_approver_level, approval_history, approved_by_user_id, approval_date, approval_notes, purchase_order_id, purchase_order_date, created_date, last_updated) FROM stdin;
\.


--
-- Data for Name: ugims_spatial_metadata; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_spatial_metadata (metadata_id, table_name, column_name, srid, geometry_type, feature_count, last_updated, extent_geometry, notes) FROM stdin;
\.


--
-- Data for Name: ugims_team; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_team (team_id, team_name, team_code, team_type, assigned_zone_id, specialization, team_lead_user_id, assistant_lead_user_id, min_members, max_members, current_member_count, shift, work_days, assigned_vehicles, assigned_equipment, is_active, status, created_date, last_updated, created_by_user_id, updated_by_user_id) FROM stdin;
2	South Zone Team	SZT01	Maintenance	\N	\N	\N	\N	\N	\N	0	\N	\N	\N	\N	t	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N
1	North Zone Team	NZT01	Maintenance	\N	\N	3	\N	\N	\N	0	\N	\N	\N	\N	t	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N
\.


--
-- Data for Name: ugims_team_membership; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_team_membership (membership_id, team_id, user_id, role_in_team, assigned_date, end_date, is_active, notes, created_date, created_by_user_id) FROM stdin;
1	1	3	Team Lead	2026-03-11	\N	t	\N	2026-03-11 01:16:10.882963	\N
2	1	1	Member	2026-03-11	\N	t	\N	2026-03-11 01:16:10.882963	\N
3	2	2	Member	2026-03-11	\N	t	\N	2026-03-11 01:16:10.882963	\N
\.


--
-- Data for Name: ugims_ugi; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_ugi (ugi_id, ugi_type_id, parcel_id, name, amharic_name, alternate_names, ugi_code, geometry, region_id, city_id, subcity_id, woreda_id, kebele_id, maintenance_zone_id, street_address, landmark_nearby, google_maps_link, what3words, establishment_date, inauguration_date, designed_by, constructed_by, construction_cost, accessibility_type_id, operating_hours_id, has_lighting, has_irrigation, has_fencing, has_parking, has_public_toilet, has_water_fountain, has_seating, has_wifi, has_security, has_handicap_access, visitor_capacity, peak_hours, peak_season, condition_status_id, operational_status_id, last_inspected_date, next_inspection_due, managing_department_id, maintenance_responsible_id, contact_person, contact_phone, contact_email, tree_count, tree_species, grass_type, irrigation_source, water_requirement_estimate, created_date, last_updated, created_by_user_id, updated_by_user_id) FROM stdin;
2	2	2	Addis Stadium	\N	\N	\N	0106000020A94E0000010000000103000000010000000500000000000000E8D21C41000000007C8D2E410000000078D41C41000000007C8D2E410000000078D41C4100000000B48C2E4100000000E8D21C4100000000B48C2E4100000000E8D21C41000000007C8D2E41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	t	f	f	f	f	f	f	f	f	2000	\N	\N	3	1	\N	\N	\N	\N	Stadium Authority	+251922222222	stadium@example.com	45	\N	\N	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N
3	13	3	Children's Playground		\N	\N	0106000020A94E000001000000010300000001000000050000000000000008BD1C410000000064782E410000000098BE1C410000000064782E410000000098BE1C41000000009C772E410000000008BD1C41000000009C772E410000000008BD1C410000000064782E41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	f	f	f	f	f	f	f	f	f	150	\N	\N	8	1	\N	\N	\N	\N	Community Center	+251933333333	playground@example.com	8	\N	\N	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:22:02.537946	\N	\N
1	1	1	Friendship Park		\N	\N	0106000020A94E0000010000000103000000010000000500000000000000F8C71C410000000004882E410000000088C91C410000000004882E410000000088C91C41000000003C872E4100000000F8C71C41000000003C872E4100000000F8C71C410000000004882E41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	t	f	f	f	f	f	f	f	f	500	\N	\N	5	1	\N	\N	\N	\N	Park Manager	+251911111111	park@example.com	120	\N	\N	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:25:30.454021	\N	\N
6	8	4	aaa	aaa	\N	\N	0106000020A94E00000100000001030000000100000005000000632268E5B07C1C41E76EFAE8DC5B2E413678D0CBBA7C1C41CA765CF24A732E4173544D0406B01C410760EBC945732E410FE9BA18FDAF1C4197A65FC4D75B2E41632268E5B07C1C41E76EFAE8DC5B2E41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	t	t	f	f	f	f	f	f	f	10	\N	\N	7	5	\N	\N	\N	\N	a	a	a@aa.com	100	\N	\N	\N	\N	2026-03-11 02:00:04.953936	2026-03-11 02:00:04.953936	\N	\N
\.


--
-- Data for Name: ugims_ugi_component; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_ugi_component (component_id, ugi_id, component_type_id, component_code, geometry, location_description, floor_number, manufacturer, model_number, serial_number, installation_date, material_type, color, dimensions, weight_kg, condition_status_id, last_inspected, inspection_frequency, warranty_expiry, maintenance_instructions, last_maintained, next_maintenance_due, operational_status_id, is_public, safety_rating, notes, photo_urls, created_date, last_updated, created_by_user_id, updated_by_user_id) FROM stdin;
\.


--
-- Data for Name: ugims_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_users (user_id, username, password_hash, full_name, email, role, created_at, last_login) FROM stdin;
2	inspector1	$2y$10$YourHashedPasswordHere	Abebe Kebede	inspector@ugims.et	inspector	2026-03-11 01:16:10.882963	\N
3	field1	$2y$10$YourHashedPasswordHere	Tigist Haile	field@ugims.et	field	2026-03-11 01:16:10.882963	\N
1	admin	$2y$10$A2lh0n5SLkSArtcU1OKGsut2ry0BGClIUf6NJlYYB78fCD5CErvFq	Admin User	admin@ugims.et	admin	2026-03-11 01:16:10.882963	2026-03-17 19:49:14.793257
\.


--
-- Data for Name: ugims_workforce_schedule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_workforce_schedule (schedule_id, user_id, schedule_date, shift_start, shift_end, break_duration_minutes, assignment_type, assigned_zone_id, assigned_task_id, clock_in_time, clock_out_time, clock_in_location, clock_out_location, actual_hours_worked, status, notes, created_date, last_updated, created_by_user_id) FROM stdin;
\.


--
-- Data for Name: ugims_workforce_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ugims_workforce_user (user_id, employee_id, first_name, last_name, amharic_name, phone_number, alternate_phone, email, emergency_contact_name, emergency_contact_phone, job_title_id, employment_type, employment_status, hire_date, contract_start_date, contract_end_date, termination_date, termination_reason, assigned_zone_id, reports_to_user_id, department_id, education_level, certifications, skills, years_experience, shift_preference, work_hours_per_week, overtime_eligible, assigned_equipment, vehicle_assigned, training_completed, training_required, last_training_date, next_training_due, medical_clearance_date, physical_capability_notes, allergies, can_access_mobile, mobile_device_assigned, last_login, created_date, last_updated, created_by_user_id, updated_by_user_id, is_active) FROM stdin;
1	EMP001	Gardener	One	\N	\N	\N	gardener1@example.com	\N	\N	8	Full-time	Active	2023-01-15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N	t
2	EMP002	Gardener	Two	\N	\N	\N	gardener2@example.com	\N	\N	8	Full-time	Active	2023-02-20	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N	t
3	EMP003	Super	Visor	\N	\N	\N	supervisor@example.com	\N	\N	5	Full-time	Active	2022-11-10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	\N	2026-03-11 01:16:10.882963	2026-03-11 01:16:10.882963	\N	\N	t
\.


--
-- Data for Name: us_gaz; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.us_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: us_lex; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.us_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: us_rules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.us_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: -
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: -
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: -
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: -
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: -
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: -
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auth_user_id_seq', 4, true);


--
-- Name: lkp_accessibility_type_access_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_accessibility_type_access_id_seq', 7, true);


--
-- Name: lkp_activity_category_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_activity_category_category_id_seq', 10, true);


--
-- Name: lkp_activity_status_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_activity_status_status_id_seq', 6, true);


--
-- Name: lkp_activity_type_activity_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_activity_type_activity_type_id_seq', 6, true);


--
-- Name: lkp_budget_category_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_budget_category_category_id_seq', 6, true);


--
-- Name: lkp_budget_source_source_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_budget_source_source_id_seq', 5, true);


--
-- Name: lkp_citizen_report_status_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_citizen_report_status_status_id_seq', 7, true);


--
-- Name: lkp_citizen_report_type_report_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_citizen_report_type_report_type_id_seq', 6, true);


--
-- Name: lkp_component_type_component_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_component_type_component_type_id_seq', 10, true);


--
-- Name: lkp_condition_status_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_condition_status_status_id_seq', 8, true);


--
-- Name: lkp_ethiopia_ugi_type_ugi_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_ethiopia_ugi_type_ugi_type_id_seq', 15, true);


--
-- Name: lkp_finding_priority_priority_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_finding_priority_priority_id_seq', 5, true);


--
-- Name: lkp_fiscal_year_fiscal_year_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_fiscal_year_fiscal_year_id_seq', 3, true);


--
-- Name: lkp_frequency_frequency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_frequency_frequency_id_seq', 12, true);


--
-- Name: lkp_inspection_status_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_inspection_status_status_id_seq', 5, true);


--
-- Name: lkp_inspection_type_inspection_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_inspection_type_inspection_type_id_seq', 4, true);


--
-- Name: lkp_issue_category_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_issue_category_category_id_seq', 6, true);


--
-- Name: lkp_issue_status_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_issue_status_status_id_seq', 6, true);


--
-- Name: lkp_job_title_job_title_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_job_title_job_title_id_seq', 20, true);


--
-- Name: lkp_land_use_type_land_use_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_land_use_type_land_use_id_seq', 15, true);


--
-- Name: lkp_leave_type_leave_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_leave_type_leave_type_id_seq', 6, true);


--
-- Name: lkp_operational_status_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_operational_status_status_id_seq', 9, true);


--
-- Name: lkp_ownership_type_ownership_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_ownership_type_ownership_id_seq', 11, true);


--
-- Name: lkp_parcel_document_type_doc_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_parcel_document_type_doc_type_id_seq', 10, true);


--
-- Name: lkp_plan_status_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_plan_status_status_id_seq', 7, true);


--
-- Name: lkp_plan_type_plan_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_plan_type_plan_type_id_seq', 9, true);


--
-- Name: lkp_skill_skill_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_skill_skill_id_seq', 10, true);


--
-- Name: lkp_ugi_lifecycle_status_lifecycle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_ugi_lifecycle_status_lifecycle_id_seq', 7, true);


--
-- Name: lkp_zone_type_zone_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkp_zone_type_zone_type_id_seq', 6, true);


--
-- Name: lkq_city_city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkq_city_city_id_seq', 5, true);


--
-- Name: lkq_kebele_kebele_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkq_kebele_kebele_id_seq', 1, false);


--
-- Name: lkq_region_region_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkq_region_region_id_seq', 6, true);


--
-- Name: lkq_subcity_subcity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkq_subcity_subcity_id_seq', 15, true);


--
-- Name: lkq_woreda_woreda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lkq_woreda_woreda_id_seq', 1, false);


--
-- Name: ugims_activity_execution_execution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_activity_execution_execution_id_seq', 1, false);


--
-- Name: ugims_audit_log_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_audit_log_audit_id_seq', 1, false);


--
-- Name: ugims_budget_budget_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_budget_budget_id_seq', 2, true);


--
-- Name: ugims_budget_line_item_line_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_budget_line_item_line_item_id_seq', 1, false);


--
-- Name: ugims_citizen_report_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_citizen_report_report_id_seq', 2, true);


--
-- Name: ugims_expense_expense_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_expense_expense_id_seq', 3, true);


--
-- Name: ugims_import_log_import_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_import_log_import_id_seq', 2, true);


--
-- Name: ugims_import_mapping_mapping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_import_mapping_mapping_id_seq', 2, true);


--
-- Name: ugims_import_session_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_import_session_session_id_seq', 2, true);


--
-- Name: ugims_inspection_finding_finding_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_inspection_finding_finding_id_seq', 2, true);


--
-- Name: ugims_inspection_inspection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_inspection_inspection_id_seq', 2, true);


--
-- Name: ugims_issue_comment_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_issue_comment_comment_id_seq', 1, false);


--
-- Name: ugims_issue_issue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_issue_issue_id_seq', 1, false);


--
-- Name: ugims_maintenance_zone_zone_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_maintenance_zone_zone_id_seq', 1, false);


--
-- Name: ugims_management_plan_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_management_plan_plan_id_seq', 2, true);


--
-- Name: ugims_monitoring_log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_monitoring_log_log_id_seq', 1, false);


--
-- Name: ugims_parcel_document_document_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_parcel_document_document_id_seq', 1, false);


--
-- Name: ugims_parcel_history_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_parcel_history_history_id_seq', 1, false);


--
-- Name: ugims_parcel_parcel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_parcel_parcel_id_seq', 4, true);


--
-- Name: ugims_plan_activity_plan_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_plan_activity_plan_activity_id_seq', 3, true);


--
-- Name: ugims_public_feedback_feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_public_feedback_feedback_id_seq', 1, false);


--
-- Name: ugims_purchase_requisition_requisition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_purchase_requisition_requisition_id_seq', 1, false);


--
-- Name: ugims_spatial_metadata_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_spatial_metadata_metadata_id_seq', 1, false);


--
-- Name: ugims_team_membership_membership_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_team_membership_membership_id_seq', 3, true);


--
-- Name: ugims_team_team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_team_team_id_seq', 2, true);


--
-- Name: ugims_ugi_component_component_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_ugi_component_component_id_seq', 1, false);


--
-- Name: ugims_ugi_ugi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_ugi_ugi_id_seq', 6, true);


--
-- Name: ugims_users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_users_user_id_seq', 3, true);


--
-- Name: ugims_workforce_schedule_schedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ugims_workforce_schedule_schedule_id_seq', 1, false);


--
-- Name: topology_id_seq; Type: SEQUENCE SET; Schema: topology; Owner: -
--

SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);


--
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: lkp_accessibility_type lkp_accessibility_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_accessibility_type
    ADD CONSTRAINT lkp_accessibility_type_pkey PRIMARY KEY (access_id);


--
-- Name: lkp_activity_category lkp_activity_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_activity_category
    ADD CONSTRAINT lkp_activity_category_pkey PRIMARY KEY (category_id);


--
-- Name: lkp_activity_status lkp_activity_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_activity_status
    ADD CONSTRAINT lkp_activity_status_pkey PRIMARY KEY (status_id);


--
-- Name: lkp_activity_status lkp_activity_status_status_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_activity_status
    ADD CONSTRAINT lkp_activity_status_status_code_key UNIQUE (status_code);


--
-- Name: lkp_activity_type lkp_activity_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_activity_type
    ADD CONSTRAINT lkp_activity_type_pkey PRIMARY KEY (activity_type_id);


--
-- Name: lkp_budget_category lkp_budget_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_budget_category
    ADD CONSTRAINT lkp_budget_category_pkey PRIMARY KEY (category_id);


--
-- Name: lkp_budget_source lkp_budget_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_budget_source
    ADD CONSTRAINT lkp_budget_source_pkey PRIMARY KEY (source_id);


--
-- Name: lkp_citizen_report_status lkp_citizen_report_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_citizen_report_status
    ADD CONSTRAINT lkp_citizen_report_status_pkey PRIMARY KEY (status_id);


--
-- Name: lkp_citizen_report_type lkp_citizen_report_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_citizen_report_type
    ADD CONSTRAINT lkp_citizen_report_type_pkey PRIMARY KEY (report_type_id);


--
-- Name: lkp_component_type lkp_component_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_component_type
    ADD CONSTRAINT lkp_component_type_pkey PRIMARY KEY (component_type_id);


--
-- Name: lkp_condition_status lkp_condition_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_condition_status
    ADD CONSTRAINT lkp_condition_status_pkey PRIMARY KEY (status_id);


--
-- Name: lkp_condition_status lkp_condition_status_status_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_condition_status
    ADD CONSTRAINT lkp_condition_status_status_code_key UNIQUE (status_code);


--
-- Name: lkp_ethiopia_ugi_type lkp_ethiopia_ugi_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_ethiopia_ugi_type
    ADD CONSTRAINT lkp_ethiopia_ugi_type_pkey PRIMARY KEY (ugi_type_id);


--
-- Name: lkp_finding_priority lkp_finding_priority_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_finding_priority
    ADD CONSTRAINT lkp_finding_priority_pkey PRIMARY KEY (priority_id);


--
-- Name: lkp_fiscal_year lkp_fiscal_year_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_fiscal_year
    ADD CONSTRAINT lkp_fiscal_year_pkey PRIMARY KEY (fiscal_year_id);


--
-- Name: lkp_frequency lkp_frequency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_frequency
    ADD CONSTRAINT lkp_frequency_pkey PRIMARY KEY (frequency_id);


--
-- Name: lkp_inspection_status lkp_inspection_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_inspection_status
    ADD CONSTRAINT lkp_inspection_status_pkey PRIMARY KEY (status_id);


--
-- Name: lkp_inspection_type lkp_inspection_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_inspection_type
    ADD CONSTRAINT lkp_inspection_type_pkey PRIMARY KEY (inspection_type_id);


--
-- Name: lkp_issue_category lkp_issue_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_issue_category
    ADD CONSTRAINT lkp_issue_category_pkey PRIMARY KEY (category_id);


--
-- Name: lkp_issue_status lkp_issue_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_issue_status
    ADD CONSTRAINT lkp_issue_status_pkey PRIMARY KEY (status_id);


--
-- Name: lkp_job_title lkp_job_title_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_job_title
    ADD CONSTRAINT lkp_job_title_pkey PRIMARY KEY (job_title_id);


--
-- Name: lkp_land_use_type lkp_land_use_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_land_use_type
    ADD CONSTRAINT lkp_land_use_type_pkey PRIMARY KEY (land_use_id);


--
-- Name: lkp_leave_type lkp_leave_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_leave_type
    ADD CONSTRAINT lkp_leave_type_pkey PRIMARY KEY (leave_type_id);


--
-- Name: lkp_operational_status lkp_operational_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_operational_status
    ADD CONSTRAINT lkp_operational_status_pkey PRIMARY KEY (status_id);


--
-- Name: lkp_operational_status lkp_operational_status_status_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_operational_status
    ADD CONSTRAINT lkp_operational_status_status_code_key UNIQUE (status_code);


--
-- Name: lkp_ownership_type lkp_ownership_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_ownership_type
    ADD CONSTRAINT lkp_ownership_type_pkey PRIMARY KEY (ownership_id);


--
-- Name: lkp_parcel_document_type lkp_parcel_document_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_parcel_document_type
    ADD CONSTRAINT lkp_parcel_document_type_pkey PRIMARY KEY (doc_type_id);


--
-- Name: lkp_plan_status lkp_plan_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_plan_status
    ADD CONSTRAINT lkp_plan_status_pkey PRIMARY KEY (status_id);


--
-- Name: lkp_plan_type lkp_plan_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_plan_type
    ADD CONSTRAINT lkp_plan_type_pkey PRIMARY KEY (plan_type_id);


--
-- Name: lkp_skill lkp_skill_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_skill
    ADD CONSTRAINT lkp_skill_pkey PRIMARY KEY (skill_id);


--
-- Name: lkp_ugi_lifecycle_status lkp_ugi_lifecycle_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_ugi_lifecycle_status
    ADD CONSTRAINT lkp_ugi_lifecycle_status_pkey PRIMARY KEY (lifecycle_id);


--
-- Name: lkp_zone_type lkp_zone_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_zone_type
    ADD CONSTRAINT lkp_zone_type_pkey PRIMARY KEY (zone_type_id);


--
-- Name: lkq_city lkq_city_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_city
    ADD CONSTRAINT lkq_city_pkey PRIMARY KEY (city_id);


--
-- Name: lkq_kebele lkq_kebele_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_kebele
    ADD CONSTRAINT lkq_kebele_pkey PRIMARY KEY (kebele_id);


--
-- Name: lkq_region lkq_region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_region
    ADD CONSTRAINT lkq_region_pkey PRIMARY KEY (region_id);


--
-- Name: lkq_region lkq_region_region_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_region
    ADD CONSTRAINT lkq_region_region_code_key UNIQUE (region_code);


--
-- Name: lkq_subcity lkq_subcity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_subcity
    ADD CONSTRAINT lkq_subcity_pkey PRIMARY KEY (subcity_id);


--
-- Name: lkq_woreda lkq_woreda_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_woreda
    ADD CONSTRAINT lkq_woreda_pkey PRIMARY KEY (woreda_id);


--
-- Name: ugims_activity_execution ugims_activity_execution_execution_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution
    ADD CONSTRAINT ugims_activity_execution_execution_number_key UNIQUE (execution_number);


--
-- Name: ugims_activity_execution ugims_activity_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution
    ADD CONSTRAINT ugims_activity_execution_pkey PRIMARY KEY (execution_id);


--
-- Name: ugims_audit_log ugims_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_audit_log
    ADD CONSTRAINT ugims_audit_log_pkey PRIMARY KEY (audit_id);


--
-- Name: ugims_budget ugims_budget_budget_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget
    ADD CONSTRAINT ugims_budget_budget_code_key UNIQUE (budget_code);


--
-- Name: ugims_budget_line_item ugims_budget_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget_line_item
    ADD CONSTRAINT ugims_budget_line_item_pkey PRIMARY KEY (line_item_id);


--
-- Name: ugims_budget ugims_budget_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget
    ADD CONSTRAINT ugims_budget_pkey PRIMARY KEY (budget_id);


--
-- Name: ugims_citizen_report ugims_citizen_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report
    ADD CONSTRAINT ugims_citizen_report_pkey PRIMARY KEY (report_id);


--
-- Name: ugims_citizen_report ugims_citizen_report_report_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report
    ADD CONSTRAINT ugims_citizen_report_report_number_key UNIQUE (report_number);


--
-- Name: ugims_expense ugims_expense_expense_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense
    ADD CONSTRAINT ugims_expense_expense_number_key UNIQUE (expense_number);


--
-- Name: ugims_expense ugims_expense_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense
    ADD CONSTRAINT ugims_expense_pkey PRIMARY KEY (expense_id);


--
-- Name: ugims_import_log ugims_import_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_import_log
    ADD CONSTRAINT ugims_import_log_pkey PRIMARY KEY (import_id);


--
-- Name: ugims_import_mapping ugims_import_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_import_mapping
    ADD CONSTRAINT ugims_import_mapping_pkey PRIMARY KEY (mapping_id);


--
-- Name: ugims_import_session ugims_import_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_import_session
    ADD CONSTRAINT ugims_import_session_pkey PRIMARY KEY (session_id);


--
-- Name: ugims_inspection_finding ugims_inspection_finding_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection_finding
    ADD CONSTRAINT ugims_inspection_finding_pkey PRIMARY KEY (finding_id);


--
-- Name: ugims_inspection ugims_inspection_inspection_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_inspection_number_key UNIQUE (inspection_number);


--
-- Name: ugims_inspection ugims_inspection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_pkey PRIMARY KEY (inspection_id);


--
-- Name: ugims_issue_comment ugims_issue_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue_comment
    ADD CONSTRAINT ugims_issue_comment_pkey PRIMARY KEY (comment_id);


--
-- Name: ugims_issue ugims_issue_issue_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_issue_number_key UNIQUE (issue_number);


--
-- Name: ugims_issue ugims_issue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_pkey PRIMARY KEY (issue_id);


--
-- Name: ugims_maintenance_zone ugims_maintenance_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_maintenance_zone
    ADD CONSTRAINT ugims_maintenance_zone_pkey PRIMARY KEY (zone_id);


--
-- Name: ugims_maintenance_zone ugims_maintenance_zone_zone_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_maintenance_zone
    ADD CONSTRAINT ugims_maintenance_zone_zone_code_key UNIQUE (zone_code);


--
-- Name: ugims_management_plan ugims_management_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_management_plan
    ADD CONSTRAINT ugims_management_plan_pkey PRIMARY KEY (plan_id);


--
-- Name: ugims_management_plan ugims_management_plan_plan_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_management_plan
    ADD CONSTRAINT ugims_management_plan_plan_number_key UNIQUE (plan_number);


--
-- Name: ugims_monitoring_log ugims_monitoring_log_log_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_monitoring_log
    ADD CONSTRAINT ugims_monitoring_log_log_number_key UNIQUE (log_number);


--
-- Name: ugims_monitoring_log ugims_monitoring_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_monitoring_log
    ADD CONSTRAINT ugims_monitoring_log_pkey PRIMARY KEY (log_id);


--
-- Name: ugims_parcel_document ugims_parcel_document_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel_document
    ADD CONSTRAINT ugims_parcel_document_pkey PRIMARY KEY (document_id);


--
-- Name: ugims_parcel_history ugims_parcel_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel_history
    ADD CONSTRAINT ugims_parcel_history_pkey PRIMARY KEY (history_id);


--
-- Name: ugims_parcel ugims_parcel_parcel_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_parcel_number_key UNIQUE (parcel_number);


--
-- Name: ugims_parcel ugims_parcel_parcel_registration_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_parcel_registration_number_key UNIQUE (parcel_registration_number);


--
-- Name: ugims_parcel ugims_parcel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_pkey PRIMARY KEY (parcel_id);


--
-- Name: ugims_plan_activity ugims_plan_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_plan_activity
    ADD CONSTRAINT ugims_plan_activity_pkey PRIMARY KEY (plan_activity_id);


--
-- Name: ugims_public_feedback ugims_public_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_public_feedback
    ADD CONSTRAINT ugims_public_feedback_pkey PRIMARY KEY (feedback_id);


--
-- Name: ugims_purchase_requisition ugims_purchase_requisition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_purchase_requisition
    ADD CONSTRAINT ugims_purchase_requisition_pkey PRIMARY KEY (requisition_id);


--
-- Name: ugims_purchase_requisition ugims_purchase_requisition_requisition_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_purchase_requisition
    ADD CONSTRAINT ugims_purchase_requisition_requisition_number_key UNIQUE (requisition_number);


--
-- Name: ugims_spatial_metadata ugims_spatial_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_spatial_metadata
    ADD CONSTRAINT ugims_spatial_metadata_pkey PRIMARY KEY (metadata_id);


--
-- Name: ugims_team_membership ugims_team_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team_membership
    ADD CONSTRAINT ugims_team_membership_pkey PRIMARY KEY (membership_id);


--
-- Name: ugims_team_membership ugims_team_membership_team_id_user_id_assigned_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team_membership
    ADD CONSTRAINT ugims_team_membership_team_id_user_id_assigned_date_key UNIQUE (team_id, user_id, assigned_date);


--
-- Name: ugims_team ugims_team_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team
    ADD CONSTRAINT ugims_team_pkey PRIMARY KEY (team_id);


--
-- Name: ugims_team ugims_team_team_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team
    ADD CONSTRAINT ugims_team_team_code_key UNIQUE (team_code);


--
-- Name: ugims_ugi_component ugims_ugi_component_component_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi_component
    ADD CONSTRAINT ugims_ugi_component_component_code_key UNIQUE (component_code);


--
-- Name: ugims_ugi_component ugims_ugi_component_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi_component
    ADD CONSTRAINT ugims_ugi_component_pkey PRIMARY KEY (component_id);


--
-- Name: ugims_ugi ugims_ugi_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_pkey PRIMARY KEY (ugi_id);


--
-- Name: ugims_ugi ugims_ugi_ugi_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_ugi_code_key UNIQUE (ugi_code);


--
-- Name: ugims_users ugims_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_users
    ADD CONSTRAINT ugims_users_pkey PRIMARY KEY (user_id);


--
-- Name: ugims_users ugims_users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_users
    ADD CONSTRAINT ugims_users_username_key UNIQUE (username);


--
-- Name: ugims_workforce_schedule ugims_workforce_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_schedule
    ADD CONSTRAINT ugims_workforce_schedule_pkey PRIMARY KEY (schedule_id);


--
-- Name: ugims_workforce_schedule ugims_workforce_schedule_user_id_schedule_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_schedule
    ADD CONSTRAINT ugims_workforce_schedule_user_id_schedule_date_key UNIQUE (user_id, schedule_date);


--
-- Name: ugims_workforce_user ugims_workforce_user_employee_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_user
    ADD CONSTRAINT ugims_workforce_user_employee_id_key UNIQUE (employee_id);


--
-- Name: ugims_workforce_user ugims_workforce_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_user
    ADD CONSTRAINT ugims_workforce_user_pkey PRIMARY KEY (user_id);


--
-- Name: idx_activity_execution_dates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_execution_dates ON public.ugims_activity_execution USING btree (actual_start_datetime);


--
-- Name: idx_activity_execution_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_execution_status ON public.ugims_activity_execution USING btree (completion_status_id);


--
-- Name: idx_activity_execution_ugi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_execution_ugi ON public.ugims_activity_execution USING btree (ugi_id);


--
-- Name: idx_activity_tracking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_tracking ON public.ugims_activity_execution USING gist (tracking_path);


--
-- Name: idx_citizen_report_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_citizen_report_date ON public.ugims_citizen_report USING btree (created_date);


--
-- Name: idx_citizen_report_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_citizen_report_location ON public.ugims_citizen_report USING gist (location_point);


--
-- Name: idx_citizen_report_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_citizen_report_status ON public.ugims_citizen_report USING btree (status_id);


--
-- Name: idx_import_log_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_import_log_date ON public.ugims_import_log USING btree (import_date);


--
-- Name: idx_import_log_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_import_log_status ON public.ugims_import_log USING btree (status);


--
-- Name: idx_import_log_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_import_log_user ON public.ugims_import_log USING btree (imported_by_user_id);


--
-- Name: idx_import_mapping_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_import_mapping_created_by ON public.ugims_import_mapping USING btree (created_by);


--
-- Name: idx_import_mapping_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_import_mapping_type ON public.ugims_import_mapping USING btree (import_type);


--
-- Name: idx_import_session_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_import_session_expires ON public.ugims_import_session USING btree (expires_at);


--
-- Name: idx_import_session_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_import_session_user ON public.ugims_import_session USING btree (user_id);


--
-- Name: idx_inspection_dates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspection_dates ON public.ugims_inspection USING btree (scheduled_date);


--
-- Name: idx_inspection_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspection_path ON public.ugims_inspection USING gist (inspection_path);


--
-- Name: idx_inspection_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspection_status ON public.ugims_inspection USING btree (inspection_status_id);


--
-- Name: idx_inspection_ugi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspection_ugi ON public.ugims_inspection USING btree (ugi_id);


--
-- Name: idx_issue_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_issue_priority ON public.ugims_issue USING btree (priority_id);


--
-- Name: idx_issue_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_issue_status ON public.ugims_issue USING btree (status_id);


--
-- Name: idx_issue_ugi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_issue_ugi ON public.ugims_issue USING btree (ugi_id);


--
-- Name: idx_parcel_geometry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parcel_geometry ON public.ugims_parcel USING gist (geometry);


--
-- Name: idx_parcel_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parcel_owner ON public.ugims_parcel USING btree (owner_name);


--
-- Name: idx_parcel_woreda; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parcel_woreda ON public.ugims_parcel USING btree (woreda_id);


--
-- Name: idx_ugi_centroid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ugi_centroid ON public.ugims_ugi USING gist (centroid);


--
-- Name: idx_ugi_condition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ugi_condition ON public.ugims_ugi USING btree (condition_status_id);


--
-- Name: idx_ugi_geometry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ugi_geometry ON public.ugims_ugi USING gist (geometry);


--
-- Name: idx_ugi_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ugi_type ON public.ugims_ugi USING btree (ugi_type_id);


--
-- Name: idx_ugi_woreda; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ugi_woreda ON public.ugims_ugi USING btree (woreda_id);


--
-- Name: idx_ugi_zone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ugi_zone ON public.ugims_ugi USING btree (maintenance_zone_id);


--
-- Name: idx_work_area; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_work_area ON public.ugims_plan_activity USING gist (target_area);


--
-- Name: lkp_activity_type lkp_activity_type_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_activity_type
    ADD CONSTRAINT lkp_activity_type_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.lkp_activity_category(category_id);


--
-- Name: lkp_activity_type lkp_activity_type_frequency_default_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_activity_type
    ADD CONSTRAINT lkp_activity_type_frequency_default_id_fkey FOREIGN KEY (frequency_default_id) REFERENCES public.lkp_frequency(frequency_id);


--
-- Name: lkp_citizen_report_type lkp_citizen_report_type_default_priority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_citizen_report_type
    ADD CONSTRAINT lkp_citizen_report_type_default_priority_id_fkey FOREIGN KEY (default_priority_id) REFERENCES public.lkp_finding_priority(priority_id);


--
-- Name: lkp_inspection_type lkp_inspection_type_typical_frequency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_inspection_type
    ADD CONSTRAINT lkp_inspection_type_typical_frequency_id_fkey FOREIGN KEY (typical_frequency_id) REFERENCES public.lkp_frequency(frequency_id);


--
-- Name: lkp_issue_category lkp_issue_category_default_priority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkp_issue_category
    ADD CONSTRAINT lkp_issue_category_default_priority_id_fkey FOREIGN KEY (default_priority_id) REFERENCES public.lkp_finding_priority(priority_id);


--
-- Name: lkq_city lkq_city_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_city
    ADD CONSTRAINT lkq_city_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.lkq_region(region_id);


--
-- Name: lkq_kebele lkq_kebele_woreda_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_kebele
    ADD CONSTRAINT lkq_kebele_woreda_id_fkey FOREIGN KEY (woreda_id) REFERENCES public.lkq_woreda(woreda_id);


--
-- Name: lkq_subcity lkq_subcity_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_subcity
    ADD CONSTRAINT lkq_subcity_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.lkq_city(city_id);


--
-- Name: lkq_woreda lkq_woreda_subcity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lkq_woreda
    ADD CONSTRAINT lkq_woreda_subcity_id_fkey FOREIGN KEY (subcity_id) REFERENCES public.lkq_subcity(subcity_id);


--
-- Name: ugims_activity_execution ugims_activity_execution_activity_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution
    ADD CONSTRAINT ugims_activity_execution_activity_type_id_fkey FOREIGN KEY (activity_type_id) REFERENCES public.lkp_activity_type(activity_type_id);


--
-- Name: ugims_activity_execution ugims_activity_execution_completion_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution
    ADD CONSTRAINT ugims_activity_execution_completion_status_id_fkey FOREIGN KEY (completion_status_id) REFERENCES public.lkp_activity_status(status_id);


--
-- Name: ugims_activity_execution ugims_activity_execution_performed_by_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution
    ADD CONSTRAINT ugims_activity_execution_performed_by_team_id_fkey FOREIGN KEY (performed_by_team_id) REFERENCES public.ugims_team(team_id);


--
-- Name: ugims_activity_execution ugims_activity_execution_performed_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution
    ADD CONSTRAINT ugims_activity_execution_performed_by_user_id_fkey FOREIGN KEY (performed_by_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_activity_execution ugims_activity_execution_plan_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution
    ADD CONSTRAINT ugims_activity_execution_plan_activity_id_fkey FOREIGN KEY (plan_activity_id) REFERENCES public.ugims_plan_activity(plan_activity_id);


--
-- Name: ugims_activity_execution ugims_activity_execution_recorded_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution
    ADD CONSTRAINT ugims_activity_execution_recorded_by_user_id_fkey FOREIGN KEY (recorded_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_activity_execution ugims_activity_execution_supervised_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution
    ADD CONSTRAINT ugims_activity_execution_supervised_by_user_id_fkey FOREIGN KEY (supervised_by_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_activity_execution ugims_activity_execution_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution
    ADD CONSTRAINT ugims_activity_execution_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id);


--
-- Name: ugims_activity_execution ugims_activity_execution_verified_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_activity_execution
    ADD CONSTRAINT ugims_activity_execution_verified_by_user_id_fkey FOREIGN KEY (verified_by_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_audit_log ugims_audit_log_changed_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_audit_log
    ADD CONSTRAINT ugims_audit_log_changed_by_user_id_fkey FOREIGN KEY (changed_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_budget ugims_budget_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget
    ADD CONSTRAINT ugims_budget_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_budget ugims_budget_budget_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget
    ADD CONSTRAINT ugims_budget_budget_source_id_fkey FOREIGN KEY (budget_source_id) REFERENCES public.lkp_budget_source(source_id);


--
-- Name: ugims_budget ugims_budget_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget
    ADD CONSTRAINT ugims_budget_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_budget ugims_budget_finance_officer_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget
    ADD CONSTRAINT ugims_budget_finance_officer_user_id_fkey FOREIGN KEY (finance_officer_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_budget ugims_budget_fiscal_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget
    ADD CONSTRAINT ugims_budget_fiscal_year_id_fkey FOREIGN KEY (fiscal_year_id) REFERENCES public.lkp_fiscal_year(fiscal_year_id);


--
-- Name: ugims_budget_line_item ugims_budget_line_item_budget_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget_line_item
    ADD CONSTRAINT ugims_budget_line_item_budget_id_fkey FOREIGN KEY (budget_id) REFERENCES public.ugims_budget(budget_id) ON DELETE CASCADE;


--
-- Name: ugims_budget_line_item ugims_budget_line_item_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget_line_item
    ADD CONSTRAINT ugims_budget_line_item_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.lkp_budget_category(category_id);


--
-- Name: ugims_budget ugims_budget_manager_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget
    ADD CONSTRAINT ugims_budget_manager_user_id_fkey FOREIGN KEY (manager_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_budget ugims_budget_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget
    ADD CONSTRAINT ugims_budget_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id);


--
-- Name: ugims_budget ugims_budget_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget
    ADD CONSTRAINT ugims_budget_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_budget ugims_budget_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_budget
    ADD CONSTRAINT ugims_budget_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.ugims_maintenance_zone(zone_id);


--
-- Name: ugims_citizen_report ugims_citizen_report_assigned_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report
    ADD CONSTRAINT ugims_citizen_report_assigned_team_id_fkey FOREIGN KEY (assigned_team_id) REFERENCES public.ugims_team(team_id);


--
-- Name: ugims_citizen_report ugims_citizen_report_assigned_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report
    ADD CONSTRAINT ugims_citizen_report_assigned_to_user_id_fkey FOREIGN KEY (assigned_to_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_citizen_report ugims_citizen_report_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report
    ADD CONSTRAINT ugims_citizen_report_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_citizen_report ugims_citizen_report_inspection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report
    ADD CONSTRAINT ugims_citizen_report_inspection_id_fkey FOREIGN KEY (inspection_id) REFERENCES public.ugims_inspection(inspection_id);


--
-- Name: ugims_citizen_report ugims_citizen_report_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report
    ADD CONSTRAINT ugims_citizen_report_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES public.ugims_issue(issue_id);


--
-- Name: ugims_citizen_report ugims_citizen_report_report_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report
    ADD CONSTRAINT ugims_citizen_report_report_type_id_fkey FOREIGN KEY (report_type_id) REFERENCES public.lkp_citizen_report_type(report_type_id);


--
-- Name: ugims_citizen_report ugims_citizen_report_responded_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report
    ADD CONSTRAINT ugims_citizen_report_responded_by_user_id_fkey FOREIGN KEY (responded_by_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_citizen_report ugims_citizen_report_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report
    ADD CONSTRAINT ugims_citizen_report_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.lkp_citizen_report_status(status_id);


--
-- Name: ugims_citizen_report ugims_citizen_report_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_citizen_report
    ADD CONSTRAINT ugims_citizen_report_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id);


--
-- Name: ugims_expense ugims_expense_activity_execution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense
    ADD CONSTRAINT ugims_expense_activity_execution_id_fkey FOREIGN KEY (activity_execution_id) REFERENCES public.ugims_activity_execution(execution_id);


--
-- Name: ugims_expense ugims_expense_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense
    ADD CONSTRAINT ugims_expense_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_expense ugims_expense_budget_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense
    ADD CONSTRAINT ugims_expense_budget_id_fkey FOREIGN KEY (budget_id) REFERENCES public.ugims_budget(budget_id);


--
-- Name: ugims_expense ugims_expense_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense
    ADD CONSTRAINT ugims_expense_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.lkp_budget_category(category_id);


--
-- Name: ugims_expense ugims_expense_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense
    ADD CONSTRAINT ugims_expense_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_expense ugims_expense_line_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense
    ADD CONSTRAINT ugims_expense_line_item_id_fkey FOREIGN KEY (line_item_id) REFERENCES public.ugims_budget_line_item(line_item_id);


--
-- Name: ugims_expense ugims_expense_paid_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense
    ADD CONSTRAINT ugims_expense_paid_by_user_id_fkey FOREIGN KEY (paid_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_expense ugims_expense_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense
    ADD CONSTRAINT ugims_expense_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.ugims_management_plan(plan_id);


--
-- Name: ugims_expense ugims_expense_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_expense
    ADD CONSTRAINT ugims_expense_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id);


--
-- Name: ugims_import_log ugims_import_log_imported_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_import_log
    ADD CONSTRAINT ugims_import_log_imported_by_user_id_fkey FOREIGN KEY (imported_by_user_id) REFERENCES public.ugims_users(user_id);


--
-- Name: ugims_import_mapping ugims_import_mapping_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_import_mapping
    ADD CONSTRAINT ugims_import_mapping_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.ugims_users(user_id);


--
-- Name: ugims_import_session ugims_import_session_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_import_session
    ADD CONSTRAINT ugims_import_session_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.ugims_users(user_id);


--
-- Name: ugims_inspection ugims_inspection_assigned_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_assigned_to_user_id_fkey FOREIGN KEY (assigned_to_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_inspection ugims_inspection_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.ugims_ugi_component(component_id);


--
-- Name: ugims_inspection ugims_inspection_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_inspection_finding ugims_inspection_finding_assigned_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection_finding
    ADD CONSTRAINT ugims_inspection_finding_assigned_to_user_id_fkey FOREIGN KEY (assigned_to_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_inspection_finding ugims_inspection_finding_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection_finding
    ADD CONSTRAINT ugims_inspection_finding_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.ugims_ugi_component(component_id);


--
-- Name: ugims_inspection_finding ugims_inspection_finding_condition_after_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection_finding
    ADD CONSTRAINT ugims_inspection_finding_condition_after_id_fkey FOREIGN KEY (condition_after_id) REFERENCES public.lkp_condition_status(status_id);


--
-- Name: ugims_inspection_finding ugims_inspection_finding_condition_before_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection_finding
    ADD CONSTRAINT ugims_inspection_finding_condition_before_id_fkey FOREIGN KEY (condition_before_id) REFERENCES public.lkp_condition_status(status_id);


--
-- Name: ugims_inspection_finding ugims_inspection_finding_finding_priority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection_finding
    ADD CONSTRAINT ugims_inspection_finding_finding_priority_id_fkey FOREIGN KEY (finding_priority_id) REFERENCES public.lkp_finding_priority(priority_id);


--
-- Name: ugims_inspection_finding ugims_inspection_finding_inspection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection_finding
    ADD CONSTRAINT ugims_inspection_finding_inspection_id_fkey FOREIGN KEY (inspection_id) REFERENCES public.ugims_inspection(inspection_id) ON DELETE CASCADE;


--
-- Name: ugims_inspection_finding ugims_inspection_finding_resolved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection_finding
    ADD CONSTRAINT ugims_inspection_finding_resolved_by_user_id_fkey FOREIGN KEY (resolved_by_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_inspection_finding ugims_inspection_finding_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection_finding
    ADD CONSTRAINT ugims_inspection_finding_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id);


--
-- Name: ugims_inspection ugims_inspection_inspection_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_inspection_status_id_fkey FOREIGN KEY (inspection_status_id) REFERENCES public.lkp_inspection_status(status_id);


--
-- Name: ugims_inspection ugims_inspection_inspection_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_inspection_type_id_fkey FOREIGN KEY (inspection_type_id) REFERENCES public.lkp_inspection_type(inspection_type_id);


--
-- Name: ugims_inspection ugims_inspection_inspector_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_inspector_user_id_fkey FOREIGN KEY (inspector_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_inspection ugims_inspection_overall_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_overall_condition_id_fkey FOREIGN KEY (overall_condition_id) REFERENCES public.lkp_condition_status(status_id);


--
-- Name: ugims_inspection ugims_inspection_scheduled_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_scheduled_by_user_id_fkey FOREIGN KEY (scheduled_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_inspection ugims_inspection_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id);


--
-- Name: ugims_inspection ugims_inspection_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_inspection
    ADD CONSTRAINT ugims_inspection_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_issue ugims_issue_assigned_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_assigned_by_user_id_fkey FOREIGN KEY (assigned_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_issue ugims_issue_assigned_to_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_assigned_to_team_id_fkey FOREIGN KEY (assigned_to_team_id) REFERENCES public.ugims_team(team_id);


--
-- Name: ugims_issue ugims_issue_assigned_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_assigned_to_user_id_fkey FOREIGN KEY (assigned_to_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_issue ugims_issue_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.lkp_issue_category(category_id);


--
-- Name: ugims_issue_comment ugims_issue_comment_commented_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue_comment
    ADD CONSTRAINT ugims_issue_comment_commented_by_user_id_fkey FOREIGN KEY (commented_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_issue_comment ugims_issue_comment_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue_comment
    ADD CONSTRAINT ugims_issue_comment_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES public.ugims_issue(issue_id) ON DELETE CASCADE;


--
-- Name: ugims_issue ugims_issue_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.ugims_ugi_component(component_id);


--
-- Name: ugims_issue ugims_issue_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_issue ugims_issue_priority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_priority_id_fkey FOREIGN KEY (priority_id) REFERENCES public.lkp_finding_priority(priority_id);


--
-- Name: ugims_issue ugims_issue_resolved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_resolved_by_user_id_fkey FOREIGN KEY (resolved_by_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_issue ugims_issue_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.lkp_issue_status(status_id);


--
-- Name: ugims_issue ugims_issue_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id);


--
-- Name: ugims_issue ugims_issue_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_issue ugims_issue_verified_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_issue
    ADD CONSTRAINT ugims_issue_verified_by_user_id_fkey FOREIGN KEY (verified_by_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_maintenance_zone ugims_maintenance_zone_subcity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_maintenance_zone
    ADD CONSTRAINT ugims_maintenance_zone_subcity_id_fkey FOREIGN KEY (subcity_id) REFERENCES public.lkq_subcity(subcity_id);


--
-- Name: ugims_maintenance_zone ugims_maintenance_zone_zone_manager_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_maintenance_zone
    ADD CONSTRAINT ugims_maintenance_zone_zone_manager_user_id_fkey FOREIGN KEY (zone_manager_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_management_plan ugims_management_plan_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_management_plan
    ADD CONSTRAINT ugims_management_plan_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_management_plan ugims_management_plan_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_management_plan
    ADD CONSTRAINT ugims_management_plan_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_management_plan ugims_management_plan_fiscal_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_management_plan
    ADD CONSTRAINT ugims_management_plan_fiscal_year_id_fkey FOREIGN KEY (fiscal_year_id) REFERENCES public.lkp_fiscal_year(fiscal_year_id);


--
-- Name: ugims_management_plan ugims_management_plan_plan_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_management_plan
    ADD CONSTRAINT ugims_management_plan_plan_type_id_fkey FOREIGN KEY (plan_type_id) REFERENCES public.lkp_plan_type(plan_type_id);


--
-- Name: ugims_management_plan ugims_management_plan_prepared_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_management_plan
    ADD CONSTRAINT ugims_management_plan_prepared_by_user_id_fkey FOREIGN KEY (prepared_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_management_plan ugims_management_plan_reviewed_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_management_plan
    ADD CONSTRAINT ugims_management_plan_reviewed_by_user_id_fkey FOREIGN KEY (reviewed_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_management_plan ugims_management_plan_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_management_plan
    ADD CONSTRAINT ugims_management_plan_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_management_plan ugims_management_plan_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_management_plan
    ADD CONSTRAINT ugims_management_plan_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.ugims_maintenance_zone(zone_id);


--
-- Name: ugims_monitoring_log ugims_monitoring_log_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_monitoring_log
    ADD CONSTRAINT ugims_monitoring_log_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_monitoring_log ugims_monitoring_log_monitor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_monitoring_log
    ADD CONSTRAINT ugims_monitoring_log_monitor_user_id_fkey FOREIGN KEY (monitor_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_monitoring_log ugims_monitoring_log_observed_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_monitoring_log
    ADD CONSTRAINT ugims_monitoring_log_observed_condition_id_fkey FOREIGN KEY (observed_condition_id) REFERENCES public.lkp_condition_status(status_id);


--
-- Name: ugims_monitoring_log ugims_monitoring_log_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_monitoring_log
    ADD CONSTRAINT ugims_monitoring_log_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id);


--
-- Name: ugims_parcel ugims_parcel_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.lkq_city(city_id);


--
-- Name: ugims_parcel_document ugims_parcel_document_document_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel_document
    ADD CONSTRAINT ugims_parcel_document_document_type_id_fkey FOREIGN KEY (document_type_id) REFERENCES public.lkp_parcel_document_type(doc_type_id);


--
-- Name: ugims_parcel_document ugims_parcel_document_parcel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel_document
    ADD CONSTRAINT ugims_parcel_document_parcel_id_fkey FOREIGN KEY (parcel_id) REFERENCES public.ugims_parcel(parcel_id) ON DELETE CASCADE;


--
-- Name: ugims_parcel_document ugims_parcel_document_uploaded_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel_document
    ADD CONSTRAINT ugims_parcel_document_uploaded_by_user_id_fkey FOREIGN KEY (uploaded_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_parcel_document ugims_parcel_document_verified_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel_document
    ADD CONSTRAINT ugims_parcel_document_verified_by_user_id_fkey FOREIGN KEY (verified_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_parcel_history ugims_parcel_history_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel_history
    ADD CONSTRAINT ugims_parcel_history_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_parcel_history ugims_parcel_history_changed_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel_history
    ADD CONSTRAINT ugims_parcel_history_changed_by_user_id_fkey FOREIGN KEY (changed_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_parcel_history ugims_parcel_history_parcel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel_history
    ADD CONSTRAINT ugims_parcel_history_parcel_id_fkey FOREIGN KEY (parcel_id) REFERENCES public.ugims_parcel(parcel_id);


--
-- Name: ugims_parcel ugims_parcel_kebele_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_kebele_id_fkey FOREIGN KEY (kebele_id) REFERENCES public.lkq_kebele(kebele_id);


--
-- Name: ugims_parcel ugims_parcel_land_use_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_land_use_type_id_fkey FOREIGN KEY (land_use_type_id) REFERENCES public.lkp_land_use_type(land_use_id);


--
-- Name: ugims_parcel ugims_parcel_maintenance_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_maintenance_zone_id_fkey FOREIGN KEY (maintenance_zone_id) REFERENCES public.ugims_maintenance_zone(zone_id);


--
-- Name: ugims_parcel ugims_parcel_ownership_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_ownership_type_id_fkey FOREIGN KEY (ownership_type_id) REFERENCES public.lkp_ownership_type(ownership_id);


--
-- Name: ugims_parcel ugims_parcel_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.lkq_region(region_id);


--
-- Name: ugims_parcel ugims_parcel_subcity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_subcity_id_fkey FOREIGN KEY (subcity_id) REFERENCES public.lkq_subcity(subcity_id);


--
-- Name: ugims_parcel ugims_parcel_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_parcel ugims_parcel_woreda_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_parcel
    ADD CONSTRAINT ugims_parcel_woreda_id_fkey FOREIGN KEY (woreda_id) REFERENCES public.lkq_woreda(woreda_id);


--
-- Name: ugims_plan_activity ugims_plan_activity_activity_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_plan_activity
    ADD CONSTRAINT ugims_plan_activity_activity_status_id_fkey FOREIGN KEY (activity_status_id) REFERENCES public.lkp_activity_status(status_id);


--
-- Name: ugims_plan_activity ugims_plan_activity_activity_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_plan_activity
    ADD CONSTRAINT ugims_plan_activity_activity_type_id_fkey FOREIGN KEY (activity_type_id) REFERENCES public.lkp_activity_type(activity_type_id);


--
-- Name: ugims_plan_activity ugims_plan_activity_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_plan_activity
    ADD CONSTRAINT ugims_plan_activity_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.ugims_ugi_component(component_id);


--
-- Name: ugims_plan_activity ugims_plan_activity_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_plan_activity
    ADD CONSTRAINT ugims_plan_activity_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_plan_activity ugims_plan_activity_depends_on_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_plan_activity
    ADD CONSTRAINT ugims_plan_activity_depends_on_activity_id_fkey FOREIGN KEY (depends_on_activity_id) REFERENCES public.ugims_plan_activity(plan_activity_id);


--
-- Name: ugims_plan_activity ugims_plan_activity_frequency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_plan_activity
    ADD CONSTRAINT ugims_plan_activity_frequency_id_fkey FOREIGN KEY (frequency_id) REFERENCES public.lkp_frequency(frequency_id);


--
-- Name: ugims_plan_activity ugims_plan_activity_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_plan_activity
    ADD CONSTRAINT ugims_plan_activity_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.ugims_management_plan(plan_id) ON DELETE CASCADE;


--
-- Name: ugims_plan_activity ugims_plan_activity_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_plan_activity
    ADD CONSTRAINT ugims_plan_activity_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id);


--
-- Name: ugims_plan_activity ugims_plan_activity_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_plan_activity
    ADD CONSTRAINT ugims_plan_activity_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_public_feedback ugims_public_feedback_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_public_feedback
    ADD CONSTRAINT ugims_public_feedback_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id);


--
-- Name: ugims_purchase_requisition ugims_purchase_requisition_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_purchase_requisition
    ADD CONSTRAINT ugims_purchase_requisition_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.ugims_plan_activity(plan_activity_id);


--
-- Name: ugims_purchase_requisition ugims_purchase_requisition_approved_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_purchase_requisition
    ADD CONSTRAINT ugims_purchase_requisition_approved_by_user_id_fkey FOREIGN KEY (approved_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_purchase_requisition ugims_purchase_requisition_budget_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_purchase_requisition
    ADD CONSTRAINT ugims_purchase_requisition_budget_id_fkey FOREIGN KEY (budget_id) REFERENCES public.ugims_budget(budget_id);


--
-- Name: ugims_purchase_requisition ugims_purchase_requisition_requested_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_purchase_requisition
    ADD CONSTRAINT ugims_purchase_requisition_requested_by_user_id_fkey FOREIGN KEY (requested_by_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_purchase_requisition ugims_purchase_requisition_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_purchase_requisition
    ADD CONSTRAINT ugims_purchase_requisition_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id);


--
-- Name: ugims_team ugims_team_assigned_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team
    ADD CONSTRAINT ugims_team_assigned_zone_id_fkey FOREIGN KEY (assigned_zone_id) REFERENCES public.ugims_maintenance_zone(zone_id);


--
-- Name: ugims_team ugims_team_assistant_lead_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team
    ADD CONSTRAINT ugims_team_assistant_lead_user_id_fkey FOREIGN KEY (assistant_lead_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_team ugims_team_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team
    ADD CONSTRAINT ugims_team_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_team_membership ugims_team_membership_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team_membership
    ADD CONSTRAINT ugims_team_membership_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_team_membership ugims_team_membership_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team_membership
    ADD CONSTRAINT ugims_team_membership_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.ugims_team(team_id) ON DELETE CASCADE;


--
-- Name: ugims_team_membership ugims_team_membership_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team_membership
    ADD CONSTRAINT ugims_team_membership_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.ugims_workforce_user(user_id) ON DELETE CASCADE;


--
-- Name: ugims_team ugims_team_team_lead_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team
    ADD CONSTRAINT ugims_team_team_lead_user_id_fkey FOREIGN KEY (team_lead_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_team ugims_team_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_team
    ADD CONSTRAINT ugims_team_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_ugi ugims_ugi_accessibility_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_accessibility_type_id_fkey FOREIGN KEY (accessibility_type_id) REFERENCES public.lkp_accessibility_type(access_id);


--
-- Name: ugims_ugi ugims_ugi_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.lkq_city(city_id);


--
-- Name: ugims_ugi_component ugims_ugi_component_component_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi_component
    ADD CONSTRAINT ugims_ugi_component_component_type_id_fkey FOREIGN KEY (component_type_id) REFERENCES public.lkp_component_type(component_type_id);


--
-- Name: ugims_ugi_component ugims_ugi_component_condition_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi_component
    ADD CONSTRAINT ugims_ugi_component_condition_status_id_fkey FOREIGN KEY (condition_status_id) REFERENCES public.lkp_condition_status(status_id);


--
-- Name: ugims_ugi_component ugims_ugi_component_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi_component
    ADD CONSTRAINT ugims_ugi_component_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_ugi_component ugims_ugi_component_operational_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi_component
    ADD CONSTRAINT ugims_ugi_component_operational_status_id_fkey FOREIGN KEY (operational_status_id) REFERENCES public.lkp_operational_status(status_id);


--
-- Name: ugims_ugi_component ugims_ugi_component_ugi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi_component
    ADD CONSTRAINT ugims_ugi_component_ugi_id_fkey FOREIGN KEY (ugi_id) REFERENCES public.ugims_ugi(ugi_id) ON DELETE CASCADE;


--
-- Name: ugims_ugi_component ugims_ugi_component_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi_component
    ADD CONSTRAINT ugims_ugi_component_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_ugi ugims_ugi_condition_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_condition_status_id_fkey FOREIGN KEY (condition_status_id) REFERENCES public.lkp_condition_status(status_id);


--
-- Name: ugims_ugi ugims_ugi_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_ugi ugims_ugi_kebele_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_kebele_id_fkey FOREIGN KEY (kebele_id) REFERENCES public.lkq_kebele(kebele_id);


--
-- Name: ugims_ugi ugims_ugi_maintenance_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_maintenance_zone_id_fkey FOREIGN KEY (maintenance_zone_id) REFERENCES public.ugims_maintenance_zone(zone_id);


--
-- Name: ugims_ugi ugims_ugi_operational_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_operational_status_id_fkey FOREIGN KEY (operational_status_id) REFERENCES public.lkp_operational_status(status_id);


--
-- Name: ugims_ugi ugims_ugi_parcel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_parcel_id_fkey FOREIGN KEY (parcel_id) REFERENCES public.ugims_parcel(parcel_id);


--
-- Name: ugims_ugi ugims_ugi_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.lkq_region(region_id);


--
-- Name: ugims_ugi ugims_ugi_subcity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_subcity_id_fkey FOREIGN KEY (subcity_id) REFERENCES public.lkq_subcity(subcity_id);


--
-- Name: ugims_ugi ugims_ugi_ugi_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_ugi_type_id_fkey FOREIGN KEY (ugi_type_id) REFERENCES public.lkp_ethiopia_ugi_type(ugi_type_id);


--
-- Name: ugims_ugi ugims_ugi_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_ugi ugims_ugi_woreda_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_ugi
    ADD CONSTRAINT ugims_ugi_woreda_id_fkey FOREIGN KEY (woreda_id) REFERENCES public.lkq_woreda(woreda_id);


--
-- Name: ugims_workforce_schedule ugims_workforce_schedule_assigned_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_schedule
    ADD CONSTRAINT ugims_workforce_schedule_assigned_zone_id_fkey FOREIGN KEY (assigned_zone_id) REFERENCES public.ugims_maintenance_zone(zone_id);


--
-- Name: ugims_workforce_schedule ugims_workforce_schedule_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_schedule
    ADD CONSTRAINT ugims_workforce_schedule_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_workforce_schedule ugims_workforce_schedule_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_schedule
    ADD CONSTRAINT ugims_workforce_schedule_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_workforce_user ugims_workforce_user_assigned_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_user
    ADD CONSTRAINT ugims_workforce_user_assigned_zone_id_fkey FOREIGN KEY (assigned_zone_id) REFERENCES public.ugims_maintenance_zone(zone_id);


--
-- Name: ugims_workforce_user ugims_workforce_user_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_user
    ADD CONSTRAINT ugims_workforce_user_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_workforce_user ugims_workforce_user_job_title_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_user
    ADD CONSTRAINT ugims_workforce_user_job_title_id_fkey FOREIGN KEY (job_title_id) REFERENCES public.lkp_job_title(job_title_id);


--
-- Name: ugims_workforce_user ugims_workforce_user_reports_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_user
    ADD CONSTRAINT ugims_workforce_user_reports_to_user_id_fkey FOREIGN KEY (reports_to_user_id) REFERENCES public.ugims_workforce_user(user_id);


--
-- Name: ugims_workforce_user ugims_workforce_user_updated_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_user
    ADD CONSTRAINT ugims_workforce_user_updated_by_user_id_fkey FOREIGN KEY (updated_by_user_id) REFERENCES public.auth_user(id);


--
-- Name: ugims_workforce_user ugims_workforce_user_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ugims_workforce_user
    ADD CONSTRAINT ugims_workforce_user_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.auth_user(id);


--
-- PostgreSQL database dump complete
--

