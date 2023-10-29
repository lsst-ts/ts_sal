#!/usr/bin/env tclsh
## \file gensimplesampleKafka.tcl
# \brief Generate simple pub/sub programs for each data type in cpp and java
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
#  Generate simple pub/sub programs for each data type in cpp and java
#
#
## Documented proc \c makesaldirs .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] name Name of SAL Topic
#
#  Create a directory strucuture for building SAL API assets
#
proc makesaldirs { base name } {
global SAL_WORK_DIR OPTIONS
   if { $OPTIONS(verbose) } {stdlog "###TRACE>>> makesaldirs $base $name"}
   if { [lindex [split $name "_"] end] != "enums" } {
    if { $name != "hash_table" } { 
     exec mkdir -p $SAL_WORK_DIR/[set base]_[set name]/cpp/src
     exec mkdir -p $SAL_WORK_DIR/[set base]_[set name]/cpp/standalone
     exec mkdir -p $SAL_WORK_DIR/[set base]_[set name]/java/src/org/lsst/sal
     exec mkdir -p $SAL_WORK_DIR/[set base]_[set name]/java/src/org/lsst/sal/$base/$name
     exec mkdir -p $SAL_WORK_DIR/[set base]/java/src
     exec mkdir -p $SAL_WORK_DIR/[set base]/java/src/org/lsst/sal
     exec mkdir -p $SAL_WORK_DIR/[set base]/cpp/src
     exec mkdir -p $SAL_WORK_DIR/[set base]_[set name]/java/standalone
     exec touch $SAL_WORK_DIR/[set base]/java/src/.depend.Makefile.saj_[set base]_cmdctl
     exec touch $SAL_WORK_DIR/[set base]/java/src/.depend.Makefile.saj_[set base]_event
     exec touch $SAL_WORK_DIR/[set base]_[set name]/java/standalone/.depend.Makefile.saj_[set base]_[set name]_pub
     exec touch $SAL_WORK_DIR/[set base]_[set name]/java/standalone/.depend.Makefile.saj_[set base]_[set name]_sub
     exec touch $SAL_WORK_DIR/[set base]_[set name]/cpp/standalone/.depend.Makefile.sacpp_[set base]_[set name]_pub
     exec touch $SAL_WORK_DIR/[set base]_[set name]/cpp/standalone/.depend.Makefile.sacpp_[set base]_[set name]_sub
     exec touch $SAL_WORK_DIR/[set base]/cpp/src/.depend.Makefile.sacpp_[set base]_cmd
     exec touch $SAL_WORK_DIR/[set base]/cpp/src/.depend.Makefile.sacpp_[set base]_event
     exec touch $SAL_WORK_DIR/[set base]/cpp/src/.depend.Makefile.sacpp_[set base]_testcommands
     exec touch $SAL_WORK_DIR/[set base]/cpp/src/.depend.Makefile.sacpp_[set base]_testevents
    }
   }
   if { $OPTIONS(verbose) } {stdlog "###TRACE<<< makesaldirs $base $name"}
}


#
## Documented proc \c addlvtypes .
# \param[in] fhlv File handle of LabVIEW include file
#
# Write LabVIEW specific data structures to header file 
#
proc addlvtypes { fhlv } {
  puts $fhlv "
typedef signed char int8_t;
typedef short int int16_t;
typedef int int32_t;
typedef long int int64_t;
typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long int uint64_t;
typedef unsigned char bool_t;
typedef struct \{
	int size;
	bool_t data\[1\];
\} BooleanArray;
typedef BooleanArray** BooleanArrayHdl;


typedef struct \{
	int size;
	int8_t data\[1\];
\} I8Array;
typedef I8Array** I8ArrayHdl;

typedef struct \{
	int size;
	int16_t data\[1\];
\} I16Array;
typedef I16Array** I16ArrayHdl;

typedef struct \{
	int size;
	int data\[1\];
\} I32Array;
typedef I32Array** I32ArrayHdl;

typedef struct \{
	int size;
	int64_t data\[1\];
\} I64Array;
typedef I64Array** I64ArrayHdl;

typedef struct \{
	int size;
	uint8_t data\[1\];
\} U8Array;
typedef U8Array** U8ArrayHdl;

typedef struct \{
	int size;
	uint16_t data\[1\];
\} U16Array;
typedef U16Array** U16ArrayHdl;

typedef struct \{
	int size;
	uint32_t data\[1\];
\} U32Array;
typedef U32Array** U32ArrayHdl;

typedef struct \{
	int size;
	uint64_t data\[1\];
\} U64Array;
typedef U64Array** U64ArrayHdl;

typedef struct \{
	int size;
	float data\[1\];
\} SGLArray;
typedef SGLArray** SGLArrayHdl;

typedef struct \{
	int size;
	double data\[1\];
\} DBLArray;
typedef DBLArray** DBLArrayHdl;

typedef struct \{
	int size;
	char data\[1\];
\} Str;
typedef Str** StrHdl;

typedef struct \{
	int size;
	StrHdl data\[1\];
\} StrArray;
typedef StrArray** StrArrayHdl;
"
}


#
## Documented proc \c makesalincl .
# \param[in] subsys Name of CSC/Subsystem as defined in SALSubsystems.xml
#
#  Generate compatible versions of the SAL Topic data structure
#  definitions
#
proc makesalincl { subsys } {
global SAL_DIR SAL_WORK_DIR SYSDIC VPROPS EVENT_ENUM OPTIONS CMD_ALIASES METADATA
   if { $OPTIONS(verbose) } {stdlog "###TRACE>>> makesalincl $subsys"}
   exec mkdir -p $SAL_WORK_DIR/avro-templates/sal
   exec mkdir -p $SAL_WORK_DIR/[set subsys]/cpp/src
   catch {
     set prev [glob $SAL_WORK_DIR/include/SAL_[set subsys]*]
     foreach f $prev {exec rm $f}
   }
   stdlog "calling salavrogen $subsys cpp"
   salavrogen $subsys cpp
   stdlog "done salavrogen $subsys cpp"
   set all [lsort [glob $SAL_WORK_DIR/[set subsys]/cpp/src/[set subsys]_*.hh]]
   set fhdr [open $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]C.h w]
   set fhlv [open $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]LV.h w]
   addlvtypes $fhlv
   puts $fhdr "#ifndef _SAL_[set subsys]C_"
   puts $fhdr "#define _SAL_[set subsys]C_"
   puts $fhdr "#include <string>"
   puts $fhdr "using namespace std;"
   foreach i $all {
     stdlog "Adding $i to sal_$subsys code fragments"
###     set fin [open $i r]
###     gets $fin rec; gets $fin rec;gets $fin rec;gets $fin rec;gets $fin rec;gets $fin rec;gets $fin rec; gets $fin rec; gets $fin rec
     set name [join [lrange [split [file rootname [file tail $i]] _] 1 end] _]
     if { $name != "ackcmd" } {
      set VPROPS(iscommand) 0
      if { [string range $name 0 7] == "command_" } {set VPROPS(iscommand) 1}
      set fcod1 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Cget.tmp w]
      set fcod1b [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]LCget.tmp w]
      set fcod2 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Cput.tmp w]
      set fcod2b [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Cchk.tmp w]
      set fcod3 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Csub.tmp w]
      set fcod4 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Cpub.tmp w]
      set fcod5 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Cargs.tmp w]
      set fcod6 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Cout.tmp w]
      set fcod7 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]shmout.tmp w]
      set fcod8 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]shmin.tmp w]
      puts $fcod8 "
           data->private_rcvStamp = [set subsys]_memIO->client\[LVClient\].shmemIncoming_[set subsys]_[set name].private_rcvStamp;"
      set fcod10 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Pargs.tmp w]
      set fcod11 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Ppub.tmp w]
      set fcod12 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]monout.tmp w]
      set fcod13 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]monin.tmp w]
      puts $fcod13 "
             [set subsys]_memIO->client\[LVClient\].shmemIncoming_[set subsys]_[set name].private_rcvStamp = Incoming_[set subsys]_[set name]->private_rcvStamp;"
      puts $fhdr "struct [set subsys]_[set name]C \{"
      puts $fhdr "  double  private_rcvStamp;"
      puts $fhlv "typedef struct [set subsys]_[set name]LV \{"
      set argidx 1
      puts $fhdr "#ifdef SAL_DEBUG_CSTRUCTS"
      puts $fhdr "  [set subsys]_[set name]C()  \{ std::cout << \"[set subsys]_[set name]C()\"  << std::endl; \}"
      puts $fhdr "  ~[set subsys]_[set name]C() \{ std::cout << \"~[set subsys]_[set name]C()\"  << std::endl; \}"
      puts $fhdr "#endif"
      set fin [open $SAL_WORK_DIR/[set subsys]/cpp/src/[set subsys]_[set name].hh r]
      set rec ""
      while { [string trim $rec] != "struct [set name] \{" } {
        gets $fin rec
      }
      set done 0
      while { $done == 0 } {
        gets $fin rec
        if { [string trim $rec] != "[set name]() :" } {
         if {  [lindex [split [lindex [string trim $rec] 1] "_"] 0] != "private" } {
           if { $OPTIONS(verbose) } { stdlog "### processing $i : $rec" }
           set VPROPS(idx) $argidx
           set VPROPS(base) $subsys
           set VPROPS(topic) "[set subsys]_[set name]"
           set drec [typejsontoc $rec]
           puts $fhdr $drec
           puts $fhlv $drec
           updatecfragments $fcod1 $fcod1b $fcod2 $fcod2b $fcod3 $fcod4 $fcod5 $fcod6 $fcod7 $fcod8 $fcod10 $fcod11 $fcod12 $fcod13
           set vname $VPROPS(name)
           if { $VPROPS(array) } {
             incr argidx $VPROPS(dim)
           } else {
             incr argidx 1
           }
         }
        } else {
          set done 1
        }
      }
      puts $fhdr "\};"
      puts $fhlv "\} [set subsys]_[set name]_Ctl;"
      close $fcod1
      close $fcod1b
      close $fcod2
      close $fcod2b
      close $fcod3
      close $fcod4
      close $fcod5
      close $fcod6
      close $fcod7
      close $fcod8
      close $fcod10
      close $fcod11
      close $fcod12
      close $fcod13
    }
   }
   if { [info exists CMD_ALIASES($subsys)] } {
     genackcmdincl $subsys $fhdr $fhlv
   }
   puts $fhdr "#endif"
   close $fhdr
   close $fhlv
   updateRevCodes $subsys
##   activeRevCodes $subsys
   if { $OPTIONS(verbose) } {stdlog "###TRACE<<< makesalincl $subsys"}
   return $SAL_WORK_DIR/avro-templates/sal/sal_$subsys.json
}

#
## Documented proc \c updatecfragments .
# \param[in] fcod1 File handle of code fragment file
# \param[in] fcod1b File handle of code fragment file
# \param[in] fcod2 File handle of code fragment file
# \param[in] fcod2b File handle of code fragment file
# \param[in] fcod3 File handle of code fragment file
# \param[in] fcod4 File handle of code fragment file
# \param[in] fcod5 File handle of code fragment file
# \param[in] fcod6 File handle of code fragment file
# \param[in] fcod7 File handle of code fragment file
# \param[in] fcod8 File handle of code fragment file
# \param[in] fcod10 File handle of code fragment file
# \param[in] fcod11 File handle of code fragment file
# \param[in] fcod12 File handle of code fragment file
# \param[in] fcod13 File handle of code fragment file
#
#  Generate code fragments to be included in API code
#  Depending upon the target language code is gnerated to read
#  and write the individual data fields of the SAL Topics
#
proc updatecfragments { fcod1 fcod1b fcod2 fcod2b fcod3 fcod4 fcod5 fcod6 fcod7 fcod8 fcod10 fcod11 fcod12 fcod13 } {
global VPROPS TYPEFORMAT METADATA
   set idx $VPROPS(idx)
   if { $VPROPS(array) } {
#      puts $fcod1 "    data->$VPROPS(name).insert(data->$VPROPS(name).end(), Instance.$VPROPS(name).begin(), Instance.$VPROPS(name).end());"
#      puts $fcod1 "    lastSample_[set VPROPS(topic)].$VPROPS(name).insert(lastSample_[set VPROPS(topic)].$VPROPS(name).end(), Instance.$VPROPS(name).begin(), Instance.$VPROPS(name).end());"
#      puts $fcod1b "    data->$VPROPS(name).insert(data->$VPROPS(name).end(), lastSample_[set VPROPS(topic)].$VPROPS(name).begin(), lastSample_[set VPROPS(topic)].$VPROPS(name).end());"
      puts $fcod2 "    Instance.$VPROPS(name).insert(Instance.$VPROPS(name).end() ,data->$VPROPS(name).begin(), data->$VPROPS(name).end());"
#      puts $fcod4 "    for (int i=0;i<$VPROPS(dim);i++)\{myData.$VPROPS(name).push_back(i+iseq);\}"

      puts $fcod1 "    for (int iseq=0;iseq<$VPROPS(dim);iseq++) \{data->$VPROPS(name)\[iseq\] = Instance.$VPROPS(name)\[iseq\];\}"
      puts $fcod1 "    for (int iseq=0;iseq<$VPROPS(dim);iseq++) \{lastSample_[set VPROPS(topic)].$VPROPS(name)\[iseq\] = Instance.$VPROPS(name)\[iseq\];\}"
      puts $fcod1b "    for (int iseq=0;iseq<$VPROPS(dim);iseq++) \{data->$VPROPS(name)\[iseq\] = lastSample_[set VPROPS(topic)].$VPROPS(name)\[iseq\];\}"
#      puts $fcod2 "    for (int iseq=0;iseq<$VPROPS(dim);iseq++) \{Instance.$VPROPS(name)\[iseq\] = data->$VPROPS(name)\[iseq\];\}"
      puts $fcod3 "       cout << \"    $VPROPS(name) : \" << SALInstance.$VPROPS(name)\[0\] << endl;"
      puts $fcod4 "    for (int i=0;i<$VPROPS(dim);i++)\{myData.$VPROPS(name)\[i\] = i+iseq;\}"
      puts $fcod6 "       cout << \"    $VPROPS(name) : \" << data->$VPROPS(name)\[0\] << endl;"
      puts $fcod7 "
           int $VPROPS(name)Size = (*(data->$VPROPS(name)))->size ;
           for (int i=0;i<$VPROPS(dim) && i<$VPROPS(name)Size;i++)\{[set VPROPS(base)]_memIO->client\[LVClient\].shmemOutgoing_[set VPROPS(topic)].$VPROPS(name)\[i\] = (*(data->$VPROPS(name)))->data\[i\];\}
           if (iverbose > 1) \{
             cout << \"Client \" << LVClient << \" Outgoing array $VPROPS(name), size = \" << $VPROPS(name)Size << endl;
           \}
"
      puts $fcod8 "
           int $VPROPS(name)Size = $VPROPS(dim);
           (*(data->$VPROPS(name)))->size = $VPROPS(name)Size;
           for (int i=0;i<$VPROPS(dim);i++)\{(*(data->$VPROPS(name)))->data\[i\] = [set VPROPS(base)]_memIO->client\[LVClient\].shmemIncoming_[set VPROPS(topic)].$VPROPS(name)\[i\];\}
           if (iverbose > 1) \{
             cout << \"Client \" << LVClient << \" Incoming array $VPROPS(topic) $VPROPS(name), size = \" << $VPROPS(name)Size << endl;
           \}
"
      puts $fcod11 "for i in range(0,$VPROPS(dim)):
  myData.$VPROPS(name)\[i\]=i"
      puts $fcod12 "    for (int i=0;i<$VPROPS(dim);i++) \{Outgoing_[set VPROPS(topic)]->$VPROPS(name)\[i\]=[set VPROPS(base)]_memIO->client\[LVClient\].shmemOutgoing_[set VPROPS(topic)].$VPROPS(name)\[i\];\}
           if (iverbose > 1) \{
             cout << \"Outgoing array $VPROPS(topic) $VPROPS(name), size = \" << $VPROPS(dim) << endl;
           \}"
      puts $fcod13 "              for (int i=0;i<$VPROPS(dim);i++) \{[set VPROPS(base)]_memIO->client\[LVClient\].shmemIncoming_[set VPROPS(topic)].$VPROPS(name)\[i\]=Incoming_[set VPROPS(topic)]->$VPROPS(name)\[i\];\}
           if (iverbose > 1) \{
             cout << \"Incoming array $VPROPS(topic) $VPROPS(name), size = \" << $VPROPS(dim) << endl;
           \}"
      set idlim [expr $idx + $VPROPS(dim)]
      set myidx 0
      while { $idx < $idlim } {

        if { $VPROPS(int) }  {
           if { $VPROPS(long) || $VPROPS(longlong) } {
              if { $VPROPS(long) } {
                 puts $fcod5 "    sscanf(argv\[$idx\], \"%ld\", &myData.$VPROPS(name)\[$myidx\]);"
              }
              puts $fcod10 "myData.$VPROPS(name)\[$myidx\] = long(sys.argv\[$idx\])"
           } else {
              if { $VPROPS(short) } {
                 puts $fcod5 "    sscanf(argv\[$idx\], \"%hd\", &myData.$VPROPS(name)\[$myidx\]);"
              } else {
                 if { $VPROPS(byte) } {
                    puts $fcod5 "    sscanf(argv\[$idx\], \"%hhu\", &myData.$VPROPS(name)\[$myidx\]);"
                 } else {
                    puts $fcod5 "    sscanf(argv\[$idx\], \"%d\", &myData.$VPROPS(name)\[$myidx\]);"
                 }
              }
              puts $fcod10 "myData.$VPROPS(name)\[$myidx\] = int(sys.argv\[$idx\])"
           }
        } else {
           if { $VPROPS(double) } {
              puts $fcod5 "    sscanf(argv\[$idx\], \"%lf\", &myData.$VPROPS(name)\[$myidx\]);"
           } else {
              puts $fcod5 "    sscanf(argv\[$idx\], \"%f\", &myData.$VPROPS(name)\[$myidx\]);"
           }
           puts $fcod10 "myData.$VPROPS(name)\[$myidx\] = float(sys.argv\[$idx\])"
        }
        incr idx 1
        incr myidx 1
      }
   } else {
      if { $VPROPS(string) } {
         puts $fcod1 "    data->$VPROPS(name)=Instance.$VPROPS(name);"
         puts $fcod1 "    lastSample_[set VPROPS(topic)].$VPROPS(name)=Instance.$VPROPS(name);"
         puts $fcod1b "   data->$VPROPS(name) = lastSample_[set VPROPS(topic)].$VPROPS(name);"
         if { $VPROPS(dim) > 0 } {
           puts $fcod2b "
    if ( data->$VPROPS(name).length() > $VPROPS(dim) ) \{
         cout << \"=== \[ $VPROPS(topic) \] Item $VPROPS(name) exceeds AVRO string length\" << endl;
         throw std::length_error(\"AVRO String too large\");
    \}"
         }
         puts $fcod2 "    Instance.$VPROPS(name) = data->$VPROPS(name).c_str();"
         puts $fcod3 "    cout << \"    $VPROPS(name) : \" << SALInstance.$VPROPS(name) << endl;"
         puts $fcod4 "    myData.$VPROPS(name)=\"RO\";"
         puts $fcod5 "    myData.$VPROPS(name)=argv\[$idx\];"
         puts $fcod6 "    cout << \"    $VPROPS(name) : \" << data->$VPROPS(name) << endl;"
         if { [lsearch "device property action itemValue" $VPROPS(name)] < 0 } {
              set copydim $VPROPS(dim)
              if { $copydim < 0 } {set copydim 999}
              puts $fcod7 "
           int $VPROPS(name)Size = (*(data->$VPROPS(name)))->size ;
           int i[set VPROPS(name)];
           for (i[set VPROPS(name)]=0;i[set VPROPS(name)]<$copydim && i[set VPROPS(name)]<$VPROPS(name)Size;i[set VPROPS(name)]++)\{[set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_$VPROPS(name)_bufferOut\[i[set VPROPS(name)]\] = (*(data->$VPROPS(name)))->data\[i[set VPROPS(name)]\];\}
           [set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_$VPROPS(name)_bufferOut\[i[set VPROPS(name)]\] = 0;
           if (iverbose > 1) \{
             cout << \"Client \" << LVClient << \" Outgoing string $VPROPS(topic) $VPROPS(name), \" << [set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_$VPROPS(name)_bufferOut << endl;
           \}
"
               puts $fcod8 "
           int $VPROPS(name)Size = strlen([set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_$VPROPS(name)_bufferIn);
           NumericArrayResize(5, 1, (UHandle*)(&(data->$VPROPS(name))), $VPROPS(name)Size);
           (*(data->$VPROPS(name)))->size = $VPROPS(name)Size;
           for (int i=0;i<$VPROPS(name)Size;i++)\{(*(data->$VPROPS(name)))->data\[i\] = [set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_$VPROPS(name)_bufferIn\[i\];\}
           if (iverbose > 1) \{
             cout << \"Client \" << LVClient << \" Incoming string $VPROPS(topic) $VPROPS(name), \" << [set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_$VPROPS(name)_bufferIn << endl;
           \}
"
         }
         puts $fcod10 "myData.$VPROPS(name)=sys.argv\[$idx\]"
         puts $fcod11 "myData.$VPROPS(name)=\"RO\""
         puts $fcod12 "             Outgoing_[set VPROPS(topic)]->[set VPROPS(name)]=[set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_[set VPROPS(name)]_bufferOut;
           if (iverbose > 1) \{
             cout << \"Outgoing $VPROPS(topic) $VPROPS(name) =  \" << Outgoing_[set VPROPS(topic)]->$VPROPS(name) << endl;
           \}"
         puts $fcod13 "             strncpy([set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_[set VPROPS(name)]_bufferIn,Incoming_[set VPROPS(topic)]->[set VPROPS(name)].c_str(),1000);
           if (iverbose > 1) \{
             cout << \"Incoming $VPROPS(topic) $VPROPS(name) =  \" << Incoming_[set VPROPS(topic)]->$VPROPS(name) << endl;
           \}"
      } else {
         puts $fcod1 "    data->$VPROPS(name) = Instance.$VPROPS(name);"
         puts $fcod1 "    lastSample_[set VPROPS(topic)].$VPROPS(name) = Instance.$VPROPS(name);"
         puts $fcod1b "   data->$VPROPS(name) = lastSample_[set VPROPS(topic)].$VPROPS(name);"
         puts $fcod2 "    Instance.$VPROPS(name) = data->$VPROPS(name);"
         puts $fcod3 "    cout << \"    $VPROPS(name) : \" << SALInstance.$VPROPS(name) << endl;"
         puts $fcod6 "    cout << \"    $VPROPS(name) : \" << data->$VPROPS(name) << endl;"
         puts $fcod7 "           [set VPROPS(base)]_memIO->client\[LVClient\].shmemOutgoing_[set VPROPS(topic)].$VPROPS(name) = data->$VPROPS(name);
           if (iverbose > 1) \{
             cout << \"Client \" << LVClient << \" Outgoing $VPROPS(topic) $VPROPS(name) =  \" << data->$VPROPS(name) << endl;
           \}"
         puts $fcod8 "           data->$VPROPS(name) = [set VPROPS(base)]_memIO->client\[LVClient\].shmemIncoming_[set VPROPS(topic)].$VPROPS(name);
           if (iverbose > 1) \{
             cout << \"Client \" << LVClient << \" Incoming $VPROPS(topic) $VPROPS(name) =  \" << data->$VPROPS(name) << endl;
           \}"
         puts $fcod12 "           Outgoing_[set VPROPS(topic)]->$VPROPS(name)=[set VPROPS(base)]_memIO->client\[LVClient\].shmemOutgoing_[set VPROPS(topic)].$VPROPS(name);
           if (iverbose > 1) \{
             cout << \"Outgoing $VPROPS(topic) $VPROPS(name) =  \" << Outgoing_[set VPROPS(topic)]->$VPROPS(name) << endl;
           \}"
         puts $fcod13 "           [set VPROPS(base)]_memIO->client\[LVClient\].shmemIncoming_[set VPROPS(topic)].$VPROPS(name)=Incoming_[set VPROPS(topic)]->$VPROPS(name);
           if (iverbose > 1) \{
             cout << \"Incoming $VPROPS(topic) $VPROPS(name) =  \" << Incoming_[set VPROPS(topic)]->$VPROPS(name) << endl;
           \}"
         if { $VPROPS(int) } {
          puts $fcod11 "myData.$VPROPS(name) = 1";
          if { $VPROPS(long) || $VPROPS(longlong) } {
            puts $fcod4 "    myData.$VPROPS(name) = 1;";
            if { $VPROPS(long) } {
               puts $fcod5 "    sscanf(argv\[$idx\], \"%ld\", &myData.$VPROPS(name));"
            }
            puts $fcod10 "myData.$VPROPS(name)=long(sys.argv\[$idx\])"
          } else {
            puts $fcod4 "    myData.$VPROPS(name) = 1;";
            if { $VPROPS(short) } {
               puts $fcod5 "    sscanf(argv\[$idx\], \"%hd\", &myData.$VPROPS(name));"
            } else {
               if { $VPROPS(byte) } {
                  puts $fcod5 "    sscanf(argv\[$idx\], \"%hhu\", &myData.$VPROPS(name));"
               } else {
                  puts $fcod5 "    sscanf(argv\[$idx\], \"%d\", &myData.$VPROPS(name));"
               }
            }
            puts $fcod10 "myData.$VPROPS(name)=int(sys.argv\[$idx\])"
          }
         } else {
          puts $fcod11 "myData.$VPROPS(name) = 1.0";
          puts $fcod10 "myData.$VPROPS(name)=float(sys.argv\[$idx\])"
          if { $VPROPS(double) } {
            puts $fcod4 "    myData.$VPROPS(name) = 1.0;";
            puts $fcod5 "    sscanf(argv\[$idx\], \"%lf\", &myData.$VPROPS(name));"
          } else {
            puts $fcod4 "    myData.$VPROPS(name) = 1.0;";
            puts $fcod5 "    sscanf(argv\[$idx\], \"%f\", &myData.$VPROPS(name));"
          }
         }
      }
   }
}

#
## Documented proc \c genackcmdincl .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fhdr File handle of output header file
# \param[in] fhlv File handle of output LabVIEW header file
#
#  Generate header fragments defining the 'ackcmd' Topic
#
proc genackcmdincl { subsys fhdr fhlv } {
global OPTIONS
   if { $OPTIONS(verbose) } {stdlog "###TRACE>>> genackcmdincl $subsys $fhdr $fhlv "}
   puts $fhdr "
struct [set subsys]_ackcmdC
\{
      double            private_rcvStamp;
      int               ack;
      int               error;
      std::string       result;
      std::string       identity;
      long              origin;
      long              cmdtype;
      double            timeout;
\};
"
   puts $fhlv "
typedef struct [set subsys]_ackcmdLV \{
      int       cmdSeqNum;
      int       ack;
      int       error;
      StrHdl    result; /* 1000 */
\} [set subsys]_ackcmd_Ctl;
typedef struct [set subsys]_waitCompleteLV \{
      int       cmdSeqNum;
      unsigned int timeout;
\} [set subsys]_waitComplete_Ctl;
"
   if { $OPTIONS(verbose) } {stdlog "###TRACE<<< genackcmdincl $subsys $fhdr $fhlv "}
}


#
## Documented proc \c makesalcmdevt .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] lang Language to generate code for
#
#  Generate code to support the Command and Event Topics
#
proc makesalcmdevt { base lang } {
global SAL_DIR SAL_WORK_DIR SYSDIC DONE_CMDEVT OPTIONS
      if { $OPTIONS(verbose) } {stdlog "###TRACE>>> makesalcmdevt $base $lang "}
      stdlog "Processing $base Types, Commands, and Events in $SAL_WORK_DIR"
      cd $SAL_WORK_DIR
      set frep [open /tmp/sreplace4_[set base][set lang].sal w]
      puts $frep "#!/bin/sh"

      if { $lang == "cpp" } {
        puts $frep "sed \\"
        puts $frep "  -e 's/_SAL_/_[set base]_/g' \\"
        puts $frep "  -e 's/SALSubsys/[set base]/g' \\"
        puts $frep "  -e 's/SALData/[set base]/g' \\"
        if { [info exists SYSDIC($base,keyedID)] } {
            puts $frep "  -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g' \\"
        }
        puts $frep "$SAL_DIR/code/templates/Makefile.sacpp_SALKafka_testcommands.template > [set base]/cpp/src/Makefile.sacpp_[set base]_testcommands"

        puts $frep "sed \\"
        puts $frep "  -e 's/_SAL_/_[set base]_/g' \\"
        puts $frep "  -e 's/SALSubsys/[set base]/g' \\"
        puts $frep "  -e 's/SALData/[set base]/g' \\"
        if { [info exists SYSDIC($base,keyedID)] } {
            puts $frep "  -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g' \\"
        }
        puts $frep "$SAL_DIR/code/templates/Makefile.sacpp_SALKafka_testevents.template > [set base]/cpp/src/Makefile.sacpp_[set base]_testevents"
      }

      close $frep
      exec chmod 755 /tmp/sreplace4_[set base][set lang].sal
      catch { set result [exec /tmp/sreplace4_[set base][set lang].sal] } bad
      if { $bad != "" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog "###TRACE<<< makesalcmdevt $base $lang "}
}


#
## Documented proc \c makesalcode .
# \param[in] jsonfile Name of input Json definition file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] name Name of SAL Topic
# \param[in] lang Target language for code generation
#
#   Generate the base SAL API code
#
proc makesalcode { jsonfile base name lang } {
global SAL_DIR SAL_WORK_DIR SYSDIC DONE_CMDEVT OPTIONS CMD_ALIASES AVRO_PREFIX
      if { $OPTIONS(verbose) } {stdlog "###TRACE>>> makesalcode $jsonfile $base $name $lang"}
      stdlog "Processing $base $name in $SAL_WORK_DIR"
      cd $SAL_WORK_DIR
      catch {makesaldirs $base $name}
      set id [set base]_[set name]
      set frep [open /tmp/sreplace_[set base][set lang].sal w]
      puts $frep "#!/bin/sh"
      if { $lang == "cpp" } {
        puts $frep "sed \\"
        puts $frep "  -e 's/sacpp_SAL_types/sacpp_[set base]_types/g' \\"
        puts $frep "  -e 's/_SAL_/_[set id]_/g' \\"
        puts $frep "$SAL_DIR/code/templates/Makefile-cppKafka.template > [set id]/cpp/standalone/Makefile"
        if { $name != "notused" } {
          puts $frep "sed \\"
          puts $frep "  -e 's/_SAL_/_[set base]_/g' \\"
          puts $frep "  -e 's/SALSubsys/[set base]/g' \\"
          puts $frep "  -e 's/SALData/[set id]/g' \\"
          if { [info exists SYSDIC($base,keyedID)] } {
            puts $frep "  -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g' \\"
          }
          puts $frep "$SAL_DIR/code/templates/Makefile.sacpp_SALKafka_sub.template > [set id]/cpp/standalone/Makefile.sacpp_[set id]_sub"

          puts $frep "sed \\"
          puts $frep "  -e 's/_SAL_/_[set base]_/g' \\"
          puts $frep "  -e 's/SALSubsys/[set base]/g' \\"
          puts $frep "  -e 's/SALData/[set id]/g' \\"
          if { [info exists SYSDIC($base,keyedID)] } {
            puts $frep "  -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g' \\"
          }
          puts $frep "$SAL_DIR/code/templates/Makefile.sacpp_SALKafka_pub.template > [set id]/cpp/standalone/Makefile.sacpp_[set id]_pub"
        }

        if { $name != "notused" } {
          modpubsubexamples $id
          puts $frep "sed -i -e 's/SALTopic/[set name]/g' [set id]/cpp/src/[set id]DataPublisher.cpp"
          puts $frep "sed -i -e 's/SALNAMESTRING/[set base]_[set name]/g' [set id]/cpp/src/[set id]DataPublisher.cpp"
          puts $frep "sed -i -e 's/SALSTRUCTSTRING/[set base]_[set name]/g' [set id]/cpp/src/[set id]DataPublisher.cpp"
          puts $frep "sed -i -e 's/SALData/$base/g' [set id]/cpp/src/[set id]DataPublisher.cpp"
          puts $frep "sed -i -e 's/SALTopic/[set name]/g' [set id]/cpp/src/[set id]DataSubscriber.cpp"
          puts $frep "sed -i -e 's/SALNAMESTRING/[set base]_[set name]/g' [set id]/cpp/src/[set id]DataSubscriber.cpp"
          puts $frep "sed -i -e 's/SALSTRUCTSTRING/[set base]_[set name]/g' [set id]/cpp/src/[set id]DataSubscriber.cpp"
          puts $frep "sed -i -e 's/SALData/$base/g' [set id]/cpp/src/[set id]DataSubscriber.cpp"
        }
      }

      if { $lang == "java"}  {
        puts $frep "sed \\"
        puts $frep "  -e 's/saj_SAL_types/saj_[set base]_types/g' \\"
        puts $frep "  -e 's/_SAL_/_[set id]_/g' \\"
        puts $frep "  -e 's/SALData/[set base]/g' \\"
        puts $frep "$SAL_DIR/code/templates/Makefile.saj_SAL_Kafkatypes.template > [set base]/java/src/Makefile.saj_[set base]_types"
        if { $name != "notused" } {
          puts $frep "sed \\"
          puts $frep "  -e 's/_SAL_/_[set id]_/g' \\"
          puts $frep "  -e 's/SALTopic/[set id]/g' \\"
          puts $frep "  -e 's/SALData/[set base]/g' \\"
          puts $frep "$SAL_DIR/code/templates/Makefile.saj_SAL_Kafkapub.template > [set id]/java/standalone/Makefile.saj_[set id]_pub"

          puts $frep "sed \\"
          puts $frep "  -e 's/_SAL_/_[set id]_/g' \\"
          puts $frep "  -e 's/SALTopic/[set id]/g' \\"
          puts $frep "  -e 's/SALData/[set base]/g' \\"
          puts $frep "$SAL_DIR/code/templates/Makefile.saj_SAL_Kafkasub.template > [set id]/java/standalone/Makefile.saj_[set id]_sub"

          puts $frep "sed \\"
          if { [info exists SYSDIC($base,keyedID)] } {
            puts $frep "  -e 's/SALSUBSYSID/aKey/g' \\"
          } else {
            puts $frep "  -e 's/SALSUBSYSID//g' \\"
          }
          puts $frep "  -e 's/SAL_SALData/SAL_[set base]/g' \\"
          puts $frep "  -e 's/SALData.SALTopic/[set name]/g' \\"
          puts $frep "  -e 's/SALData./[getAvroNamespace][set base]./g' \\"
          puts $frep "  -e 's/SALNAMESTRING/[set id]/g' \\"
          puts $frep "$SAL_DIR/code/templates/SALTopicDataPublisher.java.template > [set id]/java/src/[set id]DataPublisher.java"

          puts $frep "sed \\"
          if { [info exists SYSDIC($base,keyedID)] } {
            puts $frep "  -e 's/SALSUBSYSID/aKey/g' \\"
          } else {
            puts $frep "  -e 's/SALSUBSYSID//g' \\"
          }
          puts $frep "  -e 's/SAL_SALData/SAL_[set base]/g' \\"
          puts $frep "  -e 's/SALData.SALTopic/[set name]/g' \\"
         puts $frep "  -e 's/SALData./[getAvroNamespace][set base]./g' \\"
          puts $frep "  -e 's/SALNAMESTRING/[set id]/g' \\"
          puts $frep "$SAL_DIR/code/templates/SALTopicDataSubscriber.java.template > [set id]/java/src/[set id]DataSubscriber.java"
        }
        exec cp $SAL_DIR/code/templates/ErrorHandlerKafka.java [set id]/java/src/ErrorHandler.java
        exec cp $SAL_DIR/code/templates/ErrorHandlerKafka.java [set base]/java/src/ErrorHandler.java

        puts $frep "sed \\"
        puts $frep "  -e 's/SALTopic/[set id]/g' \\"
        puts $frep "  -e 's/SALData/$base/g' \\"
        puts $frep "  -e 's/_SAL_/_[set id]_/g' \\"
        puts $frep "$SAL_DIR/code/templates/runsample.template > [set id]/java/standalone/[set id].run"
      }
      close $frep
      exec chmod 755 /tmp/sreplace_[set base][set lang].sal
      catch { set result [exec /tmp/sreplace_[set base][set lang].sal] } bad
      if { $bad != "" } {stdlog $bad}
##      if { $name != "notused" } {
        stdlog "calling addSALKAFKAtypes $id $lang $base"
        checkTopicTypes $base
        addSALKAFKAtypes $id $lang $base
        stdlog "done addSALKAFKAtypes $id $lang $base"
##      }
      if { $lang == "cpp" } {
        set frep [open /tmp/sreplace2_[set base][set lang].sal w]
        puts $frep "#!/bin/sh"

        puts $frep "sed -i -e 's/SALData/$base/g' [set base]/cpp/src/SAL_[set base].h"
        puts $frep "sed -i -e 's/SALData/$base/g' [set base]/cpp/src/SAL_[set base].cpp"
        if { [info exists CMD_ALIASES($base)] } {
          set revcode [getRevCode [set base]_ackcmd short]
          puts $frep "sed -i -e 's/SALResponse/$base\:\:ackcmd[set revcode]/g' [set base]/cpp/src/SAL_[set base].cpp"
        }
        close $frep
        exec chmod 755 /tmp/sreplace2_[set base][set lang].sal
        catch { set result [exec /tmp/sreplace2_[set base][set lang].sal] } bad
        stdlog "done sreplace2 $jsonfile $id $lang"
      }
      if { $lang == "java" } {
        set frep [open /tmp/sreplace2_[set base][set lang].sal w]
        puts $frep "#!/bin/sh"

        puts $frep "sed -i -e 's/SALData/$base/g' [set id]/java/src/org/lsst/sal/SAL_[set base].java"
        puts $frep "sed -i -e 's/SALData/$base/g' [set base]/java/src/org/lsst/sal/SAL_[set base].java"
        if { [info exists CMD_ALIASES($base)] } {
          set revcode [getRevCode [set base]_ackcmd short]
          puts $frep "sed -i -e 's/SALResponse/ackcmd[set revcode]/g' [set id]/java/src/org/lsst/sal/SAL_[set base].java"
          puts $frep "sed -i -e 's/SALResponse/ackcmd[set revcode]/g' [set base]/java/src/org/lsst/sal/SAL_[set base].java"
        }
        close $frep
        exec chmod 755 /tmp/sreplace2_[set base][set lang].sal
        catch { set result [exec /tmp/sreplace2_[set base][set lang].sal] } bad
      }
      if { $lang == "cpp" } {
         exec ln -sf $SAL_WORK_DIR/[set base]/cpp/src/SAL_[set base].cpp $SAL_WORK_DIR/[set id]/cpp/src/.
         exec ln -sf $SAL_WORK_DIR/[set base]/cpp/src/SAL_[set base].h $SAL_WORK_DIR/[set id]/cpp/src/.
         salcpptestgen $base $id
      }
      if { $lang == "java" } {
         if { [llength [split $base "_"]] == 1  } {
           salavrogen $base java
           exec cp [set base]/java/src/saj_[set base]_types.jar $SAL_WORK_DIR/lib/.
           exec cp [set base]/java/src/SAL_[set base].jar $SAL_WORK_DIR/lib/.
         }
         saljavaclassgen $base $id
      }
      if { $OPTIONS(verbose) } {stdlog "###TRACE<<< makesalcode $jsonfile $base $name $lang"}
}


#
## Documented proc \c salavrogen .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] lang Language to generate code for
#
#  Generate Avro files for a Subsystem/CSC
#
proc salavrogen { base lang } {
global SAL_WORK_DIR OPTIONS ONEDONECPP ONEDONEJAVA SAL_DIR AVRO_RELEASE
   if { $OPTIONS(verbose) } {stdlog "###TRACE>>> salavrogen $base $lang"}
       cd $SAL_WORK_DIR/$base/$lang
       stdlog "Generating $lang type support for $base"
       if { $lang == "cpp" && $ONEDONECPP == 0} {
          set all [glob $SAL_WORK_DIR/avro-templates/[set base]/[set base]_*.json]
          foreach i $all {
            if { [lindex [split [file tail $i] ._] 2] != "enums" } {
             if { [file tail $i] != "[set base]_hash_table.json" } {
              puts stdout "Processing $i"
              exec avrogencpp -i $i -o $SAL_WORK_DIR/[set base]/cpp/src/[file rootname [file tail $i]].hh -n $base
             }
            }
          }
          set ONEDONECPP 1
       }
       if { $lang == "java" && $ONEDONEJAVA == 0} {
          set all [glob $SAL_WORK_DIR/avro-templates/[set base]/[set base]_*.json]
          foreach i $all {
            if { [lindex [split [file tail $i] ._] 2] != "enums" } {
             if { [file tail $i] != "[set base]_hash_table.json" } {
              puts stdout "Processing $i"
              catch {exec java -jar $SAL_DIR/../lib/avro-tools-[set AVRO_RELEASE].jar compile schema $i $SAL_WORK_DIR/[set base]/java/src/}
             }
            }
          }
          catch {exec java -jar $SAL_DIR/../lib/avro-tools-[set AVRO_RELEASE].jar compile schema $SAL_WORK_DIR/avro-templates/[set base]/[set base]_ackcmd.json $SAL_WORK_DIR/[set base]/java/src/}
          cd $SAL_WORK_DIR/$base/$lang/src
          set result none
          catch { set result [exec make -f Makefile.saj_[set base]_types] } bad
          catch {stdlog "result = $result"}
          catch {stdlog "$bad"}
          stdlog "Avro : Java type support code generated"
          set ONEDONEJAVA 1
      }
      cd $SAL_WORK_DIR
   if { $OPTIONS(verbose) } {stdlog "###TRACE<<< salavrogen $base $lang"}
}



#
## Documented proc \c saljavaclassgen .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] id Topic identifier
#
#  Generate Java class file for a SAL Topic
#
proc saljavaclassgen { base id } {
global SAL_WORK_DIR OPTIONS
 if { $OPTIONS(verbose) } {stdlog "###TRACE>>> saljavaclassgen $base $id"}
 if { $OPTIONS(fastest) == 0 } {
   cd $SAL_WORK_DIR/$base/java/src
   set result none
   stdlog "javac : Done types"
   if { $id != "[set base]_notused" } {
    cd $SAL_WORK_DIR/$id/java/standalone
    set result none
    catch { set result [exec make -f Makefile.saj_[set id]_pub] } bad
    catch {stdlog "result = $result"}
    catch {stdlog "$bad"}
    stdlog "javac : Done Publisher"
    catch { set result [exec make -f Makefile.saj_[set id]_sub] } bad
    catch {stdlog "result = $result"}
    catch {stdlog "$bad"}
    stdlog "javac : Done Subscriber"
    cd $SAL_WORK_DIR
  }
 }
 if { $OPTIONS(verbose) } {stdlog "###TRACE<<< saljavaclassgen $base $id"}
}

#
## Documented proc \c salcppclassgen .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] id Topic identifier
#
#  Generate C++ test program for a SAL Topic
#
proc salcpptestgen { base id } {
global SAL_WORK_DIR SAL_DIR OPTIONS DONE_CMDEVT
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> salcpptestgen $base $id"}
  if { $OPTIONS(fastest) == 0 } {
    if { $id != "[set base]_notused" } {
     stdlog "Generating cpp test programs for $id"
     cd $SAL_WORK_DIR/$id/cpp/standalone
     catch { set result [exec make -f Makefile.sacpp_[set id]_sub] } bad
     catch {stdlog "result = $result"}
     catch {stdlog "$bad"}
     stdlog "cpp : Done Subscriber"
     catch { set result [exec make -f Makefile.sacpp_[set id]_pub] } bad
     catch {stdlog "result = $result"}
     catch {stdlog "$bad"}
     stdlog "cpp : Done Publisher"
    }
  }
  if { $DONE_CMDEVT == 0 && $OPTIONS(fastest) == 0 } {
   cd $SAL_WORK_DIR/$base/cpp/src
   catch { exec make -f Makefile.sacpp_[set base]_testcommands all } bad
   catch {stdlog "result = $result"}
   catch {stdlog "$bad"}
   stdlog "cpp : Done Commander"
   catch { exec make -f Makefile.sacpp_[set base]_testevents all } bad
   catch {stdlog "result = $result"}
   catch {stdlog "$bad"}
   stdlog "cpp : Done Event/Logger"
   set DONE_CMDEVT 1
   if { $base == "Test" } {
      exec cp $SAL_DIR/code/templates/Makefile.sacpp_KafkaTestWithSalobj $SAL_WORK_DIR/$base/cpp/src/.
      exec cp $SAL_DIR/code/templates/sacpp_TestWithSalobj.cpp $SAL_WORK_DIR/$base/cpp/src/.
      exec cp $SAL_DIR/code/templates/sacpp_TestWithSalobjTarget.cpp $SAL_WORK_DIR/$base/cpp/src/.
      cd $SAL_WORK_DIR/$base/cpp/src
      exec make -f Makefile.sacpp_KafkaTestWithSalobj
   }
   cd $SAL_WORK_DIR
  }
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< salcpptestgen $base $id"}
}

source $SAL_DIR/add_system_dictionary.tcl
source $SAL_DIR/gensalgetputKafka.tcl
source $SAL_DIR/managetypesKafka.tcl
source $SAL_DIR/activaterevcodesKafka.tcl
source $SAL_DIR/add_private_json.tcl
source $SAL_DIR/checkjson.tcl


