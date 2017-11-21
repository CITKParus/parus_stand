/*
    Обработка очереди печати стенда
    Работа с устройством печати - выгрузка готовых отчетов с сервера, поставновка в очередь принтера
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const _ = require("lodash"); //работа с массивами и коллекциями
const conf = require("./config"); //константы и настройки
const client = require("./client"); //клиент для взаимодействия с сервером стенда

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
        //создадим экземпляр родительского класса
        super();
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
