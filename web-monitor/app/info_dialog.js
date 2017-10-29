/*
    WEB-монитор стенда
    Информационный диалог
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import Dialog from "material-ui/Dialog"; //базовый класс диалога Material UI

//----------------
//описание классов
//----------------

//основной класс компонента
class InfoDialog extends React.Component {
    //конструктор
    constructor(props) {
        super(props);
    }
    //генерация содержимого
    render() {
        return (
            <div>
                <Dialog title={this.props.title} modal={false} open={this.props.open}>
                    {this.props.text}
                </Dialog>
            </div>
        );
    }
}

//----------------
//интерфейс модуля
//----------------

export default InfoDialog;
