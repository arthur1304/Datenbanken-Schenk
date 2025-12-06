-- Optional: zuerst alles löschen (richtige Reihenfolge wegen FK-Abhängigkeiten)
DROP TABLE IF EXISTS work_schedule;
DROP TABLE IF EXISTS assignments;
DROP TABLE IF EXISTS project_kpis;
DROP TABLE IF EXISTS actual_costs;
DROP TABLE IF EXISTS project_baselines;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS roles;

--------------------------------------------------
-- 1) Rollen
--------------------------------------------------
CREATE TABLE roles (
    RoleID                      INTEGER       PRIMARY KEY,
    RoleName                    VARCHAR(255)  NOT NULL,
    DefaultCapacityHoursPerWeek INTEGER       NOT NULL
);

--------------------------------------------------
-- 2) Standorte
--------------------------------------------------
CREATE TABLE locations (
    LocationID   INTEGER       PRIMARY KEY,
    LocationName VARCHAR(255)  NOT NULL,
    Country      VARCHAR(255)  NOT NULL,
    Tier         VARCHAR(255)
);

--------------------------------------------------
-- 3) Kunden
--------------------------------------------------
CREATE TABLE customers (
    CustomerID   INTEGER       PRIMARY KEY,
    CustomerName VARCHAR(255)  NOT NULL,
    Industry     VARCHAR(255)
);

--------------------------------------------------
-- 4) Mitarbeiter
--------------------------------------------------
CREATE TABLE employees (
    EmployeeID  INTEGER       PRIMARY KEY,
    EmployeeName VARCHAR(255) NOT NULL,
    RoleID      INTEGER       NOT NULL,
    LocationID  INTEGER       NOT NULL,
    HireDate    DATE,
    ActiveFlag  BOOLEAN       NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_employees_role
        FOREIGN KEY (RoleID) REFERENCES roles (RoleID),
    CONSTRAINT fk_employees_location
        FOREIGN KEY (LocationID) REFERENCES locations (LocationID)
);

--------------------------------------------------
-- 5) Projekte
--------------------------------------------------
CREATE TABLE projects (
    ProjectID         INTEGER       PRIMARY KEY,
    ProjectName       VARCHAR(255)  NOT NULL,
    CustomerID        INTEGER       NOT NULL,
    ProjectManagerID  INTEGER       NOT NULL,
    Status            VARCHAR(255)  NOT NULL,
    ProjectType       VARCHAR(255),
    StartDatePlanned  DATE,
    EndDatePlanned    DATE,
    StartDateActual   DATE,
    EndDateActual     DATE,
    CONSTRAINT fk_projects_customer
        FOREIGN KEY (CustomerID) REFERENCES customers (CustomerID),
    CONSTRAINT fk_projects_projectmanager
        FOREIGN KEY (ProjectManagerID) REFERENCES employees (EmployeeID)
);

--------------------------------------------------
-- 6) Projekt-Baselines (Planwerte)
--------------------------------------------------
CREATE TABLE project_baselines (
    BaselineID         INTEGER       PRIMARY KEY,
    ProjectID          INTEGER       NOT NULL,
    VersionNr          INTEGER       NOT NULL,
    PlannedBudgetTotal NUMERIC(18,2),
    PlannedEndDate     DATE,
    IsActive           BOOLEAN       NOT NULL DEFAULT FALSE,
    ValidFrom          DATE,
    ValidTo            DATE,
    CONSTRAINT fk_baselines_project
        FOREIGN KEY (ProjectID) REFERENCES projects (ProjectID)
);

--------------------------------------------------
-- 7) Ist-Kosten
--------------------------------------------------
CREATE TABLE actual_costs (
    CostID     INTEGER       PRIMARY KEY,
    ProjectID  INTEGER       NOT NULL,
    CostDate   DATE          NOT NULL,
    CostType   VARCHAR(255)  NOT NULL,
    Amount     NUMERIC(18,2) NOT NULL,
    CostCenter VARCHAR(255),
    CONSTRAINT fk_costs_project
        FOREIGN KEY (ProjectID) REFERENCES projects (ProjectID)
);

--------------------------------------------------
-- 8) Projekt-KPIs (Snapshots)
--------------------------------------------------
CREATE TABLE project_kpis (
    KpiID             INTEGER       PRIMARY KEY,
    ProjectID         INTEGER       NOT NULL,
    SnapshotDate      DATE          NOT NULL,
    SPI               NUMERIC(10,4),
    CPI               NUMERIC(10,4),
    SV_Days           INTEGER,
    CV_Amount         NUMERIC(18,2),
    CompletionPercent INTEGER,
    CONSTRAINT fk_kpis_project
        FOREIGN KEY (ProjectID) REFERENCES projects (ProjectID)
);

--------------------------------------------------
-- 9) Assignments (n:m Employees <-> Projects)
--------------------------------------------------
CREATE TABLE assignments (
    AssignmentID INTEGER  PRIMARY KEY,
    EmployeeID   INTEGER  NOT NULL,
    ProjectID    INTEGER  NOT NULL,
    Date         DATE     NOT NULL,
    PlannedHours INTEGER  NOT NULL,
    CONSTRAINT fk_assignments_employee
        FOREIGN KEY (EmployeeID) REFERENCES employees (EmployeeID),
    CONSTRAINT fk_assignments_project
        FOREIGN KEY (ProjectID)  REFERENCES projects (ProjectID)
);

--------------------------------------------------
-- 10) Work Schedule (Zeitdimension / Kapazität)
--------------------------------------------------
CREATE TABLE work_schedule (
    ScheduleID     INTEGER  PRIMARY KEY,
    EmployeeID     INTEGER  NOT NULL,
    Date           DATE     NOT NULL,
    AvailableHours INTEGER  NOT NULL,
    IsHoliday      BOOLEAN  NOT NULL DEFAULT FALSE,
    IsVacation     BOOLEAN  NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_work_schedule_employee
        FOREIGN KEY (EmployeeID) REFERENCES employees (EmployeeID)
);
