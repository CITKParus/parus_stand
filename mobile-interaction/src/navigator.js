import React from "react";
import { StackNavigator } from "react-navigation";
import ScanerPage from "./ScanerPage";
import SettingsPage from "./SettingsPage";

const FlowNivigator = StackNavigator(
    {
        First: { screen: ScanerPage }
    },
    {
        headerMode: "none",
        initialRouteName: "First"
    }
);
const AppNavigator = StackNavigator(
    {
        Flow: { screen: FlowNivigator },
        Settings: { screen: SettingsPage }
    },
    {
        initialRouteName: "Flow",
        headerMode: "float"
    }
);

export default AppNavigator;
