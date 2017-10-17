/*
    Сервис взаимодействия стенда с ПП Парус 8
    Исполнение высокоуровневых функций стенда
*/

//---------------------
//подключение библиотек
//---------------------

const pc = require("./parus_client"); //низкоуровневый клиент ПП Парус 8
const utils = require("./utils"); //вспомогательные функции

//-------------------------
//глобальные идентификаторы
//-------------------------

let PARUS_SESSION = ""; //идентификатор сессии ПП Парус 8

//-------
//функции
//-------

//начало сеанса
function logIn() {
    return new Promise((resolve, reject) => {
        if (!PARUS_SESSION) {
            utils.log({ msp: "No Parus session! Logging in..." });
            pc.parusServerAction({
                prms: { SACTION: pc.PARUS_ACTION_LOGIN, SSESSION: "931D8EEAC7394A748065758114DF22E0" },
                callBack: resp => {
                    console.log(resp);
                }
            });
        } else {
        }
    });
}

//окончание сеанса
function logOut() {}

//окончание сеанса

//получение состояния стенда
function getStandState() {
    /*
parusClient.parusServerAction({
    prms: { SACTION: "STAND_GET_STATE", SSESSION: "931D8EEAC7394A748065758114DF22E0" },
    callBack: resp => {
        console.log(resp);
    }
});
*/
    console.log("getStandState");
}

//выполнение действия ПП Парус 8
function makeAction(prms, res) {
    //console.log("makeAction");
    //console.log(prms);
    //res.writeHead(200, { "Content-Type": "application/json" });
    //res.end(JSON.stringify(resp));
}

//----------------
//интерфейс модуля
//----------------

exports.makeAction = makeAction;
