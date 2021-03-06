#####################
Command snippet model
#####################

General Requirements
####################


.. requirement:: target-shell

 The :term:`command snippets <command snippet>` handled by |project-name| tools should be of ``bash`` and ``POSIX`` shell dialects.


.. requirement:: command-snippet-endoding

  The :term:`command snippets <command snippet>` text should be stored, processed and transported in US-ASCII encoding.

.. requirement:: command-snippet-metadata-encoding

  The :term:`command snippet metadata` text fields should be stored, processed and transported in US-ASCII encoding.

Command snippet requirements
############################

.. requirement:: valid-command-snippet

  A :term:`command snippet` text must meet the following carracteristics to be valid:

  * Must be a sequence of US-ASCII :term:`character literals <character literal>`
  * Must be valid ``POSIX`` / ``bash v4`` shell dialect

.. requirement:: command-parameters

  A :term:`command parameter` is denoted with POSIX-shell positional parameters\ [#positional-parameter]_ syntax: ``$1 .. $9`` or their in-braces equivalent ``${1}``.

.. _shell-processing-workflow:

Shell processing workflow
#########################

The way |project-name| tools handle snippets and extract a great deal of information to the end-user requires a good understanding on how unix shells process text into commands.

.. note::

  Some paragraphs of this section are greedly copied from `The Bourne-Again Shell in "The Architecture of Open Source Applications" <http://aosabook.org/en/bash.html>`_

The first stage of the processing pipeline is input processing (:numref:`bash-processing-pipeline`): taking characters from the terminal or a file, breaking them into lines, and passing the lines to the shell parser to transform into commands. The lines are sequences of characters terminated by newlines\ [#bash-exceptions]_. Such a shell-processable line is referred to as a :term:`command`.

.. _bash-processing-pipeline:
.. digraph:: processingpipeline
  :caption: Bash processing pipeline

  rankdir=TB;
  graph[ranksep=1,compound=true,splines = spline];
  {rank=same; PS WE WS GL}
  {rank=same; CS CE}
  PS  [label=<parsing  <BR/> <FONT POINT-SIZE="10">Extract semantics</FONT>>];
  LA  [shape=box,label=<lexical analyser <BR/> <FONT POINT-SIZE="10">Identify tokens delemited <BR/> with metacharacters</FONT>>];
  PA  [shape=box,label=<parser <BR/> <FONT POINT-SIZE="10">Make sense of tokens</FONT>>];
  IP  [shape=doubleoctagon,label=<input processing <BR/> <FONT POINT-SIZE="10">Grab one line</FONT>>];
  WE  [label="word expansion"];
  EX  [label="execution"];
  CS  [label=<command substitution<BR/> <FONT POINT-SIZE="10" FACE="monospace">parse_comsub</FONT>>];
  CE  [label="command extraction"];

  WS  [label="word splitting"];
  GL  [label="pathname expansion"];
  IP -> PS -> WE -> WS -> GL -> CE -> EX;
  subgraph cluster_parsing {
    style=filled;
    color="#f5f5f0";
    PS -> PA [dir=none,style=dotted,lhead=cluster_parsing];
    PA -> LA [dir=both,style=dashed];
  }
  CS -> PA [dir=none,style=dotted,lhead=cluster_parsing];
  WE -> CS;
  EX -> CS [style=dashed,dir=both];


The second step is parsing. The initial job of the parsing engine is lexical analysis: to separate the stream of characters into words and apply meaning to the result. The :term:`word` is the basic unit on which the parser operates. :term:`Words <word>` are sequences of characters separated by metacharacters, which include simple separators like spaces and tabs, or characters that are special to the shell language, like semicolons and ampersands.

The lexical analyzer takes lines of input, breaks them into tokens at metacharacters, identifies the tokens based on context, and passes them on to the parser to be assembled into statements and commands. There is a lot of context involved—for instance, the word for can be a reserved word, an identifier, part of an assignment statement, or other word, and the following is a perfectly valid command:

.. code-block:: bash

  for for in for; do for=for; done; echo $for

that displays ``for``.

The parser encodes a certain amount of state and shares it with the analyzer to allow the sort of context-dependent analysis the grammar requires. For example, the lexical analyzer categorizes words according to the token type: reserved word (in the appropriate context), word, assignment statement, and so on. In order to do this, the parser has to tell it something about how far it has progressed parsing a command, whether it is processing a multiline string (sometimes called a "here-document"), whether it's in a case statement or a conditional command, or whether it is processing an extended shell pattern or compound assignment statement.

Much of the work to recognize the end of the command substitution during the parsing stage is encapsulated into a single function (``parse_comsub``). This function has to know about here documents, shell comments, metacharacters and word boundaries, quoting, and when reserved words are acceptable (so it knows when it's in a ``case`` statement); it took a while to get that right. When expanding a command substitution during word expansion, bash uses the parser to find the correct end of the construct, that is a right parenthesis.

The parser returns a single C structure representing a :term:`command` (which, in the case of :term:`compound commands <compound command>` like loops, may include other commands in turn) and passes it to the next stage of the shell's operation: word expansion. The command structure is composed of :term:`command` objects and lists of words.

.. _bash-word-expansions:
.. digraph:: wordexpansions
  :caption: Bash word expansions order

  graph[ranksep=1,compound=true,splines=spline];
  node[shape="plaintext"];
  PVE [label=<parameter expansion <BR/><BR/><FONT POINT-SIZE="10" FACE="monospace">$PARAM<BR/>${PARAM:...}</FONT>>];
  ARE [label=<arithmetic expansion<BR/><BR/><FONT POINT-SIZE="10" FACE="monospace">$(( EXPRESSION ))<BR/> $[ EXPRESSION ]</FONT>>];
  CMS [label=<command substitution<BR/><BR/><FONT POINT-SIZE="10" FACE="monospace">$( COMMAND )<BR/>`COMMAND`</FONT>>];
  TLE [label=<tilde expansion<BR/><BR/><FONT POINT-SIZE="10" FACE="monospace">~<BR/>~+<BR/>~-</FONT>>];
  BRE [label=<brace expansion<BR/><BR/><FONT POINT-SIZE="10" FACE="monospace">{a,b,c}</FONT>>];
  PRS [label=<process substitution<BR/><BR/><FONT POINT-SIZE="10" FACE="monospace">&lt;(COMMAND)</FONT>>];

  BRE -> TLE;
  TLE -> PVE;
  TLE -> ARE;
  TLE -> CMS;
  TLE -> PRS;

Word expansions (:numref:`bash-word-expansions`) are done in a peculiar order, with the last step allowing four expansions to run in parallel. As previously mentionned, command (and process) substitution requires the shell to use the parser and execute the corresponding command in a subshell, using its output to replace the expression previously occupied by the construct. This participate in interwinded steps and context-dependant analysis during shells text processing.

.. _call-expression-structure:

Call expression structure
#########################

.. note::

  See the :numref:`call-expression-parsing` for details on how |project-name| tools should parse call expressions.

|project-name| tooling will provide a static analysis of given :term:`snippets <command snippet>` to infer some understanding of invoked :term:`utility executables <utility executable>` and their arguments. Given the dynamic nature of unix shell input processing and the context-dependent syntax analysis involved (:numref:`shell-processing-workflow`), there is no guarantee that there will be a perfect match between information gathered during static analysis and runtime effective invocations.
The "unit of work" to isolate such runtime invocations is reffered to as a :term:`call expression`.
A :term:`call expression` is a section of the :term:`command snippet` close to the definition of a bash simple command [#bashman]_. Here is a classic example:

.. code-block:: shell

  ls -la /usr/bin

Static call expressions
=======================

When a "context-free" situation is meeted, the :term:`call expression` is considered "static". The identification of elements in such a static :term:`call expression` is done after static expansion, that is after static variable expansions are proceeded.
A rudimentary formal definition is provided in the bellow figure (:numref:`abnf-call-expression`) given a context-free situation.

.. _abnf-call-expression:
.. code-block:: abnf
    :caption: Static call expression formal :rfc:`ABNF <7405>` syntax definition

    COMMAND-IDENTIFIER       = (ALPHA / DIGIT) *(ALPHA / DIGIT / HYPHEN / UNDERSCORE)
    ARGUMENT                 = WORD
    CALL-EXPRESSION          = *(ASSIGNMENT) COMMAND-IDENTIFIER *(ARGUMENT)


.. note::

  See the :doc:`/pages/appendix/grammar-commons` and :doc:`/pages/appendix/bash-grammar` documents for the depending token definitions.

To qualify as "static", a :term:`call expression` must meet the following constrains:

- the :term:`command identifier` is not the result of word expansion, unless after a double-dash\ [#bash-getopts]_
- expanding variables and positionnal parameters are double-quoted to be isolated as a single argument, unless after a double-dash\ [#bash-getopts]_
- command substitutions are double-quoted to be isolated as a single argument, unless after a double-dash\ [#bash-getopts]_
- tilde and path expansions are allowed
- variable expansions can be unquoted for a list of options for example, but a static assignment must be provided in the :term:`snippet <command snippet>`

An assignment is considered static if it follows those constrains:

- it is not part of a :term:`call expression`
- it is not embedded in a subshell, such as command or process substitution
- variable and positionnal parameter expansions are double-quoted


Examples :

.. code-block:: bash

  # OK, positionnal parameter quoted
  echo "$1"

.. code-block:: bash

  # Not OK, positionnal parameter unquoted
  echo $1

.. code-block:: bash

  # OK, positionnal parameter unquoted after double-dash
  grep -- -v $1

.. code-block:: bash

  # OK, options are unquoted but expanded to a static assignment
  MY_OPTS="--summarize --human-readable"
  du $MY_OPTS "$1"

.. code-block:: bash

  # OK
  # - options are unquoted but expanded to a static assignment
  # - positionnal argument unquoted but after double-dash
  DU_OPTS="--summarize --human-readable"
  du $DU_OPTS -- $1

Command identifier
==================

A :term:`command identifier` will be ultimately resolved to a :term:`builtin command` or a :term:`utility name`.
Within the unix system, the mapping between the :term:`command identifier` and the :term:`utility executable` is bijective, that is there is exactly one executable that can be matched from its identifier, and reciprocically, there is exactly one identifier that can be matched from an executable\ [#path-resolution]_.

However, from |project-name| perspective, the association must be done with a loosly defined :term:`utility interface model` and is therefore non-bijective.
First, because multiple programs can hold the same :term:`utility name`. Second, because this mapping is done in the context of analysing a static :term:`call expression`, and the association will be considered valid for a peculiar :term:`version range` of the program supporting some set of options.

Arguments
=========

Arguments are :term:`words <word>` following the :term:`command identifier`.
Discriminating between option expressions and :term:`operands <operand>` and giving semantics to each argument is a central aspect of |project-name| to fulfill its pedagogical goal.

Option expressions
++++++++++++++++++

Option expressions resolve to option assignment to the program.
There is a great variety of expectable expressions, see :numref:`option-expression-syntax`.

Operands
++++++++

:term:`Operands <operand>` are the subject upon which the program operates.


Analytic model
##############

`to be written`

.. todo:: Define command snippet analytic model

Forks
##################

`to be written`

.. todo:: Define command snippet forks

Sub-command snippet
===================

`to be written`

Commmand snippet variant
========================

`to be written`

Alias
=====

`to be written`

----------------------

.. container:: footnotes

  .. [#bashman] :linuxman:`bash(1)`
  .. [#bash-exceptions] Four exceptions: multiple lines can be processed in one row when terminated with the escape character, ``\`` and `here-documents <https://en.wikipedia.org/wiki/Here_document>`_ are read multilines until the provided WORD is matched. Also :term:`compound commands <compound command>` such as ``for`` construct may be written in multiple lines, needing some look-ahead line processing before execution. Finally, the semicolon ``;`` metacharacter is interpreted as a line delimiter.
  .. [#bash-getopts] In a great number of bash :term:`builtin commands <builtin command>` and unix programs, the double-dash ``--`` is a signal to inform that any upcoming argument should be treated as an :term:`operand`. This behavior is implemented by the :linuxman:`getopt(3)` GNU function, which documentation states that "the special argument '--' forces an end of option-scanning".
  .. [#path-resolution] The shell will resolve the first :term:`utility executable` that matches the :term:`utility name` while iterating over each path expression hold in the :envvar:`PATH` variable. So this executable should be considered the one and only valid executable.
  .. [#positional-parameter] See `POSIX.1-2008, sec. 2.5.1 <http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_05_01>`_
