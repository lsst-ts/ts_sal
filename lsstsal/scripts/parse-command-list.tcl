#!/usr/bin/env tclsh

set fin [open commands-list r]
set fout [open commands-list.html w]
while { [gets $fin rec] > -1 } {
  if { [string index $rec 0] == "#" || [string trim $rec] == "" } {
  } else {
    set s [lindex $rec 0]
    if { $s != "Any" } {
       lappend CMDS($s) [join [lrange $rec 1 end] :]
    }
  }
}
close $fin

set fout [open commands-list.html w]
foreach s [lsort [array names CMDS]] {
   puts stdout "Processing $s"
   puts $fout "<H3>$s Commands</H3><P><UL>"
   puts $fout "<TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightBlue  WIDTH=600>
<TR BGCOLOR=Yellow><B><TD>Subsystem</TD><TD>Device</TD><TD>Property</TD><TD>Action</TD<TD>Parameter</TD></B></TR>"
   foreach c [lsort $CMDS($s)] {
      set f "[split $c :] <EM>n/a</EM> <EM>n/a</EM> <EM>n/a</EM>"
      puts $fout "<TR><TD>$s</TD><TD>[lindex $f 0]</TD><TD>[lindex $f 1]</TD><TD> [lindex $f 2]</TD><TD> [lindex $f 3]</TD></TR>"
   }
   puts $fout "</TABLE></UL><P>"
}

close $fout

