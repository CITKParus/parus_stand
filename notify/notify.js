/*
	Оповещение о событиях стенда (Telegram)
	Главный модуль
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const TelegramBot = require("node-telegram-bot-api"); //API Telegram Bot
const conf = require("./config"); //настройки
const inc = require("./incoming"); //очередь входящих сообщений
const out = require("./outgoing"); //очередь исходящих сообщений
const prc = require("./message_processor"); //обработчик сообщений
//const NotifyQueue = require("./notify_queue"); //очередь оповещений для рассылки

//-----------
//точка входа
//-----------

//запуск процесса
function run() {
    //API бота
    let bot = new TelegramBot(conf.BOT_TOKEN, { polling: true });
    //очередь входящих сообщений
    let inQ = new inc.Incoming({ bot: bot });
    //очередь исходящих сообщений
    let outQ = new out.Outgoing({ bot: bot, sendDelay: conf.OUT_SEND_DELAY });
    //очередь оповещений для рассылки
    //let nQ = new NotifyQueue();
    //обработчик входящих сообщений	- ядро бота
    let proc = new prc.MessageProcessor();
    //запуск бота - обрабатываем входящие, даём ответы на запросы, проверяем очередь заказанных отчетов на их готовность
    inQ.startListen();
    outQ.startSending();
    //Q.startProcessing();
    inQ.on(inc.EVT_NEW_IN_MESSAGE, inMsg => {
        process.nextTick(() => {
            proc.processMessage(inMsg);
        });
    });
    //nQ.on(conf.EVT_NEW_RESPOND, outMsg => {
    //    outQ.addMessage(outMsg);
    //});
    proc.on(prc.EVT_NEW_RESPOND, outMsg => {
        outQ.addMessage(outMsg);
    });
}

//старутем
run();
