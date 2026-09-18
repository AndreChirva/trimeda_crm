-- ==========================================
-- fm_tm_catalogForm_checkItem
-- Валидация бизнес-правил для позиции каталога
-- ==========================================

CREATE PROCEDURE [dbo].[fm_tm_catalogForm_checkItem]
   @username nvarchar(256),
   @itemID nvarchar(256),
   @parameters ExtendedDictionaryParameter readonly
AS
BEGIN

   DECLARE @pname NVARCHAR(255)
    SELECT @pname = Value2 FROM @parameters WHERE [key] = 'name'

    DECLARE @ptype NVARCHAR(50)
    SELECT @ptype = Value2 FROM @parameters WHERE [key] = 'type'

    DECLARE @punit NVARCHAR(50)
    SELECT @punit = Value2 FROM @parameters WHERE [key] = 'unit'

    DECLARE @pcost_price FLOAT
    SELECT @pcost_price = Value2 FROM @parameters WHERE [key] = 'cost_price'

    DECLARE @pretail_price FLOAT
    SELECT @pretail_price = Value2 FROM @parameters WHERE [key] = 'retail_price'

    IF ISNULL(@pname, '') = ''
    BEGIN
        SELECT 0 AS Result, 'Укажите название' AS Msg
        RETURN
    END

    IF ISNULL(@ptype, '') = ''
    BEGIN
        SELECT 0 AS Result, 'Выберите тип позиции' AS Msg
        RETURN
    END

    IF ISNULL(@punit, '') = ''
    BEGIN
        SELECT 0 AS Result, 'Выберите единицу измерения' AS Msg
        RETURN
    END

    IF TRY_CAST(@pcost_price AS DECIMAL(15,2)) < 0
    BEGIN
        SELECT 0 AS Result, 'Себестоимость не может быть отрицательной' AS Msg
        RETURN
    END

    IF TRY_CAST(@pretail_price AS DECIMAL(15,2)) < 0
    BEGIN
        SELECT 0 AS Result, 'Розничная цена не может быть отрицательной' AS Msg
        RETURN
    END

    IF TRY_CAST(@pretail_price AS DECIMAL(15,2)) < TRY_CAST(@pcost_price AS DECIMAL(15,2))
    BEGIN
        SELECT 0 AS Result, 'Розничная цена ниже себестоимости' AS Msg
        RETURN
    END

    SELECT 1 AS Result, '' AS Msg
END