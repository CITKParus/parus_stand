/*
    Обработка очереди печати стенда
    Клиент для взаимодействия с серверной частью стенда
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const _ = require("lodash"); //работа с массивами и коллекциями
const http = require("http"); //работа с HTTP протоколом
const request = require("request"); //работа с HTTP-сервером
const fs = require("fs"); //работа с файловой системой
const config = require("./config"); //настройки приложения
const utils = require("./utils"); //вспомогательные функции

//-------------------------
//глобальные идентификаторы
//-------------------------

//параметры протокола HTTP
const HTTP_OK = 200; //код успешного ответа HTTP-сервера

//типы передачи POST-параметров в запросах к серверу
const REQUEST_CT_JSON = "application/json"; //передаём JSON

//методы запросов к серверу
const REQUEST_METHOD_POST = "POST"; //POST-запрос
const REQUEST_METHOD_GET = "GET"; //GET-запрос

//действия сервера стенда
const SERVER_ACTION_MSG_GET_LIST = "MSG_GET_LIST"; //получение списка уведомлений
const SERVER_ACTION_MSG_SET_STATE = "MSG_SET_STATE"; //установка состояния уведомления
const SERVER_ACTION_MSG_INSERT = "MSG_INSERT"; //добавление сообщения
const SERVER_ACTION_MSG_DELETE = "MSG_DELETE"; //удаление сообщения
const SERVER_ACTION_PRINT_GET_STATE = "PRINT_GET_STATE"; //проверка состояния отчета в очереди печати

//типы сообщений в очереди уведомлений стенда
const SERVER_MSG_TYPE_NOTIFY = "NOTIFY"; //уведомления
const SERVER_MSG_TYPE_RESTS = "RESTS"; //остатки в натуральном выражении
const SERVER_MSG_TYPE_REST_PRC = "REST_PRC"; //остатки в процентах
const SERVER_MSG_TYPE_PRINT = "PRINT"; //очередь печати

//состояния сообщений в очереди уведомлений стенда
const SERVER_MSG_STATE_NOT_SENDED = "NOT_SENDED"; //не отправлено (для типа "NOTIFY")
const SERVER_MSG_STATE_SENDED = "SENDED"; //отправлено (для типа "NOTIFY")
const SERVER_MSG_STATE_NOT_PRINTED = "NOT_PRINTED"; //не напечатано (для типа "PRINT")
const SERVER_MSG_STATE_PRINTED = "PRINTED"; //напечатано (для типа "PRINT")
const SERVER_MSG_STATE_UNDEFINED = "UNDEFINED"; //не определено (для остальных типов)

//виды уведомительных сообщений очереди стенда
const SERVER_MSG_NOTIFY_INFO = "INFORMATION"; //информация
const SERVER_MSG_NOTIFY_WARN = "WARNING"; //предупреждение
const SERVER_MSG_NOTIFY_ERROR = "ERROR"; //ошибка

//порядок сортировки сообщений в очереди уведомлений стенда
const SERVER_MSG_ORDER_OLD_FIRST = 1; //сначала старые
const SERVER_MSG_ORDER_NEW_FIRST = -1; //сначала новые

//состосние отчета в очереди
const SERVER_RPT_QUEUE_STATE_INS = "QUEUE_STATE_INS"; //поставлено в очередь
const SERVER_RPT_QUEUE_STATE_RUN = "QUEUE_STATE_RUN"; //обрабатывается
const SERVER_RPT_QUEUE_STATE_OK = "QUEUE_STATE_OK"; //завершено успешно
const SERVER_RPT_QUEUE_STATE_ERR = "QUEUE_STATE_ERR"; //завершено с ошибкой

//типовые состояния ответов сервера
const SERVER_STATE_ERR = "ERR"; //состояние сервера - ошибка
const SERVER_STATE_OK = "OK"; //состояние сервера - всё нормально

//типовые сообщения коиента
const CLIENT_RE_MSG_ERROR = "Ошибка сервера стенда!"; //ошибка при обращении к внешнему сервису
const CLIENT_RE_MSG_UNEXPECTED_RESPONSE = "Неожиданный ответ сервера стенда!"; //ошибка при разборе ответа внешнего сервиса

//-------
//функции
//-------

//сборка стандартного ответа клиента
const buildServerResp = (state, message) => {
    return {
        state: state,
        message: message
    };
};

//сборка стандартного отрицательного ответа клиента
const buildErrResp = message => {
    return buildServerResp(SERVER_STATE_ERR, message);
};

//сборка стандартного положительного ответа клиента
const buildOkResp = message => {
    return buildServerResp(SERVER_STATE_OK, message);
};

//конвертация параметров запроса к серверу в application/x-www-form-urlencoded
const objectToReqestBodyParams = obj => {
    let str = "";
    for (let key in obj) {
        if (str != "") str += "&";
        str += key + "=" + encodeURIComponent(obj[key]);
    }
    return str;
};

//выполнение действия на сервере стенда
const standServerAction = prms => {
    return new Promise((resolve, reject) => {
        let headers = {}; //заголовок запроса
        let body = null; //тело запроса
        let method = prms.method || REQUEST_METHOD_POST; //метод (POST, GET, PUT и т.п.)
        let params = { token: config.CLIENT_TOKEN }; //параметры передаваемые API
        //выставим параметры API для передачи на сервер (если они есть)
        if (prms.actionData) {
            _.extend(params, prms.actionData);
        }
        //заголовок для GET содержит параметры
        if (method == REQUEST_METHOD_GET) {
            if (params) for (let key in params) headers[key] = params[key];
        }
        //заголовок для POST - тип данных тела
        if (method == REQUEST_METHOD_POST) {
            headers["Content-type"] = REQUEST_CT_JSON;
        }
        //для POST в тело положим параметры
        if (method == REQUEST_METHOD_POST) {
            body = JSON.stringify(params);
        }
        //настроим запрос
        let options = {
            url: config.SERVER_URL,
            method,
            headers,
            body
        };
        //выполним запрос
        request(options, (error, response, body) => {
            //если пришел ответ без ошибок HTTP и транспорта
            if (!error && response.statusCode == HTTP_OK) {
                //пробуем его интерпретировать
                try {
                    let srvResp = JSON.parse(body);
                    resolve(srvResp);
                } catch (e) {
                    //при интерпретации произошла ошибка - это неожиданный ответ, мы хотели JSON
                    reject(buildErrResp(CLIENT_RE_MSG_UNEXPECTED_RESPONSE));
                }
            } else {
                //были ошибки транспорта (сети нет, или нет сервера по указанному адресу и т.п.)
                reject(buildErrResp(CLIENT_RE_MSG_ERROR));
            }
        });
    });
};

//скачивание файла по указанному URL
const downloadFile = (fileName, fileURL) => {
    return new Promise((resolve, reject) => {
        let fullFileName = config.TEMP_FOLDER + "\\" + fileName;
        let file = fs.createWriteStream(fullFileName);
        file.on("error", err => {
            reject(buildErrResp(err.message));
        });
        file.on("open", () => {
            let request = http
                .get(fileURL, response => {
                    response.pipe(file);
                    file.on("finish", () => {
                        file.close(() => {
                            resolve(buildOkResp(fullFileName));
                        });
                    });
                })
                .on("error", err => {
                    utils.removeFile(fullFileName);
                    reject(buildErrResp(err.message));
                });
        });
    });
};

//----------------
//интерфейс модуля
//----------------

exports.SERVER_ACTION_MSG_GET_LIST = SERVER_ACTION_MSG_GET_LIST;
exports.SERVER_ACTION_MSG_SET_STATE = SERVER_ACTION_MSG_SET_STATE;
exports.SERVER_ACTION_MSG_INSERT = SERVER_ACTION_MSG_INSERT;
exports.SERVER_ACTION_MSG_DELETE = SERVER_ACTION_MSG_DELETE;
exports.SERVER_ACTION_PRINT_GET_STATE = SERVER_ACTION_PRINT_GET_STATE;
exports.SERVER_MSG_TYPE_NOTIFY = SERVER_MSG_TYPE_NOTIFY;
exports.SERVER_MSG_TYPE_RESTS = SERVER_MSG_TYPE_RESTS;
exports.SERVER_MSG_TYPE_REST_PRC = SERVER_MSG_TYPE_REST_PRC;
exports.SERVER_MSG_TYPE_PRINT = SERVER_MSG_TYPE_PRINT;
exports.SERVER_MSG_STATE_NOT_SENDED = SERVER_MSG_STATE_NOT_SENDED;
exports.SERVER_MSG_STATE_SENDED = SERVER_MSG_STATE_SENDED;
exports.SERVER_MSG_STATE_NOT_PRINTED = SERVER_MSG_STATE_NOT_PRINTED;
exports.SERVER_MSG_STATE_PRINTED = SERVER_MSG_STATE_PRINTED;
exports.SERVER_MSG_STATE_UNDEFINED = SERVER_MSG_STATE_UNDEFINED;
exports.SERVER_MSG_NOTIFY_INFO = SERVER_MSG_NOTIFY_INFO;
exports.SERVER_MSG_NOTIFY_WARN = SERVER_MSG_NOTIFY_WARN;
exports.SERVER_MSG_NOTIFY_ERROR = SERVER_MSG_NOTIFY_ERROR;
exports.SERVER_MSG_ORDER_OLD_FIRST = SERVER_MSG_ORDER_OLD_FIRST;
exports.SERVER_MSG_ORDER_NEW_FIRST = SERVER_MSG_ORDER_NEW_FIRST;
exports.SERVER_RPT_QUEUE_STATE_INS = SERVER_RPT_QUEUE_STATE_INS;
exports.SERVER_RPT_QUEUE_STATE_RUN = SERVER_RPT_QUEUE_STATE_RUN;
exports.SERVER_RPT_QUEUE_STATE_OK = SERVER_RPT_QUEUE_STATE_OK;
exports.SERVER_RPT_QUEUE_STATE_ERR = SERVER_RPT_QUEUE_STATE_ERR;
exports.SERVER_STATE_ERR = SERVER_STATE_ERR;
exports.SERVER_STATE_OK = SERVER_STATE_OK;
exports.buildErrResp = buildErrResp;
exports.buildOkResp = buildOkResp;
exports.standServerAction = standServerAction;
exports.downloadFile = downloadFile;
