#!/usr/bin/env tclsh

puts stdout "Building datastreams.html"
set scriptdir $env(SAL_HOME)/scripts

source $scriptdir/datastream_desc.tcl
source $scriptdir/camera-subsysdesc.tcl
source $scriptdir/unitsdesc.tcl
source $scriptdir/qosdesc.tcl


set fin [open .salwork/datastreams.detail r]
while { [gets $fin rec] > -1 } {
   set s [split [lindex $rec 1] .]
   if { [lindex $s 1] != "command" &&  [lindex $s 1] != "ackcmd" } {
     set SYSTEMS([lindex $s 0]) 1
     set topic [join [lrange $s 0 [expr [llength $s]-2]] .]
     lappend T($topic) [lindex $s end]
     set PROPS($topic,[lindex $s end]) [lrange $rec 2 end]
   }
}
close $fin

set VERSION 3.2
set RELEASE "Nov 2016"
set AUTHOR "D. Mills (NOAO), dmills@noao.edu"

set fout [open datastreams.html w]

puts $fout "
<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">
<HTML>
<HEAD>
        <META HTTP-EQUIV=\"CONTENT-TYPE\" CONTENT=\"text/html; charset=utf-8\">
        <TITLE>LSST Telescope/Site Middleware - Datastream prototyping</TITLE>
        <META NAME=\"GENERATOR\" CONTENT=\"OpenOffice.org 1.9.129  (Linux)\">
        <META NAME=\"CREATED\" CONTENT=\"20060511;10051700\">
        <META NAME=\"CHANGED\" CONTENT=\"20060627;9441000\">
        <STYLE>
        <!--
                @page \{ size: 8.5in 11in \}
        -->
        </STYLE>
</HEAD>
<BODY LANG=\"en-US\" DIR=\"LTR\">
<H1>LSST Telescope/Site Middleware - Datastream prototyping</H1>
<H2><FONT SIZE=4><B>Version - $VERSION<B></FONT></H2>
<P><FONT SIZE=4><B>Date – $RELEASE</B></FONT></P>
<P><FONT SIZE=4><B>Author – $AUTHOR</B></FONT></P>
<H2>Introduction</H2>
<P>This document describes a strawman set of datastream prototypes
which<BR>will be used to evaluate the capability of various software
components<BR>(middleware) for use in the LSST software
infrastructure. 
</P>
<P>For each datastream type, we provide a brief description of the
item,<BR>plus an estimate of the number of subsytems likely to
produce and<BR>subscribe to items of this type. The update frequency
and likely <BR>size of components of the datastream are provided, and
finally a<BR>list of any Binary Large Object (BLOB's) which might be
produced<BR>in association with the datastream.</P>
<P>The objective is to produce a comprehensive list which can be
used<BR>to help automate the testing of middleware components. A
database will<BR>be generated using the information herein, and
software written to autogenerate<BR>sample code to simulate
interactions between any 2 (or more) of the subsystems<BR>described.</P>
<P>A full list of the subsystems can be found in Appendix A. 
</P>"

set subs [lsort [array names T]]
set flst [open .salwork/datastreams_desc.names w]
foreach s $subs {
  puts $flst $s
}
close $flst

set fin [open .salwork/datastreams_desc.pubsub r]
while { [gets $fin rec] > -1 } {
  set PUBS([lindex $rec 0]) [lindex $rec 1]
  set SUBS([lindex $rec 0]) [lindex $rec 2]
}
close $fin 


foreach s $subs {
  set p [lindex [split $s .] 0]
  if { [info exists INTRO($p)] == 0 && [info exists DESC($p)] } {
     set INTRO($p) 1
     puts $fout "<H2>Subsystem : $p</H2><P>$DESC($p)<P>"
  }
  puts stdout "Processing $s"
  puts $fout "<H2>Topic : $s</H2>
<H3>Description</H3><P>"
  if { [info exists DESC($s)] } {
     puts $fout "$DESC($s)<P>"
  } else {
     puts stdout "No DESC for $s"
     if { [info exists SDESC($s)] } {
        puts $fout "$SDESC($s)<P>"
     } else {
        puts stdout "No SDESC for $s"
     }
  }
  if { [info exists PUBS($s)] == 0 } {puts stdout "No PUBS for $s"; set PUBS($s) 1}
  if { [info exists SUBS($s)] == 0 } {puts stdout "No SUBS for $s"; set SUBS($s) 2}
  set items [lsort $T($s)]
  set freq [lindex $PROPS($s,[lindex $T($s) 0]) 2]
  puts $fout "<UL>
        <LI><P STYLE=\"margin-bottom: 0in\">Number of sources : $PUBS($s)</P>
        <LI><P STYLE=\"margin-bottom: 0in\">Number of subscribers : $SUBS($s)</P>
        <LI><P STYLE=\"margin-bottom: 0in\">Frequency : $freq Hz</P>"
  foreach i $items {
     puts stdout "Processing $s.$i"
     set v "$i / [lindex $PROPS($s,$i) 1] / [lindex $PROPS($s,$i) 0]"
     puts $fout "        <LI><P STYLE=\"margin-bottom: 0in\">Item / type / count : $v</P>"
  }
  if { [info exists BLOBS($s)] } {
     puts $fout "        <LI><P>BLOBs : $BLOBS($s)</P>"
  } else {
     puts $fout "        <LI><P>BLOBs : None</P>"
  }
  puts $fout "</UL><P>"
}

puts $fout "<HR><H1>Appendix A - Prototype Datastreams</H1><UL>"
foreach s $subs {
  puts $fout "        <LI><P STYLE=\"margin-bottom: 0in\">$s</P>"
}

puts $fout "</UL></BODY></HTML>"
close $fout








