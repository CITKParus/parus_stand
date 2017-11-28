/******************************************************************************
 *
 * Индикатор работы экрана отгрузки
 *
 *****************************************************************************/

import React from "react";
import { ActivityIndicator, Text, View, StyleSheet } from "react-native";
const styles = StyleSheet.create({
    cntainer: {
        alignItems: "center"
    }
});
export const ShipmentLoading = props => (
    <View style={styles.container}>
        <ActivityIndicator
            animating={true}
            color="white"
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
                color: "white"
            }}
        >
            {props.text}
        </Text>
    </View>
);
