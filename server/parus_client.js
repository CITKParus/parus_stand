/*
    Сервер стенда
    Библиотека низкоуровневого взаимодействия с ПП Парус 8
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const request = require("request"); //обработчик запросов к серверу
const querystring = require("querystring"); //парсер параметров запросов
const conf = require("./config"); //настройки сервера
const utils = require("./utils"); //вспомогательные функции

//-------------------------
//глобальные идентификаторы
//-------------------------

//заголовок запроса к HTTP-серверу ПП Парус 8
const PARUS_REQ_HEADERS = {
    "User-Agent": conf.SERVER_NAME, //агент
    "Content-Type": utils.REQUEST_CT_FORM_URLENCODED //тип содержимого
};

//параметры отправки запросов к HTTP-серверу ПП Парус 8
const PARUS_REQ_METHOD = utils.REQUEST_METHOD_POST; //способ отправки параметров
const PARUS_REQ_QUERY_PRMS = "CPRMS"; //префикс параметров в запросе

//типовые ответы HTTP-сервера ПП Парус 8
const PARUS_RESP_TYPE = "STAND_MESSAGE"; //маркер ответов от сервера
const PARUS_RESP_STATE_ERR = 0; //от сервера пришла ошибка
const PARUS_RESP_STATE_OK = 1; //от сервера пришел успех

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
    request(options, (error, response, body) => {
        //если пришел ответ без ошибок HTTP и транспорта
        if (!error && response.statusCode == utils.HTTP_OK) {
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
            data.callBack(utils.buildErrResp(utils.SERVER_RE_MSG_ERROR_PARUS));
        }
    });
}

//----------------
//интерфейс модуля
//----------------

exports.parusServerAction = parusServerAction;
