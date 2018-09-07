#!/usr/bin/env tclsh
#
#  Rebuild SAL support for a subsystem from default idl/cmd/evt input
#
set subsys [lindex $argv 0]
puts stdout "Rebuilding SAL support for $subsys subsystem"

set SAL_DIR $env(SAL_DIR)
set OSPL_HOME $env(OSPL_HOME)
set SAL_WORK_DIR [file normalize .]

set oldfiles [glob *$subsys*]
foreach o $oldfiles {
  if { [file exists "$o"] } {
    exec rm -fr $o
  }
}


set idlfiles [lsort [glob $SAL_DIR/idl-templates/validated/[set subsys]_*.idl]]
foreach i $idlfiles {
  exec cp $i .
  puts stdout "Copied $i"
}

if { [file exists $SAL_DIR/cmdevt-templates/command_list_[set subsys]] } {
  exec cp $SAL_DIR/cmdevt-templates/command_list_[set subsys] .
  puts stdout "Copied $SAL_DIR/cmdevt-templates/command_list_[set subsys]"
} else {
  puts stdout "No commands defined for $subsys"
}

if { [file exists $SAL_DIR/cmdevt-templates/event_list_[set subsys]] } {
  exec cp $SAL_DIR/cmdevt-templates/event_list_[set subsys] .
  puts stdout "Copied $SAL_DIR/cmdevt-templates/event_list_[set subsys]"
} else {
  puts stdout "No events defined for $subsys"
}

puts stdout "Validating $subsys ..."
foreach i $idlfiles {
  set l [file tail $i]
  exec salgenerator $l validate
#  exec salgenerator $l html
}

puts stdout "Generating code for $subsys ..."
foreach i $idlfiles {
  set l [file tail $i]
  exec salgenerator $l sal cpp java python
  set id [file rootname $l]
  if { [file exists ./$id/cpp/standalone/sacpp_[set subsys]_pub] } { 
     puts stdout "$l - C++ Publisher 		OK"
  } else {
     puts stdout "$l - C++ Publisher 		ERROR"
  }
  if { [file exists ./$id/cpp/standalone/sacpp_[set subsys]_sub] } { 
     puts stdout "$l - C++ Subscriber 		OK"
  } else {
     puts stdout "$l - C++ Subscriber 		ERROR"
  }
  if { [file exists ./$id/java/standalone/saj_[set id]_pub.jar] } { 
     puts stdout "$l - Java Publisher 		OK"
  } else {
     puts stdout "$l - Java Publisher 		ERROR"
  }
  if { [file exists ./$id/java/standalone/saj_[set id]_sub.jar] } { 
     puts stdout "$l - Java Subscriber 		OK"
  } else {
     puts stdout "$l - Java Subscriber 		ERROR"
  }
}
if { [file exists ./$subsys/cpp/src/sacpp_[set subsys]_cmd] } { 
     puts stdout "$l - C++ Commander 		OK"
} else {
     puts stdout "$l - C++ Commander 		ERROR"
}

if { [file exists ./$subsys/cpp/src/sacpp_[set subsys]_ctrl] } { 
     puts stdout "$l - C++ Command Processor 	OK"
} else {
     puts stdout "$l - C++ Command Processor 	ERROR"
}

if { [file exists ./$subsys/cpp/src/sacpp_[set subsys]_event] } { 
     puts stdout "$l - C++ Event 		OK"
} else {
     puts stdout "$l - C++ Event 		ERROR"
}

if { [file exists ./$subsys/cpp/src/sacpp_[set subsys]_eventlog] } { 
     puts stdout "$l - C++ Log Event 		OK"
} else {
     puts stdout "$l - C++ LogEvent 		ERROR"
}

if { [file exists ./$subsys/java/src/saj_[set subsys]_cmdctl.jar] } { 
     puts stdout "$l - Java Commanding 		OK"
} else {
     puts stdout "$l - Java Commanding 		ERROR"
}

if { [file exists ./$subsys/java/src/saj_[set subsys]_event.jar] } { 
     puts stdout "$l - Java Events 		OK"
} else {
     puts stdout "$l - Java Events 		ERROR"
}


if { [file exists ./$subsys/cpp/src/SALPY_[set subsys].so] } { 
     puts stdout "$l - Python library 		OK"
} else {
     puts stdout "$l - Python library ERROR"
}


