# AI Interior Design Platform - Database Package

Complete Supabase/PostgreSQL database schema for **clawlist.store** AI interior design platform.

## 📦 Package Contents

| File | Lines | Description |
|------|-------|-------------|
| **schema.sql** | 1,157 | Complete PostgreSQL schema with tables, indexes, RLS, triggers |
| **types.ts** | 533 | TypeScript type definitions for all tables and enums |
| **README.md** | 262 | Comprehensive documentation and usage guide |
| **MIGRATION.md** | 395 | Step-by-step migration and setup instructions |
| **ER-DIAGRAM.md** | 384 | Entity relationship diagram and data flow |

**Total**: 2,731 lines of production-ready database code

## 🚀 Quick Start

### 1. Create Supabase Project
```bash
# Go to https://supabase.com/dashboard
# Click "New Project" → Name: "ai-interior-design"
```

### 2. Run Schema
```bash
# Copy schema.sql contents into Supabase SQL Editor
# Click "Run"
```

### 3. Verify Installation
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';
-- Should return 15 tables
```

### 4. Add to Your Project
```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js';
import type { Database } from '@/database/types';

export const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);
```

## 📊 Database Overview

### Tables (15)
- **users** - User profiles and subscription info
- **subscriptions** - Subscription management
- **payments** - Payment transactions
- **projects** - Interior design projects
- **floor_plans** - Uploaded floor plans
- **style_preferences** - Style choices
- **furniture_items** - Furniture catalog
- **designs** - Generated designs
- **design_renders** - Rendered images
- **design_modifications** - Modification history
- **shopping_lists** - Shopping lists
- **shopping_list_items** - List items
- **exports** - Export history
- **usage_logs** - Usage tracking
- **style_templates** - Style presets

### Features
✅ Row Level Security (RLS) on all tables
✅ Automatic timestamp updates
✅ Quota management functions
✅ Soft delete support
✅ Stripe integration ready
✅ 40+ optimized indexes
✅ Comprehensive triggers
✅ Full TypeScript types

## 📖 Documentation

### For Developers
- **README.md** - API reference, example queries, monitoring
- **types.ts** - TypeScript types for type-safe queries
- **MIGRATION.md** - Setup instructions and troubleshooting

### For Architects
- **schema.sql** - Complete schema with comments
- **ER-DIAGRAM.md** - Visual data model and relationships

## 🔐 Security Features

### Row Level Security (RLS)
All tables protected with RLS policies:
```sql
-- Users can only access their own data
CREATE POLICY "Users can view own projects" ON projects
    FOR SELECT USING (auth.uid() = user_id);
```

### Data Protection
- Soft deletes for projects
- Cascade deletes for related data
- Foreign key constraints
- Unique constraints on business rules

### Stripe Integration
- No credit card data stored
- Webhook-ready payment tracking
- PCI DSS compliant

## 📈 Performance

### Optimized Indexes
- Primary keys (UUID) on all tables
- Foreign key indexes
- Composite indexes for common queries
- Partial indexes for active records

### Query Performance
```sql
-- Fast project lookup with latest design
SELECT p.*, d.version_number
FROM projects p
LEFT JOIN LATERAL (
    SELECT version_number FROM designs
    WHERE project_id = p.id
    ORDER BY version_number DESC LIMIT 1
) d ON true
WHERE p.user_id = $1;
```

## 🎯 Quota Management

Built-in quota checking functions:

```typescript
// Check if user can create project
const canCreate = await supabase.rpc('can_create_project', {
  p_user_id: userId
});

// Check if user can perform action
const canGenerate = await supabase.rpc('can_perform_action', {
  p_user_id: userId,
  p_action_type: 'generation'
});
```

### Quota Limits

| Feature | Free | Pro | Studio |
|---------|------|-----|--------|
| Projects | 1 | 5 | 20 |
| Generations | 1 | 3 | 5 |
| Modifications | 2 | 15 | 50 |
| Furniture Parse | 5 | 30 | 50 |

## 💾 Storage Buckets

Required Supabase Storage buckets:
1. **floor-plans** - Floor plan images
2. **reference-images** - Style references
3. **design-renders** - Generated renders
4. **exports** - Exported files
5. **furniture-images** - Product images (public)

## 🔄 Data Flow

```
User creates project
  → Upload floor plan
    → AI processes image
    → User confirms
  → Select style
  → Add furniture
    → AI parses links
  → Generate design
    → Create renders
    → Generate shopping list
  → Export results
```

## 📝 Example Usage

### Create Project
```typescript
const { data: project } = await supabase
  .from('projects')
  .insert({
    user_id: userId,
    name: 'My Living Room',
    type: 'single_room',
    total_area_sqm: 25.5,
    ceiling_height_cm: 280
  })
  .select()
  .single();
```

### Get Project with Details
```typescript
const { data: project } = await supabase
  .from('projects')
  .select(`
    *,
    floor_plans(*),
    style_preference:style_preferences(*),
    furniture_items(*),
    designs(
      *,
      renders:design_renders(*),
      shopping_lists(
        *,
        items:shopping_list_items(*)
      )
    )
  `)
  .eq('id', projectId)
  .single();
```

### Check User Quota
```typescript
const { data: canCreate } = await supabase
  .rpc('can_create_project', { p_user_id: userId });

if (!canCreate) {
  // Show upgrade prompt
}
```

## 🧪 Testing

### Run Tests
```sql
-- Test user creation
INSERT INTO users (id, email, current_tier)
VALUES ('test-uuid', 'test@example.com', 'free');

-- Test project creation
INSERT INTO projects (user_id, name, type)
VALUES ('test-uuid', 'Test Project', 'single_room');

-- Verify active_projects_count increased
SELECT active_projects_count FROM users WHERE id = 'test-uuid';
-- Should return 1
```

## 🛠️ Maintenance

### Backup
```bash
# Supabase automatic backups: Daily (7 days retention)
# Manual backup before migrations
pg_dump $DATABASE_URL > backup.sql
```

### Monitoring
```sql
-- Active users by tier
SELECT current_tier, COUNT(*) FROM users GROUP BY current_tier;

-- Monthly revenue
SELECT DATE_TRUNC('month', paid_at) AS month,
       SUM(amount_cents) / 100.0 AS revenue
FROM payments WHERE status = 'succeeded'
GROUP BY month ORDER BY month DESC;

-- Popular features
SELECT action_type, COUNT(*) FROM usage_logs
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY action_type ORDER BY COUNT(*) DESC;
```

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Stripe Integration Guide](https://stripe.com/docs)

## 🤝 Support

For issues or questions:
1. Check **MIGRATION.md** for setup issues
2. Review **README.md** for API questions
3. Inspect **schema.sql** for schema details
4. Examine **ER-DIAGRAM.md** for data relationships

## 📄 License

Part of the AI Interior Design Platform (clawlist.store)
Created: 2026-03-06

---

**Ready to deploy!** Follow MIGRATION.md for step-by-step setup instructions.