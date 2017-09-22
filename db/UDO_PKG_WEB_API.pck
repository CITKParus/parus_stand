create or replace package UDO_PKG_WEB_API
/*
 Обработчик HTTP-запросов
*/
 as

  /* Константы - режим отладки */
  BDEBUG                 constant boolean := false;

  /* Константы - типы ответов сервиса */
  NRESP_FORMAT_JSON      constant number(1) := 0;                  -- Ответ в JSON
  NRESP_FORMAT_XML       constant number(1) := 1;                  -- Ответ в XML
  SRESP_TYPE_KEY         constant varchar2(20) := 'RESP_TYPE';     -- Наименование ключа для идентификации ответа сервера
  SRESP_TYPE_VAL         constant varchar2(20) := 'STAND_MESSAGE'; -- Значение ключа для идентификации ответа сервера
  SRESP_STATE_KEY        constant varchar2(20) := 'STATE';         -- Наименование ключа для описания в ответе состояния сервера
  SRESP_MSG_KEY          constant varchar2(20) := 'MSG';           -- Наименование ключа для описания в ответе сообщения сервера
  NRESP_STATE_ERR        constant number(1) := 0;                  -- Ошибка выполнения
  NRESP_STATE_OK         constant number(1) := 1;                  -- Успешное выполнение
  
  /* Константы - ключи запросов (общие, частные в соответствующих модулях) */
  SREQ_ACTION_KEY        constant varchar2(20) := 'SACTION';       -- Наименование ключа для действия с сервером
  SREQ_SESSION_KEY       constant varchar2(20) := 'SSESSION';      -- Наименование ключа для идентификатора сессии
  
  /* Константы - коды специальных действий сервера */
  SACTION_VERIFY         constant varchar2(20) := 'VERIFY';        -- Проверка валидности сессии
  
  /* Константы - возможность исполнения действия без авторизации */
  NUNAUTH_YES            constant number(1) := 1;                  -- Возможно исполнение без авторизации
  NUNAUTH_NO             constant number(1) := 0;                  -- Невозможно исполнение без авторизации
  
  /* Константы - состояние исполнения обработчика */
  NEXEC_OK               constant number(1) := 1;                  -- Успешное исполнение  
  
  /* Авторизация для обработки запросос WEB-сервиса */
  function AUTHORIZE
  (
    SPROCEDURE           varchar2            -- Имя исполняемой процедуры
  ) return boolean;
  
  /* Транслитерация русской строки в английскую */
  function RESP_TRANSLATE_MSG
  (
    SSTR_RU              varchar2            -- Строка с русскими символами (CL8MSWIN1251)
  ) return varchar2;

  /* Нормализация сообщения об ошибке */
  function RESP_CORRECT_ERR
  (
    SERR                 varchar2            -- Ненормальзованное сообщени об ошибке
  ) return varchar2;

  /* Формирование стандартного ответа сервиса */
  function RESP_MAKE
  (
    NRESP_FORMAT         number,             -- Формат ответа (0 - JSON, 1 - XML)
    NRESP_STATE          number,             -- Тип ответа (0 - ошибка, 1 - успех)
    SRESP_MSG            varchar2            -- Сообщение
  ) return clob;

  /* Разбор стандартного ответа сервера (в JSON) */
  procedure RESP_PARSE
  (
    CJSON                clob,               -- Данные ответа
    NRESP_TYPE           out number,         -- Тип ответа (0 - ошибка, 1 - успех, null - CJSON не является стандартным ответом сервера)
    SRESP_MSG            out varchar2        -- Сообщение сервера
  );

  /* Выдача ответа WEB-серверу */
  procedure RESP_PUBLISH
  (
    CDATA                clob,                    -- Данные
    SCONTENT_TYPE        varchar2 := 'text/json', -- MIME-Type для данных
    SCHARSET             varchar2 := 'UTF-8'      -- Кодировка
  );

  /* Определение пользователя сессии */
  function SESSION_GET_USER return varchar2;

  /* Проверка актуальности сессии */
  procedure SESSION_VALIDATE
  (
    SSESSION             varchar2            -- Идентификатор сессии
  );

  /* Считывание записи обработчика */
  function WEB_API_ACTIONS_GET
  (
    NRN                  number,             -- Рег. номер записи
    NSMART               number := 0         -- Признак выдачи сообщения об ошибке
  ) return UDO_T_WEB_API_ACTIONS%rowtype;

  /* Считывание записи обработчика (по коду действия) */
  function WEB_API_ACTIONS_GET
  (
    SACTION              varchar2,           -- Код действия
    NSMART               number := 0         -- Признак выдачи сообщения об ошибке
  ) return UDO_T_WEB_API_ACTIONS%rowtype;

  /* Запуск обработчика действия */
  procedure WEB_API_ACTIONS_PROCESS
  (
    NRN                  number,             -- Рег. номер обработчика
    CPRMS                clob,               -- Входные параметры
    SFILE                varchar2 := null,   -- Идентификатор файла в буфере
    CRES                 out clob            -- Результат работы
  );

  /* Обработка запроса WEB-сервиса (JSON) */
  procedure PROCESS
  (
    CPRMS                clob,               -- Параметры запроса
    SFILE                varchar2 := null    -- Идентификатор файла в буфере
  );

  /* Обработка выгрузки файлов */
  procedure DOWNLOAD
  (
    CPRMS                clob                -- Параметры запроса
  );

end;
/
create or replace package body UDO_PKG_WEB_API as
  
  /* Авторизация для обработки запросос WEB-сервиса */
  function AUTHORIZE
  (
    SPROCEDURE           varchar2            -- Имя исполняемой процедуры
  ) return boolean 
  is
  begin
    /* Если вызываемая процедура в списке разрешенных */
    if (UPPER(SPROCEDURE) in
       ('PARUS.UDO_PKG_WEB_API.PROCESS'
        ,'PARUS.UDO_PKG_WEB_API.DOWNLOAD'))
    then
      /* Да, её можно исполнять */
      return true;
    else
      /* Нет, её нельзя исполнять */
      return false;
    end if;
  exception
    when others then
      /* Если что-то не так - на всякий случай запретим исполнение */
      return false;
  end;
  
  /* Транслитерация русской строки в английскую */
  function RESP_TRANSLATE_MSG
  (
    SSTR_RU              varchar2            -- Строка с русскими символами (CL8MSWIN1251)
  ) return varchar2 
  is
    SRES                 varchar2(4000);     -- Результат работы
  begin
    /* Выполним транслитерацию */
    SRES := TRANSLATE(UPPER(SSTR_RU), 'АБВГДЕЗИЙКЛМНОПРСТУФЬЫЪЭ', 'ABVGDEZIJKLMNOPRSTUF''Y''E');
    SRES := replace(SRES, 'Ж', 'ZH');
    SRES := replace(SRES, 'Х', 'KH');
    SRES := replace(SRES, 'Ц', 'TS');
    SRES := replace(SRES, 'Ч', 'CH');
    SRES := replace(SRES, 'Ш', 'SH');
    SRES := replace(SRES, 'Щ', 'SH');
    SRES := replace(SRES, 'Ю', 'YU');
    SRES := replace(SRES, 'Я', 'YA');
    
    /* Вернем ответ */
    return SRES;
  end;

  /* Нормализация сообщения об ошибке */
  function RESP_CORRECT_ERR
  (
    SERR                 varchar2            -- Ненормальзованное сообщени об ошибке
  ) return varchar2 
  is
    STMP                 varchar2(4000) := SERR; -- Буфер для расчетов
    SRES                 varchar2(4000);         -- Результат
    NB                   number;                 -- Начало интервала
    NE                   number;                 -- Окончание интервала
  begin
    begin
      /* Пока есть рудименты */
      while (INSTR(STMP, 'ORA') <> 0)
      loop
        NB := INSTR(STMP, 'ORA');
        NE := INSTR(STMP, ':', NB);
        /* Удаляем их */
        STMP := trim(replace(STMP, trim(SUBSTR(STMP, NB, NE - NB + 1)), ''));
      end loop;
      /* Сохраним результат */
      SRES := STMP;
    exception
      when others then
        SRES := SERR;
    end;
    
    /* Вернем результат */
    return SRES;
  end;

  /* Формирование стандартного ответа сервиса */
  function RESP_MAKE
  (
    NRESP_FORMAT         number,             -- Формат ответа (0 - JSON, 1 - XML)
    NRESP_STATE          number,             -- Тип ответа (0 - ошибка, 1 - успех)
    SRESP_MSG            varchar2            -- Сообщение
  ) return clob 
  is
    CRESP                clob;               -- Текст ответа
  begin
    /* Откроем буфер */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRESP, CACHE => false);
    
    /* Собираем ответ */
    case NRESP_FORMAT
      /* Если ответ в JSON */
      when NRESP_FORMAT_JSON then
        declare
          JRESP      JSON;            -- Ответ (объектное представление)
          SRESP_MSG_ varchar2(32000); -- Буфер для сообщения
        begin
          /* Инициализируем буфер сообщения */
          SRESP_MSG_ := SRESP_MSG;
          /* Нормализуем сообщение об ошибке */
          if (NRESP_STATE = NRESP_STATE_ERR) then
            SRESP_MSG_ := RESP_CORRECT_ERR(SERR => SRESP_MSG_);
          end if;
          /* Если режим отладки - то отдадим в транслите */
          if (BDEBUG) then
            SRESP_MSG_ := RESP_TRANSLATE_MSG(SSTR_RU => SRESP_MSG_);
          end if;
          /* Инициализируем ответ */
          JRESP := JSON();
          /* Тип ответа - стандартный ответ системы */
          JRESP.PUT(PAIR_NAME => SRESP_TYPE_KEY, PAIR_VALUE => SRESP_TYPE_VAL);
          /* Состояние (0 - ошибка, 1 - успех) */
          JRESP.PUT(PAIR_NAME => SRESP_STATE_KEY, PAIR_VALUE => NRESP_STATE);
          /* Сообщение */
          JRESP.PUT(PAIR_NAME => SRESP_MSG_KEY, PAIR_VALUE => SRESP_MSG_);
          /* Всё в CLOB */
          JRESP.TO_CLOB(BUF => CRESP);
        end;
      /* Если ответ в XML */
      when NRESP_FORMAT_XML then
        begin
          null;
        end;
      else
        null;
    end case;
    
    /* Вернем результат */
    return CRESP;
  end;

  /* Разбор стандартного ответа сервера (в JSON) */
  procedure RESP_PARSE
  (
    CJSON                clob,               -- Данные ответа
    NRESP_TYPE           out number,         -- Тип ответа (0 - ошибка, 1 - успех, null - CJSON не является стандартным ответом сервера)
    SRESP_MSG            out varchar2        -- Сообщение сервера
  ) 
  is
    JRESP JSON;
  begin
    JRESP := JSON(CJSON);
    if (JRESP.EXIST(SRESP_TYPE_KEY)) then
      if (JRESP.GET(SRESP_TYPE_KEY).VALUE_OF = SRESP_TYPE_VAL) then
        if ((JRESP.EXIST(SRESP_STATE_KEY)) and (JRESP.EXIST(SRESP_MSG_KEY))) then
          NRESP_TYPE := JRESP.GET(SRESP_STATE_KEY).VALUE_OF;
          SRESP_MSG  := JRESP.GET(SRESP_MSG_KEY).VALUE_OF;
        else
          NRESP_TYPE := null;
          SRESP_MSG  := null;
        end if;
      else
        NRESP_TYPE := null;
        SRESP_MSG  := null;
      end if;
    else
      NRESP_TYPE := null;
      SRESP_MSG  := null;
    end if;
  exception
    when others then
      NRESP_TYPE := null;
      SRESP_MSG  := null;
  end;

  /* Выдача ответа WEB-серверу */
  procedure RESP_PUBLISH
  (
    CDATA                clob,                    -- Данные
    SCONTENT_TYPE        varchar2 := 'text/json', -- MIME-Type для данных
    SCHARSET             varchar2 := 'UTF-8'      -- Кодировка
  )
  is
    NTOTLEN              number(17);              -- Общее кол-во символов к передаче
    NREST                number(17);              -- Остаток символов к передаче
    NBLEN                number(17) := 2000;      -- Длина строкового буфера (порция)
    STMP                 varchar2(2000);          -- Cтроковый буфер
    NI                   number(17) := 0;         -- Cчетчик передач
  begin
    /* Если есть данные */
    if ((CDATA is not null) and (DBMS_LOB.GETLENGTH(CDATA) > 0)) then
      /* Определим сколько всего данных */
      NTOTLEN := DBMS_LOB.GETLENGTH(CDATA);
      /* Определим сколько осталось передать данных */
      NREST := NTOTLEN;
      /* Отправим заголовок */
      OWA_UTIL.MIME_HEADER(CCONTENT_TYPE => SCONTENT_TYPE, CCHARSET => SCHARSET, BCLOSE_HEADER => false);
      HTP.P('Content-length: ' || NTOTLEN);
      OWA_UTIL.HTTP_HEADER_CLOSE();
      /* Режем буфер на строки */
      while (NREST > 0)
      loop
        /* Отрезаем */
        STMP := DBMS_LOB.SUBSTR(CDATA, NBLEN, (NBLEN * NI) + 1);
        /* Отмечаем, что отрезали */
        NI    := NI + 1;
        NREST := NREST - LENGTH(STMP);
        /* Выдаем */
        HTP.PRN(STMP);
      end loop;
    end if;
  end;

  /* Определение пользователя сессии */
  function SESSION_GET_USER return varchar2
  is
  begin
    return UTILIZER();
  end;

  /* Проверка актуальности сессии */
  procedure SESSION_VALIDATE
  (
    SSESSION             varchar2            -- Идентификатор сессии
  )
  is
  begin
    /* Валидируем сессию */
    PKG_SESSION.VALIDATE_WEB(SCONNECT => SSESSION);
  exception
    when others then
      P_EXCEPTION(0, 'Сессия истекла!');
  end;

  /* Считывание записи обработчика */
  function WEB_API_ACTIONS_GET
  (
    NRN                  number,             -- Рег. номер записи
    NSMART               number := 0         -- Признак выдачи сообщения об ошибке
  ) return UDO_T_WEB_API_ACTIONS%rowtype
  is
    RES                  UDO_T_WEB_API_ACTIONS%rowtype; -- Результат работы
    SERR                 varchar2(4000);                -- Буфер для ошибок
  begin
    /* Считаем запись */
    begin
      select T.* into RES from UDO_T_WEB_API_ACTIONS T where T.RN = NRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART, NDOCUMENT => NRN, SUNIT_TABLE => 'UDO_T_HTTP_ACTIONS');
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(NSMART, SERR);
    end;
    
    /* Вернем результат */
    return RES;
  end;

  /* Считывание записи обработчика (по коду действия) */
  function WEB_API_ACTIONS_GET
  (
    SACTION              varchar2,           -- Код действия
    NSMART               number := 0         -- Признак выдачи сообщения об ошибке
  ) return UDO_T_WEB_API_ACTIONS%rowtype
  is
    RES                  UDO_T_WEB_API_ACTIONS%rowtype; -- Результат работы
    SERR                 varchar2(4000);                -- Буфер для ошибок
  begin
    /* Считаем запись */
    begin
      select T.* into RES from UDO_T_WEB_API_ACTIONS T where T.ACTION = SACTION;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(NSMART,
                    'Для действия "%s" в системе нет зарегистрированных обработчиков!',
                    SACTION);
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(NSMART, SERR);
    end;
    
    /* Вернем результат */
    return RES;
  end;

  /* Запуск обработчика действия */
  procedure WEB_API_ACTIONS_PROCESS
  (
    NRN                  number,             -- Рег. номер обработчика
    CPRMS                clob,               -- Входные параметры
    SFILE                varchar2 := null,   -- Идентификатор файла в буфере
    CRES                 out clob            -- Результат работы
  )
  is
    ACTPROC              UDO_T_WEB_API_ACTIONS%rowtype; -- Запись обработчика действия
    SSQL                 varchar2(4000);                -- Исполняемый запрос
    NCUR                 integer;                       -- Курсор для запроса
    NRES                 integer;                       -- Результат исполнения запроса
    SERR                 varchar2(4000);                -- Буфер для ошибок
  begin
    /* Считаем обработчик */
    ACTPROC := WEB_API_ACTIONS_GET(NRN => NRN);
    
    /* Собираем запрос */
    SSQL := 'begin ' || ACTPROC.PROCESSOR;
    if (SFILE is not null) then
      SSQL := SSQL || '(CPRMS => :CPRMS, SFILE => :SFILE, CRES => :CRES); end;';
    else
      SSQL := SSQL || '(CPRMS => :CPRMS, CRES => :CRES); end;';
    end if;
    
    /* Проверяем его */
    NCUR := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(C => NCUR, statement => SSQL, LANGUAGE_FLAG => DBMS_SQL.NATIVE);
    
    /* Наполняем его параметрами */
    DBMS_SQL.BIND_VARIABLE(C => NCUR, name => 'CPRMS', value => CPRMS);
    if (SFILE is not null) then
      DBMS_SQL.BIND_VARIABLE(C => NCUR, name => 'SFILE', value => SFILE);
    end if;
    DBMS_SQL.BIND_VARIABLE(C => NCUR, name => 'CRES', value => CRES);
    
    /* Исполняем запрос */
    NRES := DBMS_SQL.EXECUTE(C => NCUR);
    
    /* Интерпретируем результат */
    if (NRES = NEXEC_OK) then
      DBMS_SQL.VARIABLE_VALUE(C => NCUR, name => 'CRES', value => CRES);
    else
      P_EXCEPTION(0,
                  'Ошибка исполнения обработчика "%s" для действия "%s"!',
                  ACTPROC.PROCESSOR,
                  ACTPROC.ACTION);
    end if;
    
    /* Закрываем курсор */
    if DBMS_SQL.IS_OPEN(C => NCUR) then
      DBMS_SQL.CLOSE_CURSOR(C => NCUR);
    end if;
  exception
    when others then
      SERR := sqlerrm;
      if DBMS_SQL.IS_OPEN(C => NCUR) then
        DBMS_SQL.CLOSE_CURSOR(C => NCUR);
      end if;
      CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                        NRESP_STATE  => NRESP_STATE_ERR,
                        SRESP_MSG    => 'Ошибка запуска обработчика для действия "' || ACTPROC.ACTION || '":' || SERR);
  end;

  /* Обработка запроса WEB-сервиса (JSON) */
  procedure PROCESS
  (
    CPRMS                clob,               -- Параметры запроса
    SFILE                varchar2 := null    -- Идентификатор файла в буфере
  )
  is
    SCANNER_EXCEPTION    exception;                         -- Ошибка JSON-сканера
    pragma exception_init(SCANNER_EXCEPTION, -20100);       -- Инициализация ошибки JSON-сканера
    PARSER_EXCEPTION     exception;                         -- Ошибка JSON-парсера
    pragma exception_init(PARSER_EXCEPTION, -20101);        -- Инициализация ошибки JSON-парсера
    JEXT_EXCEPTION       exception;                         -- Ошибка JSON-расширений
    pragma exception_init(JEXT_EXCEPTION, -20110);          -- Инициализация ошибки JSON-расширений
    JPRMS                JSON;                              -- Объектное представление параметров запроса
    CRES                 clob;                              -- Текстовое представление ответа
    SERR                 varchar2(4000);                    -- Буфер для ошибок
    SACTION              UDO_T_WEB_API_ACTIONS.ACTION%type; -- Код действия запроса
    ACTPROC              UDO_T_WEB_API_ACTIONS%rowtype;     -- Запись обработчика действия
  begin
    /* Инициализация ответа */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    
    /* Разбор параметров запроса */
    begin
      /* Конвертируем параметры в объектное представление */
      JPRMS := JSON(CPRMS);
      
      /* Считаем код действия */
      if ((not JPRMS.EXIST(SREQ_ACTION_KEY)) or (JPRMS.GET(SREQ_ACTION_KEY).VALUE_OF is null)) then
        P_EXCEPTION(0, 'В запросе к серверу не указан код действия!');
      else
        SACTION := JPRMS.GET(SREQ_ACTION_KEY).VALUE_OF;
      end if;
      
      /* Считаем обработчик для действия */
      ACTPROC := WEB_API_ACTIONS_GET(SACTION => SACTION, NSMART => 0);
      
      /* Проверим возможность исполнения данного действия пользователем (если не установлен флаг исполнения без авторизации) */
      if (ACTPROC.UNAUTH = NUNAUTH_NO) then
        if ((not JPRMS.EXIST(SREQ_SESSION_KEY)) or (JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF is null)) then
          P_EXCEPTION(0, 'В запросе к серверу не указана сессия!');
        else
          /* Валидируем сессию */
          SESSION_VALIDATE(SSESSION => JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF);
        end if;
      end if;
      
      /* Исполним действие (только если это не спец-действие по валидации сессии) */
      if (SACTION <> SACTION_VERIFY) then
        WEB_API_ACTIONS_PROCESS(NRN => ACTPROC.RN, CPRMS => CPRMS, SFILE => SFILE, CRES => CRES);
      else
        /* Если это было действие по валидации сессии - то вернем ответ что всё прошло хорошо */
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                          NRESP_STATE  => NRESP_STATE_OK,
                          SRESP_MSG    => JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF);
      end if;
    exception
      when SCANNER_EXCEPTION then
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                          NRESP_STATE  => NRESP_STATE_ERR,
                          SRESP_MSG    => 'Ошибка проверки запроса - убедитесь что зыпрос является валидным JSON-выражением!');
      when PARSER_EXCEPTION then
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                          NRESP_STATE  => NRESP_STATE_ERR,
                          SRESP_MSG    => 'Ошибка разбора запроса - убедитесь что зыпрос является валидным JSON-выражением!');
      when JEXT_EXCEPTION then
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                          NRESP_STATE  => NRESP_STATE_ERR,
                          SRESP_MSG    => 'Ошибка обработки запроса - убедитесь что зыпрос является валидным JSON-выражением!');
      when others then
        SERR := sqlerrm;
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON, NRESP_STATE => NRESP_STATE_ERR, SRESP_MSG => SERR);
    end;
    
    /* Вернем результат */
    RESP_PUBLISH(CDATA => CRES);
  end;
  
  /* Обработка выгрузки файлов */
  procedure DOWNLOAD
  (
    CPRMS                clob                -- Параметры запроса
  )
  is
  begin                     
    null;
  end;

end;
/
