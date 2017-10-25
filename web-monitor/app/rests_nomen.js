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
Chart.defaults.global.responsive = true;

//основной класс компонента
class RestsNomen extends React.Component {
    //конструктор
    constructor(props) {
        super(props);
        this.state = {
            itemChart: null,
            chartOptions: {
                type: "bar",
                data: {
                    labels: [],
                    datasets: [
                        {
                            backgroundColor: "rgba(255, 99, 132, 0.2)",
                            borderColor: "rgb(255, 99, 132)",
                            borderWidth: 1,
                            data: []
                        }
                    ]
                },
                options: {
                    title: {
                        display: true,
                        text: "Остатки номенклатуры"
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
    drawChart() {
        if (this.props.chartData) {
            if (!_.isEqual(this.state.chartOptions.data.datasets[0].data, this.props.chartData.data)) {
                if (this.state.itemChart) {
                    this.state.itemChart.destroy();
                }
                let tmp = {};
                _.extend(tmp, this.state.chartOptions);
                _.extend(tmp.data.labels, this.props.chartData.labels);
                _.extend(tmp.data.datasets[0].data, this.props.chartData.data);
                tmp.options.scales.yAxes[0].ticks.max = this.props.chartData.max;
                let ctx = document.getElementById("NomenRests").getContext("2d");
                this.setState({ itemChart: new Chart(ctx, tmp) });
            }
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
    //генерация содержимого
    render() {
        return <canvas id="NomenRests" className="chart-item" />;
    }
}

//----------------
//интерфейс модуля
//----------------

export default RestsNomen;
