-- ==========================================
-- ИНДЕКСЫ
-- Под фильтры, сортировки и JOIN'ы
-- ==========================================

-- ===== tm_api_tokens =====
CREATE NONCLUSTERED INDEX IX_tm_api_tokens_expires_at ON tm_api_tokens (expires_at ASC);
CREATE NONCLUSTERED INDEX IX_tm_api_tokens_hash ON tm_api_tokens (token_hash ASC);
CREATE NONCLUSTERED INDEX IX_tm_api_tokens_tenant_id ON tm_api_tokens (tenant_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_api_tokens_user_id ON tm_api_tokens (user_id ASC);

-- ===== tm_audit_log =====
CREATE NONCLUSTERED INDEX IX_tm_audit_log_created_at ON tm_audit_log (created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_audit_log_entity ON tm_audit_log (entity_type ASC, entity_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_audit_log_tenant_id ON tm_audit_log (tenant_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_audit_log_user_id ON tm_audit_log (user_id ASC);

-- ===== tm_catalog =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_catalog_tenant_sku ON tm_catalog (tenant_id ASC, sku ASC);

-- ===== tm_catalog_attribute_values =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_catalog_attr ON tm_catalog_attribute_values (catalog_id ASC, attribute_id ASC);

-- ===== tm_catalog_types =====
CREATE NONCLUSTERED INDEX IX_tm_catalog_types_tenant ON tm_catalog_types (tenant_id ASC);

-- ===== tm_catalog_units =====
CREATE NONCLUSTERED INDEX IX_tm_catalog_units_tenant ON tm_catalog_units (tenant_id ASC);

-- ===== tm_catalog_variants =====
CREATE NONCLUSTERED INDEX IX_variants_tenant_catalog ON tm_catalog_variants (tenant_id ASC, catalog_id ASC);

-- ===== tm_chat_participants =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_chat_participants ON tm_chat_participants (chat_room_id ASC, user_id ASC, client_id ASC);

-- ===== tm_client_briefs =====
CREATE NONCLUSTERED INDEX IX_tm_client_briefs_client_id ON tm_client_briefs (client_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_client_briefs_project_id ON tm_client_briefs (project_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_client_briefs_tenant_id ON tm_client_briefs (tenant_id ASC);

-- ===== tm_client_contacts =====
CREATE NONCLUSTERED INDEX IX_tm_client_contacts_client_id ON tm_client_contacts (client_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_client_contacts_email ON tm_client_contacts (email ASC);
CREATE NONCLUSTERED INDEX IX_tm_client_contacts_phone ON tm_client_contacts (phone ASC);

-- ===== tm_clients =====
CREATE NONCLUSTERED INDEX IX_tm_clients_category ON tm_clients (category ASC);
CREATE NONCLUSTERED INDEX IX_tm_clients_created_at ON tm_clients (created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_clients_email ON tm_clients (email ASC);
CREATE NONCLUSTERED INDEX IX_tm_clients_manager_id ON tm_clients (manager_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_clients_phone ON tm_clients (phone ASC);
CREATE NONCLUSTERED INDEX IX_tm_clients_status ON tm_clients (status ASC);
CREATE NONCLUSTERED INDEX IX_tm_clients_tenant_id ON tm_clients (tenant_id ASC);

-- ===== tm_deal_history =====
CREATE NONCLUSTERED INDEX IX_tm_deal_history_changed_by ON tm_deal_history (changed_by ASC);
CREATE NONCLUSTERED INDEX IX_tm_deal_history_created_at ON tm_deal_history (created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_deal_history_deal_id ON tm_deal_history (deal_id ASC);

-- ===== tm_deals =====
CREATE NONCLUSTERED INDEX IX_tm_deals_client_id ON tm_deals (client_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_deals_close_date ON tm_deals (close_date ASC);
CREATE NONCLUSTERED INDEX IX_tm_deals_created_at ON tm_deals (created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_deals_pipeline_id ON tm_deals (pipeline_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_deals_project_id ON tm_deals (project_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_deals_stage_id ON tm_deals (stage_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_deals_status ON tm_deals (status ASC);
CREATE NONCLUSTERED INDEX IX_tm_deals_tenant_id ON tm_deals (tenant_id ASC);

-- ===== tm_invitations =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_invitations_token ON tm_invitations (token ASC);

-- ===== tm_invoices =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_invoices_tenant_number ON tm_invoices (tenant_id ASC, number ASC);

-- ===== tm_lead_activities =====
CREATE NONCLUSTERED INDEX IX_tm_lead_activities_created_at ON tm_lead_activities (created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_lead_activities_lead_id ON tm_lead_activities (lead_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_lead_activities_type ON tm_lead_activities (type ASC);
CREATE NONCLUSTERED INDEX IX_tm_lead_activities_user_id ON tm_lead_activities (user_id ASC);

-- ===== tm_lead_sources =====
CREATE NONCLUSTERED INDEX IX_tm_lead_sources_code ON tm_lead_sources (code ASC);
CREATE NONCLUSTERED INDEX IX_tm_lead_sources_tenant_id ON tm_lead_sources (tenant_id ASC);

-- ===== tm_leads =====
CREATE NONCLUSTERED INDEX IX_tm_leads_assigned_to ON tm_leads (assigned_to ASC);
CREATE NONCLUSTERED INDEX IX_tm_leads_client_id ON tm_leads (client_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_leads_converted_at ON tm_leads (converted_at ASC);
CREATE NONCLUSTERED INDEX IX_tm_leads_created_at ON tm_leads (created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_leads_email ON tm_leads (email ASC);
CREATE NONCLUSTERED INDEX IX_tm_leads_phone ON tm_leads (phone ASC);
CREATE NONCLUSTERED INDEX IX_tm_leads_source_id ON tm_leads (source_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_leads_status ON tm_leads (status ASC);
CREATE NONCLUSTERED INDEX IX_tm_leads_tenant_id ON tm_leads (tenant_id ASC);

-- ===== tm_login_attempts =====
CREATE NONCLUSTERED INDEX IX_tm_login_attempts_created_at ON tm_login_attempts (created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_login_attempts_email ON tm_login_attempts (email ASC);
CREATE NONCLUSTERED INDEX IX_tm_login_attempts_ip ON tm_login_attempts (ip_address ASC);

-- ===== tm_media =====
CREATE NONCLUSTERED INDEX IX_tm_media_created_by ON tm_media (tenant_id ASC, created_by ASC);
CREATE NONCLUSTERED INDEX IX_tm_media_s3 ON tm_media (tenant_id ASC, id ASC);
CREATE NONCLUSTERED INDEX IX_tm_media_tenant_created ON tm_media (tenant_id ASC, created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_media_tenant_entity ON tm_media (tenant_id ASC, entity_type ASC, entity_id ASC);

-- ===== tm_milestones =====
CREATE NONCLUSTERED INDEX IX_tm_milestones_due_date ON tm_milestones (due_date ASC);
CREATE NONCLUSTERED INDEX IX_tm_milestones_order ON tm_milestones (project_id ASC, order_index ASC);
CREATE NONCLUSTERED INDEX IX_tm_milestones_project_id ON tm_milestones (project_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_milestones_status ON tm_milestones (status ASC);
CREATE NONCLUSTERED INDEX IX_tm_milestones_tenant_id ON tm_milestones (tenant_id ASC);

-- ===== tm_pipeline_stages =====
CREATE NONCLUSTERED INDEX IX_tm_pipeline_stages_order ON tm_pipeline_stages (pipeline_id ASC, order_index ASC);
CREATE NONCLUSTERED INDEX IX_tm_pipeline_stages_pipeline_id ON tm_pipeline_stages (pipeline_id ASC);

-- ===== tm_pipelines =====
CREATE NONCLUSTERED INDEX IX_tm_pipelines_is_default ON tm_pipelines (is_default ASC);
CREATE NONCLUSTERED INDEX IX_tm_pipelines_tenant_id ON tm_pipelines (tenant_id ASC);

-- ===== tm_plans =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_plans_code ON tm_plans (code ASC);

-- ===== tm_price_list_items =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_price_list_catalog ON tm_price_list_items (price_list_id ASC, catalog_id ASC);

-- ===== tm_project_members =====
CREATE NONCLUSTERED INDEX IX_tm_project_members_project_id ON tm_project_members (project_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_project_members_role ON tm_project_members (role ASC);
CREATE NONCLUSTERED INDEX IX_tm_project_members_user_id ON tm_project_members (user_id ASC);
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_project_members_project_user ON tm_project_members (project_id ASC, user_id ASC);

-- ===== tm_project_status_history =====
CREATE NONCLUSTERED INDEX IX_tm_project_status_history_changed_by ON tm_project_status_history (changed_by ASC);
CREATE NONCLUSTERED INDEX IX_tm_project_status_history_created_at ON tm_project_status_history (created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_project_status_history_project_id ON tm_project_status_history (project_id ASC);

-- ===== tm_projects =====
CREATE NONCLUSTERED INDEX IX_tm_projects_client_id ON tm_projects (client_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_projects_created_at ON tm_projects (created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_projects_manager_id ON tm_projects (manager_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_projects_status ON tm_projects (status ASC);
CREATE NONCLUSTERED INDEX IX_tm_projects_tenant_id ON tm_projects (tenant_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_projects_type ON tm_projects (project_type ASC);

-- ===== tm_stock_items =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_stock_items_warehouse_catalog ON tm_stock_items (warehouse_id ASC, catalog_id ASC);

-- ===== tm_task_comments =====
CREATE NONCLUSTERED INDEX IX_tm_task_comments_created_at ON tm_task_comments (created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_task_comments_task_id ON tm_task_comments (task_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_task_comments_user_id ON tm_task_comments (user_id ASC);

-- ===== tm_task_dependencies =====
CREATE NONCLUSTERED INDEX IX_tm_task_dependencies_depends ON tm_task_dependencies (depends_on_task_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_task_dependencies_task_id ON tm_task_dependencies (task_id ASC);
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_task_dependencies ON tm_task_dependencies (task_id ASC, depends_on_task_id ASC);

-- ===== tm_tasks =====
CREATE NONCLUSTERED INDEX IX_tm_tasks_assigned_to ON tm_tasks (assigned_to ASC);
CREATE NONCLUSTERED INDEX IX_tm_tasks_created_at ON tm_tasks (created_at DESC);
CREATE NONCLUSTERED INDEX IX_tm_tasks_created_by ON tm_tasks (created_by ASC);
CREATE NONCLUSTERED INDEX IX_tm_tasks_due_date ON tm_tasks (due_date ASC);
CREATE NONCLUSTERED INDEX IX_tm_tasks_milestone_id ON tm_tasks (milestone_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_tasks_parent_task_id ON tm_tasks (parent_task_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_tasks_priority ON tm_tasks (priority ASC);
CREATE NONCLUSTERED INDEX IX_tm_tasks_project_id ON tm_tasks (project_id ASC);
CREATE NONCLUSTERED INDEX IX_tm_tasks_status ON tm_tasks (status ASC);
CREATE NONCLUSTERED INDEX IX_tm_tasks_tenant_id ON tm_tasks (tenant_id ASC);

-- ===== tm_team_members =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_team_members ON tm_team_members (team_id ASC, user_id ASC);

-- ===== tm_tenant_settings =====
CREATE NONCLUSTERED INDEX IX_tm_tenant_settings_tenant_id ON tm_tenant_settings (tenant_id ASC);
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_tenant_settings_tenant_key ON tm_tenant_settings (tenant_id ASC, [key] ASC);

-- ===== tm_tenants =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_tenants_subdomain ON tm_tenants (subdomain ASC);

-- ===== tm_user_notification_settings =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_user_notif_settings ON tm_user_notification_settings (user_id ASC, notification_type ASC);

-- ===== tm_user_roles =====
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_user_roles ON tm_user_roles (user_id ASC, role_id ASC);

-- ===== tm_users =====
CREATE NONCLUSTERED INDEX IX_tm_users_email ON tm_users (email ASC);
CREATE NONCLUSTERED INDEX IX_tm_users_tenant_id ON tm_users (tenant_id ASC);
CREATE UNIQUE NONCLUSTERED INDEX UQ_tm_users ON tm_users (tenant_id ASC, email ASC);

-- ===== tm_webhooks =====
CREATE NONCLUSTERED INDEX IX_tm_webhooks_is_active ON tm_webhooks (is_active ASC);
CREATE NONCLUSTERED INDEX IX_tm_webhooks_tenant_id ON tm_webhooks (tenant_id ASC);

-- ===== tm_work_logs =====
CREATE NONCLUSTERED INDEX IX_tm_work_logs_date ON tm_work_logs (date DESC);