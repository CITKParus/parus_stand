/*
    Сервис взаимодействия стенда с ПП Парус 8
    Главный модуль
*/

//---------------------
//подключение библиотек
//---------------------

const http = require("http"); //библиотека для работы с HTTP
const config = require("./config"); //настройки сервиса
const parusClient = require("./parus_client"); //низкоуровневый клиент ПП Парус 8 !!!! убарть !!!!

//-----------
//точка входа
//-----------

//запуск процесса
function run() {
    //запускаем WEB-сервис
    var srv = http.createServer((req, res) => {
        const resp = { data: "HI! I'M STAND SERVER! CONNECTING TO PARUS SYSTEM AT " + config.PARUS_HTTP_ADDRESS };
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(resp));
    });
    srv.listen(config.SERVER_PORT);
}

//старутем
//run();
parusClient.parusServerAction({
    prms: { SACTION: "STAND_GET_STATE", SSESSION: "931D8EEAC7394A748065758114DF22E0" },
    callBack: resp => {
        console.log(resp);
    }
});
