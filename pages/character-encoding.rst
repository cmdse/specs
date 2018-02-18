##################
Character encoding
##################

Good reads
##########

- `The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets (No Excuses!) <http://www.joelonsoftware.com/articles/Unicode.html>`_
- `String and charset in Go <https://blog.golang.org/strings>`_

Definitions
###########

.. glossary::

  string
    An arbitrary sequence of bytes. Note that with this definition, a string alone is not sufficient to get a textual representation. A :term:`charset` and its :term:`encoding` must be provided along.

  string literal
    A :term:`string` with valid :term:`utf-8` sequences.

  glyph
    The non-reductable sum of pixels corresponding to a representation of it's corresponding :term:`character symbol(s) <character symbol>`.

  character symbol
  character literal
    A unique element in a :term:`charset`.

  character
    The meaning of character is loose. It can either mean a :term:`glyph` or a :term:`character literal`, which is not the same since a glyph can be the result of merging two literals as it often happens with dead keystrokes.
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
    An :term:`encoding` for the :linuxman:`unicode(7)` :term:`charset`. See :linuxman:`utf-8(7)`.

  ucs-2
    An :term:`encoding` for a subset of the `Unicode <https://en.wikipedia.org/wiki/Unicode>`_ :term:`charset`. This subset is known as the Basic Multilingual Plane and is composed of the first 65,536 :term:`code points <code point>`. This encoding uses 2-bytes for each character.


Linux terminal and encoding
###########################

POSIX locale environement variables
===================================

In POSIX systems, a set of environment variables share knowledge on locale and encoding set for the system [#posix-locale]_.
The :envvar:`LANG`, :envvar:`LC_ALL` and :envvar:`LC_CTYPE` environment variables are those of interest for encoding. Each of their value has the following pattern:

.. code-block:: text

  $lang[.$codeset[@$variant]

The ``$codeset`` part refers to the configured encoding, and should be extrapolated for I/O terminal operations in the following order [#posix-lang-var-order]_ :

* :envvar:`LC_ALL`
* :envvar:`LC_CTYPE`
* :envvar:`LANG`

.. sidebar:: Resources

  - `Into the mist: how linux console fonts work <http://www.tldp.org/LDP/LG/issue91/loozzr.html>`_
  - :linuxman:`console_codes(4)`
  - `How much of Unicode does xterm support? <http://www.cl.cam.ac.uk/~mgk25/unicode.html#xterm>`_
  - `UTF-8 and Unicode FAQ for Unix/Linux <http://www.cl.cam.ac.uk/~mgk25/unicode.html>`_
  - `Linux kernel documentation "Unicode support" section <https://www.kernel.org/doc/html/latest/admin-guide/unicode.html>`_
  - `Linux difference between /dev/console, /dev/tty and /dev/tty0 <https://unix.stackexchange.com/a/384792/66564>`_



.. envvar:: LANG

  If :envvar:`LC_ALL` is not set, then locale parameters whose corresponding :envvar:`LC_*` variables are not set default to the value of :envvar:`LANG`.

.. envvar:: LC_ALL

  When set, the value of this variable overrides the values of all other :envvar:`LC_*` variables.

.. envvar:: LC_CTYPE

  Controls the way upper to lowercase conversion takes place.

Linux terminal
==============

.. todo:: Document Linux terminal encoding support

.. epigraph::

  If the console is in utf8 mode (see  :linuxman:`unicode_start(1)`)  then  the  kernel expects  that  user program output is coded as UTF-8 (see :linuxman:`utf-8(7)`), and converts that to Unicode (ucs2).  Otherwise, a translation table is used from the 8-bit program output to 16-bit Unicode values. Such a translation table is called a Unicode console map.  There are four of them: three built  into  the  kernel,  the fourth  settable  using  the  -m  option of setfont.  An escape sequence chooses between these four tables; after loading a cmap, setfont will output the escape sequence Esc ( K that makes it the active translation.

  :linuxman:`setfont(8)`

Linux commands
==============

.. epigraph::

  Some command-line utilities have problems with multibyte characters. For example, tr always assumes that one character is represented as one byte, regardless of the locale. [#intro-unicode]_

Program encoding strategy
#########################

.. todo:: Program encoding strategy

----------------------

.. container:: footnotes

  .. [#posix-locale] `POSIX.1-2008, sec. 7.1 <http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap07.html>`_
  .. [#intro-unicode] `Introduction to Unicode — Using Unicode in Linux <http://michal.kosmulski.org/computing/articles/linux-unicode.html>`_
  .. [#posix-lang-var-order] This is how ncurse, `tcell <https://godoc.org/github.com/gdamore/tcell#RegisterEncoding>`_ and other popular terminal libraries proceed.
