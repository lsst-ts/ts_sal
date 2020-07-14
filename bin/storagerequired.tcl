#!/usr/bin/env tclsh

set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)

set OPSYEARS(ATArchiver) "1,14"
set OPSYEARS(ATCamera) "1,14"
set OPSYEARS(ATDome) "1,14"
set OPSYEARS(ATHeaderService) "1,14"
set OPSYEARS(ATMCS) "1,14"
set OPSYEARS(ATMonochromator) "1,14"
set OPSYEARS(ATPneumatics) "1,14"
set OPSYEARS(ATSpectrograph) "1,14"
set OPSYEARS(ATTCS) "1,14"
set OPSYEARS(ATThermoelectricCooler) "1,14"
set OPSYEARS(ATWhiteLight) "1,14"
set OPSYEARS(CBP) "2,4"
set OPSYEARS(CatchupArchiver) "1,14"
set OPSYEARS(Dome) "1,14"
set OPSYEARS(DomeADB) "1,14"
set OPSYEARS(DomeAPS) "1,14"
set OPSYEARS(DomeLWS) "1,14"
set OPSYEARS(DomeLouvers) "1,14"
set OPSYEARS(DomeMONCS) "1,14"
set OPSYEARS(DomeTHCS) "1,14"
set OPSYEARS(EEC) "1,14"
set OPSYEARS(Electrometer) "1,14"
set OPSYEARS(Environment) "1,14"
set OPSYEARS(FiberSpectrograph) "1,14"
set OPSYEARS(Hexapod) "1,14"
set OPSYEARS(LinearStage) "1,14"
set OPSYEARS(M2MS) "1,14"
set OPSYEARS(MTArchiver) "1,14"
set OPSYEARS(MTCamera) "1,14"
set OPSYEARS(MTHeaderService) "1,14"
set OPSYEARS(MTM1M3) "2,14"
set OPSYEARS(MTMount) "2,14"
set OPSYEARS(MTOFC) "2,14"
set OPSYEARS(MTWEP) "2,14"
set OPSYEARS(OCS) "1,14"
set OPSYEARS(PromptProcessing) "1,14"
set OPSYEARS(Rotator) "1,14"
set OPSYEARS(Scheduler) "2,14"
set OPSYEARS(Script) "1,14"
set OPSYEARS(ScriptLoader) "1,14"
set OPSYEARS(ScriptQueue) "1,14"
set OPSYEARS(Sequencer) "2,14"
set OPSYEARS(SummitFacility) "1,14"
set OPSYEARS(TCS) "1,14"
set OPSYEARS(TunableLaser) "3,14"
set OPSYEARS(VMS) "1,14"

set OPSYEARSB(Camera.WDS.wfsRaft) "2,14"
set OPSYEARSB(Camera.GAS)  "2,14"
set OPSYEARSB(SeeingDimm.Application) "1,14"
set OPSYEARSB(Skycam.Application) "1,14"
set OPSYEARSB(Environment.LightningDetector) "2,14"
set OPSYEARSB(Environment.VideoCameras) "3,14"
set OPSYEARSB(ATCamera.headers) "1,14"
set OPSYEARSB(Comcam.headers) "2,14"
set OPSYEARSB(Camera.headers) "2,14"
set OPSYEARSB(Camera.WDS.optPathDiff) "2,14"
set OPSYEARSB(VMS.reduced) "2,14"
set OPSYEARSB(Environment.anemometers) "2,14"
set OPSYEARSB(Environment.domeSeeing) "1,14"
set OPSYEARSB(Environment.starTracker) "2,14"

set OPSYEARSB(Environment.CMOSCamera) "2,2"

set EPOCHS "na Year0 AIV-Auxtel Com-Comcam Com-Main Survey1 Survey2 Survey3 Survey4 Survey5 Survey6 Survey7 Survey8 Survey9 Survey10"
puts stdout "Calculating Storage requirements"

#unset freq
source $SAL_DIR/update_bandwidths.tcl

foreach blob  [array names OPSYEARSB] { 
   puts stdout "$blob $blobsum($blob)"
}


set fcum [open bandwidth/cumulative-storage-reqirements.html w]
puts $fcum "
<HTML><HEAD><TITLE>Cumulative EFD storage requirements</TITLE></HEAD>
<BODY><H1>Cumulative EFD storage  requirements - Summary</H1>
<P>This table shows the estimated cumulative EFD storage  requirements<BR>
for the LSST Observatory Telemetry, plus Command and Events history.<P>
It also includes estimates for the known Large File Annex objects, of the following classes<P>
<UL><UL>"
foreach lfo [lsort [array names OPSYEARSB]] {
   puts $fcum "<LI>$lfo"
}


puts $fcum "</UL></UL>
<P><TABLE BORDER=3 CELLPADDING=5  BGCOLOR=LightBlue WIDTH=600>
<TR BGCOLOR=Yellow><B><TD>Year</TD><TD>EFD Tables (GB)</TD><TD>Large File Annex (GB)</TD></B></TR>"


set total 0
set btotal 0
foreach y "1 2 3 4 5 6 7 8 9 10 11 12 13 14" {
  set aty($y) 0
  set bty($y) 0
  foreach s [array names OPSYEARS] {
     set start [lindex [split $OPSYEARS($s) ,] 0]
     set end   [lindex [split $OPSYEARS($s) ,] 1]
     if { $y >= $start && $y <= $end } {
       if { [info exists msum($s)] } {
         set aty($y) [expr $aty($y) + $msum($s)]
       }
     }
  }
  foreach s [array names OPSYEARSB] {
     set start [lindex [split $OPSYEARSB($s) ,] 0]
     set end   [lindex [split $OPSYEARSB($s) ,] 1]
     if { $y >= $start && $y <= $end } {
       if { [info exists blobsum($s)] } {
         set bty($y) [expr $bty($y) + $blobsum($s)]
       }
     }
  }
  set total [expr $total + $aty($y)]
  set gb [expr $total *60 *60 *365 *12 / 1000000000.]
  set btotal [expr $btotal + $bty($y)]
  set bgb [expr $btotal *60 *60 *365 *12 / 1000000000.]
  puts stdout "Cumulative total for year [lindex $EPOCHS $y] is [expr int($gb)] GB + [expr int($bgb)] GB"
  puts $fcum "<TR><TD>[lindex $EPOCHS $y]</TD><TD>[expr int($gb)]</TD><TD>[expr int($bgb)]</TD></TR>"
}

puts $fcum "</TABLE><P></BODY></HTML>"
close $fcum






