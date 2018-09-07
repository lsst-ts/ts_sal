#!/usr/bin/env tclsh

proc telemetrytables { fid } {
global SUBSYSTEM2 SID ITEM PROP DESC COMMENT
  set all [lsort [array names ITEM]]
  foreach i $all {
    set s [lindex [split $i .] 0]
    if { $s == $SUBSYSTEM2 } {
       puts $fid "<H3>Telemetry datastream topic : $i</H3><P>
$DESC($i)<P>
<TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightGrey WIDTH=700><TR><TD>Item</TD><TD>Type</TD><TD>Size</TD><TD>Freq.</TD><TD>Notes</TD></TR>"
       foreach p $ITEM($i) {
           set it $PROP($i,$p)
           set cmt "None"
           catch { set cmt $COMMENT($i.$p) }
           puts $fid "<TR><TD>$p</TD><TD>[lindex $it 1]</TD><TD>[lindex $it 0]</TD><TD>[lindex $it 2]</TD><TD>$cmt</TD></TR>"
       }
       puts $fid "</TABLE><P>"
    }
  }
}

set scriptdir $SAL_DIR
#source $scriptdir/newstreams.tcl
catch {source $SAL_WORK_DIR/.salwork/datastreams.comments}

set fin [open $SAL_WORK_DIR/.salwork/datastreams.detail r]
while { [gets $fin rec] > -1 } {
  set r [split [lindex $rec 0] .]
  if { [llength $r] == 4 } {
    set s [join [lrange $r 0 2] .]
    lappend ITEM($s) [lindex $r 3]
    set PROP($s,[lindex $r 3]) [lrange $rec 1 end]
  } else {
    set s [join [lrange $r 0 1] .]
    lappend ITEM($s) [lindex $r 2]
    set PROP($s,[lindex $r 2]) [lrange $rec 1 end]
  }
}
close $fin


source $scriptdir/streamdesc.tcl
source $scriptdir/subsysdesc.tcl
source $scriptdir/camera-subsysdesc.tcl
source $scriptdir/newcomments.tcl
source $scriptdir/datastream_desc.tcl  

set ACTIVEGLOSSARY ""
foreach i [lsort [array names GLOSSARY]] {
  set ACTIVEGLOSSARY "$ACTIVEGLOSSARY<BR>$i - $GLOSSARY($i)"
}

foreach i [array names SDESC] {
  if { [info exists DESC($i)] == 0 } {set DESC($i) $SDESC($i)}
  puts stdout "No DESC for $i"
}

set SUBSYSTEM1 OCS
foreach i $SUBS {
  set SUBSYSTEM2 $i
  set ORIGDATE [exec date +%m/%d/20%y]
  source $scriptdir/icd_template.html
  set fout [open $SAL_WORK_DIR/html/icd-sw-$SID($SUBSYSTEM1)-$SID($SUBSYSTEM2).html w]
  puts $fout "$TICD"
  telemetrytables $fout
  puts $fout "$TICD2"
  close $fout
  puts stdout "Done $i"
}


