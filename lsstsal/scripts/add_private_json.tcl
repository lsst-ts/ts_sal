#!/usr/bin/env tclsh
## \file add_private_json.tcl
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



## Documented proc \c add_private_json .
# \param[in] fjson File handle of an open Json file
# \param[in] trail Optional string of spaces to prefix the output
#
proc add_private_json { fson trail } {
global TRAILINGITEMS
  puts $fson "   \{\"name\": \"private_sndStamp\", \"type\": \"double\", \"default\": 0.0, \"description\": \"Time of instance publication\", \"units\": \"second\"\},
   \{\"name\": \"private_rcvStamp\", \"type\": \"double\", \"default\": 0.0, \"description\": \"Time of instance reception\", \"units\": \"second\"\},
   \{\"name\": \"private_seqNum\", \"type\": \"long\", \"default\": 0, \"description\": \"Sequence number\", \"units\": \"unitless\"\},
   \{\"name\": \"private_identity\", \"type\": \"string\", \"default\": \"\", \"description\": \"Identity of publisher: SAL component name for a CSC or user@host for a user\", \"units\": \"unitless\"\},
   \{\"name\": \"private_origin\", \"type\": \"long\", \"default\": 0, \"description\": \"Process ID of publisher\", \"units\": \"unitless\"\}[set trail]
  "
}

