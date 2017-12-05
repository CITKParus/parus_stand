/******************************************************************************
 *
 * Сообщение об ошибке
 *
 *****************************************************************************/

import React from "react";
import { Text, StyleSheet, TouchableOpacity, View } from "react-native";
const styles = StyleSheet.create({
    errorContainer: {
        marginHorizontal: 50,
        alignItems: "center",
        backgroundColor: "transparent"
    },
    errorText: {
        lineHeight: 38,
        fontSize: 34,
        marginVertical: 10,
        color: "white",
        backgroundColor: "transparent"
    },
    button: {
        width: 400,
        height: 70,
        borderWidth: 0.5,
        borderColor: "#FFF",
        marginTop: 50,
        justifyContent: "center"
    },
    buttonText: {
        fontSize: 22,
        alignSelf: "center",
        backgroundColor: "transparent",
        color: "#FFF"
    }
});
export const Error = props => (
    <View style={[styles.errorContainer, props.marginTop ? { marginTop: 400 } : {}]}>
        <Text style={styles.errorText}>{"Произошла ошибка :("}</Text>
        <Text style={styles.errorText}>{props.text}</Text>
        <TouchableOpacity style={styles.button} onPress={props.onPress}>
            <Text style={styles.buttonText}>OK</Text>
        </TouchableOpacity>
    </View>
);
