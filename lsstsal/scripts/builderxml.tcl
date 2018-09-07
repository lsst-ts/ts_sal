
proc topicitem { fid topic item type } {
  puts $fid "<UML:Attribute name=\"$item\" changeable=\"none\" visibility=\"public\" ownerScope=\"instance\"  targetScope=\"instance\">
<UML:Attribute.initialValue><UML:Expression/>
</UML:Attribute.initialValue>
<UML:StructuralFeature.type>
<UML:Classifier xmi.idref=\"$topic$item\"/>
</UML:StructuralFeature.type>
<UML:ModelElement.taggedValue>
<UML:TaggedValue tag=\"type\" value=\"$type\"/>
<UML:TaggedValue tag=\"derived\" value=\"0\"/>
<UML:TaggedValue tag=\"containment\" value=\"Not Specified\"/>
<UML:TaggedValue tag=\"ordered\" value=\"0\"/>
<UML:TaggedValue tag=\"collection\" value=\"false\"/>
<UML:TaggedValue tag=\"position\" value=\"0\"/>
<UML:TaggedValue tag=\"lowerBound\" value=\"1\"/>
<UML:TaggedValue tag=\"upperBound\" value=\"1\"/>
<UML:TaggedValue tag=\"duplicates\" value=\"0\"/>
<UML:TaggedValue tag=\"styleex\" value=\"volatile=0;\"/>
</UML:ModelElement.taggedValue>
</UML:Attribute>"
}

proc buildxml { sid } {
global stagingdir streamdir
 set fin [open $streamdir/template.xml r]
 set fout [open $stagingdir/$sid_eamodel.xml w]
 while { [gets $fin rec] > -1 } {
  if { [string range $rec 0 2] == "###" } {
    if { $rec == "###classname" } {
      puts $fout "<UML:TaggedValue tag=\"ea_targetName\" value=\"$s\"/>"
    }
    if { $rec == "###role" } {
      puts $fout "<UML:ClassifierRole name=\"$s\" visibility=\"public\">"
    }
    if { $rec == "###type" } {
      puts $fout "<UML:Class name=\"my[set s]Type\" visibility=\"public\" isRoot=\"false\" isLeaf=\"false\" isAbstract=\"false\" isActive=\"false\">"
    }
    if { $rec == "###items" } {
       set fidl [open $streamdir/$s.idl r]
       gets $fidl rec
       while { [gets $fidl rec] > -1 } {
           if { [string length $rec] > 3 } {
              set t [lindex [lindex [split $rec "\<"] 0] 0]
              set n [string trim [lindex $rec 1] ";"]
              topicitem $fout $s $n $t
           }
       }
       close $fidl
    }
    if { $rec == "###items2" } {
       puts $fout "<UML:DataType xmi.id=\"cameraRaftr1status\" name=\"void\" visibility=\"private\" isRoot=\"false\" isLeaf=\"false\" isAbstract=\"false\"/>"
       puts $fout "<UML:DataType xmi.id=\"cameraRaftr2status\" name=\"void\" visibility=\"private\" isRoot=\"false\" isLeaf=\"false\" isAbstract=\"false\"/>"
    }
    if { $rec == "###listener" } {
      puts $fout "<UML:Class name=\"my[set s]TypeListener\" visibility=\"public\" isRoot=\"false\" isLeaf=\"false\" isAbstract=\"false\" isActive=\"false\">"
    }
    if { $rec == "###header1" } {
      puts $fout "<UML:TaggedValue tag=\"header1\" value=\"#include \&lt;stdio.h\&gt;\&#xA;#include \&lt;stdlib.h\&gt;\&#xA;#include \&quot;ndds/ndds_cpp.h\&quot;\&#xA;#include \&quot;my[set s]Type.h\&quot;\&#xA;#include \&quot;my[set s]TypeSupport.h\&quot;\&#xA;\"/>"
    }
    if { $rec == "###code" } {
      puts $fout "<UML:TaggedValue tag=\"code\" value=\"my[set s]TypeDataReader *my[set s]Type_instance = NULL;\&#xA;my[set s]TypeSeq data_seq;\&#xA;DDS_SampleInfoSeq info_seq;\&#xA;DDS_ReturnCode_t retcode;\&#xA;int i;\&#xA;\&#xA;my[set s]Type_instance = my[set s]TypeDataReader::narrow(reader);\&#xA;if (my[set s]Type_instance == NULL) \{\&#xA;	printf(\&quot;DataReader narrow error\\n\&quot;);\&#xA;	return;\&#xA;\}\&#xA;\&#xA;retcode = my[set s]Type_instance-\&gt;take (\&#xA;	data_seq, info_seq, DDS_LENGTH_UNLIMITED,\&#xA;	DDS_ANY_SAMPLE_STATE, DDS_ANY_VIEW_STATE, DDS_ANY_INSTANCE_STATE);\&#xA;\&#xA;if (retcode == DDS_RETCODE_NO_DATA) \{\&#xA;	return;\&#xA;\} else if (retcode != DDS_RETCODE_OK) \{\&#xA;	printf(\&quot;take error %d\\n\&quot;, retcode);\&#xA;	return;\&#xA;\}\&#xA;\&#xA;for (i = 0; i \&lt; data_seq.length(); ++i) \{\&#xA;	if (info_seq\[i\].valid_data) \{\&#xA;		my[set s]TypeTypeSupport::print_data(\&amp;data_seq\[i\]);\&#xA;	\}\&#xA;\}\&#xA;\&#xA;retcode = my[set s]Type_instance-\&gt;return_loan(data_seq, info_seq);\&#xA;if (retcode != DDS_RETCODE_OK) \{\&#xA;	printf(\&quot;return loan error %d\\n\&quot;, retcode);\&#xA;\}\"/>"
    }
  } else {
    puts $fout $rec
  }
 }
 close $fin
 close $fout
}

set stagingdir /tmp/salgenerator/lsst_SAL_xml
set streamdir  /opt/lsst/streams
set salcodedir /opt/lsst/salcode
set XFILES ""

foreach s $PUBS {
  buildxml $s
  lappend XFILES [set s]_eamodel.xml
}
foreach s $SUBS {
  buildxml $s
  lappend XFILES [set s]_eamodel.xml
}

cd $stagingdir
foreach f $XFILES {
  exec cp $salcodedir/$f .
}
cd ..
exec tar czf lsst_SAL_xml.tar.gz lsst_SAL_xml
exec cp lsst_SAL_xml.tar.gz /var/www/html/downloads/salcode/.
 
 
puts stdout "<P><HR><P>
<H2>Service Abstraction Layer - XML Model</H2>
This archive contains an XML model for import into Enterprise Architect.<P><UL>"
if { $SUBS != "" } {
   puts stdout "Models subscription for :
<UL>"
   foreach s $SUBS {
      puts stdout "<LI>$s"
   }
   puts stdout "</UL>"
}
 
if { $PUBS != "" } {
   puts stdout "Models publishing for :
<UL>"
   foreach s $PUBS {
      puts stdout "<LI>$s"
   }
   puts stdout "</UL>"
}

puts stdout "<P><TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightGreen  WIDTH=400>
<TR><TD>Archive size</TD><TD>[file size /var/www/html/downloads/salcode/lsst_SAL_xml.tar.gz] bytes</TD></TR>
<TR><TD>Archive type</TD><TD>Gzip compressed Tar format</TD></TR>
<TR><TD>Language</TD><TD>Enterprise Architect XMI import compatible</TD></TR>
<TR><TD>Download link</TD><TD><A HREF=\"downloads/salcode/lsst_SAL_xml.tar.gz\">lsst_SAL_xml.tar.gz</A></TD></TR>
</TABLE>
<P><HR><P>"
 
 

