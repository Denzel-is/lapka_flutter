//const express = require('express');
//const bodyParser = require('body-parser');
//const { Pool } = require('pg');
//const cors = require('cors');
//const jwt = require('jsonwebtoken');
//const bcrypt = require('bcrypt');
//const path = require('path');
//
//const app = express();
//app.use(cors());
//app.use(bodyParser.json());
//
//// Конфигурация подключения к PostgreSQL
//const pool = new Pool({
//  user: 'postgres',
//  host: 'localhost',
//  database: 'lapka',
//  password: '1234',
//  port: 5432,
//});
//
//// Секретный ключ для JWT
//const jwtSecret = 'ertyuiokjhgfdrtyuioll51254hbgvbnhy5145';
//
//// Раздача статических файлов из папки 'images'
//const imageDirectory = path.join(__dirname, 'images');
//app.use('/images', express.static(imageDirectory));
////
//// Middleware для проверки JWT
//const authenticateJWT = (req, res, next) => {
//  const authHeader = req.headers.authorization;
//  if (authHeader) {
//    const token = authHeader.split(' ')[1];
//    jwt.verify(token, jwtSecret, (err, user) => {
//      if (err) {
//        return res.sendStatus(403); // Неверный токен
//      }
//      req.user = user;
//      next();
//    });
//  } else {
//    res.sendStatus(401); // Нет токена
//  }
//};
//
//// ------------------ Роуты авторизации ------------------ //
//
//// Регистрация
//app.post('/register', async (req, res) => {
//  const { email, password } = req.body;
//  try {
//    const existingUser = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
//    if (existingUser.rows.length > 0) {
//      return res.status(400).json({ error: 'Пользователь с таким email уже существует' });
//    }
//    const hashedPassword = await bcrypt.hash(password, 10);
//    const result = await pool.query(
//      'INSERT INTO users (email, password) VALUES ($1, $2) RETURNING *',
//      [email, hashedPassword]
//    );
//    const user = result.rows[0];
//    const token = jwt.sign({ id: user.id, email: user.email }, jwtSecret, { expiresIn: '1h' });
//    res.status(201).json({ token });
//  } catch (error) {
//    console.error('Ошибка регистрации:', error);
//    res.status(500).json({ error: 'Ошибка сервера' });
//  }
//});
//
//// Логин
//app.post('/login', async (req, res) => {
//  const { email, password } = req.body;
//  try {
//    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
//    if (result.rows.length === 0) {
//      return res.status(401).json({ error: 'Неверные email или пароль' });
//    }
//    const user = result.rows[0];
//    const isValidPassword = await bcrypt.compare(password, user.password);
//    if (!isValidPassword) {
//      return res.status(401).json({ error: 'Неверные email или пароль' });
//    }
//    const token = jwt.sign({ id: user.id, email: user.email }, jwtSecret, { expiresIn: '1h' });
//    res.json({ token });
//  } catch (error) {
//    console.error('Ошибка входа:', error);
//    res.status(500).json({ error: 'Ошибка сервера' });
//  }
//});
//
//// ------------------ Роуты корзины ------------------ //
//
//// Получить все товары корзины пользователя
//app.get('/cart', authenticateJWT, async (req, res) => {
//  const userId = req.user.id;
//
//  try {
//    const result = await pool.query(
//      `SELECT cart_items.quantity, products.id, products.name, products.price, products.imageurl
//       FROM cart_items
//       JOIN products ON cart_items.product_id = products.id
//       WHERE cart_items.user_id = $1`,
//      [userId]
//    );
//
//    if (result.rows.length === 0) {
//      return res.status(404).json({ error: 'Корзина пуста' });
//    }
//
//    const cartItems = result.rows.map((row) => ({
//      product: {
//        id: row.id,
//        name: row.name,
//        price: row.price,
//        imageUrl: row.imageurl,
//      },
//      quantity: row.quantity,
//    }));
//
//    res.json(cartItems);
//  } catch (error) {
//    console.error('Ошибка получения корзины:', error);
//    res.status(500).json({ error: 'Ошибка сервера' });
//  }
//});
//
//// Добавить товар в корзину
//app.post('/cart', authenticateJWT, async (req, res) => {
//  const { productId, quantity } = req.body;
//  const userId = req.user.id;
//  try {
//    const existingCartItem = await pool.query(
//      'SELECT * FROM cart_items WHERE user_id = $1 AND product_id = $2',
//      [userId, productId]
//    );
//    if (existingCartItem.rows.length > 0) {
//      const newQuantity = existingCartItem.rows[0].quantity + quantity;
//      const updateResult = await pool.query(
//        'UPDATE cart_items SET quantity = $1 WHERE id = $2 RETURNING *',
//        [newQuantity, existingCartItem.rows[0].id]
//      );
//      res.json(updateResult.rows[0]);
//    } else {
//      const insertResult = await pool.query(
//        'INSERT INTO cart_items (user_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *',
//        [userId, productId, quantity]
//      );
//      res.json(insertResult.rows[0]);
//    }
//  } catch (error) {
//    console.error('Ошибка добавления товара в корзину:', error);
//    res.status(500).json({ error: 'Ошибка добавления товара в корзину' });
//  }
//});app.get('/users/me', authenticateJWT, async (req, res) => {
//     const userId = req.user.id;
//     try {
//       const result = await pool.query('SELECT id, name, email FROM users WHERE id = $1', [userId]);
//       if (result.rows.length === 0) {
//         return res.status(404).json({ error: 'Пользователь не найден' });
//       }
//       res.json(result.rows[0]);
//     } catch (error) {
//       console.error('Ошибка получения данных пользователя:', error);
//       res.status(500).json({ error: 'Ошибка сервера' });
//     }
//   });
//
//
//  app.put('/users/update', authenticateJWT, async (req, res) => {
//    const userId = req.user.id;
//    const { name, email } = req.body;
//
//    if (!name || !email) {
//      return res.status(400).json({ error: 'Имя и email обязательны' });
//    }
//
//    try {
//      await pool.query('UPDATE users SET name = $1, email = $2 WHERE id = $3', [name, email, userId]);
//      res.status(200).json({ message: 'Данные обновлены' });
//    } catch (error) {
//      console.error('Ошибка обновления данных пользователя:', error);
//      res.status(500).json({ error: 'Ошибка сервера' });
//    }
//  });
//app.post('/users/change-password', authenticateJWT, async (req, res) => {
//  const userId = req.user.id;
//  const { password } = req.body;
//
//  if (!password) {
//    return res.status(400).json({ error: 'Пароль обязателен' });
//  }
//
//  try {
//    const hashedPassword = await bcrypt.hash(password, 10);
//    await pool.query('UPDATE users SET password = $1 WHERE id = $2', [hashedPassword, userId]);
//    res.status(200).json({ message: 'Пароль успешно изменён' });
//  } catch (error) {
//    console.error('Ошибка смены пароля:', error);
//    res.status(500).json({ error: 'Ошибка сервера' });
//  }
//});
//
//
//
//
//// ------------------ Проверка статических файлов ------------------ //
//app.get('/images/dog_food.png', (req, res) => {
//  const defaultImagePath = path.join(imageDirectory, 'dog_food.png');
//  res.sendFile(defaultImagePath);
//});
//
//// ------------------ Запуск сервера ------------------ //
//const port = 3000;
//app.listen(port, () => {
//  console.log(`Сервер запущен на порту ${port}`);
//});

// server.js
const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');

const app = express();
app.use(bodyParser.json());

// Настройки подключения к PostgreSQL
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'lapka',
  password: '1234',
  port: 5432,
});

// Пример роутов:
app.post('/api/register', async (req, res) => {
  const { email, password } = req.body;
  // Проверить, нет ли уже такого пользователя, добавить в БД и т.д.
  try {
    const userExists = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );
    if (userExists.rows.length > 0) {
      return res.status(400).json({ error: 'Пользователь существует' });
    }
    await pool.query(
      'INSERT INTO users (email, password) VALUES ($1, $2)',
      [email, password]
    );
    res.status(200).json({ message: 'Регистрация успешна' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});

app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;
  // Проверить пользователя в БД, вернуть токен/сессию
  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1 AND password = $2',
      [email, password]
    );
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Неверные данные' });
    }
    // Допустим, генерируем условный токен
    const token = 'abc123';
    res.status(200).json({ token, message: 'Успех' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});

app.get('/api/products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products');
    // Допустим, в БД есть поля: id, name, description, price, category_id
    res.status(200).json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Сервер запущен на порту ${PORT}`);
});


