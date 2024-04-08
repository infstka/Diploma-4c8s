const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const db = require('./database.js');

// Обновление профиля пользователя
router.put('/update/:id', async (req, res) => {
  const id = req.params.id;
  const { username, user_password, user_email } = req.body;
  let hashedPassword = user_password; 
  if (user_password.trim() !== '') { 
    hashedPassword = await bcrypt.hash(user_password, 10);
  }
  
  // Проверяем уникальность username и user_email
  const sqlQueryCheck = "CALL check_duplicate_user_except_current(?, ?, ?, @user_count)";
  db.query(sqlQueryCheck, [id, username, user_email], (err, result) => {
    db.query('SELECT @user_count', (err, result) => {
      if (err) {
        res.status(500).json({ error: 'Ошибка сервера' });
      } else if (result[0]['@user_count'] > 0) {
        // Если нашлось совпадение, возвращаем ошибку
        res.status(400).json({ error: 'Пользователь с такими данными уже существует!' });
      } else {
        // Если не найдено совпадений, выполняем обновление профиля пользователя
        const sqlQuery = "CALL update_user_profile(?, ?, ?, ?)";
        db.query(sqlQuery, [id, username, hashedPassword, user_email], (err, result) => {
          if (err) {
            res.status(500).json({ error: 'Ошибка обновления профиля' });
          } else {
            res.status(200).json({ message: 'Профиль обновлен' });
          }
        });
      }
    });
  });
});

// Получить все бронирования для определенного пользователя
router.get('/history/bookings/:id', (req, res) => {
  const id = req.params.id;
  db.query(`CALL get_booking_history(?)`, 
           [id], (error, results, fields) => {
    if (error) throw error;
    res.send(results[0]);
  });
});

// Получить все аренды для определенного пользователя
router.get('/history/rentals/:id', (req, res) => {
  const id = req.params.id;
  db.query('CALL get_rentals_history(?)', [id], (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results[0]);
    }
  });
});

module.exports = router;