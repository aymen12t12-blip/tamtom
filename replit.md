# طمطوم - Tamtom | منصة التجارة الإلكترونية للخضار والفواكه في السعودية

## Overview
منصة متكاملة لتجارة الخضار والفواكه إلكترونياً في المملكة العربية السعودية. تحتوي على ثلاثة واجهات: تطبيق العميل، تطبيق السائق، ولوحة الإدارة.
Currency: SAR (ريال سعودي / ر.س) — All prices in ar-SA locale.

## Architecture

### Frontend
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS + Radix UI components
- **State Management**: TanStack Query (React Query)
- **Routing**: Wouter
- **Icons**: Lucide React

### Backend
- **Server**: Node.js + Express (TypeScript)
- **Runtime**: tsx for development
- **WebSockets**: ws library for real-time updates

### Database
- **Database**: PostgreSQL (Replit built-in)
- **ORM**: Drizzle ORM
- **Schema**: `shared/schema.ts`
- **Migrations**: `drizzle/` directory

## Project Structure

```
/
├── client/          # React frontend
│   └── src/
│       ├── components/  # UI components (Radix-based)
│       ├── context/     # React Context providers
│       ├── contexts/    # Additional contexts
│       ├── hooks/       # Custom hooks
│       ├── pages/       # App pages (customer, admin, driver)
│       ├── services/    # API service layer
│       └── utils/       # Utility functions
├── server/          # Express backend
│   ├── routes/      # API endpoints
│   ├── services/    # Business logic
│   ├── db.ts        # DatabaseStorage implementation
│   ├── storage.ts   # Storage interface + MemStorage
│   ├── seed.ts      # Database seeding
│   ├── socket.ts    # WebSocket setup
│   └── viteServer.ts # Vite dev middleware
├── shared/          # Shared TypeScript types and schema
│   └── schema.ts    # Drizzle schema (single source of truth)
├── drizzle/         # DB migrations
└── drizzle.config.ts
```

## Development

### Running the App
```bash
npm run dev
```
The server starts on port 5000, serving both the Express API and Vite dev server via middleware.

### Database Setup
```bash
npm run db:push   # Push schema changes to database
npm run db:setup  # Run setup script
```

### Build for Production
```bash
npm run build     # Build both client and server
npm start         # Run production server
```

## Key Configuration

- **Port**: 5000 (both dev server and API)
- **Storage**: `USE_MEMORY_STORAGE = false` in `server/storage.ts` — uses PostgreSQL
- **Vite Config**: Root `vite.config.ts` serves client from `client/` directory
- **Host**: `0.0.0.0` for dev server (Replit proxy compatibility)
- **AllowedHosts**: `true` (bypasses host header check for Replit proxy)

## Environment Variables
- `DATABASE_URL` - PostgreSQL connection string (auto-set by Replit)
- `NODE_ENV` - development/production

## User Types
1. **Customers** - Browse restaurants, place orders, track delivery
2. **Drivers** - Accept/manage deliveries, track earnings
3. **Admins** - Full platform management (restaurants, menus, drivers, analytics)

## Default Seed Data
On first run with a fresh database, the app seeds:
- 5 categories (vegetables, fruits, dates, etc.)
- 3 restaurants
- 4 menu items
- 19 UI settings
- 2 admin users
- 2 drivers

## Drivers Schema — Extended Fields
The `drivers` table has these important fields:
- `paymentMode`: 'commission' | 'salary' — how driver is paid
- `commissionRate`: percentage of delivery fee (when paymentMode='commission')
- `salaryAmount`: monthly salary amount (when paymentMode='salary')
- `allowProfileEdit`: boolean — admin controls if driver can edit their own profile
- `notes`: admin notes about the driver
- `joinDate`: when the driver joined

## Admin Panel Features
- **إدارة السائقين**: 4-tab account dialog (بيانات السائق, المحفظة, المعاملات, العمولات)
- **الأقسام**: Search bar (sticky) added
- **العروض الخاصة**: No restaurant association required (global store offers)
- **Currency**: SAR everywhere (ر.س) — locale: ar-SA
