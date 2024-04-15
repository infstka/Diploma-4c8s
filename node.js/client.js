const express = require('express');
const router = express.Router();
const db = require('./database.js');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const verifyToken = require('./user').verifyToken;

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
router.get('/', verifyToken, (req, res) => {
  const query = 'CALL get_clients()';
  
  db.query(query, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results[0]);
    }
  });
});

// Добавить нового клиента
router.post('/add', verifyToken, upload.single('clientImage'), (req, res) => {
  const clientName = req.body.clientName;
  const clientImagePath = req.file.path.replace(/\\/g, '/');
  
  const query = 'CALL new_client(?, ?)';
  const values = [clientName, clientImagePath];
  
  db.query(query, values, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(201).json({ message: 'Клиент успешно добавлен' });
    }
  });
});

// Удалить клиента
router.delete('/:clientId', verifyToken, (req, res) => {
  const clientId = req.params.clientId;
  
  const query = 'CALL delete_client(?)';
  const values = [clientId];
  
  db.query(query, values, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      const imagePath = results[0][0].client_image_path; // Получаем путь к изображению клиента из результатов процедуры
      
      fs.unlink(path.join(__dirname, imagePath), (error) => {
        if (error) {
          console.log('Ошибка удаления файла изображения:', error);
        }
      });
      
      res.status(200).json({ message: 'Клиент успешно удален' });
    }
  });
});

module.exports = router;