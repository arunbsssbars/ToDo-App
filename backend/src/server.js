require('dotenv').config();
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const todoRoutes = require('./routes/todoRoutes');
require('./config/db'); // ensure DB init

const app = express();
const PORT = process.env.PORT || 3000;

// Enable Cross-Origin Resource Sharing (CORS) for Flutter Web, Desktop, Emulator, and Mobile
app.use(cors());

// Parse incoming JSON payloads
app.use(express.json());

// Request logger for clear educational tracking
app.use((req, res, next) => {
  console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Health check route
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Todo App API Server is healthy and running! 🚀',
    timestamp: new Date().toISOString(),
  });
});

// Mount modular API routes
app.use('/api/auth', authRoutes);
app.use('/api/todos', todoRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `API Route ${req.method} ${req.originalUrl} not found`,
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('💥 Server Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: err.message,
  });
});

// Start Express server on 0.0.0.0 to accept connections from emulators and LAN devices
app.listen(PORT, '0.0.0.0', () => {
  console.log(`=======================================================`);
  console.log(` Todo App Backend API Server running on port ${PORT}`);
  console.log(`- Localhost:         http://localhost:${PORT}`);
  console.log(`- Android Emulator:  http://10.0.2.2:${PORT}`);
  console.log(`- Healthcheck:       http://localhost:${PORT}/api/health`);
  console.log(`=======================================================`);
});
