const { Todo, DeletedTodo } = require('../models');

// Get all todos for authenticated user or guest
const getAllTodos = async (req, res) => {
  try {
    const { filter } = req.query;
    const { user, guestId } = req;

    const where = {};
    if (user) {
      where.userId = user.id;
    } else if (guestId) {
      where.guestId = guestId;
    }

    // Apply filter
    if (filter === 'pending') {
      where.isCompleted = false;
    } else if (filter === 'completed') {
      where.isCompleted = true;
    }

    const todos = await Todo.findAll({
      where,
      order: [['createdAt', 'DESC']],
    });

    res.json({
      success: true,
      data: todos,
      count: todos.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching todos',
      error: error.message,
    });
  }
};

// Get single todo by ID
const getTodoById = async (req, res) => {
  try {
    const { id } = req.params;
    const { user, guestId } = req;

    const where = { id };
    if (user) {
      where.userId = user.id;
    } else if (guestId) {
      where.guestId = guestId;
    }

    const todo = await Todo.findOne({ where });

    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Todo not found',
      });
    }

    res.json({
      success: true,
      data: todo,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching todo',
      error: error.message,
    });
  }
};

// Create new todo
const createTodo = async (req, res) => {
  try {
    const { title, description, priority, scheduledTime } = req.body;
    const { user, guestId } = req;

    if (!title || title.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Title is required',
      });
    }

    const todo = await Todo.create({
      title: title.trim(),
      description: description?.trim() || null,
      priority: priority || 'medium',
      scheduledTime: scheduledTime || null,
      userId: user?.id || null,
      guestId: guestId || null,
    });

    res.status(201).json({
      success: true,
      message: 'Todo created successfully',
      data: todo,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error creating todo',
      error: error.message,
    });
  }
};

// Update todo
const updateTodo = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, priority, scheduledTime, isCompleted } = req.body;
    const { user, guestId } = req;

    const where = { id };
    if (user) {
      where.userId = user.id;
    } else if (guestId) {
      where.guestId = guestId;
    }

    const todo = await Todo.findOne({ where });

    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Todo not found',
      });
    }

    // Update fields
    if (title !== undefined) todo.title = title.trim();
    if (description !== undefined) todo.description = description?.trim() || null;
    if (priority !== undefined) todo.priority = priority;
    if (scheduledTime !== undefined) todo.scheduledTime = scheduledTime;
    if (isCompleted !== undefined) {
      todo.isCompleted = isCompleted;
      todo.completedAt = isCompleted ? new Date() : null;
    }

    await todo.save();

    res.json({
      success: true,
      message: 'Todo updated successfully',
      data: todo,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error updating todo',
      error: error.message,
    });
  }
};

// Delete todo and save to history
const deleteTodo = async (req, res) => {
  try {
    const { id } = req.params;
    const { user, guestId } = req;

    const where = { id };
    if (user) {
      where.userId = user.id;
    } else if (guestId) {
      where.guestId = guestId;
    }

    const todo = await Todo.findOne({ where });
    console.log('Deleting todo:', todo);
    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Todo not found',
      });
    }

    // Save to deleted todos history
    const deletedTodo = await DeletedTodo.create({
      originalId: todo.id,
      userId: user?.id || null,
      guestId: guestId || null,
      title: todo.title,
      description: todo.description,
      priority: todo.priority,
      wasCompleted: todo.isCompleted,
      scheduledTime: todo.scheduledTime,
      deletedAt: new Date(),
    });
    console.log('Saved to deleted todos:', deletedTodo);
    // Delete the todo
    await todo.destroy();
    console.log('Todo deleted successfully');
    res.json({
      success: true,
      message: 'Todo deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting todo',
      error: error.message,
    });
  }
};

// Toggle todo completion
const toggleTodoCompletion = async (req, res) => {
  try {
    const { id } = req.params;
    const { user, guestId } = req;

    const where = { id };
    if (user) {
      where.userId = user.id;
    } else if (guestId) {
      where.guestId = guestId;
    }

    const todo = await Todo.findOne({ where });

    if (!todo) {
      return res.status(404).json({
        success: false,
        message: 'Todo not found',
      });
    }

    todo.isCompleted = !todo.isCompleted;
    todo.completedAt = todo.isCompleted ? new Date() : null;
    await todo.save();

    res.json({
      success: true,
      message: `Todo marked as ${todo.isCompleted ? 'completed' : 'pending'}`,
      data: todo,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error toggling todo completion',
      error: error.message,
    });
  }
};

module.exports = {
  getAllTodos,
  getTodoById,
  createTodo,
  updateTodo,
  deleteTodo,
  toggleTodoCompletion,
};