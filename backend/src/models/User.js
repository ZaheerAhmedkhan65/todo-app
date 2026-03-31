const bcrypt = require('bcryptjs');
const { db } = require('../config/database');

class User {
    // Create new user
    static async create({ username, email, password }) {
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await db.query(
            'INSERT INTO users (username, email, password) VALUES (?, ?, ?)',
            [username, email, hashedPassword]
        );
        return { id: result.insertId, username, email };
    }

    // Find user by email
    static async findByEmail(email) {
        const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        return rows[0] || null;
    }

    // Find user by ID
    static async findById(id) {
        const [rows] = await db.query('SELECT * FROM users WHERE id = ?', [id]);
        return rows[0] || null;
    }

    // Update user
    static async update(id, { username, email }) {
        const fields = [];
        const values = [];
        
        if (username) {
            fields.push('username = ?');
            values.push(username);
        }
        if (email) {
            fields.push('email = ?');
            values.push(email);
        }
        
        if (fields.length === 0) return null;
        
        values.push(id);
        await db.query(
            `UPDATE users SET ${fields.join(', ')} WHERE id = ?`,
            values
        );
        return this.findById(id);
    }

    // Compare password
    async comparePassword(password) {
        return bcrypt.compare(password, this.password);
    }
}

module.exports = User;