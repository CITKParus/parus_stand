/*
    WEB-монитор стенда
    Клиент для взаимодействия с серверной частью стенда
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

import config from "./config"; //настройки приложения

//-------------------------
//глобальные идентификаторы
//-------------------------

//типы передачи POST-параметров в запросах к серверу
const REQUEST_CT_JSON = "application/json"; //передаём JSON

//методы запросов к серверу
const REQUEST_METHOD_POST = "POST"; //POST-запрос
const REQUEST_METHOD_GET = "GET"; //GET-запрос

//действия сервера стенда
const SERVER_ACTION_STAND_GET_STATE = "STAND_GET_STATE"; //получение состояния стенда

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
        //исполним запрос
        fetch(config.SERVER_URL, { method, headers, body }).then(
            r => {
                //если всё успешно - разбираем JSON-ответ
                r.json().then(
                    jR => {
                        //JSON успешно разобран
                        resolve(jR);
                    },
                    jE => {
                        //ошибка при парсинге - это неожиданный ответ сервера
                        reject(buildErrResp(CLIENT_RE_MSG_UNEXPECTED_RESPONSE));
                    }
                );
            },
            e => {
                //ошибка транспорта - сети нет, или сервер не поднят
                reject(buildErrResp(CLIENT_RE_MSG_ERROR));
            }
        );
    });
};

//----------------
//интерфейс модуля
//----------------

export default {
    SERVER_ACTION_STAND_GET_STATE,
    SERVER_STATE_ERR,
    SERVER_STATE_OK,
    standServerAction
};
