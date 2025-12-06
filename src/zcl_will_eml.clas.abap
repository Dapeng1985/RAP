CLASS zcl_will_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: _read_eml,
      _update_eml.

    DATA: gt_import TYPE TABLE FOR READ IMPORT zwill_r_travel.

    DATA: gt_result TYPE TABLE FOR READ RESULT zwill_r_travel.

    DATA: gs_failed   TYPE RESPONSE FOR FAILED zwill_r_travel,
          gs_reported TYPE RESPONSE FOR REPORTED zwill_r_travel.


ENDCLASS.



CLASS zcl_will_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*& 读取EML
    _read_eml( ).
    IF gs_failed IS INITIAL.
      out->write( gt_result ).
    ENDIF.

*& 更新EML
    _update_eml( ).
    IF gs_failed IS INITIAL.
      out->write( sy-dbcnt && 'changed' ).
    ENDIF.
  ENDMETHOD.

  METHOD _read_eml.
    "& Read Import 变量定义
    DATA: lt_read_import TYPE TABLE FOR READ IMPORT zwill_r_travel,
          ls_read_import TYPE STRUCTURE FOR READ IMPORT zwill_r_travel.

    "& 第二种定义工作区方式（同abap）
    DATA: ls_import LIKE LINE OF lt_read_import.

    "& Read Result 变量定义
    DATA: lt_read_result TYPE TABLE FOR READ RESULT zwill_r_travel,
          ls_read_result TYPE STRUCTURE FOR READ RESULT zwill_r_travel,
          ls_result      LIKE LINE OF lt_read_result.

    "& Response 变量定义
    DATA: ls_failed   TYPE RESPONSE FOR FAILED zwill_r_travel,
          ls_reported TYPE RESPONSE FOR REPORTED zwill_r_travel.

    "& 建议写法（%tky代表KEY）
    ls_read_import-%tky-AgencyId = '001457'.
    ls_read_import-%tky-TravelId = '56465468'.

    ls_read_import-AgencyId = '001457'.  "第二种写法
    APPEND ls_read_import TO lt_read_import.

*&  READ EML
    READ ENTITY zwill_r_travel
    ALL FIELDS WITH lt_read_import
    RESULT lt_read_result
    FAILED ls_failed.

*& 输出
    gs_failed = ls_failed.
    gt_result = lt_read_result[].

  ENDMETHOD.

  METHOD _update_eml.
    DATA: lt_update_import TYPE TABLE FOR UPDATE zwill_r_travel,
          ls_update_import TYPE STRUCTURE FOR UPDATE zwill_r_travel.

    ls_update_import-%tky-AgencyId = '001457'.
    ls_update_import-%tky-TravelId = '56465468'.
    ls_update_import-Status = 'A'.
    APPEND ls_update_import TO lt_update_import.

    ls_update_import-%tky-AgencyId = '001456'.
    ls_update_import-%tky-TravelId = '56465465'.
    ls_update_import-Status = 'B'.
    APPEND ls_update_import TO lt_update_import.

    MODIFY ENTITY zwill_r_travel
    UPDATE FIELDS ( Status ) WITH lt_update_import
    FAILED gs_failed.
    IF gs_failed IS NOT INITIAL.
      ROLLBACK ENTITIES.
    ELSE.
      COMMIT ENTITIES.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
