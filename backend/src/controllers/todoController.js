const crypto = require('crypto');
const db = require('../config/db');

const uuidv4 = () => {
  if (crypto.randomUUID) return crypto.randomUUID();
  return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
};

/**
 * Get all todos for the logged-in user
 * GET /api/todos
 * Query params: ?category=Work&priority=High&is_completed=true&search=groceries
 */
const getTodos = (req, res) => {
  const userId = req.userId; // Provided by authMiddleware
  const { category, priority, is_completed, search } = req.query;

  let query = 'SELECT * FROM todos WHERE user_id = ?';
  const params = [userId];

  if (category && category !== 'All') {
    query += ' AND category = ?';
    params.push(category);
  }

  if (priority && priority !== 'All') {
    query += ' AND priority = ?';
    params.push(priority);
  }

  if (is_completed !== undefined) {
    query += ' AND is_completed = ?';
    params.push(is_completed === 'true' || is_completed === '1' ? 1 : 0);
  }

  if (search && search.trim() !== '') {
    query += ' AND (title LIKE ? OR description LIKE ?)';
    params.push(`%${search.trim()}%`, `%${search.trim()}%`);
  }

  query += ' ORDER BY is_completed ASC, created_at DESC';

  db.all(query, params, (err, rows) => {
    if (err) {
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }

    // Convert integer boolean SQLite field to true/false for clean API serialization
    const formattedTodos = rows.map((todo) => ({
      ...todo,
      is_completed: Boolean(todo.is_completed),
    }));

    return res.status(200).json({
      success: true,
      count: formattedTodos.length,
      data: formattedTodos,
    });
  });
};

/**
 * Get a single todo by ID
 * GET /api/todos/:id
 */
const getTodoById = (req, res) => {
  const userId = req.userId;
  const { id } = req.params;

  db.get('SELECT * FROM todos WHERE id = ? AND user_id = ?', [id, userId], (err, row) => {
    if (err) {
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }

    if (!row) {
      return res.status(404).json({ success: false, message: 'Todo not found or unauthorized' });
    }

    return res.status(200).json({
      success: true,
      data: {
        ...row,
        is_completed: Boolean(row.is_completed),
      },
    });
  });
};

/**
 * Create a new todo
 * POST /api/todos
 * Body: { title, description, category, priority, due_date }
 */
const createTodo = (req, res) => {
  const userId = req.userId;
  const { title, description, category, priority, due_date } = req.body;

  if (!title || title.trim() === '') {
    return res.status(400).json({ success: false, message: 'Todo title is required' });
  }

  const todoId = uuidv4();
  const todoCategory = category || 'Personal';
  const todoPriority = priority || 'Medium';
  const todoDesc = description || '';
  const todoDueDate = due_date || null;
  const isCompleted = 0;
  const now = new Date().toISOString();

  db.run(
    `INSERT INTO todos (id, user_id, title, description, category, priority, is_completed, due_date, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [todoId, userId, title.trim(), todoDesc.trim(), todoCategory, todoPriority, isCompleted, todoDueDate, now, now],
    function (err) {
      if (err) {
        return res.status(500).json({ success: false, message: 'Failed to create todo', error: err.message });
      }

      return res.status(201).json({
        success: true,
        message: 'Todo created successfully',
        data: {
          id: todoId,
          user_id: userId,
          title: title.trim(),
          description: todoDesc.trim(),
          category: todoCategory,
          priority: todoPriority,
          is_completed: false,
          due_date: todoDueDate,
          created_at: now,
          updated_at: now,
        },
      });
    }
  );
};

/**
 * Update an existing todo
 * PUT /api/todos/:id
 * Body: { title, description, category, priority, is_completed, due_date }
 */
const updateTodo = (req, res) => {
  const userId = req.userId;
  const { id } = req.params;
  const { title, description, category, priority, is_completed, due_date } = req.body;

  // First verify the todo exists and belongs to this user
  db.get('SELECT * FROM todos WHERE id = ? AND user_id = ?', [id, userId], (err, existing) => {
    if (err) {
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }

    if (!existing) {
      return res.status(404).json({ success: false, message: 'Todo not found or unauthorized' });
    }

    const updatedTitle = title !== undefined ? title.trim() : existing.title;
    const updatedDesc = description !== undefined ? description.trim() : existing.description;
    const updatedCategory = category !== undefined ? category : existing.category;
    const updatedPriority = priority !== undefined ? priority : existing.priority;
    const updatedCompleted = is_completed !== undefined ? (is_completed ? 1 : 0) : existing.is_completed;
    const updatedDueDate = due_date !== undefined ? due_date : existing.due_date;
    const now = new Date().toISOString();

    db.run(
      `UPDATE todos 
       SET title = ?, description = ?, category = ?, priority = ?, is_completed = ?, due_date = ?, updated_at = ?
       WHERE id = ? AND user_id = ?`,
      [updatedTitle, updatedDesc, updatedCategory, updatedPriority, updatedCompleted, updatedDueDate, now, id, userId],
      function (updateErr) {
        if (updateErr) {
          return res.status(500).json({ success: false, message: 'Failed to update todo', error: updateErr.message });
        }

        return res.status(200).json({
          success: true,
          message: 'Todo updated successfully',
          data: {
            id,
            user_id: userId,
            title: updatedTitle,
            description: updatedDesc,
            category: updatedCategory,
            priority: updatedPriority,
            is_completed: Boolean(updatedCompleted),
            due_date: updatedDueDate,
            created_at: existing.created_at,
            updated_at: now,
          },
        });
      }
    );
  });
};

/**
 * Toggle todo completion status
 * PATCH /api/todos/:id/toggle
 */
const toggleTodoStatus = (req, res) => {
  const userId = req.userId;
  const { id } = req.params;

  db.get('SELECT is_completed FROM todos WHERE id = ? AND user_id = ?', [id, userId], (err, existing) => {
    if (err) {
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }

    if (!existing) {
      return res.status(404).json({ success: false, message: 'Todo not found or unauthorized' });
    }

    const newStatus = existing.is_completed === 1 ? 0 : 1;
    const now = new Date().toISOString();

    db.run(
      'UPDATE todos SET is_completed = ?, updated_at = ? WHERE id = ? AND user_id = ?',
      [newStatus, now, id, userId],
      function (updateErr) {
        if (updateErr) {
          return res.status(500).json({ success: false, message: 'Failed to toggle todo', error: updateErr.message });
        }

        return res.status(200).json({
          success: true,
          message: `Todo marked as ${newStatus === 1 ? 'completed' : 'pending'}`,
          data: {
            id,
            is_completed: Boolean(newStatus),
            updated_at: now,
          },
        });
      }
    );
  });
};

/**
 * Delete a todo
 * DELETE /api/todos/:id
 */
const deleteTodo = (req, res) => {
  const userId = req.userId;
  const { id } = req.params;

  db.run('DELETE FROM todos WHERE id = ? AND user_id = ?', [id, userId], function (err) {
    if (err) {
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }

    if (this.changes === 0) {
      return res.status(404).json({ success: false, message: 'Todo not found or unauthorized' });
    }

    return res.status(200).json({
      success: true,
      message: 'Todo deleted successfully',
      data: { id },
    });
  });
};

module.exports = {
  getTodos,
  getTodoById,
  createTodo,
  updateTodo,
  toggleTodoStatus,
  deleteTodo,
};
