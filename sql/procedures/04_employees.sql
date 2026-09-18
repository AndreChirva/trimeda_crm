-- ==========================================
-- СОТРУДНИКИ: CRUD, словари, формы, доступы
-- ==========================================

-- (1) crud_tm_employees_getItems
CREATE PROCEDURE [dbo].[crud_tm_employees_getItems]
  @filters CRUDFilterParameter READONLY,
  @sort sql_variant,
  @direction nvarchar(8),
  @page int,
  @pageSize int,
  @username nvarchar(32)
AS
BEGIN
    DECLARE @isDirector bit = dbo.sec_isUserInRole(@username, 'owner')
    DECLARE @tenant_id bigint;
    DECLARE @status int = ISNULL((SELECT TRY_CAST(value AS int) FROM @filters WHERE [Key] = 'status'), 0)
    DECLARE @fio NVARCHAR(255) = ISNULL((SELECT value FROM @filters WHERE [Key] = 'name'), '');
    DECLARE @email NVARCHAR(255) = ISNULL((SELECT value FROM @filters WHERE [Key] = 'email'), '');
    DECLARE @phone NVARCHAR(255) = ISNULL((SELECT value FROM @filters WHERE [Key] = 'phone'), '');

    SELECT @tenant_id = tenant_id
    FROM tm_users tu
    JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username

    IF (OBJECT_ID('tempdb..#ids') IS NOT NULL) DROP TABLE #ids
    CREATE TABLE #ids (id int PRIMARY KEY)

    INSERT INTO #ids (id)
    SELECT tu.id
    FROM tm_users tu
    LEFT JOIN tm_statuses s ON tu.status_id = s.id
    WHERE tu.tenant_id = @tenant_id
        AND tu.deleted_at IS NULL
        AND (@status = 0 OR s.id = @status)
        AND (@fio = '' OR tu.first_name LIKE '%' + @fio + '%' OR tu.last_name LIKE '%' + @fio + '%')
        AND (@email = '' OR tu.email LIKE '%' + @email + '%')
        AND (@phone = '' OR tu.phone LIKE '%' + @phone + '%')

    SELECT
        tu.id,
        N'<div style="font-weight: 600; color: #1e293b; font-size: 0.95rem;">' + ISNULL(tu.first_name, '') + ' ' + ISNULL(tu.last_name, '') + N'</div>' +
        CASE
            WHEN r.name = N'Собственник' THEN N'<div style="font-size: 0.8rem; color: #2e7d32; font-weight: 500; margin-top: 2px;">👑 Директор</div>'
            ELSE N'<div style="font-size: 0.8rem; color: #64748b; margin-top: 2px;">' + ISNULL(r.name, N'') + N'</div>'
        END AS [name],

        N'<div style="color: #334155; font-size: 0.9rem;">' + ISNULL(tu.position, N'—') + N'</div>' AS [position],

        N'<a href="mailto:' + tu.email + N'" style="color: #475569; font-size: 0.9rem; text-decoration: none; border-bottom: 1px dashed #cbd5e1;">' + tu.email + N'</a>' AS [email],

        N'<div style="color: #475569; font-size: 0.9rem;">' + ISNULL(tu.phone, N'—') + N'</div>' AS [phone],

        CASE
            WHEN au.username = @username THEN
                N'<div style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; background:' +
                CASE
                    WHEN s.code = 'active' THEN N'#f0fdf4; color:#166534;'
                    WHEN s.code = 'OnBreak' THEN N'#fffbeb; color:#b45309;'
                    WHEN s.code = 'Inactive' THEN N'#fef2f2; color:#991b1b;'
                    WHEN s.code = 'Fired' THEN N'#f1f5f9; color:#64748b;'
                    ELSE N'#f8fafc; color:#475569;'
                END + N'">' +
                CASE
                    WHEN s.code = 'active' THEN N'<span style="width:6px;height:6px;background:#22c55e;border-radius:50%;"></span> ' + s.name
                    WHEN s.code = 'OnBreak' THEN N'<span style="width:6px;height:6px;background:#f59e0b;border-radius:50%;"></span> ' + s.name
                    WHEN s.code = 'Inactive' THEN N'<span style="width:6px;height:6px;background:#ef4444;border-radius:50%;"></span> ' + s.name
                    WHEN s.code = 'Fired' THEN N'<span style="width:6px;height:6px;background:#94a3b8;border-radius:50%;"></span> ' + s.name
                    ELSE N'<span style="width:6px;height:6px;background:#cbd5e1;border-radius:50%;"></span> ' + ISNULL(s.name, N'—')
                END +
                N' <i class="fas fa-lock" style="font-size:0.75rem; opacity:0.6;"></i></div>'
            ELSE
                N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, tu.id) + N'" data-param-p1="employee" style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; text-decoration:none; background:' +
                CASE
                    WHEN s.code = 'active' THEN N'#f0fdf4; color:#166534;'
                    WHEN s.code = 'OnBreak' THEN N'#fffbeb; color:#b45309;'
                    WHEN s.code = 'Inactive' THEN N'#fef2f2; color:#991b1b;'
                    WHEN s.code = 'Fired' THEN N'#f1f5f9; color:#64748b;'
                    ELSE N'#f8fafc; color:#475569;'
                END + N'">' +
                CASE
                    WHEN s.code = 'active' THEN N'<span style="width:6px;height:6px;background:#22c55e;border-radius:50%;"></span> ' + s.name
                    WHEN s.code = 'OnBreak' THEN N'<span style="width:6px;height:6px;background:#f59e0b;border-radius:50%;"></span> ' + s.name
                    WHEN s.code = 'Inactive' THEN N'<span style="width:6px;height:6px;background:#ef4444;border-radius:50%;"></span> ' + s.name
                    WHEN s.code = 'Fired' THEN N'<span style="width:6px;height:6px;background:#94a3b8;border-radius:50%;"></span> ' + s.name
                    ELSE N'<span style="width:6px;height:6px;background:#cbd5e1;border-radius:50%;"></span> ' + ISNULL(s.name, N'—')
                END +
                N'</a>'
        END AS [status],

        N'<div style="color: #94a3b8; font-size: 0.85rem;">' + CONVERT(NVARCHAR(10), tu.created_at, 104) + N'</div>' AS [created_at],

        N'<div style="display: inline-flex; gap: 14px; align-items: center;">' +
            N'<a href="#" class="as-form-modal" data-code="tm_employeeForm" data-itemID="' + CONVERT(NVARCHAR(20), tu.id) + N'" style="color: #64748b;"><i class="far fa-edit" style="font-size: 1.05rem;"></i></a>' +
        N'</div>' AS [edit]

    FROM tm_users tu
    INNER JOIN #ids ids ON tu.id = ids.id
    LEFT JOIN tm_user_roles ur ON tu.id = ur.user_id
    LEFT JOIN tm_roles r ON ur.role_id = r.id
    LEFT JOIN tm_statuses s ON tu.status_id = s.id AND s.entity_type = 'employee'
    LEFT JOIN as_users au ON tu.email = au.email
    WHERE tu.status <> 'deleted'
    ORDER BY tu.id DESC
    OFFSET (@page - 1) * @pageSize ROWS
    FETCH NEXT @pageSize ROWS ONLY;

    SELECT COUNT(*) AS total FROM #ids;

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
            "name": { "placeholder": "🔍 Имя или Фамилия...", "cssClass": "form-control crm-filter-input" },
            "email": { "placeholder": "✉️ Email сотрудника...", "cssClass": "form-control crm-filter-input" },
            "phone": { "placeholder": "📱 Телефон...", "cssClass": "form-control crm-filter-input" },
            "status": { "placeholder": "💡 Выберите статус", "width": "200px", "cssClass": "form-control select-picker crm-filter-select" }
        }' AS FilterOptions;

    DROP TABLE #ids;
END
GO

-- (2) crud_tm_employees_deleteItem
CREATE PROCEDURE [dbo].[crud_tm_employees_deleteItem]
    @itemID int,
    @username nvarchar(32)
AS
BEGIN
    DECLARE @name nvarchar(64)
    SELECT @name = username FROM as_users WHERE id = @itemID

    DECLARE @isAdmin bit = dbo.sec_isUserInRole(@username, 'admin')
    IF @isAdmin = 0 AND dbo.sec_isUserInRole(@name, 'admin') = 1
    BEGIN
        SELECT 'Не можете удалять пользователей с ролью admin' Msg, 0 Result
        RETURN
    END

    DECLARE @tm_user_id BIGINT, @tenant_id BIGINT
    DECLARE @user_email NVARCHAR(256), @user_login NVARCHAR(256)
    DECLARE @is_owner BIT = 0

    SELECT @user_login = username, @user_email = email
    FROM as_users WHERE id = @itemID

    IF ISNULL(@user_email, '') <> ''
    BEGIN
        SELECT @tm_user_id = id, @tenant_id = tenant_id
        FROM tm_users WHERE email = @user_email;
    END

    IF @tm_user_id IS NULL
    BEGIN
        SELECT @tm_user_id = id, @tenant_id = tenant_id
        FROM tm_users WHERE email = @user_login;
    END

    IF @tm_user_id IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM tm_user_roles ur
                   INNER JOIN tm_roles r ON ur.role_id = r.id
                   WHERE ur.user_id = @tm_user_id AND r.code = 'owner')
        BEGIN
            SET @is_owner = 1
        END
    END

    IF @is_owner = 1 AND @tenant_id IS NOT NULL
    BEGIN
        DELETE FROM tm_pipeline_stages WHERE pipeline_id IN (SELECT id FROM tm_pipelines WHERE tenant_id = @tenant_id);
        DELETE FROM tm_pipelines WHERE tenant_id = @tenant_id;
        DELETE FROM tm_expense_categories WHERE tenant_id = @tenant_id;
        DELETE FROM tm_lead_sources WHERE tenant_id = @tenant_id;
        DELETE FROM tm_tenant_settings WHERE tenant_id = @tenant_id;
        DELETE FROM tm_user_roles WHERE user_id IN (SELECT id FROM tm_users WHERE tenant_id = @tenant_id);
        DELETE FROM tm_users WHERE tenant_id = @tenant_id;
        DELETE FROM tm_roles WHERE tenant_id = @tenant_id;
        DELETE FROM tm_subscriptions WHERE tenant_id = @tenant_id;
        DELETE FROM tm_tenants WHERE id = @tenant_id;
    END
    ELSE IF @tm_user_id IS NOT NULL
    BEGIN
        DELETE FROM tm_user_roles WHERE user_id = @tm_user_id;
        DELETE FROM tm_users WHERE id = @tm_user_id;
    END

    DELETE FROM as_userRoles WHERE userID = @itemID
    DELETE FROM as_msg_red WHERE msgID IN (SELECT id FROM as_msg_messages WHERE userID = @itemID)
    DELETE FROM as_msg_red WHERE userID = @itemID
    DELETE FROM as_msg_messages WHERE userID = @itemID
    DELETE FROM as_msg_roomUsers WHERE userID = @itemID

    EXEC [dbo].[as_users_deleteUser] @itemID

    IF (@@ROWCOUNT > 0)
        SELECT 'OK' Msg, 1 Result
    ELSE
        SELECT 'Error occurs while user deleting...' Msg, 0 Result
END
GO

-- (3) fm_tm_employeeForm_getItem
CREATE PROCEDURE [dbo].[fm_tm_employeeForm_getItem]
    @itemID int,
    @username nvarchar(256)
AS
BEGIN
    DECLARE @tenant_id BIGINT
    SET @tenant_id = (SELECT tu.tenant_id
                      FROM tm_users tu
                      JOIN as_users au ON tu.email = au.email AND au.username = @username)

    SELECT ISNULL(tu.first_name, '') firstName, ISNULL(tu.last_name, '') lastName,
           ISNULL(tu.email, '') email, ISNULL(tu.phone, '') phone, '' password
    FROM tm_users tu
    WHERE tu.tenant_id = @tenant_id AND tu.id = @itemID

    SELECT '' Title, '' Subtitle, 'h2' HeaderTag, 1 LineLabel
END
GO

-- (4) fm_tm_employeeForm_saveItem
CREATE PROCEDURE [dbo].[fm_tm_employeeForm_saveItem]
   @username nvarchar(256),
   @itemID int,
   @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pfirstName nvarchar(max), @plastName nvarchar(max), @pemail nvarchar(max)
    DECLARE @pphone nvarchar(max), @ppassword nvarchar(max)

    SELECT @pfirstName = Value2 FROM @parameters WHERE [key]='firstName'
    SELECT @plastName = Value2 FROM @parameters WHERE [key]='lastName'
    SELECT @pemail = Value2 FROM @parameters WHERE [key]='email'
    SELECT @pphone = Value2 FROM @parameters WHERE [key]='phone'
    SELECT @ppassword = Value2 FROM @parameters WHERE [key]='password'

    DECLARE @userEmail nvarchar(256)
    SET @userEmail = (SELECT email FROM tm_users WHERE id = @itemID)

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE tm_users
        SET first_name = @pfirstName,
            last_name = @plastName,
            phone = @pphone
        WHERE id = @itemID

        IF ISNULL(@ppassword, '') <> ''
        BEGIN
            IF LEN(@ppassword) < 5
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 0 AS Result, N'Ошибка: Новый пароль должен быть не менее 5 символов!' AS Msg;
                RETURN
            END

            DECLARE @NewPasswordHash NVARCHAR(MAX)
            EXEC dbo.as_encryptPassword2 @passwordIn = @ppassword, @passwordOut = @NewPasswordHash OUTPUT;

            UPDATE AS_USERS SET passwordHash = @NewPasswordHash WHERE email = @userEmail

            INSERT INTO dbo.as_trace (code, header, text, created, username)
            VALUES ('team', 'Password reset by admin', 'User: ' + @userEmail, GETDATE(), @username);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 0 AS Result, ERROR_MESSAGE() AS Msg;
    END CATCH

    SELECT
        1 AS Result,
        N'<div style="font-family: system-ui, sans-serif; padding: 4px; background: #1B5E20; color: #fff; border-radius: 8px; text-align: center;">' +
            N'<b>Карточка сотрудника успешно обновлена! 🌿</b>' +
            CASE WHEN ISNULL(@ppassword, '') <> '' THEN N'<br><span style="font-size:0.85rem; color:#A5D6A7;">Новый пароль успешно активирован.</span>' ELSE N'' END +
        N'</div>' AS Msg,
        '' AS SuccessUrl,
        1 AS HideFormAfterSubmit,
        '#as-table-tm_employees' AS RefreshContainer,
        0 AS EnableSaveAlert;

    SELECT '' AS [type];
END
GO

-- (5) fm_tm_employeeAccess_getItem
CREATE PROCEDURE [dbo].[fm_tm_employeeAccess_getItem]
    @username NVARCHAR(256),
    @itemID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Login NVARCHAR(256);
    SELECT @Login = email FROM dbo.tm_users WHERE id = @itemID;

    IF CHARINDEX('@', ISNULL(@Login, '')) > 0
        SET @Login = LEFT(@Login, CHARINDEX('@', @Login) - 1);
    SET @Login = REPLACE(@Login, '.', '');

    SELECT
        N'<div style="font-family: system-ui, sans-serif; padding: 10px; text-align: left;">' +
            N'<p style="color: #475569; font-size: 0.95rem; margin-bottom: 20px; line-height: 1.5;">' +
                N'Учетная запись сотрудника успешно активирована в базе данных «Ландшафт.Офис». ' +
                N'Скопируйте сгенерированные доступы для передачи члену команды:' +
            N'</p>' +
            N'<div style="background: #f8fafc; padding: 18px; border-radius: 12px; border: 1px solid #e2e8f0; font-size: 1.05rem; margin-bottom: 20px; color: #1e293b; line-height: 1.7;">' +
                N'<b>Логин доступа:</b> <span style="font-weight:600; color:#1b5e20;">' + ISNULL(@Login, '') + N'</span><br>' +
                N'<b>Пароль доступа:</b> <span style="color: #2E7D32; font-weight: 700; font-family: monospace; font-size: 1.15rem; letter-spacing:0.5px; background:#fff; padding:2px 8px; border-radius:4px; border:1px solid #e2e8f0;">123456</span>' +
            N'</div>' +
            N'<div style="color: #94a3b8; font-size: 0.8rem; text-align: center; margin-top: 15px;">' +
                N'Вы можете скопировать текст прямо с экрана. Окно закроется только при нажатии на крестик.' +
            N'</div>' +
        N'</div>' AS [text];

    SELECT
        N'Доступы сотрудника созданы! 🎉' AS title,
        N'Завершить' AS saveBtnText,
        1 AS hideSaveBtn,
        460 AS width;
END
GO

-- (6) fm_tm_employeeForm_position_dict
CREATE PROCEDURE [dbo].[fm_tm_employeeForm_position_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
    DECLARE @tenant_id bigint, @position nvarchar(max)
    SET @tenant_id = (SELECT tu.tenant_id FROM tm_users tu JOIN as_users au ON tu.email = au.email AND au.username = @username)
    SET @position = (SELECT [position] FROM tm_users WHERE tenant_id = @tenant_id AND id = @itemID)

    SELECT [position] Text, 0 Value
    FROM tm_users
    WHERE tenant_id = @tenant_id AND id = @itemID
    UNION
    SELECT name Text, id Value
    FROM tm_positions
    WHERE tenant_id = @tenant_id AND name <> @position
    ORDER BY Value
END
GO

-- (7) crud_tm_employees_status_dict
CREATE PROCEDURE [dbo].[crud_tm_employees_status_dict]
  @tableCode nvarchar(32),
  @col nvarchar(32),
  @username nvarchar(32),
  @parameters ExtendedDictionaryParameter readonly,
  @filters CRUDFilterParameter READONLY
AS
BEGIN
    DECLARE @user_email nvarchar(255), @tenant_id bigint
    SET @user_email = (SELECT email FROM as_users WHERE username = @username)
    SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

    SELECT 0 Value, 'Выберети статус' Text
    UNION
    SELECT id Value, name Text
    FROM tm_statuses
    WHERE entity_type = 'employee' AND tenant_id = @tenant_id
    ORDER BY Value
END
GO

-- (8) fm_tm_employeeStatusForm_saveItem
CREATE PROCEDURE [dbo].[fm_tm_employeeStatusForm_saveItem]
    @username nvarchar(256),
    @itemID int,
    @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
    DECLARE @pstatus_id nvarchar(max), @p1 nvarchar(50)
    SELECT @pstatus_id = Value2 FROM @parameters WHERE [key] = 'status_id'
    SELECT @p1 = Value2 FROM @parameters WHERE [key] = 'p1'

    DECLARE @tenant_id BIGINT
    DECLARE @status_id INT = TRY_CAST(@pstatus_id AS INT)

    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username

    IF @tenant_id IS NULL BEGIN SELECT 0 AS Result, 'Компания не найдена' AS Msg; RETURN; END
    IF ISNULL(@status_id, 0) = 0 BEGIN SELECT 0 AS Result, 'Выберите статус' AS Msg; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM tm_statuses WHERE id = @status_id AND tenant_id = @tenant_id)
    BEGIN SELECT 0 AS Result, 'Статус не найден' AS Msg; RETURN; END

    IF @p1 = 'client'
        UPDATE tm_clients SET status_id = @status_id, updated_at = GETDATE()
        WHERE id = @itemID AND tenant_id = @tenant_id;
    ELSE IF @p1 = 'project'
        UPDATE tm_projects SET status_id = @status_id, updated_at = GETDATE()
        WHERE id = @itemID AND tenant_id = @tenant_id;
    ELSE IF @p1 = 'employee'
        UPDATE tm_users SET status_id = @status_id, updated_at = GETDATE()
        WHERE id = @itemID AND tenant_id = @tenant_id;
    ELSE
    BEGIN
        IF EXISTS (SELECT 1 FROM tm_projects WHERE id = @itemID AND tenant_id = @tenant_id)
            UPDATE tm_projects SET status_id = @status_id, updated_at = GETDATE() WHERE id = @itemID;
        ELSE IF EXISTS (SELECT 1 FROM tm_clients WHERE id = @itemID AND tenant_id = @tenant_id)
            UPDATE tm_clients SET status_id = @status_id, updated_at = GETDATE() WHERE id = @itemID;
        ELSE
            UPDATE tm_users SET status_id = @status_id, updated_at = GETDATE() WHERE id = @itemID;
    END

    SELECT 1 AS Result, 'Статус обновлён' AS Msg, '' AS SuccessUrl, 1 AS HideFormAfterSubmit, '' AS RefreshContainer, 1 AS EnableSaveAlert;

    SELECT '' AS type;
END
GO