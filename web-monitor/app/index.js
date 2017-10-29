/*
    WEB-монитор стенда
    Точка входа в приложение
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import ReactDOM from "react-dom"; //работа с DOM в React
import MuiThemeProvider from "material-ui/styles/MuiThemeProvider"; //тема для Material UI
import Monitor from "./monitor"; //корневой компонент монитора

//-----------
//точка входа
//-----------

ReactDOM.render(
    <MuiThemeProvider>
        <Monitor />
    </MuiThemeProvider>,
    document.getElementById("app-content")
);
