const express = require('express');
const router = express.Router();
const db = require('./database.js');
const verifyToken = require('./user').verifyToken;

// Получить забронированное время
router.get("/:data", verifyToken, (req,res) => {  
    const data = req.params.data;
    db.query("CALL get_bookings_by_date(?)", [data], (error,results,fields) => {
        if(error) throw error;
        res.send({error:false, data:results[0], message: "Booked"})
    });
})

// Забронировать время
router.post("/book", verifyToken, (req,res) => {
    const user_id = req.body.user_id;
    const timerange = req.body.timerange;
    const data = req.body.data;
    const category = req.body.category;

    db.query("CALL book_time(?, ?, ?, ?)", [user_id, timerange, data, category], (error,results,fields) => {
        if(error) throw error;
        res.send({error:false, data:results, message: "Updated"})  
    });
})

// Удалить бронирование
router.delete('/delete/:id', verifyToken, (req, res) => {
  const id = req.params.id;
  db.query('CALL delete_and_archive_booking(?)', [id], (error, results, fields) => {
    if (error) throw error;
    res.send(results);
  });
});

// Восстановить удаленное бронирование
router.delete('/restore/:id', verifyToken, (req, res) => {
  const id = req.params.id;
  db.query('CALL restore_archived_booking(?)', [id], (error, results, fields) => {
    if (error) throw error;
    res.send(results);
  });
});

module.exports = router;