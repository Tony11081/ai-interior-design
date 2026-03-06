# AI 室内设计平台 - 开发文档

## 🎉 项目状态

### ✅ 已完成

1. **三 AI 协作设计**
   - UI 设计（Stitch AI）- 7 个页面
   - 系统架构（Claude AI）- 完整架构文档
   - 数据库设计（Codex AI）- 15 张表 + RLS + 索引

2. **项目初始化**
   - Next.js 15 + TypeScript
   - Tailwind CSS
   - 核心依赖已安装

3. **基础配置**
   - Supabase 客户端
   - 环境变量
   - 工具函数

4. **首页实现**
   - Hero section（图纸 → 3D 转换展示）
   - How It Works（3 步流程）
   - 定价预览（Free/Pro/Studio）
   - Footer

## 📁 项目结构

```
ai-interior-design/
├── app/
│   ├── page.tsx          # 首页 ✅
│   ├── globals.css       # 全局样式 ✅
│   └── layout.tsx        # 根布局
├── components/
│   └── ui/               # shadcn/ui 组件
├── lib/
│   ├── supabase.ts       # Supabase 客户端 ✅
│   └── utils.ts          # 工具函数 ✅
├── database/
│   ├── schema.sql        # 数据库 Schema ✅
│   ├── types.ts          # TypeScript 类型 ✅
│   └── README.md         # 数据库文档 ✅
├── docs/
│   └── architecture.md   # 系统架构文档 ✅
└── .env.local            # 环境变量 ✅
```

## 🚀 快速开始

### 1. 安装依赖
```bash
cd ~/clawd/projects/ai-interior-design
npm install
```

### 2. 配置环境变量
编辑 `.env.local`，填入正确的 Supabase 和 Stripe 密钥。

### 3. 初始化数据库
访问 Supabase Dashboard 并运行 `database/schema.sql`。

### 4. 启动开发服务器
```bash
npm run dev
```

访问 http://localhost:3000

## 📊 Supabase 配置

### 项目信息
- **Project ID**: utqhhjoqinprxnsdrexi
- **URL**: https://utqhhjoqinprxnsdrexi.supabase.co
- **Dashboard**: https://supabase.com/dashboard/project/utqhhjoqinprxnsdrexi

### 初始化步骤
1. 访问 Supabase Dashboard
2. 进入 SQL Editor
3. 复制 `database/schema.sql` 内容
4. 执行 SQL
5. 创建 Storage 桶：
   - floor-plans
   - reference-images
   - design-renders
   - exports
   - furniture-images

## 🎯 下一步开发任务

### 高优先级（本周）
- [ ] 登录/注册页面
- [ ] 项目列表页
- [ ] 项目创建流程（6 步向导）
- [ ] Supabase 认证集成
- [ ] 基础 API 路由

### 中优先级（下周）
- [ ] 图纸上传功能
- [ ] 风格选择界面
- [ ] 家具链接解析
- [ ] 结果展示页
- [ ] Stripe 支付集成

### 低优先级（未来）
- [ ] AI 服务集成
- [ ] 3D 渲染
- [ ] 导出功能
- [ ] 团队协作
- [ ] 移动端优化

## 🛠️ 技术栈

### 前端
- Next.js 15 (App Router)
- TypeScript
- Tailwind CSS
- shadcn/ui
- Lucide Icons

### 后端
- Next.js API Routes
- Supabase (PostgreSQL + Auth + Storage)
- Stripe (支付)

### 部署
- Vercel (前端 + API)
- Supabase (数据库)
- Cloudflare (DNS)

## 📖 相关文档

- **架构文档**: `docs/architecture.md`
- **数据库文档**: `database/README.md`
- **PRD**: `~/clawd/projects/ai-interior-design-prd.md`
- **Stitch 设计**: https://stitch.withgoogle.com/project/2854171124588656897

## 🐛 已知问题

1. shadcn/ui 需要手动配置（已创建 components.json）
2. Supabase API keys 需要从 Dashboard 获取
3. Stripe 密钥需要配置

## 💡 开发提示

1. **代码风格**: 使用 TypeScript strict mode
2. **组件**: 优先使用 shadcn/ui 组件
3. **样式**: 使用 Tailwind CSS，避免自定义 CSS
4. **API**: 所有 API 路由放在 `app/api/` 下
5. **类型**: 使用 `database/types.ts` 中的类型定义

## 🔗 有用链接

- [Next.js 文档](https://nextjs.org/docs)
- [Supabase 文档](https://supabase.com/docs)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [shadcn/ui](https://ui.shadcn.com)
- [Stripe 文档](https://stripe.com/docs)

---

**创建时间**: 2026-03-06
**最后更新**: 2026-03-06
**开发服务器**: http://localhost:3000
**状态**: 开发中 🚧
