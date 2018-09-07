#!/usr/bin/env tclsh

proc logsum { f t s {url no} } {
  set mbps [format %16.4f [expr $s*8./1024./1024.]]
  set perday [format %16.2f [expr $mbps*60.*60.*10./8.]]
  set rcol ""
  if { [lindex $t 0] == "Total" } {set rcol "BGCOLOR=Orange"}
  puts stdout "Topic $t:		[format %16.1f $s] Bytes/s $mbps Mbps	$perday MB/day"
  if { $url == "no" } {
     puts $f "<TR $rcol><TD>$t</TD><TD>[format %16.1f $s]</TD><TD>$mbps</TD><TD>$perday</TD></TR>"
  } else {
     puts $f "<TR><TD><A HREF=\"datastreams-bandwidths-$t.html\">$t</A></TD><TD>[format %16.1f $s]</TD><TD>$mbps</TD><TD>$perday</TD></TR>"
  }
}

proc blogsum { f t s {url no} } {
  set mbps [format %16.4f [expr $s*8./1024./1024.]]
  set perday [format %8d [expr int($mbps*60.*60.*10./8.*10+5) / 10]]
  set rcol ""
  if { [lindex $t 0] == "Total" } {set rcol "BGCOLOR=Orange"}
  puts stdout "Topic $t: $perday MB/day"
  puts $f "<TR><TD style=\"font-weight: bold;\"><big><big>$t</TD><TD style=\"font-weight: bold; text-align: right;\"><big><big>$perday</TD></TR>"
}

set scriptdir $env(SAL_DIR)
source $scriptdir/datastream_desc.tcl
source $scriptdir/camera-subsysdesc.tcl
source $scriptdir/stream_frequencies.tcl

exec mkdir -p bandwidth
set fin  [open datastreams.html r]
set fout [open datastreams.def w]
set fo2  [open bandwidth/datastreams-bandwidths.html w]
#set fdat [open datastreams.detail w]
puts $fo2 "
<HTML><HEAD><TITLE>Telemetry bandwidth requirements</TITLE></HEAD>
<BODY><H1>Telemetry bandwidth requirements</H1>
<P>This table shows the estimated bandwidth requirements<BR>
for the LSST Observatory Telemetry. Each major subsystem<BR>
is show, and is linked to a more detailed table.<P>
<P><TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightBlue WIDTH=600>
<TR BGCOLOR=Yellow><B><TD>Subsystem Id</TD><TD>Bytes/Sec</TD><TD>Mbps</TD><TD>MB per Day</TD></B></TR>"

set top ""
set maj system
set msum(system) 0
catch {unset freq}

while { [gets $fin rec] > -1 } {
   set s [split $rec "<>:"]
   if { [string trim [lindex $s 2]] == "Topic" } {
     if { $top != "" } {logsum $fo2 $top $sum($top)}
     if { $top != "" } {set msum($maj) [expr $msum($maj) + $sum($top)]}
     set top [string trim [lindex $s 3]]
     if { [string trim [lindex [split $top .] 0]] != $maj } {
        set maj [string trim [lindex [split $top .] 0]]
        set msum($maj) 0
     }
     set sum($top) 64
     set bsum($top) 0
     set sour($top) 1
   }
   if { [string trim [lindex $s 5]] == "Frequency" } {
      set freq($top) [string trim [lindex [lindex $s 6] 0]]
      if { $freq($top) < 1 } {set freq($top) 0.5}
      if { $freq($top) == "Infrequent" } {set freq($top) 0.001}
   }
   if { [info exists FREQUENCY($top)] } {set freq($top) $FREQUENCY($top)}
   set sour($top) 1
   if { [string trim [lindex $s 5]] == "Number of sources" } {
      set sour($top) [string trim [lindex [lindex $s 6] 0]]
   }
   if { [string trim [lindex $s 5]] == "Item / type / count" } {
#      gets $fin r2
      set s2 $rec
      set s [split $s2 "<>:"]
      set it [split [string trim [lindex $s 6]] /]
      set ty [string trim [lindex $it 1]]
      set n [string trim [lindex $it 2]]
      if { $n == "" } {set n 1 ; set strn [lindex $s 7]}
      if { [info exists strn] == 0 } {set strn 32}
      set nf [expr $n * $freq($top) * $sour($top)]
      switch $ty {
            string -
            String { set sum($top) [expr $sum($top) + $strn.*$nf] } 
            float  -
            Float  { set sum($top) [expr $sum($top) + 4.*$nf] } 
            double  -
            Double  { set sum($top) [expr $sum($top) + 8.*$nf] } 
            int    -
            long   -
            Int    { set sum($top) [expr $sum($top) + 4.*$nf] } 
            short  -
            Short  { set sum($top) [expr $sum($top) + 2.*$nf] } 
            byte   -
            Byte   { set sum($top) [expr $sum($top) + 1.*$nf] } 
            default {puts stdout "Unsupported type - $ty"}
      }
      set id [join [string trim [lindex $it 0]] "_"]
#puts stdout "$id $ty $n" 
      if { $n > 1 } {
         puts $fout "$top.$id\[$n\]		$ty"
#         puts $fdat "$top.$id $n $ty $freq($top)"
      } else {
         puts $fout "$top.$id			$ty"
#         puts $fdat "$top.$id 1 $ty $freq($top)"
      }
   }
}

if { $top != "" } {set msum($maj) [expr $msum($maj) + $sum($top)]}
puts $fo2 "</TABLE><P></BODY></HTML>"
close $fo2

set fo3 [open bandwidth/datastreams-bandwidths-by-subsystem.html w]
puts $fo3 "
<HTML><HEAD><TITLE>Telemetry bandwidth requirements</TITLE></HEAD>
<BODY><H1>Telemetry bandwidth requirements - Summary</H1>
<P>This table shows the estimated bandwidth requirements<BR>
for the LSST Observatory Telemetry. Each major subsystem<BR>
is show, and is linked to a more detailed table.<P>
This table does not include large vector/image datatypes,<BR>
See <A HREF=\"datastreams-bandwidths-by-blobs.html\">here</A> for BLOB data.<P>
<P><TABLE BORDER=3 CELLPADDING=5  BGCOLOR=LightBlue WIDTH=600>
<TR BGCOLOR=Yellow><B><TD>Subsystem Id</TD><TD>Bytes/Sec</TD><TD>Mbps</TD><TD>MB per Day</TD></B></TR>"
set gt 0
foreach s [lsort [array names msum]] {
    logsum $fo3 $s $msum($s) href
    set gt [expr $gt + $msum($s)]
}

logsum $fo3 "Total for all Subsystems" $gt
puts $fo3 "</TABLE><P></BODY></HTML>"
close $fo3

set fo4 [open bandwidth/datastreams-bandwidths-by-blobs.html w]
puts $fo4 "
<HTML><HEAD><TITLE>Telemetry bandwidth requirements - BLOBs</TITLE></HEAD>
<BODY><H1>Telemetry bandwidth requirements - BLOBs</H1>
<P>This table shows the estimated bandwidth requirements<BR>
for the LSST Observatory Telemetry. Only subsystems which <BR>
produce large image/vector datasets (BLOBs) are shown here.<P>
<P><TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightBlue  WIDTH=600>
<TR BGCOLOR=Yellow><B><TD>Subsystem</TD><TD>Bytes/Sec</TD><TD>Mbps</TD><TD>MB per Day</TD></B></TR>"
set bgt 0
foreach s [lsort [array names BLOBS]] {
    set sdot [join [split $s _] .]
    set sour($sdot) 1
    set freq($sdot) 0.054
    if { [info exists FREQUENCY($sdot)] } {set freq($sdot) $FREQUENCY($sdot)}
    set bpp [expr [string trim [lindex $BLOBS($s) 1] bit] / 8]
    set siz [split [lindex $BLOBS($s) 0] x]
    set bbytes [expr $bpp*$sour($sdot)*$freq($sdot)*[lindex $siz 0]*[lindex $siz 1]*[lindex $siz 2]]
    set bsum($s) $bbytes
puts stdout "BLOB : $sdot $freq($sdot) $bbytes"
    logsum $fo4 $s $bsum($s)
    set bgt [expr $bgt + $bsum($s)]
}

logsum $fo4 All-BLOBs $bgt
puts $fo4 "</TABLE><P></BODY></HTML>"
close $fo4

close $fin
close $fout
#close $fdat

set maj ""
foreach s [lsort [array names sum]] {
   set t [lindex [split $s .] 0]
   if { $t != $maj } {
      if { $maj != "" } {
         logsum $fo5 "Total for Subsystem" $msum($maj)
      }
      catch {puts $fo5 "</TABLE><P></BODY></HTML>"
             close $fo5
      }
      set maj $t
      set fo5 [open bandwidth/datastreams-bandwidths-$t.html w]
puts $fo5 "
<HTML><HEAD><TITLE>Telemetry bandwidth requirements - $t</TITLE></HEAD>
<BODY><H1>Telemetry bandwidth requirements - $t</H1>
<P>This table shows the estimated bandwidth requirements<BR>
for the LSST Observatory Telemetry. This table details the<BR>
estimates for the $t Subsystem.<P>
This table does not include large vector/image datatypes,<BR>
See <A HREF=\"datastreams-bandwidths-by-blobs.html\">here</A> for BLOB data.<P>
<P><TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightBlue  WIDTH=600>
<TR BGCOLOR=Yellow><B><TD>Subsystem Id</TD><TD>Bytes/Sec</TD><TD>Mbps</TD><TD>MB per Day</TD></B></TR>"
   }
   logsum $fo5 $s $sum($s)
}
logsum $fo5 "Total for Subsystem" $msum($maj)
puts $fo5 "</TABLE><P></BODY></HTML>"
close $fo5



set fo6 [open bandwidth/datastreams-bw-summary.html w]
puts $fo6 "
<HTML><HEAD><TITLE>Telemetry bandwidth requirements</TITLE></HEAD>
<BODY><H1>Telemetry bandwidth requirements - Summary</H1>
<P>This table shows the estimated bandwidth requirements<BR>
for the LSST Observatory Telemetry. Each major subsystem<BR>
is shown.<P>
This table does not include large vector/image datatypes,<BR>
See <A HREF=\"datastreams-bandwidths-by-blobs.html\">here</A> for BLOB data.<P>
<P><TABLE BORDER=1 CELLPADDING=1  BGCOLOR=LightBlue WIDTH=450>
<TR BGCOLOR=Yellow><B><TD style=\"font-weight: bold;\"><big><big>Subsystem Id</TD><TD><BIG><BIG>MB per Day</TD></B></TR>"
set gt 0
foreach s [lsort [array names msum]] {
    blogsum $fo6 $s $msum($s)
    set gt [expr $gt + $msum($s)]
}

blogsum $fo6 "Total for all Subsystems" $gt
puts $fo6 "</TABLE><P></BODY></HTML>"
close $fo6

set fout [open bandwidth/stream_frequencies.tcl w]
foreach t [lsort [array names freq]] {
  set s [join [split $t .] _]
  puts $fout "set FREQUENCY($s) $freq($t)"
}
close $fout


