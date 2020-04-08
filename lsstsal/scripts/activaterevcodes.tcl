#!/usr/bin/env tclsh

set SAL_WORK_DIR $env(SAL_WORK_DIR)

proc updateRevCodes { subsys } {
global SAL_WORK_DIR REVCODE
  set lidl [glob $SAL_WORK_DIR/idl-templates/validated/[set subsys]_*.idl]
  set fmd5 [open $SAL_WORK_DIR/idl-templates/validated/[set subsys]_revCodes.tcl w]
  foreach i [lsort $lidl] {
    set c [lindex [exec md5sum $i] 0]
    set s [file tail [file rootname $i]]
    puts $fmd5 "set REVCODE($s) [string range $c 0 7]"
    set REVCODE($s) [string range $c 0 7]
  }
  close $fmd5
}


proc getItemName { rec } {
  if { [lindex $rec 0] == "unsigned" } { set rec [lrange $rec 1 end] }
  if { [lindex $rec 1] == "long" } { set rec [lrange $rec 1 end] }
  set item [string trim [lindex [split [lindex $rec 1] "\[\];"] 0]]
  return $item
}


proc activeRevCodes { subsys } {
global SAL_WORK_DIR REVCODE OPTIONS SALVERSION
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> activeRevCodes $subsys"}
  set fin [open $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl r]
  set fout [open $SAL_WORK_DIR/idl-templates/validated/sal/sal_revCoded_[set subsys].idl w]
  set fpyb [open $SAL_WORK_DIR/include/SAL_[set subsys]_salpy_units.pyb3 w]
  set xmlversion [exec cat $SAL_WORK_DIR/VERSION]
  puts $fout "// SAL_VERSION=$SALVERSION XML_VERSION=$xmlversion"
  gets $fin rec ; puts $fout $rec
  while { [gets $fin rec] > -1 } {
    set r2 [string trim $rec "{}"]
    set r3 [string trim $rec " 	{};"]
    if { $r3 == "" } {
      puts $fout $rec
    } else {
     if { [lindex $r2 0] == "struct" } {
       set curtopic [set subsys]_[lindex $r2 1]
       set id [lindex $r2 1]
       set desc ""
       catch { set desc [string trim [lindex [split [exec grep "###Description $curtopic :" $SAL_WORK_DIR/sql/[set subsys]_items.sql] ":"] 1]] }
       if { $id != "command" && $id != "logevent" } {
         set annot " // @Metadata=(Description=\"$desc\")"
         puts $fout "struct [set id]_[string range [set REVCODE([set subsys]_$id)] 0 7] \{ $annot"
       } else {
         puts $fout $rec
       }
     } else {
       if { [lindex $r2 0] == "#pragma" } {
          set id [lindex $r2 2]
          if { $id != "command" && $id != "logevent" } {
            puts $fout "#pragma keylist [set id]_[string range [set REVCODE([set subsys]_$id)] 0 7] [lrange $rec 3 end]"
          } else {
            puts $fout $rec
          }
       } else {
          set annot ""
          if { $curtopic != "command" && $curtopic != "logevent" } {
           catch {
            if { [lindex [lindex $rec 0] 0] != "const" } {
              set item [getItemName $rec]
              if { $item == "[set subsys]ID" } {
                set annot " // @Metadata=(Description=\"Index number for CSC with multiple instances\")"
              } else {
                set lookup [exec grep "(\"$curtopic\"," $SAL_WORK_DIR/sql/[set subsys]_items.sql | grep ",\"$item\""]
                set ign [string length "INSERT INTO [set subsys]_items VALUES "]
                set mdata [split [string trim [string range "$lookup" $ign end] "();"] ","]
                set annot " // @Metadata=(Units=[lindex $mdata 5],Description=[lindex $mdata 9])"
              }
              puts $fpyb "	m.attr(\"[set curtopic]C_[set item]_units\") = [lindex $mdata 5];"
            }
           }
          }
          if { [string range $annot 0 2] != " //" } { set annot "" }
          puts $fout "$rec[set annot]"
       }
     }
    }
  }
  close $fin
  close $fout
  close $fpyb
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< activeRevCodes $subsys"}
}


proc getRevCode { topic { type "long"} } {
global REVCODE
   if { [llength [split $topic _]] == 2 } {
      set it [lindex [split $topic _] end]
      if { $it == "command" || $it == "logevent" } {
         return ""
      }
   }
   if { $type == "short" } {
     set revcode _[string range [set REVCODE($topic)] 0 7]
   } else {
     set revcode $REVCODE($topic)
   }
   return $revcode
}

proc modidlforjava { subsys } {
global SAL_WORK_DIR REVCODE SYSDIC CMD_ALIASES OPTIONS
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> modidlforjava $subsys"}
  stdlog "Updating $subsys idl with revCodes"
  set lc [exec wc -l $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl]
  set lcnt [expr [lindex $lc 0] -2]
  set fin [open $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl r]
  exec rm -f $SAL_WORK_DIR/[set subsys]/java/sal_[set subsys].idl
  set fout [open $SAL_WORK_DIR/[set subsys]/java/sal_[set subsys].idl w]
  set ln 0
  while { $ln < $lcnt} {
     gets $fin rec ; puts $fout $rec
     incr ln 1
  }
  close $fin
  set fin [open $SAL_WORK_DIR/idl-templates/validated/sal/sal_revCoded_[set subsys].idl r]
  gets $fin rec; gets $fin rec
  set done 0
  while { [gets $fin rec] > -1 } {
     set chk [lindex [split $rec "\{\}\""] 0]
     if { [lindex  $chk 0] != "const" } {
        puts $fout $rec
     }
  }
  close $fin
  close $fout
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< modidlforjava $subsys"}
}





