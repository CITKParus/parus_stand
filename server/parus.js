/*
    Сервер стенда
    Библиотека высокоуровневого взаимодействия с ПП Парус 8
*/

//---------------------
//подключение библиотек
//---------------------

const conf = require("./config"); //настройки сервера
const pc = require("./parus_client"); //низкоуровневый клиент ПП Парус 8
const vm = require("./vending_machine_client"); //низкоуровневый клиент вендингового аппарата
const utils = require("./utils"); //вспомогательные функции

//-------------------------
//глобальные идентификаторы
//-------------------------

//состояние подключения к ПП Парус 8
let PARUS_SESSION = ""; //идентификатор сессии ПП Парус 8
const PARUS_MAX_CONN_ATTEMPT = 3; //максимальное количество попыток создания подключения к ПП Парус 8

//команды HTTP-сервера ПП Парус 8
const PARUS_ACTION_VERIFY = "VERIFY"; //верификация сессии ПП Парус 8
const PARUS_ACTION_DOWNLOAD = "DOWNLOAD"; //выгрузка файла с сервера ПП Парус 8
const PARUS_ACTION_LOGIN = "LOGIN"; //создание сессии ПП Парус 8
const PARUS_ACTION_LOGOUT = "LOGOUT"; //завершение сессии ПП Парус 8
const PARUS_ACTION_AUTH_BY_BARCODE = "AUTH_BY_BARCODE"; //аутентификация посетителя стенда по штрихкоду
const PARUS_ACTION_SHIPMENT = "SHIPMENT"; //отгрузка товара посетителю
const PARUS_ACTION_SHIPMENT_ROLLBACK = "SHIPMENT_ROLLBACK"; //откат отгрузки товара посетителю
const PARUS_ACTION_PRINT = "PRINT"; //постановка отгрузочного документа в очередь печати
const PARUS_ACTION_MSG_INSERT = "MSG_INSERT"; //добавление сообщения в очедерь уведомлений стенда
const PARUS_ACTION_MSG_DELETE = "MSG_DELETE"; //удаление сообщения из очедери уведомлений стенда
const PARUS_ACTION_MSG_SET_STATE = "MSG_SET_STATE"; //установка состояния сообщения в очедери уведомлений стенда
const PARUS_ACTION_MSG_GET_LIST = "MSG_GET_LIST"; //получение списка сообщений очереди уведомлений стенда
const PARUS_ACTION_STAND_GET_STATE = "STAND_GET_STATE"; //получение состояния стенда

//-------
//функции
//-------

//начало сеанса
function logIn(attempt) {
    return new Promise((resolve, reject) => {
        //проверим наличие сессии
        if (!PARUS_SESSION) {
            //создадим её, если нет
            utils.log({ msg: "No Parus session! Logging in (attempt " + attempt + ")..." });
            pc.parusServerAction({
                prms: {
                    SACTION: PARUS_ACTION_LOGIN,
                    SUSER: conf.PARUS_USER_NAME,
                    SPASSWORD: conf.PARUS_USER_PASSWORD,
                    SCOMPANY: conf.PARUS_COMPANY
                },
                callBack: resp => {
                    //проверим результат создания сессии
                    if (resp.state == utils.SERVER_STATE_ERR) {
                        //не получилось - скажем об этом
                        utils.log({ type: utils.LOG_TYPE_ERR, msg: "Can't create session: " + resp.message });
                        //если ещё есть попытки подключения
                        if (attempt < PARUS_MAX_CONN_ATTEMPT) {
                            //используем их
                            let attRest = PARUS_MAX_CONN_ATTEMPT - attempt;
                            utils.log({ msg: attRest + " more attempts. Trying one more time!" });
                            logIn(++attempt).then(
                                r => {
                                    resolve(r);
                                },
                                e => {
                                    reject(e);
                                }
                            );
                        } else {
                            //всё, сдаёмся
                            reject(resp);
                        }
                    } else {
                        //получилось - запоминаем сессию и выходим с успехом
                        PARUS_SESSION = resp.message.SSESSION;
                        utils.log({ msg: "Session (ID: " + PARUS_SESSION + ") created " });
                        resolve(resp);
                    }
                }
            });
        } else {
            //верифицируем, если она есть
            utils.log({ msg: "Session exists (ID: " + PARUS_SESSION + "). Cheking..." });
            pc.parusServerAction({
                prms: { SACTION: PARUS_ACTION_VERIFY, SSESSION: PARUS_SESSION },
                callBack: resp => {
                    //проверим результат верификации
                    if (resp.state == utils.SERVER_STATE_ERR) {
                        //верификация не удалась - скажем об этом...
                        utils.log({
                            type: utils.LOG_TYPE_ERR,
                            msg: "Can't validate session (ID: " + PARUS_SESSION + "). Relogging in... "
                        });
                        //...забудем кривую сессию
                        PARUS_SESSION = "";
                        //и попробуем сделать новую
                        logIn(1).then(
                            r => {
                                resolve(r);
                            },
                            e => {
                                reject(e);
                            }
                        );
                    } else {
                        //верификация удалась - ресолвим с успехом
                        utils.log({ msg: "Session (ID: " + PARUS_SESSION + ") validated " });
                        resolve(resp);
                    }
                }
            });
        }
    });
}

//окончание сеанса
function logOut() {
    return new Promise((resolve, reject) => {
        //проверим наличие сессии
        if (!PARUS_SESSION) {
            //её нет - и делать нечего
            utils.log({ msg: "No Parus session to be terminated" });
            resolve("");
        } else {
            //сессия есть - будем закрывать её на сервере ПП Парус 8
            utils.log({ msg: "Closing Parus session (ID: " + PARUS_SESSION + ")..." });
            pc.parusServerAction({
                prms: { SACTION: PARUS_ACTION_LOGOUT, SSESSION: PARUS_SESSION },
                callBack: resp => {
                    //проверим результат завершения сессии
                    if (resp.state == utils.SERVER_STATE_ERR) {
                        //завершение не удалось
                        utils.log({
                            type: utils.LOG_TYPE_ERR,
                            msg: "Can't terminate session (ID: " + PARUS_SESSION + "): " + resp.message
                        });
                        reject(resp);
                    } else {
                        utils.log({ msg: "Session (ID: " + PARUS_SESSION + ") terminated " });
                        //забудем сессию
                        PARUS_SESSION = "";
                        //завершение удалась - ресолвим с успехом
                        resolve(utils.buildOkResp("Terminated"));
                    }
                }
            });
        }
    });
}

//получение состояния стенда
function getStandState(prms) {
    return new Promise(function(resolve, reject) {
        //исполняем действие на сервере ПП Парус 8
        pc.parusServerAction({
            prms: { SACTION: PARUS_ACTION_STAND_GET_STATE, SSESSION: PARUS_SESSION },
            callBack: resp => {
                //проверим результат выполнения
                if (resp.state == utils.SERVER_STATE_ERR) {
                    //завершение не удалось
                    reject(resp);
                } else {
                    //завершение удалась - ресолвим с успехом
                    resolve(resp);
                }
            }
        });
    });
}

//аутентификация пользователя по штрих-коду
function authUserByBarcode(prms) {
    return new Promise(function(resolve, reject) {
        //проверим наличие параметров
        if (prms.barcode) {
            //исполняем действие на сервере ПП Парус 8
            pc.parusServerAction({
                prms: { SACTION: PARUS_ACTION_AUTH_BY_BARCODE, SSESSION: PARUS_SESSION, SBARCODE: prms.barcode },
                callBack: resp => {
                    //проверим результат выполнения
                    if (resp.state == utils.SERVER_STATE_ERR) {
                        //завершение не удалось
                        reject(resp);
                    } else {
                        //завершение удалась - ресолвим с успехом
                        resolve(resp);
                    }
                }
            });
        } else {
            reject(utils.buildErrResp("Не указан штрих-код!"));
        }
    });
}

//отгрузка товара посетителю
function shipment(prms) {
    return new Promise(function(resolve, reject) {
        //проверим наличие параметров
        if (prms.customer) {
            if (prms.rack_line) {
                if (prms.rack_line_cell) {
                    //сначала исполняем формирование отгрузочного документа на сервере ПП Парус 8
                    pc.parusServerAction({
                        prms: {
                            SACTION: PARUS_ACTION_SHIPMENT,
                            SSESSION: PARUS_SESSION,
                            SCUSTOMER: prms.customer,
                            NRACK_LINE: prms.rack_line,
                            NRACK_LINE_CELL: prms.rack_line_cell
                        },
                        callBack: resp => {
                            //проверим результат выполнения
                            if (resp.state == utils.SERVER_STATE_ERR) {
                                //завершение не удалось
                                utils.log({
                                    type: utils.LOG_TYPE_ERR,
                                    msg: "Error creating shipment document: " + resp.message
                                });
                                reject(resp);
                            } else {
                                utils.log({
                                    msg: "Shipment document created successfully. Sending command to vending machine..."
                                });
                                //завершение удалась - отдадим команду вендинговому аппарату
                                vm.vendingMachineAction({
                                    line: prms.rack_line_cell,
                                    callBack: r => {
                                        //если с вендинговым автоматом всё прошло успешно
                                        if (r.state != utils.SERVER_STATE_ERR) {
                                            utils.log({
                                                msg: "Sending document to print queue..."
                                            });
                                            //ставим документ в очередь печати (если печать нам доступна)
                                            if (conf.PRINT_SERVICE_ENABLED) {
                                                pc.parusServerAction({
                                                    prms: {
                                                        SACTION: PARUS_ACTION_PRINT,
                                                        SSESSION: PARUS_SESSION,
                                                        NTRANSINVCUST: resp.message
                                                    },
                                                    callBack: printResp => {
                                                        //протоколируем результат постановки в очередь
                                                        if (printResp.state == utils.SERVER_STATE_ERR) {
                                                            //не поставилось в очередь
                                                            utils.log({
                                                                type: utils.LOG_TYPE_ERR,
                                                                msg:
                                                                    "Error sending document to ptint queue: " +
                                                                    resp.message
                                                            });
                                                            //даже если документ в очередь не встал - скажем что всё ок (вендинг уже не откатишь), но выдадим специальное сообщение (без упоминания печати накладных)
                                                            resolve(
                                                                utils.buildOkResp(utils.SERVER_RE_MSG_SHIPED_NO_PRINT)
                                                            );
                                                        } else {
                                                            //поставилось в очередь печати
                                                            utils.log({
                                                                msg: "Document sended to print queue successfully"
                                                            });
                                                            //сделалось всё - и документ, и автомат и печать в очередь
                                                            resolve(utils.buildOkResp(utils.SERVER_RE_MSG_SHIPED));
                                                        }
                                                    }
                                                });
                                            } else {
                                                //скажем что всё ок - нет, значит нет, выдаём специальное сообщение об успехе (без упоминания печати накладных)
                                                utils.log({
                                                    msg: "Document printing disabled"
                                                });
                                                resolve(utils.buildOkResp(utils.SERVER_RE_MSG_SHIPED_NO_PRINT));
                                            }
                                        } else {
                                            utils.log({
                                                type: utils.LOG_TYPE_ERR,
                                                msg:
                                                    "Vending machine error: " +
                                                    r.message +
                                                    " Rolling back shipment document..."
                                            });
                                            //была ошибка на вендинговом автомате - выполним откат товарного документа в ПП Парус 8
                                            pc.parusServerAction({
                                                prms: {
                                                    SACTION: PARUS_ACTION_SHIPMENT_ROLLBACK,
                                                    SSESSION: PARUS_SESSION,
                                                    NTRANSINVCUST: resp.message
                                                },
                                                callBack: rollBackResp => {
                                                    //протоколируем результат отката товарного документа
                                                    if (rollBackResp.state == utils.SERVER_STATE_ERR) {
                                                        utils.log({
                                                            type: utils.LOG_TYPE_ERR,
                                                            msg: "Error rolling back document: " + rollBackResp.message
                                                        });
                                                    } else {
                                                        utils.log({
                                                            msg: "Document rolled back successfully"
                                                        });
                                                    }
                                                    //отдаём ошибку вендингового аппарата
                                                    reject(r);
                                                }
                                            });
                                        }
                                    }
                                });
                            }
                        }
                    });
                } else {
                    reject(utils.buildErrResp("Не указано место хранения яруса стеллажа стенда!"));
                }
            } else {
                reject(utils.buildErrResp("Не указан ярус стеллажа стенда!"));
            }
        } else {
            reject(utils.buildErrResp("Не указан посетитель стенда!"));
        }
    });
}

//получение сообщений из очереди уведомлений стенда
function msgGetList(prms) {
    return new Promise(function(resolve, reject) {
        //проверим наличие параметров
        if (prms) {
            //исполняем действие на сервере ПП Парус 8
            pc.parusServerAction({
                prms: {
                    SACTION: PARUS_ACTION_MSG_GET_LIST,
                    SSESSION: PARUS_SESSION,
                    DFROM: prms.from,
                    STP: prms.type,
                    SSTS: prms.state,
                    NLIMIT: prms.limit,
                    NORDER: prms.order
                },
                callBack: resp => {
                    //проверим результат выполнения
                    if (resp.state == utils.SERVER_STATE_ERR) {
                        //завершение не удалось
                        reject(resp);
                    } else {
                        //завершение удалась - ресолвим с успехом
                        resolve(resp);
                    }
                }
            });
        } else {
            reject(utils.buildErrResp(utils.SERVER_RE_MSG_BAD_REQUEST));
        }
    });
}

//добавление сообщения в очередь стенда
function msgInsert(prms) {
    return new Promise(function(resolve, reject) {
        //проверим наличие параметров
        if (prms) {
            //исполняем действие на сервере ПП Парус 8
            pc.parusServerAction({
                prms: {
                    SACTION: PARUS_ACTION_MSG_INSERT,
                    SSESSION: PARUS_SESSION,
                    STP: prms.type,
                    SMSG: prms.message,
                    SNOTIFY_TYPE: prms.notifyType
                },
                callBack: resp => {
                    //проверим результат выполнения
                    if (resp.state == utils.SERVER_STATE_ERR) {
                        //завершение не удалось
                        reject(resp);
                    } else {
                        //завершение удалась - ресолвим с успехом
                        resolve(resp);
                    }
                }
            });
        } else {
            reject(utils.buildErrResp(utils.SERVER_RE_MSG_BAD_REQUEST));
        }
    });
}

//удаление сообщения из очереди стенда
function msgDelete(prms) {
    return new Promise(function(resolve, reject) {
        //проверим наличие параметров
        if (prms) {
            //исполняем действие на сервере ПП Парус 8
            pc.parusServerAction({
                prms: {
                    SACTION: PARUS_ACTION_MSG_DELETE,
                    SSESSION: PARUS_SESSION,
                    NRN: prms.rn
                },
                callBack: resp => {
                    //проверим результат выполнения
                    if (resp.state == utils.SERVER_STATE_ERR) {
                        //завершение не удалось
                        reject(resp);
                    } else {
                        //завершение удалась - ресолвим с успехом
                        resolve(resp);
                    }
                }
            });
        } else {
            reject(utils.buildErrResp(utils.SERVER_RE_MSG_BAD_REQUEST));
        }
    });
}

//установка статуса сообщения в очереди стенда
function msgSetState(prms) {
    return new Promise(function(resolve, reject) {
        //проверим наличие параметров
        if (prms) {
            //исполняем действие на сервере ПП Парус 8
            pc.parusServerAction({
                prms: {
                    SACTION: PARUS_ACTION_MSG_SET_STATE,
                    SSESSION: PARUS_SESSION,
                    NRN: prms.rn,
                    SSTS: prms.state
                },
                callBack: resp => {
                    //проверим результат выполнения
                    if (resp.state == utils.SERVER_STATE_ERR) {
                        //завершение не удалось
                        reject(resp);
                    } else {
                        //завершение удалась - ресолвим с успехом
                        resolve(resp);
                    }
                }
            });
        } else {
            reject(utils.buildErrResp(utils.SERVER_RE_MSG_BAD_REQUEST));
        }
    });
}

//выполнение действия ПП Парус 8
function makeAction(prms) {
    return new Promise(function(resolve, reject) {
        //здесь будем хранить функцию исполняющую действие на сервере (должна возвращать Promise)
        let actionFunction;
        //определим функцию исполнения действия
        switch (prms.action) {
            //завершение сеанса
            case PARUS_ACTION_LOGOUT: {
                actionFunction = logOut;
                break;
            }
            //получение состояния стенда
            case PARUS_ACTION_STAND_GET_STATE: {
                actionFunction = getStandState;
                break;
            }
            //аутентификация посетителя стенда по штрихкоду
            case PARUS_ACTION_AUTH_BY_BARCODE: {
                actionFunction = authUserByBarcode;
                break;
            }
            //отгрузка товара посетителю
            case PARUS_ACTION_SHIPMENT: {
                actionFunction = shipment;
                break;
            }
            //получение списка сообщений очереди уведомлений стенда
            case PARUS_ACTION_MSG_GET_LIST: {
                actionFunction = msgGetList;
                break;
            }
            //добавление сообщения в очередь уведомлений стенда
            case PARUS_ACTION_MSG_INSERT: {
                actionFunction = msgInsert;
                break;
            }
            //удаление сообщения из очереди уведомлений стенда
            case PARUS_ACTION_MSG_DELETE: {
                actionFunction = msgDelete;
                break;
            }
            //установка состояния сообщения в очереди уведомлений стенда
            case PARUS_ACTION_MSG_SET_STATE: {
                actionFunction = msgSetState;
                break;
            }
            //какая-то неизвестная нам функция
            default: {
                actionFunction = utils.SERVER_RE_MSG_BAD_REQUEST;
                break;
            }
        }
        //если с функцией не определились
        if (actionFunction === utils.SERVER_RE_MSG_BAD_REQUEST) {
            //закроем этот промис сообщением о том, что не смогли найти нужную функцию
            utils.log({ type: utils.LOG_TYPE_ERR, msg: "Bad request" });
            resolve(utils.buildErrResp(utils.SERVER_RE_MSG_BAD_REQUEST));
        } else {
            //если просят всё что угодно, кроме завершения сессии
            if (prms.action != PARUS_ACTION_LOGOUT) {
                return (
                    //всегда перед вызовом функций делаем сессию ПП Парус 8 (если она уже есть - будет просто валидирована, если валидация не удастся - пересоздана)
                    logIn(1)
                        //смотрим что у нас с созданием/верификацией сессии ПП Парус 8
                        .then(
                            //сессия ПП Парус 8- ОК, можно выполнять функцию-действие ПП Парус 8
                            r => {
                                utils.log({ msg: "Executing Parus action '" + prms.action + "'" });
                                return actionFunction(prms);
                            },
                            //вообще не получилось с сессией (может сервер ПП Парус 8 не стартован)
                            e => {
                                throw e;
                            }
                        )
                        //здесь перехватываем результаты функции-действия ПП Парус 8 (всегда ресолвим, что бы наш сервис всегда отдавал ответ, положительный или отрицательный)
                        .then(
                            r => {
                                utils.log({ msg: "Done!" });
                                resolve(r);
                            },
                            e => {
                                utils.log({ type: utils.LOG_TYPE_ERR, msg: "Execution error: " + e.message });
                                resolve(e);
                            }
                        )
                );
            } else {
                //завершаем сессию
                actionFunction().then(
                    r => {
                        resolve(r);
                    },
                    e => {
                        reject(e);
                    }
                );
            }
        }
    });
}

//----------------
//интерфейс модуля
//----------------

exports.PARUS_ACTION_VERIFY = PARUS_ACTION_VERIFY;
exports.PARUS_ACTION_DOWNLOAD = PARUS_ACTION_DOWNLOAD;
exports.PARUS_ACTION_LOGIN = PARUS_ACTION_LOGIN;
exports.PARUS_ACTION_LOGOUT = PARUS_ACTION_LOGOUT;
exports.PARUS_ACTION_AUTH_BY_BARCODE = PARUS_ACTION_AUTH_BY_BARCODE;
exports.PARUS_ACTION_SHIPMENT = PARUS_ACTION_SHIPMENT;
exports.PARUS_ACTION_MSG_INSERT = PARUS_ACTION_MSG_INSERT;
exports.PARUS_ACTION_MSG_GET_LIST = PARUS_ACTION_MSG_GET_LIST;
exports.PARUS_ACTION_STAND_GET_STATE = PARUS_ACTION_STAND_GET_STATE;
exports.makeAction = makeAction;
