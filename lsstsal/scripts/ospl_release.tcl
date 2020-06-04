#!/usr/bin/env tclsh

set whichidl [exec which idlpp]
set vers [split [exec strings $whichidl | grep OSPL_V] "/_"]
set nfld [lsearch $vers OSPL]
set OSPL_RELEASE [join [lrange $vers [expr $nfld+1] [expr $nfld+3]] "."]
puts stdout $OSPL_RELEASE

