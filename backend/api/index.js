const { sequelize, testConnection, syncDatabase } = require('../src/config/database');
const routes = require('../src/routes');
const { notFound, errorHandler } = require('../src/middleware/errorHandler');
const { apiLimiter } = require('../src/middleware/rateLimiter');

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');

const app = express();

// Security middleware
app.use(helmet());

// CORS configuration
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Guest-ID'],
  credentials: true,
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Compression middleware
app.use(compression());

// Rate limiting
app.use('/api', apiLimiter);

// API routes
app.use('/api', routes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Todo App API',
    version: '1.0.0',
    endpoints: {
      health: '/api/health',
      todos: '/api/todos',
      auth: '/api/auth',
      history: '/api/history',
    },
    authEnabled: process.env.AUTH_ENABLED === 'true',
  });
});

// 404 handler
app.use(notFound);

// Global error handler
app.use(errorHandler);

// Vercel serverless function handler
module.exports = async (req, res) => {
  try {
    // Initialize database connection if needed
    await testConnection();
    await syncDatabase();
    
    // Handle the request
    app(req, res);
  } catch (error) {
    console.error('Vercel function error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
};