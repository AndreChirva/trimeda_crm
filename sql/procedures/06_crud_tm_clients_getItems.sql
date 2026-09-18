-- ==========================================
-- crud_tm_clients_getItems
-- Таблица клиентов: фильтры, пагинация, HTML
-- ==========================================

CREATE PROCEDURE [dbo].[crud_tm_clients_getItems]
  @filters CRUDFilterParameter READONLY,
  @sort sql_variant,
  @direction nvarchar(8),
  @page int,
  @pageSize int,
  @username nvarchar(32)
AS
BEGIN
  DECLARE @fio nvarchar(128) = (SELECT TOP 1 Value FROM @filters WHERE [Key] = 'fio')
  DECLARE @status int = (SELECT TOP 1 TRY_CAST(Value AS int) FROM @filters WHERE [Key] = 'status')

  DECLARE @tenant_id BIGINT;

  SELECT @tenant_id = tu.tenant_id
  FROM tm_users tu
  INNER JOIN as_users au ON tu.email = au.email
  WHERE au.username = @username;

  IF (OBJECT_ID('tempdb..#ids') IS NOT NULL) DROP TABLE #ids
  CREATE TABLE #ids (id int PRIMARY KEY)

  INSERT INTO #ids
  SELECT id
  FROM tm_clients
  WHERE tenant_id = @tenant_id AND deleted_at IS NULL
        AND (ISNULL(@fio, '') = '' OR first_name LIKE '%' + @fio + '%'
             OR last_name LIKE '%' + @fio + '%' OR middle_name LIKE '%' + @fio + '%'
             OR email LIKE '%' + @fio + '%' OR phone LIKE '%' + @fio + '%')
        AND (@status = 0 OR status_id = @status)

  SELECT ISNULL(c.id, '') id,
        N'<div style="display: flex; align-items: center; gap: 12px; padding: 4px 0;">' +
            N'<div style="width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(135deg, #2E7D32, #4CAF50); display: flex; align-items: center; justify-content: center; color: #ffffff; font-weight: 700; font-size: 0.9rem; flex-shrink: 0;">' +
                UPPER(LEFT(ISNULL(c.first_name, '?'), 1)) + UPPER(LEFT(ISNULL(c.last_name, ''), 1)) +
            N'</div>' +
            N'<div>' +
                N'<div style="font-weight: 600; color: #1e293b; font-size: 0.95rem;">' +
                    ISNULL(c.last_name, '') + ' ' + ISNULL(c.first_name, '') + ' ' + ISNULL(c.middle_name, '') +
                N'</div>' +
            N'</div>' +
        N'</div>' AS [fio],

        N'<div style="display: flex; align-items: center; gap: 6px; color: #475569; font-size: 0.9rem;">' +
            N'<i class="fas fa-phone-alt" style="color: #90a4ae; font-size: 0.75rem;"></i>' +
            ISNULL(c.phone, N'—') +
        N'</div>' AS [phone],

        N'<a href="mailto:' + ISNULL(c.email, '') + N'" style="color: #475569; font-size: 0.9rem; text-decoration: none; border-bottom: 1px dashed #cbd5e1;">' +
            ISNULL(c.email, N'—') +
        N'</a>' AS [email],

        N'<div style="display: flex; align-items: center; gap: 6px; color: #64748b; font-size: 0.85rem;">' +
            N'<i class="fas fa-map-marker-alt" style="color: #90a4ae; font-size: 0.75rem;"></i>' +
            ISNULL(c.address, N'—') +
        N'</div>' AS [address],

        CASE
            WHEN s.code = 'active' THEN
                N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, c.id) + N'" data-param-p1="client" style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; text-decoration:none; background:#f0fdf4; color:#166534;"><span style="width:6px;height:6px;background:#22c55e;border-radius:50%;"></span> ' + ISNULL(s.name, N'Активный') + N'</a>'
            WHEN s.code = 'potential' THEN
                N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, c.id) + N'" data-param-p1="client" style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; text-decoration:none; background:#fffbeb; color:#b45309;"><span style="width:6px;height:6px;background:#f59e0b;border-radius:50%;"></span> ' + ISNULL(s.name, N'Потенциальный') + N'</a>'
            WHEN s.code = 'inactive' THEN
                N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, c.id) + N'" data-param-p1="client" style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; text-decoration:none; background:#fef2f2; color:#991b1b;"><span style="width:6px;height:6px;background:#ef4444;border-radius:50%;"></span> ' + ISNULL(s.name, N'Неактивный') + N'</a>'
            WHEN s.code = 'vip' THEN
                N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, c.id) + N'" data-param-p1="client" style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; text-decoration:none; background:#fdf2f8; color:#9d174d;"><span style="width:6px;height:6px;background:#ec4899;border-radius:50%;"></span> 👑 ' + ISNULL(s.name, N'VIP') + N'</a>'
            ELSE
                N'<a href="#" class="as-form-modal" data-code="tm_employeeStatusForm" data-itemID="' + CONVERT(NVARCHAR, c.id) + N'" data-param-p1="client" style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; font-size:0.85rem; font-weight:600; text-decoration:none; background:#f5f5f5; color:#616161;"><span style="width:6px;height:6px;background:#cbd5e1;border-radius:50%;"></span> ' + ISNULL(s.name, N'—') + N'</a>'
        END AS [status],

        N'<div style="color: #94a3b8; font-size: 0.85rem;">' +
            ISNULL(CONVERT(NVARCHAR(10), c.created_at, 104), N'—') +
        N'</div>' AS [created_at],

        N'<div style="display: inline-flex; gap: 14px; align-items: center;">' +
            N'<a href="#" class="as-form-modal" data-code="tm_clientEditForm" data-itemID="' + CONVERT(NVARCHAR(20), c.id) + N'" data-title="Редактировать клиента" style="color: #64748b;"><i class="far fa-edit"></i></a>' +
            N'<a href="#" class="as-form-modal" data-code="tm_clientViewForm" data-itemID="' + CONVERT(NVARCHAR(20), c.id) + N'" style="color: #64748b;"><i class="fas fa-eye"></i></a>' +
        N'</div>' AS [edit]

  FROM tm_clients c
  LEFT JOIN tm_statuses s ON c.status_id = s.id AND s.entity_type = 'client'
  WHERE c.id IN (SELECT id FROM #ids)
  ORDER BY id
  OFFSET @PageSize * (@Page - 1) ROWS
  FETCH NEXT @PageSize ROWS ONLY;

  SELECT COUNT(*) FROM #ids

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
            "fio": { "placeholder": "🔍 Имя или Фамилия...", "cssClass": "form-control crm-filter-input" },
            "status": { "placeholder": "💡 Выберите статус", "width": "200px", "cssClass": "form-control select-picker crm-filter-select" }
        }' AS FilterOptions;

  DROP TABLE #ids
END