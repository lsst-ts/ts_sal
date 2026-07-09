#!/usr/bin/env tclsh
## \file parseAvro.tcl
# \brief This contains procedures to parse the input SAL XML
#  files and generate Avro shema
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3
#\n
# Copyright 2012-2026 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code
#
## Documented proc \c parseAvro .
# \param[in] subsys The sub-system being processed
# \param[in] fname Name of input Avro file
#
#  Create the files in avro-templates corresponding to the
#  SAL Topics defined in an Avro file
#

package require json

proc parseAvro { subsys fname } {
global AVRORESERVED SAL_WORK_DIR SAL_DIR CMDS CMD_ALIASES EVTS EVENT_ALIASES AVROTYPES
global TLMS TLM_ALIASES EVENT_ENUM EVENT_ENUMS UNITS ENUM_DONE SYSDIC DESC OPTIONS METADATA
global TRAILINGITEMS
   if { $OPTIONS(verbose) } {stdlog "###TRACE>>> parseAvro $subsys $fname"}
    set avroJson [join [list $subsys [string replace [lindex [split $fname "/"] end] end-3 end "json"]] "_"]

    set favsc [open $fname r]
    set content [read $favsc]
    close $favsc
    set avscData [json::json2dict $content]

    set favro [open $SAL_WORK_DIR/avro-templates/$subsys/$avroJson r]
    set content [read $favro]
    close $favro
    set avroData [json::json2dict $content]

    set topic [dict get $avscData name]
    set fqdnTopic [join [list $subsys $topic] "_"]
    puts stdout "Translating $fqdnTopic"
    set fields [dict get $avscData fields]
    set avroFields [dict get $avroData fields]
    try {
        set topicDesc [dict get $avscData description]
    } on error err {
        set topicDesc "No description given"
    }

    lappend TLM_ALIASES($subsys) $topic
    set METADATA($fqdnTopic,description) \"$topicDesc\"

    foreach field $fields {
        set fattr [dict get $field name]
        set ftype [dict get $field type]

        try {
            set attrType [lsearch -inline -not $ftype null]
        } on error err {
            set attrType "null"
        }

        lappend TLMS($subsys,$topic,param) "$attrType $fattr"
	    lappend TLMS($subsys,$topic,plist) "$fattr"
    }
    # Use the fields in the generated JSON file since METADATA wants the
    # private attributes.
    foreach field $avroFields {
        set fattr [dict get $field name]
        try {
            set funits [dict get $field units]
        } on error err {
            set funits "unitless"
        }
        try {
            set fdesc [safeString [dict get $field description]]
        } on error err {
            set fdesc "No description given"
        }

        set METADATA($fqdnTopic,$fattr,description) \"$fdesc\"
        set METADATA($fqdnTopic,$fattr,units) \"$funits\"
        set METADATA($fqdnTopic,$fattr,size) 1
    }
}