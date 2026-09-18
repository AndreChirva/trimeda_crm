-- ==========================================
-- fm_tm_employeeForm_saveItem
-- Сохранение сотрудника: транзакция, хеширование пароля, логирование
-- ==========================================

CREATE PROCEDURE [dbo].[fm_tm_employeeForm_saveItem]
   @username nvarchar(256),
   @itemID int,
   @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pfirstName nvarchar(max)
    SELECT @pfirstName = Value2 FROM @parameters WHERE [key]='firstName'
    DECLARE @plastName nvarchar(max)
    SELECT @plastName = Value2 FROM @parameters WHERE [key]='lastName'
    DECLARE @pemail nvarchar(max)
    SELECT @pemail = Value2 FROM @parameters WHERE [key]='email'
    DECLARE @pphone nvarchar(max)
    SELECT @pphone = Value2 FROM @parameters WHERE [key]='phone'
    DECLARE @ppassword nvarchar(max)
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

            UPDATE AS_USERS
            SET passwordHash = @NewPasswordHash
            WHERE email = @userEmail

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