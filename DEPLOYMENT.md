# Deploying Rails Finance Tracker to Railway

This guide will walk you through deploying your Ruby on Rails Finance Tracker application to Railway, a modern cloud platform for deploying applications.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Project Configuration](#project-configuration)
3. [Railway Setup](#railway-setup)
4. [Environment Variables](#environment-variables)
5. [Database Setup](#database-setup)
6. [Deployment](#deployment)
7. [Post-Deployment](#post-deployment)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

- Ruby on Rails application (this guide uses Rails 8.0.2)
- Git repository (GitHub recommended)
- Railway account ([sign up here](https://railway.app))
- Railway CLI installed (optional but recommended)

### Installing Railway CLI
```bash
# Windows (PowerShell)
iwr -useb railway.app/install.ps1 | iex

# macOS/Linux
curl -fsSL railway.app/install.sh | sh
```

## Project Configuration

### 1. Update Gemfile

Ensure your `Gemfile` includes PostgreSQL for production:

```ruby
# Use sqlite3 as the database for Active Record in development/test
gem "sqlite3", ">= 2.1", group: [:development, :test]
# Use PostgreSQL for production
gem "pg", "~> 1.1", group: :production
```

### 2. Create Procfile

Create a `Procfile` in your project root:

```
web: bundle exec rails server -p $PORT -e production
release: bundle exec rails db:create db:migrate
```

### 3. Configure Database for Production

Update `config/database.yml`:

```yaml
production:
  adapter: postgresql
  encoding: unicode
  host: <%= ENV['DATABASE_HOST'] %>
  port: <%= ENV['DATABASE_PORT'] %>
  database: <%= ENV['DATABASE_NAME'] %>
  username: <%= ENV['DATABASE_USERNAME'] %>
  password: <%= ENV['DATABASE_PASSWORD'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  sslmode: require
```

### 4. Update Production Environment

In `config/environments/production.rb`, configure for Railway:

```ruby
# Disable SSL enforcement (Railway handles this)
config.assume_ssl = false
config.force_ssl = false

# Configure allowed hosts
config.hosts = [
  ENV['RAILWAY_PUBLIC_DOMAIN'],     # Allow requests from Railway domain
  /.*\.up\.railway\.app/,           # Allow requests from Railway subdomains
  'localhost'                       # Allow localhost for development
].compact

# Configure mailer host
config.action_mailer.default_url_options = { host: ENV['RAILWAY_PUBLIC_DOMAIN'] || 'localhost' }

# Use memory store for cache (simpler for Railway)
config.cache_store = :memory_store

# Use async adapter for jobs
config.active_job.queue_adapter = :async
```

### 5. Create Railway Configuration (Optional)

Create `railway.toml`:

```toml
[build]
builder = "heroku/buildpacks:20"

[deploy]
healthcheckPath = "/up"
healthcheckTimeout = 300
restartPolicyType = "on_failure"
restartPolicyMaxRetries = 10

[[services]]
name = "web"
```

### 6. Install Dependencies

```bash
bundle install
```

## Railway Setup

### Option 1: Using Railway Dashboard (Recommended)

1. **Create Account**: Sign up at [railway.app](https://railway.app)
2. **Create New Project**: Click "New Project"
3. **Connect GitHub**: Select "Deploy from GitHub repo"
4. **Select Repository**: Choose your finance-tracker repository
5. **Configure**: Railway will auto-detect it's a Rails app

### Option 2: Using Railway CLI

```bash
# Login to Railway
railway login

# Initialize project in your app directory
railway init

# Link to existing project (if you created one in dashboard)
railway link [project-id]
```

## Environment Variables

Set these environment variables in Railway dashboard or via CLI:

### Required Variables

```bash
RAILS_ENV=production
RAILS_MASTER_KEY=your_master_key_here
SECRET_KEY_BASE=your_secret_key_base_here
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_LEVEL=info
```

### Getting Your Keys

1. **RAILS_MASTER_KEY**: Copy from `config/master.key`
2. **SECRET_KEY_BASE**: Generate with `bundle exec rails secret`

### Setting via Railway CLI

```bash
railway variables set RAILS_ENV=production
railway variables set RAILS_MASTER_KEY=your_master_key_here
railway variables set SECRET_KEY_BASE=your_secret_key_base_here
railway variables set RAILS_SERVE_STATIC_FILES=true
railway variables set RAILS_LOG_LEVEL=info
```

### Setting via Dashboard

1. Go to your Railway project
2. Click on your service
3. Go to "Variables" tab
4. Add each environment variable

## Database Setup

### Add PostgreSQL Service

1. **In Railway Dashboard**:
   - Click "New Service"
   - Select "Database"
   - Choose "PostgreSQL"
   - Railway will automatically set `DATABASE_URL`

2. **Via CLI**:
   ```bash
   railway add postgresql
   ```

### Verify Database Connection

Railway automatically sets `DATABASE_URL` when you add PostgreSQL. Your app will use this URL, which includes all connection parameters.

## Deployment

### Method 1: Automatic Deployment (GitHub Integration)

1. **Connect Repository**: Ensure your Railway project is connected to GitHub
2. **Commit Changes**:
   ```bash
   git add .
   git commit -m "Configure app for Railway production deployment"
   git push origin main
   ```
3. **Auto Deploy**: Railway automatically builds and deploys

### Method 2: Manual Deployment (CLI)

```bash
# Deploy current directory
railway up

# Or deploy specific service
railway up --service web
```

### Deployment Process

Railway will:
1. **Build**: Install dependencies and compile assets
2. **Release**: Run database migrations via release command
3. **Deploy**: Start the web server on assigned port

## Post-Deployment

### 1. Verify Deployment

- Check deployment logs in Railway dashboard
- Visit your app URL (provided in Railway dashboard)
- Test core functionality

### 2. Monitor Application

- **Logs**: View real-time logs in Railway dashboard
- **Metrics**: Monitor CPU, memory, and request metrics
- **Health Check**: Railway automatically monitors `/up` endpoint

### 3. Custom Domain (Optional)

1. Go to "Settings" in Railway dashboard
2. Add your custom domain
3. Configure DNS records as instructed

## Troubleshooting

### Common Issues

#### 1. Database Connection Errors
```bash
# Check if PostgreSQL service is running
railway status

# Verify DATABASE_URL is set
railway variables
```

#### 2. Asset Compilation Errors
```bash
# Precompile assets locally to test
RAILS_ENV=production bundle exec rails assets:precompile

# Clear assets and retry
RAILS_ENV=production bundle exec rails assets:clobber
```

#### 3. Migration Errors
```bash
# Check database status
railway connect postgresql

# Run migrations manually
railway run rails db:migrate
```

#### 4. Host Authorization Errors
Ensure your `production.rb` has correct host configuration:
```ruby
config.hosts = [
  ENV['RAILWAY_PUBLIC_DOMAIN'],
  /.*\.up\.railway\.app/,
  'localhost'
].compact
```

### Useful Railway CLI Commands

```bash
# View logs
railway logs

# Connect to database
railway connect postgresql

# Run Rails console in production
railway run rails console

# Check service status
railway status

# View environment variables
railway variables

# Open app in browser
railway open
```

### Debugging Production Issues

1. **Check Logs**: Always start with Railway logs
2. **Environment Variables**: Verify all required variables are set
3. **Database**: Ensure PostgreSQL service is running
4. **Health Check**: Verify `/up` endpoint responds
5. **DNS**: For custom domains, check DNS propagation

## Security Considerations

1. **Never commit secrets**: Keep `master.key` and credentials secure
2. **Use environment variables**: For all sensitive configuration
3. **Enable HTTPS**: Railway provides SSL termination
4. **Regular updates**: Keep dependencies updated

## Performance Tips

1. **Database Connection Pooling**: Configure appropriate pool size
2. **Asset CDN**: Consider using Railway's CDN for assets
3. **Caching**: Implement Redis for better performance (optional)
4. **Background Jobs**: Use Railway's background workers for heavy tasks

## Support

- **Railway Documentation**: [docs.railway.app](https://docs.railway.app)
- **Railway Discord**: [discord.gg/railway](https://discord.gg/railway)
- **Rails Guides**: [guides.rubyonrails.org](https://guides.rubyonrails.org)

---

## Quick Deployment Checklist

- [ ] Update Gemfile with PostgreSQL
- [ ] Create Procfile
- [ ] Configure database.yml for production
- [ ] Update production.rb settings
- [ ] Set environment variables in Railway
- [ ] Add PostgreSQL service
- [ ] Commit and push changes
- [ ] Verify deployment
- [ ] Test application functionality

Your Rails Finance Tracker should now be successfully deployed on Railway! 🚀
