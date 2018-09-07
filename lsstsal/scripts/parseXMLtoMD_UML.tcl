#!/usr/bin/env tclsh

source $env(SAL_DIR)/add_system_dictionary.tcl
set TCODE(string) '_rC9ncFqtEeiGoKJ3GcWAXw'
set TCODE(short) '_rC9ncVqtEeiGoKJ3GcWAXw'
set TCODE(char) '_rC9nclqtEeiGoKJ3GcWAXw'
set TCODE(unsignedshort) '_rC9nc1qtEeiGoKJ3GcWAXw'
set TCODE(octet) '_rC9ndFqtEeiGoKJ3GcWAXw'
set TCODE(boolean) '_rC9ndVqtEeiGoKJ3GcWAXw'
set TCODE(long) '_rC9ndlqtEeiGoKJ3GcWAXw'
set TCODE(unsignedlong) '_rC9nd1qtEeiGoKJ3GcWAXw'
set TCODE(int) '_rC9ndlqtEejGoKJ3GcWAXw'
set TCODE(longlong) '_rC9neFqtEeiGoKJ3GcWAXw'
set TCODE(unsignedint) '_rC9ndlqtEekGoKJ3GcWAXw'
set TCODE(unsignedlonglong) '_rC9neVqtEeiGoKJ3GcWAXw'
set TCODE(float) '_rC-OgFqtEeiGoKJ3GcWAXw'
set TCODE(double) '_rC-OgVqtEeiGoKJ3GcWAXw'
set TCODE(byte) '_rC-OglqtEeiGoKJ3GcWAXw'

proc genEnumeration { fid ename enum } {
global ENUMXID EXIDBASE
   set EXIDBASE($ename) "_18_5_3_b1b02ca_1519318452686_183403_[format %4.4d $ENUMXID]"
   puts $fid "			<packagedElement xmi:type='uml:Enumeration' xmi:id='[set EXIDBASE(
$ename)]' name='[set ename]'>"
   foreach i [split $enum ,] {
     incr ENUMXID 1
     puts $fid "		   <ownedLiteral xmi:type='uml:EnumerationLiteral' xmi:id='_18_5_3
_b1b02ca_1519318452686_183403_[format %4.4d $ENUMXID]' name='[set i]'/>"
   }
   puts $fid "		</packagedElement>"
}

proc refEnumeration { fid ename } {
global ENUMXID EXIDBASE
  puts $fid "<ownedAttribute xmi:type='uml:Property'  name='[set ename]' visibility='private' type='[set EXIDBASE($ename)]'>
	<ownedComment xmi:type='uml:Comment'  body='&lt;html&gt;&lt;pre&gt;See the [set ename] enumeration defined in the Typedefs package.&lt;/pre&gt;&lt;/html&gt;'>
		<annotatedElement/>
	</ownedComment>
	<xmi:Extension extender='MagicDraw UML 18.5'>
		<modelExtension>
			<lowerValue xmi:type='uml:LiteralInteger' xmi:id='EAID_LI000037_C7EC_4be8_AFF9_F31133CB40EF' value='1'/>
		</modelExtension>
	</xmi:Extension>
	<xmi:Extension extender='MagicDraw UML 18.5'>
		<modelExtension>
			<upperValue xmi:type='uml:LiteralInteger' xmi:id='EAID_LI000038_C7EC_4be8_AFF9_F31133CB40EF' value='1'/>
		</modelExtension>
	</xmi:Extension>
</ownedAttribute>"
}

proc genUnits { fid } { 
   set nunit 1
   set xmibase "_18_5_2_ed9034f_1520634937974_583483_"
   puts $fid "			  <packagedElement xmi:type='uml:Package' xmi:id='_18_5_2_ed9034f_1520634937917_143772_8348' name='Units (based on ISO 80000)'>"
   foreach unit "volt ampere second radian newton meter kelvin Steps" {
       puts $fid "			  	  <packagedElement xmi:type='uml:InstanceSpecification' xmi:id='[set xmibase]_[format %4.4d $nunit]' name='[set unit]'/>"
       incr nunit  1
   }
   foreach dunit "squareMeter metersPerSecond hertz lps watt pascal Celcius milliampere" {
       puts $fid "				  <packagedElement xmi:type='uml:InstanceSpecification' xmi:id='[set xmibase]_[format %4.4d $nunit]' name='[set dunit]'>
						<classifier href='QUDV.mdzip#_16_5_1_12c903cb_1245417652468_149854_5164'>
							<xmi:Extension extender='MagicDraw UML 18.5'>
								<referenceExtension referentPath='QUDV::DerivedUnit' referentType='Class'/>
							</xmi:Extension>
						</classifier>
				  </packagedElement>"
       incr nunit 1
    }
    if { 0 } {
    puts $fid "			<packagedElement xmi:type='uml:Profile' xmi:id='_18_5_2_ed9034f_1520974485955_868960_15666' name='Units_and_DataTypes_Profile'>
				<metamodelReference xmi:idref='_18_5_2_ed9034f_1520974485957_480084_15669'/>
				<packageImport xmi:type='uml:PackageImport' xmi:id='_18_5_2_ed9034f_1520974485957_480084_15669'>
					<importedPackage href='http://www.omg.org/spec/UML/20131001/UML.xmi#_0'>
						<xmi:Extension extender='MagicDraw UML 18.5'>
							<referenceExtension referentPath='UML Standard Profile::UML2 Metamodel' referentType='Model'originalID='_9_0_be00301_1108053761194_467635_11463'/>
						</xmi:Extension>
					</importedPackage>
				</packageImport>
				<packagedElement xmi:type='uml:Stereotype' xmi:id='_18_5_2_ed9034f_1520974485956_152305_15667' name='LSSTType' isActive='true'>
					<ownedAttribute xmi:type='uml:Property' xmi:id='_18_5_2_ed9034f_1520974485958_649551_15671' name='base_DataType' visibility='private'association='_18_5_2_ed9034f_1520974485957_517309_15668'>
						<type href='http://www.omg.org/spec/UML/20131001/UML.xmi#DataType'>
							<xmi:Extension extender='MagicDraw UML 18.5'>
								<referenceExtension referentPath='UML Standard Profile::UML2 Metamodel::DataType' referentType='Class'/>
							</xmi:Extension>
						</type>
					</ownedAttribute>
					<ownedAttribute xmi:type='uml:Property' xmi:id='_18_5_2_ed9034f_1520974485958_627467_15672' name='units' visibility='private'>
						<type href='MD_customization_for_SysML.mdzip#_11_5EAPbeta_be00301_1147430329106_6539_1367'>
							<xmi:Extension extender='MagicDraw UML 18.5'>
								<referenceExtension referentPath='MD Customization for SysML::additional_stereotypes::deprecated elements::Unit' referentType='Stereotype'/>
							</xmi:Extension>
						</type>
						<defaultValue xmi:type='uml:InstanceValue' xmi:id='_18_5_3_ed9034f_1523921380074_7571_15759' instance='_18_5_2_ed9034f_1520634937976_670653_8393'/>
					</ownedAttribute>
					<ownedAttribute xmi:type='uml:Property' xmi:id='_18_5_2_ed9034f_1520974485958_646465_15673' name='symbol' visibility='private'>
						<type href='http://www.omg.org/spec/UML/20131001/PrimitiveTypes.xmi#String'>
							<xmi:Extension extender='MagicDraw UML 18.5'>
								<referenceExtension referentPath='UML Standard Profile::UML2 Metamodel::PrimitiveTypes::String' referentType='PrimitiveType'/>
							</xmi:Extension>
						</type>
					</ownedAttribute>
				</packagedElement>
				<packagedElement xmi:type='uml:Extension' xmi:id='_18_5_2_ed9034f_1520974485957_517309_15668'>
					<memberEnd xmi:idref='_18_5_2_ed9034f_1520974485958_649551_15671'/>
					<memberEnd xmi:idref='_18_5_2_ed9034f_1520974485959_21513_15674'/>
					<navigableOwnedEnd xmi:idref='_18_5_2_ed9034f_1520974485959_21513_15674'/>
					<ownedEnd xmi:type='uml:ExtensionEnd' xmi:id='_18_5_2_ed9034f_1520974485959_21513_15674' name='extension_LSSTType' visibility='private' aggregation='composite' type='_18_5_2_ed9034f_1520974485956_152305_15667' association='_18_5_2_ed9034f_1520974485957_517309_15668'>
						<lowerValue xmi:type='uml:LiteralInteger' xmi:id='_18_5_2_ed9034f_1520974485959_485686_15676'/>
						<xmi:Extension extender='MagicDraw UML 18.5'>
							<modelExtension>
								<upperValue xmi:type='uml:LiteralUnlimitedNatural' xmi:id='_18_5_2_ed9034f_1520974485959_128259_15675' value='1'/>
							</modelExtension>
						</xmi:Extension>
					</ownedEnd>
				</packagedElement>
			</packagedElement>"
    }
    puts $fid "			</packagedElement>"
}




proc parseXMLtoUML { } { 
global IDLRESERVED SAL_WORK_DIR SAL_DIR CMDS CMD_ALIASES EVTS EVENT_ALIASES SYSDIC TCODE
global TLMS TLM_ALIASES EVENT_ENUM ENUM EATYPE IGNORE
   set fout [open SALXML_to_UML.xmi w]
   puts $fout "<?xml version='1.0' encoding='UTF-8'?>
<xmi:XMI xmlns:uml='http://www.omg.org/spec/UML/20131001' xmlns:xmi='http://www.omg.org/spec/XMI/20131001' xmlns:StandardProfile='http://www.omg.org/spec/UML/20131001/StandardProfile' xmlns:MD_Customization_for_SysML__additional_stereotypes='http://www.magicdraw.com/spec/Customization/180/SysML' xmlns:DSL_Customization='http://www.magicdraw.com/schemas/DSL_Customization.xmi' xmlns:sysml='http://www.omg.org/spec/SysML/20150709/SysML' xmlns:MagicDraw_Profile='http://www.omg.org/spec/UML/20131001/MagicDrawProfile' xmlns:Units_and_DataTypes_Profile='http://www.magicdraw.com/schemas/Units_and_DataTypes_Profile.xmi' xmlns:MD_Customization_for_Requirements__additional_stereotypes='http://www.magicdraw.com/spec/Customization/180/Requirements' xmlns:Validation_Profile='http://www.magicdraw.com/schemas/Validation_Profile.xmi'>
	<xmi:Documentation>
		<xmi:exporter>MagicDraw UML</xmi:exporter>
		<xmi:exporterVersion>18.5</xmi:exporterVersion>
	</xmi:Documentation>
	<xmi:Extension extender='MagicDraw UML 18.5'>
		<plugin pluginName='SysML' pluginVersion='18.5'/>
		<plugin pluginName='Cameo Requirements Modeler' pluginVersion='18.5'/>
		<req_resource resourceID='1480' resourceName='Cameo Requirements Modeler' resourceValueName='Cameo Requirements Modeler'/>
		<req_resource resourceID='1440' resourceName='SysML' resourceValueName='SysML'/>
	</xmi:Extension>
		<uml:Model xmi:type='uml:Model' name='SAL_Model'>
			<packagedElement xmi:type='uml:Package' name='SAL_Interface'>"
   foreach subsys $SYSDIC(systems) {
    set ctype ""
    set eaid 1
    set donefirst 0
    set tname none
    set itemid 0
    set EANUM 1
    puts $fout "				    <packagedElement xmi:type='uml:Package' name='[set subsys]'>"
    foreach stype "Commands Events Telemetry" {
    if { [file exists [set subsys]_[set stype].xml] } {
     set fin [open [set subsys]_[set stype].xml r]
     puts $fout "					<packagedElement xmi:type='uml:Package' name='[set stype]'>"
     while { [gets $fin rec] > -1 } {
##puts stdout $rec
      set tag   [lindex [split $rec "<>"] 1]
      set value [lindex [split $rec "<>"] 2]
      if { $tag == "SALTelemetry" }    {set ctype "telemetry"}
      if { $tag == "SALEvent" }        {set ctype "event"}
      if { $tag == "SALTelemetrySet" } {
          set ctype "telemetry"
      }
      if { $tag == "SALCommandSet" }   {
          set ctype "command" 
      }
      if { $tag == "SALEventSet" }     {
          set ctype "event"
      }
      if { $tag == "Alias" }           {
          set alias $value
          set shouldbe [join [lrange [split $tname _] 2 end] "_"]
          if { $alias != $shouldbe } {
             puts stdout "ERROR - Alias does not match EFDB_Topic declaration for $alias"
             exit
          }
      }
      if { $tag == "Subsystem" }       {set subsys $value}
      if { $tag == "Enumeration" }     {set ENUM($item) $value ; puts stdout "Enumeration $item = $value"}
      if { $tag == "/SALTelemetry" || $tag == "/SALEvent" || $tag == "/SALCommand" } {
         puts $fout "						</packagedElement>"
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
        set parts [split $value _]
        set chk [string tolower [join [lrange $parts 1 end] _]]
        if { [lsearch $IGNORE $chk] > -1 } {
           puts stdout "Ignoring $value"
           set looking 1
           while { $looking } {
             gets $fin rec
             if { [string range $rec 0 4] == "</SAL" } {set looking 0}
           }
        }
        puts stdout "Translating $tname"
        puts $fout "						<packagedElement xmi:type='uml:Class' name='[set tname]'>"
      }
      if { $tag == "EFDB_Name" } {
        set item $value ; set unit "" ; set ENUM($item) ""
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
         set ctype $TCODE([join $value ""])
      }
      if { $tag == "IDL_Size"}        {set sdim $value}
      if { $tag == "Description"}     {set desc [join [split $value "'<>"]]}
      if { $tag == "Frequency"}       {set freq $value}
      if { $tag == "Range"}           {set range $value}
      if { $tag == "Count"}           {set idim $value}
      if { $tag == "Units"}           {set unit $value}
      if { $tag == "/item" && $item != "priority" } {
         if { [info exists EATYPE($type)] == 0 } {
            set EAIDS($EANUM) $type
            set EATYPE($type) $EANUM
            incr EANUM 1
         }
         puts $fout "
								<ownedAttribute xmi:type='uml:Property' name=\"[set item]\" type=$ctype>
								</ownedAttribute>
								<ownedComment xmi:type='uml:Comment'  body='[set desc]'>
									<annotatedElement />
								</ownedComment>
"
         if { $ENUM($item) != "" } {
            puts $fout "							<nestedClassifier xmi:type='uml:Enumeration'  name='[set item]'>"
            set ei 1
            foreach e [split $ENUM($item) ,] { 
                puts $fout "									<ownedLiteral xmi:type='uml:EnumerationLiteral' name='[set e]'/>"
                incr ei 1
            }
            puts $fout "							</nestedClassifier>"
         }
         incr eaid 1
      }
     }
     puts $fout "					</packagedElement>"
     close $fin
      }
     }
     puts $fout "				    </packagedElement>"
    }
    puts $fout "			</packagedElement>"
    genUnits $fout
#    forach ename [array names ENUM] {
#       genEnumeration $fout $ename $ENUM($ename)
#    }
    puts $fout "			<packagedElement xmi:type='uml:Package' xmi:id='_rC9AbVqtEeiGoKJ3GcWAXw' name='IDL_Datatypes'>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC9ncFqtEeiGoKJ3GcWAXw' name='string'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC9ncVqtEeiGoKJ3GcWAXw' name='short'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC9nclqtEeiGoKJ3GcWAXw' name='char'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC9nc1qtEeiGoKJ3GcWAXw' name='unsigned short'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC9ndFqtEeiGoKJ3GcWAXw' name='octet'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC9ndVqtEeiGoKJ3GcWAXw' name='boolean'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC9ndlqtEeiGoKJ3GcWAXw' name='long'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC9nd1qtEeiGoKJ3GcWAXw' name='unsigned long'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC9neFqtEeiGoKJ3GcWAXw' name='long long'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC9neVqtEeiGoKJ3GcWAXw' name='unsigned long long'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC-OgFqtEeiGoKJ3GcWAXw' name='float'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC-OgVqtEeiGoKJ3GcWAXw' name='double'/>
				<packagedElement xmi:type='uml:DataType' xmi:id='_rC-OglqtEeiGoKJ3GcWAXw' name='byte'/>
			</packagedElement>
		</uml:Model>
</xmi:XMI>
"
   close $fout
}


set IGNORE "command_start command_stop command_enable command_disable command_standby command_entercontrol command_exitcontrol logevent_settingversions logevent_summarystate logevent_errorcode logevent_appliedsettingsmatchstart"
set IDLRESERVED "abstract any attribute boolean case char component const consumes context custom default double emits enum eventtype exception factory false finder fixed float getraises home import in inout interface local long module multiple native object octet oneway out primarykey private provides public publishes raises readonly sequence setraises short string struct supports switch true truncatable typedef typeid typeprefix union unsigned uses valuebase valuetype void wchar wstring"
set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)
source $SAL_DIR/add_private_idl.tcl
source $SAL_DIR/checkidl.tcl


