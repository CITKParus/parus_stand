/******************************************************************************
 *
 * Экран считывания QR-кодов
 *
 *****************************************************************************/

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
        hasCameraPermission: null, // Разрешение на использование камеры
        scannable: true, // Режим сканера
        data: null, // Данные полученные от пользователя (сканером или вручную)
        manual: false, // Режим ручного ввода кода
        loading: false // Режим загрузки
    };
    // Параметры навигации
    navigation = this.props.navigation;

    // Навигация на экран Настроек
    _navToSettings = () => {
        this.navigation.navigate("Settings");
    };

    // Сбросить состояние экрана
    refresh = () => {
        this.setState({
            scannable: true,
            data: null,
            manual: false,
            loading: false
        });
    };

    // После загрузки экрана
    componentDidMount() {
        // Запросить разрешение камеры
        this._requestCameraPermission();
    }

    // Запрос разрешения камеры
    _requestCameraPermission = async () => {
        // Запрос
        const status = await Permissions.request("camera");
        // Установить текущее состояния разрешения
        this.setState({
            hasCameraPermission: status === "authorized"
        });
    };

    // Считывание qr-кода
    _handleBarCodeRead = async data => {
        // Если в режиме сканера
        if (this.state.scannable) {
            // Установка состояния
            this.setState({
                loading: true, // Режим загрузки включен
                scannable: false, // Режим сканера выключен
                data: data.data // Полученные данные
            });
            // Аутентификация пользователя по считанному коду
            await this._auth();
        }
    };

    // При ручном вводе кода
    _handleManualButton = async () => {
        // Установка состояния
        this.setState({
            loading: true // Режим загрузки включен
        });
        // Аутентификация пользователя по введенному коду
        await this._auth();
    };

    // Переключение режимов сканер/ручной ввод
    _handleSwitchButton = async () => {
        // Установка состояния
        this.setState({
            manual: !this.state.manual,
            scannable: !this.state.scannable
        });
    };

    // Аутентификация пользователя по коду
    _auth = async () => {
        // Запрос подключения к сети
        const isConnected = connected();
        // Если есть подключение
        if (!isConnected) {
            // Если нет подключения к сети
            Alert.alert(
                "Нет подключения к сети :(",
                response.message,
                [
                    {
                        text: "Отменить",
                        onPress: () => {
                            this.setState({
                                loading: false,
                                manual: false, // Режим ручного ввода выключен
                                scannable: true
                            });
                        }
                    }
                ],
                { cancelable: false }
            );
            return;
        }
        console.log(this.state.data);
        // Отправляем запрос на аутентификацию пользователя
        const response = await AUTH_BY_BARCODE(this.state.data);

        // Если сканер не активен
        if (!this.state.scannable) {
            // Если в ответ пришла ошибка
            if (response.state == "ERR") {
                // Показать сообщение об ошибке
                Alert.alert(
                    "Произошла ошибка :(",
                    response.message,
                    [
                        {
                            text: "Отменить",
                            // При нажатии на кнопку подтверждения
                            onPress: () => {
                                // Установка состояния
                                this.setState({
                                    loading: false, // Режим загрузки выключен
                                    manual: false, // Режим ручного ввода выключен
                                    scannable: true // Режим сканера включен
                                });
                            }
                        }
                    ],
                    { cancelable: false }
                );
                return;
            }
            // Если все хорошо, переход на страницу загрузки с передачей информации о товарах
            this.navigation.navigate("Second", { response: response.message, onGoBack: this.refresh });
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
                                onManualSubmit={this._handleManualButton}
                                onSwitch={this._handleSwitchButton}
                            />
                        </Camera>
                    )}
            </View>
        );
    }
}
