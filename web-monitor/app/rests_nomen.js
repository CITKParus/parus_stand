/*
    WEB-монитор стенда
    Остатки номенклатуры
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import Chart from "chart.js"; //работа с графиками и диаграммами
import _ from "lodash"; //работа с коллекциями и объектами

//----------------
//описание классов
//----------------

//параметры графиков
Chart.defaults.global.responsive = false;

class RestsNomen extends React.Component {
    //конструктор
    constructor(props) {
        super(props);
        this.state = {
            itemChart: null, //график
            chartOptions: {
                //настройки графика
                type: "bar",
                data: {
                    title: "Остатки номенклатуры",
                    labels: [],
                    datasets: [{ label: "% остатка", data: [] }]
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
    //отрисовка графика
    drawChart() {
        if (this.props.chartData) {
            if (this.state.itemChart) {
                this.state.itemChart.destroy();
            }
            let tmp = {};
            _.extend(tmp, this.state.chartOptions);
            _.extend(tmp.data.labels, this.props.chartData.labels);
            _.extend(tmp.data.datasets[0].data, this.props.chartData.data);
            let ctx = document.getElementById("NomenRests").getContext("2d");
            this.setState({ itemChart: new Chart(ctx, tmp) });
        }
    }
    //после подключения компонента
    componentDidMount() {
        this.drawChart();
    }
    //после обновления данных
    componentWillReceiveProps() {
        this.drawChart();
    }
    render() {
        return <canvas id="NomenRests" width="350" height="350" />;
    }
}

//----------------
//интерфейс модуля
//----------------

export default RestsNomen;
