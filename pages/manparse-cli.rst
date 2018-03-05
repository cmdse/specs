.. _manparse-cli-section:

############
Manparse CLI
############

.. note:: The project is developped at `github.com/cmdse/manparse <https://github.com/cmdse/manparse>`_

:command:`manparse` is a tool to extract a :term:`utility interface model` from man-pages.
It uses :command:`doclifter` [#doclifter-official]_ from Eric S. Raymond which converts man pages to `DocBook <http://docbook.org>`_ xml files.
Those files already hold a good level of semantics, and :command:`manparse` will do its best to grab as much information as possible.
The :term:`utility interface model` should be serialized to be consumed by other tools.
Serialization format has not yet been chosen but it will likely be JSON + `JSON Schema <http://json-schema.org/>`_.

Synopsis
############


.. container:: synopsis big

   manparse [-v|-q] files...


Options
############

.. program:: manparse

.. option:: -v, --verbose

   Blah

.. option:: -q, --quiet

   Shhhht

Implementation details
######################

:command:`manparse` will pass through multiple steps to build up a :term:`utility interface model` from a manpage:

#. call ``doclifter`` to generate a docbook file in a temporary folder;
#. unmarshall the docbook xml file;
#. flatten subsections to raw text;
#. extract the command synopses in a tree structure;
#. run parse scenarios to extract a partial :term:`option description model` and eventually :term:`sub-commands <sub-command>`;
#. match synopses with :term:`option description model`, and when suitable infer a ``POSIX_STACK_SWITCH`` :term:`option expression variant`.


Parse scenario
==============

A parse scenario is an abstraction to leverage the numerous set of situations :command:`manparse` can be exposed to.

Parse scenario execution is triggered when its associated prerequisites are met. Prerequisites are a set of conditions affecting:

- the available section names;
- the content of those sections;
- the synopses.

The canonical parse scenario or default parse scenario is the fallback scenario and should match a good half of encountered manpages.
Multiple parse scenarios can be matched at the same time and should be executed one after the other.
As you can see in the bellow subsections, many scenarios share some conditions.

Canonical parse scenario:
+++++++++++++++++++++++++

- [condition 1] a section named "OPTIONS" is found;
- [condition 2] no section named "COMMANDS" is found;
- [condition 3] the "OPTIONS" section matches the structure of option synopses list.

Embedded sub-command parse scenario:
++++++++++++++++++++++++++++++++++++

- [condition 1] a section named "OPTIONS" is found;
- [condition 2] a section named "COMMANDS" is found;
- [condition 3] the "OPTIONS" section matches the structure of option synopses list;
- [condition 4] the "COMMANDS" section matches the structure of command synopses;
- [condition 5] command synopses reference a COMMAND parameter.

External sub-command parse scenario:
++++++++++++++++++++++++++++++++++++

- [condition 1] a section named "OPTIONS" is found;
- [condition 2] a section named "COMMANDS" is found;
- [condition 3] the "OPTIONS" section matches the structure of option synopses list;
- [condition 4] the "COMMANDS" section contains a list of one-word entries with description, and each description contains a reference to an external manpage;
- [condition 5] command synopses reference a COMMAND parameter.

Multiple OPTIONS sections parse scenario:
+++++++++++++++++++++++++++++++++++++++++

- [condition 1] multiple section containing "OPTIONS" are found;
- [condition 2] each of those "OPTIONS" sections matches the structure of option synopses list.


Synopsis docbook extraction
===========================


Option docbook extraction
=========================


Sub-commands docbook extraction
===============================


Model Extraction Failures
=========================

:command:`doclifter`\ [#doclifter-official]_ author reports 93% success on a bare Ubuntu install:

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


--------------------------------------------

.. container:: footnotes

   .. [#doclifter-official] See `doclifter <https://gitlab.com/esr/doclifter>`_
   .. [#doclifter-patches] See `PATCHES file from doclifter project <https://gitlab.com/esr/doclifter/raw/master/PATCHES>`_
