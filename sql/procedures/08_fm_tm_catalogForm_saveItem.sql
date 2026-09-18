-- ==========================================
-- fm_tm_catalogForm_saveItem
-- Сохранение позиции каталога: insert/update + привязка фото
-- ==========================================

CREATE PROCEDURE [dbo].[fm_tm_catalogForm_saveItem]
   @username nvarchar(256),
   @itemID int,
   @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pname nvarchar(max)
    SELECT @pname = Value2 FROM @parameters WHERE [key]='name'
    DECLARE @psku nvarchar(max)
    SELECT @psku = Value2 FROM @parameters WHERE [key]='sku'
    DECLARE @ptype int
    SELECT @ptype = Value2 FROM @parameters WHERE [key]='type'
    DECLARE @punit int
    SELECT @punit = Value2 FROM @parameters WHERE [key]='unit'
    DECLARE @pcost_price FLOAT
    SELECT @pcost_price = Value2 FROM @parameters WHERE [key]='cost_price'
    DECLARE @pretail_price FLOAT
    SELECT @pretail_price = Value2 FROM @parameters WHERE [key]='retail_price'
    DECLARE @psupplier_id nvarchar(max)
    SELECT @psupplier_id = Value2 FROM @parameters WHERE [key]='supplier_id'
    DECLARE @pdescription nvarchar(max)
    SELECT @pdescription = Value2 FROM @parameters WHERE [key]='description'
    DECLARE @pis_active nvarchar(max)
    SELECT @pis_active = Value2 FROM @parameters WHERE [key]='is_active'
    DECLARE @psize nvarchar(max)
    SELECT @psize = Value2 FROM @parameters WHERE [Key] = 'size'

    DECLARE @tenant_id BIGINT
    DECLARE @now DATETIME = GETDATE()
    DECLARE @typeName nvarchar(256)
    DECLARE @unitCode nvarchar(20)

    SET @typeName = (SELECT name FROM tm_catalog_types WHERE id = @ptype)
    SET @unitCode = (SELECT code FROM tm_catalog_units WHERE id = @punit)

    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    IF @tenant_id IS NULL
    BEGIN
        SELECT 0 Result, 'Компания не найдена' Msg
        RETURN
    END

    IF ISNULL(@pname, '') = ''
    BEGIN
        SELECT 0 Result, 'Укажите название' Msg
        RETURN
    END

    IF ISNULL(@ptype, '') = ''
    BEGIN
        SELECT 0 Result, 'Укажите тип' Msg
        RETURN
    END

    IF ISNULL(@punit, '') = ''
    BEGIN
        SELECT 0 Result, 'Укажите единицу измерения' Msg
        RETURN
    END

    IF COALESCE(@itemID, 0) = 0
    BEGIN
        INSERT INTO tm_catalog (
            tenant_id, name, sku, [type], unit, cost_price, retail_price,
            supplier_id, description, is_active, created_at,
            tm_catalog_type_id, [size], tm_catalog_units_id
        )
        VALUES (
            @tenant_id, @pname, ISNULL(@psku, ''), @typeName, @unitCode,
            TRY_CAST(@pcost_price AS DECIMAL(15,2)),
            TRY_CAST(@pretail_price AS DECIMAL(15,2)),
            NULLIF(TRY_CAST(@psupplier_id AS BIGINT), 0),
            @pdescription,
            CASE WHEN @pis_active = 'True' THEN 1 ELSE 0 END,
            @now, @ptype, @psize, @punit
        )

        SET @itemID = SCOPE_IDENTITY()

        UPDATE as_rs_resources
        SET itemID = CAST(@itemID AS nvarchar(64))
        WHERE entityCode = 'catalogPhotos'
              AND ISNULL(itemID, '') = '{col-itemID}'

        SELECT
            1 Result,
            'Позиция создана' Msg,
            '' AS SuccessUrl,
            1 AS HideFormAfterSubmit,
            '#as-table-tm_catalog' AS RefreshContainer,
            1 AS EnableSaveAlert
    END
    ELSE
    BEGIN
        UPDATE tm_catalog
        SET name = @pname,
            sku = ISNULL(@psku, ''),
            unit = @unitCode,
            tm_catalog_units_id = @punit,
            cost_price = TRY_CAST(@pcost_price AS DECIMAL(15,2)),
            retail_price = TRY_CAST(@pretail_price AS DECIMAL(15,2)),
            supplier_id = NULLIF(TRY_CAST(@psupplier_id AS BIGINT), 0),
            description = @pdescription,
            is_active = CASE WHEN @pis_active = 'True' THEN 1 ELSE 0 END,
            updated_at = @now,
            [size] = @psize,
            tm_catalog_type_id = @ptype,
            [type] = @typeName
        WHERE id = @itemID AND tenant_id = @tenant_id

        SELECT
            1 AS Result,
            'Позиция обновлена!' AS Msg,
            '' AS SuccessUrl,
            1 AS HideFormAfterSubmit,
            '#as-table-tm_catalog' AS RefreshContainer,
            1 AS EnableSaveAlert
    END

    SELECT '' [type]
END
