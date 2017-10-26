/*
    Оповещение о событиях стенда (Telegram)
    Обработчик очереди исходящих сообщений
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const _ = require("lodash"); //работа с массивами и коллекциями
const utils = require("./utils"); //вспомогательные функции

//-------------------------
//глобальные идентификаторы
//-------------------------

//состояния сообщений в очереди
const MSG_STATE_ADDED = "added"; //добавлено в очередь на отправку
const MSG_STATE_SENDING = "sending"; //отправляется
const MSG_STATE_SEND = "send"; //отправлено
const MSG_STATE_ERROR = "error"; //ошибка отправки

//типовые ответы очереди обработки исходящих сообщений
const OUT_MSG_NO_BOT = "Нет объекта бота для обработки сообщений!"; //отсуствует объект API-бота
const OUT_MSG_BAD_MESSAGE_FORMAT = "Некорректно указаны параметры отправляемого сообщения!"; //ошибка формата исходящего сообщения

//---------------------------------
//класс очереди исходящих сообщений
//---------------------------------

class Outgoing {
    //конструктор класса
    constructor(options) {
        //хранилище очереди
        this.outMessages = [];
        //признак функционирования обработчика
        this.isProcessing = false;
        //опции, если есть
        if (options) {
            //ссылка на API бота
            this.bot = options.bot;
            //время ожидания перед отправкой очередного сообщения
            this.sendDelay = options.sendDelay;
        } else {
            //параметры по умолчанию
            this.bot = null;
            this.sendDelay = 1;
        }
    }

    //добавление нового исходящего сообщения в очередь
    addMessage(msg) {
        //создадим новый элемент очереди
        let tmp = {
            state: MSG_STATE_ADDED, //состояние сообщения (отправлено успешно, ошибка отправки, добавлено)
            sendErr: "", //ошибка отправки
            msg: {} //отправляемое сообщение
        };
        _.extend(tmp.msg, msg);
        //добавим его в очередь
        this.outMessages.push(tmp);
    }

    //обработка элемента очереди
    sendMessage(prms) {
        //переопределим себя
        let self = this;
        //создаем промис отправки сообщения
        return new Promise((resolve, reject) => {
            //если бот есть - значит есть кому отправить
            if (self.bot) {
                if (prms && prms.msg && prms.msg.chatID && prms.msg.message && prms.msg.options) {
                    self.bot.sendMessage(prms.msg.chatID, prms.msg.message.substr(0, 4095), prms.msg.options).then(
                        response => {
                            resolve(null);
                        },
                        err => {
                            reject(err);
                        }
                    );
                } else {
                    reject(OUT_MSG_BAD_MESSAGE_FORMAT);
                }
            } else {
                reject(OUT_MSG_NO_BOT);
            }
        });
    }

    //обработка очереди исходящих сообщений
    sendingLoop() {
        //переопределим себя
        let self = this;
        //найдем очередное сообщение для обработки
        let outMessagesItem = _.find(self.outMessages, { state: MSG_STATE_ADDED });
        //если что-то нашли для отправки
        if (outMessagesItem) {
            //скажем, что сообщение в обработке
            outMessagesItem.state = MSG_STATE_SENDING;
            //обработаем то что нашли
            self.sendMessage({ msg: outMessagesItem.msg }).then(
                response => {
                    //установим статус сообщения - отправили
                    outMessagesItem.state = MSG_STATE_SEND;
                    //перезапустим отправку
                    if (self.isProcessing)
                        setTimeout(() => {
                            self.sendingLoop();
                        }, self.sendDelay);
                },
                err => {
                    //установим статус сообщения - ошибка отправки
                    outMessagesItem.state = MSG_STATE_ERROR;
                    outMessagesItem.sendErr = err;
                    utils.log(err);
                    //перезапустим отправку
                    if (self.isProcessing)
                        setTimeout(() => {
                            self.sendingLoop();
                        }, self.sendDelay);
                }
            );
        } else {
            //отправлять нечего - просто перезапустим отправку
            if (self.isProcessing)
                setTimeout(() => {
                    self.sendingLoop();
                }, self.sendDelay);
        }
    }

    //запуск обработки очереди исходящих сообщений
    startSending() {
        this.isProcessing = true;
        this.sendingLoop();
    }

    //остановка обработки очереди исходящих сообщений
    stopSending() {
        this.isProcessing = false;
    }
}

//----------------
//интерфейс модуля
//----------------

exports.MSG_STATE_ADDED = MSG_STATE_ADDED;
exports.MSG_STATE_SENDING = MSG_STATE_SENDING;
exports.MSG_STATE_SEND = MSG_STATE_SEND;
exports.MSG_STATE_ERROR = MSG_STATE_ERROR;
exports.OUT_MSG_NO_BOT = OUT_MSG_NO_BOT;
exports.OUT_MSG_BAD_MESSAGE_FORMAT = OUT_MSG_BAD_MESSAGE_FORMAT;
exports.Outgoing = Outgoing;
