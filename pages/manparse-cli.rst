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

--------------------------------------------

.. container:: footnotes

   .. [#doclifter-official] See `doclifter <https://gitlab.com/esr/doclifter>`_
