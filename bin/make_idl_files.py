#!/usr/bin/env python
import argparse

import lsst.ts.xml
from lsst.ts.sal.make_idl_file import make_idl_file

parser = argparse.ArgumentParser(
    description="Build the IDL file for one or more SAL component")
parser.add_argument("components", nargs='*',
                    help="Names of SAL components, e.g. 'Script ScriptQueue'. "
                    "Ignored if --all is specified")
parser.add_argument("--all", action="store_true",
                    help="Make all components except those listed in --exclude.")
parser.add_argument("--dry-run", action="store_true",
                    help="Print the component names that would be built and exit.")
parser.add_argument("--exclude", nargs="+",
                    help="Names of SAL components to exclude. "
                    "If an entry appears in both `components` and `exclude` then it is excluded.")

args = parser.parse_args()

if args.all:
    components = lsst.ts.xml.subsystems
else:
    components = args.components
if args.exclude:
    exclude = set(args.exclude)
    components = [name for name in components if name not in exclude]
print(f"Making IDL files for: {', '.join(components)}")
if not args.dry_run:
    for name in components:
        make_idl_file(name=name)
