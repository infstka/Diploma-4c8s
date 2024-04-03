const express = require('express');
const router = express.Router();
const db = require('./database.js');

// Получить все контакты
router.get('/', (req, res) => {
  db.query('SELECT * FROM contacts', (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Получить контакты по типу
router.get('/:type', (req, res) => {
  const type = req.params.type;
  db.query('SELECT * FROM contacts WHERE contact_type = ?', [type], (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Добавить новый контакт
router.post('/add', (req, res) => {
  const { contact, contact_type } = req.body;
  db.query('INSERT INTO contacts (contact, contact_type) VALUES (?, ?)', [contact, contact_type], (error, results, fields) => {
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
  db.query('UPDATE contacts SET contact = ? WHERE id = ?', [contact, id], (error, results, fields) => {
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
  db.query('DELETE FROM contacts WHERE id = ?', [id], (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json({ message: 'Контакт успешно удален' });
    }
  });
});

module.exports = router;