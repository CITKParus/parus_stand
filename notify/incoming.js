/*
    Оповещение о событиях стенда (Telegram)
    Обработчик очереди входящих сообщений
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const _ = require("lodash"); //работа с массивами и коллекциями
const EventEmitter = require("events"); //обработчик пользовательских событий
const utils = require("./utils"); //утилиты бота

//-------------------------
//глобальные идентификаторы
//-------------------------

//типовые события
const EVT_NEW_IN_MESSAGE = "new_in_message"; //новое входящее сообщение

//--------------------------------
//класс очереди входящих сообщений
//--------------------------------

class Incoming extends EventEmitter {
    //конструктор класса
    constructor(options) {
        //создадим экземпляр родительского класса
        super();
        //хранилище очереди
        this.inMessages = [];
        //ссылка на API бота
        if (options) {
            this.bot = options.bot;
        }
    }

    //добавление нового сообщения в очередь
    addMessage(msg) {
        //создадим новый эсземпляр сообщения
        let tmp = {};
        _.extend(tmp, msg);
        //добавим в очередь входящих
        this.inMessages.push(tmp);
        //оповестим подписчиков, что пришло новое сообщение
        this.emit(EVT_NEW_IN_MESSAGE, tmp);
    }

    //запуск прослушивания входящих сообщений
    startListen() {
        //переопределим себя
        let self = this;
        //если бот есть - значит есть кому слушать
        if (self.bot) {
            //реакция на входящие текстовые сообщения
            self.bot.on("text", msg => {
                //в очередь
                utils.log(["Incomming message:", msg, ""]);
                self.addMessage(msg);
            });
        }
    }
}

//----------------
//интерфейс модуля
//----------------

exports.EVT_NEW_IN_MESSAGE = EVT_NEW_IN_MESSAGE;
exports.Incoming = Incoming;
