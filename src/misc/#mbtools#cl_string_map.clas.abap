CLASS /mbtools/cl_string_map DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

************************************************************************
* MBT String Map
*
* Original Author: Copyright (c) 2014 abapGit Contributors
* http://www.abapgit.org
* Renamed: to_abap > to_struc
*
* Released under MIT License: https://opensource.org/licenses/MIT
*
* Last update: 2020-11-30
************************************************************************

  PUBLIC SECTION.

    CONSTANTS version TYPE string VALUE 'v1.0.2' ##NEEDED.

    TYPES:
      BEGIN OF ty_entry,
        k TYPE string,
        v TYPE string,
      END OF ty_entry .
    TYPES:
      ty_entries TYPE STANDARD TABLE OF ty_entry WITH KEY k .
    TYPES:
      ty_entries_ts TYPE SORTED TABLE OF ty_entry WITH UNIQUE KEY k .

    DATA mt_entries TYPE ty_entries_ts READ-ONLY.

    CLASS-METHODS create
      IMPORTING
        !iv_case_insensitive TYPE abap_bool DEFAULT abap_false
        !iv_from             TYPE any OPTIONAL
      RETURNING
        VALUE(ro_instance)   TYPE REF TO /mbtools/cl_string_map .
    METHODS constructor
      IMPORTING
        !iv_case_insensitive TYPE abap_bool DEFAULT abap_false
        !iv_from             TYPE any OPTIONAL.

    METHODS get
      IMPORTING
        !iv_key       TYPE string
      RETURNING
        VALUE(rv_val) TYPE string .
    METHODS has
      IMPORTING
        !iv_key       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool .
    METHODS set
      IMPORTING
        !iv_key       TYPE string
        !iv_val       TYPE string
      RETURNING
        VALUE(ro_map) TYPE REF TO /mbtools/cl_string_map.
    METHODS size
      RETURNING
        VALUE(rv_size) TYPE i .
    METHODS is_empty
      RETURNING
        VALUE(rv_yes) TYPE abap_bool .
    METHODS delete
      IMPORTING
        !iv_key TYPE string .
    METHODS keys
      RETURNING
        VALUE(rt_keys) TYPE string_table .
    METHODS values
      RETURNING
        VALUE(rt_values) TYPE string_table .
    METHODS clear.
    METHODS to_struc
      CHANGING
        !cs_container TYPE any.
    METHODS from_struc
      IMPORTING
        !is_container TYPE any.
    METHODS from_entries
      IMPORTING
        !it_entries TYPE ANY TABLE.
    METHODS strict
      IMPORTING
        !iv_strict         TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(ro_instance) TYPE REF TO /mbtools/cl_string_map .
    METHODS freeze.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mv_is_strict TYPE abap_bool.
    DATA mv_read_only TYPE abap_bool.
    DATA mv_case_insensitive TYPE abap_bool.
ENDCLASS.



CLASS /mbtools/cl_string_map IMPLEMENTATION.


  METHOD clear.

    IF mv_read_only = abap_true.
      lcx_error=>raise( 'String map is read only' ).
    ENDIF.

    CLEAR mt_entries.

  ENDMETHOD.


  METHOD constructor.
    mv_is_strict = abap_true.
    mv_case_insensitive = iv_case_insensitive.

    IF iv_from IS NOT INITIAL.
      DATA lo_type TYPE REF TO cl_abap_typedescr.
      lo_type = cl_abap_typedescr=>describe_by_data( iv_from ).

      CASE lo_type->type_kind.
        WHEN cl_abap_typedescr=>typekind_struct1 OR cl_abap_typedescr=>typekind_struct2.
          from_struc( iv_from ).

        WHEN cl_abap_typedescr=>typekind_oref.
          DATA lo_from TYPE REF TO /mbtools/cl_string_map.
          TRY.
              lo_from ?= iv_from.
            CATCH cx_sy_move_cast_error.
              lcx_error=>raise( 'Incorrect string map instance to copy from' ).
          ENDTRY.
          mt_entries = lo_from->mt_entries.

        WHEN cl_abap_typedescr=>typekind_table.
          from_entries( iv_from ).

        WHEN OTHERS.
          lcx_error=>raise( |Incorrect input for string_map=>create, typekind { lo_type->type_kind }| ).
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD create.
    CREATE OBJECT ro_instance
      EXPORTING
        iv_case_insensitive = iv_case_insensitive
        iv_from             = iv_from.
  ENDMETHOD.


  METHOD delete.

    IF mv_read_only = abap_true.
      lcx_error=>raise( 'String map is read only' ).
    ENDIF.

    DELETE mt_entries WHERE k = iv_key.

  ENDMETHOD.


  METHOD freeze.
    mv_read_only = abap_true.
  ENDMETHOD.


  METHOD from_entries.

    FIELD-SYMBOLS <i> TYPE ty_entry.

    IF mv_read_only = abap_true.
      lcx_error=>raise( 'String map is read only' ).
    ENDIF.

    LOOP AT it_entries ASSIGNING <i> CASTING.
      set(
        iv_key = <i>-k
        iv_val = <i>-v ).
    ENDLOOP.

  ENDMETHOD.


  METHOD from_struc.

    DATA lo_type TYPE REF TO cl_abap_typedescr.
    DATA lo_struc TYPE REF TO cl_abap_structdescr.
    FIELD-SYMBOLS <c> LIKE LINE OF lo_struc->components.
    FIELD-SYMBOLS <val> TYPE any.

    IF mv_read_only = abap_true.
      lcx_error=>raise( 'String map is read only' ).
    ENDIF.

    CLEAR mt_entries.

    lo_type = cl_abap_typedescr=>describe_by_data( is_container ).
    IF lo_type->type_kind <> cl_abap_typedescr=>typekind_struct1
      AND lo_type->type_kind <> cl_abap_typedescr=>typekind_struct2.
      lcx_error=>raise( 'Only structures supported' ).
    ENDIF.

    lo_struc ?= lo_type.
    LOOP AT lo_struc->components ASSIGNING <c>.
      CHECK <c>-type_kind CO 'bsI8PaeFCNgXyDT'. " values
      ASSIGN COMPONENT <c>-name OF STRUCTURE is_container TO <val>.
      ASSERT sy-subrc = 0.
      set(
        iv_key = |{ <c>-name }|
        iv_val = |{ <val> }| ).
    ENDLOOP.

  ENDMETHOD.


  METHOD get.

    DATA lv_key LIKE iv_key.
    FIELD-SYMBOLS <entry> LIKE LINE OF mt_entries.

    IF mv_case_insensitive = abap_true.
      lv_key = to_upper( iv_key ).
    ELSE.
      lv_key = iv_key.
    ENDIF.

    READ TABLE mt_entries ASSIGNING <entry> WITH KEY k = lv_key.
    IF sy-subrc = 0.
      rv_val = <entry>-v.
    ENDIF.

  ENDMETHOD.


  METHOD has.

    READ TABLE mt_entries TRANSPORTING NO FIELDS WITH KEY k = iv_key.
    rv_has = boolc( sy-subrc = 0 ).

  ENDMETHOD.


  METHOD is_empty.
    rv_yes = boolc( lines( mt_entries ) = 0 ).
  ENDMETHOD.


  METHOD keys.

    FIELD-SYMBOLS <entry> LIKE LINE OF mt_entries.
    LOOP AT mt_entries ASSIGNING <entry>.
      APPEND <entry>-k TO rt_keys.
    ENDLOOP.

  ENDMETHOD.


  METHOD set.

    DATA ls_entry LIKE LINE OF mt_entries.
    DATA lv_key LIKE iv_key.
    FIELD-SYMBOLS <entry> LIKE LINE OF mt_entries.

    IF mv_read_only = abap_true.
      lcx_error=>raise( 'String map is read only' ).
    ENDIF.

    IF mv_case_insensitive = abap_true.
      lv_key = to_upper( iv_key ).
    ELSE.
      lv_key = iv_key.
    ENDIF.

    READ TABLE mt_entries ASSIGNING <entry> WITH KEY k = lv_key.
    IF sy-subrc = 0.
      <entry>-v = iv_val.
    ELSE.
      ls_entry-k = lv_key.
      ls_entry-v = iv_val.
      INSERT ls_entry INTO TABLE mt_entries.
    ENDIF.

    ro_map = me.

  ENDMETHOD.


  METHOD size.

    rv_size = lines( mt_entries ).

  ENDMETHOD.


  METHOD strict.
    mv_is_strict = iv_strict.
    ro_instance = me.
  ENDMETHOD.


  METHOD to_struc.

    DATA lo_type TYPE REF TO cl_abap_typedescr.
    DATA lv_field TYPE string.
    FIELD-SYMBOLS <entry> LIKE LINE OF mt_entries.
    FIELD-SYMBOLS <val> TYPE any.

    lo_type = cl_abap_typedescr=>describe_by_data( cs_container ).
    IF lo_type->type_kind <> cl_abap_typedescr=>typekind_struct1
      AND lo_type->type_kind <> cl_abap_typedescr=>typekind_struct2.
      lcx_error=>raise( 'Only structures supported' ).
    ENDIF.

    LOOP AT mt_entries ASSIGNING <entry>.
      lv_field = to_upper( <entry>-k ).
      ASSIGN COMPONENT lv_field OF STRUCTURE cs_container TO <val>.
      IF sy-subrc = 0.
        " TODO check target type ?
        <val> = <entry>-v.
      ELSEIF mv_is_strict = abap_false.
        CONTINUE.
      ELSE.
        lcx_error=>raise( |Component { lv_field } not found in target| ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD values.

    FIELD-SYMBOLS <entry> LIKE LINE OF mt_entries.
    LOOP AT mt_entries ASSIGNING <entry>.
      APPEND <entry>-v TO rt_values.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
