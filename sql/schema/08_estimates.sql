-- ==========================================
-- 08. СМЕТЫ
-- 4 блока: земляные работы, инженерия, озеленение, логистика
-- ==========================================

-- Сметы
CREATE TABLE tm_estimates (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    project_id      BIGINT NOT NULL,
    version_id      BIGINT,
    number          NVARCHAR(50),
    status          NVARCHAR(50) DEFAULT N'draft',
    total_amount    DECIMAL(15,2),
    created_by      BIGINT,
    created_at      DATETIME2 DEFAULT GETDATE(),
    updated_at      DATETIME2
);

-- Позиции сметы
CREATE TABLE tm_estimate_items (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    estimate_id     BIGINT NOT NULL,
    block           NVARCHAR(50),  -- earthworks / engineering / greening / logistics
    catalog_id      BIGINT,
    name            NVARCHAR(255),
    unit            NVARCHAR(20),
    quantity        DECIMAL(15,3),
    price           DECIMAL(15,2),
    total           DECIMAL(15,2),
    ord             INT DEFAULT 0
);

-- Версии смет
CREATE TABLE tm_estimate_versions (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    estimate_id     BIGINT NOT NULL,
    version         INT NOT NULL,
    comment         NVARCHAR(MAX),
    created_by      BIGINT,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Согласования смет
CREATE TABLE tm_estimate_approvals (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    estimate_id     BIGINT NOT NULL,
    user_id         BIGINT,
    status          NVARCHAR(50),  -- approved / rejected / pending
    comment         NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);