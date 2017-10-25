/*
    WEB-монитор стенда
    Страница мониторинга
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import RestNomen from "./rests_nomen"; //диаграмма остатков номенклатуры
import client from "./client"; //клиент для доступа к серверу стенда

//----------------
//описание классов
//----------------

class Monitor extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            nomenRests: {} //остатки номенклатур
        };
        this.getRandomInt = this.getRandomInt.bind(this);
        this.refreshStandState = this.refreshStandState.bind(this);
    }
    getRandomInt() {
        return Math.floor(Math.random() * (100 - 0)) + 0;
    }
    refreshStandState() {
        /*
        let tmp = {
            labels: ["Orbit", "Dirol", "Wrigley"],
            data: [this.getRandomInt(), this.getRandomInt(), this.getRandomInt()]
        };
        this.setState({ nomenRests: tmp }, () => {
            setTimeout(this.refreshStandState, 1000);
        });
        */

        client.standServerAction({ actionData: { action: client.SERVER_ACTION_STAND_GET_STATE } }).then(
            r => {
                console.log(r);
            },
            e => {
                console.log(e);
            }
        );
    }
    componentDidMount() {
        this.refreshStandState();
    }
    render() {
        return (
            <div className="screen-center">
                <div className="mdl-grid monitor-line">
                    <div className="mdl-cell mdl-cell--6-col mdl-cell--middle monitor-line-cell">
                        <RestNomen chartData={this.state.nomenRests} />
                    </div>
                    <div className="mdl-cell mdl-cell--6-col mdl-cell--middle monitor-line-cell">Тут журнал</div>
                </div>
                <div className="mdl-grid monitor-line">
                    <div className="mdl-cell mdl-cell--6-col mdl-cell--middle monitor-line-cell">Тут график</div>
                    <div className="mdl-cell mdl-cell--6-col mdl-cell--middle monitor-line-cell">Здесь состояние</div>
                </div>
            </div>
        );
    }
}

//----------------
//интерфейс модуля
//----------------

export default Monitor;
