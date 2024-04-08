const express = require('express');
const router = express.Router();
const db = require('./database.js');

// Получить забронированное время
router.get("/:data", (req,res) => {  
    const data = req.params.data;
    db.query("CALL get_bookings_by_date(?)", [data], (error,results,fields) => {
        if(error) throw error;
        res.send({error:false, data:results[0], message: "Booked"})
    });
})

// Забронировать время
router.post("/book", (req,res) => {
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
router.delete('/delete/:id', (req, res) => {
  const id = req.params.id;
  db.query('CALL delete_and_archive_booking(?)', [id], (error, results, fields) => {
    if (error) throw error;
    res.send(results);
  });
});

// Восстановить удаленное бронирование
router.delete('/restore/:id', (req, res) => {
  const id = req.params.id;
  db.query('CALL restore_archived_booking(?)', [id], (error, results, fields) => {
    if (error) throw error;
    res.send(results);
  });
});

module.exports = router;