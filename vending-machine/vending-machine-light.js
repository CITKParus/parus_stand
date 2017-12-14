//------------------------------------------------
// Прошивка вендингового аппарата
// Подсветка в зависимости от загруженности стенда
//------------------------------------------------

//------------------------------
// Подключаем внешние библиотеки
//------------------------------

var wifi = require("@amperka/wifi"); //работа с модулем WiFi
var http = require("http"); //работа с HTTP

//--------------------------------
// Определяем глобальные константы
//--------------------------------

//подключение к сети и параметры сервера-приложений
var WIFI_PORT = PrimarySerial; //порт (URAT) подключения WiFi-модуля
var WIFI_SSID = "STAND"; // имя WiFi-сети
var WIFI_PSWD = "ok2017sana"; // ключ WiFi-сети
var SERVER_URL = "http://192.168.1.228:3030/?token=50fdd530-b44a-4151-a9d7-15662f41c000&action=STAND_GET_STATE";
var SERVER_LOOP_TIMEOUT = 5000; //период опроса сервера (мс)

//состояния ответа WEB-сервера
var SERVER_RESP_OK = "OK"; //успех
var SERVER_RESP_ERR = "ERR"; //ошибка

//настройки светодиодов
var LEDS = [
  [P4, P5, P6],
  [P7, P8, P9],
  [P10, P11, P12]
];

//------------------------------
// Функции
//------------------------------

//протоколирование
function log(message) {
    print("STAND: " + message);
}

//установка цвета
function setColor(color) {
    color.forEach(function(c, i) {
        LEDS.forEach(function(led) {
            led[i].write(c);
        });
    });
}

//установка синего
function setColorRed() {
    setColor([1, 0, 0]);
}

//установка красного
function setColorBlue() {
    setColor([0, 1, 0]);
}

//установка зеленого
function setColorGreen() {
    setColor([0, 0, 1]);
}

//инициализация окружения
function init() {
    log("Initializing ports and pins...");
    //настраиваем интерфейс UART (COM-порт по сути, к которому подключен WiFi-модуль)
    WIFI_PORT.setup(115200);
    //настраиваем пины диодов
    LEDS.forEach(function(led) {
        led.forEach(function(pin) {
            pin.mode("output");
        });
    });
    log("Done!");
}

//подключение к сети и опрос сервера
function start() {
    //выставим цвет по умолчанию
    setColorBlue();
    //включим WiFi-моудль
    log("Starting up WiFi-module...");
    var wifiAdapter = wifi.setup(WIFI_PORT, function(err) {
        //таймаут инициализации (если без ошибок - будем стартовать почти сразу)
        var timeOut = 50;
        //не смогли запустить WiFi-модуль - выставим таймаут перед инициализацией (проблемы с новой прошивкой)
        if (err) {
            timeOut = 2000;
            log("Hardware WiFi-module error: " + err);
            log("Waiting for init in " + timeOut + " millisecodns...");
        } else {
            log("Done!");
        }
        //стартуем сразу или по таймауту, в зависимости от наличия ошибок
        setTimeout(() => {
            //инициализируем WiFi-модуль
            log("Initializing WiFi-module...");
            wifiAdapter.init(function(err) {
                if (err) {
                    log("WiFi-module inittialization error: " + err);
                    log("Trying to connect to Wi-Fi network anyway...");
                } else {
                    log("Done!");
                }
                //подключаемся к WiFi сети
                log("Connecting to " + WIFI_SSID + " network...");
                wifiAdapter.connect(WIFI_SSID, WIFI_PSWD, function(err) {
                    //если подключились к сети
                    if (!err) {
                        log("Connected!");
                        //начинаем опрос сервера
                        startServerLoop();
                    } else {
                        log("Network connection error: " + err);
                    }
                });
            });
        }, timeOut);
    });
}

//получение данных сервера и управление подсветкой
function getServerData(callBack) {
    http.get(SERVER_URL, function(res) {
        var response = '';
        res.on("data", function(d) {response += d;});
        res.on("close", function() {
            try {
                var d = JSON.parse(response);
                if(d.state == SERVER_RESP_OK) {
                    if((d.message.NRESTS_LIMIT_PRC_MIN)&&(d.message.NRESTS_LIMIT_PRC_MDL)&&((d.message.NRESTS_PRC_CURR)||(d.message.NRESTS_PRC_CURR === 0))) {
                        log("Curent stand load: " + d.message.NRESTS_PRC_CURR + "%");
                        if(d.message.NRESTS_PRC_CURR <= d.message.NRESTS_LIMIT_PRC_MIN) {
                            setColorRed();
                        } else {
                            setColorGreen();
                        }
                    } else {
                        log("Unexpected server response!");
                        setColorBlue();
                    }
                } else {
                    log("Server error: " + d.message);
                    setColorBlue();
                }
            } catch (e) {
                log("Unexpected server response!");
                setColorBlue();
            }
            callBack();
        });
    }).on("error", function(e) {
        log("Server error: " + e.message);
        setColorBlue();
        callBack();
    });
}

//запуск мониторинга сервера
function startServerLoop() {
    log("Calling server...");
    getServerData(function() {
        setTimeout(startServerLoop, SERVER_LOOP_TIMEOUT);
    });
}

//------------
// Точка входа
//------------

init();
start();
