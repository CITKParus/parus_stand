/*
    WEB-монитор стенда
    Список уведомлений стенда
*/

//---------------------
//подключение библиотек
//---------------------

import React from "react"; //классы React
import { List, ListItem } from "material-ui/List"; //классы Material UI для работы со списками
import Subheader from "material-ui/Subheader"; //класс Material UI для подзаголовка
import Divider from "material-ui/Divider"; //класс Material UI для разделителя элементов списка

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
    //отрисовка списка
    drawList(listData) {
        if (listData) {
            if (!_.isEqual(this.state.items, listData.items)) {
            }
        }
    }
    //после подключения компонента
    componentDidMount() {
        this.drawList(this.props.listData);
    }
    //после обновления данных
    componentWillReceiveProps(newProps) {
        this.drawList(newProps.listData);
    }
    //генерация содержимого
    render() {
        let listItems;
        if (this.props.listData.length > 0) {
            listItems = this.props.listData.map((item, i) => {
                return (
                    <div key={i}>
                        <ListItem primaryText={item.text} secondaryText={item.title} />
                        {i != this.props.listData.length - 1 && <Divider />}
                    </div>
                );
            });
        } else {
            listItems = <ListItem primaryText="Список пуст" disabled={true} />;
        }
        return (
            <List>
                <Subheader>Сообщения стенда</Subheader>
                {listItems}
            </List>
        );
    }
}

//----------------
//интерфейс модуля
//----------------

export default NotifyList;
