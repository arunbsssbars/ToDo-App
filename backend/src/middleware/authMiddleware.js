const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'todo_flutter_super_secret_jwt_key_2026';

/**
 * Middleware to authenticate requests using JWT Bearer Token.
 * It extracts the token from the "Authorization" header, verifies it,
 * and attaches the decoded userId to `req.userId`.
 */
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Expected format: "Bearer <TOKEN>"

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access token required. Please log in.',
    });
  }

  jwt.verify(token, JWT_SECRET, (err, decodedUser) => {
    if (err) {
      return res.status(403).json({
        success: false,
        message: 'Invalid or expired token. Please log in again.',
      });
    }

    // Attach user payload (id, email) to the request object
    req.user = decodedUser;
    req.userId = decodedUser.id;
    next();
  });
};

module.exports = {
  authenticateToken,
  JWT_SECRET,
};
