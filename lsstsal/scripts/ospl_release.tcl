#!/usr/bin/env tclsh

set OSPL_RELEASE 6.9
catch {set OSPL_RELEASE [lindex [exec $env(OSPL_HOME)/bin/idlpp -v] 3]}
puts stdout $OSPL_RELEASE

