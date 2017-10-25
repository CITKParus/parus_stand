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

//основной класс компонента
class Monitor extends React.Component {
    //конструктор класса
    constructor(props) {
        super(props);
        this.state = {
            error: "",
            nomenRests: {}
        };
        this.refreshStandState = this.refreshStandState.bind(this);
    }
    //обновление состояния стенда
    refreshStandState() {
        client.standServerAction({ actionData: { action: client.SERVER_ACTION_STAND_GET_STATE } }).then(
            r => {
                if (r.state == client.SERVER_STATE_ERR) {
                    this.setState({ error: r.message });
                } else {
                    let tmp = {
                        labels: [],
                        data: [],
                        max: r.message.NOMEN_CONFS[0].NMAX_QUANT
                    };
                    r.message.NOMEN_RESTS.forEach(rest => {
                        tmp.labels.push(rest.SNOMMODIF);
                        tmp.data.push(rest.NREST);
                    });
                    this.setState({ error: "", nomenRests: tmp }, () => {
                        setTimeout(this.refreshStandState, 1000);
                    });
                }
            },
            e => {
                this.setState({ error: e.message, nomenRests: {} }, () => {
                    setTimeout(this.refreshStandState, 1000);
                });
            }
        );
    }
    //при подключении к странице
    componentDidMount() {
        this.refreshStandState();
    }
    //генерация содержимого
    render() {
        let monitror;
        if (this.state.error) {
            monitror = (
                <h4>
                    <center>{this.state.error}</center>
                </h4>
            );
        } else {
            monitror = (
                <div>
                    <RestNomen chartData={this.state.nomenRests} />
                </div>
            );
        }
        return <div className="screen-center">{monitror}</div>;
    }
}

//----------------
//интерфейс модуля
//----------------

export default Monitor;
