﻿/*
    WEB-монитор стенда
    Страница мониторинга
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import AppBar from "material-ui/AppBar"; //заголовок приложения
import InfoDialog from "./info_dialog"; //информационный диалог
import RestsNomen from "./rests_nomen"; //диаграмма остатков номенклатуры
import RestsDynamic from "./rests_dynamic"; //диаграмма динамики общих остатков стенда
import NotifyList from "./notify_list"; //список уведомлений стенда
import StandState from "./stand_state"; //состояние стенда
import AddAgent from "./add_agent"; //компонент для добавления контрагента
import client from "./client"; //клиент для доступа к серверу стенда
import config from "./config"; //настройки приложения

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
            notifyList: [],
            standState: {}
        };
        this.refreshStandState = this.refreshStandState.bind(this);
        this.showErrorAndRefresh = this.showErrorAndRefresh.bind(this);
        this.showDataAndRefresh = this.showDataAndRefresh.bind(this);
    }
    //отображение ошибки стенда и перезапрос данных
    showErrorAndRefresh(message) {
        this.setState({ error: message, restsNomen: {}, restsDynamic: {}, notifyList: [], totalRests: -1 }, () => {
            setTimeout(this.refreshStandState, config.REFRESH_RATE);
        });
    }
    //отображение данных стенда и перезапрос
    showDataAndRefresh(restsNomen, restsDynamic, totalRests, notifyList, standState) {
        this.setState(
            {
                error: "",
                restsNomen,
                restsDynamic,
                totalRests,
                notifyList,
                standState
            },
            () => {
                setTimeout(this.refreshStandState, config.REFRESH_RATE);
            }
        );
    }
    //обновление состояния стенда
    refreshStandState() {
        client.standServerAction({ actionData: { action: client.SERVER_ACTION_STAND_GET_STATE } }).then(
            r => {
                if (r.state == client.SERVER_STATE_ERR) {
                    this.showErrorAndRefresh(r.message);
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
                    r.message.RACK_REST_PRC_HISTS.reverse().forEach((rest, i) => {
                        tmpRestsDynamic.labels.push(i);
                        tmpRestsDynamic.data.push(rest.NREST_PRC);
                    });
                    //список уведомлений стенда
                    let tmpNotifyList = [];
                    r.message.MESSAGES.forEach((m, i) => {
                        tmpNotifyList.push({ title: m.STS, text: m.SMSG.SMSG, type: m.SMSG.SNOTIFY_TYPE });
                    });
                    //состояние стенда
                    let tmpStandState = {
                        state: r.message.SERVICE_STATE.SSTATE,
                        customerName: r.message.SERVICE_STATE.SAGENT_NAME,
                        restPrc: r.message.NRESTS_PRC_CURR
                    };
                    //теперь всё положим в состояние монитора
                    this.showDataAndRefresh(
                        tmpRestsNomen,
                        tmpRestsDynamic,
                        tmpTotalRests,
                        tmpNotifyList,
                        tmpStandState
                    );
                }
            },
            e => {
                //покажем ошибку
                this.showErrorAndRefresh(e.message);
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
                    title={"Нехватка товара на стенде"}
                    text={"Вендинговый автомат пуст, произведите загрузку!"}
                    open={this.state.totalRests == 0}
                />
            );
        }
        let restsNomen = (
            <div className="monitor-chart">
                <RestsNomen chartData={this.state.restsNomen} />
            </div>
        );
        let restsDynamic = (
            <div className="monitor-chart">
                <RestsDynamic chartData={this.state.restsDynamic} />
            </div>
        );
        let notifyList = (
            <div>
                <NotifyList listData={this.state.notifyList} />
            </div>
        );
        let stansState = (
            <div className="monitor-stand-state">
                <StandState stateData={this.state.standState} />
            </div>
        );
        let addAgent = (
            <div className="monitor-add-agent">
                <AddAgent />
            </div>
        );
        return (
            <div>
                <AppBar
                    zDepth={3}
                    style={{ backgroundColor: "rgb(8, 86, 135)" }}
                    title={<span className="monitor-bar-title">Парус - мониторинг</span>}
                    iconElementLeft={<img className="monitor-bar-logo" src="img/parus_logo.png" />}
                />
                <div className="screen-center">
                    {infoDialog}
                    <div className="monitor-col">
                        <div className="monitor-line">{restsNomen}</div>
                        <div className="monitor-line">{restsDynamic}</div>
                    </div>
                    {/*<div className="monitor-col monitor-messages-list">{notifyList}</div>*/}
                    {/*<div className="monitor-col">{stansState}</div>*/}
                    <div className="monitor-col">
                        <div className="monitor-line">{stansState}</div>
                        <div className="monitor-line">{addAgent}</div>
                    </div>
                </div>
            </div>
        );
    }
}

//----------------
//интерфейс модуля
//----------------

export default Monitor;
