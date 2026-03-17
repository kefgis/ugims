-- Table for storing field mapping templates
CREATE TABLE IF NOT EXISTS ugims_import_mapping (
    mapping_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mapping_name VARCHAR(100) NOT NULL,
    import_type VARCHAR(20) NOT NULL, -- 'parcel' or 'ugi'
    field_mapping JSONB NOT NULL,
    created_by INTEGER REFERENCES ugims_users(user_id),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_default BOOLEAN DEFAULT false
);

-- Add index for faster lookups
CREATE INDEX idx_import_mapping_type ON ugims_import_mapping(import_type);
CREATE INDEX idx_import_mapping_created_by ON ugims_import_mapping(created_by);


-- Table for temporary import sessions
CREATE TABLE IF NOT EXISTS ugims_import_session (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER REFERENCES ugims_users(user_id),
    import_type VARCHAR(20) NOT NULL,
    temp_dir VARCHAR(255),
    shapefile_name VARCHAR(255),
    total_records INTEGER DEFAULT 0,
    field_mapping JSONB,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '2 hours')
);

-- Add index for cleanup
CREATE INDEX idx_import_session_expires ON ugims_import_session(expires_at);
CREATE INDEX idx_import_session_user ON ugims_import_session(user_id);



-- Make sure the import log table exists
CREATE TABLE IF NOT EXISTS ugims_import_log (
    import_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    import_type VARCHAR(20) NOT NULL,
    filename VARCHAR(255) NOT NULL,
    records_processed INTEGER DEFAULT 0,
    records_success INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,
    import_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    imported_by_user_id INTEGER REFERENCES ugims_users(user_id),
    status VARCHAR(20) DEFAULT 'pending',
    error_log TEXT
);

-- Add indexes
CREATE INDEX idx_import_log_date ON ugims_import_log(import_date);
CREATE INDEX idx_import_log_status ON ugims_import_log(status);
CREATE INDEX idx_import_log_user ON ugims_import_log(imported_by_user_id);


-- =====================================================
-- CREATE ALL IMPORT SYSTEM TABLES
-- =====================================================

-- 1. Import Mapping Table
CREATE TABLE IF NOT EXISTS ugims_import_mapping (
    mapping_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mapping_name VARCHAR(100) NOT NULL,
    import_type VARCHAR(20) NOT NULL,
    field_mapping JSONB NOT NULL,
    created_by INTEGER REFERENCES ugims_users(user_id),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_default BOOLEAN DEFAULT false
);

-- 2. Import Session Table
CREATE TABLE IF NOT EXISTS ugims_import_session (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER REFERENCES ugims_users(user_id),
    import_type VARCHAR(20) NOT NULL,
    temp_dir VARCHAR(255),
    shapefile_name VARCHAR(255),
    total_records INTEGER DEFAULT 0,
    field_mapping JSONB,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '2 hours')
);

-- 3. Import Log Table (if not exists)
CREATE TABLE IF NOT EXISTS ugims_import_log (
    import_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    import_type VARCHAR(20) NOT NULL,
    filename VARCHAR(255) NOT NULL,
    records_processed INTEGER DEFAULT 0,
    records_success INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,
    import_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    imported_by_user_id INTEGER REFERENCES ugims_users(user_id),
    status VARCHAR(20) DEFAULT 'pending',
    error_log TEXT
);

-- Add all indexes
CREATE INDEX IF NOT EXISTS idx_import_mapping_type ON ugims_import_mapping(import_type);
CREATE INDEX IF NOT EXISTS idx_import_mapping_created_by ON ugims_import_mapping(created_by);

CREATE INDEX IF NOT EXISTS idx_import_session_expires ON ugims_import_session(expires_at);
CREATE INDEX IF NOT EXISTS idx_import_session_user ON ugims_import_session(user_id);

CREATE INDEX IF NOT EXISTS idx_import_log_date ON ugims_import_log(import_date);
CREATE INDEX IF NOT EXISTS idx_import_log_status ON ugims_import_log(status);
CREATE INDEX IF NOT EXISTS idx_import_log_user ON ugims_import_log(imported_by_user_id);