##################
Character encoding
##################

Good reads
##########

- `The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets (No Excuses!) <http://www.joelonsoftware.com/articles/Unicode.html>`_
- `String and charset in Go <https://blog.golang.org/strings>`_

Glossary
########

.. glossary::

  string
    An arbitrary sequence of bytes. Note that with this definition, a string alone is not sufficient to get a textual representation. A :term:`charset` and its :term:`encoding` must be provided along.

  string literal
    A :term:`string` with valid :term:`utf-8` sequences.

  character
    The meaning of character is loose. It can mean the glyph, that is the non-reductable sum of pixels corresponding to a representation of it's corresponding symbol(s).
    But it can also mean one symbol in a charset, which is not the same since a glyph can be the result of merging two symbols as it often happens with dead keystrokes.
    For example, pressing :kbd:`\`` followed by :kbd:`a` will result in *à* glyph, but in the UTF-8 encoding, is not the same as *à* symbol.

  charset
    Strictly saying, a set of symbols that can be used. Often confused with :term:`encoding`.

  encoding
    The in-memory representation of a :term:`charset`.

  rune
  code point
    A representation in the form of character of a unicode byte sequence.
    Rune is the Go synonym for a code point.

  utf-8
    An :term:`encoding` for the `Unicode <https://en.wikipedia.org/wiki/Unicode>`_ :term:`charset`. See the `UTF8 Manpage <http://man7.org/linux/man-pages/man7/utf-8.7.html>`_.

  ucs-2
    An :term:`encoding` for a subset of the `Unicode <https://en.wikipedia.org/wiki/Unicode>`_ :term:`charset`. This subset is known as the Basic Multilingual Plane and is composed of the first 65,536 :term:`code points <code point>`. This encoding uses 2-bytes for each character.


Linux terminal and encoding
###########################

POSIX locale environement variables
===================================

.. todo:: Document POSIX locale environement variables

.. sidebar:: Resources

  - `Effect of $LANG on terminal <https://unix.stackexchange.com/questions/48689/effect-of-lang-on-terminal>`_
  - `How to get terminals character encoding in linux <https://stackoverflow.com/questions/5306153/how-to-get-terminals-character-encoding>`_
  - `POSIX.1-2008, locale section <http://pubs.opengroup.org/onlinepubs/9699919799/>`_
  - `Into the mist: how linux console fonts work <http://www.tldp.org/LDP/LG/issue91/loozzr.html>`_
  - `console_codes - Linux console escape and control sequences <http://man7.org/linux/man-pages/man4/console_codes.4.html>`_
  - `Introduction to Unicode — Using Unicode in Linux <http://michal.kosmulski.org/computing/articles/linux-unicode.html>`_

The :envvar:`LANG` var


.. envvar:: LANG

  If :envvar:`LC_ALL` is not set, then locale parameters whose corresponding :envvar:`LC_*` variables are not set default to the value of :envvar:`LANG`.

.. envvar:: LC_ALL

  When set, the value of this variable overrides the values of all other :envvar:`LC_*` variables.

.. envvar:: LC_CTYPE

  Controls the way upper to lowercase conversion takes place.

Linux terminal
==============

.. todo:: Document Linux terminal encoding support
