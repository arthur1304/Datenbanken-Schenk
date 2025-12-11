-- Projekte mit negativer Schedule Variance
SELECT
    p.ProjectID,
    p.ProjectName,
    p.Status,
    pb.PlannedEndDate,
    p.EndDatePlanned as forecast_end_date,
    (p.EndDatePlanned - pb.PlannedEndDate) as sv_days,
    ROUND(
        (((p.EndDatePlanned - pb.PlannedEndDate)::numeric /
          (pb.PlannedEndDate - pb.ValidFrom)::numeric) * 100),
        2
    ) as sv_percent,
    COUNT(pk.KpiID) as kpi_snapshots
FROM
    projects p
    INNER JOIN project_baselines pb ON p.ProjectID = pb.ProjectID
    LEFT JOIN project_kpis pk ON p.ProjectID = pk.ProjectID
WHERE
    p.Status IN ('In Progress', 'On Hold')
    AND pb.IsActive = TRUE
    AND p.EndDatePlanned > pb.PlannedEndDate
    AND (pb.PlannedEndDate - pb.ValidFrom) > 0  -- Prevent division by zero
GROUP BY
    p.ProjectID, p.ProjectName, p.Status, pb.PlannedEndDate,
    p.EndDatePlanned, pb.ValidFrom
HAVING
    (p.EndDatePlanned - pb.PlannedEndDate) > 7
ORDER BY
    sv_days DESC
LIMIT 20;