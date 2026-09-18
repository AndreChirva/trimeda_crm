-- ==========================================
-- 01. ЯДРО СИСТЕМЫ
-- Пользователи, роли, статусы, тенанты
-- ==========================================

-- Тенанты (компании)
CREATE TABLE tm_tenants (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    name            NVARCHAR(255) NOT NULL,
    subdomain       NVARCHAR(100) NOT NULL,
    created_at      DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT UQ_tm_tenants_subdomain UNIQUE (subdomain)
);

-- Настройки тенанта
CREATE TABLE tm_tenant_settings (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    [key]           NVARCHAR(100) NOT NULL,
    value           NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT UQ_tm_tenant_settings_tenant_key UNIQUE (tenant_id, [key])
);

-- Сайты тенанта
CREATE TABLE tm_tenant_sites (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    domain          NVARCHAR(255),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Должности
CREATE TABLE tm_positions (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    role_code       NVARCHAR(50),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Пользователи (сотрудники)
CREATE TABLE tm_users (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    email           NVARCHAR(255) NOT NULL,
    first_name      NVARCHAR(100),
    last_name       NVARCHAR(100),
    middle_name     NVARCHAR(100),
    phone           NVARCHAR(50),
    position        NVARCHAR(100),
    position_id     INT,
    status_id       INT,
    status          NVARCHAR(50) DEFAULT 'active',
    deleted_at      DATETIME2,
    created_at      DATETIME2 DEFAULT GETDATE(),
    updated_at      DATETIME2,
    CONSTRAINT UQ_tm_users UNIQUE (tenant_id, email)
);

-- Роли
CREATE TABLE tm_roles (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    code            NVARCHAR(50) NOT NULL,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Связь пользователей и ролей
CREATE TABLE tm_user_roles (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    role_id         BIGINT NOT NULL,
    CONSTRAINT UQ_tm_user_roles UNIQUE (user_id, role_id)
);

-- Статусы
CREATE TABLE tm_statuses (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    entity_type     NVARCHAR(50) NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    code            NVARCHAR(50) NOT NULL,
    ord             INT DEFAULT 0,
    is_active       BIT DEFAULT 1,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Настройки уведомлений
CREATE TABLE tm_user_notification_settings (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id             BIGINT NOT NULL,
    notification_type   NVARCHAR(50) NOT NULL,
    is_enabled          BIT DEFAULT 1,
    CONSTRAINT UQ_tm_user_notif_settings UNIQUE (user_id, notification_type)
);