/******************************************************************************
 *
 * Индикатор работы экрана сканера
 *
 *****************************************************************************/

import React from "react";
import { ActivityIndicator, Text, View, StyleSheet } from "react-native";
const styles = StyleSheet.create({
    centerContainer: {
        width: 650,
        height: 350,
        marginTop: 250,
        justifyContent: "flex-end",
        alignItems: "center"
    }
});
export const ScanerLoading = props => {
    const { visible } = props;
    if (!visible) return null;
    return (
        <View style={{ alignItems: "center" }}>
            <View style={styles.centerContainer}>
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
                        color: "#FFF"
                    }}
                >
                    {"Хм, посмотрим... ;-)"}
                </Text>
            </View>
        </View>
    );
};
