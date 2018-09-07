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
source /usr/local/scripts/tcl/simulatedb.tcl
source /usr/local/scripts/tcl/streamutils.tcl

if { [info exists FormData(DEBUG)] == 0 } {set FormData(DEBUG) 0}
set FormData(DEBUG) 1
puts stdout "Content-type: text/html\n\n"
set FormData(dbsim_type) ""

GetPostedData
##printformdata

set start "$FormData(dbsim_starty)-[format %2.2d $FormData(dbsim_startmon)]-[format %2.2d $FormData(dbsim_startday)] [format %2.2d $FormData(dbsim_starthour)]:[format %2.2d $FormData(dbsim_startmin)]:[format %2.2d $FormData(dbsim_startsec)]"

set end "$FormData(dbsim_endy)-[format %2.2d $FormData(dbsim_endmon)]-[format %2.2d $FormData(dbsim_endday)] [format %2.2d $FormData(dbsim_endhour)]:[format %2.2d $FormData(dbsim_endmin)]:[format %2.2d $FormData(dbsim_endsec)]"

puts stdout "<HTML><HEAD><TITLE>Stream facility database simulation</TITLE></HEAD>
<BODY BGCOLOR=White>
<IMG SRC=\"/LSST_logo.gif\" ALIGN=CENTER>
<IMG SRC=\"/dbsim.gif\" ALIGN=CENTER><P><HR><P>
<H2>Facility Database Simulation - Processing</H2><P><UL>
Start time is $start<BR>
End time is $end<P>"

set n 1
exec rm -fr /tmp/facilitydb-mysql
exec mkdir -p /tmp/facilitydb-mysql
while { $n < $FormData(dbsim_numstreams) } {
 if { [info exists FormData(dbsim_tlm$n)] } {
   set i $FormData(dbsim_stream$n)
   set subsys [join [lrange [split $i _] 0 1] _]
   puts stdout "Processing $i<BR>"
   if { $FormData(dbsim_type) == "sql" || $FormData(dbsim_type) == "db"} {
     exec cp $WORKING/$i.sqldef /tmp/facilitydb-mysql/$i-createtable.sql
     set fout [open /tmp/facilitydb-mysql/$i.sql w]
     simulateperiod $fout $i $start $end $DELTASECS($subsys)
     close $fout
     puts stdout "Created INSERT for $i<BR>"
   } else {
     puts stdout "Selected option not available for $FormData(dbsim_stream$n)<BR>"
   }
 }
 if { [info exists FormData(dbsim_cmd$n)] } {
   puts stdout "Selected command simulation not available for $FormData(dbsim_stream$n)<BR>"
 }
 if { [info exists FormData(dbsim_log$n)] } {
   puts stdout "Selected logging simulation not available for $FormData(dbsim_stream$n)<BR>"
 }
 incr n 1
}

cd /tmp
if { $FormData(dbsim_type) == "sql" } {
   exec tar czf /var/www/html/downloads/facilitydb-mysql.tar.gz facilitydb-mysql
   puts stdout "</UL><P><HR><P>
<H2>Facility Database Simulation - Downloads</H2>
<UL>This archive contains Mysql INSERT files.<P>
<TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightGreen  WIDTH=400>
<TR><TD>Archive size</TD><TD>
[file size /var/www/html/downloads/facilitydb-mysql.tar.gz] bytes</TD></TR>
<TR><TD>Archive type</TD><TD>Gzip compressed Tar format</TD></TR>
<TR><TD>Language</TD><TD>SQL (Mysql compatible)</TD></TR>
<TR><TD>Download link</TD><TD>
<A HREF=\"/downloads/facilitydb-mysql.tar.gz\">facilitydb-mysql.tar.gz</A>
</TD></TR></TABLE></UL><P><HR><P>"

}

if { $FormData(dbsim_type) == "db" } {
   puts stdout "</UL><P><HR><P>
<H2>Facility Database Simulation - Database insert</H2><P><UL>"
  cd facilitydb-mysql
  set tables [glob *-createtable.sql]
  foreach i $tables {
    puts stdout "Processing $i<BR>"
    if { $FormData(dbsim_pass) != "" } {
       set ok [catch {exec /usr/bin/mysql -h $FormData(dbsim_host) -u $FormData(dbsim_user) -p $FormData(dbsim_pass) $FormData(dbsim_name) < $i } result]
    } else {
       set ok [catch {exec /usr/bin/mysql -h $FormData(dbsim_host) -u $FormData(dbsim_user) $FormData(dbsim_name) < $i } result]
    }
    puts stdout "$result<BR>"
    exec rm -f $i
  }
  set inserts [exec *.sql]
  foreach i $inserts {
    puts stdout "Processing $i<BR>"
    if { $FormData(dbsim_pass) != "" } {
       set ok [catch {exec /usr/bin/mysql -h $FormData(dbsim_host) -u $FormData(dbsim_user) -p $FormData(dbsim_pass) $FormData(dbsim_name) < $i } result]
    } else {
       set ok [catch {exec /usr/bin/mysql -h $FormData(dbsim_host) -u $FormData(dbsim_user) $FormData(dbsim_name) < $i } result]
    }
    puts stdout "$result<BR>"
  }
}


puts stdout "</UL><P><HR><P></BODY></HTML>"


