######################
Design FAQ
######################

Why aren't there more shell grammars planned for support ?
##########################################################

Other shell grammars support require big work for a limited payback since any command can be executed with bash in any linux distributions. Bash is the de-facto shell standard accross linux distributions, see `the rationale of shfmt golang library author here <https://github.com/mvdan/sh/issues/120>`_ :

.. epigraph::

  [ksh and fish] are cooler, newer shells that - as far as I know - are popular as interactive shells. But not so much for scripts that you maintain over time. Those tend to be in Bash or POSIX Shell, since you want the scripts to run on as many systems as possible.

  -- Daniel Martí
