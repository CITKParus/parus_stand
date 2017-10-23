import React from "react";
import { TouchableOpacity, StyleSheet } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import PropTypes from "prop-types";
const styles = StyleSheet.create({
    button: {
        position: "absolute",
        top: 30,
        right: 10
    },
    icon: {
        backgroundColor: "transparent"
    }
});
export const IconButton = props => {
    const { onPress, icon, iconSize } = props;
    return (
        <TouchableOpacity style={styles.button} onPress={onPress}>
            <Ionicons name={icon} color="white" size={iconSize} style={styles.icon} />
        </TouchableOpacity>
    );
};
IconButton.defaultProps = {
    iconSize: 30
};
IconButton.propTypes = {
    icon: PropTypes.string.isRequired,
    onPress: PropTypes.func.isRequired,
    iconSize: PropTypes.number
};
