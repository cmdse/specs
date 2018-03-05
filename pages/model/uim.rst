#######################
Utility Interface Model
#######################

.. note:: A :term:`utility interface model` (UIM) is a central aspect of |project-name| model since it enables all rich-semantic features. :command:`manparse` is a tool developed along with |project-name| to extract such UIM from manpages, see :numref:`manparse-cli-section`.

It is defined as follow:

.. container:: definition

  Structured data describing the command line interface capabilities of a :term:`utility executable` identified by its :term:`utility name`. The capabilities are defined through:

  - a set of :term:`synopses <synopsis>` of minimum length one, see :numref:`synopses-section` ;
  - an :term:`option description model` which is a set of options and their related expressions, see :numref:`option-description-model-section`;
  - an :term:`option scheme`, see :numref:`option-schemes-section`;
  - an optional set of :term:`sub-commands <sub-command>`, see :numref:`subcommands-section`.

  Those are defined for a peculiar :term:`version range`.
  The term “utility” is directly borrowed from the POSIX.1-2008 reference\ [#posix-synopsis]_.


.. _synopses-section:

Synopses
########


POSIX.1-2008 reference\ [#posix-synopsis]_ defines strictly the syntax of a utility (or command) synopsis:

.. container:: synopsis

   **utility_name[**-a\ **][**-b\ **][**-c option_argument\ **][**-d\ **|**-e\ **][**-f\ **[**\ option_argument\ **]][**\ operand\ **...]**

This standard syntax definition is globally well defined. :command:`doclifter`\ [#doclifter-project]_ author reports a 93% success rate for its manapge to DocBook extractor on a bare Ubuntu install.

POSIX.1-2008 Strict Rules
=========================

**The following syntax rules are non-exhaustive but give a quick overview of the standard:**

- Options are denoted with hyphen ``-`` prefixes and separated by blank characters.
- Optional words are enclosed between square braquets ``[]``.
- Exclusive expressions are denoted with the pipe ``|`` character.
- Alternatively, mutually-exclusive options and operands may be listed with multiple synopsis lines. For example:

  .. container:: synopsis

     | **utility_name -d[**-a\ **][**-c option_argument\ **][**\ operand\ **...]**
     | **utility_name[**-a\ **][**-b\ **][**\ operand\ **...]**

- Repeatable expressions are followed up by ellipsis ``…`` or three dots character.
- Names that require substitution could be enclosed in angle-braquets ``<>`` or embedded with underscore ``_`` characters (non-mandatory).
- Utilities with many flags generally show all of the individual flags (that do not take option-arguments) grouped, as in:

  .. container:: synopsis

     **utility_name** **[**-abcDxyz\ **][**\ -p arg\ **][**\ operand\ **]**

- Utilities with very complex arguments may be shown as follows:

  .. container:: synopsis

     **utility_name [**\ options\ **][**\ operands\ **]**

- Unless otherwise specified, whenever an operand or option-argument is, or contains, a numeric value, the number is interpreted as a decimal integer.

POSIX.1-2008 Guidance Rules
===========================

POSIX.1-2008 reference\ [#posix-synopsis]_ defines guidance rules which shall be implemented.

**Guidelines are provided as non-mandatory, but many are implemented in Unix system utilities. This list is non-exhaustive, but reatains rules which might affect the cmdse project:**

- **G1, 2** Utility names should be between two and nine characters, inclusive, and should include lowercase letters (the lower character classification) and digits only from the portable character set.
- **G3** Each option name should be a single alphanumeric character (the **alnum** character classification) from the portable character set. Multi-digit options should not be allowed.
- **G4** All options should be preceded by the '-' delimiter character.
- **G5** One or more options without option-arguments, followed by at most one option that takes an option-argument, should be accepted when grouped behind one ``-`` delimiter.
- **G6** Each option and option-argument should be a separate argument, except as noted in Utility Argument Syntax, item (2).
- **G8** When multiple option-arguments are specified to follow a single option, they should be presented as a single argument, using comma ``,`` characters within that argument or blank characters within that argument to separate them.
- **G9** All options should precede operands on the command line.
- **G10** The first ``--`` argument that is not an option-argument should be accepted as a delimiter indicating the end of options. Any following arguments should be treated as operands, even if they begin with the ``-`` character.
- **G11** The order of different options relative to one another should not matter, unless the options are documented as mutually-exclusive.
- **G12** The order of operands may matter and position-related interpretations should be determined on a utility-specific basis.
- **G13** For utilities that use operands to represent files to be opened for either reading or writing, the ``-`` operand should be used to mean only standard input (or standard output when it is clear from context that an output file is being specified) or a file named '-'.

.. http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html
.. https://stackoverflow.com/questions/8957222/are-there-standards-for-linux-command-line-switches-and-arguments

Accepted non-POSIX rules
========================

- POSIX guideline **G3** must be extended with GNU-style and X-Toolkit style options.

*to be continued*

.. todo:: Write a list of accepted non-POSIX rules

.. _option-description-model-section:

Option Description Model
########################

An option description model is a set of :term:`option descriptions <option description>`. The latter is defined as follow:

.. container:: definition

   Structured data composed of a description text field and a collection of match models.
   Each match model is related to an :term:`option expression variant` and has a one-or-two groups regular expression.
   When two groups can be matched, the latest is the option parameter of an explicit option assignments.

It is traditionnaly found on linux manual pages in the "OPTIONS" section. Bellow an invented example:

.. code-block:: console

   OPTIONS
       -h, --help
           Display help.

       -a, --all
           Select all items.

        ...


.. _option-expression-syntax:

Option expressions Variants
===========================

Three option styles exists in the unix world.

#. `POSIX Style <http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html>`_
#. `GNU Style <https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html>`_
#. `X Toolkit Style <http://www.catb.org/esr/writings/taoup/html/ch10s05.html>`_

In the :numref:`option-expression-variants`, different option expression variants are listed and their corresponding style.

.. _option-expression-variants:
.. list-table:: Option expression variants
  :header-rows: 1
  :widths: 1 20 40 15 10

  * - | Expression variant
      | assign. value in "<>"
    - Variant
    - Description
    - Style
    - Prevalence
  * - ``-o``
    - ``POSIX_SHORT_SWITCH``
    - One-letter option switch
    - POSIX
    - Very common
  * - ``-opq``
    - ``POSIX_GROUPED_SHORT_FLAGS``
    - One-letter option stack switch. This is equivalent to ``-o -p -q``.
    - POSIX
    - Common
  * - ``-o <value>``
    - ``POSIX_SHORT_ASSIGNMENT``
    - One-letter option switch with value assignment
    - POSIX
    - Very common
  * - ``-o<value>``
    - ``POSIX_SHORT_STICKY_VALUE``
    - One-letter option switch with integer sticky value
    - POSIX
    - Common
  * - ``-option``
    - ``X2LKT_SWITCH``
    - Long option switch
    - X Toolkit
    - Less common
  * - ``+option``
    - ``X2LKT_REVERSE_SWITCH``
    - Long option switch reset (:linuxman:`xterm(1)`)
    - X Toolkit
    - Rare
  * - ``-option <value>``
    - ``X2LKT_IMPLICIT_ASSIGNMENT``
    - Long option switch with implicit value assignment
    - X Toolkit
    - Less common
  * - ``-option=<value>``
    - ``X2LKT_EXPLICIT_ASSIGNMENT``
    - Long option switch with explicit value assignment
    - X Toolkit
    - Less common
  * - ``--option``
    - ``GNU_SWITCH``
    - Long option switch
    - GNU
    - Very common
  * - ``--option <value>``
    - ``GNU_IMPLICIT_ASSIGNMENT``
    - Long option switch with implicit value assignement
    - GNU
    - Very common
  * - ``--option=<value>``
    - ``GNU_EXPLICIT_ASSIGNMENT``
    - Long option switch with explicit value assignment
    - GNU
    - Very common
  * - ``--``
    - ``POSIX_END_OF_OPTIONS``
    - Signal end of options, i.e. upcoming arguments must be treated as :term:`operands <operand>`\ [#end-of-options]_
    - GNU
    - Common
  * - ``option``
    - ``HEADLESS_OPTION``
    - An "old style" option, see :linuxman:`tar(1)`\ [#tar]_ for an example.
    - NONE
    - Very rare


.. _option-schemes-section:

Option scheme
#############

An :term:`option scheme` is a set of :term:`option expression variants <option expression variant>` which delimits the option expressions supported by a :term:`command identifier`. A list of presets provided by |project-name| is shown in :numref:`option-schemes`.

.. _option-schemes:
.. list-table:: List of option scheme presets
  :header-rows: 1
  :widths: 25 40 35

  * - Preset
    - Description
    - Supported option expression variants
  * - POSIX-Strict
    - Option expressions can be can be composed solely with POSIX-styled variants.
    - * ``POSIX_SHORT_SWITCH``
      * ``POSIX_GROUPED_SHORT_FLAGS``
      * ``POSIX_SHORT_ASSIGNMENT``
      * ``POSIX_END_OF_OPTIONS``
  * - Linux-Standard
    - Option expressions can be of any common GNU or POSIX-styled variants. Very often, one option has either one GNU and one POSIX variant, either one POSIX variant.
    - * ``POSIX_SHORT_SWITCH``
      * ``POSIX_GROUPED_SHORT_FLAGS``
      * ``POSIX_SHORT_ASSIGNMENT``
      * ``GNU_SWITCH``
      * ``GNU_IMPLICIT_ASSIGNMENT``
      * ``GNU_EXPLICIT_ASSIGNMENT``
      * ``POSIX_END_OF_OPTIONS``
  * - Linux-Explicit
    - Option expressions can be of any common GNU or POSIX-styled variants with implicit assignments.
    - * ``POSIX_SHORT_SWITCH``
      * ``POSIX_GROUPED_SHORT_FLAGS``
      * ``POSIX_SHORT_ASSIGNMENT``
      * ``GNU_SWITCH``
      * ``GNU_EXPLICIT_ASSIGNMENT``
      * ``POSIX_END_OF_OPTIONS``
  * - Linux-Implicit
    - Option expressions can be of any common GNU or POSIX-styled variants with explicit assignments.
    - * ``POSIX_SHORT_SWITCH``
      * ``POSIX_GROUPED_SHORT_FLAGS``
      * ``POSIX_SHORT_ASSIGNMENT``
      * ``GNU_SWITCH``
      * ``GNU_IMPLICIT_ASSIGNMENT``
      * ``POSIX_END_OF_OPTIONS``
  * - X-Toolkit-Strict
    - Option expressions can be composed solely with X-Toolkit-styled variants.
    - * ``X2LKT_SWITCH``
      * ``X2LKT_REVERSE_SWITCH``
      * ``X2LKT_IMPLICIT_ASSIGNMENT``
      * ``X2LKT_EXPLICIT_ASSIGNMENT``
      * ``POSIX_END_OF_OPTIONS``
  * - X-Toolkit-Standard
    - Option expressions can be composed solely with X-Toolkit-styled variants and POSIX short.
    - * ``X2LKT_SWITCH``
      * ``X2LKT_REVERSE_SWITCH``
      * ``X2LKT_IMPLICIT_ASSIGNMENT``
      * ``X2LKT_EXPLICIT_ASSIGNMENT``
      * ``POSIX_SHORT_SWITCH``
      * ``POSIX_END_OF_OPTIONS``
  * - X-Toolkit-Explicit
    - Option expressions can be composed solely with X-Toolkit-styled variants and POSIX short.
    - * ``X2LKT_SWITCH``
      * ``X2LKT_REVERSE_SWITCH``
      * ``X2LKT_EXPLICIT_ASSIGNMENT``
      * ``POSIX_SHORT_SWITCH``
      * ``POSIX_END_OF_OPTIONS``
  * - X-Toolkit-Implicit
    - Option expressions can be composed solely with X-Toolkit-styled variants and POSIX short.
    - * ``X2LKT_SWITCH``
      * ``X2LKT_REVERSE_SWITCH``
      * ``X2LKT_IMPLICIT_ASSIGNMENT``
      * ``POSIX_SHORT_SWITCH``
      * ``POSIX_END_OF_OPTIONS``


.. _subcommands-section:

Sub-commands
############

*to be writen*

----------------------

.. container:: footnotes

   .. [#posix-synopsis] See `POSIX.1-2008, sec. 12.1 <http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html>`_, “Utility Conventions”
   .. [#end-of-options] See `POSIX.1-2008, sec. 12.1 <http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html>`_, guideline 10 which states that “The first ``--`` argument that is not an option-argument should be accepted as a delimiter indicating the end of options. Any following arguments should be treated as operands, even if they begin with the ``-`` character.” This behavior is implemented in a great number of bash :term:`builtin commands <builtin command>` and unix programs.
   .. [#doclifter-project] See `Gitlab project <https://gitlab.com/esr/doclifter>`_
   .. [#tar] `Tar "Old Option Style" <https://www.gnu.org/software/tar/manual/html_section/tar_21.html#SEC38>`_
