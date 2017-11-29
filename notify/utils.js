/*
    Оповещение о событиях стенда (Telegram)
    Утилиты для работы сервиса
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const _ = require("lodash"); //работа с массивами и коллекциями
const EOL = require("os").EOL; //сдвиг каретки
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

//проверка на команду
const isCommand = str => {
    return str.startsWith("/");
};

//извлечение команды из текста
const getCommand = str => {
    //результат работы
    let res = "";
    //если это вообще команда - извлекаем
    if (isCommand(str)) {
        if (str.indexOf(" ") == -1) res = str.substr(1);
        else res = str.substr(1, str.indexOf(" ") - 1);
    }
    //вернем результат
    return res;
};

//разбор сообщения
const parseMessage = m => {
    //инициализируем результат
    let res = {
        msg: {},
        userName: m.from.first_name,
        isCommand: false,
        command: "",
        chatID: -1,
        chatType: "",
        queryID: "",
        queryData: ""
    };
    //положим туда исходное сообщение "как есть"
    _.extend(res.msg, m);
    //достанем спец-поля
    res.chatID = m.chat.id;
    res.chatType = m.chat.type;
    if (m.entities) if (_.find(m.entities, { type: "bot_command" })) res.isCommand = true;
    if (res.isCommand) res.command = getCommand(m.text);
    //вернем ответ
    return res;
};

//----------------
//интерфейс модуля
//----------------

exports.EOL = EOL;
exports.log = log;
exports.isCommand = isCommand;
exports.getCommand = getCommand;
exports.parseMessage = parseMessage;
