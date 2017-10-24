/*
    WEB-монитор стенда
    Страница мониторинга
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //React

//----------------
//описание классов
//----------------

class Monitor extends React.Component {
    render() {
        return (
            <div>
                <div className="mdl-grid">
                    <div className="mdl-cell mdl-cell--6-col mdl-cell--middle">Здесь диаграмма</div>
                    <div className="mdl-cell mdl-cell--6-col mdl-cell--middle">Тут журнал</div>
                </div>
                <div className="mdl-grid">
                    <div className="mdl-cell mdl-cell--6-col mdl-cell--middle">Тут график</div>
                    <div className="mdl-cell mdl-cell--6-col mdl-cell--middle">Здесь состояние</div>
                </div>
            </div>
        );
    }
}

//----------------
//интерфейс модуля
//----------------

export default Monitor;
