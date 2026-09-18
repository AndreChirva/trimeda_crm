-- ==========================================
-- 14. АУДИТ И ИНТЕГРАЦИИ
-- ==========================================

-- Аудит действий
CREATE TABLE tm_audit_log (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    user_id         BIGINT,
    action          NVARCHAR(100),
    entity_type     NVARCHAR(200),
    entity_id       BIGINT,
    old_values      NVARCHAR(MAX),
    new_values      NVARCHAR(MAX),
    ip_address      NVARCHAR(90),
    user_agent      NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Попытки входа
CREATE TABLE tm_login_attempts (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    email           NVARCHAR(255),
    ip_address      NVARCHAR(90),
    success         BIT,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- API-токены
CREATE TABLE tm_api_tokens (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    user_id         BIGINT,
    name            NVARCHAR(100),
    token_hash      NVARCHAR(255),
    scopes          NVARCHAR(MAX),
    last_used_at    DATETIME2,
    expires_at      DATETIME2,
    created_at      DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT UQ_tm_api_tokens_hash UNIQUE (token_hash)
);

-- Логи интеграций
CREATE TABLE tm_integration_logs (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    integration     NVARCHAR(100),
    direction       NVARCHAR(20),
    status          NVARCHAR(40),
    payload         NVARCHAR(MAX),
    response        NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Вебхуки
CREATE TABLE tm_webhooks (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    event           NVARCHAR(100),
    url             NVARCHAR(500),
    is_active       BIT DEFAULT 1,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Приглашения
CREATE TABLE tm_invitations (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    email           NVARCHAR(255),
    token           NVARCHAR(100),
    status          NVARCHAR(40),
    created_at      DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT UQ_tm_invitations_token UNIQUE (token)
);