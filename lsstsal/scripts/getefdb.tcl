#!/usr/bin/env tclsh
#
# freq selected from 0.001 0.01 0.03 0.1 0.2 1 10 20 30
set SAL_DIR $env(SAL_DIR)
set start [lindex $argv 0]
set end   [lindex $argv 1]
set freq [lindex $argv 2]
puts stdout "EFDB creation for topics with frequency = $freq"
set interval [expr int(1.0/$freq)]
if { $interval == 0 } {set interval [string range [expr 1.0/$freq] 0 3]}
puts stdout "From $start to $end every $interval secs"

source $SAL_DIR/datastreams.freqs
set all [lsort [glob *.idl]]

foreach topic $all {
   set t [file rootname $topic]
   set fullt $t
   if { [info exists FREQUENCY($t)] } {set dofreq $FREQUENCY($t)}
   set t [join [lrange [split $topic _] 0 1] _]
   if { [info exists FREQUENCY($t)] } {set dofreq $FREQUENCY($t)}
   if { $dofreq == $freq } {
      puts stdout "Processing $topic"
      set target [join [split ./sql/$fullt-[set start]_to_[set end].sql " "] -]
      if { [file exists $target] } {
        puts stdout "$target already exists"
      } else {
        puts stdout [exec date]
        set doit [open /tmp/gendb w]
        puts $doit  "salgenerator $topic db $start $end $interval"
        close $doit
        exec chmod 755 /tmp/gendb
        exec /tmp/gendb
        puts stdout [exec date]
      }
   }
}



