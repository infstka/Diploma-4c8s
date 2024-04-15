const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const fs = require('fs');
var db = require('./database.js');
const { generateSecretKey, loadSecretKey } = require('./generator');

let secretKey;

secretKey = loadSecretKey();

// Функция для генерации JWT токена
function generateToken(user_email) {
    const token = jwt.sign({ email: user_email }, secretKey, { expiresIn: '3d' });
    return token;
}

// Middleware для проверки токена
function verifyToken(req, res, next) {
    const bearerHeader = req.headers['authorization'];
    if (typeof bearerHeader !== 'undefined') {
        const bearer = bearerHeader.split(' ');
        const bearerToken = bearer[1];
        jwt.verify(bearerToken, secretKey, (err, authData) => {
            if (err) {
                res.sendStatus(403);
            } else {
                req.authData = authData;
                next();
            }
        });
    } else {
        res.sendStatus(403);
    }
}

// Регистрация (+ проверка)
router.route('/register').post(async (req, res) => {
    var username = req.body.username;
    var user_email = req.body.user_email;
    var user_password = req.body.user_password;
    var hashedPassword = await bcrypt.hash(user_password, 10); 

    db.query('CALL check_while_reg(?, ?, @userExists)', [username, user_email], (error, results, fields) => {
        if (error) {
            res.send(JSON.stringify({
                success: false,
                message: error
            }));
        } else {
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
                    const token = generateToken(user_email); 
                    res.send(JSON.stringify({
                        success: true,
                        user: data[0],
                        token: token 
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

module.exports.router = router;
module.exports.verifyToken = verifyToken;