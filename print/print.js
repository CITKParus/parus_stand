/*
	Обработка очереди печати стенда
	Главный модуль
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const conf = require("./config"); //настройки
const pq = require("./print_queue"); //очередь печати

//-----------
//точка входа
//-----------

//запуск процесса
function run() {
    //очередь оповещений для рассылки
    let pQ = new pq.PrintQueue();
    //запуск - обрабатываем очередь печати
    pQ.startProcessing();
    pQ.on(pq.EVT_NEW_REPORT_READY, report => {
        console.log("NEW REPORT FOR DOWNLOAD: " + report.SURL);
    });
}

//старутем
run();
