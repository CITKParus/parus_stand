//-----------------------------------
// Настраиваем константы конфигурации
//-----------------------------------

var WIFI_SSID = "MartyMim"; // имя WiFi-сети
var WIFI_PSWD = "var2008eniK"; // ключ WiFi-сети
var WIFI_PORT = PrimarySerial; //порт (URAT) подключения WiFi-модуля
var SERVER_PORT = 8080; //порт WEB-сервера

//------------------------------
// Подключаем внешние библиотеки
//------------------------------

var wifi = require("@amperka/wifi"); //работа с модулем WiFi
var http = require("http"); //работа с HTTP

//--------------------------------
// Определяем глобальные константы
//--------------------------------

//состояние ответа сервера
var SERVER_RESP_OK = "OK"; //успех
var SERVER_RESP_ERR = "ERR"; //ошибка

//доступные линии отгрузки вендингового аппарата
var HARD_LINES = ["1", "2", "3"]; //наименования линий
var LINES = [ //конфигурация линий
  {name: HARD_LINES[0], pin: A2, on: false},
  {name: HARD_LINES[1], pin: A4, on: false},
  {name: HARD_LINES[2], pin: P8, on: false}
];

//------------------------------
// Функции
//------------------------------

//протоколирование
function log(message) {
  print("STAND: " + message);
}

//отправка типового ответа WEB-сервера
function buildResp(state, message) {
  return {state: state, message: message};
}

//отправка отрицательного ответа WEB-сервера
function buildOkResp(message) {
  return buildResp(SERVER_RESP_OK, message);
}

//отправка положительного ответа WEB-сервера
function buildErrResp(message) {
  return buildResp(SERVER_RESP_ERR, message);
}

//отгрузка с линии
function lineShipment(lineName, callBack) {
  LINES.forEach(function(line) {
    var tmp = line;
    if(tmp.name == lineName) {
      tmp.pin.write(true);
      log("Line " + lineName + " opened");
      setTimeout(function() {        
        tmp.pin.write(false);
        log("Line " + lineName + " closed");
        callBack();
      }, 100);
    }
  });
}

//инициализация окружения
function init() {
  log("Initializing...");
  //настраиваем интерфейс UART (COM-порт по сути, к которому подключен WiFi-модуль)
  WIFI_PORT.setup(115200);
  //настраиваем пины для аппаратов отгрузки
  LINES.forEach(function(line) {
    line.pin.mode("output");
    line.pin.write(false);
  });
}

//запуск WEB-сервера
function start() {
  //включим WiFi-моудль
  log("Starting up WiFi-module...");
  var wifiAdapter = wifi.setup(WIFI_PORT, function(err) {
    //если модуль стартовал успешно
    if(!err) {
      //подключаемся к WiFi сети
      log("Connecting to " + WIFI_SSID + " network...");
      wifiAdapter.connect(WIFI_SSID, WIFI_PSWD, function(err) {
        //если подключились к сети
        if(!err) {
          log("Connected!");
          //создаём WEB-сервер
          log("Starting up WEB-server on port " + SERVER_PORT);
          var srv = http.createServer(function (req, res) {
            var a = url.parse(req.url, true);
            processRequest(a, function (respData) {              
              res.writeHead(200);
              res.end(JSON.stringify(respData));
            });
          });
          //слушаем нужный порт
          srv.listen(SERVER_PORT);
          wifiAdapter.getIP(function (err, ip) {
            if(!err) {
              log("WEB-server started at " + ip + ":" + SERVER_PORT);           
            } else {
              log("Error while detecting WiFi-module IP address: " + err);
            }
          });          
        } else {
          log("Network connection error: " + err);
        }
      });
    } else {
      //не смогли запустить WiFi-модуль
      log("Hardware WiFi-module error: " + err);
    }
  });
}

//обработка входящих запросов
function processRequest(data, callBack) {
  //отфильтруем запросы 
  if((data) && (data.query) && (data.query.line) && (HARD_LINES.indexOf(data.query.line) !== -1)) {
    //открываем линию отгрузки
    log("Shiping from line " + data.query.line + "...");
    lineShipment(data.query.line, function() {
      log("Shiping from line " + data.query.line + " finished");
      callBack(buildOkResp());
    });
  } else {
    //такой запрос мы обработать не можем
    callBack(buildErrResp("Bad request!"));
  }
}

//------------
// Точка входа
//------------

init();
start();