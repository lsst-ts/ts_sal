

proc genpythonbinding { subsys } {
global SAL_DIR SAL_WORK_DIR SYSDIC VPROPS CMD_ALIASES
  puts stdout "Generating pybind11 bindings"
  set fin  [open $SAL_DIR/code/templates/SALDDS_pybind11.cpp.template r]
  set fout [open $SAL_WORK_DIR/[set subsys]/cpp/src/SALPY_[set subsys].cpp w]
  while { [gets $fin rec] > -1 } {
     puts $fout $rec
     if { [string range $rec 0 29] == "// INSERT_SAL_PYTHON_DATATYPES" } {
        if { [info exists CMD_ALIASES($subsys)] } {
          puts $fout "
    py::class_<SALData_ackcmdC>(m,\"SALData_ackcmdC\" )    
        .def(py::init<>())
        .def_readwrite( \"ack\", &SALData_ackcmdC::ack )    
        .def_readwrite( \"error\", &SALData_ackcmdC::error )    
        .def_readwrite( \"result\", &SALData_ackcmdC::result )    
        .def_readwrite( \"host\", &SALData_ackcmdC::host )    
        .def_readwrite( \"origin\", &SALData_ackcmdC::origin )    
        .def_readwrite( \"cmdtype\", &SALData_ackcmdC::cmdtype )    
        .def_readwrite( \"timeout\", &SALData_ackcmdC::timeout )    
        ;
"
        }
        set fin2 [open $SAL_WORK_DIR/include/SAL_[set subsys]C.pyb r]
        while { [gets $fin2 r2] > -1 } { puts $fout $r2}
        close $fin2
        set fin3 [open $SAL_WORK_DIR/include/SAL_[set subsys]_salpy_units.pyb3 r]
        while { [gets $fin3 r3] > -1 } { puts $fout $r3}
        close $fin3
     }
     if { [string range $rec 0 26] == "// INSERT_SAL_PYTHON_GETPUT" } {
        set fin2 [open $SAL_WORK_DIR/include/SAL_[set subsys]C.pyb2 r]
        while { [gets $fin2 r2] > -1 } { puts $fout $r2}
        close $fin2
     }
     if { [string range $rec 0 25] == "// INSERT CMDALIAS SUPPORT" } {
        gencmdaliascode $subsys python $fout
     }
     if { [string range $rec 0 27] == "// INSERT EVENTALIAS SUPPORT" } {
        geneventaliascode $subsys python $fout
     }
  }
  close $fin
  close $fout
  set frep [open /tmp/sreplace3_[set subsys]py.sal w]
  puts $frep "#!/bin/sh"
  puts $frep "perl -pi -w -e 's/SALData/[set subsys]/g;' $SAL_WORK_DIR/[set subsys]/cpp/src/SALPY_[set subsys].cpp "
  exec touch $SAL_WORK_DIR/[set subsys]/cpp/src/.depend.Makefile.sacpp_SALData_python
  exec cp  $SAL_DIR/code/templates/Makefile.sacpp_SAL_pybind11.template $SAL_WORK_DIR/[set subsys]/cpp/src/Makefile.sacpp_[set subsys]_python
  puts $frep "perl -pi -w -e 's/_SAL_/_[set subsys]_/g;' $SAL_WORK_DIR/[set subsys]/cpp/src/Makefile.sacpp_[set subsys]_python"
  puts $frep "perl -pi -w -e 's/SALSubsys/[set subsys]/g;' $SAL_WORK_DIR/[set subsys]/cpp/src/Makefile.sacpp_[set subsys]_python"
  puts $frep "perl -pi -w -e 's/SALData/[set subsys]/g;' $SAL_WORK_DIR/[set subsys]/cpp/src/Makefile.sacpp_[set subsys]_python"
  if { [info exists SYSDIC($subsys,keyedID)] } {
     puts $frep "perl -pi -w -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g;' $SAL_WORK_DIR/[set subsys]/cpp/src/Makefile.sacpp_[set subsys]_python"
  }
  close $frep
  exec chmod 755 /tmp/sreplace3_[set subsys]py.sal
  catch { set result [exec /tmp/sreplace3_[set subsys]py.sal] } bad
  if { $bad != "" } {puts stdout $bad}
}


