#!/usr/bin/tcldsh
#
#  Using mysqltcl interface:
#
load /usr/lib64/tcl8.5/mysqltcl-3.052/libmysqltcl3.052.so
set efd [mysqlconnect -host localhost -user efduser -password lssttest -db EFD]
mysqlinfo $efd tables
set x [mysqlsel $efd "SELECT * FROM archiver_commandLog" -list]
set y [mysqlsel $efd "SELECT * FROM archiver_commandLog ORDER BY date_time LIMIT 10" -list]
mysqlclose $efd 

