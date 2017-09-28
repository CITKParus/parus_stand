create or replace package UDO_PKG_WEB_API
/*
 Обработчик HTTP-запросов
*/
 as

  /* Константы - режим отладки */
  BDEBUG                    constant boolean := true;

  /* Константы - типы ответов сервиса */
  NRESP_FORMAT_JSON         constant number(1) := 0;                  -- Ответ в JSON
  NRESP_FORMAT_XML          constant number(1) := 1;                  -- Ответ в XML
  SRESP_TYPE_KEY            constant varchar2(20) := 'RESP_TYPE';     -- Наименование ключа для идентификации ответа сервера
  SRESP_TYPE_VAL            constant varchar2(20) := 'STAND_MESSAGE'; -- Значение ключа для идентификации ответа сервера
  SRESP_STATE_KEY           constant varchar2(20) := 'STATE';         -- Наименование ключа для описания в ответе состояния сервера
  SRESP_MSG_KEY             constant varchar2(20) := 'MSG';           -- Наименование ключа для описания в ответе сообщения сервера
  NRESP_STATE_ERR           constant number(1) := 0;                  -- Ошибка выполнения
  NRESP_STATE_OK            constant number(1) := 1;                  -- Успешное выполнение
  
  /* Константы - ключи запросов (общие, частные в соответствующих обработчиках) */
  SREQ_ACTION_KEY           constant varchar2(20) := 'SACTION';       -- Наименование ключа для действия с сервером
  SREQ_SESSION_KEY          constant varchar2(20) := 'SSESSION';      -- Наименование ключа для идентификатора сессии
  SREQ_USER_KEY             constant varchar2(20) := 'SUSER';         -- Наименование ключа для имени пользователя
  SREQ_PASSWORD_KEY         constant varchar2(20) := 'SPASSWORD';     -- Наименование ключа для имени пользователя
  SREQ_COMPANY_KEY          constant varchar2(20) := 'SCOMPANY';      -- Наименование ключа для названия организации  
  SREQ_FILE_TYPE_KEY        constant varchar2(20) := 'SFILE_TYPE';    -- Наименование ключа для типа выгружаемого файла
  SREQ_FILE_RN_KEY          constant varchar2(20) := 'NFILE_RN';      -- Наименование ключа для рег. номера выгружаемого файла
  
  /* Константы - коды специальных действий сервера */
  SACTION_LOGIN             constant varchar2(20) := 'LOGIN';         -- Аутентификация
  SACTION_LOGOUT            constant varchar2(20) := 'LOGOUT';        -- Завершение сессии
  SACTION_VERIFY            constant varchar2(20) := 'VERIFY';        -- Проверка валидности сессии
  SACTION_DOWNLOAD          constant varchar2(20) := 'DOWNLOAD';      -- Выгрузка файла
  
  /* Константы - типы выгружаемых файлов */
  SFILE_TYPE_REPORT         constant varchar2(20) := 'REPORT';        -- Готовый отчет
  
  /* Константы - возможность исполнения действия без авторизации */
  NUNAUTH_YES               constant number(1) := 1;                  -- Возможно исполнение без авторизации
  NUNAUTH_NO                constant number(1) := 0;                  -- Невозможно исполнение без авторизации
  
  /* Константы - состояние исполнения обработчика */
  NEXEC_OK                  constant number(1) := 1;                  -- Успешное исполнение
  
  /* Констнаты - состояние отчета в очереди печати */  
  NRPTQ_STATUS_QUEUE        constant number(1) := 0;                  -- Поставлено в очередь
  NRPTQ_STATUS_PROCESS      constant number(1) := 1;                  -- Выполнение начато
  NRPTQ_STATUS_OK           constant number(1) := 2;                  -- Выполнение завершено (успешно)
  NRPTQ_STATUS_ERR          constant number(1) := 3;                  -- Выполнение завершено (с ошибками) 
  
  /* Константы - типы отчетов */
  NRPT_TYPE_CRYSTAL         constant number(1) := 0;                  -- Crystal Reports
  NRPT_TYPE_EXCEL           constant number(1) := 1;                  -- MS Excel
  NRPT_TYPE_DRILL           constant number(1) := 2;                  -- DrillDown
  NRPT_TYPE_OOCALC          constant number(1) := 3;                  -- Open Office Calc
  NRPT_TYPE_BINARY          constant number(1) := 4;                  -- Двоичные данные
  
  /* Авторизация для обработки запросос WEB-сервиса */
  function AUTHORIZE
  (
    SPROCEDURE              varchar2         -- Имя исполняемой процедуры
  ) return boolean;
  
  /* Конвертация строковых значений в числовые для целей WEB-представления */
  function UTL_CONVERT_TO_NUMBER
  (
    SSTR                    varchar2,        -- Конвертируемая строка (разрядность 17.5, допускается передавать пробелы в качестве разделителя групп разрядов (но не другие символы!), допускается передавать в качестве разделителя целой и дробной части "." или ",", отрицательные обрабатываются корректно с минусом спереди, автоматически удаляются некоторые спец-символы)
    NSMART                  number := 0      -- Признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return number;
  
  /* Конвертация числовых значений в строковые для целей WEB-представления */
  function UTL_CONVERT_TO_STRING
  (
    NNUMB                   number,          -- Конвертируемое число
    NSEPARATE               number := 0,     -- Разделять разряды (0 - нет, 1 - да)
    NSHARP                  number := 2      -- Точность (кол-во знаков после запятой, только для NSEPARATE = 1)
  ) return varchar2;
  
  /* Конвертация строки в дату для целей WEB-представления */
  function UTL_CONVERT_TO_DATE
  (
    NSMART                  number,          -- Признак выдачи сообщения об ошибке
    SDATE                   varchar2,        -- Дата (строковое представление)
    SERR_MSG                varchar2 := null -- Сообщение об ошибке конвертации
  ) return date; 
  
  /* Считывание записи отчета */
  function UTL_RPT_GET
  (
    NREPORT                 number,          -- Регистрационный номер отчета
    NSMART                  number := 0      -- Признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return USERREPORTS%rowtype;
  
  /* Считывание записи очереди печати отчетов */
  function UTL_RPTQ_GET
  (
    NREPORTQ                number,          -- Регистрационный номер позиции очереди печати отчетов
    NSMART                  number := 0      -- Признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return RPTPRTQUEUE%rowtype;
  
  /* Формирование имени файла готового отчета */
  function UTL_RPTQ_BUILD_FILE_NAME
  (
    NREPORTQ                number           -- Регистрационный номер позиции очереди
  ) return varchar2;      
  
  /* Преобразование имени файла для использования в HTML-заголовке */
  function UTL_PREPARE_FILENAME
  (
    SFILE_NAME              varchar2         -- Имя файла
  ) return varchar2;  
  
  /* Транслитерация русской строки в английскую */
  function RESP_TRANSLATE_MSG
  (
    SSTR_RU                 varchar2         -- Строка с русскими символами (CL8MSWIN1251)
  ) return varchar2;

  /* Нормализация сообщения об ошибке */
  function RESP_CORRECT_ERR
  (
    SERR                    varchar2         -- Ненормальзованное сообщени об ошибке
  ) return varchar2;

  /* Формирование стандартного ответа сервиса */
  function RESP_MAKE
  (
    NRESP_FORMAT            number,          -- Формат ответа (0 - JSON, 1 - XML)
    NRESP_STATE             number,          -- Тип ответа (0 - ошибка, 1 - успех)
    SRESP_MSG               varchar2         -- Сообщение
  ) return clob;

  /* Разбор стандартного ответа сервера (в JSON) */
  procedure RESP_PARSE
  (
    CJSON                   clob,            -- Данные ответа
    NRESP_TYPE              out number,      -- Тип ответа (0 - ошибка, 1 - успех, null - CJSON не является стандартным ответом сервера)
    SRESP_MSG               out varchar2     -- Сообщение сервера
  );

  /* Выдача ответа WEB-серверу */
  procedure RESP_PUBLISH
  (
    CDATA                   clob,                    -- Данные
    SCONTENT_TYPE           varchar2 := 'text/json', -- MIME-Type для данных
    SCHARSET                varchar2 := 'UTF-8'      -- Кодировка
  );

  /* Выдача ответа WEB-серверу (в виде файла для скачивания) */
  procedure RESP_DOWNLOAD
  (
    BDATA                   in out nocopy blob,                    -- Данные
    SFILE_NAME              varchar2,                              -- Имя файла
    SCONTENT_TYPE           varchar2 := 'application/octet-stream' -- MIME-Type для данных
  );
  
  /* Определение пользователя сессии */
  function SESSION_GET_USER return varchar2;

  /* Проверка актуальности сессии */
  procedure SESSION_VALIDATE
  (
    SSESSION                varchar2         -- Идентификатор сессии
  );

  /* Считывание записи обработчика */
  function WEB_API_ACTIONS_GET
  (
    NRN                     number,          -- Регистрационный номер записи
    NSMART                  number := 0      -- Признак выдачи сообщения об ошибке
  ) return UDO_T_WEB_API_ACTIONS%rowtype;

  /* Считывание записи обработчика (по коду действия) */
  function WEB_API_ACTIONS_GET
  (
    SACTION                 varchar2,        -- Код действия
    NSMART                  number := 0      -- Признак выдачи сообщения об ошибке
  ) return UDO_T_WEB_API_ACTIONS%rowtype;

  /* Запуск обработчика действия */
  procedure WEB_API_ACTIONS_PROCESS
  (
    NRN                     number,          -- Регистрационный номер обработчика
    CPRMS                   clob,            -- Входные параметры
    CRES                    out clob         -- Результат работы
  );

  /* Обработка запроса WEB-сервиса (JSON) */
  procedure PROCESS
  (
    CPRMS                   clob             -- Параметры запроса
  );

end;
/
create or replace package body UDO_PKG_WEB_API as
  
  /* Авторизация для обработки запросос WEB-сервиса */
  function AUTHORIZE
  (
    SPROCEDURE              varchar2         -- Имя исполняемой процедуры
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
  
  /* Конвертация строковых значений в числовые для целей WEB-представления */
  function UTL_CONVERT_TO_NUMBER
  (
    SSTR                    varchar2,         -- Конвертируемая строка (разрядность 17.5, допускается передавать пробелы в качестве разделителя групп разрядов (но не другие символы!), допускается передавать в качестве разделителя целой и дробной части "." или ",", отрицательные обрабатываются корректно с минусом спереди, автоматически удаляются некоторые спец-символы)
    NSMART                  number := 0       -- Признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return number 
  is
    STMP                    PKG_STD.TLSTRING; -- Буфер для конвертации
    NTMP                    PKG_STD.TLNUMBER; -- Буфер для конвертации
  begin
    /* Конвертируем */
    begin
      if (SSTR is not null) then
        STMP := REGEXP_REPLACE(SSTR, '[ #&$%!@\(\)]');
        STMP := replace(STMP, ',', '.');
        NTMP := TO_NUMBER(STMP, '99999999999999999D99999', 'NLS_NUMERIC_CHARACTERS = ''. ''');
      end if;
    exception
      when others then
        P_EXCEPTION(NSMART,
                    'Переданное значение - "' || SSTR || '", не является числом!');
    end;
    return NTMP;
  end;

  /* Конвертация числовых значений в строковые для целей WEB-представления */
  function UTL_CONVERT_TO_STRING
  (
    NNUMB                   number,          -- Конвертируемое число
    NSEPARATE               number := 0,     -- Разделять разряды (0 - нет, 1 - да)
    NSHARP                  number := 2      -- Точность (кол-во знаков после запятой, только для NSEPARATE = 1)
  ) return varchar2 
  is
    SPATTERN                PKG_STD.TSTRING; -- Шаблон для конвертации с разделителями
    SRES                    PKG_STD.TSTRING; -- Результат работы
  begin
    /* Простой перевод в строку, без разделителей */
    if (NSEPARATE = 0) then
      SRES := replace(TO_CHAR(NVL(NNUMB, 0)), ',', '.');
      if NNUMB < 1 and NNUMB > 0 then
        SRES := '0' || SRES;
      end if;
    else
      /* Перевод с разделителями, с указанной точностью */
      if ((NSHARP is null) or (NSHARP <= 0)) then
        SPATTERN := '999G999G999G999G999G990';
      else
        SPATTERN := '999G999G999G999G999G990D' || RPAD('9', TRUNC(NSHARP), '9');
      end if;
      SRES := trim(TO_CHAR(NNUMB, SPATTERN, 'nls_numeric_characters=''. '''));
    end if;
    return SRES;
  exception
    when others then
      return null;
  end;

  /* Конвертация строки в дату для целей WEB-представления */
  function UTL_CONVERT_TO_DATE
  (
    NSMART                  number,          -- Признак выдачи сообщения об ошибке
    SDATE                   varchar2,        -- Дата (строковое представление)
    SERR_MSG                varchar2 := null -- Сообщение об ошибке конвертации
  ) return date 
  is
    DRESULT                 PKG_STD.TLDATE;  -- Результат работы
  begin
    /* Конвертируем в зависимости от возможных разделителей */
    begin
      if (SUBSTR(SDATE, 5, 1) = '-') then
        DRESULT := TO_DATE(SDATE, 'yyyy-mm-dd');
      elsif (SUBSTR(SDATE, 3, 1) = '.') then
        DRESULT := TO_DATE(SDATE, 'dd.mm.yyyy');
      else
        DRESULT := TO_DATE(SDATE, 'dd/mm/yyyy');
      end if;
    exception
      when others then
        /* Выдаем ошибку */
        P_EXCEPTION(NSMART,
                    NVL(SERR_MSG, 'Дата задана некорректно.') || ' Укажите дату в формате "ДД.ММ.ГГГГ"!');
    end;
    return DRESULT;
  end;
  
  /* Считывание записи отчета */
  function UTL_RPT_GET
  (
    NREPORT                 number,              -- Регистрационный номер отчета
    NSMART                  number := 0          -- Признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return USERREPORTS%rowtype 
  is
    RES                     USERREPORTS%rowtype; -- Результат работы
  begin
    /* Считаем данные */
    begin
      select T.* into RES from USERREPORTS T where T.RN = NREPORT;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART, NDOCUMENT => NREPORT, SUNIT_TABLE => 'USERREPORTS');
    end;
    /* Вернем результат */
    return RES;
  end;
  
  /* Считывание записи очереди печати отчетов */
  function UTL_RPTQ_GET
  (
    NREPORTQ                number,              -- Регистрационный номер позиции очереди печати отчетов
    NSMART                  number := 0          -- Признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return RPTPRTQUEUE%rowtype 
  is
    RES                     RPTPRTQUEUE%rowtype; -- Результат работы
  begin
    /* Считаем данные */
    begin
      select T.* into RES from RPTPRTQUEUE T where T.RN = NREPORTQ;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART, NDOCUMENT => NREPORTQ, SUNIT_TABLE => 'RPTPRTQUEUE');
    end;
    /* Вернем результат */
    return RES;
  end;
  
  /* Формирование имени файла готового отчета */
  function UTL_RPTQ_BUILD_FILE_NAME
  (
    NREPORTQ                number               -- Регистрационный номер позиции очереди
  ) return varchar2 
  is
    RPTQ_REC                RPTPRTQUEUE%rowtype; -- Запись позиции очереди
    RPT_REC                 USERREPORTS%rowtype; -- Запись отчета
    SEXT                    PKG_STD.TSTRING;     -- Расширение файла
    SFILE_NAME              PKG_STD.TSTRING;     -- Имя файла отчета
  begin
    /* Cчитаем запись позиции очереди */
    RPTQ_REC := UTL_RPTQ_GET(NREPORTQ => NREPORTQ);
    /* Считаем запись отчета */
    RPT_REC := UTL_RPT_GET(NREPORT => RPTQ_REC.USER_REPORT);
    /* Определимся с расширением */
    case RPT_REC.REPORT_TYPE
      when NRPT_TYPE_CRYSTAL then
        SEXT := 'pdf';
      when NRPT_TYPE_EXCEL then
        SEXT := 'xls';
      when NRPT_TYPE_OOCALC then
        SEXT := 'ods';
      else
        SEXT := 'dat';
    end case;
    /* Сформируем имя файла */
    SFILE_NAME := RPTQ_REC.AUTHID || '_' || TO_CHAR(RPTQ_REC.RN) || '.' || SEXT;
    /* Вернем результат */
    return SFILE_NAME;
  exception
    when others then
      return null;
  end;
  
  /* Преобразование имени файла для использования в HTML-заголовке */
  function UTL_PREPARE_FILENAME
  (
    SFILE_NAME              varchar2         -- Имя файла
  ) return varchar2 
  is
  begin
    return UTL_URL.ESCAPE(replace(replace(SUBSTR(SFILE_NAME, INSTR(SFILE_NAME, '/') + 1), CHR(10), null),
                                  CHR(13),
                                  null),
                          false,
                          'UTF8');
  end;
  
  /* Транслитерация русской строки в английскую */
  function RESP_TRANSLATE_MSG
  (
    SSTR_RU                 varchar2         -- Строка с русскими символами (CL8MSWIN1251)
  ) return varchar2 
  is
    SRES                    varchar2(4000);  -- Результат работы
  begin
    /* Выполним транслитерацию */
    SRES := TRANSLATE(UPPER(SSTR_RU), 'АБВГДЕЗИЙКЛМНОПРСТУФЬЫЪЭ', 'ABVGDEZIJKLMNOPRSTUF''Y''E');
    SRES := replace(SRES, 'Ё', 'E');
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
    SERR                    varchar2                -- Ненормальзованное сообщени об ошибке
  ) return varchar2 
  is
    STMP                    varchar2(4000) := SERR; -- Буфер для расчетов
    SRES                    varchar2(4000);         -- Результат
    NB                      number;                 -- Начало интервала
    NE                      number;                 -- Окончание интервала
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
    NRESP_FORMAT            number,          -- Формат ответа (0 - JSON, 1 - XML)
    NRESP_STATE             number,          -- Тип ответа (0 - ошибка, 1 - успех)
    SRESP_MSG               varchar2         -- Сообщение
  ) return clob 
  is
    CRESP                   clob;            -- Текст ответа
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
    CJSON                   clob,            -- Данные ответа
    NRESP_TYPE              out number,      -- Тип ответа (0 - ошибка, 1 - успех, null - CJSON не является стандартным ответом сервера)
    SRESP_MSG               out varchar2     -- Сообщение сервера
  ) 
  is
    JRESP JSON;
  begin
    JRESP := JSON(CJSON);
    if (JRESP.EXIST(SRESP_TYPE_KEY)) then
      if (JRESP.GET(SRESP_TYPE_KEY).VALUE_OF() = SRESP_TYPE_VAL) then
        if ((JRESP.EXIST(SRESP_STATE_KEY)) and (JRESP.EXIST(SRESP_MSG_KEY))) then
          NRESP_TYPE := JRESP.GET(SRESP_STATE_KEY).VALUE_OF();
          SRESP_MSG  := JRESP.GET(SRESP_MSG_KEY).VALUE_OF();
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

  /* Выдача ответа WEB-серверу (в теле HTTP-ответа) */
  procedure RESP_PUBLISH
  (
    CDATA                   clob,                    -- Данные
    SCONTENT_TYPE           varchar2 := 'text/json', -- MIME-Type для данных
    SCHARSET                varchar2 := 'UTF-8'      -- Кодировка
  )
  is
    NTOTLEN                 number(17);              -- Общее кол-во символов к передаче
    NREST                   number(17);              -- Остаток символов к передаче
    NBLEN                   number(17) := 2000;      -- Длина строкового буфера (порция)
    STMP                    varchar2(2000);          -- Cтроковый буфер
    NI                      number(17) := 0;         -- Cчетчик передач
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
  
  /* Выдача ответа WEB-серверу (в виде файла для скачивания) */
  procedure RESP_DOWNLOAD
  (
    BDATA                   in out nocopy blob,                    -- Данные
    SFILE_NAME              varchar2,                              -- Имя файла
    SCONTENT_TYPE           varchar2 := 'application/octet-stream' -- MIME-Type для данных
  )
  is
    NTOTLEN                 number(17);                            -- Общее кол-во символов к передаче
  begin
    /* Если есть данные */
    if ((BDATA is not null) and (DBMS_LOB.GETLENGTH(BDATA) > 0)) then
      /* Определим сколько всего данных */
      NTOTLEN := DBMS_LOB.GETLENGTH(BDATA);
      /* Открываем заголовок HTTP */
      OWA_UTIL.MIME_HEADER(CCONTENT_TYPE => SCONTENT_TYPE, BCLOSE_HEADER => false);
      /* Указываем размер скачиваемого файла и его имя */
      HTP.P('Content-length: ' || NTOTLEN);
      HTP.P('Content-Disposition:  attachment; filename="' || UTL_PREPARE_FILENAME(SFILE_NAME => SFILE_NAME) || '"');
      /* Закрываем заголовок */
      OWA_UTIL.HTTP_HEADER_CLOSE;
      /* Выгрузка буфера */
      WPG_DOCLOAD.DOWNLOAD_FILE(BDATA);
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
    SSESSION                varchar2         -- Идентификатор сессии
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
    NRN                     number,                        -- Регистрационный номер записи
    NSMART                  number := 0                    -- Признак выдачи сообщения об ошибке
  ) return UDO_T_WEB_API_ACTIONS%rowtype
  is
    RES                     UDO_T_WEB_API_ACTIONS%rowtype; -- Результат работы
    SERR                    varchar2(4000);                -- Буфер для ошибок
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
    SACTION                 varchar2,                      -- Код действия
    NSMART                  number := 0                    -- Признак выдачи сообщения об ошибке
  ) return UDO_T_WEB_API_ACTIONS%rowtype
  is
    RES                     UDO_T_WEB_API_ACTIONS%rowtype; -- Результат работы
    SERR                    varchar2(4000);                -- Буфер для ошибок
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
    NRN                     number,                        -- Регистрационный номер обработчика
    CPRMS                   clob,                          -- Входные параметры
    CRES                    out clob                       -- Результат работы
  )
  is
    ACTPROC                 UDO_T_WEB_API_ACTIONS%rowtype; -- Запись обработчика действия
    SSQL                    varchar2(4000);                -- Исполняемый запрос
    NCUR                    integer;                       -- Курсор для запроса
    NRES                    integer;                       -- Результат исполнения запроса
    SERR                    varchar2(4000);                -- Буфер для ошибок
  begin
    /* Считаем обработчик */
    ACTPROC := WEB_API_ACTIONS_GET(NRN => NRN);
    
    /* Собираем запрос */
    SSQL := 'begin ' || ACTPROC.PROCESSOR;
    SSQL := SSQL || '(CPRMS => :CPRMS, CRES => :CRES); end;';
    
    /* Проверяем его */
    NCUR := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(C => NCUR, statement => SSQL, LANGUAGE_FLAG => DBMS_SQL.NATIVE);
    
    /* Наполняем его параметрами */
    DBMS_SQL.BIND_VARIABLE(C => NCUR, name => 'CPRMS', value => CPRMS);
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
    CPRMS                   clob                               -- Параметры запроса
  )
  is
    SCANNER_EXCEPTION       exception;                         -- Ошибка JSON-сканера
    pragma exception_init(SCANNER_EXCEPTION, -20100);          -- Инициализация ошибки JSON-сканера
    PARSER_EXCEPTION        exception;                         -- Ошибка JSON-парсера
    pragma exception_init(PARSER_EXCEPTION, -20101);           -- Инициализация ошибки JSON-парсера
    JEXT_EXCEPTION          exception;                         -- Ошибка JSON-расширений
    pragma exception_init(JEXT_EXCEPTION, -20110);             -- Инициализация ошибки JSON-расширений
    JPRMS                   JSON;                              -- Объектное представление параметров запроса
    CRES                    clob;                              -- Текстовое представление ответа
    SERR                    varchar2(4000);                    -- Буфер для ошибок
    SACTION                 UDO_T_WEB_API_ACTIONS.ACTION%type; -- Код действия запроса
    ACTPROC                 UDO_T_WEB_API_ACTIONS%rowtype;     -- Запись обработчика действия
    BDOWNLOAD               boolean := false;                  -- Вризнак возможности выгрузки данных
    BDOWNLOAD_BUFFER        blob;                              -- Буфер для выгружаемого файла
    SDOWNLOAD_FILE_NAME     varchar2(4000);                    -- Имя выгружаемого файла    
  begin
    /* Инициализация ответа */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
  
    /* Разбор параметров запроса */
    begin
      /* Конвертируем параметры в объектное представление */
      JPRMS := JSON(CPRMS);
    
      /* Считаем код действия */
      if ((not JPRMS.EXIST(SREQ_ACTION_KEY)) or (JPRMS.GET(SREQ_ACTION_KEY).VALUE_OF() is null)) then
        P_EXCEPTION(0, 'В запросе к серверу не указан код действия!');
      else
        SACTION := JPRMS.GET(SREQ_ACTION_KEY).VALUE_OF();
      end if;
    
      /* Считаем обработчик для действия */
      ACTPROC := WEB_API_ACTIONS_GET(SACTION => SACTION, NSMART => 0);
    
      /* Проверим возможность исполнения данного действия пользователем (если не установлен флаг исполнения без авторизации) */
      if (ACTPROC.UNAUTH = NUNAUTH_NO) then
        if ((not JPRMS.EXIST(SREQ_SESSION_KEY)) or (JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF() is null)) then
          P_EXCEPTION(0, 'В запросе к серверу не указана сессия!');
        else
          /* Валидируем сессию */
          SESSION_VALIDATE(SSESSION => JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF());
        end if;
      end if;
    
      /* Исполним действие: спецдействия непосредственно тут, для прочих - вызываем обработчик */
      case SACTION
        /* Спецдействие - Аутентификация (обрабатывается непосредственно здесь, в ядре) */
        when SACTION_LOGIN then
          declare
            SUSR      USERLIST.AUTHID%type; -- Имя пользователя в системе
            SUSR_NAME USERLIST.NAME%type;   -- Полное имя пользователя
            SPASS     PKG_STD.TSTRING;      -- Пароль
            SCOMPANY  COMPANIES.NAME%type;  -- Организация
            SSESSION  PKG_STD.TSTRING;      -- Идентификатор сессии
            JRESP     JSON;                 -- Объектное представление ответа
          begin
            /* Считаем имя пользователя */
            if ((not JPRMS.EXIST(SREQ_USER_KEY)) or (JPRMS.GET(SREQ_USER_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0, 'В запросе к серверу не указано имя пользователя!');
            else
              SUSR := JPRMS.GET(SREQ_USER_KEY).VALUE_OF();
            end if;
            /* Считываем пароль */
            if ((not JPRMS.EXIST(SREQ_PASSWORD_KEY)) or (JPRMS.GET(SREQ_PASSWORD_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0, 'В запросе к серверу не указан пароль!');
            else
              SPASS := JPRMS.GET(SREQ_PASSWORD_KEY).VALUE_OF();
            end if;
            /* Считываем организацию */
            if ((not JPRMS.EXIST(SREQ_COMPANY_KEY)) or (JPRMS.GET(SREQ_COMPANY_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0, 'В запросе к серверу не указана организация!');
            else
              SCOMPANY := JPRMS.GET(SREQ_COMPANY_KEY).VALUE_OF();
            end if;
            /* Формируем идентификатор сессии */
            SSESSION := RAWTOHEX(SYS_GUID());
            /* Выполним аутентификацию */
            PKG_SESSION.LOGON_WEB(SCONNECT        => SSESSION,
                                  SUTILIZER       => SUSR,
                                  SPASSWORD       => SPASS,
                                  SIMPLEMENTATION => 'Other',
                                  SAPPLICATION    => 'Other',
                                  SCOMPANY        => SCOMPANY);
            PKG_SESSION.TIMEOUT_WEB(SCONNECT => SSESSION, NTIMEOUT => 2880);
            /* Найдем имя пользователя */
            FIND_USERLIST_BY_AUTHID(NFLAG_SMART => 0, SAUTHID => UPPER(SUSR), SNAME => SUSR_NAME);
            /* Собираем ответ */
            JRESP := JSON();
            JRESP.PUT(PAIR_NAME => 'SSESSION', PAIR_VALUE => SSESSION);
            JRESP.PUT(PAIR_NAME => 'SUSER_NAME', PAIR_VALUE => SUSR_NAME);
            JRESP.TO_CLOB(BUF => CRES);          
          end;
        /* Спецдействие - Завершение сессии (обрабатывается непосредственно здесь, в ядре) */
        when SACTION_LOGOUT then
          begin
            /* Завершим сессию */
            PKG_SESSION.LOGOFF_WEB(sCONNECT => JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF());
            /* Скажем что всё прошло хорошо */
            CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                              NRESP_STATE  => NRESP_STATE_OK,
                              SRESP_MSG    => JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF());
          end;
        /* Спецдействие - Валидация сессии (обрабатывается непосредственно здесь, в ядре) */
        when SACTION_VERIFY then
          begin
            /* Если это было действие по валидации сессии - то вернем ответ что всё прошло хорошо */
            CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                              NRESP_STATE  => NRESP_STATE_OK,
                              SRESP_MSG    => JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF());
          end;        
        /* Спецдействие - Выгрузка файла (обрабатывается непосредственно здесь, в ядре) */
        when SACTION_DOWNLOAD then
          declare
            SFILE_TYPE PKG_STD.TSTRING;     -- Тип выгружаемого файла
            NFILE_RN   PKG_STD.TREF;        -- Рег. номер выгружаемого файла   
            RPTQ       RPTPRTQUEUE%rowtype; -- Выгружаемая позиция очереди
          begin
            /* Считаем тип файла */
            if ((not JPRMS.EXIST(SREQ_FILE_TYPE_KEY)) or (JPRMS.GET(SREQ_FILE_TYPE_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0,
                          'В запросе к серверу не указан тип выгружаемого файла!');
            else
              SFILE_TYPE := JPRMS.GET(SREQ_FILE_TYPE_KEY).VALUE_OF();
            end if;
            /* Считаем идентификатор файла */
            if ((not JPRMS.EXIST(SREQ_FILE_RN_KEY)) or (JPRMS.GET(SREQ_FILE_RN_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0,
                          'В запросе к серверу не указан регистрационный номер выгружаемого файла!');
            else
              NFILE_RN := UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET(SREQ_FILE_RN_KEY).VALUE_OF(), NSMART => 0);
            end if;
            /* Инициализируем буферы выгрузки */
            DBMS_LOB.CREATETEMPORARY(LOB_LOC => BDOWNLOAD_BUFFER, CACHE => false);          
            /* Работаем от типа файла */
            case (SFILE_TYPE)
              /* Файл готового отчета */
              when (SFILE_TYPE_REPORT) then
                begin
                  /* Считаем позицию очереди печати */
                  RPTQ := UTL_RPTQ_GET(NREPORTQ => NFILE_RN, NSMART => 0);
                  /* Проврим её состояние */
                  if (RPTQ.STATUS <> NRPTQ_STATUS_OK) then
                    P_EXCEPTION(0,
                                'Отчет не может быть выгружен - он ещё не исполнен или исполнен с ошибками!');
                  end if;
                  /* Считаем данные из очереди печати */
                  begin
                    select NVL(R.REPORT, R.REPORT_PDF),
                           UTL_RPTQ_BUILD_FILE_NAME(NREPORTQ => R.PRN)
                      into BDOWNLOAD_BUFFER,
                           SDOWNLOAD_FILE_NAME
                      from RPTPRTQUEUE_RPT R
                     where R.PRN = RPTQ.RN;
                  exception
                    when others then
                      P_EXCEPTION(0,
                                  'Ошибка считывания данных позиции очереди печати (RN: %s)!',
                                  TO_CHAR(NFILE_RN));
                  end;
                  /* Дополнительные проверки */
                  if (SDOWNLOAD_FILE_NAME is null) then
                    P_EXCEPTION(0,
                                'Не удалось определить имя выгружаемого файла!');
                  end if;
                  if (NVL(DBMS_LOB.GETLENGTH(BDOWNLOAD_BUFFER), 0) = 0) then
                    P_EXCEPTION(0, 'Выгружаемый файл пуст!');
                  end if;
                end;
              /* Неизвестный тип файла */
              else
                P_EXCEPTION(0,
                            'Для Файла типа "%s" выгрузка не поддерживается!',
                            SFILE_TYPE);
            end case;
            /* Данные успешно подготовлены, все проверки пройдены - можно выгружать */
            BDOWNLOAD := true;
          end;        
        /* Прочие действия - обрабатываются вызовами соответствующих обработчиков */
        else
          begin
            /* Исполним обработчик действия */
            WEB_API_ACTIONS_PROCESS(NRN => ACTPROC.RN, CPRMS => CPRMS, CRES => CRES);
          end;
      end case;
      
    /* Обработка ошибок разбора JSON и контроля обязательных параметров */
    exception
      when SCANNER_EXCEPTION then
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                          NRESP_STATE  => NRESP_STATE_ERR,
                          SRESP_MSG    => 'Ошибка проверки запроса - убедитесь что зыпрос является валидным JSON-выражением!');
        rollback;                          
      when PARSER_EXCEPTION then
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                          NRESP_STATE  => NRESP_STATE_ERR,
                          SRESP_MSG    => 'Ошибка разбора запроса - убедитесь что зыпрос является валидным JSON-выражением!');
        rollback;                          
      when JEXT_EXCEPTION then
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                          NRESP_STATE  => NRESP_STATE_ERR,
                          SRESP_MSG    => 'Ошибка обработки запроса - убедитесь что зыпрос является валидным JSON-выражением!');
        rollback;                          
      when others then
        SERR := sqlerrm;
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON, NRESP_STATE => NRESP_STATE_ERR, SRESP_MSG => SERR);
        rollback;
    end;

    /* Вернем результат - обычный овет в теле HTTP или файл */
    if (not BDOWNLOAD) then
      RESP_PUBLISH(CDATA => CRES);
    else
      RESP_DOWNLOAD(BDATA => BDOWNLOAD_BUFFER, SFILE_NAME => SDOWNLOAD_FILE_NAME);
    end if; 
  end;

end;
/
