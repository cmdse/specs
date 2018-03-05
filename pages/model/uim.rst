#######################
Utility Interface Model
#######################

A :term:`utility interface model` is defined as follow:

.. container:: definition

  Structured data describing the command line interface capabilities of a :term:`utility executable` identified by its :term:`utility name`. The capabilities are defined through:

  - a set of :term:`synopses <synopsis>` of minimum length one;
  - an :term:`option description model` which is a set of options and their related expressions;
  - an :term:`option scheme`;
  - an optional set of :term:`sub-commands <sub-command>`.

  Those are defined for a peculiar :term:`version range`.
  The term “utility” is directly borrowed from the POSIX.1-2008 reference\ [#posix-synopsis]_.

Synopses
########


POSIX.1-2008 reference\ [#posix-synopsis]_ defines strictly the syntax of a utility (or command) synopsis:

.. container:: synopsis

   **utility_name[**-a\ **][**-b\ **][**-c option_argument\ **][**-d\ **|**-e\ **][**-f\ **[**\ option_argument\ **]][**\ operand\ **...]**

This standard syntax definition is globally well defined. :command:`doclifter`\ [#doclifter-project]_ uses it to generate docbook files with ``<refsynopsis>`` tags:

.. container:: quote

   It lifts over **93%** of these pages without requiring any hand-hacking.

He maintains a list of non-complying tools on a bare Ubuntu installation\ [#doclifter-patches]_, in which are described 10 errors regarding SYNOPSIS interpolation:

.. code-block:: text

    C	Broken command synopsis syntax. This may mean you're using a
        construction in the command synopsis other than the standard
        [ ] | { }, or it may mean you have running text in the command synopsis
        section (the latter is not technically an error, but most cases of it
        are impossible to translate into DocBook markup), or it may mean the
        command syntax fails to match the description.
    D	Non-break space prevents doclifter from incorrectly interpreting
        "Feature Test" as end of function synopsis.
    H	Renaming SYNOPSIS because either (a) third-party viewers and
        translators will try to interpret it as a command synopsis and become
        confused, or (b) it actually needs to be named "SYNOPSIS" with no
        modifier for function protoypes to be properly recognized.
    M	Synopsis section name changed to avoid triggering command-synopsis
        parsing.
    U	Unbalanced group in command synopsis. You probably forgot
        to open or close a [ ] or { } group properly.
    Z	Your Synopsis is exceptionally creative.  Unfortunately, that means
        it cannot be translated to structural markup even when things like
        running-text inclusions have been moved elswhere.
    i	Non-ASCII character in document synopsis can't be parsed.
    j	Parenthesized comments in command synopsis.  This is impossible
        to translate to DocBook.
    p	Synopsis was incomplete and somewhat garbled.
    t	Synopsis has to be immediately after NAME section for DocBook


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


Option Description Model
########################

Sub-commands
############

*to be writen*

----------------------

.. container:: footnotes

   .. [#posix-synopsis] See `POSIX.1-2008, sec. 12.1 <http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html>`_, “Utility Conventions”
   .. [#doclifter-project] See `Gitlab project <https://gitlab.com/esr/doclifter>`_
   .. [#doclifter-patches] See `PATCHES file from doclifter project <https://gitlab.com/esr/doclifter/raw/master/PATCHES>`_
