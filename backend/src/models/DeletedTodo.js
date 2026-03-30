const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const DeletedTodo = sequelize.define('DeletedTodo', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  originalId: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  guestId: {
    type: DataTypes.STRING(100),
    allowNull: true,
  },
  title: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  priority: {
    type: DataTypes.ENUM('low', 'medium', 'high'),
    allowNull: true,
  },
  wasCompleted: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  scheduledTime: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  deletedAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'deleted_todos',
  timestamps: false,
  indexes: [
    { fields: ['userId'] },
    { fields: ['guestId'] },
    { fields: ['deletedAt'] },
  ],
});

// Find by user or guest
DeletedTodo.findByUserOrGuest = async function(userId, guestId) {
  const where = {};
  if (userId) {
    where.userId = userId;
  } else if (guestId) {
    where.guestId = guestId;
  }
  return this.findAll({ where, order: [['deletedAt', 'DESC']] });
};

module.exports = DeletedTodo;