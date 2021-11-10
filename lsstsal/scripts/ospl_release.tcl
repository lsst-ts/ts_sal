#!/usr/bin/env tclsh
## \file ospl_release.tcl
# \brief Sets the OpenSplice release for use in salgenerator
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code

set OSPL_RELEASE 6.10.4
catch {set OSPL_RELEASE [lindex [exec $env(OSPL_HOME)/bin/idlpp -v] 3]}
puts stdout $OSPL_RELEASE
