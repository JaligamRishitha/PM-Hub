"""Seed script to populate the database with IT project demo data."""
import sys
from datetime import date, timedelta

from app.core.database import Base, engine, SessionLocal
from app.core.security import hash_password
from app.models.user import User
from app.models.organization import Organization
from app.models.programme import Programme
from app.models.project import Project
from app.models.wbs import WBSItem
from app.models.activity import ProjectActivity
from app.models.milestone import Milestone
from app.models.cbs import CBS
from app.models.variation import ApprovedVariation
from app.models.compensation_event import CompensationEvent
from app.models.milestone_payment import MilestonePayment
from app.models.risk import Risk
from app.models.issue import Issue
from app.models.safety_incident import SafetyIncident
from app.models.hse_checklist import HSEChecklist
from app.models.document import Document


def seed():
    import app.models  # noqa: F401
    Base.metadata.create_all(bind=engine)

    # Migrate: add phase column if missing
    from sqlalchemy import text
    with engine.connect() as conn:
        try:
            conn.execute(text(
                "ALTER TABLE projects ADD COLUMN IF NOT EXISTS phase VARCHAR(50) DEFAULT 'Gate B'"
            ))
            conn.commit()
        except Exception:
            conn.rollback()

    db = SessionLocal()
    try:
        if db.query(User).first():
            # Backfill phase for existing projects that have NULL phase
            projects_to_update = db.query(Project).filter(Project.phase.is_(None)).all()
            if projects_to_update:
                phase_assignments = ['Gate B', 'Gate C', 'Design Completion', 'Construction', 'Commissioned']
                for i, p in enumerate(projects_to_update):
                    p.phase = phase_assignments[i % len(phase_assignments)]
                db.commit()
                print(f"Backfilled phase for {len(projects_to_update)} existing projects.")
            print("Database already seeded. Skipping.")
            return

        today = date.today()

        # ── Users ──────────────────────────────────────────────
        users = [
            User(email="pm@pmhub.com", full_name="Alex Johnson", hashed_password=hash_password("password123"), role="project_manager"),
            User(email="cm@pmhub.com", full_name="Sarah Williams", hashed_password=hash_password("password123"), role="commercial_manager"),
            User(email="hse@pmhub.com", full_name="Mike Chen", hashed_password=hash_password("password123"), role="hse_officer"),
            User(email="admin@pmhub.com", full_name="Admin User", hashed_password=hash_password("password123"), role="admin"),
        ]
        db.add_all(users)
        db.flush()

        # ── Organizations & Programmes ─────────────────────────
        org1 = Organization(name="Global IT Solutions Group", code="GITSG", description="Enterprise IT and digital transformation portfolio")
        org2 = Organization(name="FinTech Innovations Ltd", code="FIL", description="Financial technology products and platforms")
        db.add_all([org1, org2])
        db.flush()

        prog1 = Programme(organization_id=org1.id, name="Enterprise Modernization Programme", code="EMP", status="Active", start_date=today - timedelta(days=365), end_date=today + timedelta(days=730))
        prog2 = Programme(organization_id=org1.id, name="Cloud & Infrastructure Programme", code="CIP", status="Active", start_date=today - timedelta(days=200), end_date=today + timedelta(days=600))
        prog3 = Programme(organization_id=org2.id, name="Digital Banking Platform Programme", code="DBP", status="Active", start_date=today - timedelta(days=150), end_date=today + timedelta(days=500))
        db.add_all([prog1, prog2, prog3])
        db.flush()

        # ── 10 IT Projects ────────────────────────────────────
        projects = [
            Project(
                programme_id=prog1.id, name="ERP System Migration", code="EMP-001",
                client="Acme Corporation", description="Migration from legacy SAP R/3 to SAP S/4HANA with full data migration and 120 custom reports",
                start_date=today - timedelta(days=180), end_date=today + timedelta(days=360),
                contract_completion_date=today + timedelta(days=330),
                status="Active", phase="Construction", total_budget=4200000, contract_value=4800000,
                forecast_cost=4500000, daily_ld_rate=5000, ld_cap_pct=10,
                location="London, UK", project_manager="Alex Johnson",
            ),
            Project(
                programme_id=prog1.id, name="HR Portal & Employee Self-Service", code="EMP-002",
                client="Acme Corporation", description="React-based HR portal with payroll integration, leave management, and performance review modules",
                start_date=today - timedelta(days=120), end_date=today + timedelta(days=180),
                contract_completion_date=today + timedelta(days=160),
                status="Active", phase="Design Completion", total_budget=1200000, contract_value=1400000,
                forecast_cost=1300000, daily_ld_rate=2000, ld_cap_pct=10,
                location="London, UK", project_manager="Sarah Williams",
            ),
            Project(
                programme_id=prog2.id, name="AWS Cloud Migration", code="CIP-001",
                client="Barclays Group", description="Migrate 85 on-premise applications to AWS including re-platforming, re-hosting, and containerization",
                start_date=today - timedelta(days=240), end_date=today + timedelta(days=120),
                contract_completion_date=today + timedelta(days=100),
                status="At Risk", phase="Construction", total_budget=3800000, contract_value=4200000,
                forecast_cost=4100000, daily_ld_rate=4000, ld_cap_pct=8,
                location="Manchester, UK", project_manager="Alex Johnson",
            ),
            Project(
                programme_id=prog2.id, name="Zero Trust Network Security", code="CIP-002",
                client="NHS Digital", description="Implement zero-trust architecture across 40 hospital sites with MFA, micro-segmentation, and SIEM integration",
                start_date=today - timedelta(days=90), end_date=today + timedelta(days=270),
                contract_completion_date=today + timedelta(days=250),
                status="Active", phase="Gate B", total_budget=2800000, contract_value=3200000,
                forecast_cost=2900000, daily_ld_rate=3500, ld_cap_pct=10,
                location="Leeds, UK", project_manager="Mike Chen",
            ),
            Project(
                programme_id=prog2.id, name="Kubernetes Platform Build", code="CIP-003",
                client="Vodafone UK", description="Enterprise Kubernetes platform on Azure AKS with GitOps, service mesh, and observability stack",
                start_date=today - timedelta(days=150), end_date=today + timedelta(days=90),
                contract_completion_date=today + timedelta(days=75),
                status="Active", phase="Gate C", total_budget=1800000, contract_value=2100000,
                forecast_cost=1950000, daily_ld_rate=2500, ld_cap_pct=10,
                location="Newbury, UK", project_manager="Alex Johnson",
            ),
            Project(
                programme_id=prog3.id, name="Mobile Banking App Rebuild", code="DBP-001",
                client="Metro Bank", description="Ground-up rebuild of iOS/Android banking app with biometric auth, real-time payments, and open banking APIs",
                start_date=today - timedelta(days=200), end_date=today + timedelta(days=100),
                contract_completion_date=today + timedelta(days=80),
                status="Active", phase="Construction", total_budget=3500000, contract_value=4000000,
                forecast_cost=3700000, daily_ld_rate=4500, ld_cap_pct=10,
                location="London, UK", project_manager="Sarah Williams",
            ),
            Project(
                programme_id=prog3.id, name="Payment Gateway Platform", code="DBP-002",
                client="Revolut", description="High-throughput payment processing platform handling 10K TPS with PCI-DSS compliance",
                start_date=today - timedelta(days=100), end_date=today + timedelta(days=260),
                contract_completion_date=today + timedelta(days=240),
                status="Active", phase="Design Completion", total_budget=2600000, contract_value=3000000,
                forecast_cost=2750000, daily_ld_rate=3000, ld_cap_pct=12,
                location="London, UK", project_manager="Alex Johnson",
            ),
            Project(
                programme_id=prog1.id, name="Data Warehouse & BI Platform", code="EMP-003",
                client="Tesco PLC", description="Snowflake data warehouse with dbt transformations, Tableau dashboards, and real-time Kafka streaming",
                start_date=today - timedelta(days=160), end_date=today + timedelta(days=200),
                contract_completion_date=today + timedelta(days=180),
                status="Active", phase="Gate B", total_budget=2200000, contract_value=2500000,
                forecast_cost=2350000, daily_ld_rate=2500, ld_cap_pct=10,
                location="Welwyn Garden City, UK", project_manager="Sarah Williams",
            ),
            Project(
                programme_id=prog3.id, name="Fraud Detection ML System", code="DBP-003",
                client="Lloyds Banking Group", description="Real-time ML fraud detection engine processing card transactions with 99.7% accuracy target",
                start_date=today - timedelta(days=60), end_date=today + timedelta(days=300),
                contract_completion_date=today + timedelta(days=280),
                status="Active", phase="Gate C", total_budget=3000000, contract_value=3500000,
                forecast_cost=3100000, daily_ld_rate=3500, ld_cap_pct=10,
                location="Edinburgh, UK", project_manager="Mike Chen",
            ),
            Project(
                programme_id=prog2.id, name="DevOps CI/CD Transformation", code="CIP-004",
                client="BP Digital", description="Enterprise-wide CI/CD pipeline standardization with GitHub Actions, ArgoCD, Terraform, and Vault",
                start_date=today - timedelta(days=110), end_date=today + timedelta(days=70),
                contract_completion_date=today + timedelta(days=60),
                status="Completed", phase="Commissioned", total_budget=950000, contract_value=1100000,
                forecast_cost=980000, daily_ld_rate=1500, ld_cap_pct=10,
                location="Sunbury, UK", project_manager="Alex Johnson",
            ),
        ]
        db.add_all(projects)
        db.flush()

        # ── WBS Items ─────────────────────────────────────────
        wbs_data = [
            # ERP Migration (0)
            (0, "1.0", "Project Management & Governance", 1, 1),
            (0, "2.0", "Requirements & Design", 1, 2),
            (0, "3.0", "Data Migration", 1, 3),
            (0, "4.0", "Development & Configuration", 1, 4),
            (0, "5.0", "Testing & QA", 1, 5),
            (0, "6.0", "Training & Go-Live", 1, 6),
            # AWS Migration (2)
            (2, "1.0", "Discovery & Assessment", 1, 1),
            (2, "2.0", "Landing Zone Setup", 1, 2),
            (2, "3.0", "Application Migration", 1, 3),
            (2, "4.0", "Optimization & Handover", 1, 4),
            # Mobile Banking (5)
            (5, "1.0", "UX Research & Design", 1, 1),
            (5, "2.0", "Core Banking API", 1, 2),
            (5, "3.0", "Mobile App Development", 1, 3),
            (5, "4.0", "Security & Compliance", 1, 4),
            (5, "5.0", "UAT & Launch", 1, 5),
        ]
        wbs_items = [WBSItem(project_id=projects[p].id, code=c, name=n, level=l, sort_order=s) for p, c, n, l, s in wbs_data]
        db.add_all(wbs_items)
        db.flush()

        # ── Activities ─────────────────────────────────────────
        activities = [
            # ERP Migration (0)
            ProjectActivity(project_id=projects[0].id, activity_code="ERP-001", activity_name="Business Process Mapping", phase="Design", planned_start=today - timedelta(days=180), planned_finish=today - timedelta(days=140), actual_start=today - timedelta(days=180), actual_finish=today - timedelta(days=138), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[0].id, activity_code="ERP-002", activity_name="Gap Analysis & Fit Study", phase="Design", planned_start=today - timedelta(days=140), planned_finish=today - timedelta(days=100), actual_start=today - timedelta(days=138), actual_finish=today - timedelta(days=95), completion_pct=100),
            ProjectActivity(project_id=projects[0].id, activity_code="ERP-003", activity_name="Data Cleansing & Extraction", phase="Construction", planned_start=today - timedelta(days=100), planned_finish=today - timedelta(days=40), actual_start=today - timedelta(days=95), actual_finish=None, completion_pct=80, is_critical=True),
            ProjectActivity(project_id=projects[0].id, activity_code="ERP-004", activity_name="S/4HANA Configuration", phase="Construction", planned_start=today - timedelta(days=80), planned_finish=today - timedelta(days=10), actual_start=today - timedelta(days=75), actual_finish=None, completion_pct=70, is_critical=True),
            ProjectActivity(project_id=projects[0].id, activity_code="ERP-005", activity_name="Custom Report Development", phase="Construction", planned_start=today - timedelta(days=40), planned_finish=today + timedelta(days=60), actual_start=today - timedelta(days=35), actual_finish=None, completion_pct=30),
            ProjectActivity(project_id=projects[0].id, activity_code="ERP-006", activity_name="Integration Testing", phase="Commissioning", planned_start=today + timedelta(days=60), planned_finish=today + timedelta(days=120), actual_start=None, actual_finish=None, completion_pct=0, is_critical=True),
            ProjectActivity(project_id=projects[0].id, activity_code="ERP-007", activity_name="User Acceptance Testing", phase="Commissioning", planned_start=today + timedelta(days=120), planned_finish=today + timedelta(days=180), actual_start=None, actual_finish=None, completion_pct=0, is_critical=True),
            ProjectActivity(project_id=projects[0].id, activity_code="ERP-008", activity_name="Go-Live & Hypercare", phase="Commissioning", planned_start=today + timedelta(days=180), planned_finish=today + timedelta(days=240), actual_start=None, actual_finish=None, completion_pct=0, is_critical=True),
            # HR Portal (1)
            ProjectActivity(project_id=projects[1].id, activity_code="HR-001", activity_name="UI/UX Wireframing", phase="Design", planned_start=today - timedelta(days=120), planned_finish=today - timedelta(days=90), actual_start=today - timedelta(days=120), actual_finish=today - timedelta(days=88), completion_pct=100),
            ProjectActivity(project_id=projects[1].id, activity_code="HR-002", activity_name="Backend API Development", phase="Construction", planned_start=today - timedelta(days=90), planned_finish=today - timedelta(days=30), actual_start=today - timedelta(days=88), actual_finish=today - timedelta(days=25), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[1].id, activity_code="HR-003", activity_name="React Frontend Build", phase="Construction", planned_start=today - timedelta(days=70), planned_finish=today - timedelta(days=10), actual_start=today - timedelta(days=68), actual_finish=None, completion_pct=85, is_critical=True),
            ProjectActivity(project_id=projects[1].id, activity_code="HR-004", activity_name="Payroll Integration", phase="Construction", planned_start=today - timedelta(days=30), planned_finish=today + timedelta(days=30), actual_start=today - timedelta(days=25), actual_finish=None, completion_pct=45),
            # AWS Migration (2)
            ProjectActivity(project_id=projects[2].id, activity_code="AWS-001", activity_name="Application Portfolio Assessment", phase="Design", planned_start=today - timedelta(days=240), planned_finish=today - timedelta(days=200), actual_start=today - timedelta(days=240), actual_finish=today - timedelta(days=195), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[2].id, activity_code="AWS-002", activity_name="AWS Landing Zone & VPC Setup", phase="Design", planned_start=today - timedelta(days=200), planned_finish=today - timedelta(days=160), actual_start=today - timedelta(days=195), actual_finish=today - timedelta(days=150), completion_pct=100),
            ProjectActivity(project_id=projects[2].id, activity_code="AWS-003", activity_name="Wave 1 Migration (30 apps)", phase="Construction", planned_start=today - timedelta(days=160), planned_finish=today - timedelta(days=80), actual_start=today - timedelta(days=150), actual_finish=today - timedelta(days=70), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[2].id, activity_code="AWS-004", activity_name="Wave 2 Migration (35 apps)", phase="Construction", planned_start=today - timedelta(days=80), planned_finish=today - timedelta(days=10), actual_start=today - timedelta(days=70), actual_finish=None, completion_pct=75, is_critical=True),
            ProjectActivity(project_id=projects[2].id, activity_code="AWS-005", activity_name="Wave 3 Migration (20 apps)", phase="Construction", planned_start=today - timedelta(days=10), planned_finish=today + timedelta(days=60), actual_start=today - timedelta(days=5), actual_finish=None, completion_pct=10),
            ProjectActivity(project_id=projects[2].id, activity_code="AWS-006", activity_name="Decommission On-Prem Servers", phase="Commissioning", planned_start=today + timedelta(days=60), planned_finish=today + timedelta(days=120), actual_start=None, actual_finish=None, completion_pct=0),
            # Zero Trust (3)
            ProjectActivity(project_id=projects[3].id, activity_code="ZT-001", activity_name="Network Topology Assessment", phase="Design", planned_start=today - timedelta(days=90), planned_finish=today - timedelta(days=60), actual_start=today - timedelta(days=90), actual_finish=today - timedelta(days=58), completion_pct=100),
            ProjectActivity(project_id=projects[3].id, activity_code="ZT-002", activity_name="Identity Provider Setup (Azure AD)", phase="Construction", planned_start=today - timedelta(days=60), planned_finish=today - timedelta(days=20), actual_start=today - timedelta(days=58), actual_finish=today - timedelta(days=18), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[3].id, activity_code="ZT-003", activity_name="Micro-Segmentation Rollout", phase="Construction", planned_start=today - timedelta(days=20), planned_finish=today + timedelta(days=90), actual_start=today - timedelta(days=18), actual_finish=None, completion_pct=25, is_critical=True),
            ProjectActivity(project_id=projects[3].id, activity_code="ZT-004", activity_name="SIEM & SOC Integration", phase="Commissioning", planned_start=today + timedelta(days=90), planned_finish=today + timedelta(days=200), actual_start=None, actual_finish=None, completion_pct=0),
            # Kubernetes (4)
            ProjectActivity(project_id=projects[4].id, activity_code="K8S-001", activity_name="AKS Cluster Provisioning", phase="Design", planned_start=today - timedelta(days=150), planned_finish=today - timedelta(days=120), actual_start=today - timedelta(days=150), actual_finish=today - timedelta(days=118), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[4].id, activity_code="K8S-002", activity_name="Istio Service Mesh Setup", phase="Construction", planned_start=today - timedelta(days=120), planned_finish=today - timedelta(days=80), actual_start=today - timedelta(days=118), actual_finish=today - timedelta(days=75), completion_pct=100),
            ProjectActivity(project_id=projects[4].id, activity_code="K8S-003", activity_name="GitOps with ArgoCD", phase="Construction", planned_start=today - timedelta(days=80), planned_finish=today - timedelta(days=40), actual_start=today - timedelta(days=75), actual_finish=today - timedelta(days=35), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[4].id, activity_code="K8S-004", activity_name="Observability Stack (Prometheus/Grafana)", phase="Construction", planned_start=today - timedelta(days=40), planned_finish=today + timedelta(days=10), actual_start=today - timedelta(days=35), actual_finish=None, completion_pct=75),
            ProjectActivity(project_id=projects[4].id, activity_code="K8S-005", activity_name="Workload Onboarding (15 services)", phase="Commissioning", planned_start=today + timedelta(days=10), planned_finish=today + timedelta(days=90), actual_start=None, actual_finish=None, completion_pct=0, is_critical=True),
            # Mobile Banking (5)
            ProjectActivity(project_id=projects[5].id, activity_code="MB-001", activity_name="User Research & Prototyping", phase="Design", planned_start=today - timedelta(days=200), planned_finish=today - timedelta(days=160), actual_start=today - timedelta(days=200), actual_finish=today - timedelta(days=155), completion_pct=100),
            ProjectActivity(project_id=projects[5].id, activity_code="MB-002", activity_name="Core Banking API Layer", phase="Construction", planned_start=today - timedelta(days=160), planned_finish=today - timedelta(days=80), actual_start=today - timedelta(days=155), actual_finish=today - timedelta(days=72), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[5].id, activity_code="MB-003", activity_name="iOS & Android Development", phase="Construction", planned_start=today - timedelta(days=120), planned_finish=today - timedelta(days=20), actual_start=today - timedelta(days=115), actual_finish=None, completion_pct=90, is_critical=True),
            ProjectActivity(project_id=projects[5].id, activity_code="MB-004", activity_name="PEN Testing & Security Audit", phase="Commissioning", planned_start=today - timedelta(days=20), planned_finish=today + timedelta(days=30), actual_start=today - timedelta(days=15), actual_finish=None, completion_pct=40),
            ProjectActivity(project_id=projects[5].id, activity_code="MB-005", activity_name="App Store Submission & Launch", phase="Commissioning", planned_start=today + timedelta(days=30), planned_finish=today + timedelta(days=80), actual_start=None, actual_finish=None, completion_pct=0, is_critical=True),
            # Payment Gateway (6)
            ProjectActivity(project_id=projects[6].id, activity_code="PG-001", activity_name="Architecture & PCI-DSS Planning", phase="Design", planned_start=today - timedelta(days=100), planned_finish=today - timedelta(days=60), actual_start=today - timedelta(days=100), actual_finish=today - timedelta(days=58), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[6].id, activity_code="PG-002", activity_name="Transaction Engine Development", phase="Construction", planned_start=today - timedelta(days=60), planned_finish=today + timedelta(days=40), actual_start=today - timedelta(days=58), actual_finish=None, completion_pct=55, is_critical=True),
            ProjectActivity(project_id=projects[6].id, activity_code="PG-003", activity_name="Load Testing (10K TPS target)", phase="Commissioning", planned_start=today + timedelta(days=40), planned_finish=today + timedelta(days=100), actual_start=None, actual_finish=None, completion_pct=0),
            # Data Warehouse (7)
            ProjectActivity(project_id=projects[7].id, activity_code="DW-001", activity_name="Data Model Design", phase="Design", planned_start=today - timedelta(days=160), planned_finish=today - timedelta(days=120), actual_start=today - timedelta(days=160), actual_finish=today - timedelta(days=118), completion_pct=100),
            ProjectActivity(project_id=projects[7].id, activity_code="DW-002", activity_name="Snowflake Setup & dbt Pipelines", phase="Construction", planned_start=today - timedelta(days=120), planned_finish=today - timedelta(days=50), actual_start=today - timedelta(days=118), actual_finish=today - timedelta(days=45), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[7].id, activity_code="DW-003", activity_name="Tableau Dashboard Development", phase="Construction", planned_start=today - timedelta(days=50), planned_finish=today + timedelta(days=30), actual_start=today - timedelta(days=45), actual_finish=None, completion_pct=60),
            ProjectActivity(project_id=projects[7].id, activity_code="DW-004", activity_name="Kafka Real-Time Streaming", phase="Construction", planned_start=today - timedelta(days=30), planned_finish=today + timedelta(days=60), actual_start=today - timedelta(days=25), actual_finish=None, completion_pct=35, is_critical=True),
            # Fraud Detection (8)
            ProjectActivity(project_id=projects[8].id, activity_code="FD-001", activity_name="Data Collection & Feature Engineering", phase="Design", planned_start=today - timedelta(days=60), planned_finish=today - timedelta(days=20), actual_start=today - timedelta(days=60), actual_finish=today - timedelta(days=18), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[8].id, activity_code="FD-002", activity_name="ML Model Training & Validation", phase="Construction", planned_start=today - timedelta(days=20), planned_finish=today + timedelta(days=60), actual_start=today - timedelta(days=18), actual_finish=None, completion_pct=30, is_critical=True),
            ProjectActivity(project_id=projects[8].id, activity_code="FD-003", activity_name="Real-Time Inference Pipeline", phase="Construction", planned_start=today + timedelta(days=60), planned_finish=today + timedelta(days=150), actual_start=None, actual_finish=None, completion_pct=0),
            # DevOps (9)
            ProjectActivity(project_id=projects[9].id, activity_code="DO-001", activity_name="GitHub Actions Pipeline Templates", phase="Design", planned_start=today - timedelta(days=110), planned_finish=today - timedelta(days=80), actual_start=today - timedelta(days=110), actual_finish=today - timedelta(days=78), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[9].id, activity_code="DO-002", activity_name="Terraform Module Library", phase="Construction", planned_start=today - timedelta(days=80), planned_finish=today - timedelta(days=40), actual_start=today - timedelta(days=78), actual_finish=today - timedelta(days=38), completion_pct=100),
            ProjectActivity(project_id=projects[9].id, activity_code="DO-003", activity_name="ArgoCD Deployment & Vault Setup", phase="Construction", planned_start=today - timedelta(days=40), planned_finish=today - timedelta(days=10), actual_start=today - timedelta(days=38), actual_finish=today - timedelta(days=8), completion_pct=100, is_critical=True),
            ProjectActivity(project_id=projects[9].id, activity_code="DO-004", activity_name="Team Onboarding & Documentation", phase="Commissioning", planned_start=today - timedelta(days=10), planned_finish=today + timedelta(days=20), actual_start=today - timedelta(days=8), actual_finish=today - timedelta(days=2), completion_pct=100),
        ]
        db.add_all(activities)
        db.flush()

        # ── Milestones ─────────────────────────────────────────
        milestones = [
            Milestone(project_id=projects[0].id, name="Design Sign-Off", phase="Design", planned_date=today - timedelta(days=100), actual_date=today - timedelta(days=95), is_critical=True),
            Milestone(project_id=projects[0].id, name="Data Migration Complete", phase="Construction", planned_date=today - timedelta(days=10), actual_date=None, is_critical=True),
            Milestone(project_id=projects[0].id, name="UAT Sign-Off", phase="Commissioning", planned_date=today + timedelta(days=180), actual_date=None, is_critical=True),
            Milestone(project_id=projects[0].id, name="Go-Live", phase="Commissioning", planned_date=today + timedelta(days=330), actual_date=None, is_critical=True),
            Milestone(project_id=projects[1].id, name="MVP Launch", phase="Construction", planned_date=today - timedelta(days=10), actual_date=None, is_critical=True),
            Milestone(project_id=projects[1].id, name="Full Rollout", phase="Commissioning", planned_date=today + timedelta(days=160), actual_date=None, is_critical=True),
            Milestone(project_id=projects[2].id, name="Landing Zone Ready", phase="Design", planned_date=today - timedelta(days=160), actual_date=today - timedelta(days=150), is_critical=True),
            Milestone(project_id=projects[2].id, name="Wave 1 Complete", phase="Construction", planned_date=today - timedelta(days=80), actual_date=today - timedelta(days=70), is_critical=False),
            Milestone(project_id=projects[2].id, name="All Apps Migrated", phase="Commissioning", planned_date=today + timedelta(days=60), actual_date=None, is_critical=True),
            Milestone(project_id=projects[2].id, name="On-Prem Decommissioned", phase="Commissioning", planned_date=today + timedelta(days=100), actual_date=None, is_critical=True),
            Milestone(project_id=projects[3].id, name="MFA Rollout Complete", phase="Construction", planned_date=today - timedelta(days=20), actual_date=today - timedelta(days=18), is_critical=True),
            Milestone(project_id=projects[3].id, name="Full Zero Trust Live", phase="Commissioning", planned_date=today + timedelta(days=250), actual_date=None, is_critical=True),
            Milestone(project_id=projects[4].id, name="Platform GA", phase="Construction", planned_date=today + timedelta(days=10), actual_date=None, is_critical=True),
            Milestone(project_id=projects[5].id, name="Beta Release", phase="Construction", planned_date=today - timedelta(days=20), actual_date=None, is_critical=True),
            Milestone(project_id=projects[5].id, name="App Store Launch", phase="Commissioning", planned_date=today + timedelta(days=80), actual_date=None, is_critical=True),
            Milestone(project_id=projects[6].id, name="PCI-DSS Certification", phase="Commissioning", planned_date=today + timedelta(days=100), actual_date=None, is_critical=True),
            Milestone(project_id=projects[7].id, name="Dashboard Go-Live", phase="Construction", planned_date=today + timedelta(days=30), actual_date=None, is_critical=True),
            Milestone(project_id=projects[8].id, name="Model Accuracy Validated", phase="Construction", planned_date=today + timedelta(days=60), actual_date=None, is_critical=True),
            Milestone(project_id=projects[9].id, name="All Teams Onboarded", phase="Commissioning", planned_date=today + timedelta(days=20), actual_date=today - timedelta(days=2), is_critical=True),
        ]
        db.add_all(milestones)
        db.flush()

        # ── CBS ────────────────────────────────────────────────
        cbs_items = [
            # ERP (0)
            CBS(project_id=projects[0].id, wbs_code="1.0", description="Project Management & PMO", budget_cost=420000, actual_cost=380000, forecast_cost=440000),
            CBS(project_id=projects[0].id, wbs_code="2.0", description="Requirements & Design", budget_cost=630000, actual_cost=610000, forecast_cost=650000),
            CBS(project_id=projects[0].id, wbs_code="3.0", description="Data Migration", budget_cost=840000, actual_cost=620000, forecast_cost=900000),
            CBS(project_id=projects[0].id, wbs_code="4.0", description="Development & Config", budget_cost=1260000, actual_cost=700000, forecast_cost=1350000),
            CBS(project_id=projects[0].id, wbs_code="5.0", description="Testing & QA", budget_cost=630000, actual_cost=50000, forecast_cost=680000),
            CBS(project_id=projects[0].id, wbs_code="6.0", description="Training & Go-Live", budget_cost=420000, actual_cost=0, forecast_cost=480000),
            # AWS Migration (2)
            CBS(project_id=projects[2].id, wbs_code="1.0", description="Discovery & Assessment", budget_cost=380000, actual_cost=350000, forecast_cost=380000),
            CBS(project_id=projects[2].id, wbs_code="2.0", description="Landing Zone & Networking", budget_cost=570000, actual_cost=560000, forecast_cost=590000),
            CBS(project_id=projects[2].id, wbs_code="3.0", description="Application Migration", budget_cost=2280000, actual_cost=1800000, forecast_cost=2500000, approved_variation=200000),
            CBS(project_id=projects[2].id, wbs_code="4.0", description="Optimization & Handover", budget_cost=570000, actual_cost=100000, forecast_cost=630000),
            # Mobile Banking (5)
            CBS(project_id=projects[5].id, wbs_code="1.0", description="UX Research & Design", budget_cost=350000, actual_cost=340000, forecast_cost=360000),
            CBS(project_id=projects[5].id, wbs_code="2.0", description="Core Banking API", budget_cost=1050000, actual_cost=980000, forecast_cost=1080000),
            CBS(project_id=projects[5].id, wbs_code="3.0", description="Mobile Development", budget_cost=1400000, actual_cost=1100000, forecast_cost=1500000),
            CBS(project_id=projects[5].id, wbs_code="4.0", description="Security & Compliance", budget_cost=350000, actual_cost=120000, forecast_cost=380000),
            CBS(project_id=projects[5].id, wbs_code="5.0", description="UAT & Launch", budget_cost=350000, actual_cost=0, forecast_cost=380000),
            # Payment Gateway (6)
            CBS(project_id=projects[6].id, wbs_code="1.0", description="Architecture & PCI Planning", budget_cost=390000, actual_cost=370000, forecast_cost=400000),
            CBS(project_id=projects[6].id, wbs_code="2.0", description="Engine Development", budget_cost=1300000, actual_cost=550000, forecast_cost=1400000),
            CBS(project_id=projects[6].id, wbs_code="3.0", description="Testing & Certification", budget_cost=910000, actual_cost=0, forecast_cost=950000),
            # Data Warehouse (7)
            CBS(project_id=projects[7].id, wbs_code="1.0", description="Data Modelling", budget_cost=330000, actual_cost=310000, forecast_cost=340000),
            CBS(project_id=projects[7].id, wbs_code="2.0", description="Snowflake & dbt", budget_cost=770000, actual_cost=720000, forecast_cost=800000),
            CBS(project_id=projects[7].id, wbs_code="3.0", description="Tableau Dashboards", budget_cost=550000, actual_cost=200000, forecast_cost=600000),
            CBS(project_id=projects[7].id, wbs_code="4.0", description="Kafka Streaming", budget_cost=550000, actual_cost=150000, forecast_cost=610000),
        ]
        db.add_all(cbs_items)
        db.flush()

        # ── Variations ────────────────────────────────────────
        variations = [
            ApprovedVariation(project_id=projects[0].id, variation_code="VO-001", description="Additional 30 custom reports requested by finance team", value=280000, cost_impact=280000, schedule_impact_days=20, approval_status="Approved", submitted_date=today - timedelta(days=60), approval_date=today - timedelta(days=45), approved_by="Client CIO"),
            ApprovedVariation(project_id=projects[0].id, variation_code="VO-002", description="SAP Fiori UX enhancements for mobile access", value=150000, cost_impact=150000, schedule_impact_days=10, approval_status="Pending", submitted_date=today - timedelta(days=15)),
            ApprovedVariation(project_id=projects[2].id, variation_code="VO-001", description="10 additional legacy apps added to migration scope", value=450000, cost_impact=450000, schedule_impact_days=25, approval_status="Approved", submitted_date=today - timedelta(days=80), approval_date=today - timedelta(days=60), approved_by="Cloud Director"),
            ApprovedVariation(project_id=projects[2].id, variation_code="VO-002", description="Multi-region DR setup for critical apps", value=320000, cost_impact=320000, schedule_impact_days=15, approval_status="Under Review", submitted_date=today - timedelta(days=20)),
            ApprovedVariation(project_id=projects[5].id, variation_code="VO-001", description="Apple Watch companion app addition", value=200000, cost_impact=200000, schedule_impact_days=18, approval_status="Approved", submitted_date=today - timedelta(days=50), approval_date=today - timedelta(days=35), approved_by="Product Owner"),
            ApprovedVariation(project_id=projects[6].id, variation_code="VO-001", description="Crypto payment support added to scope", value=380000, cost_impact=380000, schedule_impact_days=30, approval_status="Pending", submitted_date=today - timedelta(days=10)),
            ApprovedVariation(project_id=projects[7].id, variation_code="VO-001", description="Additional 15 Tableau dashboards for marketing", value=120000, cost_impact=120000, schedule_impact_days=12, approval_status="Approved", submitted_date=today - timedelta(days=40), approval_date=today - timedelta(days=28), approved_by="CMO"),
        ]
        db.add_all(variations)
        db.flush()

        # ── Compensation Events ────────────────────────────────
        ce_items = [
            CompensationEvent(project_id=projects[0].id, event_name="SAP license delivery delay (vendor issue)", linked_wbs="4.0", time_impact_days=12, daily_overhead_cost=4000, status="Approved"),
            CompensationEvent(project_id=projects[0].id, event_name="Client data freeze delayed by 3 weeks", linked_wbs="3.0", time_impact_days=21, daily_overhead_cost=4000, status="Pending"),
            CompensationEvent(project_id=projects[2].id, event_name="AWS region outage during Wave 2 migration", linked_wbs="3.0", time_impact_days=5, daily_overhead_cost=6000, status="Approved"),
            CompensationEvent(project_id=projects[2].id, event_name="Legacy app undocumented dependencies discovered", linked_wbs="3.0", time_impact_days=18, daily_overhead_cost=6000, status="Pending"),
            CompensationEvent(project_id=projects[5].id, event_name="Open banking API spec change by regulator", linked_wbs="2.0", time_impact_days=14, daily_overhead_cost=5000, status="Approved"),
        ]
        db.add_all(ce_items)
        db.flush()

        # ── Milestone Payments ─────────────────────────────────
        payments = [
            MilestonePayment(milestone_id=milestones[0].id, payment_percentage=10, payment_value=480000, invoice_number="INV-ERP-001", invoice_date=today - timedelta(days=90), payment_status="Received"),
            MilestonePayment(milestone_id=milestones[1].id, payment_percentage=20, payment_value=960000, invoice_number=None, payment_status="Pending"),
            MilestonePayment(milestone_id=milestones[6].id, payment_percentage=10, payment_value=420000, invoice_number="INV-AWS-001", invoice_date=today - timedelta(days=145), payment_status="Received"),
            MilestonePayment(milestone_id=milestones[7].id, payment_percentage=25, payment_value=1050000, invoice_number="INV-AWS-002", invoice_date=today - timedelta(days=65), payment_status="Received"),
            MilestonePayment(milestone_id=milestones[8].id, payment_percentage=30, payment_value=1260000, invoice_number=None, payment_status="Pending"),
            MilestonePayment(milestone_id=milestones[13].id, payment_percentage=15, payment_value=600000, invoice_number=None, payment_status="Pending"),
            MilestonePayment(milestone_id=milestones[18].id, payment_percentage=100, payment_value=1100000, invoice_number="INV-DO-001", invoice_date=today - timedelta(days=1), payment_status="Received"),
        ]
        db.add_all(payments)
        db.flush()

        # ── Risks ──────────────────────────────────────────────
        risks = [
            Risk(project_id=projects[0].id, risk_code="R-001", title="Data quality issues in legacy system", description="Source data in SAP R/3 has inconsistencies that may cause migration failures", category="Technical", probability=4, impact=4, mitigation_plan="Run data profiling tool, allocate 3-week cleansing sprint", owner="Alex Johnson", status="Open", cost_exposure=350000),
            Risk(project_id=projects[0].id, risk_code="R-002", title="Key SME availability during UAT", description="Business users may be unavailable for 6-week UAT window", category="Resource", probability=3, impact=4, mitigation_plan="Pre-book UAT resources, stagger testing by module", owner="Sarah Williams", status="Open", cost_exposure=200000),
            Risk(project_id=projects[2].id, risk_code="R-001", title="Application compatibility with AWS", description="Legacy .NET Framework apps may need significant refactoring", category="Technical", probability=4, impact=3, mitigation_plan="Run AWS Migration Hub assessment, identify refactor candidates early", owner="Alex Johnson", status="Open", cost_exposure=500000),
            Risk(project_id=projects[2].id, risk_code="R-002", title="Network latency post-migration", description="Hybrid connectivity may not meet SLA for latency-sensitive apps", category="Technical", probability=3, impact=5, mitigation_plan="Deploy Direct Connect, perform latency testing in pilot", owner="Mike Chen", status="Open", cost_exposure=300000),
            Risk(project_id=projects[3].id, risk_code="R-001", title="Staff resistance to MFA adoption", description="Clinical staff may resist mandatory MFA on shared devices", category="Resource", probability=4, impact=3, mitigation_plan="Phased rollout with champions programme, FIDO2 keys for shared devices", owner="Mike Chen", status="Mitigated", cost_exposure=150000),
            Risk(project_id=projects[4].id, risk_code="R-001", title="Cluster scaling limits under peak load", description="AKS cluster may hit Azure quota limits during traffic spikes", category="Technical", probability=2, impact=4, mitigation_plan="Pre-request quota increases, implement HPA and cluster autoscaler", owner="Alex Johnson", status="Open", cost_exposure=200000),
            Risk(project_id=projects[5].id, risk_code="R-001", title="App store rejection due to compliance", description="Apple/Google may reject app for financial services compliance issues", category="Legal", probability=3, impact=5, mitigation_plan="Engage Apple/Google developer relations early, pre-submission review", owner="Sarah Williams", status="Open", cost_exposure=400000),
            Risk(project_id=projects[5].id, risk_code="R-002", title="Biometric auth device fragmentation", description="Fingerprint/face recognition may fail on older Android devices", category="Technical", probability=3, impact=3, mitigation_plan="Test on top 20 device models, provide PIN fallback", owner="Alex Johnson", status="Open", cost_exposure=100000),
            Risk(project_id=projects[6].id, risk_code="R-001", title="PCI-DSS audit failure", description="First audit attempt may identify non-conformances delaying launch", category="Legal", probability=3, impact=5, mitigation_plan="Engage QSA for pre-audit assessment, remediate findings early", owner="Mike Chen", status="Open", cost_exposure=600000),
            Risk(project_id=projects[7].id, risk_code="R-001", title="Snowflake cost overrun", description="Compute credits may exceed budget with complex dbt models", category="Commercial", probability=4, impact=3, mitigation_plan="Implement resource monitors, optimize warehouse sizing", owner="Sarah Williams", status="Open", cost_exposure=180000),
            Risk(project_id=projects[8].id, risk_code="R-001", title="Model accuracy below 99.7% target", description="False positive rate may be too high for production use", category="Technical", probability=3, impact=5, mitigation_plan="Ensemble model approach, A/B testing with existing rules engine", owner="Mike Chen", status="Open", cost_exposure=500000),
            Risk(project_id=projects[8].id, risk_code="R-002", title="Training data bias", description="Historical fraud data may contain demographic bias", category="Legal", probability=3, impact=4, mitigation_plan="Fairness testing framework, bias audit by external consultancy", owner="Alex Johnson", status="Open", cost_exposure=250000),
        ]
        db.add_all(risks)
        db.flush()

        # ── Issues ─────────────────────────────────────────────
        issues = [
            Issue(project_id=projects[0].id, issue_code="ISS-001", title="SAP transport conflicts between dev and QA", description="Multiple developers overwriting each other's transports", priority="High", assigned_to="Tech Lead", raised_by="Dev Team", raised_date=today - timedelta(days=12), due_date=today - timedelta(days=2), status="Open"),
            Issue(project_id=projects[0].id, issue_code="ISS-002", title="Legacy data mapping incomplete for GL accounts", description="30% of GL accounts have no mapping to S/4HANA chart of accounts", priority="Critical", assigned_to="Data Architect", raised_by="Finance BA", raised_date=today - timedelta(days=5), due_date=today + timedelta(days=5), status="In Progress"),
            Issue(project_id=projects[2].id, issue_code="ISS-001", title="VPN throughput bottleneck during migration", description="Site-to-site VPN maxing out at 500Mbps during bulk data transfer", priority="High", assigned_to="Network Engineer", raised_by="Migration Lead", raised_date=today - timedelta(days=8), due_date=today + timedelta(days=3), status="Open"),
            Issue(project_id=projects[2].id, issue_code="ISS-002", title="Oracle DB license non-transferable to cloud", description="Oracle licensing prohibits running on AWS EC2 without re-licensing", priority="Critical", assigned_to="Procurement", raised_by="Cloud Architect", raised_date=today - timedelta(days=20), due_date=today - timedelta(days=10), status="In Progress"),
            Issue(project_id=projects[3].id, issue_code="ISS-001", title="Legacy RADIUS server incompatible with Azure AD", description="3 hospital sites use RADIUS auth that doesn't support SAML federation", priority="Medium", assigned_to="Identity Engineer", raised_by="Site IT Manager", raised_date=today - timedelta(days=15), due_date=today + timedelta(days=10), status="Open"),
            Issue(project_id=projects[5].id, issue_code="ISS-001", title="Push notification delivery rate below 90%", description="Firebase FCM delivery unreliable on Huawei devices (no GMS)", priority="Medium", assigned_to="Mobile Dev Lead", raised_by="QA Team", raised_date=today - timedelta(days=7), due_date=today + timedelta(days=14), status="Open"),
            Issue(project_id=projects[5].id, issue_code="ISS-002", title="Open banking API rate limiting", description="Bank API returns 429 errors during peak testing at 100 req/s", priority="High", assigned_to="API Engineer", raised_by="Performance Tester", raised_date=today - timedelta(days=3), due_date=today + timedelta(days=7), status="In Progress"),
            Issue(project_id=projects[6].id, issue_code="ISS-001", title="Card scheme certification delay", description="Visa certification slot pushed back by 4 weeks", priority="High", assigned_to="Compliance Lead", raised_by="PM", raised_date=today - timedelta(days=5), due_date=today + timedelta(days=30), status="Open"),
            Issue(project_id=projects[7].id, issue_code="ISS-001", title="dbt model run time exceeding 4-hour SLA", description="Full refresh taking 6+ hours due to complex joins on fact tables", priority="High", assigned_to="Data Engineer", raised_by="BI Analyst", raised_date=today - timedelta(days=6), due_date=today + timedelta(days=5), status="In Progress"),
            Issue(project_id=projects[8].id, issue_code="ISS-001", title="GPU cluster provisioning delayed", description="Azure GPU quota request pending approval for 2+ weeks", priority="Critical", assigned_to="Cloud Ops", raised_by="ML Engineer", raised_date=today - timedelta(days=14), due_date=today - timedelta(days=4), status="Open"),
        ]
        db.add_all(issues)
        db.flush()

        # ── Safety Incidents (IT workspace safety) ─────────────
        incidents = [
            SafetyIncident(project_id=projects[0].id, incident_type="Observation", severity="Minor", reported_date=today - timedelta(days=30), resolved_date=today - timedelta(days=28), status="Closed", penalty_cost=0, description="Trailing cables across walkway in server room", lost_time_hours=0, location="Data Centre Floor 2", reported_by="Facilities"),
            SafetyIncident(project_id=projects[2].id, incident_type="Observation", severity="Minor", reported_date=today - timedelta(days=20), resolved_date=today - timedelta(days=18), status="Closed", penalty_cost=0, description="Emergency exit blocked by decommissioned hardware", lost_time_hours=0, location="Server Room B", reported_by="HSE Officer"),
            SafetyIncident(project_id=projects[2].id, incident_type="Near Miss", severity="Moderate", reported_date=today - timedelta(days=10), status="Under Investigation", penalty_cost=0, description="UPS overheating detected before failure during migration window", lost_time_hours=4, location="Data Centre", reported_by="DC Operator"),
            SafetyIncident(project_id=projects[3].id, incident_type="Observation", severity="Minor", reported_date=today - timedelta(days=15), resolved_date=today - timedelta(days=14), status="Resolved", penalty_cost=0, description="Ergonomic issue - adjustable desks not provided for site deployment team", lost_time_hours=0, location="Hospital Site 12", reported_by="Team Lead"),
            SafetyIncident(project_id=projects[4].id, incident_type="Injury", severity="Minor", reported_date=today - timedelta(days=5), resolved_date=today - timedelta(days=4), status="Closed", penalty_cost=0, description="Developer reported RSI symptoms from extended keyboard use", lost_time_hours=8, location="Office - Floor 3", reported_by="Line Manager"),
            SafetyIncident(project_id=projects[5].id, incident_type="Near Miss", severity="Minor", reported_date=today - timedelta(days=8), resolved_date=today - timedelta(days=7), status="Resolved", penalty_cost=0, description="Unsecured laptop with production credentials left in meeting room", lost_time_hours=0, location="Metro Bank HQ", reported_by="Security Guard"),
            SafetyIncident(project_id=projects[7].id, incident_type="Environmental", severity="Minor", reported_date=today - timedelta(days=12), status="Open", penalty_cost=0, description="E-waste from decommissioned servers not disposed per WEEE regulations", lost_time_hours=0, location="Tesco DC", reported_by="Environmental Officer"),
        ]
        db.add_all(incidents)
        db.flush()

        # ── HSE Checklist ──────────────────────────────────────
        hse_items = [
            HSEChecklist(project_id=projects[0].id, checklist_item="DSE assessment completed for all team members", category="Ergonomics", status="Completed", last_inspection_date=today - timedelta(days=10), inspector="Mike Chen"),
            HSEChecklist(project_id=projects[0].id, checklist_item="Data centre access control list reviewed", category="Physical Security", status="Completed", last_inspection_date=today - timedelta(days=5), inspector="Security Lead"),
            HSEChecklist(project_id=projects[2].id, checklist_item="Fire suppression system tested in server room", category="Fire Safety", status="Completed", last_inspection_date=today - timedelta(days=15), inspector="Facilities Manager"),
            HSEChecklist(project_id=projects[2].id, checklist_item="Cable management audit in data centre", category="Electrical Safety", status="In Progress", last_inspection_date=today - timedelta(days=3), inspector="DC Technician"),
            HSEChecklist(project_id=projects[2].id, checklist_item="UPS battery replacement schedule current", category="Electrical Safety", status="Failed", last_inspection_date=today - timedelta(days=10), inspector="DC Operator", notes="3 UPS units past replacement date - ordered replacements"),
            HSEChecklist(project_id=projects[3].id, checklist_item="Lone worker policy for hospital site visits", category="Lone Working", status="Completed", last_inspection_date=today - timedelta(days=8), inspector="Mike Chen"),
            HSEChecklist(project_id=projects[3].id, checklist_item="DBS checks for hospital site access", category="Personnel", status="Completed", last_inspection_date=today - timedelta(days=20), inspector="HR"),
            HSEChecklist(project_id=projects[4].id, checklist_item="Ergonomic workstation setup for dev team", category="Ergonomics", status="Completed", last_inspection_date=today - timedelta(days=4), inspector="Facilities"),
            HSEChecklist(project_id=projects[5].id, checklist_item="Secure disposal of test devices with bank data", category="Data Security", status="Pending"),
            HSEChecklist(project_id=projects[6].id, checklist_item="PCI-DSS physical security controls verified", category="Physical Security", status="Completed", last_inspection_date=today - timedelta(days=7), inspector="QSA Auditor"),
            HSEChecklist(project_id=projects[7].id, checklist_item="E-waste disposal procedure in place", category="Environmental", status="Pending"),
            HSEChecklist(project_id=projects[8].id, checklist_item="GPU server room cooling adequate", category="Environmental", status="Completed", last_inspection_date=today - timedelta(days=6), inspector="DC Manager"),
        ]
        db.add_all(hse_items)
        db.flush()

        # ── Documents ──────────────────────────────────────────
        documents = [
            Document(project_id=projects[0].id, doc_code="SDD-ERP-001", title="S/4HANA Solution Design Document", category="Specification", revision="C", status="Approved", uploaded_by="Solution Architect"),
            Document(project_id=projects[0].id, doc_code="DMP-ERP-001", title="Data Migration Plan", category="Report", revision="B", status="Approved", uploaded_by="Data Architect"),
            Document(project_id=projects[0].id, doc_code="TP-ERP-001", title="Integration Test Plan", category="Report", revision="A", status="Under Review", uploaded_by="QA Lead"),
            Document(project_id=projects[2].id, doc_code="ARC-AWS-001", title="AWS Target Architecture", category="Drawing", revision="D", status="Approved", uploaded_by="Cloud Architect"),
            Document(project_id=projects[2].id, doc_code="RUN-AWS-001", title="Cloud Runbook & Playbooks", category="Method Statement", revision="B", status="Under Review", uploaded_by="DevOps Lead"),
            Document(project_id=projects[3].id, doc_code="RA-ZT-001", title="Zero Trust Risk Assessment", category="Risk Assessment", revision="A", status="Approved", uploaded_by="Security Architect"),
            Document(project_id=projects[3].id, doc_code="HLD-ZT-001", title="Network Segmentation Design", category="Drawing", revision="B", status="Approved", uploaded_by="Network Architect"),
            Document(project_id=projects[5].id, doc_code="PRD-MB-001", title="Mobile App PRD", category="Specification", revision="E", status="Approved", uploaded_by="Product Owner"),
            Document(project_id=projects[5].id, doc_code="SEC-MB-001", title="Penetration Test Report", category="Report", revision="A", status="Draft", uploaded_by="Security Consultant"),
            Document(project_id=projects[6].id, doc_code="PCI-PG-001", title="PCI-DSS Compliance Matrix", category="Contract", revision="A", status="Under Review", uploaded_by="Compliance Lead"),
            Document(project_id=projects[7].id, doc_code="DM-DW-001", title="Snowflake Data Model ERD", category="Drawing", revision="C", status="Approved", uploaded_by="Data Engineer"),
            Document(project_id=projects[8].id, doc_code="MLD-FD-001", title="ML Model Design Document", category="Specification", revision="A", status="Approved", uploaded_by="ML Engineer"),
            Document(project_id=projects[9].id, doc_code="STD-DO-001", title="CI/CD Standards & Guidelines", category="Specification", revision="B", status="Approved", uploaded_by="DevOps Lead"),
            Document(project_id=projects[9].id, doc_code="COR-DO-001", title="Team Onboarding Correspondence", category="Correspondence", revision="A", status="Approved", uploaded_by="Alex Johnson"),
        ]
        db.add_all(documents)

        db.commit()
        print("Database seeded successfully with IT project demo data!")
    except Exception as e:
        db.rollback()
        print(f"Seeding failed: {e}")
        sys.exit(1)
    finally:
        db.close()


if __name__ == "__main__":
    seed()
