proc doitem { i fid name n type {unit none} {range none} {help "No comment"} } {
   set iname [getitemname $name]
   puts $fid "<TR><TD><INPUT NAME=\"id$i\" VALUE=\"$iname\"></TD>
<TD><select name=\"type$i\">"
   set ctype [lindex [split $type "<>"] 0]
##puts stdout "doitem $i $fid $name $n $ctype $unit $range"
   dotypeselect $fid $ctype
   puts $fid "</select>"
   puts $fid "<TD><INPUT NAME=\"siz$i\" VALUE=\"$n\"></TD>"
   dounit $fid $i $unit
   puts $fid "<TD><INPUT NAME=\"range$i\" VALUE=\"$range\"></TD>
<TD><INPUT NAME=\"help$i\" VALUE=\"$help\"></TD>
<TD><INPUT TYPE=\"checkbox\" NAME=\"delete_$i\" VALUE=\"yes\"></TD></TR>"
}

proc dotypeselect { fid choice } {
global SYSDIC
   foreach t $SYSDIC(datatypes) {
     if { $t == $choice } {
       puts $fid "<option value=\"$t\" SELECTED>$t</option>"
     } else {
       puts $fid "<option value=\"$t\">$t</option>"
     }
   }
}


proc getitemname { name } {
  set spl [split $name "._-"]
  set id [join [lrange $spl 2 end] _]
  return $id
}


proc liststreams { {subsys all} } {
global SAL_WORK_DIR SAL_DIR
   set fs [open $SAL_WORK_DIR/.salwork/datastreams.names r]
   while { [gets $fs rec] > -1 } {
      set spl [split $rec "_"]
      if { $subsys == "all" || $subsys == [lindex $spl 0] } {
        if { [lindex $spl 1] != "command" &&  [lindex $spl 1] != "ackcmd" && [lindex $spl 1] != "logevent"} {
          set s [join [lrange $spl 0 1] "_"]
          set sname($s) 1
        }
      }
   } 
   return [lsort [array names sname]]  
}


proc dounit { fid id u} {
global UDESC
  set u [string tolower $u]
  if { [string trim $u] == "" } {set u none}
  puts $fid "<TD><select name=\"unit$id\">"
  puts $fid "<option value=\"$u\" selected>$u"
  foreach i [lsort [array names UDESC]] {
     if { $u != $i } {
       puts $fid "<option value=\"$i\">$i"
     }
  }
  puts $fid "</select></TD>"
}

proc dogen { fid id {cmd yes} } {
   if { $cmd } {
      puts $fid "<TR><TD><A HREF=\"sal-generator-$id.html\">$id</A></TD>"
   } else {
      set uid [join [split $id .] "_"]
      puts $fid "<TR><TD><A HREF=\"$id/$uid-streamdef.html\">$id</A></TD>"
   }
   puts $fid "<TD><INPUT TYPE=\"checkbox\" NAME=\"sub_$id\" VALUE=\"yes\">
<TD><INPUT TYPE=\"checkbox\" NAME=\"pub_$id\" VALUE=\"yes\">"
   if { $cmd } {
      puts $fid "<TD><INPUT TYPE=\"checkbox\" NAME=\"issue_$id\" VALUE=\"yes\">
<TD><INPUT TYPE=\"checkbox\" NAME=\"proc_$id\" VALUE=\"yes\">"
   }
}


proc idlpreamble { fid id } {
  puts $fid "struct [join [split $id .] _] \{
  string<32>	private_revCode; //private
  double	private_sndStamp; //private
  double	private_rcvStamp; //private
  long		private_seqNum; //private
  long		private_origin; //private
  long		private_host; //private" 
}

proc sqlpreamble { fid id } {
  puts $fid  "CREATE TABLE $id \{"
  puts $fid  "  date_time date time NOT NULL,
  private_revCode char(32),
  private_sndStamp double,
  private_rcvStamp double,
  private_seqNum int,
  private_origin int,
  private_host int,"
}

set WORKING /home/shared/lsst/tests/api/streams
if { [info exists FormData(workingDir)] } {
   set WORKING $FormData(workingDir)
}
if { [info exists env(workingDir)] } {
   set WORKING $env(workingDir)
}



