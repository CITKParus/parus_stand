/*
    Сервис взаимодействия стенда с ПП Парус 8
    Константы и настройки
*/

//----------------
//интерфейс модуля
//----------------

//общесистемные
exports.HTTP_OK = 200; //код успешного ответа HTTP-сервера

//параметры сервера
exports.SERVER_PORT = 3000;

//типовые состояния ответов сервера
exports.SERVER_STATE_ERR = "ERR"; //состояние сервера - ошибка
exports.SERVER_STATE_OK = "OK"; //состояние сервера - всё нормально

//типовые сообщения состояния ответов сервера
exports.SERVER_RE_MSG_ERROR = "Ошибка внешнего сервиса!"; //ошибка при обращении к внешнему сервису
exports.SERVER_RE_MSG_UNEXPECTED_RESPONSE = "Неожиданный ответ внешнего сервиса!"; //ошибка при разборе ответа внешнего сервиса

//параметры подключения к HTTP-серверу ПП Парус 8
exports.PARUS_HTTP_ADDRESS = "http://212.5.81.211:7777/stand/PARUS.UDO_PKG_WEB_API.PROCESS"; //адрес HTTP-сервера
exports.PARUS_USER_NAME = "stand"; //имя пользователя
exports.PARUS_USER_PASSWORD = "stand"; //пароль пользователя
exports.PARUS_COMPANY = "Организация"; //регистрационный номер организации

//заголовок запроса к HTTP-серверу ПП Парус 8
exports.PARUS_REQ_HEADERS = {
    "User-Agent": "CITK Demo Stand/0.0.1", //агент
    "Content-Type": "application/x-www-form-urlencoded" //тип содержимого
};

//параметры отправки запросов к HTTP-серверу ПП Парус 8
exports.PARUS_REQ_METHOD = "POST"; //способ отправки параметров
exports.PARUS_REQ_QUERY_PRMS = "CPRMS"; //префикс параметров в запросе

//типовые ответы HTTP-сервера ПП Парус 8
exports.PARUS_RESP_TYPE = "STAND_MESSAGE"; //маркер ответов от сервера
exports.PARUS_RESP_STATE_ERR = 0; //от сервера пришла ошибка
exports.PARUS_RESP_STATE_OK = 1; //от сервера пришел успех
