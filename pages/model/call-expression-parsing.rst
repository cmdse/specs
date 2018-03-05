.. _call-expression-parsing:

########################
Call expressions parsing
########################

To add semantics, the :term:`call expression` parser will try to guess the nature of arguments by converting them into tokens.
After givent some context, such tokens will be assembled to metadata, which is comprised of:

- option assignment expressions and a description of left-side and value parts
- standalone option expressions and a description of the underlying option
- command operands and a their description


Parsing workflow
################

The :numref:`call-expression-process-flow` shows an overview of the different steps involved in call expression parsing.
Those steps are grouped into higher-level steps (*A*, *B*, *C*). The core of call expression parsing is done in *B* through tokenization (see :numref:`token-typings` for a better understanding on token typing). But some static bash analysis must be done upstream (*A*, see :numref:`call-expression-structure` for more details about this step).
After parsing, the call expression must be assembled to form a metadata structure (*C*).

.. _call-expression-process-flow:
.. uml:: /diagrams/call-expr-process.puml
   :caption: Call expression parsing dataflow
   :align: center
   :width: 500

.. _token-typings:

Tokenization
############

The first step consists in creating a list of tokens that maps the command arguments (:numref:`call-expression-process-flow`, *item B.1*). The token types will be updated thanks to basic inference rules and command meta-information. These token types are first assigned to "context-free" tokens (see :numref:`context-free-tokens` for a listing). "Context-free" means that their nature can be captured without the need for information about their siblings or position, and is therefore trivial.

In a second step (:numref:`call-expression-process-flow`, *item B.3*), token types are assigned to "semantic token type" values (:numref:`semantic-token-properties`) given some inference rules and information extracted from the :term:`utility interface model` (PIM, :numref:`call-expression-process-flow`, *item B.2*). The underlying algorithm is described in details in :numref:`option-parsing-algorithm`.

When semantic type cannot be inferred, a prompt to the user is processed (:numref:`call-expression-process-flow`, *item B.4*).



Context-free tokens typings
===========================

The :numref:`context-free-tokens` shows a list of the context-free token types.
In the last column, a list of semantic type candidates is provided. This list shows which semantic types this context-free type can be transformed to.
Some of these context-free token types overlap semantic token types, because they have only one semantic candidate (resolved to *self*). They are considered "non-ambiguous" and don't need further transformation.

.. _context-free-tokens:
.. list-table:: Context-free token types
  :header-rows: 1
  :widths: 40 10 10 40

  * - Context-free token type
    - Is option flag?
    - | Examples
      | *given in*
      | *brackets* "[]"
    - Semantic type candidates
  * - ``POSIX_SHORT_STICKY_VALUE``
    - yes
    - ``[-o<int-value>]``
    - *self*
  * - ``GNU_EXPLICIT_ASSIGNMENT``
    - yes
    - ``[--option=<value>]``
    - *self*
  * - ``X2LKT_EXPLICIT_ASSIGNMENT``
    - yes
    - ``[-option=<value>]``
    - *self*
  * - ``X2LKT_REVERSE_SWITCH``
    - yes
    - ``[+option]``
    - *self*
  * - ``POSIX_END_OF_OPTIONS``
    - yes
    - ``[--]``
    - *self*
  * - ``ONE_DASH_LETTER``
    - yes
    - | ``[-o] <value>``
      | ``[-o]``
    - * ``POSIX_SHORT_ASSIGNMENT_LEFT_SIDE``
      * ``POSIX_SHORT_SWITCH``
  * - ``ONE_DASH_WORD_ALPHANUM``
    - yes
    - | ``[-opq]```
      | ``[-option]```
    - * ``POSIX_STACKED_SHORT_SWITCHES``
      * ``X2LKT_SWITCH``
      * ``X2LKT_IMPLICIT_ASSIGNEMNT_LEFT_SIDE``
  * - ``ONE_DASH_WORD``
    - yes
    - | ``[-long-option]``
      | ``[-long-option] <value>``
    - * ``X2LKT_SWITCH``
      * ``X2LKT_IMPLICIT_ASSIGNEMNT_LEFT_SIDE``
  * - ``TWO_DASH_WORD``
    - yes
    - ``[--option]``
    - * ``GNU_SWITCH``
      * ``GNU_IMPLICIT_ASSIGNMENT_LEFT_SIDE``
  * - ``OPT_WORD``
    - no\ [#headless-option-exception]_
    - | ``-o [<value>]``
      | ``--option [<value>]``
      | ``-option [<value>]``
      | ``option``
    - * ``OPERAND``
      * ``POSIX_SHORT_ASSIGNMENT_VALUE``
      * ``GNU_IMPLICIT_ASSIGNMENT_VALUE``
      * ``X2LKT_IMPLICIT_ASSIGNMENT_VALUE``
      * ``HEADLESS_OPTION``
  * - ``WORD``
    - no
    - | ``ls [~/]``
      | ``-o /some/file``
      | ``--option /some/files``
      | ``-option /some/file``
    - * ``OPERAND``
      * ``POSIX_SHORT_ASSIGNMENT_VALUE``
      * ``GNU_IMPLICIT_ASSIGNMENT_VALUE``
      * ``X2LKT_IMPLICIT_ASSIGNMENT_VALUE``


Semantic tokens typings
=======================

.. note::

  See the :numref:`option-expression-syntax` for details on the existing option expression styles from which a majority of those semantic token types are derived.

The :numref:`semantic-token-properties` shows a list of the semantic token types. Those types have a positional model (:numref:`token-positional-model`) from which rules can be inferred.
For example of such inferences, in the :term:`call expression` ``find . -type file``, "file" would be a token which positional model is ``OPT_IMPLICIT_ASSIGNMENT_VALUE`` and type ``X2LKT_IMPLICIT_ASSIGNMENT_VALUE`` and "-type" a ``OPT_IMPLICIT_ASSIGNMENT_LEFT_SIDE`` of type ``X2LKT_IMPLICIT_ASSIGNEMNT_LEFT_SIDE``.

.. _token-positional-model:
.. list-table:: Token positional model
  :header-rows: 1
  :widths: 20 40 10 10 10 10

  * - Positionnal model name
    - Description
    - Binding
    - | is
      | "option part"
    - | is
      | "option flag"
    - | is
      | "semantic"
  * - ``OPT_IMPLICIT_ASSIGNMENT_LEFT_SIDE``
    - The left side of an implicit option assignment in the form ``left-side <value>``.
    - *right*
    - *yes*
    - *yes*
    - *yes*
  * - ``OPT_IMPLICIT_ASSIGNMENT_VALUE``
    - The right side of an implicit option assignment in the form ``left-side <value>``.
    - *left*
    - *yes*
    - *no*
    - *yes*
  * - ``STANDALONE_OPT_ASSIGNMENT``
    - A token option with value assignment.
    - *none*
    - *yes*
    - *yes*
    - *yes*
  * - ``OPT_SWITCH``
    - An option switch, that is without value.
    - *none*
    - *yes*
    - *yes*
    - *yes*
  * - ``COMMAND_OPERAND``
    - A command operand.
    - *none*
    - *no*
    - *no*
    - *yes*
  * - ``UNSET``
    - Positional model unset.
    - *inferred*
    - *inferred*
    - *inferred*
    - *false*

In the :numref:`token-positional-model`, the first 5 models are applicable for semantic token types, while the latest is applicable for context-free types. The attributes of the latest are dynamically inferred regarding the set of semantic candidates associated with a token instance. For example, if a context-free type has semantic candidates which positionnal model all have is "option part" set to true, it will infer the attribute to true.


.. _semantic-token-properties:
.. list-table:: Semantic token types
  :header-rows: 1
  :widths: 10 10 10

  * - Semantic token type
    - | Example, *given in brackets*, "[]"
    - | Positional model
  * - ``X2LKT_REVERSE_SWITCH``
    - ``[+option]``
    - ``OPT_SWITCH``
  * - ``POSIX_SHORT_SWITCH``
    - ``[-o]``
    - ``OPT_SWITCH``
  * - ``POSIX_STACKED_SHORT_SWITCHES``
    - ``[-opq]``
    - ``OPT_SWITCH``
  * - ``POSIX_SHORT_ASSIGNMENT_LEFT_SIDE``
    - ``[-o] <value>``
    - ``OPT_IMPLICIT_ASSIGNMENT_LEFT_SIDE``
  * - ``POSIX_SHORT_ASSIGNMENT_VALUE``
    - ``-o [<value>]``
    - ``OPT_IMPLICIT_ASSIGNMENT_VALUE``
  * - ``POSIX_SHORT_STICKY_VALUE``
    - ``[-o<value>]``
    - ``STANDALONE_OPT_ASSIGNMENT``
  * - ``X2LKT_SWITCH``
    - ``[-option]``
    - ``OPT_SWITCH``
  * - ``X2LKT_IMPLICIT_ASSIGNEMNT_LEFT_SIDE``
    - ``[-option] <value>``
    - ``OPT_IMPLICIT_ASSIGNMENT_LEFT_SIDE``
  * - ``X2LKT_IMPLICIT_ASSIGNMENT_VALUE``
    - ``-option [<value>]``
    - ``OPT_IMPLICIT_ASSIGNMENT_VALUE``
  * - ``X2LKT_EXPLICIT_ASSIGNMENT``
    - ``[-option=<value>]``
    - ``STANDALONE_OPT_ASSIGNMENT``
  * - ``GNU_SWITCH``
    - ``--option``
    - ``OPT_SWITCH``
  * - ``GNU_IMPLICIT_ASSIGNMENT_LEFT_SIDE``
    - ``[--option] <value>``
    - ``OPT_IMPLICIT_ASSIGNMENT_LEFT_SIDE``
  * - ``GNU_IMPLICIT_ASSIGNMENT_VALUE``
    - ``--option [<value>]``
    - ``OPT_IMPLICIT_ASSIGNMENT_VALUE``
  * - ``GNU_EXPLICIT_ASSIGNMENT``
    - ``[--option=<value>]``
    - ``STANDALONE_OPT_ASSIGNMENT``
  * - ``POSIX_END_OF_OPTIONS``
    - ``[--]``
    - ``OPT_SWITCH``
  * - ``OPERAND``
    - ``[<operand>]``
    - ``COMMAND_OPERAND``
  * - ``HEADLESS_OPTION``
    - ``[option]``
    - ``OPT_SWITCH``

Analytic Model
##############

.. _snippet-class-diagram:
.. uml:: /diagrams/snippet.puml
 :align: center
 :width: 100%

.. _option-parsing-algorithm:

Option parsing algorithm
########################

This section offers an in-depth look at tokenization (B) step from :numref:`call-expression-process-flow`.
The parser will hold in memory a list of tokens (:numref:`snippet-class-diagram`). Each of these starts with a context-free type. The parser's job is considered done when all tokens hold a semantic type.
To get there, it will proceed with the following steps :

#. Initiate the token list with the result of mapping arguments to context-free token generation.
#. Fetch the :term:`utility interface model` (PIM) if it exists.
#. Provide the list and the PIM as arguments of the *parse* function (:numref:`algo-parse`). Such function will do the following:

   #. Check for the existence of an ``POSIX_END_OF_OPTIONS`` typed token (:numref:`algo-check-end-of-options`) and convert to operands all remaining tokens to the right.
   #. Repeat the following operation until the last two operations didn't turn out to at least one context-free to semantic conversion:

        For each non-semantic token, *inferRight* (:numref:`algo-infer-right`) and *inferLeft* (:numref:`algo-infer-left`). Those functions will try to infer the semantic type by checking its siblings'. For example, if the left sibling token type is ``X2LKT_IMPLICIT_ASSIGNEMNT_LEFT_SIDE``, the only possible type for this token would be ``X2LKT_IMPLICIT_ASSIGNMENT_VALUE``.
        If the token type is "option part", use the option descriptions from the PIM to try an exact match (:numref:`algo-match-option-description`).
        For example, the token is ``--reverse``, and the :term:`utility interface model` contains an option description that exactly match ``--reverse``.
        If no exact match is found, check for a pattern match with the option scheme (:numref:`algo-reduce-candidates-with-scheme`).
        For example, if the token ``-pq`` is encountered, and the program :term:`option scheme` is "Linux-Standard-Explicit" (see :numref:`option-schemes`), the only possible mapping for ``ONE_DASH_WORD`` will be ``POSIX_STACKED_SHORT_SWITCHES``.
        Finally, increment *conversions* if the token type "is semantic".

#. Until all tokens are of "semantic" type, prompt the user for a token type annotation and loop back at 3.2.

.. _algo-parse:

.. figure:: /algorithms/parse.svg
  :align: left


  Parse function

.. _algo-check-end-of-options:

.. figure:: /algorithms/checkEndOfOptions.svg
  :align: left


  CheckEndOfOptions function

.. _algo-infer-right:

.. figure:: /algorithms/inferRight.svg
  :align: left


  InferRight function

.. _algo-infer-left:

.. figure:: /algorithms/inferLeft.svg
  :align: left


  InferLeft function

.. _algo-convert-to-semantic:

.. figure:: /algorithms/convertToSemantic.svg
  :align: left


  ConvertToSemantic function

.. _algo-match-option-description:

.. figure:: /algorithms/matchOptionDescription.svg
  :align: left


  MatchOptionDescription function

.. _algo-reduce-candidates-with-scheme:

.. figure:: /algorithms/reduceCandidatesWithScheme.svg
  :align: left


  ReduceCandidatesWithScheme function

Edge cases and extension perspectives
#####################################

Some argument constructs must be anticipated, so here is a list of problematic examples to open to further enhancements:

- How to model restricted operands such as in :linuxman:`dd(1)`? Although they look like headless options, dd operands are "typed".
- How to model sub-commands, such as in :linuxman:`git(1)`?
- How to model commands which operands can be another command, such as `find -exec <command> {} \;` ?

----------------------

.. container:: footnotes

  .. [#headless-option-exception] Although ``HEADLESS_OPTION`` is an option, it is very rare and should only be matched when defined in a :term:`utility interface model`, or reviewed by the user. So, by default we assume a ``WORD`` is not an option.
