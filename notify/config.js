/*
    Оповещение о событиях стенда (Telegram)
    Настройки
*/

//----------------
//интерфейс модуля
//----------------

//общесистемные
exports.DEBUG = true; //режим отладки
exports.BOT_TOKEN = "476700469:AAF-Q9C23Bl4odNZRAA4kceXI7fGbFu8DKA"; //уникальный идентификатор бота
exports.BOT_USERNAME = "citk_parus_stand_bot"; //имя пользователя бота
exports.OUT_SEND_DELAY = 1; //интервал опроса очереди исходящих сообщений (мс)
exports.NOTIFY_CHECK_DELAY = 1000; //интервал опроса очереди уведомлений стенда (мс)
exports.SATE_FILE = "c:\\repos\\temp\\citk_parus_stand_bot_state.dat"; //файл для хранения состояния чатов

//подключение к серверу стенда
exports.SERVER_URL = "http://localhost:3030"; //адрес сервера
exports.CLIENT_NAME = "CITK Demo Stand Notify Service/0.0.1"; //наименование клиента
exports.CLIENT_TOKEN = "76433e4e-ed7b-49e2-9497-dc4c66483e9e"; //токен доступа
