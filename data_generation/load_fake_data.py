import sys
import random
from datetime import date, timedelta

import psycopg2
from faker import Faker

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "projektdb",
    "user": "projektuser",
    "password": "projektpass",
}

fake = Faker("de_DE")


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def truncate_all(cur):
    # Reihenfolge egal dank CASCADE
    cur.execute("""
        TRUNCATE TABLE
            work_schedule,
            assignments,
            project_kpis,
            actual_costs,
            project_baselines,
            projects,
            employees,
            customers,
            locations,
            roles
        RESTART IDENTITY CASCADE;
    """)


def generate_data(scale: str):
    if scale == "small":
        n_roles = 5
        n_locations = 5
        n_customers = 50
        n_employees = 50
        n_projects = 30
        days_schedule = 90  # ~3 Monate
        costs_per_project = 10
        kpis_per_project = 10
        assignments_total = 3000
        work_schedule_rows = 5000
    elif scale == "large":
        n_roles = 5
        n_locations = 10
        n_customers = 500
        n_employees = 200
        n_projects = 200
        days_schedule = 365
        costs_per_project = 200
        kpis_per_project = 100
        assignments_total = 100_000
        work_schedule_rows = 73_000  # grob 365*200
    else:
        raise ValueError("scale must be 'small' or 'large'")

    conn = get_connection()
    cur = conn.cursor()

    print(f"TRUNCATE existing data...")
    truncate_all(cur)

    # ----------------- roles -----------------
    print("Insert roles...")
    role_names = [
        "Project Manager",
        "Developer",
        "Business Analyst",
        "QA Engineer",
        "DevOps Engineer",
    ]
    for role_id in range(1, n_roles + 1):
        name = role_names[(role_id - 1) % len(role_names)]
        default_hours = 40
        cur.execute(
            "INSERT INTO roles (RoleID, RoleName, DefaultCapacityHoursPerWeek) "
            "VALUES (%s, %s, %s)",
            (role_id, name, default_hours),
        )

    # ----------------- locations -----------------
    print("Insert locations...")
    for loc_id in range(1, n_locations + 1):
        cur.execute(
            "INSERT INTO locations (LocationID, LocationName, Country, Tier) "
            "VALUES (%s, %s, %s, %s)",
            (
                loc_id,
                fake.city(),
                fake.country(),
                random.choice(["A", "B", "C"]),
            ),
        )

    # ----------------- customers -----------------
    print("Insert customers...")
    for cust_id in range(1, n_customers + 1):
        cur.execute(
            "INSERT INTO customers (CustomerID, CustomerName, Industry) "
            "VALUES (%s, %s, %s)",
            (
                cust_id,
                fake.company(),
                random.choice(
                    ["IT", "Manufacturing", "Retail", "Healthcare", "Finance"]
                ),
            ),
        )

    # ----------------- employees -----------------
    print("Insert employees...")
    pm_role_id = 1  # Project Manager
    pm_employee_ids = []
    for emp_id in range(1, n_employees + 1):
        # 15% PMs, Rest andere Rollen
        if random.random() < 0.15:
            role_id = pm_role_id
            pm_employee_ids.append(emp_id)
        else:
            role_id = random.randint(2, n_roles)  # keine PM-Rolle
        loc_id = random.randint(1, n_locations)
        hire_date = fake.date_between(start_date="-5y", end_date="-30d")
        active = True

        cur.execute(
            "INSERT INTO employees (EmployeeID, EmployeeName, RoleID, LocationID, HireDate, ActiveFlag) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            (emp_id, fake.name(), role_id, loc_id, hire_date, active),
        )

    # Falls keine PM erzeugt wurde (extrem unwahrscheinlich), fallback:
    if not pm_employee_ids:
        pm_employee_ids = [1]

    # ----------------- projects -----------------
    print("Insert projects...")
    project_ids = []
    base_start = date.today() - timedelta(days=180)
    for proj_id in range(1, n_projects + 1):
        name = f"Projekt {proj_id}"
        customer_id = random.randint(1, n_customers)
        pm_id = random.choice(pm_employee_ids)
        status = random.choice(["Planned", "In Progress", "On Hold", "Completed"])
        ptype = random.choice(["Client", "Internal", "R&D"])

        start_planned = base_start + timedelta(days=random.randint(0, 120))
        duration_days = random.randint(60, 240)
        end_planned = start_planned + timedelta(days=duration_days)

        if status in ("In Progress", "Completed"):
            start_actual = start_planned + timedelta(days=random.randint(-10, 10))
            end_actual = (
                start_actual + timedelta(days=duration_days + random.randint(-20, 40))
                if status == "Completed"
                else None
            )
        else:
            start_actual = None
            end_actual = None

        cur.execute(
            """
            INSERT INTO projects (
                ProjectID, ProjectName, CustomerID, ProjectManagerID, Status,
                ProjectType, StartDatePlanned, EndDatePlanned,
                StartDateActual, EndDateActual
            )
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """,
            (
                proj_id,
                name,
                customer_id,
                pm_id,
                status,
                ptype,
                start_planned,
                end_planned,
                start_actual,
                end_actual,
            ),
        )
        project_ids.append(proj_id)

    # ----------------- project_baselines -----------------
    print("Insert project_baselines...")
    baseline_id = 1
    for proj_id in project_ids:
        planned_budget = random.randint(50_000, 500_000)
        planned_end = fake.date_between(start_date="+30d", end_date="+365d")
        valid_from = fake.date_between(start_date="-200d", end_date="-100d")
        valid_to = fake.date_between(start_date="-99d", end_date="-1d")
        is_active = True

        cur.execute(
            """
            INSERT INTO project_baselines (
                BaselineID, ProjectID, VersionNr, PlannedBudgetTotal,
                PlannedEndDate, IsActive, ValidFrom, ValidTo
            )
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """,
            (
                baseline_id,
                proj_id,
                1,
                planned_budget,
                planned_end,
                is_active,
                valid_from,
                valid_to,
            ),
        )
        baseline_id += 1

    # ----------------- actual_costs -----------------
    print("Insert actual_costs...")
    cost_id = 1
    for proj_id in project_ids:
        for _ in range(costs_per_project):
            cost_date = fake.date_between(start_date="-180d", end_date="today")
            cost_type = random.choice(
                ["Personnel", "Travel", "Software", "Hardware", "Other"]
            )
            amount = round(random.uniform(500, 20_000), 2)
            cost_center = f"CC-{random.randint(100,999)}"
            cur.execute(
                """
                INSERT INTO actual_costs (
                    CostID, ProjectID, CostDate, CostType, Amount, CostCenter
                )
                VALUES (%s,%s,%s,%s,%s,%s)
                """,
                (cost_id, proj_id, cost_date, cost_type, amount, cost_center),
            )
            cost_id += 1

    # ----------------- project_kpis -----------------
    print("Insert project_kpis...")
    kpi_id = 1
    for proj_id in project_ids:
        base_snapshot = date.today() - timedelta(days=90)
        for i in range(kpis_per_project):
            snap_date = base_snapshot + timedelta(days=i * 3)
            # SPI/CPI um 1 herum
            spi = round(random.uniform(0.7, 1.3), 3)
            cpi = round(random.uniform(0.7, 1.3), 3)
            sv_days = random.randint(-60, 60)
            cv_amount = round(random.uniform(-100_000, 100_000), 2)
            completion = max(0, min(100, int((i / kpis_per_project) * 100)))

            cur.execute(
                """
                INSERT INTO project_kpis (
                    KpiID, ProjectID, SnapshotDate,
                    SPI, CPI, SV_Days, CV_Amount, CompletionPercent
                )
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
                """,
                (
                    kpi_id,
                    proj_id,
                    snap_date,
                    spi,
                    cpi,
                    sv_days,
                    cv_amount,
                    completion,
                ),
            )
            kpi_id += 1

    # ----------------- assignments -----------------
    print("Insert assignments...")
    assignment_id = 1
    # wir verteilen assignments_total zufällig
    for _ in range(assignments_total):
        emp_id = random.randint(1, n_employees)
        proj_id = random.choice(project_ids)
        assign_date = fake.date_between(start_date="-90d", end_date="+90d")
        hours = random.randint(1, 8)
        cur.execute(
            """
            INSERT INTO assignments (
                AssignmentID, EmployeeID, ProjectID, Date, PlannedHours
            )
            VALUES (%s,%s,%s,%s,%s)
            """,
            (assignment_id, emp_id, proj_id, assign_date, hours),
        )
        assignment_id += 1

    # ----------------- work_schedule -----------------
    print("Insert work_schedule...")
    schedule_id = 1
    start_schedule = date.today() - timedelta(days=days_schedule // 2)
    employees_ids = list(range(1, n_employees + 1))

    for _ in range(work_schedule_rows):
        emp_id = random.choice(employees_ids)
        day_offset = random.randint(0, days_schedule - 1)
        d = start_schedule + timedelta(days=day_offset)

        is_holiday = random.random() < 0.03
        is_vacation = (not is_holiday) and (random.random() < 0.05)
        if is_holiday or is_vacation:
            available_hours = 0
        else:
            available_hours = random.choice([6, 7, 8])

        cur.execute(
            """
            INSERT INTO work_schedule (
                ScheduleID, EmployeeID, Date,
                AvailableHours, IsHoliday, IsVacation
            )
            VALUES (%s,%s,%s,%s,%s,%s)
            """,
            (schedule_id, emp_id, d, available_hours, is_holiday, is_vacation),
        )
        schedule_id += 1

    print("Commit...")
    conn.commit()
    cur.close()
    conn.close()
    print("Done.")


if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in ("small", "large"):
        print("Usage: python load_fake_data.py [small|large]")
        sys.exit(1)
    generate_data(sys.argv[1])
