/******************************************************************************
 *
 * Приветствие пользователя на экране отгрузки
 *
 *****************************************************************************/

import React from "react";
import { Text, StyleSheet, TouchableOpacity, View } from "react-native";
const styles = StyleSheet.create({
    welcomeContainer: {
        marginBottom: 100,
        alignItems: "center",
        backgroundColor: "transparent"
    },
    welcome: {
        lineHeight: 38,
        fontSize: 34,
        marginBottom: 10,
        color: "white",
        backgroundColor: "transparent"
    }
});
export const ShipmentWelcome = props => (
    <View style={styles.welcomeContainer}>
        <Text style={styles.welcome}>{"Здравствуйте,"}</Text>
        <Text style={styles.welcome}>{props.user.trim()},</Text>
        <Text style={styles.welcome}>{"укажите желаемый товар"}</Text>
    </View>
);
