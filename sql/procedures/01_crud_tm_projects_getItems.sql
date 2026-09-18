-- ==========================================
-- crud_tm_projects_getItems
-- Таблица проектов: фильтры, пагинация, HTML
-- ==========================================

CREATE PROCEDURE [dbo].[crud_tm_projects_getItems]
    @filters CRUDFilterParameter READONLY,
    @sort sql_variant,
    @direction nvarchar(8),
    @page int,
    @pageSize int,
    @username nvarchar(32)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tenant_id BIGINT;

    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    DECLARE @filterClient NVARCHAR(255) = ISNULL((SELECT TOP 1 Value FROM @filters WHERE [Key] = 'client'), '');
    DECLARE @filterStatus INT = ISNULL((SELECT TOP 1 TRY_CAST(Value AS INT) FROM @filters WHERE [Key] = 'status'), 0);
    DECLARE @filterName NVARCHAR(255) = ISNULL((SELECT TOP 1 Value FROM @filters WHERE [Key] = 'project'), '');
    DECLARE @filterManager INT = ISNULL((SELECT TOP 1 TRY_CAST(Value AS INT) FROM @filters WHERE [Key] = 'manager'), 0);
    DECLARE @filtertype INT = ISNULL((SELECT TOP 1 TRY_CAST(Value AS INT) FROM @filters WHERE [Key] = 'project_type'), 0);

    IF OBJECT_ID('tempdb..#ids') IS NOT NULL DROP TABLE #ids;
    CREATE TABLE #ids (id BIGINT PRIMARY KEY);

    INSERT INTO #ids (id)
    SELECT p.id
    FROM tm_projects p
    LEFT JOIN tm_clients c ON p.client_id = c.id
    LEFT JOIN tm_statuses s ON p.status_id = s.id AND s.entity_type = 'project'
    LEFT JOIN tm_project_types tpt ON tpt.id = p.project_type_id
    WHERE p.tenant_id = @tenant_id
       AND p.deleted_at IS NULL
       AND (@filterClient = '' OR c.first_name LIKE '%' + @filterClient + '%'
                            OR c.last_name LIKE '%' + @filterClient + '%'
                            OR c.middle_name LIKE '%' + @filterClient + '%')
       AND (@filterManager = 0 OR p.manager_id = @filterManager)
       AND (@filterStatus = 0 OR s.id = @filterStatus)
       AND (@filtertype = 0 OR tpt.id = @filtertype);

    SELECT
        p.id,
        N'<div style="display: flex; align-items: center; gap: 12px; padding: 4px 0;">' +
            N'<div style="width: 42px; height: 42px; border-radius: 10px; background: linear-gradient(135deg, #1B5E20, #2E7D32); display: flex; align-items: center; justify-content: center; color: #ffffff; font-size: 1.1rem; flex-shrink: 0; box-shadow: 0 4px 10px rgba(46, 125, 50, 0.2);">🌿</div>' +
            N'<div>' +
                N'<div style="font-weight: 600; color: #1e293b; font-size: 0.95rem; line-height: 1.2;">' +
                    ISNULL(p.name, N'Без названия') +
                N'</div>' +
                N'<div style="font-size: 0.78rem; color: #64748b; margin-top: 3px;">' +
                    ISNULL(p.address, N'Адрес не указан') +
                N'</div>' +
            N'</div>' +
        N'</div>' AS [project],

        CASE
            WHEN pt.code = 'design' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#F3E5F5; color:#7B1FA2; padding:5px 12px; border-radius:8px; font-size:0.78rem; font-weight:700; white-space:nowrap;">📐 Проектирование</span>'
            WHEN pt.code = 'construction' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#FFF3E0; color:#E65100; padding:5px 12px; border-radius:8px; font-size:0.78rem; font-weight:700; white-space:nowrap;">🔨 Строительство</span>'
            WHEN pt.code = 'full_cycle' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#E8F5E9; color:#2E7D32; padding:5px 12px; border-radius:8px; font-size:0.78rem; font-weight:700; white-space:nowrap;">🌿 Полный цикл</span>'
            WHEN pt.code = 'maintenance' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#E3F2FD; color:#1565C0; padding:5px 12px; border-radius:8px; font-size:0.78rem; font-weight:700; white-space:nowrap;">🔧 Обслуживание</span>'
            ELSE N'<span style="display:inline-flex; align-items:center; gap:6px; background:#f5f5f5; color:#616161; padding:5px 12px; border-radius:8px; font-size:0.78rem; font-weight:600; white-space:nowrap;">' + ISNULL(pt.name, N'—') + N'</span>'
        END AS [project_type],

        N'<div style="display: flex; align-items: center; gap: 8px;">' +
            N'<div style="width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, #E3F2FD, #BBDEFB); display: flex; align-items: center; justify-content: center; color: #1565C0; font-weight: 700; font-size: 0.8rem; flex-shrink: 0;">' +
                UPPER(LEFT(ISNULL(c.first_name, '?'), 1)) + UPPER(LEFT(ISNULL(c.last_name, ''), 1)) +
            N'</div>' +
            N'<div>' +
                N'<div style="color: #1e293b; font-size: 0.9rem; font-weight: 500;">' +
                    ISNULL(c.last_name, '') + ' ' + ISNULL(c.first_name, '') +
                N'</div>' +
                N'<div style="color: #64748b; font-size: 0.75rem;">' +
                    ISNULL(c.phone, '') +
                N'</div>' +
            N'</div>' +
        N'</div>' AS [client],

        N'<div style="display: flex; align-items: center; gap: 8px;">' +
            N'<div style="width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, #F3E5F5, #E1BEE7); display: flex; align-items: center; justify-content: center; color: #7B1FA2; font-weight: 700; font-size: 0.8rem; flex-shrink: 0;">' +
                UPPER(LEFT(ISNULL(m.first_name, '?'), 1)) + UPPER(LEFT(ISNULL(m.last_name, ''), 1)) +
            N'</div>' +
            N'<div style="color: #334155; font-size: 0.9rem;">' +
                ISNULL(m.first_name, '') + ' ' + ISNULL(m.last_name, '') +
            N'</div>' +
        N'</div>' AS [manager],

        CASE
            WHEN ts.code = 'new' THEN N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, p.id) + N'" data-param-p1="project" style="display:inline-flex; align-items:center; gap:6px; background:#E3F2FD; color:#1565C0; padding:6px 12px; border-radius:20px; font-size:0.8rem; font-weight:600; text-decoration:none; white-space:nowrap;"><span style="width:6px;height:6px;background:#2196F3;border-radius:50%;"></span> Новый</a>'
            WHEN ts.code = 'measurement' THEN N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, p.id) + N'" data-param-p1="project" style="display:inline-flex; align-items:center; gap:6px; background:#FFF3E0; color:#E65100; padding:6px 12px; border-radius:20px; font-size:0.8rem; font-weight:600; text-decoration:none; white-space:nowrap;"><span style="width:6px;height:6px;background:#FF9800;border-radius:50%;"></span> Замер</a>'
            WHEN ts.code = 'design' THEN N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, p.id) + N'" data-param-p1="project" style="display:inline-flex; align-items:center; gap:6px; background:#F3E5F5; color:#7B1FA2; padding:6px 12px; border-radius:20px; font-size:0.8rem; font-weight:600; text-decoration:none; white-space:nowrap;"><span style="width:6px;height:6px;background:#9C27B0;border-radius:50%;"></span> Проектирование</a>'
            WHEN ts.code = 'construction' THEN N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, p.id) + N'" data-param-p1="project" style="display:inline-flex; align-items:center; gap:6px; background:#FFF8E1; color:#F57F17; padding:6px 12px; border-radius:20px; font-size:0.8rem; font-weight:600; text-decoration:none; white-space:nowrap;"><span style="width:6px;height:6px;background:#FFC107;border-radius:50%;"></span> Строительство</a>'
            WHEN ts.code = 'done' THEN N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, p.id) + N'" data-param-p1="project" style="display:inline-flex; align-items:center; gap:6px; background:#E8F5E9; color:#2E7D32; padding:6px 12px; border-radius:20px; font-size:0.8rem; font-weight:600; text-decoration:none; white-space:nowrap;"><span style="width:6px;height:6px;background:#4CAF50;border-radius:50%;"></span> Завершён</a>'
            ELSE N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, p.id) + N'" data-param-p1="project" style="display:inline-flex; align-items:center; gap:6px; background:#f5f5f5; color:#616161; padding:6px 12px; border-radius:20px; font-size:0.8rem; text-decoration:none; white-space:nowrap;"><span style="width:6px;height:6px;background:#cbd5e1;border-radius:50%;"></span> ' + ISNULL(ts.name, N'—') + N'</a>'
        END AS [status],

        N'<div style="color: #1B5E20; font-size: 0.95rem; font-weight: 700; white-space:nowrap;">' +
            ISNULL(FORMAT(p.budget, 'N0'), N'0') + N' ₽' +
        N'</div>' AS [budget],

        N'<div style="display:flex; align-items:center; gap:6px; white-space:nowrap;">' +
            N'<i class="far fa-calendar-alt" style="color:#94a3b8; font-size:0.85rem;"></i>' +
            N'<span style="color:#64748b; font-size:0.82rem;">' +
                ISNULL(CONVERT(NVARCHAR(10), p.start_date, 104), N'?') +
            N'</span>' +
            N'<i class="fas fa-long-arrow-alt-right" style="color:#cbd5e1; font-size:0.75rem;"></i>' +
            N'<span style="color:' +
                CASE
                    WHEN ts.code = 'done' THEN N'#2E7D32'
                    WHEN p.end_date < CAST(GETDATE() AS DATE) THEN N'#ef4444'
                    WHEN p.end_date < DATEADD(day, 3, GETDATE()) THEN N'#f59e0b'
                    ELSE N'#334155'
                END + N'; font-size:0.85rem; font-weight:700;">' +
                ISNULL(CONVERT(NVARCHAR(10), p.end_date, 104), N'?') +
            N'</span>' +
        N'</div>' AS [dates],

        N'<div style="display: inline-flex; gap: 12px; align-items: center;">' +
            N'<a href="#" class="as-form-modal" data-code="tm_projectEditForm" data-itemID="' + CONVERT(NVARCHAR(20), p.id) + N'" data-title="Редактировать" style="color: #64748b;"><i class="far fa-edit" style="font-size: 1.05rem;"></i></a>' +
            N'<a href="#" class="as-form-modal" data-code="tm_projectViewForm" data-itemID="' + CONVERT(NVARCHAR(20), p.id) + N'" data-title="Просмотр" style="color: #64748b;"><i class="fas fa-eye" style="font-size: 1.05rem;"></i></a>' +
        N'</div>' AS [edit]

    FROM tm_projects p
    INNER JOIN #ids ids ON p.id = ids.id
    LEFT JOIN tm_clients c ON p.client_id = c.id
    LEFT JOIN tm_users m ON p.manager_id = m.id
    LEFT JOIN tm_statuses ts ON ts.id = p.status_id AND ts.entity_type = 'project'
    LEFT JOIN tm_project_types pt ON pt.id = p.project_type_id
    ORDER BY p.id DESC
    OFFSET (@page - 1) * @pageSize ROWS
    FETCH NEXT @pageSize ROWS ONLY;

    SELECT COUNT(*) AS total FROM #ids;

    SELECT
        'Проекты' AS title,
        1 AS HideTitleCount,
        1 AS [EnableExcelExport],
        1 AS EnablePrint,
        'id' AS keyField,
        0 AS showSearch,
        1 AS showPagination,
        20 AS defaultPageSize,
        N'{
            "project": { "placeholder": "🔍 Название проекта...", "cssClass": "form-control crm-filter-input" },
            "status": { "placeholder": "💡 Статус", "cssClass": "form-control crm-filter-select" },
            "client": { "placeholder": "👤 Клиент", "cssClass": "form-control crm-filter-select" },
            "manager": { "placeholder": "👔 Менеджер", "cssClass": "form-control crm-filter-select" },
            "project_type": { "placeholder": "📐 Тип проекта", "cssClass": "form-control crm-filter-select" }
        }' AS FilterOptions;

    DROP TABLE #ids;
END