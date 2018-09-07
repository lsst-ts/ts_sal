#!/usr/bin/env tclsh


set ftcl [open svcSAL_tclAccess.c w]
set finc [open svcSAL_tclAccess.h w]

puts $finc "int updateVariables(Tcl_Interp *interp, char *subsysid, int *shmdata_ref);
int readVariables(Tcl_Interp *interp, char *subsysid, int *shmdata_ref);"

set incs [glob *_cache.h]
foreach f $incs {
   if { [file size $f] != 0 } {
      puts $ftcl "#include \"$f\""
   }
}
puts $ftcl "#include \"tcl.h\"
#include <string.h>
#include \"svcSAL_tclAccess.h\"

int updateVariables(Tcl_Interp *interp, char *subsysid, int *shmdata_ref)
\{
    char *text;
    char newName\[64\];
    int iterator;"
set incs [glob shm_tcl_*.c]
foreach f $incs {
   if { [file size $f] != 0 } {
      set fcp [open $f r]
      while { [gets $fcp rec] > -1 } {
         puts $ftcl $rec
      }
      close $fcp
      puts stdout "Added $f to shm_tcl.c"
   }
}

puts $ftcl "
    return TCL_OK;
\}"
puts $ftcl "

int readVariables(Tcl_Interp *interp, char *subsysid, int *shmdata_ref)
\{
"
set incs [glob shmrd_tcl_*.c]
foreach f $incs {
  set subsys [string range [file rootname [file tail $f]] 10 end]
  puts $finc "int shm_tcl_get_$subsys ( Tcl_Interp *interp, char *subsysid, int *shmdata_ref );"
  puts $ftcl "
    if (strcmp(subsysid,\"$subsys\") == 0) \{
      shm_tcl_get_$subsys ( interp, subsysid, shmdata_ref );
    \}
"
}
puts $ftcl "
    return TCL_OK;
\}"


set incs [glob shmrd_tcl_*.c]
foreach f $incs {
   if { [file size $f] != 0 } {
      set fcp [open $f r]
      while { [gets $fcp rec] > -1 } {
         puts $ftcl $rec
      }
      close $fcp
      puts stdout "Added $f to shm_tcl.c"
   }
}

close $ftcl
close $finc

