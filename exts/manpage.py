#!/usr/bin/env python
# encoding: utf-8
#
# Copyright (c) 2013 Dariusz Dwornikowski.  All rights reserved.
#
"""
  Providing links to manpages with :linuxman: directiv
"""

from docutils import nodes, utils
from docutils.parsers.rst.roles import set_classes
from string import Template
import warnings
import re

def make_link_node(rawtext, app, name, manpage_num, options):
    """Create a link to a man page.
    """
    ref = None
    ref = app.config.linux_man_url_regex
    if not ref:
        ref = "http://linux.die.net/man/%s/%s" % (manpage_num, name)
    else:
        s = Template(ref)
        ref = s.substitute(num=manpage_num, topic=name)
    set_classes(options)
    emph = nodes.emphasis(text="%s(%s)" % (name, manpage_num))
    node = nodes.reference(rawtext, '', refuri=ref,
                           **options)
    node.append(emph)
    return node


def man_role(name, rawtext, text, lineno, inliner, options={}, content=[]):
    """Link to an online man page issue.
    """
    app = inliner.document.settings.env.app
    p = re.compile("([a-zA-Z0-9_\.\-_]+)\((\d)\)")
    m = p.match(text)
    if m == None:
        inliner.document.reporter.warning('linuxman role argument didn\'t match expected syntax ref(entry) in the following expression: %s' % rawtext, line=lineno)
        return [nodes.emphasis(text=text)], []
    manpage_num = m.group(2)
    name = m.group(1)
    node = make_link_node(rawtext, app, name, manpage_num, {'classes': ['linuxman-url']})
    return [node], []

def setup(app):
    app.info('Initializing manpage plugin')
    app.add_role('linuxman', man_role)
    app.add_config_value('linux_man_url_regex', None, 'env')
    return
