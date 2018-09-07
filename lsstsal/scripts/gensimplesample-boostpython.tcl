#!/usr/bin/env tclsh
#
#  Generate simple pub/sub programs for each data type in cpp and java
#
proc makesaldirs { base name } {
global SAL_WORK_DIR
   exec mkdir -p $SAL_WORK_DIR/[set base]_[set name]/python
   exec mkdir -p $SAL_WORK_DIR/[set base]_[set name]/cpp/src
   exec mkdir -p $SAL_WORK_DIR/[set base]_[set name]/cpp/standalone
   exec mkdir -p $SAL_WORK_DIR/[set base]_[set name]/isocpp
   exec mkdir -p $SAL_WORK_DIR/[set base]_[set name]/java/src/org/lsst/sal
   exec mkdir -p $SAL_WORK_DIR/[set base]_[set name]/java/src/org/lsst/sal/$base/$name
###   exec mkdir -p $SAL_WORK_DIR/SAL_[set base]/java/src/org/lsst/sal
   exec mkdir -p $SAL_WORK_DIR/[set base]/java/src
   exec mkdir -p $SAL_WORK_DIR/[set base]/java/src/org/lsst/sal
   exec mkdir -p $SAL_WORK_DIR/[set base]/cpp/src
   exec mkdir -p $SAL_WORK_DIR/[set base]/isocpp/src
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
###   exec mkdir -p $SAL_WORK_DIR/SAL_[set base]/cpp/src
   exec ln -sf $SAL_WORK_DIR/idl-templates/validated/sal/sal_$base.idl $SAL_WORK_DIR/$base/cpp/.
   exec ln -sf $SAL_WORK_DIR/idl-templates/validated/sal/sal_$base.idl $SAL_WORK_DIR/$base/isocpp/.
   exec ln -sf $SAL_WORK_DIR/idl-templates/validated/sal/sal_$base.idl $SAL_WORK_DIR/$base/java/.
   exec touch $SAL_WORK_DIR/[set base]/cpp/.depend.Makefile.sacpp_[set base]_types
   exec touch $SAL_WORK_DIR/[set base]/java/.depend.Makefile.saj_[set base]_types
   exec touch $SAL_WORK_DIR/[set base]/isocpp/.depend.Makefile.ISO_Cxx_[set base]_types
}


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



proc makesalidl { subsys } {
global SAL_DIR SAL_WORK_DIR SYSDIC VPROPS
   set all [lsort [glob $SAL_WORK_DIR/idl-templates/validated/[set subsys]_*.idl]]
   exec mkdir -p $SAL_WORK_DIR/idl-templates/validated/sal
   set fout [open $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl w]
   exec mkdir -p $SAL_WORK_DIR/[set subsys]/cpp/src
   set fhdr [open $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]C.h w]
   set fhlv [open $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]LV.h w]
   addlvtypes $fhlv
   puts $fhdr "
#ifndef _SAL_[set subsys]C_
#define _SAL_[set subsys]C_

#include <string>

using namespace std;
"
   set fbst [open $SAL_WORK_DIR/include/SAL_[set subsys]C.bp w]
   set fbst2 [open $SAL_WORK_DIR/include/SAL_[set subsys]C.bp2 w]
   puts $fout "module $subsys \{"
   foreach i $all {
      puts stdout "Adding $i to sal_$subsys.idl"
      set fin [open $i r]
      gets $fin rec
      set name [join [lrange [split [file rootname [file tail $i]] _] 1 end] _]
      set VPROPS(iscommand) 0
      if { [string range $name 0 7] == "command_" } {set VPROPS(iscommand) 1}
      set fcod1 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Cget.tmp w]
      set fcod2 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Cput.tmp w]
      set fcod3 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Csub.tmp w]
      set fcod4 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Cpub.tmp w]
      set fcod5 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Cargs.tmp w]
      set fcod6 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Cout.tmp w]
      set fcod7 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]shmout.tmp w]
      set fcod8 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]shmin.tmp w]
      set fcod10 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Pargs.tmp w]
      set fcod11 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Ppub.tmp w]
      set fcod12 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]monout.tmp w]
      set fcod13 [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]monin.tmp w]
      puts $fout "	struct $name \{"
      puts $fhdr "struct [set subsys]_[set name]C
\{"
      puts $fhlv "typedef struct [set subsys]_[set name]LV \{"
      puts $fbst "   bp::class_<[set subsys]_[set name]C>(\"[set subsys]_[set name]C\")"
      if {[string range $name 0 7] != "command_" && [string range $name 0 8] != "logevent_"}  {
        puts $fbst2 "
  .def(
        \"getSample_[set name]\" ,  &::SAL_[set subsys]::getSample_[set name] )
  .def(
        \"getNextSample_[set name]\" ,  &::SAL_[set subsys]::getNextSample_[set name] )
  .def(
      \"putSample_[set name]\" ,  &::SAL_[set subsys]::putSample_[set name] )"
      }
      if { [info exists SYSDIC($subsys,keyedID)] } {
          puts $fout "	  short	[set subsys]ID;"
      }
      set argidx 1
      while { [gets $fin rec] > -1 } {
         if { [lindex $rec 0] == "#pragma" } {
            if { [info exists SYSDIC($subsys,keyedID)] } {
               puts $fout "	#pragma keylist $name [set subsys]ID"
            } else {
               puts $fout "	#pragma keylist $name"
            }
            puts $fhdr "
#ifdef SAL_DEBUG_CSTRUCTS
  [set subsys]_[set name]C()  \{ std::cout << \"[set subsys]_[set name]C()\"  << std::endl; \}
  ~[set subsys]_[set name]C() \{ std::cout << \"~[set subsys]_[set name]C()\"  << std::endl; \}
#endif
\};
"
           puts $fhlv "\} [set subsys]_[set name]_Ctl;"
           puts $fbst "      ;"
         } else {
            puts $fout "	$rec"
            if { [lindex $rec 0] != "const" } {
             if { [string range [lindex $rec 1] 0 7] != "private_" && [llength $rec] > 1 } {
               puts $fhdr [typeidltoc $rec]
               if { $VPROPS(iscommand) } {
                  if { [lsearch "device property action value" $VPROPS(name)] < 0 } {
                     puts $fhlv [typeidltolv $rec]
                  }
               } else {
                  puts $fhlv [typeidltolv $rec]
               }
               set VPROPS(idx) $argidx
               set VPROPS(base) $subsys
               set VPROPS(topic) "[set subsys]_[set name]"
               updatecfragments $fcod1 $fcod2 $fcod3 $fcod4 $fcod5 $fcod6 $fcod7 $fcod8 $fcod10 $fcod11 $fcod12 $fcod13
               set vname $VPROPS(name)
               if { $VPROPS(array) } {
                  puts $fbst "      .add_property(\"$vname\", make_array(&[set subsys]_[set name]C::$vname))"
               } else {
                  puts $fbst "      .def_readwrite(\"$vname\", &[set subsys]_[set name]C::$vname)"
               }
               if { $VPROPS(array) } {
                 incr argidx $VPROPS(dim)
               } else {
                 incr argidx 1
               }
             }
            }
         }
      }
      close $fin
      close $fcod1
      close $fcod2
      close $fcod3
      close $fcod4
      close $fcod5
      close $fcod6
      close $fcod7
      close $fcod8
      close $fcod10
      close $fcod11
   }
   if { [info exists SYSDIC($subsys,keyedID)] } {
       genkeyedidl $fout $subsys
   } else {
     puts $fout "	struct command
	\{
      string<32>	private_revCode;
      double		private_sndStamp;
      double		private_rcvStamp;
      long		private_origin;
      long 		private_host;
      long		private_seqNum;
      string<32>	device;
      string<32>	property;
      string<32>	action;
      string<32>	value;
      string<128>	modifiers;
	\};
	#pragma keylist command
	struct ackcmd
	\{
      string<32>	private_revCode;
      double		private_sndStamp;
      double		private_rcvStamp;
      long		private_origin;
      long 		private_host;
      long		private_seqNum;
      long 		ack;
      long 		error;
      string<256>	result;
	\};
	#pragma keylist ackcmd
	struct logevent
	\{
      string<32>	private_revCode;
      double		private_sndStamp;
      double		private_rcvStamp;
      long		private_origin;
      long 		private_host;
      string<128>	message;
	\};
	#pragma keylist logevent"
     puts $fout "\};
"
   }
   puts $fhdr "
struct [set subsys]_commandC
\{
      std::string	device;
      std::string	property;
      std::string	action;
      std::string	value;
      std::string	modifiers;

\};
struct [set subsys]_ackcmdC
\{
      int 	ack;
      int 	error;
      std::string	result;

\};
struct [set subsys]_logeventC
\{
      std::string	message;

\};

#endif
"
   puts $fhlv "
typedef struct [set subsys]_ackcmdLV
\{
      int       cmdSeqNum;
      int 	ack;
      int 	error;
      StrHdl	result; /* 256 */
\} [set subsys]_ackcmd_Ctl;
typedef struct [set subsys]_waitCompleteLV
\{
      int       cmdSeqNum;
      unsigned int timeout;
\} [set subsys]_waitComplete_Ctl;
"
   close $fout
   close $fhdr
   close $fhlv
   close $fbst
   close $fbst2
   return $SAL_WORK_DIR/idl-templates/validated/sal/sal_$subsys.idl
}

proc updatecfragments { fcod1 fcod2 fcod3 fcod4 fcod5 fcod6 fcod7 fcod8 fcod10 fcod11 fcod12 fcod13 } {
global VPROPS TYPEFORMAT
   set idx $VPROPS(idx)
   if { $VPROPS(iscommand) } {set idx [expr $idx - 4]}
   if { $VPROPS(array) } {
      puts $fcod1 "    for (int iseq=0;iseq<$VPROPS(dim);iseq++) \{data->$VPROPS(name)\[iseq\] = Instances\[j\].$VPROPS(name)\[iseq\];\}"
      puts $fcod2 "    for (int iseq=0;iseq<$VPROPS(dim);iseq++) \{Instance.$VPROPS(name)\[iseq\] = data->$VPROPS(name)\[iseq\];\}"
      puts $fcod3 "       cout << \"    $VPROPS(name) : \" << SALInstance.$VPROPS(name)\[0\] << endl;"
      puts $fcod4 "    for (int i=0;i<$VPROPS(dim);i++)\{myData.$VPROPS(name)\[i\] = i+iseq;\}"
      puts $fcod6 "       cout << \"    $VPROPS(name) : \" << data->$VPROPS(name)\[0\] << endl;"
      puts $fcod7 "
           int $VPROPS(name)Size = (*(data->$VPROPS(name)))->size ;
           for (int i=0;i<$VPROPS(dim) && i<$VPROPS(name)Size;i++)\{[set VPROPS(base)]_memIO->client\[LVClient\].shmemOutgoing_[set VPROPS(topic)].$VPROPS(name)\[i\] = (*(data->$VPROPS(name)))->data\[i\];\}"
      puts $fcod8 "
           int $VPROPS(name)Size = $VPROPS(dim);
           (*(data->$VPROPS(name)))->size = $VPROPS(name)Size;
           for (int i=0;i<$VPROPS(dim);i++)\{(*(data->$VPROPS(name)))->data\[i\] = [set VPROPS(base)]_memIO->client\[LVClient\].shmemIncoming_[set VPROPS(topic)].$VPROPS(name)\[i\];\}"
      puts $fcod11 "for i in range(0,$VPROPS(dim)):
  myData.$VPROPS(name)\[i\]=i"
      puts $fcod12 "    for (int i=0;i<$VPROPS(dim);i++) \{Outgoing_[set VPROPS(topic)]->$VPROPS(name)\[i\]=[set VPROPS(base)]_memIO->client\[LVClient\].shmemOutgoing_[set VPROPS(topic)].$VPROPS(name)\[i\];\}"
      puts $fcod13 "    for (int i=0;i<$VPROPS(dim);i++) \{[set VPROPS(base)]_memIO->client\[LVClient\].shmemIncoming_[set VPROPS(topic)].$VPROPS(name)\[i\]=Incoming_[set VPROPS(topic)]->$VPROPS(name)\[i\];\}"
      set idlim [expr $idx + $VPROPS(dim)]
      set myidx 0
      while { $idx < $idlim } {

        if { $VPROPS(int) }  {
           if { $VPROPS(long) || $VPROPS(longlong) } {
              if { $VPROPS(long) } {
                 puts $fcod5 "    sscanf(argv\[$idx\], \"%ld\", &myData.$VPROPS(name)\[$myidx\]);"
              } else {
                 puts $fcod5 "    sscanf(argv\[$idx\], \"%lld\", &myData.$VPROPS(name)\[$myidx\]);"
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
         puts $fcod1 "    data->$VPROPS(name)=Instances\[j\].$VPROPS(name).m_ptr;"
         puts $fcod2 "    Instance.$VPROPS(name) = DDS::string_dup(data->$VPROPS(name).c_str());"
         puts $fcod3 "    cout << \"    $VPROPS(name) : \" << SALInstance.$VPROPS(name) << endl;"
         puts $fcod4 "    myData.$VPROPS(name)=\"LSST\";"
         puts $fcod5 "    myData.$VPROPS(name)=argv\[$idx\];"
         puts $fcod6 "    cout << \"    $VPROPS(name) : \" << data->$VPROPS(name) << endl;"
         if { [lsearch "device property action value" $VPROPS(name)] < 0 } {
              puts $fcod7 "
           int $VPROPS(name)Size = (*(data->$VPROPS(name)))->size ;
           int i[set VPROPS(name)];
           for (i[set VPROPS(name)]=0;i[set VPROPS(name)]<$VPROPS(dim)-1 && i[set VPROPS(name)]<$VPROPS(name)Size;i[set VPROPS(name)]++)\{[set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_$VPROPS(name)_bufferOut\[i[set VPROPS(name)]\] = (*(data->$VPROPS(name)))->data\[i[set VPROPS(name)]\];\}
           [set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_$VPROPS(name)_bufferOut\[i[set VPROPS(name)]\] = 0;"
               puts $fcod8 "
           int $VPROPS(name)Size = strlen([set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_$VPROPS(name)_bufferIn);
           NumericArrayResize(5, 1, (UHandle*)(&(data->$VPROPS(name))), $VPROPS(name)Size);
           (*(data->$VPROPS(name)))->size = $VPROPS(name)Size;
           for (int i=0;i<$VPROPS(name)Size;i++)\{(*(data->$VPROPS(name)))->data\[i\] = [set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_$VPROPS(name)_bufferIn\[i\];\}"
         }
         puts $fcod10 "myData.$VPROPS(name)=sys.argv\[$idx\]"
         puts $fcod11 "myData.$VPROPS(name)=\"LSST\""
         if { [lsearch "device property action value" $VPROPS(name)] < 0 } {
               puts $fcod12 "             Outgoing_[set VPROPS(topic)]->[set VPROPS(name)]=[set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_[set VPROPS(name)]_bufferOut;"
               puts $fcod13 "             strcpy([set VPROPS(base)]_memIO->client\[LVClient\].[set VPROPS(topic)]LV_[set VPROPS(name)]_bufferIn,Incoming_[set VPROPS(topic)]->[set VPROPS(name)].c_str());"
         }
      } else {
         puts $fcod1 "    data->$VPROPS(name) = Instances\[j\].$VPROPS(name);"
         puts $fcod2 "    Instance.$VPROPS(name) = data->$VPROPS(name);"
         puts $fcod3 "    cout << \"    $VPROPS(name) : \" << SALInstance.$VPROPS(name) << endl;"
         puts $fcod6 "    cout << \"    $VPROPS(name) : \" << data->$VPROPS(name) << endl;"
         puts $fcod7 "           [set VPROPS(base)]_memIO->client\[LVClient\].shmemOutgoing_[set VPROPS(topic)].$VPROPS(name) = data->$VPROPS(name);"
         puts $fcod8 "           data->$VPROPS(name) = [set VPROPS(base)]_memIO->client\[LVClient\].shmemIncoming_[set VPROPS(topic)].$VPROPS(name);"
         puts $fcod12 "           Outgoing_[set VPROPS(topic)]->$VPROPS(name)=[set VPROPS(base)]_memIO->client\[LVClient\].shmemOutgoing_[set VPROPS(topic)].$VPROPS(name);"
         puts $fcod13 "           [set VPROPS(base)]_memIO->client\[LVClient\].shmemIncoming_[set VPROPS(topic)].$VPROPS(name)=Incoming_[set VPROPS(topic)]->$VPROPS(name);"
         if { $VPROPS(int) } {
          puts $fcod11 "myData.$VPROPS(name) = 1";
          if { $VPROPS(long) || $VPROPS(longlong) } {
            puts $fcod4 "    myData.$VPROPS(name) = 1;";
            if { $VPROPS(long) } {
               puts $fcod5 "    sscanf(argv\[$idx\], \"%ld\", &myData.$VPROPS(name));"
            } else {
               puts $fcod5 "    sscanf(argv\[$idx\], \"%lld\", &myData.$VPROPS(name));"
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

proc genkeyedidl { fout base } {
     puts $fout "	struct command
	\{
	  string<32>	private_revCode;
	  double	private_sndStamp;
	  double	private_rcvStamp;
	  long		private_origin;
	  long 		private_host;
	  long		private_seqNum;
	  short	[set base]ID;
	  string<32>	device;
	  string<32>	property;
	  string<32>	action;
	  string<32>	value;
	  string<128>	modifiers;
	\};
	#pragma keylist command [set base]ID
	struct ackcmd
	\{
	  string<32>	private_revCode;
	  double	private_sndStamp;
	  double	private_rcvStamp;
	  long		private_origin;
	  long 		private_host;
	  long		private_seqNum;
	  short	[set base]ID;
	  long 		ack;
	  long 		error;
	  string<256>	result;
	\};
	#pragma keylist ackcmd [set base]ID
	struct logevent
	\{
	  string<32>	private_revCode;
	  double	private_sndStamp;
	  double	private_rcvStamp;
	  long		private_origin;
	  long 		private_host;
	  long		private_seqNum;
	  short	[set base]ID;
	  string<128>	message;
	\};
	#pragma keylist logevent [set base]ID"
     puts $fout "\};
"
}


proc makesalcode { idlfile base name lang } {
global SAL_DIR SAL_WORK_DIR SYSDIC ONEPYTHON
      puts stdout "Processing $base $name in $SAL_WORK_DIR"
      cd $SAL_WORK_DIR
      catch {makesaldirs $base $name}
      set id [set base]_[set name]
      set frep [open /tmp/sreplace.sal w]
      puts $frep "#!/bin/sh"
      if { $lang == "cpp" } {
        exec cp $SAL_DIR/code/templates/SAL_defines.h $SAL_DIR/../include/.
        exec cp $SAL_DIR/code/templates/Makefile-cpp.template [set id]/cpp/standalone/Makefile
        puts $frep "perl -pi -w -e 's/sacpp_SAL_types/sacpp_[set base]_types/g;' [set id]/cpp/standalone/Makefile"
        puts $frep "perl -pi -w -e 's/_SAL_/_[set id]_/g;' [set id]/cpp/standalone/Makefile"
        exec cp $SAL_DIR/code/templates/Makefile.sacpp_SAL_types.template [set base]/cpp/Makefile.sacpp_[set base]_types
        puts $frep "perl -pi -w -e 's/SALDATA.idl/[file tail $idlfile]/g;' [set base]/cpp/Makefile.sacpp_[set base]_types"
        puts $frep "perl -pi -w -e 's/SALData/sal_[set base]/g;' [set base]/cpp/Makefile.sacpp_[set base]_types"
        puts $frep "perl -pi -w -e 's/sacpp_SAL_types/sacpp_[set base]_types/g;' [set base]/cpp/Makefile.sacpp_[set base]_types"
        exec cp $SAL_DIR/code/templates/Makefile.sacpp_SAL_sub.template [set id]/cpp/standalone/Makefile.sacpp_[set id]_sub
        puts $frep "perl -pi -w -e 's/_SAL_/_[set base]_/g;' [set id]/cpp/standalone/Makefile.sacpp_[set id]_sub"
        puts $frep "perl -pi -w -e 's/SALSubsys/[set base]/g;' [set id]/cpp/standalone/Makefile.sacpp_[set id]_sub"
        puts $frep "perl -pi -w -e 's/SALData/[set id]/g;' [set id]/cpp/standalone/Makefile.sacpp_[set id]_sub"
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g;' [set id]/cpp/standalone/Makefile.sacpp_[set id]_sub"
        }
        exec cp $SAL_DIR/code/templates/Makefile.sacpp_SAL_pub.template [set id]/cpp/standalone/Makefile.sacpp_[set id]_pub
        puts $frep "perl -pi -w -e 's/_SAL_/_[set base]_/g;' [set id]/cpp/standalone/Makefile.sacpp_[set id]_pub"
        puts $frep "perl -pi -w -e 's/SALSubsys/[set base]/g;' [set id]/cpp/standalone/Makefile.sacpp_[set id]_pub"
        puts $frep "perl -pi -w -e 's/SALData/[set id]/g;' [set id]/cpp/standalone/Makefile.sacpp_[set id]_pub"
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g;' [set id]/cpp/standalone/Makefile.sacpp_[set id]_pub"
        }
        exec cp $SAL_DIR/code/templates/Makefile.sacpp_SAL_cmd.template [set base]/cpp/src/Makefile.sacpp_[set base]_cmd
        puts $frep "perl -pi -w -e 's/_SAL_/_[set base]_/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_cmd"
        puts $frep "perl -pi -w -e 's/SALSubsys/[set base]/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_cmd"
        puts $frep "perl -pi -w -e 's/SALData/[set base]/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_cmd"
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_cmd"
        }
        exec cp $SAL_DIR/code/templates/Makefile.sacpp_SAL_testcommands.template [set base]/cpp/src/Makefile.sacpp_[set base]_testcommands
        puts $frep "perl -pi -w -e 's/_SAL_/_[set base]_/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_testcommands"
        puts $frep "perl -pi -w -e 's/SALSubsys/[set base]/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_testcommands"
        puts $frep "perl -pi -w -e 's/SALData/[set base]/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_testcommands"
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_testcommands"
        }
        modpubsubexamples $id
        puts $frep "perl -pi -w -e 's/SALTopic/[set name]/g;' [set id]/cpp/src/[set id]DataPublisher.cpp"
        puts $frep "perl -pi -w -e 's/SALNAMESTRING/[set base]_[set name]/g;' [set id]/cpp/src/[set id]DataPublisher.cpp"
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set id]/cpp/src/[set id]DataPublisher.cpp"
        puts $frep "perl -pi -w -e 's/SALTopic/[set name]/g;' [set id]/cpp/src/[set id]DataSubscriber.cpp"
        puts $frep "perl -pi -w -e 's/SALNAMESTRING/[set base]_[set name]/g;' [set id]/cpp/src/[set id]DataSubscriber.cpp"
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set id]/cpp/src/[set id]DataSubscriber.cpp"
        exec cp $SAL_DIR/code/templates/Makefile.sacpp_SAL_event.template [set base]/cpp/src/Makefile.sacpp_[set base]_event
        puts $frep "perl -pi -w -e 's/_SAL_/_[set base]_/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_event"
        puts $frep "perl -pi -w -e 's/SALSubsys/[set base]/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_event"
        puts $frep "perl -pi -w -e 's/SALData/[set base]/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_event"
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_event"
        }
        exec cp $SAL_DIR/code/templates/Makefile.sacpp_SAL_testevents.template [set base]/cpp/src/Makefile.sacpp_[set base]_testevents
        puts $frep "perl -pi -w -e 's/_SAL_/_[set base]_/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_testevents"
        puts $frep "perl -pi -w -e 's/SALSubsys/[set base]/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_testevents"
        puts $frep "perl -pi -w -e 's/SALData/[set base]/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_testevents"
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g;' [set base]/cpp/src/Makefile.sacpp_[set base]_testevents"
        }
        exec cp $SAL_DIR/code/templates/SALDataCommander.cpp.template [set base]/cpp/src/[set base]Commander.cpp
        puts $frep "perl -pi -w -e 's/SALTopic/[set base]\:\:[set name]/g;' [set base]/cpp/src/[set base]Commander.cpp"
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/cpp/src/[set base]Commander.cpp"
        exec cp $SAL_DIR/code/templates/SALDataController.cpp.template [set base]/cpp/src/[set base]Controller.cpp
        puts $frep "perl -pi -w -e 's/SALTopic/[set base]\:\:[set name]/g;' [set base]/cpp/src/[set base]Controller.cpp"
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/cpp/src/[set base]Controller.cpp"
        exec cp $SAL_DIR/code/templates/SALDataEvent.cpp.template [set base]/cpp/src/[set base]Event.cpp
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/cpp/src/[set base]Event.cpp"
        exec cp $SAL_DIR/code/templates/SALDataEventLogger.cpp.template [set base]/cpp/src/[set base]EventLogger.cpp
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/cpp/src/[set base]EventLogger.cpp"
        foreach f "CheckStatus.cpp CheckStatus.h" {
##### These should be generated by idlpp
##### SALData.cpp SALDataDcps.cpp SALDataDcps.h SALDataDcps_impl.cpp SALDataDcps_impl.h 
##### SALData.h  SALDataSplDcps.cpp SALDataSplDcps.h ccpp_SALData.h"
           exec cp $SAL_DIR/code/templates/$f [set id]/cpp/src/.
           exec cp $SAL_DIR/code/templates/$f [set base]/cpp/src/.
        }
      }
      if { $lang == "java"}  {
        exec cp $SAL_DIR/code/templates/Makefile-java.template [set id]/java/standalone/Makefile
        puts $frep "perl -pi -w -e 's/saj_SAL_types/saj_[set base]_types/g;' [set id]/java/standalone/Makefile"
        puts $frep "perl -pi -w -e 's/_SAL_/_[set id]_/g;' [set id]/java/standalone/Makefile"
        exec cp $SAL_DIR/code/templates/Makefile.saj_SAL_types.template [set base]/java/Makefile.saj_[set base]_types
        puts $frep "perl -pi -w -e 's/SALDATA.idl/[file tail $idlfile]/g;' [set base]/java/Makefile.saj_[set base]_types"
        puts $frep "perl -pi -w -e 's/SALData/[set base]/g;' [set base]/java/Makefile.saj_[set base]_types"
        puts $frep "perl -pi -w -e 's/_SAL_/_[set base]_/g;' [set base]/java/Makefile.saj_[set base]_types"
        exec cp $SAL_DIR/code/templates/Makefile-java.template [set id]/java/Makefile
        puts $frep "perl -pi -w -e 's/_SAL_/_[set id]_/g;' [set id]/java/Makefile"
        exec cp $SAL_DIR/code/templates/Makefile.saj_SAL_pub.template [set id]/java/standalone/Makefile.saj_[set id]_pub
        puts $frep "perl -pi -w -e 's/_SAL_/_[set id]_/g;' [set id]/java/standalone/Makefile.saj_[set id]_pub"
        puts $frep "perl -pi -w -e 's/SALTopic/[set id]/g;' [set id]/java/standalone/Makefile.saj_[set id]_pub"
        puts $frep "perl -pi -w -e 's/SALData/[set base]/g;' [set id]/java/standalone/Makefile.saj_[set id]_pub"
        exec cp $SAL_DIR/code/templates/Makefile.saj_SAL_sub.template [set id]/java/standalone/Makefile.saj_[set id]_sub
        puts $frep "perl -pi -w -e 's/_SAL_/_[set id]_/g;' [set id]/java/standalone/Makefile.saj_[set id]_sub"
        puts $frep "perl -pi -w -e 's/SALTopic/[set id]/g;' [set id]/java/standalone/Makefile.saj_[set id]_sub"
        puts $frep "perl -pi -w -e 's/SALData/[set base]/g;' [set id]/java/standalone/Makefile.saj_[set id]_sub"
        exec cp $SAL_DIR/code/templates/SALTopicDataPublisher.java.template [set id]/java/src/[set id]DataPublisher.java
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID/aKey/g;' [set id]/java/src/[set id]DataPublisher.java"
        } else {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID//g;' [set id]/java/src/[set id]DataPublisher.java"
        }
        puts $frep "perl -pi -w -e 's/SALTopic/[set name]/g;' [set id]/java/src/[set id]DataPublisher.java"
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set id]/java/src/[set id]DataPublisher.java"
        puts $frep "perl -pi -w -e 's/SALNAMESTRING/[set id]/g;' [set id]/java/src/[set id]DataPublisher.java"
        exec cp $SAL_DIR/code/templates/SALTopicDataSubscriber.java.template [set id]/java/src/[set id]DataSubscriber.java
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID/aKey/g;' [set id]/java/src/[set id]DataSubscriber.java"
        } else {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID//g;' [set id]/java/src/[set id]DataSubscriber.java"
        }
        puts $frep "perl -pi -w -e 's/SALTopic/[set name]/g;' [set id]/java/src/[set id]DataSubscriber.java"
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set id]/java/src/[set id]DataSubscriber.java"
        puts $frep "perl -pi -w -e 's/SALNAMESTRING/[set id]/g;' [set id]/java/src/[set id]DataSubscriber.java"

        exec cp $SAL_DIR/code/templates/Makefile.saj_SAL_cmdctl.template [set base]/java/src/Makefile.saj_[set base]_cmdctl
        puts $frep "perl -pi -w -e 's/_SAL_/_[set base]_/g;' [set base]/java/src/Makefile.saj_[set base]_cmdctl"
        puts $frep "perl -pi -w -e 's/SALData/[set base]/g;' [set base]/java/src/Makefile.saj_[set base]_cmdctl"
        exec cp $SAL_DIR/code/templates/SALDataCommander.java.template [set base]/java/src/[set base]Commander.java
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID/aKey/g;' [set base]/java/src/[set base]Commander.java"
        } else {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID//g;' [set base]/java/src/[set base]Commander.java"
        }
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/java/src/[set base]Commander.java"
        exec cp $SAL_DIR/code/templates/SALDataController.java.template [set base]/java/src/[set base]Controller.java
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID/aKey/g;' [set base]/java/src/[set base]Controller.java"
        } else {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID//g;' [set base]/java/src/[set base]Controller.java"
        }
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/java/src/[set base]Controller.java"
        exec cp $SAL_DIR/code/templates/ErrorHandler.java [set id]/java/src/ErrorHandler.java
        exec cp $SAL_DIR/code/templates/ErrorHandler.java [set base]/java/src/ErrorHandler.java
        exec cp $SAL_DIR/code/templates/runsample.template [set id]/java/standalone/[set id].run
        puts $frep "perl -pi -w -e 's/SALTopic/[set id]/g;' [set id]/java/standalone/[set id].run"
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set id]/java/standalone/[set id].run"
        puts $frep "perl -pi -w -e 's/_SAL_/_[set id]_/g;' [set id]/java/standalone/[set id].run"
        exec cp $SAL_DIR/code/templates/runcmdctl.template [set base]/java/src/[set base]_cmdctl.run
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/java/src/[set base]_cmdctl.run"
        puts $frep "perl -pi -w -e 's/_SAL_/_[set id]_/g;' [set base]/java/src/[set base]_cmdctl.run"

        exec cp $SAL_DIR/code/templates/Makefile.saj_SAL_event.template [set base]/java/src/Makefile.saj_[set base]_event
        puts $frep "perl -pi -w -e 's/_SAL_/_[set base]_/g;' [set base]/java/src/Makefile.saj_[set base]_event"
        puts $frep "perl -pi -w -e 's/SALData/[set base]/g;' [set base]/java/src/Makefile.saj_[set base]_event"
        exec cp $SAL_DIR/code/templates/SALDataEvent.java.template [set base]/java/src/[set base]Event.java
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID/aKey/g;' [set base]/java/src/[set base]Event.java"
        } else {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID//g;' [set base]/java/src/[set base]Event.java"
        }
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/java/src/[set base]Event.java"
        exec cp $SAL_DIR/code/templates/SALDataEventLogger.java.template [set base]/java/src/[set base]EventLogger.java
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID/aKey/g;' [set base]/java/src/[set base]EventLogger.java"
        } else {
          puts $frep "perl -pi -w -e 's/SALSUBSYSID//g;' [set base]/java/src/[set base]EventLogger.java"
        }
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/java/src/[set base]EventLogger.java"
        exec cp $SAL_DIR/code/templates/runevent.template [set base]/java/src/[set base]_event.run
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/java/src/[set base]_event.run"
        puts $frep "perl -pi -w -e 's/_SAL_/_[set id]_/g;' [set base]/java/src/[set base]_event.run"
      }
      if { $lang == "isocpp" } {
        exec cp $SAL_DIR/code/templates/Makefile-isocpp.template [set id]/isocpp/Makefile
        puts $frep "perl -pi -w -e 's/SAL_Typesupport/[set base]_TypeSupport/g;' [set id]/isocpp/Makefile"
        puts $frep "perl -pi -w -e 's/_SAL_/_[set id]_/g;' [set id]/isocpp/Makefile"
        exec cp $SAL_DIR/code/templates/Makefile.ISO_Cxx_SAL_Typesupport.template [set base]/isocpp/Makefile.ISO_Cxx_[set base]_Typesupport
        puts $frep "perl -pi -w -e 's/SALDATA.idl/[file tail $idlfile]/g;' [set base]/isocpp/Makefile.ISO_Cxx_[set base]_Typesupport"
        puts $frep "perl -pi -w -e 's/SALData/sal_[set base]/g;' [set base]/isocpp/Makefile.ISO_Cxx_[set base]_Typesupport"
        puts $frep "perl -pi -w -e 's/_SAL_/_[set base]_/g;' [set base]/isocpp/Makefile.ISO_Cxx_[set base]_Typesupport"
        exec cp $SAL_DIR/code/templates/implementation.hpp.template [set id]/isocpp/implementation.hpp
        exec cp $SAL_DIR/code/templates/publisher.cpp.template [set id]/isocpp/publisher.cpp
        exec cp $SAL_DIR/code/templates/subscriber.cpp.template [set id]/isocpp/subscriber.cpp
        exec cp $SAL_DIR/code/templates/implementation.cpp.template [set id]/isocpp/implementation.cpp
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set id]/isocpp/implementation.cpp"
        puts $frep "perl -pi -w -e 's/SALTopic/$name/g;' [set id]/isocpp/implementation.cpp"
        puts $frep "perl -pi -w -e 's/SALNAMESTRING/$name/g;' [set id]/isocpp/implementation.cpp"
      }
      if { $lang == "PyDDS" } {
        exec cp $SAL_DIR/code/templates/SALTopicPublisher.py.template [set id]/python/[set id]Publisher.py
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set id]/python/[set id]Publisher.py"
        puts $frep "perl -pi -w -e 's/SALTopic/$name/g;' [set id]/python/[set id]Publisher.py"
        puts $frep "perl -pi -w -e 's/SALDATA.idl/[file tail $idlfile]/g;' [set id]/python/[set id]Publisher.py"
        exec cp $SAL_DIR/code/templates/SALTopicSubscriber.py.template [set id]/python/[set id]Subscriber.py
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set id]/python/[set id]Subscriber.py"
        puts $frep "perl -pi -w -e 's/SALTopic/$name/g;' [set id]/python/[set id]Subscriber.py"
        puts $frep "perl -pi -w -e 's/SALDATA.idl/[file tail $idlfile]/g;' [set id]/python/[set id]Subscriber.py"
      }
      close $frep
      exec chmod 755 /tmp/sreplace.sal
      catch { set result [exec /tmp/sreplace.sal] } bad
      if { $bad != "" } {puts stdout $bad}
puts stdout "calling addSALDDStypes $idlfile $id $lang"
      addSALDDStypes $idlfile $id $lang $base
puts stdout "done addSALDDStypes $idlfile $id $lang"
      if { $lang == "cpp" } {
        set frep [open /tmp/sreplace2.sal w]
        puts $frep "#!/bin/sh"
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/cpp/src/SAL_[set base].h"
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/cpp/src/SAL_[set base].cpp"
        puts $frep "perl -pi -w -e 's/SALCommand/$base\:\:command/g;' [set base]/cpp/src/SAL_[set base].cpp"
        puts $frep "perl -pi -w -e 's/SALResponse/$base\:\:ackcmd/g;' [set base]/cpp/src/SAL_[set base].cpp"
        close $frep
        exec chmod 755 /tmp/sreplace2.sal
        catch { set result [exec /tmp/sreplace2.sal] } bad
      }
      if { $lang == "java" } {
        set frep [open /tmp/sreplace2.sal w]
        puts $frep "#!/bin/sh"
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set id]/java/src/org/lsst/sal/SAL_[set base].java"
        puts $frep "perl -pi -w -e 's/SALCommand/command/g;' [set id]/cpp/src/org/lsst/sal/SAL_[set base].java"
        puts $frep "perl -pi -w -e 's/SALResponse/ackcmd/g;' [set id]/cpp/src/org/lsst/sal/SAL_[set base].java"
        puts $frep "perl -pi -w -e 's/SALData/$base/g;' [set base]/java/src/org/lsst/sal/SAL_[set base].java"
        puts $frep "perl -pi -w -e 's/SALCommand/command/g;' [set base]/cpp/src/org/lsst/sal/SAL_[set base].java"
        puts $frep "perl -pi -w -e 's/SALResponse/ackcmd/g;' [set base]/cpp/src/org/lsst/sal/SAL_[set base].java"
        close $frep
        exec chmod 755 /tmp/sreplace2.sal
        catch { set result [exec /tmp/sreplace2.sal] } bad
      }
puts stdout "calling salidlgen $base $lang"
      salidlgen $base $lang
puts stdout "done salidlgen $base $lang"
      if { $lang == "cpp" } { 
         set incfiles [glob [set base]/cpp/*.h]
         puts stdout "Updating include files : $incfiles"
         catch { foreach i $incfiles {  exec cp $i $SAL_DIR/include/. } }
         exec cp [set base]/cpp/libsacpp_[set base]_types.so $SAL_DIR/../lib/.
         exec ln -sf $SAL_WORK_DIR/[set base]/cpp/src/SAL_[set base].cpp $SAL_WORK_DIR/[set id]/cpp/src/.
         exec ln -sf $SAL_WORK_DIR/[set base]/cpp/src/SAL_[set base].h $SAL_WORK_DIR/[set id]/cpp/src/.
         salcpptestgen $base $id
      }
      if { $lang == "java" } {
         exec cp [set base]/java/saj_[set base]_types.jar $SAL_DIR/../lib/.
         saljavaclassgen $base $id
      }
      if { $lang == "python" } {
         puts stdout "Generating Boost bindings"
         genpythonbinding $base
         puts stdout "Generating python shared library"
         salpythonshlibgen $base
         puts stdout "Generating python command tests"
         gencommandtestspython $base
         puts stdout "Generating python event tests"
         geneventtestspython $base
         puts stdout "Generating python telemetry tests"
         gentelemetrytestspython $base
      }
}


proc unittest { } {
global SAL_WORK_DIR
      makesalidl tcs
      makesalcode $SAL_WORK_DIR/idl-templates/validated/sal/sal_tcs.idl tcs kernel_TrackingTarget cpp
      makesalcode $SAL_WORK_DIR/idl-templates/validated/sal/sal_tcs.idl tcs kernel_TrackingTarget java
      makesalcode $SAL_WORK_DIR/idl-templates/validated/sal/sal_tcs.idl tcs kernel_TrackingTarget isocpp
      makesalcode $SAL_WORK_DIR/idl-templates/validated/sal/sal_tcs.idl tcs kernel_TrackingTarget python
}


proc salfullgen { } {
global SAL_WORK_DIR OPTIONS
  set atypes [lsort [glob $SAL_WORK_DIR/idl-templates/validated/sal/*.idl]]
  foreach i $atypes {
    set base [lindex [exec grep module $i] 1]
    set ptypes [split [exec grep pragma $i] \n]
    foreach j $ptypes {
      set name [lindex $j 2]
      makesalcode $idlfile $base $name cpp
      salidlgen cpp
      makesalcode $idlfile $base $name java
      salidlgen java
      makesalcode $idlfile $base $name isocpp
      salidlgen isocpp
      makesalcode $idlfile $base $name python
    }
  }
}

proc salidlgen { base lang } {
global SAL_WORK_DIR OPTIONS ONEDDSGEN
   if { $lang != "python" } {
     if { $ONEDDSGEN == 0 } {
       cd $SAL_WORK_DIR/$base/$lang
       puts stdout "Generating $lang type support for $base"
       if { $lang == "cpp" }     {catch { set result [exec make -f Makefile.sacpp_[set base]_types] } bad; puts stdout $bad}
       if { $lang == "isocpp" }  {catch { set result [exec make -f Makefile.ISO_Cxx_[set base]_Typesupport] } bad; puts stdout $bad}
       if { $lang == "java"}     {catch { set result [exec make -f Makefile.saj_[set base]_types] } bad; puts stdout $bad}
       puts stdout "idl : $result"
       cd $SAL_WORK_DIR
       set ONEDDSGEN 1
     }
   }
}



proc salpythonshlibgen { base } {
global SAL_WORK_DIR
   cd $SAL_WORK_DIR/$base/cpp/src
   puts stdout "Generating Python SAL support for $base"
   exec touch .depend.Makefile.sacpp_[set base]_python
   catch { set result [exec make -f Makefile.sacpp_[set base]_python] } bad
   if { $bad != "" } {puts stdout $bad}
   puts stdout "python : Done SALPY_[set base].so"
}


proc saljavaclassgen { base id } {
global SAL_WORK_DIR OPTIONS
   cd $SAL_WORK_DIR/$id/java/standalone
   catch { set result [exec make -f Makefile.saj_[set id]_pub] } bad
   catch {puts stdout "result = $result"}
   catch {puts stdout "$bad"}
   puts stdout "javac : Done Publisher"
   catch { set result [exec make -f Makefile.saj_[set id]_sub] } bad
   catch {puts stdout "result = $result"}
   catch {puts stdout "$bad"}
   puts stdout "javac : Done Subscriber"
   cd $SAL_WORK_DIR/$base/java/src
   catch { set result [exec make -f Makefile.saj_[set base]_cmdctl] } bad
   catch {puts stdout "result = $result"}
   catch {puts stdout "$bad"}
   puts stdout "javac : Done Commander/Controller"
   catch { set result [exec make -f Makefile.saj_[set base]_event] } bad
   catch {puts stdout "result = $result"}
   catch {puts stdout "$bad"}
   puts stdout "javac : Done Event/Logger"
   cd $SAL_WORK_DIR
}

proc salcpptestgen { base id } {
global SAL_WORK_DIR OPTIONS DONE_CMDEVT
  puts stdout "Generating cpp test programs for $id"
  cd $SAL_WORK_DIR/$id/cpp/standalone
  catch { set result [exec make -f Makefile.sacpp_[set id]_sub] } bad
  catch {puts stdout "result = $result"}
  catch {puts stdout "$bad"}
  puts stdout "cpp : Done Subscriber"
  catch { set result [exec make -f Makefile.sacpp_[set id]_pub] } bad
  catch {puts stdout "result = $result"}
  catch {puts stdout "$bad"}
  puts stdout "cpp : Done Publisher"
  if { $DONE_CMDEVT == 0 } {
   cd $SAL_WORK_DIR/$base/cpp/src
   catch { exec make -f Makefile.sacpp_[set base]_cmd } bad
   catch {puts stdout "result = $result"}
   catch {puts stdout "$bad"}
   catch { exec make -f Makefile.sacpp_[set base]_testcommands } bad
   catch {puts stdout "result = $result"}
   catch {puts stdout "$bad"}
   puts stdout "cpp : Done Commander"
   catch { exec make -f Makefile.sacpp_[set base]_event } bad
   catch {puts stdout "result = $result"}
   catch {puts stdout "$bad"}
   catch { exec make -f Makefile.sacpp_[set base]_testevents } bad
   catch {puts stdout "result = $result"}
   catch {puts stdout "$bad"}
   puts stdout "cpp : Done Event/Logger"
   set DONE_CMDEVT 1
   cd $SAL_WORK_DIR
  }
}

source $SAL_DIR/add_system_dictionary.tcl
source $SAL_DIR/gensalgetput.tcl
source $SAL_DIR/gensimplepython.tcl
source $SAL_DIR/managetypes.tcl


