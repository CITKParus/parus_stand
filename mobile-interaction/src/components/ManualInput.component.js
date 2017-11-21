import React from "react";
import { StyleSheet, Text, TextInput, TouchableOpacity, View } from "react-native";

const styles = StyleSheet.create({
    container: {
        justifyContent: "flex-end",
        alignItems: "center"
    },
    textInput: {
        color: "#FFF",
        fontSize: 30,
        borderWidth: 0.5,
        borderColor: "#FFF",
        width: 400,
        padding: 15
    },
    button: {
        width: 150,
        height: 70,
        marginTop: 30,
        marginBottom: 60,
        justifyContent: "center",
        backgroundColor: "white"
    },
    buttonText: {
        fontSize: 22,
        alignSelf: "center",
        backgroundColor: "transparent",
        color: "black"
    }
});

export const ManualInput = props => {
    const { onChangeText, onSubmitEditing, visible } = props;
    if (!visible) return null;
    return (
        <View style={styles.container}>
            <TextInput
                style={styles.textInput}
                placeholder="Код с бейджа"
                placeholderTextColor="#f0f0f0"
                onChangeText={onChangeText}
                onSubmitEditing={onSubmitEditing}
                returnKeyType="next"
                keyboardType="numeric"
            />
            <TouchableOpacity style={styles.button} onPress={onSubmitEditing}>
                <Text style={styles.buttonText}>ОК</Text>
            </TouchableOpacity>
        </View>
    );
};
