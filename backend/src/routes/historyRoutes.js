const express = require('express');
const router = express.Router();
const historyController = require('../controllers/historyController');
const { optionalAuth } = require('../middleware/auth');

// All routes use optional authentication middleware
router.use(optionalAuth);

// GET /api/history - Get all deleted todos with optional filter
router.get('/', historyController.getDeletedTodos);

// DELETE /api/history - Clear all deleted todos
router.delete('/', historyController.clearDeletedTodos);

module.exports = router;