#!/usr/bin/env python

import sys
from lsst.ts.sal.make_salpy_lib import make_salpy_lib

sal_names = sys.argv[1:]
if not sal_names:
    print("Must specify one or more SAL component names")
    sys.exit(1)

for sal_name in sal_names:
    make_salpy_lib(sal_name)
