-- This SQL script creates indexes to optimize query performance on various tables.
-- -- The indexes are ment for query 1 optimization.
CREATE INDEX idx_assignments_empid_date 
ON assignments(EmployeeID, Date);

CREATE INDEX idx_workschedule_empid_date 
ON work_schedule(EmployeeID, Date) 
WHERE IsHoliday = FALSE AND IsVacation = FALSE;

CREATE INDEX idx_employees_roleid 
ON employees(RoleID);

-- The indexes are ment for query 2 optimization.
CREATE INDEX idx_project_kpis_projectid ON project_kpis(ProjectID);

-- The indexes are ment for query 3 optimization.
CREATE INDEX idx_actual_costs_projectid 
ON actual_costs(ProjectID, Amount, CostType);

CREATE INDEX idx_baselines_project_active_budget 
ON project_baselines(ProjectID, IsActive, PlannedBudgetTotal) 
WHERE IsActive = TRUE;

CREATE INDEX idx_projects_status_customer 
ON projects(Status, ProjectID, CustomerID) 
WHERE Status = 'In Progress';