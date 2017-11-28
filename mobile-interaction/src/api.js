/******************************************************************************
 *
 * Взаимодействие с серверным API
 *
 *****************************************************************************/

import { AsyncStorage } from "react-native";
import { config } from "./config";
import { AUTH_BY_BARCODE_RESPONSE } from "./mock";

// Секретный токен для аутентификации приложения
const TOKEN = "44988367-dca2-4664-b2a5-f17c0b018842";

// Аутентификация по уникальному коду пользователя
export const AUTH_BY_BARCODE = async barcode => {
    console.log("AUTH_BY_BARCODE");
    console.log(barcode);
    // Считывание адреса сервера из хранилища
    const BASEURL = await AsyncStorage.getItem("url");
    // Объект запроса
    const body = {
        token: TOKEN,
        action: "AUTH_BY_BARCODE",
        barcode: barcode
    };
    // Параметры запроса
    const parameters = {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(body)
    };

    try {
        if (config.dev) return AUTH_BY_BARCODE_RESPONSE;
        // Отправка запроса по указанному адресу с параметрами
        const response = await fetch(BASEURL, parameters);
        // Получение ответа от сервера в формате json
        const result = await response.json();
        console.log(result);
        return result;
    } catch (err) {
        // Отлавливание ошибок отправки запроса
        console.log(err);
        return {
            state: "ERR",
            message: "Ошибка соединения =("
        };
    }
};

// Отмена аутентификации
export const CANCEL_AUTH = async customerID => {
    console.log("CANCEL_AUTH");
    console.log(customerID);
    // Считывание адреса сервера из хранилища
    const BASEURL = await AsyncStorage.getItem("url");
    // Объект запроса
    const body = {
        token: TOKEN,
        action: "CANCEL_AUTH",
        customerID: customerID
    };
    // Параметры запроса
    const parameters = {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(body)
    };

    try {
        // Отправка запроса по указанному адресу с параметрами
        const response = await fetch(BASEURL, parameters);
        // Получение ответа от сервера в формате json
        const result = await response.json();
        console.log(result);
        return result;
    } catch (err) {
        // Отлавливание ошибок отправки запроса
        console.log(err);
        return {
            state: "ERR",
            message: "Ошибка соединения =("
        };
    }
};

// Отгрузка товара
export const SHIPMENT = async data => {
    console.log("SHIPMENT");
    console.log(data);
    // Считывание адреса сервера из хранилища
    const BASEURL = await AsyncStorage.getItem("url");
    // Объект запроса
    const body = {
        token: TOKEN,
        action: "SHIPMENT",
        customer: data.customer,
        rack_line: data.rack_line,
        rack_line_cell: data.rack_line_cell
    };
    // Параметры запроса
    const parameters = {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(body)
    };
    try {
        // Отправка запроса по указанному адресу с параметрами
        const response = await fetch(BASEURL, parameters);
        // Получение ответа от сервера в формате json
        const result = await response.json();
        console.log(result);
        return result;
    } catch (err) {
        // Отлавливание ошибок отправки запроса
        console.log(err);
        return {
            state: "ERR",
            message: "Ошибка соединения =("
        };
    }
};
