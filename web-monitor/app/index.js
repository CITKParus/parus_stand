/*
    WEB-монитор стенда
    Точка входа в приложение
*/

import React from "react";
import ReactDOM from "react-dom";
import config from "./config";
import Monitor from "./monitor";

console.log(config.server);

ReactDOM.render(<Monitor />, document.getElementById("app-content"));
