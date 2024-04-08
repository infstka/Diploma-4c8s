const express = require('express');
const router = express.Router();
const db = require('./database.js');

// Получить все контакты
router.get('/', (req, res) => {
  const query = 'CALL get_contacts()';
  
  db.query(query, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results[0]);
    }
  });
});

// Добавить новый контакт
router.post('/add', (req, res) => {
  const { contact, contact_type } = req.body;
  
  const query = 'CALL new_contact(?, ?)';
  const values = [contact, contact_type];
  
  db.query(query, values, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(201).json({ message: 'Контакт успешно добавлен' });
    }
  });
});

// Обновить контакт по идентификатору
router.put('/update/:id', (req, res) => {
  const id = req.params.id;
  const { contact } = req.body;
  
  const query = 'CALL update_contact(?, ?)';
  const values = [contact, id];
  
  db.query(query, values, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json({ message: 'Контакт успешно обновлен' });
    }
  });
});

// Удалить контакт по идентификатору
router.delete('/delete/:id', (req, res) => {
  const id = req.params.id;
  
  const query = 'CALL delete_contact(?)';
  const values = [id];
  
  db.query(query, values, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json({ message: 'Контакт успешно удален' });
    }
  });
});

module.exports = router;