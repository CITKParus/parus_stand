/*
    Оповещение о событиях стенда (Telegram)
    Обработчик очереди уведомительных сообщений стенда - проверяет статусы уведомлений на сервере,
    отдаёт боту на рассылку те из них, которые ещё не были отправлены
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const _ = require("lodash"); //работа с массивами и коллекциями
const EventEmitter = require("events"); //обработчик пользовательских событий
const conf = require("./config"); //константы и настройки
const client = require("./client"); //клиент для взаимодействия с сервером стенда
const utils = require("./utils"); //вспомогательные функции
const commands = require("./commands"); //настройки сценариев отработки команд

//-------------------------
//глобальные идентификаторы
//-------------------------

//типовые события
const EVT_NEW_OUT_MESSAGE = "new_out_message"; //новое сообщение для отправки

//--------------------------------
//класс очереди уведомлений стенда
//--------------------------------

class NotifyQueue extends EventEmitter {
    //конструктор класса
    constructor(options) {
        //создадим экземпляр родительского класса
        super();
        //признак функционирования обработчика
        this.isProcessing = false;
    }

    //отправка сообщения с уведомлением от стенда
    sendRespond(outMsg) {
        //оповестим подписчиков о появлении нового сообщения для рассылки
        this.emit(EVT_NEW_OUT_MESSAGE, outMsg);
    }

    //перезапуск формирования очереди уведомлений на отправку
    restartProcessingLoop() {
        if (this.isProcessing)
            setTimeout(() => {
                this.notifyProcessingLoop();
            }, conf.NOTIFY_CHECK_DELAY);
    }

    //формирование очереди уведомлений на отправку
    notifyProcessingLoop() {
        //переопределим себя
        let self = this;
        //сходим на сервер за очередным сообщением
        client
            .standServerAction({
                actionData: {
                    action: client.SERVER_ACTION_MSG_GET_LIST,
                    type: client.SERVER_MSG_TYPE_NOTIFY,
                    state: client.SERVER_MSG_STATE_NOT_SENDED,
                    limit: 1,
                    order: client.SERVER_MSG_ORDER_OLD_FIRST
                }
            })
            .then(
                r => {
                    //сервер вернул ответ на запрос нового уведомления - разбираем
                    if (r.state == client.SERVER_STATE_ERR) {
                        //сервер вернул ошибку
                        utils.log("Server returned error while reading new message: " + r.message);
                        self.restartProcessingLoop();
                    } else {
                        //сервер вернул данные уведомления - поставим его в очередь на отправку
                        if (r.message && Array.isArray(r.message) && r.message.length > 0) {
                            try {
                                utils.log("Have new message (NRN: " + r.message[0].NRN + "). Sending to out queue...");
                                let messageText = r.message[0].SMSG.SMSG;
                                if (r.message[0].SMSG.SNOTIFY_TYPE == client.SERVER_MSG_NOTIFY_WARN)
                                    messageText = "<i>Предупреждение: " + messageText + "</i>";
                                if (r.message[0].SMSG.SNOTIFY_TYPE == client.SERVER_MSG_NOTIFY_ERROR)
                                    messageText = "<b>Критическое сообщение: " + messageText + "</b>";
                                self.sendRespond(
                                    commands.createResp(
                                        commands.PRC_STATE_OK,
                                        commands.BROADCAST_CHAT_ID,
                                        messageText,
                                        {
                                            parse_mode: "HTML"
                                        }
                                    )
                                );
                                utils.log("Done. Setting server status to " + client.SERVER_MSG_STATE_SENDED + "...");
                                //отметим на стенде, что уведомление отослано
                                client
                                    .standServerAction({
                                        actionData: {
                                            action: client.SERVER_ACTION_MSG_SET_STATE,
                                            rn: r.message[0].NRN,
                                            state: client.SERVER_MSG_STATE_SENDED
                                        }
                                    })
                                    .then(
                                        rS => {
                                            //сервер вернул ответ на установку статуса уведомления - разбираем
                                            if (rS.state == client.SERVER_STATE_ERR) {
                                                //сервер вернул ошибку
                                                utils.log(
                                                    "Server returned error while setting message (" +
                                                        r.message[0].NRN +
                                                        ") state: " +
                                                        rS.message
                                                );
                                            } else {
                                                utils.log("Done!");
                                            }
                                            // просто перезапустим цикл прослушки в любом случае
                                            self.restartProcessingLoop();
                                        },
                                        eS => {
                                            //при установке состояния уведомления сервера произошла ошибка
                                            utils.log(
                                                "Server error while setting message (" +
                                                    r.message[0].NRN +
                                                    ") state: " +
                                                    eS.message
                                            );
                                            self.restartProcessingLoop();
                                        }
                                    );
                            } catch (e) {
                                //неверный формат сообщения
                                utils.log(["Recived message has wrong format: ", JSON.stringify(r)]);
                                self.restartProcessingLoop();
                            }
                        } else {
                            //просто нет новых сообщений - ждём дальше
                            self.restartProcessingLoop();
                        }
                    }
                },
                e => {
                    //при получении уведомления с сервера произошла ошибка
                    utils.log("Server error while readind new message: " + e.message);
                    self.restartProcessingLoop();
                }
            );
    }

    //запуск обработки очереди уведомлений
    startProcessing() {
        this.isProcessing = true;
        this.notifyProcessingLoop();
    }

    //остановка обработки очереди уведомлений
    stopProcessing() {
        this.isProcessing = false;
    }
}

//----------------
//интерфейс модуля
//----------------

exports.EVT_NEW_OUT_MESSAGE = EVT_NEW_OUT_MESSAGE;
exports.NotifyQueue = NotifyQueue;
