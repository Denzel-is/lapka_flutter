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
