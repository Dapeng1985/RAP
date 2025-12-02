CLASS zcl_will_insert_travel_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_will_insert_travel_data IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: lt_itab TYPE TABLE OF zwill_travel.

*& 填充数据
    lt_itab = VALUE #(
                        ( agency_id = '001456'
                        travel_id = '56465465'
                        description = 'Travel in the past'
                        customer_id = 1
                        begin_date = '20241101'
                        end_date = '20241201'
                        status = ' '
                        changed_at = '20241104080350.0000000 '
                        changed_by = 'testa' )
                        ( agency_id = '0014526'
                        travel_id = '56465455'
                        description = 'Travel in the past'
                        customer_id = 1
                        begin_date = '20241101'
                        end_date = '20241201'
                        status = ' '
                        changed_at = '20241104080350.0000000 '
                        changed_by = 'testa' )
                        ( agency_id = '001457'
                        travel_id = '56465468'
                        description = 'Travel in the past'
                        customer_id = 1
                        begin_date = '20241101'
                        end_date = '20241201'
                        status = ' '
                        changed_at = '20241104080350.0000000 '
                        changed_by = 'testa' )
         ).


*& 清空数据
    DELETE FROM zwill_travel.

*& 插入数据
    INSERT zwill_travel FROM TABLE @lt_itab.

    out->write( 'Travel entries inserted successfully.' ).
  ENDMETHOD.
ENDCLASS.
