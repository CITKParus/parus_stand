/*
    Оповещение о событиях стенда (Telegram)
    Утилиты для работы сервиса
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const conf = require("./config"); //константы и настройки

//-------
//функции
//-------

//протоколирование работы
function log(data) {
    if (conf.DEBUG) {
        if (data) {
            if (Array.isArray(data)) {
                data.forEach(i => {
                    console.log(i);
                });
            } else {
                console.log(data);
            }
        } else {
            console.log(data);
        }
    }
}

//----------------
//интерфейс модуля
//----------------

exports.log = log;
