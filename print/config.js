/*
    Обработка очереди печати стенда
    Настройки
*/

//----------------
//интерфейс модуля
//----------------

//общесистемные
exports.DEBUG = true; //режим отладки
exports.PRINT_CHECK_DELAY = 1000; //интервал опроса очереди печати стенда (мс)
exports.TEMP_FOLDER = "c:\\repos\\temp"; //каталог размещения временных файлов
exports.POWER_SHELL = "powershell.exe"; //исполняемый файл Power Shell
exports.PRINTER_SCRIPT = "print.ps1"; //командный файл Power Shell для постановки файла в очередь принтера

//подключение к серверу стенда
exports.SERVER_URL = "http://localhost:3030"; //адрес сервера
exports.CLIENT_NAME = "CITK Demo Stand Print Service/0.0.1"; //наименование клиента
exports.CLIENT_TOKEN = "c48d602f-ac7e-485d-a2f3-8d65f40d81c1"; //токен доступа
