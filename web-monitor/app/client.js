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
const REQUEST_CT_FORM_URLENCODED = "application/x-www-form-urlencoded";
const REQUEST_CT_FORM_DATA = "multipart/form-data";

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
    return new Promise(function(resolve, reject) {
        //общие параметры запроса
        let method = prms.method || REQUEST_METHOD_POST; //метод (POST, GET, PUT и т.п.)
        let params = { token: config.CLIENT_TOKEN }; //параметры передаваемые API
        //выставим параметры API для передачи на сервер (если они есть)
        if (prms.actionData) {
            _.extend(params, prms.actionData);
        }
        //создадим объект запроса
        let request = new XMLHttpRequest();
        //будем отслеживать изменения состояния запроса
        request.onreadystatechange = () => {
            //сеанс связи с сервером открыт
            if (request.readyState == 1) {
                //выставим заголовок для GET-запросов
                if (method == REQUEST_METHOD_GET) {
                    //если параметры есть
                    if (params)
                        //то они будут записаны в заголовок запроса к серверу
                        for (let key in params) request.setRequestHeader(key, params[key]);
                }
                //выставим заголовок для POST-запросов
                if (method == REQUEST_METHOD_POST) {
                    request.setRequestHeader("Content-type", REQUEST_CT_FORM_URLENCODED);
                }
            }
            //сервер ответил
            if (request.readyState == 4) {
                //пробуем разбираться с тем, что прислал сервер
                try {
                    //сервер вернул успех при отработке запроса
                    if (request.status == 200) {
                        //патыемся распарсить и просто отдать ответ, закрыв обещание
                        resolve(JSON.parse(request.responseText));
                    } else {
                        //сервер сообщил об ошибке
                        reject(JSON.parse(request.responseText).serror);
                    }
                } catch (e) {
                    //разобраться не удалось
                    reject(buildErrResp(CLIENT_RE_MSG_UNEXPECTED_RESPONSE));
                }
            }
        };
        //ошибка подключения к серверу (нет связи или что-то подобное)
        request.onerror = () => {
            reject(buildErrResp(CLIENT_RE_MSG_ERROR));
        };
        //откроем асинхронный запрос к серверу
        try {
            request.open(method, config.SERVER_URL, true);
        } catch (e) {
            reject(buildErrResp(CLIENT_RE_MSG_ERROR));
        }
        //отправляем сформированный запрос на сервер (для GET запросов - пустой, для остальных - с параметрами)
        request.send(method == REQUEST_METHOD_GET ? null : objectToReqestBodyParams(params));
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
