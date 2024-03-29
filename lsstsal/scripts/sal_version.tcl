## \file sal_version.tcl
# \brief Sets the SAL version for use in salgenerator
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code

if { [info exists SALVERSION] == 0 } {
  cd $env(TS_SAL_DIR)
  set SALVERSION [string trim [exec git describe --tags --dirty] "v"]
  set SAL_BASE_DIR $env(SAL_DIR)/scripts
  set SAL_CMAKE_DIR $SAL_BASE_DIR/code/simd/cmake
}


