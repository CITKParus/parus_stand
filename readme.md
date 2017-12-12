# Стенд WEB-технологий Парус 8

### Что мы использовали:

#### Функциональные особенности ПП Парус 8

* Учёт товарных запасов по местам хранения
* Электронная инвентаризация
* WEB-сервис отчётности

#### Дополнительные технологии

* ПП Парус 8 как WEB-сервис
* Доступ к ПП Парус 8 из мобильных и WEB-приложений
* Обработка штрих-кодов и QR-кодов

#### Список технологий

* [Node.js](https://nodejs.org/en/) - web сервисы
* [React](https://reactjs.org/) - web интерфейс
* [React Native](https://facebook.github.io/react-native/) - мобильный интерфейс
* [Iskra JS](http://amperka.ru/product/iskra-js) - программируемый микроконтроллер

### Состав:

!(https://citkparus.github.io/parus_stand/stand_schema.png)

#### 1. /db/ - серверные расширения Парус 8 (PL/SQL)

* Автоматизация формирования документов в системе
* Программные раширения Парус 8, обеспечивающие работу стенда

#### 2. /notify/ - сервис оповещения (Node.js)

* Telegram-бот для мониторинга состояния склада

#### 3. /print/ - сервис печати (Node.js)

* Мониторинг очереди печати и отправка заданий на принтер (автоматическая печать ТТН)

#### 4. /server/ - веб-сервис Парус 8 (Node.js)

* Связь с БД Парус 8
* HTTP API для Telegram-бота
* HTTP API для web приложений
* HTTP API для сервиса печати

#### 5. /vending-machine/ - вендинговый аппарат (JavaScript)

* Управление автоматической выдачей жвачки

#### 6. /mobile-interaction/ - мобильное приложение (React Native)

* Входная точка
* Считывание штрихкодов с бейджей посетителей
* Интерфейс заказа товара из автомата отгрузки

#### 7. /web-monitor/ - веб-мониторинг (React)

* Online мониторинг остатков на складе и прочая статистика работы стенда

Исходный код: https://github.com/CITKParus/parus_stand
