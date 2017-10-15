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

//-------
//функции
//-------

//сборка стандартного ответа сервера стенда
function buildServerResp(state, message) {
    return {
        state: state,
        message: message
    };
}

//выполнение действия на сервере ПП Парус 8
function parusServerAction(data) {
    //преобразуем параметры для передачи
    let reqPrms = {};
    reqPrms[conf.PARUS_REQ_QUERY_PRMS] = JSON.stringify(data.prms);
    reqPrms = querystring.stringify(reqPrms);
    //настроим запрос
    let options = {
        url: conf.PARUS_HTTP_ADDRESS,
        method: conf.PARUS_REQ_METHOD,
        headers: conf.PARUS_REQ_HEADERS,
        body: reqPrms
    };
    //выполним запрос
    request(options, function(error, response, body) {
        //если пришел ответ без ошибок HTTP и транспорта
        if (!error && response.statusCode == conf.HTTP_OK) {
            //пробуем его интерпретировать
            try {
                let srvResp = JSON.parse(body);
                //проверим, может быть пришел типовой ответ - просто успех или ошибка операции
                if (srvResp.RESP_TYPE == conf.PARUS_RESP_TYPE) {
                    //преобразуем сообщение от ПП Парус 8 в типовой ответ сервера стенда
                    data.callBack(
                        buildServerResp(
                            srvResp.STATE == conf.PARUS_RESP_STATE_ERR ? conf.SERVER_STATE_ERR : conf.SERVER_STATE_OK,
                            srvResp.MSG
                        )
                    );
                } else {
                    // пришел не типовой ответ - данные о чём-то - отдаём как есть, указав, что всё успешно
                    data.callBack(buildServerResp(conf.SERVER_STATE_OK, srvResp));
                }
            } catch (e) {
                //при интерпретации произошла ошибка - это неожиданный ответ, мы хотели JSON
                data.callBack(buildServerResp(conf.SERVER_STATE_ERR, conf.SERVER_RE_MSG_UNEXPECTED_RESPONSE));
            }
        } else {
            //были ошибки транспорта (сети нет, или нет сервера по указанному адресу и т.п.)
            data.callBack(buildServerResp(conf.SERVER_STATE_ERR, conf.SERVER_RE_MSG_ERROR));
        }
    });
}

//----------------
//интерфейс модуля
//----------------

exports.parusServerAction = parusServerAction;
