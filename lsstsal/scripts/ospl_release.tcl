#!/usr/bin/env tclsh

set vers [split [exec strings $env(OSPL_HOME)/bin/idlpp | grep OSPL_V] "/_"]
set nfld [lsearch $vers OSPL]
set OSPL_RELEASE [string range [join [lrange $vers [expr $nfld+1] [expr $nfld+3]] "."] 1 end]
puts stdout $OSPL_RELEASE

