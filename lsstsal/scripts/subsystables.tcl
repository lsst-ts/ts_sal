#!/usr/bin/env tclsh


set fout [open subsystables.sqldef w]
set all [lsort [glob *.idl]]
foreach i $all {
    set subsys [file rootname $i]
    set sys [lindex [split $subsys _] 0]
    set S($sys) 1
    puts $fout "insert into RTIDDS_SUBSCRIPTIONS (table_owner,table_name,domain_id,topic_name,type_name) values ('lsstFacility','$sys',0,'$sys [set subsys]','[set subsys]');"
}

close $fout

foreach s [lsort [array names S]] {puts stdout $s}
