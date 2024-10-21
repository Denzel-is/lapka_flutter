const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
 const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');
const cartFilePath = path.join(__dirname, 'cart.json'); // Путь к файлу





// Конфигурация подключения к PostgreSQL
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'lapka',
  password: '1234',
  port: 5432,
});
// Проверяем, существует ли файл корзины. Если нет, создаем его с пустым массивом
if (!fs.existsSync(cartFilePath)) {
  writeCartFile([]); // Если файл не существует, создаем его с пустым массивом
}
const app = express();
 app.use(cors());
app.use(bodyParser.json());


// Секретный ключ для JWT
const jwtSecret = 'ertyuiokjhgfdrtyuioll51254hbgvbnhygtvhbnjhy5145';

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
//// Добавление товара в корзину
//app.post('/cart', async (req, res) => {
//  const { productId, quantity } = req.body;
//  const token = req.headers.authorization?.split(' ')[1];
//
//  if (!token) {
//    return res.status(401).json({ error: 'Токен отсутствует' });
//  }
//
//  try {
//    const decoded = jwt.verify(token, jwtSecret);
//    const userId = decoded.userId;
//
//    // Проверим, есть ли уже этот товар в корзине пользователя
//    const result = await pool.query(
//      'SELECT * FROM cart_items WHERE user_id = $1 AND product_id = $2',
//      [userId, productId]
//    );
//
//    if (result.rows.length > 0) {
//      // Если товар уже в корзине, обновляем количество
//      await pool.query(
//        'UPDATE cart_items SET quantity = quantity + $1 WHERE user_id = $2 AND product_id = $3',
//        [quantity, userId, productId]
//      );
//    } else {
//      // Если товара нет, добавляем его в корзину
//      await pool.query(
//        'INSERT INTO cart_items (user_id, product_id, quantity) VALUES ($1, $2, $3)',
//        [userId, productId, quantity]
//      );
//    }
//
//    res.json({ message: 'Товар добавлен в корзину' });
//  } catch (error) {
//    console.error(error);
//    res.status(500).json({ error: 'Ошибка добавления товара в корзину' });
//  }
//});
//
//// Получение товаров в корзине
//app.get('/cart', async (req, res) => {
//  const token = req.headers.authorization?.split(' ')[1];
//
//  if (!token) {
//    return res.status(401).json({ error: 'Токен отсутствует' });
//  }
//
//  try {
//    const decoded = jwt.verify(token, jwtSecret);
//    const userId = decoded.userId;
//
//    const result = await pool.query(
//      `SELECT products.id, products.name, products.price, cart_items.quantity
//       FROM cart_items
//       JOIN products ON cart_items.product_id = products.id
//       WHERE cart_items.user_id = $1`,
//      [userId]
//    );
//
//    res.json(result.rows);
//  } catch (error) {
//    console.error(error);
//    res.status(500).json({ error: 'Ошибка получения корзины' });
//  }
//});
//
//// Удаление товара из корзины
//app.delete('/cart/:productId', async (req, res) => {
//  const { productId } = req.params;
//  const token = req.headers.authorization?.split(' ')[1];
//
//  if (!token) {
//    return res.status(401).json({ error: 'Токен отсутствует' });
//  }
//
//  try {
//    const decoded = jwt.verify(token, jwtSecret);
//    const userId = decoded.userId;
//
//    await pool.query('DELETE FROM cart_items WHERE user_id = $1 AND product_id = $2', [userId, productId]);
//
//    res.json({ message: 'Товар удален из корзины' });
//  } catch (error) {
//    console.error(error);
//    res.status(500).json({ error: 'Ошибка удаления товара из корзины' });
//  }
//});

// Добавление товара в корзину
app.post('/cart', (req, res) => {
  const { productId, quantity } = req.body;
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Токен отсутствует' });
  }

  try {
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId;

    let cart = readCartFile();

    // Проверим, есть ли уже этот товар в корзине пользователя
    const existingItem = cart.find(item => item.userId === userId && item.productId === productId);

    if (existingItem) {
      // Обновляем количество товара
      existingItem.quantity += quantity;
    } else {
      // Добавляем новый товар в корзину
      cart.push({ userId, productId, quantity });
    }

    writeCartFile(cart);

    res.json({ message: 'Товар добавлен в корзину' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Ошибка добавления товара в корзину' });
  }
});

// Получение товаров в корзине
app.get('/cart', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Токен отсутствует' });
  }

  try {
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId;

    const cart = readCartFile();
    const userCart = cart.filter(item => item.userId === userId);

    res.json(userCart);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Ошибка получения корзины' });
  }
});

// Удаление товара из корзины
app.delete('/cart/:productId', (req, res) => {
  const { productId } = req.params;
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Токен отсутствует' });
  }

  try {
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId;

    let cart = readCartFile();
    cart = cart.filter(item => !(item.userId === userId && item.productId === productId));

    writeCartFile(cart);

    res.json({ message: 'Товар удален из корзины' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Ошибка удаления товара из корзины' });
  }
});
// Получение продуктов по категории
app.get('/categories/:id/products', async (req, res) => {
  const { id } = req.params; // Получаем id категории

  try {
    // Проверяем наличие продуктов с category_id равным переданному id
    const result = await pool.query(
      'SELECT * FROM products WHERE category_id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Продукты не найдены для данной категории' });
    }

    res.json(result.rows);
  } catch (error) {
    console.error('Ошибка получения продуктов по категории:', error);
    res.status(500).json({ error: 'Ошибка получения продуктов' });
  }
});



function readCartFile() {
  try {
    const data = fs.readFileSync(cartFilePath, 'utf8');
    return JSON.parse(data); // Преобразуем содержимое файла в объект
  } catch (error) {
    console.error('Ошибка чтения файла корзины:', error);
    return []; // Если файла нет, возвращаем пустой массив
  }
}
function writeCartFile(cart) {
  try {
    fs.writeFileSync(cartFilePath, JSON.stringify(cart, null, 2), 'utf8');
  } catch (error) {
    console.error('Ошибка записи файла корзины:', error);
  }
}



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

//// Получение продуктов по категории
//app.get('/categories/:id/products', async (req, res) => {
//  const { id } = req.params;
//  const result = await pool.query(
//    'SELECT * FROM products WHERE category_id = $1',
//    [id]
//  );
//  res.json(result.rows);
//});



// Запуск сервера
const port = 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
