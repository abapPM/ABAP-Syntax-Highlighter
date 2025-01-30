![Version](https://img.shields.io/endpoint?url=https://shield.abappm.com/github/abapPM/ABAP-Syntax-Highlighter/src/zcl_Syntax-Highlighter.clas.abap/c_version&label=Version&color=blue)

[![License](https://img.shields.io/github/license/abapPM/ABAP-Syntax-Highlighter?label=License&color=success)](https://github.com/abapPM/ABAP-Syntax-Highlighter/blob/main/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg?color=success)](https://github.com/abapPM/.github/blob/main/CODE_OF_CONDUCT.md)
[![REUSE Status](https://api.reuse.software/badge/github.com/abapPM/ABAP-Syntax-Highlighter)](https://api.reuse.software/info/github.com/abapPM/ABAP-Syntax-Highlighter)

# Syntax-Highlighter

Syntax highlighter for ABAP, HTML, XML, CSS, JavaScript, JSON, Markdown, and more.

NO WARRANTIES, [MIT License](https://github.com/abapPM/ABAP-Syntax-Highlighter/blob/main/LICENSE)

## Usage

For example, here's how you highlight keywords and comments in a line of ABAP code:

```abap
DATA(highlighter) = zcl_highlighter_factory=>create( 'file.abap' ).

DATA(code) = `call function 'FM_NAME'. " Commented`.

DATA(html) = highlighter->process_line( code ).

WRITE html.
```

Output:

```abap
call function 'FM_NAME'. " Commmented
```

```html
<span class="keyword">call</span> <span class="keyword">function</span> <span class="text">'FM_NAME'</span>. <span class="comment">" Commented</span>
```

> [!NOTE]
> It's recommended to process one line at a time instead of passing a long string containing newline separators.

The language is derived from the extension of the filename passed to the factory:

Extension   | Syntax Highlighter
------------|-------------------
`.abap`     | ABAP Code
`.css`      | CSS3
`.diff`     | Git Diff
`.html `    | HTML
`.ini `     | Plain Text
`.js `      | JavaScript
`.json`     | JSON
`.json5`    | JSON5 (limited support for comments)
`.jsonc`    | JSON  (with end-of-line comments)
`.markdown` | Markdown
`.md`       | Markdown
`.sass`     | SASS
`.scss`     | SCSS
`.text `    | Plain Text
`.txt `     | Plain Text
`.xml `     | XML
`.yaml `    | YAML (experimental)
`.yml `     | YAML (experimental)

Options:

You can show invisible characters in the output by settings an option in the factory call. This will highlight the following characters: horizontal tab (x09), form feed (x0C), carriage return (x0D), space (x20), as well as byte-order-marks (BOM) for UTF-8 (xEF BB BF), UTF-16 big-endian (xFE FF), and UTF-16 little-endian (xFF FE).

```abap
DATA(highlighter) = zcl_highlighter_factory=>create(
  filename     = 'file.abap'
  hidden_chars = abap_true ).
```

## Prerequisites

SAP Basis 7.40 or higher

## Installation

Install `syntax-highlighter` as a global module in your system using [apm](https://abappm.com).

or

Specify the `syntax-highlighter` module as a dependency in your project and import it to your namespace using [apm](https://abappm.com).

## Contributions

All contributions are welcome! Read our [Contribution Guidelines](https://github.com/abapPM/ABAP-Syntax-Highlighter/blob/main/CONTRIBUTING.md), fork this repo, and create a pull request.

You can install the developer version of ABAP SYNTAX-HIGHLIGHTER using [abapGit](https://github.com/abapGit/abapGit) by creating a new online repository for `https://github.com/abapPM/ABAP-Syntax-Highlighter`.

Recommended SAP package: `$SYNTAX-HIGHLIGHTER`

## Attibution

This project includes the code for the following open-source projects. Please support them if you can!

- [abapGit](https://github.com/abapGit/abapGit), abapGit Community, [MIT](https://github.com/abapGit/abapGit/blob/main/LICENSE)

## About

Made with ❤ in Canada

Copyright 2025 apm.to Inc. <https://apm.to>

Follow [@marcf.be](https://bsky.app/profile/marcf.be) on Blueksy and [@marcfbe](https://linkedin.com/in/marcfbe) or LinkedIn
