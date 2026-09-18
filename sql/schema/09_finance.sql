-- ==========================================
-- 09. ФИНАНСЫ
-- ==========================================

-- Категории расходов
CREATE TABLE tm_expense_categories (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Счета
CREATE TABLE tm_invoices (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    client_id       BIGINT,
    project_id      BIGINT,
    number          NVARCHAR(50) NOT NULL,
    amount          DECIMAL(15,2),
    status          NVARCHAR(40) DEFAULT N'draft',
    due_date        DATE,
    paid_at         DATETIME2,
    payment_id      NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT UQ_tm_invoices_tenant_number UNIQUE (tenant_id, number)
);

-- Позиции счёта
CREATE TABLE tm_invoice_items (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    invoice_id      BIGINT NOT NULL,
    name            NVARCHAR(255),
    quantity        DECIMAL(15,3),
    price           DECIMAL(15,2),
    total           DECIMAL(15,2)
);

-- Платежи
CREATE TABLE tm_payments (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    invoice_id      BIGINT,
    amount          DECIMAL(15,2),
    method          NVARCHAR(50),
    status          NVARCHAR(40),
    paid_at         DATETIME2,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Расходы
CREATE TABLE tm_expenses (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    category_id     BIGINT,
    project_id      BIGINT,
    amount          DECIMAL(15,2),
    comment         NVARCHAR(MAX),
    created_by      BIGINT,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Подписки (тарифы для тенантов)
CREATE TABLE tm_subscriptions (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    plan_id         BIGINT,
    status          NVARCHAR(40),
    started_at      DATETIME2,
    expires_at      DATETIME2,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Тарифные планы
CREATE TABLE tm_plans (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    code            NVARCHAR(50) NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    price           DECIMAL(15,2),
    CONSTRAINT UQ_tm_plans_code UNIQUE (code)
);

-- Счета на оплату подписки
CREATE TABLE tm_billing_invoices (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    subscription_id BIGINT,
    number          NVARCHAR(50),
    amount          DECIMAL(15,2),
    status          NVARCHAR(40),
    due_date        DATE,
    paid_at         DATETIME2,
    payment_id      NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);