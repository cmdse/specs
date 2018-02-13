.. cmdse documentation master file, created by
   sphinx-quickstart on Mon Jan 15 16:16:06 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

:author: Jules Samuel RANDOLPH <jules.sam.randolph@gmail.com>


.. Difference between unix shell grammars
   http://hyperpolyglot.org/unix-shells
   https://github.com/fish-shell/fish-shell/issues/2382

============================================================
Specifications for cmdse: the search engine of bash commands
============================================================

`Feature-rich, semantic-wise crowdourced knowledge hub and search engine for useful command-line snippets.`

.. note:: See `github.com/cmdse/core <https://github.com/cmdse/core>`_ library for an implementation of thoses specifications.

.. warning:: This document is a working draft and subject to heavy change in a near future.

Introduction
############


The motivations behind the creation of |project-name| originates from a very simple reasoning.

* How many times I have relied on Google to look for the syntax of a specific command; what if I could search by command directly from the shell ?
* How often I had a precise idea of *what* I wanted to do, but no idea which shell snippet would drive me there ?
* What if I could finally learn those commands and their semantics, instead of running off memorising those ?

The |project-name| program should meet the following requirements:

* Provide a user-friendly command line tool to query linux-shell command snippets.
* Enable the user to query *what* he wants to do, and the search engine grabs the best-matched snippets.
* Enable features to memorize the semantics of commonly used commands with mini-quizz.
* Model rich meta-data on program arguments and options, allowing the user to learn the semantics of the programs and snippets he uses.
* Support  ``bash`` and ``POSIX Shell`` syntaxes.
* Infer if a snippet is ``POSIX Shell`` or ``bash``\ -compatible.

.. todolist::

.. toctree::
   :maxdepth: 3
   :numbered:
   :caption: Table of Contents
   :glob:

   pages/cli
   pages/model/command-snippet
   pages/model/call-expression-parsing
   pages/model/query
   pages/model/user
   pages/*
   pages/appendix/*


.. Comment.. todolist::
