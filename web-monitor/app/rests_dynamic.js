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

//-------
//функции
//-------

const getInitialChartState = () => {
    return {
        type: "line",
        data: {
            labels: [],
            datasets: [
                {
                    backgroundColor: ["rgba(153, 102, 255, 0.4)"],
                    borderColor: ["rgb(153, 102, 255)"],
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
    };
};

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
            itemChart: null
        };
    }
    //отрисовка графика
    drawChart(chartData) {
        if (chartData.data) {
            if (!_.isEqual(this.state.itemChart.data.datasets[0].data, chartData.data)) {
                if (this.state.itemChart) {
                    this.state.itemChart.destroy();
                }
                let tmp = getInitialChartState();
                _.extend(tmp.data.labels, chartData.labels);
                _.extend(tmp.data.datasets[0].data, chartData.data);
                tmp.options.scales.yAxes[0].ticks.max = chartData.max;
                if (chartData.meas) tmp.options.title.text = "Динамика остатков (" + chartData.meas + ")";
                let ctx = document.getElementById("RestsDynamic").getContext("2d");
                this.setState({ itemChart: new Chart(ctx, tmp) });
            }
        } else {
            if (this.state.itemChart) {
                this.state.itemChart.destroy();
            }
            let ctx = document.getElementById("RestsDynamic").getContext("2d");
            this.setState({ itemChart: new Chart(ctx, getInitialChartState()) });
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
