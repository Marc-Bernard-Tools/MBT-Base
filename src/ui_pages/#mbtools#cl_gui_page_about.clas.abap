CLASS /mbtools/cl_gui_page_about DEFINITION
  PUBLIC
  INHERITING FROM /mbtools/cl_gui_component
  FINAL
  CREATE PUBLIC .

************************************************************************
* MBT GUI Page About
*
* Original Author: Copyright (c) 2014 abapGit Contributors
* http://www.abapgit.org
*
* Released under MIT License: https://opensource.org/licenses/MIT
************************************************************************
  PUBLIC SECTION.

    INTERFACES /mbtools/if_gui_event_handler .
    INTERFACES /mbtools/if_gui_renderable .
    INTERFACES /mbtools/if_gui_hotkeys .

    METHODS constructor
      RAISING
        /mbtools/cx_exception .
    CLASS-METHODS create
      RETURNING
        VALUE(ri_page) TYPE REF TO /mbtools/if_gui_renderable
      RAISING
        /mbtools/cx_exception .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mo_asset_manager TYPE REF TO /mbtools/if_gui_asset_manager .

    CLASS-METHODS build_menu
      RETURNING
        VALUE(ro_menu) TYPE REF TO /mbtools/cl_html_toolbar .
    METHODS register_header
      RAISING
        /mbtools/cx_exception .
    METHODS render_about
      RETURNING
        VALUE(ri_html) TYPE REF TO /mbtools/if_html
      RAISING
        /mbtools/cx_exception .
ENDCLASS.



CLASS /MBTOOLS/CL_GUI_PAGE_ABOUT IMPLEMENTATION.


  METHOD /mbtools/if_gui_event_handler~on_event.

  ENDMETHOD.


  METHOD /mbtools/if_gui_hotkeys~get_hotkey_actions.

  ENDMETHOD.


  METHOD /mbtools/if_gui_renderable~render.

    gui_services( )->register_event_handler( me ).
    gui_services( )->get_hotkeys_ctl( )->register_hotkeys( me ).

    ri_html = /mbtools/cl_html=>create( ).

    ri_html->add( render_about( ) ).

    gui_services( )->cache_all_assets( mo_asset_manager ).

  ENDMETHOD.


  METHOD build_menu.

    DATA:
      lo_support_menu TYPE REF TO /mbtools/cl_html_toolbar,
      lo_bar_menu     TYPE REF TO /mbtools/cl_html_toolbar.

    CREATE OBJECT ro_menu EXPORTING iv_id = 'toolbar-main'.

    CREATE OBJECT lo_support_menu.

    lo_support_menu->add(
      iv_txt = 'FAQ'
      iv_act = /mbtools/if_actions=>go_faq
    )->add(
      iv_txt = 'Documentation'
      iv_act = /mbtools/if_actions=>mbt_docs
    )->add(
      iv_txt = 'Ticket'
      iv_act = /mbtools/if_actions=>mbt_support ).

    CREATE OBJECT lo_bar_menu.

    lo_bar_menu->add(
      iv_txt = 'Home'
      iv_act = /mbtools/if_actions=>go_home
    )->add(
      iv_txt = 'Website'
      iv_act = /mbtools/if_actions=>mbt_website
    )->add(
      iv_txt = 'About'
      iv_act = /mbtools/if_actions=>go_about ).

    ro_menu->add(
      iv_txt = 'Support'
      io_sub = lo_support_menu
    )->add(
      iv_txt = /mbtools/cl_html=>icon( iv_name  = 'bars/grey' )
      io_sub = lo_bar_menu ).

  ENDMETHOD.


  METHOD constructor.

    super->constructor( ).

    mo_asset_manager = /mbtools/cl_gui_factory=>get_asset_manager( ).

    register_header( ).

  ENDMETHOD.


  METHOD create.

    DATA lo_component TYPE REF TO /mbtools/cl_gui_page_about.

    CREATE OBJECT lo_component.

    ri_page = /mbtools/cl_gui_page=>create(
      iv_has_logo        = abap_true
      iv_has_banner      = abap_false
      iv_page_title      = 'About'
      io_page_menu       = build_menu( )
      ii_child_component = lo_component ).

  ENDMETHOD.


  METHOD register_header.

    mo_asset_manager->register_asset(
      iv_url       = 'img/logo_header.png'
      iv_type      = 'image/png'
      iv_mime_name = '/MBTOOLS/LOGO_HEADER' ).

    mo_asset_manager->register_asset(
      iv_url       = 'img/banner_header.png'
      iv_type      = 'image/png'
      iv_mime_name = '/MBTOOLS/BANNER_HEADER' ).

  ENDMETHOD.


  METHOD render_about.

    ri_html = /mbtools/cl_html=>create( ).

    ri_html->add( '<div class="bundles">' ).

    ri_html->add( '<p>About MBT</p>' ).

    ri_html->add( '</div>' ).

  ENDMETHOD.
ENDCLASS.
