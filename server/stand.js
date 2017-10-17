/*
    Сервис взаимодействия стенда с ПП Парус 8
    Главный модуль
*/

//---------------------
//подключение библиотек
//---------------------

const http = require("http"); //библиотека для работы с HTTP
const qs = require("querystring"); //парсер параметров запросов
const conf = require("./config"); //настройки сервиса
const parus = require("./parus"); //библиотека высокоуровневых функций стенда
const utils = require("./utils"); //вспомогательные функции

//-----------
//точка входа
//-----------

//запуск сервиса
function run() {
    //скажем, что стартуем
    utils.log({ msg: "Starting server..." });
    //опишем WEB-сервис
    var srv = http.createServer((req, res) => {
        const resp = { data: "HI! I'M STAND SERVER! CONNECTING TO PARUS SYSTEM AT " + conf.PARUS_HTTP_ADDRESS };
        //разбираем параметры запроса
        utils.parseRequestParams(req, rp => {
            //если запрос не нормальный
            if (rp === utils.REQUEST_STATE_ERR) {
                //не будем его обрабатывать
                utils.log({ type: utils.LOG_TYPE_ERR, msg: "Bad server request!" });
            } else {
                //выполняем действие на сервере ПП Парус 8
                parus.makeAction(rp, res);
            }
        });
    });
    //запускаем WEB-сервис
    srv.listen(conf.SERVER_PORT, () => {
        utils.log({ msg: "Server started at port " + srv.address().port });
        utils.log({ msg: "Available ip's: " + utils.getIPs().join(", ") });
    });
}

//останов сервиса
function stop() {
    utils.log({ msg: "Server stoped!" });
}

//обработка события "выход" жизненного цикла процесса
process.on("exit", code => {
    //остановим сервис
    stop();
});

//перехват CTRL + C
process.on("SIGINT", () => {
    //инициируем выход из процесса
    process.exit(0);
});

//старутем
run();
