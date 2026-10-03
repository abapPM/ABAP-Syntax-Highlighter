CLASS ltcl_highlighter_xml DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA cut TYPE REF TO /apmg/cl_highlighter_xml.

    METHODS:
      setup,
      sole_closing_xml_tag FOR TESTING RAISING cx_static_check,
      complete_xml_tag FOR TESTING RAISING cx_static_check,
      complete_xml_tag_with_closing FOR TESTING RAISING cx_static_check,
      empty_attributes FOR TESTING RAISING cx_static_check,
      open_tags FOR TESTING RAISING cx_static_check,
      attributes_only FOR TESTING RAISING cx_static_check,
      attribute_value_equal_signs FOR TESTING RAISING cx_static_check,
      multi_line_comments FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_highlighter_xml IMPLEMENTATION.

  METHOD setup.

    cut = NEW #( ).

  ENDMETHOD.

  METHOD sole_closing_xml_tag.

    cl_abap_unit_assert=>assert_equals(
      exp = |<span class="xml_tag">&gt;</span>|
      act = cut->process_line( |>| ) ).

  ENDMETHOD.

  METHOD complete_xml_tag.

    cl_abap_unit_assert=>assert_equals(
      exp = |<span class="xml_tag">&lt;tag&gt;</span>|
      act = cut->process_line( |<tag>| ) ).

  ENDMETHOD.

  METHOD complete_xml_tag_with_closing.

    cl_abap_unit_assert=>assert_equals(
      exp = |<span class="xml_tag">&lt;tag/&gt;</span>|
      act = cut->process_line( |<tag/>| ) ).

  ENDMETHOD.

  METHOD empty_attributes.

    cl_abap_unit_assert=>assert_equals(
      exp = |<span class="xml_tag">&lt;ECTD</span>|
         && |<span class="attr"> SAPRL</span>=|
         && |<span class="attr_val">"751"</span>|
         && |<span class="attr"> VERSION</span>=|
         && |<span class="attr_val">"1.5"</span>|
         && |<span class="attr"> DOWNLOADDATE</span>=<span class="attr_val">""</span>|
         && |<span class="attr"> DOWNLOADTIME</span>=<span class="attr_val">""</span>|
         && |<span class="xml_tag">&gt;</span>|
      act = cut->process_line( |<ECTD SAPRL="751" VERSION="1.5" DOWNLOADDATE="" DOWNLOADTIME="">| ) ).

  ENDMETHOD.

  METHOD attributes_only.

    cl_abap_unit_assert=>assert_equals(
      exp = |<span class="attr"> SAPRL</span>=|
         && |<span class="attr_val">"751"</span>|
         && |<span class="attr"> VERSION</span>=|
         && |<span class="attr_val">"&gt;1.5"</span>|
      act = cut->process_line( | SAPRL="751" VERSION=">1.5"| ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = |<span class="attr">SAPRL</span>=|
         && |<span class="attr_val">"751"</span>|
         && |<span class="attr"> VERSION</span>=|
         && |<span class="attr_val">'&gt;1.5'</span>|
      act = cut->process_line( |SAPRL="751" VERSION='>1.5'| ) ).

  ENDMETHOD.

  METHOD open_tags.

    cl_abap_unit_assert=>assert_equals(
      exp = |<span class="xml_tag">&lt;ECTD</span>|
      act = cut->process_line( |<ECTD| ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = |<span class="xml_tag">&lt;ECTD</span>|
         && |<span class="attr"> SAPRL</span>=|
         && |<span class="attr_val">"751"</span>|
         && |<span class="attr"> VERSION</span>=|
         && |<span class="attr_val">"1.5"</span>|
      act = cut->process_line( |<ECTD SAPRL="751" VERSION="1.5"| ) ).

  ENDMETHOD.

  METHOD attribute_value_equal_signs.

    cl_abap_unit_assert=>assert_equals(
      exp = |<span class="xml_tag">&lt;meta</span>|
         && |<span class="attr"> name</span>=|
         && |<span class="attr_val">"viewport"</span>|
         && |<span class="attr"> content</span>=|
         && |<span class="attr_val">"width=device, initial=1.0, maximum=1.0"</span>|
         && |<span class="xml_tag">&gt;</span>|
      act = cut->process_line( |<meta name="viewport" content="width=device, initial=1.0, maximum=1.0">| ) ).

  ENDMETHOD.

  METHOD multi_line_comments.

    cl_abap_unit_assert=>assert_equals(
      exp = |<span class="comment">&lt;!-- comment</span>|
      act = cut->process_line( |<!-- comment| ) ).

    " New instance (i.e. different file)
    cut = NEW #( ).

    cl_abap_unit_assert=>assert_equals(
      exp = |<span class="xml_tag">&lt;tag&gt;</span>|
      act = cut->process_line( |<tag>| ) ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_syntax_cases DEFINITION DEFERRED.

CLASS /apmg/cl_highlighter_xml DEFINITION LOCAL FRIENDS ltcl_syntax_cases.

*----------------------------------------------------------------------*
*       CLASS ltcl_syntax_cases definition
*----------------------------------------------------------------------*
CLASS ltcl_syntax_cases DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    DATA:
      after_parse  TYPE /apmg/cl_highlighter_xml=>ty_match_tt,
      after_order  TYPE /apmg/cl_highlighter_xml=>ty_match_tt,
      after_extend TYPE /apmg/cl_highlighter_xml=>ty_match_tt.

    METHODS:
      do_test IMPORTING line TYPE string,
      generate_parse IMPORTING token  TYPE c
                               offset TYPE i
                               length TYPE i,
      generate_order IMPORTING token    TYPE c
                               offset   TYPE i
                               length   TYPE i
                               text_tag TYPE string,
      generate_extend IMPORTING token    TYPE c
                                offset   TYPE i
                                length   TYPE i
                                text_tag TYPE string,
      test_xml_01 FOR TESTING,
      test_xml_02 FOR TESTING,
      test_xml_03 FOR TESTING,
      test_xml_04 FOR TESTING,
      test_xml_05 FOR TESTING,
      test_xml_06 FOR TESTING,
      test_xml_07 FOR TESTING,
      test_xml_08 FOR TESTING,
      test_xml_09 FOR TESTING.

ENDCLASS.
*----------------------------------------------------------------------*
*       CLASS ltcl_syntax_cases IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS ltcl_syntax_cases IMPLEMENTATION.

  METHOD do_test.

    DATA(syntax_highlighter) = NEW /apmg/cl_highlighter_xml( ).
    DATA(matches_act) = syntax_highlighter->parse_line( line ).

    SORT matches_act BY offset.

    cl_abap_unit_assert=>assert_equals( exp = after_parse
                                        act = matches_act
                                        msg = | Error during parsing: { line }| ).

    syntax_highlighter->order_matches( EXPORTING line    = line
                       CHANGING  matches = matches_act ).

    cl_abap_unit_assert=>assert_equals( exp = after_order
                                        act = matches_act
                                        msg = | Error during ordering: { line }| ).

    syntax_highlighter->extend_matches(
      EXPORTING
        line    = line
      CHANGING
        matches = matches_act ).

    cl_abap_unit_assert=>assert_equals( exp = after_extend
                                        act = matches_act
                                        msg = | Error during extending: { line }| ).

    " Check consistency
    DATA(offs) = 0.
    LOOP AT matches_act INTO DATA(match).
      IF match-offset <> offs.
        cl_abap_unit_assert=>assert_equals( exp = offs
                                            act = match-offset
                                            msg = | Error during consistency check: { sy-tabix }| ).
      ENDIF.
      offs = offs + match-length.
    ENDLOOP.

  ENDMETHOD.

  METHOD generate_parse.
    DATA(match) = VALUE /apmg/cl_highlighter_xml=>ty_match(
      token  = token
      offset = offset
      length = length ).
    APPEND match TO after_parse.
  ENDMETHOD.

  METHOD generate_order.
    DATA(match) = VALUE /apmg/cl_highlighter_xml=>ty_match(
      token    = token
      offset   = offset
      length   = length
      text_tag = text_tag ).
    APPEND match TO after_order.
  ENDMETHOD.

  METHOD generate_extend.
    DATA(match) = VALUE /apmg/cl_highlighter_xml=>ty_match(
      token    = token
      offset   = offset
      length   = length
      text_tag = text_tag ).
    APPEND match TO after_extend.
  ENDMETHOD.

********************************************************
* Test parsing and ordering of tags in xml             *
********************************************************
  METHOD test_xml_01.

    DATA(line) = `<tag>Text</tag>`.

    " Generate table with expected values after parsing
    generate_parse( token  = 'X'
                    offset = 0
                    length = 1 ).
    generate_parse( token  = 'X'
                    offset = 4
                    length = 1 ).
    generate_parse( token  = 'X'
                    offset = 9
                    length = 1 ).
    generate_parse( token  = 'X'
                    offset = 14
                    length = 1 ).

    " Generate table with expected values after ordering

    generate_order( token    = 'X'
                    offset   = 0
                    length   = 5
                    text_tag = '<' ).
    generate_order( token    = 'X'
                    offset   = 9
                    length   = 6
                    text_tag = '<' ).

    " Generate table with expected values after extending
    generate_extend( token    = 'X'
                     offset   = 0
                     length   = 5
                     text_tag = '<' ).
    generate_extend( token    = '.'
                     offset   = 5
                     length   = 4
                     text_tag = '' ).
    generate_extend( token    = 'X'
                     offset   = 9
                     length   = 6
                     text_tag = '<' ).

    do_test( line ).

  ENDMETHOD.

  METHOD test_xml_02.

    DATA(line) = `<tag/>`.

    " Generate table with expected values after parsing
    generate_parse( token  = 'X'
                    offset = 0
                    length = 1 ).
    generate_parse( token  = 'X'
                    offset = 5
                    length = 1 ).

    " Generate table with expected values after ordering
    generate_order( token    = 'X'
                    offset   = 0
                    length   = 6
                    text_tag = '<' ).
    " Generate table with expected values after extending
    generate_extend( token    = 'X'
                     offset   = 0
                     length   = 6
                     text_tag = '<' ).

    do_test( line ).

  ENDMETHOD.

  METHOD test_xml_03.

    DATA(line) = `<tag attribute="value"/>`.

    " Generate table with expected values after parsing
    generate_parse( token  = 'X'
                    offset = 0
                    length = 1 ).
    generate_parse( token  = 'A'
                    offset = 4
                    length = 10 ).
    generate_parse( token  = 'V'
                    offset = 15
                    length = 7 ).
    generate_parse( token  = 'X'
                    offset = 23
                    length = 1 ).

    " Generate table with expected values after ordering
    generate_order( token    = 'X'
                    offset   = 0
                    length   = 4
                    text_tag = '<' ).
    generate_order( token    = 'A'
                    offset   = 4
                    length   = 10
                    text_tag = '' ).
    generate_order( token    = 'V'
                    offset   = 15
                    length   = 7
                    text_tag = '' ).
    generate_order( token    = 'X'
                    offset   = 22
                    length   = 2
                    text_tag = '>' ).

    " Generate table with expected values after extending
    generate_extend( token    = 'X'
                     offset   = 0
                     length   = 4
                     text_tag = '<' ).
    generate_extend( token    = 'A'
                     offset   = 4
                     length   = 10
                     text_tag = '' ).
    generate_extend( token    = '.'
                     offset   = 14
                     length   = 1
                     text_tag = '' ).
    generate_extend( token    = 'V'
                     offset   = 15
                     length   = 7
                     text_tag = '' ).
    generate_extend( token    = 'X'
                     offset   = 22
                     length   = 2
                     text_tag = '>' ).

    do_test( line ).

  ENDMETHOD.

  METHOD test_xml_04.

    DATA(line) = `<?xml version="1.0"?>`.

    " Generate table with expected values after parsing
    generate_parse( token  = 'X'
                    offset = 0
                    length = 1 ).
    generate_parse( token  = 'A'
                    offset = 5
                    length = 8 ).
    generate_parse( token  = 'V'
                    offset = 14
                    length = 5 ).
    generate_parse( token  = 'X'
                    offset = 20
                    length = 1 ).

    " Generate table with expected values after ordering
    generate_order( token    = 'X'
                    offset   = 0
                    length   = 5
                    text_tag = '<' ).
    generate_order( token    = 'A'
                    offset   = 5
                    length   = 8
                    text_tag = '' ).
    generate_order( token    = 'V'
                    offset   = 14
                    length   = 5
                    text_tag = '' ).
    generate_order( token    = 'X'
                    offset   = 19
                    length   = 2
                    text_tag = '>' ).

    " Generate table with expected values after extending
    generate_extend( token    = 'X'
                     offset   = 0
                     length   = 5
                     text_tag = '<' ).
    generate_extend( token    = 'A'
                     offset   = 5
                     length   = 8
                     text_tag = '' ).
    generate_extend( token    = '.'
                     offset   = 13
                     length   = 1
                     text_tag = '' ).
    generate_extend( token    = 'V'
                     offset   = 14
                     length   = 5
                     text_tag = '' ).
    generate_extend( token    = 'X'
                     offset   = 19
                     length   = 2
                     text_tag = '>' ).

    do_test( line ).

  ENDMETHOD.

  METHOD test_xml_05.

    DATA(line) = `<ns:tag ns:a1="v1" ns:a2='v2'>"text"</ns:tag>`.

    " Generate table with expected values after parsing
    generate_parse( token  = 'X'
                    offset = 0
                    length = 1 ).
    generate_parse( token  = 'A'
                    offset = 7
                    length = 6 ).
    generate_parse( token  = 'V'
                    offset = 14
                    length = 4 ).
    generate_parse( token  = 'A'
                    offset = 18
                    length = 6 ).
    generate_parse( token  = 'V'
                    offset = 25
                    length = 4 ).
    generate_parse( token  = 'X'
                    offset = 29
                    length = 1 ).
    generate_parse( token  = 'V'
                    offset = 30
                    length = 6 ).
    generate_parse( token  = 'X'
                    offset = 36
                    length = 1 ).
    generate_parse( token  = 'X'
                    offset = 44
                    length = 1 ).

    " Generate table with expected values after ordering
    generate_order( token    = 'X'
                    offset   = 0
                    length   = 7
                    text_tag = '<' ).
    generate_order( token    = 'A'
                    offset   = 7
                    length   = 6
                    text_tag = '' ).
    generate_order( token    = 'V'
                    offset   = 14
                    length   = 4
                    text_tag = '' ).
    generate_order( token    = 'A'
                    offset   = 18
                    length   = 6
                    text_tag = '' ).
    generate_order( token    = 'V'
                    offset   = 25
                    length   = 4
                    text_tag = '' ).
    generate_order( token    = 'X'
                    offset   = 29
                    length   = 1
                    text_tag = '>' ).
    generate_order( token    = 'X'
                    offset   = 36
                    length   = 9
                    text_tag = '<' ).

    " Generate table with expected values after extending
    generate_extend( token    = 'X'
                     offset   = 0
                     length   = 7
                     text_tag = '<' ).
    generate_extend( token    = 'A'
                     offset   = 7
                     length   = 6
                     text_tag = '' ).
    generate_extend( token    = '.'
                     offset   = 13
                     length   = 1
                     text_tag = '' ).
    generate_extend( token    = 'V'
                     offset   = 14
                     length   = 4
                     text_tag = '' ).
    generate_extend( token    = 'A'
                     offset   = 18
                     length   = 6
                     text_tag = '' ).
    generate_extend( token    = '.'
                     offset   = 24
                     length   = 1
                     text_tag = '' ).
    generate_extend( token    = 'V'
                     offset   = 25
                     length   = 4
                     text_tag = '' ).
    generate_extend( token    = 'X'
                     offset   = 29
                     length   = 1
                     text_tag = '>' ).
    generate_extend( token    = '.'
                     offset   = 30
                     length   = 6
                     text_tag = '' ).
    generate_extend( token    = 'X'
                     offset   = 36
                     length   = 9
                     text_tag = '<' ).

    do_test( line ).

  ENDMETHOD.

  METHOD test_xml_06.

    "unclosed tag
    DATA(line) = `<ns:tag ns:a1="v1"`.

    " Generate table with expected values after parsing
    generate_parse( token  = 'X'
                    offset = 0
                    length = 1 ).
    generate_parse( token  = 'A'
                    offset = 7
                    length = 6 ).
    generate_parse( token  = 'V'
                    offset = 14
                    length = 4 ).

    " Generate table with expected values after ordering
    generate_order( token    = 'X'
                    offset   = 0
                    length   = 7
                    text_tag = '<' ).
    generate_order( token    = 'A'
                    offset   = 7
                    length   = 6
                    text_tag = '' ).
    generate_order( token    = 'V'
                    offset   = 14
                    length   = 4
                    text_tag = '' ).

    " Generate table with expected values after extending
    generate_extend( token    = 'X'
                     offset   = 0
                     length   = 7
                     text_tag = '<' ).
    generate_extend( token    = 'A'
                     offset   = 7
                     length   = 6
                     text_tag = '' ).
    generate_extend( token    = '.'
                     offset   = 13
                     length   = 1
                     text_tag = '' ).
    generate_extend( token    = 'V'
                     offset   = 14
                     length   = 4
                     text_tag = '' ).

    do_test( line ).

  ENDMETHOD.

  METHOD test_xml_07.

    "invalid XML characters in a string

    "xml special characters in attribute
    DATA(line) = `<tag attribute=" ' > "/>`.

    " Generate table with expected values after parsing
    generate_parse( token  = 'X'
                    offset = 0
                    length = 1 ).
    generate_parse( token  = 'A'
                    offset = 4
                    length = 10 ).
    generate_parse( token  = 'V'
                    offset = 15
                    length = 7 ).
    generate_parse( token  = 'X'
                    offset = 23
                    length = 1 ).

    " Generate table with expected values after ordering
    generate_order( token    = 'X'
                    offset   = 0
                    length   = 4
                    text_tag = '<' ).
    generate_order( token    = 'A'
                    offset   = 4
                    length   = 10
                    text_tag = '' ).
    generate_order( token    = 'V'
                    offset   = 15
                    length   = 7
                    text_tag = '' ).
    generate_order( token    = 'X'
                    offset   = 22
                    length   = 2
                    text_tag = '>' ).

    " Generate table with expected values after extending
    generate_extend( token    = 'X'
                     offset   = 0
                     length   = 4
                     text_tag = '<' ).
    generate_extend( token    = 'A'
                     offset   = 4
                     length   = 10
                     text_tag = '' ).
    generate_extend( token    = '.'
                     offset   = 14
                     length   = 1
                     text_tag = '' ).
    generate_extend( token    = 'V'
                     offset   = 15
                     length   = 7
                     text_tag = '' ).
    generate_extend( token    = 'X'
                     offset   = 22
                     length   = 2
                     text_tag = '>' ).

    do_test( line ).

  ENDMETHOD.

  METHOD test_xml_08.

    "invalid XML characters in a string

    "attribute at beginning of line
    DATA(line) = `attribute='>" '`.

    " Generate table with expected values after parsing
    generate_parse( token  = 'A'
                    offset = 0
                    length = 9 ).
    generate_parse( token  = 'V'
                    offset = 10
                    length = 5 ).

    " Generate table with expected values after ordering
    generate_order( token    = 'A'
                    offset   = 0
                    length   = 9
                    text_tag = '' ).
    generate_order( token    = 'V'
                    offset   = 10
                    length   = 5
                    text_tag = '' ).

    " Generate table with expected values after extending
    generate_extend( token    = 'A'
                     offset   = 0
                     length   = 9
                     text_tag = '' ).
    generate_extend( token    = '.'
                     offset   = 9
                     length   = 1
                     text_tag = '' ).
    generate_extend( token    = 'V'
                     offset   = 10
                     length   = 5
                     text_tag = '' ).

    do_test( line ).

  ENDMETHOD.

  METHOD test_xml_09.

    "back quotes used for attribute values (HTML)

    DATA(line) = |<tag attribute=`value`/>|.

    " Generate table with expected values after parsing
    generate_parse( token  = 'X'
                    offset = 0
                    length = 1 ).
    generate_parse( token  = 'A'
                    offset = 4
                    length = 10 ).
    generate_parse( token  = 'V'
                    offset = 15
                    length = 7 ).
    generate_parse( token  = 'X'
                    offset = 23
                    length = 1 ).

    " Generate table with expected values after ordering
    generate_order( token    = 'X'
                    offset   = 0
                    length   = 4
                    text_tag = '<' ).
    generate_order( token    = 'A'
                    offset   = 4
                    length   = 10
                    text_tag = '' ).
    generate_order( token    = 'V'
                    offset   = 15
                    length   = 7
                    text_tag = '' ).
    generate_order( token    = 'X'
                    offset   = 22
                    length   = 2
                    text_tag = '>' ).

    " Generate table with expected values after extending
    generate_extend( token    = 'X'
                     offset   = 0
                     length   = 4
                     text_tag = '<' ).
    generate_extend( token    = 'A'
                     offset   = 4
                     length   = 10
                     text_tag = '' ).
    generate_extend( token    = '.'
                     offset   = 14
                     length   = 1
                     text_tag = '' ).
    generate_extend( token    = 'V'
                     offset   = 15
                     length   = 7
                     text_tag = '' ).
    generate_extend( token    = 'X'
                     offset   = 22
                     length   = 2
                     text_tag = '>' ).

    do_test( line ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_xml_regressions DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA cut TYPE REF TO /apmg/cl_highlighter_xml.
    METHODS:
      setup,
      separate_comments FOR TESTING,
      quoted_comment_markers FOR TESTING,
      comment_first_end FOR TESTING,
      comment_nested_start FOR TESTING,
      instance_isolation FOR TESTING,
      dotted_attributes FOR TESTING,
      text_after_comment FOR TESTING,
      nested_quotes FOR TESTING,
      quotes_in_comments FOR TESTING.
ENDCLASS.


CLASS ltcl_xml_regressions IMPLEMENTATION.
  METHOD setup.
    cut = NEW #( ).
  ENDMETHOD.

  METHOD separate_comments.
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( '<!-- first --><tag/><!-- second -->' )
      exp = |<span class="comment">&lt;!-- first --&gt;</span>|
         && |<span class="xml_tag">&lt;tag/&gt;</span>|
         && |<span class="comment">&lt;!-- second --&gt;</span>| ).
  ENDMETHOD.

  METHOD quoted_comment_markers.
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( '<tag value="-->"/>' )
      exp = |<span class="xml_tag">&lt;tag</span><span class="attr"> value</span>=|
         && |<span class="attr_val">"--&gt;"</span><span class="xml_tag">/&gt;</span>| ).
  ENDMETHOD.

  METHOD comment_first_end.
    cut->process_line( '<!-- open' ).
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( '<tag --> <next/>' )
      exp = |<span class="comment">&lt;tag --&gt;</span> <span class="xml_tag">&lt;next/&gt;</span>| ).
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( '<last/>' )
      exp = |<span class="xml_tag">&lt;last/&gt;</span>| ).
  ENDMETHOD.

  METHOD comment_nested_start.
    cut->process_line( '<!-- open' ).
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( 'prefix <!-- nested --> <next/>' )
      exp = |<span class="comment">prefix &lt;!-- nested --&gt;</span> |
         && |<span class="xml_tag">&lt;next/&gt;</span>| ).
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( '<last/>' )
      exp = |<span class="xml_tag">&lt;last/&gt;</span>| ).
  ENDMETHOD.

  METHOD instance_isolation.
    cut->process_line( '<!-- open' ).
    DATA(other) = NEW /apmg/cl_highlighter_xml( ).
    cl_abap_unit_assert=>assert_equals(
      act = other->process_line( '<tag/>' )
      exp = |<span class="xml_tag">&lt;tag/&gt;</span>| ).
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( 'body' )
      exp = |<span class="comment">body</span>| ).
    cut->process_line( '-->' ).
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( '<tag/>' )
      exp = |<span class="xml_tag">&lt;tag/&gt;</span>| ).
  ENDMETHOD.

  METHOD dotted_attributes.
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( '<tag xml.name="v"/>' )
      exp = |<span class="xml_tag">&lt;tag</span><span class="attr"> xml.name</span>=|
         && |<span class="attr_val">"v"</span><span class="xml_tag">/&gt;</span>| ).
  ENDMETHOD.

  METHOD text_after_comment.
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( '<!-- note --> "text"' )
      exp = |<span class="comment">&lt;!-- note --&gt;</span> "text"| ).
  ENDMETHOD.

  METHOD nested_quotes.
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( `<tag value="'quoted'"/>` )
      exp = |<span class="xml_tag">&lt;tag</span><span class="attr"> value</span>=|
         && |<span class="attr_val">"'quoted'"</span><span class="xml_tag">/&gt;</span>| ).
  ENDMETHOD.

  METHOD quotes_in_comments.
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( '<!-- " --> <tag value="v"/>' )
      exp = |<span class="comment">&lt;!-- " --&gt;</span> |
         && |<span class="xml_tag">&lt;tag</span><span class="attr"> value</span>=|
         && |<span class="attr_val">"v"</span><span class="xml_tag">/&gt;</span>| ).
    cut->process_line( '<!-- open' ).
    cl_abap_unit_assert=>assert_equals(
      act = cut->process_line( '" --> <tag value="v"/>' )
      exp = |<span class="comment">" --&gt;</span> |
         && |<span class="xml_tag">&lt;tag</span><span class="attr"> value</span>=|
         && |<span class="attr_val">"v"</span><span class="xml_tag">/&gt;</span>| ).
  ENDMETHOD.
ENDCLASS.
