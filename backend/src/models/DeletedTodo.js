const { db } = require('../config/database');

class DeletedTodo {
    // Get all deleted todos for a user or guest
    static async findAll({ userId, guestId, filter } = {}) {
        let query = 'SELECT * FROM deleted_todos WHERE 1=1';
        const params = [];

        if (userId) {
            query += ' AND userId = ?';
            params.push(userId);
        } else if (guestId) {
            query += ' AND guestId = ?';
            params.push(guestId);
        }

        if (filter === 'completed') {
            query += ' AND wasCompleted = true';
        } else if (filter === 'pending') {
            query += ' AND wasCompleted = false';
        }

        query += ' ORDER BY deletedAt DESC';

        const [rows] = await db.query(query, params);
        return rows;
    }

    // Create deleted todo record
    static async create({ originalId, userId, guestId, title, description, priority, wasCompleted, scheduledTime }) {
        const [result] = await db.query(
            'INSERT INTO deleted_todos (originalId, userId, guestId, title, description, priority, wasCompleted, scheduledTime) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [originalId, userId || null, guestId || null, title, description || null, priority || 'medium', wasCompleted || false, scheduledTime || null]
        );
        return { id: result.insertId, originalId, userId, guestId, title, description, priority, wasCompleted, scheduledTime };
    }

    // Clear all deleted todos for a user or guest
    static async clear({ userId, guestId } = {}) {
        let query = 'DELETE FROM deleted_todos WHERE 1=1';
        const params = [];

        if (userId) {
            query += ' AND userId = ?';
            params.push(userId);
        } else if (guestId) {
            query += ' AND guestId = ?';
            params.push(guestId);
        }

        const [result] = await db.query(query, params);
        return result.affectedRows;
    }
}

module.exports = DeletedTodo;