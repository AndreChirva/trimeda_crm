-- ==========================================
-- ФОРМЫ И СЛОВАРИ (остальные процедуры)
-- ==========================================

-- (1) fm_tm_newProject_client_id_dict
CREATE PROCEDURE [dbo].[fm_tm_newProject_client_id_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
    DECLARE @user_email nvarchar(256) = (SELECT email FROM as_users WHERE username = @username)
    DECLARE @tenant_id bigint = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

    SELECT 'Выберите клиента' Text, 0 Value
    UNION
    SELECT ISNULL(last_name, '') + ' ' + ISNULL(first_name, '') + ' ' + ISNULL(middle_name, '') Text, id Value
    FROM tm_clients
    WHERE tenant_id = @tenant_id AND deleted_at IS NULL
    ORDER BY Value
END
GO

-- (2) fm_tm_newProject_manager_id_dict
CREATE PROCEDURE [dbo].[fm_tm_newProject_manager_id_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
    DECLARE @tenant_id bigint, @user_email nvarchar(256)
    SET @user_email = (SELECT email FROM as_users WHERE username = @username)
    SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

    SELECT 0 Value, 'Выберите сотрудника' Text
    UNION
    SELECT id Value, (first_name + ' ' + last_name) Text
    FROM tm_users
    WHERE tenant_id = @tenant_id AND position_id = 2
    ORDER BY Value
END
GO

-- (3) fm_tm_newProject_project_type_dict
CREATE PROCEDURE [dbo].[fm_tm_newProject_project_type_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
    DECLARE @user_email nvarchar(256) = (SELECT email FROM as_users WHERE username = @username)
    DECLARE @tenant_id bigint = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

    SELECT 'Выберите тип проекта' Text, 0 Value
    UNION
    SELECT name Text, id Value
    FROM tm_project_types
    WHERE tenant_id = @tenant_id
    ORDER BY Value
END
GO

-- (4) fm_tm_newProject_project_type_id_dict
CREATE PROCEDURE [dbo].[fm_tm_newProject_project_type_id_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
    DECLARE @tenant_id BIGINT;
    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    SELECT '— Выберите тип —' AS Text, 0 AS Value
    UNION ALL
    SELECT pt.name AS Text, pt.id AS Value
    FROM tm_project_types pt
    WHERE pt.tenant_id = @tenant_id
    ORDER BY Text;
END
GO

-- (5) fm_tm_newProject_address_dict
CREATE PROCEDURE [dbo].[fm_tm_newProject_address_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
    SELECT ' --- ' Text, 0 Value
    UNION
    SELECT TOP 5 code Text, id Value
    FROM as_trace
    ORDER BY Text
END
GO

-- (6) fm_tm_projectEditForm_manager_dict
CREATE PROCEDURE [dbo].[fm_tm_projectEditForm_manager_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
    DECLARE @tenant_id bigint, @user_email nvarchar(256)
    SET @user_email = (SELECT email FROM as_users WHERE username = @username)
    SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

    SELECT id Value, (first_name + ' ' + last_name) Text
    FROM tm_users
    WHERE tenant_id = @tenant_id AND position_id = 2
    ORDER BY Value
END
GO

-- (7) fm_tm_projectEditForm_projectType_dict
CREATE PROCEDURE [dbo].[fm_tm_projectEditForm_projectType_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
    DECLARE @tenant_id bigint, @user_email nvarchar(256)
    SET @user_email = (SELECT email FROM as_users WHERE username = @username)
    SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

    SELECT name Text, id Value
    FROM tm_project_types
    WHERE tenant_id = @tenant_id
    ORDER BY Value
END
GO

-- (8) fm_tm_employeeStatusForm_getItem
CREATE PROCEDURE [dbo].[fm_tm_employeeStatusForm_getItem]
    @itemID int,
    @username nvarchar(256)
AS
BEGIN
    SELECT '' status_id
    SELECT '' Title, '' Subtitle, 'h2' HeaderTag, 1 LineLabel
END
GO

-- (9) fm_tm_employeeStatusForm_status_id_dict
CREATE PROCEDURE [dbo].[fm_tm_employeeStatusForm_status_id_dict]
   @username nvarchar(256),
   @itemID nvarchar(128),
   @parameters ExtendedDictionaryParameter READONLY
AS
BEGIN
    DECLARE @tenant_id bigint;
    DECLARE @entity_type NVARCHAR(50)

    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON au.email = tu.email AND au.username = @username

    SELECT TOP 1 @entity_type = Value2 FROM @parameters WHERE [Key] = 'p1';

    SELECT N'<span style="color: #94a3b8;">— Выберите статус —</span>' AS Text, 0 AS Value
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
    WHERE ts.tenant_id = @tenant_id AND entity_type = @entity_type
    ORDER BY Value;
END
GO

-- (10) fm_tm_employeeForm_saveEditableField
CREATE PROCEDURE [dbo].[fm_tm_employeeForm_saveEditableField]
    @pk nvarchar(128),
    @fieldCode nvarchar(64),
    @value nvarchar(max),
    @username nvarchar(256)
AS
BEGIN
    IF @fieldCode = 'XXX'
    BEGIN
        SELECT 1 Result, '' Msg
        RETURN
    END
    SELECT 0 Result, 'Not found field' Msg
END
GO

-- (11) fm_tm_clientForm_checkItem
CREATE PROCEDURE [dbo].[fm_tm_clientForm_checkItem]
   @username nvarchar(256),
   @itemID nvarchar(256),
   @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
    SELECT 1 Result, '' Msg
END
GO

-- (12) crud_tm_employees_status_id_dict
CREATE PROCEDURE [dbo].[crud_tm_employees_status_id_dict]
  @tableCode nvarchar(32),
  @col nvarchar(32),
  @username nvarchar(32),
  @parameters ExtendedDictionaryParameter readonly,
  @filters CRUDFilterParameter READONLY
AS
BEGIN
    SELECT 0 Value, ' --- ' Text
    UNION
    SELECT id Value, code Text
    FROM tm_statuses
    ORDER BY Value
END
GO