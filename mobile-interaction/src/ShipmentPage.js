/******************************************************************************
 *
 * Экран отгрузки товара
 *
 *****************************************************************************/

import React from "react";
import { StatusBar, Text, View, StyleSheet, AsyncStorage, Alert, Image } from "react-native";
import LinearGradient from "react-native-linear-gradient";
import { IconButton, ShipmentCell, ShipmentLoading, ShipmentContainer, ShipmentResult } from "./components";
import { SHIPMENT, CANCEL_AUTH } from "./api";

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: "#fff"
    },
    backButton: {
        top: 30,
        right: 0,
        left: 10,

        backgroundColor: "transparent"
    },
    mainContainer: {
        alignItems: "center",
        marginTop: 300
    },
    logoContainer: {
        position: "absolute",
        top: 30,
        right: 10
    },
    logo: {
        height: 125,
        width: 125
    }
});

export default class ShipmentPage extends React.Component {
    static navigationOptions = {
        header: null
    };
    navigation = this.props.navigation;

    // Установка состояния по умолчанию
    state = {
        user: this.props.navigation.state.params.response.USER.NAGENT,
        loading: false, // Режим загрузки выключен
        loadingText: "Отгружаем...", // Сообщение о загрузке
        result: false, // Результата еще нет
        resultText: "Ошибка", // Результат
        onGoBack: this.navigation.state.params.onGoBack // Действие при возврате на предыдущий экран
    };

    // Возврат на предыдущений экран
    _navBack = async () => {
        this.setState({
            loading: true,
            loadingText: "Ожидайте..."
        });
        const response = await CANCEL_AUTH(this.state.user);
        if (response.state == "ERR") {
            Alert.alert(
                "Произошла ошибка :(",
                response.message,
                [
                    {
                        text: "ОК",
                        onPress: () => {
                            this.setState({
                                loading: false
                            });
                        }
                    }
                ],
                { cancelable: false }
            );
            return;
        }
        this.state.onGoBack();
        this.navigation.goBack();
    };

    // Отгрузка товара
    ship = async item => {
        this.setState({
            loading: true
        });
        const response = await SHIPMENT(item);

        if (response.state == "ERR") {
            Alert.alert(
                "Произошла ошибка :(",
                response.message,
                [
                    {
                        text: "ОК",
                        onPress: () => {
                            this.setState({
                                loading: false,
                                result: false,
                                resultText: null
                            });
                        }
                    }
                ],
                { cancelable: false }
            );
            return;
        }

        this.setState({
            loading: false,
            result: true,
            resultText: response.message || "Спасибо, не забудьте Вашу накладную"
        });
    };
    render() {
        console.log(this.state);
        const { response } = this.props.navigation.state.params;
        return (
            <LinearGradient
                style={styles.container}
                colors={["#000046", "#1CB5E0"]}
                start={{ x: 0.0, y: 0.25 }}
                end={{ x: 0.5, y: 1.0 }}
            >
                <StatusBar barStyle="light-content" />
                {!this.state.loading && (
                    <IconButton onPress={this._navBack} icon="ios-arrow-back" style={styles.backButton} text="Назад" />
                )}
                <View style={styles.logoContainer}>
                    <Image source={require("./assets/icons/parus_logo.png")} style={styles.logo} />
                </View>
                <View style={styles.mainContainer}>
                    {this.state.loading && <ShipmentLoading text={this.state.loadingText} />}
                    {!this.state.loading &&
                        !this.state.result && (
                            <ShipmentContainer
                                rests={response.RESTS.RACK_LINE_RESTS}
                                user={response.USER.SAGENT}
                                userName={response.USER.SAGENT_NAME}
                                onPress={this.ship}
                            />
                        )}
                    {this.state.result &&
                        !this.state.loading && (
                            <ShipmentResult onPress={this._navBack} resultText={this.state.resultText} />
                        )}
                </View>
            </LinearGradient>
        );
    }
}
