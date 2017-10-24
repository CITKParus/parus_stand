/*
    WEB-монитор стенда
    Точка входа в приложение
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import ReactDOM from "react-dom"; //работа с DOM в React
import Monitor from "./monitor"; //корневой компонент монитора

//-----------
//точка входа
//-----------

ReactDOM.render(<Monitor />, document.getElementById("app-content"));
