# -*- python -*-
import os
from lsst.sconsUtils import scripts, env
scripts.BasicSConstruct("ts_sal")
# symbols required for SALPY libraries to work
for name in ("OSPL_URI",):
    env['ENV'][name] = os.environ[name]
