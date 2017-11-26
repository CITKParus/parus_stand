/*
    Сервер стенда
    Главный модуль
*/

//---------------------
//подключение библиотек
//---------------------

const http = require("http"); //библиотека для работы с HTTP
const qs = require("querystring"); //парсер параметров запросов
const conf = require("./config"); //настройки сервера
const parus = require("./parus"); //библиотека высокоуровневого взаимодействия с ПП Парус 8
const utils = require("./utils"); //вспомогательные функции
const tokens = require("./tokens"); //библиотека проверки прав доступа клиентов сервера

//-------------------------
//глобальные идентификаторы
//-------------------------

//состояния сервера
const SERVER_STATE_NOT_STARTED = "not_started";
const SERVER_STATE_STARTED = "started";
const SERVER_STATE_STOPPING = "stopping";

//экземпляр сервера
let srv = {
    httpSrv: {},
    state: SERVER_STATE_NOT_STARTED
};

//заголовок ответа сервера
let STAND_RESP_HEADER = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Methods": "GET, POST"
};

//-------
//функции
//-------

//запуск сервера
const run = () => {
    //скажем, что стартуем
    utils.log({ msg: "Starting server at port " + conf.SERVER_PORT + "..." });
    //опишем WEB-сервер
    srv.httpSrv = http.createServer((req, res) => {
        //только если сервер работает
        if (srv.state == SERVER_STATE_STARTED) {
            //разбираем параметры запроса
            utils.parseRequestParams(req, rp => {
                //скажем, что принимаем любые заголовки
                STAND_RESP_HEADER["Access-Control-Allow-Headers"] =
                    req.headers["access-control-request-headers"] || "*";
                //если запрос не нормальный
                if (rp === utils.REQUEST_STATE_ERR) {
                    //не будем его обрабатывать
                    utils.log({ type: utils.LOG_TYPE_ERR, msg: "New request: Bad server request!" });
                    //скажем клиенту об этом
                    res.writeHead(200, STAND_RESP_HEADER);
                    res.end(JSON.stringify(utils.buildErrResp(utils.SERVER_RE_MSG_BAD_REQUEST)));
                } else {
                    utils.log({ msg: "New request: " + JSON.stringify(rp) });
                    //проверим токен доступа
                    if (tokens.checkToken(rp.token)) {
                        //выполняем действие на сервере ПП Парус 8
                        parus.makeAction(rp).then(
                            r => {
                                res.writeHead(200, STAND_RESP_HEADER);
                                res.end(JSON.stringify(r));
                            },
                            e => {
                                res.writeHead(200, STAND_RESP_HEADER);
                                res.end(JSON.stringify(e));
                            }
                        );
                    } else {
                        //токен доступа не указан или указан неверно
                        res.writeHead(200, STAND_RESP_HEADER);
                        res.end(JSON.stringify(utils.buildErrResp(utils.SERVER_RE_MSG_ACCESS_DENIED)));
                    }
                }
            });
        } else {
            //сервер не работет - рвём соединение (отправляем пустой ответ и закрываем сокет)
            utils.log({ msg: "New connection while server stopping - rejecting..." });
            res.end();
            req.connection.end();
            req.connection.destroy();
        }
    });
    //запускаем WEB-сервер
    srv.httpSrv.listen(conf.SERVER_PORT, () => {
        srv.state = SERVER_STATE_STARTED;
        utils.log({ msg: "Server started at port " + srv.httpSrv.address().port });
        utils.log({ msg: "Available ip's: " + utils.getIPs().join(", ") });
    });
    srv.httpSrv.on("error", e => {
        utils.log({ type: utils.LOG_TYPE_ERR, msg: "Error while starting server: " + e.message });
        process.exit(1);
    });
};

//останов сервера
const stop = () => {
    //сначала прекратим приём сообщений
    utils.log({ msg: "Stoping server..." });
    srv.state = SERVER_STATE_STOPPING;
    srv.httpSrv.close(e => {
        srv.state = SERVER_STATE_NOT_STARTED;
        utils.log({ msg: "Done" });
        //теперь закроем сессию ПП Парус
        parus.makeAction({ action: parus.PARUS_ACTION_LOGOUT }).then(
            r => {
                //завершаем процесс нормально
                process.exit(0);
            },
            e => {
                //завершаем процесс с кодом ошибки
                process.exit(1);
            }
        );
    });
};

//обработка события "выход" жизненного цикла процесса
process.on("exit", code => {
    //сообщим о завершении процесса
    utils.log({ msg: "Process killed with code " + code });
});

//перехват CTRL + C
process.on("SIGINT", () => {
    //инициируем выход из процесса
    stop();
});

//-----------
//точка входа
//-----------

//старутем
run();
