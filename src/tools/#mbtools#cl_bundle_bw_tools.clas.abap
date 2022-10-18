CLASS /mbtools/cl_bundle_bw_tools DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

************************************************************************
* MBT BW Bundle
*
* Copyright 2021 Marc Bernard <https://marcbernardtools.com/>
* SPDX-License-Identifier: GPL-3.0-only
************************************************************************
  PUBLIC SECTION.

    INTERFACES /mbtools/if_tool.

    CONSTANTS:
      BEGIN OF c_tool,
        version     TYPE string VALUE '1.0.0' ##NO_TEXT,
        title       TYPE string VALUE 'BW Tools' ##NO_TEXT,
        is_bundle   TYPE c VALUE abap_true,
        bundle_id   TYPE i VALUE 2,
        download_id TYPE i VALUE 5653,
        description TYPE string VALUE
        'World-class tools and enhancements for SAP BW and SAP BW/4HANA' ##NO_TEXT,
      END OF c_tool.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /mbtools/cl_bundle_bw_tools IMPLEMENTATION.


  METHOD /mbtools/if_tool~install.
    RETURN.
  ENDMETHOD.


  METHOD /mbtools/if_tool~launch.
    RETURN.
  ENDMETHOD.


  METHOD /mbtools/if_tool~title.
    rv_title = c_tool-title.
  ENDMETHOD.


  METHOD /mbtools/if_tool~tool.
    MOVE-CORRESPONDING c_tool TO rs_tool.
  ENDMETHOD.


  METHOD /mbtools/if_tool~uninstall.
    RETURN.
  ENDMETHOD.
ENDCLASS.
