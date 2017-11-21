import React from "react";
import { Text, View, TouchableOpacity, StyleSheet } from "react-native";
import { ManualInput, QRCodeIcon } from ".";

const styles = StyleSheet.create({
    centerContainer: {
        width: 650,
        height: 350,
        marginTop: 250,
        justifyContent: "flex-end",
        alignItems: "center"
    }
});

export const ScanerInput = props => {
    const { manual, visible, onManualChangeText, onManualSubmit, onSwitch } = props;
    if (!visible) return null;
    return (
        <View style={{ alignItems: "center" }}>
            <View style={styles.centerContainer}>
                <ManualInput onChangeText={onManualChangeText} onSubmitEditing={onManualSubmit} visible={manual} />
                <QRCodeIcon visible={!manual} />
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
                onPress={onSwitch}
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
    );
};
