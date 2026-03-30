const { DeletedTodo } = require('../models');

// Get all deleted todos for authenticated user or guest
const getDeletedTodos = async (req, res) => {
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
    if (filter === 'completed') {
      where.wasCompleted = true;
    } else if (filter === 'pending') {
      where.wasCompleted = false;
    }

    const deletedTodos = await DeletedTodo.findAll({
      where,
      order: [['deletedAt', 'DESC']],
    });

    res.json({
      success: true,
      data: deletedTodos,
      count: deletedTodos.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching deleted todos',
      error: error.message,
    });
  }
};

// Clear all deleted todos for authenticated user or guest
const clearDeletedTodos = async (req, res) => {
  try {
    const { user, guestId } = req;

    const where = {};
    if (user) {
      where.userId = user.id;
    } else if (guestId) {
      where.guestId = guestId;
    }

    const deleted = await DeletedTodo.destroy({ where });

    res.json({
      success: true,
      message: `Successfully cleared ${deleted} deleted todos`,
      deletedCount: deleted,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error clearing deleted todos',
      error: error.message,
    });
  }
};

module.exports = {
  getDeletedTodos,
  clearDeletedTodos,
};