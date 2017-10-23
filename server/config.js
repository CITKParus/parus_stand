/*
    Сервер стенда
    Константы и настройки
*/

//----------------
//интерфейс модуля
//----------------

//наименование сервера
exports.SERVER_NAME = "CITK Demo Stand/0.0.1";

//параметры сервера
exports.SERVER_PORT = 3000; //порт
exports.SERVER_CHECK_TOKENS = false; //флаг контроля токенов доступа клиентов

//параметры подключения к HTTP-серверу ПП Парус 8
exports.PARUS_HTTP_ADDRESS = "http://212.5.81.211:7777/stand/PARUS.UDO_PKG_WEB_API.PROCESS"; //адрес HTTP-сервера
exports.PARUS_USER_NAME = "stand"; //имя пользователя
exports.PARUS_USER_PASSWORD = "stand"; //пароль пользователя
exports.PARUS_COMPANY = "Организация"; //регистрационный номер организации

//параметры подключения к HTTP-серверу вендингового автомата
exports.VENDING_MACHINE_HTTP_ADDRESS = "http://192.168.1.74:8080"; //адрес HTTP-сервера
exports.VENDING_MACHINE_ENABLED = true; //флаг доступности вендингового автомата
