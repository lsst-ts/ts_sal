#!/usr/bin/env tclsh
## \file avro_release.tcl
# \brief Sets the AVRO schema processor release for use in salgenerator
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code

set AVRO_RELEASE 1.11.0
catch {set AVRO_RELEASE [exec $env(TS_SAL_DIR)/bin/avrogencpp --version]}
puts stdout $AVRO_RELEASE
