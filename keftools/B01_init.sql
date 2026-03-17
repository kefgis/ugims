-- =====================================================
-- URBAN GREEN INFRASTRUCTURE MANAGEMENT SYSTEM (UGIMS)
-- Complete Database Schema - MODIFIED VERSION
-- Only UUID → SERIAL conversion, no other changes
-- PostgreSQL with PostGIS
-- =====================================================

-- Enable PostGIS (must be installed)
CREATE EXTENSION IF NOT EXISTS postgis;

-- =====================================================
-- 0. AUTH_USER PLACEHOLDER (UUID → SERIAL)
-- =====================================================
CREATE TABLE auth_user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(128) NOT NULL,
    email VARCHAR(254),
    first_name VARCHAR(150),
    last_name VARCHAR(150),
    is_active BOOLEAN DEFAULT TRUE,
    is_staff BOOLEAN DEFAULT FALSE,
    is_superuser BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP,
    date_joined TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 1. UGIMS USERS TABLE (needed early for references)
-- =====================================================
CREATE TABLE ugims_users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    email VARCHAR(100),
    role VARCHAR(50) DEFAULT 'staff',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- =====================================================
-- 2. LOCATION HIERARCHY LOOKUP TABLES (lkq_*)
-- =====================================================

CREATE TABLE lkq_region (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL,
    region_code VARCHAR(10) UNIQUE,
    geometry GEOMETRY(MultiPolygon, 20137)
);

CREATE TABLE lkq_city (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    region_id INTEGER REFERENCES lkq_region(region_id),
    municipality_code VARCHAR(20),
    geometry GEOMETRY(MultiPolygon, 20137)
);

CREATE TABLE lkq_subcity (
    subcity_id SERIAL PRIMARY KEY,
    subcity_name VARCHAR(100) NOT NULL,
    city_id INTEGER REFERENCES lkq_city(city_id),
    administrative_code VARCHAR(20),
    geometry GEOMETRY(MultiPolygon, 20137)
);

CREATE TABLE lkq_Woreda (
    Woreda_id SERIAL PRIMARY KEY,
    Woreda_name VARCHAR(100) NOT NULL,
    Woreda_number VARCHAR(20),
    subcity_id INTEGER REFERENCES lkq_subcity(subcity_id),
    geometry GEOMETRY(MultiPolygon, 20137)
);

CREATE TABLE lkq_kebele (
    kebele_id SERIAL PRIMARY KEY,
    kebele_number VARCHAR(20) NOT NULL,
    kebele_name VARCHAR(100),
    Woreda_id INTEGER REFERENCES lkq_Woreda(Woreda_id),
    geometry GEOMETRY(MultiPolygon, 20137)
);

-- =====================================================
-- 3. STATUS AND CONDITION LOOKUP TABLES
-- =====================================================

CREATE TABLE lkp_condition_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    status_code VARCHAR(10) UNIQUE,
    description TEXT,
    color_code VARCHAR(7),
    requires_immediate_action BOOLEAN DEFAULT FALSE,
    maintenance_priority INTEGER
);

CREATE TABLE lkp_operational_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    status_code VARCHAR(10) UNIQUE,
    description TEXT,
    is_accessible_to_public BOOLEAN DEFAULT TRUE
);

CREATE TABLE lkp_ugi_lifecycle_status (
    lifecycle_id SERIAL PRIMARY KEY,
    lifecycle_name VARCHAR(50) NOT NULL,
    description TEXT,
    next_stage_id INTEGER,
    typical_duration_days INTEGER
);

CREATE TABLE lkp_accessibility_type (
    access_id SERIAL PRIMARY KEY,
    access_name VARCHAR(50) NOT NULL,
    description TEXT,
    requires_permit BOOLEAN DEFAULT FALSE,
    requires_fee BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- 4. UGI TYPES (Ethiopian context)
-- =====================================================

CREATE TABLE lkp_ethiopia_ugi_type (
    ugi_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL,
    type_category VARCHAR(50),
    amharic_name VARCHAR(100),
    description TEXT,
    minimum_area_sq_m DECIMAL(10,2),
    requires_fencing BOOLEAN DEFAULT FALSE,
    requires_lighting BOOLEAN DEFAULT FALSE,
    requires_irrigation BOOLEAN DEFAULT FALSE,
    maintenance_priority INTEGER DEFAULT 3
);

-- =====================================================
-- 5. COMPONENT TYPES
-- =====================================================

CREATE TABLE lkp_component_type (
    component_type_id SERIAL PRIMARY KEY,
    component_name VARCHAR(100) NOT NULL,
    component_category VARCHAR(50),
    typical_lifespan_years INTEGER,
    requires_regular_inspection BOOLEAN DEFAULT TRUE,
    inspection_frequency_days INTEGER
);

-- =====================================================
-- 6. ZONE AND MAINTENANCE AREA TABLES
-- =====================================================

CREATE TABLE lkp_zone_type (
    zone_type_id SERIAL PRIMARY KEY,
    zone_type_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE ugims_maintenance_zone (
    zone_id SERIAL PRIMARY KEY,
    zone_name VARCHAR(100) NOT NULL,
    zone_code VARCHAR(20) UNIQUE,
    zone_manager_user_id INTEGER REFERENCES auth_user(id),
    subcity_id INTEGER REFERENCES lkq_subcity(subcity_id),
    geometry GEOMETRY(MultiPolygon, 20137),
    area_sq_m DECIMAL(12,2),
    priority_level INTEGER DEFAULT 3,
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

-- =====================================================
-- 7. PARCEL MANAGEMENT
-- =====================================================

CREATE TABLE lkp_land_use_type (
    land_use_id SERIAL PRIMARY KEY,
    land_use_name VARCHAR(100) NOT NULL,
    land_use_category VARCHAR(50),
    description TEXT
);

CREATE TABLE lkp_ownership_type (
    ownership_id SERIAL PRIMARY KEY,
    ownership_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE lkp_parcel_document_type (
    doc_type_id SERIAL PRIMARY KEY,
    doc_type_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE ugims_parcel (
    parcel_id SERIAL PRIMARY KEY,
    parcel_number VARCHAR(50) UNIQUE NOT NULL,
    parcel_registration_number VARCHAR(50) UNIQUE,
    geometry GEOMETRY(MultiPolygon, 20137) NOT NULL,
    region_id INTEGER REFERENCES lkq_region(region_id),
    city_id INTEGER REFERENCES lkq_city(city_id),
    subcity_id INTEGER REFERENCES lkq_subcity(subcity_id),
    Woreda_id INTEGER REFERENCES lkq_Woreda(Woreda_id),
    kebele_id INTEGER REFERENCES lkq_kebele(kebele_id),
    maintenance_zone_id INTEGER REFERENCES ugims_maintenance_zone(zone_id),
    street_name VARCHAR(255),
    house_number VARCHAR(50),
    landmark VARCHAR(255),
    gps_coordinates GEOMETRY(Point, 20137),
    land_use_type_id INTEGER REFERENCES lkp_land_use_type(land_use_id),
    ownership_type_id INTEGER REFERENCES lkp_ownership_type(ownership_id),
    owner_name VARCHAR(255),
    owner_id_number VARCHAR(50),
    owner_contact VARCHAR(100),
    area_sq_m DECIMAL(12,2),
    cadastral_zone VARCHAR(50),
    registration_date DATE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id INTEGER REFERENCES auth_user(id),
    status_id INTEGER,
    spatial_accuracy VARCHAR(50),
    survey_date DATE,
    survey_method VARCHAR(100)
);

CREATE TABLE ugims_parcel_document (
    document_id SERIAL PRIMARY KEY,
    parcel_id INTEGER NOT NULL REFERENCES ugims_parcel(parcel_id) ON DELETE CASCADE,
    document_type_id INTEGER REFERENCES lkp_parcel_document_type(doc_type_id),
    document_title VARCHAR(255),
    document_number VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    issuing_authority VARCHAR(255),
    file_url TEXT,
    uploaded_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    uploaded_by_user_id INTEGER REFERENCES auth_user(id),
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by_user_id INTEGER REFERENCES auth_user(id),
    verification_date DATE
);

CREATE TABLE ugims_parcel_history (
    history_id SERIAL PRIMARY KEY,
    parcel_id INTEGER REFERENCES ugims_parcel(parcel_id),
    change_type VARCHAR(50),
    old_geometry GEOMETRY(MultiPolygon, 20137),
    new_geometry GEOMETRY(MultiPolygon, 20137),
    old_owner VARCHAR(255),
    new_owner VARCHAR(255),
    change_reason TEXT,
    changed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by_user_id INTEGER REFERENCES auth_user(id),
    approved_by_user_id INTEGER REFERENCES auth_user(id),
    approval_date TIMESTAMP,
    status VARCHAR(50)
);

-- =====================================================
-- 8. UGI ASSETS
-- =====================================================

CREATE TABLE ugims_ugi (
    ugi_id SERIAL PRIMARY KEY,
    ugi_type_id INTEGER NOT NULL REFERENCES lkp_ethiopia_ugi_type(ugi_type_id),
    parcel_id INTEGER NOT NULL REFERENCES ugims_parcel(parcel_id),
    name VARCHAR(255) NOT NULL,
    amharic_name VARCHAR(255),
    alternate_names TEXT,
    ugi_code VARCHAR(50) UNIQUE,
    geometry GEOMETRY(MultiPolygon, 20137) NOT NULL,
    centroid GEOMETRY(Point, 20137) GENERATED ALWAYS AS (ST_Centroid(geometry)) STORED,
    area_sq_m DECIMAL(12,2) GENERATED ALWAYS AS (ST_Area(geometry)) STORED,
    perimeter_m DECIMAL(12,2) GENERATED ALWAYS AS (ST_Perimeter(geometry)) STORED,
    region_id INTEGER REFERENCES lkq_region(region_id),
    city_id INTEGER REFERENCES lkq_city(city_id),
    subcity_id INTEGER REFERENCES lkq_subcity(subcity_id),
    Woreda_id INTEGER REFERENCES lkq_Woreda(Woreda_id),
    kebele_id INTEGER REFERENCES lkq_kebele(kebele_id),
    maintenance_zone_id INTEGER REFERENCES ugims_maintenance_zone(zone_id),
    street_address TEXT,
    landmark_nearby VARCHAR(255),
    google_maps_link TEXT,
    what3words VARCHAR(100),
    establishment_date DATE,
    inauguration_date DATE,
    designed_by VARCHAR(255),
    constructed_by VARCHAR(255),
    construction_cost DECIMAL(15,2),
    accessibility_type_id INTEGER REFERENCES lkp_accessibility_type(access_id),
    operating_hours_id INTEGER,
    has_lighting BOOLEAN DEFAULT FALSE,
    has_irrigation BOOLEAN DEFAULT FALSE,
    has_fencing BOOLEAN DEFAULT FALSE,
    has_parking BOOLEAN DEFAULT FALSE,
    has_public_toilet BOOLEAN DEFAULT FALSE,
    has_water_fountain BOOLEAN DEFAULT FALSE,
    has_seating BOOLEAN DEFAULT FALSE,
    has_wifi BOOLEAN DEFAULT FALSE,
    has_security BOOLEAN DEFAULT FALSE,
    has_handicap_access BOOLEAN DEFAULT FALSE,
    visitor_capacity INTEGER,
    peak_hours TEXT,
    peak_season VARCHAR(100),
    condition_status_id INTEGER REFERENCES lkp_condition_status(status_id),
    operational_status_id INTEGER REFERENCES lkp_operational_status(status_id),
    last_inspected_date DATE,
    next_inspection_due DATE,
    managing_department_id INTEGER,
    maintenance_responsible_id INTEGER,
    contact_person VARCHAR(255),
    contact_phone VARCHAR(50),
    contact_email VARCHAR(255),
    tree_count INTEGER,
    tree_species TEXT,
    grass_type VARCHAR(100),
    irrigation_source VARCHAR(100),
    water_requirement_estimate DECIMAL(10,2),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    updated_by_user_id INTEGER REFERENCES auth_user(id),
    CONSTRAINT ugi_geometry_valid CHECK (ST_IsValid(geometry))
);

CREATE TABLE ugims_ugi_component (
    component_id SERIAL PRIMARY KEY,
    ugi_id INTEGER NOT NULL REFERENCES ugims_ugi(ugi_id) ON DELETE CASCADE,
    component_type_id INTEGER REFERENCES lkp_component_type(component_type_id),
    component_code VARCHAR(50) UNIQUE,
    geometry GEOMETRY(Point, 20137),
    location_description TEXT,
    floor_number INTEGER,
    manufacturer VARCHAR(255),
    model_number VARCHAR(100),
    serial_number VARCHAR(100),
    installation_date DATE,
    material_type VARCHAR(100),
    color VARCHAR(50),
    dimensions VARCHAR(100),
    weight_kg DECIMAL(8,2),
    condition_status_id INTEGER REFERENCES lkp_condition_status(status_id),
    last_inspected DATE,
    inspection_frequency VARCHAR(50),
    warranty_expiry DATE,
    maintenance_instructions TEXT,
    last_maintained DATE,
    next_maintenance_due DATE,
    operational_status_id INTEGER REFERENCES lkp_operational_status(status_id),
    is_public BOOLEAN DEFAULT TRUE,
    safety_rating INTEGER CHECK (safety_rating BETWEEN 1 AND 5),
    notes TEXT,
    photo_urls TEXT[],
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    updated_by_user_id INTEGER REFERENCES auth_user(id)
);

-- =====================================================
-- 9. PLANNING AND ACTIVITY MANAGEMENT
-- =====================================================

CREATE TABLE lkp_fiscal_year (
    fiscal_year_id SERIAL PRIMARY KEY,
    fiscal_year_name VARCHAR(9) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    description TEXT
);

CREATE TABLE lkp_plan_type (
    plan_type_id SERIAL PRIMARY KEY,
    plan_type_name VARCHAR(50) NOT NULL,
    description TEXT,
    planning_horizon_days INTEGER,
    requires_approval BOOLEAN DEFAULT TRUE
);

CREATE TABLE lkp_plan_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE lkp_activity_category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    requires_special_skill BOOLEAN DEFAULT FALSE
);

CREATE TABLE lkp_frequency (
    frequency_id SERIAL PRIMARY KEY,
    frequency_name VARCHAR(50) NOT NULL,
    days_interval INTEGER,
    times_per_year DECIMAL(5,2),
    description TEXT
);

CREATE TABLE lkp_activity_type (
    activity_type_id SERIAL PRIMARY KEY,
    activity_name VARCHAR(100) NOT NULL,
    activity_name_amharic VARCHAR(100),
    category_id INTEGER REFERENCES lkp_activity_category(category_id),
    typical_duration_hours DECIMAL(5,2),
    typical_crew_size INTEGER,
    requires_supervision BOOLEAN DEFAULT TRUE,
    safety_gear_required TEXT,
    equipment_needed TEXT,
    season_preference VARCHAR(50),
    frequency_default_id INTEGER REFERENCES lkp_frequency(frequency_id)
);

CREATE TABLE lkp_activity_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    status_code VARCHAR(10) UNIQUE,
    description TEXT,
    is_terminal BOOLEAN DEFAULT FALSE,
    can_edit BOOLEAN DEFAULT TRUE
);

CREATE TABLE ugims_management_plan (
    plan_id SERIAL PRIMARY KEY,
    plan_number VARCHAR(50) UNIQUE,
    plan_name VARCHAR(255) NOT NULL,
    plan_type_id INTEGER REFERENCES lkp_plan_type(plan_type_id),
    fiscal_year_id INTEGER REFERENCES lkp_fiscal_year(fiscal_year_id),
    scope_type VARCHAR(50),
    ugi_ids INTEGER[],
    zone_id INTEGER REFERENCES ugims_maintenance_zone(zone_id),
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    total_budget_allocated DECIMAL(15,2),
    total_estimated_cost DECIMAL(15,2),
    total_actual_cost DECIMAL(15,2),
    budget_source VARCHAR(255),
    budget_code VARCHAR(100),
    total_estimated_man_days DECIMAL(10,2),
    total_actual_man_days DECIMAL(10,2),
    estimated_equipment_hours DECIMAL(10,2),
    plan_status_id INTEGER,
    approval_status_id INTEGER,
    approved_by_user_id INTEGER REFERENCES auth_user(id),
    approval_date TIMESTAMP,
    approval_notes TEXT,
    prepared_by_user_id INTEGER REFERENCES auth_user(id),
    prepared_date TIMESTAMP,
    reviewed_by_user_id INTEGER REFERENCES auth_user(id),
    reviewed_date TIMESTAMP,
    goals_and_objectives TEXT,
    success_criteria TEXT,
    risks_and_assumptions TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    updated_by_user_id INTEGER REFERENCES auth_user(id),
    notes TEXT,
    attachments TEXT[]
);

CREATE TABLE ugims_plan_activity (
    plan_activity_id SERIAL PRIMARY KEY,
    plan_id INTEGER NOT NULL REFERENCES ugims_management_plan(plan_id) ON DELETE CASCADE,
    activity_number VARCHAR(50),
    activity_type_id INTEGER REFERENCES lkp_activity_type(activity_type_id),
    activity_name VARCHAR(255),
    activity_description TEXT,
    ugi_id INTEGER REFERENCES ugims_ugi(ugi_id),
    component_id INTEGER REFERENCES ugims_ugi_component(component_id),
    target_area GEOMETRY(Polygon, 20137),
    frequency_id INTEGER REFERENCES lkp_frequency(frequency_id),
    scheduled_start_date DATE,
    scheduled_end_date DATE,
    scheduled_start_month INTEGER,
    scheduled_end_month INTEGER,
    preferred_time_of_day VARCHAR(50),
    duration_days INTEGER,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_pattern JSONB,
    estimated_man_days DECIMAL(8,2),
    estimated_labor_cost DECIMAL(12,2),
    estimated_material_cost DECIMAL(12,2),
    estimated_equipment_cost DECIMAL(12,2),
    total_estimated_cost DECIMAL(12,2),
    required_materials TEXT,
    required_materials_list JSONB,
    required_equipment TEXT,
    required_equipment_list JSONB,
    estimated_crew_size INTEGER,
    required_skills TEXT,
    assigned_team_id INTEGER,
    assigned_team_lead INTEGER,
    depends_on_activity_id INTEGER REFERENCES ugims_plan_activity(plan_activity_id),
    prerequisites TEXT,
    priority INTEGER DEFAULT 3,
    activity_status_id INTEGER REFERENCES lkp_activity_status(status_id),
    weather_dependent BOOLEAN DEFAULT FALSE,
    preferred_weather VARCHAR(50),
    cannot_execute_in_rain BOOLEAN DEFAULT FALSE,
    safety_requirements TEXT,
    requires_supervision BOOLEAN DEFAULT TRUE,
    expected_outcome TEXT,
    quality_standards TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    updated_by_user_id INTEGER REFERENCES auth_user(id)
);

-- =====================================================
-- 10. WORKFORCE MANAGEMENT
-- =====================================================

CREATE TABLE lkp_job_title (
    job_title_id SERIAL PRIMARY KEY,
    job_title_name VARCHAR(100) NOT NULL,
    job_category VARCHAR(50),
    pay_grade VARCHAR(20),
    requires_certification BOOLEAN DEFAULT FALSE,
    requires_license BOOLEAN DEFAULT FALSE
);

CREATE TABLE lkp_skill (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL,
    skill_category VARCHAR(50),
    certification_required BOOLEAN DEFAULT FALSE
);

CREATE TABLE lkp_leave_type (
    leave_type_id SERIAL PRIMARY KEY,
    leave_name VARCHAR(50) NOT NULL,
    description TEXT,
    paid BOOLEAN DEFAULT TRUE,
    days_per_year INTEGER
);

CREATE TABLE ugims_workforce_user (
    user_id INTEGER PRIMARY KEY REFERENCES auth_user(id),
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    amharic_name VARCHAR(200),
    phone_number VARCHAR(20),
    alternate_phone VARCHAR(20),
    email VARCHAR(255),
    emergency_contact_name VARCHAR(200),
    emergency_contact_phone VARCHAR(20),
    job_title_id INTEGER REFERENCES lkp_job_title(job_title_id),
    employment_type VARCHAR(50),
    employment_status VARCHAR(50),
    hire_date DATE,
    contract_start_date DATE,
    contract_end_date DATE,
    termination_date DATE,
    termination_reason TEXT,
    assigned_zone_id INTEGER REFERENCES ugims_maintenance_zone(zone_id),
    reports_to_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    department_id INTEGER,
    education_level VARCHAR(100),
    certifications TEXT[],
    skills INTEGER[],
    years_experience INTEGER,
    shift_preference VARCHAR(50),
    work_hours_per_week INTEGER,
    overtime_eligible BOOLEAN DEFAULT TRUE,
    assigned_equipment TEXT[],
    vehicle_assigned VARCHAR(100),
    training_completed TEXT[],
    training_required TEXT[],
    last_training_date DATE,
    next_training_due DATE,
    medical_clearance_date DATE,
    physical_capability_notes TEXT,
    allergies TEXT,
    can_access_mobile BOOLEAN DEFAULT TRUE,
    mobile_device_assigned VARCHAR(100),
    last_login TIMESTAMP,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    updated_by_user_id INTEGER REFERENCES auth_user(id),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE ugims_team (
    team_id SERIAL PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    team_code VARCHAR(20) UNIQUE,
    team_type VARCHAR(50),
    assigned_zone_id INTEGER REFERENCES ugims_maintenance_zone(zone_id),
    specialization VARCHAR(100),
    team_lead_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    assistant_lead_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    min_members INTEGER,
    max_members INTEGER,
    current_member_count INTEGER DEFAULT 0,
    shift VARCHAR(50),
    work_days VARCHAR(100),
    assigned_vehicles TEXT[],
    assigned_equipment TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    status VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    updated_by_user_id INTEGER REFERENCES auth_user(id)
);

CREATE TABLE ugims_team_membership (
    membership_id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES ugims_team(team_id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES ugims_workforce_user(user_id) ON DELETE CASCADE,
    role_in_team VARCHAR(50),
    assigned_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    UNIQUE(team_id, user_id, assigned_date)
);

CREATE TABLE ugims_workforce_schedule (
    schedule_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES ugims_workforce_user(user_id),
    schedule_date DATE NOT NULL,
    shift_start TIME,
    shift_end TIME,
    break_duration_minutes INTEGER,
    assignment_type VARCHAR(50),
    assigned_zone_id INTEGER REFERENCES ugims_maintenance_zone(zone_id),
    assigned_task_id INTEGER,
    clock_in_time TIMESTAMP,
    clock_out_time TIMESTAMP,
    clock_in_location GEOMETRY(Point, 20137),
    clock_out_location GEOMETRY(Point, 20137),
    actual_hours_worked DECIMAL(5,2),
    status VARCHAR(50),
    notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    UNIQUE(user_id, schedule_date)
);

-- =====================================================
-- 11. ACTIVITY EXECUTION
-- =====================================================

CREATE TABLE ugims_activity_execution (
    execution_id SERIAL PRIMARY KEY,
    plan_activity_id INTEGER REFERENCES ugims_plan_activity(plan_activity_id),
    ugi_id INTEGER NOT NULL REFERENCES ugims_ugi(ugi_id),
    activity_type_id INTEGER NOT NULL REFERENCES lkp_activity_type(activity_type_id),
    execution_number VARCHAR(50) UNIQUE,
    actual_start_datetime TIMESTAMP,
    actual_end_datetime TIMESTAMP,
    scheduled_start_datetime TIMESTAMP,
    duration_minutes INTEGER GENERATED ALWAYS AS 
        (EXTRACT(EPOCH FROM (actual_end_datetime - actual_start_datetime))/60) STORED,
    start_location GEOMETRY(Point, 20137),
    end_location GEOMETRY(Point, 20137),
    work_area GEOMETRY(Polygon, 20137),
    tracking_path GEOMETRY(LineString, 20137),
    performed_by_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    performed_by_team_id INTEGER REFERENCES ugims_team(team_id),
    supervised_by_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    additional_workers JSONB,
    actual_man_days DECIMAL(6,2),
    actual_man_hours DECIMAL(6,2),
    actual_labor_cost DECIMAL(12,2),
    actual_material_cost DECIMAL(12,2),
    actual_equipment_cost DECIMAL(12,2),
    total_actual_cost DECIMAL(12,2),
    materials_used JSONB,
    materials_used_text TEXT,
    equipment_used JSONB,
    work_performed TEXT,
    work_notes TEXT,
    challenges_encountered TEXT,
    deviations_from_plan TEXT,
    completion_status_id INTEGER REFERENCES lkp_activity_status(status_id),
    completion_percentage INTEGER DEFAULT 100,
    quality_rating INTEGER CHECK (quality_rating BETWEEN 1 AND 5),
    quality_notes TEXT,
    before_photos TEXT[],
    during_photos TEXT[],
    after_photos TEXT[],
    additional_documents TEXT[],
    verified_by_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    verification_datetime TIMESTAMP,
    verification_notes TEXT,
    verification_status VARCHAR(50),
    issues_identified BOOLEAN DEFAULT FALSE,
    issue_ids INTEGER[],
    followup_required BOOLEAN DEFAULT FALSE,
    followup_notes TEXT,
    followup_date DATE,
    weather_conditions VARCHAR(100),
    temperature_c DECIMAL(4,1),
    precipitation BOOLEAN,
    wind_conditions VARCHAR(50),
    recorded_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    recorded_by_user_id INTEGER REFERENCES auth_user(id),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mobile_device_id VARCHAR(100),
    mobile_app_version VARCHAR(20),
    sync_datetime TIMESTAMP,
    offline_record BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- 12. INSPECTION AND MONITORING
-- =====================================================

CREATE TABLE lkp_inspection_type (
    inspection_type_id SERIAL PRIMARY KEY,
    inspection_name VARCHAR(100) NOT NULL,
    description TEXT,
    typical_frequency_id INTEGER REFERENCES lkp_frequency(frequency_id),
    requires_tools BOOLEAN DEFAULT FALSE,
    requires_certification BOOLEAN DEFAULT FALSE
);

CREATE TABLE lkp_inspection_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    description TEXT,
    allows_editing BOOLEAN DEFAULT TRUE
);

CREATE TABLE lkp_finding_priority (
    priority_id SERIAL PRIMARY KEY,
    priority_name VARCHAR(50) NOT NULL,
    response_time_hours INTEGER,
    color_code VARCHAR(7),
    requires_immediate_action BOOLEAN DEFAULT FALSE
);

CREATE TABLE ugims_inspection (
    inspection_id SERIAL PRIMARY KEY,
    inspection_number VARCHAR(50) UNIQUE,
    inspection_type_id INTEGER REFERENCES lkp_inspection_type(inspection_type_id),
    ugi_id INTEGER REFERENCES ugims_ugi(ugi_id),
    component_id INTEGER REFERENCES ugims_ugi_component(component_id),
    inspection_area GEOMETRY(Polygon, 20137),
    scheduled_date TIMESTAMP,
    scheduled_by_user_id INTEGER REFERENCES auth_user(id),
    assigned_to_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    assigned_date TIMESTAMP,
    started_datetime TIMESTAMP,
    completed_datetime TIMESTAMP,
    inspector_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    inspector_notes TEXT,
    inspection_path GEOMETRY(LineString, 20137),
    start_location GEOMETRY(Point, 20137),
    end_location GEOMETRY(Point, 20137),
    overall_condition_id INTEGER REFERENCES lkp_condition_status(status_id),
    overall_rating INTEGER CHECK (overall_rating BETWEEN 1 AND 10),
    findings_summary TEXT,
    recommendations TEXT,
    issues_found BOOLEAN DEFAULT FALSE,
    critical_issues_found BOOLEAN DEFAULT FALSE,
    issue_count INTEGER DEFAULT 0,
    inspection_status_id INTEGER REFERENCES lkp_inspection_status(status_id),
    report_document_url TEXT,
    photo_urls TEXT[],
    video_urls TEXT[],
    followup_required BOOLEAN DEFAULT FALSE,
    followup_inspection_id INTEGER,
    followup_date DATE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    updated_by_user_id INTEGER REFERENCES auth_user(id),
    mobile_device_id VARCHAR(100),
    sync_datetime TIMESTAMP,
    offline_record BOOLEAN DEFAULT FALSE
);

CREATE TABLE ugims_inspection_finding (
    finding_id SERIAL PRIMARY KEY,
    inspection_id INTEGER NOT NULL REFERENCES ugims_inspection(inspection_id) ON DELETE CASCADE,
    ugi_id INTEGER REFERENCES ugims_ugi(ugi_id),
    component_id INTEGER REFERENCES ugims_ugi_component(component_id),
    location_point GEOMETRY(Point, 20137),
    location_description TEXT,
    finding_type VARCHAR(100),
    finding_description TEXT NOT NULL,
    finding_priority_id INTEGER REFERENCES lkp_finding_priority(priority_id),
    condition_before_id INTEGER REFERENCES lkp_condition_status(status_id),
    condition_after_id INTEGER REFERENCES lkp_condition_status(status_id),
    quantity_affected INTEGER,
    severity INTEGER CHECK (severity BETWEEN 1 AND 5),
    immediate_action_taken TEXT,
    recommended_action TEXT,
    recommended_action_date DATE,
    estimated_repair_cost DECIMAL(12,2),
    estimated_repair_hours DECIMAL(6,2),
    assigned_to_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    assigned_date DATE,
    work_order_created BOOLEAN DEFAULT FALSE,
    work_order_id INTEGER,
    resolved BOOLEAN DEFAULT FALSE,
    resolved_date TIMESTAMP,
    resolved_by_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    resolution_notes TEXT,
    photo_urls TEXT[],
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ugims_monitoring_log (
    log_id SERIAL PRIMARY KEY,
    log_number VARCHAR(50) UNIQUE,
    ugi_id INTEGER REFERENCES ugims_ugi(ugi_id),
    location_point GEOMETRY(Point, 20137) NOT NULL,
    location_description TEXT,
    monitor_user_id INTEGER NOT NULL REFERENCES ugims_workforce_user(user_id),
    log_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    log_type VARCHAR(50),
    log_category VARCHAR(50),
    observations TEXT NOT NULL,
    issues_noted TEXT,
    actions_taken TEXT,
    observed_condition_id INTEGER REFERENCES lkp_condition_status(status_id),
    visitor_count_estimate INTEGER,
    weather_conditions VARCHAR(100),
    temperature_c DECIMAL(4,1),
    recent_rainfall BOOLEAN,
    photo_urls TEXT[],
    is_urgent BOOLEAN DEFAULT FALSE,
    requires_followup BOOLEAN DEFAULT FALSE,
    followup_notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    mobile_device_id VARCHAR(100),
    sync_datetime TIMESTAMP,
    offline_record BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- 13. ISSUE TRACKING
-- =====================================================

CREATE TABLE lkp_issue_category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    default_priority_id INTEGER REFERENCES lkp_finding_priority(priority_id)
);

CREATE TABLE lkp_issue_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    description TEXT,
    is_closed BOOLEAN DEFAULT FALSE
);

CREATE TABLE ugims_issue (
    issue_id SERIAL PRIMARY KEY,
    issue_number VARCHAR(50) UNIQUE,
    source_type VARCHAR(50),
    source_reference_id INTEGER,
    category_id INTEGER REFERENCES lkp_issue_category(category_id),
    issue_type VARCHAR(100),
    priority_id INTEGER REFERENCES lkp_finding_priority(priority_id),
    ugi_id INTEGER REFERENCES ugims_ugi(ugi_id),
    component_id INTEGER REFERENCES ugims_ugi_component(component_id),
    location_point GEOMETRY(Point, 20137),
    location_description TEXT,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    reported_by_name VARCHAR(255),
    reported_by_contact VARCHAR(100),
    reported_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    severity INTEGER CHECK (severity BETWEEN 1 AND 5),
    affects_safety BOOLEAN DEFAULT FALSE,
    affects_accessibility BOOLEAN DEFAULT FALSE,
    affects_operations BOOLEAN DEFAULT FALSE,
    photo_urls TEXT[],
    assigned_to_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    assigned_to_team_id INTEGER REFERENCES ugims_team(team_id),
    assigned_datetime TIMESTAMP,
    assigned_by_user_id INTEGER REFERENCES auth_user(id),
    work_order_created BOOLEAN DEFAULT FALSE,
    work_order_id INTEGER,
    status_id INTEGER REFERENCES lkp_issue_status(status_id),
    status_history JSONB,
    resolved_datetime TIMESTAMP,
    resolved_by_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    resolution_notes TEXT,
    resolution_action_taken TEXT,
    verified_by_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    verification_datetime TIMESTAMP,
    verification_notes TEXT,
    estimated_cost DECIMAL(12,2),
    actual_cost DECIMAL(12,2),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    updated_by_user_id INTEGER REFERENCES auth_user(id)
);

CREATE TABLE ugims_issue_comment (
    comment_id SERIAL PRIMARY KEY,
    issue_id INTEGER NOT NULL REFERENCES ugims_issue(issue_id) ON DELETE CASCADE,
    comment_text TEXT NOT NULL,
    comment_type VARCHAR(50),
    commented_by_user_id INTEGER REFERENCES auth_user(id),
    commented_by_name VARCHAR(255),
    commented_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    attachments TEXT[],
    is_public BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- 14. CITIZEN ENGAGEMENT
-- =====================================================

CREATE TABLE lkp_citizen_report_type (
    report_type_id SERIAL PRIMARY KEY,
    report_type_name VARCHAR(100) NOT NULL,
    report_type_name_amharic VARCHAR(100),
    category VARCHAR(50),
    default_priority_id INTEGER REFERENCES lkp_finding_priority(priority_id),
    estimated_response_days INTEGER
);

CREATE TABLE lkp_citizen_report_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    status_name_amharic VARCHAR(100),
    description TEXT,
    is_visible_to_public BOOLEAN DEFAULT TRUE
);

CREATE TABLE ugims_citizen_report (
    report_id SERIAL PRIMARY KEY,
    report_number VARCHAR(50) UNIQUE,
    reporter_name VARCHAR(255),
    reporter_email VARCHAR(255),
    reporter_phone VARCHAR(50),
    is_anonymous BOOLEAN DEFAULT FALSE,
    preferred_contact_method VARCHAR(50),
    report_type_id INTEGER REFERENCES lkp_citizen_report_type(report_type_id),
    report_title VARCHAR(255),
    report_description TEXT NOT NULL,
    location_point GEOMETRY(Point, 20137) NOT NULL,
    location_description TEXT,
    ugi_id INTEGER REFERENCES ugims_ugi(ugi_id),
    address_text TEXT,
    photo_urls TEXT[],
    status_id INTEGER REFERENCES lkp_citizen_report_status(status_id) DEFAULT 1,
    assigned_to_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    assigned_team_id INTEGER REFERENCES ugims_team(team_id),
    assigned_datetime TIMESTAMP,
    issue_id INTEGER REFERENCES ugims_issue(issue_id),
    inspection_id INTEGER REFERENCES ugims_inspection(inspection_id),
    response_message TEXT,
    response_datetime TIMESTAMP,
    responded_by_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    resolved_datetime TIMESTAMP,
    resolution_notes TEXT,
    resolution_photo_urls TEXT[],
    satisfaction_rating INTEGER CHECK (satisfaction_rating BETWEEN 1 AND 5),
    feedback_comments TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    mobile_device_id VARCHAR(100),
    app_version VARCHAR(20),
    sync_datetime TIMESTAMP
);

CREATE TABLE ugims_public_feedback (
    feedback_id SERIAL PRIMARY KEY,
    ugi_id INTEGER REFERENCES ugims_ugi(ugi_id),
    feedback_type VARCHAR(50),
    visitor_purpose VARCHAR(100),
    overall_rating INTEGER CHECK (overall_rating BETWEEN 1 AND 5),
    cleanliness_rating INTEGER CHECK (cleanliness_rating BETWEEN 1 AND 5),
    safety_rating INTEGER CHECK (safety_rating BETWEEN 1 AND 5),
    maintenance_rating INTEGER CHECK (maintenance_rating BETWEEN 1 AND 5),
    accessibility_rating INTEGER CHECK (accessibility_rating BETWEEN 1 AND 5),
    comments TEXT,
    suggestions TEXT,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    visit_date DATE,
    feedback_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(50),
    anonymous BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- 15. BUDGET AND FINANCIAL MANAGEMENT
-- =====================================================

CREATE TABLE lkp_budget_category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_code VARCHAR(20),
    description TEXT
);

CREATE TABLE lkp_budget_source (
    source_id SERIAL PRIMARY KEY,
    source_name VARCHAR(100) NOT NULL,
    source_type VARCHAR(50),
    description TEXT
);

CREATE TABLE ugims_budget (
    budget_id SERIAL PRIMARY KEY,
    budget_code VARCHAR(50) UNIQUE,
    budget_name VARCHAR(255) NOT NULL,
    fiscal_year_id INTEGER REFERENCES lkp_fiscal_year(fiscal_year_id),
    budget_year VARCHAR(9),
    start_date DATE,
    end_date DATE,
    budget_type VARCHAR(50),
    budget_source_id INTEGER REFERENCES lkp_budget_source(source_id),
    funding_source_details TEXT,
    scope_type VARCHAR(50),
    zone_id INTEGER REFERENCES ugims_maintenance_zone(zone_id),
    ugi_id INTEGER REFERENCES ugims_ugi(ugi_id),
    department_id INTEGER,
    project_name VARCHAR(255),
    allocated_amount DECIMAL(15,2) NOT NULL,
    committed_amount DECIMAL(15,2) DEFAULT 0,
    expended_amount DECIMAL(15,2) DEFAULT 0,
    remaining_amount DECIMAL(15,2) GENERATED ALWAYS AS (allocated_amount - committed_amount - expended_amount) STORED,
    currency VARCHAR(3) DEFAULT 'ETB',
    exchange_rate DECIMAL(10,4),
    original_amount DECIMAL(15,2),
    budget_status VARCHAR(50),
    approval_status VARCHAR(50),
    approved_by_user_id INTEGER REFERENCES auth_user(id),
    approval_date TIMESTAMP,
    approval_document TEXT,
    manager_user_id INTEGER REFERENCES auth_user(id),
    finance_officer_user_id INTEGER REFERENCES auth_user(id),
    category_breakdown JSONB,
    notes TEXT,
    restrictions TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    updated_by_user_id INTEGER REFERENCES auth_user(id)
);

CREATE TABLE ugims_budget_line_item (
    line_item_id SERIAL PRIMARY KEY,
    budget_id INTEGER NOT NULL REFERENCES ugims_budget(budget_id) ON DELETE CASCADE,
    line_number INTEGER,
    category_id INTEGER REFERENCES lkp_budget_category(category_id),
    description TEXT NOT NULL,
    allocated_amount DECIMAL(15,2) NOT NULL,
    committed_amount DECIMAL(15,2) DEFAULT 0,
    expended_amount DECIMAL(15,2) DEFAULT 0,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_frequency VARCHAR(50),
    notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ugims_expense (
    expense_id SERIAL PRIMARY KEY,
    expense_number VARCHAR(50) UNIQUE,
    budget_id INTEGER REFERENCES ugims_budget(budget_id),
    line_item_id INTEGER REFERENCES ugims_budget_line_item(line_item_id),
    expense_date DATE NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    category_id INTEGER REFERENCES lkp_budget_category(category_id),
    expense_type VARCHAR(50),
    vendor_name VARCHAR(255),
    vendor_id VARCHAR(100),
    invoice_number VARCHAR(100),
    receipt_number VARCHAR(100),
    ugi_id INTEGER REFERENCES ugims_ugi(ugi_id),
    activity_execution_id INTEGER REFERENCES ugims_activity_execution(execution_id),
    plan_id INTEGER REFERENCES ugims_management_plan(plan_id),
    work_order_id INTEGER,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    payment_date DATE,
    paid_by_user_id INTEGER REFERENCES auth_user(id),
    supporting_documents TEXT[],
    notes TEXT,
    approved_by_user_id INTEGER REFERENCES auth_user(id),
    approval_date TIMESTAMP,
    approval_notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INTEGER REFERENCES auth_user(id),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ugims_purchase_requisition (
    requisition_id SERIAL PRIMARY KEY,
    requisition_number VARCHAR(50) UNIQUE,
    requisition_date DATE DEFAULT CURRENT_DATE,
    requested_by_user_id INTEGER REFERENCES ugims_workforce_user(user_id),
    department_id INTEGER,
    purpose TEXT NOT NULL,
    ugi_id INTEGER REFERENCES ugims_ugi(ugi_id),
    activity_id INTEGER REFERENCES ugims_plan_activity(plan_activity_id),
    items JSONB NOT NULL,
    total_estimated_cost DECIMAL(15,2),
    budget_id INTEGER REFERENCES ugims_budget(budget_id),
    budget_check_status VARCHAR(50),
    budget_check_notes TEXT,
    approval_status VARCHAR(50),
    current_approver_level INTEGER,
    approval_history JSONB,
    approved_by_user_id INTEGER REFERENCES auth_user(id),
    approval_date TIMESTAMP,
    approval_notes TEXT,
    purchase_order_id VARCHAR(100),
    purchase_order_date DATE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 16. SPATIAL METADATA AND AUDIT
-- =====================================================

CREATE TABLE ugims_spatial_metadata (
    metadata_id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    column_name VARCHAR(100) NOT NULL,
    srid INTEGER DEFAULT 20137,
    geometry_type VARCHAR(50),
    feature_count INTEGER,
    last_updated TIMESTAMP,
    extent_geometry GEOMETRY(Polygon, 20137),
    notes TEXT
);

CREATE TABLE ugims_audit_log (
    audit_id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER NOT NULL,
    action VARCHAR(50) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_by_user_id INTEGER REFERENCES auth_user(id),
    changed_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT
);

-- =====================================================
-- 17. IMPORT SYSTEM TABLES (UUID → SERIAL)
-- =====================================================

-- Table for storing field mapping templates
CREATE TABLE IF NOT EXISTS ugims_import_mapping (
    mapping_id SERIAL PRIMARY KEY,
    mapping_name VARCHAR(100) NOT NULL,
    import_type VARCHAR(20) NOT NULL,
    field_mapping JSONB NOT NULL,
    created_by INTEGER REFERENCES ugims_users(user_id),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_default BOOLEAN DEFAULT false
);

-- Table for temporary import sessions
CREATE TABLE IF NOT EXISTS ugims_import_session (
    session_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES ugims_users(user_id),
    import_type VARCHAR(20) NOT NULL,
    temp_dir VARCHAR(255),
    shapefile_name VARCHAR(255),
    total_records INTEGER DEFAULT 0,
    field_mapping JSONB,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '2 hours')
);

-- Make sure the import log table exists
CREATE TABLE IF NOT EXISTS ugims_import_log (
    import_id SERIAL PRIMARY KEY,
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
CREATE INDEX IF NOT EXISTS idx_import_mapping_type ON ugims_import_mapping(import_type);
CREATE INDEX IF NOT EXISTS idx_import_mapping_created_by ON ugims_import_mapping(created_by);
CREATE INDEX IF NOT EXISTS idx_import_session_expires ON ugims_import_session(expires_at);
CREATE INDEX IF NOT EXISTS idx_import_session_user ON ugims_import_session(user_id);
CREATE INDEX IF NOT EXISTS idx_import_log_date ON ugims_import_log(import_date);
CREATE INDEX IF NOT EXISTS idx_import_log_status ON ugims_import_log(status);
CREATE INDEX IF NOT EXISTS idx_import_log_user ON ugims_import_log(imported_by_user_id);

-- =====================================================
-- 18. INSERT ALL LOOKUP DATA FIRST
-- =====================================================

-- Insert into lkq_region
INSERT INTO lkq_region (region_name, region_code) VALUES
('Addis Ababa', 'AA'),
('Sidama', 'SD'),
('Oromia', 'OR'),
('Amhara', 'AM'),
('Tigray', 'TG'),
('Southern Nations Nationalities and Peoples', 'SNNP');

-- Insert into lkq_city
INSERT INTO lkq_city (city_name, region_id) VALUES
('Addis Ababa', 1),
('Hawassa', 2),
('Adama', 3),
('Bahir Dar', 4),
('Mekelle', 5);

-- Insert into lkq_subcity
INSERT INTO lkq_subcity (subcity_name, city_id) VALUES
('Addis Ketema', 1),
('Akaki Kaliti', 1),
('Arada', 1),
('Bole', 1),
('Gulele', 1),
('Kirkos', 1),
('Kolfe Keranio', 1),
('Lideta', 1),
('Nifas Silk-Lafto', 1),
('Yeka', 1),
('Hawassa Tula', 2),
('Hawassa Tabore', 2),
('Hawassa Mehal', 2),
('Hawassa Hayk Dar', 2),
('Hawassa Adare', 2);

-- Insert into lkp_condition_status
INSERT INTO lkp_condition_status (status_name, status_code, description, color_code, requires_immediate_action, maintenance_priority) VALUES
('Excellent', 'EXC', 'New or like-new condition, no maintenance needed', '#00FF00', FALSE, 5),
('Good', 'GOOD', 'Minor wear only, routine maintenance sufficient', '#90EE90', FALSE, 4),
('Fair', 'FAIR', 'Some deterioration, planned maintenance needed', '#FFFF00', FALSE, 3),
('Poor', 'POOR', 'Significant deterioration, repair needed soon', '#FFA500', FALSE, 2),
('Critical', 'CRIT', 'Unsafe or non-functional, immediate action required', '#FF0000', TRUE, 1),
('Under Repair', 'REPR', 'Currently undergoing repair/maintenance', '#0000FF', FALSE, NULL),
('Not Applicable', 'NA', 'Condition assessment not applicable', '#808080', FALSE, NULL),
('Not Inspected', 'NINS', 'Has not been inspected recently', '#C0C0C0', FALSE, NULL);

-- Insert into lkp_operational_status
INSERT INTO lkp_operational_status (status_name, status_code, description, is_accessible_to_public) VALUES
('Open - Fully Operational', 'OPEN', 'Fully open and functioning normally', TRUE),
('Open - Limited Access', 'LIMIT', 'Open but with some areas restricted', TRUE),
('Open - Reduced Hours', 'REDHR', 'Open with reduced operating hours', TRUE),
('Temporarily Closed', 'TCLOS', 'Temporarily closed for maintenance or events', FALSE),
('Closed - Seasonal', 'SEAS', 'Closed for the season', FALSE),
('Closed - Under Construction', 'CONST', 'Closed for construction/renovation', FALSE),
('Permanently Closed', 'PCLOS', 'Permanently closed/decommissioned', FALSE),
('Under Maintenance', 'MAINT', 'Currently undergoing maintenance', FALSE),
('Emergency Closure', 'EMERG', 'Closed due to emergency/safety issue', FALSE);

-- Insert into lkp_ugi_lifecycle_status
INSERT INTO lkp_ugi_lifecycle_status (lifecycle_name, description, typical_duration_days) VALUES
('Planned', 'UGI has been planned but not yet established', NULL),
('Under Construction', 'Currently being developed/constructed', 180),
('Newly Established', 'Recently completed, in establishment phase', 365),
('Operational', 'Fully operational and mature', NULL),
('Under Renovation', 'Undergoing major renovation', 90),
('Decommissioned', 'No longer in use as UGI', NULL),
('Transferred', 'Ownership/management transferred', NULL);

-- Insert into lkp_accessibility_type
INSERT INTO lkp_accessibility_type (access_name, description, requires_permit, requires_fee) VALUES
('Public - Free Access', 'Open to all without any restrictions', FALSE, FALSE),
('Public - Timed Access', 'Open to public during specific hours', FALSE, FALSE),
('Public - Fee Required', 'Open to public with entrance fee', FALSE, TRUE),
('Restricted - Permit Required', 'Access requires special permit', TRUE, FALSE),
('Restricted - Members Only', 'Only accessible to members', TRUE, TRUE),
('Private', 'Private property, no public access', TRUE, FALSE),
('Institutional', 'Access limited to institution members', TRUE, FALSE);

-- Insert into lkp_ethiopia_ugi_type
INSERT INTO lkp_ethiopia_ugi_type (type_name, type_category, amharic_name, description, minimum_area_sq_m, requires_fencing, requires_lighting, requires_irrigation) VALUES
('Urban Park', 'Recreational', 'የከተማ መናፈሻ', 'Public park with recreational facilities, seating, and landscaping', 1000, TRUE, TRUE, TRUE),
('Sport Field', 'Recreational', 'የስፖርት ሜዳ', 'Designated area for athletic activities including football, athletics', 5000, TRUE, TRUE, TRUE),
('Cemetery', 'Cultural/Religious', 'የመቃብር ስፍራ', 'Burial grounds with vegetation and pathways', 2000, TRUE, FALSE, FALSE),
('Open Green Space', 'Recreational', 'ክፍት አረንጓዴ ቦታ', 'Unstructured grass and vegetation for recreation', 500, FALSE, FALSE, FALSE),
('Roadside Green Area', 'Transportation', 'የመንገድ ዳር አረንጓዴ', 'Vegetation along roads and highways', 100, FALSE, FALSE, TRUE),
('Road Divide/Median', 'Transportation', 'የመንገድ መከፋፈያ', 'Vegetated central reservations', 50, FALSE, FALSE, TRUE),
('Roundabout', 'Transportation', 'ክብ መንገድ', 'Circular intersection with central greenery', 200, FALSE, TRUE, TRUE),
('Urban Forest', 'Natural', 'የከተማ ደን', 'Dense vegetation area with trees and shrubs', 5000, FALSE, FALSE, FALSE),
('River/Riverside Green', 'Natural', 'የወንዝ ዳር አረንጓዴ', 'Riparian vegetation along water bodies', 1000, FALSE, FALSE, FALSE),
('Public Square/Plaza', 'Recreational', 'የህዝብ አደባባይ', 'Urban spaces with hardscape and greenery', 500, FALSE, TRUE, TRUE),
('Community Garden', 'Agricultural', 'የማህበረሰብ አትክልት ስፍራ', 'Cultivated lands for community agriculture', 200, TRUE, FALSE, TRUE),
('Botanical Garden', 'Educational', 'የእፅዋት አትክልት ስፍራ', 'Scientific collection of plants for research and education', 2000, TRUE, TRUE, TRUE),
('Children''s Playground', 'Recreational', 'የህጻናት መጫወቻ', 'Area specifically designed for children with play equipment', 300, TRUE, TRUE, TRUE),
('Green Buffer Zone', 'Environmental', 'አረንጓዴ መከላከያ ቀጠና', 'Vegetated area separating different land uses', 500, FALSE, FALSE, FALSE),
('Institutional Grounds', 'Institutional', 'የተቋማት ግቢ', 'Green areas within schools, hospitals, government compounds', 300, TRUE, TRUE, TRUE);

-- Insert into lkp_component_type (abbreviated list for brevity)
INSERT INTO lkp_component_type (component_name, component_category, typical_lifespan_years, requires_regular_inspection, inspection_frequency_days) VALUES
('Park Bench', 'Seating', 10, TRUE, 90),
('Street Light', 'Lighting', 15, TRUE, 180),
('Public Toilet', 'Sanitation', 15, TRUE, 7),
('Tree', 'Vegetation', 50, TRUE, 180),
('Playground Equipment', 'Play', 7, TRUE, 30),
('Fence', 'Boundary', 15, TRUE, 180),
('Information Board', 'Signage', 5, TRUE, 180),
('Sprinkler Head', 'Irrigation', 3, TRUE, 30),
('Water Fountain', 'Water', 8, TRUE, 30),
('Trash Can', 'Waste', 3, TRUE, 7);

-- Insert into lkp_zone_type
INSERT INTO lkp_zone_type (zone_type_name, description) VALUES
('Regular Maintenance Zone', 'Standard zones for routine maintenance activities'),
('High-Profile Zone', 'Tourist areas, city centers requiring premium maintenance'),
('Ecologically Sensitive Zone', 'Areas with protected species or sensitive ecosystems'),
('Flood-Prone Zone', 'Areas requiring special drainage and flood management'),
('New Development Zone', 'Recently developed areas with establishment-phase maintenance'),
('Heritage Zone', 'Areas with historical or cultural significance');

-- Insert into lkp_land_use_type
INSERT INTO lkp_land_use_type (land_use_name, land_use_category, description) VALUES
('Residential - Low Density', 'Residential', 'Single-family homes, villas'),
('Residential - Medium Density', 'Residential', 'Apartment buildings, condominiums'),
('Residential - Mixed Use', 'Residential', 'Residential with ground floor commercial'),
('Commercial', 'Commercial', 'Shops, markets, offices'),
('Industrial', 'Industrial', 'Factories, warehouses'),
('Institutional', 'Public', 'Schools, hospitals, government offices'),
('Recreational', 'Public', 'Parks, sports fields, public gardens'),
('Religious', 'Public', 'Churches, mosques, monasteries'),
('Cemetery', 'Public', 'Burial grounds'),
('Transportation', 'Infrastructure', 'Roads, railways, airports'),
('Agricultural', 'Rural', 'Farming land'),
('Vacant', 'Undeveloped', 'Undeveloped land'),
('Water Body', 'Natural', 'Lakes, rivers, ponds'),
('Forest', 'Natural', 'Wooded areas, urban forests'),
('Mixed Use', 'Commercial/Residential', 'Combined commercial and residential');

-- Insert into lkp_ownership_type
INSERT INTO lkp_ownership_type (ownership_name, description) VALUES
('Public - Federal Government', 'Owned by federal government of Ethiopia'),
('Public - Regional Government', 'Owned by regional state government'),
('Public - Municipal', 'Owned by city/municipal government'),
('Public - Woreda', 'Owned by woreda administration'),
('Private - Individual', 'Privately owned by individual'),
('Private - Corporate', 'Owned by private company/organization'),
('Religious Institution', 'Owned by religious organization'),
('Community/Collective', 'Owned by community collectively'),
('Mixed Ownership', 'Multiple owners/shareholders'),
('Leasehold', 'Government land under long-term lease'),
('Unregistered/Informal', 'Occupied without formal registration');

-- Insert into lkp_parcel_document_type
INSERT INTO lkp_parcel_document_type (doc_type_name, description) VALUES
('Title Deed', 'Official land ownership certificate'),
('Lease Agreement', 'Contract for leased land'),
('Survey Plan', 'Cadastral survey map'),
('Tax Receipt', 'Proof of land/property tax payment'),
('Transfer Deed', 'Document of ownership transfer'),
('Court Order', 'Legal document affecting ownership'),
('Mortgage Document', 'Loan security documentation'),
('Zoning Certificate', 'Official zoning designation'),
('Environmental Impact Assessment', 'EIA approval document'),
('Building Permit', 'Construction approval');

-- Insert into lkp_fiscal_year
INSERT INTO lkp_fiscal_year (fiscal_year_name, start_date, end_date, is_current) VALUES
('2023-2024', '2023-07-01', '2024-06-30', FALSE),
('2024-2025', '2024-07-01', '2025-06-30', TRUE),
('2025-2026', '2025-07-01', '2026-06-30', FALSE);

-- Insert into lkp_plan_type
INSERT INTO lkp_plan_type (plan_type_name, description, planning_horizon_days, requires_approval) VALUES
('Annual Maintenance Plan', 'Yearly plan for routine maintenance', 365, TRUE),
('Seasonal Plan', 'Plan for specific season (dry/rainy)', 180, TRUE),
('Capital Improvement Plan', 'Major renovation or new construction', 730, TRUE),
('Emergency Response Plan', 'Plan for emergencies and incidents', 30, FALSE),
('Event-Based Plan', 'Plan for specific events', 60, TRUE),
('Vegetation Management Plan', 'Specialized plan for vegetation', 365, TRUE),
('Irrigation Management Plan', 'Water management schedule', 365, FALSE),
('Pest Control Plan', 'Integrated pest management', 180, TRUE),
('5-Year Strategic Plan', 'Long-term strategic planning', 1825, TRUE);

-- Insert into lkp_plan_status
INSERT INTO lkp_plan_status (status_name) VALUES
('Draft'),
('Submitted'),
('Approved'),
('Rejected'),
('In Progress'),
('Completed'),
('Cancelled');

-- Insert into lkp_activity_category
INSERT INTO lkp_activity_category (category_name, description, requires_special_skill) VALUES
('Vegetation Management', 'Activities related to plants and grass', FALSE),
('Irrigation Management', 'Watering system operations', TRUE),
('Infrastructure Maintenance', 'Repair of physical structures', TRUE),
('Cleaning and Sanitation', 'Litter collection and cleaning', FALSE),
('Safety and Security', 'Safety inspections and measures', TRUE),
('Special Events', 'Event setup and support', FALSE),
('Inspections', 'Regular condition assessments', TRUE),
('Renovation', 'Major improvement projects', TRUE),
('Pest Control', 'Pest management activities', TRUE),
('Soil Management', 'Fertilizing and soil treatment', TRUE);

-- Insert into lkp_frequency
INSERT INTO lkp_frequency (frequency_name, days_interval, times_per_year, description) VALUES
('Daily', 1, 365, 'Every day'),
('Weekly', 7, 52, 'Once per week'),
('Bi-Weekly', 14, 26, 'Every two weeks'),
('Monthly', 30, 12, 'Once per month'),
('Bi-Monthly', 60, 6, 'Every two months'),
('Quarterly', 90, 4, 'Every three months'),
('Semi-Annually', 180, 2, 'Twice per year'),
('Annually', 365, 1, 'Once per year'),
('As Needed', NULL, NULL, 'On-demand, no fixed schedule'),
('Seasonally - Dry Season', NULL, 1, 'Once during dry season'),
('Seasonally - Rainy Season', NULL, 1, 'Once during rainy season'),
('After Major Events', NULL, NULL, 'After storms, festivals, etc.');

-- Insert into lkp_activity_type (simplified list)
INSERT INTO lkp_activity_type (activity_name, category_id, typical_duration_hours, typical_crew_size, season_preference) VALUES
('Grass Mowing', 1, 2.0, 2, 'Rainy'),
('Tree Pruning', 1, 4.0, 3, 'Dry'),
('Irrigation System Check', 2, 1.0, 1, 'Any'),
('Bench Repair', 3, 1.5, 1, 'Dry'),
('Litter Collection', 4, 2.0, 2, 'Any'),
('Routine Safety Inspection', 7, 1.0, 1, 'Any');

-- Insert into lkp_activity_status
INSERT INTO lkp_activity_status (status_name, status_code, description, is_terminal, can_edit) VALUES
('Planned', 'PLAN', 'Activity has been planned but not yet scheduled', FALSE, TRUE),
('Scheduled', 'SCHED', 'Activity has been assigned a specific date/time', FALSE, TRUE),
('Assigned', 'ASGN', 'Activity has been assigned to personnel', FALSE, TRUE),
('In Progress', 'PROG', 'Activity is currently being executed', FALSE, FALSE),
('Completed', 'COMP', 'Activity successfully completed', TRUE, FALSE),
('Cancelled', 'CANC', 'Activity was cancelled before completion', TRUE, FALSE);

-- Insert into lkp_inspection_type
INSERT INTO lkp_inspection_type (inspection_name, description, typical_frequency_id, requires_tools) VALUES
('Routine Maintenance Inspection', 'Regular check for maintenance needs', 4, FALSE),
('Safety Inspection', 'Check for safety hazards and risks', 4, FALSE),
('Tree Health Assessment', 'Detailed tree condition assessment', 6, TRUE),
('Playground Safety Inspection', 'Comprehensive playground equipment check', 2, TRUE);

-- Insert into lkp_inspection_status
INSERT INTO lkp_inspection_status (status_name, description, allows_editing) VALUES
('Scheduled', 'Inspection has been scheduled', TRUE),
('Assigned', 'Assigned to inspector', TRUE),
('In Progress', 'Inspection is being conducted', TRUE),
('Completed', 'Inspection completed, pending review', FALSE),
('Approved', 'Inspection approved', FALSE);

-- Insert into lkp_finding_priority
INSERT INTO lkp_finding_priority (priority_name, response_time_hours, color_code, requires_immediate_action) VALUES
('Critical - Immediate', 1, '#FF0000', TRUE),
('High - 24 Hours', 24, '#FFA500', TRUE),
('Medium - 1 Week', 168, '#FFFF00', FALSE),
('Low - 1 Month', 720, '#00FF00', FALSE),
('Informational Only', NULL, '#0000FF', FALSE);

-- Insert into lkp_issue_category
INSERT INTO lkp_issue_category (category_name, description, default_priority_id) VALUES
('Safety Hazard', 'Issues that pose safety risks to public', 1),
('Vandalism', 'Deliberate damage to property', 2),
('Equipment Malfunction', 'Non-working equipment', 3),
('Vegetation Problem', 'Issues with trees, grass, plants', 3),
('Litter/Dumping', 'Illegal dumping or excessive litter', 4),
('Lighting Issue', 'Non-functioning lights', 3);

-- Insert into lkp_issue_status
INSERT INTO lkp_issue_status (status_name, description, is_closed) VALUES
('Reported', 'Issue has been reported', FALSE),
('Acknowledged', 'Issue has been acknowledged by staff', FALSE),
('Assigned', 'Assigned to responsible person/team', FALSE),
('In Progress', 'Work on issue has started', FALSE),
('Resolved', 'Issue has been resolved', TRUE),
('Closed', 'Issue closed after verification', TRUE);

-- Insert into lkp_citizen_report_type
INSERT INTO lkp_citizen_report_type (report_type_name, category, default_priority_id, estimated_response_days) VALUES
('Broken Bench', 'Infrastructure', 3, 7),
('Damaged Play Equipment', 'Safety', 2, 3),
('Overgrown Vegetation', 'Maintenance', 4, 14),
('Fallen Tree/Branch', 'Safety', 1, 1),
('Broken Light', 'Infrastructure', 3, 5),
('Trash Overflow', 'Sanitation', 4, 2);

-- Insert into lkp_citizen_report_status
INSERT INTO lkp_citizen_report_status (status_name, description, is_visible_to_public) VALUES
('Submitted', 'Report has been submitted', TRUE),
('Under Review', 'Staff is reviewing the report', TRUE),
('Acknowledged', 'Report has been acknowledged', TRUE),
('Assigned', 'Assigned to responsible team', TRUE),
('In Progress', 'Work on the issue has started', TRUE),
('Resolved', 'Issue has been resolved', TRUE),
('Closed', 'Report closed after verification', TRUE);

-- Insert into lkp_budget_category
INSERT INTO lkp_budget_category (category_name, category_code, description) VALUES
('Personnel - Salaries', 'PERS', 'Staff salaries and wages'),
('Materials - Plants', 'MATP', 'Plants, trees, seeds, flowers'),
('Equipment - Purchase', 'EQPP', 'New equipment purchase'),
('Utilities - Water', 'UTLW', 'Water bills'),
('Contract Services', 'CONTR', 'Outsourced services'),
('Capital Projects', 'CAP', 'Major construction/renovation');

-- Insert into lkp_budget_source
INSERT INTO lkp_budget_source (source_name, source_type, description) VALUES
('Municipal General Fund', 'Government', 'City general budget allocation'),
('Federal Government Grant', 'Government', 'Grant from federal government'),
('Donor - International', 'Donor', 'International aid/development funding'),
('User Fees', 'Revenue', 'Fees collected from users'),
('Sponsorships', 'Revenue', 'Corporate sponsorships');

-- Insert into lkp_job_title (THIS IS CRITICAL - NEEDED FOR WORKFORCE_USER)
INSERT INTO lkp_job_title (job_title_name, job_category, requires_certification) VALUES
('UGI Director', 'Management', FALSE),
('UGI Deputy Director', 'Management', FALSE),
('Zone Manager', 'Management', FALSE),
('Senior Supervisor', 'Supervision', FALSE),
('Field Supervisor', 'Supervision', FALSE),
('Inspector', 'Inspection', TRUE),
('Senior Gardener', 'Field Staff', TRUE),
('Gardener', 'Field Staff', FALSE),
('Irrigation Technician', 'Technical', TRUE),
('Electrician', 'Technical', TRUE),
('Carpenter', 'Technical', TRUE),
('Mason', 'Technical', TRUE),
('Equipment Operator', 'Technical', TRUE),
('Laborer', 'Field Staff', FALSE),
('Tree Surgeon/Arborist', 'Specialist', TRUE),
('Pest Control Technician', 'Specialist', TRUE),
('Cleaner', 'Field Staff', FALSE),
('Security Guard', 'Security', FALSE),
('Administrative Assistant', 'Administrative', FALSE),
('GIS Specialist', 'Technical', TRUE);

-- Insert into lkp_skill
INSERT INTO lkp_skill (skill_name, skill_category, certification_required) VALUES
('Lawn Mowing', 'Grounds Maintenance', FALSE),
('Hedge Trimming', 'Grounds Maintenance', FALSE),
('Tree Pruning', 'Arboriculture', TRUE),
('Pesticide Application', 'Pest Control', TRUE),
('Irrigation Repair', 'Irrigation', TRUE),
('Electrical Wiring', 'Electrical', TRUE),
('Plumbing', 'Plumbing', TRUE),
('Carpentry', 'Construction', FALSE),
('Welding', 'Metalwork', TRUE),
('First Aid', 'Safety', TRUE);

-- Insert into lkp_leave_type
INSERT INTO lkp_leave_type (leave_name, description, paid, days_per_year) VALUES
('Annual Leave', 'Regular vacation leave', TRUE, 20),
('Sick Leave', 'Medical leave', TRUE, 12),
('Emergency Leave', 'Family emergency', TRUE, 5),
('Maternity Leave', 'Maternity', TRUE, 90),
('Unpaid Leave', 'Leave without pay', FALSE, NULL),
('Public Holiday', 'Official holiday', TRUE, NULL);

-- =====================================================
-- 19. INSERT AUTH AND USER DATA
-- =====================================================

-- Insert into auth_user
INSERT INTO auth_user (username, password, email, is_active) VALUES
('gardener1', 'pbkdf2_sha256$dummy', 'gardener1@example.com', true),
('gardener2', 'pbkdf2_sha256$dummy', 'gardener2@example.com', true),
('supervisor', 'pbkdf2_sha256$dummy', 'supervisor@example.com', true),
('admin', 'pbkdf2_sha256$dummy', 'admin@example.com', true);

-- Insert into ugims_users
INSERT INTO ugims_users (username, password_hash, full_name, email, role)
VALUES
('admin', '$2y$10$YourHashedPasswordHere', 'Admin User', 'admin@ugims.et', 'admin'),
('inspector1', '$2y$10$YourHashedPasswordHere', 'Abebe Kebede', 'inspector@ugims.et', 'inspector'),
('field1', '$2y$10$YourHashedPasswordHere', 'Tigist Haile', 'field@ugims.et', 'field');

-- =====================================================
-- 20. INSERT WORKFORCE DATA (NOW JOB_TITLE_ID EXISTS)
-- =====================================================

-- Insert into ugims_workforce_user (job_title_id 8 = Gardener, 5 = Field Supervisor)
INSERT INTO ugims_workforce_user (
    user_id, employee_id, first_name, last_name, email, 
    job_title_id, employment_type, employment_status, hire_date, is_active
)
VALUES 
((SELECT id FROM auth_user WHERE username = 'gardener1'), 'EMP001', 'Gardener', 'One', 'gardener1@example.com', 8, 'Full-time', 'Active', '2023-01-15', true),
((SELECT id FROM auth_user WHERE username = 'gardener2'), 'EMP002', 'Gardener', 'Two', 'gardener2@example.com', 8, 'Full-time', 'Active', '2023-02-20', true),
((SELECT id FROM auth_user WHERE username = 'supervisor'), 'EMP003', 'Super', 'Visor', 'supervisor@example.com', 5, 'Full-time', 'Active', '2022-11-10', true);

-- Insert teams
INSERT INTO ugims_team (team_name, team_code, team_type, is_active) VALUES
('North Zone Team', 'NZT01', 'Maintenance', true),
('South Zone Team', 'SZT01', 'Maintenance', true);

-- =====================================================
-- 21. INSERT REMAINING DEMO DATA
-- =====================================================

-- Insert parcels
INSERT INTO ugims_parcel (parcel_number, geometry, land_use_type_id, ownership_type_id)
VALUES
('PARC-001', ST_GeomFromText('POLYGON((471500 1000500, 471700 1000500, 471700 1000300, 471500 1000300, 471500 1000500))', 20137), 7, 3),
('PARC-002', ST_GeomFromText('POLYGON((472200 1001200, 472400 1001200, 472400 1001000, 472200 1001000, 472200 1001200))', 20137), 7, 3),
('PARC-003', ST_GeomFromText('POLYGON((470800 998500, 471000 998500, 471000 998300, 470800 998300, 470800 998500))', 20137), 1, 5);

-- Insert UGI Assets
DO $$
DECLARE
    parcel1 INTEGER;
    parcel2 INTEGER;
    parcel3 INTEGER;
BEGIN
    SELECT parcel_id INTO parcel1 FROM ugims_parcel WHERE parcel_number = 'PARC-001' LIMIT 1;
    SELECT parcel_id INTO parcel2 FROM ugims_parcel WHERE parcel_number = 'PARC-002' LIMIT 1;
    SELECT parcel_id INTO parcel3 FROM ugims_parcel WHERE parcel_number = 'PARC-003' LIMIT 1;

    INSERT INTO ugims_ugi (ugi_type_id, parcel_id, name, geometry, condition_status_id, operational_status_id, has_lighting, has_irrigation, visitor_capacity, contact_person, contact_phone, contact_email, tree_count)
    VALUES
    (1, parcel1, 'Friendship Park', ST_GeomFromText('POLYGON((471550 1000450, 471650 1000450, 471650 1000350, 471550 1000350, 471550 1000450))', 20137), 2, 1, true, true, 500, 'Park Manager', '+251911111111', 'park@example.com', 120),
    (2, parcel2, 'Addis Stadium', ST_GeomFromText('POLYGON((472250 1001150, 472350 1001150, 472350 1001050, 472250 1001050, 472250 1001150))', 20137), 3, 1, true, true, 2000, 'Stadium Authority', '+251922222222', 'stadium@example.com', 45),
    (13, parcel3, 'Children''s Playground', ST_GeomFromText('POLYGON((470850 998450, 470950 998450, 470950 998350, 470850 998350, 470850 998450))', 20137), 1, 1, true, false, 150, 'Community Center', '+251933333333', 'playground@example.com', 8);
END $$;

-- Insert Citizen Reports
INSERT INTO ugims_citizen_report (report_number, reporter_name, reporter_email, report_type_id, report_description, location_point, status_id)
VALUES
('RPT-20240315-001', 'Solomon Ayele', 'solomon@email.com', 1, 'Bench broken near the main entrance', ST_SetSRID(ST_MakePoint(471600, 1000420), 20137), 1),
('RPT-20240316-002', 'Meron Tadesse', 'meron@email.com', 3, 'Grass overgrown, needs mowing', ST_SetSRID(ST_MakePoint(472300, 1001120), 20137), 2);

-- Insert Maintenance Plans
INSERT INTO ugims_management_plan (plan_name, plan_type_id, fiscal_year_id, planned_start_date, planned_end_date, total_budget_allocated, plan_status_id, goals_and_objectives)
VALUES
('Annual Park Maintenance 2024', 1, 2, '2024-07-01', '2025-06-30', 150000.00, 1, 'Routine upkeep of all parks'),
('Sport Field Renovation', 3, 2, '2024-09-01', '2024-12-31', 300000.00, 1, 'Resurface running track');

-- Insert Plan Activities
DO $$
DECLARE
    plan1 INTEGER;
    plan2 INTEGER;
    park_ugi INTEGER;
    stadium_ugi INTEGER;
BEGIN
    SELECT plan_id INTO plan1 FROM ugims_management_plan WHERE plan_name = 'Annual Park Maintenance 2024' LIMIT 1;
    SELECT plan_id INTO plan2 FROM ugims_management_plan WHERE plan_name = 'Sport Field Renovation' LIMIT 1;
    SELECT ugi_id INTO park_ugi FROM ugims_ugi WHERE name = 'Friendship Park' LIMIT 1;
    SELECT ugi_id INTO stadium_ugi FROM ugims_ugi WHERE name = 'Addis Stadium' LIMIT 1;

    INSERT INTO ugims_plan_activity (plan_id, activity_type_id, ugi_id, scheduled_start_date, scheduled_end_date, estimated_man_days, estimated_labor_cost, estimated_material_cost, activity_status_id)
    VALUES
    (plan1, 1, park_ugi, '2024-07-15', '2024-07-20', 5, 2500.00, 500.00, 1),
    (plan1, 2, park_ugi, '2024-08-01', '2024-08-05', 3, 1500.00, 300.00, 1),
    (plan2, 3, stadium_ugi, '2024-09-10', '2024-09-30', 20, 15000.00, 5000.00, 1);
END $$;

-- Insert Inspections
INSERT INTO ugims_inspection (inspection_number, inspection_type_id, ugi_id, scheduled_date, inspection_status_id, inspector_notes)
VALUES
('INS-20240320-001', 1, (SELECT ugi_id FROM ugims_ugi WHERE name = 'Friendship Park' LIMIT 1), '2024-03-20 10:00:00', 1, 'Check all benches and lights'),
('INS-20240321-002', 2, (SELECT ugi_id FROM ugims_ugi WHERE name = 'Children''s Playground' LIMIT 1), '2024-03-21 14:00:00', 1, 'Playground safety inspection');

-- Insert Inspection Findings
DO $$
DECLARE
    insp1 INTEGER;
BEGIN
    SELECT inspection_id INTO insp1 FROM ugims_inspection WHERE inspection_number = 'INS-20240320-001' LIMIT 1;
    INSERT INTO ugims_inspection_finding (inspection_id, finding_description, finding_priority_id, severity, resolved)
    VALUES
    (insp1, 'Two benches have loose screws', 3, 2, false),
    (insp1, 'One light pole not working', 2, 3, false);
END $$;

-- Insert Budgets
INSERT INTO ugims_budget (budget_name, fiscal_year_id, allocated_amount, budget_status)
VALUES
('Parks Maintenance', 2, 100000.00, 'Approved'),
('Sports Facilities', 2, 50000.00, 'Approved');

-- Insert Expenses
DO $$
DECLARE
    budget1 INTEGER;
    budget2 INTEGER;
BEGIN
    SELECT budget_id INTO budget1 FROM ugims_budget WHERE budget_name = 'Parks Maintenance' LIMIT 1;
    SELECT budget_id INTO budget2 FROM ugims_budget WHERE budget_name = 'Sports Facilities' LIMIT 1;

    INSERT INTO ugims_expense (budget_id, expense_date, description, amount, vendor_name)
    VALUES
    (budget1, '2024-07-20', 'Grass cutting materials', 1200.00, 'Green Supplies Co.'),
    (budget1, '2024-08-05', 'Pruning tools', 450.00, 'Garden World'),
    (budget2, '2024-09-15', 'Track paint', 3500.00, 'Sport Equipment Ltd');
END $$;

-- Insert import mapping templates
INSERT INTO ugims_import_mapping (mapping_name, import_type, field_mapping, created_by, is_default)
VALUES
('Default Parcel Mapping', 'parcel', '{"field1":"column1","field2":"column2"}'::jsonb, 
 (SELECT user_id FROM ugims_users WHERE username = 'admin' LIMIT 1), true),
('Default UGI Mapping', 'ugi', '{"field1":"column1","field2":"column2"}'::jsonb,
 (SELECT user_id FROM ugims_users WHERE username = 'admin' LIMIT 1), true);

-- Insert import sessions
INSERT INTO ugims_import_session (user_id, import_type, temp_dir, shapefile_name, total_records, field_mapping)
VALUES
((SELECT user_id FROM ugims_users WHERE username = 'inspector1' LIMIT 1), 'parcel', '/tmp/import_123', 'parcels.shp', 150, '{"field1":"column1"}'::jsonb),
((SELECT user_id FROM ugims_users WHERE username = 'field1' LIMIT 1), 'ugi', '/tmp/import_456', 'ugis.shp', 75, '{"field1":"column1"}'::jsonb);

-- Insert import logs
INSERT INTO ugims_import_log (import_type, filename, records_processed, records_success, records_failed, imported_by_user_id, status)
VALUES
('parcel', 'parcels_20240315.shp', 150, 145, 5, 
 (SELECT user_id FROM ugims_users WHERE username = 'inspector1' LIMIT 1), 'completed'),
('ugi', 'ugis_20240316.shp', 75, 72, 3, 
 (SELECT user_id FROM ugims_users WHERE username = 'field1' LIMIT 1), 'completed');

-- Add team memberships
DO $$
DECLARE
    north_team INTEGER;
    south_team INTEGER;
    gardener1_id INTEGER;
    gardener2_id INTEGER;
    supervisor_id INTEGER;
BEGIN
    SELECT team_id INTO north_team FROM ugims_team WHERE team_code = 'NZT01' LIMIT 1;
    SELECT team_id INTO south_team FROM ugims_team WHERE team_code = 'SZT01' LIMIT 1;
    
    SELECT id INTO gardener1_id FROM auth_user WHERE username = 'gardener1' LIMIT 1;
    SELECT id INTO gardener2_id FROM auth_user WHERE username = 'gardener2' LIMIT 1;
    SELECT id INTO supervisor_id FROM auth_user WHERE username = 'supervisor' LIMIT 1;
    
    INSERT INTO ugims_team_membership (team_id, user_id, role_in_team, assigned_date, is_active)
    VALUES
    (north_team, supervisor_id, 'Team Lead', CURRENT_DATE, true),
    (north_team, gardener1_id, 'Member', CURRENT_DATE, true),
    (south_team, gardener2_id, 'Member', CURRENT_DATE, true);
END $$;

-- Update team leads
DO $$
DECLARE
    north_team INTEGER;
    supervisor_id INTEGER;
BEGIN
    SELECT team_id INTO north_team FROM ugims_team WHERE team_code = 'NZT01' LIMIT 1;
    SELECT id INTO supervisor_id FROM auth_user WHERE username = 'supervisor' LIMIT 1;
    
    UPDATE ugims_team 
    SET team_lead_user_id = supervisor_id
    WHERE team_id = north_team;
END $$;

-- =====================================================
-- 22. INDEXES FOR PERFORMANCE
-- =====================================================

-- Spatial indexes
CREATE INDEX IF NOT EXISTS idx_ugi_geometry ON ugims_ugi USING GIST (geometry);
CREATE INDEX IF NOT EXISTS idx_ugi_centroid ON ugims_ugi USING GIST (centroid);
CREATE INDEX IF NOT EXISTS idx_parcel_geometry ON ugims_parcel USING GIST (geometry);
CREATE INDEX IF NOT EXISTS idx_citizen_report_location ON ugims_citizen_report USING GIST (location_point);
CREATE INDEX IF NOT EXISTS idx_inspection_path ON ugims_inspection USING GIST (inspection_path);
CREATE INDEX IF NOT EXISTS idx_activity_tracking ON ugims_activity_execution USING GIST (tracking_path);
CREATE INDEX IF NOT EXISTS idx_work_area ON ugims_plan_activity USING GIST (target_area);

-- B-tree indexes
CREATE INDEX IF NOT EXISTS idx_ugi_Woreda ON ugims_ugi(Woreda_id);
CREATE INDEX IF NOT EXISTS idx_ugi_zone ON ugims_ugi(maintenance_zone_id);
CREATE INDEX IF NOT EXISTS idx_ugi_type ON ugims_ugi(ugi_type_id);
CREATE INDEX IF NOT EXISTS idx_ugi_condition ON ugims_ugi(condition_status_id);
CREATE INDEX IF NOT EXISTS idx_parcel_Woreda ON ugims_parcel(Woreda_id);
CREATE INDEX IF NOT EXISTS idx_parcel_owner ON ugims_parcel(owner_name);

CREATE INDEX IF NOT EXISTS idx_activity_execution_ugi ON ugims_activity_execution(ugi_id);
CREATE INDEX IF NOT EXISTS idx_activity_execution_dates ON ugims_activity_execution(actual_start_datetime);
CREATE INDEX IF NOT EXISTS idx_activity_execution_status ON ugims_activity_execution(completion_status_id);

CREATE INDEX IF NOT EXISTS idx_inspection_ugi ON ugims_inspection(ugi_id);
CREATE INDEX IF NOT EXISTS idx_inspection_dates ON ugims_inspection(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_inspection_status ON ugims_inspection(inspection_status_id);

CREATE INDEX IF NOT EXISTS idx_issue_ugi ON ugims_issue(ugi_id);
CREATE INDEX IF NOT EXISTS idx_issue_status ON ugims_issue(status_id);
CREATE INDEX IF NOT EXISTS idx_issue_priority ON ugims_issue(priority_id);

CREATE INDEX IF NOT EXISTS idx_citizen_report_status ON ugims_citizen_report(status_id);
CREATE INDEX IF NOT EXISTS idx_citizen_report_date ON ugims_citizen_report(created_date);

-- =====================================================
-- END OF SCHEMA
-- =====================================================