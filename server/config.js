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
exports.SERVER_PORT = 3030; //порт
exports.SERVER_CHECK_TOKENS = true; //флаг контроля токенов доступа клиентов
exports.SERVER_VERIFY_PARUS_SESSION = false; //флаг принудительной проверки доступности сессии Парус 8
exports.SERVER_USER_RESET_EMERGENCY_CODE = -321; //ключ аварийного сброса текущего пользователя вендингового автомата

//параметры подключения к HTTP-серверу ПП Парус 8
exports.PARUS_HTTP_ADDRESS = "http://212.5.81.211:7777/stand/PARUS.UDO_PKG_WEB_API.PROCESS"; //адрес HTTP-сервера
exports.PARUS_USER_NAME = "stand"; //имя пользователя
exports.PARUS_USER_PASSWORD = "stand"; //пароль пользователя
exports.PARUS_COMPANY = "Организация"; //регистрационный номер организации

//параметры подключения к HTTP-серверу вендингового автомата
//exports.VENDING_MACHINE_HTTP_ADDRESS = "http://192.168.1.74:8080"; //адрес HTTP-сервера (дом)
exports.VENDING_MACHINE_HTTP_ADDRESS = "http://172.28.35.232:8080"; //адрес HTTP-сервера (офис)
exports.VENDING_MACHINE_ENABLED = false; //флаг доступности вендингового автомата

//параметры использования сервиса печати
exports.PRINT_SERVICE_ENABLED = true; //флаг доступности сервиса печати
