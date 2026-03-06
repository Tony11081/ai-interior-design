# Database Migration Guide

## Quick Start

### 1. Create Supabase Project

```bash
# Via Supabase Dashboard
# 1. Go to https://supabase.com/dashboard
# 2. Click "New Project"
# 3. Name: "ai-interior-design"
# 4. Database Password: [Generate strong password]
# 5. Region: Choose closest to your users
# 6. Click "Create new project"
```

### 2. Run Schema

```bash
# Option A: Via Supabase SQL Editor (Recommended)
# 1. Open your project in Supabase Dashboard
# 2. Go to SQL Editor
# 3. Click "New Query"
# 4. Copy entire contents of schema.sql
# 5. Click "Run"

# Option B: Via psql CLI
psql "postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres" \
  -f /Users/chengyadong/clawd/projects/ai-interior-design/database/schema.sql
```

### 3. Create Storage Buckets

```sql
-- Run in Supabase SQL Editor
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('floor-plans', 'floor-plans', false),
  ('reference-images', 'reference-images', false),
  ('design-renders', 'design-renders', false),
  ('exports', 'exports', false),
  ('furniture-images', 'furniture-images', true);
```

### 4. Set Storage Policies

```sql
-- Floor plans bucket policy
CREATE POLICY "Users can upload own floor plans"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'floor-plans' AND
  (storage.foldername(name))[1] IN (
    SELECT id::text FROM projects WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Users can view own floor plans"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'floor-plans' AND
  (storage.foldername(name))[1] IN (
    SELECT id::text FROM projects WHERE user_id = auth.uid()
  )
);

-- Reference images bucket policy
CREATE POLICY "Users can upload own reference images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'reference-images' AND
  (storage.foldername(name))[1] IN (
    SELECT id::text FROM projects WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Users can view own reference images"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'reference-images' AND
  (storage.foldername(name))[1] IN (
    SELECT id::text FROM projects WHERE user_id = auth.uid()
  )
);

-- Design renders bucket policy
CREATE POLICY "Users can view own design renders"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'design-renders' AND
  (storage.foldername(name))[1] IN (
    SELECT d.id::text FROM designs d
    JOIN projects p ON p.id = d.project_id
    WHERE p.user_id = auth.uid()
  )
);

-- Exports bucket policy
CREATE POLICY "Users can view own exports"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'exports' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Furniture images are public (cached product images)
CREATE POLICY "Anyone can view furniture images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'furniture-images');
```

### 5. Verify Installation

```sql
-- Check tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Expected output: 15 tables
-- design_modifications, design_renders, designs, exports,
-- floor_plans, furniture_items, payments, projects,
-- shopping_list_items, shopping_lists, style_preferences,
-- style_templates, subscriptions, usage_logs, users

-- Check RLS policies
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Check functions
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- Expected functions:
-- can_create_project, can_perform_action, get_monthly_usage_count,
-- sync_user_tier_from_subscription, update_active_projects_count,
-- update_updated_at_column

-- Check triggers
SELECT trigger_name, event_object_table, action_timing, event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- Check storage buckets
SELECT id, name, public
FROM storage.buckets
ORDER BY name;
```

### 6. Seed Initial Data (Optional)

```sql
-- Insert default style templates
INSERT INTO style_templates (name, style, description, is_active, sort_order)
VALUES
  ('Modern Minimalist', 'modern', 'Clean lines, neutral colors, minimal decoration', true, 1),
  ('Industrial Loft', 'industrial', 'Exposed brick, metal accents, raw materials', true, 2),
  ('Scandinavian Cozy', 'scandinavian', 'Light wood, white walls, hygge vibes', true, 3),
  ('Classic Traditional', 'traditional', 'Elegant furniture, rich colors, timeless style', true, 4),
  ('Eclectic Mix', 'eclectic', 'Mix of styles, bold colors, personal expression', true, 5);

-- Verify
SELECT id, name, style, is_active FROM style_templates ORDER BY sort_order;
```

## Environment Variables

Add these to your `.env.local`:

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://[PROJECT-REF].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Get these from: Project Settings → API
```

## Testing the Database

### Test 1: Create a test user

```sql
-- This simulates Supabase Auth creating a user
-- In production, use Supabase Auth API
INSERT INTO auth.users (id, email)
VALUES ('00000000-0000-0000-0000-000000000001', 'test@example.com');

INSERT INTO users (id, email, full_name, current_tier)
VALUES ('00000000-0000-0000-0000-000000000001', 'test@example.com', 'Test User', 'free');

-- Verify
SELECT id, email, current_tier, active_projects_count FROM users;
```

### Test 2: Create a test project

```sql
INSERT INTO projects (user_id, name, type, status, total_area_sqm, ceiling_height_cm)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'My Living Room',
  'single_room',
  'draft',
  25.5,
  280
);

-- Verify active_projects_count increased
SELECT id, email, active_projects_count FROM users
WHERE id = '00000000-0000-0000-0000-000000000001';
-- Should show active_projects_count = 1
```

### Test 3: Test quota function

```sql
-- Check if user can create another project
SELECT can_create_project('00000000-0000-0000-0000-000000000001');
-- Should return false (free tier = 1 project max)

-- Upgrade to pro
UPDATE users
SET current_tier = 'pro'
WHERE id = '00000000-0000-0000-0000-000000000001';

-- Check again
SELECT can_create_project('00000000-0000-0000-0000-000000000001');
-- Should return true (pro tier = 5 projects max)
```

### Test 4: Test RLS policies

```sql
-- Set session to test user
SET request.jwt.claims = '{"sub": "00000000-0000-0000-0000-000000000001"}';

-- This should work (user's own project)
SELECT * FROM projects WHERE user_id = '00000000-0000-0000-0000-000000000001';

-- Create another user
INSERT INTO auth.users (id, email)
VALUES ('00000000-0000-0000-0000-000000000002', 'other@example.com');

INSERT INTO users (id, email, full_name)
VALUES ('00000000-0000-0000-0000-000000000002', 'other@example.com', 'Other User');

-- This should return empty (not user's project)
SELECT * FROM projects WHERE user_id = '00000000-0000-0000-0000-000000000002';
```

### Test 5: Clean up test data

```sql
-- Delete test users (cascades to all related data)
DELETE FROM users WHERE email IN ('test@example.com', 'other@example.com');
DELETE FROM auth.users WHERE email IN ('test@example.com', 'other@example.com');
```

## Common Issues & Solutions

### Issue 1: RLS policies blocking queries

**Symptom**: Queries return empty results even though data exists

**Solution**: Check if you're using the correct authentication context
```sql
-- For server-side operations, use service role key
-- For client-side operations, ensure user is authenticated
```

### Issue 2: Trigger not firing

**Symptom**: `updated_at` not updating, or `active_projects_count` incorrect

**Solution**: Check trigger exists and is enabled
```sql
SELECT trigger_name, event_object_table, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
AND event_object_table = 'projects';
```

### Issue 3: Foreign key constraint violation

**Symptom**: Cannot insert record due to missing parent

**Solution**: Ensure parent record exists first
```sql
-- Check if project exists before inserting floor_plan
SELECT id FROM projects WHERE id = '<project_id>';
```

### Issue 4: Enum value not recognized

**Symptom**: `invalid input value for enum`

**Solution**: Check enum values
```sql
SELECT enumlabel FROM pg_enum
WHERE enumtypid = 'subscription_tier'::regtype;
```

## Rollback Plan

If you need to rollback the schema:

```sql
-- WARNING: This will delete ALL data!

-- Drop all tables (in reverse dependency order)
DROP TABLE IF EXISTS usage_logs CASCADE;
DROP TABLE IF EXISTS exports CASCADE;
DROP TABLE IF EXISTS shopping_list_items CASCADE;
DROP TABLE IF EXISTS shopping_lists CASCADE;
DROP TABLE IF EXISTS design_modifications CASCADE;
DROP TABLE IF EXISTS design_renders CASCADE;
DROP TABLE IF EXISTS designs CASCADE;
DROP TABLE IF EXISTS furniture_items CASCADE;
DROP TABLE IF EXISTS style_preferences CASCADE;
DROP TABLE IF EXISTS floor_plans CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS style_templates CASCADE;

-- Drop enums
DROP TYPE IF EXISTS export_format CASCADE;
DROP TYPE IF EXISTS design_style CASCADE;
DROP TYPE IF EXISTS furniture_priority CASCADE;
DROP TYPE IF EXISTS furniture_status CASCADE;
DROP TYPE IF EXISTS generation_status CASCADE;
DROP TYPE IF EXISTS project_status CASCADE;
DROP TYPE IF EXISTS project_type CASCADE;
DROP TYPE IF EXISTS payment_status CASCADE;
DROP TYPE IF EXISTS subscription_status CASCADE;
DROP TYPE IF EXISTS subscription_tier CASCADE;

-- Drop functions
DROP FUNCTION IF EXISTS update_updated_at_column CASCADE;
DROP FUNCTION IF EXISTS sync_user_tier_from_subscription CASCADE;
DROP FUNCTION IF EXISTS update_active_projects_count CASCADE;
DROP FUNCTION IF EXISTS can_create_project CASCADE;
DROP FUNCTION IF EXISTS get_monthly_usage_count CASCADE;
DROP FUNCTION IF EXISTS can_perform_action CASCADE;
```

## Next Steps

After database setup:

1. **Configure Supabase Auth**
   - Enable email/password authentication
   - Set up OAuth providers (Google, GitHub, etc.)
   - Configure email templates

2. **Set up Stripe Webhooks**
   - Create webhook endpoint in your app
   - Configure Stripe to send events
   - Handle subscription events

3. **Implement API Routes**
   - Project CRUD operations
   - Design generation endpoints
   - Payment processing

4. **Add Monitoring**
   - Set up Supabase logs
   - Monitor query performance
   - Track usage patterns

5. **Backup Strategy**
   - Enable Supabase automatic backups
   - Set up manual backup schedule
   - Test restore process

## Support

For issues or questions:
- Check Supabase docs: https://supabase.com/docs
- Review schema comments in schema.sql
- Test with example queries in README.md