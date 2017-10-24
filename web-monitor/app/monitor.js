/*
    WEB-монитор стенда
    Страница мониторинга
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import RestNomen from "./rests_nomen"; //диаграмма остатков номенклатуры

//----------------
//описание классов
//----------------

class Monitor extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            nomenRests: {
                type: "bar",
                data: {
                    title: "Остатки номенклатуры",
                    labels: ["Orbit", "Dirol", "Wrigley"],
                    datasets: [{ label: "% остатка", data: ["50", "50", "45"] }]
                },
                options: {
                    categoryPercentage: 1,
                    scales: {
                        yAxes: [
                            {
                                display: true,
                                ticks: {
                                    suggestedMin: 0,
                                    suggestedMax: 100
                                }
                            }
                        ]
                    }
                }
            }
        };
    }
    getRandomInt() {
        return Math.floor(Math.random() * (100 - 0)) + 0;
    }
    componentDidMount() {
        setInterval(() => {
            let tmp = {
                type: "bar",
                data: {
                    title: "Остатки номенклатуры",
                    labels: ["Orbit", "Dirol", "Wrigley"],
                    datasets: [
                        { label: "% остатка", data: [this.getRandomInt(), this.getRandomInt(), this.getRandomInt()] }
                    ]
                },
                options: {
                    categoryPercentage: 1,
                    scales: {
                        yAxes: [
                            {
                                display: true,
                                ticks: {
                                    suggestedMin: 0,
                                    suggestedMax: 100
                                }
                            }
                        ]
                    }
                }
            };
            this.setState({ nomenRests: tmp });
        }, 1000);
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
