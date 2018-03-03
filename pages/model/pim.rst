#######################
Program Interface Model
#######################

Synopses
########

POSIX.1-2008 Strict Rules
=========================

POSIX.1-2008 reference\ [#posix-synopsis]_ defines strictly the syntax of a utility (or command) synopsis:

   **utility_name[**-a\ **][**-b\ **][**-c option_argument\ **]**
       **[**-d\ **|**-e\ **][**-f\ **[**\ option_argument\ **]][**\ operand\ **...]**

**The following syntax rules are non-exhaustive but give a quick overview of the standard:**

- Options are denoted with hyphen ``-`` prefixes and separated by blank characters.
- Optional words are enclosed between square braquets ``[]``.
- Exclusive expressions are denoted with the pipe ``|`` character.
- Alternatively, mutually-exclusive options and operands may be listed with multiple synopsis lines. For example:

    | **utility_name -d[**-a\ **][**-c option_argument\ **][**\ operand\ **...]**
    | **utility_name[**-a\ **][**-b\ **][**\ operand\ **...]**

- Repeatable expressions are followed up by ellipsis ``…`` or three dots character.
- Names that require substitution could be enclosed in angle-braquets ``<>`` or embedded with underscore ``_`` characters (non-mandatory).
- Utilities with many flags generally show all of the individual flags (that do not take option-arguments) grouped, as in:

     **utility_name** **[**-abcDxyz\ **][**\ -p arg\ **][**\ operand\ **]**
- Utilities with very complex arguments may be shown as follows:

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

Option Description Model
########################

Sub-commands
############

*to be writen*

----------------------

.. container:: footnotes

   .. [#posix-synopsis] See `POSIX.1-2008, sec. 12.1 <http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html>`_, “Utility Conventions”
