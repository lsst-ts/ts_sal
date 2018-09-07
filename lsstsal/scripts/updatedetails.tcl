
set SAL_WORK_DIR $env(SAL_WORK_DIR)

exec mkdir -p $SAL_WORK_DIR/.salwork
set fout [open $SAL_WORK_DIR/.salwork/datastreams.detail w]
set flog [open /tmp/salhtml.log a]
set all [lsort [glob $SAL_WORK_DIR/idl-templates/validated/*.detail]]
foreach s $all {
  set id [file rootname [file tail $s]]
  set fin [open $s r]
  while { [gets $fin rec] > -1 } {
     puts $fout "$id $rec"
  }
  close $fin
  puts $flog "Added details of $s"
}

close $fout
close $flog

