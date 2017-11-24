/*
    Обработка очереди печати стенда
    Работа с устройством печати - выгрузка готовых отчетов с сервера, поставновка в очередь принтера
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const child_process = require("child_process"); //запуск дочерних процессов в ОС
const _ = require("lodash"); //работа с массивами и коллекциями
const conf = require("./config"); //константы и настройки
const client = require("./client"); //клиент для взаимодействия с сервером стенда
const utils = require("./utils"); //вспомогательные функции

//-------------------------
//глобальные идентификаторы
//-------------------------

//состояния файлов в очереди печати
const FILE_STATE_ADDED = "added"; //файл добавлен в очередь на отправку устройству печати
const FILE_STATE_PRINTING = "printing"; //отчет отправляется на устройство печати
const FILE_STATE_DONE = "done"; //отправлен на устройство печати
const FILE_STATE_ERROR = "error"; //ошибка отправки на устройство печати

//-------------------------------
//класс очереди устройства печати
//-------------------------------

class DevicePrintQueue {
    //конструктор класса
    constructor(options) {
        //хранилище очереди заказанных файлов
        this.reports = [];
        //признак функционирования обработчика
        this.isWorking = false;
    }

    //добавление готового отчета в очередь для отправки устройству печати
    addReport(rpt) {
        //создадим новый элемент очереди
        let tmp = {
            state: FILE_STATE_ADDED, //состояние отчета (добавлен в очередь на отправку, отправляется на устройство печати, отправлен)
            err: "", //сообщение об ошибке отправки устройству печати
            rpt: {} //данные отчета из очереди сервера
        };
        _.extend(tmp.rpt, rpt);
        //добавим его в очередь
        this.reports.push(tmp);
    }

    //перезапуск отправки на устройство печати
    restartPrinterLoop() {
        if (this.isWorking)
            setTimeout(() => {
                this.printerLoop();
            }, conf.PRINT_CHECK_DELAY);
    }

    //отправка файла на принтер
    sendFileToPrinter(fileName) {
        return new Promise(function(resolve, reject) {
            if (fileName && fileName != "") {
                const sp = child_process.spawn(conf.POWER_SHELL, ["-File", conf.PRINTER_SCRIPT, fileName]);
                sp.on("error", err => {
                    reject(client.buildErrResp(err.message));
                });
                sp.on("close", code => {
                    if (code == 1) {
                        reject(client.buildErrResp("Finished with error code: " + code));
                    } else {
                        resolve(client.buildOkResp(code));
                    }
                });
            } else {
                reject(client.buildErrResp("No file specified!"));
            }
        });
    }

    //отработка очереди отправляемых на устройство печати отчетов
    printerLoop() {
        //переопределим себя
        let self = this;
        //найдем очередной отчет для обработки
        let reportItem = _.find(self.reports, { state: FILE_STATE_ADDED });
        //если что-то нашли для обработки
        if (reportItem) {
            //скажем, что отчет в обработке
            reportItem.state = FILE_STATE_PRINTING;
            //скачиваем готовый файл
            utils.log("Downloading report (RN: " + reportItem.rpt.NRN + ")...");
            client
                .downloadFile(reportItem.rpt.SFILE_NAME, reportItem.rpt.SURL)
                .then(r => {
                    //файл успешно выгружен
                    utils.log("Downloaded in " + r.message + " Sending to printer...");
                    //отправляем его на принтер
                    return self.sendFileToPrinter(r.message);
                })
                .then(r => {
                    //скажем, что отчет распечатан
                    reportItem.state = FILE_STATE_DONE;
                    utils.log("Successfully send to printer!");
                    //перезапустим проверку очереди
                    self.restartPrinterLoop();
                })
                .catch(e => {
                    //скажем, что есть ошибка при обработке отчета
                    reportItem.state = FILE_STATE_ERROR;
                    reportItem.err = e.message;
                    utils.log("Error: " + e.message);
                    //перезапустим проверку очереди
                    self.restartPrinterLoop();
                });
        } else {
            //нет отчетов для обработки - просто перезапустим проверку очереди
            self.restartPrinterLoop();
        }
    }

    //запуск обработки очереди устройства
    startProcessing() {
        utils.log("Starting printer queue processor...");
        this.isWorking = true;
        this.printerLoop();
        utils.log("Done.");
    }

    //остановка обработки очереди устройства
    stopProcessing() {
        utils.log("Stopping printer queue processor...");
        this.isWorking = false;
        utils.log("Done.");
    }
}

//----------------
//интерфейс модуля
//----------------

exports.DevicePrintQueue = DevicePrintQueue;
