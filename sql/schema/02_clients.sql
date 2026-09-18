-- ==========================================
-- 02. КЛИЕНТЫ
-- ==========================================

-- Клиенты
CREATE TABLE tm_clients (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    type            NVARCHAR(40) DEFAULT N'individual',
    company_name    NVARCHAR(255),
    inn             NVARCHAR(40),
    first_name      NVARCHAR(100),
    last_name       NVARCHAR(100),
    middle_name     NVARCHAR(100),
    email           NVARCHAR(255),
    phone           NVARCHAR(50),
    secondary_phone NVARCHAR(50),
    address         NVARCHAR(MAX),
    source          NVARCHAR(100),
    status          NVARCHAR(40) DEFAULT N'active',
    status_id       INT,
    category        NVARCHAR(100),
    tags            NVARCHAR(MAX),
    custom_fields   NVARCHAR(MAX),
    manager_id      BIGINT,
    notes           NVARCHAR(MAX),
    total_revenue   DECIMAL(15,2) DEFAULT 0,
    created_at      DATETIME2 DEFAULT GETDATE(),
    updated_at      DATETIME2,
    deleted_at      DATETIME2
);

-- Контакты клиента (ЛПР)
CREATE TABLE tm_client_contacts (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    client_id       BIGINT NOT NULL,
    first_name      NVARCHAR(100),
    last_name       NVARCHAR(100),
    position        NVARCHAR(100),
    phone           NVARCHAR(50),
    email           NVARCHAR(255),
    is_primary      BIT DEFAULT 0,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Брифы клиента
CREATE TABLE tm_client_briefs (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id           BIGINT NOT NULL,
    client_id           BIGINT NOT NULL,
    project_id          BIGINT,
    budget_min          DECIMAL(15,2),
    budget_max          DECIMAL(15,2),
    deadline            DATE,
    style_preferences   NVARCHAR(MAX),
    functional_zones    NVARCHAR(MAX),
    plant_preferences   NVARCHAR(MAX),
    additional_notes    NVARCHAR(MAX),
    created_at          DATETIME2 DEFAULT GETDATE()
);