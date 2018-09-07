#!/usr/bin/env tclsh

proc parseXMLtoUML { fname } { 
global IDLRESERVED SAL_WORK_DIR SAL_DIR CMDS CMD_ALIASES EVTS EVENT_ALIASES
global TLMS TLM_ALIASES EVENT_ENUM
   set fin [open $fname r]
   set fout [open [file root $fname]_to_UML.xml w]
   puts $fout "<?xml version=\"1.0\" encoding=\"windows-1252\"?>
<XMI xmi.version=\"1.1\" xmlns:UML=\"omg.org/UML1.3\" timestamp=\"2017-11-09 11:42:06\">
	<XMI.header>
		<XMI.documentation>
			<XMI.exporter>Enterprise Architect</XMI.exporter>
			<XMI.exporterVersion>2.5</XMI.exporterVersion>
		</XMI.documentation>
	</XMI.header>
	<XMI.content>
		<UML:Model>
			<UML:Namespace.ownedElement>
				<UML:Class name=\"EARootClass\"  isRoot=\"true\" isLeaf=\"false\" isAbstract=\"false\"/>
				<UML:Package name=\"[file root $fname]\"  isRoot=\"false\" isLeaf=\"false\" isAbstract=\"false\" visibility=\"public\">
					<UML:ModelElement.taggedValue>
						<UML:TaggedValue tag=\"parent\"/>
						<UML:TaggedValue tag=\"ea_package_id\" value=\"6\"/>
						<UML:TaggedValue tag=\"created\" value=\"2017-11-09 11:39:25\"/>
						<UML:TaggedValue tag=\"modified\" value=\"2017-11-09 11:39:27\"/>
						<UML:TaggedValue tag=\"iscontrolled\" value=\"FALSE\"/>
						<UML:TaggedValue tag=\"lastloaddate\" value=\"2017-11-09 11:39:25\"/>
						<UML:TaggedValue tag=\"lastsavedate\" value=\"2017-11-09 11:39:25\"/>
						<UML:TaggedValue tag=\"version\" value=\"1.0\"/>
						<UML:TaggedValue tag=\"isprotected\" value=\"FALSE\"/>
						<UML:TaggedValue tag=\"usedtd\" value=\"FALSE\"/>
						<UML:TaggedValue tag=\"logxml\" value=\"FALSE\"/>
						<UML:TaggedValue tag=\"tpos\" value=\"0\"/>
						<UML:TaggedValue tag=\"packageFlags\" value=\"isModel=1;VICON=3;CRC=0;\"/>
						<UML:TaggedValue tag=\"batchsave\" value=\"0\"/>
						<UML:TaggedValue tag=\"batchload\" value=\"0\"/>
						<UML:TaggedValue tag=\"phase\" value=\"1.0\"/>
						<UML:TaggedValue tag=\"status\" value=\"Proposed\"/>
						<UML:TaggedValue tag=\"author\" value=\"SAL_EA_Export\"/>
						<UML:TaggedValue tag=\"complexity\" value=\"1\"/>
						<UML:TaggedValue tag=\"ea_stype\" value=\"Public\"/>
						<UML:TaggedValue tag=\"tpos\" value=\"0\"/>
						<UML:TaggedValue tag=\"gentype\" value=\"IDL\"/>
					</UML:ModelElement.taggedValue>
					<UML:Namespace.ownedElement>
"
   set ctype ""
   set eaid 1
   set subsys ""
   set donefirst 0
   set tname none
   set itemid 0
   set EANUM 1
   while { [gets $fin rec] > -1 } {
      set tag   [lindex [split $rec "<>"] 1]
      set value [lindex [split $rec "<>"] 2]
      if { $tag == "SALTelemetry" }    {set ctype "telemetry"}
      if { $tag == "SALEvent" }        {set ctype "event"}
      if { $tag == "SALTelemetrySet" } {set ctype "telemetry"}
      if { $tag == "SALCommandSet" }   {set ctype "command"}
      if { $tag == "SALEventSet" }     {set ctype "event"}
      if { $tag == "Alias" }           {
          set alias $value
          set shouldbe [join [lrange [split $tname _] 2 end] "_"]
          if { $alias != $shouldbe } {
             puts stdout "ERROR - Alias does not match EFDB_Topic declaration for $alias"
             exit
          }
      }
      if { $tag == "Subsystem" }       {set subsys $value}
      if { $tag == "Enumeration" }     {set EVENT_ENUM($alias) "$item:$value"}
      if { $tag == "/SALTelemetry" || $tag == "/SALEvent" || $tag == "/SALCommand" } {
         puts $fout "
							</UML:Classifier.feature>
						</UML:Class>
"
      }
      if { $tag == "EFDB_Topic" } {
        set alias ""
        set itemid 0
        if { [info exists topics($value)] } { 
           puts stdout "ERROR - duplicate EFDB_Topic = $value"
           exit
        }
        set topics($value) 1
        set tname $value
        puts stdout "Translating $tname"
        puts $fout "
						<UML:Class name=\"[set tname]\"  isRoot=\"false\" isLeaf=\"false\" isAbstract=\"false\" isActive=\"false\">
							<UML:ModelElement.stereotype>
								<UML:Stereotype name=\"Signal\"/>
							</UML:ModelElement.stereotype>
							<UML:ModelElement.taggedValue>
								<UML:TaggedValue tag=\"isSpecification\" value=\"false\"/>
								<UML:TaggedValue tag=\"ea_stype\" value=\"Class\"/>
								<UML:TaggedValue tag=\"ea_ntype\" value=\"0\"/>
								<UML:TaggedValue tag=\"version\" value=\"1.0\"/>
								<UML:TaggedValue tag=\"package\" />
								<UML:TaggedValue tag=\"date_created\" value=\"2017-11-09 11:39:25\"/>
								<UML:TaggedValue tag=\"date_modified\" value=\"2017-11-09 11:39:25\"/>
								<UML:TaggedValue tag=\"gentype\" value=\"IDL\"/>
								<UML:TaggedValue tag=\"tagged\" value=\"0\"/>
								<UML:TaggedValue tag=\"package_name\" value=\"[set subsys]\"/>
								<UML:TaggedValue tag=\"phase\" value=\"1.0\"/>
								<UML:TaggedValue tag=\"author\" value=\"SAL_EA_Export\"/>
								<UML:TaggedValue tag=\"complexity\" value=\"1\"/>
								<UML:TaggedValue tag=\"status\" value=\"Proposed\"/>
								<UML:TaggedValue tag=\"stereotype\" value=\"Signal\"/>
								<UML:TaggedValue tag=\"tpos\" value=\"0\"/>
								<UML:TaggedValue tag=\"ea_localid\" value=\"86\"/>
								<UML:TaggedValue tag=\"ea_eleType\" value=\"element\"/>
								<UML:TaggedValue tag=\"eventflags\" value=\"OBJ=2666;\"/>
								<UML:TaggedValue tag=\"style\" value=\"BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;\"/>
							</UML:ModelElement.taggedValue>
							<UML:Classifier.feature>
"
      }
      if { $tag == "EFDB_Name" } {
        set item $value ; set unit ""
        incr itemid 1
        set desc "" ; set range "" ; set location ""
        set freq 0.054 ; set sdim 1
        if { [lsearch $IDLRESERVED [string tolower $item]] > -1 } {
           puts stdout "Invalid use of IDL reserved token $item"
           exit 1
        }
      }
      if { $tag == "IDL_Type"} {
         set type $value
         if { $type == "long long" } {set type "longlong"}
         if { $type == "unsigned long long" } {set type "unsigned longlong"}
      }
      if { $tag == "IDL_Size"}        {set sdim $value}
      if { $tag == "Description"}     {set desc $value}
      if { $tag == "Frequency"}       {set freq $value}
      if { $tag == "Range"}           {set range $value}
      if { $tag == "Count"}           {set idim $value}
      if { $tag == "Units"}           {set unit $value}
      if { $tag == "/item" } {
         if { [info exists EATYPE($type)] == 0 } {
            set EAIDS($EANUM) $type
            set EATYPE($type) $EANUM
            incr EANUM 1
         }
         puts $fout "
								<UML:Attribute name=\"[set item]\" changeable=\"none\" visibility=\"public\" ownerScope=\"instance\" targetScope=\"instance\">
									<UML:Attribute.initialValue>
										<UML:Expression/>
									</UML:Attribute.initialValue>
									<UML:StructuralFeature.type>
										<UML:Classifier xmi.idref=\"eaxmiid[set EATYPE($type)]\"/>
									</UML:StructuralFeature.type>
									<UML:ModelElement.taggedValue>
										<UML:TaggedValue tag=\"description\" value=\"private\"/>
										<UML:TaggedValue tag=\"type\" value=\"[set type]\"/>
										<UML:TaggedValue tag=\"derived\" value=\"0\"/>
										<UML:TaggedValue tag=\"containment\" value=\"Not Specified\"/>
										<UML:TaggedValue tag=\"length\" value=\"0\"/>
										<UML:TaggedValue tag=\"ordered\" value=\"0\"/>
										<UML:TaggedValue tag=\"precision\" value=\"0\"/>
										<UML:TaggedValue tag=\"scale\" value=\"0\"/>
										<UML:TaggedValue tag=\"collection\" value=\"false\"/>
										<UML:TaggedValue tag=\"position\" value=\"0\"/>
										<UML:TaggedValue tag=\"lowerBound\" value=\"1\"/>
										<UML:TaggedValue tag=\"upperBound\" value=\"1\"/>
										<UML:TaggedValue tag=\"duplicates\" value=\"0\"/>
										<UML:TaggedValue tag=\"ea_guid\" />
										<UML:TaggedValue tag=\"ea_localid\" value=\"[set eaid]\"/>
										<UML:TaggedValue tag=\"styleex\" value=\"volatile=0;union=0;\"/>
									</UML:ModelElement.taggedValue>
								</UML:Attribute>
"
         incr eaid 1
      }
   }
   puts $fout "
					</UML:Namespace.ownedElement>
				</UML:Package>
"
   foreach t [array names EAIDS] {
     puts $fout "				<UML:DataType xmi.id=\"eaxmiid[set t]\" name=\"[set EAIDS($t)]\" visibility=\"private\" isRoot=\"false\" isLeaf=\"false\" isAbstract=\"false\"/>"
   }
   puts $fout "
			</UML:Namespace.ownedElement>
		</UML:Model>
	</XMI.content>
	<XMI.difference/>
	<XMI.extensions xmi.extender=\"Enterprise Architect 2.5\"/>
</XMI>
"
   close $fin
   close $fout
   set fout [open [file root $fname]_enums_to_UML.xml w]
   puts $fout "<?xml version=\"1.0\" encoding=\"windows-1252\"?>
<XMI xmi.version=\"1.1\" xmlns:UML=\"omg.org/UML1.3\" timestamp=\"2017-11-09 11:42:06\">
	<XMI.header>
		<XMI.documentation>
			<XMI.exporter>salgenerator</XMI.exporter>
		</XMI.documentation>
	</XMI.header>
	<XMI.content>
"
   set enumid 10000
   set evts [array names EVENT_ENUM]
   foreach e $evts {
          incr enumid 1
          set i 1
          set enum [string trim $e "\{\}"]
          puts $fout "		<packagedElement xmi:type='uml:Enumeration' xmi:id='_enum_[set enumid]' name='[set enum]'>"
          set cnst [lindex [split $enum :] 1]
          foreach id [split $cnst ,] {
              puts $fout "			<ownedLiteral xmi:type='uml:EnumerationLiteral' xmi:id='_enum_[set enumid]_[set i]' name='[set id]'/>"
              incr i 1
          }
   }
   puts $fout "		</packagedElement>
	</XMI.content>
</XMI>
"
   close $fout
}


proc unifyxml { } {
  set fin [open  all.xmi r]
  set fout [open sal_objects.XMI w]
  puts $fout "<?xml version=\"1.0\" encoding=\"windows-1252\"?>
<XMI xmi.version=\"1.1\" xmlns:UML=\"omg.org/UML1.3\" timestamp=\"2017-11-09 11:42:06\">
	<XMI.header>
		<XMI.documentation>
			<XMI.exporter>Enterprise Architect</XMI.exporter>
			<XMI.exporterVersion>2.5</XMI.exporterVersion>
		</XMI.documentation>
	</XMI.header>
	<XMI.content>"
  while { [gets $fin rec] > -1 } {
     set pream [string trim [lindex [split $rec .] 0]]
     if { [string range $pream 0 3] == "<XMI" ||  [string range $pream 0 4] == "</XMI" ||[string range $pream 0 4] == "<?xml" } {
        set ignore 1
     } else {
        puts $fout $rec
     }
  } 
  puts $fout "	</XMI.content>
	<XMI.difference/>
	<XMI.extensions xmi.extender=\"Enterprise Architect 2.5\"/>
</XMI>
"
  close $fin
  close $fout
}


set IDLRESERVED "abstract any attribute boolean case char component const consumes context custom default double emits enum eventtype exception factory false finder fixed float getraises home import in inout interface local long module multiple native object octet oneway out primarykey private provides public publishes raises readonly sequence setraises short string struct supports switch true truncatable typedef typeid typeprefix union unsigned uses valuebase valuetype void wchar wstring"
set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)
source $SAL_DIR/add_private_idl.tcl
source $SAL_DIR/checkidl.tcl


