import React from "react";
import { StatusBar, Text, TextInput, View, StyleSheet, Button, Alert } from "react-native";
import { config } from "./config";
const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: "#fff"
    },
    row: {
        margin: 10,
        justifyContent: "flex-start"
    },
    label: {
        fontSize: 16,
        paddingBottom: 10
    },
    input: {
        fontSize: 16,
        color: "black"
    },
    button: {}
});
export default class ScanerPage extends React.Component {
    static navigationOptions = {
        title: "Парус"
    };

    render() {
        const { goBack } = this.props.navigation;
        const save = async () => {
            await AsyncStorage.setItem("url", this.state.url);
            goBack();
        };
        return (
            <View style={styles.container}>
                <StatusBar barStyle="default" />
                <View style={styles.row}>
                    <Text style={styles.label}>Hello World</Text>
                </View>
            </View>
        );
    }
}
