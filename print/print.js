/*
	Обработка очереди печати стенда
	Главный модуль
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const conf = require("./config"); //настройки
const pq = require("./print_queue"); //очередь печати сервера
const dpq = require("./device_print_queue"); //очередь печати принтера

//-----------
//точка входа
//-----------

//запуск процесса
function run() {
    //создам экземпляр очереди печати сервера
    let pQ = new pq.PrintQueue();
    //создадим экземпляр очереди печати принтера
    let dPQ = new dpq.DevicePrintQueue();
    //запускаем обработку очереди печати принтера
    dPQ.startProcessing();
    //запускаем обрабатку очереди печати сервера
    pQ.startProcessing();
    pQ.on(pq.EVT_NEW_REPORT_READY, report => {
        dPQ.addReport(report);
    });
}

//старутем
run();
