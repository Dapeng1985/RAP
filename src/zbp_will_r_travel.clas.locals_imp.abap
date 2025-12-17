CLASS lhc_zwill_r_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setCancel FOR MODIFY
      IMPORTING keys FOR ACTION travel~setCancel
      RESULT    rs.
    METHODS allAc FOR MODIFY
      IMPORTING keys FOR ACTION travel~allAc.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.   "&返回值[数据更新后，直接更新该页面的数据]
    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatestatus.
    METHODS set_owner FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~set_owner.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.

    METHODS _is_allowed RETURNING VALUE(rec) TYPE abap_boolean.
ENDCLASS.

CLASS lhc_zwill_r_travel IMPLEMENTATION.

  METHOD setCancel.
    DATA: lo_msg TYPE REF TO zcm_will_travel.
    DATA: ls_reported_travel LIKE LINE OF reported-travel,
          ls_failed_check    LIKE LINE OF failed-travel.

    DATA: lt_ri      TYPE TABLE FOR READ IMPORT zwill_r_travel,
          ls_read_in LIKE LINE OF lt_ri.

    DATA: lt_travel TYPE TABLE FOR READ RESULT zwill_r_travel.

    DATA: lt_upd TYPE TABLE FOR UPDATE zwill_r_travel,
          ls_upd LIKE LINE OF lt_upd.

    DATA: ls_failed TYPE RESPONSE FOR FAILED zwill_r_travel.

    FIELD-SYMBOLS: <ls_key>    LIKE LINE OF keys,
                   <ls_travel> LIKE LINE OF lt_travel.

    LOOP AT keys ASSIGNING <ls_key>.
      CLEAR: ls_read_in.
      ls_read_in = CORRESPONDING #( <ls_key> ).
      APPEND ls_read_in TO lt_ri.
    ENDLOOP.

    READ ENTITY IN LOCAL MODE zwill_r_travel
    ALL FIELDS WITH lt_ri
    RESULT lt_travel
    FAILED ls_failed.

    LOOP AT lt_travel ASSIGNING <ls_travel>.
      IF <ls_travel>-Status = 'C'.
        "& 状态为C时，返回错误消息
        CREATE OBJECT lo_msg
          EXPORTING
            textid   = zcm_will_travel=>already_cancelled
            severity = if_abap_behv_message=>severity-error.

        ls_reported_travel-%tky = <ls_travel>-%tky.
        ls_reported_travel-%msg = lo_msg.
        APPEND ls_reported_travel TO reported-travel.

        ls_failed_check-%tky = <ls_travel>-%tky.
        APPEND ls_failed_check TO failed-travel.
      ELSE.
        "& 状态不为C-Cancelled时，准备将选中数据更新为C
        CLEAR: ls_upd.
        ls_upd-%tky = <ls_travel>-%tky.
        ls_upd-Status = 'C'.
        APPEND ls_upd TO lt_upd.

        MODIFY ENTITY IN LOCAL MODE zwill_r_travel
        UPDATE FIELDS ( Status )
        WITH lt_upd
        FAILED ls_failed.
        IF  ls_failed IS INITIAL.
          "& 返回成功消息
          CREATE OBJECT lo_msg
            EXPORTING
              textid   = zcm_will_travel=>cancel_success
              severity = if_abap_behv_message=>severity-success.

          CLEAR: ls_reported_travel.
          ls_reported_travel-%tky = <ls_travel>-%tky.
          ls_reported_travel-%msg = lo_msg.
          APPEND ls_reported_travel TO reported-travel.


          "& 返回值  更新页码数据用
          INSERT VALUE #( %tky = <ls_travel>-%tky %param = <ls_travel> ) INTO TABLE rs.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD allAc.
    DATA ls_failed TYPE RESPONSE FOR FAILED zwill_r_travel.
    SELECT  FROM zwill_travel FIELDS * INTO TABLE @DATA(lt_cancelled) .

    LOOP AT lt_cancelled INTO DATA(ls_line).
      IF ls_line-status <> 'C'.
        CONTINUE.
      ENDIF.

      MODIFY ENTITY IN LOCAL MODE zwill_r_travel
      UPDATE FIELDS ( Status )
      WITH VALUE #( ( %tky-AgencyId = ls_line-agency_id %tky-TravelId = ls_line-travel_id Status = 'A' ) )
      FAILED ls_failed.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "& Global 权限检查
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA(l_auth_check) = _is_allowed( ).

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      IF l_auth_check = abap_true.
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      IF l_auth_check = abap_true.
        result-%update = if_abap_behv=>auth-allowed.
      ELSE.
        result-%update  = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      IF l_auth_check = abap_true.
        result-%delete = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

    IF requested_authorizations-%action-setcancel = if_abap_behv=>mk-on.
      IF l_auth_check = abap_true.
        result-%action-setcancel = if_abap_behv=>auth-allowed.
      ELSE.
        result-%action-setcancel = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

    IF requested_authorizations-%action-allac = if_abap_behv=>mk-on.
      IF l_auth_check = abap_true.
        result-%action-allac = if_abap_behv=>auth-allowed.
      ELSE.
        result-%action-allac = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD _is_allowed.
    rec = abap_true.

*    authority-check object '/LRN/AGCY'
*        id '/LRN/AGCY' FIELD '11'
*        ID 'ACTVT'     FIELD '02'.
*    IF SY-SUBRC = 0.
*      REC = ABAP_TRUE.
*    ELSE.
*      REC = ABAP_FALSE.
*    ENDIF.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    DATA ls_result LIKE LINE OF result.

    "按KEY读取当前数据
    READ ENTITY IN LOCAL MODE zwill_r_travel
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT  DATA(lt_travels)
    FAILED DATA(ls_failed).

    CHECK ls_failed IS INITIAL.

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travel>).
      IF requested_authorizations-%update =  if_abap_behv=>mk-on.
        ls_result-%tky = <ls_travel>-%tky.
        IF <ls_travel>-Status = 'A'.
          ls_result-%update = if_abap_behv=>auth-unauthorized.
        ELSE.
          ls_result-%update = if_abap_behv=>auth-allowed.
        ENDIF.
        APPEND ls_result TO result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.
    "& Validation 适用于托管和非托管带草稿的场景
    "&   可以指定场景：create； update； delete
    "&   指定字段变更： field xxxx;

    "& 参数说明：
    "& -->KEYS       指定数据的key信息
    "& <--failed     指定数据 错误标记
    "& <--reported   消息
    READ ENTITY IN LOCAL MODE zwill_r_travel
    FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels)
    FAILED DATA(ls_failed).

    LOOP AT lt_travels INTO DATA(ls_travel).
      IF ls_travel-Status IS INITIAL.
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = ls_travel-%tky
                        %msg = NEW zcm_will_travel( textid = zcm_will_travel=>fill_empty )   "消息提升
                        %element-status = if_abap_behv=>mk-on                               "点击消息时，会跳转到对应的字段
                      ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_owner.
    DATA lt_travel_upd TYPE TABLE FOR UPDATE zwill_r_travel.

    lt_travel_upd = CORRESPONDING #( keys ).

    DATA(lv_agencyid) = cl_abap_context_info=>get_user_technical_name(  ).
    LOOP AT lt_travel_upd ASSIGNING FIELD-SYMBOL(<fs_upd>).
      <fs_upd>-Description = lv_agencyid.
    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE zwill_r_travel
    UPDATE FIELDS ( Description )
    WITH lt_travel_upd
    REPORTED DATA(ls_reported).

    MOVE-CORRESPONDING ls_reported-travel TO reported-travel.
  ENDMETHOD.

  METHOD get_instance_features.
    read entity in LOCAL MODE zwill_r_travel
    fieLDS ( Status BeginDate EndDate )
    with corrESPONDING #( keys )
    result data(travels).

    data(lv_today) = cl_abap_context_info=>get_system_date(  ).

    loop AT travels iNTO dATA(ls_travel).
      append corrESPONDING #( ls_travel ) to result
        aSSIGNING fIELD-SYMBOL(<fs_result>).

      "& 若该条数据状态为C-Cancelled，则取消按钮/更新按钮不可用
      if ls_travel-Status = 'C'.
        <fs_result>-%action-setCancel = if_abap_behv=>fc-o-disabled.
        <fs_result>-%update = if_abap_behv=>fc-o-disabled.
      endif.

      if ls_travel-begindate is not initial and ls_travel-begindate <= lv_today.
        <fs_result>-%field-CustomerId = if_abap_behv=>fc-f-read_only.
        <fs_result>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
      else.
        <fs_result>-%field-CustomerId = if_abap_behv=>fc-f-mandatory.
        <fs_result>-%field-BeginDate = if_abap_behv=>fc-f-mandatory.
      endif.
    enDLOOP.
  ENDMETHOD.

ENDCLASS.
