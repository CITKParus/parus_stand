import React from "react";
import {
    ActivityIndicator,
    StatusBar,
    Text,
    View,
    StyleSheet,
    Alert,
    Dimensions,
    Image,
    TouchableOpacity,
    TextInput
} from "react-native";
import { Constants, BarCodeScanner, Permissions } from "expo";
import { Ionicons, MaterialCommunityIcons } from "@expo/vector-icons";
import { IconButton } from "./IconButton";
let { height, width } = Dimensions.get("window");
const styles = StyleSheet.create({
    pageContainer: {
        flex: 1,
        backgroundColor: "#fff",
        alignItems: "center",
        justifyContent: "center"
    },
    container: {
        height: height,
        width: width,
        alignItems: "center",
        justifyContent: "flex-start"
    },
    logo: {
        position: "absolute",
        height: 100,
        width: 100,
        top: 30,
        left: 10
    },
    centerContainer: {
        width: 650,
        height: 350,
        marginTop: 250,
        justifyContent: "flex-end",
        alignItems: "center"
    }
});
export default class ScanerPage extends React.Component {
    static navigationOptions = {
        header: null
    };
    state = {
        hasCameraPermission: null,
        scannable: true,
        data: null,
        manual: false,
        loading: false
    };
    navigation = this.props.navigation;
    componentDidMount() {
        this._requestCameraPermission();
    }

    _requestCameraPermission = async () => {
        const { status } = await Permissions.askAsync(Permissions.CAMERA);
        this.setState({
            hasCameraPermission: status === "granted"
        });
    };

    _handleBarCodeRead = async data => {
        if (this.state.scannable) {
            this.setState({
                loading: true,
                scannable: false,
                data: data.data
            });
            await this._auth();
        }
    };

    _handleManualButton = () => {
        this.setState({
            manual: !this.state.manual,
            scannable: !this.state.scannable
        });
    };

    _handleOkButton = async () => {
        this.setState({
            loading: true
        });
        await this._auth();
    };

    _navToSettings = () => {
        this.navigation.navigate("Settings");
    };

    _auth = async () => {
        setTimeout(() => {
            /* TODO: HTTP CALL */
            let response = {
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
            this.navigation.navigate("Second", { response: response });
            let error = null;
            if (error !== null) {
                Alert.alert(
                    "Произошла ошибка :(",
                    error,
                    [
                        {
                            text: "Отменить",
                            onPress: () => {
                                this.setState({
                                    loading: false,
                                    scannable: true
                                });
                            }
                        }
                    ],
                    { cancelable: false }
                );
            }
        }, 1000);
    };
    render() {
        return (
            <View style={styles.pageContainer}>
                <StatusBar barStyle="light-content" />
                {this.state.hasCameraPermission === null ? (
                    <Text>Requesting for camera permission</Text>
                ) : this.state.hasCameraPermission === false ? (
                    <Text>Camera permission is not granted</Text>
                ) : (
                    <BarCodeScanner onBarCodeRead={this._handleBarCodeRead} type={"front"} style={styles.container}>
                        <Image source={require("./assets/icons/parus_logo.png")} style={styles.logo} />

                        <IconButton onPress={this._navToSettings} icon="ios-construct-outline" />
                        {this.state.loading && (
                            <View style={{ alignItems: "center" }}>
                                <View style={styles.centerContainer}>
                                    <ActivityIndicator
                                        animating={true}
                                        color="white"
                                        size="large"
                                        style={{
                                            paddingBottom: 100
                                        }}
                                    />
                                    <Text
                                        style={{
                                            fontSize: 34,
                                            fontWeight: "bold",
                                            backgroundColor: "transparent",
                                            color: "#FFF"
                                        }}
                                    >
                                        Хм, посмотрим... ;-)
                                    </Text>
                                </View>
                            </View>
                        )}
                        {!this.state.loading && (
                            <View style={{ alignItems: "center" }}>
                                <View style={styles.centerContainer}>
                                    {!this.state.manual && (
                                        <MaterialCommunityIcons
                                            name="qrcode-scan"
                                            size={200}
                                            color="white"
                                            style={{
                                                backgroundColor: "transparent",
                                                marginBottom: 50
                                            }}
                                        />
                                    )}

                                    {this.state.manual && (
                                        <View style={{ justifyContent: "flex-end", alignItems: "center" }}>
                                            <TextInput
                                                style={{
                                                    color: "#FFF",
                                                    fontSize: 30,
                                                    borderWidth: 0.5,
                                                    borderColor: "#FFF",
                                                    width: 400,
                                                    padding: 15
                                                }}
                                                placeholder="Код с бейджа"
                                                placeholderTextColor="#f0f0f0"
                                                onChangeText={data => this.setState({ data })}
                                                onSubmitEditing={this._handleOkButton}
                                                returnKeyType="next"
                                                keyboardType="numeric"
                                            />
                                            <TouchableOpacity
                                                style={{
                                                    width: 150,
                                                    height: 70,
                                                    marginTop: 30,
                                                    marginBottom: 60,
                                                    justifyContent: "center",
                                                    backgroundColor: "white"
                                                }}
                                                onPress={this._handleOkButton}
                                            >
                                                <Text
                                                    style={{
                                                        fontSize: 22,
                                                        alignSelf: "center",
                                                        backgroundColor: "transparent",
                                                        color: "black"
                                                    }}
                                                >
                                                    ОК
                                                </Text>
                                            </TouchableOpacity>
                                        </View>
                                    )}
                                    <Text
                                        style={{
                                            fontSize: 34,
                                            fontWeight: "bold",
                                            backgroundColor: "transparent",
                                            color: "#FFF"
                                        }}
                                    >
                                        {!this.state.manual
                                            ? "Поднесите ваш бейдж к камере"
                                            : "Введите номер вашего бейджа"}
                                    </Text>
                                </View>

                                <TouchableOpacity
                                    style={{
                                        width: 400,
                                        height: 70,
                                        borderWidth: 0.5,
                                        borderColor: "#FFF",
                                        marginTop: 150,
                                        justifyContent: "center"
                                    }}
                                    onPress={this._handleManualButton}
                                >
                                    <Text
                                        style={{
                                            fontSize: 22,
                                            alignSelf: "center",
                                            backgroundColor: "transparent",
                                            color: "#FFF"
                                        }}
                                    >
                                        {!this.state.manual ? "Ввести вручную" : "Отсканировать"}
                                    </Text>
                                </TouchableOpacity>
                            </View>
                        )}
                    </BarCodeScanner>
                )}
            </View>
        );
    }
}
