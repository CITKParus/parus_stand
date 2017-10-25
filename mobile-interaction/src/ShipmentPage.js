import React from "react";
import { StatusBar, Text, View, StyleSheet, Button, AsyncStorage, Alert, TouchableOpacity } from "react-native";
import { IconButton } from "./IconButton";
const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: "#fff",
        alignItems: "center"
    },
    backButton: {
        top: 30,
        right: 0,
        left: 10
    },
    welcomeContainer: {
        marginTop: 200,
        marginBottom: 100,
        alignItems: "center"
    },
    welcome: {
        lineHeight: 32,
        fontSize: 26,
        marginBottom: 10
    },
    restContainer: {},
    line: {
        flexDirection: "row",
        alignItems: "center"
    },
    cellButton: {
        backgroundColor: "black",
        marginHorizontal: 20,
        height: 100,
        width: 200,
        justifyContent: "center",
        alignItems: "center"
    },
    cellText: {
        color: "white",
        fontSize: 20
    }
});

export default class SettingsPage extends React.Component {
    static navigationOptions = {
        header: null
    };
    navigation = this.props.navigation;
    _navBack = () => {
        this.navigation.goBack();
    };
    ship = async item => {
        console.log(item);
    };
    renderCELLS = cells => {
        return cells.map(cell => (
            <TouchableOpacity
                onPress={async () => {
                    await this.ship(cell.NRACK_CELL);
                }}
                style={styles.cellButton}
                key={cell.NRACK_CELL}
            >
                <Text style={styles.cellText}>{cell.NOMEN_RESTS[0].SNOMMODIF}</Text>
            </TouchableOpacity>
        ));
    };
    renderREST = rests => {
        return rests.map(line => (
            <View style={styles.line} key={line.NRACK_LINE}>
                {this.renderCELLS(line.RACK_LINE_CELL_RESTS)}
            </View>
        ));
    };
    render() {
        //const { response } = this.props.navigation.state.params;
        const response = {
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
                                    BEMPTY: false,
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
        return (
            <View style={styles.container}>
                <StatusBar barStyle="default" />
                <IconButton
                    onPress={this._navBack}
                    icon="ios-arrow-back"
                    iconColor="black"
                    style={styles.backButton}
                    text="Назад"
                />
                <View style={styles.welcomeContainer}>
                    <Text style={styles.welcome}>{"Здравствуйте,"}</Text>
                    <Text style={styles.welcome}>{response.message.USER.SAGENT_NAME},</Text>
                    <Text style={styles.welcome}>{"укажите желаемый товар"}</Text>
                </View>
                <View style={styles.restContainer}>{this.renderREST(response.message.RESTS.RACK_LINE_RESTS)}</View>
            </View>
        );
    }
}
