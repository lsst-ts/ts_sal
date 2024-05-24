#!/usr/bin/env tclsh
## \file checkjson.tcl
# \brief This contains procedures to parse the Avro json files
# and check for problems like the use of reserved words.
#
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code


#
## Documented proc \c validitem .
# \param[in] type Data type of item
# \param[in] item Name of the data item
# \param[in] op Optional type of information to return (dim,type,id)
#
# Check the data type of an item and return the correctly
# formatted Json definition, error if a reserved word is used
#
proc validitem { type item {op all} } {
global NEWCONSTS AVROSIZES AVRORESERVED
  if { $type == "int" } {set type "long"}
  if { $type == "byte" } {set type "octet"}
  if { $type == "longlong" } {set type "long long"}
  if { [string range $type 0 5] == "string" } { 
      set id [string trim $item "\;"]
      set siz  [lindex [split $type "<>"] 1]
      if { [info exists NEWCONSTS($siz)] } {set siz $NEWCONSTS($siz)}
      set nof $siz
      set t $type
      if { $siz != "" } {
        set v "  string<$siz>	$id"
      } else {
        set v "  string	$id"
      }
   } else {
     set it [split $item "\[\]"]
     set t $type
     if { [llength $it] == 1 } {
      set id [string trim [lindex $it 0] "\;"]
      set siz 1
      set v "  $t	$id"
     } else {
      set id [string trim [lindex $it 0] "\;"]
      set siz  [lindex $it 1]
      if { [info exists NEWCONSTS($siz)] } {set siz $NEWCONSTS($siz)}
      set v "  $type	$id\[$siz\]"
     }
   }
#puts stdout "valid is $v"
   if { [lsearch $AVRORESERVED [string tolower $id]] > -1 } {errorexit "Invalid use of AVRO reserved token $id"}
   if { $op == "dim" } {return $siz}
   if { $op == "type" } {return $t}
   if { $op == "id" } {return $id}
   return $v
}
      
#
## Documented proc \c salsyntaxcheck .
# \param[in] type Type of record to check
# \param[in] value Record to check
#
#  Check the syntax of SAL input records. Replace problematical 
#  characters which are not allowed.
#
proc salsyntaxcheck { type value } {
    switch $type {
         topic { 
                 set vfd [join [split $value "\"\'\;,\]\[\}\{()@\\&\%\!\` ^=-+\<\>\/\n"] _]
                 return "OK $vfd"
               }
    }
}


#
## Documented proc \c gentopicdefsql .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Create an MySQL input file which can be used to create an EFD table to 
#  store Topic data at runtime.
#
proc gentopicdefsql { subsys } {
global SAL_WORK_DIR
   exec mkdir -p $SAL_WORK_DIR/sql
     set fsql [open $SAL_WORK_DIR/sql/[set subsys]_items.sql w]
     puts $fsql "CREATE TABLE [set subsys]_items (
  Topic           varchar(128),
  ItemId	  smallint unsigned,
  EFDB_Name	  varchar(128),
  IDL_Type        varchar(128),
  Count           smallint unsigned,
  Units           varchar(128),
  Frequency       float,
  Constraints     varchar(128),
  Description     varchar(128),
  PRIMARY KEY (ItemId)
);"
    close $fsql
}


#
## Documented proc \c createackcmdjson .
# \param[in] base Name of Subsystem/CSC
# \param[in] keyid Optional specifier indicating that the SAL Topic is keyed
#
#  Create the AVRO Json fragment to define the 'ackcmd' Topic for a Subsystem
#  If the Topic is keyed, then an extra field is added for the key value.
#
proc createackcmdjson { base {keyid 0} } {
global SAL_WORK_DIR OPTIONS env
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> createackcmdjson $base $keyid"}
  exec cp $env(SAL_DIR)/code/templates/subsys_ackcmd.json $SAL_WORK_DIR/avro-templates/[set base]/[set base]_ackcmd.json
  set frep [open /tmp/genackcmdjson_[set base] w]
  puts $frep "perl -pi -w -e 's/lsst.sal.kafka_Test/lsst.sal.[set base]/g;' $SAL_WORK_DIR/avro-templates/[set base]/[set base]_ackcmd.json"
  close $frep
  exec chmod 755 /tmp/genackcmdjson_[set base]
  catch { set result [exec /tmp/genackcmdjson_[set base]] } bad
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< createackcmdjson $base $keyid"}
}

#
## Documented proc \c getAvroMethod.
# \param[in] item Name of SAL Topic item
#
#  Returns the name of the Avro method used to get/set values
#  Removes _ and converts to UpperCamelCase
#
proc getAvroMethod { item } {
   set nitem [split $item "_"]
   set res ""
   foreach i $nitem {
      set res "$res[string toupper [string range $i 0 0]][string range $i 1 end]"
   }
   return $res
}

proc getAvroNamespace { } {
global AVRO_PREFIX
  if { $AVRO_PREFIX == "lsst.sal" } { return [set AVRO_PREFIX]. }
  return [set AVRO_PREFIX]_
}

set SAL_WORK_DIR $env(SAL_WORK_DIR)
set SAL_DIR $env(SAL_DIR)
source $env(SAL_DIR)/streamutilsKafka.tcl
source $env(SAL_DIR)/utilitiesKafka.tcl
source $env(SAL_DIR)/add_system_dictionary.tcl
source $env(SAL_DIR)/add_private_json.tcl

set AVROTYPES "boolean byte short int long longlong float double string unsigned const"
set AVROSIZES(byte)     1
set AVROSIZES(octet)     1
set AVROSIZES(unsignedbyte)     1
set AVROSIZES(boolean)  2
set AVROSIZES(string)   1
set AVROSIZES(short)    2
set AVROSIZES(int)      4
set AVROSIZES(unsignedshort)    2
set AVROSIZES(unsignedint)      4
set AVROSIZES(long)     4
set AVROSIZES(longlong) 8
set AVROSIZES(unsignedlong)     4
set AVROSIZES(float)    4
set AVROSIZES(long\ long) 8
set AVROSIZES(unsignedlong\ long) 8
set AVROSIZES(double)   8
set AVRORESERVED "abstract any attribute boolean case char component const consumes context custom dec default double emits enum eventtype exception exit factory false finder fixed float getraises home import in inout interface limit local long module multiple native object octet oneway out primarykey private provides public publishes raises readonly sequence setraises short string struct supports switch true truncatable typedef typeid typeprefix union unsigned uses valuebase valuetype void wchar wstring"



