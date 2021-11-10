## \file versioning.tcl
# \brief This script seeks out any _version.tcl and runs them
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code

set vfiles [glob $SAL_DIR/*_version.tcl]
foreach f $vfiles {
  source $f
}
