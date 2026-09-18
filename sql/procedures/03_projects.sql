-- ==========================================
-- ПРОЕКТЫ: CRUD, словари, формы
-- ==========================================

-- (1) crud_tm_projects_getItems
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
    DECLARE @filtertype int = ISNULL((SELECT TOP 1 TRY_CAST(Value AS INT) FROM @filters WHERE [Key] = 'project_type'), 0);

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
                N'<div style="font-weight: 600; color: #1e293b; font-size: 0.95rem; line-height: 1.2;">' + ISNULL(p.name, N'Без названия') + N'</div>' +
                N'<div style="font-size: 0.78rem; color: #64748b; margin-top: 3px;">' + ISNULL(p.address, N'Адрес не указан') + N'</div>' +
            N'</div>' +
        N'</div>' AS [project],

        CASE
            WHEN pt.code = 'design' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#F3E5F5; color:#7B1FA2; padding:5px 12px; border-radius:8px; font-size:0.78rem; font-weight:700;">📐 Проектирование</span>'
            WHEN pt.code = 'construction' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#FFF3E0; color:#E65100; padding:5px 12px; border-radius:8px; font-size:0.78rem; font-weight:700;">🔨 Строительство</span>'
            WHEN pt.code = 'full_cycle' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#E8F5E9; color:#2E7D32; padding:5px 12px; border-radius:8px; font-size:0.78rem; font-weight:700;">🌿 Полный цикл</span>'
            WHEN pt.code = 'maintenance' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#E3F2FD; color:#1565C0; padding:5px 12px; border-radius:8px; font-size:0.78rem; font-weight:700;">🔧 Обслуживание</span>'
            ELSE N'<span style="display:inline-flex; align-items:center; gap:6px; background:#f5f5f5; color:#616161; padding:5px 12px; border-radius:8px; font-size:0.78rem; font-weight:600;">' + ISNULL(pt.name, N'—') + N'</span>'
        END AS [project_type],

        N'<div style="display: flex; align-items: center; gap: 8px;">' +
            N'<div style="width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, #E3F2FD, #BBDEFB); display: flex; align-items: center; justify-content: center; color: #1565C0; font-weight: 700; font-size: 0.8rem; flex-shrink: 0;">' +
                UPPER(LEFT(ISNULL(c.first_name, '?'), 1)) + UPPER(LEFT(ISNULL(c.last_name, ''), 1)) +
            N'</div>' +
            N'<div>' +
                N'<div style="color: #1e293b; font-size: 0.9rem; font-weight: 500;">' + ISNULL(c.last_name, '') + ' ' + ISNULL(c.first_name, '') + N'</div>' +
                N'<div style="color: #64748b; font-size: 0.75rem;">' + ISNULL(c.phone, '') + N'</div>' +
            N'</div>' +
        N'</div>' AS [client],

        N'<div style="display: flex; align-items: center; gap: 8px;">' +
            N'<div style="width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, #F3E5F5, #E1BEE7); display: flex; align-items: center; justify-content: center; color: #7B1FA2; font-weight: 700; font-size: 0.8rem; flex-shrink: 0;">' +
                UPPER(LEFT(ISNULL(m.first_name, '?'), 1)) + UPPER(LEFT(ISNULL(m.last_name, ''), 1)) +
            N'</div>' +
            N'<div style="color: #334155; font-size: 0.9rem;">' + ISNULL(m.first_name, '') + ' ' + ISNULL(m.last_name, '') + N'</div>' +
        N'</div>' AS [manager],

        CASE
            WHEN ts.code = 'new' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#E3F2FD; color:#1565C0; padding:6px 12px; border-radius:20px; font-size:0.8rem; font-weight:600;"><span style="width:6px;height:6px;background:#2196F3;border-radius:50%;"></span> Новый</span>'
            WHEN ts.code = 'measurement' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#FFF3E0; color:#E65100; padding:6px 12px; border-radius:20px; font-size:0.8rem; font-weight:600;"><span style="width:6px;height:6px;background:#FF9800;border-radius:50%;"></span> Замер</span>'
            WHEN ts.code = 'design' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#F3E5F5; color:#7B1FA2; padding:6px 12px; border-radius:20px; font-size:0.8rem; font-weight:600;"><span style="width:6px;height:6px;background:#9C27B0;border-radius:50%;"></span> Проектирование</span>'
            WHEN ts.code = 'construction' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#FFF8E1; color:#F57F17; padding:6px 12px; border-radius:20px; font-size:0.8rem; font-weight:600;"><span style="width:6px;height:6px;background:#FFC107;border-radius:50%;"></span> Строительство</span>'
            WHEN ts.code = 'done' THEN N'<span style="display:inline-flex; align-items:center; gap:6px; background:#E8F5E9; color:#2E7D32; padding:6px 12px; border-radius:20px; font-size:0.8rem; font-weight:600;"><span style="width:6px;height:6px;background:#4CAF50;border-radius:50%;"></span> Завершён</span>'
            ELSE N'<span style="display:inline-flex; align-items:center; gap:6px; background:#f5f5f5; color:#616161; padding:6px 12px; border-radius:20px; font-size:0.8rem;"><span style="width:6px;height:6px;background:#cbd5e1;border-radius:50%;"></span> ' + ISNULL(ts.name, N'—') + N'</span>'
        END AS [status],

        CASE
            WHEN ts.code = 'new' THEN N'<div style="display:flex; align-items:center; gap:8px;"><div style="width:70px; height:8px; background:#e2e8f0; border-radius:4px; overflow:hidden;"><div style="width:10%; height:100%; background:linear-gradient(90deg, #2196F3, #42A5F5);"></div></div><span style="font-size:0.78rem; font-weight:700; color:#1565C0;">10%</span></div>'
            WHEN ts.code = 'measurement' THEN N'<div style="display:flex; align-items:center; gap:8px;"><div style="width:70px; height:8px; background:#e2e8f0; border-radius:4px; overflow:hidden;"><div style="width:25%; height:100%; background:linear-gradient(90deg, #FF9800, #FFA726);"></div></div><span style="font-size:0.78rem; font-weight:700; color:#E65100;">25%</span></div>'
            WHEN ts.code = 'design' THEN N'<div style="display:flex; align-items:center; gap:8px;"><div style="width:70px; height:8px; background:#e2e8f0; border-radius:4px; overflow:hidden;"><div style="width:45%; height:100%; background:linear-gradient(90deg, #9C27B0, #AB47BC);"></div></div><span style="font-size:0.78rem; font-weight:700; color:#7B1FA2;">45%</span></div>'
            WHEN ts.code = 'construction' THEN N'<div style="display:flex; align-items:center; gap:8px;"><div style="width:70px; height:8px; background:#e2e8f0; border-radius:4px; overflow:hidden;"><div style="width:75%; height:100%; background:linear-gradient(90deg, #FFC107, #FFD54F);"></div></div><span style="font-size:0.78rem; font-weight:700; color:#F57F17;">75%</span></div>'
            WHEN ts.code = 'done' THEN N'<div style="display:flex; align-items:center; gap:8px;"><div style="width:70px; height:8px; background:#e2e8f0; border-radius:4px; overflow:hidden;"><div style="width:100%; height:100%; background:linear-gradient(90deg, #4CAF50, #66BB6A);"></div></div><span style="font-size:0.78rem; font-weight:700; color:#2E7D32;">100%</span></div>'
            ELSE N'<div style="display:flex; align-items:center; gap:8px;"><div style="width:70px; height:8px; background:#e2e8f0; border-radius:4px; overflow:hidden;"><div style="width:0%; height:100%; background:#cbd5e1;"></div></div><span style="font-size:0.78rem; font-weight:700; color:#94a3b8;">0%</span></div>'
        END AS [progress],

        N'<div style="color: #1B5E20; font-size: 0.95rem; font-weight: 700; white-space:nowrap;">' +
            ISNULL(FORMAT(p.budget, 'N0'), N'0') + N' ₽' +
        N'</div>' AS [budget],

        N'<div style="display:flex; align-items:center; gap:6px; white-space:nowrap;">' +
            N'<i class="far fa-calendar-alt" style="color:#94a3b8; font-size:0.85rem;"></i>' +
            N'<span style="color:#64748b; font-size:0.82rem;">' + ISNULL(CONVERT(NVARCHAR(10), p.start_date, 104), N'?') + N'</span>' +
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
GO

-- (2) fm_tm_newProject_getItem
CREATE PROCEDURE [dbo].[fm_tm_newProject_getItem]
    @itemID int,
    @username nvarchar(256)
AS
BEGIN
    DECLARE @tenant_id BIGINT
    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    JOIN as_users au ON tu.email = au.email AND au.username = @username

    SELECT '' id, '' name, '' client_id, '' address, '' area, '' project_type,
           '' status, '' manager_id, '' budget, '' start_date, '' end_date

    SELECT '' Title, '' Subtitle, 'h2' HeaderTag, 1 LineLabel
END
GO

-- (3) fm_tm_newProject_saveItem
CREATE PROCEDURE [dbo].[fm_tm_newProject_saveItem]
    @username nvarchar(256),
    @itemID int,
    @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pname nvarchar(255), @pclient_id nvarchar(128), @paddress nvarchar(500)
    DECLARE @parea nvarchar(50), @pproject_type_id nvarchar(50), @pstatus_id nvarchar(50)
    DECLARE @pmanager_id nvarchar(128), @pbudget nvarchar(50)
    DECLARE @pstart_date nvarchar(50), @pend_date nvarchar(50)

    SELECT @pname = Value2 FROM @parameters WHERE [key] = 'name'
    SELECT @pclient_id = Value2 FROM @parameters WHERE [key] = 'client_id'
    SELECT @paddress = Value2 FROM @parameters WHERE [key] = 'address'
    SELECT @parea = Value2 FROM @parameters WHERE [key] = 'area'
    SELECT @pproject_type_id = Value2 FROM @parameters WHERE [key] = 'project_type_id'
    SELECT @pstatus_id = Value2 FROM @parameters WHERE [key] = 'status_id'
    SELECT @pmanager_id = Value2 FROM @parameters WHERE [key] = 'manager_id'
    SELECT @pbudget = Value2 FROM @parameters WHERE [key] = 'budget'
    SELECT @pstart_date = Value2 FROM @parameters WHERE [key] = 'start_date'
    SELECT @pend_date = Value2 FROM @parameters WHERE [key] = 'end_date'

    DECLARE @tenant_id BIGINT, @project_id BIGINT
    DECLARE @now DATETIME = GETDATE()
    DECLARE @status_id INT = TRY_CAST(@pstatus_id AS INT)
    DECLARE @project_type_id INT = TRY_CAST(@pproject_type_id AS INT)
    DECLARE @project_type_code NVARCHAR(50)

    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username

    IF @tenant_id IS NULL BEGIN SELECT 0 AS Result, 'Компания не найдена' AS Msg; RETURN; END
    IF ISNULL(@pname, '') = '' BEGIN SELECT 0 AS Result, 'Укажите название проекта' AS Msg; RETURN; END

    IF @status_id IS NULL OR @status_id = 0
    BEGIN
        SELECT TOP 1 @status_id = id
        FROM tm_statuses
        WHERE tenant_id = @tenant_id AND entity_type = 'project' AND code = 'new'
    END

    IF @project_type_id IS NOT NULL
    BEGIN
        SELECT @project_type_code = code
        FROM tm_project_types
        WHERE id = @project_type_id AND tenant_id = @tenant_id
    END

    IF @itemID IS NULL OR @itemID = 0
    BEGIN
        INSERT INTO tm_projects (tenant_id, name, client_id, address, area, project_type, project_type_id,
            status_id, manager_id, budget, start_date, end_date, created_at)
        VALUES (@tenant_id, @pname, TRY_CAST(@pclient_id AS BIGINT), @paddress,
            TRY_CAST(@parea AS DECIMAL(10,2)), @project_type_code, @project_type_id,
            @status_id, TRY_CAST(@pmanager_id AS BIGINT), TRY_CAST(@pbudget AS DECIMAL(15,2)),
            TRY_CAST(@pstart_date AS DATE), TRY_CAST(@pend_date AS DATE), @now)
        SET @project_id = SCOPE_IDENTITY()

        SELECT 1 AS Result, 'Проект создан!' AS Msg, '' AS SuccessUrl, 1 AS HideFormAfterSubmit, '#as-table-tm_projects' AS RefreshContainer, 1 AS EnableSaveAlert
    END
    ELSE
    BEGIN
        UPDATE tm_projects
        SET name = @pname, client_id = TRY_CAST(@pclient_id AS BIGINT), address = @paddress,
            area = TRY_CAST(@parea AS DECIMAL(10,2)), project_type = @project_type_code,
            project_type_id = @project_type_id, status_id = @status_id,
            manager_id = TRY_CAST(@pmanager_id AS BIGINT), budget = TRY_CAST(@pbudget AS DECIMAL(15,2)),
            start_date = TRY_CAST(@pstart_date AS DATE), end_date = TRY_CAST(@pend_date AS DATE),
            updated_at = @now
        WHERE id = @itemID AND tenant_id = @tenant_id

        SELECT 1 AS Result, 'Проект обновлён!' AS Msg, '' AS SuccessUrl, 1 AS HideFormAfterSubmit, '#as-table-tm_projects' AS RefreshContainer, 1 AS EnableSaveAlert
    END

    INSERT INTO as_trace (code, header, text, created, username)
    VALUES ('project', 'Project saved', 'ID: ' + CONVERT(NVARCHAR, @itemID), @now, @username)

    SELECT '' AS type
END
GO

-- (4) fm_tm_projectEditForm_getItem
CREATE PROCEDURE [dbo].[fm_tm_projectEditForm_getItem]
    @itemID int,
    @username nvarchar(256)
AS
BEGIN
    DECLARE @user_email nvarchar(256) = (SELECT email FROM as_users WHERE username = @username)
    DECLARE @tenant_id BIGINT = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

    SELECT ISNULL(tp.name, '') name,
           ISNULL((SELECT TOP 1 last_name + ' ' + first_name + ' ' + middle_name FROM tm_clients WHERE id = tp.client_id), '') client,
           ISNULL(tp.address, '') address, ISNULL(tp.area, 0) area,
           ISNULL((SELECT TOP 1 name FROM tm_project_types WHERE id = tp.project_type_id), '') projectType,
           ISNULL((SELECT TOP 1 first_name + ' ' + last_name FROM tm_users WHERE id = tp.manager_id), '') manager,
           ISNULL(tp.budget, 0) budget,
           CASE WHEN start_date IS NULL THEN '' ELSE CONVERT(NVARCHAR(10), start_date, 23) END AS start_date,
           CASE WHEN end_date IS NULL THEN '' ELSE CONVERT(NVARCHAR(10), end_date, 23) END AS end_date
    FROM tm_projects tp
    WHERE tp.tenant_id = @tenant_id AND tp.id = @itemID

    SELECT '' Title, '' Subtitle, 'h2' HeaderTag, 1 LineLabel
END
GO

-- (5) fm_tm_projectEditForm_saveItem
CREATE PROCEDURE [dbo].[fm_tm_projectEditForm_saveItem]
   @username nvarchar(256),
   @itemID int,
   @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @pname nvarchar(max), @pclient nvarchar(max), @paddress nvarchar(max)
    DECLARE @parea nvarchar(max), @pprojectType nvarchar(max), @pmanager nvarchar(max)
    DECLARE @pbudget nvarchar(max), @pstart_date nvarchar(max), @pend_date nvarchar(max)

    SELECT @pname = Value2 FROM @parameters WHERE [key]='name'
    SELECT @pclient = Value2 FROM @parameters WHERE [key]='client'
    SELECT @paddress = Value2 FROM @parameters WHERE [key]='address'
    SELECT @parea = Value2 FROM @parameters WHERE [key]='area'
    SELECT @pprojectType = Value2 FROM @parameters WHERE [key]='projectType'
    SELECT @pmanager = Value2 FROM @parameters WHERE [key]='manager'
    SELECT @pbudget = Value2 FROM @parameters WHERE [key]='budget'
    SELECT @pstart_date = Value2 FROM @parameters WHERE [key]='start_date'
    SELECT @pend_date = Value2 FROM @parameters WHERE [key]='end_date'

    DECLARE @tenant_id BIGINT
    DECLARE @now datetime = getdate()
    DECLARE @project_type_id INT = TRY_CAST(@pprojectType AS INT)
    DECLARE @project_type_code NVARCHAR(50)

    SELECT @tenant_id = tp.tenant_id
    FROM tm_users tp
    INNER JOIN as_users au ON au.email = tp.email AND au.username = @username

    IF @project_type_id IS NOT NULL
    BEGIN
        SELECT @project_type_code = code
        FROM tm_project_types
        WHERE id = @project_type_id AND tenant_id = @tenant_id
    END

    UPDATE tm_projects
    SET name = @pname, address = @paddress, area = TRY_CAST(@parea AS DECIMAL(10,2)),
        project_type = @project_type_code, project_type_id = @project_type_id,
        manager_id = TRY_CAST(@pmanager AS BIGINT), budget = TRY_CAST(@pbudget AS DECIMAL(15,2)),
        start_date = TRY_CAST(@pstart_date AS DATE), end_date = TRY_CAST(@pend_date AS DATE),
        updated_at = @now
    WHERE id = @itemID AND tenant_id = @tenant_id

    INSERT INTO as_trace (code, header, text, created, username)
    VALUES ('project', 'Project updated', 'ID: ' + CONVERT(NVARCHAR, @itemID), @now, @username)

    SELECT 1 AS Result, 'Проект обновлён!' AS Msg, '' AS SuccessUrl, 1 AS HideFormAfterSubmit, '#as-table-tm_projects' AS RefreshContainer, 1 AS EnableSaveAlert

    SELECT '' AS type
END
GO

-- (6) fm_tm_projectViewForm_getItem
CREATE PROCEDURE [dbo].[fm_tm_projectViewForm_getItem]
    @itemID int,
    @username nvarchar(256)
AS
BEGIN
    DECLARE @tenant_id BIGINT;
    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email AND au.username = @username;

    SELECT
        p.id, p.name, p.address, p.area, p.budget, p.start_date, p.end_date, p.created_at, p.updated_at,
        ISNULL(c.last_name, '') + ' ' + ISNULL(c.first_name, '') + ' ' + ISNULL(c.middle_name, '') AS client_name,
        ISNULL(c.phone, '') AS client_phone,
        ISNULL(m.first_name, '') + ' ' + ISNULL(m.last_name, '') AS manager_name,
        ISNULL(m.phone, '') AS manager_phone,
        ISNULL(pt.name, '—') AS project_type_name,
        ISNULL(pt.code, '') AS project_type_code,
        ISNULL(ts.name, '—') AS status_name,
        ISNULL(ts.code, '') AS status_code,
        CONVERT(NVARCHAR(10), p.start_date, 104) AS start_date_str,
        CONVERT(NVARCHAR(10), p.end_date, 104) AS end_date_str,
        CONVERT(NVARCHAR(10), p.created_at, 104) AS created_at_str,
        FORMAT(p.budget, 'N0') AS budget_str,
        UPPER(LEFT(ISNULL(c.first_name, '?'), 1)) + UPPER(LEFT(ISNULL(c.last_name, ''), 1)) AS client_initials,
        UPPER(LEFT(ISNULL(m.first_name, '?'), 1)) + UPPER(LEFT(ISNULL(m.last_name, ''), 1)) AS manager_initials,
        CASE
            WHEN ts.code = 'new' THEN 10
            WHEN ts.code = 'measurement' THEN 25
            WHEN ts.code = 'design' THEN 45
            WHEN ts.code = 'construction' THEN 75
            WHEN ts.code = 'done' THEN 100
            ELSE 0
        END AS progress
    FROM tm_projects p
    LEFT JOIN tm_clients c ON p.client_id = c.id
    LEFT JOIN tm_users m ON p.manager_id = m.id
    LEFT JOIN tm_project_types pt ON p.project_type_id = pt.id
    LEFT JOIN tm_statuses ts ON p.status_id = ts.id AND ts.entity_type = 'project'
    WHERE p.id = @itemID AND p.tenant_id = @tenant_id;
END
GO

-- (7) crud_tm_projects_manager_dict
CREATE PROCEDURE [dbo].[crud_tm_projects_manager_dict]
  @tableCode nvarchar(32),
  @col nvarchar(32),
  @username nvarchar(32),
  @parameters ExtendedDictionaryParameter readonly,
  @filters CRUDFilterParameter READONLY
AS
BEGIN
    DECLARE @tenant_id bigint, @user_email nvarchar(256)
    SET @user_email = (SELECT email FROM as_users WHERE username = @username)
    SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

    SELECT 0 Value, 'Выберите менеджера' Text
    UNION
    SELECT tu.id Value, (tu.first_name + ' ' + tu.last_name) Text
    FROM tm_users tu
    LEFT JOIN tm_positions tp ON tu.position_id = tp.id AND tp.tenant_id = @tenant_id
    LEFT JOIN tm_statuses ts ON ts.id = tu.status_id AND ts.tenant_id = @tenant_id
    WHERE tu.tenant_id = @tenant_id AND tp.role_code = 'manager' AND ts.code <> 'Fired'
    ORDER BY Value
END
GO

-- (8) crud_tm_projects_status_dict
CREATE PROCEDURE [dbo].[crud_tm_projects_status_dict]
  @tableCode nvarchar(32),
  @col nvarchar(32),
  @username nvarchar(32),
  @parameters ExtendedDictionaryParameter readonly,
  @filters CRUDFilterParameter READONLY
AS
BEGIN
    DECLARE @tenant_id bigint, @user_email nvarchar(255)
    SET @user_email = (SELECT email FROM as_users WHERE username = @username)
    SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

    SELECT 0 Value, 'Выберите статус' Text
    UNION
    SELECT ts.id Value, ts.name Text
    FROM tm_statuses ts
    WHERE tenant_id = @tenant_id AND entity_type = 'project'
    ORDER BY Value
END
GO

-- (9) crud_tm_projects_project_type_dict
CREATE PROCEDURE [dbo].[crud_tm_projects_project_type_dict]
  @tableCode nvarchar(32),
  @col nvarchar(32),
  @username nvarchar(32),
  @parameters ExtendedDictionaryParameter readonly,
  @filters CRUDFilterParameter READONLY
AS
BEGIN
    DECLARE @tenant_id bigint, @email_user nvarchar(256)
    SET @email_user = (SELECT email FROM as_users WHERE username = @username)
    SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @email_user)

    SELECT 0 Value, 'Выберите тип проекта' Text
    UNION
    SELECT id Value, name Text
    FROM tm_project_types
    WHERE tenant_id = @tenant_id
    ORDER BY Value
END
GO

-- (10) fm_tm_projects_stats_getItem
CREATE PROCEDURE [dbo].[fm_tm_projects_stats_getItem]
    @itemID int,
    @username nvarchar(256)
AS
BEGIN
    DECLARE @tenant_id bigint
    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    SELECT
        (SELECT COUNT(*) FROM tm_projects WHERE tenant_id = @tenant_id AND deleted_at IS NULL) AS stat_total,
        (SELECT COUNT(*) FROM tm_projects WHERE tenant_id = @tenant_id AND deleted_at IS NULL AND created_at >= DATEADD(month, -1, GETDATE())) AS stat_new,
        (SELECT COUNT(*) FROM tm_projects p
         LEFT JOIN tm_statuses s ON p.status_id = s.id
         WHERE p.tenant_id = @tenant_id AND p.deleted_at IS NULL
           AND p.end_date < CAST(GETDATE() AS DATE) AND s.code <> 'done') AS stat_overdue,
        (SELECT FORMAT(SUM(ISNULL(budget, 0)), 'N0') FROM tm_projects WHERE tenant_id = @tenant_id AND deleted_at IS NULL) AS stat_budget
END
GO