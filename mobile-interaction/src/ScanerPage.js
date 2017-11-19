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
import Camera from "react-native-camera";
import Permissions from "react-native-permissions";
import MaterialCommunityIcons from "react-native-vector-icons/MaterialCommunityIcons";
import { IconButton } from "./IconButton";
import { AUTH_BY_BARCODE } from "./api";
import renderIf from "./renderIf";
import { ManualInput, LogoButton, ScanerLoading } from "./components";
import { connected } from "./utils";
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

    setStateAsync(state) {
        return new Promise(resolve => {
            this.setState(state, resolve);
        });
    }
    refresh = () => {
        console.log("refresh");

        this.setState({
            scannable: true,
            data: null,
            manual: false,
            loading: false
        });
    };
    componentDidMount() {
        this._requestCameraPermission();
    }

    _requestCameraPermission = async () => {
        const status = await Permissions.request("camera");

        this.setState({
            hasCameraPermission: status === "authorized"
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

    _handleManualButton = async () => {
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
        const isConnected = connected();
        if (isConnected) {
            console.log(this.state.data);
            const response = await AUTH_BY_BARCODE(this.state.data);

            if (response.state == "ERR") {
                Alert.alert(
                    "Произошла ошибка :(",
                    response.message,
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
            } else {
                this.navigation.navigate("Second", { response: response.message, onGoBack: this.refresh });
            }
        } else {
            Alert.alert(
                "Нет подключения к сети :(",
                response.message,
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
    };

    render() {
        console.log(this.state);
        const { hasCameraPermission, loading, manual } = this.state;
        return (
            <View style={styles.pageContainer}>
                <StatusBar barStyle="light-content" />
                {hasCameraPermission === null ? (
                    <Text>Requesting for camera permission</Text>
                ) : hasCameraPermission === false ? (
                    <Text>Camera permission is not granted</Text>
                ) : (
                    <Camera onBarCodeRead={this._handleBarCodeRead} type={"front"} style={styles.container}>
                        <LogoButton
                            onPress={() => {
                                this.refresh();
                            }}
                        />

                        <IconButton onPress={this._navToSettings} icon="ios-construct-outline" />

                        {loading ? (
                            <ScanerLoading />
                        ) : (
                            <View style={{ alignItems: "center" }}>
                                <View style={styles.centerContainer}>
                                    {manual ? (
                                        <ManualInput
                                            onChangeText={data => this.setState({ data: data })}
                                            onSubmitEditing={this._handleOkButton}
                                        />
                                    ) : (
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
                                    <Text
                                        style={{
                                            fontSize: 34,
                                            fontWeight: "bold",
                                            backgroundColor: "transparent",
                                            color: "#FFF"
                                        }}
                                    >
                                        {!manual ? "Поднесите ваш бейдж к камере" : "Введите номер вашего бейджа"}
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
                                        {!manual ? "Ввести вручную" : "Отсканировать"}
                                    </Text>
                                </TouchableOpacity>
                            </View>
                        )}
                    </Camera>
                )}
            </View>
        );
    }
}
