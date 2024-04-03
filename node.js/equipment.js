const express = require('express');
const router = express.Router();
const db = require('./database.js');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Настройка multer
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    cb(null, './files/images/equipment/');
  },
  filename: function(req, file, cb) {
    cb(null, file.originalname);
  }
});

const upload = multer({ storage: storage });

// Получить все оборудование
router.get('/', (req, res) => {
  db.query('SELECT * FROM equipment', (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Получить все цены
router.get('/prices', (req, res) => {
  db.query('SELECT * FROM prices', (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Добавить новое оборудование
router.post('/add', upload.single('equipmentImage'), (req, res) => {
  const equipmentName = req.body.equipmentName;
  const equipmentCategory = req.body.equipmentCategory;
  const isRentable = req.body.isRentable === 'true' ? 1 : 0; 
  const equipmentImagePath = req.file.path.replace(/\\/g, '/');
  const priceId = req.body.priceId; 

  db.query('INSERT INTO equipment (eq_name, eq_category, is_rentable, eq_image_path, price_id) VALUES (?, ?, ?, ?, ?)', 
    [equipmentName, equipmentCategory, isRentable, equipmentImagePath, priceId], 
    (error, results, fields) => {
      if (error) {
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        res.status(201).json({ message: 'Оборудование успешно добавлено' });
      }
    }
  );
});

// Удалить оборудование
//router.delete('/:equipmentId', (req, res) => {
//  const equipmentId = req.params.equipmentId;
//  db.query('SELECT eq_image_path FROM equipment WHERE id = ?', [equipmentId], (error, results, fields) => {
//    if (error) {
//      res.status(500).json({ error: 'Ошибка сервера' });
//    } else {
//      const imagePath = results[0].eq_image_path;
//      db.query('DELETE FROM equipment WHERE id = ?', [equipmentId], (error, results, fields) => {
//        if (error) {
//          res.status(500).json({ error: 'Ошибка сервера' });
//        } else {
//          fs.unlink(path.join(__dirname, imagePath), (error) => {
//            if (error) {
//              console.log('Ошибка удаления файла изображения:', error);
//            }
//          });
//          res.status(200).json({ message: 'Оборудование успешно удалено' });
//        }
//      });
//    }
//  });
//});

// Обновить оборудование
router.put('/:equipmentId', upload.single('equipmentImage'), (req, res) => {
  const equipmentId = req.params.equipmentId;
  const equipmentName = req.body.equipmentName;
  const equipmentCategory = req.body.equipmentCategory;
  const isRentable = req.body.isRentable === 'true' ? 1 : 0; 
  let equipmentImagePath = req.body.equipmentImagePath; 

  if (req.file) {
    // Если передано новое изображение, обновляем путь к изображению
    equipmentImagePath = req.file.path.replace(/\\/g, '/');
  }

  const priceId = req.body.priceId; 

  db.query('UPDATE equipment SET eq_name = ?, eq_category = ?, is_rentable = ?, eq_image_path = ?, price_id = ? WHERE id = ?', 
    [equipmentName, equipmentCategory, isRentable, equipmentImagePath, priceId, equipmentId], 
    (error, results, fields) => {
      if (error) {
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        res.status(200).json({ message: 'Оборудование успешно обновлено' });
      }
    }
  );
});

module.exports = router;