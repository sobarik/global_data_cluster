CLASS zcl_gdc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES ty_key TYPE string .
    TYPES ty_value TYPE string .
    TYPES:
      BEGIN OF ty_s_item,
        m_key   TYPE ty_key,
        m_value TYPE ty_value,
      END OF ty_s_item .
    TYPES:
      ty_t_items TYPE HASHED TABLE OF ty_s_item WITH UNIQUE KEY primary_key COMPONENTS m_key .
    TYPES:
      ty_t_memitems TYPE STANDARD TABLE OF ty_s_item .

    DATA mt_msgs TYPE bal_tt_msg .
    DATA mt_values TYPE ty_t_items .

    CLASS-METHODS get_area
      IMPORTING
        VALUE(i_guid) TYPE guid_32
        VALUE(i_mem)  TYPE abap_bool DEFAULT 'X'
      RETURNING
        VALUE(r_obj)  TYPE REF TO zcl_gdc .
    METHODS clear_msgs
      RETURNING
        VALUE(r_value) TYPE i .
    METHODS del_props
      RETURNING
        VALUE(r_value) TYPE i .
    METHODS del_prop
      IMPORTING
        VALUE(i_mem)   TYPE abap_bool DEFAULT ' '
        VALUE(i_name)  TYPE ty_key
      RETURNING
        VALUE(r_value) TYPE i .
    METHODS set_prop
      IMPORTING
        VALUE(i_mem)   TYPE abap_bool DEFAULT ' '
        VALUE(i_name)  TYPE ty_key
        VALUE(i_value) TYPE ty_value DEFAULT ''
      RETURNING
        VALUE(r_value) TYPE i .
    METHODS load_msgs
      RETURNING
        VALUE(r_value) TYPE i .
    METHODS save_msgs
      RETURNING
        VALUE(r_value) TYPE i .
    METHODS load_props
      RETURNING
        VALUE(r_value) TYPE i .
    METHODS save_props
      RETURNING
        VALUE(r_value) TYPE i .
    METHODS get_prop
      IMPORTING
        VALUE(i_mem)   TYPE abap_bool DEFAULT ' '
        VALUE(i_name)  TYPE ty_key
      RETURNING
        VALUE(r_value) TYPE ty_value .
    METHODS add_msg
      IMPORTING
        VALUE(i_mem)   TYPE abap_bool DEFAULT ' '
        VALUE(i_msg)   TYPE bal_s_msg
      RETURNING
        VALUE(r_value) TYPE i .
    METHODS constructor
      IMPORTING
        VALUE(i_guid) TYPE guid_32 .
    CLASS-METHODS test .
  PROTECTED SECTION.

    DATA m_guid TYPE guid_32 .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GDC IMPLEMENTATION.


  METHOD add_msg.
    r_value = 1.
    TRY.
        IF i_mem = abap_true.
          load_msgs( ).
        ENDIF.
        APPEND i_msg TO mt_msgs.
        IF i_mem = abap_true.
          save_msgs( ).
        ENDIF.
        r_value = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD clear_msgs.
    r_value = 1.
    TRY.
        CLEAR mt_msgs.
        save_msgs( ).
        r_value = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD constructor.
    m_guid = i_guid.
  ENDMETHOD.


  METHOD del_prop.
    r_value = 1.
    TRY.
        IF i_mem = abap_true.
          load_props( ).
        ENDIF.
        DELETE TABLE mt_values WITH TABLE KEY m_key = i_name.
        IF i_mem = abap_true.
          save_props( ).
        ENDIF.
        r_value = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD del_props.
    r_value = 1.
    TRY.
        CLEAR mt_values.
        save_props( ).
        r_value = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD get_area.
    r_obj = NEW zcl_gdc( i_guid = i_guid ).
    IF i_mem = abap_true.
      r_obj->load_msgs( ).
      r_obj->load_props( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_prop.
    r_value = ''.
    TRY.
        IF i_mem = abap_true.
          load_props( ).
        ENDIF.
        TRY.
            r_value = mt_values[ m_key = i_name ]-m_value.
          CATCH cx_sy_itab_line_not_found.
            r_value = '#'.
        ENDTRY.
    ENDTRY.
  ENDMETHOD.


  METHOD load_msgs.
    DATA:
      lv_data_string TYPE string VALUE IS INITIAL
      .
    r_value = 1.
    TRY.
        IMPORT p_data = lv_data_string FROM DATABASE ztbl_gdc(02) ID m_guid.
        /ui2/cl_json=>deserialize(
          EXPORTING
            json = lv_data_string
            pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          CHANGING
            data = mt_msgs
        ).
        r_value = 0.
      CATCH cx_sy_import_mismatch_error.
    ENDTRY.
  ENDMETHOD.


  METHOD load_props.
    DATA:
      lv_data_string TYPE string VALUE IS INITIAL
      .
    r_value = 1.
    TRY.
        IMPORT p_data = lv_data_string FROM DATABASE ztbl_gdc(01) ID m_guid.
        /ui2/cl_json=>deserialize(
          EXPORTING
            json = lv_data_string
            pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          CHANGING
            data = mt_values
        ).
        r_value = 0.
      CATCH cx_sy_import_mismatch_error.
    ENDTRY.
  ENDMETHOD.


  METHOD save_msgs.
    r_value = 1.
    TRY.
        DATA(lv_data_string) = /ui2/cl_json=>serialize(
          data = mt_msgs
          compress = abap_true
          pretty_name = /ui2/cl_json=>pretty_mode-camel_case
        ).
        GET TIME STAMP FIELD DATA(lv_ts).
        EXPORT p_data = lv_data_string TO DATABASE ztbl_gdc(02) ID m_guid.
        UPDATE ztbl_gdc
          SET userid = @sy-uname, timestamp = @lv_ts
            WHERE relid = '02' AND id = @m_guid.
        r_value = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD save_props.
    r_value = 1.
    TRY.
        DATA(lv_data_string) = /ui2/cl_json=>serialize(
          data = mt_values
          compress = abap_true
          pretty_name = /ui2/cl_json=>pretty_mode-camel_case
        ).
        GET TIME STAMP FIELD DATA(lv_ts).
        EXPORT p_data = lv_data_string  TO DATABASE ztbl_gdc(01) ID m_guid.
        UPDATE ztbl_gdc
          SET userid = @sy-uname, timestamp = @lv_ts
            WHERE relid = '01' AND id = @m_guid.
        r_value = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD set_prop.
    r_value = 1.
    TRY.
        IF i_mem = abap_true.
          load_props( ).
        ENDIF.
        IF line_exists( mt_values[ m_key = i_name ] ).
          mt_values[ m_key = i_name ]-m_value = i_value.
        ELSE.
          INSERT VALUE #( m_key = i_name m_value = i_value ) INTO TABLE mt_values.
        ENDIF.
        IF i_mem = abap_true.
          save_props( ).
        ENDIF.
        r_value = 0.
    ENDTRY.
  ENDMETHOD.


  METHOD test.
    DATA(lv_guid) = cl_system_uuid=>create_uuid_c32_static( ).
    DATA(lo_mem) = get_area( i_guid = lv_guid ).

    lo_mem->add_msg(
      i_mem = 'X'
      i_msg = VALUE #( msgty = 'I' msgno = '000' msgid = 'BL'  msgv1 = 'Test: Inform' )
    ).
    lo_mem->set_prop( i_mem = 'X' i_name = 'prop01' i_value = 'prop01_value' ).
    lo_mem->set_prop( i_mem = 'X' i_name = 'prop02' i_value = 'prop02_value' ).
    FREE lo_mem.
    "
    lo_mem = get_area( i_mem = 'X' i_guid = lv_guid ).
    lo_mem->load_props( ).
    WRITE: 'prop01 = ', lo_mem->get_prop( i_name = 'prop01' ), /.
    WRITE: 'prop02 = ', lo_mem->get_prop( i_name = 'prop02' ), /.
    loop at lo_mem->mt_msgs ASSIGNING FIELD-SYMBOL(<fs_msg>).
      write: <fs_msg>-msgty, <fs_msg>-msgno, <fs_msg>-msgid, <fs_msg>-msgv1, /.
    endloop.
    FREE lo_mem.

  ENDMETHOD.
ENDCLASS.
