#!/usr/bin/env tclsh

set all $argv

foreach i $all {
   puts stdout "Tidying $i"
   set fin [open $i r]
   set fout [open $i.new w]
   gets $fin rec
   puts $fout $rec
   gets $fin rec ; gets $fin rec ;gets $fin rec ;gets $fin rec ;gets $fin rec
   while { [gets $fin rec] > -1 } {puts $fout $rec}
   close $fin
   close $fout
   exec mv $i.new $i
}


