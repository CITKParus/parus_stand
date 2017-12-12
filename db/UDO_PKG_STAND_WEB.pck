create or replace package UDO_PKG_STAND_WEB as
  /*
    WEB API ������
  */
  
  /* ����������� ������������ ����������� ������ � JSON */
  function STAND_RACK_NOMEN_CONFS_TO_JSON
  (
    NC                      UDO_PKG_STAND.TRACK_NOMEN_CONFS -- ������������ ������������ ������
  ) return JSON_LIST;
  
  /* ����������� �������� �� ������������ ������ � JSON */
  function STAND_RACK_NOMEN_RESTS_TO_JSON
  (
    NR                      UDO_PKG_STAND.TNOMEN_RESTS -- ������� ������������
  ) return JSON_LIST;
  
  /* ����������� �������� �� �������� ������ � JSON */
  function STAND_RACK_REST_TO_JSON
  (
    R                       UDO_PKG_STAND.TRACK_REST -- ������� ������
  ) return JSON;
  
  /* ����������� ������� ������������� ������ � JSON */
  function STAND_RACK_REST_PRCHS_TO_JSON
  (
    RH                      UDO_PKG_STAND.TRACK_REST_PRC_HISTS -- ������� ������������� ������
  ) return JSON_LIST;
  
  /* ����������� �������� � ���������� ������ � JSON */
  function STAND_USER_TO_JSON
  (
    U                       UDO_PKG_STAND.TSTAND_USER -- ������������ ������
  ) return JSON;
  
  /* ����������� ��������� ������ � JSON */
  function STAND_STATE_TO_JSON
  (
    SS                      UDO_PKG_STAND.TSTAND_STATE -- ��������� ������
  ) return JSON;
  
  /* ����������� ������ ��������� � JSON */
  function MESSAGES_TO_JSON
  (
    MSGS                    UDO_PKG_STAND.TMESSAGES -- ������ ���������
  ) return JSON_LIST;
  
  /* �������������� ���������� ������ �� ��������� */
  procedure AUTH_BY_BARCODE
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );

  /* �������� ������ ������� */
  procedure LOAD
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );
  
  /* ����� ��������� �������� ������ */
  procedure LOAD_ROLLBACK
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );
  
  /* ������ ���������� ������ �� ������ */
  procedure SHIPMENT
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );
  
  /* ����� ������ ���������� ������ �� ������ */
  procedure SHIPMENT_ROLLBACK
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );
  
  /* ���������� ������� � ������� ������ */
  procedure PRINT
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );
  
    /* �������� ��������� ������ � ������� ������ */
  procedure PRINT_GET_STATE
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );
  
  /* ��������� ��������� � ������� ����������� */
  procedure MSG_INSERT
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );
  
  /* �������� ��������� �� ������� ����������� */
  procedure MSG_DELETE
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );
  
  /* ��������� ��������� ��������� � ������� ����������� */
  procedure MSG_SET_STATE
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );

  /* ������ ������ ��������� */
  procedure MSG_GET_LIST
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );
  
  /* ��������� ��������� ������ */
  procedure STAND_GET_STATE
  (
    CPRMS                   clob,       -- ������� ���������
    CRES                    out clob    -- ��������� ������
  );

end;
/
create or replace package body UDO_PKG_STAND_WEB as

  /* ����������� ������������ ����������� ������ � JSON */
  function STAND_RACK_NOMEN_CONFS_TO_JSON
  (
    NC                      UDO_PKG_STAND.TRACK_NOMEN_CONFS -- ������������ ������������ ������
  ) return JSON_LIST is
    JSLCN                   JSON_LIST;                      -- JSON-��������� ����������� ������
    JSLCN_ITM               JSON;                           -- JSON-�������� ����������� ������
  begin
    /* �������������� ����� */
    JSLCN := JSON_LIST();
    /* ������� ������������, ���� ���� */
    if ((NC is not null) and (NC.COUNT > 0)) then
      for N in NC.FIRST .. NC.LAST
      loop
        /* �������� ������ ������� ������������ */
        JSLCN_ITM := JSON();
        JSLCN_ITM.PUT(PAIR_NAME => 'NNOMEN', PAIR_VALUE => NC(N).NNOMEN);
        JSLCN_ITM.PUT(PAIR_NAME => 'SNOMEN', PAIR_VALUE => NC(N).SNOMEN);
        JSLCN_ITM.PUT(PAIR_NAME => 'NNOMMODIF', PAIR_VALUE => NC(N).NNOMMODIF);
        JSLCN_ITM.PUT(PAIR_NAME => 'SNOMMODIF', PAIR_VALUE => NC(N).SNOMMODIF);
        JSLCN_ITM.PUT(PAIR_NAME => 'NMAX_QUANT', PAIR_VALUE => NC(N).NMAX_QUANT);        
        JSLCN_ITM.PUT(PAIR_NAME => 'NMEAS', PAIR_VALUE => NC(N).NMEAS);
        JSLCN_ITM.PUT(PAIR_NAME => 'SMEAS', PAIR_VALUE => NC(N).SMEAS);
        /* ������ ������������ - � ���������� ����������� */
        JSLCN.APPEND(ELEM => JSLCN_ITM.TO_JSON_VALUE());
      end loop;
    end if;
    /* ������ ����� */
    return JSLCN;
  end;  
  
  /* ����������� �������� �� ������������ ������ � JSON */
  function STAND_RACK_NOMEN_RESTS_TO_JSON
  (
    NR                      UDO_PKG_STAND.TNOMEN_RESTS -- ������� ������������
  ) return JSON_LIST is
    JSLCN                   JSON_LIST;                 -- JSON-��������� ����������� ������
    JSLCN_ITM               JSON;                      -- JSON-�������� ����������� ������
  begin
    /* �������������� ����� */
    JSLCN := JSON_LIST();
    /* ������� ������� ������������, ���� ���� */
    if ((NR is not null) and (NR.COUNT > 0)) then
      for N in NR.FIRST .. NR.LAST
      loop
        /* �������� ������ ������� ������������ */
        JSLCN_ITM := JSON();
        JSLCN_ITM.PUT(PAIR_NAME => 'NNOMEN', PAIR_VALUE => NR(N).NNOMEN);
        JSLCN_ITM.PUT(PAIR_NAME => 'SNOMEN', PAIR_VALUE => NR(N).SNOMEN);
        JSLCN_ITM.PUT(PAIR_NAME => 'NNOMMODIF', PAIR_VALUE => NR(N).NNOMMODIF);
        JSLCN_ITM.PUT(PAIR_NAME => 'SNOMMODIF', PAIR_VALUE => NR(N).SNOMMODIF);
        JSLCN_ITM.PUT(PAIR_NAME => 'NREST', PAIR_VALUE => NR(N).NREST);
        JSLCN_ITM.PUT(PAIR_NAME => 'NMEAS', PAIR_VALUE => NR(N).NMEAS);
        JSLCN_ITM.PUT(PAIR_NAME => 'SMEAS', PAIR_VALUE => NR(N).SMEAS);
        /* ������ ������������ - � ���������� ����������� */
        JSLCN.APPEND(ELEM => JSLCN_ITM.TO_JSON_VALUE());
      end loop;
    end if;
    /* ������ ����� */
    return JSLCN;
  end;
  
  /* ����������� �������� �� �������� ������ � JSON */
  function STAND_RACK_REST_TO_JSON
  (
    R                       UDO_PKG_STAND.TRACK_REST -- ������� ������
  ) return JSON is
    JS                      JSON;                    -- JSON-�������� ��������
    JSL                     JSON_LIST;               -- JSON-��������� ������ ��������
    JSL_ITM                 JSON;                    -- JSON-�������� ����� ��������
    JSLC                    JSON_LIST;               -- JSON-��������� ����� �����
    JSLC_ITM                JSON;                    -- JSON-�������� ������ �����
  begin
    /* �������������� ����� */
    JS := JSON();
    /* ������� ������ �������� */
    JS.PUT(PAIR_NAME => 'NRACK', PAIR_VALUE => R.NRACK);
    JS.PUT(PAIR_NAME => 'NSTORE', PAIR_VALUE => R.NSTORE);
    JS.PUT(PAIR_NAME => 'SSTORE', PAIR_VALUE => R.SSTORE);
    JS.PUT(PAIR_NAME => 'SRACK_PREF', PAIR_VALUE => R.SRACK_PREF);
    JS.PUT(PAIR_NAME => 'SRACK_NUMB', PAIR_VALUE => R.SRACK_NUMB);
    JS.PUT(PAIR_NAME => 'SRACK_NAME', PAIR_VALUE => R.SRACK_NAME);
    JS.PUT(PAIR_NAME => 'NRACK_LINES_CNT', PAIR_VALUE => R.NRACK_LINES_CNT);
    JS.PUT(PAIR_NAME => 'BEMPTY', PAIR_VALUE => R.BEMPTY);
    JSL := JSON_LIST();
    /* ������� ����� �������� */
    if (R.RACK_LINE_RESTS.COUNT > 0) then
      for L in R.RACK_LINE_RESTS.FIRST .. R.RACK_LINE_RESTS.LAST
      loop
        /* �������� ������ ����� */
        JSL_ITM := JSON();
        JSL_ITM.PUT(PAIR_NAME => 'NRACK_LINE', PAIR_VALUE => R.RACK_LINE_RESTS(L).NRACK_LINE);
        JSL_ITM.PUT(PAIR_NAME => 'NRACK_LINE_CELLS_CNT', PAIR_VALUE => R.RACK_LINE_RESTS(L).NRACK_LINE_CELLS_CNT);
        JSL_ITM.PUT(PAIR_NAME => 'BEMPTY', PAIR_VALUE => R.RACK_LINE_RESTS(L).BEMPTY);
        /* ������� ������ ����� */
        JSLC := JSON_LIST();
        if (R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS.COUNT > 0) then
          for C in R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS.FIRST .. R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS.LAST
          loop
            /* �������� ������ ������ */
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
            /* ��������� ����������� - � ������ */
            JSLC_ITM.PUT(PAIR_NAME  => 'NOMEN_RESTS',
                         PAIR_VALUE => STAND_RACK_NOMEN_RESTS_TO_JSON(NR => R.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS)
                                       .TO_JSON_VALUE());
            /* ������ - � ��������� ����� ����� */
            JSLC.APPEND(ELEM => JSLC_ITM.TO_JSON_VALUE());
          end loop;
        end if;
        /* ��������� ����� - � ���� */
        JSL_ITM.PUT(PAIR_NAME => 'RACK_LINE_CELL_RESTS', PAIR_VALUE => JSLC.TO_JSON_VALUE());
        /* ���� - � ��������� ������ �������� */
        JSL.APPEND(ELEM => JSL_ITM.TO_JSON_VALUE());
      end loop;
    end if;
    /* ��������� ������ - � ������� */
    JS.PUT(PAIR_NAME => 'RACK_LINE_RESTS', PAIR_VALUE => JSL);
    /* ������ �������� */
    return JS;
  end;
  
  /* ����������� ������� ������������� ������ � JSON */
  function STAND_RACK_REST_PRCHS_TO_JSON
  (
    RH                      UDO_PKG_STAND.TRACK_REST_PRC_HISTS -- ������� ������������� ������
  ) return JSON_LIST is
    JSLRH                   JSON_LIST;                         -- JSON-��������� ����������� ������
    JSLRH_ITM               JSON;                              -- JSON-�������� ����������� ������
  begin
    /* �������������� ����� */
    JSLRH := JSON_LIST();
    /* ������� �������, ���� ���� */
    if ((RH is not null) and (RH.COUNT > 0)) then
      for N in RH.FIRST .. RH.LAST
      loop
        /* �������� ������ ������� ������������ */
        JSLRH_ITM := JSON();
        JSLRH_ITM.PUT(PAIR_NAME => 'DTS', PAIR_VALUE => TO_CHAR(RH(N).DTS, 'yyyy-mm-dd"T"hh24:mi:ss'));
        JSLRH_ITM.PUT(PAIR_NAME => 'STS', PAIR_VALUE => RH(N).STS);
        JSLRH_ITM.PUT(PAIR_NAME => 'NREST_PRC', PAIR_VALUE => RH(N).NREST_PRC);
        /* ������ ������������ - � ���������� ����������� */
        JSLRH.APPEND(ELEM => JSLRH_ITM.TO_JSON_VALUE());
      end loop;
    end if;
    /* ������ ����� */
    return JSLRH;
  end;
  
  /* ����������� �������� � ���������� ������ � JSON */
  function STAND_USER_TO_JSON
  (
    U                       UDO_PKG_STAND.TSTAND_USER -- ������������ ������
  ) return JSON is
    JU                      JSON;                     -- JSON-�������� ������������ ������
  begin
    /* �������������� ����� */
    JU := JSON();
    /* ������� ������ */
    JU.PUT(PAIR_NAME => 'NAGENT', PAIR_VALUE => U.NAGENT);
    JU.PUT(PAIR_NAME => 'SAGENT', PAIR_VALUE => U.SAGENT);
    JU.PUT(PAIR_NAME => 'SAGENT_NAME', PAIR_VALUE => U.SAGENT_NAME);
    /* ������ �������� */
    return JU;
  end;
  
  /* ����������� ��������� ������ � JSON */
  function STAND_STATE_TO_JSON
  (
    SS                      UDO_PKG_STAND.TSTAND_STATE -- ��������� ������
  ) return JSON is
    JS                      JSON;                      -- JSON-�������� ��������� ������
  begin
    /* �������������� ����� */
    JS := JSON();
    /* ������� ������ */
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
    /* ������ �������� */
    return JS;
  end;
  
  /* ����������� ������ ��������� � JSON */
  function MESSAGES_TO_JSON
  (
    MSGS                    UDO_PKG_STAND.TMESSAGES -- ������ ���������
  ) return JSON_LIST is
    JL                      JSON_LIST;              -- JSON-�������� c����� ���������
    JLI                     JSON;                   -- JSON-�������� �������� ������
  begin
    /* �������������� ����� */
    JL := JSON_LIST();
    /* ���� ��������� ���� - ������� �� */
    if ((MSGS is not null) and (MSGS.COUNT > 0)) then
      for I in MSGS.FIRST .. MSGS.LAST
      loop
        /* �������������� ������� ��������� */
        JLI := JSON();
        /* ������� ������ ��������� */
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
        /* �������� ��������� � ����� */
        JL.APPEND(ELEM => JLI.TO_JSON_VALUE());
      end loop;
    end if;
    /* ������ ��������� */
    return JL;
  end;
  
  /* �������������� ���������� ������ �� ��������� */
  procedure AUTH_BY_BARCODE
  (
    CPRMS                   clob,                                       -- ������� ���������
    CRES                    out clob                                    -- ��������� ������
  ) is
    JRES                    JSON;                                       -- ������ ������
    JPRMS                   JSON;                                       -- ��������� ������������� ���������� �������
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- ���. ����� �����������
    SBARCODE                PKG_STD.TSTRING;                            -- ��������
    U                       UDO_PKG_STAND.TSTAND_USER;                  -- ������������ ������
    R                       UDO_PKG_STAND.TRACK_REST;                   -- ������� ������    
    SERR                    PKG_STD.TSTRING;                            -- ����� ��� ������
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    JRES := JSON();
    /* ������������ ��������� � ��������� ������������� */
    JPRMS := JSON(CPRMS);
    /* ��������� �������� */
    if ((not JPRMS.EXIST('SBARCODE')) or (JPRMS.GET('SBARCODE').VALUE_OF() is null)) then
      P_EXCEPTION(0, '� ������� � ������� �� ������ ��������!');
    else
      SBARCODE := JPRMS.GET('SBARCODE').VALUE_OF();
    end if;
    /* ������ ������������ � �������������� ���������� */
    UDO_PKG_STAND.STAND_AUTH_BY_BARCODE(NCOMPANY => NCOMPANY, SBARCODE => SBARCODE, STAND_USER => U, RACK_REST => R);
    /* ������� ����� */
    JRES.PUT(PAIR_NAME => 'USER', PAIR_VALUE => STAND_USER_TO_JSON(U => U).TO_JSON_VALUE());
    JRES.PUT(PAIR_NAME => 'RESTS', PAIR_VALUE => STAND_RACK_REST_TO_JSON(R => R).TO_JSON_VALUE());
    /* ����� ����� */
    JRES.TO_CLOB(BUF => CRES);
  exception
    when others then
      SERR := sqlerrm;
      CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                        NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_ERR,
                                        SRESP_MSG    => SERR);
      rollback;
  end;
  
  /* �������� ������ ������� */
  procedure LOAD
  (
    CPRMS                   clob,                                       -- ������� ���������
    CRES                    out clob                                    -- ��������� ������
  ) is
    JPRMS                   JSON;                                       -- ��������� ������������� ���������� �������
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- ���. ����� �����������    
    NRACK_LINE              PKG_STD.TNUMBER;                            -- ���� �������� ��� �������� ������
    NRACK_LINE_CELL         PKG_STD.TNUMBER;                            -- ������ �������� ��� �������� ������
    NINCOMEFROMDEPS         PKG_STD.TREF;                               -- ���. ����� �������������� ��������� �� ������� �� �������������
    SERR                    PKG_STD.TSTRING;                            -- ����� ��� ������
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* ������������ ��������� � ��������� ������������� */
    JPRMS := JSON(CPRMS);
    /* ��������� ���� �������� ��� �������� ������ */
    if ((not JPRMS.EXIST('NRACK_LINE')) or (JPRMS.GET('NRACK_LINE').VALUE_OF() is null)) then
      NRACK_LINE := null;
    else
      NRACK_LINE := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NRACK_LINE').VALUE_OF(), NSMART => 0);
    end if;
    /* ��������� ������ �������� ��� �������� ������ */
    if ((not JPRMS.EXIST('NRACK_LINE_CELL')) or (JPRMS.GET('NRACK_LINE_CELL').VALUE_OF() is null)) then
      NRACK_LINE_CELL := null;
    else
      NRACK_LINE_CELL := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR   => JPRMS.GET('NRACK_LINE_CELL').VALUE_OF(),
                                                               NSMART => 0);
    end if;
    /* ��������� ����� (������������ �� ����� ��������) */
    UDO_PKG_STAND.LOAD(NCOMPANY        => NCOMPANY,
                       NRACK_LINE      => NRACK_LINE,
                       NRACK_LINE_CELL => NRACK_LINE_CELL,
                       NINCOMEFROMDEPS => NINCOMEFROMDEPS);
    /* ����� ����� ��� �� ������ ������� */
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
  
  /* ����� ��������� �������� ������ */
  procedure LOAD_ROLLBACK
  (
    CPRMS                   clob,                                       -- ������� ���������
    CRES                    out clob                                    -- ��������� ������
  ) is
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- ���. ����� �����������
    NINCOMEFROMDEPS         PKG_STD.TREF;                               -- ���. ����� ����������������� "������� �� �������������"        
    SERR                    PKG_STD.TSTRING;                            -- ����� ��� ������
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* ���������� ��������� ������ */
    UDO_PKG_STAND.LOAD_ROLLBACK(NCOMPANY => NCOMPANY, NINCOMEFROMDEPS => NINCOMEFROMDEPS);
    /* ����� ����� ��� �� ������ ������� */
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
  
  /* ������ ���������� ������ �� ������ */
  procedure SHIPMENT
  (
    CPRMS                   clob,                                       -- ������� ���������
    CRES                    out clob                                    -- ��������� ������
  ) is
    JPRMS                   JSON;                                       -- ��������� ������������� ���������� �������
    JRES                    JSON;                                       -- ��������� ������������� ������
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- ���. ����� �����������
    SCUSTOMER               PKG_STD.TSTRING;                            -- �������� �����������-����������
    NRACK_LINE              PKG_STD.TNUMBER;                            -- ���� �������� ��� ������ ������
    NRACK_LINE_CELL         PKG_STD.TNUMBER;                            -- ������ �������� ��� ������ ������
    NTRANSINVCUST           PKG_STD.TREF;                               -- ���. ����� �������������� ����
    RESTS_HIST_TMP          UDO_PKG_STAND.TMESSAGES;                    -- ����� ��� ������� ��������
    SERR                    PKG_STD.TSTRING;                            -- ����� ��� ������
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* �������������� ����� */
    JRES := JSON();
    /* ������������ ��������� � ��������� ������������� */
    JPRMS := JSON(CPRMS);
    /* ��������� �����������-���������� */
    if ((not JPRMS.EXIST('SCUSTOMER')) or (JPRMS.GET('SCUSTOMER').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  '� ������� � ������� �� ������ �������� ���������� ������!');
    else
      SCUSTOMER := JPRMS.GET('SCUSTOMER').VALUE_OF();
    end if;
    /* ��������� ���� �������� ��� ������ ������ */
    if ((not JPRMS.EXIST('NRACK_LINE')) or (JPRMS.GET('NRACK_LINE').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  '� ������� � ������� �� ������ ���� �������� ��� ������ ������!');
    else
      NRACK_LINE := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NRACK_LINE').VALUE_OF(), NSMART => 0);
    end if;
    /* ��������� ������ �������� ��� ������ ������ */
    if ((not JPRMS.EXIST('NRACK_LINE_CELL')) or (JPRMS.GET('NRACK_LINE_CELL').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  '� ������� � ������� �� ������� ������ �������� ��� ������ ������!');
    else
      NRACK_LINE_CELL := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR   => JPRMS.GET('NRACK_LINE_CELL').VALUE_OF(),
                                                               NSMART => 0);
    end if;
    /* ����� ����� ���������� (�������� � ����� ��������) */
    UDO_PKG_STAND.SHIPMENT(NCOMPANY        => NCOMPANY,
                           SCUSTOMER       => SCUSTOMER,
                           NRACK_LINE      => NRACK_LINE,
                           NRACK_LINE_CELL => NRACK_LINE_CELL,
                           NTRANSINVCUST   => NTRANSINVCUST);
    /* ��������� ������� �� ������ ����� �������� */
    RESTS_HIST_TMP := UDO_PKG_STAND.MSG_GET_LIST(DFROM  => null,
                                                 STP    => UDO_PKG_STAND.SMSG_TYPE_REST_PRC,
                                                 NLIMIT => 1,
                                                 NORDER => UDO_PKG_STAND.NMSG_ORDER_DESC);
    /* ��������� ����� */
    JRES.PUT(PAIR_NAME => 'NTRANSINVCUST', PAIR_VALUE => NTRANSINVCUST);
    if ((RESTS_HIST_TMP is not null) and (RESTS_HIST_TMP.COUNT = 1)) then
      JRES.PUT(PAIR_NAME => 'NRESTS_PRC_CURR', PAIR_VALUE => TO_NUMBER(RESTS_HIST_TMP(RESTS_HIST_TMP.FIRST).SMSG));
    else
      JRES.PUT(PAIR_NAME => 'NRESTS_PRC_CURR', PAIR_VALUE => 0);
    end if;
    /* ����� �����  */
    JRES.TO_CLOB(BUF => CRES);    
  exception
    when others then
      SERR := sqlerrm;
      CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                        NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_ERR,
                                        SRESP_MSG    => SERR);
      rollback;
  end;
  
  /* ����� ������ ���������� ������ �� ������ */
  procedure SHIPMENT_ROLLBACK
  (
    CPRMS                   clob,                                       -- ������� ���������
    CRES                    out clob                                    -- ��������� ������
  ) is
    JPRMS                   JSON;                                       -- ��������� ������������� ���������� �������
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- ���. ����� �����������
    NTRANSINVCUST           PKG_STD.TREF;                               -- ���. ����� ������������ ����
    SERR                    PKG_STD.TSTRING;                            -- ����� ��� ������
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* ������������ ��������� � ��������� ������������� */
    JPRMS := JSON(CPRMS);
    /* ��������� ��������������� ����� ������������ ��������� ��������� �� ������ ����������� */
    if ((not JPRMS.EXIST('NTRANSINVCUST')) or (JPRMS.GET('NTRANSINVCUST').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  '� ������� � ������� �� ������ ��������������� ����� ������������ ��������� ��������� �� ������ �����������!');
    else
      NTRANSINVCUST := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NTRANSINVCUST').VALUE_OF(), NSMART => 0);
    end if;
    /* ����� ����� ���������� (�������� � ����� ��������) */
    UDO_PKG_STAND.SHIPMENT_ROLLBACK(NCOMPANY => NCOMPANY, NTRANSINVCUST => NTRANSINVCUST);
    /* ����� ����� ��� �� ������ ������� */
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
  
  /* ���������� ������� � ������� ������ */
  procedure PRINT
  (
    CPRMS                   clob,                                       -- ������� ���������
    CRES                    out clob                                    -- ��������� ������
  ) is
    JPRMS                   JSON;                                       -- ��������� ������������� ���������� �������
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- ���. ����� �����������
    NTRANSINVCUST           PKG_STD.TREF;                               -- ���. ����� ������������ ����
    SERR                    PKG_STD.TSTRING;                            -- ����� ��� ������
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* ������������ ��������� � ��������� ������������� */
    JPRMS := JSON(CPRMS);
    /* ��������� ��������������� ����� ������������ ��������� ��������� �� ������ ����������� */
    if ((not JPRMS.EXIST('NTRANSINVCUST')) or (JPRMS.GET('NTRANSINVCUST').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  '� ������� � ������� �� ������ ��������������� ����� ��������������� ��������� ��������� �� ������ �����������!');
    else
      NTRANSINVCUST := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NTRANSINVCUST').VALUE_OF(), NSMART => 0);
    end if;
    /* ������ � ������� ������ �������� */
    UDO_PKG_STAND.PRINT(NCOMPANY => NCOMPANY, NTRANSINVCUST => NTRANSINVCUST);
    /* ����� ����� ��� �� ������ ������� */
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
  
  /* �������� ��������� ������ � ������� ������ */
  procedure PRINT_GET_STATE
  (
    CPRMS                   clob,                           -- ������� ���������
    CRES                    out clob                        -- ��������� ������
  ) is
    JPRMS                   JSON;                           -- ��������� ������������� ���������� �������  
    JRES                    JSON;                           -- ��������� ������������� ������    
    NRPTPRTQUEUE            RPTPRTQUEUE.RN%type;            -- ������������� ������� ������� ������
    RPT_QUEUE_STATE         UDO_PKG_STAND.TRPT_QUEUE_STATE; -- ��������� ������ � ������� ������
    SERR                    PKG_STD.TSTRING;                -- ����� ��� ������    
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* ������������ ��������� � ��������� ������������� */
    JPRMS := JSON(CPRMS);
    /* �������� ������� ������ � ���������� */
    if ((not JPRMS.EXIST(UDO_PKG_WEB_API.SREQ_SESSION_KEY)) or
       (JPRMS.GET(UDO_PKG_WEB_API.SREQ_SESSION_KEY).VALUE_OF() is null)) then
      P_EXCEPTION(0, '� ������� � ������� �� ������� ������!');
    end if;
    /* ��������� ������������� ������� ������� ������ */
    if ((not JPRMS.EXIST('NRPTPRTQUEUE')) or (JPRMS.GET('NRPTPRTQUEUE').VALUE_OF() is null)) then
      P_EXCEPTION(0,
                  '� ������� � ������� �� ������ ������������� ������� ������� ������!');
    else
      NRPTPRTQUEUE := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NRPTPRTQUEUE').VALUE_OF(), NSMART => 0);
    end if;
    /* �������� ��������� ������ � ������� */
    UDO_PKG_STAND.PRINT_GET_STATE(SSESSION        => JPRMS.GET(UDO_PKG_WEB_API.SREQ_SESSION_KEY).VALUE_OF(),
                                  NRPTPRTQUEUE    => NRPTPRTQUEUE,
                                  RPT_QUEUE_STATE => RPT_QUEUE_STATE);
    /* �������������� ����� */
    JRES := JSON();
    /* ������� ����� ��� ������ */
    JRES.PUT(PAIR_NAME => 'NRN', PAIR_VALUE => RPT_QUEUE_STATE.NRN);
    JRES.PUT(PAIR_NAME => 'SSTATE', PAIR_VALUE => RPT_QUEUE_STATE.SSTATE);
    JRES.PUT(PAIR_NAME => 'SERR', PAIR_VALUE => RPT_QUEUE_STATE.SERR);
    JRES.PUT(PAIR_NAME => 'SFILE_NAME', PAIR_VALUE => RPT_QUEUE_STATE.SFILE_NAME);
    JRES.PUT(PAIR_NAME => 'SURL', PAIR_VALUE => RPT_QUEUE_STATE.SURL);
    /* ����� ����� */
    JRES.TO_CLOB(BUF => CRES);
  exception
    when others then
      SERR := sqlerrm;
      CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                        NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_ERR,
                                        SRESP_MSG    => SERR);
      rollback;
  end;
  
  /* ��������� ��������� � ������� ����������� */
  procedure MSG_INSERT
  (
    CPRMS                   clob,            -- ������� ���������
    CRES                    out clob         -- ��������� ������
  ) is
    JPRMS                   JSON;            -- ��������� ������������� ���������� �������
    STP                     PKG_STD.TSTRING; -- ��� ���������
    SMSG                    PKG_STD.TSTRING; -- ����� ���������
    SNOTIFY_TYPE            PKG_STD.TSTRING; -- ��� ����������� (��� ��������� ���� "����������")
    SERR                    PKG_STD.TSTRING; -- ����� ��� ������
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* ������������ ��������� � ��������� ������������� */
    JPRMS := JSON(CPRMS);
    /* ��������� ��� ��������� */
    if ((not JPRMS.EXIST('STP')) or (JPRMS.GET('STP').VALUE_OF() is null)) then
      P_EXCEPTION(0, '� ������� � ������� �� ������ ��� ���������!');
    else
      STP := JPRMS.GET('STP').VALUE_OF();
    end if;
    /* ��������� ����� ��������� */
    if ((not JPRMS.EXIST('SMSG')) or (JPRMS.GET('SMSG').VALUE_OF() is null)) then
      P_EXCEPTION(0, '� ������� � ������� �� ������ ����� ���������!');
    else
      SMSG := JPRMS.GET('SMSG').VALUE_OF();
    end if;
    /* ��������� ��� ����������� */
    if ((not JPRMS.EXIST('SNOTIFY_TYPE')) or (JPRMS.GET('SNOTIFY_TYPE').VALUE_OF() is null)) then
      SNOTIFY_TYPE := UDO_PKG_STAND.SNOTIFY_TYPE_INFO;
    else
      SNOTIFY_TYPE := JPRMS.GET('SNOTIFY_TYPE').VALUE_OF();
    end if;
    /* ��������� ��������� */
    UDO_PKG_STAND.MSG_INSERT(STP => STP, SMSG => SMSG, SNOTIFY_TYPE => SNOTIFY_TYPE);
    /* ����� ����� ��� �� ������ ������� */
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

  /* �������� ��������� �� ������� ����������� */
  procedure MSG_DELETE
  (
    CPRMS                   clob,            -- ������� ���������
    CRES                    out clob         -- ��������� ������
  ) is
    JPRMS                   JSON;            -- ��������� ������������� ���������� �������
    NRN                     PKG_STD.TREF;    -- ��� ���������
    SERR                    PKG_STD.TSTRING; -- ����� ��� ������
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* ������������ ��������� � ��������� ������������� */
    JPRMS := JSON(CPRMS);
    /* ��������� ������������� ��������� */
    if ((not JPRMS.EXIST('NRN')) or (JPRMS.GET('NRN').VALUE_OF() is null)) then
      P_EXCEPTION(0, '� ������� � ������� �� ������ ������������� ���������!');
    else
      NRN := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NRN').VALUE_OF(), NSMART => 0);
    end if;
    /* ������� ��������� */
    UDO_PKG_STAND.MSG_DELETE(NRN => NRN);
    /* ����� ����� ��� �� ������ ������� */
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
 
  /* ��������� ��������� ��������� � ������� ����������� */
  procedure MSG_SET_STATE
  (
    CPRMS                   clob,            -- ������� ���������
    CRES                    out clob         -- ��������� ������
  ) is
    JPRMS                   JSON;            -- ��������� ������������� ���������� �������
    NRN                     PKG_STD.TREF;    -- ���. ����� ���������
    SSTS                    PKG_STD.TSTRING; -- ��������� ���������
    SERR                    PKG_STD.TSTRING; -- ����� ��� ������
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* ������������ ��������� � ��������� ������������� */
    JPRMS := JSON(CPRMS);
    /* ��������� ������������� ��������� */
    if ((not JPRMS.EXIST('NRN')) or (JPRMS.GET('NRN').VALUE_OF() is null)) then
      P_EXCEPTION(0, '� ������� � ������� �� ������ ������������� ���������!');
    else
      NRN := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NRN').VALUE_OF(), NSMART => 0);
    end if;
    /* ��������� ��������������� ��������� ��������� */
    if ((not JPRMS.EXIST('SSTS')) or (JPRMS.GET('SSTS').VALUE_OF() is null)) then
      P_EXCEPTION(0, '� ������� � ������� �� ������� ��������������� ��������� ���������!');
    else
      SSTS := JPRMS.GET('SSTS').VALUE_OF();
    end if;
    /* ������������� ��������� ��������� */
    UDO_PKG_STAND.MSG_SET_STATE(NRN => NRN, SSTS => SSTS);
    /* ����� ����� ��� �� ������ ������� */
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


  /* ������ ������ ��������� */
  procedure MSG_GET_LIST
  (
    CPRMS                   clob,                    -- ������� ���������
    CRES                    out clob                 -- ��������� ������
  ) is
    JRES                    JSON_LIST;               -- ��������� ������������� ������ - ������ ���������
    JPRMS                   JSON;                    -- ��������� ������������� ���������� �������
    DFROM                   PKG_STD.TLDATE;          -- "���� �" ��� ������ ���������
    STP                     PKG_STD.TSTRING;         -- ��� ��������� ��� ������
    SSTS                    PKG_STD.TSTRING;         -- ��������� ��������� ��� ������
    NLIMIT                  PKG_STD.TNUMBER;         -- ������������ ���������� ���������� ���������
    NORDER                  PKG_STD.TNUMBER;         -- ������� ���������� ���������
    MSGS                    UDO_PKG_STAND.TMESSAGES; -- ��������� ���������
    SERR                    PKG_STD.TSTRING;         -- ����� ��� ������
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* ������������ ��������� � ��������� ������������� */
    JPRMS := JSON(CPRMS);
    /* ��������� "���� �" ��� ������ ��������� */
    if ((not JPRMS.EXIST('DFROM')) or (JPRMS.GET('DFROM').VALUE_OF() is null)) then
      DFROM := null;
    else
      DFROM := UDO_PKG_WEB_API.UTL_CONVERT_TO_DATE(SDATE     => JPRMS.GET('DFROM').VALUE_OF(),
                                                   NSMART    => 0,
                                                   STEMPLATE => 'dd.mm.yyyy hh24:mi:ss');
    end if;
    /* ��������� ��� ��� ������ ��������� */
    if ((not JPRMS.EXIST('STP')) or (JPRMS.GET('STP').VALUE_OF() is null)) then
      STP := null;
    else
      STP := JPRMS.GET('STP').VALUE_OF();
    end if;
    /* ��������� ��������� ��� ������ ��������� */
    if ((not JPRMS.EXIST('SSTS')) or (JPRMS.GET('SSTS').VALUE_OF() is null)) then
      SSTS := null;
    else
      SSTS := JPRMS.GET('SSTS').VALUE_OF();
    end if;    
    /* ��������� ����������� �� ���������� ���������� ��������� */
    if ((not JPRMS.EXIST('NLIMIT')) or (JPRMS.GET('NLIMIT').VALUE_OF() is null)) then
      NLIMIT := null;
    else
      NLIMIT := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NLIMIT').VALUE_OF(), NSMART => 0);
    end if;
    /* ��������� ������� ���������� ���������� ��������� */
    if ((not JPRMS.EXIST('NORDER')) or (JPRMS.GET('NORDER').VALUE_OF() is null)) then
      NORDER := UDO_PKG_STAND.NMSG_ORDER_ASC;
    else
      NORDER := UDO_PKG_WEB_API.UTL_CONVERT_TO_NUMBER(SSTR => JPRMS.GET('NORDER').VALUE_OF(), NSMART => 0);
    end if;
    /* �������� ������ �������� � ������������ �� � JSON */
    MSGS := UDO_PKG_STAND.MSG_GET_LIST(DFROM => DFROM, STP => STP, SSTS => SSTS, NLIMIT => NLIMIT, NORDER => NORDER);
    JRES := MESSAGES_TO_JSON(MSGS => MSGS);
    /* ����� ����� */
    JRES.TO_CLOB(BUF => CRES);  
  exception
    when others then
      SERR := sqlerrm;
      CRES := UDO_PKG_WEB_API.RESP_MAKE(NRESP_FORMAT => UDO_PKG_WEB_API.NRESP_FORMAT_JSON,
                                        NRESP_STATE  => UDO_PKG_WEB_API.NRESP_STATE_ERR,
                                        SRESP_MSG    => SERR);
      rollback;
  end;
  
  /* ��������� ��������� ������ */
  procedure STAND_GET_STATE
  (
    CPRMS                   clob,                                       -- ������� ���������
    CRES                    out clob                                    -- ��������� ������
  ) is
    NCOMPANY                COMPANIES.RN%type := GET_SESSION_COMPANY(); -- ���. ����� �����������
    JRES                    JSON;                                       -- ��������� ������������� ������
    STAND_STATE             UDO_PKG_STAND.TSTAND_STATE;                 -- ��������� ������
    SERR                    PKG_STD.TSTRING;                            -- ����� ��� ������
  begin
    /* �������������� ����� */
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => CRES, CACHE => false);
    /* ������� ��������� ������ */
    UDO_PKG_STAND.STAND_GET_STATE(NCOMPANY => NCOMPANY, STAND_STATE => STAND_STATE);
    JRES := STAND_STATE_TO_JSON(SS => STAND_STATE);
    /* ����� ����� */
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
