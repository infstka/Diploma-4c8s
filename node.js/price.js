const express = require('express');
const router = express.Router();
const db = require('./database.js');

// Получить все услуги
router.get('/', (req, res) => {
  db.query('SELECT * FROM prices', (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Получить услуги по категории
router.get('/category/:category', (req, res) => {
  const category = req.params.category;
  db.query('SELECT * FROM prices WHERE category = ?', [category], (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Добавить новую услугу
router.post('/add', (req, res) => {
  const { service, price, category } = req.body;
  db.query('INSERT INTO prices (service, price, category) VALUES (?, ?, ?)', [service, price, category], (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(201).json({ message: 'Услуга успешно добавлена' });
    }
  });
});

// Обновить услугу по идентификатору
router.put('/update/:id', (req, res) => {
  const id = req.params.id;
  const { service, price } = req.body;
  db.query('UPDATE prices SET service = ?, price = ? WHERE id = ?', [service, price, id], (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json({ message: 'Услуга успешно обновлена' });
    }
  });
});

// Удалить услугу по идентификатору
router.delete('/delete/:id', (req, res) => {
  const id = req.params.id;
  db.query('DELETE FROM prices WHERE id = ?', [id], (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json({ message: 'Услуга успешно удалена' });
    }
  });
});

module.exports = router;