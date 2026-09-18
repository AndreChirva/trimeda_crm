-- ==========================================
-- 13. СОБЫТИЯ
-- ==========================================

-- События (встречи, выезды, замеры)
CREATE TABLE tm_events (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    project_id      BIGINT,
    client_id       BIGINT,
    title           NVARCHAR(255),
    description     NVARCHAR(MAX),
    start_at        DATETIME2,
    end_at          DATETIME2,
    location        NVARCHAR(MAX),
    created_by      BIGINT,
    created_at      DATETIME2 DEFAULT GETDATE()
);

-- Участники событий
CREATE TABLE tm_event_attendees (
    id              BIGINT IDENTITY(1,1) PRIMARY KEY,
    event_id        BIGINT NOT NULL,
    user_id         BIGINT,
    status          NVARCHAR(50)
);