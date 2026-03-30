const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { optionalAuth, requireAuth } = require('../middleware/auth');
const { authLimiter } = require('../middleware/rateLimiter');

// POST /api/auth/register - Register new user
router.post('/register', authLimiter, authController.register);

// POST /api/auth/login - Login user
router.post('/login', authLimiter, authController.login);

// GET /api/auth/profile - Get current user profile (requires auth)
router.get('/profile', optionalAuth, requireAuth, authController.getProfile);

// PUT /api/auth/profile - Update current user profile (requires auth)
router.put('/profile', optionalAuth, requireAuth, authController.updateProfile);

module.exports = router;