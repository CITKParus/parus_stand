import React from "react";
import Camera from "react-native-camera";
import Permissions from "react-native-permissions";
import { StatusBar, Text, View, StyleSheet, Alert, Dimensions } from "react-native";
import { LogoButton, ScanerLoading, ScanerInput, IconButton } from "./components";
import { AUTH_BY_BARCODE } from "./api";
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
    loading: {
        backgroundColor: "black"
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

    refresh = () => {
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
            loading: true,
            scannable: false
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
            if (!this.state.scannable) {
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
        const { hasCameraPermission, loading, manual } = this.state;
        return (
            <View style={styles.pageContainer}>
                <StatusBar barStyle="light-content" />
                {hasCameraPermission === null && <Text>Запрашиваю разрешение камеры</Text>}
                {hasCameraPermission === false && <Text>Разрешение камеры не предоставлено</Text>}
                {loading && (
                    <View style={[styles.container, styles.loading]}>
                        <LogoButton
                            onPress={() => {
                                this.refresh();
                            }}
                        />
                        <ScanerLoading visible={loading} />
                    </View>
                )}
                {!loading &&
                    hasCameraPermission && (
                        <Camera onBarCodeRead={this._handleBarCodeRead} type={"front"} style={styles.container}>
                            <LogoButton
                                onPress={() => {
                                    this.refresh();
                                }}
                            />
                            <IconButton onPress={this._navToSettings} icon="ios-construct-outline" />
                            <ScanerInput
                                visible={!loading}
                                manual={manual}
                                onManualChangeText={data => this.setState({ data: data })}
                                onManualSubmit={this._handleOkButton}
                                onSwitch={this._handleManualButton}
                            />
                        </Camera>
                    )}
            </View>
        );
    }
}
