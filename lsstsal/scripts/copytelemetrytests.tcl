#!/usr/bin/env tclsh

source $env(SAL_DIR)/add_system_dictionary.tcl
foreach SYSDIC(subsystems) {
    set all [glob [set subsys]_*/cpp]
    foreach i $all {
       set tlm [lindex [split $i "/"] 0]
       set top [join [lrange [split $tlm "_"] 1 end] "_"]
       exec cp -v $i/standalone/sacpp_[set subsys]_pub $subsys/cpp/src/sacpp_[set subsys]_[set top]_publisher
       exec cp -v $i/standalone/sacpp_[set subsys]_sub $subsys/cpp/src/sacpp_[set subsys]_[set top]_subscriber
       puts stdout "Done $subsys $top"
    }
}


