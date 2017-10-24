/*
    WEB-монитор стенда
    Остатки номенклатуры
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import Chart from "chart.js"; //работа с графиками и диаграммами

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
            itemChart: null //график
        };
    }
    //отрисовка графика
    drawChart() {
        if (this.props.chartData) {
            if (this.state.itemChart) {
                this.state.itemChart.destroy();
            }
            let ctx = document.getElementById("NomenRests").getContext("2d");
            this.setState({ itemChart: new Chart(ctx, this.props.chartData) });
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
