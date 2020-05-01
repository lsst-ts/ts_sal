proc calcshmid { subsys } {
  set fout [open /tmp/subsys.tmp w]
  puts $fout "$subsys"
  close $fout
  set id [string range [exec md5sum /tmp/subsys.tmp] 0 3]
  return $id
}

if { [file exists $env(SAL_WORK_DIR)/SALSubsystems.xml] } {
   source $env(SAL_DIR)/update_ts_xml_dictionary.tcl
   parseSystemDictionary
} else {
   puts stdout "
*******************************************************************************
****************** WARNING - missing dictionary *******************************
*******************************************************************************

	$env(SAL_WORK_DIR)/SALSubsystems.xml not found

 	Please copy it from the ts_xml installation

*******************************************************************************
*******************************************************************************"

  exit 7
}

set SYSDIC(datatypes) "byte short int long float string int64 double ubyte ushort uint ulong"




