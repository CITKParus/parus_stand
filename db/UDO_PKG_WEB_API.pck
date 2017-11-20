create or replace package UDO_PKG_WEB_API
/*
 ���������� HTTP-��������
*/
 as

  /* ��������� - ����� ������� */
  BDEBUG                    constant boolean := true; -- ����� �������

  /* ��������� - ���������� "������ �������" */
  NSESSION_EXPIRED_CODE       constant number(17) := -20500;              -- ��� ���������� "������ �������"
  SSESSION_EXPIRED_MSG        constant varchar2(20) := 'SESSION_EXPIRED'; -- ��������� ���������� "������ �������"
  ESESSION_EXPIRED            exception;                                  -- ���������� "������ �������"
  pragma exception_init(ESESSION_EXPIRED, -20500);                        -- ������������� ���������� "������ �������"
  
  /* ��������� - ���� ������� ������� */
  NRESP_FORMAT_JSON         constant number(1) := 0;                  -- ����� � JSON
  NRESP_FORMAT_XML          constant number(1) := 1;                  -- ����� � XML
  SRESP_TYPE_KEY            constant varchar2(20) := 'RESP_TYPE';     -- ������������ ����� ��� ������������� ������ �������
  SRESP_TYPE_VAL            constant varchar2(20) := 'STAND_MESSAGE'; -- �������� ����� ��� ������������� ������ �������
  SRESP_STATE_KEY           constant varchar2(20) := 'STATE';         -- ������������ ����� ��� �������� � ������ ��������� �������
  SRESP_MSG_KEY             constant varchar2(20) := 'MSG';           -- ������������ ����� ��� �������� � ������ ��������� �������
  NRESP_STATE_ERR           constant number(1) := 0;                  -- ������ ����������
  NRESP_STATE_OK            constant number(1) := 1;                  -- �������� ����������
  
  /* ��������� - ����� �������� (�����, ������� � ��������������� ������������) */
  SREQ_ACTION_KEY           constant varchar2(20) := 'SACTION';    -- ������������ ����� ��� �������� � ��������
  SREQ_SESSION_KEY          constant varchar2(20) := 'SSESSION';   -- ������������ ����� ��� �������������� ������
  SREQ_USER_KEY             constant varchar2(20) := 'SUSER';      -- ������������ ����� ��� ����� ������������
  SREQ_PASSWORD_KEY         constant varchar2(20) := 'SPASSWORD';  -- ������������ ����� ��� ����� ������������
  SREQ_COMPANY_KEY          constant varchar2(20) := 'SCOMPANY';   -- ������������ ����� ��� �������� �����������  
  SREQ_FILE_TYPE_KEY        constant varchar2(20) := 'SFILE_TYPE'; -- ������������ ����� ��� ���� ������������ �����
  SREQ_FILE_RN_KEY          constant varchar2(20) := 'NFILE_RN';   -- ������������ ����� ��� ���. ������ ������������ �����
  
  /* ��������� - ���� ����������� �������� ������� */
  SACTION_LOGIN             constant varchar2(20) := 'LOGIN';            -- ��������������
  SACTION_LOGOUT            constant varchar2(20) := 'LOGOUT';           -- ���������� ������
  SACTION_VERIFY            constant varchar2(20) := 'VERIFY';           -- �������� ���������� ������
  SACTION_DOWNLOAD          constant varchar2(20) := 'DOWNLOAD';         -- �������� �����
  SACTION_DOWNLOAD_GET_URL  constant varchar2(20) := 'DOWNLOAD_GET_URL'; -- ������������ URL ��� �������� �����
  
  /* ��������� - ���� ����������� ������ */
  SFILE_TYPE_REPORT         constant varchar2(20) := 'REPORT';        -- ������� �����
  
  /* ��������� - ����������� ���������� �������� ��� ����������� */
  NUNAUTH_YES               constant number(1) := 1; -- �������� ���������� ��� �����������
  NUNAUTH_NO                constant number(1) := 0; -- ���������� ���������� ��� �����������
  
  /* ��������� - ��������� ���������� ����������� */
  NEXEC_OK                  constant number(1) := 1; -- �������� ����������
  
  /* ��������� - ��������� ������ � ������� ������ */  
  NRPTQ_STATUS_QUEUE        constant number(1) := 0; -- ���������� � �������
  NRPTQ_STATUS_PROCESS      constant number(1) := 1; -- ���������� ������
  NRPTQ_STATUS_OK           constant number(1) := 2; -- ���������� ��������� (�������)
  NRPTQ_STATUS_ERR          constant number(1) := 3; -- ���������� ��������� (� ��������) 
  
  /* ��������� - ���� ������� */
  NRPT_TYPE_CRYSTAL         constant number(1) := 0; -- Crystal Reports
  NRPT_TYPE_EXCEL           constant number(1) := 1; -- MS Excel
  NRPT_TYPE_DRILL           constant number(1) := 2; -- DrillDown
  NRPT_TYPE_OOCALC          constant number(1) := 3; -- Open Office Calc
  NRPT_TYPE_BINARY          constant number(1) := 4; -- �������� ������
  
  /* ����������� ��� ��������� �������� WEB-������� */
  function AUTHORIZE
  (
    SPROCEDURE              varchar2         -- ��� ����������� ���������
  ) return boolean;
  
  /* ����������� ��������� �������� � �������� ��� ����� WEB-������������� */
  function UTL_CONVERT_TO_NUMBER
  (
    SSTR                    varchar2,        -- �������������� ������ (����������� 17.5, ����������� ���������� ������� � �������� ����������� ����� �������� (�� �� ������ �������!), ����������� ���������� � �������� ����������� ����� � ������� ����� "." ��� ",", ������������� �������������� ��������� � ������� �������, ������������� ��������� ��������� ����-�������)
    NSMART                  number := 0      -- ������� ������ ��������� �� ������ (0 - ��������, 1 - �� ��������)
  ) return number;
  
  /* ����������� �������� �������� � ��������� ��� ����� WEB-������������� */
  function UTL_CONVERT_TO_STRING
  (
    NNUMB                   number,          -- �������������� �����
    NSEPARATE               number := 0,     -- ��������� ������� (0 - ���, 1 - ��)
    NSHARP                  number := 2      -- �������� (���-�� ������ ����� �������, ������ ��� NSEPARATE = 1)
  ) return varchar2;
  
  /* ����������� ������ � ���� ��� ����� WEB-������������� */
  function UTL_CONVERT_TO_DATE
  (
    NSMART                  number,           -- ������� ������ ��������� �� ������
    SDATE                   varchar2,         -- ���� (��������� �������������)
    STEMPLATE               varchar2 := null, -- ������ ��� �����������
    SERR_MSG                varchar2 := null  -- ��������� �� ������ �����������
  ) return date; 
  
  /* ���������� ������ ������ */
  function UTL_RPT_GET
  (
    NREPORT                 number,          -- ��������������� ����� ������
    NSMART                  number := 0      -- ������� ������ ��������� �� ������ (0 - ��������, 1 - �� ��������)
  ) return USERREPORTS%rowtype;
  
  /* ���������� ������ ������� ������ ������� */
  function UTL_RPTQ_GET
  (
    NREPORTQ                number,          -- ��������������� ����� ������� ������� ������ �������
    NSMART                  number := 0      -- ������� ������ ��������� �� ������ (0 - ��������, 1 - �� ��������)
  ) return RPTPRTQUEUE%rowtype;
  
  /* ������������ ����� ����� �������� ������ */
  function UTL_RPTQ_BUILD_FILE_NAME
  (
    NREPORTQ                number           -- ��������������� ����� ������� �������
  ) return varchar2;      
  
  /* �������������� ����� ����� ��� ������������� � HTML-��������� */
  function UTL_PREPARE_FILENAME
  (
    SFILE_NAME              varchar2         -- ��� �����
  ) return varchar2;  
  
  /* ������������ URL ��� �������� ����� */
  function UTL_BUILD_DOWNLOAD_URL
  (
    SSESSION                varchar2,        -- ������������� ������
    SFILE_TYPE              varchar2,        -- ��� ����� (��. ��������� SFILE_TYPE_*)
    NFILE_RN                number           -- ��������������� ����� �����
  ) return varchar2;
  
  /* �������������� ������� ������ � ���������� */
  function RESP_TRANSLATE_MSG
  (
    SSTR_RU                 varchar2         -- ������ � �������� ��������� (CL8MSWIN1251)
  ) return varchar2;

  /* ������������ ��������� �� ������ */
  function RESP_CORRECT_ERR
  (
    SERR                    varchar2         -- ����������������� �������� �� ������
  ) return varchar2;

  /* ������������ ������������ ������ ������� */
  function RESP_MAKE
  (
    NRESP_FORMAT            number,          -- ������ ������ (0 - JSON, 1 - XML)
    NRESP_STATE             number,          -- ��� ������ (0 - ������, 1 - �����)
    SRESP_MSG               varchar2         -- ���������
  ) return clob;

  /* ������ ������������ ������ ������� (� JSON) */
  procedure RESP_PARSE
  (
    CJSON                   clob,            -- ������ ������
    NRESP_TYPE              out number,      -- ��� ������ (0 - ������, 1 - �����, null - CJSON �� �������� ����������� ������� �������)
    SRESP_MSG               out varchar2     -- ��������� �������
  );

  /* ������ ������ WEB-������� */
  procedure RESP_PUBLISH
  (
    CDATA                   clob,                    -- ������
    SCONTENT_TYPE           varchar2 := 'text/json', -- MIME-Type ��� ������
    SCHARSET                varchar2 := 'UTF-8'      -- ���������
  );

  /* ������ ������ WEB-������� (� ���� ����� ��� ����������) */
  procedure RESP_DOWNLOAD
  (
    BDATA                   in out nocopy blob,                    -- ������
    SFILE_NAME              varchar2,                              -- ��� �����
    SCONTENT_TYPE           varchar2 := 'application/octet-stream' -- MIME-Type ��� ������
  );
  
  /* ����������� ������������ ������ */
  function SESSION_GET_USER return varchar2;

  /* �������� ������������ ������ */
  procedure SESSION_VALIDATE
  (
    SSESSION                varchar2         -- ������������� ������
  );

  /* ���������� ������ ����������� */
  function WEB_API_ACTIONS_GET
  (
    NRN                     number,          -- ��������������� ����� ������
    NSMART                  number := 0      -- ������� ������ ��������� �� ������
  ) return UDO_T_WEB_API_ACTIONS%rowtype;

  /* ���������� ������ ����������� (�� ���� ��������) */
  function WEB_API_ACTIONS_GET
  (
    SACTION                 varchar2,        -- ��� ��������
    NSMART                  number := 0      -- ������� ������ ��������� �� ������
  ) return UDO_T_WEB_API_ACTIONS%rowtype;

  /* ������ ����������� �������� */
  procedure WEB_API_ACTIONS_PROCESS
  (
    NRN                     number,          -- ��������������� ����� �����������
    CPRMS                   clob,            -- ������� ���������
    CRES                    out clob         -- ��������� ������
  );

  /* ��������� ������� WEB-������� (JSON) */
  procedure PROCESS
  (
    CPRMS                   clob             -- ��������� �������
  );

end;
/
create or replace package body UDO_PKG_WEB_API as
  
  /* ����������� ��� ��������� �������� WEB-������� */
  function AUTHORIZE
  (
    SPROCEDURE              varchar2         -- ��� ����������� ���������
  ) return boolean is
  begin
    /* ���� ���������� ��������� � ������ ����������� */
    if (UPPER(SPROCEDURE) in
       ('PARUS.UDO_PKG_WEB_API.PROCESS'
        ,'PARUS.UDO_PKG_WEB_API.DOWNLOAD'))
    then
      /* ��, � ����� ��������� */
      return true;
    else
      /* ���, � ������ ��������� */
      return false;
    end if;
  exception
    when others then
      /* ���� ���-�� �� ��� - �� ������ ������ �������� ���������� */
      return false;
  end;
  
  /* ����������� ��������� �������� � �������� ��� ����� WEB-������������� */
  function UTL_CONVERT_TO_NUMBER
  (
    SSTR                    varchar2,         -- �������������� ������ (����������� 17.5, ����������� ���������� ������� � �������� ����������� ����� �������� (�� �� ������ �������!), ����������� ���������� � �������� ����������� ����� � ������� ����� "." ��� ",", ������������� �������������� ��������� � ������� �������, ������������� ��������� ��������� ����-�������)
    NSMART                  number := 0       -- ������� ������ ��������� �� ������ (0 - ��������, 1 - �� ��������)
  ) return number is
    STMP                    PKG_STD.TLSTRING; -- ����� ��� �����������
    NTMP                    PKG_STD.TLNUMBER; -- ����� ��� �����������
  begin
    /* ������������ */
    begin
      if (SSTR is not null) then
        STMP := REGEXP_REPLACE(SSTR, '[ #&$%!@\(\)]');
        STMP := replace(STMP, ',', '.');
        NTMP := TO_NUMBER(STMP, '99999999999999999D99999', 'NLS_NUMERIC_CHARACTERS = ''. ''');
      end if;
    exception
      when others then
        P_EXCEPTION(NSMART,
                    '���������� �������� - "' || SSTR || '", �� �������� ������!');
    end;
    /* ������ ����� */
    return NTMP;
  end;

  /* ����������� �������� �������� � ��������� ��� ����� WEB-������������� */
  function UTL_CONVERT_TO_STRING
  (
    NNUMB                   number,          -- �������������� �����
    NSEPARATE               number := 0,     -- ��������� ������� (0 - ���, 1 - ��)
    NSHARP                  number := 2      -- �������� (���-�� ������ ����� �������, ������ ��� NSEPARATE = 1)
  ) return varchar2 is
    SPATTERN                PKG_STD.TSTRING; -- ������ ��� ����������� � �������������
    SRES                    PKG_STD.TSTRING; -- ��������� ������
  begin
    /* ������� ������� � ������, ��� ������������ */
    if (NSEPARATE = 0) then
      SRES := replace(TO_CHAR(NVL(NNUMB, 0)), ',', '.');
      if NNUMB < 1 and NNUMB > 0 then
        SRES := '0' || SRES;
      end if;
    else
      /* ������� � �������������, � ��������� ��������� */
      if ((NSHARP is null) or (NSHARP <= 0)) then
        SPATTERN := '999G999G999G999G999G990';
      else
        SPATTERN := '999G999G999G999G999G990D' || RPAD('9', TRUNC(NSHARP), '9');
      end if;
      SRES := trim(TO_CHAR(NNUMB, SPATTERN, 'nls_numeric_characters=''. '''));
    end if;
    /* ������ ����� */
    return SRES;
  exception
    when others then
      /* ���� ���-�� �� ��� - ������ ������ */
      return null;
  end;

  /* ����������� ������ � ���� ��� ����� WEB-������������� */
  function UTL_CONVERT_TO_DATE
  (
    NSMART                  number,           -- ������� ������ ��������� �� ������
    SDATE                   varchar2,         -- ���� (��������� �������������)
    STEMPLATE               varchar2 := null, -- ������ ��� �����������
    SERR_MSG                varchar2 := null  -- ��������� �� ������ �����������
  ) return date is
    DRESULT                 PKG_STD.TLDATE;   -- ��������� ������
  begin
    /* ������������ � ����������� �� ��������� ������������ */
    begin
      if (STEMPLATE is null) then
        if (SUBSTR(SDATE, 5, 1) = '-') then
          DRESULT := TO_DATE(SDATE, 'yyyy-mm-dd');
        elsif (SUBSTR(SDATE, 3, 1) = '.') then
          DRESULT := TO_DATE(SDATE, 'dd.mm.yyyy');
        else
          DRESULT := TO_DATE(SDATE, 'dd/mm/yyyy');
        end if;
      else
        DRESULT := TO_DATE(SDATE, STEMPLATE);
      end if;
    exception
      when others then
        /* ������ ������ */
        P_EXCEPTION(NSMART,
                    NVL(SERR_MSG, '���� ������ �����������.') || ' ������� ���� � ������� "' ||
                    NVL(STEMPLATE, '��.��.����') || '"!');
    end;
    /* ������ ����� */
    return DRESULT;
  end;
  
  /* ���������� ������ ������ */
  function UTL_RPT_GET
  (
    NREPORT                 number,              -- ��������������� ����� ������
    NSMART                  number := 0          -- ������� ������ ��������� �� ������ (0 - ��������, 1 - �� ��������)
  ) return USERREPORTS%rowtype is
    RES                     USERREPORTS%rowtype; -- ��������� ������
  begin
    /* ������� ������ */
    begin
      select T.* into RES from USERREPORTS T where T.RN = NREPORT;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART, NDOCUMENT => NREPORT, SUNIT_TABLE => 'USERREPORTS');
    end;
    /* ������ ��������� */
    return RES;
  end;
  
  /* ���������� ������ ������� ������ ������� */
  function UTL_RPTQ_GET
  (
    NREPORTQ                number,              -- ��������������� ����� ������� ������� ������ �������
    NSMART                  number := 0          -- ������� ������ ��������� �� ������ (0 - ��������, 1 - �� ��������)
  ) return RPTPRTQUEUE%rowtype is
    RES                     RPTPRTQUEUE%rowtype; -- ��������� ������
  begin
    /* ������� ������ */
    begin
      select T.* into RES from RPTPRTQUEUE T where T.RN = NREPORTQ;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART, NDOCUMENT => NREPORTQ, SUNIT_TABLE => 'RPTPRTQUEUE');
    end;
    /* ������ ��������� */
    return RES;
  end;
  
  /* ������������ ����� ����� �������� ������ */
  function UTL_RPTQ_BUILD_FILE_NAME
  (
    NREPORTQ                number               -- ��������������� ����� ������� �������
  ) return varchar2 is
    RPTQ_REC                RPTPRTQUEUE%rowtype; -- ������ ������� �������
    RPT_REC                 USERREPORTS%rowtype; -- ������ ������
    SEXT                    PKG_STD.TSTRING;     -- ���������� �����
    SFILE_NAME              PKG_STD.TSTRING;     -- ��� ����� ������
  begin
    /* C������ ������ ������� ������� */
    RPTQ_REC := UTL_RPTQ_GET(NREPORTQ => NREPORTQ);
    /* ������� ������ ������ */
    RPT_REC := UTL_RPT_GET(NREPORT => RPTQ_REC.USER_REPORT);
    /* ����������� � ����������� */
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
    /* ���������� ��� ����� */
    SFILE_NAME := RPTQ_REC.AUTHID || '_' || TO_CHAR(RPTQ_REC.RN) || '.' || SEXT;
    /* ������ ��������� */
    return SFILE_NAME;
  exception
    when others then
      return null;
  end;
  
  /* �������������� ����� ����� ��� ������������� � HTML-��������� */
  function UTL_PREPARE_FILENAME
  (
    SFILE_NAME              varchar2         -- ��� �����
  ) return varchar2 is
  begin
    return UTL_URL.ESCAPE(replace(replace(SUBSTR(SFILE_NAME, INSTR(SFILE_NAME, '/') + 1), CHR(10), null),
                                  CHR(13),
                                  null),
                          false,
                          'UTF8');
  end;
  
  /* ������������ URL ��� �������� ����� */
  function UTL_BUILD_DOWNLOAD_URL
  (
    SSESSION                varchar2,        -- ������������� ������
    SFILE_TYPE              varchar2,        -- ��� ����� (��. ��������� SFILE_TYPE_*)
    NFILE_RN                number           -- ��������������� ����� �����
  ) return varchar2 is
    JRES                    JSON;            -- ��������� ������ (��������� �������������)
    SRES                    PKG_STD.TSTRING; -- ��������� ������ (��������� �������������)
  begin
    /* �������� ��������� */
    if (SSESSION is null) then
      P_EXCEPTION(0,
                  '�� ������ ������������� ������ ��� ������������ URL �������� �����!');
    end if;
    if (SFILE_TYPE is null) then
      P_EXCEPTION(0,
                  '�� ������ ��� ����� ��� ������������ URL �������� �����!');
    end if;
    if (NFILE_RN is null) then
      P_EXCEPTION(0,
                  '�� ������ ������������� ����� ��� ������������ URL �������� �����!');
    end if;
    /* �������� �� ���� ����� */
    case (SFILE_TYPE)
      /* ���� �������� ������ */
      when (SFILE_TYPE_REPORT) then
        begin
          JRES := JSON();
          JRES.PUT(PAIR_NAME => SREQ_SESSION_KEY, PAIR_VALUE => SSESSION);
          JRES.PUT(PAIR_NAME => SREQ_ACTION_KEY, PAIR_VALUE => SACTION_DOWNLOAD);
          JRES.PUT(PAIR_NAME => SREQ_FILE_TYPE_KEY, PAIR_VALUE => SFILE_TYPE_REPORT);          
          JRES.PUT(PAIR_NAME => SREQ_FILE_RN_KEY, PAIR_VALUE => NFILE_RN);          
          SRES := JRES.TO_CHAR();
        end;
      /* ����������� ��� ����� */
      else
        P_EXCEPTION(0,
                    '��� ����� ���� "%s" �������� �� ��������������!',
                    SFILE_TYPE);
    end case;
    /* ������ ����� URL */
    return SRES;
  end;
  
  /* �������������� ������� ������ � ���������� */
  function RESP_TRANSLATE_MSG
  (
    SSTR_RU                 varchar2         -- ������ � �������� ��������� (CL8MSWIN1251)
  ) return varchar2 is
    SRES                    varchar2(4000);  -- ��������� ������
  begin
    /* �������� �������������� */
    SRES := TRANSLATE(UPPER(SSTR_RU), '������������������������', 'ABVGDEZIJKLMNOPRSTUF''Y''E');
    SRES := replace(SRES, '�', 'E');
    SRES := replace(SRES, '�', 'ZH');
    SRES := replace(SRES, '�', 'KH');
    SRES := replace(SRES, '�', 'TS');
    SRES := replace(SRES, '�', 'CH');
    SRES := replace(SRES, '�', 'SH');
    SRES := replace(SRES, '�', 'SH');
    SRES := replace(SRES, '�', 'YU');
    SRES := replace(SRES, '�', 'YA');    
    /* ������ ����� */
    return SRES;
  end;

  /* ������������ ��������� �� ������ */
  function RESP_CORRECT_ERR
  (
    SERR                    varchar2                -- ����������������� �������� �� ������
  ) return varchar2 is
    STMP                    varchar2(4000) := SERR; -- ����� ��� ��������
    SRES                    varchar2(4000);         -- ���������
    NB                      number;                 -- ������ ���������
    NE                      number;                 -- ��������� ���������
  begin
    begin
      /* ���� ���� ��������� */
      while (INSTR(STMP, 'ORA') <> 0)
      loop
        NB := INSTR(STMP, 'ORA');
        NE := INSTR(STMP, ':', NB);
        /* ������� �� */
        STMP := trim(replace(STMP, trim(SUBSTR(STMP, NB, NE - NB + 1)), ''));
      end loop;
      /* �������� ��������� */
      SRES := STMP;
    exception
      when others then
        SRES := SERR;
    end;
    
    /* ������ ��������� */
    return SRES;
  end;

  /* ������������ ������������ ������ ������� */
  function RESP_MAKE
  (
    NRESP_FORMAT            number,          -- ������ ������ (0 - JSON, 1 - XML)
    NRESP_STATE             number,          -- ��� ������ (0 - ������, 1 - �����)
    SRESP_MSG               varchar2         -- ���������
  ) return clob is
    CRESP                   clob;            -- ����� ������
  begin
    /* ������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRESP, CACHE => false);
    
    /* �������� ����� */
    case NRESP_FORMAT
      /* ���� ����� � JSON */
      when NRESP_FORMAT_JSON then
        declare
          JRESP      JSON;            -- ����� (��������� �������������)
          SRESP_MSG_ varchar2(32000); -- ����� ��� ���������
        begin
          /* �������������� ����� ��������� */
          SRESP_MSG_ := SRESP_MSG;
          /* ����������� ��������� �� ������ */
          if (NRESP_STATE = NRESP_STATE_ERR) then
            SRESP_MSG_ := RESP_CORRECT_ERR(SERR => SRESP_MSG_);
          end if;
          /* ���� ����� ������� - �� ������� � ��������� */
          if (BDEBUG) then
            SRESP_MSG_ := RESP_TRANSLATE_MSG(SSTR_RU => SRESP_MSG_);
          end if;
          /* �������������� ����� */
          JRESP := JSON();
          /* ��� ������ - ����������� ����� ������� */
          JRESP.PUT(PAIR_NAME => SRESP_TYPE_KEY, PAIR_VALUE => SRESP_TYPE_VAL);
          /* ��������� (0 - ������, 1 - �����) */
          JRESP.PUT(PAIR_NAME => SRESP_STATE_KEY, PAIR_VALUE => NRESP_STATE);
          /* ��������� */
          JRESP.PUT(PAIR_NAME => SRESP_MSG_KEY, PAIR_VALUE => SRESP_MSG_);
          /* �� � CLOB */
          JRESP.TO_CLOB(BUF => CRESP);
        end;
      /* ���� ����� � XML */
      when NRESP_FORMAT_XML then
        begin
          null;
        end;
      else
        null;
    end case;
    
    /* ������ ��������� */
    return CRESP;
  end;

  /* ������ ������������ ������ ������� (� JSON) */
  procedure RESP_PARSE
  (
    CJSON                   clob,            -- ������ ������
    NRESP_TYPE              out number,      -- ��� ������ (0 - ������, 1 - �����, null - CJSON �� �������� ����������� ������� �������)
    SRESP_MSG               out varchar2     -- ��������� �������
  ) is
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

  /* ������ ������ WEB-������� (� ���� HTTP-������) */
  procedure RESP_PUBLISH
  (
    CDATA                   clob,                    -- ������
    SCONTENT_TYPE           varchar2 := 'text/json', -- MIME-Type ��� ������
    SCHARSET                varchar2 := 'UTF-8'      -- ���������
  ) is
    NTOTLEN                 number(17);              -- ����� ���-�� �������� � ��������
    NREST                   number(17);              -- ������� �������� � ��������
    NBLEN                   number(17) := 2000;      -- ����� ���������� ������ (������)
    STMP                    varchar2(2000);          -- C�������� �����
    NI                      number(17) := 0;         -- C������ �������
  begin
    /* ���� ���� ������ */
    if ((CDATA is not null) and (DBMS_LOB.GETLENGTH(CDATA) > 0)) then
      /* ��������� ������� ����� ������ */
      NTOTLEN := DBMS_LOB.GETLENGTH(CDATA);
      /* ��������� ������� �������� �������� ������ */
      NREST := NTOTLEN;
      /* �������� ��������� */
      OWA_UTIL.MIME_HEADER(CCONTENT_TYPE => SCONTENT_TYPE, CCHARSET => SCHARSET, BCLOSE_HEADER => false);
      HTP.P('Content-length: ' || NTOTLEN);
      OWA_UTIL.HTTP_HEADER_CLOSE();
      /* ����� ����� �� ������ */
      while (NREST > 0)
      loop
        /* �������� */
        STMP := DBMS_LOB.SUBSTR(CDATA, NBLEN, (NBLEN * NI) + 1);
        /* ��������, ��� �������� */
        NI    := NI + 1;
        NREST := NREST - LENGTH(STMP);
        /* ������ */
        HTP.PRN(STMP);
      end loop;
    end if;
  end;
  
  /* ������ ������ WEB-������� (� ���� ����� ��� ����������) */
  procedure RESP_DOWNLOAD
  (
    BDATA                   in out nocopy blob,                    -- ������
    SFILE_NAME              varchar2,                              -- ��� �����
    SCONTENT_TYPE           varchar2 := 'application/octet-stream' -- MIME-Type ��� ������
  ) is
    NTOTLEN                 number(17);                            -- ����� ���-�� �������� � ��������
  begin
    /* ���� ���� ������ */
    if ((BDATA is not null) and (DBMS_LOB.GETLENGTH(BDATA) > 0)) then
      /* ��������� ������� ����� ������ */
      NTOTLEN := DBMS_LOB.GETLENGTH(BDATA);
      /* ��������� ��������� HTTP */
      OWA_UTIL.MIME_HEADER(CCONTENT_TYPE => SCONTENT_TYPE, BCLOSE_HEADER => false);
      /* ��������� ������ ������������ ����� � ��� ��� */
      HTP.P('Content-length: ' || NTOTLEN);
      HTP.P('Content-Disposition:  attachment; filename="' || UTL_PREPARE_FILENAME(SFILE_NAME => SFILE_NAME) || '"');
      /* ��������� ��������� */
      OWA_UTIL.HTTP_HEADER_CLOSE;
      /* �������� ������ */
      WPG_DOCLOAD.DOWNLOAD_FILE(BDATA);
    end if;
  end;

  /* ����������� ������������ ������ */
  function SESSION_GET_USER return varchar2 is
  begin
    return UTILIZER();
  end;

  /* �������� ������������ ������ */
  procedure SESSION_VALIDATE
  (
    SSESSION                varchar2         -- ������������� ������
  ) is
  begin
    /* ���������� ������ */
    PKG_SESSION.VALIDATE_WEB(SCONNECT => SSESSION);
  exception
    when others then
      RAISE_APPLICATION_ERROR(NSESSION_EXPIRED_CODE, SSESSION_EXPIRED_MSG);
  end;

  /* ���������� ������ ����������� */
  function WEB_API_ACTIONS_GET
  (
    NRN                     number,                        -- ��������������� ����� ������
    NSMART                  number := 0                    -- ������� ������ ��������� �� ������
  ) return UDO_T_WEB_API_ACTIONS%rowtype is
    RES                     UDO_T_WEB_API_ACTIONS%rowtype; -- ��������� ������
    SERR                    varchar2(4000);                -- ����� ��� ������
  begin
    /* ������� ������ */
    begin
      select T.* into RES from UDO_T_WEB_API_ACTIONS T where T.RN = NRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART, NDOCUMENT => NRN, SUNIT_TABLE => 'UDO_T_HTTP_ACTIONS');
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(NSMART, SERR);
    end;
    
    /* ������ ��������� */
    return RES;
  end;

  /* ���������� ������ ����������� (�� ���� ��������) */
  function WEB_API_ACTIONS_GET
  (
    SACTION                 varchar2,                      -- ��� ��������
    NSMART                  number := 0                    -- ������� ������ ��������� �� ������
  ) return UDO_T_WEB_API_ACTIONS%rowtype is
    RES                     UDO_T_WEB_API_ACTIONS%rowtype; -- ��������� ������
    SERR                    varchar2(4000);                -- ����� ��� ������
  begin
    /* ������� ������ */
    begin
      select T.* into RES from UDO_T_WEB_API_ACTIONS T where T.ACTION = SACTION;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(NSMART,
                    '��� �������� "%s" � ������� ��� ������������������ ������������!',
                    SACTION);
      when others then
        SERR := sqlerrm;
        P_EXCEPTION(NSMART, SERR);
    end;
    
    /* ������ ��������� */
    return RES;
  end;

  /* ������ ����������� �������� */
  procedure WEB_API_ACTIONS_PROCESS
  (
    NRN                     number,                        -- ��������������� ����� �����������
    CPRMS                   clob,                          -- ������� ���������
    CRES                    out clob                       -- ��������� ������
  ) is
    ACTPROC                 UDO_T_WEB_API_ACTIONS%rowtype; -- ������ ����������� ��������
    SSQL                    varchar2(4000);                -- ����������� ������
    NCUR                    integer;                       -- ������ ��� �������
    NRES                    integer;                       -- ��������� ���������� �������
    SERR                    varchar2(4000);                -- ����� ��� ������
  begin
    /* ������� ���������� */
    ACTPROC := WEB_API_ACTIONS_GET(NRN => NRN);
    
    /* �������� ������ */
    SSQL := 'begin ' || ACTPROC.PROCESSOR;
    SSQL := SSQL || '(CPRMS => :CPRMS, CRES => :CRES); end;';
    
    /* ��������� ��� */
    NCUR := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(C => NCUR, statement => SSQL, LANGUAGE_FLAG => DBMS_SQL.NATIVE);
    
    /* ��������� ��� ����������� */
    DBMS_SQL.BIND_VARIABLE(C => NCUR, name => 'CPRMS', value => CPRMS);
    DBMS_SQL.BIND_VARIABLE(C => NCUR, name => 'CRES', value => CRES);
    
    /* ��������� ������ */
    NRES := DBMS_SQL.EXECUTE(C => NCUR);
    
    /* �������������� ��������� */
    if (NRES = NEXEC_OK) then
      DBMS_SQL.VARIABLE_VALUE(C => NCUR, name => 'CRES', value => CRES);
    else
      P_EXCEPTION(0,
                  '������ ���������� ����������� "%s" ��� �������� "%s"!',
                  ACTPROC.PROCESSOR,
                  ACTPROC.ACTION);
    end if;
    
    /* ��������� ������ */
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
                        SRESP_MSG    => '������ ������� ����������� ��� �������� "' || ACTPROC.ACTION || '":' || SERR);
  end;
  
  /* ��������� ������� WEB-������� (JSON) */
  procedure PROCESS
  (
    CPRMS                   clob                               -- ��������� �������
  ) is
    SCANNER_EXCEPTION       exception;                         -- ������ JSON-�������
    pragma exception_init(SCANNER_EXCEPTION, -20100);          -- ������������� ������ JSON-�������
    PARSER_EXCEPTION        exception;                         -- ������ JSON-�������
    pragma exception_init(PARSER_EXCEPTION, -20101);           -- ������������� ������ JSON-�������
    JEXT_EXCEPTION          exception;                         -- ������ JSON-����������
    pragma exception_init(JEXT_EXCEPTION, -20110);             -- ������������� ������ JSON-����������
    JPRMS                   JSON;                              -- ��������� ������������� ���������� �������
    CRES                    clob;                              -- ��������� ������������� ������
    SERR                    varchar2(4000);                    -- ����� ��� ������
    SACTION                 UDO_T_WEB_API_ACTIONS.ACTION%type; -- ��� �������� �������
    ACTPROC                 UDO_T_WEB_API_ACTIONS%rowtype;     -- ������ ����������� ��������
    BDOWNLOAD               boolean := false;                  -- ������� ����������� �������� ������
    BDOWNLOAD_BUFFER        blob;                              -- ����� ��� ������������ �����
    SDOWNLOAD_FILE_NAME     varchar2(4000);                    -- ��� ������������ �����    
  begin
    /* ������������� ������ */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
  
    /* ������ ���������� ������� */
    begin
      /* ������������ ��������� � ��������� ������������� */
      begin
        JPRMS := JSON(CPRMS);
      exception
        when NO_DATA_FOUND then
          JPRMS := JSON();
      end;
      
      /* ������� ��� �������� */
      if ((not JPRMS.EXIST(SREQ_ACTION_KEY)) or (JPRMS.GET(SREQ_ACTION_KEY).VALUE_OF() is null)) then
        P_EXCEPTION(0, '� ������� � ������� �� ������ ��� ��������!');
      else
        SACTION := JPRMS.GET(SREQ_ACTION_KEY).VALUE_OF();
      end if;
    
      /* ������� ���������� ��� �������� */
      ACTPROC := WEB_API_ACTIONS_GET(SACTION => SACTION, NSMART => 0);
    
      /* �������� ����������� ���������� ������� �������� ������������� (���� �� ���������� ���� ���������� ��� �����������) */
      if (ACTPROC.UNAUTH = NUNAUTH_NO) then
        if ((not JPRMS.EXIST(SREQ_SESSION_KEY)) or (JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF() is null)) then
          P_EXCEPTION(0, '� ������� � ������� �� ������� ������!');
        else
          /* ���������� ������ */
          SESSION_VALIDATE(SSESSION => JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF());
        end if;
      end if;
    
      /* �������� ��������: ������������ ��������������� ���, ��� ������ - �������� ���������� */
      case SACTION
        /* ������������ - �������������� (�������������� ��������������� �����, � ����) */
        when SACTION_LOGIN then
          declare
            SUSR      USERLIST.AUTHID%type; -- ��� ������������ � �������
            SUSR_NAME USERLIST.NAME%type;   -- ������ ��� ������������
            SPASS     PKG_STD.TSTRING;      -- ������
            SCOMPANY  COMPANIES.NAME%type;  -- �����������
            SSESSION  PKG_STD.TSTRING;      -- ������������� ������
            JRESP     JSON;                 -- ��������� ������������� ������
          begin
            /* ������� ��� ������������ */
            if ((not JPRMS.EXIST(SREQ_USER_KEY)) or (JPRMS.GET(SREQ_USER_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0, '� ������� � ������� �� ������� ��� ������������!');
            else
              SUSR := JPRMS.GET(SREQ_USER_KEY).VALUE_OF();
            end if;
            /* ��������� ������ */
            if ((not JPRMS.EXIST(SREQ_PASSWORD_KEY)) or (JPRMS.GET(SREQ_PASSWORD_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0, '� ������� � ������� �� ������ ������!');
            else
              SPASS := JPRMS.GET(SREQ_PASSWORD_KEY).VALUE_OF();
            end if;
            /* ��������� ����������� */
            if ((not JPRMS.EXIST(SREQ_COMPANY_KEY)) or (JPRMS.GET(SREQ_COMPANY_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0, '� ������� � ������� �� ������� �����������!');
            else
              SCOMPANY := JPRMS.GET(SREQ_COMPANY_KEY).VALUE_OF();
            end if;
            /* ��������� ������������� ������ */
            SSESSION := RAWTOHEX(SYS_GUID());
            /* �������� �������������� */
            PKG_SESSION.LOGON_WEB(SCONNECT        => SSESSION,
                                  SUTILIZER       => SUSR,
                                  SPASSWORD       => SPASS,
                                  SIMPLEMENTATION => 'Other',
                                  SAPPLICATION    => 'Other',
                                  SCOMPANY        => SCOMPANY);
            PKG_SESSION.TIMEOUT_WEB(SCONNECT => SSESSION, NTIMEOUT => 2880);
            /* ������ ��� ������������ */
            FIND_USERLIST_BY_AUTHID(NFLAG_SMART => 0, SAUTHID => UPPER(SUSR), SNAME => SUSR_NAME);
            /* �������� ����� */
            JRESP := JSON();
            JRESP.PUT(PAIR_NAME => 'SSESSION', PAIR_VALUE => SSESSION);
            JRESP.PUT(PAIR_NAME => 'SUSER_NAME', PAIR_VALUE => SUSR_NAME);
            JRESP.TO_CLOB(BUF => CRES);          
          end;
        /* ������������ - ���������� ������ (�������������� ��������������� �����, � ����) */
        when SACTION_LOGOUT then
          begin
            /* �������� ������ */
            PKG_SESSION.LOGOFF_WEB(SCONNECT => JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF());
            /* ������ ��� �� ������ ������ */
            CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                              NRESP_STATE  => NRESP_STATE_OK,
                              SRESP_MSG    => JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF());
          end;
        /* ������������ - ��������� ������ (�������������� ��������������� �����, � ����) */
        when SACTION_VERIFY then
          begin
            /* ���� ��� ���� �������� �� ��������� ������ - �� ������ ����� ��� �� ������ ������ */
            CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                              NRESP_STATE  => NRESP_STATE_OK,
                              SRESP_MSG    => JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF());
          end;        
        /* ������������ - �������� ����� (�������������� ��������������� �����, � ����) */
        when SACTION_DOWNLOAD then
          declare
            SFILE_TYPE PKG_STD.TSTRING;     -- ��� ������������ �����
            NFILE_RN   PKG_STD.TREF;        -- ���. ����� ������������ �����   
            RPTQ       RPTPRTQUEUE%rowtype; -- ����������� ������� �������
          begin
            /* ������� ��� ����� */
            if ((not JPRMS.EXIST(SREQ_FILE_TYPE_KEY)) or (JPRMS.GET(SREQ_FILE_TYPE_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0,
                          '� ������� � ������� �� ������ ��� ������������ �����!');
            else
              SFILE_TYPE := JPRMS.GET(SREQ_FILE_TYPE_KEY).VALUE_OF();
            end if;
            /* ������� ������������� ����� */
            if ((not JPRMS.EXIST(SREQ_FILE_RN_KEY)) or (JPRMS.GET(SREQ_FILE_RN_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0,
                          '� ������� � ������� �� ������ ��������������� ����� ������������ �����!');
            else
              NFILE_RN := UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET(SREQ_FILE_RN_KEY).VALUE_OF(), NSMART => 0);
            end if;
            /* �������������� ������ �������� */
            DBMS_LOB.CREATETEMPORARY(LOB_LOC => BDOWNLOAD_BUFFER, CACHE => false);          
            /* �������� �� ���� ����� */
            case (SFILE_TYPE)
              /* ���� �������� ������ */
              when (SFILE_TYPE_REPORT) then
                begin
                  /* ������� ������� ������� ������ */
                  RPTQ := UTL_RPTQ_GET(NREPORTQ => NFILE_RN, NSMART => 0);
                  /* ������� � ��������� */
                  if (RPTQ.STATUS <> NRPTQ_STATUS_OK) then
                    P_EXCEPTION(0,
                                '����� �� ����� ���� �������� - �� ��� �� �������� ��� �������� � ��������!');
                  end if;
                  /* ������� ������ �� ������� ������ */
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
                                  '������ ���������� ������ ������� ������� ������ (RN: %s)!',
                                  TO_CHAR(NFILE_RN));
                  end;
                  /* �������������� �������� */
                  if (SDOWNLOAD_FILE_NAME is null) then
                    P_EXCEPTION(0,
                                '�� ������� ���������� ��� ������������ �����!');
                  end if;
                  if (NVL(DBMS_LOB.GETLENGTH(BDOWNLOAD_BUFFER), 0) = 0) then
                    P_EXCEPTION(0, '����������� ���� ����!');
                  end if;
                end;
              /* ����������� ��� ����� */
              else
                P_EXCEPTION(0,
                            '��� ����� ���� "%s" �������� �� ��������������!',
                            SFILE_TYPE);
            end case;
            /* ������ ������� ������������, ��� �������� �������� - ����� ��������� */
            BDOWNLOAD := true;
          end;
        /* ������������ - ���������� URL ��� �������� ����� (�������������� ��������������� �����, � ����) */
        when SACTION_DOWNLOAD_GET_URL then
          declare
            SFILE_TYPE PKG_STD.TSTRING;     -- ��� ������������ �����
            NFILE_RN   PKG_STD.TREF;        -- ���. ����� ������������ �����   
          begin
            /* ������� ��� ����� */
            if ((not JPRMS.EXIST(SREQ_FILE_TYPE_KEY)) or (JPRMS.GET(SREQ_FILE_TYPE_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0,
                          '� ������� � ������� �� ������ ��� ������������ �����!');
            else
              SFILE_TYPE := JPRMS.GET(SREQ_FILE_TYPE_KEY).VALUE_OF();
            end if;
            /* ������� ������������� ����� */
            if ((not JPRMS.EXIST(SREQ_FILE_RN_KEY)) or (JPRMS.GET(SREQ_FILE_RN_KEY).VALUE_OF() is null)) then
              P_EXCEPTION(0,
                          '� ������� � ������� �� ������ ��������������� ����� ������������ �����!');
            else
              NFILE_RN := UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET(SREQ_FILE_RN_KEY).VALUE_OF(), NSMART => 0);
            end if;
            /* ������ ��� �� ������ ������ */
            CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                              NRESP_STATE  => NRESP_STATE_OK,
                              SRESP_MSG    => UTL_BUILD_DOWNLOAD_URL(SSESSION   => JPRMS.GET(SREQ_SESSION_KEY).VALUE_OF(),
                                                                     SFILE_TYPE => SFILE_TYPE,
                                                                     NFILE_RN   => NFILE_RN));
          end;
        /* ������ �������� - �������������� �������� ��������������� ������������ */
        else
          begin
            /* �������� ���������� �������� */
            WEB_API_ACTIONS_PROCESS(NRN => ACTPROC.RN, CPRMS => CPRMS, CRES => CRES);
          end;
      end case;
      
    /* ��������� ������ ������� JSON � �������� ������������ ���������� */
    exception
      when SCANNER_EXCEPTION then
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                          NRESP_STATE  => NRESP_STATE_ERR,
                          SRESP_MSG    => '������ �������� ������� - ��������� ��� ������ �������� �������� JSON-����������!');
        rollback;                          
      when PARSER_EXCEPTION then
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                          NRESP_STATE  => NRESP_STATE_ERR,
                          SRESP_MSG    => '������ ������� ������� - ��������� ��� ������ �������� �������� JSON-����������!');
        rollback;                          
      when JEXT_EXCEPTION then
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                          NRESP_STATE  => NRESP_STATE_ERR,
                          SRESP_MSG    => '������ ��������� ������� - ��������� ��� ������ �������� �������� JSON-����������!');
        rollback;                          
      when ESESSION_EXPIRED then
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON,
                          NRESP_STATE  => NRESP_STATE_ERR,
                          SRESP_MSG    => SSESSION_EXPIRED_MSG);
      when others then
        SERR := sqlerrm;
        CRES := RESP_MAKE(NRESP_FORMAT => NRESP_FORMAT_JSON, NRESP_STATE => NRESP_STATE_ERR, SRESP_MSG => SERR);
        rollback;
    end;

    /* ������ ��������� - ������� ���� � ���� HTTP ��� ���� */
    if (not BDOWNLOAD) then
      RESP_PUBLISH(CDATA => CRES);
    else
      RESP_DOWNLOAD(BDATA => BDOWNLOAD_BUFFER, SFILE_NAME => SDOWNLOAD_FILE_NAME);
    end if; 
  end;

end;
/
