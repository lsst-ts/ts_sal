#!/usr/bin/env tclsh

#
# Step 1 : Modify datastreams.detail as necessary (web tools)
#      1a: or cat baseline_sep08.detail */*.detail > datastreams.detail
# Step 2 : ./genidlshmem.tcl to .idl and .sqldef files per topic
# Step 3 : ./genshmem.tcl [subsys] to generate c libraries/apps
# Step 4 : ./genshmtcl.tcl to generate tcl test code
# Step 5 : make ; touch Shared/*.o ; make to lib libshm.so
#

proc olddoitem { fid fo2 name type } {
global ITEMLIST
   switch $type {
       string -
       String { puts $fid "  string<32> $name;" 
                puts $fo2 "  $name char(32),"
                set ITEMLIST "$ITEMLIST,char.$name"
              }
       longlong    { puts $fid "  long $name;" 
                puts $fo2 "  $name bigint,"
                set ITEMLIST "$ITEMLIST,longlong.$name"
              }
       int    -
       long   -
       Int    { puts $fid "  long $name;" 
                puts $fo2 "  $name int,"
                set ITEMLIST "$ITEMLIST,int.$name"
              }
       short  -
       Short  { puts $fid "  short $name;" 
                puts $fo2 "  $name smallint,"
                set ITEMLIST "$ITEMLIST,short.$name"
              }
       char   -
       Char   {
                puts $fid "  string<32> $name;"
                puts $fo2 "  $name char(32),"
                set ITEMLIST "$ITEMLIST,char.$name"
              }
       byte   -
       Byte   { puts $fid "  octet $name;"
                puts $fo2 "  $name tinyint,"
                set ITEMLIST "$ITEMLIST,byte.$name"
              }
       boolean   -
       bool   { puts $fid "  boolean $name;"
                puts $fo2 "  $name tinyint,"
                set ITEMLIST "$ITEMLIST,boolean.$name"
              }
       float  -
       Float  { puts $fid "  float $name;" 
                puts $fo2 "  $name float," 
                 set ITEMLIST "$ITEMLIST,float.$name"
              }
       double -
       Double { puts $fid "  double $name;" 
                puts $fo2 "  $name double," 
                set ITEMLIST "$ITEMLIST,double.$name"
               }
   }
}

proc expanditem { fo2 name type nd } {
   set i 1
   while { $i <= $nd } {
      puts $fo2 "  [set name]_[set i] [set type],"
      incr i 1
   }
}


proc nditem { fid fo2 name type nd } {
global ITEMLIST
   switch $type {
       string -
       String { puts $fid "  string<$nd> $name;" 
                puts $fo2 "  $name varchar($nd),"
                set ITEMLIST "$ITEMLIST,char.$name"
              }
       int    -
       long   -
       Int    { puts $fid "  long $name\[$nd\];" 
                expanditem $fo2 $name int $nd ; set ITEMLIST "$ITEMLIST,int.[set name].$nd"
              }
       longlong    { puts $fid "  longlong $name\[$nd\];" 
                expanditem $fo2 $name bigint $nd ; set ITEMLIST "$ITEMLIST,longlong.[set name].$nd"
              }
       short  -
       Short  { puts $fid "  short $name\[$nd\];" 
                expanditem $fo2 $name smallint $nd ; set ITEMLIST "$ITEMLIST,short.[set name].$nd"
              }
       char   -
       Char   {
                puts $fid "  string<$nd> $name;"
                puts $fo2 "  $name varchar($nd)," ; set ITEMLIST "$ITEMLIST,char.[set name].$nd"
              }
       byte   -
       Byte   { puts $fid "  octet $name\[$nd\];"
                expanditem $fo2 $name tinyint $nd ; set ITEMLIST "$ITEMLIST,byte.[set name].$nd"
              }
       boolean   -
       bool   { puts $fid "  boolean $name\[$nd\];"
                expanditem $fo2 $name tinyint $nd ; set ITEMLIST "$ITEMLIST,boolean.[set name].$nd"
              }
       float  -
       Float  { puts $fid "  float $name\[$nd\];" 
                expanditem $fo2 $name $type $nd ; set ITEMLIST "$ITEMLIST,float.[set name].$nd"
               }
       double -
       Double { puts $fid "  double $name\[$nd\];" 
                expanditem $fo2 $name $type $nd  ; set ITEMLIST "$ITEMLIST,double.[set name].$nd"
               }
   }
}

source $env(SAL_DIR)/streamutils.tcl
set defdir .salwork
set last ""
set hasindex 0
set ITEMLIST ""
set flog [open /tmp/salhtml.log w]
set fin [open $defdir/datastreams.detail r]
set fsum [open $defdir/datastreams.names w]
while { [gets $fin rec] > -1 } {
   if { [string range $rec 0 5] == "#index" } {
      set ki [lindex $rec 1]
      gets $fin rec
      set d [split [lindex $rec 0] "./_"]
      set ncmp [expr [llength $d] -2]
      if { $ncmp < 0}  {set ncmp 0}
      set id [join [lrange $d 0 $ncmp] _]
      set keyindex($id) $ki
   }
   set id [lindex $rec 0]
   set topic [lindex $rec 0]
   if { $id != $last } {
      if { $last != "" } {puts $fsum $last}
      catch { 
###puts $fout "\};"
###              close $fout
              if { [info exists keyindex($last)] } {
                puts $fo2 "  PRIMARY KEY (date_time,$keyindex($last))"
              } else {
                puts $fo2 "  PRIMARY KEY (date_time)"
              }
              puts $fo2 ");"
              close $fo2
              puts $fo3 "set SQLREC($last) \"$ITEMLIST\""
              close $fo3
            }
      set last $id
###      set fout [open $id.idl w]
      set fo2  [open $id.sqldef w]
      set fo3  [open $id.sqlwrt w]
###      puts $fout "struct $topic \{
###  string<32> private_revCode; //private
###  double private_sndStamp; //private
###  double private_rcvStamp; //private
###  long private_seqNum; //private
###  long private_origin; //private
###  long private_host; //private"
      puts $fo2  "DROP TABLE IF EXISTS $topic;"
      puts $fo2  "CREATE TABLE $topic ("
      puts $fo2  "  date_time DATETIME(6),
  private_revCode char(32),
  private_sndStamp double precision,
  private_rcvStamp double precision,
  private_seqNum int,
  private_origin int,
  private_host int,"
      set ITEMLIST "char.private_revCode,double.private_sndStamp,double.private_rcvStamp,int.private_seqNum,int.private_origin,int.private_host"
      set nsub [lindex [split $topic _] 0]
      if { [info exists SYSDIC([set nsub],keyedID)] } {
         puts $fo2 "  [set nsub]ID int,"
         set ITEMLIST "$ITEMLIST,int.[set nsub]ID"
      }
   }
   set name [lindex [split [lindex $rec 1] .] end]
   set type [lindex $rec 3]
   if { [lindex $rec 2] > 1 } {
      set nd [lindex $rec 2]
#puts stdout "nditem $fout $fo2 $name $type $nd"
      if { [string range $type 0 5] == "string" } { set type string }
      nditem $flog $fo2 $name $type $nd
   } else {
#puts stdout "olddoitem $fout $fo2 $name $type"
      olddoitem $flog $fo2 $name $type
   }
   puts $flog "Added $name to $topic"
}

###puts $fout "\};"
###close $fout
if { [info exists keyindex($last)] } {
 puts $fo2 "  PRIMARY KEY (date_time,$keyindex($last))"
} else {
  puts $fo2 "  PRIMARY KEY (date_time)"
}
puts $fo2 ");"
close $fo2
puts $fo3 "set SQLREC($last) \"$ITEMLIST\""
close $fo3
     
close $flog


close $fsum
set lidl [glob $SAL_WORK_DIR/idl-templates/validated/*.idl]
set fmd5 [open .salwork/revCodes.tcl w]
foreach i [lsort $lidl] {
  set c [lindex [exec md5sum $i] 0]
  set s [file tail [file rootname $i]]
  puts $fmd5 "set REVCODE($s) $c"
}
close $fmd5


