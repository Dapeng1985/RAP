CLASS lhc_zwill_r_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setCancel FOR MODIFY
      IMPORTING keys FOR ACTION travel~setCancel
      RESULT    rs.
    METHODS allAc FOR MODIFY
      IMPORTING keys FOR ACTION travel~allAc.   "&返回值[数据更新后，直接更新该页面的数据]

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
    data ls_failed type resPONSE FOR fAILED zwill_r_travel.
    SELECT  FROM zwill_travel FIELDS * INTO TABLE @DATA(lt_cancelled) .

    LOOP AT lt_cancelled INTO DATA(ls_line).
      IF ls_line-status <> 'C'.
        CONTINUE.
      ENDIF.

      MODIFY ENTITY in LOCAL MODE zwill_r_travel
      UPDATE FIELDS ( Status )
      WITH VALUE #( ( %tky-AgencyId = ls_line-agency_id %tky-TravelId = ls_line-travel_id Status = 'A' ) )
      FAILED ls_failed.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
