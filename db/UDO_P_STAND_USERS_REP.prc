/* ������ ������� � QR-������ ������������� */
create or replace procedure UDO_P_STAND_USERS_REP
(
  NCOMPANY in number, -- ��������������� ����� �����������
  NIDENT   in number -- ������������� ���������� �������
) as
  NVERSION    VERSIONS.RN%type; -- ������ ������� "�����������"
  NDP_BARCODE DOCS_PROPS.RN%type; -- ��������������� ����� ��������������� �������� ��� �������� ���������
  BQRCODE     blob; -- ����������� QR-����
  ICNT        int; -- ������� �����������
  ILIST_COUNT int; -- ������� ������� ������
  IPOS        int; -- ������� ������ �� ����� (1 ��� 2)
  SSHEET      PKG_STD.TSTRING := '����1'; -- ������������ ����� ������
  SCELL_SORG  PKG_STD.TSTRING := 'SORG'; -- ������������ ������ ����������� ����������
  SCELL_SNAME PKG_STD.TSTRING := 'SNAME'; -- ������������ ������ ��� ����������
  SCELL_SBAR  PKG_STD.TSTRING := 'SBAR'; -- ������������ ������ QR-���� ����������
  SCELL_SCODE PKG_STD.TSTRING := 'SCODE'; -- ������������ ������ ���� ����������
begin
  /* ������������� ������ */
  PRSG_EXCEL.PREPARE;
  /* ����� ����� */
  PRSG_EXCEL.SHEET_SELECT(SSHEET_NAME => SSHEET);
  /* �������� 1�� ������ �� ����� */
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SORG || '1');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SNAME || '1');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SBAR || '1');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SCODE || '1');
  /* �������� 2�� ������ �� ����� */
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SORG || '2');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SNAME || '2');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SBAR || '2');
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => SCELL_SCODE || '2');

  /* ��������� ������ ������� "�����������" */
  FIND_VERSION_BY_COMPANY(NCOMPANY => NCOMPANY, SUNITCODE => 'AGNLIST', NVERSION => NVERSION);


  /* ��������� ��������������� ����� ��������������� �������� ��� �������� ��������� */
  FIND_DOCS_PROPS_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SCODE => '��������', NRN => NDP_BARCODE);

  ICNT        := 0;
  ILIST_COUNT := 0;

  /* ���� �� ���� ������� ������������ �� �������� "���������� ������" */
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
    /* ����������� ������� ����������� */
    ICNT := ICNT + 1;
    /* �� ��������� ����� �� 2�� ������� �� ����� */
    IPOS := 2;
    /* ���� ���������� �������� */
    if (mod(ICNT, 2) != 0) then
      /* ����������� ������� ������� ������ */
      ILIST_COUNT := ILIST_COUNT + 1;
      /* �������� ���� �� ������� */
      PRSG_EXCEL.SHEET_COPY(SSHEET, SSHEET || '.' || ILIST_COUNT, SSHEET);
      /* �������� ����� ���� */
      PRSG_EXCEL.SHEET_SELECT(SSHEET || '.' || ILIST_COUNT);
      /* ����� � 1�� ������� �� ����� */
      IPOS := 1;
    end if;
    /* ���������� ����������� */
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => SCELL_SORG || IPOS, SCELL_VALUE => REC.FULLNAME);
    /* �������� ������ ������ ��������� � ����������*/
    PRSG_EXCEL.CELL_ATTRIBUTE_SET(SCELL_NAME       => SCELL_SORG || IPOS,
                                  SATTRIBUTE_NAME  => 'Interior.ColorIndex',
                                  SATTRIBUTE_VALUE => REC.AGN_COMMENT);
    /* �� ��������� ���� ������ - �����, ������������� ��� ���� ��������� ������*/
    if REC.AGN_COMMENT not in ('43', '55') then
      PRSG_EXCEL.CELL_ATTRIBUTE_SET(SCELL_NAME       => SCELL_SORG || IPOS,
                                    SATTRIBUTE_NAME  => 'Font.ColorIndex',
                                    SATTRIBUTE_VALUE => '1');
    end if;
    /* ���������� ��� */
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => SCELL_SNAME || IPOS, SCELL_VALUE => REC.AGNNAME);
    /* ���������� ����������� QR-���� */
    BQRCODE := F_QRCODE_ENCODE(STEXT => 'https://citkparus.github.io/parus_stand/?id=' || REC.BARCODE, NSIZE => 168);
    /* ���������� ����������� QR-���� */
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => SCELL_SBAR || IPOS, BCELL_VALUE => BQRCODE);
    /* ���������� ��� */
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_SCODE || IPOS, REC.BARCODE);
  end loop;

  /* ������ ���� ������� */
  PRSG_EXCEL.SHEET_DELETE(SSHEET);
end;
/
