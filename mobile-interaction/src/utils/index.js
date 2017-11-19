import { NetInfo } from "react-native";
export const connected = () => {
    const connection = NetInfo.getConnectionInfo();
    if (connection.type === "none") {
        return false;
    } else {
        return true;
    }
};
