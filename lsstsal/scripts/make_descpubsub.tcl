#!/usr/bin/env tclsh

set fin [open $env(SAL_WORK_DIR)/.salwork/datastreams.names r]
set fout [open $env(SAL_WORK_DIR)/.salwork/datastreams_desc.pubsub w]
while { [gets $fin rec] > -1 } {
   puts $fout "$rec 1 2"
}
close $fin
close $fout

