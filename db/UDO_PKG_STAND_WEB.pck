create or replace package UDO_PKG_STAND_WEB as
  /*
    WEB API стенда
  */
  
  /* Конвертация остатков по номенклатуре стенда в JSON */
  function STAND_RACK_NOMEN_REST_TO_JSON
  (
    NR                      UDO_PKG_STAND.TNOMEN_RESTS -- Остатки номенклатуры
  ) return JSON_LIST;
  
  /* Конвертация остатков по стеллажу стенда в JSON */
  function STAND_RACK_REST_TO_JSON
  (
    R                       UDO_PKG_STAND.TRACK_REST -- Остатки стенда
  ) return JSON;
  
  /* Конвертация сведений о посетителе стенда в JSON */
  function STAND_USER_TO_JSON
  (
    U                       UDO_PKG_STAND.TSTAND_USER -- Пользователь стенда
  ) return JSON;
  
  /* Конвертация списка сообщений в JSON */
  function MESSAGES_TO_JSON
  (
    MSGS                    UDO_PKG_STAND.TMESSAGES -- Список сообщений
  ) return JSON_LIST;
  
  /* Аутентификация посетителя стенда по штрихкоду */
  procedure AUTH_BY_BARCODE
  (
    CPRMS                   clob,       -- Входные параметры
    CRES                    out clob    -- Результат работы
  );

  /* Выдача посетителю товара со стенда */
  procedure SHIPMENT
  (
    CPRMS                   clob,       -- Входные параметры
    CRES                    out clob    -- Результат работы
  );
  
  /* Помещение сообщения в очередь уведомлений */
  procedure MSG_INSERT
  (
    CPRMS                   clob,       -- Входные параметры
    CRES                    out clob    -- Результат работы
  );
  
  /* Выдача списка сообщений */
  procedure MSG_GET_LIST
  (
    CPRMS                   clob,       -- Входные параметры
    CRES                    out clob    -- Результат работы
  );

end;
/
create or replace package body UDO_PKG_STAND_WEB as

  /* Конвертация остатков по номенклатуре стенда в JSON */
  function STAND_RACK_NOMEN_REST_TO_JSON
  (
    NR                      UDO_PKG_STAND.TNOMEN_RESTS -- Остатки номенклатуры
  ) return JSON_LIST is
    JSLCN                   JSON_LIST;               -- JSON-коллекция номенклатур ячейки
    JSLCN_ITM               JSON;                    -- JSON-описание номенклатур ячейки
  begin
    /* Инициализируем выход */
    JSLCN := JSON_LIST();
    /* Обходим остатки номенклатуры, если есть */
    if ((NR is not null) and (NR.COUNT > 0)) then
      for N in NR.FIRST .. NR.LAST
      loop
        /* Собираем объект остатка номенклатуры */
        JSLCN_ITM := JSON();
        JSLCN_ITM.PUT(PAIR_NAME => 'NNOMEN', PAIR_VALUE => NR(N).NNOMEN);
        JSLCN_ITM.PUT(PAIR_NAME => 'SNOMEN', PAIR_VALUE => NR(N).SNOMEN);
        JSLCN_ITM.PUT(PAIR_NAME => 'NNOMMODIF', PAIR_VALUE => NR(N).NNOMMODIF);
        JSLCN_ITM.PUT(PAIR_NAME => 'SNOMMODIF', PAIR_VALUE => NR(N).SNOMMODIF);
        JSLCN_ITM.PUT(PAIR_NAME => 'NREST', PAIR_VALUE => NR(N).NREST);
        JSLCN_ITM.PUT(PAIR_NAME => 'NMEAS', PAIR_VALUE => NR(N).NMEAS);
        JSLCN_ITM.PUT(PAIR_NAME => 'SMEAS', PAIR_VALUE => NR(N).SMEAS);
        /* Объект номенклатуры - в клоллекцию номенклатур */
        JSLCN.APPEND(ELEM => JSLCN_ITM.TO_JSON_VALUE());
      end loop;
    end if;
    /* Вернем ответ */
    return JSLCN;
  end;
  
  /* Конвертация остатков по стеллажу стенда в JSON */
  function STAND_RACK_REST_TO_JSON
  (
    R                       UDO_PKG_STAND.TRACK_REST -- Остатки стенда
  ) return JSON is
    JS                      JSON;                    -- JSON-описание стеллажа
    JSL                     JSON_LIST;               -- JSON-коллекция ярусов стеллажа
    JSL_ITM                 JSON;                    -- JSON-описание яруса стеллажа
    JSLC                    JSON_LIST;               -- JSON-коллекция ячеек яруса
    JSLC_ITM                JSON;                    -- JSON-описание ячейки яруса
  begin
    /* Инициализируем ответ */
    JS := JSON();
    /* Соберем объект стеллажа */
    JS.PUT(PAIR_NAME => 'NRACK', PAIR_VALUE => R.NRACK);
    JS.PUT(PAIR_NAME => 'NSTORE', PAIR_VALUE => R.NSTORE);
    JS.PUT(PAIR_NAME => 'SSTORE', PAIR_VALUE => R.SSTORE);
    JS.PUT(PAIR_NAME => 'SRACK_PREF', PAIR_VALUE => R.SRACK_PREF);
    JS.PUT(PAIR_NAME => 'SRACK_NUMB', PAIR_VALUE => R.SRACK_NUMB);
    JS.PUT(PAIR_NAME => 'SRACK_NAME', PAIR_VALUE => R.SRACK_NAME);
    JS.PUT(PAIR_NAME => 'NRACK_LINES_CNT', PAIR_VALUE => R.NRACK_LINES_CNT);
    JS.PUT(PAIR_NAME => 'BEMPTY', PAIR_VALUE => R.BEMPTY);
    JSL := JSON_LIST();
    /* Обходим ярусы стеллажа */
    if (R.RACK_LINE_RESTS.COUNT > 0) then
      for L in R.RACK_LINE_RESTS.FIRST .. R.RACK_LINE_RESTS.LAST
      loop
        /* Собираем объект яруса */
        JSL_ITM := JSON();
        JSL_ITM.PUT(PAIR_NAME => 'NRACK_LINE', PAIR_VALUE => R.RACK_LINE_RESTS(L).NRACK_LINE);
        JSL_ITM.PUT(PAIR_NAME => 'NRACK_LINE_CELLS_CNT', PAIR_VALUE => R.RACK_LINE_RESTS(L).NRACK_LINE_CELLS_CNT);
        JSL_ITM.PUT(PAIR_NAME => 'BEMPTY', PAIR_VALUE => R.RACK_LINE_RESTS(L).BEMPTY);
        /* Обходим ячейки яруса */
        JSLC := JSON_LIST();
        if (R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS.COUNT > 0) then
          for C in R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS.FIRST .. R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS.LAST
          loop
            /* Собираем объект ячейки */
            JSLC_ITM := JSON();
            JSLC_ITM.PUT(PAIR_NAME  => 'NRACK_CELL',
                         PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_CELL);
            JSLC_ITM.PUT(PAIR_NAME  => 'SRACK_CELL_PREF',
                         PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_PREF);
            JSLC_ITM.PUT(PAIR_NAME  => 'SRACK_CELL_NUMB',
                         PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_NUMB);
            JSLC_ITM.PUT(PAIR_NAME  => 'SRACK_CELL_NAME',
                         PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_NAME);
            JSLC_ITM.PUT(PAIR_NAME  => 'NRACK_LINE',
                         PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_LINE);
            JSLC_ITM.PUT(PAIR_NAME  => 'NRACK_LINE_CELL',
                         PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_LINE_CELL);
            JSLC_ITM.PUT(PAIR_NAME => 'BEMPTY', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).BEMPTY);
            /* Коллекцию номенклатур - в ячейку */
            JSLC_ITM.PUT(PAIR_NAME  => 'NOMEN_RESTS',
                         PAIR_VALUE => STAND_RACK_NOMEN_REST_TO_JSON(NR => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS)
                                       .TO_JSON_VALUE());
            /* Ячейку - в коллекцию ячеек яруса */
            JSLC.APPEND(ELEM => JSLC_ITM.TO_JSON_VALUE());
          end loop;
        end if;
        /* Коллекцию ячеек - в ярус */
        JSL_ITM.PUT(PAIR_NAME => 'RACK_LINE_CELL_RESTS', PAIR_VALUE => JSLC.TO_JSON_VALUE());
        /* Ярус - в коллекцию ярусов стеллажа */
        JSL.APPEND(ELEM => JSL_ITM.TO_JSON_VALUE());
      end loop;
    end if;
    /* Коллекцию ярусов - в стеллаж */
    JS.PUT(PAIR_NAME => 'RACK_LINE_RESTS', PAIR_VALUE => JSL);
    /* Вернем резульат */
    return JS;
  end;
  
  /* Конвертация сведений о посетителе стенда в JSON */
  function STAND_USER_TO_JSON
  (
    U                       UDO_PKG_STAND.TSTAND_USER -- Пользователь стенда
  ) return JSON is
    JU                      JSON;                     -- JSON-описание пользователя стенда
  begin
    /* Инициализируем ответ */
    JU := JSON();
    /* Соберем объект */
    JU.PUT(PAIR_NAME => 'NAGENT', PAIR_VALUE => U.NAGENT);
    JU.PUT(PAIR_NAME => 'SAGENT', PAIR_VALUE => U.SAGENT);
    JU.PUT(PAIR_NAME => 'SAGENT_NAME', PAIR_VALUE => U.SAGENT_NAME);
    /* Вернем резульат */
    return JU;
  end;
  
  /* Конвертация списка сообщений в JSON */
  function MESSAGES_TO_JSON
  (
    MSGS                    UDO_PKG_STAND.TMESSAGES -- Список сообщений
  ) return JSON_LIST is
    JL                      JSON_LIST;              -- JSON-описание cписка сообщений
    JLI                     JSON;                   -- JSON-описание элемента списка
  begin
    /* Инициализируем ответ */
    JL := JSON_LIST();
    /* Если сообщения есть - обходим их */
    if ((MSGS is not null) and (MSGS.COUNT > 0)) then
      for I in MSGS.FIRST .. MSGS.LAST
      loop
        /* Инициализируем элемент сообщения */
        JLI := JSON();
        /* Соберем объект сообщения */
        JLI.PUT(PAIR_NAME => 'NRN', PAIR_VALUE => MSGS(I).NRN);
        JLI.PUT(PAIR_NAME => 'DTS', PAIR_VALUE => MSGS(I).DTS);
        JLI.PUT(PAIR_NAME => 'STS', PAIR_VALUE => MSGS(I).STS);
        JLI.PUT(PAIR_NAME => 'STP', PAIR_VALUE => MSGS(I).STP);
        JLI.PUT(PAIR_NAME => 'SMSG', PAIR_VALUE => MSGS(I).SMSG);
        /* Поместим сообщение в ответ */
        JL.APPEND(ELEM => JLI.TO_JSON_VALUE());
      end loop;
    end if;
    /* Вернем результат */
    return JL;
  end;  
  
  /* Аутентификация посетителя стенда по штрихкоду */
  procedure AUTH_BY_BARCODE
  (
    CPRMS                   clob,                                       -- Входные параметры
    CRES                    out clob                                    -- Результат работы
  ) is
    JRES                    JSON;                                       -- Буфера ответа
    JPRMS                   JSON;                                       -- Объектное представление параметров запроса
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- Рег. номер организации
    SBARCODE                PKG_STD.TSTRING;                            -- Штрихкод
    U                       UDO_PKG_STAND.TSTAND_USER;                  -- Пользователь стенда
    R                       UDO_PKG_STAND.TRACK_REST;                   -- Остатки стенда    
    SERR                    PKG_STD.TSTRING;                            -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    JRES := JSON();
    /* Конвертируем параметры в объектное представление */
    JPRMS := JSON(CPRMS);
    /* Считываем штрихкод */
    if ((not JPRMS.EXIST('SBARCODE')) or (JPRMS.GET('SBARCODE').VALUE_OF() is null)) then
      P_EXCEPTION(0, 'В запросе к серверу не указан штрихкод!');
    else
      SBARCODE := JPRMS.GET('SBARCODE').VALUE_OF();
    end if;
    /* Найдем пользователя и дополнительную информацию */
    UDO_PKG_STAND.STAND_AUTH_BY_BARCODE(NCOMPANY => NCOMPANY, SBARCODE => SBARCODE, STAND_USER => U, RACK_REST => R);
    /* Соберем ответ */
    JRES.PUT(PAIR_NAME => 'USER', PAIR_VALUE => STAND_USER_TO_JSON(U => U).TO_JSON_VALUE());
    JRES.PUT(PAIR_NAME => 'RESTS', PAIR_VALUE => STAND_RACK_REST_TO_JSON(R => R).TO_JSON_VALUE());
    /* Отдаём ответ */
    JRES.TO_CLOB(BUF => CRES);
  exception
    when others then
      SERR := sqlerrm;
      CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                        NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_ERR,
                                        SRESP_MSG    => SERR);
      rollback;
  end;
  
  /* Выдача посетителю товара со стенда */
  procedure SHIPMENT
  (
    CPRMS                   clob,                                       -- Входные параметры
    CRES                    out clob                                    -- Результат работы
  ) is
    JPRMS                   JSON;                                       -- Объектное представление параметров запроса
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- Рег. номер организации
    SCUSTOMER               PKG_STD.TSTRING;                            -- Мнемокод контрагента-посетителя
    NRACK_LINE              PKG_STD.TNUMBER;                            -- Ярус стеллажа для выдачи товара
    NRACK_LINE_CELL         PKG_STD.TNUMBER;                            -- Ячейка стеллажа для выдачи товара
    NTRANSINVCUST           PKG_STD.TREF;                               -- Рег. номер сформированной РНОП
    SERR                    PKG_STD.TSTRING;                            -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Конвертируем параметры в объектное представление */
    JPRMS := JSON(CPRMS);
    /* Считываем контрагента-посетителя */
    if ((not JPRMS.EXIST('SCUSTOMER')) or (JPRMS.GET('SCUSTOMER').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  'В запросе к серверу не указан мнемокод посетителя стенда!');
    else
      SCUSTOMER := JPRMS.GET('SCUSTOMER').VALUE_OF();
    end if;
    /* Считываем ярус стеллажа для выдачи товара */
    if ((not JPRMS.EXIST('NRACK_LINE')) or (JPRMS.GET('NRACK_LINE').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  'В запросе к серверу не указан ярус стеллажа для выдачи товара!');
    else
      NRACK_LINE := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NRACK_LINE').VALUE_OF(), NSMART => 0);
    end if;
    /* Считываем ячейку стеллажа для выдачи товара */
    if ((not JPRMS.EXIST('NRACK_LINE_CELL')) or (JPRMS.GET('NRACK_LINE_CELL').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  'В запросе к серверу не указана ячейка стеллажа для выдачи товара!');
    else
      NRACK_LINE_CELL := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR   => JPRMS.GET('NRACK_LINE_CELL').VALUE_OF(),
                                                               NSMART => 0);
    end if;
    /* Выдаём товар посетителю (списание с места хранения) */
    UDO_PKG_STAND.SHIPMENT(NCOMPANY        => NCOMPANY,
                           SCUSTOMER       => SCUSTOMER,
                           NRACK_LINE      => NRACK_LINE,
                           NRACK_LINE_CELL => NRACK_LINE_CELL,
                           NTRANSINVCUST   => NTRANSINVCUST);
    /* Отдаём ответ что всё прошло успешно */
    CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                      NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_OK,
                                      SRESP_MSG    => NTRANSINVCUST);
  exception
    when others then
      SERR := sqlerrm;
      CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                        NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_ERR,
                                        SRESP_MSG    => SERR);
      rollback;
  end;
  
  /* Помещение сообщения в очередь уведомлений */
  procedure MSG_INSERT
  (
    CPRMS                   clob,            -- Входные параметры
    CRES                    out clob         -- Результат работы
  ) is
    JPRMS                   JSON;            -- Объектное представление параметров запроса
    STP                     PKG_STD.TSTRING; -- Тип сообщения
    SMSG                    PKG_STD.TSTRING; -- Текст сообщения
    SERR                    PKG_STD.TSTRING; -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Конвертируем параметры в объектное представление */
    JPRMS := JSON(CPRMS);
    /* Считываем тип сообщения */
    if ((not JPRMS.EXIST('STP')) or (JPRMS.GET('STP').VALUE_OF() is null)) then
      P_EXCEPTION(0, 'В запросе к серверу не указан тип сообщения!');
    else
      STP := JPRMS.GET('STP').VALUE_OF();
    end if;
    /* Считываем текст сообщения */
    if ((not JPRMS.EXIST('SMSG')) or (JPRMS.GET('SMSG').VALUE_OF() is null)) then
      P_EXCEPTION(0, 'В запросе к серверу не указан текст сообщения!');
    else
      SMSG := JPRMS.GET('SMSG').VALUE_OF();
    end if;
    /* Добавляем сообщение */
    UDO_PKG_STAND.MSG_INSERT(STP => STP, SMSG => SMSG);
    /* Отдаём ответ что всё прошло успешно */
    CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                      NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_OK,
                                      SRESP_MSG    => '');
  exception
    when others then
      SERR := sqlerrm;
      CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                        NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_ERR,
                                        SRESP_MSG    => SERR);
      rollback;
  end;
  
  /* Выдача списка сообщений */
  procedure MSG_GET_LIST
  (
    CPRMS                   clob,            -- Входные параметры
    CRES                    out clob         -- Результат работы
  ) is
    JRES                    JSON_LIST;       -- Объектное представление ответа - списка сообщений
    JPRMS                   JSON;            -- Объектное представление параметров запроса
    DFROM                   PKG_STD.TLDATE;  -- "Дата с" для отбора сообщений
    STP                     PKG_STD.TSTRING; -- Тип сообщения для отбора
    NLIMIT                  PKG_STD.TNUMBER; -- Максимальное количество отбираемых сообщений
    NORDER                  PKG_STD.TNUMBER; -- Порядок сортировки сообщений
    MSGS                    UDO_PKG_STAND.TMESSAGES; -- Коллекция сообщений
    SERR                    PKG_STD.TSTRING; -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Конвертируем параметры в объектное представление */
    JPRMS := JSON(CPRMS);
    /* Считываем "дату с" для отбора сообщений */
    if ((not JPRMS.EXIST('DFROM')) or (JPRMS.GET('DFROM').VALUE_OF() is null)) then
      DFROM := null;
    else
      DFROM := UDO_PKG_WEB_API.UTL_CONVERT_TO_DATE(SDATE     => JPRMS.GET('DFROM').VALUE_OF(),
                                                   NSMART    => 0,
                                                   STEMPLATE => 'dd.mm.yyyy hh24:mi:ss');
    end if;
    /* Считываем тип для отбора сообщений */
    if ((not JPRMS.EXIST('STP')) or (JPRMS.GET('STP').VALUE_OF() is null)) then
      STP := null;
    else
      STP := JPRMS.GET('STP').VALUE_OF();
    end if;
    /* Считываем ограничение по количеству отобранных сообщений */
    if ((not JPRMS.EXIST('NLIMIT')) or (JPRMS.GET('NLIMIT').VALUE_OF() is null)) then
      NLIMIT := null;
    else
      NLIMIT := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NLIMIT').VALUE_OF(), NSMART => 0);
    end if;
    /* Считываем порядок сортировки отобранных сообщений */
    if ((not JPRMS.EXIST('NORDER')) or (JPRMS.GET('NORDER').VALUE_OF() is null)) then
      NORDER := UDO_PKG_STAND.NMSG_ORDER_ASC;
    else
      NORDER := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NORDER').VALUE_OF(), NSMART => 0);
    end if;
    /* Получаем список собщений и конвертируем их в JSON */
    MSGS := UDO_PKG_STAND.MSG_GET_LIST(DFROM => DFROM, STP => STP, NLIMIT => NLIMIT, NORDER => NORDER);
    JRES := MESSAGES_TO_JSON(MSGS => MSGS);
    /* Отдаём ответ */
    JRES.TO_CLOB(BUF => CRES);  
  exception
    when others then
      SERR := sqlerrm;
      CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                        NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_ERR,
                                        SRESP_MSG    => SERR);
      rollback;
  end;
  
end;
/
