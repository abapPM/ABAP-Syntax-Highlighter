CLASS /apmg/cl_highlighter_css DEFINITION
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
      " CSS Standard            https://www.w3.org/TR/css-2018/
      " CSS Reference           https://www.w3schools.com/cssref/default.asp
      " We used a mixture of above as reference for the keyword list
      " 1) CSS Properties       https://www.w3schools.com/cssref/default.asp
      " 2) CSS Values & Units   https://www.w3schools.com/cssref/css_units.asp
      " 3) CSS Selectors        https://www.w3.org/TR/css-2018/#selectors
      " 4) CSS Functions        https://www.w3schools.com/cssref/css_functions.asp
      " 5) CSS Colors           https://www.w3schools.com/colors/colors_names.asp
      " 6) CSS Extensions
      " 7) CSS At-Rules         https://www.w3.org/TR/css-2018/#at-rules
      " 8) HTML Tags
      BEGIN OF c_css,
        keyword    TYPE string VALUE 'keyword',
        text       TYPE string VALUE 'text',
        comment    TYPE string VALUE 'comment',
        selectors  TYPE string VALUE 'selectors',
        units      TYPE string VALUE 'units',
        properties TYPE string VALUE 'properties',
        values     TYPE string VALUE 'values',
        functions  TYPE string VALUE 'functions',
        colors     TYPE string VALUE 'colors',
        extensions TYPE string VALUE 'extensions',
        at_rules   TYPE string VALUE 'at_rules',
        html       TYPE string VALUE 'html',
      END OF c_css,
      BEGIN OF c_token,
        keyword    TYPE c VALUE 'K',
        text       TYPE c VALUE 'T',
        comment    TYPE c VALUE 'C',
        selectors  TYPE c VALUE 'S',
        units      TYPE c VALUE 'U',
        properties TYPE c VALUE 'P',
        values     TYPE c VALUE 'V',
        functions  TYPE c VALUE 'F',
        colors     TYPE c VALUE 'Z',
        extensions TYPE c VALUE 'E',
        at_rules   TYPE c VALUE 'A',
        html       TYPE c VALUE 'H',
      END OF c_token,
      BEGIN OF c_regex,
        " comments /* ... */
        comment   TYPE string VALUE '\/\*.*\*\/|\/\*|\*\/',
        " single or double quoted strings
        text      TYPE string VALUE '("[^"]*")|(''[^'']*'')|(`[^`]*`)',
        " in general keywords don't contain numbers (except -ms-scrollbar-3dlight-color)
        keyword   TYPE string VALUE '\b[a-z3@\-]+\b',
        " selectors begin with :
        selectors TYPE string VALUE ':[:a-z]+\b',
        " units
        units     TYPE string
        VALUE '\b[0-9\. ]+(ch|cm|em|ex|in|mm|pc|pt|px|vh|vmax|vmin|vw)\b|\b[0-9\. ]+%',
      END OF c_regex.

    CLASS-METHODS class_constructor.

    METHODS constructor.

  PROTECTED SECTION.

    TYPES:
      ty_token TYPE c LENGTH 1,
      BEGIN OF ty_keyword,
        keyword TYPE string,
        token   TYPE ty_token,
      END OF ty_keyword.

    CLASS-DATA keywords TYPE HASHED TABLE OF ty_keyword WITH UNIQUE KEY keyword.
    CLASS-DATA comment TYPE abap_bool.

    CLASS-METHODS init_keywords.

    CLASS-METHODS insert_keywords
      IMPORTING
        list  TYPE string
        token TYPE ty_token.

    CLASS-METHODS is_keyword
      IMPORTING
        chunk         TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS order_matches REDEFINITION.

    METHODS parse_line REDEFINITION.

  PRIVATE SECTION.
ENDCLASS.



CLASS /apmg/cl_highlighter_css IMPLEMENTATION.


  METHOD class_constructor.

    init_keywords( ).

  ENDMETHOD.


  METHOD constructor.

    super->constructor( ).

    " Reset indicator for multi-line comments
    CLEAR comment.

    " Initialize instances of regular expression
    add_rule( regex = c_regex-keyword
              token = c_token-keyword
              style = c_css-keyword ).

    add_rule( regex = c_regex-comment
              token = c_token-comment
              style = c_css-comment ).

    add_rule( regex = c_regex-text
              token = c_token-text
              style = c_css-text ).

    add_rule( regex = c_regex-selectors
              token = c_token-selectors
              style = c_css-selectors ).

    add_rule( regex = c_regex-units
              token = c_token-units
              style = c_css-units ).

    " Styles for keywords
    add_rule( regex = ''
              token = c_token-html
              style = c_css-html ).

    add_rule( regex = ''
              token = c_token-properties
              style = c_css-properties ).

    add_rule( regex = ''
              token = c_token-values
              style = c_css-values ).

    add_rule( regex = ''
              token = c_token-functions
              style = c_css-functions ).

    add_rule( regex = ''
              token = c_token-colors
              style = c_css-colors ).

    add_rule( regex = ''
              token = c_token-extensions
              style = c_css-extensions ).

    add_rule( regex = ''
              token = c_token-at_rules
              style = c_css-at_rules ).

  ENDMETHOD.


  METHOD init_keywords.

    CLEAR keywords.

    " 1) CSS Properties
    DATA(keyword_list) =
    'align-content|align-items|align-self|animation|animation-delay|animation-direction|animation-duration|' &&
    'animation-fill-mode|animation-iteration-count|animation-name|animation-play-state|animation-timing-function|' &&
    'backface-visibility|background|background-attachment|background-blend-mode|background-clip|background-color|' &&
    'background-image|background-origin|background-position|background-repeat|background-size|border|' &&
    'border-bottom|border-bottom-color|border-bottom-left-radius|border-bottom-right-radius|border-bottom-style|' &&
    'border-bottom-width|border-collapse|border-color|border-image|border-image-outset|border-image-repeat|' &&
    'border-image-slice|border-image-source|border-image-width|border-left|border-left-color|border-left-style|' &&
    'border-left-width|border-radius|border-right|border-right-color|border-right-style|border-right-width|' &&
    'border-spacing|border-style|border-top|border-top-color|border-top-left-radius|border-top-right-radius|' &&
    'border-top-style|border-top-width|border-width|box-decoration-break|box-shadow|box-sizing|caption-side|' &&
    'caret-color|clear|clip|color|column-count|column-fill|column-gap|column-rule|column-rule-color|' &&
    'column-rule-style|column-rule-width|column-span|column-width|columns|content|counter-increment|' &&
    'counter-reset|cursor|direction|display|empty-cells|filter|flex|flex-basis|flex-direction|flex-flow|' &&
    'flex-grow|flex-shrink|flex-wrap|float|font|font-family|font-kerning|font-size|font-size-adjust|' &&
    'font-stretch|font-style|font-variant|font-weight|grid|grid-area|grid-auto-columns|grid-auto-flow|' &&
    'grid-auto-rows|grid-column|grid-column-end|grid-column-gap|grid-column-start|grid-gap|grid-row|' &&
    'grid-row-end|grid-row-gap|grid-row-start|grid-template|grid-template-areas|grid-template-columns|' &&
    'grid-template-rows|hanging-punctuation|height|hyphens|isolation|justify-content|' &&
    'letter-spacing|line-height|list-style|list-style-image|list-style-position|list-style-type|margin|' &&
    'margin-bottom|margin-left|margin-right|margin-top|max-height|max-width|media|min-height|min-width|' &&
    'mix-blend-mode|object-fit|object-position|opacity|order|outline|outline-color|outline-offset|' &&
    'outline-style|outline-width|overflow|overflow-x|overflow-y|padding|padding-bottom|padding-left|' &&
    'padding-right|padding-top|page-break-after|page-break-before|page-break-inside|perspective|' &&
    'perspective-origin|pointer-events|position|quotes|resize|scroll-behavior|tab-size|table-layout|' &&
    'text-align|text-align-last|text-decoration|text-decoration-color|text-decoration-line|' &&
    'text-decoration-style|text-indent|text-justify|text-overflow|text-rendering|text-shadow|text-transform|' &&
    'transform|transform-origin|transform-style|transition|transition-delay|transition-duration|' &&
    'transition-property|transition-timing-function|unicode-bidi|user-select|vertical-align|visibility|' &&
    'white-space|width|word-break|word-spacing|word-wrap|writing-mode|z-index'.
    insert_keywords( list  = keyword_list
                     token = c_token-properties ).

    " 2) CSS Values
    keyword_list =
    'absolute|all|auto|block|bold|border-box|both|bottom|center|counter|cover|dashed|fixed|hidden|important|' &&
    'inherit|initial|inline-block|italic|left|max-content|middle|min-content|no-repeat|none|normal|pointer|' &&
    'relative|rem|right|solid|table-cell|text|top|transparent|underline|url'.
    insert_keywords( list  = keyword_list
                     token = c_token-values ).

    " 3) CSS Selectors
    keyword_list =
    ':active|::after|::before|:checked|:disabled|:empty|:enabled|:first-child|::first-letter|::first-line|' &&
    ':first-of-type|:focus|:hover|:lang|:last-child|:last-of-type|:link|:not|:nth-child|:nth-last-child|' &&
    ':nth-last-of-type|:nth-of-type|:only-child|:only-of-type|:root|:target|:visited'.
    insert_keywords( list  = keyword_list
                     token = c_token-selectors ).

    " 4) CSS Functions
    keyword_list =
    'attr|calc|cubic-bezier|hsl|hsla|linear-gradient|math|radial-gradient|repeating-linear-gradient|' &&
    'repeating-radial-gradient|rgb|rgba|rotate|scale|theme|translateX|translateY|var'.
    insert_keywords( list  = keyword_list
                     token = c_token-functions ).

    " 5) CSS Colors
    keyword_list =
    '#|aliceblue|antiquewhite|aqua|aquamarine|azure|beige|bisque|black|blanchedalmond|blue|blueviolet|brown|' &&
    'burlywood|cadetblue|chartreuse|chocolate|coral|cornflowerblue|cornsilk|crimson|cyan|darkblue|darkcyan|' &&
    'darkgoldenrod|darkgray|darkgreen|darkgrey|darkkhaki|darkmagenta|darkolivegreen|darkorange|darkorchid|' &&
    'darkred|darksalmon|darkseagreen|darkslateblue|darkslategray|darkslategrey|darkturquoise|darkviolet|' &&
    'deeppink|deepskyblue|dimgray|dimgrey|dodgerblue|firebrick|floralwhite|forestgreen|fuchsia|gainsboro|' &&
    'ghostwhite|gold|goldenrod|gray|green|greenyellow|grey|honeydew|hotpink|indianred|indigo|ivory|khaki|' &&
    'lavender|lavenderblush|lawngreen|lemonchiffon|lightblue|lightcoral|lightcyan|lightgoldenrodyellow|' &&
    'lightgray|lightgreen|lightgrey|lightpink|lightsalmon|lightseagreen|lightskyblue|lightslategray|' &&
    'lightslategrey|lightsteelblue|lightyellow|lime|limegreen|linen|magenta|maroon|mediumaquamarine|' &&
    'mediumblue|mediumorchid|mediumpurple|mediumseagreen|mediumslateblue|mediumspringgreen|mediumturquoise|' &&
    'mediumvioletred|midnightblue|mintcream|mistyrose|moccasin|navajowhite|navy|oldlace|olive|olivedrab|' &&
    'orange|orangered|orchid|palegoldenrod|palegreen|paleturquoise|palevioletred|papayawhip|peachpuff|' &&
    'peru|pink|plum|powderblue|purple|rebeccapurple|red|rosybrown|royalblue|saddlebrown|salmon|sandybrown|' &&
    'seagreen|seashell|sienna|silver|skyblue|slateblue|slategray|slategrey|snow|springgreen|steelblue|' &&
    'tan|teal|thistle|tomato|turquoise|violet|wheat|white|whitesmoke|yellow|yellowgreen'.
    insert_keywords( list  = keyword_list
                     token = c_token-colors ).

    " 6) CSS Extensions
    keyword_list =
    'moz|moz-binding|moz-border-bottom-colors|moz-border-left-colors|moz-border-right-colors|' &&
    'moz-border-top-colors|moz-box-align|moz-box-direction|moz-box-flex|moz-box-ordinal-group|' &&
    'moz-box-orient|moz-box-pack|moz-box-shadow|moz-context-properties|moz-float-edge|' &&
    'moz-force-broken-image-icon|moz-image-region|moz-orient|moz-osx-font-smoothing|' &&
    'moz-outline-radius|moz-outline-radius-bottomleft|moz-outline-radius-bottomright|' &&
    'moz-outline-radius-topleft|moz-outline-radius-topright|moz-stack-sizing|moz-system-metric|' &&
    'moz-transform|moz-transform-origin|moz-transition|moz-transition-delay|moz-user-focus|' &&
    'moz-user-input|moz-user-modify|moz-window-dragging|moz-window-shadow|ms|ms-accelerator|' &&
    'ms-block-progression|ms-content-zoom-chaining|ms-content-zoom-limit|' &&
    'ms-content-zoom-limit-max|ms-content-zoom-limit-min|ms-content-zoom-snap|' &&
    'ms-content-zoom-snap-points|ms-content-zoom-snap-type|ms-content-zooming|ms-filter|' &&
    'ms-flow-from|ms-flow-into|ms-high-contrast-adjust|ms-hyphenate-limit-chars|' &&
    'ms-hyphenate-limit-lines|ms-hyphenate-limit-zone|ms-ime-align|ms-overflow-style|' &&
    'ms-scroll-chaining|ms-scroll-limit|ms-scroll-limit-x-max|ms-scroll-limit-x-min|' &&
    'ms-scroll-limit-y-max|ms-scroll-limit-y-min|ms-scroll-rails|ms-scroll-snap-points-x|' &&
    'ms-scroll-snap-points-y|ms-scroll-snap-x|ms-scroll-snap-y|ms-scroll-translation|' &&
    'ms-scrollbar-3dlight-color|ms-scrollbar-arrow-color|ms-scrollbar-base-color|' &&
    'ms-scrollbar-darkshadow-color|ms-scrollbar-face-color|ms-scrollbar-highlight-color|' &&
    'ms-scrollbar-shadow-color|ms-scrollbar-track-color|ms-transform|ms-text-autospace|' &&
    'ms-touch-select|ms-wrap-flow|ms-wrap-margin|ms-wrap-through|o|o-transform|webkit|' &&
    'webkit-animation-trigger|webkit-app-region|webkit-appearance|webkit-aspect-ratio|' &&
    'webkit-backdrop-filter|webkit-background-composite|webkit-border-after|' &&
    'webkit-border-after-color|webkit-border-after-style|webkit-border-after-width|' &&
    'webkit-border-before|webkit-border-before-color|webkit-border-before-style|' &&
    'webkit-border-before-width|webkit-border-end|webkit-border-end-color|' &&
    'webkit-border-end-style|webkit-border-end-width|webkit-border-fit|' &&
    'webkit-border-horizontal-spacing|webkit-border-radius|webkit-border-start|' &&
    'webkit-border-start-color|webkit-border-start-style|webkit-border-start-width|' &&
    'webkit-border-vertical-spacing|webkit-box-align|webkit-box-direction|webkit-box-flex|' &&
    'webkit-box-flex-group|webkit-box-lines|webkit-box-ordinal-group|webkit-box-orient|' &&
    'webkit-box-pack|webkit-box-reflect|webkit-box-shadow|webkit-column-axis|' &&
    'webkit-column-break-after|webkit-column-break-before|webkit-column-break-inside|' &&
    'webkit-column-progression|webkit-cursor-visibility|webkit-dashboard-region|' &&
    'webkit-font-size-delta|webkit-font-smoothing|webkit-highlight|webkit-hyphenate-character|' &&
    'webkit-hyphenate-limit-after|webkit-hyphenate-limit-before|webkit-hyphenate-limit-lines|' &&
    'webkit-initial-letter|webkit-line-align|webkit-line-box-contain|webkit-line-clamp|' &&
    'webkit-line-grid|webkit-line-snap|webkit-locale|webkit-logical-height|' &&
    'webkit-logical-width|webkit-margin-after|webkit-margin-after-collapse|' &&
    'webkit-margin-before|webkit-margin-before-collapse|webkit-margin-bottom-collapse|' &&
    'webkit-margin-collapse|webkit-margin-end|webkit-margin-start|webkit-margin-top-collapse|' &&
    'webkit-marquee|webkit-marquee-direction|webkit-marquee-increment|' &&
    'webkit-marquee-repetition|webkit-marquee-speed|webkit-marquee-style|webkit-mask-box-image|' &&
    'webkit-mask-box-image-outset|webkit-mask-box-image-repeat|webkit-mask-box-image-slice|' &&
    'webkit-mask-box-image-source|webkit-mask-box-image-width|webkit-mask-repeat-x|' &&
    'webkit-mask-repeat-y|webkit-mask-source-type|webkit-max-logical-height|' &&
    'webkit-max-logical-width|webkit-min-logical-height|webkit-min-logical-width|' &&
    'webkit-nbsp-mode|webkit-padding-after|webkit-padding-before|webkit-padding-end|' &&
    'webkit-padding-start|webkit-perspective-origin-x|webkit-perspective-origin-y|' &&
    'webkit-print-color-adjust|webkit-rtl-ordering|webkit-svg-shadow|' &&
    'webkit-tap-highlight-color|webkit-text-combine|webkit-text-decoration-skip|' &&
    'webkit-text-decorations-in-effect|webkit-text-fill-color|webkit-text-security|' &&
    'webkit-text-stroke|webkit-text-stroke-color|webkit-text-stroke-width|webkit-text-zoom|' &&
    'webkit-transform|webkit-transform-origin|webkit-transform-origin-x|' &&
    'webkit-transform-origin-y|webkit-transform-origin-z|webkit-transition|' &&
    'webkit-transition-delay|webkit-user-drag|webkit-user-modify|overflow-clip-box|' &&
    'overflow-clip-box-block|overflow-clip-box-inline|zoom'.
    insert_keywords( list  = keyword_list
                     token = c_token-extensions ).

    " 6) CSS At-Rules (SASS/SCSS)
    keyword_list =
    '@|charset|counter-style|font-face|import|keyframes|@use|@mixin|@include|@extend'.
    insert_keywords( list  = keyword_list
                     token = c_token-at_rules ).

    " 7) HTML tag
    keyword_list =
    'doctyype|a|abbr|acronym|address|applet|area|b|base|basefont|bdo|bgsound|big|blink|blockquote|' &&
    'body|br|button|caption|center|cite|code|col|colgroup|dd|del|dfn|dir|div|dl|dt|em|embed|fieldset|' &&
    'font|form|frame|frameset|h1|h2|h3|h4|h5|h6|head|hr|html|i|iframe|ilayer|img|input|ins|isindex|' &&
    'kbd|keygen|label|layer|legend|li|link|listing|map|menu|meta|multicol|nobr|noembed|noframes|' &&
    'nolayer|noscript|object|ol|optgroup|option|p|param|plaintext|pre|q|s|samp|script|select|server|' &&
    'small|sound|spacer|span|strike|strong|style|sub|sup|tbody|textarea|title|tt|u|ul|var|wbr|xmp|' &&
    'xsl|xml|accesskey|action|align|alink|alt|background|balance|behavior|bgcolor|bgproperties|' &&
    'border|bordercolor|bordercolordark|bordercolorlight|bottommargin|checked|class|classid|clear|' &&
    'code|codebase|codetype|color|cols|colspan|compact|content|controls|coords|data|datafld|' &&
    'dataformatas|datasrc|direction|disabled|dynsrc|enctype|event|face|for|frame|frameborder|' &&
    'framespacing|height|hidden|href|hspace|http-equiv|id|ismap|lang|language|leftmargin|link|loop|' &&
    'lowsrc|marginheight|marginwidth|maxlength|mayscript|method|methods|multiple|name|nohref|' &&
    'noresize|noshade|nowrap|palette|pluginspage|public|readonly|rel|rev|rightmargin|rows|rowspan|' &&
    'rules|scroll|scrollamount|scrolldelay|scrolling|selected|shape|size|span|src|start|style|' &&
    'tabindex|target|text|title|topmargin|truespeed|type|url|urn|usemap|valign|value|vlink|volume|' &&
    'vrml|vspace|width|wrap|apply-templates|attribute|choose|comment|define-template-set|' &&
    'entity-ref|eval|expr|for-each|if|match|no-entities|node-name|order-by|otherwise|select|' &&
    'stylesheet|template|test|value-of|version|when|xmlns|xsl|cellpadding|cellspacing|table|td|' &&
    'tfoot|th|thead|tr'.
    insert_keywords( list  = keyword_list
                     token = c_token-html ).

  ENDMETHOD.


  METHOD insert_keywords.

    SPLIT list AT '|' INTO TABLE DATA(keyword_list).

    LOOP AT keyword_list ASSIGNING FIELD-SYMBOL(<keyword>).
      DATA(keyword) = VALUE ty_keyword(
        keyword = <keyword>
        token   = token ).
      INSERT keyword INTO TABLE keywords.
    ENDLOOP.

  ENDMETHOD.


  METHOD is_keyword.

    result = xsdbool( line_exists( keywords[ keyword = to_lower( chunk ) ] ) ).

  ENDMETHOD.


  METHOD order_matches.

    FIELD-SYMBOLS <prev_match> TYPE ty_match.

    " Longest matches
    SORT matches BY offset length DESCENDING.

    DATA(line_len)   = strlen( line ).
    DATA(prev_token) = ''.
    DATA(prev_end)   = ''.

    " Check if this is part of multi-line comment and mark it accordingly
    IF comment = abap_true.
      IF NOT line_exists( matches[ token = c_token-comment ] ).
        CLEAR matches.
        APPEND INITIAL LINE TO matches ASSIGNING FIELD-SYMBOL(<match>).
        <match>-token = c_token-comment.
        <match>-offset = 0.
        <match>-length = line_len.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT matches ASSIGNING <match>.
      " Delete matches after open text match
      IF prev_token = c_token-text AND <match>-token <> c_token-text.
        CLEAR <match>-token.
        CONTINUE.
      ENDIF.

      DATA(match) = substring( val = line
                               off = <match>-offset
                               len = <match>-length ).

      CASE <match>-token.
        WHEN c_token-keyword.
          " Skip keyword that's part of previous (longer) keyword
          IF <match>-offset < prev_end.
            CLEAR <match>-token.
            CONTINUE.
          ENDIF.

          " Map generic keyword to specific CSS token
          match = to_lower( match ).
          READ TABLE keywords ASSIGNING FIELD-SYMBOL(<keyword>) WITH TABLE KEY keyword = match.
          IF sy-subrc = 0.
            <match>-token = <keyword>-token.
          ENDIF.

        WHEN c_token-comment.
          CASE match.
            WHEN '/*'.
              DELETE matches WHERE offset > <match>-offset.
              <match>-length = line_len - <match>-offset.
              comment = abap_true.
            WHEN '*/'.
              DELETE matches WHERE offset < <match>-offset.
              <match>-length = <match>-offset + 2.
              <match>-offset = 0.
              comment = abap_false.
            WHEN OTHERS.
              DATA(cmmt_end) = <match>-offset + <match>-length.
              DELETE matches WHERE offset > <match>-offset AND offset <= cmmt_end.
          ENDCASE.

        WHEN c_token-text.
          <match>-text_tag = match.
          IF prev_token = c_token-text.
            IF <match>-text_tag = <prev_match>-text_tag.
              <prev_match>-length = <match>-offset + <match>-length - <prev_match>-offset.
              CLEAR prev_token.
            ENDIF.
            CLEAR <match>-token.
            CONTINUE.
          ENDIF.

      ENDCASE.

      prev_token = <match>-token.
      prev_end   = <match>-offset + <match>-length.
      ASSIGN <match> TO <prev_match>.
    ENDLOOP.

    DELETE matches WHERE token IS INITIAL.

  ENDMETHOD.


  METHOD parse_line. "REDEFINITION

    result = super->parse_line( line ).

    " Remove non-keywords
    LOOP AT result ASSIGNING FIELD-SYMBOL(<match>) WHERE token = c_token-keyword.
      IF NOT is_keyword( substring( val = line
                                    off = <match>-offset
                                    len = <match>-length ) ).
        CLEAR <match>-token.
      ENDIF.
    ENDLOOP.

    DELETE result WHERE token IS INITIAL.

  ENDMETHOD.
ENDCLASS.
