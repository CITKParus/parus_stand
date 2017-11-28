/******************************************************************************
 *
 * Кнопка с векторной иконкой
 *
 *****************************************************************************/

import React from "react";
import { TouchableOpacity, StyleSheet, Text } from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";
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
    const { onPress, icon, iconColor, iconSize, text, textColor, style } = props;
    return (
        <TouchableOpacity style={[styles.button, style]} onPress={onPress}>
            <Ionicons name={icon} color={iconColor} size={iconSize} style={styles.icon} />
            {text !== null && <Text style={[styles.text, { color: textColor }]}>{text}</Text>}
        </TouchableOpacity>
    );
};
IconButton.defaultProps = {
    iconSize: 30,
    iconColor: "white",
    textColor: "white",
    text: null
};
IconButton.propTypes = {
    icon: PropTypes.string.isRequired,
    onPress: PropTypes.func.isRequired,
    iconSize: PropTypes.number,
    iconColor: PropTypes.string,
    textColor: PropTypes.string,
    text: PropTypes.string
};
