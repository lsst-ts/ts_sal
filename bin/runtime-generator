#!/usr/bin/env tclsh

set OPTIONS(verbose) 0
set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)

source $env(SAL_DIR)/add_system_dictionary.tcl

set EVERYTHING [lsort $SYSDIC(systems)]
foreach subsys $EVERYTHING {
   catch {
      set x [glob $env(TS_XML_DIR)/python/lsst/ts/xml/data/sal_interfaces/$subsys/$subsys*.xml]
      set DO($subsys) 1
   } else {
     puts stdout "No definitions for $subsys"
   }
}

if { $argv == "" || [lsearch $argv idl] > -1 } {
 puts stdout  "Updating IDL only"
 foreach subsys $EVERYTHING {
  if { [info exists DO($subsys)] && [info exists SYSDIC($subsys,idl)] } {
   set bad ""
   set result ""
   catch { set results [exec salgenerator $subsys sal idl] } bad
   puts stdout "$result $bad"
  }
 }
}


if { $argv == "" || [lsearch $argv validate] > -1} {
  puts stdout  "Validating interfaces"
  foreach subsys $EVERYTHING {
   if { [info exists DO($subsys)] } {
   set bad ""
   set result ""
   catch { set results [exec salgenerator $subsys validate ] } bad
   puts stdout "$result $bad"
   }
  }
}

if { $argv == "" || [lsearch $argv cpp] > -1 } {
 puts stdout  "Generating C++"
 foreach subsys $EVERYTHING {
  if { [info exists DO($subsys)] && [info exists SYSDIC($subsys,cpp)] } {
   set bad ""
   set result ""
   catch { set results [exec salgenerator $subsys sal cpp ] } bad
   puts stdout "$result $bad"
  }
 }
}


if { $argv == "" || [lsearch $argv labview] > -1 } {
 puts stdout  "Generating LabVIEW"
 foreach subsys $EVERYTHING {
  if { [info exists DO($subsys)] && [info exists SYSDIC($subsys,labview)] } {
   set bad ""
   set result ""
   catch { set results [exec salgenerator $subsys labview ] } bad
   puts stdout "$result $bad"
  }
 }
}



if { $argv == "" || [lsearch $argv java] > -1 } {
 puts stdout  "Generating Java"
 foreach subsys $EVERYTHING {
  if { $subsys != "MTMount" } {
   if { [info exists DO($subsys)] && [info exists SYSDIC($subsys,java)] } {
    exec rm -fr [set subsys]/java
    set bad ""
    set result ""
    catch { set results [exec salgenerator $subsys sal java ] } bad
    puts stdout "$result $bad"
    set bad ""
    set result ""
    catch { set results [exec salgenerator $subsys maven ] } bad
    puts stdout "$result $bad"
   }
  }
 }
}

if { $argv == "" || [lsearch $argv lib] > -1 } {
 puts stdout  "Updating libraries"
 foreach subsys $EVERYTHING {
  if { [info exists DO($subsys)] } {
   set bad ""
   set result ""
   catch { set results [exec salgenerator $subsys lib ] } bad
   puts stdout "$result $bad"
  }
 }
}



cd $env(SAL_WORK_DIR)

if { $argv == "" || [lsearch $argv rpm] > -1 } {
 puts stdout  "Updating RPMs"
 foreach subsys $EVERYTHING {
  if { [info exists DO($subsys)] } {
   set bad ""
   set result ""
   catch { set results [exec salgenerator $subsys rpm] } bad
   puts stdout "$result $bad"
  }
 }
}


if { $argv == "" || [lsearch $argv apidoc] > -1 } {
 puts stdout  "Updating Documentation"
 foreach subsys $EVERYTHING {
  if { [info exists DO($subsys)] } {
   set bad ""
   set result ""
   catch { set results [exec salgenerator $subsys apidoc] } bad
   puts stdout "$result $bad"
  }
 }
}
