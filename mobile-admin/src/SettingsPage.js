import React from "react";
import { StatusBar, Text, TextInput, View, StyleSheet, Button, AsyncStorage, Alert } from "react-native";
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
export default class SettingsPage extends React.Component {
    static navigationOptions = {
        title: "Настройки"
    };
    constructor(props) {
        super(props);
        this.state = {
            url: config.serverUrl
        };
    }

    async componentDidMount() {
        try {
            let url = await AsyncStorage.getItem("url");
            if (url == null) {
                url = config.serverUrl;
                await AsyncStorage.setItem("url", url);
            }
            this.setState({ url });
        } catch (error) {
            Alert.alert("Ошибка", error);
        }
    }

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
                    <Text style={styles.label}>Адрес сервера</Text>
                    <TextInput
                        style={styles.input}
                        onChangeText={url => this.setState({ url })}
                        value={this.state.url}
                    />
                </View>
                <Button title="Сохранить" style={styles.button} onPress={save} />
            </View>
        );
    }
}
