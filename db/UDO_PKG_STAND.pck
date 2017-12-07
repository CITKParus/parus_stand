create or replace package UDO_PKG_STAND as
  /*
    ������� ��� ������ ������
  */

  /* ��������� �������� ������ ������ ������ */
  NALLOW_MULTI_SUPPLY_YES   PKG_STD.TNUMBER := 1;                                       -- ��������� ������������� �������� ������ ����������
  NALLOW_MULTI_SUPPLY_NO    PKG_STD.TNUMBER := 0;                                       -- �� ��������� ������������� �������� ������ ����������

  /* ��������� ������ ������ ������ */
  NALLOW_MULTI_SUPPLY       PKG_STD.TNUMBER := NALLOW_MULTI_SUPPLY_YES;                 -- ����������� ������������� ��������
  SGUEST_BASRCODE           PKG_STD.TSTRING := '0000';                                  -- �����-��� ��������� ����������
  
  /* ��������� �������� ������ ��� ������ */
  SSTORE_PRODUCE            AZSAZSLISTMT.AZS_NUMBER%type := '������������';             -- ����� ������������ ������� ���������
  SSTORE_GOODS              AZSAZSLISTMT.AZS_NUMBER%type := '���';                      -- ����� �������� ������� ���������
  SRACK_PREF                STPLRACKS.PREF%type := '�������';                           -- ������� �������� ������ �������� ������� ���������
  SRACK_NUMB                STPLRACKS.NUMB%type := '1';                                 -- ����� �������� ������ �������� ������� ���������
  SRACK_CELL_PREF_TMPL      STPLCELLS.PREF%type := '����';                              -- ������ �������� ����� ��������
  SRACK_CELL_NUMB_TMPL      STPLCELLS.NUMB%type := '�����';                             -- ������ ������ ����� ��������
  NRACK_LINES               PKG_STD.TNUMBER := 1;                                       -- ���������� ������ ��������
  NRACK_LINE_CELLS          PKG_STD.TNUMBER := 3;                                       -- ���������� ����� (���� ��������) � �����
  NRACK_CELL_CAPACITY       PKG_STD.TNUMBER := 5;                                       -- ������������ ���������� ������������ � ������ ��������
  NRACK_CELL_SHIP_CNT       PKG_STD.TNUMBER := 1;                                       -- ���������� ������������, ����������� ����������� �� ���� ����������
  NRESTS_LIMIT_PRC_MIN      PKG_STD.TLNUMBER := 40;                                     -- ����������� ����������� ������� �� ������ (� %)  
  NRESTS_LIMIT_PRC_MDL      PKG_STD.TLNUMBER := 60;                                     -- ������� ������� �� ������ (� %)  

  /* ��������� �������� �������� �� ������ */
  SDEF_STORE_MOVE_IN        AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type := '������ ����������';  -- �������� ������� �� ���������
  SDEF_STORE_MOVE_OUT       AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type := '������ �������';     -- �������� ������� �� ���������
  SDEF_STORE_PARTY          INCOMDOC.CODE%type := '������� ���������';                  -- ������ �� ���������
  SDEF_FACE_ACC             FACEACC.NUMB%type := '�������������';                       -- ������� ���� �� ���������
  SDEF_TARIF                DICTARIF.CODE%type := '�������';                            -- ����� �� ���������
  SDEF_SHEEP_VIEW           DICSHPVW.CODE%type := '���������';                          -- ��� �������� �� ���������
  SDEF_PAY_TYPE             AZSGSMPAYMENTSTYPES.GSMPAYMENTS_MNEMO%type := '��� ������'; -- ��� ������ �� ���������
  SDEF_TAX_GROUP            DICTAXGR.CODE%type := '��� �������';                        -- ��������� ������ �� ���������
  SDEF_NOMEN_1              DICNOMNS.NOMEN_CODE%type := 'Orbit';                        -- ������������ �� ��������� (1)
  SDEF_NOMEN_MODIF_1        NOMMODIF.MODIF_CODE%type := '������';                       -- ����������� ������������ �� ��������� (1)
  SDEF_NOMEN_2              DICNOMNS.NOMEN_CODE%type := 'Orbit';                        -- ������������ �� ��������� (2)
  SDEF_NOMEN_MODIF_2        NOMMODIF.MODIF_CODE%type := '���������';                    -- ����������� ������������ �� ��������� (2)
  SDEF_NOMEN_3              DICNOMNS.NOMEN_CODE%type := 'Orbit';                        -- ������������ �� ��������� (3)
  SDEF_NOMEN_MODIF_3        NOMMODIF.MODIF_CODE%type := '������������';                 -- ����������� ������������ �� ��������� (3)

  /* ��������� �������� �������� */
  SINCDEPS_TYPE             DOCTYPES.DOCCODE%type := '���';                             -- ��� ��������� "������ �� �������������"
  SINCDEPS_PREF             INCOMEFROMDEPS.DOC_PREF%type := '���';                      -- ������� ��������� "������ �� �������������"

  /* ��������� �������� �������� */
  STRINVCUST_TYPE           DOCTYPES.DOCCODE%type := '����';                            -- ��� ��������� "��������� ��������� �� ������ ������������"
  STRINVCUST_PREF           INCOMEFROMDEPS.DOC_PREF%type := '����';                     -- ������� ��������� "��������� ��������� �� ������ ������������"
  STRINVCUST_REPORT         USERREPORTS.CODE%type := 'RL1580';                          -- �������� ����������������� ������ ��� �������������� ������
    
  /* ��������� �������� �������� �������� ���������� ������ */
  NAGN_SUPPLY_NOT_YET       PKG_STD.TNUMBER := 1;                                       -- �������� ��� �� ����
  NAGN_SUPPLY_ALREADY       PKG_STD.TNUMBER := 2;                                       -- �������� ��� ����
  
  /* ��������� �������� ������������ �������������� ������� */
  SDP_BARCODE               DOCS_PROPS.CODE%type := '��������';                         -- �������� ��������������� �������� ��� ������� ���������
  
  /* ��������� �������� ����� ��������� ������� ������ */
  SMSG_TYPE_NOTIFY          UDO_T_STAND_MSG.TP%type := 'NOTIFY';                        -- ��������� ���� "����������"
  SMSG_TYPE_RESTS           UDO_T_STAND_MSG.TP%type := 'RESTS';                         -- ��������� ���� "�������� �� ��������"
  SMSG_TYPE_REST_PRC        UDO_T_STAND_MSG.TP%type := 'REST_PRC';                      -- ��������� ���� "�������� �� �������� (% �������������)"  
  SMSG_TYPE_PRINT           UDO_T_STAND_MSG.TP%type := 'PRINT';                         -- ��������� ���� "������� ������"
  
  /* ��������� �������� ����� ���������� ��� �������������� ���������  */
  SNOTIFY_TYPE_INFO         PKG_STD.TSTRING := 'INFORMATION';                           -- ����������
  SNOTIFY_TYPE_WARN         PKG_STD.TSTRING := 'WARNING';                               -- ��������������
  SNOTIFY_TYPE_ERROR        PKG_STD.TSTRING := 'ERROR';                                 -- ������
  
  /* ��������� �������� ����� ��������� ������� ������ */
  SMSG_STATE_UNDEFINED      UDO_T_STAND_MSG.STS%type := 'UNDEFINED';                    -- ��������� "�����������"
  SMSG_STATE_NOT_SENDED     UDO_T_STAND_MSG.STS%type := 'NOT_SENDED';                   -- ��������� "������������"
  SMSG_STATE_NOT_PRINTED    UDO_T_STAND_MSG.STS%type := 'NOT_PRINTED';                  -- ��������� "�������������"
  SMSG_STATE_SENDED         UDO_T_STAND_MSG.STS%type := 'SENDED';                       -- ��������� "����������"
  SMSG_STATE_PRINTED        UDO_T_STAND_MSG.STS%type := 'PRINTED';                      -- ��������� "�����������"

  /* ��������� �������� ������� ���������� ��������� ������� ������ */
  NMSG_ORDER_ASC            PKG_STD.TNUMBER := 1;                                       -- ������� ������
  NMSG_ORDER_DESC           PKG_STD.TNUMBER := -1;                                      -- C������ �����
  
  /* ��������� �������� ��������� ������ � ������� ������ */
  NRPT_QUEUE_STATE_INS      PKG_STD.TNUMBER := 0;                                       -- ���������� � �������
  NRPT_QUEUE_STATE_RUN      PKG_STD.TNUMBER := 1;                                       -- ��������������
  NRPT_QUEUE_STATE_OK       PKG_STD.TNUMBER := 2;                                       -- ��������� �������
  NRPT_QUEUE_STATE_ERR      PKG_STD.TNUMBER := 3;                                       -- ��������� � �������
  
  /* ��������� �������� ��������� ������ � ������� ������ */
  SRPT_QUEUE_STATE_INS      PKG_STD.TSTRING := 'QUEUE_STATE_INS';                       -- ���������� � �������
  SRPT_QUEUE_STATE_RUN      PKG_STD.TSTRING := 'QUEUE_STATE_RUN';                       -- ��������������
  SRPT_QUEUE_STATE_OK       PKG_STD.TSTRING := 'QUEUE_STATE_OK';                        -- ��������� �������
  SRPT_QUEUE_STATE_ERR      PKG_STD.TSTRING := 'QUEUE_STATE_ERR';                       -- ��������� � �������

  /* ���� ������ - ������������ ������ ������ */
  type TRACK_LINE_CELL_CONF is record
  (
    NRACK_CELL              STPLCELLS.RN%type,                                          -- ��������������� ����� ������
    NRACK_LINE              PKG_STD.TREF,                                               -- ����� ����� �������� �� ������� ��������� �����
    NRACK_LINE_CELL         PKG_STD.TREF,                                               -- ����� ������ � ����� �������� ������
    SPREF                   STPLCELLS.PREF%type,                                        -- ������� ������
    SNUMB                   STPLCELLS.NUMB%type,                                        -- ����� ������
    SNAME                   PKG_STD.TSTRING,                                            -- ������ ������������ ������
    NNOMEN                  DICNOMNS.RN%type,                                           -- ��������������� ����� ������������ ��������
    SNOMEN                  DICNOMNS.NOMEN_CODE%type,                                   -- �������� ������������ ��������
    NNOMMODIF               NOMMODIF.RN%type,                                           -- ��������������� ����� ����������� ������������ ��������
    SNOMMODIF               NOMMODIF.MODIF_CODE%type,                                   -- �������� ����������� ������������ ��������
    NCAPACITY               PKG_STD.TNUMBER,                                            -- ����������� ������
    NSHIP_CNT               PKG_STD.TNUMBER                                             -- ����������� ����������
  );
  
  /* ���� ������ - ��������� ������������ ����� ������ ������ */
  type TRACK_LINE_CELL_CONFS is table of TRACK_LINE_CELL_CONF;

  /* ���� ������ - ������������ ������������ ������ */
  type TRACK_NOMEN_CONF is record
  (
    NNOMEN                  DICNOMNS.RN%type,                                           -- ��������������� ����� ������������ ��������
    SNOMEN                  DICNOMNS.NOMEN_CODE%type,                                   -- �������� ������������ ��������
    NNOMMODIF               NOMMODIF.RN%type,                                           -- ��������������� ����� ����������� ������������ ��������
    SNOMMODIF               NOMMODIF.MODIF_CODE%type,                                   -- �������� ����������� ������������ ��������
    NMAX_QUANT              PKG_STD.TLNUMBER,                                           -- ����������� ��������� ���������� ������������ �� ������
    NMEAS                   DICMUNTS.RN%type,                                           -- ��������������� ����� �������� �� ������������
    SMEAS                   DICMUNTS.MEAS_MNEMO%type                                    -- �������� �������� �� ������������
  );

  /* ���� ������ - ��������� ������������ ������������ ������ */
  type TRACK_NOMEN_CONFS is table of TRACK_NOMEN_CONF;

  /* ���� ������ - ��������� ������� ������������ */
  type TNOMEN_REST is record
  (
    NNOMEN                  DICNOMNS.RN%type,                                           -- ��������������� ����� ������������ �������
    SNOMEN                  DICNOMNS.NOMEN_CODE%type,                                   -- �������� ������������ �������
    NNOMMODIF               NOMMODIF.RN%type,                                           -- ��������������� ����� ����������� ������������ �������
    SNOMMODIF               NOMMODIF.MODIF_CODE%type,                                   -- �������� ����������� ������������ �������
    NREST                   STPLGOODSSUPPLY.QUANT%type,                                 -- ������� � ��������� ��
    NMEAS                   DICMUNTS.RN%type,                                           -- ��������������� ����� �������� �� ������������ �������
    SMEAS                   DICMUNTS.MEAS_MNEMO%type                                    -- �������� �������� �� ������������ �������
  );
  
  /* ���� ������ - ��������� ��������� �������� ������������ */
  type TNOMEN_RESTS is table of TNOMEN_REST;
  
  /* ���� ������ - ��������� ������� ������ �������� (����� ��������) */
  type TRACK_LINE_CELL_REST is record
  (
    NRACK_CELL              STPLCELLS.RN%type,                                          -- ��������������� ����� ������
    SRACK_CELL_PREF         STPLCELLS.PREF%type,                                        -- ������� ������
    SRACK_CELL_NUMB         STPLCELLS.NUMB%type,                                        -- ����� ������
    SRACK_CELL_NAME         PKG_STD.TSTRING,                                            -- ������ ������������ ������
    NRACK_LINE              PKG_STD.TREF,                                               -- ����� ����� �������� �� ������� ��������� �����
    NRACK_LINE_CELL         PKG_STD.TREF,                                               -- ����� ������ � ����� �������� ������
    BEMPTY                  boolean,                                                    -- ���� ������ ������
    NOMEN_RESTS             TNOMEN_RESTS := TNOMEN_RESTS()                              -- ������� �����������
  );
  
  /* ���� ������ - ��������� ��������� �������� ����� �������� (����� ��������) */
  type TRACK_LINE_CELL_RESTS is table of TRACK_LINE_CELL_REST;
  
  /* ���� ������ - ��������� ������� ����� �������� */
  type TRACK_LINE_REST is record
  (
    NRACK_LINE              PKG_STD.TREF,                                               -- ����� ����� ��������
    NRACK_LINE_CELLS_CNT    PKG_STD.TREF,                                               -- ���������� ����� �����
    BEMPTY                  boolean,                                                    -- ���� ������� �����
    RACK_LINE_CELL_RESTS    TRACK_LINE_CELL_RESTS := TRACK_LINE_CELL_RESTS()            -- ������� � ������ �������� �����
  );
  
  /* ���� ������ - ��������� ��������� �������� ������ �������� */
  type TRACK_LINE_RESTS is table of TRACK_LINE_REST;
  
  /* ���� ������ - ��������� ������� �������� */
  type TRACK_REST is record
  (
    NRACK                   STPLRACKS.RN%type,                                          -- ��������������� ����� ��������
    NSTORE                  AZSAZSLISTMT.RN%type,                                       -- ��������������� ����� ������ ��������
    SSTORE                  AZSAZSLISTMT.AZS_NUMBER%type,                               -- �������� ������ ��������
    SRACK_PREF              STPLRACKS.PREF%type,                                        -- ������� ��������
    SRACK_NUMB              STPLRACKS.NUMB%type,                                        -- ����� ��������
    SRACK_NAME              PKG_STD.TSTRING,                                            -- ������ ������������ ��������
    NRACK_LINES_CNT         PKG_STD.TREF,                                               -- ���������� ������ ��������
    BEMPTY                  boolean,                                                    -- ���� ������� ��������        
    RACK_LINE_RESTS         TRACK_LINE_RESTS := TRACK_LINE_RESTS()                      -- ������� � ������ ��������
  );
  
  /* ��� ������ - ������� ������������� (% ������� �� �������) ������ */
  type TRACK_REST_PRC_HIST is record
  (
    DTS                     date,                                                       -- ���� �������
    STS                     PKG_STD.TSTRING,                                            -- ��������� ������������� ���� ������� (��.��.���� ��24:��:��)
    NREST_PRC               PKG_STD.TLNUMBER                                            -- % ������������� ������ �� ����
  );
  
  /* ��� ������ - ������ ������� �������� ������ */
  type TRACK_REST_PRC_HISTS is table of TRACK_REST_PRC_HIST;
  
  /* ���� ������ - ���������� ������ */
  type TSTAND_USER is record
  (
    NAGENT                  AGNLIST.RN%type,                                            -- ��������������� ����� �����������-����������
    SAGENT                  AGNLIST.AGNABBR%type,                                       -- �������� �����������-����������
    SAGENT_NAME             AGNLIST.AGNNAME%type                                        -- ������������ �����������-����������
  );
  
  /* ���� ������ - ��������� */
  type TMESSAGE is record
  (
    NRN                     UDO_T_STAND_MSG.RN%type,                                    -- ��������������� ����� ���������
    DTS                     UDO_T_STAND_MSG.TS%type,                                    -- ���� ���������
    STS                     PKG_STD.TSTRING,                                            -- ��������� ������������� ���� ��������� (��.��.���� ��24:��:��)
    STP                     UDO_T_STAND_MSG.TP%type,                                    -- ��� ���������
    SMSG                    UDO_T_STAND_MSG.MSG%type,                                   -- ����� ���������
    SSTS                    UDO_T_STAND_MSG.STS%type                                    -- ��������� ���������
  );
  
  /* ���� ������ - ��������� ��������� */
  type TMESSAGES is table of TMESSAGE;  
  
  /* ���� ������ - ��������� ������ */  
  type TSTAND_STATE is record
  (
    NRESTS_LIMIT_PRC_MIN    PKG_STD.TLNUMBER,                                           -- ����������� ����������� ������� �� ������ (� %)  
    NRESTS_LIMIT_PRC_MDL    PKG_STD.TLNUMBER,                                           -- ������� ����������� ������� �� ������ (� %)  
    NRESTS_PRC_CURR         PKG_STD.TLNUMBER,                                           -- ������� ������������� ������ (%)
    NOMEN_CONFS             TRACK_NOMEN_CONFS,                                          -- ������������ ����������� ������
    NOMEN_RESTS             TNOMEN_RESTS,                                               -- ������� ����������� ������
    RACK_REST_PRC_HISTS     TRACK_REST_PRC_HISTS,                                       -- ������� % ������������� ������
    RACK_REST               TRACK_REST,                                                 -- ������� �� ������ �������� ������    
    MESSAGES                TMESSAGES                                                   -- ��������� ������
  );
  
  /* ���� ������ - ��������� ������� ������� ������ ������� */
  type TRPT_QUEUE_STATE is record
  (
    NRN                     RPTPRTQUEUE.RN%type,                                        -- ��������������� ����� ������� �������
    SSTATE                  PKG_STD.TSTRING,                                            -- ��������� (��. ��������� SRPT_QUEUE_STATE_*)
    SERR                    RPTPRTQUEUE.ERROR_TEXT%type,                                -- ��������� �� ������ (���� ����)
    SFILE_NAME              PKG_STD.TSTRING,                                            -- ��� ����� ������
    SURL                    PKG_STD.TSTRING                                             -- URL ��� �������� �������� ������
  );
  
  /* ������� ���������� ��������� � ������� */
  procedure MSG_BASE_INSERT
  (
    STP                     varchar2,   -- ��� ���������
    SMSG                    varchar2,   -- ����� ���������
    NRN                     out number  -- ��������������� ����� ������������ ���������
  );
  
  /* ������� �������� ��������� �� ������� */
  procedure MSG_BASE_DELETE
  (
    NRN                     number      -- ��������������� ����� ���������
  );
  
  /* ������� ��������� ��������� ��������� ������� */
  procedure MSG_BASE_SET_STATE
  (
    NRN                     number,     -- ��������������� ����� ���������
    SSTS                    varchar2    -- ��������� ��������� (��. ��������� SMSG_STATE_*)
  );
  
  /* ���������� � ������� ��������� ���� "����������" */
  procedure MSG_INSERT_NOTIFY
  (
    SMSG                    varchar2,                     -- ����� ���������
    SNOTIFY_TYPE            varchar2 := SNOTIFY_TYPE_INFO -- ��� ���������� (��. ��������� SNOTIFY_TYPE_*)
  );  
  
  /* ���������� � ������� ��������� ���� "�������� �� ��������" */
  procedure MSG_INSERT_RESTS
  (
    SMSG                    varchar2    -- ����� ���������
  );

    /* ���������� � ������� ��������� ���� "�������� �� �������� (% �������������)" */
  procedure MSG_INSERT_REST_PRC
  (
    SMSG                    varchar2    -- ����� ���������
  );
  
  /* ���������� � ������� ��������� ���� "������� ������" */
  procedure MSG_INSERT_PRINT
  (
    SMSG                    varchar2    -- ����� ���������
  );
  
  /* ���������� � ������� ��������� */
  procedure MSG_INSERT
  (
    STP                     varchar2,                     -- ��� ���������
    SMSG                    varchar2,                     -- ����� ���������
    SNOTIFY_TYPE            varchar2 := SNOTIFY_TYPE_INFO -- ��� ���������� (��. ��������� SNOTIFY_TYPE_*)
  );
  
  /* �������� ��������� �� ������� */
  procedure MSG_DELETE
  (
    NRN                     number      -- ��������������� ����� ���������
  );
  
  /* ��������� ��������� ��������� ������� */
  procedure MSG_SET_STATE
  (
    NRN                     number,     -- ��������������� ����� ���������
    SSTS                    varchar2    -- ��������� ��������� (��. ��������� SMSG_STATE_*)
  );
  
  /* ���������� ��������� �� ������� */
  function MSG_GET
  (
    NRN                     number,     -- ��������������� ����� ���������
    NSMART                  number := 0 -- ������� ������ ��������� �� ������ (0 - ��������, 1 - �� ��������)
  ) return UDO_T_STAND_MSG%rowtype;
  
  /* ���������� ����� ��������� �� ������� */
  function MSG_GET_LIST
  (
    DFROM                   date := null,            -- ���� � ������� ���������� ������ ������ (null - �� ���������)
    STP                     varchar2 := null,        -- ��� ��������� (null - ���, ��. ��������� SMSG_TYPE_*)
    SSTS                    varchar2 := null,        -- ��������� ��������� (null - �����, ��. ��������� SMSG_STATE_*)
    NLIMIT                  number := null,          -- ������������ ���������� (null - ���)
    NORDER                  number := NMSG_ORDER_ASC -- ������� ���������� (��. ��������� SMSG_ORDER_*)
  ) return TMESSAGES;  
  
  /* ������������ ������������ �������� (�������-�����) */
  function RACK_BUILD_NAME 
  (
    SPREF                   varchar2,   -- ������� ��������
    SNUMB                   varchar2    -- ����� ��������
  ) return varchar2;
  
  /* ������������ �������� ������ ����� �������� ������ */
  function RACK_LINE_CELL_BUILD_PREF
  (
    NRACK_LINE              number,     -- ����� ����� �������� � ������� ��������� ������               
    SPREF_TMPL              varchar2    -- ������ ��������
  ) return varchar2;

  /* ������������ ������ ������ ����� �������� ������ */
  function RACK_LINE_CELL_BUILD_NUMB
  (
    NRACK_LINE_CELL         number,     -- ����� ������ � ����� ��������
    SNUMB_TMPL              varchar2    -- ������ ������
  ) return varchar2;
  
  /* ������������ ������� ����� (�������-�����) ������ ����� �������� ������ (�� �������� � ������)*/
  function RACK_LINE_CELL_BUILD_NAME
  (
    SPREF                   varchar2,   -- ������� ������
    SNUMB                   varchar2    -- ����� ������
  ) return varchar2;  
  
  /* ������������ ������� ����� (�������-�����) ������ ����� �������� ������ (�� �����������)*/
  function RACK_LINE_CELL_BUILD_NAME
  (
    NRACK_LINE              number,     -- ����� ����� �������� � ������� ��������� ������
    NRACK_LINE_CELL         number,     -- ����� ������ � ����� ��������
    SPREF_TMPL              varchar2,   -- ������ ��������    
    SNUMB_TMPL              varchar2    -- ������ ������
  ) return varchar2;
  
  /* ������������� ������������ ����� ������ */
  procedure STAND_INIT_RACK_LINE_CELL_CONF
  (
    NCOMPANY                number,     -- ��������������� ����� ����������� 
    SSTORE                  varchar2    -- �������� ������ ������
  );
  
  /* ������������� ������������ ����������� ������ */
  procedure STAND_INIT_RACK_NOMEN_CONF;

  /* ������������� ������������ ������ */
  procedure STAND_INIT_RACK_CONF
  (
    NCOMPANY                number,     -- ��������������� ����� ����������� 
    SSTORE                  varchar2    -- �������� ������ ������
  );
  
  /* ��������� ������������ ������ ������ */
  function STAND_GET_RACK_LINE_CELL_CONF
  (
    NRACK_LINE              number,     -- ����� ����� �������� ������
    NRACK_LINE_CELL         number      -- ����� ������ � ����� �������� ������
  ) return TRACK_LINE_CELL_CONF;
  
  /* ��������� ������������ ������������ ������ (�� ���. ������ �����������) */
  function STAND_GET_RACK_NOMEN_CONF
  (
    NNOMMODIF               number      -- ��������������� ����� ����������� ������������
  ) return TRACK_NOMEN_CONF;
  
  /* ��������� ������������ ������������ ������ (�� ��������� ������������ � �����������) */
  function STAND_GET_RACK_NOMEN_CONF
  (
    SNOMEN                  varchar2,   -- �������� ������������
    SNOMMODIF               varchar2    -- �������� ����������� ������������
  ) return TRACK_NOMEN_CONF;
  
  /* ��������� �������� �������� ������ �� ������������� */
  function STAND_GET_RACK_NOMEN_REST
  (
    NCOMPANY                number,           -- ��������������� ����� �����������
    SSTORE                  varchar2,         -- �������� ������ ������
    SPREF                   varchar2,         -- ������� �������� ������
    SNUMB                   varchar2,         -- ����� �������� ������
    SCELL                   varchar2 := null, -- ������������ (�������-�����) ������ �������� (null - �� ����)    
    SNOMEN                  varchar2 := null, -- ������������ (null - �� ����)
    SNOMEN_MODIF            varchar2 := null  -- ����������� (null - �� ����)
  ) return TNOMEN_RESTS;
  
  /* ��������� �������� �������� ������ �� ������ �������� */
  function STAND_GET_RACK_REST
  (
    NCOMPANY                number,     -- ��������������� ����� �����������
    SSTORE                  varchar2,   -- �������� ������ ������
    SPREF                   varchar2,   -- ������� �������� ������
    SNUMB                   varchar2    -- ����� �������� ������
  ) return TRACK_REST;
  
  /* ����� �����������-���������� ������ �� ��������� */
  function STAND_GET_AGENT_BY_BARCODE
  (
    NCOMPANY                number,     -- ��������������� ����� �����������
    SBARCODE                varchar2    -- ��������
  ) return TSTAND_USER;
  
  /* ��������� ��������� ������ */
  procedure STAND_GET_STATE
  (
    NCOMPANY                number,          -- ��������������� ����� �����������
    STAND_STATE             out TSTAND_STATE -- ��������� ������
  );

  /* ���������� ������� �������� �� ������ */
  procedure STAND_SAVE_RACK_REST
  (
    NCOMPANY                number,     -- ��������������� ����� ������������
    BNOTIFY_REST            boolean,    -- ���� ���������� � ������� �������
    BNOTIFY_LIMIT           boolean     -- ���� ���������� � ����������� �������� �������
  );
  
  /* �������� ������������� ������ �����������-���������� ������ �� ������ (��. ��������� NAGN_SUPPLY_*) */
  function STAND_CHECK_SUPPLY
  (
    NCOMPANY                number,     -- ��������������� ����� �����������
    NAGENT                  number      -- ��������������� ����� �����������
  ) return number;
  
  /* �������������� ���������� ������ �� ��������� */
  procedure STAND_AUTH_BY_BARCODE
  (
    NCOMPANY                number,          -- ��������������� ����� �����������
    SBARCODE                varchar2,        -- ��������
    STAND_USER              out TSTAND_USER, -- �������� � ������������ ������
    RACK_REST               out TRACK_REST   -- �������� �� �������� �� ������
  );    
  
  /* ���������� ������ ���������� */
  procedure STAND_USER_CREATE  
  (
    NCOMPANY                number,     -- ��������������� ����� �����������
    SAGNABBR                varchar2,   -- ������� � �������� ����������
    SAGNNAME                varchar2,   -- �������, ��� � �������� ����������
    SFULLNAME               varchar2    -- ������������ ����������� ����������
  );
  
  /* �������� ������ ������� */
  procedure LOAD
  (
    NCOMPANY                number,         -- ��������������� ����� ����������� 
    NRACK_LINE              number := null, -- ����� ����� �������� ������ ��� �������� (null - ������� ���)
    NRACK_LINE_CELL         number := null, -- ����� ������ � ����� �������� ������ ��� �������� (null - ������� ���)
    NINCOMEFROMDEPS         out number      -- ��������������� ����� ��������������� "������� �� �������������"    
  );

  /* ����� ��������� �������� ������ */
  procedure LOAD_ROLLBACK
  (
    NCOMPANY                number,     -- ��������������� ����� �����������
    NINCOMEFROMDEPS         out number  -- ��������������� ����� ����������������� "������� �� �������������"        
  );

  /* �������� �� ������ ���������� */
  procedure SHIPMENT
  (
    NCOMPANY                number,     -- ��������������� ����� �����������
    SCUSTOMER               varchar2,   -- �������� �����������-����������
    NRACK_LINE              number,     -- ����� ����� �������� ������
    NRACK_LINE_CELL         number,     -- ����� ������ � ����� �������� ������
    NTRANSINVCUST           out number  -- ��������������� ����� �������������� ����    
  );

  /* ����� �������� �� ������ */
  procedure SHIPMENT_ROLLBACK
  (
    NCOMPANY                number,     -- ��������������� ����� �����������
    NTRANSINVCUST           number      -- ��������������� ����� ����������� ����
  );
  
  /* ���������� ��������� ������ ������� ������ */
  procedure PRINT_GET_STATE
  (
    SSESSION                varchar2,            -- ������������� ������    
    NRPTPRTQUEUE            number,              -- ��������������� ����� ������ ������� ������
    RPT_QUEUE_STATE         out TRPT_QUEUE_STATE -- ��������� ������� ������� ������
  );
  
  /* ���������� ������ ���������� ��� ������ ���������� (���������� ����������) */
  procedure PRINT_SET_SELECTLIST
  (
    NIDENT                  number,     -- ������������� ������
    NDOCUMENT               number,     -- ��������������� ����� ���������
    SUNITCODE               varchar2    -- ��� ������� ���������
  );
  
  /* ������� ������ ���������� ��� ������ ���������� (���������� ����������) */
  procedure PRINT_CLEAR_SELECTLIST
  (
    NIDENT                  number      -- ������������� ������
  );
  
  /* ������ ���� ����� ������ ������ */
  procedure PRINT
  (
    NCOMPANY                number,     -- ��������������� ����� ������������
    NTRANSINVCUST           number      -- ��������������� ����� ����
  );
  
end;
/
create or replace package body UDO_PKG_STAND as

  /* ����������� ���������� ������������ ������ */
  RACK_LINE_CELL_CONFS      TRACK_LINE_CELL_CONFS; -- ����� �������� ������
  RACK_NOMEN_CONFS          TRACK_NOMEN_CONFS;     -- ������������ ������
  
  /* ������� ���������� ��������� � ������� */
  procedure MSG_BASE_INSERT
  (
    STP                     varchar2,                 -- ��� ���������
    SMSG                    varchar2,                 -- ����� ���������
    NRN                     out number                -- ��������������� ����� ������������ ���������
  ) is
    SSTS                    UDO_T_STAND_MSG.STS%type; -- ��������� ������������ ���������
  begin
    /* �������� ��������� */
    if (STP not in (SMSG_TYPE_NOTIFY, SMSG_TYPE_RESTS, SMSG_TYPE_REST_PRC, SMSG_TYPE_PRINT)) then
      P_EXCEPTION(0, '��� ��������� "%s" �� ��������������!', STP);
    end if;
    if (SMSG is null) then
      P_EXCEPTION(0, '�� ������� ��������� ��� ����������!');
    end if;
    /* ���������� ��������������� ����� */
    NRN := GEN_ID();
    /* ��������� ��������� */
    case STP
      when SMSG_TYPE_NOTIFY then
        SSTS := SMSG_STATE_NOT_SENDED;
      when SMSG_TYPE_PRINT then
        SSTS := SMSG_STATE_NOT_PRINTED;
      else
        SSTS := SMSG_STATE_UNDEFINED;
    end case;
    /* ������� ��������� */
    insert into UDO_T_STAND_MSG (RN, TS, TP, MSG, STS) values (NRN, sysdate, STP, SMSG, SSTS);
  end;
    
  /* ������� �������� ��������� �� ������� */
  procedure MSG_BASE_DELETE
  (
    NRN                     number      -- ��������������� ����� ���������
  ) is
  begin
    /* ������ ��������� */
    delete from UDO_T_STAND_MSG T where T.RN = NRN;
  end;
  
  /* ������� ��������� ��������� ��������� ������� */
  procedure MSG_BASE_SET_STATE
  (
    NRN                     number,                  -- ��������������� ����� ���������
    SSTS                    varchar2                 -- ��������� ��������� (��. ��������� SMSG_STATE_*)
  ) is
    REC                     UDO_T_STAND_MSG%rowtype; -- ������ ��������������� ���������
  begin
    /* ������� ��������� */
    REC := MSG_GET(NRN => NRN, NSMART => 0);
    /* �������� ������������ �������� ��������� */
    case REC.TP
      /* ��������� ���� "����������" */
      when SMSG_TYPE_NOTIFY then
        begin
          if (SSTS not in (SMSG_STATE_NOT_SENDED, SMSG_STATE_SENDED)) then
            P_EXCEPTION(0,
                        '��������� ��������� "%s" ��� ��������� ���� "%s" �����������!',
                        SSTS,
                        REC.TP);
          end if;
        end;
      /* ��������� ���� "�������� �� ��������" */
      when SMSG_TYPE_RESTS then
        begin
          if (SSTS not in (SMSG_STATE_UNDEFINED)) then
            P_EXCEPTION(0,
                        '��������� ��������� "%s" ��� ��������� ���� "%s" �����������!',
                        SSTS,
                        REC.TP);
          end if;
        end;
      /* ��������� ���� "�������� �� �������� (% �������������)"   */
      when SMSG_TYPE_REST_PRC then
        begin
          if (SSTS not in (SMSG_STATE_UNDEFINED)) then
            P_EXCEPTION(0,
                        '��������� ��������� "%s" ��� ��������� ���� "%s" �����������!',
                        SSTS,
                        REC.TP);
          end if;
        end;
      /* ��������� ���� "������� ������" */
      when SMSG_TYPE_PRINT then
        begin
          if (SSTS not in (SMSG_STATE_NOT_PRINTED, SMSG_STATE_PRINTED)) then
            P_EXCEPTION(0,
                        '��������� ��������� "%s" ��� ��������� ���� "%s" �����������!',
                        SSTS,
                        REC.TP);
          end if;
        end;
      /* ����������� ��� ��������� */
      else
        P_EXCEPTION(0,
                    '��������� ��������� ��� ��������� ���� "%s" �� ��������������!',
                    REC.TP);
    end case;
    /* ��������� ��������� � ��������� */
    update UDO_T_STAND_MSG T set T.STS = SSTS where T.RN = REC.RN;
  end;
  
  /* ���������� � ������� ��������� ���� "����������" */
  procedure MSG_INSERT_NOTIFY
  (
    SMSG                    varchar2,                     -- ����� ���������
    SNOTIFY_TYPE            varchar2 := SNOTIFY_TYPE_INFO -- ��� ���������� (��. ��������� SNOTIFY_TYPE_*)    
  ) is
    NRN                     UDO_T_STAND_MSG.RN%type; -- ��������������� ����� ������������ ���������
    JM                      JSON;                    -- ��������� ������������� ���������
  begin
    /* �������� ��� ���������� */
    if (SNOTIFY_TYPE is null) then
      P_EXCEPTION(0,
                  '�� ������ ��� ���������� ��� ��������������� ���������!');
    end if;
    if (SNOTIFY_TYPE not in (SNOTIFY_TYPE_INFO, SNOTIFY_TYPE_WARN, SNOTIFY_TYPE_ERROR)) then
      P_EXCEPTION(0, '��� ���������� "%s" �� ��������������!', SNOTIFY_TYPE);
    end if;
    /* ������ ��������� */
    JM := JSON();
    JM.PUT(PAIR_NAME => 'SMSG', PAIR_VALUE => SMSG);
    JM.PUT(PAIR_NAME => 'SNOTIFY_TYPE', PAIR_VALUE => SNOTIFY_TYPE);
    /* �������� ������� ���������� � ������� ��������� */
    MSG_BASE_INSERT(STP => SMSG_TYPE_NOTIFY, SMSG => JM.TO_CHAR(), NRN => NRN);
  end;
  
  /* ���������� � ������� ��������� ���� "�������� �� ��������" */
  procedure MSG_INSERT_RESTS
  (
    SMSG                    varchar2                 -- ����� ���������
  ) is
    NRN                     UDO_T_STAND_MSG.RN%type; -- ��������������� ����� ������������ ���������
  begin
    /* �������� ������� ���������� � ������� ��������� */
    MSG_BASE_INSERT(STP => SMSG_TYPE_RESTS, SMSG => SMSG, NRN => NRN);
  end;

  /* ���������� � ������� ��������� ���� "�������� �� �������� (% �������������)" */
  procedure MSG_INSERT_REST_PRC
  (
    SMSG                    varchar2                 -- ����� ���������
  ) is
    NRN                     UDO_T_STAND_MSG.RN%type; -- ��������������� ����� ������������ ���������
  begin
    /* �������� ������� ���������� � ������� ��������� */
    MSG_BASE_INSERT(STP => SMSG_TYPE_REST_PRC, SMSG => SMSG, NRN => NRN);
  end;

  /* ���������� � ������� ��������� ���� "������� ������" */
  procedure MSG_INSERT_PRINT
  (
    SMSG                    varchar2                 -- ����� ���������
  ) is
    NRN                     UDO_T_STAND_MSG.RN%type; -- ��������������� ����� ������������ ���������
  begin
    /* �������� ������� ���������� � ������� ��������� */
    MSG_BASE_INSERT(STP => SMSG_TYPE_PRINT, SMSG => SMSG, NRN => NRN);
  end;
  
  /* ���������� � ������� ��������� */
  procedure MSG_INSERT
  (
    STP                     varchar2,                     -- ��� ���������
    SMSG                    varchar2,                     -- ����� ���������
    SNOTIFY_TYPE            varchar2 := SNOTIFY_TYPE_INFO -- ��� ���������� (��. ��������� SNOTIFY_TYPE_*)    
  ) is
  begin
    /* �������� ��������� */
    if (STP is null) then
      P_EXCEPTION(0, '�� ������ ��� ���������!');
    end if;
    if (SMSG is null) then
      P_EXCEPTION(0, '�� ������ ����� ���������!');
    end if;
    /* �������� �� ���� ��������� */
    case STP
      /* ��� ��������� - ���������� */
      when SMSG_TYPE_NOTIFY then
        MSG_INSERT_NOTIFY(SMSG => SMSG, SNOTIFY_TYPE => SNOTIFY_TYPE);
      /* ��� ��������� - �������� �� �������� */        
      when SMSG_TYPE_RESTS then
        MSG_INSERT_RESTS(SMSG => SMSG);
      /* ��� ��������� - �������� �� �������� (% �������������) */        
      when SMSG_TYPE_RESTS then
        MSG_INSERT_REST_PRC(SMSG => SMSG);
      /* ��� ��������� - ������� ������ */        
      when SMSG_TYPE_PRINT then
        MSG_INSERT_PRINT(SMSG => SMSG);
      /* ����������� ��� ��������� */
      else
        P_EXCEPTION(0, '��� ��������� "%s" �� ��������������!', STP);
    end case;
  end;
  
  /* �������� ��������� �� ������� */
  procedure MSG_DELETE
  (
    NRN                     number      -- ��������������� ����� ���������
  ) is
  begin
    /* �������� ������� �������� */
    MSG_BASE_DELETE(NRN => NRN);
  end;
  
  /* ��������� ��������� ��������� ������� */
  procedure MSG_SET_STATE
  (
    NRN                     number,     -- ��������������� ����� ���������
    SSTS                    varchar2    -- ��������� ��������� (��. ��������� SMSG_STATE_*)
  ) is
  begin
    /* �������� ������� ��������� ��������� */
    MSG_BASE_SET_STATE(NRN => NRN, SSTS => SSTS);
  end;
      
  /* ���������� ��������� �� ������� */
  function MSG_GET
  (
    NRN                     number,                  -- ��������������� ����� ���������
    NSMART                  number := 0              -- ������� ������ ��������� �� ������ (0 - ��������, 1 - �� ��������)
  ) return UDO_T_STAND_MSG%rowtype is
    RES                     UDO_T_STAND_MSG%rowtype; -- ��������� ������
  begin
    /* ������� ������ */
    begin
      select T.* into RES from UDO_T_STAND_MSG T where T.RN = NRN;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART, NDOCUMENT => NRN, SUNIT_TABLE => 'UDO_T_STAND_MSG');
    end;
    /* ������ ��������� */
    return RES;
  end;
  
  /* ���������� ����� ��������� �� ������� */
  function MSG_GET_LIST
  (
    DFROM                   date := null,            -- ���� � ������� ���������� ������ ������ (null - �� ���������)
    STP                     varchar2 := null,        -- ��� ��������� (null - ���, ��. ��������� SMSG_TYPE_*)
    SSTS                    varchar2 := null,        -- ��������� ��������� (null - �����, ��. ��������� SMSG_STATE_*)
    NLIMIT                  number := null,          -- ������������ ���������� (null - ���)
    NORDER                  number := NMSG_ORDER_ASC -- ������� ���������� (��. ��������� SMSG_ORDER_*)
  ) return TMESSAGES is
    RES                     TMESSAGES;               -- ��������� ������
  begin
    /* �������� ������������ �������� ������� ���������� */
    if (NORDER not in (NMSG_ORDER_ASC, NMSG_ORDER_DESC)) then
      P_EXCEPTION(0,
                  '����������� ������ ������� ���������� ������������ ���������!');
    end if;
    /* �������������� ����� */
    RES := TMESSAGES();
    /* ������ ������ ��������� � �������� ��������������� ������� */
    for M in (select *
                from (select *
                        from (select T.*
                                from UDO_T_STAND_MSG T
                               where ((STP is null) or (STP is not null) and (T.TP = STP))
                                 and ((SSTS is null) or (SSTS is not null) and (T.STS = SSTS))
                                 and ((DFROM is null) or (DFROM is not null) and (T.TS >= DFROM))
                               order by T.RN * NORDER) D
                       where ((NLIMIT is null) or (NLIMIT is not null) and (ROWNUM <= NLIMIT))) F)
    loop
      /* ��������� ��������� � ����� */
      RES.EXTEND();
      /* ��������� ��� */
      RES(RES.LAST).NRN := M.RN;
      RES(RES.LAST).DTS := M.TS;
      RES(RES.LAST).STS := TO_CHAR(M.TS, 'dd.mm.yyyy hh24:mi:ss');
      RES(RES.LAST).STP := M.TP;
      RES(RES.LAST).SMSG := M.MSG;
      RES(RES.LAST).SSTS := M.STS;
    end loop;
    /* ����� ��������� */
    return RES;
  end;
  
  /* ������������ ������������ �������� (�������-�����) */
  function RACK_BUILD_NAME 
  (
    SPREF                   varchar2,   -- ������� ��������
    SNUMB                   varchar2    -- ����� ��������
  ) return varchar2 is
  begin
    return trim(SPREF) || '-' || trim(SNUMB);
  end;
  
  /* ������������ �������� ������ ����� �������� ������ */
  function RACK_LINE_CELL_BUILD_PREF
  (
    NRACK_LINE              number,     -- ����� ����� �������� � ������� ��������� ������               
    SPREF_TMPL              varchar2    -- ������ ��������
  ) return varchar2 is
  begin
    return SPREF_TMPL || NRACK_LINE;
  end;

  /* ������������ ������ ������ ����� �������� ������ */
  function RACK_LINE_CELL_BUILD_NUMB
  (
    NRACK_LINE_CELL         number,     -- ����� ������ � ����� ��������
    SNUMB_TMPL              varchar2    -- ������ ������
  ) return varchar2 is
  begin
    return SNUMB_TMPL || NRACK_LINE_CELL;
  end;
  
  /* ������������ ������� ����� (�������-�����) ������ ����� �������� ������ (�� �������� � ������)*/
  function RACK_LINE_CELL_BUILD_NAME
  (
    SPREF                   varchar2,   -- ������� ������
    SNUMB                   varchar2    -- ����� ������
  ) return varchar2 is
  begin
    return trim(SPREF) || '-' || trim(SNUMB);
  end;  
  
  /* ������������ ������� ����� (�������-�����) ������ ����� �������� ������ (�� �����������)*/
  function RACK_LINE_CELL_BUILD_NAME
  (
    NRACK_LINE              number,     -- ����� ����� �������� � ������� ��������� ������
    NRACK_LINE_CELL         number,     -- ����� ������ � ����� ��������
    SPREF_TMPL              varchar2,   -- ������ ��������    
    SNUMB_TMPL              varchar2    -- ������ ������
  ) return varchar2 is
  begin
    return RACK_LINE_CELL_BUILD_NAME(SPREF => RACK_LINE_CELL_BUILD_PREF(NRACK_LINE => NRACK_LINE,
                                                                        SPREF_TMPL => SPREF_TMPL),
                                     SNUMB => RACK_LINE_CELL_BUILD_NUMB(NRACK_LINE_CELL => NRACK_LINE_CELL,
                                                                        SNUMB_TMPL      => SNUMB_TMPL));
  end;  
  
  /* ������������� ������������ ����� ������ */
  procedure STAND_INIT_RACK_LINE_CELL_CONF 
  (
    NCOMPANY                number,             -- ��������������� ����� ����������� 
    SSTORE                  varchar2            -- �������� ������ ������
  ) is
    NDEF_NOMEN_1              DICNOMNS.RN%type; -- ������������ �� ��������� (1)
    NDEF_NOMEN_MODIF_1        NOMMODIF.RN%type; -- ����������� ������������ �� ��������� (1)
    NDEF_NOMEN_2              DICNOMNS.RN%type; -- ������������ �� ��������� (2)
    NDEF_NOMEN_MODIF_2        NOMMODIF.RN%type; -- ����������� ������������ �� ��������� (2)
    NDEF_NOMEN_3              DICNOMNS.RN%type; -- ������������ �� ��������� (3)
    NDEF_NOMEN_MODIF_3        NOMMODIF.RN%type; -- ����������� ������������ �� ��������� (3)
  begin
    /* �������������� ��������� */
    RACK_LINE_CELL_CONFS := TRACK_LINE_CELL_CONFS();
    /* ���������� ������������ �� ��������� */
    FIND_DICNOMNS_BY_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SNOMEN_CODE => SDEF_NOMEN_1, NRN => NDEF_NOMEN_1);
    FIND_NOMMODIF_BY_CODE(NPRN => NDEF_NOMEN_1, SCODE => SDEF_NOMEN_MODIF_1, NFRN => NDEF_NOMEN_MODIF_1);
    FIND_DICNOMNS_BY_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SNOMEN_CODE => SDEF_NOMEN_2, NRN => NDEF_NOMEN_2);
    FIND_NOMMODIF_BY_CODE(NPRN => NDEF_NOMEN_2, SCODE => SDEF_NOMEN_MODIF_2, NFRN => NDEF_NOMEN_MODIF_2);
    FIND_DICNOMNS_BY_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SNOMEN_CODE => SDEF_NOMEN_3, NRN => NDEF_NOMEN_3);
    FIND_NOMMODIF_BY_CODE(NPRN => NDEF_NOMEN_3, SCODE => SDEF_NOMEN_MODIF_3, NFRN => NDEF_NOMEN_MODIF_3);
    /* ������� ����� */
    for I in 1 .. NRACK_LINES
    loop
      /* ������� ������ ����� */
      for J in 1 .. NRACK_LINE_CELLS
      loop
        /* ������� ������ � ��������� */
        RACK_LINE_CELL_CONFS.EXTEND();
        /* ������������� ������ ������ ������������ ����������� */
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NRACK_LINE := I;
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NRACK_LINE_CELL := J;
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SPREF := RACK_LINE_CELL_BUILD_PREF(NRACK_LINE => I,
                                                                                           SPREF_TMPL => SRACK_CELL_PREF_TMPL);
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNUMB := RACK_LINE_CELL_BUILD_NUMB(NRACK_LINE_CELL => J,
                                                                                           SNUMB_TMPL      => SRACK_CELL_NUMB_TMPL);
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNAME := RACK_LINE_CELL_BUILD_NAME(SPREF => RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST)
                                                                                                    .SPREF,
                                                                                           SNUMB => RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST)
                                                                                                    .SNUMB);
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NCAPACITY := NRACK_CELL_CAPACITY;
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NSHIP_CNT := NRACK_CELL_SHIP_CNT;
        FIND_STPLCELLS_NUMB(NFLAG_SMART  => 0,
                            NFLAG_OPTION => 0,
                            NCOMPANY     => NCOMPANY,
                            NSTORE       => null,
                            SSTORE       => SSTORE,
                            SCELL        => RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNAME,
                            NRN          => RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NRACK_CELL);
        /* ������������� ������ ��������������� ����������� �������� */
        case
          /* 1 - 1 */
          when (I = 1) and (J = 1) then
            begin
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMEN := NDEF_NOMEN_1;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMEN := SDEF_NOMEN_1;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMMODIF := NDEF_NOMEN_MODIF_1;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMMODIF := SDEF_NOMEN_MODIF_1;
            end;
          /* 1 - 2 */
          when (I = 1) and (J = 2) then
            begin
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMEN := NDEF_NOMEN_2;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMEN := SDEF_NOMEN_2;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMMODIF := NDEF_NOMEN_MODIF_2;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMMODIF := SDEF_NOMEN_MODIF_2;
            end;
          /* 1 - 3 */
          when (I = 1) and (J = 3) then
            begin
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMEN := NDEF_NOMEN_3;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMEN := SDEF_NOMEN_3;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMMODIF := NDEF_NOMEN_MODIF_3;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMMODIF := SDEF_NOMEN_MODIF_3;
            end;
          /* ����������� ������ */
          else
            P_EXCEPTION(0,
                        '����������� ������ �%s � ����� �%s - �� ���� ������ ������������!',
                        TO_CHAR(J),
                        TO_CHAR(I));
        end case;
      end loop;
    end loop;
  end;
  
  /* ������������� ������������ ����������� ������ */
  procedure STAND_INIT_RACK_NOMEN_CONF is
  begin
    /* ��������������� ��������� �������� ����������� */
    RACK_NOMEN_CONFS := TRACK_NOMEN_CONFS();
    /* ������� ������������ ����� ������ ��� ���� ��� �� ������������ ��������� �������� ����������� */
    if ((RACK_LINE_CELL_CONFS is not null) and (RACK_LINE_CELL_CONFS.COUNT > 0)) then
      /* �������� ��������� �������� ����������� ����, ������� ������� � ������� */
      declare
        BADD boolean := false;
      begin
        /* ���� �� �� ������������������ ����� ������� */
        for I in RACK_LINE_CELL_CONFS.FIRST .. RACK_LINE_CELL_CONFS.LAST
        loop
          BADD := true;
          if (RACK_NOMEN_CONFS.COUNT > 0) then
            /* ���� � ��������� �������� �����������... */
            for J in RACK_NOMEN_CONFS.FIRST .. RACK_NOMEN_CONFS.LAST
            loop
              /* ...����� ��, ��� � ������ */
              if (RACK_NOMEN_CONFS(J).NNOMMODIF = RACK_LINE_CELL_CONFS(I).NNOMMODIF) then
                /* ����� ���� - �������� �������� �� ������ ���������� (�� ������ ����������� ���������) */
                BADD := false;
                RACK_NOMEN_CONFS(J).NMAX_QUANT := RACK_NOMEN_CONFS(J).NMAX_QUANT + RACK_LINE_CELL_CONFS(I).NCAPACITY;
              end if;
            end loop;
          end if;
          /* ������������ ��� � ������ ��� ��� � ��������� �������� - ������ ������� � */
          if (BADD) then
            RACK_NOMEN_CONFS.EXTEND();
            RACK_NOMEN_CONFS(RACK_NOMEN_CONFS.LAST).SNOMEN := RACK_LINE_CELL_CONFS(I).SNOMEN;
            RACK_NOMEN_CONFS(RACK_NOMEN_CONFS.LAST).NNOMEN := RACK_LINE_CELL_CONFS(I).NNOMEN;
            RACK_NOMEN_CONFS(RACK_NOMEN_CONFS.LAST).SNOMMODIF := RACK_LINE_CELL_CONFS(I).SNOMMODIF;
            RACK_NOMEN_CONFS(RACK_NOMEN_CONFS.LAST).NNOMMODIF := RACK_LINE_CELL_CONFS(I).NNOMMODIF;
            RACK_NOMEN_CONFS(RACK_NOMEN_CONFS.LAST).NMAX_QUANT := RACK_LINE_CELL_CONFS(I).NCAPACITY;
            begin
              select MU.RN,
                     MU.MEAS_MNEMO
                into RACK_NOMEN_CONFS(RACK_NOMEN_CONFS.LAST).NMEAS,
                     RACK_NOMEN_CONFS(RACK_NOMEN_CONFS.LAST).SMEAS
                from DICNOMNS DN,
                     DICMUNTS MU
               where DN.RN = RACK_LINE_CELL_CONFS(I).NNOMEN
                 and DN.UMEAS_MAIN = MU.RN;
            exception
              when others then
                P_EXCEPTION(0,
                            '�� ������� ���������� �������� �� ��� ������������ "%s" (RN: %s)!',
                            RACK_LINE_CELL_CONFS(I).SNOMEN,
                            TO_CHAR(RACK_LINE_CELL_CONFS(I).NNOMEN));
            end;          
          end if;
        end loop;
      end;
      /* ��������, ��� ���� ���� ���-�� � ����� ������������ */
      if (RACK_NOMEN_CONFS.COUNT = 0) then
        P_EXCEPTION(0,
                    '�� ������� ���������� ������������ ����������� ������!');
      end if;
    /* ��� �������� ���� �������� ������ */
    else
      P_EXCEPTION(0, '����� �������� ������ ��� �� ����������������!');
    end if;
  end;
  
  /* ������������� ������������ ������ */
  procedure STAND_INIT_RACK_CONF
  (
    NCOMPANY                number,     -- ��������������� ����� ����������� 
    SSTORE                  varchar2    -- �������� ������ ������
  ) is
  begin
    /* �������������� ����� �������� */
    STAND_INIT_RACK_LINE_CELL_CONF(NCOMPANY => NCOMPANY, SSTORE => SSTORE);
    /* �������������� ������������ �������� */
    STAND_INIT_RACK_NOMEN_CONF();
  end;
  
  /* ��������� ������������ ������ ������ */
  function STAND_GET_RACK_LINE_CELL_CONF
  (
    NRACK_LINE              number,     -- ����� ����� �������� ������
    NRACK_LINE_CELL         number      -- ����� ������ � ����� �������� ������
  ) return TRACK_LINE_CELL_CONF is
  begin
    /* ������� ������������ ����� ������ � ������� ������ */
    if ((RACK_LINE_CELL_CONFS is not null) and (RACK_LINE_CELL_CONFS.COUNT > 0)) then
      for I in RACK_LINE_CELL_CONFS.FIRST .. RACK_LINE_CELL_CONFS.LAST
      loop
        /* ���� ������� ������ ������... */
        if ((RACK_LINE_CELL_CONFS(I).NRACK_LINE = NRACK_LINE) and
           (RACK_LINE_CELL_CONFS(I).NRACK_LINE_CELL = NRACK_LINE_CELL)) then
          /* ...����� � */
          return RACK_LINE_CELL_CONFS(I);
        end if;
      end loop;
    else
      P_EXCEPTION(0, '�� ������ ������������ ����� ������!');
    end if;
    /* ���� �� ����� - �� �������� ������ �� ����� */
    P_EXCEPTION(0,
                '��� ������ �%s ����� �%s ������ ������������ �� ����������!',
                TO_CHAR(NRACK_LINE_CELL),
                TO_CHAR(NRACK_LINE));
  end;
  
  /* ��������� ������������ ������������ ������ (�� ���. ������ �����������) */
  function STAND_GET_RACK_NOMEN_CONF
  (
    NNOMMODIF               number      -- ��������������� ����� ����������� ������������
  ) return TRACK_NOMEN_CONF is
  begin
    /* ������� ������������ ����������� ������ � ������� ������ */
    if ((RACK_NOMEN_CONFS is not null) and (RACK_NOMEN_CONFS.COUNT > 0)) then
      for I in RACK_NOMEN_CONFS.FIRST .. RACK_NOMEN_CONFS.LAST
      loop
        /* ���� ������� ������ ������������... */
        if (RACK_NOMEN_CONFS(I).NNOMMODIF = NNOMMODIF) then
          /* ...����� � */
          return RACK_NOMEN_CONFS(I);
        end if;
      end loop;
    else
      P_EXCEPTION(0, '�� ������ ������������ ������������ ������!');
    end if;
    /* ���� �� ����� - �� �������� ������ �� ����� */
    P_EXCEPTION(0,
                '��� ����������� ������������ (RN: %s) ������������ �� ����������!',
                TO_CHAR(NNOMMODIF));
  end;

  /* ��������� ������������ ������������ ������ (�� ��������� ������������ � �����������) */
  function STAND_GET_RACK_NOMEN_CONF
  (
    SNOMEN                  varchar2,   -- �������� ������������
    SNOMMODIF               varchar2    -- �������� ����������� ������������
  ) return TRACK_NOMEN_CONF is
  begin
    /* ������� ������������ ����������� ������ � ������� ������ */
    if ((RACK_NOMEN_CONFS is not null) and (RACK_NOMEN_CONFS.COUNT > 0)) then
      for I in RACK_NOMEN_CONFS.FIRST .. RACK_NOMEN_CONFS.LAST
      loop
        /* ���� ������� ������ ������������... */
        if ((RACK_NOMEN_CONFS(I).SNOMEN = SNOMEN) and (RACK_NOMEN_CONFS(I).SNOMMODIF = SNOMMODIF)) then
          /* ...����� � */
          return RACK_NOMEN_CONFS(I);
        end if;
      end loop;
    else
      P_EXCEPTION(0, '�� ������ ������������ ������������ ������!');
    end if;
    /* ���� �� ����� - �� �������� ������ �� ����� */
    P_EXCEPTION(0,
                '��� ����������� "%s" ������������ "%s" ������������ �� ����������!',
                SNOMMODIF,
                SNOMEN);
  end;


  /* ��������� �������� �������� ������ �� ������������� */
  function STAND_GET_RACK_NOMEN_REST
  (
    NCOMPANY                number,             -- ��������������� ����� �����������
    SSTORE                  varchar2,           -- �������� ������ ������
    SPREF                   varchar2,           -- ������� �������� ������
    SNUMB                   varchar2,           -- ����� �������� ������
    SCELL                   varchar2 := null,   -- ������������ (�������-�����) ������ �������� (null - �� ����)
    SNOMEN                  varchar2 := null,   -- ������������ (null - �� ����)
    SNOMEN_MODIF            varchar2 := null    -- ����������� (null - �� ����)
  ) return TNOMEN_RESTS is
    NSTORE                  PKG_STD.TREF;       -- ���. ����� ������
    NRACK                   PKG_STD.TREF;       -- ���. ����� ��������
    NCELL                   PKG_STD.TREF;       -- ���. ����� ������
    BADD                    boolean;            -- ���� ������������� ���������� ������������ � ���������
    N                       PKG_STD.TNUMBER;    -- ���������� ����� ������������ � �������������� ���������
    NREST                   PKG_STD.TLNUMBER;   -- ������� �� ������� ������������ � ������� ����� ��������
    NTMP                    PKG_STD.TLNUMBER;   -- ����� ��� ���������
    RES                     TNOMEN_RESTS;       -- ��������� ������
    /* ���������� ������������ � �������������� ��������� */
    procedure ADD_NOMEN
    (
      SNOMEN                varchar2,           -- �������� ����������� ������������
      SNOMEN_MODIF          varchar2,           -- �������� ����������� ����������� ������������
      ARR                   in out TNOMEN_RESTS -- ��������� ��� ����������
    ) is
      NOMEN_CONF            TRACK_NOMEN_CONF;   -- ������������ ������������ ������
    begin
      /* �������������� ���������, ���� ���� */
      if (ARR is null) then
        ARR := TNOMEN_RESTS();
      end if;
      /* ����� ������������ � ������������ ������ */
      NOMEN_CONF := STAND_GET_RACK_NOMEN_CONF(SNOMEN => SNOMEN, SNOMMODIF => SNOMEN_MODIF);
      /* ������� ������� � ��������� */
      ARR.EXTEND();
      ARR(ARR.LAST).NNOMEN := NOMEN_CONF.NNOMEN;
      ARR(ARR.LAST).SNOMEN := NOMEN_CONF.SNOMEN;
      ARR(ARR.LAST).NNOMMODIF := NOMEN_CONF.NNOMMODIF;
      ARR(ARR.LAST).SNOMMODIF := NOMEN_CONF.SNOMMODIF;
      ARR(ARR.LAST).NREST := 0;
      ARR(ARR.LAST).NMEAS := NOMEN_CONF.NMEAS;
      ARR(ARR.LAST).SMEAS := NOMEN_CONF.SMEAS;
    end;
  begin
    /* �������� ��������� */
    if (((SNOMEN is null) and (SNOMEN_MODIF is not null)) or ((SNOMEN is not null) and (SNOMEN_MODIF is null))) then
      P_EXCEPTION(0,
                  '����������� ������������� �������� ������������ � �����������!');
    end if;
    /* ����� ���. ����� ������ */
    FIND_DICSTORE_NUMB(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SNUMB => SSTORE, NRN => NSTORE);
    /* ������ ���. ����� �������� */
    P_STPLRACKS_FIND(NFLAG_SMART => 0,
                     NCOMPANY    => NCOMPANY,
                     SSTORE      => SSTORE,
                     SPREF       => SPREF,
                     SNUMB       => SNUMB,
                     NRN         => NRACK);
    /* ����� ���. ����� ������ */
    FIND_STPLCELLS_NUMB(NFLAG_SMART  => 0,
                        NFLAG_OPTION => 1,
                        NCOMPANY     => NCOMPANY,
                        NSTORE       => NSTORE,
                        SSTORE       => SSTORE,
                        SCELL        => SCELL,
                        NRN          => NCELL);
    /* �������������� ����� */
    RES := TNOMEN_RESTS();
    /* ���� ������������ ������ - �� ����� ������� � � ��������� (��������� ������ ������ ���� � ���������, ���� ���� �������� ���) */
    if ((SNOMEN is not null) and (SNOMEN_MODIF is not null)) then
      ADD_NOMEN(SNOMEN => SNOMEN, SNOMEN_MODIF => SNOMEN_MODIF, ARR => RES);
    end if;
    /* ������� ������� ����������� �� ������ �������� */
    for NMNS in (select DN.RN NNOMEN,
                        DN.NOMEN_CODE SNOMEN,
                        NM.RN NNOMMODIF,
                        NM.MODIF_CODE SNOMMODIF,
                        RACK_LINE_CELL_BUILD_NAME(SPREF => C.PREF, SNUMB => C.NUMB) SCELL
                   from STPLGOODSSUPPLY SG,
                        GOODSSUPPLY     G,
                        GOODSPARTIES    GP,
                        STPLRACKS       R,
                        STPLCELLS       C,
                        INCOMDOC        IND,
                        DICNOMNS        DN,
                        NOMMODIF        NM
                  where G.COMPANY = NCOMPANY
                    and G.STORE = NSTORE
                    and G.RN = SG.GOODSSUPPLY
                    and R.RN = NRACK
                    and R.RN = C.PRN
                    and C.RN = SG.CELL
                    and G.PRN = GP.RN
                    and GP.INDOC = IND.RN
                    and IND.CODE = SDEF_STORE_PARTY
                    and GP.NOMMODIF = NM.RN
                    and NM.PRN = DN.RN
                    and ((NCELL is null) or ((NCELL is not null) and (C.RN = NCELL)))
                    and ((SNOMEN is null) or ((SNOMEN is not null) and (DN.NOMEN_CODE = SNOMEN)))
                    and ((SNOMEN_MODIF is null) or ((SNOMEN_MODIF is not null) and (NM.MODIF_CODE = SNOMEN_MODIF)))
                  group by DN.RN,
                           DN.NOMEN_CODE,
                           NM.RN,
                           NM.MODIF_CODE,
                           RACK_LINE_CELL_BUILD_NAME(SPREF => C.PREF, SNUMB => C.NUMB))
    loop
      /* ��������� ����� ������������ � ��������� */
      BADD := true;
      if (RES.COUNT > 0) then
        for I in RES.FIRST .. RES.LAST
        loop
          /* ���� ����� ��� ����... */
          if (RES(I).NNOMMODIF = NMNS.NNOMMODIF) then
            /* ...������ ��� �� ���� ��������� � �������� � ����� - ���� ����� ������ ������� */
            BADD := false;
            N    := I;
            exit;
          end if;
        end loop;
      end if;
      /* ������� ������������ � ���������, ���� ���� */
      if (BADD) then
        ADD_NOMEN(SNOMEN => SNOMEN, SNOMEN_MODIF => SNOMEN_MODIF, ARR => RES);
        /* �������� ����� ������ �������� - ���� ����������� ������� */
        N := RES.LAST;
      end if;
      /* �������� ������� �� ������ ������������ */
      P_STPLGOODSSUPPLY_GETREST(NFLAG_SMART   => 0,
                                NCOMPANY      => NCOMPANY,
                                SSTORE        => SSTORE,
                                SCELL         => NMNS.SCELL,
                                SNOMEN        => NMNS.SNOMEN,
                                SNOMMODIF     => NMNS.SNOMMODIF,
                                SNOMMODIFPACK => null,
                                SINDOC        => SDEF_STORE_PARTY,
                                SSERNUMB      => null,
                                SCOUNTRY      => null,
                                SGTD          => null,
                                NQUANT        => NREST,
                                NQUANTALT     => NTMP,
                                NQUANTPACK    => NTMP);
      /* ������� ������� */
      RES(N).NREST := NREST + RES(N).NREST;
    end loop;
    /* ������ ��������� */
    return RES;
  end;

  /* ��������� �������� �������� ������ �� ������ �������� */
  function STAND_GET_RACK_REST
  (
    NCOMPANY                number,               -- ��������������� ����� �����������
    SSTORE                  varchar2,             -- �������� ������ ������
    SPREF                   varchar2,             -- ������� �������� ������
    SNUMB                   varchar2              -- ����� �������� ������
  ) return TRACK_REST is
    CELL_CONF               TRACK_LINE_CELL_CONF; -- ������������ ������ (����� ��������) ������
    RES                     TRACK_REST;           -- ��������� ������
  begin
    /* ������� ������� � �������������� ��������� */
    begin
      select T.RN,
             T.STORE,
             S.AZS_NUMBER,
             trim(T.PREF),
             trim(T.NUMB),
             RACK_BUILD_NAME(SPREF => T.PREF, SNUMB => T.NUMB),
             NRACK_LINES
        into RES.NRACK,
             RES.NSTORE,
             RES.SSTORE,
             RES.SRACK_PREF,
             RES.SRACK_NUMB,
             RES.SRACK_NAME,
             RES.NRACK_LINES_CNT
        from STPLRACKS    T,
             AZSAZSLISTMT S
       where T.COMPANY = NCOMPANY
         and T.STORE = S.RN
         and S.AZS_NUMBER = SSTORE
         and trim(T.PREF) = SPREF
         and trim(T.NUMB) = SNUMB;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0,
                    '������� "%s" �� ������ "%s" �� ��������!',
                    RACK_BUILD_NAME(SPREF => SPREF, SNUMB => SNUMB),
                    SSTORE);
    end;
    /* ������, ��� ������� ������ */
    RES.BEMPTY := true;
    /* �������������� ��������� ������ */
    RES.RACK_LINE_RESTS := TRACK_LINE_RESTS();
    /* ������� ����� (�������� ������������ ������) */
    for L in 1 .. RES.NRACK_LINES_CNT
    loop
      /* ������� ����� ���� */
      RES.RACK_LINE_RESTS.EXTEND();
      RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS := TRACK_LINE_CELL_RESTS();
      /* �������������� ��� */
      RES.RACK_LINE_RESTS(L).NRACK_LINE := L;
      RES.RACK_LINE_RESTS(L).NRACK_LINE_CELLS_CNT := NRACK_LINE_CELLS;
      /* ������ ��� ���� ������ */
      RES.RACK_LINE_RESTS(L).BEMPTY := true;
      /* ������� ������ ����� (�������� ������������ ������) */
      for C in 1 .. RES.RACK_LINE_RESTS(L).NRACK_LINE_CELLS_CNT
      loop
        /* ������� ������������ ������ ������ */
        CELL_CONF := STAND_GET_RACK_LINE_CELL_CONF(NRACK_LINE => L, NRACK_LINE_CELL => C);
        /* ������� ������ � ���� */
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS.EXTEND();
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS := TNOMEN_RESTS();
        /* ����������������� ������ */
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_CELL := CELL_CONF.NRACK_CELL;
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_PREF := CELL_CONF.SPREF;
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_NUMB := CELL_CONF.SNUMB;
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_NAME := CELL_CONF.SNAME;
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_LINE := CELL_CONF.NRACK_LINE;
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_LINE_CELL := CELL_CONF.NRACK_LINE_CELL;
        /* ������ ��� ������ ������ */
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).BEMPTY := true;
        /* ������ �������� ������ ��������� ������������ (������ �������� ������������ ������) */
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS := STAND_GET_RACK_NOMEN_REST(NCOMPANY     => NCOMPANY,
                                                                                                SSTORE       => RES.SSTORE,
                                                                                                SPREF        => RES.SRACK_PREF,
                                                                                                SNUMB        => RES.SRACK_NUMB,
                                                                                                SCELL        => RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C)
                                                                                                                .SRACK_CELL_NAME,
                                                                                                SNOMEN       => CELL_CONF.SNOMEN,
                                                                                                SNOMEN_MODIF => CELL_CONF.SNOMMODIF);
        /* ���� ����� �� ������������ �� �������, �� �������� ������, ����� � �������� ���� ������������� */
        if (RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS.COUNT > 0) then
          for N in RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS.FIRST .. RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C)
                                                                                       .NOMEN_RESTS.LAST
          loop
            if (RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS(N).NREST <> 0) then
              RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).BEMPTY := false;
              RES.RACK_LINE_RESTS(L).BEMPTY := false;
              RES.BEMPTY := false;
              exit;
            end if;
          end loop;
        end if;
      end loop;
    end loop;
    /* ������ ��������� */
    return RES;
  end;
  
  /* ����� �����������-���������� ������ �� ��������� */
  function STAND_GET_AGENT_BY_BARCODE
  (
    NCOMPANY                number,             -- ��������������� ����� �����������
    SBARCODE                varchar2            -- ��������
  ) return TSTAND_USER is
    NVERSION                VERSIONS.RN%type;   -- ������ ������� "�����������"
    NDP_BARCODE             DOCS_PROPS.RN%type; -- ��������������� ����� ��������������� �������� ��� �������� ���������
    RES                     TSTAND_USER;        -- ��������� ������
  begin
    /* ��������� ������ ������� "�����������" */
    FIND_VERSION_BY_COMPANY(NCOMPANY => NCOMPANY, SUNITCODE => 'AGNLIST', NVERSION => NVERSION);  
    /* ��������� ��������������� ����� ��������������� �������� ��� �������� ��������� */
    FIND_DOCS_PROPS_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SCODE => SDP_BARCODE, NRN => NDP_BARCODE);  
    /* ������ ����������� � ��������� ���������� */
    begin
      select AG.RN,
             AG.AGNABBR,
             AG.AGNNAME
        into RES.NAGENT,
             RES.SAGENT,
             RES.SAGENT_NAME
        from AGNLIST AG
       where AG.VERSION = NVERSION
         and F_DOCS_PROPS_GET_STR_VALUE(NPROPERTY => NDP_BARCODE, SUNITCODE => 'AGNLIST', NDOCUMENT => AG.RN) =
             SBARCODE;
    exception
      when TOO_MANY_ROWS then
        P_EXCEPTION(0,
                    '������� ����� ������ ����������� �� ���������� "%s"!',
                    SBARCODE);
      when NO_DATA_FOUND then
        P_EXCEPTION(0, '���������� �� ���������� "%s" �� ��������!', SBARCODE);
    end;  
    /* ������ ��������� */
    return RES;
  end;
  
  /* ��������� ��������� ������ */
  procedure STAND_GET_STATE
  (
    NCOMPANY                number,                -- ��������������� ����� �����������
    STAND_STATE             out TSTAND_STATE       -- ��������� ������
  ) is
    RESTS_HIST_TMP          TMESSAGES;             -- ����� ��� ������� ��������
    NREST_PRC_TOTAL         PKG_STD.TLNUMBER := 0; -- ����� ��� % �������� �����������
    NR_TMP                  TNOMEN_RESTS;          -- ����� ��� �������� ������������ ������
    N                       PKG_STD.TNUMBER;       -- ������ ������� �������
  begin
    /* ����������� ����������� ������� �� ������ (� %) */
    STAND_STATE.NRESTS_LIMIT_PRC_MIN := NRESTS_LIMIT_PRC_MIN;
    /* ������� ����������� ������� �� ������ (� %) */
    STAND_STATE.NRESTS_LIMIT_PRC_MDL := NRESTS_LIMIT_PRC_MDL;
    /* ������������ ����������� ������ */
    STAND_STATE.NOMEN_CONFS := RACK_NOMEN_CONFS;
    /* ������� ����������� ������ ����� % ������� ����������� �� ������������� ������ �������� */
    STAND_STATE.NOMEN_RESTS := TNOMEN_RESTS();
    if ((RACK_NOMEN_CONFS is not null) and (RACK_NOMEN_CONFS.COUNT > 0)) then
      for I in RACK_NOMEN_CONFS.FIRST .. RACK_NOMEN_CONFS.LAST
      loop
        NR_TMP := STAND_GET_RACK_NOMEN_REST(NCOMPANY     => NCOMPANY,
                                            SSTORE       => SSTORE_GOODS,
                                            SPREF        => SRACK_PREF,
                                            SNUMB        => SRACK_NUMB,
                                            SNOMEN       => RACK_NOMEN_CONFS(I).SNOMEN,
                                            SNOMEN_MODIF => RACK_NOMEN_CONFS(I).SNOMMODIF);
        if (NR_TMP.COUNT > 0) then
          for J in NR_TMP.FIRST .. NR_TMP.LAST
          loop
            /* �������� ������� ������������ */
            STAND_STATE.NOMEN_RESTS.EXTEND();
            STAND_STATE.NOMEN_RESTS(STAND_STATE.NOMEN_RESTS.LAST) := NR_TMP(J);
            /* ��� �� ���������� ����� % ������� ������ ������������ �� ������������� ������ �������� */
            NREST_PRC_TOTAL := NREST_PRC_TOTAL + NR_TMP(J).NREST / RACK_NOMEN_CONFS(I).NMAX_QUANT * 100;
          end loop;
        end if;
      end loop;
    else
      P_EXCEPTION(0, '����� �� ���������������!');
    end if;
    /* ������� ������������� ������ (%) */
    STAND_STATE.NRESTS_PRC_CURR := ROUND(NREST_PRC_TOTAL / (RACK_NOMEN_CONFS.COUNT * 100) * 100, 0);
    /* ������� �������� ����������� ������ */
    STAND_STATE.RACK_REST_PRC_HISTS := TRACK_REST_PRC_HISTS();
    RESTS_HIST_TMP                  := MSG_GET_LIST(DFROM  => null,
                                                    STP    => SMSG_TYPE_REST_PRC,                                                    
                                                    NLIMIT => 10,
                                                    NORDER => NMSG_ORDER_DESC);
    for I in 1 .. 10
    loop
      STAND_STATE.RACK_REST_PRC_HISTS.EXTEND();
      if (RESTS_HIST_TMP.COUNT > 0) then
        if (RESTS_HIST_TMP.EXISTS(I)) then
          N := I;
        else
          N := RESTS_HIST_TMP.LAST;
        end if;
        STAND_STATE.RACK_REST_PRC_HISTS(STAND_STATE.RACK_REST_PRC_HISTS.LAST).DTS := RESTS_HIST_TMP(N).DTS;
        STAND_STATE.RACK_REST_PRC_HISTS(STAND_STATE.RACK_REST_PRC_HISTS.LAST).STS := RESTS_HIST_TMP(N).STS;
        begin
          STAND_STATE.RACK_REST_PRC_HISTS(STAND_STATE.RACK_REST_PRC_HISTS.LAST).NREST_PRC := TO_NUMBER(RESTS_HIST_TMP(N).SMSG);
        exception
          when others then
            STAND_STATE.RACK_REST_PRC_HISTS(STAND_STATE.RACK_REST_PRC_HISTS.LAST).NREST_PRC := 0;
        end;      
      else
        STAND_STATE.RACK_REST_PRC_HISTS(STAND_STATE.RACK_REST_PRC_HISTS.LAST).DTS := null;
        STAND_STATE.RACK_REST_PRC_HISTS(STAND_STATE.RACK_REST_PRC_HISTS.LAST).STS := null;
        STAND_STATE.RACK_REST_PRC_HISTS(STAND_STATE.RACK_REST_PRC_HISTS.LAST).NREST_PRC := 0;
      end if;
    end loop;
    /* ������� �� ������ �������� ������ */
    STAND_STATE.RACK_REST := STAND_GET_RACK_REST(NCOMPANY => NCOMPANY,
                                                 SSTORE   => SSTORE_GOODS,
                                                 SPREF    => SRACK_PREF,
                                                 SNUMB    => SRACK_NUMB);
    /* ��������� ������ */
    STAND_STATE.MESSAGES := MSG_GET_LIST(DFROM  => null,
                                         STP    => SMSG_TYPE_NOTIFY,
                                         NLIMIT => 10,
                                         NORDER => NMSG_ORDER_DESC);
  end;
  
  /* ���������� ������� �������� �� ������ */
  procedure STAND_SAVE_RACK_REST
  (
    NCOMPANY                number,                -- ��������������� ����� ������������
    BNOTIFY_REST            boolean,               -- ���� ���������� � ������� �������
    BNOTIFY_LIMIT           boolean                -- ���� ���������� � ����������� �������� �������
  ) is
    NREST_PRC_TOTAL         PKG_STD.TLNUMBER := 0; -- ����� ��� % �������� �����������
    SRESTS                  PKG_STD.TLSTRING;      -- ������ �������� ��� ���������
    NR_TMP                  TNOMEN_RESTS;          -- ����� ��� �������� ������������ ������
    NR                      TNOMEN_RESTS;          -- ������� ������� ������������ ������
  begin
    /* �������������� �������� ��������� �������� */
    NR := TNOMEN_RESTS();
    /* ������� ������� �� ������ (�� ���� �������������, ������� � �� ������ ���������) */
    if ((RACK_NOMEN_CONFS is not null) and (RACK_NOMEN_CONFS.COUNT > 0)) then
      for I in RACK_NOMEN_CONFS.FIRST .. RACK_NOMEN_CONFS.LAST
      loop
        NR_TMP := STAND_GET_RACK_NOMEN_REST(NCOMPANY     => NCOMPANY,
                                            SSTORE       => SSTORE_GOODS,
                                            SPREF        => SRACK_PREF,
                                            SNUMB        => SRACK_NUMB,
                                            SNOMEN       => RACK_NOMEN_CONFS(I).SNOMEN,
                                            SNOMEN_MODIF => RACK_NOMEN_CONFS(I).SNOMMODIF);
        if (NR_TMP.COUNT > 0) then
          for J in NR_TMP.FIRST .. NR_TMP.LAST
          loop
            /* ������� ������� � ��������� */
            NR.EXTEND();
            NR(NR.LAST) := NR_TMP(J);
            /* ��������� ����� % ������� ����������� �� ������ ������ �������� � �������� ��������� ��� �������� */
            NREST_PRC_TOTAL := NREST_PRC_TOTAL + NR(NR.LAST).NREST / RACK_NOMEN_CONFS(I).NMAX_QUANT * 100;
            SRESTS          := SRESTS || NR(NR.LAST).SNOMMODIF || ' - ' || NR(NR.LAST).NREST || '; ';
          end loop;
        end if;
      end loop;
    else
      P_EXCEPTION(0, '����� �� ���������������!');
    end if;
    if (NR.COUNT = 0) then
      P_EXCEPTION(0, '�� ������� ���������� ������� ����������� ������!');
    end if;
    /* ������������ ������� ������������ ������������ ����������� �������� */
    NREST_PRC_TOTAL := ROUND(NREST_PRC_TOTAL / (RACK_NOMEN_CONFS.COUNT * 100) * 100, 0);
    /* �������� ������� �� ������ */
    MSG_INSERT_RESTS(SMSG => UDO_PKG_STAND_WEB.STAND_RACK_NOMEN_RESTS_TO_JSON(NR => NR).TO_CHAR());
    MSG_INSERT_REST_PRC(SMSG => NREST_PRC_TOTAL);
    /* ���� ������� ���������� �� �������� � �������� */
    if (BNOTIFY_REST) then
      if (NREST_PRC_TOTAL = 0) then
        MSG_INSERT_NOTIFY(SMSG         => '�� ������ ������ ��� ������',
                          SNOTIFY_TYPE => SNOTIFY_TYPE_ERROR);
      else
        MSG_INSERT_NOTIFY(SMSG         => '����� �������� �� ' || TO_CHAR(NREST_PRC_TOTAL) ||
                                          '%. ������� ������� �� ������: ' || SRESTS,
                          SNOTIFY_TYPE => SNOTIFY_TYPE_INFO);
      end if;
    end if;
    /* ���� ������� ���������� � ����������� �������� ������� */
    if (BNOTIFY_LIMIT) then
      /* ���������, ���� ��� ���� ������������ ������ ��� �� ��� ������ */
      if (NREST_PRC_TOTAL = 0) then
        MSG_INSERT_NOTIFY(SMSG         => '�� ������ ������ ��� ������! ��������� �����!',
                          SNOTIFY_TYPE => SNOTIFY_TYPE_ERROR);
      else
        if (NREST_PRC_TOTAL < NRESTS_LIMIT_PRC_MIN) then
          MSG_INSERT_NOTIFY(SMSG         => '������� ������������� ������ ' || TO_CHAR(NREST_PRC_TOTAL) ||
                                            '% ���� ����������� ������� � ' || TO_CHAR(NRESTS_LIMIT_PRC_MIN) ||
                                            '%! ������������� ��������� �����!',
                            SNOTIFY_TYPE => SNOTIFY_TYPE_WARN);
        end if;
      end if;
    end if;
  end;
  
  /* �������� ������������� ������ �����������-���������� ������ �� ������ (��. ��������� NAGN_SUPPLY_*) */
  function STAND_CHECK_SUPPLY
  (
    NCOMPANY                number,          -- ��������������� ����� �����������
    NAGENT                  number           -- ��������������� ����� �����������
  ) return number is
    NRES                    PKG_STD.TNUMBER; -- ��������� ������
  begin
    /* ������� ����� ������� � ������ ������������, �� ������ ������, � ������������� ������, � ����� � ��������� �� ��������� ��� ������ */
    begin
      select count(*)
        into NRES
        from TRANSINVCUST      T,
             DOCTYPES          DT,
             AZSAZSLISTMT      ST
       where T.COMPANY = NCOMPANY
         and trim(T.PREF) = STRINVCUST_PREF
         and T.DOCTYPE = DT.RN
         and DT.DOCCODE = STRINVCUST_TYPE
         and T.AGENT = NAGENT
         and T.STORE = ST.RN
         and ST.AZS_NUMBER = SSTORE_GOODS;
    exception
      when others then
        P_EXCEPTION(0,
                    '������ ������ ��������� ��������� �� ������ ������������ ��� ����������� (RN: %s)!',
                    TO_CHAR(NAGENT));
    end;    
    /* ����� ���... */
    if (NRES = 0) then
      /* ...������ �� ��������� ������� ����������� */
      NRES := NAGN_SUPPLY_NOT_YET;
    else
      /* ...��� ���� � ����� - ��������� */
      NRES := NAGN_SUPPLY_ALREADY;
    end if;  
    /* ������ ��������� */
    return NRES;
  end;  
  
  /* �������������� ���������� ������ �� ��������� */
  procedure STAND_AUTH_BY_BARCODE
  (
    NCOMPANY                number,          -- ��������������� ����� �����������
    SBARCODE                varchar2,        -- ��������    
    STAND_USER              out TSTAND_USER, -- �������� � ������������ ������
    RACK_REST               out TRACK_REST   -- �������� �� �������� �� ������
  ) is
  begin
    /* ������ ����������� �� ��������� */
    STAND_USER := STAND_GET_AGENT_BY_BARCODE(NCOMPANY => NCOMPANY, SBARCODE => SBARCODE);
    /* ��������, ��� �������� ������� ����������� ��� �� ���� (���� ����, �������) */
    if ((NALLOW_MULTI_SUPPLY = NALLOW_MULTI_SUPPLY_NO) and (SBARCODE <> SGUEST_BASRCODE)) then
      if (STAND_CHECK_SUPPLY(NCOMPANY => NCOMPANY, NAGENT => STAND_USER.NAGENT) = NAGN_SUPPLY_ALREADY) then
        P_EXCEPTION(0,
                    '��������, �������� ��� ���������� "%s" ��� �������������!',
                    STAND_USER.SAGENT_NAME);
      end if;
    end if;
    /* ������� ������� �� ��������, ������� ����������� ����� */
    RACK_REST := STAND_GET_RACK_REST(NCOMPANY => NCOMPANY,
                                     SSTORE   => SSTORE_GOODS,
                                     SPREF    => SRACK_PREF,
                                     SNUMB    => SRACK_NUMB);
  end;
  
   /* ���������� ������ ���������� */
  procedure STAND_USER_CREATE  
  (
    NCOMPANY                number,                  -- ��������������� ����� �����������
    SAGNABBR                varchar2,                -- ������� � �������� ����������
    SAGNNAME                varchar2,                -- �������, ��� � �������� ����������
    SFULLNAME               varchar2                 -- ������������ ����������� ����������
  )
  as
     NVERSION                 VERSIONS.RN%type;        -- ������ ������� "�����������"
     nCRN                     ACATALOG.RN%type;        -- ������� ������� "�����������"
     nAGENT                   AGNLIST.RN%type;         -- ��������������� ����� ������ ����������
     NDP_BARCODE              DOCS_PROPS.RN%type;      -- ��������������� ����� ��������������� �������� ��� �������� ���������
     NDPV_BARCODE             DOCS_PROPS_VALS.RN%type; -- ��������������� ����� �������� ��������������� �������� ��� �������� ���������
     NBARDCODE                PKG_STD.tNUMBER;         -- �����-��� ������������
     
  begin
    /* ��������� ������ ������� "�����������" */
    FIND_VERSION_BY_COMPANY(NCOMPANY => NCOMPANY, SUNITCODE => 'AGNLIST', NVERSION => NVERSION);
    
    /* ��������� ��������������� ����� ��������������� �������� ��� �������� ��������� */
    FIND_DOCS_PROPS_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SCODE => SDP_BARCODE, NRN => NDP_BARCODE);

    /* ������ ������������ �������� ��������� */
    begin
      select max(TO_NUMBER(F_DOCS_PROPS_GET_STR_VALUE(NPROPERTY => NDP_BARCODE,
                                                      SUNITCODE => 'AGNLIST',
                                                      NDOCUMENT => AG.RN)))
        into NBARDCODE
        from AGNLIST AG
       where AG.VERSION = NVERSION
         and F_DOCS_PROPS_GET_STR_VALUE(NPROPERTY => NDP_BARCODE, SUNITCODE => 'AGNLIST', NDOCUMENT => AG.RN) is not null;
    end;

    /* �������� ����� �������� ���������*/
    if NBARDCODE is null or NBARDCODE < 1000 then
      /* ���� ������ 1000, �� �������� ������ � ������*/
      NBARDCODE := 1000;
    else
      /* ���� ������ 1000, �� ����� ��������� ��������*/
      NBARDCODE := NBARDCODE + 1;
    end if;
    
    /* ������ ������� � ������� "�����������" */
    FIND_ACATALOG_NAME(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       NVERSION    => NVERSION,
                       SUNITCODE   => 'AGNLIST',
                       SNAME       => '���������� ������',
                       NRN         => NCRN);
    /* ��������� ����������� ��� ���������� */
    P_AGNLIST_BASE_INSERT(NCOMPANY  => NCOMPANY,
                          NCRN      => NCRN,
                          SAGNABBR  => SAGNABBR,
                          SAGNNAME  => SAGNNAME,
                          SFULLNAME => SFULLNAME,
                          NRN       => NAGENT);
    /* ��������� ��������� ���������� */
    PKG_DOCS_PROPS_VALS.MODIFY(SPROPERTY   => SDP_BARCODE,
                               SUNITCODE   => 'AGNLIST',
                               NDOCUMENT   => NAGENT,
                               SSTR_VALUE  => NBARDCODE,
                               NNUM_VALUE  => null,
                               DDATE_VALUE => null,
                               NRN         => NDPV_BARCODE);
  end;

  /* �������� ������ ������� */
  procedure LOAD
  (
    NCOMPANY                number,                       -- ��������������� ����� ����������� 
    NRACK_LINE              number := null,               -- ����� ����� �������� ������ ��� �������� (null - ������� ���)
    NRACK_LINE_CELL         number := null,               -- ����� ������ � ����� �������� ������ ��� �������� (null - ������� ���)
    NINCOMEFROMDEPS         out number                    -- ��������������� ����� ��������������� "������� �� �������������"
  ) is
    /* ���� ������ */
    type TNOMEN is record                                 -- ������������ ��������
    (
      RACK_NOMEN_CONF       TRACK_NOMEN_CONF,             -- ������������ ������������ ������
      NINCOMEFROMDEPSSPEC   INCOMEFROMDEPSSPEC.RN%type    -- ���. ����� �������������� ������� ������������ "������� �� �������������" ��� ���� ������������
    );
    type TNOMENS is table of TNOMEN;                      -- ��������� ����������� ��������   
    /* ���������� */
    NCRN                    INCOMEFROMDEPS.RN%type;       -- ������� ���������� ���������� "������ �� �������������"
    NJUR_PERS               JURPERSONS.RN%type;           -- ��������������� ����� ������������ ���� "������� �� �������������" (�������� �� �����������)
    SJUR_PERS               JURPERSONS.CODE%type;         -- �������� ����� ������������ ���� "������� �� �������������" (�������� �� �����������)
    SDOC_NUMB               INCOMEFROMDEPS.DOC_NUMB%type; -- ����� ������������ "������� �� �������������"
    SOUT_DEPARTMENT         INS_DEPARTMENT.CODE%type;     -- �������������-����������� ������������ "������� �� �������������"
    SAGENT                  AGNLIST.AGNABBR%type;         -- ��� ������������ "������� �� �������������"
    SCURRENCY               CURNAMES.CURCODE%type;        -- ������ ������������ "������� �� �������������" (������� ������ �����������)
    NINCOMEFROMDEPSSPEC     INCOMEFROMDEPSSPEC.RN%type;   -- ���. ����� �������������� ������� ������������ "������� �� �������������"
    NSTRPLRESJRNL           STRPLRESJRNL.RN%type;         -- ���. ����� �������������� ������ �������������� �� ������ ��������
    CELL_CONF               TRACK_LINE_CELL_CONF;         -- ������������ ������ (����� ��������) ������
    NWARNING                PKG_STD.TREF;                 -- ���� �������������� ��������� ��������� �������
    SMSG                    PKG_STD.TSTRING;              -- ����� ��������� ��������� ��������� �������
    NOMENS                  TNOMENS;                      -- ��������� ����������� �����������
  begin
    /* ��������, ��� ����� ��������������� */
    if ((RACK_NOMEN_CONFS is null) or (RACK_NOMEN_CONFS.COUNT <= 0)) then
      P_EXCEPTION(0, '����� �� ���������������!');
    end if;
  
    /* �������� ��������� - ��������� ������ ����� ������ ������ ���� */
    if ((NRACK_LINE is null) and (NRACK_LINE_CELL is not null)) then
      P_EXCEPTION(0,
                  '��� �������� ������ ������ � ����� �������� ����������� ��������� � ���� ��������!');
    end if;
  
    /* ��������, ��� ��������� ���� �������� ���������� */
    if (NRACK_LINE is not null) then
      if (NRACK_LINE <> TRUNC(NRACK_LINE) or (NRACK_LINE not between 1 and NRACK_LINES)) then
        P_EXCEPTION(0, '����� ����� �������� ������ ������� �����������!');
      end if;
    end if;
  
    /* ��������, ��� ��������� ������ ����� ���������� � ���������������� */
    if ((NRACK_LINE is not null) and (NRACK_LINE_CELL is not null)) then
      CELL_CONF := STAND_GET_RACK_LINE_CELL_CONF(NRACK_LINE => NRACK_LINE, NRACK_LINE_CELL => NRACK_LINE_CELL);
    end if;
  
    /* ��������� ���. ����� �������� */
    FIND_ROOT_CATALOG(NCOMPANY => NCOMPANY, SCODE => 'IncomFromDeps', NCRN => NCRN);
  
    /* ��������� �������� ����������� ���� ����������� */
    FIND_JURPERSONS_MAIN(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SJUR_PERS => SJUR_PERS, NJUR_PERS => NJUR_PERS);
  
    /* ��������� ������� ������ */
    FIND_CURRENCY_BASE_NAME(NCOMPANY => NCOMPANY, SCODE => SCURRENCY, SISO => SCURRENCY);
  
    /* ��������� ������������� ������, � �������� ������������ ������� */
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
        P_EXCEPTION(0, '��� ������ "%s" �� ������� �������������!', SSTORE_PRODUCE);
    end;
  
    /* ��������� ��� ������-���������� */
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
                    '��� ������ "%s" �� ������� ����������� ������������� ����!',
                    SSTORE_PRODUCE);
    end;
  
    /* ��������������� ��������� ����������� ����������� */
    NOMENS := TNOMENS();
  
    /* ������� ������������ ����������� ������ ��� ���� ��� �� ������������ ��������� ����������� ����������� */
    for I in 1 .. NRACK_LINES
    loop
      if ((NRACK_LINE is null) or (((NRACK_LINE is not null)) and (NRACK_LINE = I))) then
        for J in 1 .. NRACK_LINE_CELLS
        loop
          if ((NRACK_LINE_CELL is null) or (((NRACK_LINE_CELL is not null)) and (NRACK_LINE_CELL = J))) then
            declare
              BADD boolean := false;
            begin
              /* ������� ������������ ������ �� ������� ���������� �������� */
              CELL_CONF := STAND_GET_RACK_LINE_CELL_CONF(NRACK_LINE => I, NRACK_LINE_CELL => J);
              /* ����� ��������� � ��������� ����������� ����������� */
              BADD := true;
              if (NOMENS.COUNT > 0) then
                /* ���� � ��� ������������ � ��������� ����������� �������������... */
                for N in NOMENS.FIRST .. NOMENS.LAST
                loop
                  /* ...����� ��, ��� � ������ */
                  if (NOMENS(N).RACK_NOMEN_CONF.NNOMMODIF = CELL_CONF.NNOMMODIF) then
                    /* ����� ���� - ��������� �� ���� */
                    BADD := false;
                  end if;
                end loop;
              end if;
              /* ������������ ��� � ������ ��� ��� � ��������� ����������� - ������ ������� � */
              if (BADD) then
                NOMENS.EXTEND();
                NOMENS(NOMENS.LAST).RACK_NOMEN_CONF := STAND_GET_RACK_NOMEN_CONF(NNOMMODIF => CELL_CONF.NNOMMODIF);
                NOMENS(NOMENS.LAST).NINCOMEFROMDEPSSPEC := null;
              end if;
            end;
          end if;
        end loop;
      end if;
    end loop;
  
    /* ��������� ��������� ����� ��������� */
    P_INCOMEFROMDEPS_GETNEXTNUMB(NCOMPANY => NCOMPANY,
                                 STYPE    => SINCDEPS_TYPE,
                                 SPREF    => SINCDEPS_PREF,
                                 SNUMB    => SDOC_NUMB);
  
    /* ��������� ��������� ������� �� ������������� */
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
  
    /* ��������� ������������ ������� �� ������������� */
    for I in NOMENS.FIRST .. NOMENS.LAST
    loop
      P_INCOMEFROMDEPSSPEC_INSERT(NCOMPANY        => NCOMPANY,
                                  NPRN            => NINCOMEFROMDEPS,
                                  SNOMEN          => NOMENS(I).RACK_NOMEN_CONF.SNOMEN,
                                  SNOMMODIF       => NOMENS(I).RACK_NOMEN_CONF.SNOMMODIF,
                                  SNOMNPACK       => null,
                                  SARTICLE        => null,
                                  SCELL           => null,
                                  SPARTY_AGENT    => null,
                                  SSUPPLY         => null,
                                  SSTORE          => null,
                                  NQUANT_PLAN     => NOMENS(I).RACK_NOMEN_CONF.NMAX_QUANT,
                                  NQUANT_FACT     => NOMENS(I).RACK_NOMEN_CONF.NMAX_QUANT,
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
                                  NRN             => NOMENS(I).NINCOMEFROMDEPSSPEC);
    end loop;
  
    /* ��������� ���� �������� ��� ������������ */
    for I in 1 .. NRACK_LINES
    loop
      if ((NRACK_LINE is null) or (((NRACK_LINE is not null)) and (NRACK_LINE = I))) then
        for J in 1 .. NRACK_LINE_CELLS
        loop
          if ((NRACK_LINE_CELL is null) or (((NRACK_LINE_CELL is not null)) and (NRACK_LINE_CELL = J))) then
            /* ������� ������������ ������ */
            CELL_CONF := STAND_GET_RACK_LINE_CELL_CONF(NRACK_LINE => I, NRACK_LINE_CELL => J);
            /* ������ ������� ������������ ������� ��� ���� ��������� */
            NINCOMEFROMDEPSSPEC := null;
            for N in NOMENS.FIRST .. NOMENS.LAST
            loop
              if (NOMENS(N).RACK_NOMEN_CONF.NNOMMODIF = CELL_CONF.NNOMMODIF) then
                NINCOMEFROMDEPSSPEC := NOMENS(N).NINCOMEFROMDEPSSPEC;
              end if;
            end loop;
            if (NINCOMEFROMDEPSSPEC is null) then
              P_EXCEPTION(0,
                          '��� ����������� "%s" ������������ "%s" �� ������� ���������� ������� ������� �� �������������!',
                          CELL_CONF.SNOMMODIF,
                          CELL_CONF.SNOMEN);
            end if;
            /* ��������� ����� �������� */
            P_STRPLRESJRNL_INSERT(NCOMPANY        => NCOMPANY,
                                  SMASTERUNITCODE => 'IncomFromDeps',
                                  SSLAVEUNITCODE  => 'IncomFromDepsSpecs',
                                  NMASTERRN       => NINCOMEFROMDEPS,
                                  NSLAVERN        => NINCOMEFROMDEPSSPEC,
                                  SSTORE          => SSTORE_GOODS,
                                  SRACK_PREF      => SRACK_PREF,
                                  SRACK_NUMB      => SRACK_NUMB,
                                  SCELL_PREF      => CELL_CONF.SPREF,
                                  SCELL_NUMB      => CELL_CONF.SNUMB,
                                  NGOODSSUPPLY    => null,
                                  NRES_TYPE       => 0,
                                  SNOMEN          => CELL_CONF.SNOMEN,
                                  SNOMMODIF       => CELL_CONF.SNOMMODIF,
                                  SNOMNMODIFPACK  => null,
                                  NNOMMODIF       => CELL_CONF.NNOMMODIF,
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
                                  NQUANT          => CELL_CONF.NCAPACITY,
                                  NQUANTALT       => 0,
                                  NQUANTPACK      => null,
                                  NRN             => NSTRPLRESJRNL);
          end if;
        end loop;
      end if;
    end loop;
  
    /* ��������� ��������� ��� "����" */
    P_INCOMEFROMDEPS_SET_STATUS(NCOMPANY  => NCOMPANY,
                                NRN       => NINCOMEFROMDEPS,
                                NSTATUS   => 2,
                                DWORKDATE => TRUNC(sysdate),
                                NWARNING  => NWARNING,
                                SMSG      => SMSG);
    if ((NWARNING is not null) or (SMSG is not null)) then
      P_EXCEPTION(0, NVL(SMSG, '������ ��������� ���������!'));
    end if;
  
    /* ������������� ������������ �� ������ �������� */
    P_STRPLRESJRNL_INDEPTS_PROCESS(NCOMPANY => NCOMPANY, NRN => NINCOMEFROMDEPS);
  
    /* ��������� � ������� ������ */
    MSG_INSERT_NOTIFY(SMSG => '����� ������� ��������...', SNOTIFY_TYPE => SNOTIFY_TYPE_INFO);
  
    /* �������� ������� �� ������ */
    STAND_SAVE_RACK_REST(NCOMPANY => NCOMPANY, BNOTIFY_REST => true, BNOTIFY_LIMIT => false);
  end;

  /* ����� ��������� �������� ������ */
  procedure LOAD_ROLLBACK
  (
    NCOMPANY                number,                 -- ��������������� ����� �����������
    NINCOMEFROMDEPS         out number              -- ��������������� ����� ����������������� "������� �� �������������"    
  ) is    
    NWARNING                PKG_STD.TREF;           -- ���� �������������� ��������� ��������� �������
    SMSG                    PKG_STD.TSTRING;        -- ����� ��������� ��������� ��������� �������
  begin
    /* ������� ��������� �������� */
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
      when others then
        NINCOMEFROMDEPS := null;
    end;
  
    /* ��������, ��� ���� �������� ������ */
    if (NINCOMEFROMDEPS is null) then
      P_EXCEPTION(0, '�� ������� �� ����� �������� ������!');
    end if;
  
    /* �������� ���������� �� ������ �������� */
    P_STRPLRESJRNL_INDEPTS_RLLBACK(NCOMPANY => NCOMPANY, NRN => NINCOMEFROMDEPS);
  
    /* ������� ��������� */
    P_INCOMEFROMDEPS_SET_STATUS(NCOMPANY  => NCOMPANY,
                                NRN       => NINCOMEFROMDEPS,
                                NSTATUS   => 0,
                                DWORKDATE => TRUNC(sysdate),
                                NWARNING  => NWARNING,
                                SMSG      => SMSG);
    if ((NWARNING is not null) or (SMSG is not null)) then
      P_EXCEPTION(0, NVL(SMSG, '������ ������ ��������� ���������!'));
    end if;
  
    /* ������� �������������� �� ������ �������� */
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
  
    /* ������� �������� */
    P_INCOMEFROMDEPS_DELETE(NCOMPANY => NCOMPANY, NRN => NINCOMEFROMDEPS);
  
    /* �������� ������� �� ������ */
    STAND_SAVE_RACK_REST(NCOMPANY => NCOMPANY, BNOTIFY_REST => false, BNOTIFY_LIMIT => true);
  end;

  /* �������� �� ������ ���������� */
  procedure SHIPMENT
  (
    NCOMPANY                number,                    -- ��������������� ����� �����������
    SCUSTOMER               varchar2,                  -- �������� �����������-����������
    NRACK_LINE              number,                    -- ����� ����� �������� ������
    NRACK_LINE_CELL         number,                    -- ����� ������ � ����� �������� ������
    NTRANSINVCUST           out number                 -- ��������������� ����� �������������� ����
  ) is
    NCRN                    INCOMEFROMDEPS.RN%type;    -- ������� ���������� ����
    NJUR_PERS               JURPERSONS.RN%type;        -- ��������������� ����� ������������ ���� ���� (�������� �� �����������)
    SJUR_PERS               JURPERSONS.CODE%type;      -- �������� ����� ������������ ���� ���� (�������� �� �����������)
    SCURRENCY               CURNAMES.CURCODE%type;     -- ������ ������������ ���� (������� ������ �����������)
    SNUMB                   TRANSINVCUST.NUMB%type;    -- ����� ������������ ����
    SMOL                    AGNLIST.AGNABBR%type;      -- ��� ������ �������� ����
    SMSG                    PKG_STD.TSTRING;           -- ����� ��������� ��������� ���������� ����/������������ ����/��������� ����    
    NTRANSINVCUSTSPECS      TRANSINVCUSTSPECS.RN%type; -- ��������������� ����� �������������� ������������ ����
    NGOODSSUPPLY            GOODSSUPPLY.RN%type;       -- ��������������� ����� ��������� ������ ��� ��������������
    NSTRPLRESJRNL           STRPLRESJRNL.RN%type;      -- ��������������� ����� �������������� ������ �������������� �� ������ ��������
    NTMP_QUANT              PKG_STD.TQUANT;            -- ����� ��� ���������� ������������ � �������� ������
    CELL_CONF               TRACK_LINE_CELL_CONF;      -- ������������ ������ (����� ��������) ������    
  begin
    /* ��������� ���. ����� �������� */
    FIND_ROOT_CATALOG(NCOMPANY => NCOMPANY, SCODE => 'GoodsTransInvoicesToConsumers', NCRN => NCRN);
  
    /* ��������� �������� ����������� ���� ����������� */
    FIND_JURPERSONS_MAIN(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SJUR_PERS => SJUR_PERS, NJUR_PERS => NJUR_PERS);
  
    /* ��������� ������� ������ */
    FIND_CURRENCY_BASE_NAME(NCOMPANY => NCOMPANY, SCODE => SCURRENCY, SISO => SCURRENCY);
  
    /* ������� ������������ ������ �� ������� ���������� �������� */
    CELL_CONF := STAND_GET_RACK_LINE_CELL_CONF(NRACK_LINE => NRACK_LINE, NRACK_LINE_CELL => NRACK_LINE_CELL);
  
    /* ��������� ��� ������ �������� */
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
                    '��� ������ "%s" �� ������� ����������� ������������� ����!',
                    SSTORE_PRODUCE);
    end;
  
    /* ��������� ��������� ����� ���� */
    P_TRANSINVCUST_GETNEXTNUMB(NCOMPANY  => NCOMPANY,
                               SJUR_PERS => SJUR_PERS,
                               DDOCDATE  => TRUNC(sysdate),
                               STYPE     => STRINVCUST_TYPE,
                               SPREF     => STRINVCUST_PREF,
                               SNUMB     => SNUMB);
  
    /* ��������� ��������� ���� */
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
  
    /* ������� ������������ ���� */
    P_TRANSINVCUSTSPECS_INSERT(NCOMPANY         => NCOMPANY,
                               NPRN             => NTRANSINVCUST,
                               STAXGR           => SDEF_TAX_GROUP,
                               SGOODSPARTY      => null,
                               SNOMEN           => CELL_CONF.SNOMEN,
                               SNOMMODIF        => CELL_CONF.SNOMMODIF,
                               SNOMNMODIFPACK   => null,
                               SARTICLE         => null,
                               SCELL            => null,
                               SHLCARGOCLASS    => null,
                               NTEMPERATURE     => null,
                               NPRICE           => 0,
                               NDISCOUNT        => 0,
                               NQUANT           => CELL_CONF.NSHIP_CNT,
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
  
    /* ������ �������� ����� */
    FIND_STPLGOODSSUPPLY_BY_PARTY(NFLAG_SMART   => 1,
                                  NCOMPANY      => NCOMPANY,
                                  SSTORE        => SSTORE_GOODS,
                                  SRACK         => RACK_BUILD_NAME(SPREF => SRACK_PREF, SNUMB => SRACK_NUMB),
                                  SCELL         => CELL_CONF.SNAME,
                                  SINDOC        => SDEF_STORE_PARTY,
                                  SSERNUMB      => null,
                                  SCOUNTRY      => null,
                                  SGTD          => null,
                                  SNOMEN        => CELL_CONF.SNOMEN,
                                  SNOMMODIF     => CELL_CONF.SNOMMODIF,
                                  SNOMMODIFPACK => null,
                                  SARTICLE      => null,
                                  DDATE         => sysdate,
                                  NGOODSSUPPLY  => NGOODSSUPPLY,
                                  NQUANT        => NTMP_QUANT,
                                  NQUANTALT     => NTMP_QUANT,
                                  NQUANTPACK    => NTMP_QUANT);
    if (NGOODSSUPPLY is null) then
      P_EXCEPTION(0,
                  '�� ������� ���������� �������� ����� ����������� "%s" ������������ "%s" �� ����� �������� "%s" �������� "%s" ������ "%s"!',
                  CELL_CONF.SNOMMODIF,
                  CELL_CONF.SNOMEN,
                  CELL_CONF.SNAME,
                  RACK_BUILD_NAME(SPREF => SRACK_PREF, SNUMB => SRACK_NUMB),
                  SSTORE_GOODS);
    end if;
  
    /* ����������� ����� �� ������ �������� */
    P_STRPLRESJRNL_INSERT(NCOMPANY        => NCOMPANY,
                          SMASTERUNITCODE => 'GoodsTransInvoicesToConsumers',
                          SSLAVEUNITCODE  => 'GoodsTransInvoicesToConsumersSpecs',
                          NMASTERRN       => NTRANSINVCUST,
                          NSLAVERN        => NTRANSINVCUSTSPECS,
                          SSTORE          => SSTORE_GOODS,
                          SRACK_PREF      => SRACK_PREF,
                          SRACK_NUMB      => SRACK_NUMB,
                          SCELL_PREF      => CELL_CONF.SPREF,
                          SCELL_NUMB      => CELL_CONF.SNUMB,
                          NGOODSSUPPLY    => NGOODSSUPPLY,
                          NRES_TYPE       => 1,
                          SNOMEN          => CELL_CONF.SNOMEN,
                          SNOMMODIF       => CELL_CONF.SNOMMODIF,
                          SNOMNMODIFPACK  => null,
                          NNOMMODIF       => CELL_CONF.NNOMMODIF,
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
                          NQUANT          => CELL_CONF.NSHIP_CNT,
                          NQUANTALT       => 0,
                          NQUANTPACK      => null,
                          NRN             => NSTRPLRESJRNL);
  
    /* ���������� �������������� ���� ��� ���� */
    P_TRANSINVCUST_SET_STATUS(NCOMPANY   => NCOMPANY,
                              NRN        => NTRANSINVCUST,
                              NSTATUS    => 2,
                              DWORK_DATE => TRUNC(sysdate),
                              SMSG       => SMSG);
  
    /* ������ ������ � ���� �������� */
    P_STRPLRESJRNL_GTINV2C_PROCESS(NCOMPANY => NCOMPANY, NRN => NTRANSINVCUST, NRES_TYPE => 1);
  
    /* �������, ��� ��������� �������� */
    MSG_INSERT_NOTIFY(SMSG         => '��������� �������� "' || CELL_CONF.SNOMEN || ' - ' || CELL_CONF.SNOMMODIF ||
                                      '"  ���������� "' || SCUSTOMER || '", ��������-�������������: ' ||
                                      STRINVCUST_TYPE || ' �' || STRINVCUST_PREF || '-' || SNUMB || ' �� ' ||
                                      TO_CHAR(sysdate, 'dd.mm.yyyy'),
                      SNOTIFY_TYPE => SNOTIFY_TYPE_INFO);
  
    /* �������� ������� �� ������ */
    STAND_SAVE_RACK_REST(NCOMPANY => NCOMPANY, BNOTIFY_REST => false, BNOTIFY_LIMIT => true);
  end;

  /* ����� �������� �� ������ */
  procedure SHIPMENT_ROLLBACK
  (
    NCOMPANY                number,               -- ��������������� ����� �����������
    NTRANSINVCUST           number                -- ��������������� ����� ����������� ����
  ) is
    SCUSTOMER               AGNLIST.AGNABBR%type; -- �������� ����������� ��������
    SMSG                    PKG_STD.TSTRING;      -- ����� ��������� ��������� ��������� �������
  begin
    /* ������� �������� ����������� ������������ ��������� */
    begin
      select A.AGNABBR
        into SCUSTOMER
        from TRANSINVCUST T,
             AGNLIST      A
       where T.RN = NTRANSINVCUST
         and T.AGENT = A.RN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NTRANSINVCUST, SUNIT_TABLE => 'TRANSINVCUST');
    end;
  
    /* �������� ���������� �� ������ �������� */
    P_STRPLRESJRNL_GTINV2C_RLLBACK(NCOMPANY => NCOMPANY, NRN => NTRANSINVCUST, NRES_TYPE => 1);
  
    /* ������� ��������� */
    P_TRANSINVCUST_SET_STATUS(NCOMPANY   => NCOMPANY,
                              NRN        => NTRANSINVCUST,
                              NSTATUS    => 0,
                              DWORK_DATE => TRUNC(sysdate),
                              SMSG       => SMSG);
    if (SMSG is not null) then
      P_EXCEPTION(0, SMSG);
    end if;
  
    /* ������� �������������� �� ������ �������� */
    for C in (select T.COMPANY,
                     T.RN
                from STRPLRESJRNL      T,
                     TRANSINVCUSTSPECS SP,
                     DOCLINKS          L
               where T.COMPANY = NCOMPANY
                 and SP.PRN = NTRANSINVCUST
                 and L.IN_DOCUMENT = SP.RN
                 and L.IN_UNITCODE = 'GoodsTransInvoicesToConsumersSpecs'
                 and L.OUT_UNITCODE = 'StoragePlacesResJournal'
                 and L.OUT_DOCUMENT = T.RN)
    loop
      P_STRPLRESJRNL_DELETE(NCOMPANY => C.COMPANY, NRN => C.RN);
    end loop;
  
    /* ������� �������� */
    P_TRANSINVCUST_DELETE(NCOMPANY => NCOMPANY, NRN => NTRANSINVCUST);
  
    /* ������ ��� �������� �������� */
    MSG_INSERT_NOTIFY(SMSG         => '�������� ���������� "' || SCUSTOMER || '" ���� ��������...',
                      SNOTIFY_TYPE => SNOTIFY_TYPE_INFO);
  
    /* �������� ������� �� ������ */
    STAND_SAVE_RACK_REST(NCOMPANY => NCOMPANY, BNOTIFY_REST => true, BNOTIFY_LIMIT => false);
  end;
  
  /* ���������� ��������� ������ ������� ������ */
  procedure PRINT_GET_STATE
  (
    SSESSION                varchar2,                       -- ������������� ������
    NRPTPRTQUEUE            number,                         -- ��������������� ����� ������ ������� ������
    RPT_QUEUE_STATE         out TRPT_QUEUE_STATE            -- ��������� ������� ������� ������    
  ) is    
    SMSG                    UDO_T_STAND_MSG.MSG%type;       -- ����� ������������ �����������
    SNOTIFY_TYPE            PKG_STD.TSTRING;                -- ��� ������������ �����������
    SRECEIVER               RPTPRTQUEUE_PRM.STR_VALUE%type; -- �������� ��������� ������ "����������-����������"
  begin
    /* ������� ������ ������� � �������������� �������� ��������� */
    begin
      select T.RN,
             DECODE(T.STATUS,
                    NRPT_QUEUE_STATE_INS,
                    SRPT_QUEUE_STATE_INS,
                    NRPT_QUEUE_STATE_RUN,
                    SRPT_QUEUE_STATE_RUN,
                    NRPT_QUEUE_STATE_OK,
                    SRPT_QUEUE_STATE_OK,
                    NRPT_QUEUE_STATE_ERR,
                    SRPT_QUEUE_STATE_ERR),
             T.ERROR_TEXT,
             DECODE(T.STATUS, NRPT_QUEUE_STATE_OK, UDO_PKG_WEB_API.UTL_RPTQ_BUILD_FILE_NAME(NREPORTQ => T.RN), ''),
             DECODE(T.STATUS,
                    NRPT_QUEUE_STATE_OK,
                    UDO_PKG_WEB_API.UTL_BUILD_DOWNLOAD_URL(SSESSION   => SSESSION,
                                                           SFILE_TYPE => UDO_PKG_WEB_API.SFILE_TYPE_REPORT,
                                                           NFILE_RN   => T.RN),
                    '')
        into RPT_QUEUE_STATE.NRN,
             RPT_QUEUE_STATE.SSTATE,
             RPT_QUEUE_STATE.SERR,
             RPT_QUEUE_STATE.SFILE_NAME,
             RPT_QUEUE_STATE.SURL
        from RPTPRTQUEUE T
       where T.RN = NRPTPRTQUEUE;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NRPTPRTQUEUE, SUNIT_TABLE => 'RPTPRTQUEUE');
    end;
    /* ���� ����� ����������� (� ������� ��� ��� - �� �����) */
    if (RPT_QUEUE_STATE.SSTATE in (SRPT_QUEUE_STATE_OK, SRPT_QUEUE_STATE_ERR)) then
      /* ���� ��������� � ������� ������ �������� �� ���� */
      for MSG in (select RN
                    from UDO_T_STAND_MSG T
                   where T.TP = SMSG_TYPE_PRINT
                     and T.STS = SMSG_STATE_NOT_PRINTED
                     and T.MSG = TO_CHAR(RPT_QUEUE_STATE.NRN))
      loop
        MSG_SET_STATE(NRN => MSG.RN, SSTS => SMSG_STATE_PRINTED);
      end loop;
      /* ������� ���������� � ��������� */
      begin
        select P.STR_VALUE
          into SRECEIVER
          from RPTPRTQUEUE_PRM P
         where P.PRN = RPT_QUEUE_STATE.NRN
           and P.NAME = 'SRECEIVER';
      exception
        when NO_DATA_FOUND then
          SRECEIVER := null;
      end;
      /* ���������� ��������� */
      if (RPT_QUEUE_STATE.SSTATE = SRPT_QUEUE_STATE_OK) then
        if (SRECEIVER is null) then
          SMSG := '������ ���������� ������ ������� ���������� ��������� ���������.';
        else
          SMSG := '��������� ��� ' || SRECEIVER || ' ������� ������������ �������� ���������� ������.';
        end if;
        SNOTIFY_TYPE := SNOTIFY_TYPE_INFO;
      else
        if (SRECEIVER is null) then
          SMSG := '������ ���������� ��������� �������� ���������� ������: ' || RPT_QUEUE_STATE.SERR;
        else
          SMSG := '������ ���������� ��������� ��� ' || SRECEIVER || ': ' || RPT_QUEUE_STATE.SERR;
        end if;
        SNOTIFY_TYPE := SNOTIFY_TYPE_ERROR;
      end if;
      /* ������� ��������� � ������� */
      MSG_INSERT_NOTIFY(SMSG => SMSG, SNOTIFY_TYPE => SNOTIFY_TYPE);
    end if;
  end;
  
  /* ���������� ������ ���������� ��� ������ ���������� (���������� ����������) */
  procedure PRINT_SET_SELECTLIST
  (
    NIDENT                  number,       -- ������������� ������
    NDOCUMENT               number,       -- ��������������� ����� ���������
    SUNITCODE               varchar2      -- ��� ������� ���������
  ) is
    NSLRN                   PKG_STD.TREF; -- ���. ����� ������� ������ ��������� ����������
    pragma AUTONOMOUS_TRANSACTION;
  begin
    /* ��������� ���� � ������ ��������� ���������� */
    P_SELECTLIST_INSERT_EXT(NIDENT     => NIDENT,
                            NDOCUMENT  => NDOCUMENT,
                            SUNITCODE  => SUNITCODE,
                            NDOCUMENT1 => null,
                            SUNITCODE1 => null,
                            NCRN       => null,
                            NRN        => NSLRN);
    /* ������������ ���������� ���������� */
    commit;                            
  end;
  
  /* ������� ������ ���������� ��� ������ ���������� (���������� ����������) */
  procedure PRINT_CLEAR_SELECTLIST
  (
    NIDENT                  number      -- ������������� ������
  ) is
    pragma AUTONOMOUS_TRANSACTION;
  begin
    /* �������� ����� */
    P_SELECTLIST_CLEAR(NIDENT => NIDENT);
    /* ������������ ���������� ���������� */
    commit;                            
  end;
  
  /* ������ ���� ����� ������ ������ */
  procedure PRINT
  (
    NCOMPANY                number,          -- ��������������� ����� ������������
    NTRANSINVCUST           number           -- ��������������� ����� ����
  ) is
    NIDENT                  PKG_STD.TREF;    -- ������������� ���������� ������� ��� ��������� ��������    
    NTRINVCUST_REPORT       PKG_STD.TREF;    -- ���. ����� ������������ ������
    STRANSINVCUST           PKG_STD.TSTRING; -- �������� ��������� ��������
    SAGENT                  PKG_STD.TSTRING; -- ���������� ��������� ��������
    NPQ                     PKG_STD.TREF;    -- ���. ����� ������� ������� ������
  begin
    /* ������� ������ ��������� �������� */
    begin
      select trim(T.PREF) || '-' || trim(T.NUMB) || ' �� ' || TO_CHAR(T.DOCDATE, 'dd.mm.yyyy'),
             AG.AGNABBR
        into STRANSINVCUST,
             SAGENT
        from TRANSINVCUST T,
             AGNLIST      AG
       where T.RN = NTRANSINVCUST
         and T.COMPANY = NCOMPANY
         and T.AGENT = AG.RN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NTRANSINVCUST, SUNIT_TABLE => 'TRANSINVCUST');
    end;
    /* ������ ��������������� ����� ������ */
    FIND_USERREP_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SCODE => STRINVCUST_REPORT, NRN => NTRINVCUST_REPORT);
    /* ���������� ������������� ���������� ������� */
    P_SELECTLIST_GENIDENT(NIDENT => NIDENT);
    /* ����� �������� � ����� (���������� ����������) */
    PRINT_SET_SELECTLIST(NIDENT => NIDENT, NDOCUMENT => NTRANSINVCUST, SUNITCODE => 'GoodsTransInvoicesToConsumers');
    /* ��������� ����� ������� ������ */
    PKG_RPTPRTQUEUE.RESET_PARAMETER();
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NCOMPANY',
                                  NDATA_TYPE  => 1,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => NCOMPANY,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NIDENT',
                                  NDATA_TYPE  => 1,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => NIDENT,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => true);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SSELLER',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SSEL_BNKATR',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SSENDER',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SSND_BNKATR',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SRECEIVER',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => SAGENT,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SREC_BNKATR',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NNUMB_LINES_FIRST',
                                  NDATA_TYPE  => 1,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => 10,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NNUMB_LINES_LAST',
                                  NDATA_TYPE  => 1,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => 10,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NNUMB_LINES',
                                  NDATA_TYPE  => 1,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => 10,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NSHOW_NOMEN',
                                  NDATA_TYPE  => 3,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => 1,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.REGISTER_REPORT(NREPORT_TYPE     => 0,
                                    BWAIT_COMPLEET   => false,
                                    NCOMPANY         => NCOMPANY,
                                    NIDENT           => null,
                                    NUSER_REPORT     => NTRINVCUST_REPORT,
                                    NCALC_TABLE      => null,
                                    NCALC_TABLE_LINK => null,
                                    SCALC_TABLE_URL  => null,
                                    SCALC_TABLE_DB   => null,
                                    NQUEUE           => NPQ);
    /* �������� ����� ���������� ���������� (���������� ����������) */
    PRINT_CLEAR_SELECTLIST(NIDENT => NIDENT);
    /* ��������� ������������� � ���, ��� ����� ��������� � ������� */
    MSG_INSERT_NOTIFY(SMSG         => '��������� "' || STRANSINVCUST || '" ��� ���������� "' || SAGENT ||
                                      '" ���������� � ������� ������',
                      SNOTIFY_TYPE => SNOTIFY_TYPE_INFO);
    /* ��������� ������ �������������� ������, � ���, ��� ���� ������� �� ������� */
    MSG_INSERT_PRINT(SMSG => NPQ);
  exception
    /* � ������ ����� ������ - �������� �� ��� ��������� ���������� ����������� � ������ */
    when others then
      /* �������� ����� ���������� ���������� (���������� ����������) */
      PRINT_CLEAR_SELECTLIST(NIDENT => NIDENT);
      raise;
  end;

begin
  /* ������������� �������� ������ */
  STAND_INIT_RACK_CONF(NCOMPANY => GET_SESSION_COMPANY(), SSTORE => SSTORE_GOODS);
end;
/
