-- ==========================================
-- 12. КОМАНДА И ОБОРУДОВАНИЕ
-- ==========================================

-- Бригады / команды
CREATE TABLE tm_teams (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    leader_id       BIGINT,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Участники бригады
CREATE TABLE tm_team_members (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    team_id         BIGINT NOT NULL,
    user_id         BIGINT NOT NULL,
    role            NVARCHAR(50),
    CONSTRAINT UQ_tm_team_members UNIQUE (team_id, user_id)
);

-- Оборудование / техника
CREATE TABLE tm_equipment (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    type            NVARCHAR(50),
    inventory_number NVARCHAR(50),
    status          NVARCHAR(50),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Назначения оборудования
CREATE TABLE tm_equipment_assignments (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    equipment_id    BIGINT NOT NULL,
    project_id      BIGINT,
    user_id         BIGINT,
    assigned_at     DATETIME2 DEFAULT GETDATE(),
    returned_at     DATETIME2
);

-- Табель рабочих (учёт смен)
CREATE TABLE tm_work_logs (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    user_id         BIGINT,
    project_id      BIGINT,
    date            DATE,
    hours           DECIMAL(5,2),
    comment         NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);
