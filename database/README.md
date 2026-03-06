# AI Interior Design Platform - Database Schema Documentation

## Overview
Complete PostgreSQL/Supabase database schema for clawlist.store AI interior design platform.

**File**: `/Users/chengyadong/clawd/projects/ai-interior-design/database/schema.sql`
**Lines**: 1,157
**Created**: 2026-03-06

## Database Structure

### Core Tables (14 tables)

1. **users** - User profiles and subscription info
2. **subscriptions** - Subscription history and status
3. **payments** - Payment transactions (subscriptions + credit packs)
4. **projects** - User interior design projects
5. **floor_plans** - Uploaded floor plan images and calibration
6. **style_preferences** - Style choices per project
7. **furniture_items** - Furniture submitted via links or manual input
8. **designs** - Generated design versions
9. **design_renders** - Rendered images (multiple views)
10. **design_modifications** - User modification history
11. **shopping_lists** - Generated shopping lists per design
12. **shopping_list_items** - Individual items in shopping lists
13. **exports** - Export history (images, PDFs, CSVs)
14. **usage_logs** - Feature usage tracking for quotas
15. **style_templates** - Pre-defined style templates (admin-managed)

### Enums (9 types)

- `subscription_tier`: free, pro, studio
- `subscription_status`: active, canceled, past_due, trialing, incomplete
- `payment_status`: pending, succeeded, failed, refunded
- `project_type`: single_room, full_house
- `project_status`: draft, floor_plan_uploaded, style_selected, furniture_added, generated, completed
- `generation_status`: pending, processing, completed, failed
- `furniture_status`: pending_parse, parsed, parse_failed, manual_input
- `furniture_priority`: must_use, replaceable
- `design_style`: modern, industrial, scandinavian, minimalist, traditional, eclectic
- `export_format`: jpg, png, pdf, csv

## Key Features

### 1. Automatic Triggers
- **updated_at**: Auto-updates timestamp on all relevant tables
- **sync_user_tier**: Syncs user tier with active subscription
- **track_active_projects**: Maintains active project count

### 2. Row Level Security (RLS)
All tables have RLS policies ensuring:
- Users can only access their own data
- Project-related data is accessible only to project owners
- Style templates are publicly readable

### 3. Quota Management Functions

**can_create_project(user_id)** - Checks project creation limits:
- Free: 1 project
- Pro: 5 projects
- Studio: 20 projects

**can_perform_action(user_id, action_type)** - Checks monthly quotas:
- Generations: Free(1), Pro(3), Studio(5)
- Modifications: Free(2), Pro(15), Studio(50)
- Furniture parsing: Free(5), Pro(30), Studio(50)

**get_monthly_usage_count(user_id, action_type)** - Returns current month usage

### 4. Data Relationships

```
users
  ├── subscriptions (1:many)
  ├── payments (1:many)
  ├── projects (1:many)
  │     ├── floor_plans (1:many)
  │     ├── style_preferences (1:1)
  │     ├── furniture_items (1:many)
  │     └── designs (1:many)
  │           ├── design_renders (1:many)
  │           ├── shopping_lists (1:many)
  │           │     └── shopping_list_items (1:many)
  │           ├── design_modifications (1:many)
  │           └── exports (1:many)
  ├── usage_logs (1:many)
  └── exports (1:many)
```

## Performance Optimizations

### Indexes Created (40+ indexes)
- Primary keys on all tables (UUID)
- Foreign key indexes for all relationships
- Composite indexes for common queries
- Partial indexes for soft deletes and active records
- Unique constraints for business rules

### Key Indexes
- `idx_projects_user_id` - Fast project lookups per user
- `idx_designs_project_version` - Unique version numbers per project
- `idx_usage_logs_user_month` - Fast monthly quota checks
- `idx_subscriptions_user_active` - One active subscription per user

## Security Features

### 1. RLS Policies
- Users can only view/modify their own data
- Nested policies for related tables (e.g., designs through projects)
- Public read access for style templates

### 2. Soft Deletes
- Projects use `deleted_at` for soft deletion
- Maintains data integrity while allowing "deletion"

### 3. Stripe Integration
- Secure payment handling via Stripe
- No credit card data stored locally
- PCI DSS compliant

## Example Queries

### Get user subscription details
```sql
SELECT u.email, u.current_tier, u.active_projects_count,
       s.status, s.current_period_end
FROM users u
LEFT JOIN subscriptions s ON s.user_id = u.id AND s.status = 'active'
WHERE u.id = '<user_id>';
```

### Get projects with latest design
```sql
SELECT p.id, p.name, p.status, d.version_number, d.status AS design_status
FROM projects p
LEFT JOIN LATERAL (
    SELECT id, version_number, status
    FROM designs WHERE project_id = p.id
    ORDER BY version_number DESC LIMIT 1
) d ON true
WHERE p.user_id = '<user_id>' AND p.deleted_at IS NULL;
```

### Check quota before action
```sql
SELECT can_perform_action('<user_id>', 'generation') AS can_generate;
SELECT can_create_project('<user_id>') AS can_create;
```

## Deployment Steps

### 1. Create Supabase Project
```bash
# Via Supabase Dashboard or CLI
supabase projects create ai-interior-design
```

### 2. Run Schema
```bash
# Execute schema.sql in Supabase SQL Editor
# Or via CLI:
psql $DATABASE_URL -f schema.sql
```

### 3. Verify Installation
```sql
-- Check tables
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';

-- Check RLS policies
SELECT tablename, policyname FROM pg_policies;

-- Check functions
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public';
```

## Storage Buckets Required

Create these Supabase Storage buckets:
1. **floor-plans** - Original and processed floor plan images
2. **reference-images** - User-uploaded style reference images
3. **design-renders** - Generated design render images
4. **exports** - Exported PDFs, CSVs, high-res images
5. **furniture-images** - Cached furniture product images

### Bucket Policies
```sql
-- Public read for design renders (with signed URLs)
-- Private for user uploads (RLS-protected)
```

## Environment Variables

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxx...
SUPABASE_SERVICE_ROLE_KEY=eyJxxx...

# Stripe
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_xxx

# AI Services
AI_IMAGE_RECOGNITION_API_KEY=xxx
AI_RENDER_ENGINE_API_KEY=xxx
```

## Migration Strategy

For future schema changes:
1. Use Supabase migrations: `supabase migration new <name>`
2. Test in staging environment first
3. Backup production data before applying
4. Use transactions for multi-step migrations

## Monitoring Queries

### Active users by tier
```sql
SELECT current_tier, COUNT(*)
FROM users
WHERE deleted_at IS NULL
GROUP BY current_tier;
```

### Monthly revenue
```sql
SELECT DATE_TRUNC('month', paid_at) AS month,
       SUM(amount_cents) / 100.0 AS revenue
FROM payments
WHERE status = 'succeeded'
GROUP BY month
ORDER BY month DESC;
```

### Popular features
```sql
SELECT action_type, COUNT(*) AS usage_count
FROM usage_logs
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY action_type
ORDER BY usage_count DESC;
```

## Notes

- All monetary values stored in cents (INTEGER) to avoid floating-point issues
- All dimensions in centimeters (DECIMAL) for precision
- Timestamps use TIMESTAMPTZ for timezone awareness
- JSONB used for flexible/evolving data structures
- UUIDs for all primary keys (better for distributed systems)

## Support

For schema questions or issues:
- Check example queries in schema.sql
- Review RLS policies for access issues
- Use helper functions for quota checks
- Monitor usage_logs for debugging