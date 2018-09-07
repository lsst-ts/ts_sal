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

proc part1 { fout sid } {
global FormData env
   puts $fout "<HTML><HEAD><TITLE>Stream definition editor - $sid</TITLE></HEAD>
<BODY BGCOLOR=White>
<IMG SRC=\"LSST_logo.gif\" ALIGN=CENTER>
<IMG SRC=\"dde.gif\" ALIGN=CENTER><P><HR><P>
<H1>Stream $sid</H1><P>
<P>$FormData(description)<HR><P>
<FORM action=\"http://triplet.tuc.noao.edu/cgi-bin/streamdef\" method=\"post\">
<INPUT NAME=\"streamid\" TYPE=\"HIDDEN\" VALUE=\"$sid\">
<INPUT NAME=\"description\" TYPE=\"HIDDEN\" VALUE=\"$FormData(description)\">"
}

proc dlog { msg } {
global FormData
  if { $FormData(DEBUG) == 1 } {
     puts stdout "$msg"
  }
}


source /usr/local/scripts/tcl/GetPostedData.tcl
source /usr/local/scripts/tcl/streamdesc.tcl
source /usr/local/scripts/tcl/streamutils.tcl
set streamdir  /var/www/html/streams/

if { [info exists FormData(DEBUG)] == 0 } {set FormData(DEBUG) 0}
set FormData(DEBUG) 1
puts stdout "Content-type: text/html\n\n"

GetPostedData
if { [info exists FormData(streamid)] } {
   set sid $FormData(streamid)
} else {
   set sid $FormData(system).$FormData(new)
}

puts stdout "<HTML><HEAD><META HTTP-EQUIV=\"Refresh\" CONTENT=\"5; URL=http://$env(HTTP_HOST)/streams/$sid-streamdef.html\"></HEAD><BODY>"

if { $FormData(DEBUG) == 1 } {
  printformdata
}

set STREAMS [array names SDESC]


set fout [open $streamdir/$sid-streamdef.html w]
dlog "opened $streamdir/$sid.html"


part1 $fout $sid

if { [info exists FormData(streamid)] } {
   puts stdout "editing it"
   set eid 1
   set newid 1
   puts $fout "
<TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightBlue  WIDTH=600>
<TR BGCOLOR=Yellow><B><TD>Name</TD><TD>Type</TD><TD>Size</TD><TD>Units</TD>
<TD>Range</TD><TD>Comment</TD><TD>Delete</TD></B></TR>"
   while { $eid < [expr [llength [array names FormData]]/6] } {
    if { [info exists FormData(id$eid)] } {
    if { [string trim $FormData(id$eid)] != "" } {
    if { [info exists FormData(delete_$eid)] == 0 } {
     set cname [join [split $FormData(id$eid) "+-\\\[\]\{\}\$\%\!\*\(\)\<\>\"\'\` 	" ] "_"]
     doitem $newid $fout $cname $FormData(type$eid) $FormData(siz$eid) $FormData(unit$eid) $FormData(range$eid) "$FormData(help$eid)"
     incr newid 1
    }
    }
    }
    incr eid 1
   }
   doitem $newid $fout "" int 1
   puts $fout "</TABLE><P>Click here to update: <input type=\"submit\" value=\"Submit\" name=\"update\"></FORM><P></BODY></HTML>"
} else {
  if { [string trim $FormData(copy) "\{\} "] != "" } {
   set fin [open $streamdir/$FormData(copy)-streamdef.html r]
   dlog "Copying from $streamdir/$FormData(copy)-streamdef.html"
   set clone 0
   while { [gets $fin rec] > -1 } {
     if { [string range $rec 0 5] == "<TABLE" } {set clone 1}
     if { $clone } {puts $fout "$rec"}
#     dlog "$clone | $rec"
   }
   close $fin 
  } else {
   dlog "New file"
   set eid 1
   puts $fout "
<TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightBlue  WIDTH=600>
<TR BGCOLOR=Yellow><B><TD>Name</TD><TD>Type</TD><TD>Size</TD><TD>Units</TD>
<TD>Range</TD><TD>Comment</TD><TD>Delete</TD></B></TR>"
   while { $eid < 10 } {
      doitem $eid $fout "" int 1
      incr eid 1
   }
   puts $fout "</TABLE><P>Click here to update: <input type=\"submit\" value=\"Submit\" name=\"update\"></FORM><P></BODY></HTML>"
  }
}

close $fout

dlog "closed it"
puts stdout "</BODY></HTML>"


###exec cat $streamdir/$sid.html

