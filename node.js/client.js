const express = require('express');
const router = express.Router();
const db = require('./database.js');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Настройка multer
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    cb(null, './files/images/band/');
  },
  filename: function(req, file, cb) {
    cb(null, file.originalname);
  }
});

const upload = multer({ storage: storage });

// Получить всех клиентов
router.get('/', (req, res) => {
  db.query('SELECT * FROM clients', (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Добавить нового клиента
router.post('/add', upload.single('clientImage'), (req, res) => {
  const clientName = req.body.clientName;
  const clientImagePath = req.file.path.replace(/\\/g, '/');
  db.query('INSERT INTO clients (client_name, client_image_path) VALUES (?, ?)', [clientName, clientImagePath], (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(201).json({ message: 'Клиент успешно добавлен' });
    }
  });
});

// Удалить клиента
router.delete('/:clientId', (req, res) => {
  const clientId = req.params.clientId;
  db.query('SELECT client_image_path FROM clients WHERE id = ?', [clientId], (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      const imagePath = results[0].client_image_path;
      db.query('DELETE FROM clients WHERE id = ?', [clientId], (error, results, fields) => {
        if (error) {
          res.status(500).json({ error: 'Ошибка сервера' });
        } else {
          fs.unlink(path.join(__dirname, imagePath), (error) => {
            if (error) {
              console.log('Ошибка удаления файла изображения:', error);
            }
          });
          res.status(200).json({ message: 'Клиент успешно удален' });
        }
      });
    }
  });
});

module.exports = router;