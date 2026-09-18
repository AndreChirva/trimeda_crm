-- ==========================================
-- 07. СКЛАД И ЗАКУПКИ
-- ==========================================

-- Склады
CREATE TABLE tm_warehouses (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100),
    address         NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Остатки на складе
CREATE TABLE tm_stock_items (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    warehouse_id    BIGINT NOT NULL,
    catalog_id      BIGINT NOT NULL,
    quantity        DECIMAL(15,3) DEFAULT 0,
    reserved        DECIMAL(15,3) DEFAULT 0,
    CONSTRAINT UQ_tm_stock_items_warehouse_catalog UNIQUE (warehouse_id, catalog_id)
);

-- Движения по складу
CREATE TABLE tm_stock_movements (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    warehouse_id    BIGINT NOT NULL,
    catalog_id      BIGINT NOT NULL,
    type            NVARCHAR(20),
    quantity        DECIMAL(15,3),
    comment         NVARCHAR(MAX),
    created_by      BIGINT,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Поставщики (питомники, магазины)
CREATE TABLE tm_suppliers (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(255),
    phone           NVARCHAR(50),
    email           NVARCHAR(255),
    address         NVARCHAR(MAX),
    inn             NVARCHAR(40),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Заказы на закупку
CREATE TABLE tm_purchase_orders (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    supplier_id     BIGINT,
    number          NVARCHAR(50),
    status          NVARCHAR(50),
    total_amount    DECIMAL(15,2),
    created_at      DATETIME2 DEFAULT GETDATE(),
    updated_at      DATETIME2
);

-- Позиции заказов
CREATE TABLE tm_purchase_order_items (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    purchase_order_id   BIGINT NOT NULL,
    catalog_id          BIGINT NOT NULL,
    quantity            DECIMAL(15,3),
    price               DECIMAL(15,2),
    total               DECIMAL(15,2)
);

-- Прайс-листы поставщиков
CREATE TABLE tm_price_lists (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    supplier_id     BIGINT,
    name            NVARCHAR(100),
    valid_from      DATE,
    valid_to        DATE,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Позиции прайс-листов
CREATE TABLE tm_price_list_items (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    price_list_id   BIGINT NOT NULL,
    catalog_id      BIGINT NOT NULL,
    price           DECIMAL(15,2),
    CONSTRAINT UQ_tm_price_list_catalog UNIQUE (price_list_id, catalog_id)
);