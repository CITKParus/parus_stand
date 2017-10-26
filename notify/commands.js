/*
    Оповещение о событиях стенда (Telegram)
    Cценарии отработки команд
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const _ = require("lodash"); //работа с массивами и коллекциями

//-------------------------
//глобальные идентификаторы
//-------------------------

//команды бота
const COMMANDS = {
    CMD_START: "start", //начало работы с ботом
    CMD_HELP: "help" //справка
};

//состояния обработки команд
const PRC_STATE_ERR = "prc_state_err"; //состояние обработки команды - ошибка
const PRC_STATE_OK = "prc_state_ok"; //состояние обработки команды - всё нормально

//типовые ответы обработчиков команд
const CMDS_MSG_NO_COMMAND = "Такой команды я не знаю, может быть Вам поможет /" + COMMANDS.CMD_HELP; //нет такой команды
const CMDS_MSG_NO_COMMAND_DESCR = "Для команды нет описания, извините, не могу Вам помочь :("; //нет описания команды
const CMDS_MSG_UNDER_CONSTRUCTION = "Команда в разработке, программист Иван обещал реализовать к маю..."; //функция в разработке
const CMDS_MSG_COMMON_ERROR_TITLE = "Во мне есть какой-то изъян:"; //типовой заголовок для сообщеия об ошибке
const CMDS_MSG_BUSY = "Подождите, пожалуйста, я ещё не обработал текущую задачу!"; //занят
const CMDS_MSG_NOT_A_COMMAND =
    "Я ожидал команду, но это не она... Попробуйте /" +
    COMMANDS.CMD_HELP +
    ' для получения справки, помните - команда начинается с "/"'; //передана не команда

//---------------------------
//функции отработки сообщений
//---------------------------

//типовой ответ обработчика сообщений
const createResp = (state, chatID, message, options) => {
    let res = {
        state: state,
        chatID: chatID,
        message: message,
        options: {}
    };
    if (options) _.extend(res.options, options);
    return res;
};

//заглушка - функция в разработке
const underConstruction = prms => {
    return new Promise(function(resolve, reject) {
        resolve(createResp(PRC_STATE_OK, prms.message.chatID, CMDS_MSG_UNDER_CONSTRUCTION));
    });
};

//начало работы с ботом
const processStart = prms => {
    return new Promise(function(resolve, reject) {
        let cmd = _.find(SCENARIO, { command: prms.chatState.currentCommand });
        if (!cmd) {
            reject(createResp(PRC_STATE_ERR, prms.message.chatID, CMDS_MSG_NO_COMMAND));
        } else {
            if (!cmd.descr) reject(createResp(PRC_STATE_ERR, prms.message.chatID, CMDS_MSG_NO_COMMAND_DESCR));
            else resolve(createResp(PRC_STATE_OK, prms.message.chatID, cmd.descr));
        }
    });
};

//справка
const processHelp = prms => {
    return new Promise((resolve, reject) => {
        let resp =
            "Когда на сервере ПП Парус 8 что-то происходит, например формируется отгрузочный документ или сервером фоновой печати подготавливается очередной отчет, я узнаю про это и сообщаю Вам.";
        resolve(createResp(PRC_STATE_OK, prms.message.chatID, resp, { parse_mode: "HTML" }));
    });
};

//------------------------------------
//настройка сценариев обработки команд
//------------------------------------

//сценарии
const SCENARIO = [
    //отработка команды "Старт"
    {
        command: COMMANDS.CMD_START,
        descr:
            'Здравствуйте, я бот демонастрационного стенда ЦИТК "Парус". Основная моя задача - рассказывать о том, что происходит на стенде. Если Вы хотите узнать о моих возможностях - исполните команду /' +
            COMMANDS.CMD_HELP,
        processor: processStart
    },
    //отработка команды "Помощь"
    {
        command: COMMANDS.CMD_HELP,
        descr: "Получение справки по командам бота",
        processor: processHelp
    }
];

//----------------
//интерфейс модуля
//----------------

exports.COMMANDS = COMMANDS;
exports.PRC_STATE_ERR = PRC_STATE_ERR;
exports.PRC_STATE_OK = PRC_STATE_OK;
exports.CMDS_MSG_NO_COMMAND = CMDS_MSG_NO_COMMAND;
exports.CMDS_MSG_NO_COMMAND_DESCR = CMDS_MSG_NO_COMMAND_DESCR;
exports.CMDS_MSG_UNDER_CONSTRUCTION = CMDS_MSG_UNDER_CONSTRUCTION;
exports.CMDS_MSG_COMMON_ERROR_TITLE = CMDS_MSG_COMMON_ERROR_TITLE;
exports.CMDS_MSG_BUSY = CMDS_MSG_BUSY;
exports.CMDS_MSG_NOT_A_COMMAND = CMDS_MSG_NOT_A_COMMAND;
exports.SCENARIO = SCENARIO;
exports.createResp = createResp;
