create or replace package UDO_PKG_STAND_WEB as
  /*
    WEB API стенда
  */
  
  /* Конвертация конфигурации номенклатур стенда в JSON */
  function STAND_RACK_NOMEN_CONFS_TO_JSON
  (
    NC                      UDO_PKG_STAND.TRACK_NOMEN_CONFS -- Конфигурация номенклатуры стенда
  ) return JSON_LIST;
  
  /* Конвертация остатков по номенклатуре стенда в JSON */
  function STAND_RACK_NOMEN_RESTS_TO_JSON
  (
    NR                      UDO_PKG_STAND.TNOMEN_RESTS -- Остатки номенклатуры
  ) return JSON_LIST;
  
  /* Конвертация остатков по стеллажу стенда в JSON */
  function STAND_RACK_REST_TO_JSON
  (
    R                       UDO_PKG_STAND.TRACK_REST -- Остатки стенда
  ) return JSON;
  
  /* Конвертация истории загруженности стенда в JSON */
  function STAND_RACK_REST_PRCHS_TO_JSON
  (
    RH                      UDO_PKG_STAND.TRACK_REST_PRC_HISTS -- История загруженности стенда
  ) return JSON_LIST;
  
  /* Конвертация сведений о посетителе стенда в JSON */
  function STAND_USER_TO_JSON
  (
    U                       UDO_PKG_STAND.TSTAND_USER -- Пользователь стенда
  ) return JSON;
  
  /* Конвертация состояния стенда в JSON */
  function STAND_STATE_TO_JSON
  (
    SS                      UDO_PKG_STAND.TSTAND_STATE -- Состояние стенда
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

  /* Загрузка стенда товаром */
  procedure LOAD
  (
    CPRMS                   clob,       -- Входные параметры
    CRES                    out clob    -- Результат работы
  );
  
  /* Откат последней загрузки стенда */
  procedure LOAD_ROLLBACK
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
  
  /* Откат выдачи посетителю товара со стенда */
  procedure SHIPMENT_ROLLBACK
  (
    CPRMS                   clob,       -- Входные параметры
    CRES                    out clob    -- Результат работы
  );
  
  /* Постановка РНОПотр в очередь печати */
  procedure PRINT
  (
    CPRMS                   clob,       -- Входные параметры
    CRES                    out clob    -- Результат работы
  );
  
    /* Проверка состояния отчета в очереди печати */
  procedure PRINT_GET_STATE
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
  
  /* Удаление сообщения из очереди уведомлений */
  procedure MSG_DELETE
  (
    CPRMS                   clob,       -- Входные параметры
    CRES                    out clob    -- Результат работы
  );
  
  /* Установка состояния сообщения в очереди уведомлений */
  procedure MSG_SET_STATE
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
  
  /* Получение состояния стенда */
  procedure STAND_GET_STATE
  (
    CPRMS                   clob,       -- Входные параметры
    CRES                    out clob    -- Результат работы
  );

end;
/
create or replace package body UDO_PKG_STAND_WEB as

  /* Конвертация конфигурации номенклатур стенда в JSON */
  function STAND_RACK_NOMEN_CONFS_TO_JSON
  (
    NC                      UDO_PKG_STAND.TRACK_NOMEN_CONFS -- Конфигурация номенклатуры стенда
  ) return JSON_LIST is
    JSLCN                   JSON_LIST;                      -- JSON-коллекция номенклатур ячейки
    JSLCN_ITM               JSON;                           -- JSON-описание номенклатур ячейки
  begin
    /* Инициализируем выход */
    JSLCN := JSON_LIST();
    /* Обходим номенклатуры, если есть */
    if ((NC is not null) and (NC.COUNT > 0)) then
      for N in NC.FIRST .. NC.LAST
      loop
        /* Собираем объект остатка номенклатуры */
        JSLCN_ITM := JSON();
        JSLCN_ITM.PUT(PAIR_NAME => 'NNOMEN', PAIR_VALUE => NC(N).NNOMEN);
        JSLCN_ITM.PUT(PAIR_NAME => 'SNOMEN', PAIR_VALUE => NC(N).SNOMEN);
        JSLCN_ITM.PUT(PAIR_NAME => 'NNOMMODIF', PAIR_VALUE => NC(N).NNOMMODIF);
        JSLCN_ITM.PUT(PAIR_NAME => 'SNOMMODIF', PAIR_VALUE => NC(N).SNOMMODIF);
        JSLCN_ITM.PUT(PAIR_NAME => 'NMAX_QUANT', PAIR_VALUE => NC(N).NMAX_QUANT);        
        JSLCN_ITM.PUT(PAIR_NAME => 'NMEAS', PAIR_VALUE => NC(N).NMEAS);
        JSLCN_ITM.PUT(PAIR_NAME => 'SMEAS', PAIR_VALUE => NC(N).SMEAS);
        /* Объект номенклатуры - в клоллекцию номенклатур */
        JSLCN.APPEND(ELEM => JSLCN_ITM.TO_JSON_VALUE());
      end loop;
    end if;
    /* Вернем ответ */
    return JSLCN;
  end;  
  
  /* Конвертация остатков по номенклатуре стенда в JSON */
  function STAND_RACK_NOMEN_RESTS_TO_JSON
  (
    NR                      UDO_PKG_STAND.TNOMEN_RESTS -- Остатки номенклатуры
  ) return JSON_LIST is
    JSLCN                   JSON_LIST;                 -- JSON-коллекция номенклатур ячейки
    JSLCN_ITM               JSON;                      -- JSON-описание номенклатур ячейки
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
                         PAIR_VALUE => STAND_RACK_NOMEN_RESTS_TO_JSON(NR => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS)
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
  
  /* Конвертация истории загруженности стенда в JSON */
  function STAND_RACK_REST_PRCHS_TO_JSON
  (
    RH                      UDO_PKG_STAND.TRACK_REST_PRC_HISTS -- История загруженности стенда
  ) return JSON_LIST is
    JSLRH                   JSON_LIST;                         -- JSON-коллекция номенклатур ячейки
    JSLRH_ITM               JSON;                              -- JSON-описание номенклатур ячейки
  begin
    /* Инициализируем выход */
    JSLRH := JSON_LIST();
    /* Обходим историю, если есть */
    if ((RH is not null) and (RH.COUNT > 0)) then
      for N in RH.FIRST .. RH.LAST
      loop
        /* Собираем объект остатка номенклатуры */
        JSLRH_ITM := JSON();
        JSLRH_ITM.PUT(PAIR_NAME => 'DTS', PAIR_VALUE => TO_CHAR(RH(N).DTS, 'yyyy-mm-dd"T"hh24:mi:ss'));
        JSLRH_ITM.PUT(PAIR_NAME => 'STS', PAIR_VALUE => RH(N).STS);
        JSLRH_ITM.PUT(PAIR_NAME => 'NREST_PRC', PAIR_VALUE => RH(N).NREST_PRC);
        /* Объект номенклатуры - в клоллекцию номенклатур */
        JSLRH.APPEND(ELEM => JSLRH_ITM.TO_JSON_VALUE());
      end loop;
    end if;
    /* Вернем ответ */
    return JSLRH;
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
  
  /* Конвертация состояния стенда в JSON */
  function STAND_STATE_TO_JSON
  (
    SS                      UDO_PKG_STAND.TSTAND_STATE -- Состояние стенда
  ) return JSON is
    JS                      JSON;                      -- JSON-описание состояния стенда
  begin
    /* Инициализируем ответ */
    JS := JSON();
    /* Соберем объект */
    JS.PUT(PAIR_NAME => 'NRESTS_LIMIT_PRC_MIN', PAIR_VALUE => SS.NRESTS_LIMIT_PRC_MIN);
    JS.PUT(PAIR_NAME => 'NRESTS_LIMIT_PRC_MDL', PAIR_VALUE => SS.NRESTS_LIMIT_PRC_MDL);
    JS.PUT(PAIR_NAME => 'NRESTS_PRC_CURR', PAIR_VALUE => SS.NRESTS_PRC_CURR);
    JS.PUT(PAIR_NAME  => 'NOMEN_CONFS',
           PAIR_VALUE => STAND_RACK_NOMEN_CONFS_TO_JSON(NC => SS.NOMEN_CONFS).TO_JSON_VALUE());
    JS.PUT(PAIR_NAME  => 'NOMEN_RESTS',
           PAIR_VALUE => STAND_RACK_NOMEN_RESTS_TO_JSON(NR => SS.NOMEN_RESTS).TO_JSON_VALUE());
    JS.PUT(PAIR_NAME  => 'RACK_REST_PRC_HISTS',
           PAIR_VALUE => STAND_RACK_REST_PRCHS_TO_JSON(RH => SS.RACK_REST_PRC_HISTS).TO_JSON_VALUE());
    JS.PUT(PAIR_NAME => 'RACK_REST', PAIR_VALUE => STAND_RACK_REST_TO_JSON(R => SS.RACK_REST).TO_JSON_VALUE());
    JS.PUT(PAIR_NAME => 'MESSAGES', PAIR_VALUE => MESSAGES_TO_JSON(MSGS => SS.MESSAGES).TO_JSON_VALUE());
    /* Вернем резульат */
    return JS;
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
        JLI.PUT(PAIR_NAME => 'DTS', PAIR_VALUE => TO_CHAR(MSGS(I).DTS, 'yyyy-mm-dd"T"hh24:mi:ss'));
        JLI.PUT(PAIR_NAME => 'STS', PAIR_VALUE => MSGS(I).STS);
        JLI.PUT(PAIR_NAME => 'STP', PAIR_VALUE => MSGS(I).STP);
        begin
          JLI.PUT(PAIR_NAME => 'SMSG', PAIR_VALUE => JSON(MSGS(I).SMSG));
        exception
          when others then
            JLI.PUT(PAIR_NAME => 'SMSG', PAIR_VALUE => MSGS(I).SMSG);
        end;
        JLI.PUT(PAIR_NAME => 'SSTS', PAIR_VALUE => MSGS(I).SSTS);
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
  
  /* Загрузка стенда товаром */
  procedure LOAD
  (
    CPRMS                   clob,                                       -- Входные параметры
    CRES                    out clob                                    -- Результат работы
  ) is
    JPRMS                   JSON;                                       -- Объектное представление параметров запроса
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- Рег. номер организации    
    NRACK_LINE              PKG_STD.TNUMBER;                            -- Ярус стеллажа для загрузки товара
    NRACK_LINE_CELL         PKG_STD.TNUMBER;                            -- Ячейка стеллажа для загрузки товара
    NINCOMEFROMDEPS         PKG_STD.TREF;                               -- Рег. номер сформированной накладной по приходу из подразделений
    SERR                    PKG_STD.TSTRING;                            -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Конвертируем параметры в объектное представление */
    JPRMS := JSON(CPRMS);
    /* Считываем ярус стеллажа для загрузки товара */
    if ((not JPRMS.EXIST('NRACK_LINE')) or (JPRMS.GET('NRACK_LINE').VALUE_OF() is null)) then
      NRACK_LINE := null;
    else
      NRACK_LINE := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NRACK_LINE').VALUE_OF(), NSMART => 0);
    end if;
    /* Считываем ячейку стеллажа для загрузки товара */
    if ((not JPRMS.EXIST('NRACK_LINE_CELL')) or (JPRMS.GET('NRACK_LINE_CELL').VALUE_OF() is null)) then
      NRACK_LINE_CELL := null;
    else
      NRACK_LINE_CELL := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR   => JPRMS.GET('NRACK_LINE_CELL').VALUE_OF(),
                                                               NSMART => 0);
    end if;
    /* Загружаем товар (приходование на места хранения) */
    UDO_PKG_STAND.LOAD(NCOMPANY        => NCOMPANY,
                       NRACK_LINE      => NRACK_LINE,
                       NRACK_LINE_CELL => NRACK_LINE_CELL,
                       NINCOMEFROMDEPS => NINCOMEFROMDEPS);
    /* Отдаём ответ что всё прошло успешно */
    CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                      NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_OK,
                                      SRESP_MSG    => NINCOMEFROMDEPS);
  exception
    when others then
      SERR := sqlerrm;
      CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                        NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_ERR,
                                        SRESP_MSG    => SERR);
      rollback;
  end;
  
  /* Откат последней загрузки стенда */
  procedure LOAD_ROLLBACK
  (
    CPRMS                   clob,                                       -- Входные параметры
    CRES                    out clob                                    -- Результат работы
  ) is
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- Рег. номер организации
    NINCOMEFROMDEPS         PKG_STD.TREF;                               -- Рег. номер расформированного "Прихода из подразделения"        
    SERR                    PKG_STD.TSTRING;                            -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Откатываем последний приход */
    UDO_PKG_STAND.LOAD_ROLLBACK(NCOMPANY => NCOMPANY, NINCOMEFROMDEPS => NINCOMEFROMDEPS);
    /* Отдаём ответ что всё прошло успешно */
    CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                      NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_OK,
                                      SRESP_MSG    => NINCOMEFROMDEPS);
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
    JRES                    JSON;                                       -- Объектное представление ответа
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- Рег. номер организации
    SCUSTOMER               PKG_STD.TSTRING;                            -- Мнемокод контрагента-посетителя
    NRACK_LINE              PKG_STD.TNUMBER;                            -- Ярус стеллажа для выдачи товара
    NRACK_LINE_CELL         PKG_STD.TNUMBER;                            -- Ячейка стеллажа для выдачи товара
    NTRANSINVCUST           PKG_STD.TREF;                               -- Рег. номер сформированной РНОП
    RESTS_HIST_TMP          UDO_PKG_STAND.TMESSAGES;                    -- Буфер для истории остатков
    SERR                    PKG_STD.TSTRING;                            -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Инициализируем ответ */
    JRES := JSON();
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
    /* Считываем остатки по стенду после отгрузки */
    RESTS_HIST_TMP := UDO_PKG_STAND.MSG_GET_LIST(DFROM  => null,
                                                 STP    => UDO_PKG_STAND.SMSG_TYPE_REST_PRC,
                                                 NLIMIT => 1,
                                                 NORDER => UDO_PKG_STAND.NMSG_ORDER_DESC);
    /* Формируем ответ */
    JRES.PUT(PAIR_NAME => 'NTRANSINVCUST', PAIR_VALUE => NTRANSINVCUST);
    if ((RESTS_HIST_TMP is not null) and (RESTS_HIST_TMP.COUNT = 1)) then
      JRES.PUT(PAIR_NAME => 'NRESTS_PRC_CURR', PAIR_VALUE => TO_NUMBER(RESTS_HIST_TMP(RESTS_HIST_TMP.FIRST).SMSG));
    else
      JRES.PUT(PAIR_NAME => 'NRESTS_PRC_CURR', PAIR_VALUE => 0);
    end if;
    /* Отдаём ответ  */
    JRES.TO_CLOB(BUF => CRES);    
  exception
    when others then
      SERR := sqlerrm;
      CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                        NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_ERR,
                                        SRESP_MSG    => SERR);
      rollback;
  end;
  
  /* Откат выдачи посетителю товара со стенда */
  procedure SHIPMENT_ROLLBACK
  (
    CPRMS                   clob,                                       -- Входные параметры
    CRES                    out clob                                    -- Результат работы
  ) is
    JPRMS                   JSON;                                       -- Объектное представление параметров запроса
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- Рег. номер организации
    NTRANSINVCUST           PKG_STD.TREF;                               -- Рег. номер откатываемой РНОП
    SERR                    PKG_STD.TSTRING;                            -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Конвертируем параметры в объектное представление */
    JPRMS := JSON(CPRMS);
    /* Считываем регистрационный номер откатываемой расходной накладной на отпуск потребителю */
    if ((not JPRMS.EXIST('NTRANSINVCUST')) or (JPRMS.GET('NTRANSINVCUST').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  'В запросе к серверу не указан регистрационный номер откатываемой расходной накладной на отпуск потребителю!');
    else
      NTRANSINVCUST := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NTRANSINVCUST').VALUE_OF(), NSMART => 0);
    end if;
    /* Выдаём товар посетителю (списание с места хранения) */
    UDO_PKG_STAND.SHIPMENT_ROLLBACK(NCOMPANY => NCOMPANY, NTRANSINVCUST => NTRANSINVCUST);
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
  
  /* Постановка РНОПотр в очередь печати */
  procedure PRINT
  (
    CPRMS                   clob,                                       -- Входные параметры
    CRES                    out clob                                    -- Результат работы
  ) is
    JPRMS                   JSON;                                       -- Объектное представление параметров запроса
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- Рег. номер организации
    NTRANSINVCUST           PKG_STD.TREF;                               -- Рег. номер откатываемой РНОП
    SERR                    PKG_STD.TSTRING;                            -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Конвертируем параметры в объектное представление */
    JPRMS := JSON(CPRMS);
    /* Считываем регистрационный номер откатываемой расходной накладной на отпуск потребителю */
    if ((not JPRMS.EXIST('NTRANSINVCUST')) or (JPRMS.GET('NTRANSINVCUST').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  'В запросе к серверу не указан регистрационный номер распечатываемой расходной накладной на отпуск потребителю!');
    else
      NTRANSINVCUST := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NTRANSINVCUST').VALUE_OF(), NSMART => 0);
    end if;
    /* Ставим в очередь печати документ */
    UDO_PKG_STAND.PRINT(NCOMPANY => NCOMPANY, NTRANSINVCUST => NTRANSINVCUST);
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
  
  /* Проверка состояния отчета в очереди печати */
  procedure PRINT_GET_STATE
  (
    CPRMS                   clob,                           -- Входные параметры
    CRES                    out clob                        -- Результат работы
  ) is
    JPRMS                   JSON;                           -- Объектное представление параметров запроса  
    JRES                    JSON;                           -- Объектное представление ответа    
    NRPTPRTQUEUE            RPTPRTQUEUE.RN%type;            -- Идентификатор позиции очереди печати
    RPT_QUEUE_STATE         UDO_PKG_STAND.TRPT_QUEUE_STATE; -- Состояние отчета в очереди печати
    SERR                    PKG_STD.TSTRING;                -- Буфер для ошибок    
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Конвертируем параметры в объектное представление */
    JPRMS := JSON(CPRMS);
    /* Проверим наличие сессии в параметрах */
    if ((not JPRMS.EXIST(UDO_PKG_WEB_API.SREQ_SESSION_KEY)) or
       (JPRMS.GET(UDO_PKG_WEB_API.SREQ_SESSION_KEY).VALUE_OF() is null)) then
      P_EXCEPTION(0, 'В запросе к серверу не указана сессия!');
    end if;
    /* Считываем идентификатор позиции очереди печати */
    if ((not JPRMS.EXIST('NRPTPRTQUEUE')) or (JPRMS.GET('NRPTPRTQUEUE').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  'В запросе к серверу не указан идентификатор позиции очереди печати!');
    else
      NRPTPRTQUEUE := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NRPTPRTQUEUE').VALUE_OF(), NSMART => 0);
    end if;
    /* Проверим состояние отчета в очереди */
    UDO_PKG_STAND.PRINT_GET_STATE(SSESSION        => JPRMS.GET(UDO_PKG_WEB_API.SREQ_SESSION_KEY).VALUE_OF(),
                                  NRPTPRTQUEUE    => NRPTPRTQUEUE,
                                  RPT_QUEUE_STATE => RPT_QUEUE_STATE);
    /* Инициализируем ответ */
    JRES := JSON();
    /* Соберем ответ для выдачи */
    JRES.PUT(PAIR_NAME => 'NRN', PAIR_VALUE => RPT_QUEUE_STATE.NRN);
    JRES.PUT(PAIR_NAME => 'SSTATE', PAIR_VALUE => RPT_QUEUE_STATE.SSTATE);
    JRES.PUT(PAIR_NAME => 'SERR', PAIR_VALUE => RPT_QUEUE_STATE.SERR);
    JRES.PUT(PAIR_NAME => 'SFILE_NAME', PAIR_VALUE => RPT_QUEUE_STATE.SFILE_NAME);
    JRES.PUT(PAIR_NAME => 'SURL', PAIR_VALUE => RPT_QUEUE_STATE.SURL);
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
  
  /* Помещение сообщения в очередь уведомлений */
  procedure MSG_INSERT
  (
    CPRMS                   clob,            -- Входные параметры
    CRES                    out clob         -- Результат работы
  ) is
    JPRMS                   JSON;            -- Объектное представление параметров запроса
    STP                     PKG_STD.TSTRING; -- Тип сообщения
    SMSG                    PKG_STD.TSTRING; -- Текст сообщения
    SNOTIFY_TYPE            PKG_STD.TSTRING; -- Тип уведомления (для сообщений типа "Оповещение")
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
    /* Считываем тип уведомления */
    if ((not JPRMS.EXIST('SNOTIFY_TYPE')) or (JPRMS.GET('SNOTIFY_TYPE').VALUE_OF() is null)) then
      SNOTIFY_TYPE := UDO_PKG_STAND.SNOTIFY_TYPE_INFO;
    else
      SNOTIFY_TYPE := JPRMS.GET('SNOTIFY_TYPE').VALUE_OF();
    end if;
    /* Добавляем сообщение */
    UDO_PKG_STAND.MSG_INSERT(STP => STP, SMSG => SMSG, SNOTIFY_TYPE => SNOTIFY_TYPE);
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

  /* Удаление сообщения из очереди уведомлений */
  procedure MSG_DELETE
  (
    CPRMS                   clob,            -- Входные параметры
    CRES                    out clob         -- Результат работы
  ) is
    JPRMS                   JSON;            -- Объектное представление параметров запроса
    NRN                     PKG_STD.TREF;    -- Тип сообщения
    SERR                    PKG_STD.TSTRING; -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Конвертируем параметры в объектное представление */
    JPRMS := JSON(CPRMS);
    /* Считываем идентификатор сообщения */
    if ((not JPRMS.EXIST('NRN')) or (JPRMS.GET('NRN').VALUE_OF() is null)) then
      P_EXCEPTION(0, 'В запросе к серверу не указан идентификатор сообщения!');
    else
      NRN := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NRN').VALUE_OF(), NSMART => 0);
    end if;
    /* Удаляем сообщение */
    UDO_PKG_STAND.MSG_DELETE(NRN => NRN);
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
 
  /* Установка состояния сообщения в очереди уведомлений */
  procedure MSG_SET_STATE
  (
    CPRMS                   clob,            -- Входные параметры
    CRES                    out clob         -- Результат работы
  ) is
    JPRMS                   JSON;            -- Объектное представление параметров запроса
    NRN                     PKG_STD.TREF;    -- Рег. номер сообщения
    SSTS                    PKG_STD.TSTRING; -- Состояние сообщения
    SERR                    PKG_STD.TSTRING; -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Конвертируем параметры в объектное представление */
    JPRMS := JSON(CPRMS);
    /* Считываем идентификатор сообщения */
    if ((not JPRMS.EXIST('NRN')) or (JPRMS.GET('NRN').VALUE_OF() is null)) then
      P_EXCEPTION(0, 'В запросе к серверу не указан идентификатор сообщения!');
    else
      NRN := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NRN').VALUE_OF(), NSMART => 0);
    end if;
    /* Считываем устанавливаемое состояние сообщения */
    if ((not JPRMS.EXIST('SSTS')) or (JPRMS.GET('SSTS').VALUE_OF() is null)) then
      P_EXCEPTION(0, 'В запросе к серверу не указано устанавливаемое состояние сообщения!');
    else
      SSTS := JPRMS.GET('SSTS').VALUE_OF();
    end if;
    /* Устанавливаем состояние сообщения */
    UDO_PKG_STAND.MSG_SET_STATE(NRN => NRN, SSTS => SSTS);
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
    CPRMS                   clob,                    -- Входные параметры
    CRES                    out clob                 -- Результат работы
  ) is
    JRES                    JSON_LIST;               -- Объектное представление ответа - списка сообщений
    JPRMS                   JSON;                    -- Объектное представление параметров запроса
    DFROM                   PKG_STD.TLDATE;          -- "Дата с" для отбора сообщений
    STP                     PKG_STD.TSTRING;         -- Тип сообщения для отбора
    SSTS                    PKG_STD.TSTRING;         -- Состояние сообщений для отбора
    NLIMIT                  PKG_STD.TNUMBER;         -- Максимальное количество отбираемых сообщений
    NORDER                  PKG_STD.TNUMBER;         -- Порядок сортировки сообщений
    MSGS                    UDO_PKG_STAND.TMESSAGES; -- Коллекция сообщений
    SERR                    PKG_STD.TSTRING;         -- Буфер для ошибок
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
    /* Считываем состояние для отбора сообщений */
    if ((not JPRMS.EXIST('SSTS')) or (JPRMS.GET('SSTS').VALUE_OF() is null)) then
      SSTS := null;
    else
      SSTS := JPRMS.GET('SSTS').VALUE_OF();
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
    MSGS := UDO_PKG_STAND.MSG_GET_LIST(DFROM => DFROM, STP => STP, SSTS => SSTS, NLIMIT => NLIMIT, NORDER => NORDER);
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
  
  /* Получение состояния стенда */
  procedure STAND_GET_STATE
  (
    CPRMS                   clob,                                       -- Входные параметры
    CRES                    out clob                                    -- Результат работы
  ) is
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- Рег. номер организации
    JRES                    JSON;                                       -- Объектное представление ответа
    STAND_STATE             UDO_PKG_STAND.TSTAND_STATE;                 -- Состояние стенда
    SERR                    PKG_STD.TSTRING;                            -- Буфер для ошибок
  begin
    /* Инициализируем выход */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* Получим состояние стенда */
    UDO_PKG_STAND.STAND_GET_STATE(NCOMPANY => NCOMPANY, STAND_STATE => STAND_STATE);
    JRES := STAND_STATE_TO_JSON(SS => STAND_STATE);
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
