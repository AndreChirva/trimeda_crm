-- ==========================================
-- 04. ПРОЕКТЫ
-- ==========================================

-- Типы проектов
CREATE TABLE tm_project_types (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    code            NVARCHAR(50) NOT NULL,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Проекты
CREATE TABLE tm_projects (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    client_id       BIGINT NOT NULL,
    name            NVARCHAR(255),
    address         NVARCHAR(MAX),
    area            DECIMAL(10,2),
    project_type    NVARCHAR(50),
    project_type_id INT,
    status_id       INT,
    manager_id      BIGINT,
    budget          DECIMAL(15,2),
    start_date      DATE,
    end_date        DATE,
    created_at      DATETIME2 DEFAULT GETDATE(),
    updated_at      DATETIME2,
    deleted_at      DATETIME2
);

-- Участники проекта
CREATE TABLE tm_project_members (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    project_id      BIGINT NOT NULL,
    user_id         BIGINT NOT NULL,
    role            NVARCHAR(50),
    created_at      DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT UQ_tm_project_members_project_user UNIQUE (project_id, user_id)
);

-- Вехи проекта
CREATE TABLE tm_milestones (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    project_id      BIGINT NOT NULL,
    name            NVARCHAR(255),
    due_date        DATE,
    status          NVARCHAR(50),
    order_index     INT DEFAULT 0,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- История статусов проекта
CREATE TABLE tm_project_status_history (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    project_id      BIGINT NOT NULL,
    from_stage_id   BIGINT,
    to_stage_id     BIGINT,
    changed_by      BIGINT,
    comment         NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);