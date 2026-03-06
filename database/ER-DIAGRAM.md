# Database ER Diagram

## Entity Relationship Diagram (Mermaid)

```mermaid
erDiagram
    users ||--o{ subscriptions : "has"
    users ||--o{ payments : "makes"
    users ||--o{ projects : "creates"
    users ||--o{ usage_logs : "generates"
    users ||--o{ exports : "creates"
    users ||--o{ design_modifications : "makes"

    users {
        uuid id PK
        text email UK
        text full_name
        subscription_tier current_tier
        text stripe_customer_id UK
        integer active_projects_count
        integer credits_balance
        timestamptz created_at
        timestamptz deleted_at
    }

    subscriptions {
        uuid id PK
        uuid user_id FK
        text stripe_subscription_id UK
        text stripe_price_id
        subscription_tier tier
        subscription_status status
        timestamptz current_period_start
        timestamptz current_period_end
        boolean cancel_at_period_end
    }

    payments {
        uuid id PK
        uuid user_id FK
        text stripe_payment_intent_id UK
        integer amount_cents
        text currency
        payment_status status
        text description
        jsonb metadata
        timestamptz paid_at
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
        integer num_residents
        jsonb usage_preferences
        timestamptz deleted_at
    }

    floor_plans {
        uuid id PK
        uuid project_id FK
        text original_file_url
        text processed_file_url
        text file_name
        decimal scale_ratio
        jsonb calibration_data
        jsonb detected_rooms
        decimal detection_confidence
        boolean is_confirmed
        jsonb user_edits
    }

    style_preferences {
        uuid id PK
        uuid project_id FK UK
        design_style primary_style
        boolean allow_mixing
        jsonb color_palette
        jsonb material_preferences
        text lighting_preference
        text budget_level
        jsonb reference_images
    }

    furniture_items {
        uuid id PK
        uuid project_id FK
        text source_url
        text source_type
        furniture_status status
        text parse_error
        text product_name
        text brand
        text category
        decimal width_cm
        decimal depth_cm
        decimal height_cm
        text color
        text material
        furniture_priority priority
        integer price_cents
        jsonb metadata
    }

    designs ||--o{ design_renders : "has"
    designs ||--o{ shopping_lists : "generates"
    designs ||--o{ design_modifications : "receives"
    designs ||--o{ exports : "exported_as"

    designs {
        uuid id PK
        uuid project_id FK
        integer version_number
        boolean is_active
        jsonb generation_params
        jsonb target_rooms
        generation_status status
        text error_message
        jsonb layout_data
        text layout_image_url
        jsonb validation_results
        boolean is_valid
        text design_rationale
        text circulation_analysis
    }

    design_renders {
        uuid id PK
        uuid design_id FK
        text room_name
        text view_angle
        text low_res_url
        text high_res_url
        text ultra_res_url
        integer render_time_seconds
        text render_engine
    }

    design_modifications {
        uuid id PK
        uuid design_id FK
        uuid user_id FK
        text modification_type
        text instruction
        jsonb changes
        boolean resulted_in_new_version
        uuid new_design_id FK
    }

    shopping_lists ||--o{ shopping_list_items : "contains"

    shopping_lists {
        uuid id PK
        uuid design_id FK
        text room_name
        integer total_items
        integer total_price_cents
        text pdf_url
        text csv_url
    }

    shopping_list_items {
        uuid id PK
        uuid shopping_list_id FK
        uuid furniture_item_id FK
        text product_name
        text brand
        text category
        integer quantity
        decimal width_cm
        decimal depth_cm
        decimal height_cm
        text source_url
        integer price_cents
        text placement_notes
    }

    exports {
        uuid id PK
        uuid user_id FK
        uuid design_id FK
        export_format format
        text file_url
        integer file_size_bytes
        jsonb export_settings
        timestamptz expires_at
    }

    usage_logs {
        uuid id PK
        uuid user_id FK
        text action_type
        uuid resource_id
        integer credits_consumed
        subscription_tier tier_at_time
        jsonb metadata
        timestamptz created_at
    }

    style_templates {
        uuid id PK
        text name UK
        design_style style
        text description
        text thumbnail_url
        jsonb example_images
        jsonb default_color_palette
        jsonb default_materials
        text default_lighting
        boolean is_active
        integer sort_order
    }
```

## Table Relationships Summary

### User Management
- **users** → subscriptions (1:many)
- **users** → payments (1:many)
- **users** → usage_logs (1:many)

### Project Hierarchy
- **users** → projects (1:many)
- **projects** → floor_plans (1:many)
- **projects** → style_preferences (1:1)
- **projects** → furniture_items (1:many)
- **projects** → designs (1:many)

### Design Outputs
- **designs** → design_renders (1:many)
- **designs** → shopping_lists (1:many)
- **designs** → design_modifications (1:many)
- **designs** → exports (1:many)

### Shopping Lists
- **shopping_lists** → shopping_list_items (1:many)
- **shopping_list_items** → furniture_items (many:1, optional)

## Key Constraints

### Unique Constraints
1. One active subscription per user
2. Unique version numbers per project
3. One style preference per project
4. Unique email per user
5. Unique Stripe IDs

### Foreign Key Cascades
- **ON DELETE CASCADE**: Most child records deleted when parent is deleted
- **ON DELETE SET NULL**: Optional references (e.g., furniture_item_id in shopping_list_items)

### Check Constraints
- Amount values must be positive (enforced at application level)
- Dimensions must be positive (enforced at application level)
- Version numbers start from 1 (enforced at application level)

## Indexes Strategy

### Performance Indexes
1. **User lookups**: email, stripe_customer_id
2. **Project queries**: user_id, status, created_at
3. **Design versions**: (project_id, version_number)
4. **Quota checks**: (user_id, date_trunc('month', created_at))
5. **Shopping lists**: design_id, room_name

### Partial Indexes
1. Active subscriptions: `WHERE status = 'active'`
2. Non-deleted projects: `WHERE deleted_at IS NULL`
3. Expiring exports: `WHERE expires_at IS NOT NULL`

## Data Flow

### Project Creation Flow
```
User creates project
  → Project record created
  → Upload floor plan
    → Floor plan record created
    → AI processes image
    → Detected rooms stored in JSONB
  → User confirms/edits floor plan
  → Select style preferences
    → Style preference record created
  → Add furniture items
    → Furniture items created
    → AI parses product links
    → Dimensions extracted
  → Generate design
    → Design record created (version 1)
    → Layout algorithm runs
    → Design renders created
    → Shopping list generated
    → Shopping list items created
  → User exports
    → Export record created
    → Usage log created
```

### Subscription Flow
```
User signs up (Free tier)
  → User record created
  → No subscription record (free tier)
User upgrades to Pro
  → Stripe checkout
  → Payment record created
  → Subscription record created
  → User.current_tier updated to 'pro'
Subscription renews
  → Stripe webhook
  → Payment record created
  → Subscription.current_period_end updated
User cancels
  → Subscription.cancel_at_period_end = true
  → At period end:
    → Subscription.status = 'canceled'
    → User.current_tier = 'free'
```

## Storage Buckets

### Required Supabase Storage Buckets

1. **floor-plans**
   - Original uploads: `{project_id}/original/{filename}`
   - Processed: `{project_id}/processed/{filename}`
   - RLS: User must own project

2. **reference-images**
   - Path: `{project_id}/references/{filename}`
   - RLS: User must own project

3. **design-renders**
   - Path: `{design_id}/{room_name}/{view_angle}_{resolution}.jpg`
   - RLS: User must own design's project

4. **exports**
   - Path: `{user_id}/{design_id}/{timestamp}_{format}.{ext}`
   - RLS: User must own export

5. **furniture-images**
   - Path: `cache/{hash}.jpg`
   - Public read (cached product images)

## Security Considerations

### RLS Policies
- All user data protected by RLS
- Nested checks for related tables
- Service role bypasses RLS for admin operations

### Sensitive Data
- No credit card data stored
- Stripe handles all payment processing
- User emails encrypted at rest (Supabase default)

### API Security
- Use service role key only in server-side code
- Anon key for client-side (RLS enforced)
- Validate all user inputs
- Rate limit API endpoints

## Performance Tips

1. **Use JSONB indexes** for frequently queried JSON fields
2. **Partition usage_logs** by month for large datasets
3. **Archive old exports** after expiration
4. **Cache style_templates** in application layer
5. **Use connection pooling** (Supabase default)

## Backup Strategy

1. **Supabase automatic backups**: Daily (retained 7 days)
2. **Manual backups**: Before major migrations
3. **Export critical data**: User projects, designs
4. **Test restore process**: Monthly verification