const express = require('express');
var mysql = require('mysql');

var connection = mysql.createConnection
({
    host: 'localhost',
    user: 'root',
    password: 'Malder100malder800',
    port: '3306',
    database: 'dsnrecords_db'
});

connection.connect(function(err){
    if(err) throw err;
    console.log('База данных подключена');
});

module.exports = connection;
