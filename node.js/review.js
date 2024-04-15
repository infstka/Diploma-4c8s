const express = require('express');
const router = express.Router();
const db = require('./database.js');
const verifyToken = require('./user').verifyToken;

// Получить все отзывы + сортировка
router.get('/', verifyToken, (req, res) => {
  const sort = req.query.sort || 'date'; // по умолчанию сортировка по дате
  const sortOrder = req.query.sortOrder || 'desc'; // по умолчанию по убыванию

  let sqlQuery = '';
  switch (sort) {
    case 'date':
      sqlQuery = `CALL get_reviews_ordered_by_date('${sortOrder}')`;
      break;
    case 'mark':
      sqlQuery = `CALL get_reviews_ordered_by_mark('${sortOrder}')`;
      break;
    default:
      sqlQuery = `CALL get_reviews()`;
  }

  db.query(sqlQuery, (err, result) => {
    if (err) {
      res.status(500).json({ error: 'Ошибка' });
    } else {
      res.status(200).json(result[0]);
    }
  });
});

// Добавить новый отзыв
router.post('/new', verifyToken, (req, res) => {
  const { user_id, review_datetime, review_mark, review_comment } = req.body;
  const sqlQuery = "CALL new_review(?,?,?,?)";
  db.query(sqlQuery, [user_id, review_datetime, review_mark, review_comment], (err, result) => {
    if (err) {
      res.status(500).json({ error: 'Ошибка' });
    } else {
      res.status(200).json({ message: 'Отзыв добавлен' });
    }
  });
});

// Обновить отзыв по идентификатору
router.put('/update/:id', verifyToken, (req, res) => {
  const id = req.params.id;
  const { review_datetime, review_mark, review_comment } = req.body;
  const sqlQuery = "CALL update_review(?,?,?,?)";
  db.query(sqlQuery, [review_datetime, review_mark, review_comment, id], (err, result) => {
    if (err) {
      res.status(500).json({ error: 'Ошибка' });
    } else {
      if (result.affectedRows === 0) {
        res.status(404).json({ error: `Отзыв с идентификатором ${id} не найден` });
      } else {
        res.status(200).json({ message: `Отзыв с идентификатором ${id} обновлен` });
      }
    }
  });
});

// Удалить отзыв
router.delete('/delete/:id', verifyToken, (req, res) => {
  const id = req.params.id;
  const sqlQuery = "CALL delete_review(?)";
  db.query(sqlQuery, [id], (err, result) => {
    if (err) {
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      res.send(JSON.stringify({success: true, message: `Review with id ${id} has been deleted`}));
    }
  });
});

module.exports = router;
