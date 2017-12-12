/*
    WEB-монитор стенда
    Список уведомлений стенда
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import { List, ListItem } from "material-ui/List"; //классы Material UI для работы со списками
import Divider from "material-ui/Divider"; //класс Material UI для разделителя элементов списка

//-------------------------
//глобальные идентификаторы
//-------------------------

//типы информационных сообщений
const NOTIFY_TYPE_INFO = "INFORMATION"; //информация
const NOTIFY_TYPE_WARN = "WARNING"; //предупреждение
const NOTIFY_TYPE_ERROR = "ERROR"; //ошибка

//цвета информационных сообщений
const NOTIFY_TYPE_INFO_COLOR = ""; //информация
const NOTIFY_TYPE_WARN_COLOR = "rgba(255, 159, 64, 1)"; //предупреждение
const NOTIFY_TYPE_ERROR_COLOR = "rgba(255, 99, 132, 1)"; //ошибка

//----------------
//описание классов
//----------------

//основной класс компонента
class NotifyList extends React.Component {
    //конструктор
    constructor(props) {
        super(props);
        this.state = {
            items: []
        };
    }
    //после подключения компонента
    componentDidMount() {}
    //после обновления данных
    componentWillReceiveProps(newProps) {}
    //генерация содержимого
    render() {
        let listItems;
        if (this.props.listData.length > 0) {
            listItems = this.props.listData.map((item, i) => {
                return (
                    <div key={i}>
                        <ListItem
                            primaryText={item.text}
                            secondaryText={item.title}
                            style={{
                                color:
                                    item.type == NOTIFY_TYPE_WARN
                                        ? NOTIFY_TYPE_WARN_COLOR
                                        : item.type == NOTIFY_TYPE_ERROR
                                          ? NOTIFY_TYPE_ERROR_COLOR
                                          : NOTIFY_TYPE_INFO_COLOR
                            }}
                        />
                        {i != this.props.listData.length - 1 && <Divider />}
                    </div>
                );
            });
        } else {
            listItems = <ListItem primaryText="Уведомлений нет" disabled={true} />;
        }
        return <List>{listItems}</List>;
    }
}

//----------------
//интерфейс модуля
//----------------

export default NotifyList;
