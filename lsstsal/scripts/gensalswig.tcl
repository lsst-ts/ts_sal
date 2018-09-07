#!/usr/bin/env tclsh
#
# Generate SALDDS swig input file
# 
# To test : 
#   set SAL_DIR $env(SAL_DIR)
#   set SAL_WORK_DIR $env(SAL_WORK_DIR)
#   set subsys camera
#   source $SAL_WORK_DIR/idl-templates/validated/[set subsys]_cmddef.tcl
#   source $SAL_WORK_DIR/idl-templates/validated/[set subsys]_evtdef.tcl
#   gensalswig $subsys
#

source $env(SAL_DIR)/utilities.tcl
source $env(SAL_DIR)/gencmdaliascode.tcl
source $env(SAL_DIR)/geneventaliascode.tcl


proc addSALDDSswig { idlfile base } {
global SAL_DIR SAL_WORK_DIR SYSDIC
  puts stdout "Configuring [set base]/python/SAL_[set base].i"
  set atypes $idlfile
  set finh [open $SAL_DIR/code/templates/SALDDS.i.template r]
  set fouth [open [set base]/python/SAL_[set base].i w]
  set rec ""
  while { [string range $rec 0 21] != "// INSERT TYPE SUPPORT" } {
       gets $finh rec
       puts $fouth $rec
  }
  foreach i $atypes {
       set ptypes [split [exec grep pragma $i] \n]
           foreach j $ptypes {
              set name [lindex $j 2]        
               puts $fouth "
      salReturn putSample_[set name]([set base]_[set name]C *data);
      salReturn getSample_[set name]([set base]_[set name]C *data);
      salReturn getNextSample_[set name]([set base]_[set name]C *data);
"
       }
  }
  gencmdaliascode $base include $fouth
  geneventaliascode $base include $fouth
  while { [gets $finh rec] > -1 } {puts $fouth $rec}
  close $finh
  close $fouth
}

proc gensalswig { base } {
global SAL_WORK_DIR
  addSALDDSswig $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set base].idl $base
  set frep [open /tmp/sreplace3.sal w]
  puts $frep "#!/bin/sh"
  puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/python/SAL_[set base].i"
  close $frep
  exec chmod 755 /tmp/sreplace3.sal
  catch { set result [exec /tmp/sreplace3.sal] } bad
  set fout [open $SAL_WORK_DIR/[set base]/python/Makefile_[set base].swig w]
  puts $fout "
LINK = \$(CXX) \$(LDFLAGS)
all:
	swig -Wall -c++ -python -I../cpp/src SAL_[set base].i
	g++ -fPIC -Wall -Wextra  -I../cpp -I../cpp/src -I\$(SAL_HOME)/include \\
		-I/cpp/src -I\$(OSPL_HOME)/include/dcps/C++/SACPP \\
		-I/cpp/src -I\$(OSPL_HOME)/include/dcps/C++/CCPP \\
		-I\$(PYTHON_BUILD_LOCATION)/include/python\$(PYTHON_BUILD_VERSION) \\
		-shared SAL_[set base]_wrap.cxx \\
		../cpp/src/SAL_[set base].cpp ../cpp/src/CheckStatus.cpp \\
		-o SALPY_swig_[set base].so \\
		-L\$(OSPL_HOME)/lib -L../cpp \\
		-lsacpp_[set base]_types -ldcpssacpp -ldcpsgapi -lddsuser -lddskernel \\
		-lddsserialization -lddsconfparser -lddsconf -lddsdatabase -lddsutil -lddsos \\
		-ldl  -lpthread \\
		-lpython\$(PYTHON_BUILD_VERSION) -lstdc++
"
  close $fout
  cd $SAL_WORK_DIR/[set base]/python
  exec make -f Makefile_[set base].swig
}





