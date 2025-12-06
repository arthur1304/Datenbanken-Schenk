SELECT 'roles' AS table_name, COUNT(*) AS row_count FROM roles
UNION ALL
SELECT 'locations', COUNT(*) FROM locations
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'projects', COUNT(*) FROM projects
UNION ALL
SELECT 'project_baselines', COUNT(*) FROM project_baselines
UNION ALL
SELECT 'actual_costs', COUNT(*) FROM actual_costs
UNION ALL
SELECT 'project_kpis', COUNT(*) FROM project_kpis
UNION ALL
SELECT 'assignments', COUNT(*) FROM assignments
UNION ALL
SELECT 'work_schedule', COUNT(*) FROM work_schedule;
