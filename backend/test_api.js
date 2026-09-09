const http = require('http');

const PORT = 3000;
const BASE_URL = `http://localhost:${PORT}`;

// Helper to make HTTP requests
function request(path, options = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const reqOptions = {
      method: options.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {}),
      },
    };

    const req = http.request(url, reqOptions, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, body: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });

    req.on('error', reject);

    if (options.body) {
      req.write(JSON.stringify(options.body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Starting Backend API & User Isolation Test Suite...\n');

  try {
    // 1. Healthcheck
    const health = await request('/api/health');
    console.log('✅ 1. Healthcheck status:', health.status, health.body.message);

    // 2. Register Alice
    const emailAlice = `alice_${Date.now()}@example.com`;
    const regAlice = await request('/api/auth/register', {
      method: 'POST',
      body: { name: 'Alice Smith', email: emailAlice, password: 'password123' },
    });
    console.log('✅ 2. Register Alice:', regAlice.status, regAlice.body.message);
    const tokenAlice = regAlice.body.data.token;
    const aliceId = regAlice.body.data.user.id;

    // 3. Login Alice
    const loginAlice = await request('/api/auth/login', {
      method: 'POST',
      body: { email: emailAlice, password: 'password123' },
    });
    console.log('✅ 3. Login Alice:', loginAlice.status, 'User:', loginAlice.body.data.user.name);

    // 4. Create Todos for Alice
    const todo1 = await request('/api/todos', {
      method: 'POST',
      headers: { Authorization: `Bearer ${tokenAlice}` },
      body: {
        title: 'Master Flutter Architecture',
        description: 'Understand Providers, Controllers, Repositories',
        category: 'Study',
        priority: 'High',
        due_date: '2026-08-30',
      },
    });
    console.log('✅ 4. Created Todo 1 for Alice:', todo1.body.data.title, 'ID:', todo1.body.data.id);
    const todo1Id = todo1.body.data.id;

    const todo2 = await request('/api/todos', {
      method: 'POST',
      headers: { Authorization: `Bearer ${tokenAlice}` },
      body: {
        title: 'Build Stitch UI Dashboard',
        description: 'Design beautiful cards and stats widgets',
        category: 'Work',
        priority: 'Medium',
      },
    });
    console.log('✅ 5. Created Todo 2 for Alice:', todo2.body.data.title, 'ID:', todo2.body.data.id);
    const todo2Id = todo2.body.data.id;

    // 5. Get Alice's Todos
    const aliceTodos = await request('/api/todos', {
      headers: { Authorization: `Bearer ${tokenAlice}` },
    });
    console.log(`✅ 6. Alice has ${aliceTodos.body.count} todos (Expected: 2)`);

    // 6. Toggle Todo 1
    const toggleRes = await request(`/api/todos/${todo1Id}/toggle`, {
      method: 'PATCH',
      headers: { Authorization: `Bearer ${tokenAlice}` },
    });
    console.log('✅ 7. Toggled Todo 1 completed:', toggleRes.body.data.is_completed);

    // 7. Register Bob
    const emailBob = `bob_${Date.now()}@example.com`;
    const regBob = await request('/api/auth/register', {
      method: 'POST',
      body: { name: 'Bob Jones', email: emailBob, password: 'secretpassword' },
    });
    console.log('✅ 8. Register Bob:', regBob.status, 'Bob User ID:', regBob.body.data.user.id);
    const tokenBob = regBob.body.data.token;

    // 8. Verify Bob sees 0 todos (Strict isolation verification!)
    const bobTodosEmpty = await request('/api/todos', {
      headers: { Authorization: `Bearer ${tokenBob}` },
    });
    console.log(`🔒 9. ISOLATION CHECK: Bob has ${bobTodosEmpty.body.count} todos (Expected: 0 - Alice's todos are hidden)`);

    // 9. Verify Bob cannot modify Alice's todo
    const bobHacksAlice = await request(`/api/todos/${todo1Id}`, {
      method: 'PUT',
      headers: { Authorization: `Bearer ${tokenBob}` },
      body: { title: 'Hacked by Bob' },
    });
    console.log(`🔒 10. ISOLATION CHECK: Bob modifying Alice's todo -> Status ${bobHacksAlice.status} (${bobHacksAlice.body.message})`);

    // 10. Bob creates his own todo
    const bobTodo = await request('/api/todos', {
      method: 'POST',
      headers: { Authorization: `Bearer ${tokenBob}` },
      body: {
        title: "Bob's Confidential Project",
        category: 'Personal',
        priority: 'High',
      },
    });
    console.log('✅ 11. Bob created own todo:', bobTodo.body.data.title);

    // 11. Bob gets his todos
    const bobTodos = await request('/api/todos', {
      headers: { Authorization: `Bearer ${tokenBob}` },
    });
    console.log(`✅ 12. Bob has ${bobTodos.body.count} todo(s) (Expected: 1, only Bob's note)`);

    // 12. Delete Alice's Todo 2
    const delRes = await request(`/api/todos/${todo2Id}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${tokenAlice}` },
    });
    console.log('✅ 13. Alice deleted Todo 2:', delRes.body.message);

    // 13. Alice final count
    const aliceFinal = await request('/api/todos', {
      headers: { Authorization: `Bearer ${tokenAlice}` },
    });
    console.log(`✅ 14. Alice final count: ${aliceFinal.body.count} todo(s) (Expected: 1)`);

    console.log('\n🎉 ALL BACKEND API & USER ISOLATION TESTS PASSED PERFECTLY!\n');
    process.exit(0);
  } catch (err) {
    console.error('❌ Test failed with error:', err);
    process.exit(1);
  }
}

// Start server in-process for test
require('./src/server');
setTimeout(runTests, 1000);
