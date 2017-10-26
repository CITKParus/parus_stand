/*
    Сервер стенда
    Вспомогательные функции
*/

//---------------------
//подключение библиотек
//---------------------

const os = require("os"); //средства операционной системы
const url = require("url"); //работа с адресной строкой
const qs = require("querystring"); //парсинг параметров запросов (application/x-www-form-urlencoded)
const mp = require("multiparty"); //парсинг данных форм запросов (multipart/form-data)

//-------------------------
//глобальные идентификаторы
//-------------------------

//параметры протокола HTTP
const HTTP_OK = 200; //код успешного ответа HTTP-сервера

//типовые состояния ответов сервера
const SERVER_STATE_ERR = "ERR"; //состояние сервера - ошибка
const SERVER_STATE_OK = "OK"; //состояние сервера - всё нормально

//типовые сообщения ответов сервера
const SERVER_RE_MSG_ERROR = "Ошибка внешнего сервиса!"; //ошибка при обращении к внешнему сервису
const SERVER_RE_MSG_ERROR_PARUS = "Ошибка внешнего сервиса (ПП Парус 8)!"; //ошибка при обращении к внешнему сервису (ПП Парус 8)
const SERVER_RE_MSG_ERROR_VENDING = "Ошибка внешнего сервиса (вендинговый автомат)!"; //ошибка при обращении к внешнему сервису (вендинговый автомат)
const SERVER_RE_MSG_UNEXPECTED_RESPONSE = "Неожиданный ответ внешнего сервиса!"; //ошибка при разборе ответа внешнего сервиса
const SERVER_RE_MSG_UNEXPECTED_RESPONSE_PARUS = "Неожиданный ответ внешнего сервиса (ПП Парус 8)!"; //ошибка при разборе ответа внешнего сервиса (ПП Парус 8)
const SERVER_RE_MSG_UNEXPECTED_RESPONSE_VENDING = "Неожиданный ответ внешнего сервиса (вендинговый автомат)!"; //ошибка при разборе ответа внешнего сервиса (вендинговый автомат)
const SERVER_RE_MSG_BAD_REQUEST = "Запрос некорректен (возможно вы забыли указать один из параметров)!"; //некорректный запрос от клиента
const SERVER_RE_MSG_ACCESS_DENIED = "Доступ запрещён (проверьте идентификатор клиента)!"; //нет доступа
const SERVER_RE_MSG_SHIPED = "Спасибо, что заинтересовались нашим стендом, не забудьте забрать накладную!"; //сообщение об успешной отгрузке товара посетителю
const SERVER_RE_MSG_SHIPED_NO_PRINT = "Спасибо, что заинтересовались нашим стендом!"; //сообщение об успешной отгрузке товара посетителю (без печати документа отгрузки)

//типы сообщений протокола работы сервера
const LOG_TYPE_INFO = "log_info"; //сообщение с информацией
const LOG_TYPE_ERR = "log_error"; //сообщение об ошибке

//состояния запросов к серверу
const REQUEST_STATE_ERR = 0; //некорректный запрос
const REQUEST_STATE_OK = 1; //корректный запрос

//типы передачи POST-параметров в запросах к серверу
const REQUEST_CT_FORM_URLENCODED = "application/x-www-form-urlencoded";
const REQUEST_CT_FORM_DATA = "multipart/form-data";
const REQUEST_CT_JSON = "application/json";

//методы запросов к серверу
const REQUEST_METHOD_POST = "POST"; //POST-запрос
const REQUEST_METHOD_GET = "GET"; //GET-запрос

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

//сборка стандартного отрицательного ответа сервера стенда
function buildErrResp(message) {
    return buildServerResp(SERVER_STATE_ERR, message);
}

//сборка стандартного положительного ответа сервера стенда
function buildOkResp(message) {
    return buildServerResp(SERVER_STATE_OK, message);
}

//протоколирование
function log(prms) {
    if (prms && prms.msg) {
        //по умолчанию - информация
        if (prms.type === undefined) prms.type = LOG_TYPE_INFO;
        //работаетм от типа сообщения
        switch (prms.type) {
            //информация
            case LOG_TYPE_INFO: {
                console.log(prms.msg);
                break;
            }
            //ошибка
            case LOG_TYPE_ERR: {
                console.error("ERROR: " + prms.msg);
                break;
            }
            //каой-то неизвестный тип
            default:
                break;
        }
    }
}

//получение списка IP-адресов хоста сервера
function getIPs() {
    let ips = [];
    //получим список сетевых интерфейсов
    const ifaces = os.networkInterfaces();
    //обходим сетевые интерфейсы
    Object.keys(ifaces).forEach(function(ifname) {
        ifaces[ifname].forEach(function(iface) {
            //пропускаем локальный адрес и не IPv4 адреса
            if ("IPv4" !== iface.family || iface.internal !== false) return;
            //добавим адрес к резульату
            ips.push(iface.address);
        });
    });
    //вернем ответ
    return ips;
}

//разбор параметров запроса к серверу
function parseRequestParams(request, callBack) {
    //если это POST-запрос - будем разбирать тело
    if (request.method == REQUEST_METHOD_POST) {
        //если параметры в формате application/x-www-form-urlencoded или application/json
        if (
            request.headers["content-type"] == REQUEST_CT_FORM_URLENCODED ||
            request.headers["content-type"] == REQUEST_CT_JSON
        ) {
            //зафиксируем, что запрос - годный
            let type = REQUEST_STATE_OK;
            //POST параметры собираем из тела
            let body = "";
            //забираем данные из тела
            request.on("data", function(data) {
                body += data;
                //слишком большой запрос - возможно флуд
                if (body.length > 1e6) {
                    type = REQUEST_STATE_ERR;
                    request.connection.destroy();
                }
            });
            //данных больше нет
            request.on("end", function() {
                //вернем то чо получилось
                if (type === REQUEST_STATE_ERR) {
                    callBack(REQUEST_STATE_ERR);
                } else {
                    if (request.headers["content-type"] == REQUEST_CT_JSON) {
                        try {
                            let data = JSON.parse(body);
                            callBack(data);
                        } catch (e) {
                            callBack(REQUEST_STATE_ERR);
                        }
                    }
                    if (request.headers["content-type"] == REQUEST_CT_FORM_URLENCODED) {
                        callBack(qs.parse(body));
                    }
                }
            });
        } else {
            //если параметры в формате multipart/form-data
            if (String(request.headers["content-type"]).startsWith(REQUEST_CT_FORM_DATA)) {
                let form = new mp.Form();
                //установим обработчик ошибок разбора формы
                form.on("error", function(err) {
                    callBack(REQUEST_STATE_ERR);
                });
                //выполним разбор
                form.parse(request, (err, fields, files) => {
                    if (!err) {
                        let prms = {};
                        Object.keys(fields).forEach(f => {
                            prms[f] = fields[f][0];
                        });
                        callBack(prms);
                    } else {
                        callBack(REQUEST_STATE_ERR);
                    }
                });
            } else {
                //неизвестный формат параметров
                callBack(REQUEST_STATE_ERR);
            }
        }
    } else {
        //для GET-запроса - из адресной строки или заголовков (если в адресной строке пусто)
        let q = url.parse(request.url, true).query;
        if (JSON.stringify(q) === "{}") callBack(request.headers);
        else callBack(q);
    }
}

//----------------
//интерфейс модуля
//----------------
exports.HTTP_OK = HTTP_OK;
exports.SERVER_STATE_ERR = SERVER_STATE_ERR;
exports.SERVER_STATE_OK = SERVER_STATE_OK;
exports.SERVER_RE_MSG_ERROR = SERVER_RE_MSG_ERROR;
exports.SERVER_RE_MSG_ERROR_PARUS = SERVER_RE_MSG_ERROR_PARUS;
exports.SERVER_RE_MSG_ERROR_VENDING = SERVER_RE_MSG_ERROR_VENDING;
exports.SERVER_RE_MSG_UNEXPECTED_RESPONSE = SERVER_RE_MSG_UNEXPECTED_RESPONSE;
exports.SERVER_RE_MSG_UNEXPECTED_RESPONSE_PARUS = SERVER_RE_MSG_UNEXPECTED_RESPONSE_PARUS;
exports.SERVER_RE_MSG_UNEXPECTED_RESPONSE_VENDING = SERVER_RE_MSG_UNEXPECTED_RESPONSE_VENDING;
exports.SERVER_RE_MSG_BAD_REQUEST = SERVER_RE_MSG_BAD_REQUEST;
exports.SERVER_RE_MSG_ACCESS_DENIED = SERVER_RE_MSG_ACCESS_DENIED;
exports.SERVER_RE_MSG_SHIPED = SERVER_RE_MSG_SHIPED;
exports.SERVER_RE_MSG_SHIPED_NO_PRINT = SERVER_RE_MSG_SHIPED_NO_PRINT;
exports.LOG_TYPE_INFO = LOG_TYPE_INFO;
exports.LOG_TYPE_ERR = LOG_TYPE_ERR;
exports.REQUEST_STATE_ERR = REQUEST_STATE_ERR;
exports.REQUEST_STATE_OK = REQUEST_STATE_OK;
exports.REQUEST_CT_FORM_URLENCODED = REQUEST_CT_FORM_URLENCODED;
exports.REQUEST_CT_FORM_DATA = REQUEST_CT_FORM_DATA;
exports.REQUEST_CT_JSON = REQUEST_CT_JSON;
exports.REQUEST_METHOD_POST = REQUEST_METHOD_POST;
exports.REQUEST_METHOD_GET = REQUEST_METHOD_GET;
exports.buildServerResp = buildServerResp;
exports.buildErrResp = buildErrResp;
exports.buildOkResp = buildOkResp;
exports.log = log;
exports.getIPs = getIPs;
exports.parseRequestParams = parseRequestParams;
