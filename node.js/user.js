const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
var db = require('./database.js');

// Регистрация (+ проверка)
router.route('/register').post(async (req, res) => {
    var username = req.body.username;
    var user_email = req.body.user_email;
    var user_password = req.body.user_password;
    var hashedPassword = await bcrypt.hash(user_password, 10); // Хеширование пароля

    db.query('CALL check_while_reg(?, ?, @userExists)', [username, user_email], (error, results, fields) => {
        if (error) {
            res.send(JSON.stringify({
                success: false,
                message: error
            }));
        } else {
            // Получение результата из переменной @userExists
            db.query('SELECT @userExists AS userExists', (error, results, fields) => {
                if (error) {
                    res.send(JSON.stringify({
                        success: false,
                        message: error
                    }));
                } else {
                    var userExists = results[0].userExists;

                    if (userExists) {
                        res.send(JSON.stringify({
                            success: false,
                            message: 'Пользователь с таким именем пользователя или адресом электронной почты уже существует.'
                        }));
                    } else {
                        db.query('CALL register(?,?,?,?,?)', [username, user_email, hashedPassword, "user", false], (error, results, fields) => {
                            if (error) {
                                res.send(JSON.stringify({
                                    success: false,
                                    message: error
                                }));
                            } else {
                                res.send(JSON.stringify({
                                    success: true,
                                    message: 'Регистрация прошла успешно.'
                                }));
                            }
                        });
                    }
                }
            });
        }
    });
});

// Авторизация
router.route('/login').post((req, res) => {
    var user_email = req.body.user_email;
    var user_password = req.body.user_password;

    db.query("CALL login(?)", [user_email], async (err, data, fields) => {
        if (err) {
            res.send(JSON.stringify({
                success: false,
                message: err
            }));
        } else {
            if (data[0].length > 0) {
                const match = await bcrypt.compare(user_password, data[0][0].user_password);
                if (match) {
                    res.send(JSON.stringify({
                        success: true,
                        user: data[0]
                    }));
                } else {
                    res.send(JSON.stringify({
                        success: false,
                        message: "Неверный пароль"
                    }));
                }
            } else {
                res.send(JSON.stringify({
                    success: false,
                    message: "empty data"
                }));
            }
        }
    });

});

module.exports = router;