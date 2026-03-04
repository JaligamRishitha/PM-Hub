from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import (
    activities,
    auth,
    cbs,
    compensation_events,
    dashboard,
    documents,
    export,
    hse_checklist,
    issues,
    milestones,
    payments,
    portfolio,
    projects,
    reports,
    risks,
    safety,
    simulation,
    variations,
    wbs,
)
from sqlalchemy import text
from app.core.database import Base, engine

# Create all tables
Base.metadata.create_all(bind=engine)

# Migrate: add new columns to existing tables if they don't exist
with engine.connect() as conn:
    try:
        conn.execute(text(
            "ALTER TABLE projects ADD COLUMN IF NOT EXISTS phase VARCHAR(50) DEFAULT 'Gate B'"
        ))
        conn.commit()
    except Exception:
        conn.rollback()

app = FastAPI(
    title="PM Hub - Project Management Intelligence Platform",
    version="2.0.0",
    description="Enterprise-grade Project Management API with Portfolio, Scheduling, Commercial, Risk, Safety, and Simulation modules",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173", "http://localhost:8080"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth.router)
app.include_router(dashboard.router)
app.include_router(portfolio.router)
app.include_router(projects.router)
app.include_router(wbs.router)
app.include_router(activities.router)
app.include_router(milestones.router)
app.include_router(cbs.router)
app.include_router(variations.router)
app.include_router(compensation_events.router)
app.include_router(payments.router)
app.include_router(risks.router)
app.include_router(issues.router)
app.include_router(safety.router)
app.include_router(hse_checklist.router)
app.include_router(documents.router)
app.include_router(export.router)
app.include_router(reports.router)
app.include_router(simulation.router)


@app.get("/api/health")
def health_check():
    return {"status": "healthy", "app": "PM Hub", "version": "2.0.0"}
