/******************************************************************************
 *
 * Тестовые данные
 *
 *****************************************************************************/

// AUTH_BY_BARCODE EXAMPLE RESPONSE
export const AUTH_BY_BARCODE_RESPONSE = {
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
                                    NREST: 0,
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
