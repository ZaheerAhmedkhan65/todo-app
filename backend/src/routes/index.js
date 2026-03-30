const express = require('express');
const router = express.Router();

// Import route modules
const todoRoutes = require('./todoRoutes');
const authRoutes = require('./authRoutes');
const historyRoutes = require('./historyRoutes');

// Mount routes
router.use('/todos', todoRoutes);
router.use('/auth', authRoutes);
router.use('/history', historyRoutes);

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'API is running',
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;