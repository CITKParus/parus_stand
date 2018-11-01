/*
    WEB-монитор стенда
    Добавление контрагента
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import RaisedButton from "material-ui/RaisedButton"; //классы Material UI для работы со списками
import TextField from "material-ui/TextField"; //классы Material UI для работы с полями ввода
import Paper from "material-ui/Paper"; //классы Material UI для контейнера с тенью
import CircularProgress from "material-ui/CircularProgress"; //классы Material UI для прогресс-бара
import _ from "lodash"; //работа с массивами и объектами
import client from "./client"; //клиент для доступа к серверу ПП Парус 8

//-------------------------
//глобальные идентификаторы
//-------------------------

//состояния компонента добавления контрагента
const VIEW_STATE_DEFAULT = "DEFAULT"; //по умолчанию
const VIEW_STATE_FORM = "FORM"; //отображается форма добавления
const VIEW_STATE_ADDING = "ADDING"; //происходит добавление
const VIEW_STATE_MESSAGE = "MESSAGE"; //отображение сообщения

//----------------
//описание классов
//----------------

//основной класс компонента
class AddAgent extends React.Component {
    //конструктор
    constructor(props) {
        super(props);
        this.state = {
            currentView: VIEW_STATE_DEFAULT,
            message: "",
            mnemo: ""
        };
        this.showAddForm = this.showAddForm.bind(this);
        this.hideAddForm = this.hideAddForm.bind(this);
        this.showMessage = this.showMessage.bind(this);
        this.hideMessage = this.hideMessage.bind(this);
        this.showProgress = this.showProgress.bind(this);
        this.makeAdd = this.makeAdd.bind(this);
        this.handleMnemoChange = this.handleMnemoChange.bind(this);
    }
    //отображение формы добалвения
    showAddForm(btn) {
        let tmpState = {};
        _.extend(tmpState, this.state);
        tmpState.currentView = VIEW_STATE_FORM;
        this.setState(tmpState);
    }
    //сокрытие формы добалвения
    hideAddForm(btn) {
        let tmpState = {};
        _.extend(tmpState, this.state);
        tmpState.currentView = VIEW_STATE_DEFAULT;
        tmpState.mnemo = "";
        this.setState(tmpState);
    }
    //отображение сообщения
    showMessage(message) {
        let tmpState = {};
        _.extend(tmpState, this.state);
        tmpState.currentView = VIEW_STATE_MESSAGE;
        tmpState.message = message;
        this.setState(tmpState);
    }
    //сокрытие сообщения
    hideMessage(btn) {
        let tmpState = {};
        _.extend(tmpState, this.state);
        tmpState.currentView = VIEW_STATE_DEFAULT;
        tmpState.message = "";
        this.setState(tmpState);
    }
    //отображение прогресса
    showProgress(callBack) {
        let tmpState = {};
        _.extend(tmpState, this.state);
        tmpState.currentView = VIEW_STATE_ADDING;
        this.setState(tmpState, callBack);
    }
    //выполнение добавления
    makeAdd(btn) {
        let tmpMnemo = this.state.mnemo;
        this.setState({ mnemo: "" }, () => {
            this.showProgress(() => {
                setTimeout(() => {
                    client.standServerAction({ actionData: { action: "ADD_AGENT", mnemo: tmpMnemo } }).then(
                        //запрос отработал
                        r => {
                            if (r.state == client.SERVER_STATE_ERR) {
                                this.showMessage(r.message);
                            } else {
                                this.showMessage(r.message);
                            }
                        },
                        //ошибка на транспортном уровне
                        e => {
                            this.showMessage(r.message);
                        }
                    );
                }, 1000);
            });
        });
    }
    //считывание значение поля ввода мнемокода контрагента
    handleMnemoChange(e) {
        let tmpState = {};
        _.extend(tmpState, this.state);
        tmpState.mnemo = e.target.value;
        this.setState(tmpState);
    }
    //генерация содержимого
    render() {
        //контейнер для содержимого компонента
        let content;
        //состояние по умолчанию
        if (this.state.currentView == VIEW_STATE_DEFAULT) {
            content = <RaisedButton label="Добавить контрагента" primary={true} onClick={this.showAddForm} />;
        }
        //состояние отображения формы ввода
        if (this.state.currentView == VIEW_STATE_FORM) {
            content = (
                <div>
                    <TextField hintText="Мнемокод контрагента" onChange={this.handleMnemoChange} />
                    <br />
                    <RaisedButton label="OK" primary={false} onClick={this.makeAdd} />
                    &nbsp;&nbsp;
                    <RaisedButton label="Отмена" primary={true} onClick={this.hideAddForm} />
                </div>
            );
        }
        //состояние отображения сообщения
        if (this.state.currentView == VIEW_STATE_MESSAGE) {
            content = (
                <div>
                    <h3>{this.state.message}</h3>
                    <br />
                    <RaisedButton label="Закрыть" primary={true} onClick={this.hideMessage} />
                </div>
            );
        }
        //состояние выполнения действия
        if (this.state.currentView == VIEW_STATE_ADDING) {
            content = (
                <div>
                    <CircularProgress />
                    <h3>Добавляю...</h3>
                </div>
            );
        }
        //финальная сборка компонента
        return (
            <Paper className="monitor-add-agent-paper" zDepth={3}>
                {content}
            </Paper>
        );
    }
}

//----------------
//интерфейс модуля
//----------------

export default AddAgent;
