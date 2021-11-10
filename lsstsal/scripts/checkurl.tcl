#!/usr/bin/env tclsh
## \file checkurl.tcl
# \brief This contains a routine to validate a URL
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code


#
## Documented proc \c checkURL .
# \param[in] url URL to be validated using wget
#
proc checkURL { url } {
  catch { exec wget --spider $url] >& /tmp/checkurl } bad
  set res [exec cat /tmp/checkurl]
  if { [lsearch $res broken] > -1 } {
    return 1
  }
  return 0
}
