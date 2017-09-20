create or replace package UDO_PKG_STAND as
  /*
    Утилиты для работы стенда
  */

  /* Константы описания склада */
  SSTORE_PRODUCE       AZSAZSLISTMT.AZS_NUMBER%type := 'Производство'; -- Склад производства готовой продукции
  SSTORE_GOODS         AZSAZSLISTMT.AZS_NUMBER%type := 'СГП'; -- Склад отгрузки готовой продукции
  SRACK_PREF           STPLRACKS.PREF%type := 'АВТОМАТ'; -- Префикс стеллажа склада отгрузки готовой продукции
  SRACK_NUMB           STPLRACKS.NUMB%type := '1'; -- Номер стеллажа склада отгрузки готовой продукции
  SRACK_CELL_PREF_TMPL STPLCELLS.PREF%type := 'ЯРУС'; -- Шаблон префикса места хранения
  SRACK_CELL_NUMB_TMPL STPLCELLS.NUMB%type := 'МЕСТО'; -- Шаблон номера места зранения
  NRACK_LINES          number(17) := 3; -- Количество ярусов стеллажа
  NRACK_LINE_CELLS     number(17) := 3; -- Количество ячеек (мест хранения) в ярусе
  NRACK_CELL_CAPACITY  number(17) := 1; -- Максимальное количество номенклатуры в ячейке хранения

  /* Константы описания движения по складу */
  SDEF_STORE_MOVE_IN AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type := 'Приход внутренний'; -- Операция прихода по умолчанию
  SDEF_STORE_PARTY   INCOMDOC.CODE%type := 'Готовая продукция'; -- Партия по умолчанию
  SDEF_NOMEN         DICNOMNS.NOMEN_CODE%type := 'Жевательная резинка'; -- Номенклатура по умолчанию
  SDEF_NOMEN_MODIF   NOMMODIF.MODIF_CODE%type := 'Orbit'; -- Модификация номенклатуры по умолчанию

  /* Константы описания приходов */
  SINCDEPS_TYPE DOCTYPES.DOCCODE%type := 'ПНП'; -- Тип документа "Приход из подразделений"
  SINCDEPS_PREF INCOMEFROMDEPS.DOC_PREF%type := 'ПНП'; -- Префикс документа "Приход из подразделений"

  /* Загрузка стенда товаром */
  procedure LOAD(NCOMPANY number -- Регистрационный номер организации 
                 );

end;
/
create or replace package body UDO_PKG_STAND as

  /* Загрузка стенда товаром */
  procedure LOAD(NCOMPANY number -- Регистрационный номер организации 
                 ) is
    NCRN            INCOMEFROMDEPS.RN%type; -- Каталог размещения документов "Приход из подразделения"
    NJUR_PERS       JURPERSONS.RN%type; -- Регистрационный номер юридического лица "Прихода из подразделения" (основное ЮЛ организации)
    SJUR_PERS       JURPERSONS.CODE%type; -- Мнемокод номер юридического лица "Прихода из подразделения" (основное ЮЛ организации)
    SDOC_NUMB       INCOMEFROMDEPS.DOC_NUMB%type; -- Номер формируемого "Прихода из подразделения"
    SOUT_DEPARTMENT INS_DEPARTMENT.CODE%type; -- Подразделение-отправитель формируемого "Прихода из подразделения"
    SAGENT          AGNLIST.AGNABBR%type; -- МОЛ формируемого "Прихода из подразделения"
    SCURRENCY       CURNAMES.CURCODE%type; -- Валюта формируемого "Прихода из подразделения"
    NQUANT INCOMEFROMDEPSSPEC.Quant_Plan%type; -- Количество номенклатуры в формируемом "Прихода из подразделения"
    NINCOMEFROMDEPS INCOMEFROMDEPS.RN%type; -- Рег. номер сформированного "Прихода из подразделения"
    NINCOMEFROMDEPSSPEC INCOMEFROMDEPSSPEC.RN%type; -- Рег. номер сформированной позиции спецификации "Прихода из подразделения"
  begin
  
    /* Проверим, что стенд абсолютно пустой - ни на одном месте хранения не должно быть остатков */
  
    /* Определим рег. номер каталога */
    FIND_ROOT_CATALOG(NCOMPANY => NCOMPANY, SCODE => 'IncomFromDeps', NCRN => NCRN);
  
    /* Определим основное юридическое лицо организации */
    FIND_JURPERSONS_MAIN(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SJUR_PERS => SJUR_PERS, NJUR_PERS => NJUR_PERS);
  
    /* Определим базовую валюту */
    FIND_CURRENCY_BASE_NAME(NCOMPANY => NCOMPANY, SCODE => SCURRENCY, SISO => SCURRENCY);
  
    /* Определим подразделения склада, с которого производится отгузка */
    begin
      select D.CODE
        into SOUT_DEPARTMENT
        from AZSAZSLISTMT   S,
             INS_DEPARTMENT D
       where S.COMPANY = NCOMPANY
         and S.AZS_NUMBER = SSTORE_PRODUCE
         and S.DEPARTMENT = D.RN;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0, 'Для склада "%s" не указано подразделение!', SSTORE_PRODUCE);
    end;
  
    /* Определим МОЛ склада-получателя */
    begin
      select AG.AGNABBR
        into SAGENT
        from AZSAZSLISTMT S,
             AGNLIST      AG
       where S.COMPANY = NCOMPANY
         and S.AZS_NUMBER = SSTORE_GOODS
         and S.AZS_AGENT = AG.RN;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0,
                    'Для склада "%s" не указано материально ответственное лицо!',
                    SSTORE_PRODUCE);
    end;
    
    /* Определим количество загружаемой номенклатуры - стенд всегда загружается полностью (количество ярусов * количество мест в ярусе * вместимость места) */
    NQUANT := NRACK_LINES * NRACK_LINE_CELLS * NRACK_CELL_CAPACITY;
  
    /* Расчитаем очередной номер документа */
    P_INCOMEFROMDEPS_GETNEXTNUMB(NCOMPANY => NCOMPANY,
                                 STYPE    => SINCDEPS_TYPE,
                                 SPREF    => SINCDEPS_PREF,
                                 SNUMB    => SDOC_NUMB);
  
    /* Генерация заголовка прихода из подразделений */
    P_INCOMEFROMDEPS_INSERT(NCOMPANY          => NCOMPANY,
                            NCRN              => NCRN,
                            SJUR_PERS         => SJUR_PERS,
                            SDOC_TYPE         => SINCDEPS_TYPE,
                            SDOC_PREF         => SINCDEPS_PREF,
                            SDOC_NUMB         => SDOC_NUMB,
                            DDOC_DATE         => sysdate,
                            SVALID_DOCTYPE    => null,
                            SVALID_DOCNUMB    => null,
                            DVALID_DOCDATE    => null,
                            SOUT_DEPARTMENT   => SOUT_DEPARTMENT,
                            SOUT_FACEACC      => null,
                            SOUT_GRAPHPOINT   => null,
                            SOUT_STORE        => SSTORE_PRODUCE,
                            SPARTY_AGENT      => null,
                            SSTORE            => SSTORE_GOODS,
                            SAGENT            => SAGENT,
                            SCURRENCY         => SCURRENCY,
                            SSTORE_OPER       => SDEF_STORE_MOVE_IN,
                            SPARTY            => SDEF_STORE_PARTY,
                            SNOTE             => null,
                            NCURCOURS         => null,
                            NCURBASECOURS     => null,
                            NCURCOURS_DOC     => 1,
                            NCURBASECOURS_DOC => 1,
                            SBARCODE          => null,
                            NDUP_RN           => null,
                            NRN               => NINCOMEFROMDEPS);
  
    /* Генерация спецификации прихода из подразделений */
    P_INCOMEFROMDEPSSPEC_INSERT(NCOMPANY        => NCOMPANY,
                                NPRN            => NINCOMEFROMDEPS,
                                SNOMEN          => SDEF_NOMEN,
                                SNOMMODIF       => SDEF_NOMEN_MODIF,
                                SNOMNPACK       => null,
                                SARTICLE        => null,
                                SCELL           => null,
                                SPARTY_AGENT    => null,
                                SSUPPLY         => null,
                                SSTORE          => null,
                                NQUANT_PLAN     => NQUANT,
                                NQUANT_FACT     => NQUANT,
                                NQUANT_PLAN_ALT => 0,
                                NQUANT_FACT_ALT => 0,
                                DSROK           => null,
                                SSERTIFICATE    => null,
                                NPRICE          => 0,
                                NPRICEMEAS      => 0,
                                NSUMM_PLAN      => 0,
                                NSUMM_FACT      => 0,
                                SNOTE           => null,
                                SSERNUMB        => null,
                                SBARCODE        => null,
                                SCOUNTRY        => null,
                                SGTD            => null,
                                SPRODUCER       => null,
                                NSTORAGE_TIME   => null,
                                SUMEAS_STORAGE  => null,
                                NRN             => NINCOMEFROMDEPSSPEC);
  
    /* Установка мест хранения для спецификации */
    /* Отработка документа как "Факт" */
    /* Распределение спецификации по местам хранения */
    null;
  end;

end;
/
