/*
    Сервер стенда
    Библиотека низкоуровневого взаимодействия с вендинговым автоматом
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const request = require("request"); //обработчик запросов к серверу
const conf = require("./config"); //настройки сервера
const utils = require("./utils"); //вспомогательные функции

//-------------------------
//глобальные идентификаторы
//-------------------------

//заголовок HTTP-запроса к вендинговому автомату
const VENDING_MACHINE_REQ_HEADERS = {
    "User-Agent": conf.SERVER_NAME, //агент
    "Content-Type": utils.REQUEST_CT_FORM_URLENCODED //тип содержимого
};

//параметры отправки HTTP-запросов к вендинговому автомату
const VENDING_MACHINE_REQ_METHOD = utils.REQUEST_METHOD_GET; //способ отправки параметров
const VENDING_MACHINE_SHIPMENT_COMMAND = "line"; //код команды отгрузки

//типовые ответы вендингового автомата
const VENDING_MACHINE_RESP_STATE_ERR = "ERR"; //от автомата пришла ошибка
const VENDING_MACHINE_RESP_STATE_OK = "OK"; //от автомата пришел успех

//-------
//функции
//-------

//выполнение действия на вендинговом автомате
function vendingMachineAction(data) {
    //если автомат доступен
    if (conf.VENDING_MACHINE_ENABLED) {
        utils.log({ msg: "Vending machine enabled - requesting..." });
        //настроим запрос
        let options = {
            url: conf.VENDING_MACHINE_HTTP_ADDRESS + "?" + VENDING_MACHINE_SHIPMENT_COMMAND + "=" + data.line,
            method: VENDING_MACHINE_REQ_METHOD,
            headers: VENDING_MACHINE_REQ_HEADERS
        };
        //выполним запрос
        request(options, (error, response, body) => {
            //если пришел ответ без ошибок HTTP и транспорта
            if (!error && response.statusCode == utils.HTTP_OK) {
                //пробуем его интерпретировать
                try {
                    let machineResp = JSON.parse(body);
                    //преобразуем сообщение от вендингового аппарата в типовой ответ сервера стенда
                    data.callBack(
                        utils.buildServerResp(
                            machineResp.state == VENDING_MACHINE_RESP_STATE_ERR
                                ? utils.SERVER_STATE_ERR
                                : utils.SERVER_STATE_OK,
                            machineResp.message
                        )
                    );
                } catch (e) {
                    //при интерпретации произошла ошибка - это неожиданный ответ, мы хотели JSON
                    data.callBack(utils.buildErrResp(utils.SERVER_RE_MSG_UNEXPECTED_RESPONSE_VENDING));
                }
            } else {
                //были ошибки транспорта (сети нет, или нет сервера по указанному адресу и т.п.)
                utils.log({ type: utils.LOG_TYPE_ERR, msg: "Can't connect to vending machine: " + error });
                data.callBack(utils.buildErrResp(utils.SERVER_RE_MSG_ERROR_VENDING));
            }
        });
    } else {
        utils.log({ msg: "Vending machine disabled" });
        data.callBack(utils.buildOkResp("Vending machine disabled"));
    }
}

//----------------
//интерфейс модуля
//----------------

exports.vendingMachineAction = vendingMachineAction;
