#
#  Generic utility procedures used in SAL suite of programs
#
set TDEPTH 0

proc errorexit { msg {id -1} } {
global SAL_LOG
  if { [info exists SAL_LOG(fd)] } {
     puts $SAL_LOG(fd) "FATAL ERROR : $msg"
     close $SAL_LOG(fd)
  }
  puts stdout "*******************************************************************************"
  puts stdout "***       ERROR : $msg"
  puts stdout "*******************************************************************************"
  exit $id
}

proc stdlog { msg {verbosity 9} } {
global SAL_LOG TDEPTH
  if { [string range $msg 0 10] == "###TRACE>>>" } { incr TDEPTH 2 }
  if { [string range $msg 0 10] == "###TRACE<<<" } { incr TDEPTH -2 }
  if { [info exists SAL_LOG(fd)] } {
     puts $SAL_LOG(fd) "[string repeat "#" $TDEPTH]$msg"
  }
  puts stdout "[string repeat "#" $TDEPTH]$msg"
}

proc clearAssets { subsys } {
global SAL_WORK_DIR SALVERSION OPTIONS
   set res ""
   if { $OPTIONS(verbose) } {stdlog "###TRACE>>> clearAssets $subsys"}
   if { $OPTIONS(cpp) } {
       catch {
         set files [glob $SAL_WORK_DIR/[set subsys]/cpp]
         foreach i $files { exec rm -fr $i }
         set files [glob $SAL_WORK_DIR/[set subsys]_*/cpp]
         foreach i $files { exec rm -fr $i }
             } res
   }
   if { $OPTIONS(idl) } {
       catch {
         exec rm -f $SAL_WORK_DIR/[set subsys]/sal_revCoded_[set subsys].idl
             } res
   }
   if { $OPTIONS(java) } {
       catch {
         set files [glob $SAL_WORK_DIR/[set subsys]/java]
         foreach i $files { exec rm -fr $i }
         set files [glob $SAL_WORK_DIR/[set subsys]_*/java]
         foreach i $files { exec rm -fr $i }
         exec rm -fr $SAL_WORK_DIR/maven/[set subsys]_[set SALVERSION]
             } res
   }
   if { $OPTIONS(labview) } {
       catch { exec rm -fr [set subsys]/labview } res
   }
   if { $OPTIONS(lib) } {
       catch {
         exec rm -f $SAL_WORK_DIR/lib/libsacpp_[set subsys]_types.so
         exec rm -f $SAL_WORK_DIR/lib/libSAL_[set subsys].so
         exec rm -f $SAL_WORK_DIR/lib/SALLV_[set subsys].so
         exec rm -f $SAL_WORK_DIR/lib/SALPY_[set subsys].so
         exec rm -f $SAL_WORK_DIR/lib/saj_[set subsys]_types.jar
             } res
   }
   if { $OPTIONS(verbose) } {stdlog "###TRACE<<< clearAssets $subsys"}
}

proc checkAssets { subsys } {
global SAL_WORK_DIR OPTIONS CMD_ALIASES EVENT_ALIASES TLM_ALIASES
   if { $OPTIONS(verbose) } {stdlog "###TRACE>>> checkAssets $subsys"}
   if { $OPTIONS(idl) } {
        checkFileAsset $SAL_WORK_DIR/[set subsys]/sal_revCoded_[set subsys].idl
   }
   if { $OPTIONS(cpp) } {
        checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/libsacpp_[set subsys]_types.so
        checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys].cpp
        checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys].h
        checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]C.h
        if { [info exists CMD_ALIASES($subsys)] } {
             checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/sacpp_[set subsys]_all_commander
             checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/sacpp_[set subsys]_all_controller
        }
        if { [info exists EVENT_ALIASES($subsys)] } {
             checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/sacpp_[set subsys]_all_sender
             checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/sacpp_[set subsys]_all_logger
        }
        if { [info exists TLM_ALIASES($subsys)] } {
             checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/sacpp_[set subsys]_all_publisher
             checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/sacpp_[set subsys]_all_subscriber
        }
   }
   if { $OPTIONS(java) } {
        checkFileAsset $SAL_WORK_DIR/[set subsys]/java/saj_[set subsys]_types.jar
        checkFileAsset $SAL_WORK_DIR/[set subsys]/java/src/org/lsst/sal/SAL_[set subsys].java
   }
   if { $OPTIONS(python) } {
        checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/SALPY_[set subsys].so
   }
   if { $OPTIONS(labview) } {
        checkFileAsset $SAL_WORK_DIR/[set subsys]/labview/SALLV_[set subsys].so
        checkFileAsset $SAL_WORK_DIR/[set subsys]/labview/SALLV_[set subsys]_Monitor
        checkFileAsset $SAL_WORK_DIR/[set subsys]/labview/sal_[set subsys].idl
        checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]LV.h
   }
   if { $OPTIONS(verbose) } {stdlog "###TRACE<<< checkAssets $subsys $language "}
}

proc checkFileAsset { fname } {
  if { [file exists $fname] == 0 } { errorexit "Failed to generate $fname" 1 }
  if { [file size $fname] == 0 } { errorexit "Failed to generate $fname - size=0" 1 }
}

proc getAlias { topic } {
   set stopic [split $topic "_"]
   if { [lindex $stopic 1] != "command" && [lindex $stopic 1] != "logevent" } {
      set alias [join [lrange $stopic 1 end] _]
   } else {
      set alias [join [lrange $stopic 2 end] _]
   }
}


proc skipPrivate { fidl } {
  foreach i "1 2 3 4 5 6 7 8" {gets $fidl rec}
}


proc getTopicNames { subsys {type all} } {
global SAL_WORK_DIR
  switch $type {
     command {
          set res [split [exec grep "pragma keylist command_" $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl] \n]
             }
     logevent {
          set res [split [exec grep "pragma keylist logevent_" $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl] \n]
             }
     all {
          set res [split [exec grep pragma $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl] \n]
             }
  }
  foreach i $res { lappend names [lindex $i 2] }
  return [lsort $names]
}

proc getTopicURL  { base topic } {
  set anchor [string tolower [lindex [split $topic _] end]]
  set linktext [set base]_[join [lrange [split $topic _] 0 end] _]
  set url "<A HREF=https://ts-xml.lsst.io/sal_interfaces/[set base].html#[set anchor]>$linktext</A>" 
}


proc updateMetaData { subsys } {
global METADATA SAL_WORK_DIR
  set fmeta [open $SAL_WORK_DIR/idl-templates/validated/[set subsys]_metadata.tcl w]
  foreach i [lsort [array names METADATA]] {
     puts $fmeta "set METADATA($i) \"$METADATA($i)\""
  }
  close $fmeta
}

proc doxygenateIDL { cscidl dcscidl } {
  set fin [open $cscidl r]
  set fout [open $dcscidl w]
  while { [gets $fin rec] > -1 } {
     if { [llength [split $rec "@"]] > 1 && [string range $rec 0 5] != "struct"} {
       set spl [split $rec "="]
       set desc [string trim [lindex [split $rec "="] end] "\");"]
       puts $fout "/// [getItemName $rec] - $desc"  
     }
     puts $fout $rec
  }
  close $fin
  close $fout
}





