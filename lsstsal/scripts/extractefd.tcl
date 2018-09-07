#!/usr/bin/env tclsh

load /usr/lib64/tcl8.5/mysqltcl-3.052/libmysqltcl3.052.so
set efd [mysqlconnect -host localhost -user efduser -password lssttest -socket /data/mysql/mysql.sock -db EFD]
mysqlinfo $efd tables
set fout [open command_log w]

foreach s $argv { 
   puts stdout "Extracting data for $s"
   set x [mysqlsel $efd "SELECT * FROM [set s]_commandLog" -list]
   foreach i $x {
      set t [lindex $i 2]
      set cmd [lrange $i 4 end]
      puts stdout "$t $s $cmd"
      puts $fout "$t $s $cmd"
   }
}

close $fout

