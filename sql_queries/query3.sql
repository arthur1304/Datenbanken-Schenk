-- Projekte mit Budgetüberschreitung
SELECT
    p.ProjectID,
    p.ProjectName,
    p.Status,
    c.CustomerName,
    pb.PlannedBudgetTotal as planned_budget,
    COALESCE(SUM(ac.Amount), 0) as actual_costs,
    (pb.PlannedBudgetTotal - COALESCE(SUM(ac.Amount), 0)) as cost_variance,
    ROUND(
        CASE 
            WHEN pb.PlannedBudgetTotal > 0 
            THEN (((pb.PlannedBudgetTotal - COALESCE(SUM(ac.Amount), 0)) / pb.PlannedBudgetTotal) * 100)::numeric
            ELSE NULL 
        END,
        2
    ) as cv_percent,
    COUNT(DISTINCT ac.CostType) as cost_types_used
FROM
    projects p
    INNER JOIN customers c ON p.CustomerID = c.CustomerID
    INNER JOIN project_baselines pb ON p.ProjectID = pb.ProjectID
    LEFT JOIN actual_costs ac ON p.ProjectID = ac.ProjectID
WHERE
    p.Status = 'In Progress'
    AND pb.IsActive = TRUE
    AND pb.PlannedBudgetTotal > 0  -- Verhindert Division durch Null
GROUP BY
    p.ProjectID, p.ProjectName, p.Status, c.CustomerName, pb.PlannedBudgetTotal
HAVING
    COALESCE(SUM(ac.Amount), 0) > pb.PlannedBudgetTotal
ORDER BY
    cost_variance ASC
LIMIT 25;
