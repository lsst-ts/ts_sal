#!/usr/bin/env tclsh

proc writeXMLtelemetry { dpath subsys } { 
global SAL_WORK_DIR SALVERSION
  exec mkdir -p $dpath
  set fout [open $dpath/[set subsys]_Telemetry.xml w]
  puts $fout "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"http://lsst-sal.tuc.noao.edu/schema/SALTelemetrySet.xsl\"?>
<SALTelemetrySet xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
	xsi:noNamespaceSchemaLocation=\"http://lsst-sal.tuc.noao.edu/schema/SALTelemetrySet.xsd\">"
  set all [glob $SAL_WORK_DIR/xml/[set subsys]_*.xml]
  foreach i $all { 
     set id [lindex [split [file tail $i] "_."] 1]
     if { $id != "Telemetry" && $id != "Commands" && $id != "Events" } {
puts stdout "processing $id"
         puts $fout "<SALTelemetry>
 <Subsystem>[set subsys]</Subsystem>
 <Version>$SALVERSION</Version>
 <Author>salgenerator</Author>
 <EFDB_Topic>[set subsys]_[set id]</EFDB_Topic>"
         set fin [open $i r]
         while { [gets $fin rec] > -1 } { 
          set tag [lindex [split $rec "<>"] 1]
          if { $tag != "EFDB_Topic" } {
            puts $fout $rec
           }
         }
         close $fin
         puts $fout "</SALTelemetry>"
     }
  }
  puts $fout "</SALTelemetrySet>"
  close $fout
}

proc writeXMLcommands { dpath subsys } {
global CMDS CMD_ALIASES SALVERSION
  exec mkdir -p $dpath
  set fout [open $dpath/[set subsys]_Commands.xml w]
  set updatedate [exec date]
  puts $fout "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"http://lsst-sal.tuc.noao.edu/schema/SALCommandSet.xsl\"?>
<SALCommandSet xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
	xsi:noNamespaceSchemaLocation=\"http://lsst-sal.tuc.noao.edu/schema/SALCommandSet.xsd\">"
  foreach i [lsort $CMD_ALIASES($subsys)] {
     puts $fout "
<SALCommand>
 <Subsystem>[set subsys]</Subsystem>
 <Version>$SALVERSION</Version>
 <Author>salgenerator</Author>
 <EFDB_Topic>[set subsys]_command_[set i]</EFDB_Topic>
 <Alias>$i</Alias>
 <Device>[lindex $CMDS($subsys,$i) 0]</Device>
 <Property>[lindex $CMDS($subsys,$i) 1]</Property>
 <Action>[lindex $CMDS($subsys,$i) 2]</Action>
 <Value>[lindex $CMDS($subsys,$i) 3]</Value>
 <Explanation>http://sal.lsst.org/SAL/Commands/[set subsys]_command_$i.html</Explanation>"
     if { [info exists CMDS($subsys,$i,param)] } {
        foreach j $CMDS($subsys,$i,param) {
           puts $fout "    <item>"
           set name [string trim [lindex $j 1] "()0123456789"]
           set type [lindex $j 0]
           set count [lindex [split [lindex $j 1] "()"] 1]
           if { $count == ""} { set count 1}
           puts $fout "      <EFDB_Name>$name</EFDB_Name>"
           puts $fout "      <Description> </Description>"
           if { [llength [split $type "<>"]] > 1 } {
              set spl [split $type "<>"]
              puts $fout "       <IDL_Type>[lindex $spl 0]</IDL_Type>"
              puts $fout "       <IDL_Size>[lindex $spl 1]</IDL_Size>"
           } else {
              puts $fout "       <IDL_Type>$type</IDL_Type>"
           }
           puts $fout "      <Units> </Units>"
           puts $fout "      <Count>$count</Count>"
           puts $fout "    </item>"
        }
     }
     puts $fout "</SALCommand>"
  }
  puts $fout "</SALCommandSet>"
  close $fout
}

proc writeXMLevents { dpath subsys } {
global EVTS EVENT_ALIASES SALVERSION
  exec mkdir -p $dpath
  set fout [open $dpath/[set subsys]_Events.xml w]
  puts $fout "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"http://lsst-sal.tuc.noao.edu/schema/SALEventSet.xsl\"?>
<SALEventSet xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
	xsi:noNamespaceSchemaLocation=\"http://lsst-sal.tuc.noao.edu/schema/SALEventSet.xsd\">"
  set updatedate [exec date]
  foreach i [lsort $EVENT_ALIASES($subsys)] {
     puts $fout "
<SALEvent>
 <Subsystem>[set subsys]</Subsystem>
 <Version>$SALVERSION</Version>
 <Author>salgenerator</Author>
 <EFDB_Topic>[set subsys]_logevent_[set i]</EFDB_Topic>
 <Alias>$i</Alias>
 <Explanation>http://sal.lsst.org/SAL/Events/[set subsys]_logevent_$i.html</Explanation>"
     if { [info exists EVTS($subsys,$i,param)] } {
        puts $fout "    <item>"
        puts $fout "      <EFDB_Name>priority</EFDB_Name>"
        puts $fout "      <Description>Severity of the event</Description>"
        puts $fout "      <IDL_Type>long</IDL_Type>"
        puts $fout "      <Units>NA</Units>"
        puts $fout "      <Count>1</Count>"
        puts $fout "    </item>"
        foreach j $EVTS($subsys,$i,param) {
         set name [string trim [lindex $j 1] "()0123456789"]
         if { $name != "priority" } {
           puts $fout "    <item>"
           set type [lindex $j 0]
           set count [lindex [split [lindex $j 1] "()"] 1]
           if { $count == ""} { set count 1}
           puts $fout "      <EFDB_Name>$name</EFDB_Name>"
           puts $fout "      <Description> </Description>"
           if { [llength [split $type "<>"]] > 1 } {
              set spl [split $type "<>"]
              puts $fout "       <IDL_Type>[lindex $spl 0]</IDL_Type>"
              puts $fout "       <IDL_Size>[lindex $spl 1]</IDL_Size>"
           } else {
              puts $fout "       <IDL_Type>$type</IDL_Type>"
           }
           puts $fout "      <Units> </Units>"
           puts $fout "      <Count>$count</Count>"
           puts $fout "    </item>"
         }
        }
     }
     puts $fout "</SALEvent>"
  }
  puts $fout "</SALEventSet>"
  close $fout
}

set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)
source $SAL_DIR/versioning.tcl

set subsys $argv
puts stdout "Converting Telemetry for $subsys"
writeXMLtelemetry . $subsys
if { [file exists $SAL_WORK_DIR/idl-templates/validated/[set subsys]_evtdef.tcl] } {
  puts stdout "Converting Events for $subsys"
  source $SAL_WORK_DIR/idl-templates/validated/[set subsys]_evtdef.tcl
  writeXMLevents . $subsys
}

if { [file exists $SAL_WORK_DIR/idl-templates/validated/[set subsys]_cmddef.tcl] } {
  puts stdout "Converting Commands for $subsys"
  source $SAL_WORK_DIR/idl-templates/validated/[set subsys]_cmddef.tcl
  writeXMLcommands . $subsys
}


