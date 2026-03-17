-- =====================================================
-- URBAN GREEN INFRASTRUCTURE MANAGEMENT SYSTEM (UGIMS)
-- Complete Database Schema
-- PostgreSQL with PostGIS
-- 
-- NOTE: This script creates a minimal auth_user table as a placeholder.
--       If using with Django, you may drop this table after Django's
--       migrations create the real auth_user, and then re-add foreign keys.
-- =====================================================

-- Enable PostGIS (must be installed)
CREATE EXTENSION IF NOT EXISTS postgis;

-- =====================================================
-- 0. AUTH_USER PLACEHOLDER (for standalone execution)
-- =====================================================
CREATE TABLE auth_user (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

-- Insert a default admin user (optional)
INSERT INTO auth_user (id, username, password, email, is_superuser, is_staff)
VALUES (gen_random_uuid(), 'admin', 'pbkdf2_sha256$dummy', 'admin@example.com', TRUE, TRUE);

-- =====================================================
-- 1. LOCATION HIERARCHY LOOKUP TABLES (lkq_*)
-- =====================================================

CREATE TABLE lkq_region (
    region_id INTEGER PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL,
    region_code VARCHAR(10) UNIQUE,
    geometry GEOMETRY(MultiPolygon, 20137)
);

INSERT INTO lkq_region (region_id, region_name, region_code) VALUES
(1, 'Addis Ababa', 'AA'),
(2, 'Sidama', 'SD'),
(3, 'Oromia', 'OR'),
(4, 'Amhara', 'AM'),
(5, 'Tigray', 'TG'),
(6, 'Southern Nations Nationalities and Peoples', 'SNNP');

CREATE TABLE lkq_city (
    city_id INTEGER PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    region_id INTEGER REFERENCES lkq_region(region_id),
    municipality_code VARCHAR(20),
    geometry GEOMETRY(MultiPolygon, 20137)
);

INSERT INTO lkq_city (city_id, city_name, region_id) VALUES
(1, 'Addis Ababa', 1),
(2, 'Hawassa', 2),
(3, 'Adama', 3),
(4, 'Bahir Dar', 4),
(5, 'Mekelle', 5);

CREATE TABLE lkq_subcity (
    subcity_id INTEGER PRIMARY KEY,
    subcity_name VARCHAR(100) NOT NULL,
    city_id INTEGER REFERENCES lkq_city(city_id),
    administrative_code VARCHAR(20),
    geometry GEOMETRY(MultiPolygon, 20137)
);

INSERT INTO lkq_subcity (subcity_id, subcity_name, city_id) VALUES
-- Addis Ababa sub-cities
(101, 'Addis Ketema', 1),
(102, 'Akaki Kaliti', 1),
(103, 'Arada', 1),
(104, 'Bole', 1),
(105, 'Gulele', 1),
(106, 'Kirkos', 1),
(107, 'Kolfe Keranio', 1),
(108, 'Lideta', 1),
(109, 'Nifas Silk-Lafto', 1),
(110, 'Yeka', 1),
-- Hawassa sub-cities
(201, 'Hawassa Tula', 2),
(202, 'Hawassa Tabore', 2),
(203, 'Hawassa Mehal', 2),
(204, 'Hawassa Hayk Dar', 2),
(205, 'Hawassa Adare', 2);

CREATE TABLE lkq_Woreda (
    Woreda_id INTEGER PRIMARY KEY,
    Woreda_name VARCHAR(100) NOT NULL,
    Woreda_number VARCHAR(20),
    subcity_id INTEGER REFERENCES lkq_subcity(subcity_id),
    geometry GEOMETRY(MultiPolygon, 20137)
);

CREATE TABLE lkq_kebele (
    kebele_id INTEGER PRIMARY KEY,
    kebele_number VARCHAR(20) NOT NULL,
    kebele_name VARCHAR(100),
    Woreda_id INTEGER REFERENCES lkq_Woreda(Woreda_id),
    geometry GEOMETRY(MultiPolygon, 20137)
);

-- =====================================================
-- 2. STATUS AND CONDITION LOOKUP TABLES
-- =====================================================

CREATE TABLE lkp_condition_status (
    status_id INTEGER PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    status_code VARCHAR(10) UNIQUE,
    description TEXT,
    color_code VARCHAR(7),
    requires_immediate_action BOOLEAN DEFAULT FALSE,
    maintenance_priority INTEGER
);

INSERT INTO lkp_condition_status (status_id, status_name, status_code, description, color_code, requires_immediate_action, maintenance_priority) VALUES
(1, 'Excellent', 'EXC', 'New or like-new condition, no maintenance needed', '#00FF00', FALSE, 5),
(2, 'Good', 'GOOD', 'Minor wear only, routine maintenance sufficient', '#90EE90', FALSE, 4),
(3, 'Fair', 'FAIR', 'Some deterioration, planned maintenance needed', '#FFFF00', FALSE, 3),
(4, 'Poor', 'POOR', 'Significant deterioration, repair needed soon', '#FFA500', FALSE, 2),
(5, 'Critical', 'CRIT', 'Unsafe or non-functional, immediate action required', '#FF0000', TRUE, 1),
(6, 'Under Repair', 'REPR', 'Currently undergoing repair/maintenance', '#0000FF', FALSE, NULL),
(7, 'Not Applicable', 'NA', 'Condition assessment not applicable', '#808080', FALSE, NULL),
(8, 'Not Inspected', 'NINS', 'Has not been inspected recently', '#C0C0C0', FALSE, NULL);

CREATE TABLE lkp_operational_status (
    status_id INTEGER PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    status_code VARCHAR(10) UNIQUE,
    description TEXT,
    is_accessible_to_public BOOLEAN DEFAULT TRUE
);

INSERT INTO lkp_operational_status (status_id, status_name, status_code, description, is_accessible_to_public) VALUES
(1, 'Open - Fully Operational', 'OPEN', 'Fully open and functioning normally', TRUE),
(2, 'Open - Limited Access', 'LIMIT', 'Open but with some areas restricted', TRUE),
(3, 'Open - Reduced Hours', 'REDHR', 'Open with reduced operating hours', TRUE),
(4, 'Temporarily Closed', 'TCLOS', 'Temporarily closed for maintenance or events', FALSE),
(5, 'Closed - Seasonal', 'SEAS', 'Closed for the season', FALSE),
(6, 'Closed - Under Construction', 'CONST', 'Closed for construction/renovation', FALSE),
(7, 'Permanently Closed', 'PCLOS', 'Permanently closed/decommissioned', FALSE),
(8, 'Under Maintenance', 'MAINT', 'Currently undergoing maintenance', FALSE),
(9, 'Emergency Closure', 'EMERG', 'Closed due to emergency/safety issue', FALSE);

CREATE TABLE lkp_ugi_lifecycle_status (
    lifecycle_id INTEGER PRIMARY KEY,
    lifecycle_name VARCHAR(50) NOT NULL,
    description TEXT,
    next_stage_id INTEGER,
    typical_duration_days INTEGER
);

INSERT INTO lkp_ugi_lifecycle_status (lifecycle_id, lifecycle_name, description, typical_duration_days) VALUES
(1, 'Planned', 'UGI has been planned but not yet established', NULL),
(2, 'Under Construction', 'Currently being developed/constructed', 180),
(3, 'Newly Established', 'Recently completed, in establishment phase', 365),
(4, 'Operational', 'Fully operational and mature', NULL),
(5, 'Under Renovation', 'Undergoing major renovation', 90),
(6, 'Decommissioned', 'No longer in use as UGI', NULL),
(7, 'Transferred', 'Ownership/management transferred', NULL);

CREATE TABLE lkp_accessibility_type (
    access_id INTEGER PRIMARY KEY,
    access_name VARCHAR(50) NOT NULL,
    description TEXT,
    requires_permit BOOLEAN DEFAULT FALSE,
    requires_fee BOOLEAN DEFAULT FALSE
);

INSERT INTO lkp_accessibility_type (access_id, access_name, description, requires_permit, requires_fee) VALUES
(1, 'Public - Free Access', 'Open to all without any restrictions', FALSE, FALSE),
(2, 'Public - Timed Access', 'Open to public during specific hours', FALSE, FALSE),
(3, 'Public - Fee Required', 'Open to public with entrance fee', FALSE, TRUE),
(4, 'Restricted - Permit Required', 'Access requires special permit', TRUE, FALSE),
(5, 'Restricted - Members Only', 'Only accessible to members', TRUE, TRUE),
(6, 'Private', 'Private property, no public access', TRUE, FALSE),
(7, 'Institutional', 'Access limited to institution members', TRUE, FALSE);

-- =====================================================
-- 3. UGI TYPES (Ethiopian context)
-- =====================================================

CREATE TABLE lkp_ethiopia_ugi_type (
    ugi_type_id INTEGER PRIMARY KEY,
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

INSERT INTO lkp_ethiopia_ugi_type (ugi_type_id, type_name, type_category, amharic_name, description, minimum_area_sq_m, requires_fencing, requires_lighting, requires_irrigation) VALUES
(1, 'Urban Park', 'Recreational', 'የከተማ መናፈሻ', 'Public park with recreational facilities, seating, and landscaping', 1000, TRUE, TRUE, TRUE),
(2, 'Sport Field', 'Recreational', 'የስፖርት ሜዳ', 'Designated area for athletic activities including football, athletics', 5000, TRUE, TRUE, TRUE),
(3, 'Cemetery', 'Cultural/Religious', 'የመቃብር ስፍራ', 'Burial grounds with vegetation and pathways', 2000, TRUE, FALSE, FALSE),
(4, 'Open Green Space', 'Recreational', 'ክፍት አረንጓዴ ቦታ', 'Unstructured grass and vegetation for recreation', 500, FALSE, FALSE, FALSE),
(5, 'Roadside Green Area', 'Transportation', 'የመንገድ ዳር አረንጓዴ', 'Vegetation along roads and highways', 100, FALSE, FALSE, TRUE),
(6, 'Road Divide/Median', 'Transportation', 'የመንገድ መከፋፈያ', 'Vegetated central reservations', 50, FALSE, FALSE, TRUE),
(7, 'Roundabout', 'Transportation', 'ክብ መንገድ', 'Circular intersection with central greenery', 200, FALSE, TRUE, TRUE),
(8, 'Urban Forest', 'Natural', 'የከተማ ደን', 'Dense vegetation area with trees and shrubs', 5000, FALSE, FALSE, FALSE),
(9, 'River/Riverside Green', 'Natural', 'የወንዝ ዳር አረንጓዴ', 'Riparian vegetation along water bodies', 1000, FALSE, FALSE, FALSE),
(10, 'Public Square/Plaza', 'Recreational', 'የህዝብ አደባባይ', 'Urban spaces with hardscape and greenery', 500, FALSE, TRUE, TRUE),
(11, 'Community Garden', 'Agricultural', 'የማህበረሰብ አትክልት ስፍራ', 'Cultivated lands for community agriculture', 200, TRUE, FALSE, TRUE),
(12, 'Botanical Garden', 'Educational', 'የእፅዋት አትክልት ስፍራ', 'Scientific collection of plants for research and education', 2000, TRUE, TRUE, TRUE),
(13, 'Children''s Playground', 'Recreational', 'የህጻናት መጫወቻ', 'Area specifically designed for children with play equipment', 300, TRUE, TRUE, TRUE),
(14, 'Green Buffer Zone', 'Environmental', 'አረንጓዴ መከላከያ ቀጠና', 'Vegetated area separating different land uses', 500, FALSE, FALSE, FALSE),
(15, 'Institutional Grounds', 'Institutional', 'የተቋማት ግቢ', 'Green areas within schools, hospitals, government compounds', 300, TRUE, TRUE, TRUE);

-- =====================================================
-- 4. COMPONENT TYPES
-- =====================================================

CREATE TABLE lkp_component_type (
    component_type_id INTEGER PRIMARY KEY,
    component_name VARCHAR(100) NOT NULL,
    component_category VARCHAR(50),
    typical_lifespan_years INTEGER,
    requires_regular_inspection BOOLEAN DEFAULT TRUE,
    inspection_frequency_days INTEGER
);

INSERT INTO lkp_component_type (component_type_id, component_name, component_category, typical_lifespan_years, requires_regular_inspection, inspection_frequency_days) VALUES
-- Seating and Rest
(101, 'Park Bench', 'Seating', 10, TRUE, 90),
(102, 'Picnic Table', 'Seating', 8, TRUE, 90),
(103, 'Public Chair', 'Seating', 7, TRUE, 180),
(104, 'Lounge Seat', 'Seating', 5, TRUE, 180),
-- Play Equipment
(201, 'Children''s Swing', 'Play', 5, TRUE, 30),
(202, 'Slide', 'Play', 7, TRUE, 30),
(203, 'See-saw', 'Play', 7, TRUE, 30),
(204, 'Climbing Frame', 'Play', 5, TRUE, 30),
(205, 'Playhouse', 'Play', 5, TRUE, 60),
(206, 'Sandpit', 'Play', 3, TRUE, 7),
(207, 'Roundabout', 'Play', 7, TRUE, 30),
(208, 'Exercise Equipment', 'Fitness', 5, TRUE, 30),
-- Lighting
(301, 'Street Light', 'Lighting', 15, TRUE, 180),
(302, 'Park Light', 'Lighting', 10, TRUE, 180),
(303, 'Decorative Light', 'Lighting', 8, TRUE, 180),
(304, 'Flood Light', 'Lighting', 10, TRUE, 180),
(305, 'Solar Light', 'Lighting', 5, TRUE, 90),
-- Sanitation
(401, 'Public Toilet', 'Sanitation', 15, TRUE, 7),
(402, 'Drinking Fountain', 'Water', 8, TRUE, 30),
(403, 'Trash Can', 'Waste', 3, TRUE, 7),
(404, 'Recycling Bin', 'Waste', 5, TRUE, 7),
(405, 'Hand Washing Station', 'Sanitation', 5, TRUE, 7),
-- Fencing and Boundaries
(501, 'Metal Fence', 'Boundary', 15, TRUE, 180),
(502, 'Wooden Fence', 'Boundary', 5, TRUE, 90),
(503, 'Hedge', 'Boundary', 10, TRUE, 30),
(504, 'Gate', 'Access', 15, TRUE, 90),
(505, 'Bollard', 'Traffic', 10, TRUE, 180),
-- Pathways and Surfaces
(601, 'Paved Path', 'Surface', 20, TRUE, 180),
(602, 'Gravel Path', 'Surface', 5, TRUE, 90),
(603, 'Grass Surface', 'Surface', 3, TRUE, 7),
(604, 'Artificial Turf', 'Surface', 8, TRUE, 30),
(605, 'Rubber Safety Surface', 'Play Surface', 5, TRUE, 30),
-- Signage
(701, 'Information Board', 'Signage', 5, TRUE, 180),
(702, 'Directional Sign', 'Signage', 5, TRUE, 180),
(703, 'Warning Sign', 'Safety', 5, TRUE, 90),
(704, 'Park Name Sign', 'Identification', 7, TRUE, 180),
-- Irrigation
(801, 'Sprinkler Head', 'Irrigation', 3, TRUE, 30),
(802, 'Drip Line', 'Irrigation', 2, TRUE, 30),
(803, 'Irrigation Controller', 'Irrigation', 5, TRUE, 90),
(804, 'Water Valve', 'Irrigation', 5, TRUE, 90),
(805, 'Water Tank', 'Storage', 10, TRUE, 180),
-- Vegetation Features
(901, 'Tree', 'Vegetation', 50, TRUE, 180),
(902, 'Shrub Bed', 'Vegetation', 10, TRUE, 30),
(903, 'Flower Bed', 'Vegetation', 1, TRUE, 7),
(904, 'Lawn Area', 'Vegetation', 10, TRUE, 7),
(905, 'Hedge Row', 'Vegetation', 15, TRUE, 30),
-- Sports Facilities
(1001, 'Football Goal', 'Sports', 5, TRUE, 30),
(1002, 'Basketball Hoop', 'Sports', 5, TRUE, 30),
(1003, 'Tennis Net', 'Sports', 2, TRUE, 7),
(1004, 'Running Track', 'Sports', 10, TRUE, 90),
(1005, 'Bleachers/Seating', 'Sports', 15, TRUE, 180),
-- Art and Decor
(1101, 'Statue/Sculpture', 'Art', 50, TRUE, 180),
(1102, 'Fountain', 'Water Feature', 20, TRUE, 30),
(1103, 'Pond', 'Water Feature', 20, TRUE, 30),
(1104, 'Gazebo', 'Structure', 20, TRUE, 180),
(1105, 'Pergola', 'Structure', 15, TRUE, 180),
-- Infrastructure
(1201, 'Electrical Outlet', 'Utility', 10, TRUE, 180),
(1202, 'Water Tap', 'Utility', 5, TRUE, 30),
(1203, 'Drainage Grate', 'Drainage', 5, TRUE, 90),
(1204, 'CCTV Camera', 'Security', 5, TRUE, 90),
(1205, 'WiFi Access Point', 'Technology', 3, TRUE, 180);

-- =====================================================
-- 5. ZONE AND MAINTENANCE AREA TABLES
-- =====================================================

CREATE TABLE lkp_zone_type (
    zone_type_id INTEGER PRIMARY KEY,
    zone_type_name VARCHAR(50) NOT NULL,
    description TEXT
);

INSERT INTO lkp_zone_type (zone_type_id, zone_type_name, description) VALUES
(1, 'Regular Maintenance Zone', 'Standard zones for routine maintenance activities'),
(2, 'High-Profile Zone', 'Tourist areas, city centers requiring premium maintenance'),
(3, 'Ecologically Sensitive Zone', 'Areas with protected species or sensitive ecosystems'),
(4, 'Flood-Prone Zone', 'Areas requiring special drainage and flood management'),
(5, 'New Development Zone', 'Recently developed areas with establishment-phase maintenance'),
(6, 'Heritage Zone', 'Areas with historical or cultural significance');

CREATE TABLE ugims_maintenance_zone (
    zone_id INTEGER PRIMARY KEY,
    zone_name VARCHAR(100) NOT NULL,
    zone_code VARCHAR(20) UNIQUE,
    zone_manager_user_id UUID,  -- References auth_user later
    subcity_id INTEGER REFERENCES lkq_subcity(subcity_id),
    geometry GEOMETRY(MultiPolygon, 20137),
    area_sq_m DECIMAL(12,2),
    priority_level INTEGER DEFAULT 3,
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

-- =====================================================
-- 6. PARCEL MANAGEMENT
-- =====================================================

CREATE TABLE lkp_land_use_type (
    land_use_id INTEGER PRIMARY KEY,
    land_use_name VARCHAR(100) NOT NULL,
    land_use_category VARCHAR(50),
    description TEXT
);

INSERT INTO lkp_land_use_type (land_use_id, land_use_name, land_use_category, description) VALUES
(1, 'Residential - Low Density', 'Residential', 'Single-family homes, villas'),
(2, 'Residential - Medium Density', 'Residential', 'Apartment buildings, condominiums'),
(3, 'Residential - Mixed Use', 'Residential', 'Residential with ground floor commercial'),
(4, 'Commercial', 'Commercial', 'Shops, markets, offices'),
(5, 'Industrial', 'Industrial', 'Factories, warehouses'),
(6, 'Institutional', 'Public', 'Schools, hospitals, government offices'),
(7, 'Recreational', 'Public', 'Parks, sports fields, public gardens'),
(8, 'Religious', 'Public', 'Churches, mosques, monasteries'),
(9, 'Cemetery', 'Public', 'Burial grounds'),
(10, 'Transportation', 'Infrastructure', 'Roads, railways, airports'),
(11, 'Agricultural', 'Rural', 'Farming land'),
(12, 'Vacant', 'Undeveloped', 'Undeveloped land'),
(13, 'Water Body', 'Natural', 'Lakes, rivers, ponds'),
(14, 'Forest', 'Natural', 'Wooded areas, urban forests'),
(15, 'Mixed Use', 'Commercial/Residential', 'Combined commercial and residential');

CREATE TABLE lkp_ownership_type (
    ownership_id INTEGER PRIMARY KEY,
    ownership_name VARCHAR(100) NOT NULL,
    description TEXT
);

INSERT INTO lkp_ownership_type (ownership_id, ownership_name, description) VALUES
(1, 'Public - Federal Government', 'Owned by federal government of Ethiopia'),
(2, 'Public - Regional Government', 'Owned by regional state government'),
(3, 'Public - Municipal', 'Owned by city/municipal government'),
(4, 'Public - Woreda', 'Owned by woreda administration'),
(5, 'Private - Individual', 'Privately owned by individual'),
(6, 'Private - Corporate', 'Owned by private company/organization'),
(7, 'Religious Institution', 'Owned by religious organization'),
(8, 'Community/Collective', 'Owned by community collectively'),
(9, 'Mixed Ownership', 'Multiple owners/shareholders'),
(10, 'Leasehold', 'Government land under long-term lease'),
(11, 'Unregistered/Informal', 'Occupied without formal registration');

CREATE TABLE lkp_parcel_document_type (
    doc_type_id INTEGER PRIMARY KEY,
    doc_type_name VARCHAR(100) NOT NULL,
    description TEXT
);

INSERT INTO lkp_parcel_document_type (doc_type_id, doc_type_name, description) VALUES
(1, 'Title Deed', 'Official land ownership certificate'),
(2, 'Lease Agreement', 'Contract for leased land'),
(3, 'Survey Plan', 'Cadastral survey map'),
(4, 'Tax Receipt', 'Proof of land/property tax payment'),
(5, 'Transfer Deed', 'Document of ownership transfer'),
(6, 'Court Order', 'Legal document affecting ownership'),
(7, 'Mortgage Document', 'Loan security documentation'),
(8, 'Zoning Certificate', 'Official zoning designation'),
(9, 'Environmental Impact Assessment', 'EIA approval document'),
(10, 'Building Permit', 'Construction approval');

CREATE TABLE ugims_parcel (
    parcel_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    updated_by_user_id UUID REFERENCES auth_user(id),
    status_id INTEGER,  -- Reference to status lookup
    spatial_accuracy VARCHAR(50),
    survey_date DATE,
    survey_method VARCHAR(100)
);

CREATE TABLE ugims_parcel_document (
    document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parcel_id UUID REFERENCES ugims_parcel(parcel_id) ON DELETE CASCADE,
    document_type_id INTEGER REFERENCES lkp_parcel_document_type(doc_type_id),
    document_title VARCHAR(255),
    document_number VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    issuing_authority VARCHAR(255),
    file_url TEXT,
    uploaded_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    uploaded_by_user_id UUID REFERENCES auth_user(id),
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by_user_id UUID REFERENCES auth_user(id),
    verification_date DATE
);

CREATE TABLE ugims_parcel_history (
    history_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parcel_id UUID REFERENCES ugims_parcel(parcel_id),
    change_type VARCHAR(50),
    old_geometry GEOMETRY(MultiPolygon, 20137),
    new_geometry GEOMETRY(MultiPolygon, 20137),
    old_owner VARCHAR(255),
    new_owner VARCHAR(255),
    change_reason TEXT,
    changed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by_user_id UUID REFERENCES auth_user(id),
    approved_by_user_id UUID REFERENCES auth_user(id),
    approval_date TIMESTAMP,
    status VARCHAR(50)
);

-- =====================================================
-- 7. UGI ASSETS
-- =====================================================

CREATE TABLE ugims_ugi (
    ugi_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ugi_type_id INTEGER NOT NULL REFERENCES lkp_ethiopia_ugi_type(ugi_type_id),
    parcel_id UUID NOT NULL REFERENCES ugims_parcel(parcel_id),
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
    operating_hours_id INTEGER,  -- Placeholder for future table
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
    created_by_user_id UUID REFERENCES auth_user(id),
    updated_by_user_id UUID REFERENCES auth_user(id),
    CONSTRAINT ugi_geometry_valid CHECK (ST_IsValid(geometry))
);

CREATE TABLE ugims_ugi_component (
    component_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ugi_id UUID NOT NULL REFERENCES ugims_ugi(ugi_id) ON DELETE CASCADE,
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
    created_by_user_id UUID REFERENCES auth_user(id),
    updated_by_user_id UUID REFERENCES auth_user(id)
);

-- =====================================================
-- 8. PLANNING AND ACTIVITY MANAGEMENT
-- =====================================================

CREATE TABLE lkp_fiscal_year (
    fiscal_year_id INTEGER PRIMARY KEY,
    fiscal_year_name VARCHAR(9) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    description TEXT
);

INSERT INTO lkp_fiscal_year (fiscal_year_id, fiscal_year_name, start_date, end_date, is_current) VALUES
(1, '2023-2024', '2023-07-01', '2024-06-30', FALSE),
(2, '2024-2025', '2024-07-01', '2025-06-30', TRUE),
(3, '2025-2026', '2025-07-01', '2026-06-30', FALSE),
(4, '2026-2027', '2026-07-01', '2027-06-30', FALSE);

CREATE TABLE lkp_plan_type (
    plan_type_id INTEGER PRIMARY KEY,
    plan_type_name VARCHAR(50) NOT NULL,
    description TEXT,
    planning_horizon_days INTEGER,
    requires_approval BOOLEAN DEFAULT TRUE
);

INSERT INTO lkp_plan_type (plan_type_id, plan_type_name, description, planning_horizon_days, requires_approval) VALUES
(1, 'Annual Maintenance Plan', 'Yearly plan for routine maintenance', 365, TRUE),
(2, 'Seasonal Plan', 'Plan for specific season (dry/rainy)', 180, TRUE),
(3, 'Capital Improvement Plan', 'Major renovation or new construction', 730, TRUE),
(4, 'Emergency Response Plan', 'Plan for emergencies and incidents', 30, FALSE),
(5, 'Event-Based Plan', 'Plan for specific events', 60, TRUE),
(6, 'Vegetation Management Plan', 'Specialized plan for vegetation', 365, TRUE),
(7, 'Irrigation Management Plan', 'Water management schedule', 365, FALSE),
(8, 'Pest Control Plan', 'Integrated pest management', 180, TRUE),
(9, '5-Year Strategic Plan', 'Long-term strategic planning', 1825, TRUE);

CREATE TABLE lkp_activity_category (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    requires_special_skill BOOLEAN DEFAULT FALSE
);

INSERT INTO lkp_activity_category (category_id, category_name, description, requires_special_skill) VALUES
(1, 'Vegetation Management', 'Activities related to plants and grass', FALSE),
(2, 'Irrigation Management', 'Watering system operations', TRUE),
(3, 'Infrastructure Maintenance', 'Repair of physical structures', TRUE),
(4, 'Cleaning and Sanitation', 'Litter collection and cleaning', FALSE),
(5, 'Safety and Security', 'Safety inspections and measures', TRUE),
(6, 'Special Events', 'Event setup and support', FALSE),
(7, 'Inspections', 'Regular condition assessments', TRUE),
(8, 'Renovation', 'Major improvement projects', TRUE),
(9, 'Pest Control', 'Pest management activities', TRUE),
(10, 'Soil Management', 'Fertilizing and soil treatment', TRUE);

CREATE TABLE lkp_frequency (
    frequency_id INTEGER PRIMARY KEY,
    frequency_name VARCHAR(50) NOT NULL,
    days_interval INTEGER,
    times_per_year DECIMAL(5,2),
    description TEXT
);

INSERT INTO lkp_frequency (frequency_id, frequency_name, days_interval, times_per_year, description) VALUES
(1, 'Daily', 1, 365, 'Every day'),
(2, 'Weekly', 7, 52, 'Once per week'),
(3, 'Bi-Weekly', 14, 26, 'Every two weeks'),
(4, 'Monthly', 30, 12, 'Once per month'),
(5, 'Bi-Monthly', 60, 6, 'Every two months'),
(6, 'Quarterly', 90, 4, 'Every three months'),
(7, 'Semi-Annually', 180, 2, 'Twice per year'),
(8, 'Annually', 365, 1, 'Once per year'),
(9, 'As Needed', NULL, NULL, 'On-demand, no fixed schedule'),
(10, 'Seasonally - Dry Season', NULL, 1, 'Once during dry season'),
(11, 'Seasonally - Rainy Season', NULL, 1, 'Once during rainy season'),
(12, 'After Major Events', NULL, NULL, 'After storms, festivals, etc.');

CREATE TABLE lkp_activity_type (
    activity_type_id INTEGER PRIMARY KEY,
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

INSERT INTO lkp_activity_type (activity_type_id, activity_name, activity_name_amharic, category_id, typical_duration_hours, typical_crew_size, season_preference) VALUES
-- Vegetation Management
(101, 'Grass Mowing', 'ሳር ማጨድ', 1, 2.0, 2, 'Rainy'),
(102, 'Grass Trimming (Edges)', 'የሳር ዳር መከርከም', 1, 1.5, 1, 'Rainy'),
(103, 'Hedge Trimming', 'አጥር መቁረጥ', 1, 3.0, 2, 'Dry'),
(104, 'Tree Pruning', 'ዛፍ መቀርዘም', 1, 4.0, 3, 'Dry'),
(105, 'Tree Planting', 'ዛፍ መትከል', 1, 1.0, 2, 'Rainy'),
(106, 'Shrub Planting', 'ቁጥቋጦ መትከል', 1, 0.5, 2, 'Rainy'),
(107, 'Flower Bed Planting', 'የአበባ አግዳሚ መትከል', 1, 2.0, 2, 'Rainy'),
(108, 'Weeding', 'አረም ማረም', 1, 2.0, 2, 'Rainy'),
(109, 'Leaf Blowing/Clearing', 'ቅጠል ማጽዳት', 1, 1.0, 1, 'Dry'),
(110, 'Mulching', 'ሙልች መዘርጋት', 1, 2.0, 2, 'Dry'),
(111, 'Fertilizer Application', 'ማዳበሪያ መርጨት', 10, 1.5, 2, 'Rainy'),
(112, 'Composting', 'ኮምፖስት ማዘጋጀት', 10, 3.0, 2, 'Any'),
-- Irrigation
(201, 'Irrigation System Check', 'የውሃ ማስተላለፊያ ሥርዓት ምርመራ', 2, 1.0, 1, 'Any'),
(202, 'Sprinkler Repair', 'ስፕሪንክለር መጠገን', 2, 2.0, 1, 'Dry'),
(203, 'Drip Line Cleaning', 'ድሪፕ መስመር ማጽዳት', 2, 2.0, 1, 'Dry'),
(204, 'Valve Maintenance', 'ቫልቭ ጥገና', 2, 1.0, 1, 'Any'),
(205, 'Controller Programming', 'ኮንትሮለር ፕሮግራም ማድረግ', 2, 0.5, 1, 'Any'),
(206, 'Hand Watering', 'በእጅ ማጠጣት', 2, 2.0, 1, 'Dry'),
-- Infrastructure Maintenance
(301, 'Bench Repair', 'ቤንች መጠገን', 3, 1.5, 1, 'Dry'),
(302, 'Fence Repair', 'አጥር መጠገን', 3, 3.0, 2, 'Dry'),
(303, 'Gate Maintenance', 'በር ጥገና', 3, 2.0, 1, 'Dry'),
(304, 'Pathway Patching', 'የእግረኛ መንገድ ጥገና', 3, 4.0, 2, 'Dry'),
(305, 'Playground Equipment Check', 'የመጫወቻ ቦታ መሳሪያዎች ምርመራ', 3, 1.0, 1, 'Any'),
(306, 'Light Bulb Replacement', 'አምፑል መቀየር', 3, 0.5, 1, 'Any'),
(307, 'Signage Repair', 'ምልክት ማስተካከል', 3, 1.0, 1, 'Dry'),
(308, 'Painting', 'ቀለም መቀባት', 3, 3.0, 2, 'Dry'),
-- Cleaning
(401, 'Litter Collection', 'ቆሻሻ መሰብሰብ', 4, 2.0, 2, 'Any'),
(402, 'Trash Can Emptying', 'የቆሻሻ መጣያ ባዶ ማድረግ', 4, 0.5, 1, 'Any'),
(403, 'Graffiti Removal', 'ግራፊቲ ማስወገድ', 4, 1.0, 1, 'Any'),
(404, 'Pressure Washing', 'ግፊት ማጠቢያ', 4, 2.0, 1, 'Dry'),
(405, 'Public Toilet Cleaning', 'የሕዝብ መጸዳጃ ቤት ማጽዳት', 4, 1.0, 1, 'Any'),
-- Inspections
(501, 'Routine Safety Inspection', 'መደበኛ የደህንነት ምርመራ', 7, 1.0, 1, 'Any'),
(502, 'Tree Health Assessment', 'የዛፍ ጤና ምዘና', 7, 1.5, 1, 'Dry'),
(503, 'Comprehensive Condition Assessment', 'አጠቃላይ ሁኔታ ምዘና', 7, 4.0, 2, 'Dry'),
(504, 'Irrigation System Audit', 'የውሃ ሥርዓት ኦዲት', 7, 2.0, 1, 'Dry'),
-- Special
(601, 'Event Setup', 'ዝግጅት ማዘጋጀት', 6, 4.0, 3, 'Any'),
(602, 'Event Cleanup', 'የዝግጅት ማጽዳት', 6, 3.0, 3, 'Any'),
(603, 'Emergency Storm Cleanup', 'የአውሎ ነፋስ ንጽህና', 5, 8.0, 4, 'Any');

CREATE TABLE lkp_activity_status (
    status_id INTEGER PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    status_code VARCHAR(10) UNIQUE,
    description TEXT,
    is_terminal BOOLEAN DEFAULT FALSE,
    can_edit BOOLEAN DEFAULT TRUE
);

INSERT INTO lkp_activity_status (status_id, status_name, status_code, description, is_terminal, can_edit) VALUES
(1, 'Planned', 'PLAN', 'Activity has been planned but not yet scheduled', FALSE, TRUE),
(2, 'Scheduled', 'SCHED', 'Activity has been assigned a specific date/time', FALSE, TRUE),
(3, 'Assigned', 'ASGN', 'Activity has been assigned to personnel', FALSE, TRUE),
(4, 'In Progress', 'PROG', 'Activity is currently being executed', FALSE, FALSE),
(5, 'On Hold', 'HOLD', 'Activity temporarily paused', FALSE, FALSE),
(6, 'Completed', 'COMP', 'Activity successfully completed', TRUE, FALSE),
(7, 'Partially Completed', 'PART', 'Only part of activity was completed', TRUE, FALSE),
(8, 'Cancelled', 'CANC', 'Activity was cancelled before completion', TRUE, FALSE),
(9, 'Failed', 'FAIL', 'Activity attempted but failed to complete', TRUE, FALSE),
(10, 'Deferred', 'DEFR', 'Activity postponed to later date', FALSE, TRUE),
(11, 'Pending Review', 'REVW', 'Completed but pending quality review', FALSE, FALSE),
(12, 'Approved', 'APPR', 'Completed and approved', TRUE, FALSE),
(13, 'Rejected', 'REJ', 'Completed but rejected, needs rework', FALSE, TRUE);

CREATE TABLE ugims_management_plan (
    plan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_number VARCHAR(50) UNIQUE,
    plan_name VARCHAR(255) NOT NULL,
    plan_type_id INTEGER REFERENCES lkp_plan_type(plan_type_id),
    fiscal_year_id INTEGER REFERENCES lkp_fiscal_year(fiscal_year_id),
    scope_type VARCHAR(50),
    ugi_ids UUID[],
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
    approved_by_user_id UUID REFERENCES auth_user(id),
    approval_date TIMESTAMP,
    approval_notes TEXT,
    prepared_by_user_id UUID REFERENCES auth_user(id),
    prepared_date TIMESTAMP,
    reviewed_by_user_id UUID REFERENCES auth_user(id),
    reviewed_date TIMESTAMP,
    goals_and_objectives TEXT,
    success_criteria TEXT,
    risks_and_assumptions TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id UUID REFERENCES auth_user(id),
    updated_by_user_id UUID REFERENCES auth_user(id),
    notes TEXT,
    attachments TEXT[]
);

CREATE TABLE ugims_plan_activity (
    plan_activity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID NOT NULL REFERENCES ugims_management_plan(plan_id) ON DELETE CASCADE,
    activity_number VARCHAR(50),
    activity_type_id INTEGER REFERENCES lkp_activity_type(activity_type_id),
    activity_name VARCHAR(255),
    activity_description TEXT,
    ugi_id UUID REFERENCES ugims_ugi(ugi_id),
    component_id UUID REFERENCES ugims_ugi_component(component_id),
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
    assigned_team_id UUID,
    assigned_team_lead UUID,
    depends_on_activity_id UUID REFERENCES ugims_plan_activity(plan_activity_id),
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
    created_by_user_id UUID REFERENCES auth_user(id),
    updated_by_user_id UUID REFERENCES auth_user(id)
);

-- Note: ugims_activity_execution references ugims_workforce_user, which will be created later.
-- We'll create ugims_workforce_user first before tables that reference it.
-- Continue with other tables, but we'll reorder slightly to avoid forWoreda references.

-- =====================================================
-- 9. WORKFORCE MANAGEMENT (created early for references)
-- =====================================================

CREATE TABLE lkp_job_title (
    job_title_id INTEGER PRIMARY KEY,
    job_title_name VARCHAR(100) NOT NULL,
    job_category VARCHAR(50),
    pay_grade VARCHAR(20),
    requires_certification BOOLEAN DEFAULT FALSE,
    requires_license BOOLEAN DEFAULT FALSE
);

INSERT INTO lkp_job_title (job_title_id, job_title_name, job_category, requires_certification) VALUES
(1, 'UGI Director', 'Management', FALSE),
(2, 'UGI Deputy Director', 'Management', FALSE),
(3, 'Zone Manager', 'Management', FALSE),
(4, 'Senior Supervisor', 'Supervision', FALSE),
(5, 'Field Supervisor', 'Supervision', FALSE),
(6, 'Inspector', 'Inspection', TRUE),
(7, 'Senior Gardener', 'Field Staff', TRUE),
(8, 'Gardener', 'Field Staff', FALSE),
(9, 'Irrigation Technician', 'Technical', TRUE),
(10, 'Electrician', 'Technical', TRUE),
(11, 'Carpenter', 'Technical', TRUE),
(12, 'Mason', 'Technical', TRUE),
(13, 'Equipment Operator', 'Technical', TRUE),
(14, 'Laborer', 'Field Staff', FALSE),
(15, 'Tree Surgeon/Arborist', 'Specialist', TRUE),
(16, 'Pest Control Technician', 'Specialist', TRUE),
(17, 'Cleaner', 'Field Staff', FALSE),
(18, 'Security Guard', 'Security', FALSE),
(19, 'Administrative Assistant', 'Administrative', FALSE),
(20, 'GIS Specialist', 'Technical', TRUE),
(21, 'Planner', 'Professional', TRUE),
(22, 'Accountant', 'Administrative', TRUE);

CREATE TABLE lkp_skill (
    skill_id INTEGER PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL,
    skill_category VARCHAR(50),
    certification_required BOOLEAN DEFAULT FALSE
);

INSERT INTO lkp_skill (skill_id, skill_name, skill_category, certification_required) VALUES
(1, 'Lawn Mowing', 'Grounds Maintenance', FALSE),
(2, 'Hedge Trimming', 'Grounds Maintenance', FALSE),
(3, 'Tree Pruning', 'Arboriculture', TRUE),
(4, 'Tree Felling', 'Arboriculture', TRUE),
(5, 'Pesticide Application', 'Pest Control', TRUE),
(6, 'Irrigation Installation', 'Irrigation', TRUE),
(7, 'Irrigation Repair', 'Irrigation', TRUE),
(8, 'Electrical Wiring', 'Electrical', TRUE),
(9, 'Plumbing', 'Plumbing', TRUE),
(10, 'Masonry', 'Construction', FALSE),
(11, 'Carpentry', 'Construction', FALSE),
(12, 'Painting', 'Maintenance', FALSE),
(13, 'Welding', 'Metalwork', TRUE),
(14, 'Equipment Operation', 'Operation', TRUE),
(15, 'First Aid', 'Safety', TRUE),
(16, 'CPR', 'Safety', TRUE),
(17, 'GIS Mapping', 'Technical', TRUE),
(18, 'Inspection', 'Quality', TRUE),
(19, 'Supervision', 'Management', FALSE),
(20, 'Customer Service', 'Soft Skill', FALSE);

CREATE TABLE lkp_leave_type (
    leave_type_id INTEGER PRIMARY KEY,
    leave_name VARCHAR(50) NOT NULL,
    description TEXT,
    paid BOOLEAN DEFAULT TRUE,
    days_per_year INTEGER
);

INSERT INTO lkp_leave_type (leave_type_id, leave_name, description, paid, days_per_year) VALUES
(1, 'Annual Leave', 'Regular vacation leave', TRUE, 20),
(2, 'Sick Leave', 'Medical leave', TRUE, 12),
(3, 'Emergency Leave', 'Family emergency', TRUE, 5),
(4, 'Maternity Leave', 'Maternity', TRUE, 90),
(5, 'Paternity Leave', 'Paternity', TRUE, 5),
(6, 'Unpaid Leave', 'Leave without pay', FALSE, NULL),
(7, 'Training Leave', 'For official training', TRUE, NULL),
(8, 'Compassionate Leave', 'Bereavement', TRUE, 3),
(9, 'Public Holiday', 'Official holiday', TRUE, NULL);

CREATE TABLE ugims_workforce_user (
    user_id UUID PRIMARY KEY REFERENCES auth_user(id),
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
    reports_to_user_id UUID REFERENCES ugims_workforce_user(user_id),
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
    created_by_user_id UUID REFERENCES auth_user(id),
    updated_by_user_id UUID REFERENCES auth_user(id),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE ugims_team (
    team_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_name VARCHAR(100) NOT NULL,
    team_code VARCHAR(20) UNIQUE,
    team_type VARCHAR(50),
    assigned_zone_id INTEGER REFERENCES ugims_maintenance_zone(zone_id),
    specialization VARCHAR(100),
    team_lead_user_id UUID REFERENCES ugims_workforce_user(user_id),
    assistant_lead_user_id UUID REFERENCES ugims_workforce_user(user_id),
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
    created_by_user_id UUID REFERENCES auth_user(id),
    updated_by_user_id UUID REFERENCES auth_user(id)
);

CREATE TABLE ugims_team_membership (
    membership_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID NOT NULL REFERENCES ugims_team(team_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES ugims_workforce_user(user_id) ON DELETE CASCADE,
    role_in_team VARCHAR(50),
    assigned_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id UUID REFERENCES auth_user(id),
    UNIQUE(team_id, user_id, assigned_date)
);

CREATE TABLE ugims_workforce_schedule (
    schedule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES ugims_workforce_user(user_id),
    schedule_date DATE NOT NULL,
    shift_start TIME,
    shift_end TIME,
    break_duration_minutes INTEGER,
    assignment_type VARCHAR(50),
    assigned_zone_id INTEGER REFERENCES ugims_maintenance_zone(zone_id),
    assigned_task_id UUID,
    clock_in_time TIMESTAMP,
    clock_out_time TIMESTAMP,
    clock_in_location GEOMETRY(Point, 20137),
    clock_out_location GEOMETRY(Point, 20137),
    actual_hours_worked DECIMAL(5,2),
    status VARCHAR(50),
    notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id UUID REFERENCES auth_user(id),
    UNIQUE(user_id, schedule_date)
);

-- =====================================================
-- Continue with ACTIVITY EXECUTION (references ugims_workforce_user)
-- =====================================================

CREATE TABLE ugims_activity_execution (
    execution_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_activity_id UUID REFERENCES ugims_plan_activity(plan_activity_id),
    ugi_id UUID NOT NULL REFERENCES ugims_ugi(ugi_id),
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
    performed_by_user_id UUID REFERENCES ugims_workforce_user(user_id),
    performed_by_team_id UUID REFERENCES ugims_team(team_id),
    supervised_by_user_id UUID REFERENCES ugims_workforce_user(user_id),
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
    verified_by_user_id UUID REFERENCES ugims_workforce_user(user_id),
    verification_datetime TIMESTAMP,
    verification_notes TEXT,
    verification_status VARCHAR(50),
    issues_identified BOOLEAN DEFAULT FALSE,
    issue_ids UUID[],
    followup_required BOOLEAN DEFAULT FALSE,
    followup_notes TEXT,
    followup_date DATE,
    weather_conditions VARCHAR(100),
    temperature_c DECIMAL(4,1),
    precipitation BOOLEAN,
    wind_conditions VARCHAR(50),
    recorded_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    recorded_by_user_id UUID REFERENCES auth_user(id),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mobile_device_id VARCHAR(100),
    mobile_app_version VARCHAR(20),
    sync_datetime TIMESTAMP,
    offline_record BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- 10. INSPECTION AND MONITORING
-- =====================================================

CREATE TABLE lkp_inspection_type (
    inspection_type_id INTEGER PRIMARY KEY,
    inspection_name VARCHAR(100) NOT NULL,
    description TEXT,
    typical_frequency_id INTEGER REFERENCES lkp_frequency(frequency_id),
    requires_tools BOOLEAN DEFAULT FALSE,
    requires_certification BOOLEAN DEFAULT FALSE
);

INSERT INTO lkp_inspection_type (inspection_type_id, inspection_name, description, typical_frequency_id, requires_tools) VALUES
(1, 'Routine Maintenance Inspection', 'Regular check for maintenance needs', 4, FALSE),
(2, 'Safety Inspection', 'Check for safety hazards and risks', 4, FALSE),
(3, 'Tree Health Assessment', 'Detailed tree condition assessment', 6, TRUE),
(4, 'Playground Safety Inspection', 'Comprehensive playground equipment check', 2, TRUE),
(5, 'Irrigation System Inspection', 'Check irrigation functionality', 4, TRUE),
(6, 'Lighting System Inspection', 'Check all lighting fixtures', 4, TRUE),
(7, 'Structural Integrity Inspection', 'Check buildings and structures', 6, TRUE),
(8, 'Post-Storm Damage Assessment', 'Inspection after severe weather', 9, FALSE),
(9, 'Annual Comprehensive Audit', 'Yearly full condition assessment', 8, TRUE),
(10, 'Compliance Inspection', 'Check against standards/regulations', 6, FALSE),
(11, 'Pest/Disease Inspection', 'Check for pests and diseases', 4, TRUE),
(12, 'Water Quality Testing', 'Test water features quality', 4, TRUE),
(13, 'Accessibility Compliance', 'Check accessibility standards', 6, FALSE);

CREATE TABLE lkp_inspection_status (
    status_id INTEGER PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    description TEXT,
    allows_editing BOOLEAN DEFAULT TRUE
);

INSERT INTO lkp_inspection_status (status_id, status_name, description, allows_editing) VALUES
(1, 'Scheduled', 'Inspection has been scheduled', TRUE),
(2, 'Assigned', 'Assigned to inspector', TRUE),
(3, 'In Progress', 'Inspection is being conducted', TRUE),
(4, 'Completed', 'Inspection completed, pending review', FALSE),
(5, 'Reviewed', 'Inspection has been reviewed', FALSE),
(6, 'Approved', 'Inspection approved', FALSE),
(7, 'Rejected', 'Inspection rejected, needs redo', FALSE),
(8, 'Cancelled', 'Inspection cancelled', FALSE);

CREATE TABLE lkp_finding_priority (
    priority_id INTEGER PRIMARY KEY,
    priority_name VARCHAR(50) NOT NULL,
    response_time_hours INTEGER,
    color_code VARCHAR(7),
    requires_immediate_action BOOLEAN DEFAULT FALSE
);

INSERT INTO lkp_finding_priority (priority_id, priority_name, response_time_hours, color_code, requires_immediate_action) VALUES
(1, 'Critical - Immediate', 1, '#FF0000', TRUE),
(2, 'High - 24 Hours', 24, '#FFA500', TRUE),
(3, 'Medium - 1 Week', 168, '#FFFF00', FALSE),
(4, 'Low - 1 Month', 720, '#00FF00', FALSE),
(5, 'Informational Only', NULL, '#0000FF', FALSE);

CREATE TABLE ugims_inspection (
    inspection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inspection_number VARCHAR(50) UNIQUE,
    inspection_type_id INTEGER REFERENCES lkp_inspection_type(inspection_type_id),
    ugi_id UUID REFERENCES ugims_ugi(ugi_id),
    component_id UUID REFERENCES ugims_ugi_component(component_id),
    inspection_area GEOMETRY(Polygon, 20137),
    scheduled_date TIMESTAMP,
    scheduled_by_user_id UUID REFERENCES auth_user(id),
    assigned_to_user_id UUID REFERENCES ugims_workforce_user(user_id),
    assigned_date TIMESTAMP,
    started_datetime TIMESTAMP,
    completed_datetime TIMESTAMP,
    inspector_user_id UUID REFERENCES ugims_workforce_user(user_id),
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
    followup_inspection_id UUID,
    followup_date DATE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id UUID REFERENCES auth_user(id),
    updated_by_user_id UUID REFERENCES auth_user(id),
    mobile_device_id VARCHAR(100),
    sync_datetime TIMESTAMP,
    offline_record BOOLEAN DEFAULT FALSE
);

CREATE TABLE ugims_inspection_finding (
    finding_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inspection_id UUID NOT NULL REFERENCES ugims_inspection(inspection_id) ON DELETE CASCADE,
    ugi_id UUID REFERENCES ugims_ugi(ugi_id),
    component_id UUID REFERENCES ugims_ugi_component(component_id),
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
    assigned_to_user_id UUID REFERENCES ugims_workforce_user(user_id),
    assigned_date DATE,
    work_order_created BOOLEAN DEFAULT FALSE,
    work_order_id UUID,
    resolved BOOLEAN DEFAULT FALSE,
    resolved_date TIMESTAMP,
    resolved_by_user_id UUID REFERENCES ugims_workforce_user(user_id),
    resolution_notes TEXT,
    photo_urls TEXT[],
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ugims_monitoring_log (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    log_number VARCHAR(50) UNIQUE,
    ugi_id UUID REFERENCES ugims_ugi(ugi_id),
    location_point GEOMETRY(Point, 20137) NOT NULL,
    location_description TEXT,
    monitor_user_id UUID NOT NULL REFERENCES ugims_workforce_user(user_id),
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
    created_by_user_id UUID REFERENCES auth_user(id),
    mobile_device_id VARCHAR(100),
    sync_datetime TIMESTAMP,
    offline_record BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- 11. ISSUE TRACKING
-- =====================================================

CREATE TABLE lkp_issue_category (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    default_priority_id INTEGER REFERENCES lkp_finding_priority(priority_id)
);

INSERT INTO lkp_issue_category (category_id, category_name, description, default_priority_id) VALUES
(1, 'Safety Hazard', 'Issues that pose safety risks to public', 1),
(2, 'Vandalism', 'Deliberate damage to property', 2),
(3, 'Equipment Malfunction', 'Non-working equipment', 3),
(4, 'Vegetation Problem', 'Issues with trees, grass, plants', 3),
(5, 'Litter/Dumping', 'Illegal dumping or excessive litter', 4),
(6, 'Graffiti', 'Unauthorized markings', 4),
(7, 'Lighting Issue', 'Non-functioning lights', 3),
(8, 'Water Issue', 'Leaks, flooding, water quality', 2),
(9, 'Animal/Wildlife', 'Issues with animals', 3),
(10, 'Accessibility Issue', 'Barriers to access', 2),
(11, 'Structural Damage', 'Damage to buildings, paths, fences', 2),
(12, 'Sanitation Issue', 'Toilet cleanliness, odor', 4),
(13, 'Noise Complaint', 'Excessive noise', 4),
(14, 'Unauthorized Activity', 'Illegal activities on site', 2),
(15, 'Fire Hazard', 'Fire risk', 1);

CREATE TABLE lkp_issue_status (
    status_id INTEGER PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    description TEXT,
    is_closed BOOLEAN DEFAULT FALSE
);

INSERT INTO lkp_issue_status (status_id, status_name, description, is_closed) VALUES
(1, 'Reported', 'Issue has been reported', FALSE),
(2, 'Acknowledged', 'Issue has been acknowledged by staff', FALSE),
(3, 'Assigned', 'Assigned to responsible person/team', FALSE),
(4, 'In Progress', 'Work on issue has started', FALSE),
(5, 'Pending Parts', 'Waiting for parts/materials', FALSE),
(6, 'Pending Approval', 'Waiting for approval', FALSE),
(7, 'Resolved', 'Issue has been resolved', TRUE),
(8, 'Closed', 'Issue closed after verification', TRUE),
(9, 'Rejected', 'Not a valid issue', TRUE),
(10, 'Duplicate', 'Already reported elsewhere', TRUE);

CREATE TABLE ugims_issue (
    issue_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_number VARCHAR(50) UNIQUE,
    source_type VARCHAR(50),
    source_reference_id UUID,
    category_id INTEGER REFERENCES lkp_issue_category(category_id),
    issue_type VARCHAR(100),
    priority_id INTEGER REFERENCES lkp_finding_priority(priority_id),
    ugi_id UUID REFERENCES ugims_ugi(ugi_id),
    component_id UUID REFERENCES ugims_ugi_component(component_id),
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
    assigned_to_user_id UUID REFERENCES ugims_workforce_user(user_id),
    assigned_to_team_id UUID REFERENCES ugims_team(team_id),
    assigned_datetime TIMESTAMP,
    assigned_by_user_id UUID REFERENCES auth_user(id),
    work_order_created BOOLEAN DEFAULT FALSE,
    work_order_id UUID,
    status_id INTEGER REFERENCES lkp_issue_status(status_id),
    status_history JSONB,
    resolved_datetime TIMESTAMP,
    resolved_by_user_id UUID REFERENCES ugims_workforce_user(user_id),
    resolution_notes TEXT,
    resolution_action_taken TEXT,
    verified_by_user_id UUID REFERENCES ugims_workforce_user(user_id),
    verification_datetime TIMESTAMP,
    verification_notes TEXT,
    estimated_cost DECIMAL(12,2),
    actual_cost DECIMAL(12,2),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id UUID REFERENCES auth_user(id),
    updated_by_user_id UUID REFERENCES auth_user(id)
);

CREATE TABLE ugims_issue_comment (
    comment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES ugims_issue(issue_id) ON DELETE CASCADE,
    comment_text TEXT NOT NULL,
    comment_type VARCHAR(50),
    commented_by_user_id UUID REFERENCES auth_user(id),
    commented_by_name VARCHAR(255),
    commented_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    attachments TEXT[],
    is_public BOOLEAN DEFAULT FALSE
);

-- =====================================================
-- 12. CITIZEN ENGAGEMENT
-- =====================================================

CREATE TABLE lkp_citizen_report_type (
    report_type_id INTEGER PRIMARY KEY,
    report_type_name VARCHAR(100) NOT NULL,
    report_type_name_amharic VARCHAR(100),
    category VARCHAR(50),
    default_priority_id INTEGER REFERENCES lkp_finding_priority(priority_id),
    estimated_response_days INTEGER
);

INSERT INTO lkp_citizen_report_type (report_type_id, report_type_name, report_type_name_amharic, category, default_priority_id, estimated_response_days) VALUES
(1, 'Broken Bench', 'የተሰበረ ቤንች', 'Infrastructure', 3, 7),
(2, 'Damaged Play Equipment', 'የተጎዳ የመጫወቻ መሳሪያ', 'Safety', 2, 3),
(3, 'Overgrown Vegetation', 'ያደገ ተክል', 'Maintenance', 4, 14),
(4, 'Fallen Tree/Branch', 'የወደቀ ዛፍ/ቅርንጫፍ', 'Safety', 1, 1),
(5, 'Broken Light', 'የተሰበረ መብራት', 'Infrastructure', 3, 5),
(6, 'Trash Overflow', 'የቆሻሻ መጣያ መሞላት', 'Sanitation', 4, 2),
(7, 'Illegal Dumping', 'ህገ-ወጥ ቆሻሻ ማፍሰስ', 'Environmental', 2, 3),
(8, 'Graffiti', 'ግራፊቲ', 'Vandalism', 3, 7),
(9, 'Water Leak', 'የውሃ ፍሳሽ', 'Infrastructure', 2, 2),
(10, 'Broken Fountain', 'የተሰበረ ምንጭ', 'Infrastructure', 4, 14),
(11, 'Unsafe Condition', 'አደገኛ ሁኔታ', 'Safety', 1, 1),
(12, 'Pest Infestation', 'የተባይ ወረራ', 'Environmental', 3, 5),
(13, 'Suggestions', 'አስተያየት', 'Feedback', 5, 30),
(14, 'Compliment', 'ምስጋና', 'Feedback', 5, NULL),
(15, 'General Inquiry', 'አጠቃላይ ጥያቄ', 'Inquiry', 5, 5);

CREATE TABLE lkp_citizen_report_status (
    status_id INTEGER PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    status_name_amharic VARCHAR(100),
    description TEXT,
    is_visible_to_public BOOLEAN DEFAULT TRUE
);

INSERT INTO lkp_citizen_report_status (status_id, status_name, status_name_amharic, description, is_visible_to_public) VALUES
(1, 'Submitted', 'ቀርቧል', 'Report has been submitted', TRUE),
(2, 'Under Review', 'በግምገማ ላይ', 'Staff is reviewing the report', TRUE),
(3, 'Acknowledged', 'እውቅና ተሰጥቶታል', 'Report has been acknowledged', TRUE),
(4, 'Assigned', 'ተመድቧል', 'Assigned to responsible team', TRUE),
(5, 'In Progress', 'በሂደት ላይ', 'Work on the issue has started', TRUE),
(6, 'Resolved', 'ተፈትቷል', 'Issue has been resolved', TRUE),
(7, 'Closed', 'ተዘግቷል', 'Report closed after verification', TRUE),
(8, 'Rejected', 'ውድቅ ተደርጓል', 'Report was not valid', TRUE),
(9, 'Duplicate', 'ተደጋጋሚ', 'Already reported by someone else', TRUE);

CREATE TABLE ugims_citizen_report (
    report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    ugi_id UUID REFERENCES ugims_ugi(ugi_id),
    address_text TEXT,
    photo_urls TEXT[],
    status_id INTEGER REFERENCES lkp_citizen_report_status(status_id) DEFAULT 1,
    assigned_to_user_id UUID REFERENCES ugims_workforce_user(user_id),
    assigned_team_id UUID REFERENCES ugims_team(team_id),
    assigned_datetime TIMESTAMP,
    issue_id UUID REFERENCES ugims_issue(issue_id),
    inspection_id UUID REFERENCES ugims_inspection(inspection_id),
    response_message TEXT,
    response_datetime TIMESTAMP,
    responded_by_user_id UUID REFERENCES ugims_workforce_user(user_id),
    resolved_datetime TIMESTAMP,
    resolution_notes TEXT,
    resolution_photo_urls TEXT[],
    satisfaction_rating INTEGER CHECK (satisfaction_rating BETWEEN 1 AND 5),
    feedback_comments TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id UUID REFERENCES auth_user(id),
    mobile_device_id VARCHAR(100),
    app_version VARCHAR(20),
    sync_datetime TIMESTAMP
);

CREATE TABLE ugims_public_feedback (
    feedback_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ugi_id UUID REFERENCES ugims_ugi(ugi_id),
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
-- 13. BUDGET AND FINANCIAL MANAGEMENT
-- =====================================================

CREATE TABLE lkp_budget_category (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_code VARCHAR(20),
    description TEXT
);

INSERT INTO lkp_budget_category (category_id, category_name, category_code, description) VALUES
(1, 'Personnel - Salaries', 'PERS', 'Staff salaries and wages'),
(2, 'Personnel - Benefits', 'BENF', 'Employee benefits and allowances'),
(3, 'Personnel - Training', 'TRAIN', 'Staff training and development'),
(4, 'Materials - Plants', 'MATP', 'Plants, trees, seeds, flowers'),
(5, 'Materials - Supplies', 'MATS', 'General maintenance supplies'),
(6, 'Materials - Chemicals', 'MATC', 'Fertilizers, pesticides, etc.'),
(7, 'Equipment - Purchase', 'EQPP', 'New equipment purchase'),
(8, 'Equipment - Maintenance', 'EQPM', 'Equipment repair and maintenance'),
(9, 'Equipment - Fuel', 'EQPF', 'Fuel for equipment and vehicles'),
(10, 'Utilities - Water', 'UTLW', 'Water bills'),
(11, 'Utilities - Electricity', 'UTLE', 'Electricity bills'),
(12, 'Utilities - Communications', 'UTLC', 'Phone, internet'),
(13, 'Contract Services', 'CONTR', 'Outsourced services'),
(14, 'Capital Projects', 'CAP', 'Major construction/renovation'),
(15, 'Emergency Fund', 'EMERG', 'Unforeseen expenses'),
(16, 'Administrative', 'ADMIN', 'Office expenses, supplies'),
(17, 'Events and Programs', 'EVENT', 'Public events and activities');

CREATE TABLE lkp_budget_source (
    source_id INTEGER PRIMARY KEY,
    source_name VARCHAR(100) NOT NULL,
    source_type VARCHAR(50),
    description TEXT
);

INSERT INTO lkp_budget_source (source_id, source_name, source_type, description) VALUES
(1, 'Municipal General Fund', 'Government', 'City general budget allocation'),
(2, 'Federal Government Grant', 'Government', 'Grant from federal government'),
(3, 'Regional Government Allocation', 'Government', 'Allocation from regional government'),
(4, 'Donor - International', 'Donor', 'International aid/development funding'),
(5, 'Donor - Local', 'Donor', 'Local NGO or charity funding'),
(6, 'Public-Private Partnership', 'Partnership', 'PPP funding'),
(7, 'User Fees', 'Revenue', 'Fees collected from users'),
(8, 'Event Revenue', 'Revenue', 'Revenue from events'),
(9, 'Sponsorships', 'Revenue', 'Corporate sponsorships'),
(10, 'Fines and Penalties', 'Revenue', 'Fines collected'),
(11, 'Special Assessment District', 'Government', 'Special local tax district');

CREATE TABLE ugims_budget (
    budget_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    ugi_id UUID REFERENCES ugims_ugi(ugi_id),
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
    approved_by_user_id UUID REFERENCES auth_user(id),
    approval_date TIMESTAMP,
    approval_document TEXT,
    manager_user_id UUID REFERENCES auth_user(id),
    finance_officer_user_id UUID REFERENCES auth_user(id),
    category_breakdown JSONB,
    notes TEXT,
    restrictions TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id UUID REFERENCES auth_user(id),
    updated_by_user_id UUID REFERENCES auth_user(id)
);

CREATE TABLE ugims_budget_line_item (
    line_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    budget_id UUID NOT NULL REFERENCES ugims_budget(budget_id) ON DELETE CASCADE,
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
    expense_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_number VARCHAR(50) UNIQUE,
    budget_id UUID REFERENCES ugims_budget(budget_id),
    line_item_id UUID REFERENCES ugims_budget_line_item(line_item_id),
    expense_date DATE NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    category_id INTEGER REFERENCES lkp_budget_category(category_id),
    expense_type VARCHAR(50),
    vendor_name VARCHAR(255),
    vendor_id VARCHAR(100),
    invoice_number VARCHAR(100),
    receipt_number VARCHAR(100),
    ugi_id UUID REFERENCES ugims_ugi(ugi_id),
    activity_execution_id UUID REFERENCES ugims_activity_execution(execution_id),
    plan_id UUID REFERENCES ugims_management_plan(plan_id),
    work_order_id UUID,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    payment_date DATE,
    paid_by_user_id UUID REFERENCES auth_user(id),
    supporting_documents TEXT[],
    notes TEXT,
    approved_by_user_id UUID REFERENCES auth_user(id),
    approval_date TIMESTAMP,
    approval_notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id UUID REFERENCES auth_user(id),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ugims_purchase_requisition (
    requisition_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requisition_number VARCHAR(50) UNIQUE,
    requisition_date DATE DEFAULT CURRENT_DATE,
    requested_by_user_id UUID REFERENCES ugims_workforce_user(user_id),
    department_id INTEGER,
    purpose TEXT NOT NULL,
    ugi_id UUID REFERENCES ugims_ugi(ugi_id),
    activity_id UUID REFERENCES ugims_plan_activity(plan_activity_id),
    items JSONB NOT NULL,
    total_estimated_cost DECIMAL(15,2),
    budget_id UUID REFERENCES ugims_budget(budget_id),
    budget_check_status VARCHAR(50),
    budget_check_notes TEXT,
    approval_status VARCHAR(50),
    current_approver_level INTEGER,
    approval_history JSONB,
    approved_by_user_id UUID REFERENCES auth_user(id),
    approval_date TIMESTAMP,
    approval_notes TEXT,
    purchase_order_id VARCHAR(100),
    purchase_order_date DATE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 14. SPATIAL METADATA AND AUDIT
-- =====================================================

CREATE TABLE ugims_spatial_metadata (
    metadata_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_by_user_id UUID REFERENCES auth_user(id),
    changed_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT
);

-- =====================================================
-- 15. COMPREHENSIVE STATUS LOOKUP (all statuses in one table)
-- =====================================================

CREATE TABLE lkp_all_statuses (
    status_id INTEGER PRIMARY KEY,
    status_type VARCHAR(50) NOT NULL,
    status_code VARCHAR(20) NOT NULL,
    status_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INTEGER,
    color_code VARCHAR(7),
    icon_name VARCHAR(50),
    UNIQUE(status_type, status_code)
);
-- Insert with new unique IDs using row_number()
INSERT INTO lkp_all_statuses (status_id, status_type, status_code, status_name, description, color_code)
SELECT 
    ROW_NUMBER() OVER (ORDER BY status_type, original_id),
    status_type,
    status_code,
    status_name,
    description,
    color_code
FROM (
    SELECT status_id as original_id, 'condition' as status_type, status_code, status_name, description, color_code FROM lkp_condition_status
    UNION ALL
    SELECT status_id, 'operational', status_code, status_name, description, NULL FROM lkp_operational_status
    UNION ALL
    SELECT status_id, 'activity', status_code, status_name, description, NULL FROM lkp_activity_status
    UNION ALL
    SELECT status_id, 'inspection', CAST(status_id AS VARCHAR), status_name, description, NULL FROM lkp_inspection_status
    UNION ALL
    SELECT status_id, 'issue', CAST(status_id AS VARCHAR), status_name, description, NULL FROM lkp_issue_status
    UNION ALL
    SELECT status_id, 'citizen_report', CAST(status_id AS VARCHAR), status_name, description, NULL FROM lkp_citizen_report_status
) combined;-- =====================================================
-- 16. TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

CREATE OR REPLACE FUNCTION update_last_updated_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_ugi_last_updated BEFORE UPDATE ON ugims_ugi
    FOR EACH ROW EXECUTE FUNCTION update_last_updated_column();

CREATE TRIGGER update_parcel_last_updated BEFORE UPDATE ON ugims_parcel
    FOR EACH ROW EXECUTE FUNCTION update_last_updated_column();

CREATE TRIGGER update_plan_last_updated BEFORE UPDATE ON ugims_management_plan
    FOR EACH ROW EXECUTE FUNCTION update_last_updated_column();

CREATE TRIGGER update_activity_execution_last_updated BEFORE UPDATE ON ugims_activity_execution
    FOR EACH ROW EXECUTE FUNCTION update_last_updated_column();

CREATE TRIGGER update_inspection_last_updated BEFORE UPDATE ON ugims_inspection
    FOR EACH ROW EXECUTE FUNCTION update_last_updated_column();

CREATE TRIGGER update_issue_last_updated BEFORE UPDATE ON ugims_issue
    FOR EACH ROW EXECUTE FUNCTION update_last_updated_column();

CREATE TRIGGER update_citizen_report_last_updated BEFORE UPDATE ON ugims_citizen_report
    FOR EACH ROW EXECUTE FUNCTION update_last_updated_column();

CREATE TRIGGER update_budget_last_updated BEFORE UPDATE ON ugims_budget
    FOR EACH ROW EXECUTE FUNCTION update_last_updated_column();

-- =====================================================
-- 17. INDEXES FOR PERFORMANCE
-- =====================================================

-- Spatial indexes
CREATE INDEX idx_ugi_geometry ON ugims_ugi USING GIST (geometry);
CREATE INDEX idx_ugi_centroid ON ugims_ugi USING GIST (centroid);
CREATE INDEX idx_parcel_geometry ON ugims_parcel USING GIST (geometry);
CREATE INDEX idx_citizen_report_location ON ugims_citizen_report USING GIST (location_point);
CREATE INDEX idx_inspection_path ON ugims_inspection USING GIST (inspection_path);
CREATE INDEX idx_activity_tracking ON ugims_activity_execution USING GIST (tracking_path);
CREATE INDEX idx_work_area ON ugims_plan_activity USING GIST (target_area);

-- B-tree indexes for foreign keys and frequent queries
CREATE INDEX idx_ugi_Woreda ON ugims_ugi(Woreda_id);
CREATE INDEX idx_ugi_zone ON ugims_ugi(maintenance_zone_id);
CREATE INDEX idx_ugi_type ON ugims_ugi(ugi_type_id);
CREATE INDEX idx_ugi_condition ON ugims_ugi(condition_status_id);
CREATE INDEX idx_parcel_Woreda ON ugims_parcel(Woreda_id);
CREATE INDEX idx_parcel_owner ON ugims_parcel(owner_name);

CREATE INDEX idx_activity_execution_ugi ON ugims_activity_execution(ugi_id);
CREATE INDEX idx_activity_execution_dates ON ugims_activity_execution(actual_start_datetime);
CREATE INDEX idx_activity_execution_status ON ugims_activity_execution(completion_status_id);

CREATE INDEX idx_inspection_ugi ON ugims_inspection(ugi_id);
CREATE INDEX idx_inspection_dates ON ugims_inspection(scheduled_date);
CREATE INDEX idx_inspection_status ON ugims_inspection(inspection_status_id);

CREATE INDEX idx_issue_ugi ON ugims_issue(ugi_id);
CREATE INDEX idx_issue_status ON ugims_issue(status_id);
CREATE INDEX idx_issue_priority ON ugims_issue(priority_id);

CREATE INDEX idx_citizen_report_status ON ugims_citizen_report(status_id);
CREATE INDEX idx_citizen_report_date ON ugims_citizen_report(created_date);

-- =====================================================
-- END OF SCHEMA
-- =====================================================












--- ++++++++++++++++++++++++++
-- new

CREATE TABLE IF NOT EXISTS lkp_plan_status (
    status_id INTEGER PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    description TEXT
);

INSERT INTO lkp_plan_status (status_id, status_name) VALUES
(1, 'Draft'),
(2, 'Submitted'),
(3, 'Approved'),
(4, 'Rejected'),
(5, 'In Progress'),
(6, 'Completed'),
(7, 'Cancelled');

