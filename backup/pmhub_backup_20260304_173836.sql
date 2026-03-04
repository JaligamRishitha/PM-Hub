--
-- PostgreSQL database dump
--

\restrict MHmxGUcJif2uabdADB0VQdSSWV9t94iYE0ceXxSuiDbYaSUiq7EOW6QkHPXc3KZ

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

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
-- Name: approved_variations; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.approved_variations (
    id integer NOT NULL,
    project_id integer NOT NULL,
    variation_code character varying(50) NOT NULL,
    description text NOT NULL,
    value numeric(15,2) NOT NULL,
    cost_impact numeric(15,2),
    schedule_impact_days integer,
    approval_status character varying(50),
    submitted_date date,
    approval_date date,
    approved_by character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.approved_variations OWNER TO pmhub;

--
-- Name: approved_variations_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.approved_variations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.approved_variations_id_seq OWNER TO pmhub;

--
-- Name: approved_variations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.approved_variations_id_seq OWNED BY public.approved_variations.id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    user_id integer,
    action character varying(50) NOT NULL,
    entity_type character varying(100) NOT NULL,
    entity_id integer,
    details text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.audit_logs OWNER TO pmhub;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_id_seq OWNER TO pmhub;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: cbs; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.cbs (
    id integer NOT NULL,
    project_id integer NOT NULL,
    wbs_code character varying(50) NOT NULL,
    description character varying(500) NOT NULL,
    budget_cost numeric(15,2),
    actual_cost numeric(15,2),
    forecast_cost numeric(15,2),
    approved_variation numeric(15,2),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.cbs OWNER TO pmhub;

--
-- Name: cbs_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.cbs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cbs_id_seq OWNER TO pmhub;

--
-- Name: cbs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.cbs_id_seq OWNED BY public.cbs.id;


--
-- Name: compensation_events; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.compensation_events (
    id integer NOT NULL,
    project_id integer NOT NULL,
    event_name character varying(255) NOT NULL,
    linked_wbs character varying(50),
    time_impact_days integer,
    daily_overhead_cost numeric(12,2),
    status character varying(50),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.compensation_events OWNER TO pmhub;

--
-- Name: compensation_events_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.compensation_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.compensation_events_id_seq OWNER TO pmhub;

--
-- Name: compensation_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.compensation_events_id_seq OWNED BY public.compensation_events.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.documents (
    id integer NOT NULL,
    project_id integer NOT NULL,
    doc_code character varying(100) NOT NULL,
    title character varying(255) NOT NULL,
    category character varying(100) NOT NULL,
    revision character varying(20),
    status character varying(50),
    file_path text,
    file_size integer,
    uploaded_by character varying(255),
    upload_date timestamp with time zone DEFAULT now(),
    description text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.documents OWNER TO pmhub;

--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.documents_id_seq OWNER TO pmhub;

--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: hse_checklist; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.hse_checklist (
    id integer NOT NULL,
    project_id integer NOT NULL,
    checklist_item character varying(500) NOT NULL,
    category character varying(100),
    status character varying(50),
    last_inspection_date date,
    inspector character varying(255),
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.hse_checklist OWNER TO pmhub;

--
-- Name: hse_checklist_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.hse_checklist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hse_checklist_id_seq OWNER TO pmhub;

--
-- Name: hse_checklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.hse_checklist_id_seq OWNED BY public.hse_checklist.id;


--
-- Name: issue_log; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.issue_log (
    id integer NOT NULL,
    project_id integer NOT NULL,
    issue_code character varying(50) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    priority character varying(50),
    assigned_to character varying(255),
    raised_by character varying(255),
    raised_date date DEFAULT CURRENT_DATE,
    due_date date,
    resolution_date date,
    resolution_notes text,
    status character varying(50),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.issue_log OWNER TO pmhub;

--
-- Name: issue_log_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.issue_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.issue_log_id_seq OWNER TO pmhub;

--
-- Name: issue_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.issue_log_id_seq OWNED BY public.issue_log.id;


--
-- Name: milestone_payments; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.milestone_payments (
    id integer NOT NULL,
    milestone_id integer NOT NULL,
    payment_percentage numeric(5,2) NOT NULL,
    payment_value numeric(15,2) NOT NULL,
    invoice_number character varying(100),
    invoice_date date,
    payment_status character varying(50),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.milestone_payments OWNER TO pmhub;

--
-- Name: milestone_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.milestone_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.milestone_payments_id_seq OWNER TO pmhub;

--
-- Name: milestone_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.milestone_payments_id_seq OWNED BY public.milestone_payments.id;


--
-- Name: milestones; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.milestones (
    id integer NOT NULL,
    project_id integer NOT NULL,
    name character varying(255) NOT NULL,
    phase character varying(50) NOT NULL,
    planned_date date NOT NULL,
    actual_date date,
    is_critical boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.milestones OWNER TO pmhub;

--
-- Name: milestones_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.milestones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.milestones_id_seq OWNER TO pmhub;

--
-- Name: milestones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.milestones_id_seq OWNED BY public.milestones.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(50) NOT NULL,
    description text,
    is_active boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.organizations OWNER TO pmhub;

--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organizations_id_seq OWNER TO pmhub;

--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: programmes; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.programmes (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(50) NOT NULL,
    description text,
    status character varying(50),
    start_date date,
    end_date date,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.programmes OWNER TO pmhub;

--
-- Name: programmes_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.programmes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.programmes_id_seq OWNER TO pmhub;

--
-- Name: programmes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.programmes_id_seq OWNED BY public.programmes.id;


--
-- Name: project_activities; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.project_activities (
    id integer NOT NULL,
    project_id integer NOT NULL,
    wbs_id integer,
    activity_code character varying(50),
    activity_name character varying(255) NOT NULL,
    phase character varying(50) NOT NULL,
    planned_start date NOT NULL,
    planned_finish date NOT NULL,
    actual_start date,
    actual_finish date,
    completion_pct numeric(5,2),
    is_milestone boolean,
    is_critical boolean,
    predecessor_ids text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.project_activities OWNER TO pmhub;

--
-- Name: project_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.project_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.project_activities_id_seq OWNER TO pmhub;

--
-- Name: project_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.project_activities_id_seq OWNED BY public.project_activities.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    programme_id integer,
    name character varying(255) NOT NULL,
    code character varying(50),
    client character varying(255) NOT NULL,
    description text,
    start_date date NOT NULL,
    end_date date NOT NULL,
    contract_completion_date date,
    actual_completion_date date,
    status character varying(50),
    total_budget numeric(15,2),
    contract_value numeric(15,2),
    forecast_cost numeric(15,2),
    daily_ld_rate numeric(12,2),
    ld_cap_pct numeric(5,2),
    location character varying(255),
    project_manager character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    phase character varying(50) DEFAULT 'Gate B'::character varying
);


ALTER TABLE public.projects OWNER TO pmhub;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.projects_id_seq OWNER TO pmhub;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: risk_register; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.risk_register (
    id integer NOT NULL,
    project_id integer NOT NULL,
    risk_code character varying(50) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    category character varying(100),
    probability integer NOT NULL,
    impact integer NOT NULL,
    mitigation_plan text,
    contingency_plan text,
    owner character varying(255),
    status character varying(50),
    identified_date date DEFAULT CURRENT_DATE,
    review_date date,
    cost_exposure numeric(15,2),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.risk_register OWNER TO pmhub;

--
-- Name: risk_register_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.risk_register_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.risk_register_id_seq OWNER TO pmhub;

--
-- Name: risk_register_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.risk_register_id_seq OWNED BY public.risk_register.id;


--
-- Name: safety_incidents; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.safety_incidents (
    id integer NOT NULL,
    project_id integer NOT NULL,
    incident_type character varying(255) NOT NULL,
    severity character varying(50) NOT NULL,
    reported_date date NOT NULL,
    resolved_date date,
    status character varying(50),
    penalty_cost numeric(12,2),
    description character varying(1000),
    lost_time_hours numeric(8,2),
    location character varying(255),
    reported_by character varying(255),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.safety_incidents OWNER TO pmhub;

--
-- Name: safety_incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.safety_incidents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.safety_incidents_id_seq OWNER TO pmhub;

--
-- Name: safety_incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.safety_incidents_id_seq OWNED BY public.safety_incidents.id;


--
-- Name: simulation_scenarios; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.simulation_scenarios (
    id integer NOT NULL,
    simulation_session_id integer NOT NULL,
    type character varying(50) NOT NULL,
    input_parameters text NOT NULL,
    output_results text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.simulation_scenarios OWNER TO pmhub;

--
-- Name: simulation_scenarios_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.simulation_scenarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.simulation_scenarios_id_seq OWNER TO pmhub;

--
-- Name: simulation_scenarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.simulation_scenarios_id_seq OWNED BY public.simulation_scenarios.id;


--
-- Name: simulation_sessions; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.simulation_sessions (
    id integer NOT NULL,
    project_id integer NOT NULL,
    created_by integer NOT NULL,
    name character varying(255) NOT NULL,
    status character varying(50),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.simulation_sessions OWNER TO pmhub;

--
-- Name: simulation_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.simulation_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.simulation_sessions_id_seq OWNER TO pmhub;

--
-- Name: simulation_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.simulation_sessions_id_seq OWNED BY public.simulation_sessions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    role character varying(50) NOT NULL,
    is_active boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO pmhub;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO pmhub;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: wbs_items; Type: TABLE; Schema: public; Owner: pmhub
--

CREATE TABLE public.wbs_items (
    id integer NOT NULL,
    project_id integer NOT NULL,
    parent_id integer,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    level integer,
    sort_order integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.wbs_items OWNER TO pmhub;

--
-- Name: wbs_items_id_seq; Type: SEQUENCE; Schema: public; Owner: pmhub
--

CREATE SEQUENCE public.wbs_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wbs_items_id_seq OWNER TO pmhub;

--
-- Name: wbs_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pmhub
--

ALTER SEQUENCE public.wbs_items_id_seq OWNED BY public.wbs_items.id;


--
-- Name: approved_variations id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.approved_variations ALTER COLUMN id SET DEFAULT nextval('public.approved_variations_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: cbs id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.cbs ALTER COLUMN id SET DEFAULT nextval('public.cbs_id_seq'::regclass);


--
-- Name: compensation_events id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.compensation_events ALTER COLUMN id SET DEFAULT nextval('public.compensation_events_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: hse_checklist id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.hse_checklist ALTER COLUMN id SET DEFAULT nextval('public.hse_checklist_id_seq'::regclass);


--
-- Name: issue_log id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.issue_log ALTER COLUMN id SET DEFAULT nextval('public.issue_log_id_seq'::regclass);


--
-- Name: milestone_payments id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.milestone_payments ALTER COLUMN id SET DEFAULT nextval('public.milestone_payments_id_seq'::regclass);


--
-- Name: milestones id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.milestones ALTER COLUMN id SET DEFAULT nextval('public.milestones_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: programmes id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.programmes ALTER COLUMN id SET DEFAULT nextval('public.programmes_id_seq'::regclass);


--
-- Name: project_activities id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.project_activities ALTER COLUMN id SET DEFAULT nextval('public.project_activities_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: risk_register id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.risk_register ALTER COLUMN id SET DEFAULT nextval('public.risk_register_id_seq'::regclass);


--
-- Name: safety_incidents id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.safety_incidents ALTER COLUMN id SET DEFAULT nextval('public.safety_incidents_id_seq'::regclass);


--
-- Name: simulation_scenarios id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.simulation_scenarios ALTER COLUMN id SET DEFAULT nextval('public.simulation_scenarios_id_seq'::regclass);


--
-- Name: simulation_sessions id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.simulation_sessions ALTER COLUMN id SET DEFAULT nextval('public.simulation_sessions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: wbs_items id; Type: DEFAULT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.wbs_items ALTER COLUMN id SET DEFAULT nextval('public.wbs_items_id_seq'::regclass);


--
-- Data for Name: approved_variations; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.approved_variations (id, project_id, variation_code, description, value, cost_impact, schedule_impact_days, approval_status, submitted_date, approval_date, approved_by, created_at, updated_at) VALUES (1, 1, 'VO-001', 'Additional 30 custom reports requested by finance team', 280000.00, 280000.00, 20, 'Approved', '2025-12-29', '2026-01-13', 'Client CIO', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.approved_variations (id, project_id, variation_code, description, value, cost_impact, schedule_impact_days, approval_status, submitted_date, approval_date, approved_by, created_at, updated_at) VALUES (2, 1, 'VO-002', 'SAP Fiori UX enhancements for mobile access', 150000.00, 150000.00, 10, 'Pending', '2026-02-12', NULL, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.approved_variations (id, project_id, variation_code, description, value, cost_impact, schedule_impact_days, approval_status, submitted_date, approval_date, approved_by, created_at, updated_at) VALUES (3, 3, 'VO-001', '10 additional legacy apps added to migration scope', 450000.00, 450000.00, 25, 'Approved', '2025-12-09', '2025-12-29', 'Cloud Director', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.approved_variations (id, project_id, variation_code, description, value, cost_impact, schedule_impact_days, approval_status, submitted_date, approval_date, approved_by, created_at, updated_at) VALUES (4, 3, 'VO-002', 'Multi-region DR setup for critical apps', 320000.00, 320000.00, 15, 'Under Review', '2026-02-07', NULL, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.approved_variations (id, project_id, variation_code, description, value, cost_impact, schedule_impact_days, approval_status, submitted_date, approval_date, approved_by, created_at, updated_at) VALUES (5, 6, 'VO-001', 'Apple Watch companion app addition', 200000.00, 200000.00, 18, 'Approved', '2026-01-08', '2026-01-23', 'Product Owner', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.approved_variations (id, project_id, variation_code, description, value, cost_impact, schedule_impact_days, approval_status, submitted_date, approval_date, approved_by, created_at, updated_at) VALUES (6, 7, 'VO-001', 'Crypto payment support added to scope', 380000.00, 380000.00, 30, 'Pending', '2026-02-17', NULL, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.approved_variations (id, project_id, variation_code, description, value, cost_impact, schedule_impact_days, approval_status, submitted_date, approval_date, approved_by, created_at, updated_at) VALUES (7, 8, 'VO-001', 'Additional 15 Tableau dashboards for marketing', 120000.00, 120000.00, 12, 'Approved', '2026-01-18', '2026-01-30', 'CMO', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.audit_logs (id, user_id, action, entity_type, entity_id, details, created_at) VALUES (1, 1, 'UPDATE', 'Activity', 3, 'Data Cleansing & Extraction', '2026-03-04 08:09:26.058859+00');


--
-- Data for Name: cbs; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (1, 1, '1.0', 'Project Management & PMO', 420000.00, 380000.00, 440000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (2, 1, '2.0', 'Requirements & Design', 630000.00, 610000.00, 650000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (3, 1, '3.0', 'Data Migration', 840000.00, 620000.00, 900000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (4, 1, '4.0', 'Development & Config', 1260000.00, 700000.00, 1350000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (5, 1, '5.0', 'Testing & QA', 630000.00, 50000.00, 680000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (6, 1, '6.0', 'Training & Go-Live', 420000.00, 0.00, 480000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (7, 3, '1.0', 'Discovery & Assessment', 380000.00, 350000.00, 380000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (8, 3, '2.0', 'Landing Zone & Networking', 570000.00, 560000.00, 590000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (9, 3, '3.0', 'Application Migration', 2280000.00, 1800000.00, 2500000.00, 200000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (10, 3, '4.0', 'Optimization & Handover', 570000.00, 100000.00, 630000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (11, 6, '1.0', 'UX Research & Design', 350000.00, 340000.00, 360000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (12, 6, '2.0', 'Core Banking API', 1050000.00, 980000.00, 1080000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (13, 6, '3.0', 'Mobile Development', 1400000.00, 1100000.00, 1500000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (14, 6, '4.0', 'Security & Compliance', 350000.00, 120000.00, 380000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (15, 6, '5.0', 'UAT & Launch', 350000.00, 0.00, 380000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (16, 7, '1.0', 'Architecture & PCI Planning', 390000.00, 370000.00, 400000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (17, 7, '2.0', 'Engine Development', 1300000.00, 550000.00, 1400000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (18, 7, '3.0', 'Testing & Certification', 910000.00, 0.00, 950000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (19, 8, '1.0', 'Data Modelling', 330000.00, 310000.00, 340000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (20, 8, '2.0', 'Snowflake & dbt', 770000.00, 720000.00, 800000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (21, 8, '3.0', 'Tableau Dashboards', 550000.00, 200000.00, 600000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.cbs (id, project_id, wbs_code, description, budget_cost, actual_cost, forecast_cost, approved_variation, created_at, updated_at) VALUES (22, 8, '4.0', 'Kafka Streaming', 550000.00, 150000.00, 610000.00, 0.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: compensation_events; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.compensation_events (id, project_id, event_name, linked_wbs, time_impact_days, daily_overhead_cost, status, created_at, updated_at) VALUES (1, 1, 'SAP license delivery delay (vendor issue)', '4.0', 12, 4000.00, 'Approved', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.compensation_events (id, project_id, event_name, linked_wbs, time_impact_days, daily_overhead_cost, status, created_at, updated_at) VALUES (2, 1, 'Client data freeze delayed by 3 weeks', '3.0', 21, 4000.00, 'Pending', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.compensation_events (id, project_id, event_name, linked_wbs, time_impact_days, daily_overhead_cost, status, created_at, updated_at) VALUES (3, 3, 'AWS region outage during Wave 2 migration', '3.0', 5, 6000.00, 'Approved', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.compensation_events (id, project_id, event_name, linked_wbs, time_impact_days, daily_overhead_cost, status, created_at, updated_at) VALUES (4, 3, 'Legacy app undocumented dependencies discovered', '3.0', 18, 6000.00, 'Pending', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.compensation_events (id, project_id, event_name, linked_wbs, time_impact_days, daily_overhead_cost, status, created_at, updated_at) VALUES (5, 6, 'Open banking API spec change by regulator', '2.0', 14, 5000.00, 'Approved', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (1, 1, 'SDD-ERP-001', 'S/4HANA Solution Design Document', 'Specification', 'C', 'Approved', NULL, NULL, 'Solution Architect', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (2, 1, 'DMP-ERP-001', 'Data Migration Plan', 'Report', 'B', 'Approved', NULL, NULL, 'Data Architect', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (3, 1, 'TP-ERP-001', 'Integration Test Plan', 'Report', 'A', 'Under Review', NULL, NULL, 'QA Lead', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (4, 3, 'ARC-AWS-001', 'AWS Target Architecture', 'Drawing', 'D', 'Approved', NULL, NULL, 'Cloud Architect', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (5, 3, 'RUN-AWS-001', 'Cloud Runbook & Playbooks', 'Method Statement', 'B', 'Under Review', NULL, NULL, 'DevOps Lead', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (6, 4, 'RA-ZT-001', 'Zero Trust Risk Assessment', 'Risk Assessment', 'A', 'Approved', NULL, NULL, 'Security Architect', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (7, 4, 'HLD-ZT-001', 'Network Segmentation Design', 'Drawing', 'B', 'Approved', NULL, NULL, 'Network Architect', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (8, 6, 'PRD-MB-001', 'Mobile App PRD', 'Specification', 'E', 'Approved', NULL, NULL, 'Product Owner', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (9, 6, 'SEC-MB-001', 'Penetration Test Report', 'Report', 'A', 'Draft', NULL, NULL, 'Security Consultant', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (10, 7, 'PCI-PG-001', 'PCI-DSS Compliance Matrix', 'Contract', 'A', 'Under Review', NULL, NULL, 'Compliance Lead', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (11, 8, 'DM-DW-001', 'Snowflake Data Model ERD', 'Drawing', 'C', 'Approved', NULL, NULL, 'Data Engineer', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (12, 9, 'MLD-FD-001', 'ML Model Design Document', 'Specification', 'A', 'Approved', NULL, NULL, 'ML Engineer', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (13, 10, 'STD-DO-001', 'CI/CD Standards & Guidelines', 'Specification', 'B', 'Approved', NULL, NULL, 'DevOps Lead', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.documents (id, project_id, doc_code, title, category, revision, status, file_path, file_size, uploaded_by, upload_date, description, created_at, updated_at) VALUES (14, 10, 'COR-DO-001', 'Team Onboarding Correspondence', 'Correspondence', 'A', 'Approved', NULL, NULL, 'Alex Johnson', '2026-02-27 11:34:51.918979+00', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: hse_checklist; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (1, 1, 'DSE assessment completed for all team members', 'Ergonomics', 'Completed', '2026-02-17', 'Mike Chen', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (2, 1, 'Data centre access control list reviewed', 'Physical Security', 'Completed', '2026-02-22', 'Security Lead', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (3, 3, 'Fire suppression system tested in server room', 'Fire Safety', 'Completed', '2026-02-12', 'Facilities Manager', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (4, 3, 'Cable management audit in data centre', 'Electrical Safety', 'In Progress', '2026-02-24', 'DC Technician', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (5, 3, 'UPS battery replacement schedule current', 'Electrical Safety', 'Failed', '2026-02-17', 'DC Operator', '3 UPS units past replacement date - ordered replacements', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (6, 4, 'Lone worker policy for hospital site visits', 'Lone Working', 'Completed', '2026-02-19', 'Mike Chen', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (7, 4, 'DBS checks for hospital site access', 'Personnel', 'Completed', '2026-02-07', 'HR', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (8, 5, 'Ergonomic workstation setup for dev team', 'Ergonomics', 'Completed', '2026-02-23', 'Facilities', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (9, 6, 'Secure disposal of test devices with bank data', 'Data Security', 'Pending', NULL, NULL, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (10, 7, 'PCI-DSS physical security controls verified', 'Physical Security', 'Completed', '2026-02-20', 'QSA Auditor', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (11, 8, 'E-waste disposal procedure in place', 'Environmental', 'Pending', NULL, NULL, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.hse_checklist (id, project_id, checklist_item, category, status, last_inspection_date, inspector, notes, created_at, updated_at) VALUES (12, 9, 'GPU server room cooling adequate', 'Environmental', 'Completed', '2026-02-21', 'DC Manager', NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: issue_log; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.issue_log (id, project_id, issue_code, title, description, priority, assigned_to, raised_by, raised_date, due_date, resolution_date, resolution_notes, status, created_at, updated_at) VALUES (1, 1, 'ISS-001', 'SAP transport conflicts between dev and QA', 'Multiple developers overwriting each other''s transports', 'High', 'Tech Lead', 'Dev Team', '2026-02-15', '2026-02-25', NULL, NULL, 'Open', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.issue_log (id, project_id, issue_code, title, description, priority, assigned_to, raised_by, raised_date, due_date, resolution_date, resolution_notes, status, created_at, updated_at) VALUES (2, 1, 'ISS-002', 'Legacy data mapping incomplete for GL accounts', '30% of GL accounts have no mapping to S/4HANA chart of accounts', 'Critical', 'Data Architect', 'Finance BA', '2026-02-22', '2026-03-04', NULL, NULL, 'In Progress', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.issue_log (id, project_id, issue_code, title, description, priority, assigned_to, raised_by, raised_date, due_date, resolution_date, resolution_notes, status, created_at, updated_at) VALUES (3, 3, 'ISS-001', 'VPN throughput bottleneck during migration', 'Site-to-site VPN maxing out at 500Mbps during bulk data transfer', 'High', 'Network Engineer', 'Migration Lead', '2026-02-19', '2026-03-02', NULL, NULL, 'Open', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.issue_log (id, project_id, issue_code, title, description, priority, assigned_to, raised_by, raised_date, due_date, resolution_date, resolution_notes, status, created_at, updated_at) VALUES (4, 3, 'ISS-002', 'Oracle DB license non-transferable to cloud', 'Oracle licensing prohibits running on AWS EC2 without re-licensing', 'Critical', 'Procurement', 'Cloud Architect', '2026-02-07', '2026-02-17', NULL, NULL, 'In Progress', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.issue_log (id, project_id, issue_code, title, description, priority, assigned_to, raised_by, raised_date, due_date, resolution_date, resolution_notes, status, created_at, updated_at) VALUES (5, 4, 'ISS-001', 'Legacy RADIUS server incompatible with Azure AD', '3 hospital sites use RADIUS auth that doesn''t support SAML federation', 'Medium', 'Identity Engineer', 'Site IT Manager', '2026-02-12', '2026-03-09', NULL, NULL, 'Open', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.issue_log (id, project_id, issue_code, title, description, priority, assigned_to, raised_by, raised_date, due_date, resolution_date, resolution_notes, status, created_at, updated_at) VALUES (6, 6, 'ISS-001', 'Push notification delivery rate below 90%', 'Firebase FCM delivery unreliable on Huawei devices (no GMS)', 'Medium', 'Mobile Dev Lead', 'QA Team', '2026-02-20', '2026-03-13', NULL, NULL, 'Open', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.issue_log (id, project_id, issue_code, title, description, priority, assigned_to, raised_by, raised_date, due_date, resolution_date, resolution_notes, status, created_at, updated_at) VALUES (7, 6, 'ISS-002', 'Open banking API rate limiting', 'Bank API returns 429 errors during peak testing at 100 req/s', 'High', 'API Engineer', 'Performance Tester', '2026-02-24', '2026-03-06', NULL, NULL, 'In Progress', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.issue_log (id, project_id, issue_code, title, description, priority, assigned_to, raised_by, raised_date, due_date, resolution_date, resolution_notes, status, created_at, updated_at) VALUES (8, 7, 'ISS-001', 'Card scheme certification delay', 'Visa certification slot pushed back by 4 weeks', 'High', 'Compliance Lead', 'PM', '2026-02-22', '2026-03-29', NULL, NULL, 'Open', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.issue_log (id, project_id, issue_code, title, description, priority, assigned_to, raised_by, raised_date, due_date, resolution_date, resolution_notes, status, created_at, updated_at) VALUES (9, 8, 'ISS-001', 'dbt model run time exceeding 4-hour SLA', 'Full refresh taking 6+ hours due to complex joins on fact tables', 'High', 'Data Engineer', 'BI Analyst', '2026-02-21', '2026-03-04', NULL, NULL, 'In Progress', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.issue_log (id, project_id, issue_code, title, description, priority, assigned_to, raised_by, raised_date, due_date, resolution_date, resolution_notes, status, created_at, updated_at) VALUES (10, 9, 'ISS-001', 'GPU cluster provisioning delayed', 'Azure GPU quota request pending approval for 2+ weeks', 'Critical', 'Cloud Ops', 'ML Engineer', '2026-02-13', '2026-02-23', NULL, NULL, 'Open', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: milestone_payments; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.milestone_payments (id, milestone_id, payment_percentage, payment_value, invoice_number, invoice_date, payment_status, created_at, updated_at) VALUES (1, 1, 10.00, 480000.00, 'INV-ERP-001', '2025-11-29', 'Received', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestone_payments (id, milestone_id, payment_percentage, payment_value, invoice_number, invoice_date, payment_status, created_at, updated_at) VALUES (2, 2, 20.00, 960000.00, NULL, NULL, 'Pending', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestone_payments (id, milestone_id, payment_percentage, payment_value, invoice_number, invoice_date, payment_status, created_at, updated_at) VALUES (3, 7, 10.00, 420000.00, 'INV-AWS-001', '2025-10-05', 'Received', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestone_payments (id, milestone_id, payment_percentage, payment_value, invoice_number, invoice_date, payment_status, created_at, updated_at) VALUES (4, 8, 25.00, 1050000.00, 'INV-AWS-002', '2025-12-24', 'Received', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestone_payments (id, milestone_id, payment_percentage, payment_value, invoice_number, invoice_date, payment_status, created_at, updated_at) VALUES (5, 9, 30.00, 1260000.00, NULL, NULL, 'Pending', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestone_payments (id, milestone_id, payment_percentage, payment_value, invoice_number, invoice_date, payment_status, created_at, updated_at) VALUES (6, 14, 15.00, 600000.00, NULL, NULL, 'Pending', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestone_payments (id, milestone_id, payment_percentage, payment_value, invoice_number, invoice_date, payment_status, created_at, updated_at) VALUES (7, 19, 100.00, 1100000.00, 'INV-DO-001', '2026-02-26', 'Received', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: milestones; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (1, 1, 'Design Sign-Off', 'Design', '2025-11-19', '2025-11-24', true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (2, 1, 'Data Migration Complete', 'Construction', '2026-02-17', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (3, 1, 'UAT Sign-Off', 'Commissioning', '2026-08-26', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (4, 1, 'Go-Live', 'Commissioning', '2027-01-23', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (5, 2, 'MVP Launch', 'Construction', '2026-02-17', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (6, 2, 'Full Rollout', 'Commissioning', '2026-08-06', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (7, 3, 'Landing Zone Ready', 'Design', '2025-09-20', '2025-09-30', true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (8, 3, 'Wave 1 Complete', 'Construction', '2025-12-09', '2025-12-19', false, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (9, 3, 'All Apps Migrated', 'Commissioning', '2026-04-28', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (10, 3, 'On-Prem Decommissioned', 'Commissioning', '2026-06-07', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (11, 4, 'MFA Rollout Complete', 'Construction', '2026-02-07', '2026-02-09', true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (12, 4, 'Full Zero Trust Live', 'Commissioning', '2026-11-04', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (13, 5, 'Platform GA', 'Construction', '2026-03-09', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (14, 6, 'Beta Release', 'Construction', '2026-02-07', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (15, 6, 'App Store Launch', 'Commissioning', '2026-05-18', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (16, 7, 'PCI-DSS Certification', 'Commissioning', '2026-06-07', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (17, 8, 'Dashboard Go-Live', 'Construction', '2026-03-29', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (18, 9, 'Model Accuracy Validated', 'Construction', '2026-04-28', NULL, true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.milestones (id, project_id, name, phase, planned_date, actual_date, is_critical, created_at, updated_at) VALUES (19, 10, 'All Teams Onboarded', 'Commissioning', '2026-03-19', '2026-02-25', true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.organizations (id, name, code, description, is_active, created_at, updated_at) VALUES (1, 'Global IT Solutions Group', 'GITSG', 'Enterprise IT and digital transformation portfolio', true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.organizations (id, name, code, description, is_active, created_at, updated_at) VALUES (2, 'FinTech Innovations Ltd', 'FIL', 'Financial technology products and platforms', true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: programmes; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.programmes (id, organization_id, name, code, description, status, start_date, end_date, created_at, updated_at) VALUES (1, 1, 'Enterprise Modernization Programme', 'EMP', NULL, 'Active', '2025-02-27', '2028-02-27', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.programmes (id, organization_id, name, code, description, status, start_date, end_date, created_at, updated_at) VALUES (2, 1, 'Cloud & Infrastructure Programme', 'CIP', NULL, 'Active', '2025-08-11', '2027-10-20', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.programmes (id, organization_id, name, code, description, status, start_date, end_date, created_at, updated_at) VALUES (3, 2, 'Digital Banking Platform Programme', 'DBP', NULL, 'Active', '2025-09-30', '2027-07-12', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: project_activities; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (1, 1, NULL, 'ERP-001', 'Business Process Mapping', 'Design', '2025-08-31', '2025-10-10', '2025-08-31', '2025-10-12', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (2, 1, NULL, 'ERP-002', 'Gap Analysis & Fit Study', 'Design', '2025-10-10', '2025-11-19', '2025-10-12', '2025-11-24', 100.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (3, 1, NULL, 'ERP-003', 'Data Cleansing & Extraction', 'Construction', '2025-11-19', '2026-01-18', '2025-11-24', NULL, 80.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (4, 1, NULL, 'ERP-004', 'S/4HANA Configuration', 'Construction', '2025-12-09', '2026-02-17', '2025-12-14', NULL, 70.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (5, 1, NULL, 'ERP-005', 'Custom Report Development', 'Construction', '2026-01-18', '2026-04-28', '2026-01-23', NULL, 30.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (6, 1, NULL, 'ERP-006', 'Integration Testing', 'Commissioning', '2026-04-28', '2026-06-27', NULL, NULL, 0.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (7, 1, NULL, 'ERP-007', 'User Acceptance Testing', 'Commissioning', '2026-06-27', '2026-08-26', NULL, NULL, 0.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (8, 1, NULL, 'ERP-008', 'Go-Live & Hypercare', 'Commissioning', '2026-08-26', '2026-10-25', NULL, NULL, 0.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (9, 2, NULL, 'HR-001', 'UI/UX Wireframing', 'Design', '2025-10-30', '2025-11-29', '2025-10-30', '2025-12-01', 100.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (10, 2, NULL, 'HR-002', 'Backend API Development', 'Construction', '2025-11-29', '2026-01-28', '2025-12-01', '2026-02-02', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (11, 2, NULL, 'HR-003', 'React Frontend Build', 'Construction', '2025-12-19', '2026-02-17', '2025-12-21', NULL, 85.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (12, 2, NULL, 'HR-004', 'Payroll Integration', 'Construction', '2026-01-28', '2026-03-29', '2026-02-02', NULL, 45.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (13, 3, NULL, 'AWS-001', 'Application Portfolio Assessment', 'Design', '2025-07-02', '2025-08-11', '2025-07-02', '2025-08-16', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (14, 3, NULL, 'AWS-002', 'AWS Landing Zone & VPC Setup', 'Design', '2025-08-11', '2025-09-20', '2025-08-16', '2025-09-30', 100.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (15, 3, NULL, 'AWS-003', 'Wave 1 Migration (30 apps)', 'Construction', '2025-09-20', '2025-12-09', '2025-09-30', '2025-12-19', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (16, 3, NULL, 'AWS-004', 'Wave 2 Migration (35 apps)', 'Construction', '2025-12-09', '2026-02-17', '2025-12-19', NULL, 75.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (17, 3, NULL, 'AWS-005', 'Wave 3 Migration (20 apps)', 'Construction', '2026-02-17', '2026-04-28', '2026-02-22', NULL, 10.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (18, 3, NULL, 'AWS-006', 'Decommission On-Prem Servers', 'Commissioning', '2026-04-28', '2026-06-27', NULL, NULL, 0.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (19, 4, NULL, 'ZT-001', 'Network Topology Assessment', 'Design', '2025-11-29', '2025-12-29', '2025-11-29', '2025-12-31', 100.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (20, 4, NULL, 'ZT-002', 'Identity Provider Setup (Azure AD)', 'Construction', '2025-12-29', '2026-02-07', '2025-12-31', '2026-02-09', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (21, 4, NULL, 'ZT-003', 'Micro-Segmentation Rollout', 'Construction', '2026-02-07', '2026-05-28', '2026-02-09', NULL, 25.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (22, 4, NULL, 'ZT-004', 'SIEM & SOC Integration', 'Commissioning', '2026-05-28', '2026-09-15', NULL, NULL, 0.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (23, 5, NULL, 'K8S-001', 'AKS Cluster Provisioning', 'Design', '2025-09-30', '2025-10-30', '2025-09-30', '2025-11-01', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (24, 5, NULL, 'K8S-002', 'Istio Service Mesh Setup', 'Construction', '2025-10-30', '2025-12-09', '2025-11-01', '2025-12-14', 100.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (25, 5, NULL, 'K8S-003', 'GitOps with ArgoCD', 'Construction', '2025-12-09', '2026-01-18', '2025-12-14', '2026-01-23', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (26, 5, NULL, 'K8S-004', 'Observability Stack (Prometheus/Grafana)', 'Construction', '2026-01-18', '2026-03-09', '2026-01-23', NULL, 75.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (27, 5, NULL, 'K8S-005', 'Workload Onboarding (15 services)', 'Commissioning', '2026-03-09', '2026-05-28', NULL, NULL, 0.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (28, 6, NULL, 'MB-001', 'User Research & Prototyping', 'Design', '2025-08-11', '2025-09-20', '2025-08-11', '2025-09-25', 100.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (29, 6, NULL, 'MB-002', 'Core Banking API Layer', 'Construction', '2025-09-20', '2025-12-09', '2025-09-25', '2025-12-17', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (30, 6, NULL, 'MB-003', 'iOS & Android Development', 'Construction', '2025-10-30', '2026-02-07', '2025-11-04', NULL, 90.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (31, 6, NULL, 'MB-004', 'PEN Testing & Security Audit', 'Commissioning', '2026-02-07', '2026-03-29', '2026-02-12', NULL, 40.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (32, 6, NULL, 'MB-005', 'App Store Submission & Launch', 'Commissioning', '2026-03-29', '2026-05-18', NULL, NULL, 0.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (33, 7, NULL, 'PG-001', 'Architecture & PCI-DSS Planning', 'Design', '2025-11-19', '2025-12-29', '2025-11-19', '2025-12-31', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (34, 7, NULL, 'PG-002', 'Transaction Engine Development', 'Construction', '2025-12-29', '2026-04-08', '2025-12-31', NULL, 55.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (35, 7, NULL, 'PG-003', 'Load Testing (10K TPS target)', 'Commissioning', '2026-04-08', '2026-06-07', NULL, NULL, 0.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (36, 8, NULL, 'DW-001', 'Data Model Design', 'Design', '2025-09-20', '2025-10-30', '2025-09-20', '2025-11-01', 100.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (37, 8, NULL, 'DW-002', 'Snowflake Setup & dbt Pipelines', 'Construction', '2025-10-30', '2026-01-08', '2025-11-01', '2026-01-13', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (38, 8, NULL, 'DW-003', 'Tableau Dashboard Development', 'Construction', '2026-01-08', '2026-03-29', '2026-01-13', NULL, 60.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (39, 8, NULL, 'DW-004', 'Kafka Real-Time Streaming', 'Construction', '2026-01-28', '2026-04-28', '2026-02-02', NULL, 35.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (40, 9, NULL, 'FD-001', 'Data Collection & Feature Engineering', 'Design', '2025-12-29', '2026-02-07', '2025-12-29', '2026-02-09', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (41, 9, NULL, 'FD-002', 'ML Model Training & Validation', 'Construction', '2026-02-07', '2026-04-28', '2026-02-09', NULL, 30.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (42, 9, NULL, 'FD-003', 'Real-Time Inference Pipeline', 'Construction', '2026-04-28', '2026-07-27', NULL, NULL, 0.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (43, 10, NULL, 'DO-001', 'GitHub Actions Pipeline Templates', 'Design', '2025-11-09', '2025-12-09', '2025-11-09', '2025-12-11', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (44, 10, NULL, 'DO-002', 'Terraform Module Library', 'Construction', '2025-12-09', '2026-01-18', '2025-12-11', '2026-01-20', 100.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (45, 10, NULL, 'DO-003', 'ArgoCD Deployment & Vault Setup', 'Construction', '2026-01-18', '2026-02-17', '2026-01-20', '2026-02-19', 100.00, false, true, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.project_activities (id, project_id, wbs_id, activity_code, activity_name, phase, planned_start, planned_finish, actual_start, actual_finish, completion_pct, is_milestone, is_critical, predecessor_ids, created_at, updated_at) VALUES (46, 10, NULL, 'DO-004', 'Team Onboarding & Documentation', 'Commissioning', '2026-02-17', '2026-03-19', '2026-02-19', '2026-02-25', 100.00, false, false, NULL, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.projects (id, programme_id, name, code, client, description, start_date, end_date, contract_completion_date, actual_completion_date, status, total_budget, contract_value, forecast_cost, daily_ld_rate, ld_cap_pct, location, project_manager, created_at, updated_at, phase) VALUES (1, 1, 'ERP System Migration', 'EMP-001', 'Acme Corporation', 'Migration from legacy SAP R/3 to SAP S/4HANA with full data migration and 120 custom reports', '2025-08-31', '2027-02-22', '2027-01-23', NULL, 'Active', 4200000.00, 4800000.00, 4500000.00, 5000.00, 10.00, 'London, UK', 'Alex Johnson', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00', 'Construction');
INSERT INTO public.projects (id, programme_id, name, code, client, description, start_date, end_date, contract_completion_date, actual_completion_date, status, total_budget, contract_value, forecast_cost, daily_ld_rate, ld_cap_pct, location, project_manager, created_at, updated_at, phase) VALUES (2, 1, 'HR Portal & Employee Self-Service', 'EMP-002', 'Acme Corporation', 'React-based HR portal with payroll integration, leave management, and performance review modules', '2025-10-30', '2026-08-26', '2026-08-06', NULL, 'Active', 1200000.00, 1400000.00, 1300000.00, 2000.00, 10.00, 'London, UK', 'Sarah Williams', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00', 'Design Completion');
INSERT INTO public.projects (id, programme_id, name, code, client, description, start_date, end_date, contract_completion_date, actual_completion_date, status, total_budget, contract_value, forecast_cost, daily_ld_rate, ld_cap_pct, location, project_manager, created_at, updated_at, phase) VALUES (3, 2, 'AWS Cloud Migration', 'CIP-001', 'Barclays Group', 'Migrate 85 on-premise applications to AWS including re-platforming, re-hosting, and containerization', '2025-07-02', '2026-06-27', '2026-06-07', NULL, 'At Risk', 3800000.00, 4200000.00, 4100000.00, 4000.00, 8.00, 'Manchester, UK', 'Alex Johnson', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00', 'Construction');
INSERT INTO public.projects (id, programme_id, name, code, client, description, start_date, end_date, contract_completion_date, actual_completion_date, status, total_budget, contract_value, forecast_cost, daily_ld_rate, ld_cap_pct, location, project_manager, created_at, updated_at, phase) VALUES (4, 2, 'Zero Trust Network Security', 'CIP-002', 'NHS Digital', 'Implement zero-trust architecture across 40 hospital sites with MFA, micro-segmentation, and SIEM integration', '2025-11-29', '2026-11-24', '2026-11-04', NULL, 'Active', 2800000.00, 3200000.00, 2900000.00, 3500.00, 10.00, 'Leeds, UK', 'Mike Chen', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00', 'Gate B');
INSERT INTO public.projects (id, programme_id, name, code, client, description, start_date, end_date, contract_completion_date, actual_completion_date, status, total_budget, contract_value, forecast_cost, daily_ld_rate, ld_cap_pct, location, project_manager, created_at, updated_at, phase) VALUES (5, 2, 'Kubernetes Platform Build', 'CIP-003', 'Vodafone UK', 'Enterprise Kubernetes platform on Azure AKS with GitOps, service mesh, and observability stack', '2025-09-30', '2026-05-28', '2026-05-13', NULL, 'Active', 1800000.00, 2100000.00, 1950000.00, 2500.00, 10.00, 'Newbury, UK', 'Alex Johnson', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00', 'Gate C');
INSERT INTO public.projects (id, programme_id, name, code, client, description, start_date, end_date, contract_completion_date, actual_completion_date, status, total_budget, contract_value, forecast_cost, daily_ld_rate, ld_cap_pct, location, project_manager, created_at, updated_at, phase) VALUES (6, 3, 'Mobile Banking App Rebuild', 'DBP-001', 'Metro Bank', 'Ground-up rebuild of iOS/Android banking app with biometric auth, real-time payments, and open banking APIs', '2025-08-11', '2026-06-07', '2026-05-18', NULL, 'Active', 3500000.00, 4000000.00, 3700000.00, 4500.00, 10.00, 'London, UK', 'Sarah Williams', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00', 'Construction');
INSERT INTO public.projects (id, programme_id, name, code, client, description, start_date, end_date, contract_completion_date, actual_completion_date, status, total_budget, contract_value, forecast_cost, daily_ld_rate, ld_cap_pct, location, project_manager, created_at, updated_at, phase) VALUES (7, 3, 'Payment Gateway Platform', 'DBP-002', 'Revolut', 'High-throughput payment processing platform handling 10K TPS with PCI-DSS compliance', '2025-11-19', '2026-11-14', '2026-10-25', NULL, 'Active', 2600000.00, 3000000.00, 2750000.00, 3000.00, 12.00, 'London, UK', 'Alex Johnson', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00', 'Design Completion');
INSERT INTO public.projects (id, programme_id, name, code, client, description, start_date, end_date, contract_completion_date, actual_completion_date, status, total_budget, contract_value, forecast_cost, daily_ld_rate, ld_cap_pct, location, project_manager, created_at, updated_at, phase) VALUES (8, 1, 'Data Warehouse & BI Platform', 'EMP-003', 'Tesco PLC', 'Snowflake data warehouse with dbt transformations, Tableau dashboards, and real-time Kafka streaming', '2025-09-20', '2026-09-15', '2026-08-26', NULL, 'Active', 2200000.00, 2500000.00, 2350000.00, 2500.00, 10.00, 'Welwyn Garden City, UK', 'Sarah Williams', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00', 'Gate B');
INSERT INTO public.projects (id, programme_id, name, code, client, description, start_date, end_date, contract_completion_date, actual_completion_date, status, total_budget, contract_value, forecast_cost, daily_ld_rate, ld_cap_pct, location, project_manager, created_at, updated_at, phase) VALUES (9, 3, 'Fraud Detection ML System', 'DBP-003', 'Lloyds Banking Group', 'Real-time ML fraud detection engine processing card transactions with 99.7% accuracy target', '2025-12-29', '2026-12-24', '2026-12-04', NULL, 'Active', 3000000.00, 3500000.00, 3100000.00, 3500.00, 10.00, 'Edinburgh, UK', 'Mike Chen', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00', 'Gate C');
INSERT INTO public.projects (id, programme_id, name, code, client, description, start_date, end_date, contract_completion_date, actual_completion_date, status, total_budget, contract_value, forecast_cost, daily_ld_rate, ld_cap_pct, location, project_manager, created_at, updated_at, phase) VALUES (10, 2, 'DevOps CI/CD Transformation', 'CIP-004', 'BP Digital', 'Enterprise-wide CI/CD pipeline standardization with GitHub Actions, ArgoCD, Terraform, and Vault', '2025-11-09', '2026-05-08', '2026-04-28', NULL, 'Completed', 950000.00, 1100000.00, 980000.00, 1500.00, 10.00, 'Sunbury, UK', 'Alex Johnson', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00', 'Commissioned');


--
-- Data for Name: risk_register; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (1, 1, 'R-001', 'Data quality issues in legacy system', 'Source data in SAP R/3 has inconsistencies that may cause migration failures', 'Technical', 4, 4, 'Run data profiling tool, allocate 3-week cleansing sprint', NULL, 'Alex Johnson', 'Open', '2026-02-27', NULL, 350000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (2, 1, 'R-002', 'Key SME availability during UAT', 'Business users may be unavailable for 6-week UAT window', 'Resource', 3, 4, 'Pre-book UAT resources, stagger testing by module', NULL, 'Sarah Williams', 'Open', '2026-02-27', NULL, 200000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (3, 3, 'R-001', 'Application compatibility with AWS', 'Legacy .NET Framework apps may need significant refactoring', 'Technical', 4, 3, 'Run AWS Migration Hub assessment, identify refactor candidates early', NULL, 'Alex Johnson', 'Open', '2026-02-27', NULL, 500000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (4, 3, 'R-002', 'Network latency post-migration', 'Hybrid connectivity may not meet SLA for latency-sensitive apps', 'Technical', 3, 5, 'Deploy Direct Connect, perform latency testing in pilot', NULL, 'Mike Chen', 'Open', '2026-02-27', NULL, 300000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (5, 4, 'R-001', 'Staff resistance to MFA adoption', 'Clinical staff may resist mandatory MFA on shared devices', 'Resource', 4, 3, 'Phased rollout with champions programme, FIDO2 keys for shared devices', NULL, 'Mike Chen', 'Mitigated', '2026-02-27', NULL, 150000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (6, 5, 'R-001', 'Cluster scaling limits under peak load', 'AKS cluster may hit Azure quota limits during traffic spikes', 'Technical', 2, 4, 'Pre-request quota increases, implement HPA and cluster autoscaler', NULL, 'Alex Johnson', 'Open', '2026-02-27', NULL, 200000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (7, 6, 'R-001', 'App store rejection due to compliance', 'Apple/Google may reject app for financial services compliance issues', 'Legal', 3, 5, 'Engage Apple/Google developer relations early, pre-submission review', NULL, 'Sarah Williams', 'Open', '2026-02-27', NULL, 400000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (8, 6, 'R-002', 'Biometric auth device fragmentation', 'Fingerprint/face recognition may fail on older Android devices', 'Technical', 3, 3, 'Test on top 20 device models, provide PIN fallback', NULL, 'Alex Johnson', 'Open', '2026-02-27', NULL, 100000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (9, 7, 'R-001', 'PCI-DSS audit failure', 'First audit attempt may identify non-conformances delaying launch', 'Legal', 3, 5, 'Engage QSA for pre-audit assessment, remediate findings early', NULL, 'Mike Chen', 'Open', '2026-02-27', NULL, 600000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (10, 8, 'R-001', 'Snowflake cost overrun', 'Compute credits may exceed budget with complex dbt models', 'Commercial', 4, 3, 'Implement resource monitors, optimize warehouse sizing', NULL, 'Sarah Williams', 'Open', '2026-02-27', NULL, 180000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (11, 9, 'R-001', 'Model accuracy below 99.7% target', 'False positive rate may be too high for production use', 'Technical', 3, 5, 'Ensemble model approach, A/B testing with existing rules engine', NULL, 'Mike Chen', 'Open', '2026-02-27', NULL, 500000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.risk_register (id, project_id, risk_code, title, description, category, probability, impact, mitigation_plan, contingency_plan, owner, status, identified_date, review_date, cost_exposure, created_at, updated_at) VALUES (12, 9, 'R-002', 'Training data bias', 'Historical fraud data may contain demographic bias', 'Legal', 3, 4, 'Fairness testing framework, bias audit by external consultancy', NULL, 'Alex Johnson', 'Open', '2026-02-27', NULL, 250000.00, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: safety_incidents; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.safety_incidents (id, project_id, incident_type, severity, reported_date, resolved_date, status, penalty_cost, description, lost_time_hours, location, reported_by, created_at, updated_at) VALUES (1, 1, 'Observation', 'Minor', '2026-01-28', '2026-01-30', 'Closed', 0.00, 'Trailing cables across walkway in server room', 0.00, 'Data Centre Floor 2', 'Facilities', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.safety_incidents (id, project_id, incident_type, severity, reported_date, resolved_date, status, penalty_cost, description, lost_time_hours, location, reported_by, created_at, updated_at) VALUES (2, 3, 'Observation', 'Minor', '2026-02-07', '2026-02-09', 'Closed', 0.00, 'Emergency exit blocked by decommissioned hardware', 0.00, 'Server Room B', 'HSE Officer', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.safety_incidents (id, project_id, incident_type, severity, reported_date, resolved_date, status, penalty_cost, description, lost_time_hours, location, reported_by, created_at, updated_at) VALUES (3, 3, 'Near Miss', 'Moderate', '2026-02-17', NULL, 'Under Investigation', 0.00, 'UPS overheating detected before failure during migration window', 4.00, 'Data Centre', 'DC Operator', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.safety_incidents (id, project_id, incident_type, severity, reported_date, resolved_date, status, penalty_cost, description, lost_time_hours, location, reported_by, created_at, updated_at) VALUES (4, 4, 'Observation', 'Minor', '2026-02-12', '2026-02-13', 'Resolved', 0.00, 'Ergonomic issue - adjustable desks not provided for site deployment team', 0.00, 'Hospital Site 12', 'Team Lead', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.safety_incidents (id, project_id, incident_type, severity, reported_date, resolved_date, status, penalty_cost, description, lost_time_hours, location, reported_by, created_at, updated_at) VALUES (5, 5, 'Injury', 'Minor', '2026-02-22', '2026-02-23', 'Closed', 0.00, 'Developer reported RSI symptoms from extended keyboard use', 8.00, 'Office - Floor 3', 'Line Manager', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.safety_incidents (id, project_id, incident_type, severity, reported_date, resolved_date, status, penalty_cost, description, lost_time_hours, location, reported_by, created_at, updated_at) VALUES (6, 6, 'Near Miss', 'Minor', '2026-02-19', '2026-02-20', 'Resolved', 0.00, 'Unsecured laptop with production credentials left in meeting room', 0.00, 'Metro Bank HQ', 'Security Guard', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.safety_incidents (id, project_id, incident_type, severity, reported_date, resolved_date, status, penalty_cost, description, lost_time_hours, location, reported_by, created_at, updated_at) VALUES (7, 8, 'Environmental', 'Minor', '2026-02-15', NULL, 'Open', 0.00, 'E-waste from decommissioned servers not disposed per WEEE regulations', 0.00, 'Tesco DC', 'Environmental Officer', '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: simulation_scenarios; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (1, 1, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "ERP System Migration", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 4200000.0, "current_actual_cost": 2360000.0, "forecast_cost": 2479000.0, "budget_variance": 1721000.0, "cost_increase_pct": 5.04, "before_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 380000.0, "variance": 40000.0}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 610000.0, "variance": 20000.0}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 620000.0, "variance": 220000.0}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 700000.0, "variance": 560000.0}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 50000.0, "variance": 580000.0}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0}], "after_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 399161.02, "variance": 20838.98, "cost_added": 19161.02}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 640758.47, "variance": -10758.47, "cost_added": 30758.47}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 651262.71, "variance": 188737.29, "cost_added": 31262.71}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 735296.61, "variance": 524703.39, "cost_added": 35296.61}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 52521.19, "variance": 577478.81, "cost_added": 2521.19}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0, "cost_added": 0.0}]}', '2026-02-27 11:40:31.710423+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (2, 1, 'Schedule', '{"milestone_id": "", "phase": "", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-03-08", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-12-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-09-09", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-02-06", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-09-14", "planned_finish": "2025-10-24", "status": "Completed", "shifted": true}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-24", "planned_finish": "2025-12-03", "status": "Completed", "shifted": true}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-12-03", "planned_finish": "2026-02-01", "status": "Delayed", "shifted": true}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-23", "planned_finish": "2026-03-03", "status": "Delayed", "shifted": true}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-02-01", "planned_finish": "2026-05-12", "status": "In Progress", "shifted": true}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-05-12", "planned_finish": "2026-07-11", "status": "Not Started", "shifted": true}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-07-11", "planned_finish": "2026-09-09", "status": "Not Started", "shifted": true}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-09-09", "planned_finish": "2026-11-08", "status": "Not Started", "shifted": true}]}', '2026-02-27 11:40:39.428535+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (3, 1, 'Cashflow', '{"milestone_delay_days": 14}', '{"project_name": "ERP System Migration", "delay_days": 14, "total_expected": 1440000.0, "total_received": 480000.0, "working_capital_gap": 960000.0, "before_cashflow": [{"month": "2025-11", "expected": 480000.0, "received": 480000.0, "cumulative": 480000.0}, {"month": "2026-02", "expected": 960000.0, "received": 0, "cumulative": 1440000.0}, {"month": "2026-03", "expected": 0, "received": 0, "cumulative": 1440000.0}], "after_cashflow": [{"month": "2025-11", "expected": 480000.0, "received": 480000.0, "cumulative": 480000.0}, {"month": "2026-02", "expected": 0, "received": 0, "cumulative": 480000.0}, {"month": "2026-03", "expected": 960000.0, "received": 0, "cumulative": 1440000.0}], "combined_chart": [{"month": "2025-11", "before_expected": 480000.0, "after_expected": 480000.0, "before_received": 480000.0, "after_received": 480000.0}, {"month": "2026-02", "before_expected": 960000.0, "after_expected": 0, "before_received": 0, "after_received": 0}, {"month": "2026-03", "before_expected": 0, "after_expected": 960000.0, "before_received": 0, "after_received": 0}]}', '2026-02-27 11:40:47.080238+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (4, 1, 'Resource', '{"activity_id": 3, "additional_resources": 2, "productivity_gain_pct": 15}', '{"project_name": "ERP System Migration", "target_activity_id": 3, "additional_resources": 2, "productivity_gain_pct": 15.0, "total_gain_pct": 30.0, "days_saved": 4, "additional_cost": 12000, "cost_per_day_saved": 3000.0, "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "duration_days": 40, "completion_pct": 100.0, "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "duration_days": 40, "completion_pct": 100.0, "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "duration_days": 60, "completion_pct": 80.0, "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "duration_days": 70, "completion_pct": 70.0, "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "duration_days": 100, "completion_pct": 30.0, "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "duration_days": 60, "completion_pct": 0.0, "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "duration_days": 60, "completion_pct": 0.0, "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "duration_days": 60, "completion_pct": 0.0, "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "duration_days": 40, "completion_pct": 100.0, "status": "Completed", "accelerated": false, "days_saved": 0}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "duration_days": 40, "completion_pct": 100.0, "status": "Completed", "accelerated": false, "days_saved": 0}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-14", "duration_days": 56, "completion_pct": 80.0, "status": "Delayed", "days_saved": 4, "additional_resources": 2, "accelerated": true}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "duration_days": 70, "completion_pct": 70.0, "status": "Delayed", "accelerated": false, "days_saved": 0}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "duration_days": 100, "completion_pct": 30.0, "status": "In Progress", "accelerated": false, "days_saved": 0}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "duration_days": 60, "completion_pct": 0.0, "status": "Not Started", "accelerated": false, "days_saved": 0}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "duration_days": 60, "completion_pct": 0.0, "status": "Not Started", "accelerated": false, "days_saved": 0}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "duration_days": 60, "completion_pct": 0.0, "status": "Not Started", "accelerated": false, "days_saved": 0}]}', '2026-02-27 11:41:01.831056+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (5, 2, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-12-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-09-14", "planned_finish": "2025-10-24", "status": "Completed", "shifted": true}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-24", "planned_finish": "2025-12-03", "status": "Completed", "shifted": true}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-02 07:50:30.7527+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (6, 3, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-12-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-09-14", "planned_finish": "2025-10-24", "status": "Completed", "shifted": true}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-24", "planned_finish": "2025-12-03", "status": "Completed", "shifted": true}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-02 10:45:28.441269+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (7, 3, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-12-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-09-14", "planned_finish": "2025-10-24", "status": "Completed", "shifted": true}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-24", "planned_finish": "2025-12-03", "status": "Completed", "shifted": true}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-02 10:45:46.748208+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (27, 8, 'Resource', '{"activity_id": 11, "additional_resources": 2, "productivity_gain_pct": 15}', '{"project_name": "HR Portal & Employee Self-Service", "target_activity_id": 11, "additional_resources": 2, "productivity_gain_pct": 15.0, "total_gain_pct": 30.0, "days_saved": 3, "additional_cost": 9000, "cost_per_day_saved": 3000.0, "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "duration_days": 30, "completion_pct": 100.0, "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "duration_days": 60, "completion_pct": 100.0, "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "duration_days": 60, "completion_pct": 85.0, "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "duration_days": 60, "completion_pct": 45.0, "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "duration_days": 30, "completion_pct": 100.0, "status": "Completed", "accelerated": false, "days_saved": 0}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "duration_days": 60, "completion_pct": 100.0, "status": "Completed", "accelerated": false, "days_saved": 0}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-14", "duration_days": 57, "completion_pct": 85.0, "status": "Delayed", "days_saved": 3, "additional_resources": 2, "accelerated": true}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "duration_days": 60, "completion_pct": 45.0, "status": "In Progress", "accelerated": false, "days_saved": 0}]}', '2026-03-03 12:08:52.650285+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (8, 4, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 10}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 10, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-29", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-09-10", "planned_finish": "2025-10-20", "status": "Completed", "shifted": true}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-20", "planned_finish": "2025-11-29", "status": "Completed", "shifted": true}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-02 13:10:17.392323+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (9, 5, 'Schedule', '{"milestone_id": "", "phase": "", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-03-08", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-12-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-09-09", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-02-06", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-09-14", "planned_finish": "2025-10-24", "status": "Completed", "shifted": true}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-24", "planned_finish": "2025-12-03", "status": "Completed", "shifted": true}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-12-03", "planned_finish": "2026-02-01", "status": "Delayed", "shifted": true}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-23", "planned_finish": "2026-03-03", "status": "Delayed", "shifted": true}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-02-01", "planned_finish": "2026-05-12", "status": "In Progress", "shifted": true}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-05-12", "planned_finish": "2026-07-11", "status": "Not Started", "shifted": true}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-07-11", "planned_finish": "2026-09-09", "status": "Not Started", "shifted": true}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-09-09", "planned_finish": "2026-11-08", "status": "Not Started", "shifted": true}]}', '2026-03-03 09:44:53.187311+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (10, 6, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-12-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-09-14", "planned_finish": "2025-10-24", "status": "Completed", "shifted": true}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-24", "planned_finish": "2025-12-03", "status": "Completed", "shifted": true}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-03 11:09:57.657285+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (11, 6, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "ERP System Migration", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 4200000.0, "current_actual_cost": 2360000.0, "forecast_cost": 2479000.0, "budget_variance": 1721000.0, "cost_increase_pct": 5.04, "before_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 380000.0, "variance": 40000.0}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 610000.0, "variance": 20000.0}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 620000.0, "variance": 220000.0}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 700000.0, "variance": 560000.0}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 50000.0, "variance": 580000.0}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0}], "after_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 399161.02, "variance": 20838.98, "cost_added": 19161.02}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 640758.47, "variance": -10758.47, "cost_added": 30758.47}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 651262.71, "variance": 188737.29, "cost_added": 31262.71}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 735296.61, "variance": 524703.39, "cost_added": 35296.61}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 52521.19, "variance": 577478.81, "cost_added": 2521.19}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0, "cost_added": 0.0}]}', '2026-03-03 11:10:53.809556+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (12, 6, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-12-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-09-14", "planned_finish": "2025-10-24", "status": "Completed", "shifted": true}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-24", "planned_finish": "2025-12-03", "status": "Completed", "shifted": true}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-03 11:11:06.530951+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (13, 6, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 10}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 10, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-29", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-09-10", "planned_finish": "2025-10-20", "status": "Completed", "shifted": true}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-20", "planned_finish": "2025-11-29", "status": "Completed", "shifted": true}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-03 11:11:10.058658+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (14, 6, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 1}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 1, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-20", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 4, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-09-01", "planned_finish": "2025-10-11", "status": "Completed", "shifted": true}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-11", "planned_finish": "2025-11-20", "status": "Completed", "shifted": true}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-03 11:11:15.388149+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (15, 7, 'Schedule', '{"milestone_id": "", "phase": "Construction", "delay_days": 1}', '{"project_name": "AWS Cloud Migration", "original_end_date": "2026-06-27", "simulated_end_date": "2026-06-27", "total_delay_days": 1, "critical_milestone_impacted": false, "project_status_before": "At Risk", "project_status_after": "At Risk", "before_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-09-20", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-09", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-04-28", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-07", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-09-20", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10, "new_delay_days": 10, "shifted": false}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-10", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10, "new_delay_days": 9, "shifted": true}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-04-28", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-07", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-02", "planned_finish": "2025-08-11", "status": "Completed"}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-11", "planned_finish": "2025-09-20", "status": "Completed"}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-09-20", "planned_finish": "2025-12-09", "status": "Completed"}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-02-17", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}], "after_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-02", "planned_finish": "2025-08-11", "status": "Completed", "shifted": false}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-11", "planned_finish": "2025-09-20", "status": "Completed", "shifted": false}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-09-21", "planned_finish": "2025-12-10", "status": "Completed", "shifted": true}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-10", "planned_finish": "2026-02-18", "status": "Delayed", "shifted": true}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-02-18", "planned_finish": "2026-04-29", "status": "In Progress", "shifted": true}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}]}', '2026-03-03 11:11:22.518366+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (16, 7, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "AWS Cloud Migration", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 3800000.0, "current_actual_cost": 2810000.0, "forecast_cost": 2929000.0, "budget_variance": 871000.0, "cost_increase_pct": 4.23, "before_cbs": [{"id": 7, "wbs_code": "1.0", "description": "Discovery & Assessment", "budget_cost": 380000.0, "actual_cost": 350000.0, "variance": 30000.0}, {"id": 8, "wbs_code": "2.0", "description": "Landing Zone & Networking", "budget_cost": 570000.0, "actual_cost": 560000.0, "variance": 10000.0}, {"id": 9, "wbs_code": "3.0", "description": "Application Migration", "budget_cost": 2280000.0, "actual_cost": 1800000.0, "variance": 680000.0}, {"id": 10, "wbs_code": "4.0", "description": "Optimization & Handover", "budget_cost": 570000.0, "actual_cost": 100000.0, "variance": 470000.0}], "after_cbs": [{"id": 7, "wbs_code": "1.0", "description": "Discovery & Assessment", "budget_cost": 380000.0, "actual_cost": 364822.06, "variance": 15177.94, "cost_added": 14822.06}, {"id": 8, "wbs_code": "2.0", "description": "Landing Zone & Networking", "budget_cost": 570000.0, "actual_cost": 583715.3, "variance": -13715.3, "cost_added": 23715.3}, {"id": 9, "wbs_code": "3.0", "description": "Application Migration", "budget_cost": 2280000.0, "actual_cost": 1876227.76, "variance": 203772.24, "cost_added": 76227.76}, {"id": 10, "wbs_code": "4.0", "description": "Optimization & Handover", "budget_cost": 570000.0, "actual_cost": 104234.88, "variance": 465765.12, "cost_added": 4234.88}]}', '2026-03-03 11:12:26.660189+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (17, 7, 'Cashflow', '{"milestone_delay_days": 14}', '{"project_name": "AWS Cloud Migration", "delay_days": 14, "total_expected": 2730000.0, "total_received": 1470000.0, "working_capital_gap": 1260000.0, "before_cashflow": [{"month": "2025-09", "expected": 420000.0, "received": 420000.0, "cumulative": 420000.0}, {"month": "2025-12", "expected": 1050000.0, "received": 1050000.0, "cumulative": 1470000.0}, {"month": "2026-04", "expected": 1260000.0, "received": 0, "cumulative": 2730000.0}, {"month": "2026-05", "expected": 0, "received": 0, "cumulative": 2730000.0}], "after_cashflow": [{"month": "2025-09", "expected": 420000.0, "received": 420000.0, "cumulative": 420000.0}, {"month": "2025-12", "expected": 1050000.0, "received": 1050000.0, "cumulative": 1470000.0}, {"month": "2026-04", "expected": 0, "received": 0, "cumulative": 1470000.0}, {"month": "2026-05", "expected": 1260000.0, "received": 0, "cumulative": 2730000.0}], "combined_chart": [{"month": "2025-09", "before_expected": 420000.0, "after_expected": 420000.0, "before_received": 420000.0, "after_received": 420000.0}, {"month": "2025-12", "before_expected": 1050000.0, "after_expected": 1050000.0, "before_received": 1050000.0, "after_received": 1050000.0}, {"month": "2026-04", "before_expected": 1260000.0, "after_expected": 0, "before_received": 0, "after_received": 0}, {"month": "2026-05", "before_expected": 0, "after_expected": 1260000.0, "before_received": 0, "after_received": 0}]}', '2026-03-03 11:12:34.856798+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (18, 8, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 14, "critical_milestone_impacted": false, "project_status_before": "Active", "project_status_after": "Active", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-11-13", "planned_finish": "2025-12-13", "status": "Completed", "shifted": true}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:07:36.752202+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (19, 8, 'Schedule', '{"milestone_id": "", "phase": "Construction", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-12-13", "planned_finish": "2026-02-11", "status": "Completed", "shifted": true}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2026-01-02", "planned_finish": "2026-03-03", "status": "Delayed", "shifted": true}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-02-11", "planned_finish": "2026-04-12", "status": "In Progress", "shifted": true}]}', '2026-03-03 12:07:53.870369+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (20, 8, 'Schedule', '{"milestone_id": "", "phase": "Closure", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 14, "critical_milestone_impacted": false, "project_status_before": "Active", "project_status_after": "Active", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:07:58.4276+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (21, 8, 'Schedule', '{"milestone_id": 5, "phase": "", "delay_days": 1}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 1, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-18", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 1, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:08:07.434581+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (22, 8, 'Schedule', '{"milestone_id": 5, "phase": "", "delay_days": 2}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 2, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-19", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 2, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:08:13.820368+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (23, 8, 'Schedule', '{"milestone_id": 5, "phase": "", "delay_days": 2}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 2, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-19", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 2, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:08:26.754629+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (24, 8, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "HR Portal & Employee Self-Service", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 0, "current_actual_cost": 0, "forecast_cost": 119000.0, "budget_variance": -119000.0, "cost_increase_pct": 0, "before_cbs": [], "after_cbs": []}', '2026-03-03 12:08:36.217859+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (25, 8, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "HR Portal & Employee Self-Service", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 0, "current_actual_cost": 0, "forecast_cost": 119000.0, "budget_variance": -119000.0, "cost_increase_pct": 0, "before_cbs": [], "after_cbs": []}', '2026-03-03 12:08:41.255245+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (26, 8, 'Cashflow', '{"milestone_delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "delay_days": 14, "total_expected": 0, "total_received": 0, "working_capital_gap": 0, "before_cashflow": [], "after_cashflow": [], "combined_chart": []}', '2026-03-03 12:08:46.425262+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (28, 8, 'Schedule', '{"milestone_id": "", "phase": "Construction", "delay_days": 2}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 2, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-19", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 2, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-12-01", "planned_finish": "2026-01-30", "status": "Completed", "shifted": true}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-21", "planned_finish": "2026-02-19", "status": "Delayed", "shifted": true}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-30", "planned_finish": "2026-03-31", "status": "In Progress", "shifted": true}]}', '2026-03-03 12:09:05.535876+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (29, 9, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 14, "critical_milestone_impacted": false, "project_status_before": "Active", "project_status_after": "Active", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-11-13", "planned_finish": "2025-12-13", "status": "Completed", "shifted": true}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:40:55.937003+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (30, 9, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 4}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 4, "critical_milestone_impacted": false, "project_status_before": "Active", "project_status_after": "Active", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-11-03", "planned_finish": "2025-12-03", "status": "Completed", "shifted": true}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:41:00.77896+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (31, 9, 'Schedule', '{"milestone_id": "", "phase": "Construction", "delay_days": 4}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 4, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-21", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 4, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-12-03", "planned_finish": "2026-02-01", "status": "Completed", "shifted": true}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-23", "planned_finish": "2026-02-21", "status": "Delayed", "shifted": true}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-02-01", "planned_finish": "2026-04-02", "status": "In Progress", "shifted": true}]}', '2026-03-03 12:41:05.849375+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (32, 9, 'Schedule', '{"milestone_id": "", "phase": "Closure", "delay_days": 4}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 4, "critical_milestone_impacted": false, "project_status_before": "Active", "project_status_after": "Active", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:41:09.171274+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (33, 9, 'Schedule', '{"milestone_id": "", "phase": "Closure", "delay_days": 40}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 40, "critical_milestone_impacted": false, "project_status_before": "Active", "project_status_after": "Active", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:41:13.491265+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (34, 9, 'Schedule', '{"milestone_id": "", "phase": "Closure", "delay_days": 40}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 40, "critical_milestone_impacted": false, "project_status_before": "Active", "project_status_after": "Active", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:41:16.028738+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (35, 9, 'Schedule', '{"milestone_id": 6, "phase": "", "delay_days": 40}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-09-15", "total_delay_days": 40, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-09-15", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 40, "shifted": true}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:41:20.033507+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (36, 9, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "HR Portal & Employee Self-Service", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 0, "current_actual_cost": 0, "forecast_cost": 119000.0, "budget_variance": -119000.0, "cost_increase_pct": 0, "before_cbs": [], "after_cbs": []}', '2026-03-03 12:41:48.173056+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (37, 9, 'Schedule', '{"milestone_id": 6, "phase": "", "delay_days": 40}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-09-15", "total_delay_days": 40, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-09-15", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 40, "shifted": true}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 12:41:53.504164+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (38, 10, 'Schedule', '{"milestone_id": "", "phase": "", "delay_days": 14}', '{"project_name": "AWS Cloud Migration", "original_end_date": "2026-06-27", "simulated_end_date": "2026-07-11", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "At Risk", "project_status_after": "At Risk", "before_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-09-20", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-09", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-04-28", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-07", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-10-04", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10, "new_delay_days": 0, "shifted": true}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-23", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10, "new_delay_days": 0, "shifted": true}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-05-12", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-21", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-02", "planned_finish": "2025-08-11", "status": "Completed"}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-11", "planned_finish": "2025-09-20", "status": "Completed"}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-09-20", "planned_finish": "2025-12-09", "status": "Completed"}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-02-17", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}], "after_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-16", "planned_finish": "2025-08-25", "status": "Completed", "shifted": true}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-25", "planned_finish": "2025-10-04", "status": "Completed", "shifted": true}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-10-04", "planned_finish": "2025-12-23", "status": "Completed", "shifted": true}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-23", "planned_finish": "2026-03-03", "status": "Delayed", "shifted": true}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-03-03", "planned_finish": "2026-05-12", "status": "In Progress", "shifted": true}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-05-12", "planned_finish": "2026-07-11", "status": "Not Started", "shifted": true}]}', '2026-03-03 13:07:54.136756+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (39, 11, 'Schedule', '{"milestone_id": "", "phase": "", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-09-09", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-20", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-11-13", "planned_finish": "2025-12-13", "status": "Completed", "shifted": true}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-12-13", "planned_finish": "2026-02-11", "status": "Completed", "shifted": true}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2026-01-02", "planned_finish": "2026-03-03", "status": "Delayed", "shifted": true}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-02-11", "planned_finish": "2026-04-12", "status": "In Progress", "shifted": true}]}', '2026-03-03 13:08:17.207305+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (40, 12, 'Schedule', '{"milestone_id": "", "phase": "", "delay_days": 14}', '{"project_name": "AWS Cloud Migration", "original_end_date": "2026-06-27", "simulated_end_date": "2026-07-11", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "At Risk", "project_status_after": "At Risk", "before_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-09-20", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-09", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-04-28", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-07", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-10-04", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10, "new_delay_days": 0, "shifted": true}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-23", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10, "new_delay_days": 0, "shifted": true}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-05-12", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-21", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-02", "planned_finish": "2025-08-11", "status": "Completed"}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-11", "planned_finish": "2025-09-20", "status": "Completed"}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-09-20", "planned_finish": "2025-12-09", "status": "Completed"}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-02-17", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}], "after_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-16", "planned_finish": "2025-08-25", "status": "Completed", "shifted": true}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-25", "planned_finish": "2025-10-04", "status": "Completed", "shifted": true}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-10-04", "planned_finish": "2025-12-23", "status": "Completed", "shifted": true}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-23", "planned_finish": "2026-03-03", "status": "Delayed", "shifted": true}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-03-03", "planned_finish": "2026-05-12", "status": "In Progress", "shifted": true}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-05-12", "planned_finish": "2026-07-11", "status": "Not Started", "shifted": true}]}', '2026-03-03 13:17:18.0735+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (41, 13, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 14, "critical_milestone_impacted": false, "project_status_before": "Active", "project_status_after": "Active", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-11-13", "planned_finish": "2025-12-13", "status": "Completed", "shifted": true}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-03 18:22:57.628532+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (42, 14, 'Schedule', '{"milestone_id": 13, "phase": "", "delay_days": 14}', '{"project_name": "Kubernetes Platform Build", "original_end_date": "2026-05-28", "simulated_end_date": "2026-05-28", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 13, "name": "Platform GA", "phase": "Construction", "planned_date": "2026-03-09", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 13, "name": "Platform GA", "phase": "Construction", "planned_date": "2026-03-23", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 23, "activity_name": "AKS Cluster Provisioning", "phase": "Design", "planned_start": "2025-09-30", "planned_finish": "2025-10-30", "status": "Completed"}, {"id": 24, "activity_name": "Istio Service Mesh Setup", "phase": "Construction", "planned_start": "2025-10-30", "planned_finish": "2025-12-09", "status": "Completed"}, {"id": 25, "activity_name": "GitOps with ArgoCD", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-01-18", "status": "Completed"}, {"id": 26, "activity_name": "Observability Stack (Prometheus/Grafana)", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-03-09", "status": "In Progress"}, {"id": 27, "activity_name": "Workload Onboarding (15 services)", "phase": "Commissioning", "planned_start": "2026-03-09", "planned_finish": "2026-05-28", "status": "Not Started"}], "after_activities": [{"id": 23, "activity_name": "AKS Cluster Provisioning", "phase": "Design", "planned_start": "2025-09-30", "planned_finish": "2025-10-30", "status": "Completed", "shifted": false}, {"id": 24, "activity_name": "Istio Service Mesh Setup", "phase": "Construction", "planned_start": "2025-10-30", "planned_finish": "2025-12-09", "status": "Completed", "shifted": false}, {"id": 25, "activity_name": "GitOps with ArgoCD", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-01-18", "status": "Completed", "shifted": false}, {"id": 26, "activity_name": "Observability Stack (Prometheus/Grafana)", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-03-09", "status": "In Progress", "shifted": false}, {"id": 27, "activity_name": "Workload Onboarding (15 services)", "phase": "Commissioning", "planned_start": "2026-03-09", "planned_finish": "2026-05-28", "status": "Not Started", "shifted": false}]}', '2026-03-03 18:23:37.838859+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (43, 14, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "Kubernetes Platform Build", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 0, "current_actual_cost": 0, "forecast_cost": 119000.0, "budget_variance": -119000.0, "cost_increase_pct": 0, "before_cbs": [], "after_cbs": []}', '2026-03-03 18:23:48.478624+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (44, 14, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 4}', '{"project_name": "Kubernetes Platform Build", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 4.0, "cost_impact": 119000.0, "escalation_amount": 4760.0, "total_cost_impact": 123760.0, "total_budget": 0, "current_actual_cost": 0, "forecast_cost": 123760.0, "budget_variance": -123760.0, "cost_increase_pct": 0, "before_cbs": [], "after_cbs": []}', '2026-03-03 18:24:02.886454+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (45, 14, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 44}', '{"project_name": "Kubernetes Platform Build", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 44.0, "cost_impact": 119000.0, "escalation_amount": 52360.0, "total_cost_impact": 171360.0, "total_budget": 0, "current_actual_cost": 0, "forecast_cost": 171360.0, "budget_variance": -171360.0, "cost_increase_pct": 0, "before_cbs": [], "after_cbs": []}', '2026-03-03 18:24:19.154763+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (46, 14, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 18500, "escalation_pct": 44}', '{"project_name": "Kubernetes Platform Build", "time_impact_days": 14, "daily_overhead_cost": 18500.0, "escalation_pct": 44.0, "cost_impact": 259000.0, "escalation_amount": 113960.0, "total_cost_impact": 372960.0, "total_budget": 0, "current_actual_cost": 0, "forecast_cost": 372960.0, "budget_variance": -372960.0, "cost_increase_pct": 0, "before_cbs": [], "after_cbs": []}', '2026-03-03 18:24:37.001493+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (47, 14, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 18500, "escalation_pct": 44}', '{"project_name": "Kubernetes Platform Build", "time_impact_days": 14, "daily_overhead_cost": 18500.0, "escalation_pct": 44.0, "cost_impact": 259000.0, "escalation_amount": 113960.0, "total_cost_impact": 372960.0, "total_budget": 0, "current_actual_cost": 0, "forecast_cost": 372960.0, "budget_variance": -372960.0, "cost_increase_pct": 0, "before_cbs": [], "after_cbs": []}', '2026-03-03 18:24:40.767912+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (48, 14, 'Cashflow', '{"milestone_delay_days": 14}', '{"project_name": "Kubernetes Platform Build", "delay_days": 14, "total_expected": 0, "total_received": 0, "working_capital_gap": 0, "before_cashflow": [], "after_cashflow": [], "combined_chart": []}', '2026-03-03 18:25:24.306082+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (49, 14, 'Resource', '{"activity_id": 26, "additional_resources": 2, "productivity_gain_pct": 15}', '{"project_name": "Kubernetes Platform Build", "target_activity_id": 26, "additional_resources": 2, "productivity_gain_pct": 15.0, "total_gain_pct": 30.0, "days_saved": 4, "additional_cost": 12000, "cost_per_day_saved": 3000.0, "before_activities": [{"id": 23, "activity_name": "AKS Cluster Provisioning", "phase": "Design", "planned_start": "2025-09-30", "planned_finish": "2025-10-30", "duration_days": 30, "completion_pct": 100.0, "status": "Completed"}, {"id": 24, "activity_name": "Istio Service Mesh Setup", "phase": "Construction", "planned_start": "2025-10-30", "planned_finish": "2025-12-09", "duration_days": 40, "completion_pct": 100.0, "status": "Completed"}, {"id": 25, "activity_name": "GitOps with ArgoCD", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-01-18", "duration_days": 40, "completion_pct": 100.0, "status": "Completed"}, {"id": 26, "activity_name": "Observability Stack (Prometheus/Grafana)", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-03-09", "duration_days": 50, "completion_pct": 75.0, "status": "In Progress"}, {"id": 27, "activity_name": "Workload Onboarding (15 services)", "phase": "Commissioning", "planned_start": "2026-03-09", "planned_finish": "2026-05-28", "duration_days": 80, "completion_pct": 0.0, "status": "Not Started"}], "after_activities": [{"id": 23, "activity_name": "AKS Cluster Provisioning", "phase": "Design", "planned_start": "2025-09-30", "planned_finish": "2025-10-30", "duration_days": 30, "completion_pct": 100.0, "status": "Completed", "accelerated": false, "days_saved": 0}, {"id": 24, "activity_name": "Istio Service Mesh Setup", "phase": "Construction", "planned_start": "2025-10-30", "planned_finish": "2025-12-09", "duration_days": 40, "completion_pct": 100.0, "status": "Completed", "accelerated": false, "days_saved": 0}, {"id": 25, "activity_name": "GitOps with ArgoCD", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-01-18", "duration_days": 40, "completion_pct": 100.0, "status": "Completed", "accelerated": false, "days_saved": 0}, {"id": 26, "activity_name": "Observability Stack (Prometheus/Grafana)", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-03-05", "duration_days": 46, "completion_pct": 75.0, "status": "In Progress", "days_saved": 4, "additional_resources": 2, "accelerated": true}, {"id": 27, "activity_name": "Workload Onboarding (15 services)", "phase": "Commissioning", "planned_start": "2026-03-09", "planned_finish": "2026-05-28", "duration_days": 80, "completion_pct": 0.0, "status": "Not Started", "accelerated": false, "days_saved": 0}]}', '2026-03-03 18:25:34.616807+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (50, 15, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "HR Portal & Employee Self-Service", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 0, "current_actual_cost": 0, "forecast_cost": 119000.0, "budget_variance": -119000.0, "cost_increase_pct": 0, "before_cbs": [], "after_cbs": []}', '2026-03-03 18:32:04.941267+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (51, 16, 'Schedule', '{"milestone_id": 1, "phase": "", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-12-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed", "shifted": false}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed", "shifted": false}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-04 07:42:16.745318+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (52, 17, 'Schedule', '{"milestone_id": 2, "phase": "", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 5, "shifted": false}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed", "shifted": false}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed", "shifted": false}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-04 08:23:19.224911+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (53, 18, 'Schedule', '{"milestone_id": "", "phase": "", "delay_days": 14}', '{"project_name": "Zero Trust Network Security", "original_end_date": "2026-11-24", "simulated_end_date": "2026-12-08", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 11, "name": "MFA Rollout Complete", "phase": "Construction", "planned_date": "2026-02-07", "actual_date": "2026-02-09", "is_critical": true, "status": "Delayed", "delay_days": 2}, {"id": 12, "name": "Full Zero Trust Live", "phase": "Commissioning", "planned_date": "2026-11-04", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 11, "name": "MFA Rollout Complete", "phase": "Construction", "planned_date": "2026-02-21", "actual_date": "2026-02-09", "is_critical": true, "status": "Delayed", "delay_days": 2, "new_delay_days": 0, "shifted": true}, {"id": 12, "name": "Full Zero Trust Live", "phase": "Commissioning", "planned_date": "2026-11-18", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 19, "activity_name": "Network Topology Assessment", "phase": "Design", "planned_start": "2025-11-29", "planned_finish": "2025-12-29", "status": "Completed"}, {"id": 20, "activity_name": "Identity Provider Setup (Azure AD)", "phase": "Construction", "planned_start": "2025-12-29", "planned_finish": "2026-02-07", "status": "Completed"}, {"id": 21, "activity_name": "Micro-Segmentation Rollout", "phase": "Construction", "planned_start": "2026-02-07", "planned_finish": "2026-05-28", "status": "In Progress"}, {"id": 22, "activity_name": "SIEM & SOC Integration", "phase": "Commissioning", "planned_start": "2026-05-28", "planned_finish": "2026-09-15", "status": "Not Started"}], "after_activities": [{"id": 19, "activity_name": "Network Topology Assessment", "phase": "Design", "planned_start": "2025-12-13", "planned_finish": "2026-01-12", "status": "Completed", "shifted": true}, {"id": 20, "activity_name": "Identity Provider Setup (Azure AD)", "phase": "Construction", "planned_start": "2026-01-12", "planned_finish": "2026-02-21", "status": "Completed", "shifted": true}, {"id": 21, "activity_name": "Micro-Segmentation Rollout", "phase": "Construction", "planned_start": "2026-02-21", "planned_finish": "2026-06-11", "status": "In Progress", "shifted": true}, {"id": 22, "activity_name": "SIEM & SOC Integration", "phase": "Commissioning", "planned_start": "2026-06-11", "planned_finish": "2026-09-29", "status": "Not Started", "shifted": true}]}', '2026-03-04 10:19:09.32595+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (54, 19, 'Schedule', '{"milestone_id": 8, "phase": "", "delay_days": 14}', '{"project_name": "AWS Cloud Migration", "original_end_date": "2026-06-27", "simulated_end_date": "2026-06-27", "total_delay_days": 14, "critical_milestone_impacted": false, "project_status_before": "At Risk", "project_status_after": "At Risk", "before_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-09-20", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-09", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-04-28", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-07", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-09-20", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10, "new_delay_days": 10, "shifted": false}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-23", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10, "new_delay_days": 0, "shifted": true}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-04-28", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-07", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-02", "planned_finish": "2025-08-11", "status": "Completed"}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-11", "planned_finish": "2025-09-20", "status": "Completed"}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-09-20", "planned_finish": "2025-12-09", "status": "Completed"}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-02-17", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}], "after_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-02", "planned_finish": "2025-08-11", "status": "Completed", "shifted": false}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-11", "planned_finish": "2025-09-20", "status": "Completed", "shifted": false}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-09-20", "planned_finish": "2025-12-09", "status": "Completed", "shifted": false}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-02-17", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}]}', '2026-03-04 10:19:21.257208+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (55, 20, 'Schedule', '{"milestone_id": 1, "phase": "", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-12-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed", "shifted": false}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed", "shifted": false}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-04 11:02:05.584054+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (56, 21, 'Schedule', '{"milestone_id": 8, "phase": "", "delay_days": 14}', '{"project_name": "AWS Cloud Migration", "original_end_date": "2026-06-27", "simulated_end_date": "2026-06-27", "total_delay_days": 14, "critical_milestone_impacted": false, "project_status_before": "At Risk", "project_status_after": "At Risk", "before_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-09-20", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-09", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-04-28", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-07", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-09-20", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10, "new_delay_days": 10, "shifted": false}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-23", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10, "new_delay_days": 0, "shifted": true}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-04-28", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-07", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-02", "planned_finish": "2025-08-11", "status": "Completed"}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-11", "planned_finish": "2025-09-20", "status": "Completed"}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-09-20", "planned_finish": "2025-12-09", "status": "Completed"}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-02-17", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}], "after_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-02", "planned_finish": "2025-08-11", "status": "Completed", "shifted": false}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-11", "planned_finish": "2025-09-20", "status": "Completed", "shifted": false}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-09-20", "planned_finish": "2025-12-09", "status": "Completed", "shifted": false}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-02-17", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}]}', '2026-03-04 11:03:20.408184+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (59, 23, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "ERP System Migration", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 4200000.0, "current_actual_cost": 2360000.0, "forecast_cost": 2479000.0, "budget_variance": 1721000.0, "cost_increase_pct": 5.04, "before_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 380000.0, "variance": 40000.0}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 610000.0, "variance": 20000.0}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 620000.0, "variance": 220000.0}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 700000.0, "variance": 560000.0}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 50000.0, "variance": 580000.0}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0}], "after_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 399161.02, "variance": 20838.98, "cost_added": 19161.02}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 640758.47, "variance": -10758.47, "cost_added": 30758.47}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 651262.71, "variance": 188737.29, "cost_added": 31262.71}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 735296.61, "variance": 524703.39, "cost_added": 35296.61}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 52521.19, "variance": 577478.81, "cost_added": 2521.19}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0, "cost_added": 0.0}]}', '2026-03-04 11:03:49.971314+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (57, 21, 'Schedule', '{"milestone_id": 9, "phase": "", "delay_days": 14}', '{"project_name": "AWS Cloud Migration", "original_end_date": "2026-06-27", "simulated_end_date": "2026-06-27", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "At Risk", "project_status_after": "At Risk", "before_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-09-20", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-09", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-04-28", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-07", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 7, "name": "Landing Zone Ready", "phase": "Design", "planned_date": "2025-09-20", "actual_date": "2025-09-30", "is_critical": true, "status": "Delayed", "delay_days": 10, "new_delay_days": 10, "shifted": false}, {"id": 8, "name": "Wave 1 Complete", "phase": "Construction", "planned_date": "2025-12-09", "actual_date": "2025-12-19", "is_critical": false, "status": "Delayed", "delay_days": 10, "new_delay_days": 10, "shifted": false}, {"id": 9, "name": "All Apps Migrated", "phase": "Commissioning", "planned_date": "2026-05-12", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 10, "name": "On-Prem Decommissioned", "phase": "Commissioning", "planned_date": "2026-06-07", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-02", "planned_finish": "2025-08-11", "status": "Completed"}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-11", "planned_finish": "2025-09-20", "status": "Completed"}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-09-20", "planned_finish": "2025-12-09", "status": "Completed"}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-02-17", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}], "after_activities": [{"id": 13, "activity_name": "Application Portfolio Assessment", "phase": "Design", "planned_start": "2025-07-02", "planned_finish": "2025-08-11", "status": "Completed", "shifted": false}, {"id": 14, "activity_name": "AWS Landing Zone & VPC Setup", "phase": "Design", "planned_start": "2025-08-11", "planned_finish": "2025-09-20", "status": "Completed", "shifted": false}, {"id": 15, "activity_name": "Wave 1 Migration (30 apps)", "phase": "Construction", "planned_start": "2025-09-20", "planned_finish": "2025-12-09", "status": "Completed", "shifted": false}, {"id": 16, "activity_name": "Wave 2 Migration (35 apps)", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 17, "activity_name": "Wave 3 Migration (20 apps)", "phase": "Construction", "planned_start": "2026-02-17", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 18, "activity_name": "Decommission On-Prem Servers", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}]}', '2026-03-04 11:03:26.212573+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (58, 22, 'Schedule', '{"milestone_id": 13, "phase": "", "delay_days": 14}', '{"project_name": "Kubernetes Platform Build", "original_end_date": "2026-05-28", "simulated_end_date": "2026-05-28", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 13, "name": "Platform GA", "phase": "Construction", "planned_date": "2026-03-09", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 13, "name": "Platform GA", "phase": "Construction", "planned_date": "2026-03-23", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 23, "activity_name": "AKS Cluster Provisioning", "phase": "Design", "planned_start": "2025-09-30", "planned_finish": "2025-10-30", "status": "Completed"}, {"id": 24, "activity_name": "Istio Service Mesh Setup", "phase": "Construction", "planned_start": "2025-10-30", "planned_finish": "2025-12-09", "status": "Completed"}, {"id": 25, "activity_name": "GitOps with ArgoCD", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-01-18", "status": "Completed"}, {"id": 26, "activity_name": "Observability Stack (Prometheus/Grafana)", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-03-09", "status": "In Progress"}, {"id": 27, "activity_name": "Workload Onboarding (15 services)", "phase": "Commissioning", "planned_start": "2026-03-09", "planned_finish": "2026-05-28", "status": "Not Started"}], "after_activities": [{"id": 23, "activity_name": "AKS Cluster Provisioning", "phase": "Design", "planned_start": "2025-09-30", "planned_finish": "2025-10-30", "status": "Completed", "shifted": false}, {"id": 24, "activity_name": "Istio Service Mesh Setup", "phase": "Construction", "planned_start": "2025-10-30", "planned_finish": "2025-12-09", "status": "Completed", "shifted": false}, {"id": 25, "activity_name": "GitOps with ArgoCD", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-01-18", "status": "Completed", "shifted": false}, {"id": 26, "activity_name": "Observability Stack (Prometheus/Grafana)", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-03-09", "status": "In Progress", "shifted": false}, {"id": 27, "activity_name": "Workload Onboarding (15 services)", "phase": "Commissioning", "planned_start": "2026-03-09", "planned_finish": "2026-05-28", "status": "Not Started", "shifted": false}]}', '2026-03-04 11:03:38.110636+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (60, 24, 'Schedule', '{"milestone_id": "", "phase": "", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-09-09", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-20", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-11-13", "planned_finish": "2025-12-13", "status": "Completed", "shifted": true}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-12-13", "planned_finish": "2026-02-11", "status": "Completed", "shifted": true}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2026-01-02", "planned_finish": "2026-03-03", "status": "Delayed", "shifted": true}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-02-11", "planned_finish": "2026-04-12", "status": "In Progress", "shifted": true}]}', '2026-03-04 11:14:05.850969+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (61, 25, 'Schedule', '{"milestone_id": 2, "phase": "", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 5, "shifted": false}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed", "shifted": false}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed", "shifted": false}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed", "shifted": false}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress", "shifted": false}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started", "shifted": false}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started", "shifted": false}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started", "shifted": false}]}', '2026-03-04 11:23:01.021109+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (62, 26, 'Schedule', '{"milestone_id": 5, "phase": "", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-04 11:24:47.300136+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (63, 27, 'Schedule', '{"milestone_id": 19, "phase": "", "delay_days": 14}', '{"project_name": "DevOps CI/CD Transformation", "original_end_date": "2026-05-08", "simulated_end_date": "2026-05-08", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Completed", "project_status_after": "At Risk", "before_milestones": [{"id": 19, "name": "All Teams Onboarded", "phase": "Commissioning", "planned_date": "2026-03-19", "actual_date": "2026-02-25", "is_critical": true, "status": "Completed", "delay_days": 0}], "after_milestones": [{"id": 19, "name": "All Teams Onboarded", "phase": "Commissioning", "planned_date": "2026-04-02", "actual_date": "2026-02-25", "is_critical": true, "status": "Completed", "delay_days": 0, "new_delay_days": 0, "shifted": true}], "before_activities": [{"id": 43, "activity_name": "GitHub Actions Pipeline Templates", "phase": "Design", "planned_start": "2025-11-09", "planned_finish": "2025-12-09", "status": "Completed"}, {"id": 44, "activity_name": "Terraform Module Library", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-01-18", "status": "Completed"}, {"id": 45, "activity_name": "ArgoCD Deployment & Vault Setup", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-02-17", "status": "Completed"}, {"id": 46, "activity_name": "Team Onboarding & Documentation", "phase": "Commissioning", "planned_start": "2026-02-17", "planned_finish": "2026-03-19", "status": "Completed"}], "after_activities": [{"id": 43, "activity_name": "GitHub Actions Pipeline Templates", "phase": "Design", "planned_start": "2025-11-09", "planned_finish": "2025-12-09", "status": "Completed", "shifted": false}, {"id": 44, "activity_name": "Terraform Module Library", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-01-18", "status": "Completed", "shifted": false}, {"id": 45, "activity_name": "ArgoCD Deployment & Vault Setup", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-02-17", "status": "Completed", "shifted": false}, {"id": 46, "activity_name": "Team Onboarding & Documentation", "phase": "Commissioning", "planned_start": "2026-02-17", "planned_finish": "2026-03-19", "status": "Completed", "shifted": false}]}', '2026-03-04 11:24:54.856679+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (64, 28, 'Schedule', '{"milestone_id": 5, "phase": "", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-04 11:25:04.936114+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (65, 29, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "ERP System Migration", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 4200000.0, "current_actual_cost": 2360000.0, "forecast_cost": 2479000.0, "budget_variance": 1721000.0, "cost_increase_pct": 5.04, "before_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 380000.0, "variance": 40000.0}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 610000.0, "variance": 20000.0}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 620000.0, "variance": 220000.0}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 700000.0, "variance": 560000.0}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 50000.0, "variance": 580000.0}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0}], "after_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 399161.02, "variance": 20838.98, "cost_added": 19161.02}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 640758.47, "variance": -10758.47, "cost_added": 30758.47}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 651262.71, "variance": 188737.29, "cost_added": 31262.71}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 735296.61, "variance": 524703.39, "cost_added": 35296.61}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 52521.19, "variance": 577478.81, "cost_added": 2521.19}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0, "cost_added": 0.0}]}', '2026-03-04 11:28:57.032039+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (66, 30, 'Schedule', '{"milestone_id": "", "phase": "", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-09-09", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-20", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-11-13", "planned_finish": "2025-12-13", "status": "Completed", "shifted": true}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-12-13", "planned_finish": "2026-02-11", "status": "Completed", "shifted": true}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2026-01-02", "planned_finish": "2026-03-03", "status": "Delayed", "shifted": true}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-02-11", "planned_finish": "2026-04-12", "status": "In Progress", "shifted": true}]}', '2026-03-04 11:34:19.663447+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (67, 30, 'Schedule', '{"milestone_id": 6, "phase": "", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-20", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-04 11:34:30.364294+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (68, 30, 'Schedule', '{"milestone_id": 6, "phase": "", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0, "new_delay_days": 0, "shifted": false}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-20", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-04 11:34:32.292776+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (69, 30, 'Schedule', '{"milestone_id": "", "phase": "Construction", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-08-26", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-20", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed", "shifted": false}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed", "shifted": false}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed", "shifted": false}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress", "shifted": false}]}', '2026-03-04 11:34:35.675421+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (72, 32, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "ERP System Migration", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 4200000.0, "current_actual_cost": 2360000.0, "forecast_cost": 2479000.0, "budget_variance": 1721000.0, "cost_increase_pct": 5.04, "before_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 380000.0, "variance": 40000.0}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 610000.0, "variance": 20000.0}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 620000.0, "variance": 220000.0}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 700000.0, "variance": 560000.0}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 50000.0, "variance": 580000.0}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0}], "after_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 399161.02, "variance": 20838.98, "cost_added": 19161.02}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 640758.47, "variance": -10758.47, "cost_added": 30758.47}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 651262.71, "variance": 188737.29, "cost_added": 31262.71}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 735296.61, "variance": 524703.39, "cost_added": 35296.61}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 52521.19, "variance": 577478.81, "cost_added": 2521.19}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0, "cost_added": 0.0}]}', '2026-03-04 11:36:04.593194+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (70, 31, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-02-22", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-12-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-09-09", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-02-06", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed", "shifted": false}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed", "shifted": false}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-12-03", "planned_finish": "2026-02-01", "status": "Delayed", "shifted": true}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-23", "planned_finish": "2026-03-03", "status": "Delayed", "shifted": true}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-02-01", "planned_finish": "2026-05-12", "status": "In Progress", "shifted": true}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-05-12", "planned_finish": "2026-07-11", "status": "Not Started", "shifted": true}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-07-11", "planned_finish": "2026-09-09", "status": "Not Started", "shifted": true}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-09-09", "planned_finish": "2026-11-08", "status": "Not Started", "shifted": true}]}', '2026-03-04 11:34:45.169553+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (71, 31, 'Schedule', '{"milestone_id": "", "phase": "Design", "delay_days": 45}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-03-09", "total_delay_days": 45, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2026-01-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-04-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 45, "shifted": true}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-10-10", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 45, "shifted": true}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-03-09", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 45, "shifted": true}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed", "shifted": false}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed", "shifted": false}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2026-01-03", "planned_finish": "2026-03-04", "status": "Delayed", "shifted": true}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2026-01-23", "planned_finish": "2026-04-03", "status": "Delayed", "shifted": true}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-03-04", "planned_finish": "2026-06-12", "status": "In Progress", "shifted": true}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-06-12", "planned_finish": "2026-08-11", "status": "Not Started", "shifted": true}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-08-11", "planned_finish": "2026-10-10", "status": "Not Started", "shifted": true}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-10-10", "planned_finish": "2026-12-09", "status": "Not Started", "shifted": true}]}', '2026-03-04 11:34:55.400771+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (73, 33, 'Schedule', '{"milestone_id": "", "phase": "", "delay_days": 14}', '{"project_name": "HR Portal & Employee Self-Service", "original_end_date": "2026-08-26", "simulated_end_date": "2026-09-09", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-06", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 5, "name": "MVP Launch", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 6, "name": "Full Rollout", "phase": "Commissioning", "planned_date": "2026-08-20", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-10-30", "planned_finish": "2025-11-29", "status": "Completed"}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-11-29", "planned_finish": "2026-01-28", "status": "Completed"}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2025-12-19", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-01-28", "planned_finish": "2026-03-29", "status": "In Progress"}], "after_activities": [{"id": 9, "activity_name": "UI/UX Wireframing", "phase": "Design", "planned_start": "2025-11-13", "planned_finish": "2025-12-13", "status": "Completed", "shifted": true}, {"id": 10, "activity_name": "Backend API Development", "phase": "Construction", "planned_start": "2025-12-13", "planned_finish": "2026-02-11", "status": "Completed", "shifted": true}, {"id": 11, "activity_name": "React Frontend Build", "phase": "Construction", "planned_start": "2026-01-02", "planned_finish": "2026-03-03", "status": "Delayed", "shifted": true}, {"id": 12, "activity_name": "Payroll Integration", "phase": "Construction", "planned_start": "2026-02-11", "planned_finish": "2026-04-12", "status": "In Progress", "shifted": true}]}', '2026-03-04 11:43:45.785485+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (74, 34, 'Schedule', '{"milestone_id": "", "phase": "", "delay_days": 14}', '{"project_name": "ERP System Migration", "original_end_date": "2027-02-22", "simulated_end_date": "2027-03-08", "total_delay_days": 14, "critical_milestone_impacted": true, "project_status_before": "Active", "project_status_after": "At Risk", "before_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-11-19", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-02-17", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-08-26", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-01-23", "actual_date": null, "is_critical": true, "status": "Pending", "delay_days": 0}], "after_milestones": [{"id": 1, "name": "Design Sign-Off", "phase": "Design", "planned_date": "2025-12-03", "actual_date": "2025-11-24", "is_critical": true, "status": "Delayed", "delay_days": 5, "new_delay_days": 0, "shifted": true}, {"id": 2, "name": "Data Migration Complete", "phase": "Construction", "planned_date": "2026-03-03", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 3, "name": "UAT Sign-Off", "phase": "Commissioning", "planned_date": "2026-09-09", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}, {"id": 4, "name": "Go-Live", "phase": "Commissioning", "planned_date": "2027-02-06", "actual_date": null, "is_critical": true, "status": "Delayed", "delay_days": 0, "new_delay_days": 14, "shifted": true}], "before_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-08-31", "planned_finish": "2025-10-10", "status": "Completed"}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-10", "planned_finish": "2025-11-19", "status": "Completed"}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-11-19", "planned_finish": "2026-01-18", "status": "Delayed"}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-09", "planned_finish": "2026-02-17", "status": "Delayed"}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-01-18", "planned_finish": "2026-04-28", "status": "In Progress"}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-04-28", "planned_finish": "2026-06-27", "status": "Not Started"}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-06-27", "planned_finish": "2026-08-26", "status": "Not Started"}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-08-26", "planned_finish": "2026-10-25", "status": "Not Started"}], "after_activities": [{"id": 1, "activity_name": "Business Process Mapping", "phase": "Design", "planned_start": "2025-09-14", "planned_finish": "2025-10-24", "status": "Completed", "shifted": true}, {"id": 2, "activity_name": "Gap Analysis & Fit Study", "phase": "Design", "planned_start": "2025-10-24", "planned_finish": "2025-12-03", "status": "Completed", "shifted": true}, {"id": 3, "activity_name": "Data Cleansing & Extraction", "phase": "Construction", "planned_start": "2025-12-03", "planned_finish": "2026-02-01", "status": "Delayed", "shifted": true}, {"id": 4, "activity_name": "S/4HANA Configuration", "phase": "Construction", "planned_start": "2025-12-23", "planned_finish": "2026-03-03", "status": "Delayed", "shifted": true}, {"id": 5, "activity_name": "Custom Report Development", "phase": "Construction", "planned_start": "2026-02-01", "planned_finish": "2026-05-12", "status": "In Progress", "shifted": true}, {"id": 6, "activity_name": "Integration Testing", "phase": "Commissioning", "planned_start": "2026-05-12", "planned_finish": "2026-07-11", "status": "Not Started", "shifted": true}, {"id": 7, "activity_name": "User Acceptance Testing", "phase": "Commissioning", "planned_start": "2026-07-11", "planned_finish": "2026-09-09", "status": "Not Started", "shifted": true}, {"id": 8, "activity_name": "Go-Live & Hypercare", "phase": "Commissioning", "planned_start": "2026-09-09", "planned_finish": "2026-11-08", "status": "Not Started", "shifted": true}]}', '2026-03-04 11:57:14.344499+00');
INSERT INTO public.simulation_scenarios (id, simulation_session_id, type, input_parameters, output_results, created_at) VALUES (75, 34, 'Cost', '{"time_impact_days": 14, "daily_overhead_cost": 8500, "escalation_pct": 0}', '{"project_name": "ERP System Migration", "time_impact_days": 14, "daily_overhead_cost": 8500.0, "escalation_pct": 0.0, "cost_impact": 119000.0, "escalation_amount": 0.0, "total_cost_impact": 119000.0, "total_budget": 4200000.0, "current_actual_cost": 2360000.0, "forecast_cost": 2479000.0, "budget_variance": 1721000.0, "cost_increase_pct": 5.04, "before_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 380000.0, "variance": 40000.0}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 610000.0, "variance": 20000.0}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 620000.0, "variance": 220000.0}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 700000.0, "variance": 560000.0}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 50000.0, "variance": 580000.0}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0}], "after_cbs": [{"id": 1, "wbs_code": "1.0", "description": "Project Management & PMO", "budget_cost": 420000.0, "actual_cost": 399161.02, "variance": 20838.98, "cost_added": 19161.02}, {"id": 2, "wbs_code": "2.0", "description": "Requirements & Design", "budget_cost": 630000.0, "actual_cost": 640758.47, "variance": -10758.47, "cost_added": 30758.47}, {"id": 3, "wbs_code": "3.0", "description": "Data Migration", "budget_cost": 840000.0, "actual_cost": 651262.71, "variance": 188737.29, "cost_added": 31262.71}, {"id": 4, "wbs_code": "4.0", "description": "Development & Config", "budget_cost": 1260000.0, "actual_cost": 735296.61, "variance": 524703.39, "cost_added": 35296.61}, {"id": 5, "wbs_code": "5.0", "description": "Testing & QA", "budget_cost": 630000.0, "actual_cost": 52521.19, "variance": 577478.81, "cost_added": 2521.19}, {"id": 6, "wbs_code": "6.0", "description": "Training & Go-Live", "budget_cost": 420000.0, "actual_cost": 0.0, "variance": 420000.0, "cost_added": 0.0}]}', '2026-03-04 11:57:18.537393+00');


--
-- Data for Name: simulation_sessions; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (1, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-02-27 11:40:31.687765+00', '2026-02-27 11:40:31.687765+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (2, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-02 07:50:30.720904+00', '2026-03-02 07:50:30.720904+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (3, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-02 10:45:28.41115+00', '2026-03-02 10:45:28.41115+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (4, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-02 13:10:17.340235+00', '2026-03-02 13:10:17.340235+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (5, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-03 09:44:53.152071+00', '2026-03-03 09:44:53.152071+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (6, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-03 11:09:57.614198+00', '2026-03-03 11:09:57.614198+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (7, 3, 1, 'Sim — AWS Cloud Migration', 'Draft', '2026-03-03 11:11:22.499239+00', '2026-03-03 11:11:22.499239+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (8, 2, 1, 'Sim — HR Portal & Employee Self-Service', 'Draft', '2026-03-03 12:07:36.726681+00', '2026-03-03 12:07:36.726681+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (9, 2, 1, 'Sim — HR Portal & Employee Self-Service', 'Draft', '2026-03-03 12:40:55.91099+00', '2026-03-03 12:40:55.91099+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (10, 3, 1, 'Sim — AWS Cloud Migration', 'Draft', '2026-03-03 13:07:54.109787+00', '2026-03-03 13:07:54.109787+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (11, 2, 1, 'Sim — HR Portal & Employee Self-Service', 'Draft', '2026-03-03 13:08:17.192397+00', '2026-03-03 13:08:17.192397+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (12, 3, 1, 'Sim — AWS Cloud Migration', 'Draft', '2026-03-03 13:17:18.047221+00', '2026-03-03 13:17:18.047221+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (13, 2, 1, 'Sim — HR Portal & Employee Self-Service', 'Draft', '2026-03-03 18:22:57.572036+00', '2026-03-03 18:22:57.572036+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (14, 5, 1, 'Sim — Kubernetes Platform Build', 'Draft', '2026-03-03 18:23:37.819678+00', '2026-03-03 18:23:37.819678+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (15, 2, 1, 'Sim — HR Portal & Employee Self-Service', 'Draft', '2026-03-03 18:32:04.911911+00', '2026-03-03 18:32:04.911911+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (16, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-04 07:42:16.715683+00', '2026-03-04 07:42:16.715683+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (17, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-04 08:23:19.192342+00', '2026-03-04 08:23:19.192342+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (18, 4, 1, 'Sim — Zero Trust Network Security', 'Draft', '2026-03-04 10:19:09.286095+00', '2026-03-04 10:19:09.286095+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (19, 3, 1, 'Sim — AWS Cloud Migration', 'Draft', '2026-03-04 10:19:21.223063+00', '2026-03-04 10:19:21.223063+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (20, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-04 11:02:05.549967+00', '2026-03-04 11:02:05.549967+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (21, 3, 1, 'Sim — AWS Cloud Migration', 'Draft', '2026-03-04 11:03:20.388406+00', '2026-03-04 11:03:20.388406+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (22, 5, 1, 'Sim — Kubernetes Platform Build', 'Draft', '2026-03-04 11:03:38.090861+00', '2026-03-04 11:03:38.090861+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (23, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-04 11:03:49.940173+00', '2026-03-04 11:03:49.940173+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (24, 2, 1, 'Sim — HR Portal & Employee Self-Service', 'Draft', '2026-03-04 11:14:05.8107+00', '2026-03-04 11:14:05.8107+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (25, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-04 11:23:00.970719+00', '2026-03-04 11:23:00.970719+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (26, 2, 1, 'Sim — HR Portal & Employee Self-Service', 'Draft', '2026-03-04 11:24:47.263892+00', '2026-03-04 11:24:47.263892+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (27, 10, 1, 'Sim — DevOps CI/CD Transformation', 'Draft', '2026-03-04 11:24:54.839313+00', '2026-03-04 11:24:54.839313+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (28, 2, 1, 'Sim — HR Portal & Employee Self-Service', 'Draft', '2026-03-04 11:25:04.911263+00', '2026-03-04 11:25:04.911263+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (29, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-04 11:28:57.00809+00', '2026-03-04 11:28:57.00809+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (30, 2, 1, 'Sim — HR Portal & Employee Self-Service', 'Draft', '2026-03-04 11:34:19.63162+00', '2026-03-04 11:34:19.63162+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (31, 1, 1, 'Sim — ERP System Migration', 'Discarded', '2026-03-04 11:34:45.151552+00', '2026-03-04 11:35:32.659592+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (32, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-04 11:36:04.579151+00', '2026-03-04 11:36:04.579151+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (33, 2, 1, 'Sim — HR Portal & Employee Self-Service', 'Discarded', '2026-03-04 11:43:45.752017+00', '2026-03-04 11:43:46.990213+00');
INSERT INTO public.simulation_sessions (id, project_id, created_by, name, status, created_at, updated_at) VALUES (34, 1, 1, 'Sim — ERP System Migration', 'Draft', '2026-03-04 11:57:14.313366+00', '2026-03-04 11:57:14.313366+00');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.users (id, email, full_name, hashed_password, role, is_active, created_at, updated_at) VALUES (1, 'pm@pmhub.com', 'Alex Johnson', '$2b$12$oqgHe3GJHhLkFgDpc5vLxuUvZncSLyaS1lXdQc3r0MCnU5sRtdJ.i', 'project_manager', true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.users (id, email, full_name, hashed_password, role, is_active, created_at, updated_at) VALUES (2, 'cm@pmhub.com', 'Sarah Williams', '$2b$12$zzGllONQ6Cs5HJJX0/yO2.5ZkPZOxrLnxszMnCmSeIfI8Begbvs1W', 'commercial_manager', true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.users (id, email, full_name, hashed_password, role, is_active, created_at, updated_at) VALUES (3, 'hse@pmhub.com', 'Mike Chen', '$2b$12$NAdlYOVPosCrgpmq8LSzzu93ASRRUntWkfUm7yScPUYsEoyIiMXWK', 'hse_officer', true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.users (id, email, full_name, hashed_password, role, is_active, created_at, updated_at) VALUES (4, 'admin@pmhub.com', 'Admin User', '$2b$12$R9AtuL0010IeMfAzQXVs.e0rOYnU0ylNUXhiYr4MX/hUHmn.42Q/m', 'admin', true, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Data for Name: wbs_items; Type: TABLE DATA; Schema: public; Owner: pmhub
--

INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (1, 1, NULL, '1.0', 'Project Management & Governance', 1, 1, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (2, 1, NULL, '2.0', 'Requirements & Design', 1, 2, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (3, 1, NULL, '3.0', 'Data Migration', 1, 3, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (4, 1, NULL, '4.0', 'Development & Configuration', 1, 4, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (5, 1, NULL, '5.0', 'Testing & QA', 1, 5, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (6, 1, NULL, '6.0', 'Training & Go-Live', 1, 6, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (7, 3, NULL, '1.0', 'Discovery & Assessment', 1, 1, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (8, 3, NULL, '2.0', 'Landing Zone Setup', 1, 2, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (9, 3, NULL, '3.0', 'Application Migration', 1, 3, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (10, 3, NULL, '4.0', 'Optimization & Handover', 1, 4, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (11, 6, NULL, '1.0', 'UX Research & Design', 1, 1, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (12, 6, NULL, '2.0', 'Core Banking API', 1, 2, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (13, 6, NULL, '3.0', 'Mobile App Development', 1, 3, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (14, 6, NULL, '4.0', 'Security & Compliance', 1, 4, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');
INSERT INTO public.wbs_items (id, project_id, parent_id, code, name, level, sort_order, created_at, updated_at) VALUES (15, 6, NULL, '5.0', 'UAT & Launch', 1, 5, '2026-02-27 11:34:51.918979+00', '2026-02-27 11:34:51.918979+00');


--
-- Name: approved_variations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.approved_variations_id_seq', 7, true);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 1, true);


--
-- Name: cbs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.cbs_id_seq', 22, true);


--
-- Name: compensation_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.compensation_events_id_seq', 5, true);


--
-- Name: documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.documents_id_seq', 14, true);


--
-- Name: hse_checklist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.hse_checklist_id_seq', 12, true);


--
-- Name: issue_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.issue_log_id_seq', 10, true);


--
-- Name: milestone_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.milestone_payments_id_seq', 7, true);


--
-- Name: milestones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.milestones_id_seq', 19, true);


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.organizations_id_seq', 2, true);


--
-- Name: programmes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.programmes_id_seq', 3, true);


--
-- Name: project_activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.project_activities_id_seq', 46, true);


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.projects_id_seq', 10, true);


--
-- Name: risk_register_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.risk_register_id_seq', 12, true);


--
-- Name: safety_incidents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.safety_incidents_id_seq', 7, true);


--
-- Name: simulation_scenarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.simulation_scenarios_id_seq', 75, true);


--
-- Name: simulation_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.simulation_sessions_id_seq', 34, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- Name: wbs_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pmhub
--

SELECT pg_catalog.setval('public.wbs_items_id_seq', 15, true);


--
-- Name: approved_variations approved_variations_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.approved_variations
    ADD CONSTRAINT approved_variations_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: cbs cbs_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.cbs
    ADD CONSTRAINT cbs_pkey PRIMARY KEY (id);


--
-- Name: compensation_events compensation_events_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.compensation_events
    ADD CONSTRAINT compensation_events_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: hse_checklist hse_checklist_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.hse_checklist
    ADD CONSTRAINT hse_checklist_pkey PRIMARY KEY (id);


--
-- Name: issue_log issue_log_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.issue_log
    ADD CONSTRAINT issue_log_pkey PRIMARY KEY (id);


--
-- Name: milestone_payments milestone_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.milestone_payments
    ADD CONSTRAINT milestone_payments_pkey PRIMARY KEY (id);


--
-- Name: milestones milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.milestones
    ADD CONSTRAINT milestones_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_code_key; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_code_key UNIQUE (code);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: programmes programmes_code_key; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.programmes
    ADD CONSTRAINT programmes_code_key UNIQUE (code);


--
-- Name: programmes programmes_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.programmes
    ADD CONSTRAINT programmes_pkey PRIMARY KEY (id);


--
-- Name: project_activities project_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.project_activities
    ADD CONSTRAINT project_activities_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: risk_register risk_register_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.risk_register
    ADD CONSTRAINT risk_register_pkey PRIMARY KEY (id);


--
-- Name: safety_incidents safety_incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.safety_incidents
    ADD CONSTRAINT safety_incidents_pkey PRIMARY KEY (id);


--
-- Name: simulation_scenarios simulation_scenarios_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.simulation_scenarios
    ADD CONSTRAINT simulation_scenarios_pkey PRIMARY KEY (id);


--
-- Name: simulation_sessions simulation_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.simulation_sessions
    ADD CONSTRAINT simulation_sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wbs_items wbs_items_pkey; Type: CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.wbs_items
    ADD CONSTRAINT wbs_items_pkey PRIMARY KEY (id);


--
-- Name: ix_approved_variations_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_approved_variations_id ON public.approved_variations USING btree (id);


--
-- Name: ix_audit_logs_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_audit_logs_id ON public.audit_logs USING btree (id);


--
-- Name: ix_cbs_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_cbs_id ON public.cbs USING btree (id);


--
-- Name: ix_compensation_events_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_compensation_events_id ON public.compensation_events USING btree (id);


--
-- Name: ix_documents_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_documents_id ON public.documents USING btree (id);


--
-- Name: ix_hse_checklist_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_hse_checklist_id ON public.hse_checklist USING btree (id);


--
-- Name: ix_issue_log_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_issue_log_id ON public.issue_log USING btree (id);


--
-- Name: ix_milestone_payments_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_milestone_payments_id ON public.milestone_payments USING btree (id);


--
-- Name: ix_milestones_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_milestones_id ON public.milestones USING btree (id);


--
-- Name: ix_organizations_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_organizations_id ON public.organizations USING btree (id);


--
-- Name: ix_programmes_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_programmes_id ON public.programmes USING btree (id);


--
-- Name: ix_project_activities_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_project_activities_id ON public.project_activities USING btree (id);


--
-- Name: ix_projects_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_projects_id ON public.projects USING btree (id);


--
-- Name: ix_risk_register_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_risk_register_id ON public.risk_register USING btree (id);


--
-- Name: ix_safety_incidents_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_safety_incidents_id ON public.safety_incidents USING btree (id);


--
-- Name: ix_simulation_scenarios_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_simulation_scenarios_id ON public.simulation_scenarios USING btree (id);


--
-- Name: ix_simulation_sessions_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_simulation_sessions_id ON public.simulation_sessions USING btree (id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_wbs_items_id; Type: INDEX; Schema: public; Owner: pmhub
--

CREATE INDEX ix_wbs_items_id ON public.wbs_items USING btree (id);


--
-- Name: approved_variations approved_variations_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.approved_variations
    ADD CONSTRAINT approved_variations_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: cbs cbs_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.cbs
    ADD CONSTRAINT cbs_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: compensation_events compensation_events_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.compensation_events
    ADD CONSTRAINT compensation_events_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: documents documents_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: hse_checklist hse_checklist_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.hse_checklist
    ADD CONSTRAINT hse_checklist_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: issue_log issue_log_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.issue_log
    ADD CONSTRAINT issue_log_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: milestone_payments milestone_payments_milestone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.milestone_payments
    ADD CONSTRAINT milestone_payments_milestone_id_fkey FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE CASCADE;


--
-- Name: milestones milestones_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.milestones
    ADD CONSTRAINT milestones_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: programmes programmes_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.programmes
    ADD CONSTRAINT programmes_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: project_activities project_activities_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.project_activities
    ADD CONSTRAINT project_activities_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_activities project_activities_wbs_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.project_activities
    ADD CONSTRAINT project_activities_wbs_id_fkey FOREIGN KEY (wbs_id) REFERENCES public.wbs_items(id) ON DELETE SET NULL;


--
-- Name: projects projects_programme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_programme_id_fkey FOREIGN KEY (programme_id) REFERENCES public.programmes(id) ON DELETE SET NULL;


--
-- Name: risk_register risk_register_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.risk_register
    ADD CONSTRAINT risk_register_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: safety_incidents safety_incidents_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.safety_incidents
    ADD CONSTRAINT safety_incidents_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: simulation_scenarios simulation_scenarios_simulation_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.simulation_scenarios
    ADD CONSTRAINT simulation_scenarios_simulation_session_id_fkey FOREIGN KEY (simulation_session_id) REFERENCES public.simulation_sessions(id) ON DELETE CASCADE;


--
-- Name: simulation_sessions simulation_sessions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.simulation_sessions
    ADD CONSTRAINT simulation_sessions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: simulation_sessions simulation_sessions_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.simulation_sessions
    ADD CONSTRAINT simulation_sessions_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: wbs_items wbs_items_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.wbs_items
    ADD CONSTRAINT wbs_items_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.wbs_items(id) ON DELETE CASCADE;


--
-- Name: wbs_items wbs_items_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pmhub
--

ALTER TABLE ONLY public.wbs_items
    ADD CONSTRAINT wbs_items_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict MHmxGUcJif2uabdADB0VQdSSWV9t94iYE0ceXxSuiDbYaSUiq7EOW6QkHPXc3KZ

