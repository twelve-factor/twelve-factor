# Twelve-Factor Code Examples

This file provides concrete code examples for implementing twelve-factor principles across different programming languages and frameworks.

## Factor II: Dependencies

### Python with requirements.txt

**Good:**
```python
# requirements.txt
flask==2.3.0
psycopg2-binary==2.9.6
redis==4.5.5
python-dotenv==1.0.0

# app.py
import flask
import psycopg2
import redis
from dotenv import load_dotenv
```

**Bad:**
```python
# No requirements.txt file
# Assuming packages are globally installed
import flask  # Which version? Unknown!
```

### Node.js with package.json

**Good:**
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.0",
    "redis": "^4.6.7",
    "dotenv": "^16.0.3"
  }
}
```

**Bad:**
```javascript
// Relying on globally installed packages
// No package.json or incomplete dependencies
```

### Ruby with Gemfile

**Good:**
```ruby
# Gemfile
source 'https://rubygems.org'

gem 'rails', '~> 7.0.0'
gem 'pg', '~> 1.5'
gem 'redis', '~> 5.0'
gem 'dotenv-rails', '~> 2.8'
```

### Go with go.mod

**Good:**
```go
// go.mod
module github.com/myapp

go 1.20

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/lib/pq v1.10.9
    github.com/redis/go-redis/v9 v9.0.5
)
```

## Factor III: Config

### Python - Environment Variables

**Good:**
```python
import os
from dotenv import load_dotenv

load_dotenv()  # Load from .env file in development

DATABASE_URL = os.environ['DATABASE_URL']
REDIS_URL = os.environ['REDIS_URL']
SECRET_KEY = os.environ['SECRET_KEY']
API_KEY = os.environ.get('API_KEY')  # Optional with default

# Validate required config at startup
required_vars = ['DATABASE_URL', 'REDIS_URL', 'SECRET_KEY']
missing = [var for var in required_vars if var not in os.environ]
if missing:
    raise ValueError(f"Missing required environment variables: {missing}")
```

**Bad:**
```python
# Hardcoded credentials
DATABASE_URL = "postgresql://user:password@localhost/mydb"
SECRET_KEY = "hardcoded-secret-key"

# Or config files with credentials
import json
with open('config.json') as f:
    config = json.load(f)
    DATABASE_URL = config['database_url']
```

### Node.js - Environment Variables

**Good:**
```javascript
require('dotenv').config(); // Load .env in development

const config = {
  database: process.env.DATABASE_URL,
  redis: process.env.REDIS_URL,
  secretKey: process.env.SECRET_KEY,
  port: process.env.PORT || 3000
};

// Validate required config
const required = ['DATABASE_URL', 'REDIS_URL', 'SECRET_KEY'];
const missing = required.filter(key => !process.env[key]);
if (missing.length > 0) {
  throw new Error(`Missing required env vars: ${missing.join(', ')}`);
}

module.exports = config;
```

**Bad:**
```javascript
// Config object with hard-coded values
const config = {
  production: {
    database: 'prod-db.example.com',
    redis: 'prod-redis.example.com'
  },
  development: {
    database: 'localhost',
    redis: 'localhost'
  }
};

module.exports = config[process.env.NODE_ENV];
```

### Ruby - Environment Variables

**Good:**
```ruby
# config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>

# config/initializers/redis.rb
$redis = Redis.new(url: ENV['REDIS_URL'])

# Validation
required_vars = %w[DATABASE_URL REDIS_URL SECRET_KEY_BASE]
missing = required_vars.reject { |var| ENV[var] }
raise "Missing env vars: #{missing.join(', ')}" if missing.any?
```

### .env File (Development Only - Never Commit)

```bash
# .env - LOCAL DEVELOPMENT ONLY
DATABASE_URL=postgresql://localhost/myapp_dev
REDIS_URL=redis://localhost:6379
SECRET_KEY=dev-secret-key-change-in-production
API_KEY=test-api-key

# .gitignore should include:
# .env
# .env.local
```

## Factor IV: Backing Services

### Python - Attached Resources

**Good:**
```python
import os
import psycopg2
import redis

# Database as attached resource via URL
db_conn = psycopg2.connect(os.environ['DATABASE_URL'])

# Cache as attached resource via URL
cache = redis.from_url(os.environ['REDIS_URL'])

# Can swap to different service by changing URL
# No code changes needed
```

**Bad:**
```python
# Hard-coded connection to specific database
db_conn = psycopg2.connect(
    host='prod-db.example.com',
    database='myapp',
    user='myapp_user',
    password='hardcoded'
)

# Special code for different providers
if os.environ.get('USE_ELASTICACHE'):
    # ElastiCache-specific code
    cache = setup_elasticache()
else:
    # Redis-specific code
    cache = setup_redis()
```

### Node.js - Attached Resources

**Good:**
```javascript
const { Pool } = require('pg');
const redis = require('redis');

// Database as attached resource
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Cache as attached resource
const cache = redis.createClient({
  url: process.env.REDIS_URL
});

// Message queue as attached resource
const queueUrl = process.env.RABBITMQ_URL;
```

## Factor V: Build, Release, Run

### Docker-based Build/Release/Run

**Good:**

```dockerfile
# Dockerfile - Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Release stage - Combine build with runtime
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package.json ./

# Run stage - Execute the release
CMD ["node", "dist/server.js"]
```

**Build script:**
```bash
#!/bin/bash
# build.sh - Creates versioned artifact

# Build Docker image (build stage)
docker build -t myapp:build .

# Tag with release version (release stage)
VERSION=$(git rev-parse --short HEAD)
docker tag myapp:build myapp:$VERSION
docker tag myapp:build myapp:latest

echo "Built release: myapp:$VERSION"
```

**Bad:**
```bash
# Deploying source code and building in production
scp -r . production-server:/app
ssh production-server "cd /app && npm install && npm run build"
```

### Python Build/Release/Run

**Good:**

```bash
# build.sh
#!/bin/bash
# Build: Create wheel
python setup.py bdist_wheel

# Release: Tag with version and config
VERSION=$(git describe --tags)
docker build -t myapp:$VERSION .

# Run: Execute the release
# docker run -e DATABASE_URL=$DATABASE_URL myapp:$VERSION
```

**Bad:**
```bash
# Building in production
git pull origin main
pip install -r requirements.txt
python manage.py migrate  # Mixing build and run
python manage.py runserver  # No separation
```

## Factor VI: Processes

### Python - Stateless Processes

**Good:**
```python
from flask import Flask, session
import redis
import os

app = Flask(__name__)
app.secret_key = os.environ['SECRET_KEY']

# Session in Redis, not memory
app.config['SESSION_TYPE'] = 'redis'
app.config['SESSION_REDIS'] = redis.from_url(os.environ['REDIS_URL'])

# File uploads go to S3, not local filesystem
import boto3
s3 = boto3.client('s3')

@app.route('/upload', methods=['POST'])
def upload():
    file = request.files['file']
    # Good: Store in backing service
    s3.upload_fileobj(file, 'my-bucket', file.filename)
    return {'status': 'uploaded'}
```

**Bad:**
```python
from flask import Flask, session

app = Flask(__name__)
app.secret_key = 'hardcoded'

# Bad: Session in memory
app.config['SESSION_TYPE'] = 'filesystem'

# Bad: File uploads to local disk
@app.route('/upload', methods=['POST'])
def upload():
    file = request.files['file']
    file.save(f'/var/uploads/{file.filename}')  # Lost on restart!
    return {'status': 'uploaded'}
```

### Node.js - Stateless Processes

**Good:**
```javascript
const express = require('express');
const session = require('express-session');
const RedisStore = require('connect-redis').default;
const redis = require('redis');
const AWS = require('aws-sdk');

const app = express();
const redisClient = redis.createClient({ url: process.env.REDIS_URL });
const s3 = new AWS.S3();

// Session in Redis
app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SECRET_KEY,
  resave: false,
  saveUninitialized: false
}));

// File uploads to S3
app.post('/upload', async (req, res) => {
  await s3.upload({
    Bucket: 'my-bucket',
    Key: req.file.name,
    Body: req.file.data
  }).promise();
  res.json({ status: 'uploaded' });
});
```

**Bad:**
```javascript
const express = require('express');
const session = require('express-session');
const fs = require('fs');

const app = express();

// Bad: Session in memory
app.use(session({
  secret: 'hardcoded',
  resave: false,
  saveUninitialized: true
}));

// Bad: File uploads to local disk
app.post('/upload', (req, res) => {
  fs.writeFileSync(`./uploads/${req.file.name}`, req.file.data);
  res.json({ status: 'uploaded' });
});
```

## Factor VII: Port Binding

### Python - Self-Contained Web Server

**Good:**
```python
import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello World!'

if __name__ == '__main__':
    # Port from environment
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
```

**Production with Gunicorn:**
```bash
# Procfile
web: gunicorn -b 0.0.0.0:$PORT app:app
```

**Bad:**
```python
# Assuming specific port
app.run(host='0.0.0.0', port=5000)  # Can't run multiple instances

# Or requiring Apache/nginx module
# (instead of self-contained server)
```

### Node.js - Self-Contained Web Server

**Good:**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello World!');
});

// Port from environment
const port = process.env.PORT || 3000;
app.listen(port, '0.0.0.0', () => {
  console.log(`Server listening on port ${port}`);
});
```

**Bad:**
```javascript
// Hard-coded port
app.listen(3000);  // Can't configure per environment

// Or requiring separate web server
// (PHP + Apache, Rails + Passenger, etc.)
```

## Factor VIII: Concurrency

### Procfile - Process Types

**Good:**
```
# Procfile - Different process types
web: gunicorn -b 0.0.0.0:$PORT app:app
worker: celery -A tasks worker --loglevel=info
scheduler: celery -A tasks beat --loglevel=info
```

**Python with Celery:**
```python
# app.py - Web process
from flask import Flask
from tasks import send_email

app = Flask(__name__)

@app.route('/send')
def send():
    send_email.delay('[email protected]')  # Async to worker
    return 'Email queued'

# tasks.py - Worker process
from celery import Celery

celery = Celery('tasks', broker=os.environ['REDIS_URL'])

@celery.task
def send_email(to):
    # Long-running task in worker process
    send_actual_email(to)
```

**Bad:**
```python
# Doing background work in web process
@app.route('/send')
def send():
    send_email('[email protected]')  # Blocks web process!
    return 'Email sent'
```

### Node.js with Bull Queue

**Good:**
```javascript
// server.js - Web process
const express = require('express');
const Queue = require('bull');
const app = express();

const emailQueue = new Queue('email', process.env.REDIS_URL);

app.post('/send', (req, res) => {
  emailQueue.add({ to: req.body.email });
  res.json({ status: 'queued' });
});

// worker.js - Worker process
const Queue = require('bull');
const emailQueue = new Queue('email', process.env.REDIS_URL);

emailQueue.process(async (job) => {
  await sendEmail(job.data.to);
});
```

## Factor IX: Disposability

### Graceful Shutdown

**Python:**
```python
import signal
import sys
from flask import Flask

app = Flask(__name__)

def graceful_shutdown(signum, frame):
    print('Received shutdown signal, cleaning up...')
    # Close database connections
    db.close()
    # Finish processing current requests
    sys.exit(0)

signal.signal(signal.SIGTERM, graceful_shutdown)
signal.signal(signal.SIGINT, graceful_shutdown)

if __name__ == '__main__':
    app.run()
```

**Node.js:**
```javascript
const express = require('express');
const app = express();

const server = app.listen(process.env.PORT);

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing server gracefully...');

  server.close(() => {
    console.log('Server closed');
    // Close database connections
    db.end();
    process.exit(0);
  });

  // Force close after 10 seconds
  setTimeout(() => {
    console.error('Forced shutdown');
    process.exit(1);
  }, 10000);
});
```

### Worker Process - Graceful Shutdown

**Python Celery:**
```python
from celery import Celery
from celery.signals import worker_shutdown

celery = Celery('tasks', broker=os.environ['REDIS_URL'])

# Configure for graceful shutdown
celery.conf.worker_pool_restarts = True

@worker_shutdown.connect
def cleanup(**kwargs):
    print('Worker shutting down, cleaning up...')
    # Cleanup code here
```

## Factor X: Dev/Prod Parity

### Same Backing Services

**Good:**
```yaml
# docker-compose.yml - Local development
version: '3.8'
services:
  app:
    build: .
    environment:
      DATABASE_URL: postgresql://postgres:password@db:5432/myapp
      REDIS_URL: redis://redis:6379

  db:
    image: postgres:15  # Same version as production

  redis:
    image: redis:7  # Same version as production
```

**Production (Heroku example):**
```bash
# Same PostgreSQL and Redis, just different URLs
heroku addons:create heroku-postgresql:standard-0
heroku addons:create heroku-redis:premium-0
```

**Bad:**
```python
# Different databases in dev vs production
if os.environ.get('ENV') == 'production':
    # PostgreSQL in production
    db = psycopg2.connect(os.environ['DATABASE_URL'])
else:
    # SQLite in development
    db = sqlite3.connect('dev.db')
```

## Factor XI: Logs

### Writing to stdout/stderr

**Python:**
```python
import logging
import sys

# Configure logging to stdout
logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
    format='%(asctime)s %(levelname)s: %(message)s'
)

logger = logging.getLogger(__name__)

# Good: Log to stdout
logger.info('User logged in', extra={'user_id': 123})
logger.error('Database connection failed', exc_info=True)
```

**Bad:**
```python
# Bad: Managing log files
logging.basicConfig(
    filename='/var/log/myapp.log',  # Don't manage files!
    level=logging.INFO
)

# Bad: Log rotation in app
from logging.handlers import RotatingFileHandler
handler = RotatingFileHandler('app.log', maxBytes=10000, backupCount=3)
```

**Node.js:**
```javascript
// Good: Log to stdout/stderr
console.log(JSON.stringify({
  level: 'info',
  message: 'User logged in',
  user_id: 123,
  timestamp: new Date().toISOString()
}));

console.error(JSON.stringify({
  level: 'error',
  message: 'Database connection failed',
  error: err.message,
  timestamp: new Date().toISOString()
}));
```

**Bad:**
```javascript
// Bad: Writing to log files
const fs = require('fs');
fs.appendFileSync('/var/log/app.log', 'Log message\n');
```

## Factor XII: Admin Processes

### Database Migrations

**Python (Django):**
```bash
# Good: Migration as one-off process with same environment
heroku run python manage.py migrate

# Bad: Running SQL directly
psql $DATABASE_URL < migration.sql
```

**Node.js (Sequelize):**
```bash
# Good: Migration with same codebase
heroku run npm run migrate

# Bad: Direct database access
mysql -h prod-db.example.com -u root -p myapp < schema.sql
```

### Rails Console

**Good:**
```bash
# Same codebase, same config
heroku run rails console
```

**Bad:**
```bash
# SSH to server and run different console
ssh production-server
cd /var/www/myapp
rails console  # Different codebase version!
```

### Data Import Script

**Good:**
```python
# scripts/import_users.py - In version control
import os
import sys
import psycopg2

# Uses same config as app
db = psycopg2.connect(os.environ['DATABASE_URL'])

def import_users(filename):
    # Import logic here
    pass

if __name__ == '__main__':
    import_users(sys.argv[1])
```

**Run as one-off:**
```bash
heroku run python scripts/import_users.py users.csv
```

**Bad:**
```python
# Local script not in version control
# Different dependencies, hard-coded credentials
import psycopg2
db = psycopg2.connect('postgresql://prod-db.example.com/myapp')
# Run from local machine
```

## Complete Example: Twelve-Factor Flask App

```python
# app.py
import os
import logging
import sys
import signal
from flask import Flask, session
from flask_session import Session
import psycopg2
import redis

# Logging to stdout (Factor XI)
logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
    format='%(asctime)s %(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)

# Config from environment (Factor III)
DATABASE_URL = os.environ['DATABASE_URL']
REDIS_URL = os.environ['REDIS_URL']
SECRET_KEY = os.environ['SECRET_KEY']

app = Flask(__name__)
app.config['SECRET_KEY'] = SECRET_KEY
app.config['SESSION_TYPE'] = 'redis'
app.config['SESSION_REDIS'] = redis.from_url(REDIS_URL)
Session(app)

# Backing services as attached resources (Factor IV)
db = psycopg2.connect(DATABASE_URL)
cache = redis.from_url(REDIS_URL)

# Stateless processes (Factor VI)
@app.route('/')
def index():
    # Session stored in Redis, not memory
    session['visits'] = session.get('visits', 0) + 1
    return f"Visits: {session['visits']}"

# Graceful shutdown (Factor IX)
def shutdown_handler(signum, frame):
    logger.info('Shutting down gracefully...')
    db.close()
    cache.close()
    sys.exit(0)

signal.signal(signal.SIGTERM, shutdown_handler)

if __name__ == '__main__':
    # Port binding (Factor VII)
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
```

```
# requirements.txt (Factor II: Dependencies)
Flask==2.3.2
Flask-Session==0.5.0
psycopg2-binary==2.9.6
redis==4.5.5
gunicorn==20.1.0
```

```
# Procfile (Factor VIII: Concurrency)
web: gunicorn -b 0.0.0.0:$PORT app:app
```

```dockerfile
# Dockerfile (Factor V: Build, Release, Run)
FROM python:3.11-slim

WORKDIR /app

# Build: Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Build: Copy application code
COPY . .

# Run: Execute the release
CMD gunicorn -b 0.0.0.0:$PORT app:app
```

```bash
# .env.example (Factor III: Config template)
DATABASE_URL=postgresql://localhost/myapp_dev
REDIS_URL=redis://localhost:6379
SECRET_KEY=change-me-in-production
PORT=5000
```

This complete example demonstrates all twelve factors in a single, production-ready application.
