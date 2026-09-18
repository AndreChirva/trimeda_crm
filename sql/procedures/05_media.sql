-- ==========================================
-- МЕДИА: загрузка, удаление, список
-- ==========================================

-- (1) fm_tm_media_upload
CREATE PROCEDURE [dbo].[fm_tm_media_upload]
    @username NVARCHAR(256),
    @entity_type NVARCHAR(50),
    @entity_id BIGINT,
    @file_name NVARCHAR(255),
    @file_path NVARCHAR(500),
    @file_size BIGINT = NULL,
    @mime_type NVARCHAR(255) = NULL,
    @title NVARCHAR(255) = NULL,
    @alt_text NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @user_email NVARCHAR(256), @tenant_id BIGINT, @media_id BIGINT
    DECLARE @now DATETIME = GETDATE()

    SELECT @user_email = email FROM as_users WHERE username = @username
    SELECT @tenant_id = tenant_id FROM tm_users WHERE email = @user_email

    IF COALESCE(@tenant_id, 0) = 0
    BEGIN
        SELECT 0 AS Result, 'Компания не найдена' AS Msg
        RETURN
    END

    DECLARE @ord INT
    SET @ord = ISNULL(
        (SELECT MAX(ord) + 1
         FROM tm_media
         WHERE tenant_id = @tenant_id
           AND entity_type = @entity_type
           AND entity_id = @entity_id),
        0)

    INSERT INTO tm_media (
        tenant_id, entity_type, entity_id, file_name, file_path,
        file_size, mime_type, storage_type, title, alt_text,
        ord, created_by, created_at
    )
    VALUES (
        @tenant_id, @entity_type, @entity_id, @file_name, @file_path,
        @file_size, @mime_type, 'local', @title, @alt_text,
        @ord,
        (SELECT id FROM tm_users WHERE tenant_id = @tenant_id AND email = @user_email),
        @now
    )

    SET @media_id = SCOPE_IDENTITY()

    SELECT
        1 AS Result,
        'Файл загружен' AS Msg,
        @media_id AS media_id,
        dbo.tm_get_media_url(@file_path, 'local', NULL) AS url;
END
GO

-- (2) fm_tm_media_delete
CREATE PROCEDURE [dbo].[fm_tm_media_delete]
    @username nvarchar(256),
    @media_id BIGINT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @user_email nvarchar(256), @tenant_id BIGINT

    SET @user_email = (SELECT email FROM as_users WHERE username = @username)
    SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

    UPDATE tm_media
    SET deleted_at = GETDATE()
    WHERE id = @media_id AND tenant_id = @tenant_id

    IF @@ROWCOUNT > 0
        SELECT 1 Result, 'Файл удален' Msg
    ELSE
        SELECT 0 Result, 'Файл не найден' Msg
END
GO

-- (3) crud_tm_media_getItems
CREATE PROCEDURE [dbo].[crud_tm_media_getItems]
    @filters CRUDFilterParameter READONLY,
    @sort sql_variant,
    @direction nvarchar(8),
    @page int,
    @pageSize int,
    @username nvarchar(32)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tenant_id BIGINT, @entity_type NVARCHAR(50), @entity_id BIGINT;

    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    SELECT @entity_type = ISNULL((SELECT TOP 1 Value FROM @filters WHERE [Key] = 'entity_type'), '');
    SELECT @entity_id = TRY_CAST((SELECT TOP 1 Value FROM @filters WHERE [Key] = 'entity_id') AS BIGINT);

    SELECT
        m.id, m.file_name, m.file_path, m.mime_type, m.file_size,
        m.title, m.alt_text, m.ord, m.created_at,
        dbo.tm_get_media_url(m.file_path, m.storage_type, m.storage_url) AS url,
        N'<img src="' + dbo.tm_get_media_url(m.file_path, m.storage_type, m.storage_url) + N'"
               style="width: 80px; height: 80px; object-fit: cover; border-radius: 8px; border: 2px solid #e2e8f0;">' AS preview,
        N'<a href="#" class="as-action-btn" data-action="delete_media" data-itemID="' + CONVERT(NVARCHAR(20), m.id) + N'" style="color: #64748b;">
            <i class="far fa-trash-alt"></i>
        </a>' AS actions
    FROM tm_media m
    WHERE m.tenant_id = @tenant_id
      AND m.deleted_at IS NULL
      AND (@entity_type = '' OR m.entity_type = @entity_type)
      AND (@entity_id IS NULL OR m.entity_id = @entity_id)
    ORDER BY m.ord
    OFFSET (@page - 1) * @pageSize ROWS
    FETCH NEXT @pageSize ROWS ONLY;

    SELECT COUNT(*) AS total
    FROM tm_media
    WHERE tenant_id = @tenant_id
      AND deleted_at IS NULL
      AND (@entity_type = '' OR entity_type = @entity_type)
      AND (@entity_id IS NULL OR entity_id = @entity_id);

    SELECT 'Медиа' AS title, 'id' AS keyField, 1 AS showPagination, 20 AS defaultPageSize;
END
GO