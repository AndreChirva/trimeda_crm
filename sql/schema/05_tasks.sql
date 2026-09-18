-- ==========================================
-- 05. ЗАДАЧИ
-- ==========================================

CREATE TABLE tm_tasks (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    project_id      BIGINT,
    milestone_id    BIGINT,
    parent_task_id  BIGINT,
    assigned_to     BIGINT,
    created_by      BIGINT,
    name            NVARCHAR(255),
    description     NVARCHAR(MAX),
    priority        NVARCHAR(50),
    status          NVARCHAR(50),
    due_date        DATE,
    created_at      DATETIME2 DEFAULT GETDATE(),
    updated_at      DATETIME2
);

CREATE TABLE tm_task_comments (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    task_id         BIGINT NOT NULL,
    user_id         BIGINT,
    comment         NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE tm_task_dependencies (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    task_id             BIGINT NOT NULL,
    depends_on_task_id  BIGINT NOT NULL,
    CONSTRAINT UQ_tm_task_dependencies UNIQUE (task_id, depends_on_task_id)
);
