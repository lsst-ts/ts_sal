#!/usr/bin/env tclsh
## \file utilities.tcl
# \brief Generic utility procedures used in SAL suite of programs
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code
set TDEPTH 0

#
## Documented proc \c errorexit .
# \param[in] msg Error message
# \param[in] id Optional error code
#
#  General exit code manager
#
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

#
## Documented proc \c stdlog .
# \param[in] msg Error message
# \param[in] verbosity Optional verbosity
#
#  General logging routine
#
proc stdlog { msg {verbosity 9} } {
global SAL_LOG TDEPTH
  if { [string range $msg 0 10] == "###TRACE>>>" } { incr TDEPTH 2 }
  if { [string range $msg 0 10] == "###TRACE<<<" } { incr TDEPTH -2 }
  if { [info exists SAL_LOG(fd)] } {
     puts $SAL_LOG(fd) "[string repeat "#" $TDEPTH]$msg"
  }
  puts stdout "[string repeat "#" $TDEPTH]$msg"
}

#
## Documented proc \c clearAssets .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Clean up SAL generated files
#
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
         exec rm -f $SAL_WORK_DIR/lib/saj_[set subsys]_types.jar
             } res
   }
   if { $OPTIONS(verbose) } {stdlog "###TRACE<<< clearAssets $subsys"}
}

#
## Documented proc \c checkAssets .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Check for SAL generated files expected as salgenerator output
#
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
   if { $OPTIONS(labview) } {
        checkFileAsset $SAL_WORK_DIR/[set subsys]/labview/SALLV_[set subsys].so
        checkFileAsset $SAL_WORK_DIR/[set subsys]/labview/SALLV_[set subsys]_Monitor
        checkFileAsset $SAL_WORK_DIR/[set subsys]/labview/sal_[set subsys].idl
        checkFileAsset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]LV.h
   }
   if { $OPTIONS(verbose) } {stdlog "###TRACE<<< checkAssets $subsys"}
}

#
## Documented proc \c checkFileAsset .
# \param[in] fname Name of file to check for
#
#  Check for named file expected as salgenerator output
#
proc checkFileAsset { fname } {
  if { [file exists $fname] == 0 } { errorexit "Failed to generate $fname" 1 }
  if { [file size $fname] == 0 } { errorexit "Failed to generate $fname - size=0" 1 }
}

#
## Documented proc \c getAlias .
#  \param[in] topic Name of SAL Topic
#
#  Return the bare Topic name
#
proc getAlias { topic } {
   set stopic [split $topic "_"]
   if { [lindex $stopic 1] != "command" && [lindex $stopic 1] != "logevent" } {
      set alias [join [lrange $stopic 1 end] _]
   } else {
      set alias [join [lrange $stopic 2 end] _]
   }
}


#
## Documented proc \c skipPrivate .
#  \param[in] fidl File handle of input IDL file
#
#  Skip private_ items when reading IDL files
#
proc skipPrivate { fidl } {
  foreach i "1 2 3 4 5 6 7" {gets $fidl rec}
}

#
## Documented proc \c safeString .
#  \param[input]
#
#  Make an input string safe from tcl parsing
#
proc safeString { input } {
#  set escquote [join [split $input "\""] {\"}]
  set safe [subst -nobackslashes -nocommands -novariables $input ]
  return $safe
}

#
## Documented proc \c getTopicNames .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] type Optional type of Topic to list
#
#  Return list of SAL Topic names for a Subsystem/CSC
#
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

#
## Documented proc \c getTopicURL .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] topic TOpic name
#
#  Retrun URL for doumentation of SAL Topic
#
proc getTopicURL  { base topic } {
  set anchor [string tolower [lindex [split $topic _] end]]
  set linktext [set base]_[join [lrange [split $topic _] 0 end] _]
  set url "<A HREF=https://ts-xml.lsst.io/python/lsst/ts/xml/data/sal_interfaces/[set base].html#[set anchor]>$linktext</A>"
}


#
## Documented proc \c updateMetaData .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Update the METADATA array contents disk copy
#
proc updateMetaData { subsys } {
global METADATA SAL_WORK_DIR
  set fmeta [open $SAL_WORK_DIR/avro-templates/[set subsys]_metadata.tcl w]
  foreach i [lsort [array names METADATA]] {
     puts $fmeta "set METADATA($i) $METADATA($i)"
  }
  close $fmeta
}

#
## Documented proc \c readMetaData .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Update the METADATA array contents from disk copy
#
proc readMetaData { subsys } {
global METADATA SAL_WORK_DIR
  source $SAL_WORK_DIR/avro-templates/[set subsys]_metadata.tcl
}



#
## Documented proc \c doxygenateIDL .
# \param[in] cscidl Input IDL file
# \param[in] dcscidl Output IDL file
#
#  Add doxygen compatible documentation to an IDL file
#
proc doxygenateIDL { cscidl dcscidl } {
  set fin [open $cscidl r]
  set fout [open $dcscidl w]
  while { [gets $fin rec] > -1 } {
     if { [llength [split $rec "@"]] > 1 && [string range $rec 0 5] != "struct"} {
       set spl [lindex [split $rec ";"] 0]
       set desc [string trim [lindex [split $rec "="] end] "\");"]
       puts $fout "/// [getItemName $spl] - $desc"
     }
     puts $fout $rec
  }
  close $fin
  close $fout
}
