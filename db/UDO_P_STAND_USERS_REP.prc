/* Печать бейджей с QR-кодами пользователей */
create or replace procedure UDO_P_STAND_USERS_REP
(
  NCOMPANY in number, -- Регистрационный номер организации
  NIDENT   in number -- Идентификатор отмеченных записей
) as
  NVERSION    VERSIONS.RN%type; -- Версия раздела "Контрагенты"
  NDP_BARCODE DOCS_PROPS.RN%type; -- Регистрационный номер дополнительного свойства для хранения штрихкода
  BQRCODE     blob; -- Изображение QR-кода
  ICNT        int; -- Счетчик посетителей
  ILIST_COUNT int; -- Счетчик страниц отчета
  IPOS        int; -- Позиция бейджа на листе (1 или 2)
  SSHEET      PKG_STD.TSTRING := 'Лист1'; -- Наименование листа отчета
  SCELL_SORG  PKG_STD.TSTRING := 'SORG'; -- Наименование ячейки организации посетителя
  SCELL_SNAME PKG_STD.TSTRING := 'SNAME'; -- Наименование ячейки ФИО посетителя
  SCELL_SBAR  PKG_STD.TSTRING := 'SBAR'; -- Наименование ячейки QR-кода посетителя
  SCELL_SCODE PKG_STD.TSTRING := 'SCODE'; -- Наименование ячейки кода посетителя
begin
  /* Инициализация отчета */
  PRSG_EXCEL.PREPARE;
  /* Выбор листа */
  PRSG_EXCEL.SHEET_SELECT(SSHEET_NAME => SSHEET);
  /* Описание 1го бейджа на листе */
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SORG || '1');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SNAME || '1');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SBAR || '1');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SCODE || '1');
  /* Описание 2го бейджа на листе */
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SORG || '2');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SNAME || '2');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SBAR || '2');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SCODE || '2');

  /* Определим версию раздела "Контрагенты" */
  FIND_VERSION_BY_COMPANY(NCOMPANY => NCOMPANY, SUNITCODE => 'AGNLIST', NVERSION => NVERSION);


  /* Определим регистрационный номер дополнительного свойства для хранения штрихкода */
  FIND_DOCS_PROPS_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SCODE => 'ШтрихКод', NRN => NDP_BARCODE);

  ICNT        := 0;
  ILIST_COUNT := 0;

  /* Идем по всем записям контрагентов из каталога "Посетители стенда" */
  for REC in (select T.AGNNAME,
                     T.FULLNAME,
                     F_DOCS_PROPS_GET_STR_VALUE(NPROPERTY => NDP_BARCODE, SUNITCODE => 'AGNLIST', NDOCUMENT => T.RN) as BARCODE,
                     T.AGN_COMMENT
                from AGNLIST    T,
                     SELECTLIST S
               where T.VERSION = NVERSION
                 and S.IDENT = NIDENT
                 and T.RN = S.DOCUMENT)
  loop
    /* Увеличиваем счетчик посетителей */
    ICNT := ICNT + 1;
    /* По умолчанию пишем во 2ую позицию на листе */
    IPOS := 2;
    /* Если посетитель нечетный */
    if (mod(ICNT, 2) != 0) then
      /* Увеличиваем счетчик страниц отчета */
      ILIST_COUNT := ILIST_COUNT + 1;
      /* Копируем лист из шаблона */
      PRSG_EXCEL.SHEET_COPY(SSHEET, SSHEET || '.' || ILIST_COUNT, SSHEET);
      /* Выбираем новый лист */
      PRSG_EXCEL.SHEET_SELECT(SSHEET || '.' || ILIST_COUNT);
      /* Пишем в 1ую позицию на листе */
      IPOS := 1;
    end if;
    /* Записываем организацию */
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => SCELL_SORG || IPOS, SCELL_VALUE => REC.FULLNAME);
    /* Заливаем ячейку цветом указанным в примечании*/
    PRSG_EXCEL.CELL_ATTRIBUTE_SET(SCELL_NAME       => SCELL_SORG || IPOS,
                                  SATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                  SATTRIBUTE_VALUE => REC.AGN_COMMENT);
    /* По умолчанию цвет текста - белый, устанавливаем для всех остальных черный*/
    if REC.AGN_COMMENT not in ('43', '55') then
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(SCELL_NAME       => SCELL_SORG || IPOS,
                                    SATTRIBUTE_NAME  => 'Font.ColorIndex',
                                    SATTRIBUTE_VALUE => '1');
    end if;
    /* Записываем ФИО */
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => SCELL_SNAME || IPOS, SCELL_VALUE => REC.AGNNAME);
    /* Генерируем изображение QR-кода */
    BQRCODE := F_QRCODE_ENCODE(STEXT => 'https://citkparus.github.io/parus_stand/?id=' || REC.BARCODE, NSIZE => 168);
    /* Записываем изображение QR-кода */
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => SCELL_SBAR || IPOS, BCELL_VALUE => BQRCODE);
    /* Записываем код */
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_SCODE || IPOS, REC.BARCODE);
  end loop;

  /* Удалем лист шаблона */
  PRSG_EXCEL.SHEET_DELETE(SSHEET);
end;
/
