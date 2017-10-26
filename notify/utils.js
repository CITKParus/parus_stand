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

//-------------------------
//глобальные идентификаторы
//-------------------------

//типовые состояния ответов сервера
const STATE_ERR = "ERR"; //состояние сервера - ошибка
const STATE_OK = "OK"; //состояние сервера - всё нормально

//-------
//функции
//-------

//сборка стандартного ответа
function buildResp(state, message) {
    return {
        state: state,
        message: message
    };
}

//сборка стандартного отрицательного ответа
function buildErrResp(message) {
    return buildResp(STATE_ERR, message);
}

//сборка стандартного положительного ответа
function buildOkResp(message) {
    return buildResp(STATE_OK, message);
}

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

//проверка на команду
function isCommand(str) {
    return str.startsWith("/");
}

//извлечение команды из текста
function getCommand(str) {
    //результат работы
    let res = "";
    //если это вообще команда - извлекаем
    if (isCommand(str)) {
        if (str.indexOf(" ") == -1) res = str.substr(1);
        else res = str.substr(1, str.indexOf(" ") - 1);
    }
    //вернем результат
    return res;
}

//разбор сообщения
function parseMessage(m) {
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
}

//----------------
//интерфейс модуля
//----------------

exports.EOL = EOL;
exports.STATE_ERR = STATE_ERR;
exports.STATE_OK = STATE_OK;
exports.buildResp = buildResp;
exports.buildErrResp = buildErrResp;
exports.buildOkResp = buildOkResp;
exports.log = log;
exports.isCommand = isCommand;
exports.getCommand = getCommand;
exports.parseMessage = parseMessage;
