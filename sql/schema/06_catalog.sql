-- ==========================================
-- 06. КАТАЛОГ
-- Растения, материалы, услуги, техника
-- ==========================================

-- Типы каталога (растения, материалы, инженерия, техника, услуги)
CREATE TABLE tm_catalog_types (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100),
    code            NVARCHAR(50),
    icon            NVARCHAR(50),
    bg_color        NVARCHAR(40),
    text_color      NVARCHAR(40),
    ord             INT DEFAULT 0,
    is_active       BIT DEFAULT 1,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Единицы измерения
CREATE TABLE tm_catalog_units (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(50),
    code            NVARCHAR(20),
    ord             INT DEFAULT 0,
    is_active       BIT DEFAULT 1,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Каталог (основная таблица)
CREATE TABLE tm_catalog (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id           BIGINT NOT NULL,
    type                NVARCHAR(50),
    sku                 NVARCHAR(100),
    name                NVARCHAR(255),
    description         NVARCHAR(MAX),
    unit                NVARCHAR(20),
    cost_price          DECIMAL(15,2),
    retail_price        DECIMAL(15,2),
    base_price          DECIMAL(15,2),
    tax_rate            DECIMAL(5,2) DEFAULT 20,
    supplier_id         BIGINT,
    is_active           BIT DEFAULT 1,
    tags                NVARCHAR(MAX),
    images              NVARCHAR(MAX),
    tm_catalog_type_id  INT,
    tm_catalog_units_id INT,
    has_variants        BIT DEFAULT 0,
    parent_id           BIGINT,
    size                NVARCHAR(100),
    created_at          DATETIME2 DEFAULT GETDATE(),
    updated_at          DATETIME2,
    CONSTRAINT UQ_tm_catalog_tenant_sku UNIQUE (tenant_id, sku)
);

-- Варианты позиций каталога
CREATE TABLE tm_catalog_variants (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    catalog_id      BIGINT NOT NULL,
    sku             NVARCHAR(100),
    name            NVARCHAR(255),
    price           DECIMAL(15,2),
    cost_price      DECIMAL(15,2),
    unit            NVARCHAR(20),
    sort_order      INT DEFAULT 0,
    is_active       BIT DEFAULT 1,
    is_default      BIT DEFAULT 0,
    attributes      NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Атрибуты каталога
CREATE TABLE tm_catalog_attributes (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100),
    type            NVARCHAR(50),
    options         NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Значения атрибутов
CREATE TABLE tm_catalog_attribute_values (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    catalog_id      BIGINT NOT NULL,
    attribute_id    BIGINT NOT NULL,
    value           NVARCHAR(MAX),
    CONSTRAINT UQ_tm_catalog_attr UNIQUE (catalog_id, attribute_id)
);

-- Спецификации растений (латынь, высота, ком земли и т.д.)
CREATE TABLE tm_plant_specifications (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    catalog_id      BIGINT NOT NULL,
    latin_name      NVARCHAR(255),
    height          NVARCHAR(50),
    diameter        NVARCHAR(50),
    root_ball       NVARCHAR(50),
    weight          DECIMAL(10,2),
    created_at      DATETIME2 DEFAULT GETDATE()
);
