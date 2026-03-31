const mysql = require("mysql2/promise");
require("dotenv").config();

let db = null;

if (process.env.NODE_ENV === "production") {
    db = mysql.createPool({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        port: process.env.DB_PORT,
        ssl: {
            waitForConnections: true,
            connectionLimit: 10,
            queueLimit: 0,
            rejectUnauthorized: true
        }
    });
} else {
    db = mysql.createPool({
        host: process.env.DB_HOST || "localhost",
        user: process.env.DB_USER || "root",
        password: process.env.DB_PASSWORD || "",
        database: process.env.DB_NAME || "todo_app",
        port: process.env.DB_PORT || 3306,
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0
    });
}

// Test database connection
const testConnection = async () => {
    try {
        const connection = await db.getConnection();
        console.log("✅ Database connection established successfully.");
        connection.release();
    } catch (error) {
        console.error("❌ Unable to connect to the database:", error);
        process.exit(1);
    }
};

// Initialize database tables
const initDatabase = async () => {
    try {
        // Create users table
        await db.query(`
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                username VARCHAR(50) NOT NULL,
                email VARCHAR(100) NOT NULL UNIQUE,
                password VARCHAR(255) NOT NULL,
                isActive BOOLEAN DEFAULT true,
                lastLogin DATETIME,
                createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
                updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        `);

        // Create todos table
        await db.query(`
            CREATE TABLE IF NOT EXISTS todos (
                id INT AUTO_INCREMENT PRIMARY KEY,
                userId INT,
                guestId VARCHAR(100),
                title VARCHAR(255) NOT NULL,
                description TEXT,
                priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
                isCompleted BOOLEAN DEFAULT false,
                scheduledTime DATETIME,
                completedAt DATETIME,
                createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
                updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (userId) REFERENCES users(id) ON DELETE SET NULL
            )
        `);

        // Create deleted_todos table
        await db.query(`
            CREATE TABLE IF NOT EXISTS deleted_todos (
                id INT AUTO_INCREMENT PRIMARY KEY,
                originalId INT,
                userId INT,
                guestId VARCHAR(100),
                title VARCHAR(255) NOT NULL,
                description TEXT,
                priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
                wasCompleted BOOLEAN DEFAULT false,
                scheduledTime DATETIME,
                deletedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (userId) REFERENCES users(id) ON DELETE SET NULL
            )
        `);

        console.log("✅ Database tables initialized successfully.");
    } catch (error) {
        console.error("❌ Database initialization failed:", error);
        process.exit(1);
    }
};

module.exports = { db, testConnection, initDatabase };