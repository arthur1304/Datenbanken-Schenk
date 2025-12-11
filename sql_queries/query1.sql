-- Überlastete PMs identifizieren
SELECT 
    e.EmployeeID, 
    e.EmployeeName, 
    SUM(a.PlannedHours) AS total_planned_hours, 
    SUM(ws.AvailableHours) AS total_available_hours, 
    ROUND(
        (SUM(a.PlannedHours)::numeric / NULLIF(SUM(ws.AvailableHours), 0)) * 100, 
        2
    ) AS utilization_rate
FROM 
    employees e
    INNER JOIN roles r ON e.RoleID = r.RoleID
    INNER JOIN assignments a ON e.EmployeeID = a.EmployeeID
    INNER JOIN work_schedule ws 
        ON e.EmployeeID = ws.EmployeeID
        AND ws.Date = a.Date
        AND ws.IsHoliday = FALSE
        AND ws.IsVacation = FALSE
WHERE 
    r.RoleName = 'Project Manager'
    AND a.Date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '28 days'
GROUP BY 
    e.EmployeeID, e.EmployeeName
HAVING 
    SUM(a.PlannedHours) > SUM(ws.AvailableHours) * 0.65
    
ORDER BY 
    utilization_rate DESC;
