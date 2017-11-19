import React from "react";
import { StyleSheet, Image, TouchableOpacity } from "react-native";

const styles = StyleSheet.create({
    logoContainer: {
        position: "absolute",
        top: 30,
        left: 10
    },
    logo: {
        height: 100,
        width: 100
    }
});
export const LogoButton = props => {
    const { onPress } = props;
    return (
        <TouchableOpacity style={styles.logoContainer} onPress={onPress}>
            <Image source={require("../assets/icons/parus_logo.png")} style={styles.logo} />
        </TouchableOpacity>
    );
};
