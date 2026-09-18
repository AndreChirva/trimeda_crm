-- ==========================================
-- dashboard_tm_projects_stats_getCounters
-- Дашборд: 4 метрики (всего, новые, просрочено, бюджет)
-- ==========================================

CREATE PROCEDURE [dbo].[dashboard_tm_projects_stats_getCounters]
    @username NVARCHAR(128),
    @parameters ExtendedDictionaryParameter READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tenant_id BIGINT;
    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    DECLARE @total INT, @new_month INT, @overdue INT, @budget NVARCHAR(50);

    SELECT @total = COUNT(*)
    FROM tm_projects
    WHERE tenant_id = @tenant_id AND deleted_at IS NULL;

    SELECT @new_month = COUNT(*)
    FROM tm_projects
    WHERE tenant_id = @tenant_id
      AND deleted_at IS NULL
      AND created_at >= DATEADD(month, -1, GETDATE());

    SELECT @overdue = COUNT(*)
    FROM tm_projects p
    LEFT JOIN tm_statuses s ON p.status_id = s.id
    WHERE p.tenant_id = @tenant_id
      AND p.deleted_at IS NULL
      AND p.end_date < CAST(GETDATE() AS DATE)
      AND s.code <> 'done';

    SELECT @budget = FORMAT(SUM(ISNULL(budget, 0)), 'N0')
    FROM tm_projects
    WHERE tenant_id = @tenant_id AND deleted_at IS NULL;

    SELECT
        N'Всего проектов' AS Title,
        N'Общее количество объектов в работе' AS Tooltip,
        N'fa fa-layer-group' AS Icon,
        CAST(ISNULL(@total, 0) AS NVARCHAR(20)) AS Number,
        N'' AS AdditionalNumber,
        N'Все объекты студии' AS DownTitle,
        N'' AS DownLink,
        1500 AS AnimateDuration,
        N'' AS Makeup,
        N'success' AS Color

    UNION ALL

    SELECT
        N'Новых за 30 дней',
        N'Объекты, запущенные за месяц',
        N'fa fa-seedling',
        CAST(ISNULL(@new_month, 0) AS NVARCHAR(20)),
        N'',
        N'Приток клиентов',
        N'',
        1500,
        N'',
        N'info'

    UNION ALL

    SELECT
        N'Просрочено',
        N'Внимание! Объекты с нарушенным дедлайном',
        N'fa fa-exclamation-triangle',
        CAST(ISNULL(@overdue, 0) AS NVARCHAR(20)),
        N'',
        CASE WHEN @overdue > 0 THEN N'⚠️ Требует контроля' ELSE N'✓ Сроки в порядке' END,
        N'?filter=overdue',
        1500,
        N'',
        N'danger'

    UNION ALL

    SELECT
        N'Бюджет проектов',
        N'Общий бюджет всех проектов',
        N'fa fa-coins',
        ISNULL(@budget, N'0') + N' ₽',
        N'',
        N'Объём в работе',
        N'',
        1500,
        N'',
        N'success';

    SELECT N'' AS panel1, N'' AS panel2;

    SELECT
        N'Обзор проектов' AS Title,
        N'Ключевые показатели по объектам' AS Subtitle,
        N'' AS Makeup,
        N'radio' AS FilterType;

    SELECT Value, Text FROM (
        SELECT '' AS Value, 'Все время' AS Text, 1 AS ord
        UNION ALL SELECT 'day', 'День', 2
        UNION ALL SELECT 'week', 'Неделя', 3
        UNION ALL SELECT 'month', 'Месяц', 4
        UNION ALL SELECT 'quarter', 'Квартал', 5
        UNION ALL SELECT 'year', 'Год', 6
    ) t1
    ORDER BY ord;
END