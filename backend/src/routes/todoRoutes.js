const express = require('express');
const router = express.Router();
const todoController = require('../controllers/todoController');
const { optionalAuth } = require('../middleware/auth');

// All routes use optional authentication middleware
router.use(optionalAuth);

// GET /api/todos - Get all todos with optional filter
router.get('/', todoController.getAllTodos);

// POST /api/todos - Create new todo
router.post('/', todoController.createTodo);

// GET /api/todos/:id - Get single todo by ID
router.get('/:id', todoController.getTodoById);

// PUT /api/todos/:id - Update todo
router.put('/:id', todoController.updateTodo);

// PATCH /api/todos/:id/toggle - Toggle todo completion
router.patch('/:id/toggle', todoController.toggleTodoCompletion);

// DELETE /api/todos/:id - Delete todo (saves to history)
router.delete('/:id', todoController.deleteTodo);

module.exports = router;