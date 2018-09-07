#!/usr/bin/env tclsh

load $env(SAL_DIR)/../lib/libxtcs.so
load $env(SAL_DIR)/../lib/libsqlite3.22.0.so Sqlite3
set startrec 5
set numvisits 9999

if { $argc > 1 } {
  set startrec [expr [lindex $argv 1] +4]
  set numvisits [lindex $argv 2]
}

set schema(ObsHistory) "obsHistID INTEGER PRIMARY KEY,Session_sessionID INTEGER,filter TEXT,expDate INTEGER,expMJD REAL, night INTEGER, visitTime REAL, visitExpTime REAL, finRank REAL, finSeeing REAL, transparency REAL, airmass REAL, vSkyBright REAL, filtSkyBrightness REAL, rotSkyPos REAL, lst REAL, altitude REAL, azimuth REAL, dist2Moon REAL, solarElong REAL, moonRA REAL, moonDec REAL, moonAlt REAL, moonAZ REAL, moonPhase REAL, sunAlt REAL, sunAZ REAL, phaseAngle REAL, rScatter REAL, mieScatter REAL, moonIllum REAL, moonBright REAL, darkBright REAL, rawSeeing REAL, wind REAL, humidity REAL, fiveSigmaDepth REAL, ditheredRA REAL, ditheredDec REAL, Field_fieldID INTEGER"
set s2 [split $schema(ObsHistory) ,]
set i 0
foreach f $s2 {
   set idx([lindex $f 0]) $i
   incr i 1
}


puts stdout "Simulating $numvisits visits, starting from record $startrec"
set count 0
set ok 0
sqlite3 db1 $env(SAL_WORK_DIR)/tcs/tcs/bin/mini-minion.db

puts stdout "Started visits at record $count"
set count 0 
set lastfield 0
set lastfilter r

proc shutdown { } {
global env
   catch {exec $env(SAL_WORK_DIR)bin/sacpp_MTMount_stop_commander 1}
   after 2000
   exit
}


proc simvisits { {n 5} } {
global TARGETS numvisits fin lastfield lastfilter env db1 idx
    set rec [db1 eval {select * from obsaa where obsHistID=$n}]
    incr n 1
    if { $n > 4999 } {set n 5}
    set field [lindex $rec $idx(Field_fieldID)]
    if { $field != $lastfield } {
     set exptime 15.0
     set slewtime 5.0
     puts stdout "Field $field"
     catch {
      set lastfield $field
      set filter [lindex $rec $idx(filter)]
      set mjd [lindex $rec $idx(expMJD)]
      set exptime [lindex $rec $idx(visitExpTime)]
      set slewtime [expr [lindex $rec $idx(visitTime)]- $exptime]
      set rot [lindex $rec $idx(rotSkyPos)]
      set ra  [split [radians_to_hms [lindex $rec $idx(ditheredRA)]] :]
      set dec [split [radians_to_dms [lindex $rec $idx(ditheredDec)]] :]
      set alt [format %12.6f [expr [lindex $rec $idx(altitude)]*180/3.14159]]
      set az  [format %12.6f [expr [lindex $rec $idx(azimuth)]*180/3.14159]]
      puts stdout "Visiting field $field $az, $alt, slewtime = $slewtime, exposure = $exptime"
#      puts stdout "command -> dome target position azimuth=$az elevation=$alt"
#      puts stdout "command -> hexapod 1 actuators position absolute x=1.0 y=2.0 z=3.0 v=-1.0 w=-2.0 z=-3.0"
#      puts stdout "command -> hexapod 2 actuators position absolute x=1.0 y=2.0 z=3.0 v=-1.0 w=-2.0 z=-3.0"
#      puts stdout "command -> rotator target position angle=$rot"
#      puts stdout "command -> camera guiders roi set xpos=1,1,1,1,1,1,1,1 ypos=2,2,2,2,2,2,2,2 roiSize=32,32,32,32,32,32,32,32" 
      if { [info exists TARGETS($field)] == 0 } {
        set TARGETS($field) "f[set field]"
        catch {target create azel "$az $alt" $TARGETS($field)}
        set radec [target format $TARGETS($field) icrs]
        catch {target create icrs "$radec" r[set TARGETS($field)]}
      }
      after 10 slew r[set TARGETS($field)]
#      after [expr int($slewtime) * 1000]
      if { $filter != $lastfilter } {
         puts stdout "Filter change required last=$lastfilter filter=$filter"
##         after 130000 "simvisits $n"
         set lastfilter $filter
         if { [info exists env(TCSSIM_QUIET)] } {
            exec $env(SAL_HOME)/scripts/standardvisit_commands.tcl $az $alt $filter &
         } else {
            exec gnome-terminal --geometry 800x300 -t "Visit with filter change" -e "$env(SAL_HOME)/scripts/standardvisit_commands.tcl $az $alt $filter" &
         }
      } else {
         if { [info exists env(TCSSIM_QUIET)] } {
            exec $env(SAL_HOME)/scripts/standardvisit_commands.tcl $az $alt &
         } else {
            exec gnome-terminal --geometry 800x300 -t "Standard Visit" -e "$env(SAL_HOME)/scripts/standardvisit_commands.tcl $az $alt" &
         }
      }
##      after [expr int($slewtime*1000)] {puts stdout "command -> camera imager expose numimages=2 expTime=15 shutter=true guide=true wfs=true"}
      incr n 1
      set lastfilter $filter
     }
     if { $n < $numvisits } {
       after [expr int(($exptime+$slewtime+20) * 1000)] "simvisits $n"
     }
    } else {
      after 10 "simvisits $n"
    }
}
puts stdout "Type simvisits to start, and shutdown to stop tracking and exit"

