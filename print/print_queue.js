/*
    Обработка очереди печати стенда
    Обработчик очереди печати - проверяет статусы отчетов на сервере,
    оповещает подписчиков о готовности отчетов
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const _ = require("lodash"); //работа с массивами и коллекциями
const EventEmitter = require("events"); //обработчик пользовательских событий
const conf = require("./config"); //константы и настройки
const client = require("./client"); //клиент для взаимодействия с сервером стенда
const utils = require("./utils"); //вспомогательные функции

//-------------------------
//глобальные идентификаторы
//-------------------------

//типовые события
const EVT_NEW_REPORT_READY = "new_report_ready"; //новое сообщение для отправки

//состояния отчетов в очереди
const RPT_STATE_ADDED = "added"; //отчет добавлен в очередь
const RPT_STATE_CHECKING = "checking"; //проводится проверка состояния отчета
const RPT_STATE_DONE = "done"; //проверен
const RPT_STATE_ERROR = "error"; //ошибка проверки состояния отчета

//--------------------------------
//класс очереди уведомлений стенда
//--------------------------------

class PrintQueue extends EventEmitter {
    //конструктор класса
    constructor(options) {
        //создадим экземпляр родительского класса
        super();
        //хранилище очереди заказанных отчетов
        this.reports = [];
        //признак функционирования обработчика
        this.isWorking = false;
    }

    //добавление нового заказанного отчета в очередь для отслеживания готовности
    addReport(rpt) {
        //создадим новый элемент очереди
        let tmp = {
            state: RPT_STATE_ADDED, //состояние отчета (добавлен в очередь, проверяется, проверен)
            err: "", //сообщение об ошибке проверки состояния отчета
            rpt: {} //заказанный отчет
        };
        _.extend(tmp.rpt, rpt);
        //добавим его в очередь
        this.reports.push(tmp);
    }

    //уведомление о готовности к печати нового отчета
    notifyNewReportReady(report) {
        //оповестим подписчиков о появлении нового отчета
        this.emit(EVT_NEW_REPORT_READY, report);
    }

    //перезапуск формирования очереди отслеживаемых отчетов
    restartDetectingLoop() {
        if (this.isWorking)
            setTimeout(() => {
                this.printDetectingLoop();
            }, conf.PRINT_CHECK_DELAY);
    }

    //формирование очереди отслеживаемых отчетов
    printDetectingLoop() {
        //переопределим себя
        let self = this;
        //сходим на сервер за очередным поставленным в очередь отчетом
        client
            .standServerAction({
                actionData: {
                    action: client.SERVER_ACTION_MSG_GET_LIST,
                    type: client.SERVER_MSG_TYPE_PRINT,
                    state: client.SERVER_MSG_STATE_NOT_PRINTED,
                    limit: 1,
                    order: client.SERVER_MSG_ORDER_OLD_FIRST
                }
            })
            .then(
                r => {
                    //сервер вернул ответ на запрос нового отчета - разбираем
                    if (r.state == client.SERVER_STATE_ERR) {
                        //сервер вернул ошибку
                        utils.log("Server returned error while reading new report queue item: " + r.message);
                        self.restartDetectingLoop();
                    } else {
                        //сервер вернул данные отчета - поставим его в очередь на отслеживание готовности
                        if (r.message && Array.isArray(r.message) && r.message.length > 0) {
                            let tmp = {
                                messageID: r.message[0].NRN,
                                reportID: r.message[0].SMSG
                            };
                            let rptQ = _.find(self.reports, { rpt: { reportID: tmp.reportID } });
                            if (!rptQ) {
                                try {
                                    utils.log("Have new report (NRN: " + tmp.reportID + "). Sending to check queue...");
                                    self.addReport(tmp);
                                    utils.log("Done.");
                                } catch (e) {
                                    //неверный формат сообщения
                                    utils.log(["Recived message has wrong format: ", JSON.stringify(r)]);
                                }
                            }
                            //перезапустим проверку очереди уведомлений об отчетах на сервере
                            self.restartDetectingLoop();
                        } else {
                            //просто нет новых отчетов - ждём дальше
                            self.restartDetectingLoop();
                        }
                    }
                },
                e => {
                    //при получении уведомления с сервера произошла ошибка
                    utils.log("Server error while readind new message: " + e.message);
                    self.restartDetectingLoop();
                }
            );
    }

    //запуск обработки очереди уведомлений
    startProcessing() {
        utils.log("Starting print queue detector...");
        this.isWorking = true;
        this.printDetectingLoop();
        utils.log("Done.");
    }

    //остановка обработки очереди уведомлений
    stopProcessing() {
        utils.log("Stopping print queue detector...");
        this.isWorking = false;
        utils.log("Done.");
    }
}

//----------------
//интерфейс модуля
//----------------

exports.EVT_NEW_REPORT_READY = EVT_NEW_REPORT_READY;
exports.PrintQueue = PrintQueue;
