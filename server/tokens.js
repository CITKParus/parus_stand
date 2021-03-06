/*
    Сервер стенда
    Библиотека проверки прав доступа клиентов сервера
*/

//---------------------
//подключение библиотек
//---------------------

const conf = require("./config"); //настройки сервера

//-------------------------
//глобальные идентификаторы
//-------------------------

//токены доступа клиентов
const CLIENT_TOKENS = [
    "50fdd530-b44a-4151-a9d7-15662f41c000", //интерфейс мониторинга
    "76433e4e-ed7b-49e2-9497-dc4c66483e9e", //сервис Telegram-бота
    "c48d602f-ac7e-485d-a2f3-8d65f40d81c1", //сервис очереди печати
    "44988367-dca2-4664-b2a5-f17c0b018842" //интерфейс взаимодействия с посетителем
];

//-------
//функции
//-------

//проверка токана доступа клиента
const checkToken = token => {
    //если проверка включена
    if (conf.SERVER_CHECK_TOKENS) {
        //если переданный токен есть в списке
        if (CLIENT_TOKENS.indexOf(token) !== -1)
            //то открываем доступ
            return true;
        else
            //иначе доступа нет
            return false;
    } else {
        //проверка отключена - всегда всё можно
        return true;
    }
};

//----------------
//интерфейс модуля
//----------------

exports.checkToken = checkToken;
