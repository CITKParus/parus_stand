/*
    WEB-монитор стенда
    Состояние стенда
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import { List, ListItem } from "material-ui/List"; //классы Material UI для работы со списками
import Paper from "material-ui/Paper"; //классы Material UI для контейнера с тенью
import ReactCSSTransitionGroup from "react-addons-css-transition-group";

//-------------------------
//глобальные идентификаторы
//-------------------------

//состояния сервиса стенда
const SERVICE_STATE_FREE = "FREE"; //свободен - ожидаем следующего посетителя
const SERVICE_STATE_WAIT_FOR_NOMEN = "WAIT_FOR_NOMEN"; //работаем с посетителем - ожидаем выбора номенклатуры
const SERVICE_STATE_SHIPING = "SHIPING"; //работаетм с посетителем - отгружаем

//пороговые состояния загруженности стенда
const NRESTS_LIMIT_PRC_MIN = { value: 40, color: "red" }; //Минимальный критический остаток по складу (в %)
const NRESTS_LIMIT_PRC_MDL = { value: 60, color: "orange" }; //Средний остаток по складу (в %)
const NRESTS_LIMIT_PRC_MAX = { value: 100, color: "green" }; //Максимальный остаток по складу (в %)

//----------------
//описание классов
//----------------

//основной класс компонента
class StandState extends React.Component {
    //конструктор
    constructor(props) {
        super(props);
        this.state = {
            stateData: {},
            stateItems: []
        };
    }
    //отрисовка состояния стенда
    drawState(stateData) {
        if (stateData) {
            //если состояние менялось - соберем новое
            if (!_.isEqual(this.state.stateData, stateData)) {
                const tmpStateItems = [];
                //текущая операция на стенде
                if (stateData.state) {
                    let currentOperationItem = "";
                    switch (stateData.state) {
                        case SERVICE_STATE_FREE: {
                            currentOperationItem = { text: "СВОБОДЕН" };
                            break;
                        }
                        case SERVICE_STATE_WAIT_FOR_NOMEN: {
                            currentOperationItem = { text: "ОЖИДАЮ ВЫБОР НОМЕНКЛАТУРЫ" };
                            break;
                        }
                        case SERVICE_STATE_SHIPING: {
                            currentOperationItem = { text: "ОТГРУЖАЮ" };
                            break;
                        }
                        default: {
                            currentOperationItem = { text: "" };
                            break;
                        }
                    }
                    tmpStateItems.push(currentOperationItem);
                }
                //текущий посетитель
                if (stateData.customerName) {
                    tmpStateItems.push({ text: "ПОСЕТИТЕЛЬ: " + stateData.customerName });
                }
                //текущая загруженность
                if (stateData.restPrc) {
                    let curColor = NRESTS_LIMIT_PRC_MAX.color;
                    if (stateData.restPrc < NRESTS_LIMIT_PRC_MDL.value) curColor = NRESTS_LIMIT_PRC_MDL.color;
                    if (stateData.restPrc < NRESTS_LIMIT_PRC_MIN.value) curColor = NRESTS_LIMIT_PRC_MIN.color;
                    tmpStateItems.push({ text: "ЗАГРУЖЕННОСТЬ СТЕНДА: " + stateData.restPrc + "%", color: curColor });
                }
                this.setState({ stateItems: tmpStateItems, stateData: stateData });
            }
        }
    }
    //после подключения компонента
    componentDidMount() {
        this.drawState(this.props.stateData);
    }
    //после обновления данных
    componentWillReceiveProps(newProps) {
        this.drawState(newProps.stateData);
    }
    //генерация содержимого
    render() {
        const items = this.state.stateItems.map((item, i) => (
            <ListItem
                key={item.text}
                disabled={true}
                primaryText={item.text}
                style={{ color: item.color, fontSize: "25px" }}
            />
        ));
        return (
            <Paper className="monitor-stand-state-paper" zDepth={3}>
                <List>
                    <ReactCSSTransitionGroup
                        transitionName="monitor-stand-state-info"
                        transitionEnterTimeout={1000}
                        transitionLeaveTimeout={500}
                    >
                        {items}
                    </ReactCSSTransitionGroup>
                </List>
            </Paper>
        );
    }
}

//----------------
//интерфейс модуля
//----------------

export default StandState;
