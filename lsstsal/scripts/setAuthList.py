#!/usr/bin/env python3

import time
import sys
import importlib
from SALPY_Test import *
testmod = "SALPY_"+sys.argv[1]
cname = "SAL_"+sys.argv[1]
mod = importlib.import_module(testmod)
mgr = getattr(mod, cname)()
cmd = sys.argv[1]+"_command_setAuthList"
dname = sys.argv[1]+"_command_setAuthListC"
myData = getattr(mod, dname)()
myData.authorizedUsers=sys.argv[2]
myData.nonAuthorizedCSCs=sys.argv[3]
mgr.salCommand(cmd)
print("sending command SAL_"+sys.argv[1]+" setAuthList "+sys.argv[2]+" "+sys.argv[3])
cmdId = mgr.issueCommand_setAuthList(myData)
timeout=int(sys.argv[4])
retval = mgr.waitForCompletion_setAuthList(cmdId,timeout)
time.sleep(1)
mgr.salShutdown()

