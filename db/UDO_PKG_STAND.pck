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
  NRACK_LINES          number(17) := 1; -- Количество ярусов стеллажа
  NRACK_LINE_CELLS     number(17) := 3; -- Количество ячеек (мест хранения) в ярусе
  NRACK_CELL_CAPACITY  number(17) := 2; -- Максимальное количество номенклатуры в ячейке хранения
  NRACK_CELL_SHIP_CNT  number(17) := 1; -- Количество номенклатуры, отгружаемое потребителю за одну транзакцию

  /* Константы описания движения по складу */
  SDEF_STORE_MOVE_IN  AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type := 'Приход внутренний'; -- Операция прихода по умолчанию
  SDEF_STORE_MOVE_OUT AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type := 'Расход внешний'; -- Операция расхода по умолчанию
  SDEF_STORE_PARTY    INCOMDOC.CODE%type := 'Готовая продукция'; -- Партия по умолчанию
  SDEF_FACE_ACC       FACEACC.NUMB%type := 'Универсальный'; -- Лицевой счет по умолчанию
  SDEF_TARIF          DICTARIF.CODE%type := 'Базовый'; -- Тариф по умолчанию
  SDEF_SHEEP_VIEW     DICSHPVW.CODE%type := 'Самовывоз'; -- Вид отгрузки по умолчанию
  SDEF_PAY_TYPE       AZSGSMPAYMENTSTYPES.GSMPAYMENTS_MNEMO%type := 'Без оплаты'; -- Вид оплаты по умолчанию
  SDEF_TAX_GROUP      DICTAXGR.CODE%type := 'Без налогов'; -- Налоговая группа по умолчанию
  SDEF_NOMEN          DICNOMNS.NOMEN_CODE%type := 'Жевательная резинка'; -- Номенклатура по умолчанию
  SDEF_NOMEN_MODIF    NOMMODIF.MODIF_CODE%type := 'Orbit'; -- Модификация номенклатуры по умолчанию

  /* Константы описания приходов */
  SINCDEPS_TYPE DOCTYPES.DOCCODE%type := 'ПНП'; -- Тип документа "Приход из подразделений"
  SINCDEPS_PREF INCOMEFROMDEPS.DOC_PREF%type := 'ПНП'; -- Префикс документа "Приход из подразделений"

  /* Константы описания расходов */
  STRINVCUST_TYPE DOCTYPES.DOCCODE%type := 'РНОП'; -- Тип документа "Расходная накладная на отпуск потребителям"
  STRINVCUST_PREF INCOMEFROMDEPS.DOC_PREF%type := 'РНОП'; -- Префикс документа "Расходная накладная на отпуск потребителям"

  /* Загрузка стенда товаром */
  procedure LOAD(NCOMPANY number -- Регистрационный номер организации 
                 );

  /* Откат последней загрузки стенда */
  procedure LOAD_ROLLBACK(NCOMPANY number -- Регистрационный номер организации
                          );

  /* Отгрузка со стенда посетителю */
  procedure SHIPMENT
  (
    NCOMPANY        number, -- Регистрационный номер организации
    SCUSTOMER       varchar2, -- Мнемокод контрагента-покупателя
    NRACK_LINE      number, -- Номер яруса стеллажа стенда
    NRACK_LINE_CELL number -- Номер ячейки в ярусе стеллажа стенда
  );

  /* Откат отгрузки со стенда */
  procedure SHIPMENT_ROLLBACK
  (
    NCOMPANY      number, -- Регистрационный номер организации
    NTRANSINVCUST number -- Регистрационный номер отгрузочной РНОП
  );
end;
/
create or replace package body UDO_PKG_STAND as

  /* Загрузка стенда товаром */
  procedure LOAD(NCOMPANY number -- Регистрационный номер организации 
                 ) is
    NCRN                INCOMEFROMDEPS.RN%type; -- Каталог размещения документов "Приход из подразделения"
    NJUR_PERS           JURPERSONS.RN%type; -- Регистрационный номер юридического лица "Прихода из подразделения" (основное ЮЛ организации)
    SJUR_PERS           JURPERSONS.CODE%type; -- Мнемокод номер юридического лица "Прихода из подразделения" (основное ЮЛ организации)
    SDOC_NUMB           INCOMEFROMDEPS.DOC_NUMB%type; -- Номер формируемого "Прихода из подразделения"
    SOUT_DEPARTMENT     INS_DEPARTMENT.CODE%type; -- Подразделение-отправитель формируемого "Прихода из подразделения"
    SAGENT              AGNLIST.AGNABBR%type; -- МОЛ формируемого "Прихода из подразделения"
    SCURRENCY           CURNAMES.CURCODE%type; -- Валюта формируемого "Прихода из подразделения" (базовая валюта организации)
    NNOMMODIF           NOMMODIF.RN%type; -- Рег. номер отгружаемой модификации номенклатуры
    NQUANT              INCOMEFROMDEPSSPEC.QUANT_PLAN%type; -- Количество номенклатуры в формируемом "Прихода из подразделения"
    NINCOMEFROMDEPS     INCOMEFROMDEPS.RN%type; -- Рег. номер сформированного "Прихода из подразделения"
    NINCOMEFROMDEPSSPEC INCOMEFROMDEPSSPEC.RN%type; -- Рег. номер сформированной позиции спецификации "Прихода из подразделения"
    NSTRPLRESJRNL       STRPLRESJRNL.RN%type; -- Рег. номер сформированной записи резервирования по местам хранения
    NWARNING            PKG_STD.TREF; -- Флаг предупреждения процедуры отработки прихода
    SMSG                PKG_STD.TSTRING; -- Текст сообщения процедуры отработки прихода
  begin
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
  
    /* Выясним регистрационный номер номенклатуры по-умолчанию */
    FIND_NOMMODIF_CODE(NFLAG_SMART  => 0,
                       NFLAG_OPTION => 0,
                       NCOMPANY     => NCOMPANY,
                       NPRN         => null,
                       SPRN         => SDEF_NOMEN,
                       SMODIF_CODE  => SDEF_NOMEN_MODIF,
                       NRN          => NNOMMODIF);
  
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
                            DDOC_DATE         => TRUNC(sysdate),
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
    for I in 1 .. NRACK_LINES
    loop
      for J in 1 .. NRACK_LINE_CELLS
      loop
        P_STRPLRESJRNL_INSERT(NCOMPANY        => NCOMPANY,
                              SMASTERUNITCODE => 'IncomFromDeps',
                              SSLAVEUNITCODE  => 'IncomFromDepsSpecs',
                              NMASTERRN       => NINCOMEFROMDEPS,
                              NSLAVERN        => NINCOMEFROMDEPSSPEC,
                              SSTORE          => SSTORE_GOODS,
                              SRACK_PREF      => SRACK_PREF,
                              SRACK_NUMB      => SRACK_NUMB,
                              SCELL_PREF      => SRACK_CELL_PREF_TMPL || I,
                              SCELL_NUMB      => SRACK_CELL_NUMB_TMPL || J,
                              NGOODSSUPPLY    => null,
                              NRES_TYPE       => 0,
                              SNOMEN          => SDEF_NOMEN,
                              SNOMMODIF       => SDEF_NOMEN_MODIF,
                              SNOMNMODIFPACK  => null,
                              NNOMMODIF       => NNOMMODIF,
                              NNOMNMODIFPACK  => null,
                              SARTICLE        => null,
                              NARTICLE        => null,
                              SGOODSUNIT      => null,
                              SDOCTYPE        => SINCDEPS_TYPE,
                              DDOCDATE        => TRUNC(sysdate),
                              SDOCNUMB        => SDOC_NUMB,
                              SDOCPREF        => SINCDEPS_PREF,
                              DRESERVING_DATE => sysdate,
                              DFREE_DATE      => null,
                              NQUANT          => NRACK_CELL_CAPACITY,
                              NQUANTALT       => 0,
                              NQUANTPACK      => null,
                              NRN             => NSTRPLRESJRNL);
      end loop;
    end loop;
  
    /* Отработка документа как "Факт" */
    P_INCOMEFROMDEPS_SET_STATUS(NCOMPANY  => NCOMPANY,
                                NRN       => NINCOMEFROMDEPS,
                                NSTATUS   => 2,
                                DWORKDATE => TRUNC(sysdate),
                                NWARNING  => NWARNING,
                                SMSG      => SMSG);
    if ((NWARNING is not null) or (SMSG is not null)) then
      P_EXCEPTION(0, NVL(SMSG, 'Ошибка отработки документа!'));
    end if;
  
    /* Распределение спецификации по местам хранения */
    P_STRPLRESJRNL_INDEPTS_PROCESS(NCOMPANY => NCOMPANY, NRN => NINCOMEFROMDEPS);
  end;

  /* Откат последней загрузки стенда */
  procedure LOAD_ROLLBACK(NCOMPANY number -- Регистрационный номер организации
                          ) is
    NINCOMEFROMDEPS INCOMEFROMDEPS.RN%type; -- Рег. номер расформируемого "Прихода из подразделения"
    NWARNING        PKG_STD.TREF; -- Флаг предупреждения процедуры отработки прихода
    SMSG            PKG_STD.TSTRING; -- Текст сообщения процедуры отработки прихода
  begin
    /* Находим последнюю загрузку */
    begin
      select max(T.RN)
        into NINCOMEFROMDEPS
        from INCOMEFROMDEPS T,
             DOCTYPES       DT,
             AZSAZSLISTMT   STORE_FROM,
             AZSAZSLISTMT   STORE_TO
       where T.COMPANY = NCOMPANY
         and T.DOC_TYPE = DT.RN
         and DT.DOCCODE = SINCDEPS_TYPE
         and trim(T.DOC_PREF) = SINCDEPS_PREF
         and T.OUT_STORE = STORE_FROM.RN
         and STORE_FROM.AZS_NUMBER = SSTORE_PRODUCE
         and T.STORE = STORE_TO.RN
         and STORE_TO.AZS_NUMBER = SSTORE_GOODS;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0, 'Не найдено ни одной загрузки стенда!');
    end;
  
    /* Отменяем размещение на местах хранения */
    P_STRPLRESJRNL_INDEPTS_RLLBACK(NCOMPANY => NCOMPANY, NRN => NINCOMEFROMDEPS);
  
    /* Снимаем отработку */
    P_INCOMEFROMDEPS_SET_STATUS(NCOMPANY  => NCOMPANY,
                                NRN       => NINCOMEFROMDEPS,
                                NSTATUS   => 0,
                                DWORKDATE => sysdate,
                                NWARNING  => NWARNING,
                                SMSG      => SMSG);
    if ((NWARNING is not null) or (SMSG is not null)) then
      P_EXCEPTION(0, NVL(SMSG, 'Ошибка снятия отработки документа!'));
    end if;
  
    /* Удаляем резервирование по местам хранения */
    for C in (select T.COMPANY,
                     T.RN
                from STRPLRESJRNL       T,
                     INCOMEFROMDEPSSPEC SP,
                     DOCLINKS           L
               where T.COMPANY = NCOMPANY
                 and SP.PRN = NINCOMEFROMDEPS
                 and L.IN_DOCUMENT = SP.RN
                 and L.IN_UNITCODE = 'IncomFromDepsSpecs'
                 and L.OUT_UNITCODE = 'StoragePlacesResJournal'
                 and L.OUT_DOCUMENT = T.RN)
    loop
      P_STRPLRESJRNL_DELETE(NCOMPANY => C.COMPANY, NRN => C.RN);
    end loop;
  
    /* Удаляем документ */
    P_INCOMEFROMDEPS_DELETE(NCOMPANY => NCOMPANY, NRN => NINCOMEFROMDEPS);
  end;

  /* Отгрузка со стенда посетителю */
  procedure SHIPMENT
  (
    NCOMPANY        number, -- Регистрационный номер организации
    SCUSTOMER       varchar2, -- Мнемокод контрагента-покупателя
    NRACK_LINE      number, -- Номер яруса стеллажа стенда
    NRACK_LINE_CELL number -- Номер ячейки в ярусе стеллажа стенда
  ) is
    NCRN               INCOMEFROMDEPS.RN%type; -- Каталог размещения РНОП
    NJUR_PERS          JURPERSONS.RN%type; -- Регистрационный номер юридического лица РНОП (основное ЮЛ организации)
    SJUR_PERS          JURPERSONS.CODE%type; -- Мнемокод номер юридического лица РНОП (основное ЮЛ организации)
    SCURRENCY          CURNAMES.CURCODE%type; -- Валюта формируемого РНОП (базовая валюта организации)
    NNOMMODIF          NOMMODIF.RN%type; -- Рег. номер отгружаемой модификации номенклатуры
    SNUMB              TRANSINVCUST.NUMB%type; -- Номер формируемого РНОП
    SMOL               AGNLIST.AGNABBR%type; -- МОЛ склада отгрузки РНОП
    SMSG               PKG_STD.TSTRING; -- Текст сообщения процедуры добавления РНОП/спецификации РНОП/отработки РНОП
    NTRANSINVCUST      TRANSINVCUST.RN%type; -- Регистрационный номер сформированной РНОП
    NTRANSINVCUSTSPECS TRANSINVCUSTSPECS.RN%type; -- Регистрационный номер сформированной спецификации РНОП
    NGOODSSUPPLY       GOODSSUPPLY.RN%type; -- Регистрационный номер товарного запаса для резервирования
    NSTRPLRESJRNL      STRPLRESJRNL.RN%type; -- Регистрационный номер сформированной записи резервирования по местам хранения
    NTMP_QUANT         PKG_STD.TQUANT; -- Буфер для количества номенклатуры в товарном запасе
  begin
    /* Определим рег. номер каталога */
    FIND_ROOT_CATALOG(NCOMPANY => NCOMPANY, SCODE => 'GoodsTransInvoicesToConsumers', NCRN => NCRN);
  
    /* Определим основное юридическое лицо организации */
    FIND_JURPERSONS_MAIN(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SJUR_PERS => SJUR_PERS, NJUR_PERS => NJUR_PERS);
  
    /* Определим базовую валюту */
    FIND_CURRENCY_BASE_NAME(NCOMPANY => NCOMPANY, SCODE => SCURRENCY, SISO => SCURRENCY);
  
    /* Выясним регистрационный номер номенклатуры по-умолчанию */
    FIND_NOMMODIF_CODE(NFLAG_SMART  => 0,
                       NFLAG_OPTION => 0,
                       NCOMPANY     => NCOMPANY,
                       NPRN         => null,
                       SPRN         => SDEF_NOMEN,
                       SMODIF_CODE  => SDEF_NOMEN_MODIF,
                       NRN          => NNOMMODIF);
  
    /* Определим МОЛ склада отгрузки */
    begin
      select AG.AGNABBR
        into SMOL
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
  
    /* Расчитаем очередной номер РНОП */
    P_TRANSINVCUST_GETNEXTNUMB(NCOMPANY  => NCOMPANY,
                               SJUR_PERS => SJUR_PERS,
                               DDOCDATE  => TRUNC(sysdate),
                               STYPE     => STRINVCUST_TYPE,
                               SPREF     => STRINVCUST_PREF,
                               SNUMB     => SNUMB);
  
    /* Добавляем заголовок РНОП */
    P_TRANSINVCUST_INSERT(NCOMPANY       => NCOMPANY,
                          NCRN           => NCRN,
                          SJUR_PERS      => SJUR_PERS,
                          SDOCTYPE       => STRINVCUST_TYPE,
                          SPREF          => STRINVCUST_PREF,
                          SNUMB          => SNUMB,
                          DDOCDATE       => TRUNC(sysdate),
                          NAUTO_CURCOURS => 1,
                          DSALEDATE      => TRUNC(sysdate),
                          SACCDOC        => null,
                          SACCNUMB       => null,
                          DACCDATE       => null,
                          SDIRDOC        => null,
                          SDIRNUMB       => null,
                          DDIRDATE       => null,
                          SSTOPER        => SDEF_STORE_MOVE_OUT,
                          SFACEACC       => SDEF_FACE_ACC,
                          SGRAPHPOINT    => null,
                          SAGENT         => SCUSTOMER,
                          STARIF         => SDEF_TARIF,
                          NSERVACT_SIGN  => 0,
                          SSTORE         => SSTORE_GOODS,
                          SMOL           => SMOL,
                          SSHEEPVIEW     => SDEF_SHEEP_VIEW,
                          SPAYTYPE       => SDEF_PAY_TYPE,
                          NDISCOUNT      => 0,
                          SCURRENCY      => SCURRENCY,
                          NCURCOURS      => 1,
                          NCURBASE       => 1,
                          NFA_COURS      => 1,
                          NFA_BASECOURS  => 1,
                          NSUMM          => 0,
                          NSUMMWITHNDS   => 0,
                          SRECIPDOC      => null,
                          SRECIPNUMB     => null,
                          DRECIPDATE     => null,
                          SFERRYMAN      => null,
                          SSHIPPER       => null,
                          SAGNFIFO       => null,
                          SFORWARDER     => null,
                          SWAYBLADENUMB  => null,
                          SDRIVER        => null,
                          SCAR           => null,
                          SROUTE         => null,
                          STRAILER1      => null,
                          STRAILER2      => null,
                          SCOMMENTS      => null,
                          SACC_AGENT     => null,
                          SSUBDIV        => null,
                          SBARCODE       => null,
                          SPAYCONF_TYPE  => null,
                          SPAYCONF_NUMB  => null,
                          DPAYCONF_DATE  => null,
                          SREG_AGENT     => null,
                          NRN            => NTRANSINVCUST,
                          SMSG           => SMSG);
  
    /* Добавим спецификацию РНОП */
    P_TRANSINVCUSTSPECS_INSERT(NCOMPANY         => NCOMPANY,
                               NPRN             => NTRANSINVCUST,
                               STAXGR           => SDEF_TAX_GROUP,
                               SGOODSPARTY      => null,
                               SNOMEN           => SDEF_NOMEN,
                               SNOMMODIF        => SDEF_NOMEN_MODIF,
                               SNOMNMODIFPACK   => null,
                               SARTICLE         => null,
                               SCELL            => null,
                               SHLCARGOCLASS    => null,
                               NTEMPERATURE     => null,
                               NPRICE           => 0,
                               NDISCOUNT        => 0,
                               NQUANT           => NRACK_CELL_SHIP_CNT,
                               NQUANTALT        => 0,
                               NCOEFF           => 0,
                               NCOEFF_VAL_SIGN  => 0,
                               NCOEFF_CALC_SIGN => 1,
                               NPRICEMEAS       => 0,
                               NSUMM            => 0,
                               NSUMMWITHNDS     => 0,
                               NSUMM_NDS        => 0,
                               NAUTOCALC_SIGN   => 1,
                               DBEGINDATE       => null,
                               DENDDATE         => null,
                               SSERNUMB         => null,
                               SCOUNTRY         => null,
                               SGTD             => null,
                               SNOTE            => null,
                               NDUP_RN          => null,
                               NRN              => NTRANSINVCUSTSPECS,
                               SMSG             => SMSG);
  
    /* Найдем товарный запас */
    FIND_STPLGOODSSUPPLY_BY_PARTY(NFLAG_SMART   => 1,
                                  NCOMPANY      => NCOMPANY,
                                  SSTORE        => SSTORE_GOODS,
                                  SRACK         => SRACK_PREF || '-' || SRACK_NUMB,
                                  SCELL         => SRACK_CELL_PREF_TMPL || TO_CHAR(NRACK_LINE) || '-' ||
                                                   SRACK_CELL_NUMB_TMPL || TO_CHAR(NRACK_LINE_CELL),
                                  SINDOC        => SDEF_STORE_PARTY,
                                  SSERNUMB      => null,
                                  SCOUNTRY      => null,
                                  SGTD          => null,
                                  SNOMEN        => SDEF_NOMEN,
                                  SNOMMODIF     => SDEF_NOMEN_MODIF,
                                  SNOMMODIFPACK => null,
                                  SARTICLE      => null,
                                  DDATE         => sysdate,
                                  NGOODSSUPPLY  => NGOODSSUPPLY,
                                  NQUANT        => NTMP_QUANT,
                                  NQUANTALT     => NTMP_QUANT,
                                  NQUANTPACK    => NTMP_QUANT);
    if (NGOODSSUPPLY is null) then
      P_EXCEPTION(0,
                  'Не удалось определить товарный запас модификации "%s" номенклатуры "%s" на месте хранения "%s" стеллажа "%s" склада "%s"!',
                  SDEF_NOMEN_MODIF,
                  SDEF_NOMEN,
                  SRACK_CELL_PREF_TMPL || TO_CHAR(NRACK_LINE) || '-' || SRACK_CELL_NUMB_TMPL ||
                  TO_CHAR(NRACK_LINE_CELL),
                  SRACK_PREF || '-' || SRACK_NUMB,
                  SSTORE_GOODS);
    end if;
  
    /* Резервируем товар на местах хранения */
    P_STRPLRESJRNL_INSERT(NCOMPANY        => NCOMPANY,
                          SMASTERUNITCODE => 'GoodsTransInvoicesToConsumers',
                          SSLAVEUNITCODE  => 'GoodsTransInvoicesToConsumersSpecs',
                          NMASTERRN       => NTRANSINVCUST,
                          NSLAVERN        => NTRANSINVCUSTSPECS,
                          SSTORE          => SSTORE_GOODS,
                          SRACK_PREF      => SRACK_PREF,
                          SRACK_NUMB      => SRACK_NUMB,
                          SCELL_PREF      => SRACK_CELL_PREF_TMPL || NRACK_LINE,
                          SCELL_NUMB      => SRACK_CELL_NUMB_TMPL || NRACK_LINE_CELL,
                          NGOODSSUPPLY    => NGOODSSUPPLY,
                          NRES_TYPE       => 1,
                          SNOMEN          => SDEF_NOMEN,
                          SNOMMODIF       => SDEF_NOMEN_MODIF,
                          SNOMNMODIFPACK  => null,
                          NNOMMODIF       => NNOMMODIF,
                          NNOMNMODIFPACK  => null,
                          SARTICLE        => null,
                          NARTICLE        => null,
                          SGOODSUNIT      => null,
                          SDOCTYPE        => STRINVCUST_TYPE,
                          DDOCDATE        => TRUNC(sysdate),
                          SDOCNUMB        => SNUMB,
                          SDOCPREF        => STRINVCUST_PREF,
                          DRESERVING_DATE => sysdate,
                          DFREE_DATE      => null,
                          NQUANT          => NRACK_CELL_SHIP_CNT,
                          NQUANTALT       => 0,
                          NQUANTPACK      => null,
                          NRN             => NSTRPLRESJRNL);
  
    /* Отработаем сформированный РНОП как факт */
    P_TRANSINVCUST_SET_STATUS(NCOMPANY   => NCOMPANY,
                              NRN        => NTRANSINVCUST,
                              NSTATUS    => 2,
                              DWORK_DATE => TRUNC(sysdate),
                              SMSG       => SMSG);
  
    /* Спишем резерв с мест хранения */
    P_STRPLRESJRNL_GTINV2C_PROCESS(NCOMPANY => NCOMPANY, NRN => NTRANSINVCUST, NRES_TYPE => 1);
  end;

  /* Откат отгрузки со стенда */
  procedure SHIPMENT_ROLLBACK
  (
    NCOMPANY      number, -- Регистрационный номер организации
    NTRANSINVCUST number -- Регистрационный номер отгрузочной РНОП
  ) is
  begin
    null;
  end;

end;
/
