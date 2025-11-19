# Twelve-Factor App - Code Examples

Practical examples showing twelve-factor compliant vs non-compliant code.

## Factor III: Config

### ❌ Bad: Hardcoded Credentials

```javascript
// config.js
module.exports = {
  database: {
    host: 'prod-db.example.com',
    user: 'admin',
    password: 'super_secret_123',
    port: 5432
  },
  apiKey: 'sk_live_abc123xyz',
  secretKey: 'my-secret-key-2024'
};
```

### ✓ Good: Environment Variables

```javascript
// config.js
module.exports = {
  database: {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT || 5432
  },
  apiKey: process.env.API_KEY,
  secretKey: process.env.SECRET_KEY
};
```

```bash
# .env (not committed to repo)
DB_HOST=prod-db.example.com
DB_USER=admin
DB_PASSWORD=super_secret_123
DB_PORT=5432
API_KEY=sk_live_abc123xyz
SECRET_KEY=my-secret-key-2024
```

---

## Factor VI: Processes (Stateless)

### ❌ Bad: In-Memory Session Storage

```python
# Flask app with in-memory sessions
from flask import Flask, session

app = Flask(__name__)
app.secret_key = 'hard-coded-secret'  # Also violates Factor III!

@app.route('/login', methods=['POST'])
def login():
    # Session stored in process memory - not scalable!
    session['user_id'] = user.id
    session['username'] = user.username
    return 'Logged in'
```

**Problems:**
- Can't scale horizontally (requires sticky sessions)
- Sessions lost on process restart
- Not resilient to crashes

### ✓ Good: External Session Store

```python
# Flask app with Redis sessions
from flask import Flask, session
from flask_session import Session
import redis
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ['SECRET_KEY']
app.config['SESSION_TYPE'] = 'redis'
app.config['SESSION_REDIS'] = redis.from_url(os.environ['REDIS_URL'])
Session(app)

@app.route('/login', methods=['POST'])
def login():
    # Session stored in Redis - stateless and scalable!
    session['user_id'] = user.id
    session['username'] = user.username
    return 'Logged in'
```

---

## Factor X: Dev/Prod Parity

### ❌ Bad: Different Databases

```python
# settings.py
import os

if os.environ.get('ENV') == 'production':
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': 'proddb',
            'HOST': 'prod-db.example.com',
        }
    }
else:
    # SQLite in development - BAD!
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': 'db.sqlite3',
        }
    }
```

**Problems:**
- SQL dialect differences
- Different transaction behavior
- Different locking mechanisms
- Code that works in dev may fail in prod

### ✓ Good: Same Database Everywhere

```python
# settings.py
import os

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ['DB_NAME'],
        'USER': os.environ['DB_USER'],
        'PASSWORD': os.environ['DB_PASSWORD'],
        'HOST': os.environ['DB_HOST'],
        'PORT': os.environ['DB_PORT'],
    }
}
```

```yaml
# docker-compose.yml for local development
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    ports:
      - "${DB_PORT}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

---

## Factor XI: Logs

### ❌ Bad: Log Files Management

```javascript
const fs = require('fs');
const path = require('path');

class Logger {
  constructor() {
    this.logFile = path.join(__dirname, 'logs', 'app.log');
    this.errorFile = path.join(__dirname, 'logs', 'error.log');
  }

  log(message) {
    const timestamp = new Date().toISOString();
    const logMessage = `${timestamp} - ${message}\n`;

    // Writing to files - BAD!
    fs.appendFileSync(this.logFile, logMessage);

    // Log rotation logic - app shouldn't do this!
    this.rotateLogsIfNeeded();
  }

  rotateLogsIfNeeded() {
    const stats = fs.statSync(this.logFile);
    if (stats.size > 10 * 1024 * 1024) { // 10MB
      // Complex rotation logic...
    }
  }
}
```

### ✓ Good: Stdout Logging

```javascript
class Logger {
  log(message, level = 'info') {
    const timestamp = new Date().toISOString();
    const logEntry = JSON.stringify({
      timestamp,
      level,
      message
    });

    // Write to stdout - let environment handle routing!
    console.log(logEntry);
  }

  error(message) {
    this.log(message, 'error');
  }

  info(message) {
    this.log(message, 'info');
  }
}
```

**In production, pipe to log aggregator:**
```bash
# Application writes to stdout, system captures and routes
node app.js | tee -a /var/log/app.log | logger -t myapp
```

---

## Factor II: Dependencies

### ❌ Bad: Implicit Dependencies

```python
# app.py
import cv2  # Assuming OpenCV is installed system-wide
import requests
from mymodule import helper

def process_image(path):
    # Relies on system ImageMagick being installed
    os.system('convert input.jpg -resize 800x600 output.jpg')
    # ...
```

**Problems:**
- No explicit dependency declaration
- Assumes system packages exist
- Not reproducible on new machines

### ✓ Good: Explicit Dependencies

```python
# requirements.txt
opencv-python==4.8.1.78
requests==2.31.0
Pillow==10.1.0  # Pure Python alternative to ImageMagick

# app.py
import cv2
import requests
from PIL import Image
from mymodule import helper

def process_image(path):
    # Use vendored library instead of system tool
    img = Image.open('input.jpg')
    img = img.resize((800, 600))
    img.save('output.jpg')
```

**Setup for new developers:**
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install all dependencies
pip install -r requirements.txt

# Everything is isolated and reproducible!
```

---

## Factor VII: Port Binding

### ❌ Bad: Assumes Webserver Injection

```php
<?php
// index.php - Assumes Apache mod_php or similar

$db = new PDO('mysql:host=localhost;dbname=myapp', 'user', 'pass');
$users = $db->query('SELECT * FROM users')->fetchAll();

foreach ($users as $user) {
    echo "<p>{$user['name']}</p>";
}
```

**Problems:**
- Requires external webserver (Apache, nginx + PHP-FPM)
- Not self-contained
- Can't easily become backing service for another app

### ✓ Good: Self-Contained with Port Binding

```javascript
// app.js - Self-contained Express app
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/users', async (req, res) => {
  const users = await db.query('SELECT * FROM users');
  res.json(users);
});

// Bind to port - completely self-contained!
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

```bash
# Run directly, no external webserver needed
PORT=3000 node app.js
```

---

## Factor V: Build, Release, Run

### ❌ Bad: Building at Runtime

```dockerfile
# Dockerfile that compiles at runtime - BAD!
FROM node:18

WORKDIR /app
COPY . .

# Install deps and build at container start - SLOW!
CMD npm install && npm run build && npm start
```

**Problems:**
- Slow startup times
- Build failures can break production
- Can't rollback to previous releases easily

### ✓ Good: Separate Build and Run

```dockerfile
# Dockerfile with separate build stage
FROM node:18 AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Runtime stage - only run, no build!
FROM node:18-slim

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Fast startup - just run!
CMD ["node", "dist/server.js"]
```

**Release process:**
```bash
# Build stage
docker build -t myapp:v123 .

# Release stage (combine build + config)
docker tag myapp:v123 registry.example.com/myapp:v123
docker push registry.example.com/myapp:v123

# Run stage
docker run -e DB_HOST=prod-db \
           -e API_KEY=$API_KEY \
           registry.example.com/myapp:v123
```

---

## Factor IX: Disposability

### ❌ Bad: Slow Startup, No Graceful Shutdown

```javascript
const express = require('express');
const app = express();

// Slow startup - loads everything synchronously
const heavyData = require('./data/large-dataset.json'); // 100MB file
const models = loadAllModels(); // Takes 2 minutes

app.get('/api/data', (req, res) => {
  res.json(heavyData);
});

// No graceful shutdown handling!
app.listen(3000);
```

### ✓ Good: Fast Startup, Graceful Shutdown

```javascript
const express = require('express');
const app = express();

// Fast startup - load only what's needed
app.get('/api/data', async (req, res) => {
  // Load on-demand
  const data = await loadDataFromCache();
  res.json(data);
});

const server = app.listen(3000);

// Graceful shutdown on SIGTERM
process.on('SIGTERM', () => {
  console.log('SIGTERM received, starting graceful shutdown');

  server.close(() => {
    console.log('HTTP server closed');

    // Close database connections
    db.close(() => {
      console.log('Database connections closed');
      process.exit(0);
    });
  });

  // Force shutdown after 30 seconds
  setTimeout(() => {
    console.error('Forced shutdown after timeout');
    process.exit(1);
  }, 30000);
});
```

---

## Factor XII: Admin Processes

### ❌ Bad: Separate Admin Scripts

```python
# scripts/migrate_db.py (outside main app)
import psycopg2

# Different dependencies, different config!
conn = psycopg2.connect(
    host='localhost',  # Hardcoded!
    database='myapp',
    user='admin',
    password='secret'
)

cursor = conn.cursor()
cursor.execute('ALTER TABLE users ADD COLUMN email VARCHAR(255)')
conn.commit()
```

### ✓ Good: Admin Tasks with Same Environment

```python
# manage.py (part of main app)
import os
import sys
from app import create_app, db

def migrate():
    """Run database migrations."""
    # Uses same config as main app!
    app = create_app(os.environ.get('FLASK_ENV', 'production'))

    with app.app_context():
        # Same database connection as app
        db.engine.execute('ALTER TABLE users ADD COLUMN email VARCHAR(255)')

if __name__ == '__main__':
    if sys.argv[1] == 'migrate':
        migrate()
```

**Running admin tasks:**
```bash
# Same environment as app processes!
python manage.py migrate

# Or via deployment platform
heroku run python manage.py migrate
```

---

## Complete Example: Twelve-Factor Node.js App

```javascript
// server.js
require('dotenv').config(); // Factor III: Load env vars
const express = require('express');
const redis = require('redis');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000; // Factor VII: Port binding

// Factor IV: Backing services as attached resources
const db = new Pool({
  connectionString: process.env.DATABASE_URL
});

const cache = redis.createClient({
  url: process.env.REDIS_URL
});

// Factor VI: Stateless processes
app.get('/api/user/:id', async (req, res) => {
  const userId = req.params.id;

  // Check cache first
  const cached = await cache.get(`user:${userId}`);
  if (cached) {
    return res.json(JSON.parse(cached));
  }

  // Query database
  const result = await db.query('SELECT * FROM users WHERE id = $1', [userId]);
  const user = result.rows[0];

  // Cache for next time
  await cache.setex(`user:${userId}`, 3600, JSON.stringify(user));

  res.json(user);
});

// Factor XI: Logs to stdout
app.use((req, res, next) => {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    method: req.method,
    path: req.path,
    ip: req.ip
  }));
  next();
});

const server = app.listen(PORT, () => {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    event: 'server_started',
    port: PORT
  }));
});

// Factor IX: Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received');

  server.close(async () => {
    await db.end();
    await cache.quit();
    process.exit(0);
  });
});
```

```json
// package.json - Factor II: Explicit dependencies
{
  "name": "twelve-factor-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.0",
    "redis": "^4.6.7",
    "dotenv": "^16.0.3"
  },
  "scripts": {
    "start": "node server.js"
  }
}
```

```dockerfile
# Dockerfile - Factor V: Build, release, run
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

FROM node:18-slim
WORKDIR /app
COPY --from=builder /app .
EXPOSE 3000
CMD ["node", "server.js"]
```

```bash
# .env.example (committed)
DATABASE_URL=postgresql://user:password@localhost:5432/myapp
REDIS_URL=redis://localhost:6379
PORT=3000

# .env (not committed, Factor III)
DATABASE_URL=postgresql://prod_user:prod_pass@prod-db.example.com:5432/prod_db
REDIS_URL=redis://prod-redis.example.com:6379
PORT=3000
```

This example demonstrates all twelve factors working together!
