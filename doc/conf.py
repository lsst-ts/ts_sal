"""Sphinx configuration file for an LSST stack package.
This configuration only affects single-package Sphinx documentation builds.
"""


# Project information
project = 'ts_sal'
copyright = '2025, LSST'
author = 'LSST'

# General configuration
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.intersphinx',
    'sphinx.ext.todo',
    'sphinx.ext.viewcode',
    'sphinx_prompt',  # Provides .. prompt:: directive for bash/shell examples
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# Options for HTML output
html_theme = 'alabaster'
html_static_path = []
html_title = project
html_short_title = project

# Extension configuration
intersphinx_mapping = {
    'python': ('https://docs.python.org/3', None),
    'ts_sal': ('https://ts-sal.lsst.io', None),
}

# Suppress warnings
suppress_warnings = ['config.cache']
