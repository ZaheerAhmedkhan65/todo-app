const { optionalAuth, requireAuth, generateToken } = require('./auth');
const { apiLimiter, authLimiter, createRateLimiter } = require('./rateLimiter');
const { ApiError, notFound, errorHandler } = require('./errorHandler');

module.exports = {
  // Auth middleware
  optionalAuth,
  requireAuth,
  generateToken,
  
  // Rate limiting
  apiLimiter,
  authLimiter,
  createRateLimiter,
  
  // Error handling
  ApiError,
  notFound,
  errorHandler,
};