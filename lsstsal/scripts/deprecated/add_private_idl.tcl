#!/usr/bin/env tclsh
## \file add_private_idl.tcl
# \brief This contains procedures to add the private_ items to
# a generated IDL file. The private_ items are common to every
# DDS Topic type and store topic independent Metadata about
# the runtime characteristics (origin and timestamps).
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code



## Documented proc \c add_private_idl .
# \param[in] fidl File handle of an open IDL file
# \param[in] spc Optional string of spaces to prefix the output
#
proc add_private_idl { fidl {spc "  "} } {
  puts $fidl "[set spc]string<8>	private_revCode; //private
[set spc]double	private_sndStamp;    //private
[set spc]double	private_rcvStamp;    //private
[set spc]long	private_seqNum;    //private
[set spc]string<128>	private_identity;    //private
[set spc]long	private_origin;    //private"
}

