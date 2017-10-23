import React from "react";
import { StatusBar, Text, View, StyleSheet, Alert, Dimensions, Image, TouchableOpacity, TextInput } from "react-native";
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
        manual: false
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

    _handleBarCodeRead = data => {
        if (this.state.scannable) Alert.alert("Scan successful!", JSON.stringify(data));

        this.setState({
            scannable: false,
            data: data.data
        });
    };

    _handleManualButton = () => {
        this.setState({
            manual: !this.state.manual,
            scannable: !this.state.scannable
        });
    };

    _handleOkButton = () => {
        Alert.alert("Scan successful!", this.state.data);
    };

    _navToSettings = () => {
        this.navigation.navigate("Settings");
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
                                {!this.state.manual ? "Поднесите ваш бейдж к камере" : "Введите номер вашего бейджа"}
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
                    </BarCodeScanner>
                )}
            </View>
        );
    }
}
