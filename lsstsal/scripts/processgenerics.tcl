#!/usr/bin/env tclsh
## \file processgenerics.tcl
# \brief This contains procedures to create and manage the
# MD5SUM revision codes used to uniqely identify versioned
# DDS Topic names.
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code

source $env(SAL_DIR)/sal_version.tcl 

#
## Documented proc \c generategenerics .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate SAL Subsystem/CSC specific XML from the SALGenerics input file
#
proc generategenerics { subsys } {
global SALVERSION
  exec cp SALGenerics.xml [set subsys]_Generics.xml
  set fout [open /tmp/salgenerics_[set subsys] w]
  puts $fout "perl -pi -w -e 's/SALGeneric/$subsys/g;' [set subsys]_Generics.xml"
  puts $fout "perl -pi -w -e 's/SALVersion/$SALVERSION/g;' [set subsys]_Generics.xml"
  close $fout
  exec chmod 755 /tmp/salgenerics_[set subsys]
  exec /tmp/salgenerics_[set subsys]
}


