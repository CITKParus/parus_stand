/*
    Сервис взаимодействия стенда с ПП Парус 8
    Главный модуль
*/

//---------------------
//подключение библиотек
//---------------------
const http = require("http");
const config = require("./config");

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
run();
