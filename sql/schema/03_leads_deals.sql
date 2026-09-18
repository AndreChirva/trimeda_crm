-- ==========================================
-- 03. ЛИДЫ И СДЕЛКИ
-- ==========================================

-- Источники лидов
CREATE TABLE tm_lead_sources (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    code            NVARCHAR(50),
    is_active       BIT DEFAULT 1,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Лиды
CREATE TABLE tm_leads (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    client_id       BIGINT,
    assigned_to     BIGINT,
    source_id       BIGINT,
    first_name      NVARCHAR(100),
    last_name       NVARCHAR(100),
    phone           NVARCHAR(50),
    email           NVARCHAR(255),
    address         NVARCHAR(MAX),
    cadastral_number NVARCHAR(50),
    budget          DECIMAL(15,2),
    status          NVARCHAR(50) DEFAULT N'new',
    converted_at    DATETIME2,
    created_at      DATETIME2 DEFAULT GETDATE(),
    updated_at      DATETIME2
);

-- Активности по лидам
CREATE TABLE tm_lead_activities (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    lead_id         BIGINT NOT NULL,
    user_id         BIGINT,
    type            NVARCHAR(50),
    comment         NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Формы лидов (с сайта)
CREATE TABLE tm_lead_forms (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100),
    fields          NVARCHAR(MAX),
    is_active       BIT DEFAULT 1,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Воронки продаж
CREATE TABLE tm_pipelines (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    is_default      BIT DEFAULT 0,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Этапы воронки
CREATE TABLE tm_pipeline_stages (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    pipeline_id     BIGINT NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    code            NVARCHAR(50),
    order_index     INT DEFAULT 0,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Сделки
CREATE TABLE tm_deals (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    client_id       BIGINT NOT NULL,
    project_id      BIGINT,
    pipeline_id     BIGINT NOT NULL,
    stage_id        BIGINT NOT NULL,
    title           NVARCHAR(255),
    amount          DECIMAL(15,2),
    currency        NVARCHAR(6) DEFAULT N'RUB',
    close_date      DATE,
    lost_reason     NVARCHAR(200),
    status          NVARCHAR(40) DEFAULT N'open',
    created_at      DATETIME2 DEFAULT GETDATE(),
    updated_at      DATETIME2
);

-- История сделок
CREATE TABLE tm_deal_history (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    deal_id         BIGINT NOT NULL,
    from_stage_id   BIGINT,
    to_stage_id     BIGINT,
    changed_by      BIGINT,
    comment         NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);