# AI 室内设计平台 - 系统架构设计

**项目**: clawlist.store
**版本**: V1.0 MVP
**更新时间**: 2026-03-06

---

## 1. 技术栈选择

### 1.1 前端技术栈
- **框架**: Next.js 15 (App Router)
- **语言**: TypeScript 5.x
- **样式**: Tailwind CSS 3.x
- **组件库**: shadcn/ui (Radix UI)
- **状态管理**: React Context + Zustand (轻量级)
- **表单**: React Hook Form + Zod
- **图片处理**: Sharp (服务端), Canvas API (客户端)
- **文件上传**: Uppy / react-dropzone
- **图表**: Recharts (数据看板)

### 1.2 后端技术栈
- **运行时**: Next.js 15 API Routes (Edge Runtime)
- **数据库**: Supabase PostgreSQL
- **认证**: Supabase Auth (Email + OAuth)
- **存储**: Supabase Storage (图纸、效果图)
- **支付**: Stripe (订阅 + 按次付费)
- **队列**: Vercel Cron + Supabase Edge Functions
- **缓存**: Vercel KV (Redis)

### 1.3 AI 服务
- **户型识别**: OpenAI GPT-4 Vision / Google Gemini Vision
- **3D 渲染**: Stable Diffusion XL / Midjourney API
- **布局算法**: 自研碰撞检测 + A* 动线规划
- **家具解析**: Puppeteer + GPT-4 (尺寸提取)

### 1.4 部署与监控
- **托管**: Vercel (前端 + API)
- **DNS/CDN**: Cloudflare
- **监控**: Vercel Analytics + Sentry
- **日志**: Axiom / Logtail

---

## 2. 项目目录结构

```
ai-interior-design/
├── app/                          # Next.js 15 App Router
│   ├── (auth)/                   # 认证路由组
│   │   ├── login/
│   │   │   └── page.tsx
│   │   ├── register/
│   │   │   └── page.tsx
│   │   └── layout.tsx
│   │
│   ├── (marketing)/              # 公开页面路由组
│   │   ├── page.tsx              # 首页
│   │   ├── pricing/
│   │   │   └── page.tsx
│   │   ├── showcase/
│   │   │   └── page.tsx
│   │   └── layout.tsx
│   │
│   ├── (dashboard)/              # 用户工作区路由组
│   │   ├── projects/
│   │   │   ├── page.tsx          # 项目列表
│   │   │   ├── [id]/
│   │   │   │   ├── page.tsx      # 项目详情
│   │   │   │   ├── editor/
│   │   │   │   │   └── page.tsx  # 6步编辑器
│   │   │   │   └── results/
│   │   │   │       └── page.tsx  # 结果页
│   │   │   └── new/
│   │   │       └── page.tsx      # 创建项目
│   │   ├── account/
│   │   │   ├── page.tsx          # 账户设置
│   │   │   ├── subscription/
│   │   │   │   └── page.tsx
│   │   │   └── billing/
│   │   │       └── page.tsx
│   │   └── layout.tsx
│   │
│   ├── (admin)/                  # 管理后台路由组
│   │   ├── dashboard/
│   │   │   └── page.tsx
│   │   ├── users/
│   │   │   └── page.tsx
│   │   ├── styles/
│   │   │   └── page.tsx
│   │   └── layout.tsx
│   │
│   ├── api/                      # API Routes
│   │   ├── auth/
│   │   │   └── [...supabase]/
│   │   │       └── route.ts
│   │   ├── projects/
│   │   │   ├── route.ts          # GET, POST
│   │   │   └── [id]/
│   │   │       ├── route.ts      # GET, PATCH, DELETE
│   │   │       └── generate/
│   │   │           └── route.ts  # POST
│   │   ├── floorplans/
│   │   │   ├── upload/
│   │   │   │   └── route.ts
│   │   │   ├── analyze/
│   │   │   │   └── route.ts
│   │   │   └── calibrate/
│   │   │       └── route.ts
│   │   ├── furniture/
│   │   │   ├── parse/
│   │   │   │   └── route.ts
│   │   │   └── validate/
│   │   │       └── route.ts
│   │   ├── generation/
│   │   │   ├── create/
│   │   │   │   └── route.ts
│   │   │   ├── status/
│   │   │   │   └── route.ts
│   │   │   └── modify/
│   │   │       └── route.ts
│   │   ├── payments/
│   │   │   ├── checkout/
│   │   │   │   └── route.ts
│   │   │   ├── webhook/
│   │   │   │   └── route.ts
│   │   │   └── credits/
│   │   │       └── route.ts
│   │   └── export/
│   │       ├── images/
│   │       │   └── route.ts
│   │       └── pdf/
│   │           └── route.ts
│   │
│   ├── layout.tsx                # 根布局
│   ├── globals.css
│   └── error.tsx
│
├── components/                   # React 组件
│   ├── ui/                       # shadcn/ui 组件
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── dialog.tsx
│   │   └── ...
│   ├── auth/
│   │   ├── login-form.tsx
│   │   └── register-form.tsx
│   ├── projects/
│   │   ├── project-card.tsx
│   │   ├── project-list.tsx
│   │   └── create-project-dialog.tsx
│   ├── editor/
│   │   ├── step-indicator.tsx
│   │   ├── floorplan-uploader.tsx
│   │   ├── floorplan-calibrator.tsx
│   │   ├── style-selector.tsx
│   │   ├── furniture-input.tsx
│   │   ├── generation-settings.tsx
│   │   └── results-viewer.tsx
│   ├── results/
│   │   ├── render-gallery.tsx
│   │   ├── layout-viewer.tsx
│   │   ├── shopping-list.tsx
│   │   └── design-notes.tsx
│   ├── pricing/
│   │   ├── pricing-table.tsx
│   │   └── feature-comparison.tsx
│   └── layout/
│       ├── header.tsx
│       ├── footer.tsx
│       └── sidebar.tsx
│
├── lib/                          # 工具库
│   ├── supabase/
│   │   ├── client.ts             # 客户端
│   │   ├── server.ts             # 服务端
│   │   └── middleware.ts
│   ├── stripe/
│   │   ├── client.ts
│   │   └── server.ts
│   ├── ai/
│   │   ├── vision.ts             # 户型识别
│   │   ├── renderer.ts           # 3D 渲染
│   │   ├── layout-engine.ts      # 布局算法
│   │   └── furniture-parser.ts   # 家具解析
│   ├── utils/
│   │   ├── validation.ts
│   │   ├── formatting.ts
│   │   └── constants.ts
│   └── hooks/
│       ├── use-user.ts
│       ├── use-subscription.ts
│       └── use-credits.ts
│
├── types/                        # TypeScript 类型
│   ├── database.ts               # Supabase 生成
│   ├── project.ts
│   ├── floorplan.ts
│   ├── furniture.ts
│   ├── generation.ts
│   └── subscription.ts
│
├── supabase/                     # Supabase 配置
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_rls_policies.sql
│   │   └── 003_storage_buckets.sql
│   └── seed.sql
│
├── public/                       # 静态资源
│   ├── images/
│   ├── styles/                   # 风格模板图
│   └── examples/                 # 案例图
│
├── scripts/                      # 脚本
│   ├── generate-types.ts         # Supabase 类型生成
│   └── seed-styles.ts            # 风格库初始化
│
├── .env.local                    # 环境变量
├── next.config.js
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

---

## 3. API 设计

### 3.1 认证 API

#### POST /api/auth/register
注册新用户
```typescript
Request: {
  email: string;
  password: string;
  name: string;
}
Response: {
  user: User;
  session: Session;
}
```

#### POST /api/auth/login
用户登录
```typescript
Request: {
  email: string;
  password: string;
}
Response: {
  user: User;
  session: Session;
}
```

#### POST /api/auth/logout
用户登出
```typescript
Response: { success: boolean }
```

### 3.2 项目管理 API

#### GET /api/projects
获取用户项目列表
```typescript
Query: {
  page?: number;
  limit?: number;
  status?: 'draft' | 'active' | 'archived';
}
Response: {
  projects: Project[];
  total: number;
  page: number;
}
```

#### POST /api/projects
创建新项目
```typescript
Request: {
  name: string;
  type: 'single_room' | 'full_house';
  area: number;
  ceiling_height: number;
  occupants: number;
  usage_habits: string[];
}
Response: {
  project: Project;
}
```

#### GET /api/projects/[id]
获取项目详情
```typescript
Response: {
  project: Project;
  floorplans: Floorplan[];
  furniture: Furniture[];
  generations: Generation[];
}
```

#### PATCH /api/projects/[id]
更新项目信息
```typescript
Request: Partial<Project>
Response: {
  project: Project;
}
```

#### DELETE /api/projects/[id]
删除项目
```typescript
Response: { success: boolean }
```

### 3.3 图纸处理 API

#### POST /api/floorplans/upload
上传图纸文件
```typescript
Request: FormData {
  file: File;
  project_id: string;
}
Response: {
  floorplan: Floorplan;
  upload_url: string;
}
```

#### POST /api/floorplans/analyze
AI 分析图纸
```typescript
Request: {
  floorplan_id: string;
}
Response: {
  rooms: Room[];
  doors: Door[];
  windows: Window[];
  dimensions: Dimensions;
  confidence: number;
}
```

#### POST /api/floorplans/calibrate
校准图纸尺寸
```typescript
Request: {
  floorplan_id: string;
  known_length: number;
  pixel_distance: number;
}
Response: {
  scale: number;
  calibrated_dimensions: Dimensions;
}
```

### 3.4 家具解析 API

#### POST /api/furniture/parse
解析家具链接
```typescript
Request: {
  urls: string[];
  project_id: string;
}
Response: {
  furniture: Furniture[];
  failed: { url: string; reason: string }[];
}
```

#### POST /api/furniture/validate
验证家具尺寸
```typescript
Request: {
  furniture_id: string;
  dimensions: {
    width: number;
    depth: number;
    height: number;
  };
}
Response: {
  valid: boolean;
  conflicts: Conflict[];
}
```

### 3.5 设计生成 API

#### POST /api/generation/create
创建生成任务
```typescript
Request: {
  project_id: string;
  style_id: string;
  rooms: string[];
  versions: number;
  strict_mode: boolean;
  priorities: string[];
}
Response: {
  generation_id: string;
  status: 'queued';
  estimated_time: number;
}
```

#### GET /api/generation/status
查询生成状态
```typescript
Query: {
  generation_id: string;
}
Response: {
  status: 'queued' | 'processing' | 'completed' | 'failed';
  progress: number;
  current_step: string;
  results?: GenerationResult[];
  error?: string;
}
```

#### POST /api/generation/modify
修改生成结果
```typescript
Request: {
  generation_id: string;
  type: 'quick_adjust' | 'local_edit' | 'text_instruction';
  params: {
    adjustment?: 'brighter' | 'luxury' | 'more_storage';
    furniture_id?: string;
    new_position?: { x: number; y: number };
    instruction?: string;
  };
}
Response: {
  generation_id: string;
  status: 'queued';
}
```

### 3.6 支付 API

#### POST /api/payments/checkout
创建支付会话
```typescript
Request: {
  plan: 'pro' | 'studio';
  interval: 'month' | 'year';
}
Response: {
  checkout_url: string;
  session_id: string;
}
```

#### POST /api/payments/webhook
Stripe Webhook 处理
```typescript
Request: Stripe Event
Response: { received: true }
```

#### POST /api/payments/credits
购买 Credit Pack
```typescript
Request: {
  pack_type: 'generation' | 'modification' | 'render' | 'parsing' | 'pdf';
  quantity: number;
}
Response: {
  checkout_url: string;
}
```

#### GET /api/payments/usage
查询用量统计
```typescript
Response: {
  plan: string;
  credits: {
    projects: { used: number; limit: number };
    generations: { used: number; limit: number };
    modifications: { used: number; limit: number };
  };
  billing_cycle_end: string;
}
```

### 3.7 导出 API

#### POST /api/export/images
导出效果图
```typescript
Request: {
  generation_id: string;
  quality: 'low' | 'high' | 'ultra';
  format: 'jpg' | 'png';
}
Response: {
  download_urls: string[];
}
```

#### POST /api/export/pdf
导出 PDF 方案书
```typescript
Request: {
  generation_id: string;
  include_shopping_list: boolean;
}
Response: {
  pdf_url: string;
}
```

---

## 4. 数据库设计

### 4.1 核心表结构

#### users (Supabase Auth 自带)
```sql
-- 扩展用户信息表
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT NOT NULL,
  avatar_url TEXT,
  plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'studio')),
  stripe_customer_id TEXT UNIQUE,
  stripe_subscription_id TEXT,
  subscription_status TEXT,
  subscription_end_at TIMESTAMPTZ,
  credits JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### projects
```sql
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('single_room', 'full_house')),
  area NUMERIC NOT NULL,
  ceiling_height NUMERIC NOT NULL,
  occupants INTEGER NOT NULL,
  usage_habits TEXT[],
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'archived')),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_status ON projects(status);
```

#### floorplans
```sql
CREATE TABLE floorplans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  analysis_result JSONB,
  calibration JSONB,
  is_calibrated BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_floorplans_project_id ON floorplans(project_id);
```

#### rooms
```sql
CREATE TABLE rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  floorplan_id UUID NOT NULL REFERENCES floorplans(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  dimensions JSONB NOT NULL,
  doors JSONB DEFAULT '[]',
  windows JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_rooms_floorplan_id ON rooms(floorplan_id);
```

#### styles
```sql
CREATE TABLE styles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  thumbnail_url TEXT,
  color_palette JSONB,
  materials JSONB,
  lighting JSONB,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### furniture
```sql
CREATE TABLE furniture (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  source_url TEXT NOT NULL,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  dimensions JSONB NOT NULL,
  color TEXT,
  material TEXT,
  price NUMERIC,
  is_required BOOLEAN DEFAULT FALSE,
  parse_status TEXT DEFAULT 'pending' CHECK (parse_status IN ('pending', 'success', 'failed')),
  parse_error TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_furniture_project_id ON furniture(project_id);
```

#### generations
```sql
CREATE TABLE generations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  style_id UUID NOT NULL REFERENCES styles(id),
  rooms UUID[],
  versions INTEGER NOT NULL,
  strict_mode BOOLEAN DEFAULT TRUE,
  priorities TEXT[],
  status TEXT DEFAULT 'queued' CHECK (status IN ('queued', 'processing', 'completed', 'failed')),
  progress INTEGER DEFAULT 0,
  current_step TEXT,
  error TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_generations_project_id ON generations(project_id);
CREATE INDEX idx_generations_status ON generations(status);
```

#### generation_results
```sql
CREATE TABLE generation_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  generation_id UUID NOT NULL REFERENCES generations(id) ON DELETE CASCADE,
  version INTEGER NOT NULL,
  room_id UUID NOT NULL REFERENCES rooms(id),
  render_urls JSONB NOT NULL,
  layout_data JSONB NOT NULL,
  furniture_placement JSONB NOT NULL,
  design_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_generation_results_generation_id ON generation_results(generation_id);
```

#### modifications
```sql
CREATE TABLE modifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  generation_id UUID NOT NULL REFERENCES generations(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('quick_adjust', 'local_edit', 'text_instruction')),
  params JSONB NOT NULL,
  result_id UUID REFERENCES generation_results(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_modifications_generation_id ON modifications(generation_id);
```

#### usage_logs
```sql
CREATE TABLE usage_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id UUID,
  credits_used INTEGER DEFAULT 0,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_usage_logs_user_id ON usage_logs(user_id);
CREATE INDEX idx_usage_logs_created_at ON usage_logs(created_at);
```

### 4.2 Row Level Security (RLS) 策略

```sql
-- 启用 RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE floorplans ENABLE ROW LEVEL SECURITY;
ALTER TABLE furniture ENABLE ROW LEVEL SECURITY;
ALTER TABLE generations ENABLE ROW LEVEL SECURITY;
ALTER TABLE generation_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE modifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_logs ENABLE ROW LEVEL SECURITY;

-- user_profiles 策略
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

-- projects 策略
CREATE POLICY "Users can view own projects"
  ON projects FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own projects"
  ON projects FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own projects"
  ON projects FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own projects"
  ON projects FOR DELETE
  USING (auth.uid() = user_id);

-- floorplans 策略
CREATE POLICY "Users can view floorplans of own projects"
  ON floorplans FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM projects
      WHERE projects.id = floorplans.project_id
      AND projects.user_id = auth.uid()
    )
  );

-- 其他表类似策略...

-- styles 表公开只读
CREATE POLICY "Styles are viewable by everyone"
  ON styles FOR SELECT
  USING (is_active = TRUE);
```

---

## 5. 数据流设计

### 5.1 用户注册与认证流程

```
用户输入邮箱密码
  ↓
POST /api/auth/register
  ↓
Supabase Auth 创建用户
  ↓
创建 user_profiles 记录
  ↓
初始化 Free 套餐配额
  ↓
返回 Session Token
  ↓
重定向到项目列表页
```

### 5.2 项目创建与图纸上传流程

```
用户填写项目信息
  ↓
POST /api/projects (创建项目)
  ↓
检查用户配额 (Free: 1个, Pro: 5个)
  ↓
创建 projects 记录
  ↓
用户上传图纸文件
  ↓
POST /api/floorplans/upload
  ↓
上传到 Supabase Storage
  ↓
创建 floorplans 记录
  ↓
POST /api/floorplans/analyze (异步)
  ↓
调用 GPT-4 Vision API
  ↓
识别房间、门窗、尺寸
  ↓
更新 floorplans.analysis_result
  ↓
创建 rooms 记录
  ↓
用户确认/编辑结果
  ↓
POST /api/floorplans/calibrate
  ↓
更新 floorplans.calibration
```

### 5.3 家具链接解析流程

```
用户粘贴家具链接
  ↓
POST /api/furniture/parse
  ↓
检查配额 (Free: 5条, Pro: 30条)
  ↓
并发处理每个链接:
  ├─ Puppeteer 抓取页面
  ├─ 提取商品信息
  ├─ GPT-4 提取尺寸
  └─ 验证数据完整性
  ↓
创建 furniture 记录
  ↓
返回解析结果
  ↓
用户标记"必须使用"
  ↓
PATCH /api/furniture/[id]
```

### 5.4 设计生成核心流程

```
用户选择风格 + 设置参数
  ↓
POST /api/generation/create
  ↓
检查配额 (Free: 1版本, Pro: 3版本)
  ↓
创建 generations 记录 (status: queued)
  ↓
记录 usage_logs
  ↓
触发后台任务 (Vercel Cron / Edge Function)
  ↓
更新 status: processing
  ↓
Step 1: 加载图纸 + 家具数据
  ↓
Step 2: 布局算法
  ├─ 碰撞检测
  ├─ 动线规划
  ├─ 功能分区
  └─ 尺寸约束验证
  ↓
Step 3: 生成平面布局图
  ↓
Step 4: 调用 Stable Diffusion XL
  ├─ 生成效果图 (每房间2视角)
  └─ 根据套餐调整分辨率
  ↓
Step 5: 生成设计说明
  ↓
创建 generation_results 记录
  ↓
更新 status: completed
  ↓
前端轮询 GET /api/generation/status
  ↓
展示结果页
```

### 5.5 修改迭代流程

```
用户点击"更明亮"按钮
  ↓
POST /api/generation/modify
  ↓
检查配额 (Free: 2次, Pro: 15次)
  ↓
创建 modifications 记录
  ↓
创建新的 generations 任务
  ↓
继承原布局 + 应用调整参数
  ↓
重新渲染效果图
  ↓
创建新的 generation_results
  ↓
返回新结果
```

### 5.6 支付与订阅流程

```
用户点击"升级到 Pro"
  ↓
POST /api/payments/checkout
  ↓
创建 Stripe Checkout Session
  ↓
重定向到 Stripe 支付页
  ↓
用户完成支付
  ↓
Stripe 发送 Webhook
  ↓
POST /api/payments/webhook
  ↓
验证签名
  ↓
更新 user_profiles:
  ├─ plan: 'pro'
  ├─ stripe_subscription_id
  ├─ subscription_status: 'active'
  └─ subscription_end_at
  ↓
更新配额限制
  ↓
发送确认邮件
```

### 5.7 导出流程

```
用户点击"导出高清图"
  ↓
POST /api/export/images
  ↓
检查套餐权限 (Free: 720p+水印, Pro: 2K)
  ↓
从 Supabase Storage 获取原图
  ↓
Sharp 处理:
  ├─ 调整分辨率
  ├─ 添加水印 (Free)
  └─ 压缩优化
  ↓
生成临时下载链接 (1小时有效)
  ↓
返回 download_urls
  ↓
前端触发下载
```

---

## 6. 安全设计

### 6.1 认证与授权

#### Supabase Auth
- Email + Password 认证
- OAuth 集成 (Google, GitHub)
- JWT Token 管理
- Session 自动刷新
- 密码强度验证

#### 权限控制
```typescript
// 中间件验证
export async function middleware(request: NextRequest) {
  const supabase = createMiddlewareClient({ req: request });
  const { data: { session } } = await supabase.auth.getSession();

  if (!session && isProtectedRoute(request.nextUrl.pathname)) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return NextResponse.next();
}

// API 路由保护
export async function POST(request: Request) {
  const supabase = createRouteHandlerClient({ cookies });
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // 业务逻辑...
}
```

### 6.2 Row Level Security (RLS)

所有用户数据表启用 RLS，确保：
- 用户只能访问自己的项目
- 用户只能修改自己的数据
- 管理员通过 service_role_key 绕过 RLS

```sql
-- 示例：projects 表 RLS
CREATE POLICY "Users can only view own projects"
  ON projects FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can only update own projects"
  ON projects FOR UPDATE
  USING (auth.uid() = user_id);
```

### 6.3 API 安全

#### 速率限制
```typescript
// lib/rate-limit.ts
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'),
});

export async function checkRateLimit(identifier: string) {
  const { success, limit, reset, remaining } = await ratelimit.limit(identifier);

  if (!success) {
    throw new Error('Rate limit exceeded');
  }

  return { limit, reset, remaining };
}
```

#### 输入验证
```typescript
// 使用 Zod 验证所有输入
import { z } from 'zod';

const createProjectSchema = z.object({
  name: z.string().min(1).max(100),
  type: z.enum(['single_room', 'full_house']),
  area: z.number().positive().max(10000),
  ceiling_height: z.number().positive().max(10),
  occupants: z.number().int().positive().max(50),
  usage_habits: z.array(z.string()).max(20),
});

export async function POST(request: Request) {
  const body = await request.json();
  const validated = createProjectSchema.parse(body); // 抛出错误如果无效
  // ...
}
```

#### CSRF 保护
- Next.js 自动处理 CSRF Token
- API Routes 使用 SameSite Cookie

#### XSS 防护
- React 自动转义输出
- 用户上传内容使用 DOMPurify 清理
- CSP Header 配置

```typescript
// next.config.js
const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: "default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:;"
  },
  {
    key: 'X-Frame-Options',
    value: 'DENY'
  },
  {
    key: 'X-Content-Type-Options',
    value: 'nosniff'
  },
  {
    key: 'Referrer-Policy',
    value: 'strict-origin-when-cross-origin'
  }
];
```

### 6.4 文件上传安全

```typescript
// 文件类型验证
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'application/pdf'];
const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB

export async function validateFile(file: File) {
  if (!ALLOWED_TYPES.includes(file.type)) {
    throw new Error('Invalid file type');
  }

  if (file.size > MAX_FILE_SIZE) {
    throw new Error('File too large');
  }

  // 使用 file-type 库验证真实文件类型
  const buffer = await file.arrayBuffer();
  const fileType = await fileTypeFromBuffer(buffer);

  if (!fileType || !ALLOWED_TYPES.includes(fileType.mime)) {
    throw new Error('File type mismatch');
  }

  return true;
}
```

### 6.5 支付安全

- 使用 Stripe Checkout (托管支付页)
- 不存储信用卡信息
- Webhook 签名验证
- PCI DSS 合规

```typescript
// Webhook 验证
import Stripe from 'stripe';

export async function POST(request: Request) {
  const body = await request.text();
  const signature = request.headers.get('stripe-signature')!;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err) {
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }

  // 处理事件...
}
```

### 6.6 敏感数据保护

```typescript
// 环境变量管理
// .env.local (不提交到 Git)
SUPABASE_SERVICE_ROLE_KEY=xxx
STRIPE_SECRET_KEY=xxx
OPENAI_API_KEY=xxx

// 使用 Vercel Environment Variables 管理生产环境密钥
// 开发/预览/生产环境隔离
```

---

## 7. 性能优化

### 7.1 前端优化

#### 代码分割
```typescript
// 动态导入大型组件
import dynamic from 'next/dynamic';

const FloorplanEditor = dynamic(() => import('@/components/editor/floorplan-editor'), {
  loading: () => <Skeleton />,
  ssr: false, // 客户端渲染
});

const ResultsViewer = dynamic(() => import('@/components/results/results-viewer'), {
  loading: () => <LoadingSpinner />,
});
```

#### 图片优化
```typescript
// 使用 Next.js Image 组件
import Image from 'next/image';

<Image
  src={floorplan.url}
  alt="Floor plan"
  width={800}
  height={600}
  quality={85}
  placeholder="blur"
  blurDataURL={floorplan.thumbnail}
  priority={false}
/>

// Supabase Storage 图片转换
const optimizedUrl = supabase.storage
  .from('floorplans')
  .getPublicUrl(path, {
    transform: {
      width: 800,
      height: 600,
      quality: 85,
      format: 'webp',
    },
  });
```

#### 字体优化
```typescript
// app/layout.tsx
import { Inter } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={inter.variable}>
      <body>{children}</body>
    </html>
  );
}
```

#### 预加载关键资源
```typescript
// app/layout.tsx
export default function RootLayout() {
  return (
    <html>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="dns-prefetch" href="https://api.stripe.com" />
      </head>
      <body>{children}</body>
    </html>
  );
}
```

### 7.2 API 优化

#### 缓存策略
```typescript
// 静态数据缓存 (风格库)
export async function GET() {
  const styles = await getStyles();

  return NextResponse.json(styles, {
    headers: {
      'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400',
    },
  });
}

// 用户数据不缓存
export async function GET() {
  const projects = await getUserProjects(userId);

  return NextResponse.json(projects, {
    headers: {
      'Cache-Control': 'private, no-cache, no-store, must-revalidate',
    },
  });
}

// 使用 Vercel KV 缓存
import { kv } from '@vercel/kv';

export async function getStyles() {
  const cached = await kv.get('styles');
  if (cached) return cached;

  const styles = await supabase.from('styles').select('*');
  await kv.set('styles', styles, { ex: 3600 }); // 1小时过期

  return styles;
}
```

#### 数据库查询优化
```typescript
// 使用索引
CREATE INDEX idx_projects_user_id_status ON projects(user_id, status);

// 分页查询
export async function getProjects(userId: string, page: number, limit: number) {
  const { data, count } = await supabase
    .from('projects')
    .select('*', { count: 'exact' })
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .range((page - 1) * limit, page * limit - 1);

  return { data, total: count, page };
}

// 避免 N+1 查询
export async function getProjectWithDetails(projectId: string) {
  const { data } = await supabase
    .from('projects')
    .select(`
      *,
      floorplans (*),
      furniture (*),
      generations (
        *,
        generation_results (*)
      )
    `)
    .eq('id', projectId)
    .single();

  return data;
}
```

#### 并发处理
```typescript
// 并发解析家具链接
export async function parseFurnitureLinks(urls: string[]) {
  const results = await Promise.allSettled(
    urls.map(url => parseSingleLink(url))
  );

  const successful = results
    .filter(r => r.status === 'fulfilled')
    .map(r => r.value);

  const failed = results
    .filter(r => r.status === 'rejected')
    .map((r, i) => ({ url: urls[i], reason: r.reason }));

  return { successful, failed };
}
```

### 7.3 后台任务优化

#### 异步处理
```typescript
// 使用 Vercel Cron Jobs
// vercel.json
{
  "crons": [
    {
      "path": "/api/cron/process-generations",
      "schedule": "* * * * *" // 每分钟
    }
  ]
}

// app/api/cron/process-generations/route.ts
export async function GET(request: Request) {
  // 验证 Cron Secret
  const authHeader = request.headers.get('authorization');
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // 处理队列中的生成任务
  const pendingGenerations = await supabase
    .from('generations')
    .select('*')
    .eq('status', 'queued')
    .limit(5);

  for (const generation of pendingGenerations.data) {
    await processGeneration(generation.id);
  }

  return NextResponse.json({ processed: pendingGenerations.data.length });
}
```

#### 队列管理
```typescript
// 使用 Supabase Edge Functions 处理长时间任务
// supabase/functions/process-generation/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req) => {
  const { generationId } = await req.json();

  // 更新状态
  await supabase
    .from('generations')
    .update({ status: 'processing', progress: 0 })
    .eq('id', generationId);

  // 执行生成任务
  try {
    await generateLayout(generationId);
    await generateRenders(generationId);
    await generateNotes(generationId);

    await supabase
      .from('generations')
      .update({ status: 'completed', progress: 100 })
      .eq('id', generationId);
  } catch (error) {
    await supabase
      .from('generations')
      .update({ status: 'failed', error: error.message })
      .eq('id', generationId);
  }

  return new Response(JSON.stringify({ success: true }));
});
```

### 7.4 CDN 与静态资源

```typescript
// next.config.js
module.exports = {
  images: {
    domains: ['ygnbikloljpjzkxxcoar.supabase.co'],
    formats: ['image/avif', 'image/webp'],
  },
  // 静态资源 CDN
  assetPrefix: process.env.NODE_ENV === 'production'
    ? 'https://cdn.clawlist.store'
    : '',
};

// Cloudflare CDN 配置
// - 自动压缩 (Brotli, Gzip)
// - 图片优化 (Polish)
// - 缓存规则 (Page Rules)
```

### 7.5 监控与分析

```typescript
// Vercel Analytics
import { Analytics } from '@vercel/analytics/react';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  );
}

// Sentry 错误追踪
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 0.1,
  environment: process.env.NODE_ENV,
});

// 性能监控
export async function GET(request: Request) {
  const start = Date.now();

  try {
    const data = await fetchData();
    const duration = Date.now() - start;

    // 记录慢查询
    if (duration > 1000) {
      console.warn(`Slow query: ${duration}ms`);
    }

    return NextResponse.json(data);
  } catch (error) {
    Sentry.captureException(error);
    throw error;
  }
}
```

---

## 8. 可扩展性设计

### 8.1 MVP 架构 (V1.0)

#### 当前规模预估
- 用户数: 0-1000
- 并发请求: < 100 req/s
- 数据库: Supabase Free/Pro Tier
- 存储: < 100GB
- AI 调用: < 10,000 次/月

#### 技术选型理由
- **Next.js + Vercel**: 零配置部署，自动扩展
- **Supabase**: 托管数据库，内置认证，快速开发
- **Stripe**: 成熟支付方案，降低合规成本
- **Edge Runtime**: 全球低延迟响应

### 8.2 扩展路径 (V2.0+)

#### 用户增长 (1000-10000)
```
当前架构 → 优化点
├─ Vercel Pro Plan ($20/月)
├─ Supabase Pro Plan ($25/月)
├─ 增加 Vercel KV 缓存
├─ 启用 Cloudflare CDN
└─ 优化数据库索引
```

#### 用户增长 (10000-100000)
```
架构升级
├─ 数据库读写分离
│   ├─ Supabase 主库 (写)
│   └─ Read Replicas (读)
├─ 队列系统
│   ├─ BullMQ + Redis
│   └─ 专用 Worker 服务
├─ 对象存储
│   ├─ Cloudflare R2
│   └─ 图片 CDN 加速
└─ 微服务拆分
    ├─ 认证服务
    ├─ 生成服务
    └─ 支付服务
```

#### 用户增长 (100000+)
```
企业级架构
├─ Kubernetes 集群
├─ PostgreSQL 集群 (Patroni)
├─ Redis 集群
├─ Kafka 消息队列
├─ 独立 AI 服务集群
└─ 多区域部署
```

### 8.3 功能扩展点

#### 预留接口设计
```typescript
// 团队协作 (Studio 套餐)
interface Project {
  // ... 现有字段
  team_id?: string;
  collaborators?: string[];
  permissions?: Record<string, Permission>;
}

// 3D 漫游 (未来功能)
interface GenerationResult {
  // ... 现有字段
  vr_scene_url?: string;
  walkthrough_video_url?: string;
}

// 施工图深化 (未来功能)
interface Generation {
  // ... 现有字段
  construction_drawings?: ConstructionDrawing[];
}

// 平台推荐家具 (未来功能)
interface Furniture {
  // ... 现有字段
  alternatives?: Furniture[];
  affiliate_link?: string;
}
```

#### 数据库扩展
```sql
-- 预留字段
ALTER TABLE projects ADD COLUMN metadata JSONB DEFAULT '{}';
ALTER TABLE generations ADD COLUMN extended_data JSONB DEFAULT '{}';

-- 未来表结构
CREATE TABLE teams (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  owner_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE team_members (
  team_id UUID REFERENCES teams(id),
  user_id UUID REFERENCES auth.users(id),
  role TEXT NOT NULL,
  PRIMARY KEY (team_id, user_id)
);
```

### 8.4 AI 服务扩展

#### 模型切换策略
```typescript
// lib/ai/config.ts
export const AI_MODELS = {
  vision: {
    primary: 'gpt-4-vision-preview',
    fallback: 'gemini-pro-vision',
  },
  rendering: {
    primary: 'stable-diffusion-xl',
    fallback: 'midjourney-api',
  },
  text: {
    primary: 'gpt-4-turbo',
    fallback: 'claude-3-opus',
  },
};

// 自动降级
export async function callVisionAPI(image: string, prompt: string) {
  try {
    return await openai.vision(image, prompt);
  } catch (error) {
    console.warn('Primary vision API failed, using fallback');
    return await gemini.vision(image, prompt);
  }
}
```

#### 成本优化
```typescript
// 根据套餐选择模型
export function getModelForPlan(plan: string, task: string) {
  if (plan === 'free') {
    return {
      vision: 'gpt-4-vision-preview', // 低成本
      rendering: 'stable-diffusion-xl', // 开源
      quality: 'low',
    };
  } else if (plan === 'pro') {
    return {
      vision: 'gpt-4-vision-preview',
      rendering: 'midjourney-api', // 高质量
      quality: 'high',
    };
  } else {
    return {
      vision: 'gpt-4-vision-preview',
      rendering: 'midjourney-api',
      quality: 'ultra',
    };
  }
}
```

### 8.5 监控与告警

```typescript
// 关键指标监控
export const METRICS = {
  // 业务指标
  signups_per_day: 'counter',
  free_to_pro_conversion: 'gauge',
  generation_success_rate: 'gauge',
  average_generation_time: 'histogram',

  // 技术指标
  api_response_time: 'histogram',
  database_query_time: 'histogram',
  ai_api_latency: 'histogram',
  error_rate: 'counter',

  // 成本指标
  ai_api_cost_per_day: 'counter',
  storage_usage: 'gauge',
  bandwidth_usage: 'counter',
};

// 告警规则
export const ALERTS = {
  high_error_rate: {
    condition: 'error_rate > 5%',
    action: 'notify_team',
  },
  slow_generation: {
    condition: 'average_generation_time > 5min',
    action: 'scale_workers',
  },
  high_ai_cost: {
    condition: 'ai_api_cost_per_day > $500',
    action: 'notify_admin',
  },
};
```

### 8.6 数据迁移策略

```typescript
// 版本化迁移
// supabase/migrations/004_add_team_support.sql
BEGIN;

-- 添加新表
CREATE TABLE teams (...);

-- 迁移现有数据
INSERT INTO teams (id, name, owner_id)
SELECT gen_random_uuid(), 'Personal Team', id
FROM auth.users;

-- 更新外键
ALTER TABLE projects ADD COLUMN team_id UUID REFERENCES teams(id);
UPDATE projects SET team_id = (
  SELECT id FROM teams WHERE owner_id = projects.user_id
);

COMMIT;
```

---

## 9. 部署清单

### 9.1 环境变量配置

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_ROLE_KEY=xxx

# Stripe
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_xxx
STRIPE_SECRET_KEY=sk_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx

# AI Services
OPENAI_API_KEY=sk-xxx
STABILITY_API_KEY=sk-xxx

# Vercel
VERCEL_URL=clawlist.store
CRON_SECRET=xxx

# Monitoring
NEXT_PUBLIC_SENTRY_DSN=xxx
SENTRY_AUTH_TOKEN=xxx
```

### 9.2 Vercel 部署配置

```json
// vercel.json
{
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "framework": "nextjs",
  "regions": ["sfo1"],
  "env": {
    "NEXT_PUBLIC_SUPABASE_URL": "@supabase-url",
    "NEXT_PUBLIC_SUPABASE_ANON_KEY": "@supabase-anon-key"
  },
  "crons": [
    {
      "path": "/api/cron/process-generations",
      "schedule": "* * * * *"
    }
  ]
}
```

### 9.3 Supabase 初始化

```bash
# 1. 创建项目
supabase init

# 2. 运行迁移
supabase db push

# 3. 生成 TypeScript 类型
npm run generate:types

# 4. 配置 Storage Buckets
supabase storage create floorplans --public
supabase storage create renders --public
supabase storage create exports --private

# 5. 配置 RLS 策略
supabase db reset
```

### 9.4 Stripe 配置

```bash
# 1. 创建产品
stripe products create --name "Pro Plan" --description "..."

# 2. 创建价格
stripe prices create --product prod_xxx --unit-amount 2900 --currency usd --recurring interval=month

# 3. 配置 Webhook
stripe listen --forward-to localhost:3000/api/payments/webhook

# 4. 测试支付
stripe checkout sessions create --mode subscription --line-items price=price_xxx --success-url https://clawlist.store/success
```

### 9.5 域名配置

```bash
# Cloudflare DNS
clawlist.store A 76.76.21.21 (Vercel)
www.clawlist.store CNAME cname.vercel-dns.com

# SSL/TLS: Full (strict)
# Page Rules:
# - Cache Level: Standard
# - Browser Cache TTL: 4 hours
# - Edge Cache TTL: 1 hour
```

---

## 10. 开发流程

### 10.1 本地开发

```bash
# 1. 克隆项目
git clone https://github.com/xxx/ai-interior-design.git
cd ai-interior-design

# 2. 安装依赖
npm install

# 3. 配置环境变量
cp .env.example .env.local
# 编辑 .env.local

# 4. 启动 Supabase 本地环境
supabase start

# 5. 运行开发服务器
npm run dev

# 6. 访问
open http://localhost:3000
```

### 10.2 Git 工作流

```bash
# 功能分支
git checkout -b feature/floorplan-upload
git commit -m "feat: add floorplan upload"
git push origin feature/floorplan-upload

# Pull Request → Review → Merge to main

# 自动部署到 Vercel Preview
# 合并后自动部署到生产环境
```

### 10.3 测试策略

```typescript
// 单元测试 (Vitest)
import { describe, it, expect } from 'vitest';
import { validateDimensions } from '@/lib/utils/validation';

describe('validateDimensions', () => {
  it('should validate correct dimensions', () => {
    expect(validateDimensions({ width: 100, depth: 50, height: 80 })).toBe(true);
  });

  it('should reject negative dimensions', () => {
    expect(validateDimensions({ width: -10, depth: 50, height: 80 })).toBe(false);
  });
});

// 集成测试 (Playwright)
import { test, expect } from '@playwright/test';

test('user can create project', async ({ page }) => {
  await page.goto('/projects/new');
  await page.fill('[name="name"]', 'Test Project');
  await page.selectOption('[name="type"]', 'single_room');
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL(/\/projects\/[a-z0-9-]+/);
});
```

---

## 11. 总结

### 11.1 架构优势

- **快速迭代**: Next.js + Supabase 快速开发
- **低成本启动**: 免费/低价 Tier 支持 MVP
- **自动扩展**: Vercel 无需运维
- **安全可靠**: RLS + Stripe 托管支付
- **性能优化**: Edge Runtime + CDN

### 11.2 技术债务管理

- 定期重构代码
- 监控性能指标
- 及时升级依赖
- 文档持续更新

### 11.3 下一步行动

1. 初始化项目结构
2. 配置 Supabase 数据库
3. 实现认证系统
4. 开发项目管理功能
5. 集成 AI 服务
6. 实现支付系统
7. 测试与优化
8. 上线部署

---

**文档版本**: 1.0
**最后更新**: 2026-03-06
**维护者**: Tony + AI Team

