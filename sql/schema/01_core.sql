-- ==========================================
-- ЯДРО СИСТЕМЫ: пользователи, роли, статусы
-- ==========================================

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
    updated_at      DATETIME2
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

-- Статусы (для клиентов, проектов, сотрудников)
CREATE TABLE tm_statuses (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    entity_type     NVARCHAR(50) NOT NULL,  -- client / project / employee
    name            NVARCHAR(100) NOT NULL,
    code            NVARCHAR(50) NOT NULL,
    ord             INT DEFAULT 0,
    is_active       BIT DEFAULT 1,
    created_at      DATETIME2 DEFAULT GETDATE()
);