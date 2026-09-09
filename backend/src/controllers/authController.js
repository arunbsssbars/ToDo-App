const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('crypto').randomUUID ? { v4: require('crypto').randomUUID } : { v4: () => Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15) };
const db = require('../config/db');
const { JWT_SECRET } = require('../middleware/authMiddleware');

/**
 * Register a new user
 * POST /api/auth/register
 * Body: { name, email, password }
 */
const register = async (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Please provide name, email, and password',
    });
  }

  // Check if user with this email already exists
  db.get('SELECT * FROM users WHERE email = ?', [email.toLowerCase().trim()], async (err, existingUser) => {
    if (err) {
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'A user with this email already exists',
      });
    }

    try {
      // Hash the password with bcrypt salt
      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(password, salt);
      const userId = uuidv4();

      db.run(
        'INSERT INTO users (id, name, email, password_hash) VALUES (?, ?, ?, ?)',
        [userId, name.trim(), email.toLowerCase().trim(), passwordHash],
        function (insertErr) {
          if (insertErr) {
            return res.status(500).json({ success: false, message: 'Failed to create user', error: insertErr.message });
          }

          // Generate JWT token valid for 7 days
          const token = jwt.sign({ id: userId, email: email.toLowerCase().trim() }, JWT_SECRET, {
            expiresIn: '7d',
          });

          return res.status(201).json({
            success: true,
            message: 'User registered successfully',
            data: {
              user: {
                id: userId,
                name: name.trim(),
                email: email.toLowerCase().trim(),
              },
              token,
            },
          });
        }
      );
    } catch (e) {
      return res.status(500).json({ success: false, message: 'Encryption error', error: e.message });
    }
  });
};

/**
 * Login existing user
 * POST /api/auth/login
 * Body: { email, password }
 */
const login = (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Please provide both email and password',
    });
  }

  db.get('SELECT * FROM users WHERE email = ?', [email.toLowerCase().trim()], async (err, user) => {
    if (err) {
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // Verify password against stored bcrypt hash
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // Issue JWT Token
    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, {
      expiresIn: '7d',
    });

    return res.status(200).json({
      success: true,
      message: 'Logged in successfully',
      data: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
        },
        token,
      },
    });
  });
};

/**
 * Get current authenticated user profile
 * GET /api/auth/me (Protected by authenticateToken)
 */
const getMe = (req, res) => {
  db.get('SELECT id, name, email, created_at FROM users WHERE id = ?', [req.userId], (err, user) => {
    if (err) {
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    return res.status(200).json({
      success: true,
      data: { user },
    });
  });
};

module.exports = {
  register,
  login,
  getMe,
};
