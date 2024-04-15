const express = require('express');
const router = express.Router();
const db = require('./database.js');
const verifyToken = require('./user').verifyToken;

// Получить услуги по категории
router.get('/category/:category', verifyToken, (req, res) => {
  const category = req.params.category;
  const query = 'CALL get_services_by_category(?)';
  
  db.query(query, [category], (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results[0]);
    }
  });
});

// Добавить новую услугу
router.post('/add', verifyToken, (req, res) => {
  const { service, price, category } = req.body;
  const query = 'CALL new_service(?, ?, ?)';
  const values = [service, price, category];
  
  db.query(query, values, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(201).json({ message: 'Услуга успешно добавлена' });
    }
  });
});

// Обновить услугу по идентификатору
router.put('/update/:id', verifyToken, (req, res) => {
  const id = req.params.id;
  const { service, price } = req.body;
  const query = 'CALL update_service(?, ?, ?)';
  const values = [service, price, id];
  
  db.query(query, values, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json({ message: 'Услуга успешно обновлена' });
    }
  });
});

// Удалить услугу по идентификатору
router.delete('/delete/:id', verifyToken, (req, res) => {
  const id = req.params.id;
  const query = 'CALL delete_service(?)';
  const values = [id];
  
  db.query(query, values, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json({ message: 'Услуга успешно удалена' });
    }
  });
});

module.exports = router;