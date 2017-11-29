/*
    Оповещение о событиях стенда (Telegram)
    Обработчик сообщений
*/

//-----------------------------
//подключение внешних библиотек
//-----------------------------

const _ = require("lodash"); //работа с массивами и коллекциями
const fs = require("fs"); //работа с файловой системой
const EventEmitter = require("events"); //обработчик пользовательских событий
const utils = require("./utils"); //утилиты сервиса
const commands = require("./commands"); //настройки сценариев отработки команд
const config = require("./config"); //настройки приложения

//-------------------------
//глобальные идентификаторы
//-------------------------

//типовые события
const EVT_NEW_RESPOND = "new_respond"; //готов очередной ответ бота

//состояния чата
const CHAT_STATE_WAIT_FOR_COMMAND = "wait_for_command"; //жду комманду
const CHAT_STATE_WAIT_FOR_COMMAND_STEP = "wait_for_command_step"; //жду дополнительных параметров команды
const CHAT_STATE_PROCESSING_COMMAND = "processing_command"; //обрабатываю команду

//---------------------------
//класс обработчика сообщений
//---------------------------

class MessageProcessor extends EventEmitter {
    //конструктор класса
    constructor() {
        //создадим экземпляр родительского класса
        super();
        //состояния чатов, ведущихся ботом
        this.botState = [];
    }

    //отправка ответного сообщения на обрабатываемое
    sendRespond(outMsg) {
        //оповестим подписчиков о появлении результата обработки
        this.emit(EVT_NEW_RESPOND, outMsg);
    }

    //модель состояния чата
    initChatState(chatID) {
        return {
            chatID: chatID, //идентификатор чата
            state: CHAT_STATE_WAIT_FOR_COMMAND, //текущее состояние чата
            currentCommand: "" //текущая отрабатываемая команда
        };
    }

    //сохранение состояния чата
    saveChatsStateSync() {
        utils.log("Saving " + this.botState.length + " chats states to " + config.SATE_FILE + "...");
        //пишем на диск
        try {
            fs.writeFileSync(config.SATE_FILE, JSON.stringify(this.botState));
            utils.log("Done!");
        } catch (e) {
            utils.log("Saving state error: " + e.message);
        }
    }

    //считывание состояния чата
    loadChatsStateSync() {
        utils.log("Loading state from " + config.SATE_FILE + " ...");
        //формируем ответ
        try {
            //читаем с диска
            this.botState = JSON.parse(fs.readFileSync(config.SATE_FILE));
            utils.log("Done, " + this.botState.length + " chats loaded!");
        } catch (e) {
            utils.log("Loading state error: " + e.message);
        }
    }

    //получение состояния чата
    getChatState(chatID) {
        let chatState = _.find(this.botState, { chatID: chatID });
        if (!chatState) {
            this.botState.push(this.initChatState(chatID));
            return _.find(this.botState, { chatID: chatID });
        } else {
            return chatState;
        }
    }

    //получение состояния бота
    getBotState() {
        return this.botState;
    }

    //установка состояния чата - начало обработки команды
    setChatStateCommandBegin(chatState, command) {
        chatState.state = CHAT_STATE_PROCESSING_COMMAND;
        chatState.currentCommand = command;
    }

    //установка состояния чата - завершение обработки команды
    setChatStateCommandFinish(chatState) {
        chatState.state = CHAT_STATE_WAIT_FOR_COMMAND;
        chatState.currentCommand = "";
    }

    //обработка команды, послупившей от пользователя
    processCommand(chatState, parsedMessage) {
        //переопределим себя
        let self = this;
        //попробуем найти её среди сценариев и исполнить
        let cmd = _.find(commands.SCENARIO, {
            command: chatState.state == CHAT_STATE_WAIT_FOR_COMMAND ? parsedMessage.command : chatState.currentCommand
        });
        //если не нашили её среди команд, поддерживаемых ботом
        if (!cmd) {
            //отдаем ответ о том, что для команды нет обработчика
            self.sendRespond(
                commands.createResp(commands.PRC_STATE_OK, parsedMessage.chatID, commands.CMDS_MSG_NO_COMMAND)
            );
        } else {
            //скажем, что команда начала исполняться
            self.setChatStateCommandBegin(chatState, parsedMessage.command);
            //исполним обработчик (он всегда есть у команды)
            cmd.processor({ chatState: chatState, message: parsedMessage }).then(
                response => {
                    //всё ок - скажем что завершили исполнение команды
                    this.setChatStateCommandFinish(chatState);
                    //поместим ответ в очередь исходящих
                    self.sendRespond(response);
                },
                err => {
                    //ошибка исполнения - всё равно завершили исполнение
                    self.setChatStateCommandFinish(chatState);
                    //сообщим об ошибке
                    self.sendRespond(
                        commands.createResp(
                            commands.PRC_STATE_ERR,
                            parsedMessage.chatID,
                            commands.CMDS_MSG_COMMON_ERROR_TITLE + " " + err.message
                        )
                    );
                }
            );
        }
    }

    //обработка входящего сообщения
    processMessage(msg) {
        //переопределим себя
        let self = this;
        //разберем сообщение
        let m = utils.parseMessage(msg);
        try {
            //найдем состояние этого чата (или добавим в стэк состояний, если это какой-то новый чат)
            let chatState = self.getChatState(m.chatID);
            //если мы ждали команду и она пришла
            if (chatState.state == CHAT_STATE_WAIT_FOR_COMMAND && m.isCommand) {
                //выполним обработку команды
                this.processCommand(chatState, m);
            } else {
                //если мы ждали команду, но пришла не она
                if (chatState.state == CHAT_STATE_WAIT_FOR_COMMAND && !m.isCommand) {
                    //пришла не команда - скажем пользователю про это
                    self.sendRespond(
                        commands.createResp(commands.PRC_STATE_OK, m.chatID, commands.CMDS_MSG_NOT_A_COMMAND)
                    );
                }
                //если мы сейчас обрабатываем команду, то надо предупреридить об этом пользоватля
                if (chatState.state == CHAT_STATE_PROCESSING_COMMAND) {
                    //скажем пользователю, что бот занят его предыдущим запросом
                    let cmd = _.find(commands.SCENARIO, { command: chatState.currentCommand });
                    self.sendRespond(
                        commands.createResp(
                            commands.PRC_STATE_OK,
                            m.chatID,
                            commands.CMDS_MSG_BUSY +
                                (cmd ? utils.EOL + ' (обрабатывается команда "' + cmd.command + '")' : "")
                        )
                    );
                }
            }
        } catch (e) {
            //отдадим ошибку в чат
            self.sendRespond(commands.createResp(commands.PRC_STATE_ERR, m.chatID, e.message));
        }
    }
}

//----------------
//интерфейс модуля
//----------------

//состояния чата
exports.EVT_NEW_RESPOND = EVT_NEW_RESPOND;
exports.CHAT_STATE_WAIT_FOR_COMMAND = CHAT_STATE_WAIT_FOR_COMMAND;
exports.CHAT_STATE_WAIT_FOR_COMMAND_STEP = CHAT_STATE_WAIT_FOR_COMMAND_STEP;
exports.CHAT_STATE_PROCESSING_COMMAND = CHAT_STATE_PROCESSING_COMMAND;
exports.MessageProcessor = MessageProcessor;
