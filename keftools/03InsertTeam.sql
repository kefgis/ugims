INSERT INTO auth_user (id, username, password, email, is_active) VALUES
(gen_random_uuid(), 'gardener1', 'pbkdf2_sha256$dummy', 'gardener1@example.com', true),
(gen_random_uuid(), 'gardener2', 'pbkdf2_sha256$dummy', 'gardener2@example.com', true),
(gen_random_uuid(), 'supervisor', 'pbkdf2_sha256$dummy', 'supervisor@example.com', true);

-- Then insert into ugims_workforce_user (use the actual UUIDs from above)
-- For simplicity, you can also insert directly with known UUIDs after retrieving them.
-- We'll skip detailed UUIDs here; you can insert via phpMyAdmin or pgAdmin later.

-- Insert teams
INSERT INTO ugims_team (team_id, team_name, team_code, team_type, is_active) VALUES
(gen_random_uuid(), 'North Zone Team', 'NZT01', 'Maintenance', true),
(gen_random_uuid(), 'South Zone Team', 'SZT01', 'Maintenance', true);


-- =====================================================
-- DEMO DATA FOR UGIMS (EPSG:20137)
-- =====================================================

-- 1. Fiscal Years (if not already present)
INSERT INTO lkp_fiscal_year (fiscal_year_id, fiscal_year_name, start_date, end_date, is_current)
VALUES
(1, '2023-2024', '2023-07-01', '2024-06-30', false),
(2, '2024-2025', '2024-07-01', '2025-06-30', true),
(3, '2025-2026', '2025-07-01', '2026-06-30', false)
ON CONFLICT (fiscal_year_id) DO NOTHING;

-- 2. Parcels (sample polygons in UTM 37S)
-- Approximate coordinates for Addis Ababa (EPSG:20137)
INSERT INTO ugims_parcel (parcel_id, parcel_number, geometry, land_use_type_id, ownership_type_id)
VALUES
(gen_random_uuid(), 'PARC-001', ST_GeomFromText('POLYGON((471500 1000500, 471700 1000500, 471700 1000300, 471500 1000300, 471500 1000500))', 20137), 7, 3),
(gen_random_uuid(), 'PARC-002', ST_GeomFromText('POLYGON((472200 1001200, 472400 1001200, 472400 1001000, 472200 1001000, 472200 1001200))', 20137), 7, 3),
(gen_random_uuid(), 'PARC-003', ST_GeomFromText('POLYGON((470800  998500, 471000  998500, 471000  998300, 470800  998300, 470800  998500))', 20137), 1, 5);

-- 3. UGI Assets (linked to parcels)
DO $$
DECLARE
    parcel1 UUID;
    parcel2 UUID;
    parcel3 UUID;
BEGIN
    SELECT parcel_id INTO parcel1 FROM ugims_parcel WHERE parcel_number = 'PARC-001' LIMIT 1;
    SELECT parcel_id INTO parcel2 FROM ugims_parcel WHERE parcel_number = 'PARC-002' LIMIT 1;
    SELECT parcel_id INTO parcel3 FROM ugims_parcel WHERE parcel_number = 'PARC-003' LIMIT 1;

    INSERT INTO ugims_ugi (ugi_id, ugi_type_id, parcel_id, name, geometry, condition_status_id, operational_status_id, has_lighting, has_irrigation, visitor_capacity, contact_person, contact_phone, contact_email, tree_count)
    VALUES
    (gen_random_uuid(), 1, parcel1, 'Friendship Park', ST_GeomFromText('POLYGON((471550 1000450, 471650 1000450, 471650 1000350, 471550 1000350, 471550 1000450))', 20137), 2, 1, true, true, 500, 'Park Manager', '+251911111111', 'park@example.com', 120),
    (gen_random_uuid(), 2, parcel2, 'Addis Stadium', ST_GeomFromText('POLYGON((472250 1001150, 472350 1001150, 472350 1001050, 472250 1001050, 472250 1001150))', 20137), 3, 1, true, true, 2000, 'Stadium Authority', '+251922222222', 'stadium@example.com', 45),
    (gen_random_uuid(), 13, parcel3, 'Children''s Playground', ST_GeomFromText('POLYGON((470850 998450, 470950 998450, 470950 998350, 470850 998350, 470850 998450))', 20137), 1, 1, true, false, 150, 'Community Center', '+251933333333', 'playground@example.com', 8);
END $$;

-- 4. Staff Users (roles: admin, inspector, field)
-- Passwords are 'demo123' – you MUST replace the hash with actual output from PHP.
-- Generate with: php -r "echo password_hash('demo123', PASSWORD_DEFAULT);"
INSERT INTO ugims_users (username, password_hash, full_name, email, role)
VALUES
('admin', '$2y$10$YourHashedPasswordHere', 'Admin User', 'admin@ugims.et', 'admin'),
('inspector1', '$2y$10$YourHashedPasswordHere', 'Abebe Kebede', 'inspector@ugims.et', 'inspector'),
('field1', '$2y$10$YourHashedPasswordHere', 'Tigist Haile', 'field@ugims.et', 'field');

-- 5. Citizen Reports (points in UTM)
INSERT INTO ugims_citizen_report (report_id, report_number, reporter_name, reporter_email, report_type_id, report_description, location_point, status_id)
VALUES
(gen_random_uuid(), 'RPT-20240315-001', 'Solomon Ayele', 'solomon@email.com', 1, 'Bench broken near the main entrance', ST_SetSRID(ST_MakePoint(471600, 1000420), 20137), 1),
(gen_random_uuid(), 'RPT-20240316-002', 'Meron Tadesse', 'meron@email.com', 3, 'Grass overgrown, needs mowing', ST_SetSRID(ST_MakePoint(472300, 1001120), 20137), 2);

-- 6. Maintenance Plans
INSERT INTO ugims_management_plan (plan_id, plan_name, plan_type_id, fiscal_year_id, planned_start_date, planned_end_date, total_budget_allocated, plan_status_id, goals_and_objectives)
VALUES
(gen_random_uuid(), 'Annual Park Maintenance 2024', 1, 2, '2024-07-01', '2025-06-30', 150000.00, 1, 'Routine upkeep of all parks'),
(gen_random_uuid(), 'Sport Field Renovation', 3, 2, '2024-09-01', '2024-12-31', 300000.00, 1, 'Resurface running track');

-- 7. Plan Activities
DO $$
DECLARE
    plan1 UUID;
    plan2 UUID;
    park_ugi UUID;
    stadium_ugi UUID;
BEGIN
    SELECT plan_id INTO plan1 FROM ugims_management_plan WHERE plan_name = 'Annual Park Maintenance 2024' LIMIT 1;
    SELECT plan_id INTO plan2 FROM ugims_management_plan WHERE plan_name = 'Sport Field Renovation' LIMIT 1;
    SELECT ugi_id INTO park_ugi FROM ugims_ugi WHERE name = 'Friendship Park' LIMIT 1;
    SELECT ugi_id INTO stadium_ugi FROM ugims_ugi WHERE name = 'Addis Stadium' LIMIT 1;

    INSERT INTO ugims_plan_activity (plan_activity_id, plan_id, activity_type_id, ugi_id, scheduled_start_date, scheduled_end_date, estimated_man_days, estimated_labor_cost, estimated_material_cost, activity_status_id)
    VALUES
    (gen_random_uuid(), plan1, 101, park_ugi, '2024-07-15', '2024-07-20', 5, 2500.00, 500.00, 1),
    (gen_random_uuid(), plan1, 104, park_ugi, '2024-08-01', '2024-08-05', 3, 1500.00, 300.00, 1),
    (gen_random_uuid(), plan2, 304, stadium_ugi, '2024-09-10', '2024-09-30', 20, 15000.00, 5000.00, 1);
END $$;

-- 8. Inspections
INSERT INTO ugims_inspection (inspection_id, inspection_number, inspection_type_id, ugi_id, scheduled_date, inspection_status_id, inspector_notes)
VALUES
(gen_random_uuid(), 'INS-20240320-001', 1, (SELECT ugi_id FROM ugims_ugi WHERE name = 'Friendship Park' LIMIT 1), '2024-03-20 10:00:00', 1, 'Check all benches and lights'),
(gen_random_uuid(), 'INS-20240321-002', 4, (SELECT ugi_id FROM ugims_ugi WHERE name = 'Children''s Playground' LIMIT 1), '2024-03-21 14:00:00', 1, 'Playground safety inspection');

-- 9. Inspection Findings
DO $$
DECLARE
    insp1 UUID;
BEGIN
    SELECT inspection_id INTO insp1 FROM ugims_inspection WHERE inspection_number = 'INS-20240320-001' LIMIT 1;
    INSERT INTO ugims_inspection_finding (finding_id, inspection_id, finding_description, finding_priority_id, severity, resolved)
    VALUES
    (gen_random_uuid(), insp1, 'Two benches have loose screws', 3, 2, false),
    (gen_random_uuid(), insp1, 'One light pole not working', 2, 3, false);
END $$;

-- 10. Budgets
INSERT INTO ugims_budget (budget_id, budget_name, fiscal_year_id, allocated_amount, budget_status)
VALUES
(gen_random_uuid(), 'Parks Maintenance', 2, 100000.00, 'Approved'),
(gen_random_uuid(), 'Sports Facilities', 2, 50000.00, 'Approved');

-- 11. Expenses
DO $$
DECLARE
    budget1 UUID;
    budget2 UUID;
BEGIN
    SELECT budget_id INTO budget1 FROM ugims_budget WHERE budget_name = 'Parks Maintenance' LIMIT 1;
    SELECT budget_id INTO budget2 FROM ugims_budget WHERE budget_name = 'Sports Facilities' LIMIT 1;

    INSERT INTO ugims_expense (expense_id, budget_id, expense_date, description, amount, vendor_name)
    VALUES
    (gen_random_uuid(), budget1, '2024-07-20', 'Grass cutting materials', 1200.00, 'Green Supplies Co.'),
    (gen_random_uuid(), budget1, '2024-08-05', 'Pruning tools', 450.00, 'Garden World'),
    (gen_random_uuid(), budget2, '2024-09-15', 'Track paint', 3500.00, 'Sport Equipment Ltd');
END $$;


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