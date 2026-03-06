// ============================================================================
// AI Interior Design Platform - TypeScript Types
// ============================================================================
// Auto-generated from database schema
// Version: 1.0 MVP
// ============================================================================

// ============================================================================
// ENUMS
// ============================================================================

export type SubscriptionTier = 'free' | 'pro' | 'studio';

export type SubscriptionStatus =
  | 'active'
  | 'canceled'
  | 'past_due'
  | 'trialing'
  | 'incomplete';

export type PaymentStatus =
  | 'pending'
  | 'succeeded'
  | 'failed'
  | 'refunded';

export type ProjectType = 'single_room' | 'full_house';

export type ProjectStatus =
  | 'draft'
  | 'floor_plan_uploaded'
  | 'style_selected'
  | 'furniture_added'
  | 'generated'
  | 'completed';

export type GenerationStatus =
  | 'pending'
  | 'processing'
  | 'completed'
  | 'failed';

export type FurnitureStatus =
  | 'pending_parse'
  | 'parsed'
  | 'parse_failed'
  | 'manual_input';

export type FurniturePriority = 'must_use' | 'replaceable';

export type DesignStyle =
  | 'modern'
  | 'industrial'
  | 'scandinavian'
  | 'minimalist'
  | 'traditional'
  | 'eclectic';

export type ExportFormat = 'jpg' | 'png' | 'pdf' | 'csv';

// ============================================================================
// DATABASE TABLES
// ============================================================================

export interface User {
  id: string; // UUID
  email: string;
  full_name: string | null;
  avatar_url: string | null;
  current_tier: SubscriptionTier;
  stripe_customer_id: string | null;
  active_projects_count: number;
  credits_balance: number;
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
  last_login_at: string | null; // ISO timestamp
  deleted_at: string | null; // ISO timestamp
}

export interface Subscription {
  id: string; // UUID
  user_id: string; // UUID
  stripe_subscription_id: string | null;
  stripe_price_id: string | null;
  tier: SubscriptionTier;
  status: SubscriptionStatus;
  current_period_start: string; // ISO timestamp
  current_period_end: string; // ISO timestamp
  cancel_at_period_end: boolean;
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
  canceled_at: string | null; // ISO timestamp
  ended_at: string | null; // ISO timestamp
}

export interface Payment {
  id: string; // UUID
  user_id: string; // UUID
  stripe_payment_intent_id: string | null;
  stripe_invoice_id: string | null;
  amount_cents: number;
  currency: string;
  status: PaymentStatus;
  description: string | null;
  metadata: Record<string, any> | null;
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
  paid_at: string | null; // ISO timestamp
  refunded_at: string | null; // ISO timestamp
}

export interface Project {
  id: string; // UUID
  user_id: string; // UUID
  name: string;
  type: ProjectType;
  status: ProjectStatus;
  total_area_sqm: number | null;
  ceiling_height_cm: number | null;
  num_residents: number | null;
  usage_preferences: Record<string, any> | null;
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
  completed_at: string | null; // ISO timestamp
  deleted_at: string | null; // ISO timestamp
}

export interface FloorPlan {
  id: string; // UUID
  project_id: string; // UUID
  original_file_url: string;
  processed_file_url: string | null;
  file_name: string;
  file_size_bytes: number;
  file_type: string;
  scale_ratio: number | null;
  calibration_data: Record<string, any> | null;
  detected_rooms: Record<string, any> | null;
  detection_confidence: number | null;
  is_confirmed: boolean;
  user_edits: Record<string, any> | null;
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
}

export interface StylePreference {
  id: string; // UUID
  project_id: string; // UUID
  primary_style: DesignStyle;
  allow_mixing: boolean;
  color_palette: string[] | null; // Array of hex colors
  material_preferences: Record<string, string> | null;
  lighting_preference: string | null;
  budget_level: string | null;
  reference_images: string[] | null; // Array of image URLs
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
}

export interface FurnitureItem {
  id: string; // UUID
  project_id: string; // UUID
  source_url: string | null;
  source_type: string | null;
  status: FurnitureStatus;
  parse_error: string | null;
  product_name: string | null;
  brand: string | null;
  category: string | null;
  width_cm: number | null;
  depth_cm: number | null;
  height_cm: number | null;
  color: string | null;
  material: string | null;
  style: string | null;
  image_url: string | null;
  price_cents: number | null;
  currency: string;
  priority: FurniturePriority;
  metadata: Record<string, any> | null;
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
}

export interface Design {
  id: string; // UUID
  project_id: string; // UUID
  version_number: number;
  is_active: boolean;
  generation_params: Record<string, any> | null;
  target_rooms: string[] | null;
  status: GenerationStatus;
  error_message: string | null;
  layout_data: Record<string, any> | null;
  layout_image_url: string | null;
  validation_results: Record<string, any> | null;
  is_valid: boolean;
  design_rationale: string | null;
  circulation_analysis: string | null;
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
  completed_at: string | null; // ISO timestamp
}

export interface DesignRender {
  id: string; // UUID
  design_id: string; // UUID
  room_name: string;
  view_angle: string;
  low_res_url: string | null;
  high_res_url: string | null;
  ultra_res_url: string | null;
  render_time_seconds: number | null;
  render_engine: string | null;
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
}

export interface DesignModification {
  id: string; // UUID
  design_id: string; // UUID
  user_id: string; // UUID
  modification_type: string;
  instruction: string | null;
  changes: Record<string, any> | null;
  resulted_in_new_version: boolean;
  new_design_id: string | null; // UUID
  created_at: string; // ISO timestamp
}

export interface ShoppingList {
  id: string; // UUID
  design_id: string; // UUID
  room_name: string | null;
  total_items: number;
  total_price_cents: number | null;
  pdf_url: string | null;
  csv_url: string | null;
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
}

export interface ShoppingListItem {
  id: string; // UUID
  shopping_list_id: string; // UUID
  furniture_item_id: string | null; // UUID
  product_name: string;
  brand: string | null;
  category: string | null;
  quantity: number;
  width_cm: number | null;
  depth_cm: number | null;
  height_cm: number | null;
  source_url: string | null;
  price_cents: number | null;
  currency: string;
  placement_notes: string | null;
  created_at: string; // ISO timestamp
}

export interface Export {
  id: string; // UUID
  user_id: string; // UUID
  design_id: string; // UUID
  format: ExportFormat;
  file_url: string;
  file_size_bytes: number | null;
  export_settings: Record<string, any> | null;
  created_at: string; // ISO timestamp
  expires_at: string | null; // ISO timestamp
}

export interface UsageLog {
  id: string; // UUID
  user_id: string; // UUID
  action_type: string;
  resource_id: string | null; // UUID
  credits_consumed: number;
  tier_at_time: SubscriptionTier;
  metadata: Record<string, any> | null;
  created_at: string; // ISO timestamp
}

export interface StyleTemplate {
  id: string; // UUID
  name: string;
  style: DesignStyle;
  description: string | null;
  thumbnail_url: string | null;
  example_images: string[] | null;
  default_color_palette: string[] | null;
  default_materials: Record<string, string> | null;
  default_lighting: string | null;
  is_active: boolean;
  sort_order: number;
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
}

// ============================================================================
// SUPABASE DATABASE TYPE
// ============================================================================

export interface Database {
  public: {
    Tables: {
      users: {
        Row: User;
        Insert: Omit<User, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Omit<User, 'id' | 'created_at'>>;
      };
      subscriptions: {
        Row: Subscription;
        Insert: Omit<Subscription, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Omit<Subscription, 'id' | 'created_at'>>;
      };
      payments: {
        Row: Payment;
        Insert: Omit<Payment, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Omit<Payment, 'id' | 'created_at'>>;
      };
      projects: {
        Row: Project;
        Insert: Omit<Project, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Omit<Project, 'id' | 'created_at'>>;
      };
      floor_plans: {
        Row: FloorPlan;
        Insert: Omit<FloorPlan, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Omit<FloorPlan, 'id' | 'created_at'>>;
      };
      style_preferences: {
        Row: StylePreference;
        Insert: Omit<StylePreference, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Omit<StylePreference, 'id' | 'created_at'>>;
      };
      furniture_items: {
        Row: FurnitureItem;
        Insert: Omit<FurnitureItem, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Omit<FurnitureItem, 'id' | 'created_at'>>;
      };
      designs: {
        Row: Design;
        Insert: Omit<Design, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Omit<Design, 'id' | 'created_at'>>;
      };
      design_renders: {
        Row: DesignRender;
        Insert: Omit<DesignRender, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Omit<DesignRender, 'id' | 'created_at'>>;
      };
      design_modifications: {
        Row: DesignModification;
        Insert: Omit<DesignModification, 'id' | 'created_at'> & {
          id?: string;
          created_at?: string;
        };
        Update: Partial<Omit<DesignModification, 'id' | 'created_at'>>;
      };
      shopping_lists: {
        Row: ShoppingList;
        Insert: Omit<ShoppingList, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Omit<ShoppingList, 'id' | 'created_at'>>;
      };
      shopping_list_items: {
        Row: ShoppingListItem;
        Insert: Omit<ShoppingListItem, 'id' | 'created_at'> & {
          id?: string;
          created_at?: string;
        };
        Update: Partial<Omit<ShoppingListItem, 'id' | 'created_at'>>;
      };
      exports: {
        Row: Export;
        Insert: Omit<Export, 'id' | 'created_at'> & {
          id?: string;
          created_at?: string;
        };
        Update: Partial<Omit<Export, 'id' | 'created_at'>>;
      };
      usage_logs: {
        Row: UsageLog;
        Insert: Omit<UsageLog, 'id' | 'created_at'> & {
          id?: string;
          created_at?: string;
        };
        Update: Partial<Omit<UsageLog, 'id' | 'created_at'>>;
      };
      style_templates: {
        Row: StyleTemplate;
        Insert: Omit<StyleTemplate, 'id' | 'created_at' | 'updated_at'> & {
          id?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Omit<StyleTemplate, 'id' | 'created_at'>>;
      };
    };
    Views: {};
    Functions: {
      can_create_project: {
        Args: { p_user_id: string };
        Returns: boolean;
      };
      can_perform_action: {
        Args: { p_user_id: string; p_action_type: string };
        Returns: boolean;
      };
      get_monthly_usage_count: {
        Args: { p_user_id: string; p_action_type: string };
        Returns: number;
      };
    };
    Enums: {
      subscription_tier: SubscriptionTier;
      subscription_status: SubscriptionStatus;
      payment_status: PaymentStatus;
      project_type: ProjectType;
      project_status: ProjectStatus;
      generation_status: GenerationStatus;
      furniture_status: FurnitureStatus;
      furniture_priority: FurniturePriority;
      design_style: DesignStyle;
      export_format: ExportFormat;
    };
  };
}

// ============================================================================
// HELPER TYPES
// ============================================================================

// Project with related data
export interface ProjectWithDetails extends Project {
  floor_plans?: FloorPlan[];
  style_preference?: StylePreference;
  furniture_items?: FurnitureItem[];
  designs?: Design[];
}

// Design with renders and shopping list
export interface DesignWithDetails extends Design {
  renders?: DesignRender[];
  shopping_lists?: (ShoppingList & {
    items?: ShoppingListItem[];
  })[];
}

// User with subscription
export interface UserWithSubscription extends User {
  subscription?: Subscription;
}

// Quota limits by tier
export const QUOTA_LIMITS: Record<SubscriptionTier, {
  projects: number;
  generations: number;
  modifications: number;
  furnitureParse: number;
}> = {
  free: {
    projects: 1,
    generations: 1,
    modifications: 2,
    furnitureParse: 5,
  },
  pro: {
    projects: 5,
    generations: 3,
    modifications: 15,
    furnitureParse: 30,
  },
  studio: {
    projects: 20,
    generations: 5,
    modifications: 50,
    furnitureParse: 50,
  },
};

// Credit pack pricing
export const CREDIT_PRICES = {
  generation: 200, // $2.00 in cents
  modification: 150, // $1.50 in cents
  highResRender: 100, // $1.00 in cents
  furnitureParse: 40, // $0.40 in cents (per 5 items)
  pdfExport: 300, // $3.00 in cents
};

// Subscription pricing
export const SUBSCRIPTION_PRICES = {
  pro: 2900, // $29.00 in cents
  studio: 7900, // $79.00 in cents
};