# Todo App Backend API

A RESTful API backend for the Todo App built with Node.js, Express, and MySQL/TiDB using MVC architecture.

## Features

- ✅ Complete MVC Architecture
- ✅ MySQL/TiDB Database with Sequelize ORM
- ✅ SSL Support for TiDB Cloud
- ✅ Optional JWT Authentication
- ✅ Rate Limiting
- ✅ CORS Support
- ✅ Input Validation
- ✅ Error Handling
- ✅ Guest User Support
- ✅ Deleted Tasks History
- ✅ Priority Levels (Low, Medium, High)
- ✅ Task Scheduling

## Prerequisites

- Node.js (v14 or higher)
- MySQL (v5.7 or higher) or TiDB Cloud cluster
- npm or yarn

## Installation

1. **Clone the repository**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` file with your database credentials.

### For Local Development (MySQL)

```env
PORT=3000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=3306
DB_NAME=todo_app
DB_USER=root
DB_PASSWORD=your_mysql_password

JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRES_IN=7d

AUTH_ENABLED=false
```

### For Production (TiDB Cloud)

1. Create a TiDB Cloud cluster at [tidbcloud.com](https://tidbcloud.com)
2. Get your cluster connection details from the dashboard
3. Update `.env` with TiDB Cloud credentials:

```env
PORT=3000
NODE_ENV=production

# TiDB Cloud connection details
DB_HOST=gateway01.us-west-2.prod.aws.tidbcloud.com
DB_PORT=4000
DB_NAME=todo_app
DB_USER=your_tidb_username.root
DB_PASSWORD=your_tidb_password
DB_SSL=true

JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRES_IN=7d

AUTH_ENABLED=false
```

4. **Create the database** (TiDB Cloud creates it automatically based on your connection)

5. **Run database migrations**
   ```bash
   npm run migrate
   ```

## Running the Server

### Development Mode
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will start on `http://localhost:3000`

## Deploying to Vercel

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**
   ```bash
   vercel login
   ```

3. **Deploy**
   ```bash
   vercel --prod
   ```

4. **Set Environment Variables**
   In Vercel dashboard, add your environment variables:
   - `DB_HOST`
   - `DB_PORT`
   - `DB_NAME`
   - `DB_USER`
   - `DB_PASSWORD`
   - `DB_SSL=true`
   - `JWT_SECRET`
   - `NODE_ENV=production`

## API Endpoints

### Health Check
- `GET /api/health` - Check API health

### Authentication (Optional)
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/profile` - Get user profile (requires auth)
- `PUT /api/auth/profile` - Update user profile (requires auth)

### Todos
- `GET /api/todos` - Get all todos (with optional filter: `?filter=pending|completed`)
- `GET /api/todos/:id` - Get single todo
- `POST /api/todos` - Create new todo
- `PUT /api/todos/:id` - Update todo
- `PATCH /api/todos/:id/toggle` - Toggle todo completion
- `DELETE /api/todos/:id` - Delete todo (saves to history)

### History (Deleted Todos)
- `GET /api/history` - Get all deleted todos
- `DELETE /api/history` - Clear deleted todos

## Authentication

Authentication is **optional** and can be enabled/disabled via the `AUTH_ENABLED` environment variable.

### When `AUTH_ENABLED=false` (Default)
- API works without authentication
- Guest users are identified by `X-Guest-ID` header
- Data is stored per guest ID

### When `AUTH_ENABLED=true`
- All endpoints require a valid JWT token
- Include token in `Authorization: Bearer <token>` header
- Register/login to get a token

## Request/Response Format

All requests and responses use JSON format.

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message"
}
```

## Todo Schema

```json
{
  "id": 1,
  "title": "Task title",
  "description": "Optional description",
  "priority": "medium",
  "isCompleted": false,
  "scheduledTime": "2024-01-15T10:00:00.000Z",
  "completedAt": null,
  "createdAt": "2024-01-10T08:00:00.000Z",
  "updatedAt": "2024-01-10T08:00:00.000Z"
}
```

## Rate Limiting

- General API: 100 requests per 15 minutes
- Auth endpoints: 10 requests per 15 minutes

## Security Features

- Helmet.js for security headers
- CORS configuration
- Input validation with express-validator
- bcrypt password hashing
- JWT token authentication
- Rate limiting
- SSL support for TiDB Cloud

## Development

### Project Structure
```
backend/
├── src/
│   ├── config/        # Database configuration
│   ├── controllers/   # Request handlers
│   ├── middleware/    # Express middleware
│   ├── models/        # Database models
│   ├── routes/        # API routes
│   ├── services/      # Business logic
│   └── server.js      # Express app setup
├── .env.example       # Environment template
└── package.json
```

## TiDB Cloud Setup

1. Sign up at [tidbcloud.com](https://tidbcloud.com)
2. Create a new cluster (Serverless tier is free)
3. Get connection details from the cluster dashboard
4. Update `.env` with your TiDB Cloud credentials
5. Set `DB_SSL=true` to enable SSL connections

## License

MIT