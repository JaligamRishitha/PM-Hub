# PM Hub - Project Management Hub

Enterprise-grade project management application for construction and infrastructure projects.

## Tech Stack

| Layer     | Technology          |
|-----------|---------------------|
| Frontend  | React 18 + Vite     |
| UI        | Material UI 5       |
| Charts    | Recharts            |
| Backend   | FastAPI (Python)    |
| ORM       | SQLAlchemy 2.0      |
| Database  | PostgreSQL 16       |
| Auth      | JWT (python-jose)   |
| Deploy    | Docker Compose      |

## Quick Start (Docker)

```bash
# Clone and navigate to project
cd "PM Hub"

# Start all services
docker compose up --build

# Access the app
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000/docs
```

## Quick Start (Local Development)

### Prerequisites
- Python 3.11+
- Node.js 20+
- PostgreSQL 16+

### Database Setup
```bash
# Create database
createdb pmhub

# Or use the schema file
psql -U postgres -d pmhub -f database/schema.sql
```

### Backend
```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt

# Configure environment
# Edit .env with your DATABASE_URL

# Run seed data
python seed.py

# Start server
uvicorn app.main:app --reload --port 8000
```

### Frontend
```bash
cd frontend

# Install dependencies
npm install

# Start dev server (proxies API to localhost:8000)
npm run dev
```

## Demo Accounts

| Role               | Email          | Password     |
|-------------------|----------------|--------------|
| Project Manager    | pm@pmhub.com   | password123  |
| Commercial Manager | cm@pmhub.com   | password123  |
| HSE Officer        | hse@pmhub.com  | password123  |
| Admin              | admin@pmhub.com| password123  |

## Modules

### Dashboard
- Summary cards: total/active/delayed projects, milestones, budget, safety
- Budget vs Actual bar chart
- Project status pie chart
- Cashflow line chart
- Upcoming milestones table (next 7 days)

### Project View
- Projects table with CRUD
- Activities table with auto-calculated status and delay days
- Milestones with table and timeline views
- Business logic: critical milestone delays mark project "At Risk"

### Commercial View
- CBS (Cost Breakdown Structure) with variance calculations
- Compensation Events with auto-calculated cost impact
- Milestone Payments with delay impact tracking
- Liquidated Damages with auto-calculated penalties

### H/S View (Health & Safety)
- Safety incidents tracking with severity levels
- HSE checklist with completion tracking
- Business logic: Mechanical Completion milestone blocked until checklist complete
- Severity breakdown pie chart

## API Documentation

Once the backend is running, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Project Structure

```
PM Hub/
├── backend/
│   ├── app/
│   │   ├── api/           # API route handlers
│   │   ├── core/          # Config, database, security
│   │   ├── models/        # SQLAlchemy models
│   │   ├── schemas/       # Pydantic schemas
│   │   ├── services/      # Business logic services
│   │   └── main.py        # FastAPI application
│   ├── seed.py            # Sample data seeder
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env
├── frontend/
│   ├── src/
│   │   ├── components/    # Reusable UI components
│   │   ├── context/       # React contexts (Auth)
│   │   ├── pages/         # Page components
│   │   ├── services/      # API client
│   │   ├── App.jsx        # Root component with routing
│   │   └── main.jsx       # Entry point
│   ├── package.json
│   ├── vite.config.js
│   ├── nginx.conf
│   ├── Dockerfile
│   └── .env
├── database/
│   └── schema.sql         # Full PostgreSQL schema
├── docker-compose.yml
├── .env
└── README.md
```
