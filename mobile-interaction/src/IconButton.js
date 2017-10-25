import React from "react";
import { TouchableOpacity, StyleSheet, Text } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import PropTypes from "prop-types";
const styles = StyleSheet.create({
    button: {
        position: "absolute",
        top: 30,
        right: 10,
        flexDirection: "row",
        alignItems: "center"
    },
    icon: {
        backgroundColor: "transparent"
    },
    text: {
        paddingLeft: 10,
        fontSize: 16
    }
});
export const IconButton = props => {
    const { onPress, icon, iconColor, iconSize, text, style } = props;
    return (
        <TouchableOpacity style={[styles.button, style]} onPress={onPress}>
            <Ionicons name={icon} color={iconColor} size={iconSize} style={styles.icon} />
            {text !== null && <Text style={styles.text}>{text}</Text>}
        </TouchableOpacity>
    );
};
IconButton.defaultProps = {
    iconSize: 30,
    iconColor: "white",
    text: null
};
IconButton.propTypes = {
    icon: PropTypes.string.isRequired,
    onPress: PropTypes.func.isRequired,
    iconSize: PropTypes.number,
    iconColor: PropTypes.string,
    text: PropTypes.string
};
