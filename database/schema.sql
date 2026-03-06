-- ============================================================================
-- AI Interior Design Platform - Supabase Database Schema
-- ============================================================================
-- Version: 1.0 MVP
-- Domain: clawlist.store
-- Created: 2026-03-06
-- Database: PostgreSQL 15+ (Supabase)
-- ============================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ENUMS
-- ============================================================================

-- User subscription tiers
CREATE TYPE subscription_tier AS ENUM ('free', 'pro', 'studio');

-- Subscription status
CREATE TYPE subscription_status AS ENUM ('active', 'canceled', 'past_due', 'trialing', 'incomplete');

-- Payment status
CREATE TYPE payment_status AS ENUM ('pending', 'succeeded', 'failed', 'refunded');

-- Project types
CREATE TYPE project_type AS ENUM ('single_room', 'full_house');

-- Project status
CREATE TYPE project_status AS ENUM ('draft', 'floor_plan_uploaded', 'style_selected', 'furniture_added', 'generated', 'completed');

-- Design generation status
CREATE TYPE generation_status AS ENUM ('pending', 'processing', 'completed', 'failed');

-- Furniture item status
CREATE TYPE furniture_status AS ENUM ('pending_parse', 'parsed', 'parse_failed', 'manual_input');

-- Furniture priority
CREATE TYPE furniture_priority AS ENUM ('must_use', 'replaceable');

-- Design style presets
CREATE TYPE design_style AS ENUM ('modern', 'industrial', 'scandinavian', 'minimalist', 'traditional', 'eclectic');

-- Export format types
CREATE TYPE export_format AS ENUM ('jpg', 'png', 'pdf', 'csv');

-- ============================================================================
-- TABLE: users
-- ============================================================================
-- Extends Supabase auth.users with application-specific data
-- Note: Supabase auth.users is managed by Supabase Auth
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT,
    avatar_url TEXT,

    -- Subscription info
    current_tier subscription_tier NOT NULL DEFAULT 'free',
    stripe_customer_id TEXT UNIQUE,

    -- Usage tracking (reset monthly for free/pro, or per billing cycle)
    active_projects_count INTEGER NOT NULL DEFAULT 0,
    credits_balance INTEGER NOT NULL DEFAULT 0, -- For credit pack purchases

    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ,

    -- Soft delete
    deleted_at TIMESTAMPTZ
);

-- Indexes for users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_stripe_customer_id ON users(stripe_customer_id);
CREATE INDEX idx_users_current_tier ON users(current_tier);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NULL;

-- ============================================================================
-- TABLE: subscriptions
-- ============================================================================
-- Tracks user subscription history and current status
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Stripe integration
    stripe_subscription_id TEXT UNIQUE,
    stripe_price_id TEXT,

    -- Subscription details
    tier subscription_tier NOT NULL,
    status subscription_status NOT NULL DEFAULT 'active',

    -- Billing cycle
    current_period_start TIMESTAMPTZ NOT NULL,
    current_period_end TIMESTAMPTZ NOT NULL,
    cancel_at_period_end BOOLEAN NOT NULL DEFAULT FALSE,

    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    canceled_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ
);

-- Indexes for subscriptions
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_stripe_subscription_id ON subscriptions(stripe_subscription_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_current_period_end ON subscriptions(current_period_end);

-- Unique constraint: one active subscription per user
CREATE UNIQUE INDEX idx_subscriptions_user_active ON subscriptions(user_id)
WHERE status = 'active';

-- ============================================================================
-- TABLE: payments
-- ============================================================================
-- Records all payment transactions (subscriptions + credit packs)
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Stripe integration
    stripe_payment_intent_id TEXT UNIQUE,
    stripe_invoice_id TEXT,

    -- Payment details
    amount_cents INTEGER NOT NULL, -- Store in cents to avoid floating point issues
    currency TEXT NOT NULL DEFAULT 'USD',
    status payment_status NOT NULL DEFAULT 'pending',

    -- Payment type
    description TEXT, -- e.g., "Pro Monthly Subscription", "10 Credits Pack"
    metadata JSONB, -- Additional data (e.g., credit pack details)

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    paid_at TIMESTAMPTZ,
    refunded_at TIMESTAMPTZ
);

-- Indexes for payments
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_stripe_payment_intent_id ON payments(stripe_payment_intent_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at DESC);

-- ============================================================================
-- TABLE: projects
-- ============================================================================
-- User interior design projects
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Project basic info
    name TEXT NOT NULL,
    type project_type NOT NULL,
    status project_status NOT NULL DEFAULT 'draft',

    -- Space details
    total_area_sqm DECIMAL(10, 2), -- Square meters
    ceiling_height_cm INTEGER, -- Centimeters
    num_residents INTEGER,

    -- Usage preferences (stored as JSONB for flexibility)
    usage_preferences JSONB, -- e.g., {"office": true, "cooking": "frequent", "storage": "high"}

    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);

-- Indexes for projects
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_created_at ON projects(created_at DESC);
CREATE INDEX idx_projects_deleted_at ON projects(deleted_at) WHERE deleted_at IS NULL;

-- ============================================================================
-- TABLE: floor_plans
-- ============================================================================
-- Uploaded floor plan images and their calibration data
CREATE TABLE floor_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,

    -- File storage (Supabase Storage)
    original_file_url TEXT NOT NULL, -- Original uploaded file
    processed_file_url TEXT, -- AI-processed version with detected boundaries

    -- File metadata
    file_name TEXT NOT NULL,
    file_size_bytes INTEGER NOT NULL,
    file_type TEXT NOT NULL, -- e.g., "image/jpeg", "application/pdf"

    -- Calibration data
    scale_ratio DECIMAL(10, 4), -- Pixels per cm (after user calibration)
    calibration_data JSONB, -- Stores calibration points, known dimensions, etc.

    -- AI detection results
    detected_rooms JSONB, -- Array of room boundaries, doors, windows
    detection_confidence DECIMAL(5, 2), -- 0-100 confidence score

    -- User confirmation
    is_confirmed BOOLEAN NOT NULL DEFAULT FALSE,
    user_edits JSONB, -- Manual adjustments made by user

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for floor_plans
CREATE INDEX idx_floor_plans_project_id ON floor_plans(project_id);
CREATE INDEX idx_floor_plans_is_confirmed ON floor_plans(is_confirmed);

-- ============================================================================
-- TABLE: style_preferences
-- ============================================================================
-- User's style choices for each project
CREATE TABLE style_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,

    -- Style selection
    primary_style design_style NOT NULL,
    allow_mixing BOOLEAN NOT NULL DEFAULT FALSE,

    -- Color and material preferences
    color_palette JSONB, -- Array of hex colors
    material_preferences JSONB, -- e.g., {"wood": "light oak", "metal": "brushed steel"}
    lighting_preference TEXT, -- e.g., "warm", "cool", "natural"

    -- Budget
    budget_level TEXT, -- e.g., "low", "medium", "high", "luxury"

    -- Reference images (Supabase Storage URLs)
    reference_images JSONB, -- Array of image URLs (max 10)

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for style_preferences
CREATE INDEX idx_style_preferences_project_id ON style_preferences(project_id);
CREATE UNIQUE INDEX idx_style_preferences_project_unique ON style_preferences(project_id);

-- ============================================================================
-- TABLE: furniture_items
-- ============================================================================
-- Furniture items submitted by users (via links or manual input)
CREATE TABLE furniture_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,

    -- Source
    source_url TEXT, -- Original product link
    source_type TEXT, -- e.g., "amazon", "ikea", "wayfair", "manual"

    -- Parsing status
    status furniture_status NOT NULL DEFAULT 'pending_parse',
    parse_error TEXT, -- Error message if parsing failed

    -- Product details
    product_name TEXT,
    brand TEXT,
    category TEXT, -- e.g., "sofa", "bed", "table", "chair"

    -- Dimensions (in cm)
    width_cm DECIMAL(10, 2),
    depth_cm DECIMAL(10, 2),
    height_cm DECIMAL(10, 2),

    -- Visual attributes
    color TEXT,
    material TEXT,
    style TEXT,
    image_url TEXT,

    -- Price (optional)
    price_cents INTEGER,
    currency TEXT DEFAULT 'USD',

    -- Usage priority
    priority furniture_priority NOT NULL DEFAULT 'replaceable',

    -- Additional metadata
    metadata JSONB, -- Store any extra parsed data

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for furniture_items
CREATE INDEX idx_furniture_items_project_id ON furniture_items(project_id);
CREATE INDEX idx_furniture_items_status ON furniture_items(status);
CREATE INDEX idx_furniture_items_category ON furniture_items(category);
CREATE INDEX idx_furniture_items_priority ON furniture_items(priority);

-- ============================================================================
-- TABLE: designs
-- ============================================================================
-- Generated design versions for a project
CREATE TABLE designs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,

    -- Version tracking
    version_number INTEGER NOT NULL, -- 1, 2, 3, etc.
    is_active BOOLEAN NOT NULL DEFAULT TRUE, -- Current active version

    -- Generation parameters
    generation_params JSONB, -- Stores settings used for generation
    target_rooms JSONB, -- Array of room IDs to generate (or null for all)

    -- Generation status
    status generation_status NOT NULL DEFAULT 'pending',
    error_message TEXT,

    -- Layout data
    layout_data JSONB, -- Furniture placement coordinates, rotations, etc.
    layout_image_url TEXT, -- 2D floor plan with furniture

    -- Validation results
    validation_results JSONB, -- Collision detection, clearance checks, etc.
    is_valid BOOLEAN NOT NULL DEFAULT FALSE,

    -- Design explanation
    design_rationale TEXT, -- AI-generated explanation of design choices
    circulation_analysis TEXT, -- Traffic flow analysis

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Indexes for designs
CREATE INDEX idx_designs_project_id ON designs(project_id);
CREATE INDEX idx_designs_status ON designs(status);
CREATE INDEX idx_designs_is_active ON designs(is_active);
CREATE INDEX idx_designs_version_number ON designs(project_id, version_number);

-- Unique constraint: version number per project
CREATE UNIQUE INDEX idx_designs_project_version ON designs(project_id, version_number);

-- ============================================================================
-- TABLE: design_renders
-- ============================================================================
-- Rendered images for each design (multiple views per design)
CREATE TABLE design_renders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    design_id UUID NOT NULL REFERENCES designs(id) ON DELETE CASCADE,

    -- Room and view info
    room_name TEXT NOT NULL, -- e.g., "Living Room", "Bedroom"
    view_angle TEXT NOT NULL, -- e.g., "front", "corner", "aerial"

    -- Image files (Supabase Storage)
    low_res_url TEXT, -- 720p with watermark (free tier)
    high_res_url TEXT, -- 2K (pro tier)
    ultra_res_url TEXT, -- 4K (studio tier)

    -- Render metadata
    render_time_seconds INTEGER,
    render_engine TEXT, -- e.g., "blender", "unreal", "custom"

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for design_renders
CREATE INDEX idx_design_renders_design_id ON design_renders(design_id);
CREATE INDEX idx_design_renders_room_name ON design_renders(room_name);

-- ============================================================================
-- TABLE: design_modifications
-- ============================================================================
-- Track user modifications to generated designs
CREATE TABLE design_modifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    design_id UUID NOT NULL REFERENCES designs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Modification type
    modification_type TEXT NOT NULL, -- e.g., "quick_button", "manual_edit", "text_instruction"

    -- Modification details
    instruction TEXT, -- User's text instruction or button label
    changes JSONB, -- Detailed changes made (furniture moved, colors changed, etc.)

    -- Result
    resulted_in_new_version BOOLEAN NOT NULL DEFAULT FALSE,
    new_design_id UUID REFERENCES designs(id) ON DELETE SET NULL,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for design_modifications
CREATE INDEX idx_design_modifications_design_id ON design_modifications(design_id);
CREATE INDEX idx_design_modifications_user_id ON design_modifications(user_id);
CREATE INDEX idx_design_modifications_created_at ON design_modifications(created_at DESC);

-- ============================================================================
-- TABLE: shopping_lists
-- ============================================================================
-- Generated shopping lists for each design
CREATE TABLE shopping_lists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    design_id UUID NOT NULL REFERENCES designs(id) ON DELETE CASCADE,

    -- List organization
    room_name TEXT, -- Null for full-house list
    total_items INTEGER NOT NULL DEFAULT 0,
    total_price_cents INTEGER, -- Sum of all items

    -- Export URLs (Supabase Storage)
    pdf_url TEXT,
    csv_url TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for shopping_lists
CREATE INDEX idx_shopping_lists_design_id ON shopping_lists(design_id);
CREATE INDEX idx_shopping_lists_room_name ON shopping_lists(room_name);

-- ============================================================================
-- TABLE: shopping_list_items
-- ============================================================================
-- Individual items in shopping lists
CREATE TABLE shopping_list_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shopping_list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
    furniture_item_id UUID REFERENCES furniture_items(id) ON DELETE SET NULL,

    -- Item details (denormalized for export stability)
    product_name TEXT NOT NULL,
    brand TEXT,
    category TEXT,
    quantity INTEGER NOT NULL DEFAULT 1,

    -- Dimensions
    width_cm DECIMAL(10, 2),
    depth_cm DECIMAL(10, 2),
    height_cm DECIMAL(10, 2),

    -- Purchase info
    source_url TEXT,
    price_cents INTEGER,
    currency TEXT DEFAULT 'USD',

    -- Placement info
    placement_notes TEXT, -- e.g., "Against north wall, 50cm from window"

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for shopping_list_items
CREATE INDEX idx_shopping_list_items_shopping_list_id ON shopping_list_items(shopping_list_id);
CREATE INDEX idx_shopping_list_items_furniture_item_id ON shopping_list_items(furniture_item_id);

-- ============================================================================
-- TABLE: exports
-- ============================================================================
-- Track user exports (images, PDFs, etc.)
CREATE TABLE exports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    design_id UUID NOT NULL REFERENCES designs(id) ON DELETE CASCADE,

    -- Export details
    format export_format NOT NULL,
    file_url TEXT NOT NULL, -- Supabase Storage URL
    file_size_bytes INTEGER,

    -- Metadata
    export_settings JSONB, -- Resolution, watermark, included sections, etc.

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ -- Optional expiration for temporary exports
);

-- Indexes for exports
CREATE INDEX idx_exports_user_id ON exports(user_id);
CREATE INDEX idx_exports_design_id ON exports(design_id);
CREATE INDEX idx_exports_created_at ON exports(created_at DESC);
CREATE INDEX idx_exports_expires_at ON exports(expires_at) WHERE expires_at IS NOT NULL;

-- ============================================================================
-- TABLE: usage_logs
-- ============================================================================
-- Track feature usage for quota enforcement and analytics
CREATE TABLE usage_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Usage type
    action_type TEXT NOT NULL, -- e.g., "generation", "modification", "export", "furniture_parse"
    resource_id UUID, -- ID of related resource (project, design, etc.)

    -- Quota tracking
    credits_consumed INTEGER NOT NULL DEFAULT 0,
    tier_at_time subscription_tier NOT NULL,

    -- Metadata
    metadata JSONB, -- Additional context

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for usage_logs
CREATE INDEX idx_usage_logs_user_id ON usage_logs(user_id);
CREATE INDEX idx_usage_logs_action_type ON usage_logs(action_type);
CREATE INDEX idx_usage_logs_created_at ON usage_logs(created_at DESC);
CREATE INDEX idx_usage_logs_user_month ON usage_logs(user_id, date_trunc('month', created_at));

-- ============================================================================
-- TABLE: style_templates
-- ============================================================================
-- Pre-defined style templates (managed by admins)
CREATE TABLE style_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Template info
    name TEXT NOT NULL UNIQUE,
    style design_style NOT NULL,
    description TEXT,

    -- Visual preview
    thumbnail_url TEXT,
    example_images JSONB, -- Array of example image URLs

    -- Style parameters
    default_color_palette JSONB,
    default_materials JSONB,
    default_lighting TEXT,

    -- Metadata
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for style_templates
CREATE INDEX idx_style_templates_style ON style_templates(style);
CREATE INDEX idx_style_templates_is_active ON style_templates(is_active);
CREATE INDEX idx_style_templates_sort_order ON style_templates(sort_order);

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_floor_plans_updated_at BEFORE UPDATE ON floor_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_style_preferences_updated_at BEFORE UPDATE ON style_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_furniture_items_updated_at BEFORE UPDATE ON furniture_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_designs_updated_at BEFORE UPDATE ON designs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_design_renders_updated_at BEFORE UPDATE ON design_renders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shopping_lists_updated_at BEFORE UPDATE ON shopping_lists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_style_templates_updated_at BEFORE UPDATE ON style_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Sync user tier with active subscription
CREATE OR REPLACE FUNCTION sync_user_tier_from_subscription()
RETURNS TRIGGER AS $$
BEGIN
    -- Update user's current_tier when subscription status changes
    IF NEW.status = 'active' THEN
        UPDATE users
        SET current_tier = NEW.tier
        WHERE id = NEW.user_id;
    ELSIF OLD.status = 'active' AND NEW.status != 'active' THEN
        -- Downgrade to free when subscription becomes inactive
        UPDATE users
        SET current_tier = 'free'
        WHERE id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sync_user_tier AFTER INSERT OR UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION sync_user_tier_from_subscription();

-- Function: Track active projects count
CREATE OR REPLACE FUNCTION update_active_projects_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.deleted_at IS NULL THEN
        UPDATE users
        SET active_projects_count = active_projects_count + 1
        WHERE id = NEW.user_id;
    ELSIF TG_OP = 'UPDATE' AND OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
        UPDATE users
        SET active_projects_count = GREATEST(active_projects_count - 1, 0)
        WHERE id = NEW.user_id;
    ELSIF TG_OP = 'DELETE' AND OLD.deleted_at IS NULL THEN
        UPDATE users
        SET active_projects_count = GREATEST(active_projects_count - 1, 0)
        WHERE id = OLD.user_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER track_active_projects AFTER INSERT OR UPDATE OR DELETE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_active_projects_count();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all user-facing tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE floor_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE style_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE furniture_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE designs ENABLE ROW LEVEL SECURITY;
ALTER TABLE design_renders ENABLE ROW LEVEL SECURITY;
ALTER TABLE design_modifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE exports ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_logs ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Subscriptions table policies
CREATE POLICY "Users can view own subscriptions" ON subscriptions
    FOR SELECT USING (auth.uid() = user_id);

-- Payments table policies
CREATE POLICY "Users can view own payments" ON payments
    FOR SELECT USING (auth.uid() = user_id);

-- Projects table policies
CREATE POLICY "Users can view own projects" ON projects
    FOR SELECT USING (auth.uid() = user_id AND deleted_at IS NULL);

CREATE POLICY "Users can create own projects" ON projects
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own projects" ON projects
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own projects" ON projects
    FOR DELETE USING (auth.uid() = user_id);

-- Floor plans table policies
CREATE POLICY "Users can view own floor plans" ON floor_plans
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM projects
            WHERE projects.id = floor_plans.project_id
            AND projects.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can manage own floor plans" ON floor_plans
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM projects
            WHERE projects.id = floor_plans.project_id
            AND projects.user_id = auth.uid()
        )
    );

-- Style preferences table policies
CREATE POLICY "Users can manage own style preferences" ON style_preferences
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM projects
            WHERE projects.id = style_preferences.project_id
            AND projects.user_id = auth.uid()
        )
    );

-- Furniture items table policies
CREATE POLICY "Users can manage own furniture items" ON furniture_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM projects
            WHERE projects.id = furniture_items.project_id
            AND projects.user_id = auth.uid()
        )
    );

-- Designs table policies
CREATE POLICY "Users can view own designs" ON designs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM projects
            WHERE projects.id = designs.project_id
            AND projects.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can manage own designs" ON designs
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM projects
            WHERE projects.id = designs.project_id
            AND projects.user_id = auth.uid()
        )
    );

-- Design renders table policies
CREATE POLICY "Users can view own design renders" ON design_renders
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM designs
            JOIN projects ON projects.id = designs.project_id
            WHERE designs.id = design_renders.design_id
            AND projects.user_id = auth.uid()
        )
    );

-- Design modifications table policies
CREATE POLICY "Users can view own modifications" ON design_modifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create modifications" ON design_modifications
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Shopping lists table policies
CREATE POLICY "Users can view own shopping lists" ON shopping_lists
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM designs
            JOIN projects ON projects.id = designs.project_id
            WHERE designs.id = shopping_lists.design_id
            AND projects.user_id = auth.uid()
        )
    );

-- Shopping list items table policies
CREATE POLICY "Users can view own shopping list items" ON shopping_list_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM shopping_lists
            JOIN designs ON designs.id = shopping_lists.design_id
            JOIN projects ON projects.id = designs.project_id
            WHERE shopping_lists.id = shopping_list_items.shopping_list_id
            AND projects.user_id = auth.uid()
        )
    );

-- Exports table policies
CREATE POLICY "Users can view own exports" ON exports
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create exports" ON exports
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Usage logs table policies
CREATE POLICY "Users can view own usage logs" ON usage_logs
    FOR SELECT USING (auth.uid() = user_id);

-- Style templates are public (read-only for users)
CREATE POLICY "Anyone can view active style templates" ON style_templates
    FOR SELECT USING (is_active = true);

-- ============================================================================
-- HELPER FUNCTIONS FOR QUOTA CHECKS
-- ============================================================================

-- Function: Check if user can create a new project
CREATE OR REPLACE FUNCTION can_create_project(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_tier subscription_tier;
    v_active_count INTEGER;
    v_max_projects INTEGER;
BEGIN
    SELECT current_tier, active_projects_count
    INTO v_tier, v_active_count
    FROM users
    WHERE id = p_user_id;

    -- Set limits based on tier
    v_max_projects := CASE v_tier
        WHEN 'free' THEN 1
        WHEN 'pro' THEN 5
        WHEN 'studio' THEN 20
        ELSE 0
    END;

    RETURN v_active_count < v_max_projects;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Get user's monthly usage count for an action
CREATE OR REPLACE FUNCTION get_monthly_usage_count(
    p_user_id UUID,
    p_action_type TEXT
)
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM usage_logs
    WHERE user_id = p_user_id
    AND action_type = p_action_type
    AND created_at >= date_trunc('month', NOW());

    RETURN COALESCE(v_count, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Check if user can perform an action based on quota
CREATE OR REPLACE FUNCTION can_perform_action(
    p_user_id UUID,
    p_action_type TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_tier subscription_tier;
    v_credits INTEGER;
    v_usage_count INTEGER;
    v_limit INTEGER;
BEGIN
    SELECT current_tier, credits_balance
    INTO v_tier, v_credits
    FROM users
    WHERE id = p_user_id;

    -- Get current month's usage
    v_usage_count := get_monthly_usage_count(p_user_id, p_action_type);

    -- Set limits based on tier and action type
    v_limit := CASE
        WHEN p_action_type = 'generation' THEN
            CASE v_tier
                WHEN 'free' THEN 1
                WHEN 'pro' THEN 3
                WHEN 'studio' THEN 5
                ELSE 0
            END
        WHEN p_action_type = 'modification' THEN
            CASE v_tier
                WHEN 'free' THEN 2
                WHEN 'pro' THEN 15
                WHEN 'studio' THEN 50
                ELSE 0
            END
        WHEN p_action_type = 'furniture_parse' THEN
            CASE v_tier
                WHEN 'free' THEN 5
                WHEN 'pro' THEN 30
                WHEN 'studio' THEN 50
                ELSE 0
            END
        ELSE 999999 -- No limit for other actions
    END;

    -- Check if within quota or has credits
    RETURN v_usage_count < v_limit OR v_credits > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- EXAMPLE QUERIES
-- ============================================================================

-- Example 1: Get user's current subscription details
-- SELECT
--     u.email,
--     u.current_tier,
--     u.active_projects_count,
--     u.credits_balance,
--     s.status AS subscription_status,
--     s.current_period_end
-- FROM users u
-- LEFT JOIN subscriptions s ON s.user_id = u.id AND s.status = 'active'
-- WHERE u.id = '<user_id>';

-- Example 2: Get all projects for a user with their latest design
-- SELECT
--     p.id,
--     p.name,
--     p.type,
--     p.status,
--     p.created_at,
--     d.id AS latest_design_id,
--     d.version_number,
--     d.status AS design_status
-- FROM projects p
-- LEFT JOIN LATERAL (
--     SELECT id, version_number, status
--     FROM designs
--     WHERE project_id = p.id
--     ORDER BY version_number DESC
--     LIMIT 1
-- ) d ON true
-- WHERE p.user_id = '<user_id>' AND p.deleted_at IS NULL
-- ORDER BY p.updated_at DESC;

-- Example 3: Get shopping list with items for a design
-- SELECT
--     sl.room_name,
--     sli.product_name,
--     sli.brand,
--     sli.category,
--     sli.quantity,
--     sli.width_cm,
--     sli.depth_cm,
--     sli.height_cm,
--     sli.price_cents / 100.0 AS price_dollars,
--     sli.source_url
-- FROM shopping_lists sl
-- JOIN shopping_list_items sli ON sli.shopping_list_id = sl.id
-- WHERE sl.design_id = '<design_id>'
-- ORDER BY sl.room_name, sli.category;

-- Example 4: Get user's monthly usage statistics
-- SELECT
--     action_type,
--     COUNT(*) AS usage_count,
--     SUM(credits_consumed) AS total_credits_used
-- FROM usage_logs
-- WHERE user_id = '<user_id>'
-- AND created_at >= date_trunc('month', NOW())
-- GROUP BY action_type
-- ORDER BY usage_count DESC;

-- Example 5: Get all furniture items for a project with parsing status
-- SELECT
--     fi.id,
--     fi.product_name,
--     fi.category,
--     fi.status,
--     fi.priority,
--     fi.width_cm,
--     fi.depth_cm,
--     fi.height_cm,
--     fi.source_url,
--     fi.parse_error
-- FROM furniture_items fi
-- WHERE fi.project_id = '<project_id>'
-- ORDER BY fi.priority DESC, fi.created_at;

-- Example 6: Check quota before allowing action
-- SELECT can_perform_action('<user_id>', 'generation') AS can_generate;
-- SELECT can_create_project('<user_id>') AS can_create;

-- Example 7: Get payment history for a user
-- SELECT
--     p.id,
--     p.description,
--     p.amount_cents / 100.0 AS amount_dollars,
--     p.currency,
--     p.status,
--     p.created_at,
--     p.paid_at
-- FROM payments p
-- WHERE p.user_id = '<user_id>'
-- ORDER BY p.created_at DESC
-- LIMIT 20;

-- ============================================================================
-- DATABASE ER DIAGRAM (Mermaid Format)
-- ============================================================================

/*
```mermaid
erDiagram
    users ||--o{ subscriptions : "has"
    users ||--o{ payments : "makes"
    users ||--o{ projects : "creates"
    users ||--o{ usage_logs : "generates"
    users ||--o{ exports : "creates"
    users ||--o{ design_modifications : "makes"

    subscriptions {
        uuid id PK
        uuid user_id FK
        text stripe_subscription_id
        subscription_tier tier
        subscription_status status
        timestamptz current_period_start
        timestamptz current_period_end
    }

    payments {
        uuid id PK
        uuid user_id FK
        text stripe_payment_intent_id
        integer amount_cents
        payment_status status
        text description
    }

    projects ||--o{ floor_plans : "has"
    projects ||--o| style_preferences : "has"
    projects ||--o{ furniture_items : "contains"
    projects ||--o{ designs : "generates"

    projects {
        uuid id PK
        uuid user_id FK
        text name
        project_type type
        project_status status
        decimal total_area_sqm
        integer ceiling_height_cm
    }

    floor_plans {
        uuid id PK
        uuid project_id FK
        text original_file_url
        decimal scale_ratio
        jsonb detected_rooms
        boolean is_confirmed
    }

    style_preferences {
        uuid id PK
        uuid project_id FK
        design_style primary_style
        jsonb color_palette
        jsonb reference_images
    }

    furniture_items {
        uuid id PK
        uuid project_id FK
        text source_url
        furniture_status status
        text product_name
        decimal width_cm
        decimal depth_cm
        decimal height_cm
        furniture_priority priority
    }

    designs ||--o{ design_renders : "has"
    designs ||--o{ shopping_lists : "generates"
    designs ||--o{ design_modifications : "receives"
    designs ||--o{ exports : "exported_as"

    designs {
        uuid id PK
        uuid project_id FK
        integer version_number
        generation_status status
        jsonb layout_data
        text layout_image_url
        boolean is_valid
    }

    design_renders {
        uuid id PK
        uuid design_id FK
        text room_name
        text view_angle
        text low_res_url
        text high_res_url
        text ultra_res_url
    }

    shopping_lists ||--o{ shopping_list_items : "contains"

    shopping_lists {
        uuid id PK
        uuid design_id FK
        text room_name
        integer total_items
        text pdf_url
        text csv_url
    }

    shopping_list_items {
        uuid id PK
        uuid shopping_list_id FK
        uuid furniture_item_id FK
        text product_name
        integer quantity
        integer price_cents
    }

    style_templates {
        uuid id PK
        text name
        design_style style
        jsonb default_color_palette
        boolean is_active
    }
```
*/

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
