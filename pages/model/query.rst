##################
Search query model
##################

Definitions
###########

.. glossary::
  :sorted:

  query litteral
     The query answer will try to match any one of those provided litterals.
     Such a litteral has the shape of any word that is not composed of special characters with the exception of ``-`` and ``_``.

  program query selector
     The empty :term:`query selector` which only selects :term:`command snippets <command snippet>` that call the program name given as query selector value.
     For example, ``:dd`` will restrict the selection to snippets containing reference to the ``dd`` program.

  query selector
     It constrains the scope of the current query. Such a selector has the form of two words separated with the ``:`` character.
     The first, optional word is the operator (*what* is selected) and the second word is the *value*.
     When the operator is omitted, the :term:`program selector <program query selector>` is processed.

     .. code-block:: text

        [OPERATOR]:VALUE


Syntax
#####################

This is a normalized syntax. If the user inputs forbidden characters, they shall be stripped out.

.. code-block:: abnf
    :caption: Query formal :rfc:`ABNF <7405>` syntax definition

    SELECTOR-CHAR            = ALPHA / DIGIT / HYPHEN / UNDERSCORE
                             ; ASCII alphanum character or hyphen or underscore
    LITERAL-CHAR             = UTF8-2 / UTF8-3 / UTF8-4 / ALPHA / DIGIT / HYPHEN / UNDERSCORE
                             ; UTF-8 alphanum character or hyphen or underscore
    LITERAL                  = 1*(LITERAL-CHAR)
                             ; A litteral is a sequence of non-special, non-whitespace characters
                             ; or hyphen or underscore
    SELECTOR-OPERATOR        = 1*(SELECTOR-CHAR)
    SELECTOR-VALUE           = 1*(SELECTOR-CHAR)
    SELECTOR                 = *(SELECTOR-OPERATOR) COLON SELECTOR-VALUE
                             ; A selector is a sequence of non-special, non-whitespace
                             ; ASCII characters or hyphen or underscore, preceded with a colon
    QUERY-WORD               = SELECTOR / LITERAL
    QUERY                    = QUERY-WORD / (QUERY-WORD WSP-SEQUENCE QUERY)

.. note::

  See the :doc:`/pages/appendix/grammar-commons` section for the depending definitions.

Search sort algorithm
#####################

.. todo:: Define query search sort algorithm

.. La commande renvoie, par défaut, le résultat le plus pertinent associé à la requête, ou bien les résultats les plus pertinents si l'écart de pertinence entre chaque résultat est inférieur à un seuil assez faible
  Les commandes apparaissent dans l'ordre de popularité (utilité objective) ou dans l'ordre de conception (utilité subjective, c-à-d l'utilité attribuée par les mainteneurs du logiciels).
