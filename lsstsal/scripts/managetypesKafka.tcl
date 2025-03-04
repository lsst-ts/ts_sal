#!/usr/bin/env tclsh
## \file managetypesKafka.tcl
# \brief This contains procedures to help manage the different
#  Kafka/C++/Java/LabVIEW data types
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
## Documented proc \c simpletypecode .
# \param[in] name Name of a data item
# \param[in] type Abstract data type
# \param[in] size Dimension of data
# \param[in] target Target language
#
#  Returns the code for the data type in the specified language
#
proc simpletypecode { name type size target } {
global TYPESUBS
   set ltyp [string tolower $type]
   switch $target {
         c  { 
              switch $ltyp {
                        string    -
                        string32  { return " char $name\[32\];" }
                        string16  { return " char $name\[16\];" }
                        string64  { return " char $name\[64\];" }
                        string1k  { return " char $name\[1024\];" }
                        byte      -
                        octet     { set s "unsigned char $name"
                                    if { $size > 1 } {
                                       return "$s\[$size\];"
                                    } else {
                                       return "$s;"
                                    }
                                  }
                        short     -
                        int       -
                        long      -
                        longlong   -
                        float     -
                        double    { set s "$TYPESUBS($ltyp) $name"
                                    if { $size > 1 } {
                                       return "$s\[$size\];"
                                    } else {
                                       return "$s;"
                                    }
                                  }
              }
         }   
         sql { 
              switch $ltyp {
                        string    -
                        string32  { return "$name char\[32\];" }
                        string16  { return "$name char\[16\];" }
                        string64  { return "$name char\[64\];" }
                        string1k  { return "$name char\[1024\];" }
                        byte      -
                        octet     {set s "$name TINYINT"
                                    if { $size > 1 } {
                                       set s ""
                                       set i 0
                                       while { $i < $size } {
                                         incr i 1
                                         set s "$s\n[set name]_$i TINYINT;"
                                       }
                                       return "$s"
                                    } else {
                                       return "$s;"
                                    }
                                  }
                        short     -
                        int       -
                        longlong   -
                        long      -
                        float     -
                        double    { set s "$name $TYPESUBS($ltyp)"
                                    if { $size > 1 } {
                                       set s ""
                                       set i 0
                                       while { $i < $size } {
                                         incr i 1
                                         set s "$s\n[set name]_$i $TYPESUBS($ltyp);"
                                       }
                                       return "$s"
                                    } else {
                                       return "$s;"
                                    }
                                  }
              }
         }   
   }
}

#
## Documented proc \c typejsontoc .
# \param[in] rec Record from JSON input file
#
#  Return the C/C++ code for an JSON data type declaration
#
proc typejsontoc { rec } {
global TYPESUBS VPROPS OPTIONS METADATA
   if { $OPTIONS(verbose) } {stdlog "### typejsontoc : $rec"}
   set u ""
   set VPROPS(array) 0
   set VPROPS(string) 0
   set VPROPS(int) 0
   set VPROPS(long) 0
   set VPROPS(boolean) 0
   set VPROPS(longlong) 0
   set VPROPS(short) 0
   set VPROPS(byte) 0
   set VPROPS(double) 0
   set VPROPS(float) 0
   set VPROPS(lvres) 0
   
   set arrdim ""
   set spl [string trim $rec " ;"]
   set type [lindex $spl 0]
   if { [string range $spl 0 10] == "std::vector" } {
     set VPROPS(name) [lindex $spl 2]
     set VPROPS(array) 1
     set type "$type>"
     set arrdim "\{0[string repeat ",0" [expr $METADATA($VPROPS(topic),$VPROPS(name),size)-1]]\}"
   } else {
     set VPROPS(name) [lindex $spl 1]
   }
   if { $VPROPS(name) == "salIndex" } {
     set VPROPS(dim) 1
   } else {
     set VPROPS(dim) $METADATA($VPROPS(topic),$VPROPS(name),size)
   }
   if { $type == "std::string" } {
      set VPROPS(string) 1
      set VPROPS(lvres) 5
      set VPROPS(dim) -1
      set res "  std::string	$VPROPS(name);"
   } else {
     if { $type != "float" && $type != "double" } {set VPROPS(int) 1; set VPROPS(lvres) 9}
     if { $type == "double" } {set VPROPS(double) 1; set VPROPS(lvres) 10}
     if { $type == "float" } { set VPROPS(float) 1}
     if { $type == "byte" } {set VPROPS(byte) 1; set VPROPS(lvres) 1  }
     if { $type == "long" } {set VPROPS(int) 1; set VPROPS(long); set VPROPS(lvres) 3  }
     if { $type == "long" } {set VPROPS(int) 1; set VPROPS(longlong) 1; set VPROPS(lvres) 4  }
     if { $type == "boolean" } {set VPROPS(boolean) 1; set VPROPS(lvres) 5  }
     if { $VPROPS(boolean) } {
       set res "  bool	$VPROPS(name)[set arrdim];"
     } else {
       set res "  $type	$VPROPS(name)[set arrdim];"
     }
   }
   return $res
}



#
## Documented proc \c simpletypecode .
#
#  Test the simpletypecode routine
#
proc testsimpletypecode { } {
   foreach case "c sql" {
      foreach typ "byte short int long float double string" {
          puts stdout "$case $typ :: [simpletypecode test $typ 1 $case]"
          puts stdout "$case $typ :: [simpletypecode test $typ 16 $case]"
      }
   }
}

## Documented proc \c transferdata .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] name Name of a data item
# \param[in] type Abstract data type
# \param[in] size Dimension of data
# \param[in] target Direction of copy
# \param[in] prefix Optional prefix for sample names
#
#  Copy data from Samples to shared memory data structures and back
#
proc transferdata { subsys name type size target {prefix ""} } {
global TYPESIZE TYPEFORMAT
   set ltyp [string tolower $type]
   switch $target {
        tcltocache { 
              switch $ltyp {
                    char   { return "       text = (char *)Tcl_GetVar2(interp, \"SHM[set subsys]\", \"$name\", TCL_GLOBAL_ONLY);
       strcpy([set subsys]_ref->$name,text);" 
                           }
                    byte   -
                    short  -
                    int    -
                    long   -
                    longlong   -
                    float  -
                    double {
                              if { $size > 1 } {
                                 set result  "	for (iterator=0;iterator<$size;iterator++) \{
          sprintf(newName,\"$name,%d\",iterator);
	  text = (char *)Tcl_GetVar2(interp, \"SHM[set subsys]\", newName, TCL_GLOBAL_ONLY);
	  sscanf(text,\"$TYPEFORMAT($ltyp)\", &[set subsys]_ref->$name\[iterator\]);
	\}"
                             } else {
                                 set result "       text = (char *)Tcl_GetVar2(interp, \"SHM[set subsys]\", \"$name\", TCL_GLOBAL_ONLY);
       sscanf(text,\"$TYPEFORMAT($ltyp)\", &[set subsys]_ref->$name);"
                              }
                              return $result;
                           }
              }
        }
        tcltest { 
              switch $ltyp {
                    char   { return "set SHM[set subsys]($name) \"LSST test\"" 
                           }
                    byte   -
                    short  -
                    int    -
                    long   -
                    longlong   -
                    float  -
                    double {
                              if { $size > 1 } {
                                 set i 1
                                 scan [expr rand()*100]] $TYPEFORMAT($ltyp) x
                                 set result "set i 0 ; while \{ \$i < $size \} \{ set SHM[set subsys]($name,\$i) \[expr $x+\$i\]; incr i 1\}"
                              } else {
                                 scan [expr rand()*100]] $TYPEFORMAT($ltyp) x
                                 set result "set SHM[set subsys]($name) $x"
                              }
                              return $result;
                           }
              }
        }
        ctest { 
              switch $ltyp {
                    char   { return "	sprintf([set subsys]_ref->$name,\"Sample string %d\",icurrent);" 
                           }
                    byte   -
                    short  -
                    int    -
                    long   -
                    longlong   -
                    float  -
                    double {  set result ""
                              if { $size > 1 } {
                                    set result "$result\n	for (iterator=0;iterator<$size;iterator++) \{
	  [set subsys]_ref->$name\[iterator\] = ($ltyp)(icurrent+iterator);
	\}"
                              } else {
                                 set result "	[set subsys]_ref->$name = ($ltyp)icurrent;"
                              }
                              return $result;
                           }
              }
        }
        lvfromcache { 
              switch $ltyp {
                    char   { return "ilen = strlen([set subsys]_ref->$name);\n	LStrLen(*$name) = ilen;\n	memcpy(*(char **)$name+4,[set subsys]_ref->$name, ilen);" }
                    byte   -
                    short  -
                    int    -
                    long   -
                    longlong   -
                    float  -
                    double {
                              if { $size > 1 } {
                                 set n [expr $TYPESIZE($type) * $size]
                                 return "LStrLen(*$name) = $n;\n	memcpy(*(char **)$name+4,[set subsys]_ref->$name, $n);"
                              } else {
                                 return "*$name=[set subsys]_ref->$name;"
                              }
                           }
              }
        }
        lvtocache { 
              switch $ltyp {
                    char   { return "strncpy([set subsys]_ref->$name,*(char **)$name+4, $size);" }
                    byte   -
                    short  -
                    int    -
                    long   -
                    longlong   -
                    float  -
                    double {
                              if { $size > 1 } {
                                 set n [expr $TYPESIZE($type) * $size]
                                 return "memcpy([set subsys]_ref->$name,*(char **)$name+4, $n);"
                              } else {
                                 return "[set subsys]_ref->$name = $name;"
                              }
                           }
              }
        }
        tclfromcache { 
              switch $ltyp {
                    char   { return "      Tcl_SetVar2(interp, \"SHM[set subsys]\", \"$name\", [set subsys]_ref->$name, TCL_GLOBAL_ONLY);"
                           }
                    byte   -
                    short  -
                    int    -
                    long   -
                    longlong   -
                    float  -
                    double {
                              if { $size > 1 } {
                                 set result "	for (iterator=0;iterator<$size;iterator++) \{
	  sprintf(newValue,\"$TYPEFORMAT($ltyp)\",[set subsys]_ref->$name\[iterator\]);
          sprintf(newName,\"$name,%d\",iterator);
	  Tcl_SetVar2(interp, \"SHM[set subsys]\", newName, newValue,  TCL_GLOBAL_ONLY);
	\}"
                                 set result "$result\n       sprintf(newValue,\"%d\",$size);
      Tcl_SetVar2(interp, \"SHM[set subsys]\", \"$name,size\", newValue,  TCL_GLOBAL_ONLY);"
                              } else {
                                 set result "      sprintf(newValue,\"$TYPEFORMAT($ltyp)\",[set subsys]_ref->$name);
      Tcl_SetVar2(interp, \"SHM[set subsys]\", \"$name\", newValue,  TCL_GLOBAL_ONLY);"

                              }
                              return $result;
                           }
              }
        }
   }
}

#
## Documented proc \c testtransferdata .
#
#  Test the transferdata routine
#
proc testtransferdata { } {
   foreach case "tcltocache tclfromcache tcltest ctest" {
      foreach typ "byte short int long float double char" {
          puts stdout "$case $typ :: [transferdata tcs_kernel_Target test $typ 1 $case]"
          puts stdout "$case $typ :: [transferdata tcs_kernel_Target test $typ 16 $case]"
      }
   }
}

#
## Documented proc \c lvtypebuilder .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] name Name of a data item
# \param[in] type Abstract data type
# \param[in] size Dimension of data
# 
#  Returns formatted LabVIEW C++ type
#
proc lvtypebuilder { base name type size } {
   set t [string tolower $type]
   if { $t == "char" || $size > 1 } {
      return "$base LStrHandle $name,"
   }
   if { $op == "get" } {
     return "$base $type* $name,"     
   }
   return "$base $type $name,"
}


set TYPESUBS(string) char
set TYPESUBS(String) char
set TYPESUBS(byte)   "unsigned char"
set TYPESUBS(int)    int
set TYPESUBS(short)  short
set TYPESUBS(int8)   "unsigned char"
set TYPESUBS(octet)  "unsigned char"
set TYPESUBS(int16)  short
set TYPESUBS(int32)  long
set TYPESUBS(long)   int
set TYPESUBS(float)  float
set TYPESUBS(double) double
set TYPESUBS(longlong) long
set TYPESUBS(bool)   int
set TYPESUBS(boolean) int
set TYPESUBS(unsignedint)    long
set TYPESUBS(unsignedshort)  short
set TYPESUBS(unsignedint16)  short
set TYPESUBS(unsignedint32)  int
set TYPESUBS(unsignedlong)   int
set TYPESUBS(unsignedlonglong) long

set ATYPESUBS(string) StrHdl
set ATYPESUBS(String) StrHdl
set ATYPESUBS(byte)   I8ArrayHdl
set ATYPESUBS(octet)  I8ArrayHdl
set ATYPESUBS(int)    I32ArrayHdl
set ATYPESUBS(short)  I16ArrayHdl
set ATYPESUBS(int8)   I8ArrayHdl
set ATYPESUBS(int16)  I16ArrayHdl
set ATYPESUBS(int32)  I32ArrayHdl
set ATYPESUBS(long)   I32ArrayHdl
set ATYPESUBS(longlong)  I64ArrayHdl
set ATYPESUBS(float)  SGLArrayHdl
set ATYPESUBS(double) DBLArrayHdl
set ATYPESUBS(bool)   BooleanArrayHdl
set ATYPESUBS(boolean) 		BooleanArrayHdl
set ATYPESUBS(unsignedbyte)     U8ArrayHdl
set ATYPESUBS(unsignedint)      U32ArrayHdl
set ATYPESUBS(unsignedshort)    U16ArrayHdl
set ATYPESUBS(unsignedint8)     U8ArrayHdl
set ATYPESUBS(unsignedint16)    U16ArrayHdl
set ATYPESUBS(unsignedint32)    U32ArrayHdl
set ATYPESUBS(unsignedlong)     U32ArrayHdl
set ATYPESUBS(unsignedlonglong) U64ArrayHdl

set TYPESIZE(String) 1
set TYPESIZE(string) 1
set TYPESIZE(byte)   1
set TYPESIZE(octet)  1
set TYPESIZE(short)  2
set TYPESIZE(int8)   1
set TYPESIZE(int16)  2
set TYPESIZE(int)    4
set TYPESIZE(int32)  4
set TYPESIZE(long)   4
set TYPESIZE(float)  4
set TYPESIZE(double) 8
set TYPESIZE(arrayshort)  2
set TYPESIZE(arraylong)   4
set TYPESIZE(arrayfloat)  4
set TYPESIZE(arraydouble) 8
set TYPESIZE(arraylonglong) 8
set TYPESIZE(arrayboolean) 4
set TYPESIZE(int64)  8
set TYPESIZE(bool)   4
set TYPESIZE(boolean) 4
set TYPESIZE(longlong) 8
set TYPESIZE(unsignedbyte)   1
set TYPESIZE(unsignedshort)  2
set TYPESIZE(unsignedint16)  2
set TYPESIZE(unsignedint)    4
set TYPESIZE(unsignedint32)  4
set TYPESIZE(unsignedlong)   4
set TYPESIZE(unsignedlonglong) 8

set TYPEFORMAT(byte)   "%hhu"
set TYPEFORMAT(octet)  "%hhu"
set TYPEFORMAT(short)  "%d"
set TYPEFORMAT(int16)  "%d"
set TYPEFORMAT(int)    "%d"
set TYPEFORMAT(int8)   "%hhu"
set TYPEFORMAT(int32)  "%d"
set TYPEFORMAT(bool)   "%d"
set TYPEFORMAT(boolean) "%d"
set TYPEFORMAT(long)   "%d"
set TYPEFORMAT(float)  "%f"
set TYPEFORMAT(double) "%lf"
set TYPEFORMAT(int64)  "%ld"
set TYPEFORMAT(longlong)      "%ld"
set TYPEFORMAT(unsignedbyte)   "%d"
set TYPEFORMAT(unsignedshort)  "%d"
set TYPEFORMAT(unsignedint16)  "%d"
set TYPEFORMAT(unsignedint)    "%d"
set TYPEFORMAT(unsignedint32)  "%d"
set TYPEFORMAT(unsignedlong)   "%ld"
set TYPEFORMAT(unsignedlonglong)   "%ld"
set TYPEFORMAT(arrayshort)  "%d"
set TYPEFORMAT(arraylong)   "%d"
set TYPEFORMAT(arrayfloat)  "%f"
set TYPEFORMAT(arraydouble) "%lf"
set TYPEFORMAT(arrayboolean) "%d"
set TYPEFORMAT(arraylonglong) "%ld"






