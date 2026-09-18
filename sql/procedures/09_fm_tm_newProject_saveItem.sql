-- ==========================================
-- fm_tm_newProject_saveItem
-- Создание проекта: insert/update + логирование
-- ==========================================

CREATE PROCEDURE [dbo].[fm_tm_newProject_saveItem]
    @username nvarchar(256),
    @itemID int,
    @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pname nvarchar(255)
    SELECT @pname = Value2 FROM @parameters WHERE [key] = 'name'

    DECLARE @pclient_id nvarchar(128)
    SELECT @pclient_id = Value2 FROM @parameters WHERE [key] = 'client_id'

    DECLARE @paddress nvarchar(500)
    SELECT @paddress = Value2 FROM @parameters WHERE [key] = 'address'

    DECLARE @parea nvarchar(50)
    SELECT @parea = Value2 FROM @parameters WHERE [key] = 'area'

    DECLARE @pproject_type_id nvarchar(50)
    SELECT @pproject_type_id = Value2 FROM @parameters WHERE [key] = 'project_type_id'

    DECLARE @pstatus_id nvarchar(50)
    SELECT @pstatus_id = Value2 FROM @parameters WHERE [key] = 'status_id'

    DECLARE @pmanager_id nvarchar(128)
    SELECT @pmanager_id = Value2 FROM @parameters WHERE [key] = 'manager_id'

    DECLARE @pbudget nvarchar(50)
    SELECT @pbudget = Value2 FROM @parameters WHERE [key] = 'budget'

    DECLARE @pstart_date nvarchar(50)
    SELECT @pstart_date = Value2 FROM @parameters WHERE [key] = 'start_date'

    DECLARE @pend_date nvarchar(50)
    SELECT @pend_date = Value2 FROM @parameters WHERE [key] = 'end_date'

    DECLARE @tenant_id BIGINT
    DECLARE @project_id BIGINT
    DECLARE @now DATETIME = GETDATE()
    DECLARE @status_id INT = TRY_CAST(@pstatus_id AS INT)
    DECLARE @project_type_id INT = TRY_CAST(@pproject_type_id AS INT)
    DECLARE @project_type_code NVARCHAR(50)

    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username

    IF @tenant_id IS NULL
    BEGIN
        SELECT 0 AS Result, 'Компания не найдена' AS Msg
        RETURN
    END

    IF ISNULL(@pname, '') = ''
    BEGIN
        SELECT 0 AS Result, 'Укажите название проекта' AS Msg
        RETURN
    END

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
        INSERT INTO tm_projects (
            tenant_id, name, client_id, address, area, project_type,
            project_type_id, status_id, manager_id, budget,
            start_date, end_date, created_at
        )
        VALUES (
            @tenant_id, @pname, TRY_CAST(@pclient_id AS BIGINT),
            @paddress, TRY_CAST(@parea AS DECIMAL(10,2)),
            @project_type_code, @project_type_id, @status_id,
            TRY_CAST(@pmanager_id AS BIGINT),
            TRY_CAST(@pbudget AS DECIMAL(15,2)),
            TRY_CAST(@pstart_date AS DATE),
            TRY_CAST(@pend_date AS DATE),
            @now
        )
        SET @project_id = SCOPE_IDENTITY()

        SELECT
            1 AS Result,
            'Проект создан!' AS Msg,
            '' AS SuccessUrl,
            1 AS HideFormAfterSubmit,
            '#as-table-tm_projects' AS RefreshContainer,
            1 AS EnableSaveAlert
    END
    ELSE
    BEGIN
        UPDATE tm_projects
        SET name = @pname,
            client_id = TRY_CAST(@pclient_id AS BIGINT),
            address = @paddress,
            area = TRY_CAST(@parea AS DECIMAL(10,2)),
            project_type = @project_type_code,
            project_type_id = @project_type_id,
            status_id = @status_id,
            manager_id = TRY_CAST(@pmanager_id AS BIGINT),
            budget = TRY_CAST(@pbudget AS DECIMAL(15,2)),
            start_date = TRY_CAST(@pstart_date AS DATE),
            end_date = TRY_CAST(@pend_date AS DATE),
            updated_at = @now
        WHERE id = @itemID AND tenant_id = @tenant_id

        SELECT
            1 AS Result,
            'Проект обновлён!' AS Msg,
            '' AS SuccessUrl,
            1 AS HideFormAfterSubmit,
            '#as-table-tm_projects' AS RefreshContainer,
            1 AS EnableSaveAlert
    END

    INSERT INTO as_trace (code, header, text, created, username)
    VALUES ('project', 'Project saved', 'ID: ' + CONVERT(NVARCHAR, @itemID), @now, @username)

    SELECT '' AS type
END