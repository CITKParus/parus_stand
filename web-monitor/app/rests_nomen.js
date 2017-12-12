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

//-------
//функции
//-------

const getInitialChartState = () => {
    return {
        type: "bar",
        data: {
            labels: [],
            datasets: [
                {
                    backgroundColor: ["rgba(255, 99, 132, 0.4)", "rgba(255, 159, 64, 0.4)", "rgba(75, 192, 192, 0.4)"],
                    borderColor: ["rgb(255, 99, 132)", "rgb(255, 159, 64)", "rgb(75, 192, 192)"],
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
    };
};

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
                _.assign(tmp.data.labels, chartData.labels);
                _.assign(tmp.data.datasets[0].data, chartData.data);
                tmp.options.scales.yAxes[0].ticks.max = chartData.max;
                if (chartData.meas) tmp.options.title.text = "Остатки номенклатуры (" + chartData.meas + ")";
                let ctx = document.getElementById("RestsNomen").getContext("2d");
                this.setState({ itemChart: new Chart(ctx, tmp) });
            }
        } else {
            if (this.state.itemChart) {
                this.state.itemChart.destroy();
            }
            let ctx = document.getElementById("RestsNomen").getContext("2d");
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
        return <canvas id="RestsNomen" />;
    }
}

//----------------
//интерфейс модуля
//----------------

export default RestsNomen;
