-- ==========================================
-- 10. МЕДИА И ДОКУМЕНТЫ
-- ==========================================

-- Медиа (фото, видео, файлы)
CREATE TABLE tm_media (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    entity_type     NVARCHAR(50),
    entity_id       BIGINT,
    file_name       NVARCHAR(255),
    file_path       NVARCHAR(500),
    file_size       BIGINT,
    mime_type       NVARCHAR(255),
    storage_type    NVARCHAR(50) DEFAULT N'local',
    storage_url     NVARCHAR(500),
    title           NVARCHAR(255),
    alt_text        NVARCHAR(255),
    ord             INT DEFAULT 0,
    created_by      BIGINT,
    created_at      DATETIME2 DEFAULT GETDATE(),
    deleted_at      DATETIME2
);

-- Фотоотчёты с объектов
CREATE TABLE tm_photo_reports (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    project_id      BIGINT,
    task_id         BIGINT,
    user_id         BIGINT,
    comment         NVARCHAR(MAX),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Папки для документов
CREATE TABLE tm_folders (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    parent_id       BIGINT,
    name            NVARCHAR(255),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Документы
CREATE TABLE tm_documents (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    folder_id       BIGINT,
    project_id      BIGINT,
    name            NVARCHAR(255),
    type            NVARCHAR(50),
    created_by      BIGINT,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Версии документов
CREATE TABLE tm_document_versions (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    document_id     BIGINT NOT NULL,
    version         INT NOT NULL,
    file_path       NVARCHAR(500),
    comment         NVARCHAR(MAX),
    created_by      BIGINT,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Дизайн-концепции
CREATE TABLE tm_design_concepts (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    project_id      BIGINT NOT NULL,
    name            NVARCHAR(255),
    status          NVARCHAR(50),
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Версии концепций
CREATE TABLE tm_design_concept_versions (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    concept_id      BIGINT NOT NULL,
    version         INT NOT NULL,
    files           NVARCHAR(MAX),
    comment         NVARCHAR(MAX),
    created_by      BIGINT,
    created_at      DATETIME2 DEFAULT GETDATE()
);