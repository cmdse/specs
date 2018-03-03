# -*- coding: utf-8 -*-
"""
    cmdse.requirements
    ~~~~~~~~~~~~~~~
    Allow definition and reference to requirements.

    Adds 'requirement' directive and 'req' role.
    'requirement' directive has the following syntax:

    .. requirement:: <req-id-hypen-separated>

        <Requirement-description>

    :copyright: Copyright 2007-2018 by Jules Randolph
    :license: BSD, see LICENSE for details.
"""
import warnings
from docutils import nodes
from docutils.parsers.rst import Directive
from sphinx.locale import _
from sphinx.environment import NoUri
from docutils.parsers.rst import directives
from docutils.parsers.rst.directives.admonitions import BaseAdmonition
from sphinx.util.nodes import set_source_info
from docutils.parsers.rst.roles import set_classes
from sphinx.roles import XRefRole
from sphinx import addnodes
from sphinx.util import ws_re
from sphinx.util.texescape import tex_escape_map

# TODO Handle cross-refs requirement in Latex
# - Define a requirementRole class as node
# - Register node + visitors
# - Add node to XRef instanciation

class requirement(nodes.Admonition, nodes.Element):
    pass

class RequirementDirective(BaseAdmonition):

    # this enables content in the directive
    node_class = requirement
    has_content = True
    required_arguments = 1
    final_argument_whitespace = False
    option_spec = {
        'class': directives.class_option,
    }

    def run(self):
        if not self.options.get('class'):
            self.options['class'] = ['admonition-requirement']

        environement = self.state.document.settings.env
        req_id = self.arguments[0]
        targetid = "requirement-" + req_id

        # requirement_node = requirement('\n'.join(self.content))
        # requirement_node += nodes.title(_('Requirement'), _('Requirement'))
        # self.state.nested_parse(self.content, self.content_offset, requirement_node)


        (req,) = super(RequirementDirective, self).run()
        if isinstance(req, nodes.system_message):
            return [req]

        req.insert(0, nodes.title(text=req_id.replace('-', ' ').title()))
        set_source_info(self, req)

        # Stash the target to be retrieved later in latex_visit_todo_node.
        req['targetref'] = '%s:%s' % (environement.docname, targetid)
        targetnode = nodes.target('', '', ids=[targetid])
        if not hasattr(environement, 'requirements_list'):
            environement.requirements_list = []
        environement.requirements_list.append({
            'docname': environement.docname,
            'lineno': self.lineno,
            'requirement_node': req.deepcopy(), # If a requirements list is to be build
            'target': targetnode,
            'index': len(environement.requirements_list),
            'identifier': targetid
        })

        return [targetnode, req]

def purge_requirements(app, environement, docname):
    if not hasattr(environement, 'requirements_list'):
        return
    environement.requirements_list = [requirement for requirement in environement.requirements_list if requirement['docname'] != docname]

def visit_requirement_node(self, node):
    self.visit_admonition(node)

def depart_requirement_node(self, node):
    self.depart_admonition(node)

class RequirementXRefRole(XRefRole):
    """
    Cross-referencing role for requirement
    """
    # TODO fix hyperlink created even when requirement definition is missing

    def compute_target_id(self, requirement_target_name) :
        return 'requirement-%s' % requirement_target_name

    def process_link(self, env, refnode, has_explicit_title, title, target):
        # type: (BuildEnvironment, nodes.reference, bool, unicode, unicode) -> Tuple[unicode, unicode]  # NOQA
        new_title = title
        newtarget = self.compute_target_id(target)
        return new_title, ws_re.sub(' ', newtarget)

    def result_nodes(self, document, env, node, is_ref):
        # type: (nodes.document, BuildEnvironment, nodes.Node, bool) -> Tuple[List[nodes.Node], List[nodes.Node]]  # NOQA
        target =  node['reftarget']
        if not is_ref:
            warnings.warn('No requirement reference found for %s' % node['refdoc'])
            return [node], []

        newnode = nodes.reference('', '', internal=True)
        try:
            app = document.settings.env.app
            newnode['refuri'] = '/' + app.builder.get_target_uri(node['refdoc'])
            newnode['refuri'] += '#' + target
            newnode.append(node)
        except NoUri:
            # ignore if no URI can be determined, e.g. for LaTeX output
            pass
        return [newnode], []

def latex_visit_requirement_node(self, node):
    # type: (nodes.NodeVisitor, todo_node) -> None
    title = node.pop(0).astext().translate(tex_escape_map)
    self.body.append(u'\n\\begin{sphinxadmonition}{note}{')
    # If this is the original todo node, emit a label that will be referenced by
    # a hyperref in the todolist.
    target = node.get('targetref')
    if target is not None:
        self.body.append(u'\\label{%s}' % target)
    self.body.append('%s:}' % title)


def latex_depart_requirement_node(self, node):
    # type: (nodes.NodeVisitor, todo_node) -> None
    self.body.append('\\end{sphinxadmonition}\n')

def setup(app):
    app.add_role('req', RequirementXRefRole(innernodeclass=nodes.emphasis))
    app.add_node(requirement,
                 html=(visit_requirement_node, depart_requirement_node),
                 latex=(latex_visit_requirement_node, latex_depart_requirement_node),
                 text=(visit_requirement_node, depart_requirement_node))

    app.add_directive('requirement', RequirementDirective)
    app.connect('env-purge-doc', purge_requirements)

    return {'version': '0.1'}   # identifies the version of our extension
