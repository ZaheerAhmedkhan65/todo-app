const { sequelize } = require('../config/database');

// Import models
const User = require('./User');
const Todo = require('./Todo');
const DeletedTodo = require('./DeletedTodo');

// Set up associations
Todo.associate({ User });

// Export all models
module.exports = {
  sequelize,
  User,
  Todo,
  DeletedTodo,
};