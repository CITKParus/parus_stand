prompt PL/SQL Developer import file
prompt Created on 29 Ноябрь 2017 г. by mikha
set feedback off
set define off
prompt Loading UDO_T_WEB_API_ACTIONS...
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (10, 'MSG_DELETE', 'UDO_PKG_STAND_WEB.MSG_DELETE', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (11, 'MSG_SET_STATE', 'UDO_PKG_STAND_WEB.MSG_SET_STATE', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (1, 'VERIFY', 'UDO_PKG_WEB_API.PROCESS', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (2, 'DOWNLOAD', 'UDO_PKG_WEB_API.PROCESS', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (3, 'LOGIN', 'UDO_PKG_WEB_API.PROCESS', 1);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (14, 'PRINT_GET_STATE', 'UDO_PKG_STAND_WEB.PRINT_GET_STATE', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (15, 'DOWNLOAD_GET_URL', 'UDO_PKG_WEB_API.PROCESS', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (16, 'LOAD', 'UDO_PKG_STAND_WEB.LOAD', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (17, 'LOAD_ROLLBACK', 'UDO_PKG_STAND_WEB.LOAD_ROLLBACK', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (4, 'LOGOUT', 'UDO_PKG_WEB_API.PROCESS', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (5, 'AUTH_BY_BARCODE', 'UDO_PKG_STAND_WEB.AUTH_BY_BARCODE', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (6, 'SHIPMENT', 'UDO_PKG_STAND_WEB.SHIPMENT', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (7, 'MSG_INSERT', 'UDO_PKG_STAND_WEB.MSG_INSERT', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (8, 'MSG_GET_LIST', 'UDO_PKG_STAND_WEB.MSG_GET_LIST', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (9, 'STAND_GET_STATE', 'UDO_PKG_STAND_WEB.STAND_GET_STATE', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (12, 'SHIPMENT_ROLLBACK', 'UDO_PKG_STAND_WEB.SHIPMENT_ROLLBACK', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (13, 'PRINT', 'UDO_PKG_STAND_WEB.PRINT', 0);
commit;
prompt 17 records loaded
set feedback on
set define on
prompt Done.
