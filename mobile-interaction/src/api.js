import { AsyncStorage } from "react-native";
import { config } from "./config";

const TOKEN = "44988367-dca2-4664-b2a5-f17c0b018842";

export const AUTH_BY_BARCODE = async barcode => {
    console.log("AUTH_BY_BARCODE");
    console.log(barcode);
    const BASEURL = await AsyncStorage.getItem("url");
    const body = {
        token: TOKEN,
        action: "AUTH_BY_BARCODE",
        barcode: barcode
    };
    const parameters = {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(body)
    };
    try {
        const response = await fetch(BASEURL, parameters);
        const result = await response.json();
        // EXAMPLE RESPONSE
        /*    const result = {
            state: "OK",
            message: {
                USER: { NAGENT: 452546, SAGENT: "Сидоров С. С.", SAGENT_NAME: "Сидоров Сидор Сидорович" },
                RESTS: {
                    NRACK: 452223,
                    NSTORE: 452222,
                    SSTORE: "СГП",
                    SRACK_PREF: "АВТОМАТ",
                    SRACK_NUMB: "1",
                    SRACK_NAME: "АВТОМАТ-1",
                    NRACK_LINES_CNT: 1,
                    BEMPTY: false,
                    RACK_LINE_RESTS: [
                        {
                            NRACK_LINE: 1,
                            NRACK_LINE_CELLS_CNT: 3,
                            BEMPTY: false,
                            RACK_LINE_CELL_RESTS: [
                                {
                                    NRACK_CELL: 452224,
                                    SRACK_CELL_PREF: "ЯРУС1",
                                    SRACK_CELL_NUMB: "МЕСТО1",
                                    SRACK_CELL_NAME: "ЯРУС1-МЕСТО1",
                                    NRACK_LINE: 1,
                                    NRACK_LINE_CELL: 1,
                                    BEMPTY: false,
                                    NOMEN_RESTS: [
                                        {
                                            NNOMEN: 452232,
                                            SNOMEN: "Жевательная резинка",
                                            NNOMMODIF: 452233,
                                            SNOMMODIF: "Orbit",
                                            NREST: 2,
                                            NMEAS: 435021,
                                            SMEAS: "шт"
                                        }
                                    ]
                                },
                                {
                                    NRACK_CELL: 452225,
                                    SRACK_CELL_PREF: "ЯРУС1",
                                    SRACK_CELL_NUMB: "МЕСТО2",
                                    SRACK_CELL_NAME: "ЯРУС1-МЕСТО2",
                                    NRACK_LINE: 1,
                                    NRACK_LINE_CELL: 2,
                                    BEMPTY: true,
                                    NOMEN_RESTS: [
                                        {
                                            NNOMEN: 452232,
                                            SNOMEN: "Жевательная резинка",
                                            NNOMMODIF: 457611,
                                            SNOMMODIF: "Dirol",
                                            NREST: 2,
                                            NMEAS: 435021,
                                            SMEAS: "шт"
                                        }
                                    ]
                                },
                                {
                                    NRACK_CELL: 452226,
                                    SRACK_CELL_PREF: "ЯРУС1",
                                    SRACK_CELL_NUMB: "МЕСТО3",
                                    SRACK_CELL_NAME: "ЯРУС1-МЕСТО3",
                                    NRACK_LINE: 1,
                                    NRACK_LINE_CELL: 3,
                                    BEMPTY: false,
                                    NOMEN_RESTS: [
                                        {
                                            NNOMEN: 452232,
                                            SNOMEN: "Жевательная резинка",
                                            NNOMMODIF: 457612,
                                            SNOMMODIF: "Eclipce",
                                            NREST: 2,
                                            NMEAS: 435021,
                                            SMEAS: "шт"
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            }
        };
*/
        console.log(result);
        return result;
    } catch (err) {
        console.log(err);
        return {
            state: "ERR",
            message: "Ошибка соединения =("
        };
    }
};

export const SHIPMENT = async data => {
    console.log("SHIPMENT");
    const BASEURL = await AsyncStorage.getItem("url");
    const body = {
        token: TOKEN,
        action: "SHIPMENT",
        customer: data.customer,
        rack_line: data.rack_line,
        rack_line_cell: data.rack_line_cell
    };
    const parameters = {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(body)
    };
    try {
        const response = await fetch(BASEURL, parameters);
        console.log(response);
        const result = await response.json();
        console.log(result);
        return result;
    } catch (err) {
        console.log(err);
        return {
            state: "ERR",
            message: "Ошибка соединения =("
        };
    }
};
