/******************************************************************************
 *
 * Результат отгрузки
 *
 *****************************************************************************/

import React from "react";
import { TouchableOpacity, Text, View, StyleSheet } from "react-native";
const styles = StyleSheet.create({
    mainContainer: {
        alignItems: "center",
        marginTop: 200
    },
    resultText: {
        fontSize: 34,
        fontWeight: "bold",
        backgroundColor: "transparent",
        color: "black",
        marginHorizontal: 20
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

export const ShipmentResult = props => (
    <View style={styles.mainContainer}>
        <Text style={styles.resultText}>{props.resultText}</Text>
        <TouchableOpacity onPress={props.onPress} style={[styles.cellButton, { marginTop: 300 }]}>
            <Text style={styles.cellText}>ОК</Text>
        </TouchableOpacity>
    </View>
);
