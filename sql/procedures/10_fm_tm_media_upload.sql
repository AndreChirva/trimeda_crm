-- ==========================================
-- fm_tm_media_upload
-- Загрузка файла в медиа-хранилище
-- ==========================================

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

    DECLARE @user_email NVARCHAR(256)
    DECLARE @tenant_id BIGINT
    DECLARE @media_id BIGINT
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