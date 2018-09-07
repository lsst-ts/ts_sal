#!/usr/bin/env tclsh

#
#  To convert legacy IDL Telemetry definitions to XML
#

source $env(SAL_DIR)/checkidl.tcl
source $env(SAL_DIR)/SALTopicTemplateXML.tcl
source $env(SAL_DIR)/versioning.tcl

set idl [glob [set argv]*.idl]
exec cat $idl > idl-templates/[set argv]_Telemetry.idl
checkidl [set argv]_Telemetry.idl
writeXMLsubsys ./xml $argv
$env(SAL_DIR)/parse_telemetry_list.tcl $argv
exec cp html/[set argv]/[set argv]_Telemetry.html $env(SAL_DIR)/icd/LSE74-html/appendixb/[set argv]/.

