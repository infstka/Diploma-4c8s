const express = require('express');
const router = express.Router();
const db = require('./database.js');

// Получить свободное оборудование для аренды на выбранный промежуток дат
router.get('/availableEquipment/:startDate/:endDate', (req, res) => {
  const { startDate, endDate } = req.params;
  db.query(
    'CALL get_available_equipment(?, ?)',
    [startDate, endDate],
    (error, results, fields) => {
      if (error) {
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        res.status(200).json(results[0]);
      }
    }
  );
});

// Создать новую заявку на аренду
router.post('/add', (req, res) => {
  const { start_date, end_date, fullname, phone, user_id, eq_ids } = req.body;
  
  const eq_ids_str = eq_ids.join(',');
  
  const query = 'CALL new_rental(?, ?, ?, ?, ?, ?)';
  const values = [start_date, end_date, fullname, phone, user_id, eq_ids_str];
  
  db.query(query, values, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(201).json({ message: 'Заявка на аренду успешно создана' });
    }
  });
});

// Удалить заявку на аренду
router.delete('/delete/:id', (req, res) => {
  const id = req.params.id;
  db.query('CALL delete_and_archive_rental(?)', [id], (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json({ message: 'Заявка на аренду успешно удалена' });
    }
  });
});

// Восстановить заявку на аренду
router.delete('/restore/:id', (req, res) => {
  const id = req.params.id;
  db.query('CALL restore_archived_rental(?)', [id], (error, results, fields) => {
    if (error) throw error;
    res.send(results);
  });
});

module.exports = router;