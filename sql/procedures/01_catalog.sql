-- ==========================================
-- КАТАЛОГ: CRUD, словари, формы
-- ==========================================

-- (1) crud_tm_catalog_getItems
CREATE PROCEDURE [dbo].[crud_tm_catalog_getItems]
  @filters CRUDFilterParameter READONLY,
  @sort sql_variant,
  @direction nvarchar(8),
  @page int,
  @pageSize int,
  @username nvarchar(32)
AS
BEGIN
  DECLARE @tenant_id BIGINT;
  SELECT @tenant_id = tu.tenant_id
  FROM tm_users tu
  INNER JOIN as_users au ON tu.email = au.email
  WHERE au.username = @username;

  DECLARE @is_active int = ISNULL((SELECT TOP 1 Value FROM @filters WHERE [Key] = 'is_active'), '')
  DECLARE @filterName NVARCHAR(255) = ISNULL((SELECT TOP 1 Value FROM @filters WHERE [Key] = 'name'), '')
  DECLARE @filterType int = ISNULL((SELECT TOP 1 Value FROM @filters WHERE [Key] = 'type'), '')
  DECLARE @filterUnit int = ISNULL((SELECT TOP 1 Value FROM @filters WHERE [Key] = 'unit'), '')

  IF OBJECT_ID('tempdb..#ids') IS NOT NULL DROP TABLE #ids;
  CREATE TABLE #ids (id BIGINT PRIMARY KEY);

  INSERT INTO #ids (id)
  SELECT ISNULL(c.id, 0) id
  FROM tm_catalog c
  WHERE c.tenant_id = @tenant_id
    AND CASE
      WHEN @is_active = 0 THEN 1
      WHEN @is_active = 1 AND c.is_active = 1 THEN 1
      WHEN @is_active = 2 AND c.is_active = 0 THEN 1
      ELSE 0
    END = 1
    AND (@filterName = '' OR c.name LIKE '%' + @filterName + '%')
    AND (ISNULL(@filterType, 0) = 0 OR c.tm_catalog_type_id = @filterType)
    AND (ISNULL(@filterUnit, 0) = 0 OR c.tm_catalog_units_id = @filterUnit)

  SELECT
    c.id,
    N'<div style="display: flex; align-items: center; gap: 12px;">' +
        N'<div style="width: 42px; height: 42px; border-radius: 10px; background: linear-gradient(135deg, #E8F5E9, #C8E6C9); display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; overflow: hidden;">' +
            ISNULL(ct.icon, N'📦') +
        N'</div>' +
        N'<div style="min-width: 0;">' +
            N'<div style="font-weight: 600; color: #1e293b; font-size: 0.95rem;">' + ISNULL(c.name, N'—') + N'</div>' +
            N'<div style="font-size: 0.78rem; color: #64748b;">Артикул: ' + ISNULL(c.sku, '—') + N'</div>' +
        N'</div>' +
    N'</div>' AS [name],

    N'<span style="display:inline-flex; align-items:center; gap:6px; background:' + ISNULL(ct.bg_color, N'#f5f5f5') + N'; color:' + ISNULL(ct.text_color, N'#616161') + N'; padding:5px 12px; border-radius:8px; font-size:0.78rem; font-weight:700;">' +
        ISNULL(ct.icon, N'📦') + N' ' + ISNULL(ct.name, N'—') +
    N'</span>' AS [type],

    N'<div style="color: #334155; font-size: 0.9rem;">' + ISNULL(c.unit, N'—') + N'</div>' AS [unit],
    N'<div style="color: #64748b; font-size: 0.9rem;">' + ISNULL(FORMAT(c.cost_price, 'N0'), N'0') + N' ₽</div>' AS [cost_price],
    N'<div style="color: #1B5E20; font-size: 0.95rem; font-weight: 700;">' + ISNULL(FORMAT(c.retail_price, 'N0'), N'0') + N' ₽</div>' AS [retail_price],

    N'<div style="display: inline-flex; gap: 12px;">' +
        N'<a href="#" class="as-form-modal" data-code="tm_catalogForm" data-itemID="' + CONVERT(NVARCHAR(20), c.id) + N'"><i class="far fa-edit"></i></a>' +
        N'<a href="#" class="as-form-modal" data-code="tm_catalogViewForm" data-itemID="' + CONVERT(NVARCHAR(20), c.id) + N'"><i class="fas fa-eye"></i></a>' +
    N'</div>' AS [actions]
  FROM tm_catalog c
  INNER JOIN #ids ids ON c.id = ids.id
  LEFT JOIN tm_catalog_types ct ON ct.id = c.tm_catalog_type_id AND ct.tenant_id = c.tenant_id
  ORDER BY c.id DESC
  OFFSET (@page - 1) * @pageSize ROWS
  FETCH NEXT @pageSize ROWS ONLY;

  SELECT COUNT(*) AS total FROM #ids;

  SELECT
    'Каталог' AS title,
    1 AS HideTitleCount,
    1 AS [EnableExcelExport],
    1 AS EnablePrint,
    'id' AS keyField,
    0 AS showSearch,
    1 AS showPagination,
    20 AS defaultPageSize,
    N'{
      "name": { "placeholder": "🔍 Название...", "cssClass": "form-control crm-filter-input" },
      "type": { "placeholder": "📦 Тип позиции", "cssClass": "form-control crm-filter-select" },
      "unit": { "placeholder": "Единица измерения", "cssClass": "form-control crm-filter-select" },
      "is_active": { "placeholder": "Активные/неактивные", "cssClass": "form-control crm-filter-select" }
    }' AS FilterOptions;

  DROP TABLE #ids;
END
GO

-- (2) crud_tm_catalog_deleteItem
CREATE PROCEDURE [dbo].[crud_tm_catalog_deleteItem]
    @itemID int,
    @username nvarchar(32)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @tenant_id BIGINT;
    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    IF @tenant_id IS NULL
    BEGIN
        SELECT 'Компания не найдена' AS Msg, 0 AS Result;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM tm_catalog WHERE id = @itemID AND tenant_id = @tenant_id)
    BEGIN
        SELECT 'Позиция не найдена' AS Msg, 0 AS Result;
        RETURN;
    END

    DELETE FROM as_rs_resources
    WHERE LOWER(entityCode) = 'catalogphotos'
      AND itemID = CAST(@itemID AS nvarchar(64));

    DELETE FROM tm_catalog WHERE id = @itemID AND tenant_id = @tenant_id;

    IF @@ROWCOUNT > 0
        SELECT 'Позиция удалена' AS Msg, 1 AS Result;
    ELSE
        SELECT 'Ошибка при удалении' AS Msg, 0 AS Result;

    SELECT '' AS [type];
END
GO

-- (3) fm_tm_catalogForm_checkItem
CREATE PROCEDURE [dbo].[fm_tm_catalogForm_checkItem]
   @username nvarchar(256),
   @itemID nvarchar(256),
   @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
   DECLARE @pname NVARCHAR(255), @ptype NVARCHAR(50), @punit NVARCHAR(50)
   DECLARE @pcost_price FLOAT, @pretail_price FLOAT

   SELECT @pname = Value2 FROM @parameters WHERE [key] = 'name'
   SELECT @ptype = Value2 FROM @parameters WHERE [key] = 'type'
   SELECT @punit = Value2 FROM @parameters WHERE [key] = 'unit'
   SELECT @pcost_price = Value2 FROM @parameters WHERE [key] = 'cost_price'
   SELECT @pretail_price = Value2 FROM @parameters WHERE [key] = 'retail_price'

   IF ISNULL(@pname, '') = ''
   BEGIN SELECT 0 AS Result, 'Укажите название' AS Msg; RETURN; END
   IF ISNULL(@ptype, '') = ''
   BEGIN SELECT 0 AS Result, 'Выберите тип позиции' AS Msg; RETURN; END
   IF ISNULL(@punit, '') = ''
   BEGIN SELECT 0 AS Result, 'Выберите единицу измерения' AS Msg; RETURN; END
   IF TRY_CAST(@pcost_price AS DECIMAL(15,2)) < 0
   BEGIN SELECT 0 AS Result, 'Себестоимость не может быть отрицательной' AS Msg; RETURN; END
   IF TRY_CAST(@pretail_price AS DECIMAL(15,2)) < 0
   BEGIN SELECT 0 AS Result, 'Розничная цена не может быть отрицательной' AS Msg; RETURN; END
   IF TRY_CAST(@pretail_price AS DECIMAL(15,2)) < TRY_CAST(@pcost_price AS DECIMAL(15,2))
   BEGIN SELECT 0 AS Result, 'Розничная цена ниже себестоимости' AS Msg; RETURN; END

   SELECT 1 AS Result, '' AS Msg
END
GO

-- (4) fm_tm_catalogForm_saveItem
CREATE PROCEDURE [dbo].[fm_tm_catalogForm_saveItem]
   @username nvarchar(256),
   @itemID int,
   @parameters ExtendedDictionaryParameter readonly
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @pname nvarchar(max), @psku nvarchar(max), @ptype int, @punit int
    DECLARE @pcost_price FLOAT, @pretail_price FLOAT
    DECLARE @psupplier_id nvarchar(max), @pdescription nvarchar(max)
    DECLARE @pis_active nvarchar(max), @psize nvarchar(max)

    SELECT @pname = Value2 FROM @parameters WHERE [key]='name'
    SELECT @psku = Value2 FROM @parameters WHERE [key]='sku'
    SELECT @ptype = Value2 FROM @parameters WHERE [key]='type'
    SELECT @punit = Value2 FROM @parameters WHERE [key]='unit'
    SELECT @pcost_price = Value2 FROM @parameters WHERE [key]='cost_price'
    SELECT @pretail_price = Value2 FROM @parameters WHERE [key]='retail_price'
    SELECT @psupplier_id = Value2 FROM @parameters WHERE [key]='supplier_id'
    SELECT @pdescription = Value2 FROM @parameters WHERE [key]='description'
    SELECT @pis_active = Value2 FROM @parameters WHERE [key]='is_active'
    SELECT @psize = Value2 FROM @parameters WHERE [Key] = 'size'

    DECLARE @tenant_id BIGINT
    DECLARE @now DATETIME = GETDATE()
    DECLARE @typeName nvarchar(256), @unitCode nvarchar(20)
    SET @typeName = (SELECT name FROM tm_catalog_types WHERE id = @ptype)
    SET @unitCode = (SELECT code FROM tm_catalog_units WHERE id = @punit)

    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    IF @tenant_id IS NULL BEGIN SELECT 0 Result, 'Компания не найдена' Msg; RETURN; END
    IF ISNULL(@pname, '') = '' BEGIN SELECT 0 Result, 'Укажите название' Msg; RETURN; END
    IF ISNULL(@ptype, '') = '' BEGIN SELECT 0 Result, 'Укажите тип' Msg; RETURN; END
    IF ISNULL(@punit, '') = '' BEGIN SELECT 0 Result, 'Укажите единицу измерения' Msg; RETURN; END

    IF COALESCE(@itemID, 0) = 0
    BEGIN
        INSERT INTO tm_catalog (tenant_id, name, sku, [type], unit, cost_price, retail_price, supplier_id, description, is_active, created_at, tm_catalog_type_id, [size], tm_catalog_units_id)
        VALUES (@tenant_id, @pname, ISNULL(@psku, ''), @typeName, @unitCode,
                TRY_CAST(@pcost_price AS DECIMAL(15,2)), TRY_CAST(@pretail_price AS DECIMAL(15,2)),
                NULLIF(TRY_CAST(@psupplier_id AS BIGINT), 0), @pdescription,
                CASE WHEN @pis_active = 'True' THEN 1 ELSE 0 END, @now, @ptype, @psize, @punit)
        SET @itemID = SCOPE_IDENTITY()

        UPDATE as_rs_resources
        SET itemID = CAST(@itemID AS nvarchar(64))
        WHERE entityCode = 'catalogPhotos' AND ISNULL(itemID, '') = '{col-itemID}'

        SELECT 1 Result, 'Позиция создана' Msg, '' AS SuccessUrl, 1 AS HideFormAfterSubmit, '#as-table-tm_catalog' AS RefreshContainer, 1 AS EnableSaveAlert
    END
    ELSE
    BEGIN
        UPDATE tm_catalog
        SET name = @pname, sku = ISNULL(@psku, ''), unit = @unitCode, tm_catalog_units_id = @punit,
            cost_price = TRY_CAST(@pcost_price AS DECIMAL(15,2)),
            retail_price = TRY_CAST(@pretail_price AS DECIMAL(15,2)),
            supplier_id = NULLIF(TRY_CAST(@psupplier_id AS BIGINT), 0),
            description = @pdescription,
            is_active = CASE WHEN @pis_active = 'True' THEN 1 ELSE 0 END,
            updated_at = @now, [size] = @psize, tm_catalog_type_id = @ptype, [type] = @typeName
        WHERE id = @itemID AND tenant_id = @tenant_id

        SELECT 1 AS Result, 'Позиция обновлена!' AS Msg, '' AS SuccessUrl, 1 AS HideFormAfterSubmit, '#as-table-tm_catalog' AS RefreshContainer, 1 AS EnableSaveAlert
    END

    SELECT '' [type]
END
GO

-- (5) fm_tm_catalogForm_getItem
CREATE PROCEDURE [dbo].[fm_tm_catalogForm_getItem]
    @itemID int,
    @username nvarchar(256)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @tenant_id BIGINT, @user_email nvarchar(255)
    SET @user_email = (SELECT email FROM as_users WHERE username = @username)
    SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @user_email)

    IF COALESCE(@itemID, 0) > 0
    BEGIN
        SELECT ISNULL(c.name, '') [name], ISNULL(c.sku, '') [sku], ISNULL(c.type, '') [type],
               ISNULL(c.unit, '') [unit], ISNULL(c.cost_price, 0) [cost_price],
               ISNULL(c.retail_price, 0) [retail_price], ISNULL(c.supplier_id, 0) [supplier_id],
               ISNULL(c.description, '') [description], c.is_active, ISNULL([size], '') [size]
        FROM tm_catalog c
        LEFT JOIN tm_catalog_types ct ON ct.id = c.tm_catalog_type_id AND ct.tenant_id = c.tenant_id
        WHERE c.id = @itemID AND c.tenant_id = @tenant_id
    END
    ELSE
    BEGIN
        SELECT 0 AS id, 0 AS [itemID], '' AS name, '' AS sku, 'plant' AS type,
               LOWER(NEWID()) AS guid, 'шт' AS unit, 0 AS cost_price, 0 AS retail_price,
               NULL AS supplier_id, '' AS description, '' [size], 1 AS is_active;
    END
END
GO

-- (6) fm_tm_catalogForm_type_dict
CREATE PROCEDURE [dbo].[fm_tm_catalogForm_type_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
    DECLARE @user_email nvarchar(255), @tenant_id bigint, @catalogID bigint
    SET @user_email = (SELECT email FROM as_users WHERE username = @username)
    SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @user_email)
    SET @catalogID = (SELECT tm_catalog_type_id FROM tm_catalog WHERE id = ISNULL(@itemID, 0))

    IF ISNULL(@itemID, 0) = 0
    BEGIN
        SELECT N'— Выберите тип —' AS Text, N'' AS Value
        UNION
        SELECT ISNULL(icon, N'') + N' ' + name AS Text, id Value
        FROM tm_catalog_types
        WHERE tenant_id = @tenant_id AND is_active = 1
        ORDER BY Value
    END
    ELSE
    BEGIN
        SELECT ISNULL(tcp.icon, N'') + N' ' + tcp.name AS Text, tcp.id Value, 0 AS sort_group, 0 AS sort_order
        FROM tm_catalog c
        JOIN tm_catalog_types tcp ON tcp.id = c.tm_catalog_type_id
        WHERE c.tenant_id = @tenant_id AND tcp.is_active = 1 AND c.id = @itemID
        UNION
        SELECT ISNULL(tcp.icon, N'') + N' ' + tcp.name AS Text, tcp.id Value, 1 AS sort_group, 1 AS sort_order
        FROM tm_catalog_types tcp
        WHERE tcp.tenant_id = @tenant_id AND tcp.is_active = 1 AND tcp.id <> @catalogID
        ORDER BY sort_group, sort_order
    END
END
GO

-- (7) fm_tm_catalogForm_unit_dict
CREATE PROCEDURE [dbo].[fm_tm_catalogForm_unit_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
    DECLARE @user_email nvarchar(255), @tenant_id bigint, @unitID bigint
    SET @user_email = (SELECT email FROM as_users WHERE username = @username)
    SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @user_email)
    SET @unitID = (SELECT tm_catalog_units_id FROM tm_catalog WHERE id = @itemID)

    IF ISNULL(@itemID, 0) = 0
    BEGIN
        SELECT N'— Выберите единицу —' AS Text, 0 AS Value
        UNION ALL
        SELECT name + N' (' + code + N')' AS Text, id AS Value
        FROM tm_catalog_units
        WHERE tenant_id = @tenant_id AND is_active = 1
        ORDER BY Value
    END
    ELSE
    BEGIN
        SELECT tcu.name + N' (' + tcu.code + N')' AS Text, tcu.id Value, 0 Ord
        FROM tm_catalog tc
        INNER JOIN tm_catalog_units tcu ON tcu.id = tc.tm_catalog_units_id
        WHERE tcu.tenant_id = @tenant_id AND tcu.is_active = 1 AND tc.id = @itemID
        UNION
        SELECT name + N' (' + code + N')' Text, id Value, 1 Ord
        FROM tm_catalog_units
        WHERE tenant_id = @tenant_id AND is_active = 1 AND id <> @unitID
        ORDER BY Ord
    END
END
GO

-- (8) fm_tm_catalogForm_supplier_id_dict
CREATE PROCEDURE [dbo].[fm_tm_catalogForm_supplier_id_dict]
   @username nvarchar(256),
   @itemID nvarchar(128)
AS
BEGIN
    DECLARE @tenant_id BIGINT;
    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    SELECT N'— выберите поставщика —' AS Text, 0 AS Value
    UNION
    SELECT name AS Text, id AS Value
    FROM tm_suppliers
    WHERE tenant_id = @tenant_id
    ORDER BY Value;
END
GO

-- (9) fm_tm_catalogForm_is_active_dict
CREATE PROCEDURE [dbo].[fm_tm_catalogForm_is_active_dict]
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

-- (10) fm_tm_catalogForm_size_dict
CREATE PROCEDURE [dbo].[fm_tm_catalogForm_size_dict]
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

-- (11) crud_tm_catalog_is_active_dict
CREATE PROCEDURE [dbo].[crud_tm_catalog_is_active_dict]
  @tableCode nvarchar(32),
  @col nvarchar(32),
  @username nvarchar(32),
  @parameters ExtendedDictionaryParameter readonly,
  @filters CRUDFilterParameter READONLY
AS
BEGIN
  SELECT 0 Value, 'Все позиции' Text
  UNION ALL SELECT 1 Value, 'Активные позиции' Text
  UNION ALL SELECT 2 Value, 'Не активные позиции' Text
  ORDER BY Value
END
GO

-- (12) crud_tm_catalog_type_dict
CREATE PROCEDURE [dbo].[crud_tm_catalog_type_dict]
  @tableCode nvarchar(32),
  @col nvarchar(32),
  @username nvarchar(32),
  @parameters ExtendedDictionaryParameter readonly,
  @filters CRUDFilterParameter READONLY
AS
BEGIN
  DECLARE @userEmail nvarchar(256), @tenant_id BIGINT
  SET @userEmail = (SELECT email FROM as_users WHERE username = @username)
  SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @userEmail)

  SELECT 0 Value, 'Выберите тип' Text
  UNION
  SELECT id Value, name Text
  FROM tm_catalog_types
  WHERE tenant_id = @tenant_id AND is_active = 1
  ORDER BY Value
END
GO

-- (13) crud_tm_catalog_unit_dict
CREATE PROCEDURE [dbo].[crud_tm_catalog_unit_dict]
  @tableCode nvarchar(32),
  @col nvarchar(32),
  @username nvarchar(32),
  @parameters ExtendedDictionaryParameter readonly,
  @filters CRUDFilterParameter READONLY
AS
BEGIN
  DECLARE @userEmail nvarchar(256), @tenant_id BIGINT
  SET @userEmail = (SELECT email FROM as_users WHERE username = @username)
  SET @tenant_id = (SELECT tenant_id FROM tm_users WHERE email = @userEmail)

  SELECT 0 Value, 'Выберите ед.изм.' Text
  UNION
  SELECT id Value, name Text
  FROM tm_catalog_units
  WHERE tenant_id = @tenant_id AND is_active = 1
  ORDER BY Value
END
GO

-- (14) crud_tm_catalog_name_dict
CREATE PROCEDURE [dbo].[crud_tm_catalog_name_dict]
  @tableCode nvarchar(32),
  @col nvarchar(32),
  @username nvarchar(32),
  @parameters ExtendedDictionaryParameter readonly,
  @filters CRUDFilterParameter READONLY
AS
BEGIN
  SELECT 0 Value, ' --- ' Text
  UNION
  SELECT TOP 5 id Value, code Text
  FROM as_trace
  ORDER BY Text
END
GO

-- (15) fm_tm_catalogViewForm_getItem
CREATE PROCEDURE [dbo].[fm_tm_catalogViewForm_getItem]
    @itemID int,
    @username nvarchar(256)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @tenant_id BIGINT;
    SELECT @tenant_id = tu.tenant_id
    FROM tm_users tu
    INNER JOIN as_users au ON tu.email = au.email
    WHERE au.username = @username;

    SELECT
        c.id, c.name, c.sku, c.[size], c.unit,
        CAST(CAST(c.cost_price AS decimal(15,2)) AS nvarchar(50)) cost_price,
        CAST(CAST(c.retail_price AS decimal(15,2)) AS nvarchar(50)) retail_price,
        c.description,
        IIF(c.is_active = 1, 'Позиция активная', 'Позиция не активная') is_active,
        c.created_at, ISNULL(c.updated_at, c.created_at) AS updated_at,
        ct.icon AS type_icon, ct.name AS type_name, ct.code AS type_code,
        ct.bg_color AS type_bg, ct.text_color AS type_color,
        s.name AS supplier_name, s.phone AS supplier_phone,
        N'<img src="' + ISNULL((SELECT TOP 1 r.url FROM as_rs_resources r WHERE r.entityCode = 'catalogPhotos' AND r.itemID = CAST(c.id AS nvarchar(64)) ORDER BY r.ord, r.id), '') + N'" style="width:100%; height:100%; object-fit:cover;">' AS photo_url,
        CASE WHEN ISNULL(c.retail_price, 0) > 0
             THEN CAST(((c.retail_price - ISNULL(c.cost_price, 0)) / c.retail_price * 100) AS DECIMAL(5,2))
             ELSE 0 END AS margin_percent,
        ISNULL(c.retail_price, 0) - ISNULL(c.cost_price, 0) AS profit_per_unit,
        FORMAT(ISNULL(c.cost_price, 0), 'N0') AS cost_price,
        FORMAT(ISNULL(c.retail_price, 0), 'N0') AS retail_price,
        FORMAT(ISNULL(c.retail_price, 0) - ISNULL(c.cost_price, 0), 'N0') AS profit,
        CONVERT(NVARCHAR(10), c.created_at, 104) AS created_date_str,
        CONVERT(NVARCHAR(10), ISNULL(c.updated_at, c.created_at), 104) AS updated_date_str
    FROM tm_catalog c
    LEFT JOIN tm_catalog_types ct ON ct.id = c.tm_catalog_type_id AND ct.tenant_id = c.tenant_id
    LEFT JOIN tm_suppliers s ON s.id = c.supplier_id AND s.tenant_id = c.tenant_id
    WHERE c.id = @itemID AND c.tenant_id = @tenant_id;

    SELECT '' AS info;
END
GO