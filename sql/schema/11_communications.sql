-- ==========================================
-- 11. КОММУНИКАЦИИ
-- ==========================================

-- Чаты
CREATE TABLE tm_chat_rooms (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    type            NVARCHAR(40),
    project_id      BIGINT,
    client_id       BIGINT,
    task_id         BIGINT,
    name            NVARCHAR(255),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Сообщения
CREATE TABLE tm_chat_messages (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    chat_room_id    BIGINT NOT NULL,
    user_id         BIGINT,
    client_id       BIGINT,
    message         NVARCHAR(MAX),
    attachments     NVARCHAR(MAX),
    is_read         BIT DEFAULT 0,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Участники чата
CREATE TABLE tm_chat_participants (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    chat_room_id    BIGINT NOT NULL,
    user_id         BIGINT,
    client_id       BIGINT,
    role            NVARCHAR(40) DEFAULT N'member',
    joined_at       DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT UQ_tm_chat_participants UNIQUE (chat_room_id, user_id, client_id)
);

-- Email-сообщения
CREATE TABLE tm_email_messages (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    to_email        NVARCHAR(255),
    subject         NVARCHAR(255),
    body            NVARCHAR(MAX),
    status          NVARCHAR(40),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Шаблоны email
CREATE TABLE tm_email_templates (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    name            NVARCHAR(100),
    subject         NVARCHAR(255),
    body            NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- SMS
CREATE TABLE tm_sms_messages (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    phone           NVARCHAR(50),
    message         NVARCHAR(MAX),
    status          NVARCHAR(40),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Звонки
CREATE TABLE tm_call_logs (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    user_id         BIGINT,
    client_id       BIGINT,
    phone           NVARCHAR(50),
    direction       NVARCHAR(20),
    duration        INT,
    outcome         NVARCHAR(100),
    notes           NVARCHAR(MAX),
    recording_path  NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Уведомления
CREATE TABLE tm_notifications (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    user_id         BIGINT,
    type            NVARCHAR(50),
    title           NVARCHAR(255),
    body            NVARCHAR(MAX),
    is_read         BIT DEFAULT 0,
    created_at      DATETIME2 DEFAULT GETDATE()
);