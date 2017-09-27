create or replace package UDO_PKG_STAND_WEB as
  /*
    WEB API стенда
  */
  
  /* Аутентификация посетителя стенда по штрихкоду */
  procedure AUTH_BY_BARCODE
  (
    CPRMS                   clob,       -- Входные параметры
    CRES                    out clob    -- Результат работы
  );

end;
/
create or replace package body UDO_PKG_STAND_WEB as

  /* Аутентификация посетителя стенда по штрихкоду */
  procedure AUTH_BY_BARCODE
  (
    CPRMS                   clob,       -- Входные параметры
    CRES                    out clob    -- Результат работы
  )is
    JRES                    JSON;                                       -- Буфера ответа
    JPRMS                   JSON;                                       -- Объектное представление параметров запроса
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- Рег. номер организации
    SBARCODE                PKG_STD.TSTRING;                            -- Штрихкод
    U                       UDO_PKG_STAND.TSTAND_USER;                  -- Пользователь стенда
    R                       UDO_PKG_STAND.TRACK_REST;                   -- Остатки стенда
    JU                      JSON;
    JS                      JSON;
    JSL                     JSON_LIST;
    JSL_ITM                 JSON;                    
    JSLC                    JSON_LIST;
    JSLC_ITM                JSON;
    JSLCN                   JSON_LIST;
    JSLCN_ITM               JSON;
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
    UDO_PKG_STAND.AUTH_BY_BARCODE(NCOMPANY => NCOMPANY, SBARCODE => SBARCODE, STAND_USER => U, RACK_REST => R);
    /* Собираем ответ - пользователь */
    JU := JSON();
    JU.PUT(PAIR_NAME => 'NAGENT', PAIR_VALUE => U.NAGENT);
    JU.PUT(PAIR_NAME => 'SAGENT', PAIR_VALUE => U.SAGENT);
    JU.PUT(PAIR_NAME => 'SAGENT_NAME', PAIR_VALUE => U.SAGENT_NAME);
    /* Собираем ответ - описание остатков стенда */
    JS := JSON();
    JS.PUT(PAIR_NAME => 'NRACK', PAIR_VALUE => R.NRACK);
    JS.PUT(PAIR_NAME => 'NSTORE', PAIR_VALUE => R.NSTORE);
    JS.PUT(PAIR_NAME => 'SSTORE', PAIR_VALUE => R.SSTORE);
    JS.PUT(PAIR_NAME => 'SRACK_PREF', PAIR_VALUE => R.SRACK_PREF);
    JS.PUT(PAIR_NAME => 'SRACK_NUMB', PAIR_VALUE => R.SRACK_NUMB);
    JS.PUT(PAIR_NAME => 'SRACK_NAME', PAIR_VALUE => R.SRACK_NAME);
    JS.PUT(PAIR_NAME => 'NRACK_LINES_CNT', PAIR_VALUE => R.NRACK_LINES_CNT);        
    JS.PUT(PAIR_NAME => 'BEMPTY', PAIR_VALUE => R.BEMPTY);
    JSL := JSON_LIST();
  if (R.RACK_LINE_RESTS.COUNT > 0) then
    for L in R.RACK_LINE_RESTS.FIRST .. R.RACK_LINE_RESTS.LAST
    loop
      JSL_ITM := JSON();
      JSL_ITM.PUT(PAIR_NAME => 'NRACK_LINE', PAIR_VALUE => R.RACK_LINE_RESTS(L).NRACK_LINE);
      JSL_ITM.PUT(PAIR_NAME => 'NRACK_LINE_CELLS_CNT', PAIR_VALUE => R.RACK_LINE_RESTS(L).NRACK_LINE_CELLS_CNT);
      JSL_ITM.PUT(PAIR_NAME => 'BEMPTY', PAIR_VALUE => R.RACK_LINE_RESTS(L).BEMPTY);
      JSLC := JSON_LIST();              
      if (R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS.COUNT > 0) then
        for C in R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS.FIRST .. R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS.LAST
        loop
          JSLC_ITM := JSON();
          JSLC_ITM.PUT(PAIR_NAME => 'NRACK_CELL', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_CELL);
          JSLC_ITM.PUT(PAIR_NAME => 'SRACK_CELL_PREF', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_PREF);
          JSLC_ITM.PUT(PAIR_NAME => 'SRACK_CELL_NUMB', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_NUMB);          
          JSLC_ITM.PUT(PAIR_NAME => 'SRACK_CELL_NAME', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_NAME);
          JSLC_ITM.PUT(PAIR_NAME => 'NRACK_LINE', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_LINE);
          JSLC_ITM.PUT(PAIR_NAME => 'NRACK_LINE_CELL', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_LINE_CELL);
          JSLC_ITM.PUT(PAIR_NAME => 'BEMPTY', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).BEMPTY);
          JSLCN := JSON_LIST();
          if (R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS.COUNT > 0) then
            for N in R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS.FIRST .. R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C)
                                                                                       .NOMEN_RESTS.LAST
            loop
              JSLCN_ITM := JSON();
              JSLCN_ITM.PUT(PAIR_NAME => 'NNOMEN', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS(N).NNOMEN);
              JSLCN_ITM.PUT(PAIR_NAME => 'SNOMEN', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS(N).SNOMEN);
              JSLCN_ITM.PUT(PAIR_NAME => 'NNOMMODIF', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS(N).NNOMMODIF);              
              JSLCN_ITM.PUT(PAIR_NAME => 'SNOMMODIF', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS(N).SNOMMODIF);              
              JSLCN_ITM.PUT(PAIR_NAME => 'NREST', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS(N).NREST);
              JSLCN_ITM.PUT(PAIR_NAME => 'NMEAS', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS(N).NMEAS);
              JSLCN_ITM.PUT(PAIR_NAME => 'SMEAS', PAIR_VALUE => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS(N).SMEAS);
              JSLCN.APPEND(ELEM => JSLCN_ITM.TO_JSON_VALUE());              
            end loop;
          end if;
          JSLC_ITM.PUT(PAIR_NAME => 'NOMEN_RESTS', PAIR_VALUE => JSLCN.TO_JSON_VALUE());      
          JSLC.APPEND(ELEM => JSLC_ITM.TO_JSON_VALUE());
        end loop;
      end if;
      
      JSL_ITM.PUT(PAIR_NAME => 'RACK_LINE_CELL_RESTS', PAIR_VALUE => JSLC.TO_JSON_VALUE());      
      JSL.APPEND(ELEM => JSL_ITM.TO_JSON_VALUE());
    end loop; 
  end if;    
  JS.PUT(PAIR_NAME => 'RACK_LINE_RESTS', PAIR_VALUE => JSL);
    /* Соберем ответ - финальный */
    JRES.PUT(PAIR_NAME => 'USER', PAIR_VALUE => JU.TO_JSON_VALUE());
    JRES.PUT(PAIR_NAME => 'RESTS', PAIR_VALUE => JS.TO_JSON_VALUE());
    /* Отдаём ответ */
    JRES.TO_CLOB(BUF => CRES);
  exception
    when others then
      SERR := sqlerrm;
      CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                        NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_ERR,
                                        SRESP_MSG    => SERR);
  end;

end;
/
