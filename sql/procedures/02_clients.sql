-- ==========================================
-- КЛИЕНТЫ: CRUD, словари, формы
-- ==========================================

-- (1) crud_tm_clients_getItems
CREATE PROCEDURE [dbo].[crud_tm_clients_getItems]
  @filters CRUDFilterParameter READONLY,
  @sort sql_variant,
  @direction nvarchar(8),
  @page int,
  @pageSize int,
  @username nvarchar(32)
AS
BEGIN
  DECLARE @fio nvarchar(128) = (SELECT TOP 1 Value FROM @filters WHERE [Key] = 'fio')
  DECLARE @status int = (SELECT TOP 1 TRY_CAST(Value AS int) FROM @filters WHERE [Key] = 'status')

  DECLARE @tenant_id BIGINT;
  SELECT @tenant_id = tu.tenant_id
  FROM tm_users tu
  INNER JOIN as_users au ON tu.email = au.email
  WHERE au.username = @username;

  IF (OBJECT_ID('tempdb..#ids') IS NOT NULL) DROP TABLE #ids
  CREATE TABLE #ids (id int PRIMARY KEY)

  INSERT INTO #ids
  SELECT id
  FROM tm_clients
  WHERE tenant_id = @tenant_id AND deleted_at IS NULL
        AND (ISNULL(@fio, '') = '' OR first_name LIKE '%' + @fio + '%'
             OR last_name LIKE '%' + @fio + '%' OR middle_name LIKE '%' + @fio + '%'
             OR email LIKE '%' + @fio + '%' OR phone LIKE '%' + @fio + '%')
        AND (@status = 0 OR status_id = @status)

  SELECT ISNULL(c.id, '') id,
        N'<div style="display: flex; align-items: center; gap: 12px; padding: 4px 0;">' +
            N'<div style="width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(135deg, #2E7D32, #4CAF50); display: flex; align-items: center; justify-content: center; color: #ffffff; font-weight: 700; font-size: 0.9rem; flex-shrink: 0;">' +
                UPPER(LEFT(ISNULL(c.first_name, '?'), 1)) + UPPER(LEFT(ISNULL(c.last_name, ''), 1)) +
            N'</div>' +
            N'<div>' +
                N'<div style="font-weight: 600; color: #1e293b; font-size: 0.95rem;">' +
                    ISNULL(c.last_name, '') + ' ' + ISNULL(c.first_name, '') + ' ' + ISNULL(c.middle_name, '') +
                N'</div>' +
            N'</div>' +
        N'</div>' AS [fio],

        N'<div style="display: flex; align-items: center; gap: 6px; color: #475569; font-size: 0.9rem;">' +
            N'<i class="fas fa-phone-alt" style="color: #90a4ae; font-size: 0.75rem;"></i>' +
            ISNULL(c.phone, N'—') +
        N'</div>' AS [phone],

        N'<a href="mailto:' + ISNULL(c.email, '') + N'" style="color: #475569; font-size: 0.9rem; text-decoration: none; border-bottom: 1px dashed #cbd5e1;">' +
            ISNULL(c.email, N'—') +
        N'</a>' AS [email],

        N'<div style="display: flex; align-items: center; gap: 6px; color: #64748b; font-size: 0.85rem;">' +
            N'<i class="fas fa-map-marker-alt" style="color: #90a4ae; font-size: 0.75rem;"></i>' +
            ISNULL(c.address, N'—') +
        N'</div>' AS [address],

        CASE
            WHEN s.code = 'active' THEN
                N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, c.id) + N'" data-param-p1="client" style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; text-decoration:none; background:#f0fdf4; color:#166534;"><span style="width:6px;height:6px;background:#22c55e;border-radius:50%;"></span> ' + ISNULL(s.name, N'Активный') + N'</a>'
            WHEN s.code = 'potential' THEN
                N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, c.id) + N'" data-param-p1="client" style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; text-decoration:none; background:#fffbeb; color:#b45309;"><span style="width:6px;height:6px;background:#f59e0b;border-radius:50%;"></span> ' + ISNULL(s.name, N'Потенциальный') + N'</a>'
            WHEN s.code = 'inactive' THEN
                N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, c.id) + N'" data-param-p1="client" style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; text-decoration:none; background:#fef2f2; color:#991b1b;"><span style="width:6px;height:6px;background:#ef4444;border-radius:50%;"></span> ' + ISNULL(s.name, N'Неактивный') + N'</a>'
            WHEN s.code = 'vip' THEN
                N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, c.id) + N'" data-param-p1="client" style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; text-decoration:none; background:#fdf2f8; color:#9d174d;"><span style="width:6px;height:6px;background:#ec4899;border-radius:50%;"></span> 👑 ' + ISNULL(s.name, N'VIP') + N'</a>'
            ELSE
                N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, c.id) + N'" data-param-p1="client" style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; text-decoration:none; background:#f5f5f5; color:#616161;"><span style="width:6px;height:6px;background:#cbd5e1;border-radius:50%;"></span> ' + ISNULL(s.name, N'—') + N'</a>'
        END AS [status],

        N'<div style="color: #94a3b8; font-size: 0.85rem;">' +
            ISNULL(CONVERT(NVARCHAR(10), c.created_at, 104), N'—') +
        N'</div>' AS [created_at],

        N'<div style="display: inline-flex; gap: 14px; align-items: center;">' +
            N'<a href="#" class="as-form-modal" data-code="tm_clientEditForm" data-itemID="' + CONVERT(NVARCHAR(20), c.id) + N'" data-title="Редактировать клиента" style="color: #64748b;"><i class="far fa-edit"></i></a>' +
            N'<a href="#" class="as-form-modal" data-code="tm_clientViewForm" data-itemID="' + CONVERT(NVARCHAR(20), c.id) + N'" style="color: #64748b;"><i class="fas fa-eye"></i></a>' +
        N'</div>' AS [edit]

  FROM tm_clients c
  LEFT JOIN tm_statuses s ON c.status_id = s.id AND s.entity_type = 'client'
  WHERE c.id IN (SELECT id FROM #ids)
  ORDER BY id
  OFFSET @PageSize * (@Page - 1) ROWS
  FETCH NEXT @PageSize ROWS ONLY;

  SELECT COUNT(*) FROM #ids

  SELECT
        '' AS title,
        1 AS HideTitleCount,
        1 AS [EnableExcelExport],
        1 AS EnablePrint,
        'id' AS keyField,
        0 AS showSearch,
        1 AS showPagination,
        20 AS defaultPageSize,
        N'{
            "fio": { "placeholder": "🔍 Имя или Фамилия...", "cssClass": "form-control crm-filter-input" },
            "status": { "placeholder": "💡 Выберите статус", "width": "200px", "cssClass": "form-control select-picker crm-filter-select" }
        }' AS FilterOptions;

  DROP TABLE #ids
END
GO

-- (2) crud_tm_clients_status_dict
CREATE PROCEDURE [dbo].[crud_tm_clients_status_dict]
  @tableCode nvarchar(32),
  @col nvarchar(32),
  @username nvarchar(32),
  @parameters ExtendedDictionaryParameter readonly,
  @filters CRUDFilterParameter READONLY
AS
BEGIN
    DECLARE @tenant_id bigint;
    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON au.email = tu.email AND au.username = @username

    SELECT
        N'<span style="color: #94a3b8;">— Выберите статус —</span>' AS Text,
        0 AS Value
    UNION ALL
    SELECT
        CASE
            WHEN ts.code = 'active' THEN N'<span style="display:inline-flex; align-items:center; gap:8px;"><span style="width:8px;height:8px;border-radius:50%;background:#22c55e;display:inline-block;"></span> ' + ts.name + N'</span>'
            WHEN ts.code = 'OnBreak' THEN N'<span style="display:inline-flex; align-items:center; gap:8px;"><span style="width:8px;height:8px;border-radius:50%;background:#f59e0b;display:inline-block;"></span> ' + ts.name + N'</span>'
            WHEN ts.code = 'Inactive' THEN N'<span style="display:inline-flex; align-items:center; gap:8px;"><span style="width:8px;height:8px;border-radius:50%;background:#ef4444;display:inline-block;"></span> ' + ts.name + N'</span>'
            WHEN ts.code = 'Fired' THEN N'<span style="display:inline-flex; align-items:center; gap:8px;"><span style="width:8px;height:8px;border-radius:50%;background:#94a3b8;display:inline-block;"></span> ' + ts.name + N'</span>'
            ELSE N'<span>' + ts.name + N'</span>'
        END AS Text,
        ts.id AS Value
    FROM tm_statuses ts
    WHERE ts.tenant_id = @tenant_id AND entity_type = 'client'
    ORDER BY Value;
END
GO

-- (3) fm_tm_clientForm_getItem
CREATE PROCEDURE [dbo].[fm_tm_clientForm_getItem]
    @itemID int,
    @username nvarchar(256)
AS
BEGIN
    DECLARE @tenant_id BIGINT;
    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    SELECT
        NULL AS id, '' AS last_name, '' AS first_name, '' AS middle_name,
        '' AS phone, '' AS email, '' AS address, 'website' AS source;

    SELECT '' Title, '' Subtitle, 'h2' HeaderTag, 1 LineLabel
END
GO

-- (4) fm_tm_clientForm_saveItem
CREATE PROCEDURE [dbo].[fm_tm_clientForm_saveItem]
   @username nvarchar(256),
   @itemID int,
   @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
    DECLARE @plast_name nvarchar(100), @pfirst_name nvarchar(100), @pmiddle_name nvarchar(100)
    DECLARE @pphone nvarchar(50), @pemail nvarchar(256), @paddress nvarchar(500), @psource nvarchar(50)

    SELECT @plast_name = Value2 FROM @parameters WHERE [key] = 'last_name'
    SELECT @pfirst_name = Value2 FROM @parameters WHERE [key] = 'first_name'
    SELECT @pmiddle_name = Value2 FROM @parameters WHERE [key] = 'middle_name'
    SELECT @pphone = Value2 FROM @parameters WHERE [key] = 'phone'
    SELECT @pemail = Value2 FROM @parameters WHERE [key] = 'email'
    SELECT @paddress = Value2 FROM @parameters WHERE [key] = 'address'
    SELECT @psource = Value2 FROM @parameters WHERE [key] = 'source'

    DECLARE @tenant_id BIGINT;
    DECLARE @now DATETIME = GETDATE();

    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    IF @tenant_id IS NULL
    BEGIN SELECT 0 AS Result, 'Компания не найдена' AS Msg; RETURN; END

    IF ISNULL(@pfirst_name, '') = ''
    BEGIN SELECT 0 AS Result, 'Укажите имя' AS Msg; RETURN; END

    IF ISNULL(@pphone, '') = ''
    BEGIN SELECT 0 AS Result, 'Укажите телефон' AS Msg; RETURN; END

    IF @itemID IS NULL OR @itemID = 0
    BEGIN
        INSERT INTO tm_clients (tenant_id, last_name, first_name, middle_name, phone, email, address, source, status, status_id, created_at)
        VALUES (@tenant_id, @plast_name, @pfirst_name, @pmiddle_name, @pphone, @pemail, @paddress, @psource, 'active',
                (SELECT TOP 1 id FROM tm_statuses WHERE tenant_id = @tenant_id AND entity_type = 'client' AND code = 'active'),
                @now);

        SELECT 1 AS Result, 'Клиент создан' AS Msg, '' AS SuccessUrl, 1 AS HideFormAfterSubmit, '' AS RefreshContainer, 0 AS EnableSaveAlert;
    END
    ELSE
    BEGIN
        UPDATE tm_clients
        SET last_name = @plast_name, first_name = @pfirst_name, middle_name = @pmiddle_name,
            phone = @pphone, email = @pemail, address = @paddress, source = @psource, updated_at = @now
        WHERE id = @itemID;

        SELECT 1 AS Result, 'Клиент обновлён' AS Msg, '' AS SuccessUrl, 1 AS HideFormAfterSubmit, '' AS RefreshContainer, 0 AS EnableSaveAlert;
    END
END
GO

-- (5) fm_tm_clientEditForm_getItem
CREATE PROCEDURE [dbo].[fm_tm_clientEditForm_getItem]
    @itemID int,
    @username nvarchar(256)
AS
BEGIN
    DECLARE @tenant_id BIGINT
    SET @tenant_id = (SELECT tu.tenant_id
                      FROM tm_users tu
                      JOIN as_users au ON tu.email = au.email AND au.username = @username)

    SELECT ISNULL(first_name, '') first_name, ISNULL(last_name, '') last_name, ISNULL(middle_name, '') middle_name,
           ISNULL(phone, '') phone, ISNULL(email, '') email, ISNULL(address, '') address
    FROM tm_clients
    WHERE tenant_id = @tenant_id AND id = @itemID

    SELECT '' Title, '' Subtitle, 'h2' HeaderTag, 1 LineLabel
END
GO

-- (6) fm_tm_clientEditForm_saveItem
CREATE PROCEDURE [dbo].[fm_tm_clientEditForm_saveItem]
   @username nvarchar(256),
   @itemID int,
   @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @plast_name nvarchar(100), @pfirst_name nvarchar(100), @pmiddle_name nvarchar(100)
    DECLARE @pphone nvarchar(max), @pemail nvarchar(256), @paddress nvarchar(500)
    DECLARE @psource nvarchar(50), @pstatus_id nvarchar(128)

    SELECT @plast_name = Value2 FROM @parameters WHERE [key] = 'last_name'
    SELECT @pfirst_name = Value2 FROM @parameters WHERE [key] = 'first_name'
    SELECT @pmiddle_name = Value2 FROM @parameters WHERE [key] = 'middle_name'
    SELECT @pphone = Value2 FROM @parameters WHERE [key] = 'phone'
    SELECT @pemail = Value2 FROM @parameters WHERE [key] = 'email'
    SELECT @paddress = Value2 FROM @parameters WHERE [key] = 'address'
    SELECT @psource = Value2 FROM @parameters WHERE [key] = 'source'
    SELECT @pstatus_id = Value2 FROM @parameters WHERE [key] = 'status_id'

    DECLARE @tenant_id BIGINT;
    DECLARE @now DATETIME = GETDATE();

    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    IF @tenant_id IS NULL
    BEGIN SELECT 0 AS Result, 'Компания не найдена' AS Msg; RETURN; END

    IF ISNULL(@pfirst_name, '') = ''
    BEGIN SELECT 0 AS Result, 'Укажите имя' AS Msg; RETURN; END

    UPDATE tm_clients
    SET last_name = @plast_name, first_name = @pfirst_name, middle_name = @pmiddle_name,
        phone = @pphone, email = @pemail, address = @paddress, source = @psource, updated_at = @now
    WHERE id = @itemID AND tenant_id = @tenant_id;

    SELECT 1 AS Result, 'Клиент обновлён' AS Msg, '' AS SuccessUrl, 1 AS HideFormAfterSubmit, '' AS RefreshContainer, 0 AS EnableSaveAlert;
END
GO

-- (7) fm_tm_clientViewForm_getItem
CREATE PROCEDURE [dbo].[fm_tm_clientViewForm_getItem]
    @itemID int,
    @username nvarchar(256)
AS
BEGIN
    DECLARE @tenant_id BIGINT;
    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    SELECT
        c.id,
        UPPER(LEFT(ISNULL(c.first_name, '?'), 1)) + UPPER(LEFT(ISNULL(c.last_name, ''), 1)) as initials,
        c.last_name, c.first_name, c.middle_name,
        c.phone, c.email, c.address, c.created_at,
        s.code AS status_code,
        CASE
            WHEN s.code = 'active' THEN N'<span style="display:inline-flex; align-items:center; gap:8px; background:#f0fdf4; color:#166534; padding:6px 14px; border-radius:20px; font-size:0.82rem; font-weight:600;"><span style="width:6px;height:6px;background:#22c55e;border-radius:50%;"></span> ' + ISNULL(s.name, N'Активный') + N'</span>'
            WHEN s.code = 'potential' THEN N'<span style="display:inline-flex; align-items:center; gap:8px; background:#fffbeb; color:#b45309; padding:6px 14px; border-radius:20px; font-size:0.82rem; font-weight:600;"><span style="width:6px;height:6px;background:#f59e0b;border-radius:50%;"></span> ' + ISNULL(s.name, N'Потенциальный') + N'</span>'
            WHEN s.code = 'inactive' THEN N'<span style="display:inline-flex; align-items:center; gap:8px; background:#fef2f2; color:#991b1b; padding:6px 14px; border-radius:20px; font-size:0.82rem; font-weight:600;"><span style="width:6px;height:6px;background:#ef4444;border-radius:50%;"></span> ' + ISNULL(s.name, N'Неактивный') + N'</span>'
            WHEN s.code = 'vip' THEN N'<span style="display:inline-flex; align-items:center; gap:8px; background:#fdf2f8; color:#9d174d; padding:6px 14px; border-radius:20px; font-size:0.82rem; font-weight:600;"><span style="width:6px;height:6px;background:#ec4899;border-radius:50%;"></span> 👑 ' + ISNULL(s.name, N'VIP') + N'</span>'
            ELSE N'<span style="display:inline-flex; align-items:center; gap:8px; background:#f5f5f5; color:#616161; padding:6px 14px; border-radius:20px; font-size:0.82rem; font-weight:600;"><span style="width:6px;height:6px;background:#cbd5e1;border-radius:50%;"></span> ' + ISNULL(s.name, N'—') + N'</span>'
        END AS status_name
    FROM tm_clients c
    LEFT JOIN tm_statuses s ON c.status_id = s.id
    WHERE c.id = @itemID AND c.tenant_id = @tenant_id;

    SELECT COUNT(*) AS projects_count FROM tm_projects WHERE client_id = @itemID;

    SELECT ISNULL(SUM(ISNULL(budget, 0)), 0) AS total_revenue FROM tm_projects WHERE client_id = @itemID;
END
GO

-- (8) fm_tm_clientForm_source_dict
CREATE PROCEDURE [dbo].[fm_tm_clientForm_source_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
   DECLARE @tenant_id bigint, @user_email nvarchar(256)
   SET @user_email = (SELECT email FROM as_users WHERE username = @username)
   SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

  SELECT 'Выберети источник' Text, 0 Value
  UNION
  SELECT name Text, id Value
  FROM tm_lead_sources
  WHERE tenant_id = @tenant_id
  ORDER BY Value
END
GO