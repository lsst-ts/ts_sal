#!/usr/bin/env tclsh

set fin [open $WORKING/datastreams.detail r]
while { [gets $fin rec] > -1 } {
  set s [join [lrange [split [lindex $rec 0] .] 0 1] _]
  set f($s) [lindex $rec 3]
}
close $fin
set fout [open $WORKING/datastreams.freqs w]
foreach i [lsort [array names f]] {
  puts $fout "set FREQUENCY($i) $f($i)"
}
close $fout
