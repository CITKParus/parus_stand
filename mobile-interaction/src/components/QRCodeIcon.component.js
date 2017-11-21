import React from "react";
import MaterialCommunityIcons from "react-native-vector-icons/MaterialCommunityIcons";

export const QRCodeIcon = props => {
    const { visible } = props;
    if (!visible) return null;
    return (
        <MaterialCommunityIcons
            name="qrcode-scan"
            size={200}
            color="white"
            style={{
                backgroundColor: "transparent",
                marginBottom: 50
            }}
        />
    );
};
