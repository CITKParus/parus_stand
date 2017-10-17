/*
    Сервис взаимодействия стенда с ПП Парус 8
    Клиентский модуль для низкоуровневого взаимодействия с ПП Парус 8
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const request = require("request"); //обработчик запросов к серверу
const querystring = require("querystring"); //парсер параметров запросов
const conf = require("./config"); //настройки сервиса
const utils = require("./utils"); //вспомогательные функции

//-------------------------
//глобальные идентификаторы
//-------------------------

//параметры протокола HTTP
const HTTP_OK = 200; //код успешного ответа HTTP-сервера

//заголовок запроса к HTTP-серверу ПП Парус 8
const PARUS_REQ_HEADERS = {
    "User-Agent": "CITK Demo Stand/0.0.1", //агент
    "Content-Type": "application/x-www-form-urlencoded" //тип содержимого
};

//параметры отправки запросов к HTTP-серверу ПП Парус 8
const PARUS_REQ_METHOD = "POST"; //способ отправки параметров
const PARUS_REQ_QUERY_PRMS = "CPRMS"; //префикс параметров в запросе

//типовые ответы HTTP-сервера ПП Парус 8
const PARUS_RESP_TYPE = "STAND_MESSAGE"; //маркер ответов от сервера
const PARUS_RESP_STATE_ERR = 0; //от сервера пришла ошибка
const PARUS_RESP_STATE_OK = 1; //от сервера пришел успех

//команды HTTP-сервера ПП Парус 8
const PARUS_ACTION_VERIFY = "VERIFY";
const PARUS_ACTION_DOWNLOAD = "DOWNLOAD";
const PARUS_ACTION_LOGIN = "LOGIN";
const PARUS_ACTION_LOGOUT = "LOGOUT";
const PARUS_ACTION_AUTH_BY_BARCODE = "AUTH_BY_BARCODE";
const PARUS_ACTION_SHIPMENT = "SHIPMENT";
const PARUS_ACTION_MSG_INSERT = "MSG_INSERT";
const PARUS_ACTION_MSG_GET_LIST = "MSG_GET_LIST";
const PARUS_ACTION_STAND_GET_STATE = "STAND_GET_STATE";

//-------
//функции
//-------

//выполнение действия на сервере ПП Парус 8
function parusServerAction(data) {
    //преобразуем параметры для передачи
    let reqPrms = {};
    reqPrms[PARUS_REQ_QUERY_PRMS] = JSON.stringify(data.prms);
    reqPrms = querystring.stringify(reqPrms);
    //настроим запрос
    let options = {
        url: conf.PARUS_HTTP_ADDRESS,
        method: PARUS_REQ_METHOD,
        headers: PARUS_REQ_HEADERS,
        body: reqPrms
    };
    //выполним запрос
    request(options, function(error, response, body) {
        //если пришел ответ без ошибок HTTP и транспорта
        if (!error && response.statusCode == HTTP_OK) {
            //пробуем его интерпретировать
            try {
                let srvResp = JSON.parse(body);
                //проверим, может быть пришел типовой ответ - просто успех или ошибка операции
                if (srvResp.RESP_TYPE == PARUS_RESP_TYPE) {
                    //преобразуем сообщение от ПП Парус 8 в типовой ответ сервера стенда
                    data.callBack(
                        utils.buildServerResp(
                            srvResp.STATE == PARUS_RESP_STATE_ERR ? utils.SERVER_STATE_ERR : utils.SERVER_STATE_OK,
                            srvResp.MSG
                        )
                    );
                } else {
                    // пришел не типовой ответ - данные о чём-то - отдаём как есть, указав, что всё успешно
                    data.callBack(utils.buildOkResp(srvResp));
                }
            } catch (e) {
                //при интерпретации произошла ошибка - это неожиданный ответ, мы хотели JSON
                data.callBack(utils.buildErrResp(utils.SERVER_RE_MSG_UNEXPECTED_RESPONSE));
            }
        } else {
            //были ошибки транспорта (сети нет, или нет сервера по указанному адресу и т.п.)
            data.callBack(utils.buildErrResp(utils.SERVER_RE_MSG_ERROR));
        }
    });
}

//----------------
//интерфейс модуля
//----------------

exports.PARUS_ACTION_VERIFY = PARUS_ACTION_VERIFY;
exports.PARUS_ACTION_DOWNLOAD = PARUS_ACTION_DOWNLOAD;
exports.PARUS_ACTION_LOGIN = PARUS_ACTION_LOGIN;
exports.PARUS_ACTION_LOGOUT = PARUS_ACTION_LOGOUT;
exports.PARUS_ACTION_AUTH_BY_BARCODE = PARUS_ACTION_AUTH_BY_BARCODE;
exports.PARUS_ACTION_SHIPMENT = PARUS_ACTION_SHIPMENT;
exports.PARUS_ACTION_MSG_INSERT = PARUS_ACTION_MSG_INSERT;
exports.PARUS_ACTION_MSG_GET_LIST = PARUS_ACTION_MSG_GET_LIST;
exports.PARUS_ACTION_STAND_GET_STATE = PARUS_ACTION_STAND_GET_STATE;
exports.parusServerAction = parusServerAction;
