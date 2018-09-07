#!/usr/bin/env tclsh

proc printformdata { } {
global env FormData
   foreach i [lsort [array names env]] {
       puts stdout "Env $i = $env($i)<BR>"
  }
   foreach i [lsort [array names FormData]] {
       puts stdout "Form $i = $FormData($i)<BR>"
  }
}

proc dlog { msg } {
global FormData
  if { $FormData(DEBUG) == 1 } {
     puts stdout "$msg"
  }
}


source /usr/local/scripts/tcl/GetPostedData.tcl
source /usr/local/scripts/tcl/versioning.tcl
source /usr/local/scripts/tcl/streamutils.tcl

if { [info exists FormData(DEBUG)] == 0 } {set FormData(DEBUG) 0}
set FormData(DEBUG) 1
puts stdout "Content-type: text/html\n\n"
set FormData(dbsim_type) ""

GetPostedData
##printformdata

set ip [split [exec /sbin/ifconfig eth0] \n]
set whereami [lindex [lindex [split [lindex $ip 1] ":"] 1] 0]

puts stdout "<HTML><HEAD><TITLE>Facility Subsystem simulation</TITLE></HEAD>
<BODY BGCOLOR=White>
<IMG SRC=\"/LSST_logo.gif\" ALIGN=CENTER>
<IMG SRC=\"/facsim.gif\" ALIGN=CENTER><P><HR><P>
<H2>Facility Subsystem Simulation - Processing</H2><P><UL>"

exec mkdir -p /home/saluser/simulations/$FormData(dbsim_simid)
set fout [open /home/saluser/simulations/$FormData(dbsim_simid)/runsimulation.sh w]
puts $fout "#!/bin/sh
#
# Simulation launcher for subsystem $FormData(dbsim_subsystem)
#"
set LOADENV(localhost) 1
set n 1
while { $n < $FormData(dbsim_numstreams) } {
 if { [info exists FormData(dbsim_tlm$n)] } {
   set i $FormData(dbsim_stream$n)
   set subsys [join [lrange [split $i _] 0 1] _]
   puts stdout "Processing $i<BR>"
   set host $FormData(dbsim_host$n)
   if { [info exists LOADENV($host)] == 0 } {
      puts $fout "#Install runtime environment on $host
echo \"Installing runtime environment on $host\"
ssh -l saluser $host mkdir -p /home/saluser/simulations/$FormData(dbsim_simid)
scp /var/www/html/downloads/ndds-javaruntime.tar.gz saluser@$host:.
ssh -l saluser $host tar xzf ndds-javaruntime.tar.gz"
      set LOADENV($host) 1
   }
   if { $host == "localhost" } {
     puts $fout "#Install programs for $i simulation
echo \"Installing programs for $i simulation on $host\"
cp -r $WORKING/shmem-$i/* /home/saluser/simulations/$FormData(dbsim_simid)/."
   } else {
     puts $fout "#Install programs for $i simulation
echo \"Installing programs for $i simulation on $host\"
scp -r $WORKING/shmem-$i/* saluser@$host:simulations/$FormData(dbsim_simid)/."
   }
 }
 incr n 1
}

puts $fout ". /home/saluser/lsstsal.$SALVERSION/setupenv"
set n 1
while { $n < $FormData(dbsim_numstreams) } {
 if { [info exists FormData(dbsim_tlm$n)] } {
   set i $FormData(dbsim_stream$n)
   set subsys [join [lrange [split $i _] 0 1] _]
   set host $FormData(dbsim_host$n)
   if { $host == "localhost" } {
     puts $fout "gnome-terminal -e /home/saluser/simulations/$FormData(dbsim_simid)/startpub-$i &"
   } else {
     puts $fout "gnome-terminal -e ssh -l saluser $host simulations/$FormData(dbsim_simid)/startpub-$i &"
   }
 }
 if { [info exists FormData(dbsim_cmd$n)] } {
   set cmds($host) 1
 }
 incr n 1
}
foreach h [array names cmds] {
   if { $host == "localhost" } {
     puts $fout "gnome-terminal -e /home/saluser/simulations/$FormData(dbsim_simid)/startsub-[set subsys]_response &"
   } else {
     puts $fout "gnome-terminal -e ssh -l saluser $host simulations/$FormData(dbsim_simid)/startsub-[set subsys]_response &"
   }
}

close $fout
exec chmod a+x /home/saluser/simulations/$FormData(dbsim_simid)/runsimulation.sh

puts stdout "<P></UL><HR><P><H2>Using the simulation</H2><UL>
The launcher for this simulation has been created in<BR>
the <B>/home/saluser/simulations/$FormData(dbsim_simid)</B> directory<BR>
on the SAL Virtual Machine.<P>
The script, <B>runsimulation.sh</B>, will copy the appropriate<BR>
runtime environments and executables to the hosts involved.<P>
The simulation processes will then be launched. Each process<BR>
runs in an terminal. The simulation desktop runs in a 
<A HREF=\"http://www.realvnc.com\">VNC</A><BR>
session. The session can be accessed using a standard VNC<BR>
viewer application , or from the web browser (click the link below).<P>
To access the VNC session start your local viewer like this<P>
<PRE>
  vncviewer $whereami:1	
</PRE>

The vnc password is \"saluser\"<P>
Once you are connected to the VNC desktop , select the<BR>
terminal window and type <P>
<PRE>
  cd simulations/test
  ./runsimulation.sh
</PRE>
<P>Or, click <A HREF=\"http://$whereami:5801\">VNC session</A>
 to access the simulation laucher desktop<BR>
using the browser. This requires Java plugin support<BR>
and is slower than using a standalone vncviewer program. 
</UL><P><HR><P>
<A HREF=\"/index.html\">SAL VM homepage</A> : : 
<a href=\"mailto:dmills@noao.edu?subject=Mail from SAL VM\">Email Support</a>
<P><HR><P></BODY></HTML>"


