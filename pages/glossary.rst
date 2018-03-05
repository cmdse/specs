########
Glossary
########

.. glossary::
  :sorted:

  .. CHAR ENCODING

  string
    An arbitrary sequence of bytes. Note that with this definition, a string alone is not sufficient to get a textual representation. A :term:`charset` and its :term:`encoding` must be provided along.

  string literal
    A :term:`string` with valid :term:`utf-8` sequences.

  glyph
    The non-reductable sum of pixels corresponding to a representation of it's corresponding :term:`character symbol(s) <character symbol>`.

  character symbol
  character literal
    A unique element in a :term:`charset`.

  character
    The meaning of character is loose. It can either mean a :term:`glyph` or a :term:`character literal`, which is not the same since a glyph can be the result of merging two literals as it often happens with dead keystrokes.
    For example, pressing :kbd:`\`` followed by :kbd:`a` will result in *à* glyph, but in the UTF-8 encoding, is not the same as *à* symbol.

  charset
    Strictly saying, a set of symbols that can be used. Often confused with :term:`encoding`.

  encoding
    The in-memory representation of a :term:`charset`.

  rune
  code point
    A representation in the form of character of a unicode byte sequence.
    Rune is the Go synonym for a code point.

  utf-8
    An :term:`encoding` for the :linuxman:`unicode(7)` :term:`charset`. See :linuxman:`utf-8(7)`.

  ucs-2
    An :term:`encoding` for a subset of the `Unicode <https://en.wikipedia.org/wiki/Unicode>`_ :term:`charset`. This subset is known as the Basic Multilingual Plane and is composed of the first 65,536 :term:`code points <code point>`. This encoding uses 2-bytes for each character.

  .. MODEL

  command
    [Unix shells] A command is a one-line processable text chunk\ [#bash-exceptions]_ to be converted in command invocation. Command invocation consists in passing to the operating system a file to be read and executed (extrapolated from the :term:`utility name`) with a list of arguments (``argv``).

  sub-command
    A sub command is a utility argument which operates as the alias of an inner command. Exemple of such is :command:`git add` :linuxman:`git-add(1)`

  command identifier
    [Unix shells] A command identifier is a word which maps to a set of instructions, either through a :term:`builtin command`, a declared function,  or with a :term:`utility executable`. See the POSIX.1-2008 section on command search and execution\ [#posix-search-execute]_.

  utility executable
    [Unix shells] An executable file which supports positional text arguments.

  utility name
    [Unix shells] The basename of a :term:`utility executable` file that the shell will try to locate with :envvar:`PATH` environment variable.

  utility interface model
    [|app-name|] Structured data describing the command line interface capabilities of a :term:`utility executable` identified by its :term:`utility name`. The capabilities are defined through:

      - a set of :term:`synopses <synopsis>` of minimum length one;
      - an :term:`option description model` which is a set of options and their related expressions;
      - an :term:`option scheme`;
      - an optional set of :term:`sub-commands`.

      Those are defined for a peculiar :term:`version range`.
      The term “utility” is directly extracted from the POSIX.1-2008 reference\ [#posix-synopsis]_.

  builtin command
    [Unix shells] A :term:`command identifier` which execution is provided and implemented within the shell.

  compound command
    [Unix shells] Compound commands are the shell programming constructs. Each construct begins with a reserved word or control operator and is terminated by a corresponding reserved word or operator. They are introduced by a keyword such as ``if`` or ``while``.

  command snippet metadata
    [|app-name|] Structured data about a :term:`command snippet`. Such information may be comprised of the following fields:

    * a list of :term:`utility interface models <utility interface model>` reffered to in the snippet;
    * text description of the snippet;
    * a list of tags applied to the snippet;
    * a list of :term:`command parameters <command parameter>` consisting each of a name, a description field and an optional default value.

  command parameter
    [|app-name|] A :term:`command snippet` parameter is a string which should be substituted with user input when the corresponding snippet is invoked.

  command snippet
    [|app-name|] A shell-processable text.

  option expression variant
      [|app-name|] A pattern to recognize one or many arguments as members of an option flag or option assignment (see :numref:`option-expression-variants`).

  option description
    [|app-name|] Structured data composed of a description text field and a collection of match models.
    Each match model is related to an :term:`option expression variant` and has a one-or-two groups regular expression.
    When two groups can be matched, the latest is the option parameter of an explicit option assignments.

  option description model
   [|app-name|] An option description model is a set of :term:`option descriptions <option description>`.

  option scheme
    [|app-name|] A set of :term:`option expression variants <option expression variant>` supported by a program command line interface (see :numref:`option-expression-variants`).

  synopsis
    [Unix shells] A text pattern describing a set of possible :term:`call expressions <call expression>`.

  word
    [Unix shells] "Word" has a special meaning in shells. In a quote-free context, it is a sequence of non-meta characters separated with blanks. Otherwise, any quoted expression is interpreted as a single word.

  version range
    [|app-name|] A version range is an expression describing a range of software versions. Such an expression is written with semver syntax\ [#semver]_.

  call expression
    [|app-name|] A call expression is a valid shell-processable character sequence of optional variable assignments followed by a word reffered to as the ":term:`command identifier`" and a list of :term:`words <word>`, namely "arguments". This command identifier cannot be a :term:`compound command`, since it is semantically closer to a control construct.
    When such expression is evaluated, the first word specifies the :term:`command identifier`, and is passed as positional parameter zero. The remaining argument expressions are passed as positional parameters to the invoked command. When a substitution expression is encountered, it will be evaluated before the :term:`command identifier` executable is invoked.

  operand
    [Unix shells] An operand is a non-option :term:`command identifier` argument, typically the subject(s) upon which the command will operate (file name, remote, ... etc).


---------------------------------------

.. container:: footnotes

  .. [#posix-synopsis] See `POSIX.1-2008, sec. 12.1 <http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html>`_, “Utility Conventions”
  .. [#semver] Semantic versionning definition is available `here: semver.org <https://semver.org/>`_. Semver ranges are defined `here: semver.npmjs.com <https://semver.npmjs.com/>`_.
  .. [#bash-exceptions] Four exceptions: multiple lines can be processed in one row when terminated with the escape character, ``\`` and `here-documents <https://en.wikipedia.org/wiki/Here_document>`_ are read multilines until the provided WORD is matched. Also :term:`compound commands <compound command>` such as ``for`` construct may be written in multiple lines, needing some look-ahead line processing before execution. Finally, the semicolon ``;`` metacharacter is interpreted as a line delimiter.
  .. [#posix-search-execute] See `POSIX.1-2008, sec. 2.9.1 <http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_09_01_01>`_
