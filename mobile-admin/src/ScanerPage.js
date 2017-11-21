import React from "react";
import {
    StatusBar,
    Text,
    TextInput,
    View,
    StyleSheet,
    Button,
    Alert,
    Platform,
    TouchableOpacity,
    Linking
} from "react-native";
import NfcManager, { NdefParser } from "react-native-nfc-manager";
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

    constructor(props) {
        super(props);
        this.state = {
            supported: true,
            enabled: false,
            tag: {}
        };
    }

    componentDidMount() {
        NfcManager.start({
            onSessionClosedIOS: () => {
                console.log("ios session closed");
            }
        })
            .then(result => {
                console.log("start OK", result);
            })
            .catch(error => {
                console.warn("start fail", error);
                this.setState({ supported: false });
            });

        if (Platform.OS === "android") {
            NfcManager.getLaunchTagEvent()
                .then(tag => {
                    console.log("launch tag", tag);
                    if (tag) {
                        this.setState({ tag });
                    }
                })
                .catch(err => {
                    console.log(err);
                });
            NfcManager.isEnabled()
                .then(enabled => {
                    this.setState({ enabled });
                })
                .catch(err => {
                    console.log(err);
                });
        }
    }

    _onTagDiscovered = tag => {
        console.log("Tag Discovered", tag);
        this.setState({ tag });
        let url = this._parseUri(tag);
    };

    _startDetection = () => {
        NfcManager.registerTagEvent(this._onTagDiscovered)
            .then(result => {
                console.log("registerTagEvent OK", result);
            })
            .catch(error => {
                console.warn("registerTagEvent fail", error);
            });
    };

    _stopDetection = () => {
        NfcManager.unregisterTagEvent()
            .then(result => {
                console.log("unregisterTagEvent OK", result);
            })
            .catch(error => {
                console.warn("unregisterTagEvent fail", error);
            });
    };

    _clearMessages = () => {
        this.setState({ tag: null });
    };

    _goToNfcSetting = () => {
        if (Platform.OS === "android") {
            NfcManager.goToNfcSetting()
                .then(result => {
                    console.log("goToNfcSetting OK", result);
                })
                .catch(error => {
                    console.warn("goToNfcSetting fail", error);
                });
        }
    };

    _parseUri = tag => {
        let result = NdefParser.parseUri(tag.ndefMessage[0]),
            uri = result && result.uri;
        if (uri) {
            console.log("parseUri: " + uri);
            return uri;
        }
        return null;
    };

    render() {
        let { supported, enabled, tag } = this.state;
        return (
            <View style={styles.container}>
                <StatusBar barStyle="default" />

                <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
                    <Text>{`Is NFC supported ? ${supported}`}</Text>
                    <Text>{`Is NFC enabled (Android only)? ${enabled}`}</Text>

                    <TouchableOpacity style={{ marginTop: 20 }} onPress={this._startDetection}>
                        <Text style={{ color: "blue" }}>Start Tag Detection</Text>
                    </TouchableOpacity>

                    <TouchableOpacity style={{ marginTop: 20 }} onPress={this._stopDetection}>
                        <Text style={{ color: "red" }}>Stop Tag Detection</Text>
                    </TouchableOpacity>

                    <TouchableOpacity style={{ marginTop: 20 }} onPress={this._clearMessages}>
                        <Text>Clear</Text>
                    </TouchableOpacity>

                    <TouchableOpacity style={{ marginTop: 20 }} onPress={this._goToNfcSetting}>
                        <Text>Go to NFC setting</Text>
                    </TouchableOpacity>

                    <Text style={{ marginTop: 20 }}>{`Current tag JSON: ${JSON.stringify(tag)}`}</Text>
                </View>
            </View>
        );
    }
}
