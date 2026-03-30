const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Todo = sequelize.define('Todo', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: true, // Null for guest users
    references: {
      model: 'users',
      key: 'id',
    },
  },
  guestId: {
    type: DataTypes.STRING(100),
    allowNull: true, // For guest users
  },
  title: {
    type: DataTypes.STRING(255),
    allowNull: false,
    validate: {
      notEmpty: true,
      len: [1, 255],
    },
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  priority: {
    type: DataTypes.ENUM('low', 'medium', 'high'),
    defaultValue: 'medium',
  },
  isCompleted: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  scheduledTime: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  completedAt: {
    type: DataTypes.DATE,
    allowNull: true,
  },
}, {
  tableName: 'todos',
  timestamps: true,
  indexes: [
    { fields: ['userId'] },
    { fields: ['guestId'] },
    { fields: ['isCompleted'] },
    { fields: ['scheduledTime'] },
  ],
});

// Associate with User model
Todo.associate = (models) => {
  Todo.belongsTo(models.User, {
    foreignKey: 'userId',
    as: 'user',
  });
};

// Find by user or guest
Todo.findByUserOrGuest = async function(userId, guestId) {
  const where = {};
  if (userId) {
    where.userId = userId;
  } else if (guestId) {
    where.guestId = guestId;
  }
  return this.findAll({ where, order: [['createdAt', 'DESC']] });
};

// Find active todos
Todo.findActive = async function(userId, guestId) {
  const where = {};
  if (userId) where.userId = userId;
  else if (guestId) where.guestId = guestId;
  where.isCompleted = false;
  return this.findAll({ where, order: [['scheduledTime', 'ASC']] });
};

module.exports = Todo;