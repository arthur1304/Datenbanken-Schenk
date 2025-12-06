SELECT 'employees -> roles' AS relation, COUNT(*) AS orphan_count
FROM employees e LEFT JOIN roles r ON e.roleid = r.roleid
WHERE r.roleid IS NULL

UNION ALL
SELECT 'employees -> locations', COUNT(*)
FROM employees e LEFT JOIN locations l ON e.locationid = l.locationid
WHERE l.locationid IS NULL

UNION ALL
SELECT 'projects -> customers', COUNT(*)
FROM projects p LEFT JOIN customers c ON p.customerid = c.customerid
WHERE c.customerid IS NULL

UNION ALL
SELECT 'projects -> employees (PM)', COUNT(*)
FROM projects p LEFT JOIN employees e ON p.projectmanagerid = e.employeeid
WHERE e.employeeid IS NULL

UNION ALL
SELECT 'project_baselines -> projects', COUNT(*)
FROM project_baselines b LEFT JOIN projects p ON b.projectid = p.projectid
WHERE p.projectid IS NULL

UNION ALL
SELECT 'actual_costs -> projects', COUNT(*)
FROM actual_costs ac LEFT JOIN projects p ON ac.projectid = p.projectid
WHERE p.projectid IS NULL

UNION ALL
SELECT 'project_kpis -> projects', COUNT(*)
FROM project_kpis k LEFT JOIN projects p ON k.projectid = p.projectid
WHERE p.projectid IS NULL

UNION ALL
SELECT 'assignments -> employees', COUNT(*)
FROM assignments a LEFT JOIN employees e ON a.employeeid = e.employeeid
WHERE e.employeeid IS NULL

UNION ALL
SELECT 'assignments -> projects', COUNT(*)
FROM assignments a LEFT JOIN projects p ON a.projectid = p.projectid
WHERE p.projectid IS NULL

UNION ALL
SELECT 'work_schedule -> employees', COUNT(*)
FROM work_schedule w LEFT JOIN employees e ON w.employeeid = e.employeeid
WHERE e.employeeid IS NULL;
