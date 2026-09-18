-- ==========================================
-- crud_tm_employees_deleteItem
-- Каскадное удаление сотрудника и тенанта
-- ==========================================

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

    DECLARE @tm_user_id BIGINT
    DECLARE @tenant_id BIGINT
    DECLARE @user_email NVARCHAR(256)
    DECLARE @user_login NVARCHAR(256)
    DECLARE @is_owner BIT = 0

    SELECT
        @user_login = username,
        @user_email = email
    FROM as_users
    WHERE id = @itemID

    IF ISNULL(@user_email, '') <> ''
    BEGIN
        SELECT
            @tm_user_id = id,
            @tenant_id = tenant_id
        FROM tm_users
        WHERE email = @user_email;
    END

    IF @tm_user_id IS NULL
    BEGIN
        SELECT
            @tm_user_id = id,
            @tenant_id = tenant_id
        FROM tm_users
        WHERE email = @user_login;
    END

    IF @tm_user_id IS NOT NULL
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM tm_user_roles ur
            INNER JOIN tm_roles r ON ur.role_id = r.id
            WHERE ur.user_id = @tm_user_id
                AND r.code = 'owner'
        )
        BEGIN
            SET @is_owner = 1
        END
    END

    IF @is_owner = 1 AND @tenant_id IS NOT NULL
    BEGIN
        DELETE FROM tm_pipeline_stages
        WHERE pipeline_id IN (SELECT id FROM tm_pipelines WHERE tenant_id = @tenant_id);

        DELETE FROM tm_pipelines WHERE tenant_id = @tenant_id;
        DELETE FROM tm_expense_categories WHERE tenant_id = @tenant_id;
        DELETE FROM tm_lead_sources WHERE tenant_id = @tenant_id;
        DELETE FROM tm_tenant_settings WHERE tenant_id = @tenant_id;

        DELETE FROM tm_user_roles
        WHERE user_id IN (SELECT id FROM tm_users WHERE tenant_id = @tenant_id);

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
    BEGIN
        SELECT 'OK' Msg, 1 Result
    END
    ELSE
    BEGIN
        SELECT 'Error occurs while user deleting...' Msg, 0 Result
    END
END