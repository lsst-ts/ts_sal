#!/usr/bin/env tclsh

proc tidysqllog { t f } {
   set fin [open $f r]
   set fout [open $f.log a]
   while { [gets $fin rec]  > -1 } {
      if { [lindex $rec 0] != "date_time" } {
          set k [lrange $rec 0 1]
          set bulk [lrange $rec 2 end]
          puts $fout "$k $t $bulk"
      }
   }
   close $fin
   close $fout
}

set BLACKLIST(tcs_logevent_Heartbeat) 1
set BLACKLIST(tcs_logevent_InternalCommand) 1

set subsys "archiver camera tcs"
foreach s $subsys {lappend cmdtables [set s]_commandLog}

set atables [exec mysql -B  --user=efduser --password=lssttest --socket=/efd_nvme/mysql/mysql.sock EFD -e "show tables;"]
foreach t $atables { 
  foreach s $subsys {
    set key [set s]_logevent
    set lk [expr [string length $key] -1]
    if { [string range $t 0 $lk] == $key } {
       lappend eventtables $t
    }
 }
}

set fin [open $argv r]

while { [gets $fin rec] > -1 } {
   set name [lindex $rec 0]
   puts stdout "Processing $name"
   set start [lindex $rec 1]
   set endt [lindex $rec 2]
   catch { exec rm [set name].history }
   foreach t $cmdtables {
     if { [info exists BLACKLIST($t)] == 0 } {
      set fout [open [set name].sql w]
      puts $fout "select * from $t where private_sndStamp > $start and private_sndStamp < $endt;"
      close $fout
      puts stdout "Running query for $t $name"
      exec mysql -B --user=efduser --password=lssttest  --socket=/efd_nvme/mysql/mysql.sock EFD < [set name].sql > [set name].history
      tidysqllog $t [set name].history
     }
   }
   foreach t $eventtables {
     if { [info exists BLACKLIST($t)] == 0 } {
      set fout [open [set name].sql w]
      puts $fout "select * from $t where private_sndStamp > $start and private_sndStamp < $endt;"
      close $fout
      puts stdout "Running query for $t $name"
      exec mysql -B --user=efduser --password=lssttest  --socket=/efd_nvme/mysql/mysql.sock EFD < [set name].sql > [set name].history
      tidysqllog $t [set name].history
     }
   }
   exec sort -u [set name].history.log > [set name].log
}
close $fin


