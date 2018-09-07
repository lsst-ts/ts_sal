#!/usr/bin/env tclsh

puts stdout "Removing old idl-templates"
exec rm -fr idl-templates

source $env(SAL_DIR)/add_system_dictionary.tcl 
foreach subsys $SYSDIC(systems) {
   catch {
      set x [glob $subsys*.xml]
      set DO($subsys) 1
   } else {
     puts stdout "No definitions for $subsys"
   }
}

puts stdout  "Validating interfaces"
foreach subsys $SYSDIC(systems) {
  if { [info exists DO($subsys)] } {
   set bad ""
   set result ""
   catch { set results [exec salgenerator $subsys validate ] } bad
   puts stdout "$result $bad"
   set bad ""
   set result ""
   catch {exec salgenerator $subsys html}
   puts stdout "$result $bad"
  }
}

puts stdout  "Generating C++"
foreach subsys $SYSDIC(systems) {
  if { [info exists DO($subsys)] } {
   set bad ""
   set result ""
   catch { set results [exec salgenerator $subsys sal cpp ] } bad
   puts stdout "$result $bad"
  }
}

puts stdout  "Generating Python"
foreach subsys $SYSDIC(systems) {
  if { [info exists DO($subsys)] } {
   set bad ""
   set result ""
   catch { set results [exec salgenerator $subsys sal python ] } bad
   puts stdout "$result $bad"
  }
}

puts stdout  "Generating LabVIEW"
foreach subsys $SYSDIC(systems) {
  if { [info exists DO($subsys)] } {
   set bad ""
   set result ""
   catch { set results [exec salgenerator $subsys labview ] } bad
   puts stdout "$result $bad"
  }
}

puts stdout  "Generating Java"
foreach subsys $SYSDIC(systems) {
  if { [info exists DO($subsys)] } {
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

source $env(SAL_DIR)/gengenericefd.tcl
set bad ""
set result ""
catch { set results [updateefdschema] } bad
puts stdout "$result $bad"





