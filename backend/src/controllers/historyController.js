const { DeletedTodo } = require('../models');

// Get all deleted todos for authenticated user or guest
const getDeletedTodos = async (req, res) => {
    try {
        const { filter } = req.query;
        const { user, guestId } = req;

        const deletedTodos = await DeletedTodo.findAll({
            userId: user?.id || null,
            guestId: guestId || null,
            filter
        });

        res.json({
            success: true,
            data: deletedTodos,
            count: deletedTodos.length
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching deleted todos',
            error: error.message
        });
    }
};

// Clear all deleted todos for authenticated user or guest
const clearDeletedTodos = async (req, res) => {
    try {
        const { user, guestId } = req;

        const deletedCount = await DeletedTodo.clear({
            userId: user?.id || null,
            guestId: guestId || null
        });

        res.json({
            success: true,
            message: `Successfully cleared ${deletedCount} deleted todos`,
            deletedCount
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error clearing deleted todos',
            error: error.message
        });
    }
};

module.exports = {
    getDeletedTodos,
    clearDeletedTodos
};