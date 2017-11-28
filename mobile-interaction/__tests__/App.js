/******************************************************************************
 *
 * Тестирование приложения и отдельных компонент
 *
 *    .∧＿∧
 *    ( ･ω･｡)つ━☆・*。
 *    ⊂　 ノ 　　　・゜+.
 *    しーＪ　　　°。+ *´¨)
 *    　　　　　　　　　.· ´¸.·*´¨) ¸.·*¨)
 *    　　　　　　　　(¸.·´ (¸.·'* ☆ вжух, вжух и в продакшен
 *****************************************************************************/

import "react-native";
import React from "react";
import App from "../App";

// Note: test renderer must be required after react-native.
import renderer from "react-test-renderer";

it("renders correctly", () => {
    const tree = renderer.create(<App />);
});
