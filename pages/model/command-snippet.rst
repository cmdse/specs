#####################
Command snippet model
#####################

Definitions
###########

.. glossary::

  command parameter
     A :term:`command snippet` parameter is a string which should be substituted with user input when the corresponding snippet is invoked.

  command snippet
     A crowdourced shell-processable text chunk that may be composed of zero to many :term:`command parameters <command parameter>`.



Call expression
##################

.. todo:: Define the call expression

Program executable
==================

Arguments
=========

Option expressions
++++++++++++++++++

Operands
++++++++

Parameters
++++++++++

Option expressions
##################

Theses option expressions will help building the semantics of the program through meta-data.
The underlying model will not be exhaustive and will evolve through time, with mixted contributions from the community and automated tools.

Styles
======

Three option styles exists in the unix world.

#. `POSIX Style <http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html>`_
#. `GNU Style <https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html>`_
#. X Toolkit Style

In the bellow table, different option expression variants are listed and their corresponding style.
This list is non-exhaustive, as there are other arcane option-styles, including "headless" switches often referred to as "old-style" options, such as in :manpage:`tar(1)` [#tar]_\ , but these can be replaced with more standard variants.

.. list-table:: Option expression variants
  :header-rows: 1
  :widths: 1 20 40 15 10

  * - Expression variant
    - Reference
    - Description
    - Style
    - Prevalence
  * - ``-o``
    - posix-short-switch
    - One-letter option switch
    - POSIX
    - Very common
  * - ``-opq``
    - posix-stacked-short-switches
    - One-letter option stack switch. This is equivalent to ``-o -p -q``.
    - POSIX
    - Common
  * - ``-o [arg]``
    - posix-short-assignment
    - One-letter option switch with value assignment
    - POSIX
    - Very common
  * - ``-o[arg]``
    - posix-short-sticky-value
    - One-letter option switch with sticky value
    - POSIX
    - Rare
  * - ``-option``
    - x-toolkit-switch
    - Long option switch
    - X Toolkit
    - Rare
  * - ``-option [arg]``
    - x-toolkit-assignment
    - Long option switch with value assignment
    - X Toolkit
    - Rare
  * - ``--option``
    - gnu-switch
    - Long option switch
    - GNU
    - Very common
  * - ``--option [arg]``
    - gnu-implicit-assignment
    - Long option switch with implicit value assignement
    - GNU
    - Very common
  * - ``--option=[arg]``
    - gnu-explicit-assignment
    - Long option switch with explicit value assignment
    - GNU
    - Very common



Option schemes
==============

An option scheme delimits the types of options supported by an executable program.

.. list-table:: List of option schemes
  :header-rows: 1
  :widths: 25 40 35

  * - Name
    - Description
    - Supported option expression variants
  * - Standard
    - Option expressions can be of any common GNU or POSIX-styled variants. Very often, one option has either one GNU and one POSIX variant, either one POSIX variant.
    - * posix-short-switch
      * posix-stacked-short-switches
      * posix-short-assignment
      * gnu-switch
      * gnu-implicit-assignment
      * gnu-explicit-assignment
  * - Standard-Explicit
    - Option expressions can be of any common GNU or POSIX-styled variants with implicit assignments.
    - * posix-short-switch
      * posix-stacked-short-switches
      * posix-short-assignment
      * gnu-switch
      * gnu-explicit-assignment
  * - Standard-Implicit
    - Option expressions can be of any common GNU or POSIX-styled variants with explicit assignments.
    - * posix-short-switch
      * posix-stacked-short-switches
      * posix-short-assignment
      * gnu-switch
      * gnu-implicit-assignment
  * - X-Toolkit
    - Option expressions can be composed solely with X-Toolkit-styled variants.
    - * x-toolkit-switch
      * x-toolkit-assignment

Option scheme composition
=========================

A model can be extended with an option expression variant, for example:

.. code-block:: text

  Standard-Implicit + x-toolkit-switch


Analytic Model
##############

.. todo:: Define command snippet analytic model (UML)


Forks
##################

.. todo:: Define command snippet forks

Sub-command snippet
===================

Commmand snippet variant
========================

Alias
=====

.. [#tar] `Tar Old Option Style <https://www.gnu.org/software/tar/manual/html_section/tar_21.html#SEC38>`_
