#!/usr/bin/env python
import argparse

import lsst.ts.xml

from lsst.ts.sal.make_salpy_lib import make_salpy_lib

parser = argparse.ArgumentParser(
    description="Build SALPY libraries for one or more SAL component"
)
parser.add_argument(
    "components", nargs="+", help='Names of SAL components, e.g. "Test"'
)
parser.add_argument(
    "--demo",
    action="store_true",
    help="Build and keep a demo reader and writer for each topic? "
    "Warning: this is much slower. "
    "This option also keeps most generated files",
)

args = parser.parse_args()

invalid_components = set(args.components) - set(lsst.ts.xml.subsystems)

if len(invalid_components) > 0:
    raise RuntimeError(
        f"The following components are not part of sal subsystems {invalid_components}. "
        "Check spelling and try again."
    )

for sal_name in args.components:
    make_salpy_lib(sal_name=sal_name, demo=args.demo)
