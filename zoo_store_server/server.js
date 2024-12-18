const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Конфигурация подключения к PostgreSQL
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'lapka',
  password: '1234',
  port: 5432,
});

// Секретный ключ для JWT
const jwtSecret = 'ertyuiokjhgfdrtyuioll51254hbgvbnhy5145';

// Маршрут для регистрации нового пользователя
app.post('/register', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Проверка на существование пользователя с таким email
    const existingUser = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'Пользователь с таким email уже существует' });
    }

    // Хэширование пароля
    const hashedPassword = await bcrypt.hash(password, 10);

    // Добавление нового пользователя в базу данных
    const result = await pool.query(
      'INSERT INTO users (email, password) VALUES ($1, $2) RETURNING *',
      [email, hashedPassword]
    );

    const user = result.rows[0];

    // Создание токена
    const token = jwt.sign({ id: user.id, email: user.email }, jwtSecret, { expiresIn: '1h' });

    res.status(201).json({ token });
  } catch (error) {
    console.error('Ошибка регистрации:', error);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});

// Маршрут для авторизации пользователя
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Проверка существования пользователя
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Неверные email или пароль' });
    }

    const user = result.rows[0];

    // Проверка пароля
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Неверные email или пароль' });
    }

    // Создание токена
    const token = jwt.sign({ id: user.id, email: user.email }, jwtSecret, { expiresIn: '1h' });

    res.json({ token });
  } catch (error) {
    console.error('Ошибка входа:', error);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});

// Маршрут для получения всех категорий
app.get('/categories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM categories');
    res.json(result.rows);
  } catch (error) {
    console.error('Ошибка получения категорий:', error);
    res.status(500).json({ error: 'Ошибка получения категорий' });
  }
});

// Маршрут для получения продуктов по категории
app.get('/categories/:id/products', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      'SELECT * FROM products WHERE category_id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Продукты не найдены для данной категории' });
    }

    res.json(result.rows);
  } catch (error) {
    console.error('Ошибка получения продуктов:', error);
    res.status(500).json({ error: 'Ошибка получения продуктов' });
  }
});

// Маршрут для добавления продукта
app.post('/products', async (req, res) => {
  const { name, price, category_id, imageUrl } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO products (name, price, category_id, imageUrl) VALUES ($1, $2, $3, $4) RETURNING *',
      [name, price, category_id, imageUrl]
    );

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Ошибка добавления продукта:', error);
    res.status(500).json({ error: 'Ошибка добавления продукта' });
  }
});

// Маршрут для обновления продукта
app.put('/products/:id', async (req, res) => {
  const { id } = req.params;
  const { name, price, category_id, imageUrl } = req.body;

  try {
    const result = await pool.query(
      'UPDATE products SET name = $1, price = $2, category_id = $3, imageUrl = $4 WHERE id = $5 RETURNING *',
      [name, price, category_id, imageUrl, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Продукт не найден' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Ошибка обновления продукта:', error);
    res.status(500).json({ error: 'Ошибка обновления продукта' });
  }
});

// Маршрут для удаления продукта
app.delete('/products/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM products WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Продукт не найден' });
    }

    res.json({ message: 'Продукт успешно удален', product: result.rows[0] });
  } catch (error) {
    console.error('Ошибка удаления продукта:', error);
    res.status(500).json({ error: 'Ошибка удаления продукта' });
  }
});

// Запуск сервера
const port = 3000;
app.listen(port, () => {
  console.log(`Сервер запущен на порту ${port}`);
});
