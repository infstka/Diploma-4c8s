const express = require('express');
const app = express();

const cors = require('cors');
app.use(cors()); 

var db = require('./database.js');
app.use(express.json());

var bodyParser = require('body-parser');
app.use(bodyParser.urlencoded({extended: true}));

// Обслуживание статических файлов из директории 'files'
app.use('/files', express.static('files'));

const userRouter = require('./user');
app.use('/user', userRouter);

const bookingRouter = require('./booking');
app.use('/booking', bookingRouter);

const profileRouter = require('./profile');
app.use('/profile', profileRouter);

const reviewRouter = require('./review');
app.use('/review', reviewRouter);

const adminRouter = require('./admin');
app.use('/admin', adminRouter);

const priceRouter = require('./price');
app.use('/price', priceRouter);

const clientRouter = require('./client');
app.use('/client', clientRouter);

const equipmentRouter = require('./equipment');
app.use('/equipment', equipmentRouter);

const contactRouter = require('./contact');
app.use('/contact', contactRouter);

//сервирование статических файлов из папки build/web
app.use(express.static('build/web'));

//обработка всех остальных запросов
app.use('*', (req, res) => {
  res.sendFile(__dirname + '/build/web/index.html');
});

app.listen(3000, () => console.log('Сервер запущен на http://localhost:3000'));