const { db } = require('../config/database');

class Todo {
    // Get all todos for a user or guest
    static async findAll({ userId, guestId, filter } = {}) {
        let query = 'SELECT * FROM todos WHERE 1=1';
        const params = [];

        if (userId) {
            query += ' AND userId = ?';
            params.push(userId);
        } else if (guestId) {
            query += ' AND guestId = ?';
            params.push(guestId);
        }

        if (filter === 'pending') {
            query += ' AND isCompleted = false';
        } else if (filter === 'completed') {
            query += ' AND isCompleted = true';
        }

        query += ' ORDER BY createdAt DESC';

        const [rows] = await db.query(query, params);
        return rows;
    }

    // Find todo by ID
    static async findById(id, { userId, guestId } = {}) {
        let query = 'SELECT * FROM todos WHERE id = ?';
        const params = [id];

        if (userId) {
            query += ' AND userId = ?';
            params.push(userId);
        } else if (guestId) {
            query += ' AND guestId = ?';
            params.push(guestId);
        }

        const [rows] = await db.query(query, params);
        return rows[0] || null;
    }

    // Create new todo
    static async create({ title, description, priority, scheduledTime, userId, guestId }) {
        const now = new Date();
        const [result] = await db.query(
            'INSERT INTO todos (title, description, priority, scheduledTime, userId, guestId, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [title, description || null, priority || 'medium', scheduledTime || null, userId || null, guestId || null, now, now]
        );
        return this.findById(result.insertId, { userId, guestId });
    }

    // Update todo
    static async update(id, { title, description, priority, scheduledTime, isCompleted }, { userId, guestId } = {}) {
        const fields = [];
        const values = [];

        if (title !== undefined) {
            fields.push('title = ?');
            values.push(title);
        }
        if (description !== undefined) {
            fields.push('description = ?');
            values.push(description);
        }
        if (priority !== undefined) {
            fields.push('priority = ?');
            values.push(priority);
        }
        if (scheduledTime !== undefined) {
            fields.push('scheduledTime = ?');
            values.push(scheduledTime);
        }
        if (isCompleted !== undefined) {
            fields.push('isCompleted = ?', 'completedAt = ?');
            values.push(isCompleted, isCompleted ? new Date() : null);
        }

        if (fields.length === 0) return null;

        values.push(id);
        if (userId) {
            values.push(userId);
            await db.query(`UPDATE todos SET ${fields.join(', ')} WHERE id = ? AND userId = ?`, values);
        } else if (guestId) {
            values.push(guestId);
            await db.query(`UPDATE todos SET ${fields.join(', ')} WHERE id = ? AND guestId = ?`, values);
        } else {
            await db.query(`UPDATE todos SET ${fields.join(', ')} WHERE id = ?`, values.slice(0, -1));
        }

        return this.findById(id, { userId, guestId });
    }

    // Toggle todo completion
    static async toggle(id, { userId, guestId } = {}) {
        const todo = await this.findById(id, { userId, guestId });
        if (!todo) return null;

        const newStatus = !todo.isCompleted;
        await db.query(
            'UPDATE todos SET isCompleted = ?, completedAt = ? WHERE id = ?',
            [newStatus, newStatus ? new Date() : null, id]
        );

        return this.findById(id, { userId, guestId });
    }

    // Delete todo
    static async delete(id, { userId, guestId } = {}) {
        const todo = await this.findById(id, { userId, guestId });
        if (!todo) return null;

        let query = 'DELETE FROM todos WHERE id = ?';
        const params = [id];

        if (userId) {
            query += ' AND userId = ?';
            params.push(userId);
        } else if (guestId) {
            query += ' AND guestId = ?';
            params.push(guestId);
        }

        await db.query(query, params);
        return todo;
    }
}

module.exports = Todo;