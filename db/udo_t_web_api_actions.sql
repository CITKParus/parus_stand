prompt PL/SQL Developer import file
prompt Created on 27 Сентябрь 2017 г. by mim__000
set feedback off
set define off
prompt Loading UDO_T_WEB_API_ACTIONS...
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (1, 'VERIFY', 'UDO_PKG_WEB_API.PROCESS', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (2, 'DOWNLOAD', 'UDO_PKG_WEB_API.PROCESS', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (3, 'LOGIN', 'UDO_PKG_WEB_API.PROCESS', 1);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (4, 'LOGOUT', 'UDO_PKG_WEB_API.PROCESS', 0);
insert into UDO_T_WEB_API_ACTIONS (rn, action, processor, unauth)
values (5, 'AUTH_BY_BARCODE', 'UDO_PKG_STAND_WEB.AUTH_BY_BARCODE', 0);
commit;
prompt 5 records loaded
set feedback on
set define on
prompt Done.
