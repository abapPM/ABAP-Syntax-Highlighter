CLASS ltcl_highlighter_yaml DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_highlighter_yaml.

    METHODS:
      setup,
      key_value FOR TESTING RAISING cx_static_check,
      comment_1 FOR TESTING RAISING cx_static_check,
      comment_2 FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_highlighter_yaml IMPLEMENTATION.

  METHOD setup.

    cut = NEW #( ).

  ENDMETHOD.

  METHOD key_value.
    DATA(act) = cut->process_line( |key: value| ).
    cl_abap_unit_assert=>assert_equals(
      act = act
      exp = |<span class="selectors">key</span>|
         && |<span class="attr">: </span>|
         && |<span class="selectors">value</span>| ).
  ENDMETHOD.

  METHOD comment_1.
    ASSERT 0 = 0.
* FIXME: comments double tagged as keywords
*    DATA(act) = cut->process_line( |key: "value" # comment| )
*    cl_abap_unit_assert=>assert_equals(
*      act = act
*      exp = |<span class="selectors">key</span>|
*         && |<span class="attr">: </span>|
*         && |<span class="text">"value"</span> |
*         && |<span class="comment"># comment</span>| )
  ENDMETHOD.

  METHOD comment_2.
    ASSERT 0 = 0.
* FIXME: comments double tagged as keywords
*    DATA(act) = cut->process_line( |# comment| )
*    cl_abap_unit_assert=>assert_equals(
*      act = act
*      exp = |<span class="comment"># comment</span>| )
  ENDMETHOD.
ENDCLASS.
