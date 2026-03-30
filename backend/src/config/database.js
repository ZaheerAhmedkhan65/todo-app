const { Sequelize } = require('sequelize');
require('dotenv').config();

// Determine if we should use SSL based on environment or explicit flag
const useSSL = process.env.DB_SSL === 'true' || 
               (process.env.NODE_ENV === 'production' && process.env.DB_HOST !== 'localhost');

// SSL options for TiDB Cloud and other secure connections
const dialectOptions = useSSL ? {
  ssl: {
    require: true,
    rejectUnauthorized: true,
  }
} : {};

const sequelize = new Sequelize(
    process.env.DB_NAME || 'todo_app',
    process.env.DB_USER || 'root',
    process.env.DB_PASSWORD || '',
    {
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 3306,
        dialect: 'mysql',
        logging: process.env.NODE_ENV === 'development' ? console.log : false,
        dialectOptions,
        pool: {
            max: 10,
            min: 0,
            acquire: 30000,
            idle: 10000,
        },
    }
);

// Test database connection
const testConnection = async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ Database connection established successfully.');
        if (useSSL) {
            console.log('🔒 SSL connection enabled');
        }
    } catch (error) {
        console.error('❌ Unable to connect to the database:', error);
        process.exit(1);
    }
};

// Sync database models
const syncDatabase = async () => {
    try {
        await sequelize.sync({ alter: process.env.NODE_ENV === 'development' });
        console.log('✅ Database synchronized successfully.');
    } catch (error) {
        console.error('❌ Database synchronization failed:', error);
        process.exit(1);
    }
};

module.exports = { sequelize, testConnection, syncDatabase };