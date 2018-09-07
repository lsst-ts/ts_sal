#!/usr/bin/env tclsh

proc writeXMLsubsys { dpath subsys {ftype subsystem} } {
global XMLTLM XMLTOPICS XMLITEMS SALVERSION
  exec mkdir -p $dpath
  set fout [open $dpath/[set subsys]_Telemetry.xml w]
  set updatedate [exec date]
  set base [lindex [split $subsys "_"] 0]
  puts $fout "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"http://lsst-sal.tuc.noao.edu/schema/SALTelemetrySet.xsl\"?>
<SALTelemetrySet xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
	xsi:noNamespaceSchemaLocation=\"http://lsst-sal.tuc.noao.edu/schema/SALTelemetrySet.xsd\">"
  foreach i [lsort [array names XMLTOPICS]] {
  puts $fout "<SALTelemetry>
<Subsystem>[set base]</Subsystem>
<Version>$SALVERSION</Version>
<Author>salgenerator</Author>
<EFDB_Topic>[set i]</EFDB_Topic>
<Explanation></Explanation>"
    if { $i != "camera_" } {
      foreach k $XMLITEMS($i) {
       puts $fout "      <item>"
       foreach j "EFDB_Name Description Frequency Publishers Values_per_Publisher Size_in_bytes IDL_Type Units Conversion Sensor_location Count Instances_per_night Bytes_per_night Needed_by_DM  Needed_by_Camera Needed_by_OCS Needed_by_TCS Needed_by_EPO" {
            set id [set i]_[set k]
            if { [info exists XMLTLM($id,$j)] } {
              if { $j == "IDL_Type" } {
                 if { [llength [split $XMLTLM($id,$j) "<>"]] > 1 } {
                    set spl [split $XMLTLM($id,$j) "<>"]
                    puts $fout "          <$j>[lindex $spl 0]</$j>"
                    puts $fout "          <IDL_Size>[lindex $spl 1]</IDL_Size>"
                 } else {
                    puts $fout "          <$j>$XMLTLM($id,$j)</$j>"
                    puts $fout "          <IDL_Size>1</IDL_Size>"
                 }
              } else {
                puts $fout "          <$j>$XMLTLM($id,$j)</$j>"
              }
            }
      }
     }
     puts $fout "      </item>"
    }
    puts $fout "</SALTelemetry>"
  }
  puts $fout "</SALTelemetrySet>"
  close $fout
}



proc testXMLtlm { subsys } {
global XMLTLM XMLTOPICS
    set XMLTOPICS($subsys) 1
    foreach j "EFDB_Topic EFDB_Name Description Frequency Publishers Values_per_Publisher Size_in_bytes IDL_Type Units Conversion Sensor_location Count Instances_per_night Bytes_per_night Needed_by_DM  Needed_by_Camera Needed_by_OCS Needed_by_TCS Needed_by_EPO Explanation" {
      set XMLTLM(test,$j) x
   }
   writeXMLsubsys $subsys
}


