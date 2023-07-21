#!/usr/bin/env tclsh

#
# Command line tool for SAL code/document/etc generation.
#

set SAL_DIR $env(SAL_DIR)
set COMMANDS "validate cpp idl java lib link maven tcl icd labview html apidoc rpm sal verbose fastest generate upload"
foreach o $COMMANDS {
  set OPTIONS($o) 0
  if { [lsearch [string tolower $argv] $o] > -1 } {
     set OPTIONS($o) 1
  }
}

set SAL_WORK_DIR $env(SAL_WORK_DIR)
if { [file exists $SAL_WORK_DIR] == 0 } {
   errorexit "Working directory $SAL_WORK_DIR does not exist"
}

if { [file exists $env(TS_XML_DIR)] } {
   cd $env(TS_XML_DIR)
   set XMLVERSION [string trim [exec git describe --tags --dirty] "v"]
 } else {
   errorexit "Please adjust setup.env so that TS_XML_DIR is correct"
}

cd $SAL_WORK_DIR
puts stdout "SAL_WORK_DIR=$SAL_WORK_DIR"

catch {exec mkdir saltemptest} ok
if { [file exists saltemptest] == 0 } {
   errorexit "Working directory $SAL_WORK_DIR does not have write permission"
}
exec mkdir -p $SAL_WORK_DIR/include
exec mkdir -p $SAL_WORK_DIR/lib
set LSST_KAFKA_IP $env(LSST_KAFKA_IP)
set LSST_KAFKA_SCHEMA_REGISTRY $env(LSST_KAFKA_SCHEMA_REGISTRY)
set LSST_KAFKA_SECURITY_PROTOCOL $env(LSST_KAFKA_SECURITY_PROTOCOL)
set LSST_KAFKA_SECURITY_MECHANISM $env(LSST_KAFKA_SECURITY_MECHANISM)
set LSST_KAFKA_SECURITY_USERNAME $env(LSST_KAFKA_SECURITY_USERNAME)
set LSST_KAFKA_SECURITY_PASSWORD $env(LSST_KAFKA_SECURITY_PASSWORD)
set LSST_KAFKA_HOST $env(LSST_KAFKA_HOST)
set LSST_KAFKA_BROKER_PORT $env(LSST_KAFKA_BROKER_PORT)
set LSST_KAFKA_PREFIX $env(LSST_KAFKA_PREFIX)
set AVRO_RELEASE $env(AVRO_RELEASE)

source $SAL_DIR/versioning.tcl
source $SAL_DIR/utilities.tcl
source $SAL_DIR/activaterevcodesKafka.tcl
source $SAL_DIR/add_system_dictionary.tcl

set argv "Test sal cpp"
puts stdout "argv = $argv"
set RELVERSION ""
if { [string range [lindex $argv end] 0 7] == "version=" } {
  set RELVERSION [string range [lindex $argv end] 8 end]
  set argv [lrange $argv 0 [expr [llength $argv]-2]]
}

puts stdout "SAL generator - [set SALVERSION]"


puts stdout "XMLVERSION = $XMLVERSION"

if { $RELVERSION != "" } {
  set SALRELEASE "[set XMLVERSION]-[set SALVERSION].$RELVERSION"
} else {
  set SALRELEASE "[set XMLVERSION]-[set SALVERSION]"
}

set OSPL_RELEASE $env(OSPL_RELEASE)



catch {exec rmdir saltemptest}
exec mkdir -p .salwork

  set DONE_CMDEVT 0
  set ONEDDSGEN 0
  cd $SAL_WORK_DIR
  set base Test
  
clearAssets $base
source $SAL_DIR/gensimplesampleKafka.tcl
source $SAL_DIR/gensalcodesKafka.tcl
checkTopicTypes $base
source $SAL_WORK_DIR/avro-templates/[set base]_revCodes.tcl
source $SAL_WORK_DIR/avro-templates/[set base]_metadata.tcl

#   catch { set inclfile [makesalincl $base] } bad
#   addSALKAFKAtypes /home/rfactory/lsst/test/avro-templates/sal/sal_Test.json Test_scalars cpp Test
#   updateRevCodes $base
#   source $SAL_WORK_DIR/avro-templates/[set base]_revCodes.tcl
#    genGenericCodes $base
#    genTelemetryCodes $inclfile $TARGETS
#    genSingleProcessTests $base
#  checkAssets $base


puts stdout "SALVERSION = $SALVERSION"
puts stdout "XMLVERSION = $XMLVERSION"
puts stdout "SAL_WORK_DIR = $SAL_WORK_DIR"
puts stdout "LSST_LAFKA_PREFIX = $LSST_KAFKA_PREFIX"
puts stdout "OSPL_RELEASE = $OSPL_RELEASE"

