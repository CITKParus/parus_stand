import React from "react";
import {
    StatusBar,
    Text,
    View,
    StyleSheet,
    Button,
    AsyncStorage,
    Alert,
    TouchableOpacity,
    ActivityIndicator
} from "react-native";
import { IconButton } from "./IconButton";
import { SHIPMENT } from "./api";
const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: "#fff"
    },
    backButton: {
        top: 30,
        right: 0,
        left: 10
    },
    mainContainer: {
        alignItems: "center",
        marginTop: 200
    },
    welcomeContainer: {
        marginBottom: 100,
        alignItems: "center"
    },
    welcome: {
        lineHeight: 32,
        fontSize: 30,
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

export default class ShipmentPage extends React.Component {
    static navigationOptions = {
        header: null
    };
    navigation = this.props.navigation;
    state = {
        loading: false,
        result: false,
        resultText: "Ошибка",
        onGoBack: this.navigation.state.params.onGoBack
    };
    _navBack = () => {
        this.setState({
            loading: false
        });
        this.state.onGoBack();
        this.navigation.goBack();
    };
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
        } else {
            this.setState({
                loading: false,
                result: true,
                resultText: response.message || "Спасибо, не забудьте Вашу накладную"
            });
        }
    };
    renderCELLS = (cells, user) => {
        return cells.map(cell => (
            <TouchableOpacity
                onPress={async () => {
                    await this.ship({
                        customer: user,
                        rack_line: cell.NRACK_LINE,
                        rack_line_cell: cell.NRACK_LINE_CELL
                    });
                }}
                style={[styles.cellButton, { backgroundColor: cell.BEMPTY ? "gray" : "black" }]}
                key={cell.NRACK_CELL}
                disabled={cell.BEMPTY}
            >
                <Text style={styles.cellText}>{cell.NOMEN_RESTS[0].SNOMMODIF}</Text>
            </TouchableOpacity>
        ));
    };
    renderREST = (rests, user) => {
        return rests.map(line => (
            <View style={styles.line} key={line.NRACK_LINE}>
                {this.renderCELLS(line.RACK_LINE_CELL_RESTS, user)}
            </View>
        ));
    };
    render() {
        const { response } = this.props.navigation.state.params;
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
                {this.state.loading && (
                    <View style={styles.mainContainer}>
                        <ActivityIndicator
                            animating={true}
                            color="black"
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
                                color: "black"
                            }}
                        >
                            Отгружаем...
                        </Text>
                    </View>
                )}
                {!this.state.loading &&
                    !this.state.result && (
                        <View style={styles.mainContainer}>
                            <View style={styles.welcomeContainer}>
                                <Text style={styles.welcome}>{"Здравствуйте,"}</Text>
                                <Text style={styles.welcome}>{response.USER.SAGENT_NAME},</Text>
                                <Text style={styles.welcome}>{"укажите желаемый товар"}</Text>
                            </View>
                            <View style={styles.restContainer}>
                                {this.renderREST(response.RESTS.RACK_LINE_RESTS, response.USER.SAGENT)}
                            </View>
                        </View>
                    )}
                {this.state.result && (
                    <View style={styles.mainContainer}>
                        <Text
                            style={{
                                fontSize: 34,
                                fontWeight: "bold",
                                backgroundColor: "transparent",
                                color: "black"
                            }}
                        >
                            {this.state.resultText}
                        </Text>

                        <TouchableOpacity onPress={this._navBack} style={[styles.cellButton, { paddingTop: 300 }]}>
                            <Text style={styles.cellText}>ОК</Text>
                        </TouchableOpacity>
                    </View>
                )}
            </View>
        );
    }
}
