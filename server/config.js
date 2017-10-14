/*
    Сервис взаимодействия стенда с ПП Парус 8
    Константы и настройки
*/

//----------------
//интерфейс модуля
//----------------

//параметры сервера
exports.SERVER_PORT = 3000;

//параметры подключения к ПП Парус 8
exports.PARUS_HTTP_ADDRESS = "http://212.5.81.211:7777/stand/PARUS.UDO_PKG_WEB_API.PROCESS"; //адрес HTTP-сервера
exports.PARUS_USER_NAME = "stand"; //имя пользователя
exports.PARUS_USER_PASSWORD = "stand"; //пароль пользователя
exports.PARUS_COMPANY = "Организация"; //регистрационный номер организации
