const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
 const cors = require('cors');


// Конфигурация подключения к PostgreSQL
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'lapka',
  password: '1234',
  port: 5432,
});

const app = express();
 app.use(cors());
app.use(bodyParser.json());


// Секретный ключ для JWT
const jwtSecret = 'ertyuiokjhgfdrtyuiol;,l51254hbgvbnhygtvhbnjhy5145';

// Регистрация
app.post('/register', async (req, res) => {
  const { email, password } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await pool.query(
      'INSERT INTO users (email, password) VALUES ($1, $2) RETURNING id, email',
      [email, hashedPassword]
    );
    const user = result.rows[0];

    const token = jwt.sign({ userId: user.id }, jwtSecret, { expiresIn: '1h' });
    res.json({ token, user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Ошибка регистрации пользователя' });
  }
});

// Авторизация
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = result.rows[0];

    if (!user) {
      return res.status(400).json({ error: 'Пользователь не найден' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Неверный пароль' });
    }

    const token = jwt.sign({ userId: user.id }, jwtSecret, { expiresIn: '1h' });
    res.json({ token, user: { id: user.id, email: user.email } });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Ошибка авторизации' });
  }
});

// Проверка токена
app.get('/profile', async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Токен отсутствует' });
  }

  try {
    const decoded = jwt.verify(token, jwtSecret);
    const result = await pool.query('SELECT id, email FROM users WHERE id = $1', [decoded.userId]);
    const user = result.rows[0];
    res.json({ user });
  } catch (error) {
    console.error(error);
    res.status(401).json({ error: 'Недействительный токен' });
  }
});

// Получение списка пользователей
app.get('/users', async (req, res) => {
  const result = await pool.query('SELECT * FROM users');
  res.json(result.rows);
});

// Получение категорий
app.get('/categories', async (req, res) => {
  const result = await pool.query('SELECT * FROM categories');
  res.json(result.rows);
});

// Получение продуктов по категории
app.get('/categories/:id/products', async (req, res) => {
  const { id } = req.params;
  const result = await pool.query(
    'SELECT * FROM products WHERE category_id = $1',
    [id]
  );
  res.json(result.rows);
});

// Запуск сервера
const port = 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
