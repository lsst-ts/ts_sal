#!/usr/bin/env tclsh

set scriptdir $env(SAL_DIR)

source $scriptdir/datastream_desc.tcl
source $scriptdir/camera-subsysdesc.tcl
source $scriptdir/streamutils.tcl
source $scriptdir/subsystems.tcl

set all [lsort $COMMANDABLE]
foreach i $all {
  set subsys [file rootname $i]
  set topic [set subsys]_command
  set fout [open $topic.idl w]
  idlpreamble $fout [set subsys]_command
  puts $fout "  long		cmdID;
  string<16>	device;
  string<16>	operation;
  string<16>	value;
  string<128>	modifiers;
\};"
  close $fout
  set topic [set subsys]_ackcmd
  set fout [open $topic.idl w]
  idlpreamble $fout [set subsys]_ackcmd
  puts $fout "  long		cmdID;
  string<16>	ack;
  string<16>	error;
  long		timeout;
  short		repeat;
  short		submits;
  string<64>	result;
\};"
  close $fout
}


