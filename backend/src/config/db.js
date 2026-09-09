const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Store SQLite database file in the backend root directory
const dbPath = path.resolve(__dirname, '../../database.sqlite');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('❌ Failed to connect to SQLite database:', err.message);
  } else {
    console.log(' Connected to SQLite database at:', dbPath);
  }
});

// Initialize database schema tables: users & todos
db.serialize(() => {
  // Enable foreign key constraints
  db.run('PRAGMA foreign_keys = ON;');

  // Users Table
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Todos Table - strictly isolated by user_id
  db.run(`
    CREATE TABLE IF NOT EXISTS todos (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT DEFAULT '',
      category TEXT DEFAULT 'Personal',
      priority TEXT DEFAULT 'Medium',
      is_completed INTEGER DEFAULT 0,
      due_date TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
  `);

  // Index for fast query filtering by user_id
  db.run(`
    CREATE INDEX IF NOT EXISTS idx_todos_user_id ON todos (user_id);
  `);
});

module.exports = db;
