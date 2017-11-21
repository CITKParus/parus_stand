/*
    Оповещение о событиях стенда (Telegram)
    Утилиты для работы сервиса
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const fs = require("fs"); //работа с файловой системой
const conf = require("./config"); //константы и настройки

//-------
//функции
//-------

//протоколирование работы
const log = data => {
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
};

//удаление файла
const removeFile = fullFileName => {
    fs.unlink(fullFileName, err => {
        if (err) log(['Ошибка удаления файла "' + fullFileName + '":', err.message]);
    });
};

//----------------
//интерфейс модуля
//----------------

exports.log = log;
exports.removeFile = removeFile;
