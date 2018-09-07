#!/usr/bin/env tclsh

proc tidyname { f } { 
  return [join [split $f .] _]
}

proc dosim { fid id nid } {
   puts $fid "<TR><TD>$id<INPUT NAME=\"dbsim_stream$nid\" TYPE=\"HIDDEN\" VALUE=\"$id\"></TD>
<TD><INPUT NAME=\"dbsim_host$nid\" VALUE=\"localhost\"></TD>
<TD><INPUT TYPE=\"checkbox\" NAME=\"dbsim_tlm$nid\" VALUE=\"yes\"></TD>
<TD><INPUT TYPE=\"checkbox\" NAME=\"dbsim_cmd$nid\" VALUE=\"yes\"></TD>
<TD><INPUT TYPE=\"checkbox\" NAME=\"dbsim_log$nid\" VALUE=\"yes\"></TD></TR>"
}



set scriptdir $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)

source $scriptdir/streamutils.tcl
source $scriptdir/add_system_dictionary.tcl
catch {unset MSYS}
set MSYS [lsort [split [exec cat $SAL_DIR/datastreams.names] \n]]]
foreach id $MSYS {
   set SYS([lindex [split $id _] 0]) 1
}

exec mkdir -p $SAL_WORK_DIR/html/dbsimulate
set fall [open $SAL_WORK_DIR/html/dbsimulate/index-dbsimulate.html w]
puts $fall "<HTML><HEAD><TITLE>Facility Subsystem and database simulation</TITLE></HEAD>
<BODY BGCOLOR=White>
<IMG SRC=\"LSST_logo.gif\" ALIGN=CENTER>
<IMG SRC=\"dbsim.gif\" ALIGN=CENTER><P><HR><P>
<H2>Facility Subsystem and Database simulation</H2><P><UL><UL>
<FORM><TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightBlue  WIDTH=400>
<TR BGCOLOR=Yellow><B><TD>Stream Name</TD><TD>Simulate subsystem</TD></TR>"


foreach subsystem $TSUBSYSTEMS {

set nid 1
puts $fall "<TR><TD><A HREF=\"index-dbsimulate-$subsystem.html\">$subsystem</A></TD>
<TD><A HREF=\"index-simulate-$subsystem.html\">$subsystem</A></TD></TR>"

set fidx [open $SAL_WORK_DIR/html/dbsimulate/index-simulate-$subsystem.html w]
puts $fidx "<HTML><HEAD><TITLE>Facility subsystem simulation</TITLE></HEAD>
<BODY BGCOLOR=White>
<IMG SRC=\"LSST_logo.gif\" ALIGN=CENTER>
<IMG SRC=\"facsim.gif\" ALIGN=CENTER><P><HR><P>
<H2>Facility Subsystem simulation - $subsystem</H2><P>
This form is used to prepare a simulation of the <B>$subsystem</B><BR>
subsystem. Each element of the simulation can be hosted on<BR>
a different machine. The default is to run all elements on<BR>
the SAL VM (localhost). <P>
For each machine used in the simulation a user account must<BR>
be created for username \"saluser\". This account must also<BR>
be enabled for ssh access from the SAL VM. <P>
The ssh public-key can be found <A HREF=\"downloads/ssh_public_key\">here</A>.<BR>
This key should be added to /home/saluser/.ssh/authorized_hosts<BR>
on each machine which is used in the simulation.<P>

<FORM action=\"/cgi-bin/simulatesubsystem\" method=\"post\">

<TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightBlue  WIDTH=600>
<TR BGCOLOR=Yellow><B><TD>Stream Name</TD><TD>Hostname</TD><TD>Telemetry</TD><TD>Commands</TD>
<TD>Logging/alerts</TD></B></TR>"

foreach id $MSYS {
   if { [lindex [split $id _] 0] == $subsystem } {
     dosim $fidx $id $nid
     incr nid 1
   }
}


puts $fidx "</TABLE><P><HR><P>
<INPUT NAME=\"dbsim_numstreams\" TYPE=\"HIDDEN\" VALUE=\"$nid\">
<INPUT NAME=\"dbsim_subsystem\" TYPE=\"HIDDEN\" VALUE=\"$subsystem\">

Simulation name : <INPUT NAME=\"dbsim_simid\" SIZE=16 VALUE=\"test\">
<P><HR><P>
<P><HR>
<P>Click here to generate simulation : <input type=\"submit\" value=\"Submit\" name=\"update\"></FORM><P></BODY></HTML>"
close $fidx

}

puts $fall "</TABLE></UL></UL><P><HR><P></BODY></HTML>"
close $fall
