/*
    WEB-монитор стенда
    Страница мониторинга
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import InfoDialog from "./info_dialog"; //информационный диалог
import RestsNomen from "./rests_nomen"; //диаграмма остатков номенклатуры
import RestsDynamic from "./rests_dynamic"; //диаграмма динамики общих остатков стенда
import NotifyList from "./notify_list"; //список уведомлений стенда
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
            totalRests: -1,
            restsNomen: {},
            restsDynamic: {},
            notifyList: []
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
                    //общий остаток по стенду
                    let tmpTotalRests = r.message.NRESTS_PRC_CURR;
                    //текущие остатки по номенклатурам
                    let tmpRestsNomen = {
                        labels: [],
                        data: [],
                        max: r.message.NOMEN_CONFS[0].NMAX_QUANT,
                        meas: r.message.NOMEN_CONFS[0].SMEAS
                    };
                    r.message.NOMEN_RESTS.forEach(rest => {
                        tmpRestsNomen.labels.push(rest.SNOMMODIF);
                        tmpRestsNomen.data.push(rest.NREST);
                    });
                    //динамика общих остатков стенда
                    let tmpRestsDynamic = {
                        labels: [],
                        data: [],
                        max: 100,
                        meas: "%"
                    };
                    r.message.RACK_REST_PRC_HISTS.forEach((rest, i) => {
                        tmpRestsDynamic.labels.push(i);
                        tmpRestsDynamic.data.push(rest.NREST_PRC);
                    });
                    //список уведомлений стенда
                    let tmpNotifyList = [];
                    r.message.MESSAGES.forEach((m, i) => {
                        tmpNotifyList.push({ title: m.STS, text: m.SMSG.SMSG, type: m.SMSG.SNOTIFY_TYPE });
                    });
                    //теперь всё положим в состояние монитора
                    this.setState(
                        {
                            error: "",
                            restsNomen: tmpRestsNomen,
                            restsDynamic: tmpRestsDynamic,
                            totalRests: tmpTotalRests,
                            notifyList: tmpNotifyList
                        },
                        () => {
                            setTimeout(this.refreshStandState, 1000);
                        }
                    );
                }
            },
            e => {
                this.setState(
                    { error: e.message, restsNomen: {}, restsDynamic: {}, notifyList: [], totalRests: -1 },
                    () => {
                        setTimeout(this.refreshStandState, 1000);
                    }
                );
            }
        );
    }
    //при подключении к странице
    componentDidMount() {
        this.refreshStandState();
    }
    //генерация содержимого
    render() {
        let infoDialog;
        if (this.state.error) {
            infoDialog = (
                <InfoDialog title={"Ошибка получения данных"} text={this.state.error} open={this.state.error != ""} />
            );
        }
        if (this.state.totalRests == 0) {
            infoDialog = (
                <InfoDialog
                    title={"Нехватка товара на сетнеде"}
                    text={"Вендинговый автомат пуст, произведите загрузку!"}
                    open={this.state.totalRests == 0}
                />
            );
        }
        let restsNomen = (
            <div>
                <RestsNomen chartData={this.state.restsNomen} />
            </div>
        );
        let restsDynamic = (
            <div>
                <RestsDynamic chartData={this.state.restsDynamic} />
            </div>
        );
        let notifyList = (
            <div>
                <NotifyList listData={this.state.notifyList} />
            </div>
        );
        return (
            <div className="screen-center">
                {infoDialog}
                <div style={{ backgroundColor: "green4" }} className="monitor-col">
                    <div style={{ backgroundColor: "magenta3" }} className="monitor-line">
                        {restsNomen}
                    </div>
                    <div style={{ backgroundColor: "yellow2" }} className="monitor-line">
                        {restsDynamic}
                    </div>
                </div>
                <div style={{ backgroundColor: "red1" }} className="monitor-col monitor-messages-list">
                    {notifyList}
                </div>
            </div>
        );
    }
}

//----------------
//интерфейс модуля
//----------------

export default Monitor;
