/*
    Сервер стенда
    Библиотека высокоуровневого взаимодействия с ПП Парус 8
*/

//---------------------
//подключение библиотек
//---------------------

const _ = require("lodash"); //работа с массивами и коллекциями
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
const PARUS_SESSION_EXPIRED_MESSAGE = "SESSION_EXPIRED"; //код сообщения об истечении сессии ПП Парус 8

//состояния сервиса стенда
const SERVICE_STATE_FREE = "FREE"; //свободен - ожидаем следующего посетителя
const SERVICE_STATE_WAIT_FOR_NOMEN = "WAIT_FOR_NOMEN"; //работаем с посетителем - ожидаем выбора номенклатуры
const SERVICE_STATE_SHIPING = "SHIPING"; //работаетм с посетителем - отгружаем

//описание текущего состояния сервиса стенда
let SERVICE_STATE = {
    SSTATE: SERVICE_STATE_FREE, //текущее состоянияе
    NAGENT: 0, //идентификатор текущего пользователя
    SAGENT_NAME: "" //наименование текущего пользователя
};

//команды HTTP-сервера ПП Парус 8
const PARUS_ACTION_VERIFY = "VERIFY"; //верификация сессии ПП Парус 8
const PARUS_ACTION_DOWNLOAD_GET_URL = "DOWNLOAD_GET_URL"; //подготовка URL для выгрузки файла с сервера ПП Парус 8
const PARUS_ACTION_LOGIN = "LOGIN"; //создание сессии ПП Парус 8
const PARUS_ACTION_LOGOUT = "LOGOUT"; //завершение сессии ПП Парус 8
const PARUS_ACTION_AUTH_BY_BARCODE = "AUTH_BY_BARCODE"; //аутентификация посетителя стенда по штрихкоду
const PARUS_ACTION_LOAD = "LOAD"; //загрузка стенда товаром
const PARUS_ACTION_LOAD_ROLLBACK = "LOAD_ROLLBACK"; //откат последней загрузки стенда товаром
const PARUS_ACTION_SHIPMENT = "SHIPMENT"; //отгрузка товара посетителю
const PARUS_ACTION_SHIPMENT_ROLLBACK = "SHIPMENT_ROLLBACK"; //откат отгрузки товара посетителю
const PARUS_ACTION_PRINT = "PRINT"; //постановка отгрузочного документа в очередь печати
const PARUS_ACTION_PRINT_GET_STATE = "PRINT_GET_STATE"; //получение состояния отчета в очереди печати
const PARUS_ACTION_MSG_INSERT = "MSG_INSERT"; //добавление сообщения в очедерь уведомлений стенда
const PARUS_ACTION_MSG_DELETE = "MSG_DELETE"; //удаление сообщения из очедери уведомлений стенда
const PARUS_ACTION_MSG_SET_STATE = "MSG_SET_STATE"; //установка состояния сообщения в очедери уведомлений стенда
const PARUS_ACTION_MSG_GET_LIST = "MSG_GET_LIST"; //получение списка сообщений очереди уведомлений стенда
const PARUS_ACTION_STAND_GET_STATE = "STAND_GET_STATE"; //получение состояния стенда

//команды сервера приложений
const SERVICE_ACTION_CANCEL_AUTH = "CANCEL_AUTH"; //отмена аутентификации посетителя стенда

//-------
//функции
//-------

//управление состоянием сервиса - переход к состоянию "Свободен"
const srvStateSetFree = () => {
    SERVICE_STATE.SSTATE = SERVICE_STATE_FREE;
    SERVICE_STATE.NAGENT = 0;
    SERVICE_STATE.SAGENT_NAME = "";
};

//управление состоянием сервиса - переход к состоянию "Ожидаем номенклатуру от посетителя"
const srvStateSetWaitForNomen = (customerID, customerName) => {
    SERVICE_STATE.SSTATE = SERVICE_STATE_WAIT_FOR_NOMEN;
    if (customerID) SERVICE_STATE.NAGENT = customerID;
    if (customerName) SERVICE_STATE.SAGENT_NAME = customerName;
};

//управление состоянием сервиса - переход к состоянию "Отгружаем номенклатуру посетителю"
const srvStateSetShiping = () => {
    SERVICE_STATE.SSTATE = SERVICE_STATE_SHIPING;
};

//начало сеанса
const logIn = attempt => {
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
            //если включен режим верификации сесии
            if (conf.SERVER_VERIFY_PARUS_SESSION) {
                //верифицируем специальным запросом на сервер
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
            } else {
                //просто говорим, что сессия есть и не будем ничего верифицировать
                utils.log({ msg: "Session exists (ID: " + PARUS_SESSION + ")." });
                resolve(utils.buildOkResp(PARUS_SESSION));
            }
        }
    });
};

//окончание сеанса
const logOut = () => {
    return new Promise((resolve, reject) => {
        //проверим наличие сессии
        if (!PARUS_SESSION) {
            //её нет - и делать нечего
            utils.log({ msg: "No Parus session to be terminated" });
            srvStateSetFree();
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
                        srvStateSetFree();
                        resolve(utils.buildOkResp("Terminated"));
                    }
                }
            });
        }
    });
};

//получение состояния стенда
const getStandState = prms => {
    return new Promise((resolve, reject) => {
        //исполняем действие на сервере ПП Парус 8
        pc.parusServerAction({
            prms: { SACTION: PARUS_ACTION_STAND_GET_STATE, SSESSION: PARUS_SESSION },
            callBack: resp => {
                //проверим результат выполнения
                if (resp.state == utils.SERVER_STATE_ERR) {
                    //завершение не удалось
                    reject(resp);
                } else {
                    //завершение удалась - ресолвим с успехом, но подмешиваем к состоянию ПП Парус 8 состояние сервиса
                    let tmp = {};
                    _.extend(tmp, resp);
                    tmp.message.SERVICE_STATE = {};
                    _.extend(tmp.message.SERVICE_STATE, SERVICE_STATE);
                    resolve(tmp);
                }
            }
        });
    });
};

//аутентификация пользователя по штрих-коду
const authUserByBarcode = prms => {
    return new Promise((resolve, reject) => {
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
                        //завершение удалась - выставляем состояние сервиса
                        srvStateSetWaitForNomen(resp.message.USER.NAGENT, resp.message.USER.SAGENT_NAME);
                        //ресолвим с успехом
                        resolve(resp);
                    }
                }
            });
        } else {
            reject(utils.buildErrResp("Не указан штрих-код!"));
        }
    });
};

//отмена аутентификации пользователя стенда
const cancelAuth = prms => {
    return new Promise((resolve, reject) => {
        //проверим наличие параметров
        if (prms.customerID) {
            //если указанный идентификатор пользователья стенда соответствует текущему или сейчас на стенде и так никого нет или прилетел спец. код принудительной отмены
            if (
                SERVICE_STATE.NAGENT == 0 ||
                SERVICE_STATE.NAGENT == conf.SERVER_USER_RESET_EMERGENCY_CODE ||
                prms.customerID == SERVICE_STATE.NAGENT
            ) {
                //сбрасываем и
                srvStateSetFree();
                //...ресолвим с успехом
                resolve(utils.buildOkResp("Состояние сервиса сброшено"));
            } else {
                //идентификатор посетителя указан неверно, при вызове данной функции
                reject(utils.buildErrResp("Указан некорректный идентификатор посетителя стенда!"));
            }
        } else {
            reject(utils.buildErrResp("Не указан идентификатор посетителя стенда!"));
        }
    });
};

//загрузка стенда товаром
const load = prms => {
    return new Promise((resolve, reject) => {
        //проверим наличие параметров
        if (prms) {
            //исполняем действие на сервере ПП Парус 8
            pc.parusServerAction({
                prms: {
                    SACTION: PARUS_ACTION_LOAD,
                    SSESSION: PARUS_SESSION,
                    NRACK_LINE: prms.rack_line,
                    NRACK_LINE_CELL: prms.rack_line_cell
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
};

//откат последней загрузки стенда товаром
const loadRollBack = prms => {
    return new Promise((resolve, reject) => {
        //исполняем действие на сервере ПП Парус 8
        pc.parusServerAction({
            prms: {
                SACTION: PARUS_ACTION_LOAD_ROLLBACK,
                SSESSION: PARUS_SESSION
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
    });
};

//отгрузка товара посетителю
const shipment = prms => {
    return new Promise((resolve, reject) => {
        //проверим наличие параметров
        if (prms.customer) {
            if (prms.rack_line) {
                if (prms.rack_line_cell) {
                    //говорим, что отгружаем
                    srvStateSetShiping();
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
                                srvStateSetWaitForNomen();
                                reject(resp);
                            } else {
                                utils.log({
                                    msg: "Shipment document created successfully. Sending command to vending machine..."
                                });
                                let transInvCustID = resp.message;
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
                                                        NTRANSINVCUST: transInvCustID
                                                    },
                                                    callBack: printResp => {
                                                        //протоколируем результат постановки в очередь
                                                        if (printResp.state == utils.SERVER_STATE_ERR) {
                                                            //не поставилось в очередь
                                                            utils.log({
                                                                type: utils.LOG_TYPE_ERR,
                                                                msg:
                                                                    "Error sending document to ptint queue: " +
                                                                    printResp.message
                                                            });
                                                            //даже если документ в очередь не встал - скажем что всё ок (вендинг уже не откатишь), но выдадим специальное сообщение (без упоминания печати накладных)
                                                            resolve(
                                                                utils.buildOkResp({
                                                                    SMSG: utils.SERVER_RE_MSG_SHIPED_NO_PRINT,
                                                                    NTRANSINVCUST: transInvCustID
                                                                })
                                                            );
                                                        } else {
                                                            //поставилось в очередь печати
                                                            utils.log({
                                                                msg: "Document sended to print queue successfully"
                                                            });
                                                            //сделалось всё - и документ, и автомат и печать в очередь
                                                            resolve(
                                                                utils.buildOkResp({
                                                                    SMSG: utils.SERVER_RE_MSG_SHIPED,
                                                                    NTRANSINVCUST: transInvCustID
                                                                })
                                                            );
                                                        }
                                                    }
                                                });
                                            } else {
                                                //скажем что всё ок - нет, значит нет, выдаём специальное сообщение об успехе (без упоминания печати накладных)
                                                utils.log({
                                                    msg: "Document printing disabled"
                                                });
                                                resolve(
                                                    utils.buildOkResp({
                                                        SMSG: utils.SERVER_RE_MSG_SHIPED_NO_PRINT,
                                                        NTRANSINVCUST: transInvCustID
                                                    })
                                                );
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
                                                    NTRANSINVCUST: transInvCustID
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
                                                    //отдаём ошибку вендингового аппарата и возвращаемся к ожиданию номенклатуры
                                                    srvStateSetWaitForNomen();
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
};

//откат отгрузки посетителю стенда
const shipmentRollBack = prms => {
    return new Promise((resolve, reject) => {
        //проверим наличие параметров
        if (prms && prms.documentID) {
            //исполняем действие на сервере ПП Парус 8
            pc.parusServerAction({
                prms: {
                    SACTION: PARUS_ACTION_SHIPMENT_ROLLBACK,
                    SSESSION: PARUS_SESSION,
                    NTRANSINVCUST: prms.documentID
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
};

//получение сообщений из очереди уведомлений стенда
const msgGetList = prms => {
    return new Promise((resolve, reject) => {
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
};

//добавление сообщения в очередь стенда
const msgInsert = prms => {
    return new Promise((resolve, reject) => {
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
};

//удаление сообщения из очереди стенда
const msgDelete = prms => {
    return new Promise((resolve, reject) => {
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
};

//установка статуса сообщения в очереди стенда
const msgSetState = prms => {
    return new Promise((resolve, reject) => {
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
};

//проверка состояния отчета по сообщению очереди уведомлений стенда
const printGetState = prms => {
    return new Promise((resolve, reject) => {
        //проверим наличие параметров
        if (prms && prms.rn) {
            //исполняем действие на сервере ПП Парус 8
            pc.parusServerAction({
                prms: {
                    SACTION: PARUS_ACTION_PRINT_GET_STATE,
                    SSESSION: PARUS_SESSION,
                    NRPTPRTQUEUE: prms.rn
                },
                callBack: resp => {
                    //проверим результат выполнения
                    if (resp.state == utils.SERVER_STATE_ERR) {
                        //завершение не удалось
                        reject(resp);
                    } else {
                        //завершение удалась - ресолвим с успехом, но доработаем URL
                        resp.message.SURL = pc.buildDownloadURL(resp.message.SURL);
                        resolve(resp);
                    }
                }
            });
        } else {
            reject(utils.buildErrResp(utils.SERVER_RE_MSG_BAD_REQUEST));
        }
    });
};

//выгрузка файла
const downloadGetUrl = prms => {
    return new Promise((resolve, reject) => {
        //проверим наличие параметров
        if (prms && prms.fileType && prms.fileRn) {
            //исполняем действие на сервере ПП Парус 8
            pc.parusServerAction({
                prms: {
                    SACTION: PARUS_ACTION_DOWNLOAD_GET_URL,
                    SSESSION: PARUS_SESSION,
                    SFILE_TYPE: prms.fileType,
                    NFILE_RN: prms.fileRn
                },
                callBack: resp => {
                    //проверим результат выполнения
                    if (resp.state == utils.SERVER_STATE_ERR) {
                        //завершение не удалось
                        reject(resp);
                    } else {
                        //завершение удалась - ресолвим с успехом, но доработаем URL
                        resp.message = pc.buildDownloadURL(resp.message);
                        resolve(resp);
                    }
                }
            });
        } else {
            reject(utils.buildErrResp(utils.SERVER_RE_MSG_BAD_REQUEST));
        }
    });
};

//выполнение действия ПП Парус 8
const makeAction = prms => {
    //переопределим себя
    self = this;
    //работаем
    return new Promise((resolve, reject) => {
        //здесь будем хранить функцию исполняющую действие на сервере (должна возвращать Promise)
        let actionFunction;
        //определим функцию исполнения действия
        switch (prms.action) {
            //завершение сеанса
            case PARUS_ACTION_LOGOUT: {
                actionFunction = logOut;
                break;
            }
            //подготовка URL для выгрузки файла с сервера ПП парус 8
            case PARUS_ACTION_DOWNLOAD_GET_URL: {
                actionFunction = downloadGetUrl;
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
            //отмена аутентификации посетителя стенда
            case SERVICE_ACTION_CANCEL_AUTH: {
                actionFunction = cancelAuth;
                break;
            }
            //загрузка стенда товаром
            case PARUS_ACTION_LOAD: {
                actionFunction = load;
                break;
            }
            //откат последней загрузки стенда товаром
            case PARUS_ACTION_LOAD_ROLLBACK: {
                actionFunction = loadRollBack;
                break;
            }
            //отгрузка товара посетителю
            case PARUS_ACTION_SHIPMENT: {
                actionFunction = shipment;
                break;
            }
            //откат отгрузки товара посетителю
            case PARUS_ACTION_SHIPMENT_ROLLBACK: {
                actionFunction = shipmentRollBack;
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
            //проверка состояния отчета по позиции очереди уведомлений стенда
            case PARUS_ACTION_PRINT_GET_STATE: {
                actionFunction = printGetState;
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
                        //сессия ПП Парус 8- ОК, можно выполнять функцию-действие ПП Парус 8
                        .then(r => {
                            utils.log({ msg: "Executing Parus action '" + prms.action + "'" });
                            return actionFunction(prms);
                        })
                        //здесь перехватываем результаты функции-действия ПП Парус 8 (всегда ресолвим, что бы наш сервис всегда отдавал ответ, положительный или отрицательный)
                        .then(r => {
                            utils.log({ msg: "Done!" });
                            resolve(r);
                        })
                        //отлов ошибок
                        .catch(e => {
                            utils.log({ type: utils.LOG_TYPE_ERR, msg: "Execution error: " + e.message });
                            //если ошибка связана с тем, что сессия истекла
                            if (e.message == PARUS_SESSION_EXPIRED_MESSAGE) {
                                //сбросим сессию сервера приложений
                                PARUS_SESSION = "";
                                //и попробуем ещё раз - это нас перелогинит и выполнит запрос повторно
                                self.makeAction(prms).then(r => resolve(r), er => resolve(er));
                            } else {
                                //просто другая ошибка - отдаём что есть клиенту
                                if (e instanceof Error) {
                                    resolve(utils.buildErrResp("Внутренняя ошибка сервера приложений: " + e.message));
                                } else {
                                    resolve(e);
                                }
                            }
                        })
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
};

//----------------
//интерфейс модуля
//----------------

exports.PARUS_SESSION_EXPIRED_MESSAGE = PARUS_SESSION_EXPIRED_MESSAGE;
exports.PARUS_ACTION_VERIFY = PARUS_ACTION_VERIFY;
exports.PARUS_ACTION_DOWNLOAD_GET_URL = PARUS_ACTION_DOWNLOAD_GET_URL;
exports.PARUS_ACTION_LOGIN = PARUS_ACTION_LOGIN;
exports.PARUS_ACTION_LOGOUT = PARUS_ACTION_LOGOUT;
exports.PARUS_ACTION_AUTH_BY_BARCODE = PARUS_ACTION_AUTH_BY_BARCODE;
exports.PARUS_ACTION_LOAD = PARUS_ACTION_LOAD;
exports.PARUS_ACTION_LOAD_ROLLBACK = PARUS_ACTION_LOAD_ROLLBACK;
exports.PARUS_ACTION_SHIPMENT = PARUS_ACTION_SHIPMENT;
exports.PARUS_ACTION_SHIPMENT_ROLLBACK = PARUS_ACTION_SHIPMENT_ROLLBACK;
exports.PARUS_ACTION_PRINT = PARUS_ACTION_PRINT;
exports.PARUS_ACTION_PRINT_GET_STATE = PARUS_ACTION_PRINT_GET_STATE;
exports.PARUS_ACTION_MSG_INSERT = PARUS_ACTION_MSG_INSERT;
exports.PARUS_ACTION_MSG_DELETE = PARUS_ACTION_MSG_DELETE;
exports.PARUS_ACTION_MSG_SET_STATE = PARUS_ACTION_MSG_SET_STATE;
exports.PARUS_ACTION_MSG_GET_LIST = PARUS_ACTION_MSG_GET_LIST;
exports.PARUS_ACTION_STAND_GET_STATE = PARUS_ACTION_STAND_GET_STATE;
exports.SERVICE_ACTION_CANCEL_AUTH = SERVICE_ACTION_CANCEL_AUTH;
exports.makeAction = makeAction;
