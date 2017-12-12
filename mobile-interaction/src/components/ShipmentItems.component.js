/******************************************************************************
 *
 * Интерфейс отгрузки товара
 *
 *****************************************************************************/

import React from "react";
import { Text, StyleSheet, TouchableOpacity, View, Image } from "react-native";
import { ShipmentWelcome } from ".";
const styles = StyleSheet.create({
    cellButton: {
        borderColor: "transparent",
        borderWidth: 1,
        borderRadius: 15,
        backgroundColor: "white",
        marginHorizontal: 20,
        height: 250,
        width: 200,
        justifyContent: "space-between",
        alignItems: "center",
        shadowColor: "rgba(0, 0, 0, 0.5)",
        shadowOpacity: 1,
        shadowRadius: 4,
        shadowOffset: {
            height: 1,
            width: 2
        }
    },
    cellText: {
        color: "black",
        fontSize: 24,
        marginVertical: 10
    },
    cellImage: {
        marginVertical: 15,
        width: 198,
        height: 99
    },
    restContainer: {},
    line: {
        flexDirection: "row",
        alignItems: "center"
    }
});

const renderCellImage = index => {
    switch (index) {
        case 1:
            return <Image source={require("../assets/1.jpg")} resizeMode="contain" style={styles.cellImage} />;
        case 2:
            return <Image source={require("../assets/2.jpg")} resizeMode="contain" style={styles.cellImage} />;
        case 3:
            return <Image source={require("../assets/3.jpg")} resizeMode="contain" style={styles.cellImage} />;
        default:
            return null;
    }
};
//renderCellImage(props.cell.NRACK_LINE_CELL);
export const ShipmentCell = props => (
    <TouchableOpacity onPress={props.onPress} style={styles.cellButton} disabled={props.cell.BEMPTY}>
        {renderCellImage(props.cell.NRACK_LINE_CELL)}
        <Text style={styles.cellText}>{props.cell.NOMEN_RESTS[0].SNOMMODIF}</Text>
        {props.cell.NOMEN_RESTS[0].NREST > 0 ? (
            <Text style={styles.cellText}>{`Осталось ${props.cell.NOMEN_RESTS[0].NREST} шт.`}</Text>
        ) : (
            <Text style={[styles.cellText, { color: "red" }]}>Закончились</Text>
        )}
    </TouchableOpacity>
);

export const ShipmentCells = props => {
    return props.cells.map(cell => (
        <ShipmentCell
            key={cell.NRACK_CELL}
            cell={cell}
            onPress={async () => {
                await props.onPress({
                    customer: props.user,
                    rack_line: cell.NRACK_LINE,
                    rack_line_cell: cell.NRACK_LINE_CELL
                });
            }}
        />
    ));
};
export const ShipmentREST = props => {
    return props.rests.map(line => (
        <View style={styles.line} key={line.NRACK_LINE}>
            <ShipmentCells cells={line.RACK_LINE_CELL_RESTS} user={props.user} onPress={props.onPress} />
        </View>
    ));
};
export const ShipmentContainer = props => (
    <View style={styles.restContainer}>
        <ShipmentWelcome user={props.userName} />
        <ShipmentREST rests={props.rests} user={props.user} onPress={props.onPress} />
    </View>
);
