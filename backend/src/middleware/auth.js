const jwt = require('jsonwebtoken');
const { User } = require('../models');

// Optional authentication middleware
// If AUTH_ENABLED is false, allows requests without authentication
// If AUTH_ENABLED is true, requires valid JWT token
const optionalAuth = async (req, res, next) => {
  // Check if auth is enabled
  if (process.env.AUTH_ENABLED !== 'true') {
    // Generate a guest ID if not provided
    if (!req.headers['x-guest-id']) {
      req.headers['x-guest-id'] = req.headers['x-guest-id'] || `guest_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
    req.user = null;
    req.guestId = req.headers['x-guest-id'];
    req.isAuthenticated = false;
    return next();
  }

  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required. Please provide a valid token.',
      });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    const user = await User.findByPk(decoded.userId);
    if (!user || !user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired token. Please login again.',
      });
    }

    // Update last login
    user.lastLogin = new Date();
    await user.save();

    req.user = user;
    req.guestId = null;
    req.isAuthenticated = true;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token. Please login again.',
      });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired. Please login again.',
      });
    }
    next(error);
  }
};

// Require authentication (strict)
const requireAuth = (req, res, next) => {
  if (!req.isAuthenticated) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required.',
    });
  }
  next();
};

// Generate JWT token
const generateToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

module.exports = {
  optionalAuth,
  requireAuth,
  generateToken,
};