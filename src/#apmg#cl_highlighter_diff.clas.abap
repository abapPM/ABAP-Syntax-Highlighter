CLASS /apmg/cl_highlighter_diff DEFINITION
  PUBLIC
  INHERITING FROM /apmg/cl_highlighter
  CREATE PUBLIC.

************************************************************************
* Syntax Highlighter
*
* Copyright (c) 2014 abapGit Contributors
* SPDX-License-Identifier: MIT
************************************************************************
  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF c_css,
        ins     TYPE string VALUE 'diff_ins',
        del     TYPE string VALUE 'diff_del',
        test    TYPE string VALUE 'diff_upd',
        comment TYPE string VALUE 'comment',
      END OF c_css,
      BEGIN OF c_token,
        ins     TYPE c VALUE 'I',
        del     TYPE c VALUE 'D',
        test    TYPE c VALUE 'T',
        comment TYPE c VALUE 'C',
      END OF c_token,
      BEGIN OF c_regex,
        ins     TYPE string VALUE '^\+.*',
        del     TYPE string VALUE '^-.*',
        test    TYPE string VALUE '^!.*',
        comment TYPE string VALUE '^#.*',
      END OF c_regex.

    METHODS constructor.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /apmg/cl_highlighter_diff IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    " Initialize instances of regular expressions

    add_rule( regex = c_regex-ins
              token = c_token-ins
              style = c_css-ins ).

    add_rule( regex = c_regex-del
              token = c_token-del
              style = c_css-del ).

    add_rule( regex = c_regex-test
              token = c_token-test
              style = c_css-test ).

    add_rule( regex = c_regex-comment
              token = c_token-comment
              style = c_css-comment ).

  ENDMETHOD.
ENDCLASS.
