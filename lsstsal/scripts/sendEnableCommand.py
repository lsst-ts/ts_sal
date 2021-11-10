#!/usr/bin/env python3

import time
import sys
import importlib
from SALPY_Test import *
testmod = "SALPY_"+sys.argv[1]
cname = "SAL_"+sys.argv[1]
mod = importlib.import_module(testmod)
mgr = getattr(mod, cname)(sys.argv[2])
cmd = sys.argv[1]+"_command_enable"
dname = sys.argv[1]+"_command_enableC"
myData = getattr(mod, dname)()
mgr.salCommand(cmd)
print("sending command SAL_"+sys.argv[1]+" enable ")
cmdId = mgr.issueCommand_enable(myData)
timeout=int(sys.argv[3])
retval = mgr.waitForCompletion_enable(cmdId,timeout)
time.sleep(1)
mgr.salShutdown()

