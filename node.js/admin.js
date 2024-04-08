const express = require('express');
const router = express.Router();
const db = require('./database.js');

// Получить всех пользователей
router.get('/users', (req, res) => {
  const sqlQuery = "CALL get_users()";
  db.query(sqlQuery, (err, result) => {
    if (err) {
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      res.send(JSON.stringify({success: true, users: result[0]}));
    }
  });
});

// Получить всех заблокированных пользователей
router.get('/users/blocked', (req, res) => {
  const sqlQuery = "CALL get_blocked_users()";
  db.query(sqlQuery, (err, result) => {
    if (err) {
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      res.send(JSON.stringify({success: true, blocked_users: result[0]}));
    }
  });
});

// Сделать пользователя администратором
router.put('/users/type/up/:id', (req, res) => {
  const id = req.params.id;
  const sqlQuery = "CALL set_admin(?)";
  db.query(sqlQuery, [id], (err, result) => {
    if (err) {
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      res.send(JSON.stringify({success: true, message: `User with id ${id} is admin now`}));
    }
  });
});

// Лишить пользователя прав администратора 
router.put('/users/type/down/:id', (req, res) => {
  const id = req.params.id;
  const sqlQuery = "CALL set_user(?)";
  db.query(sqlQuery, [id], (err, result) => {
    if (err) {
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      res.send(JSON.stringify({success: true, message: `User with id ${id} is user now`}));
    }
  });
});

// Удалить пользователя по id
router.delete('/users/delete/:id', (req, res) => {
  const id = req.params.id;
  const sqlQuery = "CALL delete_user(?)";
  db.query(sqlQuery, [id], (err, result) => {
    if (err) {
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      res.send(JSON.stringify({success: true, message: `User with id ${id} has been deleted`}));
    }
  });
});

// Заблокировать пользователя по id
router.put('/users/block/:id', (req, res) => {
  const id = req.params.id;
  const sqlQuery = "CALL block_user(?)";
  db.query(sqlQuery, [id], (err, result) => {
    if (err) {
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      res.send(JSON.stringify({success: true, message: `User with id ${id} has been blocked`}));
    }
  });
});

// Разблокировать пользователя по id
router.put('/users/blocked/unblock/:id', (req, res) => {
  const id = req.params.id;
  const sqlQuery = "CALL unblock_user(?)";
  db.query(sqlQuery, [id], (err, result) => {
    if (err) {
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      res.send(JSON.stringify({success: true, message: `User with id ${id} has been unblocked`}));
    }
  });
});

// Получить все бронирования
router.get('/bookings', (req, res) => {
  const sqlQuery = "CALL get_bookings()";
  db.query(sqlQuery, (err, result) => {
    if (err) {
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      res.send(JSON.stringify({success: true, bookings: result[0]}));
    }
  });
});

// Получить все отмененные бронирования
router.get('/bookings/deleted', (req, res) => {
  const sqlQuery = "CALL get_archived_bookings()";
  db.query(sqlQuery, (err, result) => {
    if (err) {
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      res.send(JSON.stringify({success: true, bookings_archive: result[0]}));
    }
  });
});

// Получить все заявки на аренду
router.get('/rentals', (req, res) => {
  const query = 'CALL get_rentals()'; 
  
  db.query(query, (error, results, fields) => {
    if (error) {
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      res.status(200).json(results[0]);
    }
  });
});

// Получить все отмененные заявки на аренду
router.get('/rentals/deleted', (req, res) => {
  const sqlQuery = "CALL get_archived_rentals()";
  db.query(sqlQuery, (err, result) => {
    if (err) {
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      res.send(JSON.stringify({success: true, bookings_archive: result[0]}));
    }
  });
});

module.exports = router;