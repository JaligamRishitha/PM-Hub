-- PM Hub Database Schema
-- PostgreSQL 16+
-- Enterprise Project Management Intelligence Platform

-- ============================================================
-- CORE: Users & Authentication
-- ============================================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'project_manager',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- PORTFOLIO: Organization → Programme → Project
-- ============================================================
CREATE TABLE organizations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE programmes (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'Active',
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    programme_id INTEGER REFERENCES programmes(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50),
    client VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    contract_completion_date DATE,
    actual_completion_date DATE,
    status VARCHAR(50) DEFAULT 'Active',
    total_budget NUMERIC(15, 2) DEFAULT 0,
    contract_value NUMERIC(15, 2) DEFAULT 0,
    forecast_cost NUMERIC(15, 2) DEFAULT 0,
    daily_ld_rate NUMERIC(12, 2) DEFAULT 0,
    ld_cap_pct NUMERIC(5, 2) DEFAULT 10.00,
    location VARCHAR(255),
    project_manager VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- SCHEDULING: WBS → Activities & Milestones
-- ============================================================
CREATE TABLE wbs_items (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    parent_id INTEGER REFERENCES wbs_items(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    level INTEGER DEFAULT 1,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE project_activities (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    wbs_id INTEGER REFERENCES wbs_items(id) ON DELETE SET NULL,
    activity_code VARCHAR(50),
    activity_name VARCHAR(255) NOT NULL,
    phase VARCHAR(50) NOT NULL,
    planned_start DATE NOT NULL,
    planned_finish DATE NOT NULL,
    actual_start DATE,
    actual_finish DATE,
    completion_pct NUMERIC(5, 2) DEFAULT 0,
    is_milestone BOOLEAN DEFAULT FALSE,
    is_critical BOOLEAN DEFAULT FALSE,
    predecessor_ids TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE milestones (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phase VARCHAR(50) NOT NULL,
    planned_date DATE NOT NULL,
    actual_date DATE,
    is_critical BOOLEAN DEFAULT FALSE,
    weight NUMERIC(5, 2) DEFAULT 1.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- COMMERCIAL: Cost Breakdown, Variations, Compensation, Payments
-- ============================================================
CREATE TABLE cbs (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    wbs_code VARCHAR(50) NOT NULL,
    description VARCHAR(500) NOT NULL,
    budget_cost NUMERIC(15, 2) DEFAULT 0,
    actual_cost NUMERIC(15, 2) DEFAULT 0,
    forecast_cost NUMERIC(15, 2) DEFAULT 0,
    approved_variation NUMERIC(15, 2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE approved_variations (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    variation_code VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    value NUMERIC(15, 2) NOT NULL DEFAULT 0,
    cost_impact NUMERIC(15, 2) DEFAULT 0,
    schedule_impact_days INTEGER DEFAULT 0,
    approval_status VARCHAR(50) DEFAULT 'Pending',
    submitted_date DATE,
    approval_date DATE,
    approved_by VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE compensation_events (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    event_name VARCHAR(255) NOT NULL,
    linked_wbs VARCHAR(50),
    time_impact_days INTEGER DEFAULT 0,
    daily_overhead_cost NUMERIC(12, 2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE milestone_payments (
    id SERIAL PRIMARY KEY,
    milestone_id INTEGER NOT NULL REFERENCES milestones(id) ON DELETE CASCADE,
    payment_percentage NUMERIC(5, 2) NOT NULL,
    payment_value NUMERIC(15, 2) NOT NULL,
    invoice_number VARCHAR(100),
    invoice_date DATE,
    payment_status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- RISK & ISSUE MANAGEMENT
-- ============================================================
CREATE TABLE risk_register (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    risk_code VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    probability INTEGER NOT NULL CHECK (probability BETWEEN 1 AND 5),
    impact INTEGER NOT NULL CHECK (impact BETWEEN 1 AND 5),
    risk_score INTEGER GENERATED ALWAYS AS (probability * impact) STORED,
    mitigation_plan TEXT,
    contingency_plan TEXT,
    owner VARCHAR(255),
    status VARCHAR(50) DEFAULT 'Open',
    identified_date DATE DEFAULT CURRENT_DATE,
    review_date DATE,
    cost_exposure NUMERIC(15, 2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE issue_log (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    issue_code VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(50) DEFAULT 'Medium',
    assigned_to VARCHAR(255),
    raised_by VARCHAR(255),
    raised_date DATE DEFAULT CURRENT_DATE,
    due_date DATE,
    resolution_date DATE,
    resolution_notes TEXT,
    status VARCHAR(50) DEFAULT 'Open',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- HEALTH & SAFETY
-- ============================================================
CREATE TABLE safety_incidents (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    incident_type VARCHAR(255) NOT NULL,
    severity VARCHAR(50) NOT NULL,
    reported_date DATE NOT NULL,
    resolved_date DATE,
    status VARCHAR(50) DEFAULT 'Open',
    penalty_cost NUMERIC(12, 2) DEFAULT 0,
    description VARCHAR(1000),
    lost_time_hours NUMERIC(8, 2) DEFAULT 0,
    location VARCHAR(255),
    reported_by VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE hse_checklist (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    checklist_item VARCHAR(500) NOT NULL,
    category VARCHAR(100),
    status VARCHAR(50) DEFAULT 'Pending',
    last_inspection_date DATE,
    inspector VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- DOCUMENTS
-- ============================================================
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    doc_code VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    revision VARCHAR(20) DEFAULT 'A',
    status VARCHAR(50) DEFAULT 'Draft',
    file_path TEXT,
    file_size INTEGER,
    uploaded_by VARCHAR(255),
    upload_date TIMESTAMPTZ DEFAULT NOW(),
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- AUDIT & SIMULATION
-- ============================================================
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id INTEGER,
    details TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE simulation_sessions (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    created_by INTEGER NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL DEFAULT 'Untitled Simulation',
    status VARCHAR(50) DEFAULT 'Draft',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE simulation_scenarios (
    id SERIAL PRIMARY KEY,
    simulation_session_id INTEGER NOT NULL REFERENCES simulation_sessions(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    input_parameters TEXT NOT NULL DEFAULT '{}',
    output_results TEXT NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_programmes_org ON programmes(organization_id);
CREATE INDEX idx_projects_programme ON projects(programme_id);
CREATE INDEX idx_wbs_project ON wbs_items(project_id);
CREATE INDEX idx_wbs_parent ON wbs_items(parent_id);
CREATE INDEX idx_activities_project ON project_activities(project_id);
CREATE INDEX idx_activities_wbs ON project_activities(wbs_id);
CREATE INDEX idx_milestones_project ON milestones(project_id);
CREATE INDEX idx_cbs_project ON cbs(project_id);
CREATE INDEX idx_variations_project ON approved_variations(project_id);
CREATE INDEX idx_ce_project ON compensation_events(project_id);
CREATE INDEX idx_risk_project ON risk_register(project_id);
CREATE INDEX idx_risk_score ON risk_register(risk_score);
CREATE INDEX idx_issue_project ON issue_log(project_id);
CREATE INDEX idx_issue_status ON issue_log(status);
CREATE INDEX idx_safety_project ON safety_incidents(project_id);
CREATE INDEX idx_hse_project ON hse_checklist(project_id);
CREATE INDEX idx_documents_project ON documents(project_id);
CREATE INDEX idx_payments_milestone ON milestone_payments(milestone_id);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_sim_sessions_project ON simulation_sessions(project_id);
CREATE INDEX idx_sim_scenarios_session ON simulation_scenarios(simulation_session_id);
