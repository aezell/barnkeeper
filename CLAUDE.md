# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Setup and Installation:**
- `mix setup` - Install dependencies, setup database, and build assets
- `mix deps.get` - Install Elixir dependencies only

**Development Server:**
- `mix phx.server` - Start Phoenix server (visit localhost:4000)
- `iex -S mix phx.server` - Start server in interactive Elixir shell

**Database Management:**
- `mix ecto.create` - Create database
- `mix ecto.migrate` - Run migrations
- `mix ecto.setup` - Create database, migrate, and run seeds
- `mix ecto.reset` - Drop and recreate database (ONLY use when explicitly required)

**Testing:**
- `mix test` - Run all tests (automatically creates test DB and runs migrations)

**Asset Management:**
- `mix assets.setup` - Install asset dependencies (Tailwind, esbuild)
- `mix assets.build` - Build assets for development
- `mix assets.deploy` - Build and minify assets for production
- Always run `mix compile` after your changes
- Always run `mix format` after your changes

**Code Quality:**
- `mix format` - Format Elixir code according to .formatter.exs
- `mix compile` - Compile the project

## Project Architecture

**Framework and Dependencies:**
- Phoenix 1.7.21 with LiveView 1.0+ for interactive components
- Ecto 3.10+ with PostgreSQL for database ORM
- Bandit web server adapter
- Tailwind CSS 3.4.3 with Heroicons for styling
- Swoosh for email handling
- Bcrypt for password hashing

**Core Business Contexts:**
- **Accounts** (`lib/barnkeeper/accounts/`) - User management and authentication
- **Activities** (`lib/barnkeeper/activities/`) - Rides and training activities
- **Care** (`lib/barnkeeper/care/`) - Vet visits, farrier visits, vaccinations, feedings
- **Facilities** (`lib/barnkeeper/facilities/`) - Locations and barn management
- **Horses** (`lib/barnkeeper/horses/`) - Horse profiles and management
- **Media** (`lib/barnkeeper/media/`) - Photo uploads and management
- **Notes** (`lib/barnkeeper/notes/`) - General note-taking
- **Teams** (`lib/barnkeeper/teams/`) - Team and membership management

**Key Entities:**
- Users with authentication and team memberships
- Horses with photos and care records
- Teams with role-based access
- Activities (rides) with scheduling
- Care records (vet visits, farrier visits, vaccinations, feedings)
- Notes and photos associated with horses

**Web Layer (BarnkeeperWeb):**
- LiveView-first architecture for most pages
- Authentication pipelines with session-based auth
- Router with authenticated and public scopes
- Core components with Heroicons integration
- HEEx templates with LiveView HTML formatter

**Key Routes:**
- `/dashboard` - Main dashboard
- `/horses` - Horse management with photo uploads
- `/vet_visits`, `/farrier_visits`, `/vaccinations` - Care management
- `/feedings` - Feeding schedules
- `/notes` - Note management
- `/calendar` - Calendar view
- `/team/setup` - Team configuration

**Database:**
- PostgreSQL with Ecto migrations
- UTC datetime timestamps
- Comprehensive schema covering all business domains
- Photo uploads with file management

**Frontend:**
- Tailwind CSS with custom brand colors and forms plugin
- Heroicons embedded via CSS masks
- LiveView JavaScript for interactivity
- Minimal custom JavaScript - prefer LiveView patterns

**Development Setup:**
- Local development with PostgreSQL
- Asset pipeline with esbuild and Tailwind
- LiveDashboard for development insights
- Swoosh mailbox preview for email testing

**Code Style and Conventions:**
- Follow Elixir/Phoenix conventions and .formatter.exs config
- Import deps: `:ecto`, `:ecto_sql`, `:phoenix` in formatter
- Use Phoenix.LiveView.HTMLFormatter for .heex templates
- Module naming: `Barnkeeper.*` for contexts, `BarnkeeperWeb.*` for web layer
- UTC datetime for all timestamps
- Always check mix.exs for dependency versions before changes
- Prefer LiveView over custom JavaScript when possible

**Safety Guidelines:**
- NEVER run `mix ecto.reset` without explicit permission
- NEVER perform destructive database operations in development
- Always use UTC datetime for new timestamp fields
- Ensure authentication on all protected routes
- Validate file uploads for security

**Best Practices:**
- Use contexts to organize business logic
- Keep controllers thin, put logic in contexts
- Leverage LiveView for interactive features
- Follow Phoenix generator patterns for consistency
- Use Ecto changesets for data validation
- Test both happy and error paths