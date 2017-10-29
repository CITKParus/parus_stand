/*
    WEB-монитор стенда
    Динамика общих остатков стенда
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
Chart.defaults.global.responsive = true;

//основной класс компонента
class RestsDynamic extends React.Component {
    //конструктор
    constructor(props) {
        super(props);
        this.state = {
            itemChart: null,
            chartOptions: {
                type: "line",
                data: {
                    labels: [],
                    datasets: [
                        {
                            backgroundColor: "rgba(75, 192, 192, 0.2)",
                            borderColor: "rgb(75, 192, 192)",
                            borderWidth: 1,
                            data: []
                        }
                    ]
                },
                options: {
                    title: {
                        display: true,
                        text: "Динамика остатков"
                    },
                    legend: {
                        display: false
                    },
                    scales: {
                        yAxes: [
                            {
                                display: true,
                                ticks: {
                                    min: 0,
                                    max: 100
                                }
                            }
                        ]
                    }
                }
            }
        };
    }
    //отрисовка графика
    drawChart(chartData) {
        if (chartData) {
            if (!_.isEqual(this.state.chartOptions.data.datasets[0].data, chartData.data)) {
                if (this.state.itemChart) {
                    this.state.itemChart.destroy();
                }
                let tmp = {};
                _.extend(tmp, this.state.chartOptions);
                _.extend(tmp.data.labels, chartData.labels);
                _.extend(tmp.data.datasets[0].data, chartData.data);
                tmp.options.scales.yAxes[0].ticks.max = chartData.max;
                if (chartData.meas) tmp.options.title.text = "Динамика остатков (" + chartData.meas + ")";
                let ctx = document.getElementById("RestsDynamic").getContext("2d");
                this.setState({ itemChart: new Chart(ctx, tmp) });
            }
        }
    }
    //после подключения компонента
    componentDidMount() {
        this.drawChart(this.props.chartData);
    }
    //после обновления данных
    componentWillReceiveProps(newProps) {
        this.drawChart(newProps.chartData);
    }
    //генерация содержимого
    render() {
        return <canvas id="RestsDynamic" />;
    }
}

//----------------
//интерфейс модуля
//----------------

export default RestsDynamic;
