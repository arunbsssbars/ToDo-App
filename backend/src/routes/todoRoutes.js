const express = require('express');
const router = express.Router();
const {
  getTodos,
  getTodoById,
  createTodo,
  updateTodo,
  toggleTodoStatus,
  deleteTodo,
} = require('../controllers/todoController');
const { authenticateToken } = require('../middleware/authMiddleware');

// All todo endpoints require valid JWT authentication
router.use(authenticateToken);

router.get('/', getTodos);
router.post('/', createTodo);
router.get('/:id', getTodoById);
router.put('/:id', updateTodo);
router.patch('/:id/toggle', toggleTodoStatus);
router.delete('/:id', deleteTodo);

module.exports = router;
