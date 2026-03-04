# PM Hub - Project Flow Documentation

## Table of Contents

1. [Overview](#1-overview)
2. [Architecture](#2-architecture)
3. [Tech Stack](#3-tech-stack)
4. [Project Structure](#4-project-structure)
5. [Database Schema](#5-database-schema)
6. [Authentication Flow](#6-authentication-flow)
7. [Backend API Flow](#7-backend-api-flow)
8. [Frontend Flow](#8-frontend-flow)
9. [Module Breakdown](#9-module-breakdown)
10. [Business Logic Rules](#10-business-logic-rules)
11. [Simulation Lab Engine](#11-simulation-lab-engine)
12. [Docker Deployment Flow](#12-docker-deployment-flow)
13. [Data Flow Diagrams](#13-data-flow-diagrams)
14. [API Reference](#14-api-reference)

---

## 1. Overview

PM Hub is an enterprise-grade Project Management application designed for managing IT projects end-to-end. It covers project scheduling, cost management, safety compliance, cashflow tracking, and advanced what-if simulation capabilities.

**Key Capabilities:**
- Dashboard with real-time KPI cards and charts
- Project, Activity, and Milestone management with delay tracking
- Commercial management (CBS, Compensation Events, Payments, Liquidated Damages)
- Health & Safety incident reporting and HSE compliance checklists
- Simulation Lab with 5 what-if simulation types
- Role-based access control (Project Manager, Commercial Manager, HSE Officer, Admin)
- Audit logging for all CRUD operations
- Excel export of all project data

---

## 2. Architecture

```
+-------------------+        +-------------------+        +-------------------+
|                   |  HTTP  |                   |  SQL   |                   |
|  React Frontend   +------->+  FastAPI Backend   +------->+  PostgreSQL 16    |
|  (Nginx :80)      |  /api  |  (Uvicorn :8000)  |        |  (Port 5432)      |
|                   <--------+                   <--------+                   |
+-------------------+        +-------------------+        +-------------------+
       Port 8080                   Port 8000                   Port 5432
```

**Request Flow:**
1. User opens browser at `http://localhost:8080`
2. Nginx serves the React SPA (static files)
3. Frontend makes API calls to `/api/*`
4. Nginx reverse-proxies `/api/*` requests to `backend:8000`
5. FastAPI processes the request, queries PostgreSQL via SQLAlchemy
6. Response flows back: PostgreSQL -> FastAPI -> Nginx -> Browser

---

## 3. Tech Stack

### Backend
| Technology | Version | Purpose |
|---|---|---|
| Python | 3.11 | Runtime |
| FastAPI | 0.104.1 | REST API framework |
| Uvicorn | 0.24.0 | ASGI server |
| SQLAlchemy | 2.0.23 | ORM (Object-Relational Mapping) |
| Pydantic | 2.5.2 | Data validation and serialization |
| PostgreSQL | 16 (Alpine) | Relational database |
| psycopg2 | 2.9.9 | PostgreSQL driver |
| python-jose | 3.3.0 | JWT token creation and verification |
| passlib + bcrypt | 1.7.4 / 4.0.1 | Password hashing |
| openpyxl | 3.1.2 | Excel file generation |

### Frontend
| Technology | Version | Purpose |
|---|---|---|
| React | 18.2 | UI framework |
| Vite | 5.0.8 | Build tool and dev server |
| Material UI (MUI) | 5.15 | Component library |
| React Router | 6.21 | Client-side routing |
| Recharts | 2.10.3 | Charts and data visualization |
| Axios | 1.6.2 | HTTP client |
| Day.js | 1.11.10 | Date manipulation |

### DevOps
| Technology | Purpose |
|---|---|
| Docker + Docker Compose | Containerized deployment |
| Nginx (Alpine) | Static file serving + reverse proxy |

---

## 4. Project Structure

```
PM Hub/
|
+-- docker-compose.yml              # Orchestrates 3 services (db, backend, frontend)
+-- .env                             # Root environment variables
+-- .gitignore
+-- database/
|   +-- schema.sql                   # Full PostgreSQL schema (12 tables + indexes)
|
+-- backend/
|   +-- Dockerfile                   # Python 3.11-slim, runs seed then uvicorn
|   +-- requirements.txt             # Python dependencies
|   +-- seed.py                      # Seeds database with IT project demo data
|   +-- .env                         # Backend environment variables
|   +-- app/
|       +-- main.py                  # FastAPI app entry point, CORS, router registration
|       +-- core/
|       |   +-- config.py            # Pydantic Settings (DB URL, JWT secret, etc.)
|       |   +-- database.py          # SQLAlchemy engine, session factory, Base
|       |   +-- security.py          # JWT auth, password hashing, role-based access
|       +-- models/                  # SQLAlchemy ORM models (12 models)
|       |   +-- user.py
|       |   +-- project.py
|       |   +-- activity.py          # Hybrid properties: status, delay_days
|       |   +-- milestone.py         # Hybrid properties: status, delay_days
|       |   +-- milestone_payment.py
|       |   +-- cbs.py               # Hybrid property: variance
|       |   +-- compensation_event.py # Hybrid property: cost_impact
|       |   +-- safety_incident.py
|       |   +-- hse_checklist.py
|       |   +-- audit_log.py
|       |   +-- simulation.py        # SimulationSession + SimulationScenario
|       +-- schemas/                 # Pydantic request/response schemas
|       |   +-- user.py              # UserCreate, UserOut, Token
|       |   +-- project.py
|       |   +-- activity.py
|       |   +-- milestone.py
|       |   +-- milestone_payment.py
|       |   +-- cbs.py
|       |   +-- compensation_event.py
|       |   +-- safety_incident.py
|       |   +-- hse_checklist.py
|       |   +-- dashboard.py         # DashboardSummary, BudgetVsActual, CashflowItem
|       |   +-- simulation.py        # SimulationRunRequest, SimulationSessionDetail
|       +-- api/                     # FastAPI route handlers (12 routers)
|       |   +-- auth.py              # /api/auth (register, login, me)
|       |   +-- dashboard.py         # /api/dashboard (summary, charts data)
|       |   +-- projects.py          # /api/projects (CRUD)
|       |   +-- activities.py        # /api/activities (CRUD)
|       |   +-- milestones.py        # /api/milestones (CRUD + business rules)
|       |   +-- cbs.py               # /api/cbs (CRUD)
|       |   +-- compensation_events.py # /api/compensation-events (CRUD)
|       |   +-- payments.py          # /api/payments (CRUD)
|       |   +-- safety.py            # /api/safety-incidents (CRUD)
|       |   +-- hse_checklist.py     # /api/hse-checklist (CRUD)
|       |   +-- export.py            # /api/export (Excel download)
|       |   +-- simulation.py        # /api/simulation (start, run, apply, discard)
|       +-- services/
|           +-- audit.py             # log_action() helper for audit trail
|           +-- simulation_engine.py # 5 simulation runners (Schedule, Cost, Cashflow, LD, Resource)
|
+-- frontend/
    +-- Dockerfile                   # Multi-stage: Node build -> Nginx serve
    +-- nginx.conf                   # Reverse proxy config (/api -> backend:8000)
    +-- package.json                 # Node dependencies
    +-- vite.config.js               # Dev server on port 3000, proxy to backend
    +-- index.html
    +-- .env                         # VITE_API_URL
    +-- src/
        +-- main.jsx                 # React entry point (no StrictMode)
        +-- App.jsx                  # Theme, routing, ProtectedRoute wrapper
        +-- context/
        |   +-- AuthContext.jsx       # Auth state management (login, logout, token validation)
        +-- services/
        |   +-- api.js               # Axios instance, all API functions, Bearer token interceptor
        +-- components/
        |   +-- Layout.jsx           # Sidebar navigation, AppBar, user menu, Excel export
        |   +-- StatusChip.jsx       # Color-coded status badges
        |   +-- FormDialog.jsx       # Reusable CRUD dialog component
        +-- pages/
            +-- Login.jsx            # Login form with demo credentials
            +-- Dashboard.jsx        # KPI cards, bar/pie/line charts, upcoming milestones
            +-- ProjectView.jsx      # Projects, Activities, Milestones tabs
            +-- CommercialView.jsx   # CBS, Compensation Events, Payments, LD tabs
            +-- SafetyView.jsx       # Safety Incidents, HSE Checklist tabs
            +-- SimulationLab.jsx    # 5 simulation tabs with before/after comparisons
```

---

## 5. Database Schema

### Entity Relationship Overview

```
users (1)----(many) simulation_sessions
                        |
                   (many) simulation_scenarios

projects (1)----(many) project_activities
         (1)----(many) milestones ----(many) milestone_payments
         (1)----(many) cbs
         (1)----(many) compensation_events
         (1)----(many) safety_incidents
         (1)----(many) hse_checklist
         (1)----(many) simulation_sessions

audit_logs (standalone - references user_id and entity_type/entity_id)
```

### Tables

| Table | Description | Key Fields |
|---|---|---|
| `users` | User accounts | email, full_name, hashed_password, role (project_manager / commercial_manager / hse_officer / admin) |
| `projects` | Top-level project records | name, client, start_date, end_date, status, total_budget, daily_ld_rate |
| `project_activities` | Tasks within a project | activity_name, phase, planned_start/finish, actual_start/finish, completion_pct |
| `milestones` | Project milestones | name, phase, planned_date, actual_date, is_critical |
| `milestone_payments` | Payments linked to milestones | payment_percentage, payment_value, invoice_number, payment_status |
| `cbs` | Cost Breakdown Structure | wbs_code, description, budget_cost, actual_cost, approved_variation |
| `compensation_events` | Contract variations/claims | event_name, linked_wbs, time_impact_days, daily_overhead_cost, status |
| `safety_incidents` | H&S incident records | incident_type, severity, reported_date, resolved_date, penalty_cost |
| `hse_checklist` | Compliance checklist items | checklist_item, status, last_inspection_date |
| `audit_logs` | Action audit trail | user_id, action, entity_type, entity_id, details |
| `simulation_sessions` | Simulation session containers | project_id, created_by, name, status (Draft/Applied/Discarded) |
| `simulation_scenarios` | Individual simulation runs | type, input_parameters (JSON), output_results (JSON) |

### Computed Properties (SQLAlchemy Hybrid Properties)

These fields are not stored in the database but are calculated on-the-fly:

| Model | Property | Calculation |
|---|---|---|
| `ProjectActivity` | `status` | "Completed" if actual_finish exists, "In Progress" if actual_start but no finish, "Delayed" if planned_finish < today and not complete, else "Pending" |
| `ProjectActivity` | `delay_days` | (actual_finish - planned_finish).days if both exist, else 0 |
| `Milestone` | `status` | "Completed" if actual_date exists, "Delayed" if actual > planned or planned < today without actual, else "Pending" |
| `Milestone` | `delay_days` | (actual_date - planned_date).days if actual > planned, else 0 |
| `CBS` | `variance` | budget_cost - actual_cost - approved_variation |
| `CompensationEvent` | `cost_impact` | time_impact_days * daily_overhead_cost |

---

## 6. Authentication Flow

### Login Sequence

```
User (Browser)          Frontend (React)           Backend (FastAPI)          Database
     |                       |                           |                       |
     |  Enter credentials    |                           |                       |
     +---------------------->|                           |                       |
     |                       |  POST /api/auth/login     |                       |
     |                       |  (email + password form)  |                       |
     |                       +-------------------------->|                       |
     |                       |                           |  SELECT user by email  |
     |                       |                           +---------------------->|
     |                       |                           |<----------------------+
     |                       |                           |                       |
     |                       |                           |  Verify bcrypt hash   |
     |                       |                           |  Create JWT token     |
     |                       |                           |  (sub = str(user.id)) |
     |                       |                           |                       |
     |                       |  { access_token, user }   |                       |
     |                       |<--------------------------+                       |
     |                       |                           |                       |
     |                       |  Store token + user       |                       |
     |                       |  in localStorage          |                       |
     |                       |  Update AuthContext        |                       |
     |                       |                           |                       |
     |  Redirect to /        |                           |                       |
     |<----------------------+                           |                       |
```

### Token Validation (on page refresh)

```
1. AuthContext initializes -> reads user from localStorage (instant UI)
2. useEffect fires once (guarded by useRef) -> calls GET /api/auth/me
3. If token valid -> updates user state with fresh data
4. If token invalid/expired -> clears localStorage, sets user = null -> redirects to /login
```

### JWT Token Details

| Field | Value |
|---|---|
| Algorithm | HS256 |
| Expiry | 480 minutes (8 hours) |
| Payload `sub` | User ID as a **string** (e.g., `"1"`) |
| Header | `Authorization: Bearer <token>` |

### Protected Routes

Every API endpoint (except `/api/auth/login`, `/api/auth/register`, `/api/health`) requires the `get_current_user` dependency which:
1. Extracts the Bearer token from the `Authorization` header
2. Decodes the JWT using the secret key
3. Looks up the user by ID from the `sub` claim
4. Returns the user object or raises `401 Unauthorized`

### Role-Based Access

The `require_role(*roles)` decorator restricts endpoints to specific roles:
- `project_manager` - Full project and activity management
- `commercial_manager` - CBS, compensation events, payments
- `hse_officer` - Safety incidents, HSE checklists
- `admin` - All access

---

## 7. Backend API Flow

### Request Lifecycle

```
HTTP Request
     |
     v
FastAPI Router (matches URL pattern)
     |
     v
Dependency Injection:
  - get_db() -> provides SQLAlchemy Session
  - get_current_user() -> validates JWT, returns User
     |
     v
Route Handler Function:
  - Validates request body via Pydantic schema
  - Queries database via SQLAlchemy ORM
  - Applies business logic
  - Logs action to audit_logs table
     |
     v
Pydantic Response Model (serializes output)
     |
     v
HTTP Response (JSON)
```

### CRUD Pattern (used across all resource routers)

Each resource (projects, activities, milestones, etc.) follows this pattern:

```python
GET    /api/{resource}/              # List all (with optional ?project_id= filter)
GET    /api/{resource}/{id}          # Get one by ID
POST   /api/{resource}/              # Create new (201 Created)
PUT    /api/{resource}/{id}          # Update existing
DELETE /api/{resource}/{id}          # Delete (204 No Content)
```

### Audit Logging

Every CREATE, UPDATE, and DELETE operation calls:
```python
log_action(db, user_id, "CREATE|UPDATE|DELETE", "EntityType", entity_id, details)
```
This writes a row to the `audit_logs` table with a timestamp for compliance tracking.

---

## 8. Frontend Flow

### Application Bootstrap

```
main.jsx
  |
  v
App.jsx
  +-- ThemeProvider (MUI theme with Inter font, rounded cards/buttons)
  +-- BrowserRouter
      +-- AuthProvider (wraps entire app with auth state)
          +-- AppRoutes
              +-- /login        -> Login.jsx (public)
              +-- / (protected) -> Layout.jsx wrapper
                  +-- /             -> Dashboard.jsx
                  +-- /projects     -> ProjectView.jsx
                  +-- /commercial   -> CommercialView.jsx
                  +-- /safety       -> SafetyView.jsx
                  +-- /simulation   -> SimulationLab.jsx
              +-- /* (catch-all) -> Redirect to /
```

### Page Load Flow (e.g., Dashboard)

```
1. User navigates to /
2. ProtectedRoute checks AuthContext -> user exists? -> render Layout
3. Layout renders: AppBar + Sidebar navigation + <Outlet />
4. Dashboard.jsx mounts:
   a. useEffect calls 4 API endpoints in parallel:
      - GET /api/dashboard/summary
      - GET /api/dashboard/upcoming-milestones
      - GET /api/dashboard/budget-vs-actual
      - GET /api/dashboard/cashflow
   b. Each response updates component state
   c. React re-renders with: 8 KPI cards, 3 charts, milestones table
```

### State Management

- **Global State**: AuthContext (user, loading, loginUser, logout)
- **Local State**: Each page manages its own data via `useState` + `useEffect`
- **No Redux**: Simple enough to use React Context + local state

### API Service Layer (`api.js`)

```
Axios Instance
  |
  +-- Base URL: from VITE_API_URL env var (empty in Docker = same origin)
  +-- Default Header: Content-Type: application/json
  +-- Request Interceptor: Attaches Authorization: Bearer <token> from localStorage
  |
  +-- Exported functions: login(), register(), getMe(), getProjects(), etc.
```

---

## 9. Module Breakdown

### 9.1 Dashboard (`/`)

**Purpose:** Executive overview of all projects at a glance.

**Data Sources:** 4 API calls to `/api/dashboard/*`

**UI Components:**
| Component | Data |
|---|---|
| 8 Summary Cards | Total projects, active, delayed, milestones, delayed milestones, total budget, actual cost, open incidents |
| Bar Chart | Budget vs Actual cost per project |
| Pie Chart | Project status distribution (Active, At Risk, Completed) |
| Line Chart | Monthly cashflow (expected vs received payments) |
| Table | Upcoming milestones in the next 7 days |

**Currency:** All monetary values displayed in GBP (£)

---

### 9.2 Project View (`/projects`)

**Purpose:** Manage projects, activities, and milestones.

**3 Tabs:**

| Tab | Features |
|---|---|
| **Projects** | Table of all projects with status chips, CRUD dialog, project selector dropdown |
| **Activities** | Activities filtered by selected project, progress bars, planned vs actual dates, CRUD dialog |
| **Milestones** | Table view + visual timeline (horizontal bars showing planned vs actual), critical flag indicator, CRUD dialog |

**Key Interactions:**
1. Select a project from the dropdown -> activities and milestones filter accordingly
2. Create/Edit dialogs use the reusable `FormDialog` component
3. Timeline view shows planned dates in blue bars and actual dates in green bars
4. Delayed items shown with red status chips

---

### 9.3 Commercial View (`/commercial`)

**Purpose:** Financial management - costs, claims, payments, and liquidated damages.

**4 Tabs:**

| Tab | Features |
|---|---|
| **CBS (Cost Breakdown Structure)** | WBS items with budget, actual, variation, and computed variance. Bar chart comparing budget vs actual. Summary cards for totals. |
| **Compensation Events** | Contract variation claims with time impact, daily overhead, and computed cost_impact. Status tracking (Pending/Approved/Rejected). |
| **Payments** | Milestone-linked payments with percentage, value, invoice details. Status: Pending/Invoiced/Received. |
| **Liquidated Damages** | Read-only calculation: `LD = delay_days x daily_ld_rate`. Shows per-project LD exposure. |

**Business Formulas:**
- `CBS Variance = budget_cost - actual_cost - approved_variation`
- `CE Cost Impact = time_impact_days x daily_overhead_cost`
- `LD Penalty = delay_days x project.daily_ld_rate`

---

### 9.4 H/S View (`/safety`)

**Purpose:** Health & Safety incident management and compliance tracking.

**2 Tabs:**

| Tab | Features |
|---|---|
| **Safety Incidents** | Incident reporting with type, severity (Low/Medium/High/Critical), dates, penalty cost. Pie chart by severity. Summary cards for open/resolved/total penalty. |
| **HSE Checklist** | Compliance checklist items per project. Status: Pending/In Progress/Completed. Last inspection date tracking. |

**Key Business Rule:** Mechanical Completion milestones cannot be marked complete until ALL HSE checklist items for that project are "Completed".

---

### 9.5 Simulation Lab (`/simulation`)

**Purpose:** What-if analysis for project risk assessment. Runs calculations on cloned in-memory data without affecting real project data until explicitly applied.

**Session Workflow:**
```
Select Project -> Start Session (Draft) -> Run Scenarios -> Review Results -> Apply or Discard
```

**5 Simulation Types** (detailed in Section 11)

---

## 10. Business Logic Rules

### Rule 1: Automatic Status Calculation
Activities and milestones have auto-computed `status` fields:
- **Completed**: actual end date is set
- **In Progress**: actual start exists but no end (activities only)
- **Delayed**: planned date has passed without completion
- **Pending**: still within planned timeline

### Rule 2: Critical Milestone Delay -> Project At Risk
When a milestone marked as `is_critical = true` becomes "Delayed", the parent project's status is automatically changed to **"At Risk"**.

### Rule 3: HSE Gating on Mechanical Completion
A milestone whose name contains "Mechanical Completion" cannot have its `actual_date` set (i.e., cannot be marked complete) unless every HSE checklist item for that project has `status = "Completed"`.

### Rule 4: Liquidated Damages
LD penalties are calculated as:
```
LD Penalty = delay_days x daily_ld_rate (set per project)
```

### Rule 5: CBS Variance
```
Variance = budget_cost - actual_cost - approved_variation
```
Positive variance = under budget, negative = over budget.

### Rule 6: Compensation Event Cost Impact
```
Cost Impact = time_impact_days x daily_overhead_cost
```

### Rule 7: Simulation Isolation
All simulation calculations run on read-only copies of data. Real project data is only modified when a simulation session is explicitly **Applied**. Sessions can be **Discarded** to cancel.

---

## 11. Simulation Lab Engine

### Session Lifecycle

```
   +--------+       +---------+       +---------+
   | Draft  +------>| Applied |       |Discarded|
   +---+----+       +---------+       +---------+
       |                                   ^
       +-----------------------------------+
```

- **Draft**: Active session, scenarios can be added
- **Applied**: All scenario effects are written to real project data (irreversible)
- **Discarded**: Session is cancelled, no changes made

### 11.1 Schedule Delay Simulation

**Input Parameters:**
- `delay_days` (integer) - Number of days to shift
- `milestone_id` (optional) - Target a specific milestone
- `phase` (optional) - Target an entire phase (e.g., "Planning", "Execution")
- If neither milestone_id nor phase is provided, delay applies to ALL milestones/activities

**Calculation Logic:**
1. Clones all milestones and activities for the project
2. Shifts `planned_date` / `planned_start` / `planned_finish` by `delay_days`
3. Checks if any critical milestone is impacted -> sets `project_status_after = "At Risk"`
4. Recalculates project end date (extends if shifted dates exceed current end)

**Output:**
- Before/after milestone comparison
- Before/after activity comparison
- Original vs simulated end date
- Critical milestone impact flag
- Project status before and after

---

### 11.2 Cost Impact Simulation

**Input Parameters:**
- `time_impact_days` - Duration of disruption
- `daily_overhead_cost` - Cost per day during disruption
- `escalation_pct` - Additional escalation percentage on top of base cost

**Calculation Logic:**
1. `cost_impact = time_impact_days x daily_overhead_cost`
2. `escalation_amount = cost_impact x (escalation_pct / 100)`
3. `total_cost_impact = cost_impact + escalation_amount`
4. Distributes impact proportionally across CBS items based on their actual_cost weight
5. Recalculates variance for each CBS item

**Output:**
- Cost impact breakdown (base + escalation)
- Before/after CBS comparison with per-item cost added
- Forecast cost and budget variance
- Cost increase percentage

---

### 11.3 Cashflow Simulation

**Input Parameters:**
- `milestone_delay_days` - How many days milestones (and their payments) are delayed

**Calculation Logic:**
1. Maps all milestone payments to their planned month
2. Shifts pending payments by the delay period (received payments stay fixed)
3. Builds monthly timeline comparing before vs after cashflow
4. Calculates cumulative curves and working capital gap (maximum difference between before and after cumulative cashflow)

**Output:**
- Before/after monthly cashflow series
- Combined chart data (both curves overlaid)
- Total expected and received amounts
- Working capital gap

---

### 11.4 Liquidated Damages Simulation

**Input Parameters:**
- `delay_days` - Additional delay to simulate
- `daily_ld_rate` (optional) - Override rate; defaults to project's `daily_ld_rate`

**Calculation Logic:**
1. Calculates existing LD from already-delayed milestones
2. Adds simulated LD: `new_penalty = delay_days x daily_ld_rate`
3. Calculates profit impact: `profit_after = (budget - actual - existing_ld) - new_penalty`

**Output:**
- Per-milestone penalty breakdown (existing + simulated)
- Total LD penalty
- Profit before and after LD
- Profit impact percentage

---

### 11.5 Resource Acceleration Simulation

**Input Parameters:**
- `activity_id` - Which activity to accelerate
- `additional_resources` - Number of extra resources to add
- `productivity_gain_pct` - Efficiency gain per resource (default: 15%)

**Calculation Logic:**
1. `total_gain = additional_resources x productivity_gain_pct` (capped at 60%)
2. Calculates remaining work days based on current completion %
3. `reduced_days = remaining_days x (1 - total_gain / 100)`
4. `days_saved = remaining_days - reduced_days`
5. Additional cost = `resources x £500/day x remaining_work_days`

**Output:**
- Before/after activity comparison
- Days saved
- Additional cost
- Cost per day saved

---

### Apply Flow (when user clicks "Apply Simulation")

When a Draft session is applied, the backend iterates through each scenario and writes changes to real tables:

| Scenario Type | What Gets Modified |
|---|---|
| **Schedule** | `milestones.planned_date`, `activities.planned_start/finish`, `projects.end_date`, `projects.status` |
| **Cost** | `cbs.actual_cost` (proportionally distributed) |
| **LD** | `projects.daily_ld_rate` (if overridden in params) |
| **Cashflow** | Informational only - no direct writes |
| **Resource** | Informational only - no direct writes |

An audit log entry is created: `"APPLY_SIMULATION"` with session details.

---

## 12. Docker Deployment Flow

### Container Architecture

```
docker-compose.yml
     |
     +-- db (postgres:16-alpine)
     |   +-- Port: 5432
     |   +-- Volume: pgdata (persistent)
     |   +-- Health check: pg_isready every 5s
     |
     +-- backend (Python 3.11-slim)
     |   +-- Port: 8000
     |   +-- Depends on: db (healthy)
     |   +-- Startup: seed.py -> uvicorn main:app
     |   +-- Env: DATABASE_URL, SECRET_KEY
     |
     +-- frontend (Nginx Alpine)
         +-- Port: 8080 -> 80 (container)
         +-- Depends on: backend
         +-- Build: Node 20 (build) -> Nginx (serve)
         +-- Nginx proxies /api -> backend:8000
```

### Startup Sequence

```
1. docker compose up --build -d
2. PostgreSQL starts and runs health checks (pg_isready)
3. Once db is healthy, backend starts:
   a. seed.py runs: creates tables (Base.metadata.create_all), inserts demo data
   b. uvicorn starts FastAPI on port 8000
4. Frontend container starts:
   a. Build stage: npm install + vite build (produces static dist/)
   b. Runtime stage: Nginx serves dist/ and proxies /api to backend
5. App accessible at http://localhost:8080
```

### Nginx Configuration

```nginx
server {
    listen 80;

    # Proxy API requests to FastAPI backend
    location /api {
        proxy_pass http://backend:8000;
        proxy_set_header Authorization $http_authorization;  # Forward JWT tokens
    }

    # Serve React SPA, fallback to index.html for client-side routing
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 13. Data Flow Diagrams

### Creating a New Project

```
User fills form in ProjectView.jsx
        |
        v
FormDialog collects: name, client, start_date, end_date, total_budget, daily_ld_rate
        |
        v
createProject(data) -> POST /api/projects/
        |
        v
FastAPI validates via ProjectCreate schema
        |
        v
SQLAlchemy creates Project row in database
        |
        v
log_action(db, user_id, "CREATE", "Project", id, name)
        |
        v
Returns ProjectOut (JSON) -> UI refreshes project list
```

### Running a Simulation

```
User selects project, names session, clicks "Start Session"
        |
        v
startSimulation({project_id, name}) -> POST /api/simulation/start
        |
        v
Backend creates SimulationSession (status: "Draft")
        |
        v
User fills simulation form (e.g., Schedule: delay_days=30, phase="Execution")
        |
        v
runSimulation({session_id, type, input_parameters}) -> POST /api/simulation/run
        |
        v
simulation_engine.py:
  1. Reads real project data (milestones, activities, CBS, payments)
  2. Runs calculations in-memory (no DB writes)
  3. Returns before/after comparison results
        |
        v
Backend saves SimulationScenario (input_parameters + output_results as JSON)
        |
        v
Frontend displays:
  - Before/After comparison cards
  - Charts (bar, line, area depending on type)
  - Impact summary
        |
        v
User clicks "Apply" or "Discard"
        |
        +-- Apply: Writes simulation effects to real project tables
        +-- Discard: Marks session as "Discarded", no changes
```

---

## 14. API Reference

### Authentication
| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/register` | Create new user account |
| POST | `/api/auth/login` | Login (returns JWT + user data) |
| GET | `/api/auth/me` | Get current user profile |

### Dashboard
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/dashboard/summary` | KPI summary (totals, counts) |
| GET | `/api/dashboard/upcoming-milestones` | Milestones due within 7 days |
| GET | `/api/dashboard/budget-vs-actual` | Per-project budget vs actual data |
| GET | `/api/dashboard/cashflow` | Monthly cashflow (expected vs received) |

### Projects
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/projects/` | List all projects |
| GET | `/api/projects/{id}` | Get project by ID |
| POST | `/api/projects/` | Create project |
| PUT | `/api/projects/{id}` | Update project |
| DELETE | `/api/projects/{id}` | Delete project |

### Activities
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/activities/?project_id=` | List activities (filterable) |
| POST | `/api/activities/` | Create activity |
| PUT | `/api/activities/{id}` | Update activity |
| DELETE | `/api/activities/{id}` | Delete activity |

### Milestones
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/milestones/?project_id=` | List milestones (filterable) |
| GET | `/api/milestones/upcoming` | Milestones due in next 7 days |
| POST | `/api/milestones/` | Create milestone |
| PUT | `/api/milestones/{id}` | Update milestone (with HSE gating logic) |
| DELETE | `/api/milestones/{id}` | Delete milestone |

### CBS (Cost Breakdown Structure)
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/cbs/?project_id=` | List CBS items |
| POST | `/api/cbs/` | Create CBS item |
| PUT | `/api/cbs/{id}` | Update CBS item |
| DELETE | `/api/cbs/{id}` | Delete CBS item |

### Compensation Events
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/compensation-events/?project_id=` | List events |
| POST | `/api/compensation-events/` | Create event |
| PUT | `/api/compensation-events/{id}` | Update event |
| DELETE | `/api/compensation-events/{id}` | Delete event |

### Payments
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/payments/?milestone_id=` | List payments |
| POST | `/api/payments/` | Create payment |
| PUT | `/api/payments/{id}` | Update payment |
| DELETE | `/api/payments/{id}` | Delete payment |

### Safety Incidents
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/safety-incidents/?project_id=` | List incidents |
| POST | `/api/safety-incidents/` | Create incident |
| PUT | `/api/safety-incidents/{id}` | Update incident |
| DELETE | `/api/safety-incidents/{id}` | Delete incident |

### HSE Checklist
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/hse-checklist/?project_id=` | List checklist items |
| POST | `/api/hse-checklist/` | Create item |
| PUT | `/api/hse-checklist/{id}` | Update item |
| DELETE | `/api/hse-checklist/{id}` | Delete item |

### Export
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/export/projects` | Download multi-sheet Excel file |

### Simulation
| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/simulation/start` | Create a new simulation session |
| POST | `/api/simulation/run` | Run a scenario within a session |
| GET | `/api/simulation/sessions?project_id=` | List all sessions |
| GET | `/api/simulation/{session_id}` | Get session with all scenarios |
| POST | `/api/simulation/{session_id}/apply` | Apply simulation to real data |
| POST | `/api/simulation/{session_id}/discard` | Discard simulation session |

### Health
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/health` | Health check (no auth required) |

---

## Demo Credentials

| Email | Password | Role |
|---|---|---|
| `admin@pmhub.com` | `admin123` | Admin |

---

## Running the Application

```bash
# Start all services
docker compose up --build -d

# Access the app
open http://localhost:8080

# View backend logs
docker logs pmhub-backend-1 --tail 50

# Stop all services
docker compose down

# Stop and remove data
docker compose down -v
```
