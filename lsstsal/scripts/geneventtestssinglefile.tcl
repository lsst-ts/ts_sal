proc geneventtestssinglefilescpp { subsys } {
    # Creates multiple files which contains an implementation of all the
    # events defined within this subsys.

    global SAL_WORK_DIR

    # Create the file writers for the sender, logger and makefile.
    set sender_cpp_file_writer [open $SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_all_sender.cpp w]
    set logger_cpp_file_writer [open $SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_all_logger.cpp w]
    set makefile_file_writer [open $SAL_WORK_DIR/$subsys/cpp/src/Makefile.sacpp_[set subsys]_all_testevents w]

    # Insert content into the sender.
    insertEventHeader $subsys $sender_cpp_file_writer
    insertSenders $subsys $sender_cpp_file_writer

    # Insert content into the logger.
    insertEventHeader $subsys $logger_cpp_file_writer
    insertLoggers $subsys $logger_cpp_file_writer

    # Insert content into the makefile.
    insertEventsMakeFile $subsys $makefile_file_writer

    # Close all the file writers.
    close $sender_cpp_file_writer
    close $logger_cpp_file_writer
    close $makefile_file_writer

    # Execute the makefile. 
    cd $SAL_WORK_DIR/$subsys/cpp/src
    exec make -f $SAL_WORK_DIR/$subsys/cpp/src/Makefile.sacpp_[set subsys]_all_testevents
    cd $SAL_WORK_DIR
}

proc insertEventHeader { subsys file_writer } {

    puts $file_writer "/*"
    puts $file_writer " * This file contains an implementation of all the events defined within the"
    puts $file_writer " * [set subsys] subsystem generated via geneventtestssinglefilescpp.tcl."
    puts $file_writer " *"
    puts $file_writer " ***/"

    puts $file_writer "#include <string>"
    puts $file_writer "#include <sstream>"
    puts $file_writer "#include <iostream>"
    puts $file_writer "#include <stdlib.h>"
    puts $file_writer "#include \"SAL_[set subsys].h\""
    puts $file_writer "#include \"ccpp_sal_[set subsys].h\""
    puts $file_writer "#include \"os.h\""
    puts $file_writer "using namespace DDS;"
    puts $file_writer "using namespace [set subsys];"
}

proc insertSenders { subsys file_writer } {
    
    global SYSDIC SAL_WORK_DIR EVENT_ALIASES  

    puts $file_writer "int main (int argc, char *argv\[\])"
    puts $file_writer "\{"
 
    if { [info exists SYSDIC($subsys,keyedID)] } {
        puts $file_writer "  int [set subsys]ID = 1;"
        puts $file_writer "  if (getenv(\"LSST_[string toupper [set subsys]]_ID\") != NULL) \{"
        puts $file_writer "    sscanf(getenv(\"LSST_[string toupper [set subsys]]_ID\"),\"%d\",&[set subsys]ID);"
        puts $file_writer "  \}"
        puts $file_writer "  SAL_[set subsys] mgr = SAL_[set subsys]([set subsys]ID);\n"
    } else {
        puts $file_writer "  SAL_[set subsys] mgr = SAL_[set subsys]();"
    }

    foreach alias $EVENT_ALIASES($subsys) {
        puts $file_writer "  mgr.salEventPub(\"[set subsys]_logevent_[set alias]\");"
    }

    foreach alias $EVENT_ALIASES($subsys) {
        puts $file_writer "\{" 
        puts $file_writer "  int priority = SAL__EVENT_INFO;"
        puts $file_writer "  int iseq;"
        puts $file_writer "  iseq = 0;"
        puts $file_writer "  [set subsys]_logevent_[set alias]C myData;"
        puts $file_writer "  cout << \"=== Event $alias iseq = \" << iseq << endl;"

        set fragment_reader [open $SAL_WORK_DIR/include/SAL_[set subsys]_logevent_[set alias]Cpub.tmp r]
        while { [gets $fragment_reader line] > -1 } {
            puts $file_writer [string range $line 2 1000]
        }
        
        puts $file_writer "  priority = myData.priority;"
        puts $file_writer "  mgr.logEvent_[set alias](&myData, priority);"
        puts $file_writer "  cout << \"=== Event $alias generated = \" << endl;"
        puts $file_writer "  sleep(1);\n\}"
    }

        puts $file_writer "  mgr.salShutdown();"
        puts $file_writer "  return 0;"
        puts $file_writer "\}"
}

proc insertLoggers { subsys file_writer } {

    global SYSDIC SAL_WORK_DIR EVENT_ALIASES  
    
    puts $file_writer "/* entry point exported and demangled so symbol can be found in shared library */"
    puts $file_writer "extern \"C\""
    puts $file_writer "\{"
    puts $file_writer "  OS_API_EXPORT"
    puts $file_writer "  int test_[set subsys]_all_logger();"
    puts $file_writer "\}"

    puts $file_writer "int test_[set subsys]_all_logger()"
    puts $file_writer "\{"

    if { [info exists SYSDIC($subsys,keyedID)] } {
        puts $file_writer "  int [set subsys]ID = 1;"
        puts $file_writer "  if (getenv(\"LSST_[string toupper [set subsys]]_ID\") != NULL) \{"
        puts $file_writer " sscanf(getenv(\"LSST_[string toupper [set subsys]]_ID\"),\"%d\",&[set subsys]ID);"
        puts $file_writer "\}"
        puts $file_writer "SAL_[set subsys] mgr = SAL_[set subsys]([set subsys]ID);\n"
    } else {
        puts $file_writer "  SAL_[set subsys] mgr = SAL_[set subsys]();\n"
    }

    foreach alias $EVENT_ALIASES($subsys) {
        puts $file_writer "  mgr.salEventSub(\"[set subsys]_logevent_[set alias]\");"
    }
    puts $file_writer "  cout << \"=== [set subsys] loggers ready \" << endl;"


    foreach alias $EVENT_ALIASES($subsys) {
        puts $file_writer "  while (1) "
        puts $file_writer "  \{"
        puts $file_writer "    int status = -1;"
        puts $file_writer "    [set subsys]_logevent_[set alias]C SALInstance;"
        puts $file_writer "    status = mgr.getEvent_[set alias](&SALInstance);"
        puts $file_writer "    if (status == SAL__OK) \{"
        puts $file_writer "      cout << \"=== Event [set alias] received = \" << endl;"

        set fragment_reader [open $SAL_WORK_DIR/include/SAL_[set subsys]_logevent_[set alias]Csub.tmp r]
        while { [gets $fragment_reader line] > -1 } {
            puts $file_writer "      [string trim $line]"
        }
        close $fragment_reader
        puts $file_writer "      break;\n    \}\n  \}"
    }

    puts $file_writer "/* Remove the DataWriters etc */"
    puts $file_writer "  mgr.salShutdown();"
    puts $file_writer "  return 0;"
    puts $file_writer "\}"

    puts $file_writer "int main (int argc, char *argv\[\])"
    puts $file_writer "\{"
    puts $file_writer "  return test_[set subsys]_all_logger();"
    puts $file_writer "\}"
}

proc insertEventsMakeFile { subsys file_writer } {
global SYSDIC
    set keyed ""
    if { [info exists SYSDIC($subsys,KEYID)] } {
       set keyed "-DSAL_SUBSYSTEM_ID_IS_KEYED
    }
    puts $file_writer "#----------------------------------------------------------------------------"
    puts $file_writer "#       Macros"
    puts $file_writer "#----------------------------------------------------------------------------"
    puts $file_writer "CFG = Release"

    puts $file_writer "ifeq (\$(CFG), Release)"
    puts $file_writer "CC            = gcc"
    puts $file_writer "CXX           = g++"
    puts $file_writer "LD            = \$(CXX) \$(CCFLAGS) \$(CPPFLAGS)"
    puts $file_writer "AR            = ar"
    puts $file_writer "PICFLAGS      = -fPIC"
    puts $file_writer "CPPFLAGS      = \$(PICFLAGS) \$(GENFLAGS) -g \$(SAL_CPPFLAGS) -D_REENTRANT -Wall -I\".\" -I\"\$(OSPL_HOME)/examples/include\" -I\"\$(OSPL_HOME)/examples\" -I\"\$(OSPL_HOME)/include\" -I\"\$(OSPL_HOME)/include/sys\" -I\"\$(OSPL_HOME)/include/dcps/C++/SACPP\" -I../../[set subsys]/cpp/src -I\"\$(SAL_HOME)/include\" -I.. -I\"\$(SAL_WORK_DIR)/include\" -Wno-write-strings $keyed"
    puts $file_writer "OBJEXT        = .o"
    puts $file_writer "OUTPUT_OPTION = -o \"\$@\""
    puts $file_writer "COMPILE.c     = \$(CC) \$(CFLAGS) \$(CPPFLAGS) -c"
    puts $file_writer "COMPILE.cc    = \$(CXX) \$(CCFLAGS) \$(CPPFLAGS) -c"
    puts $file_writer "LDFLAGS       = -L\".\" -L\"\$(OSPL_HOME)/lib\" -Wl,-rpath,\$\$ORIGIN -Wl,-rpath,\$\$ORIGIN/\$(OSPL_HOME)/lib -L\"\$(SAL_WORK_DIR)/lib\""
    puts $file_writer "CCC           = \$(CXX)"
    puts $file_writer "MAKEFILE      = Makefile.sacpp_[set subsys]_all_testevents // may be not needed"
    puts $file_writer "DEPENDENCIES  ="
    puts $file_writer "BTARGETDIR    = ./"

    puts $file_writer "BIN1           = \$(BTARGETDIR)sacpp_[set subsys]_all_sender"
    puts $file_writer "OBJS1          = .obj/SAL_[set subsys].o .obj/sacpp_[set subsys]_all_sender.o"
    puts $file_writer "SRC           = ../src/SAL_[set subsys].cpp    sacpp_[set subsys]_all_senderc"

    puts $file_writer "BIN2          = \$(BTARGETDIR)sacpp_[set subsys]_all_logger"
    puts $file_writer "OBJS2         = .obj/SAL_[set subsys].o .obj/sacpp_[set subsys]_all_logger.o"
    puts $file_writer "SRC           = ../src/SAL_[set subsys].cpp    sacpp_[set subsys]_all_loggerc"

    puts $file_writer "CAT           = cat"
    puts $file_writer "MV            = mv -f"
    puts $file_writer "RM            = rm -rf"
    puts $file_writer "CP            = cp -p"
    puts $file_writer "NUL           = /dev/null"
    puts $file_writer "MKDIR         = mkdir -p"
    puts $file_writer "TESTDIRSTART  = test -d"
    puts $file_writer "TESTDIREND    = ||"
    puts $file_writer "TOUCH         = touch"
    puts $file_writer "EXEEXT        ="
    puts $file_writer "LIBPREFIX     = lib"
    puts $file_writer "LIBSUFFIX     ="
    puts $file_writer "GENFLAGS      = -g"
    puts $file_writer "LDLIBS        = -l\"sacpp_[set subsys]_types\$(LIBSUFFIX)\" -l\"dcpssacpp\" -l\"dcpsgapi\" -l\"ddsuser\" -l\"ddskernel\" -l\"ddsserialization\" -l\"ddsconfparser\" -l\"ddsconf\" -l\"ddsdatabase\" -l\"ddsutil\" -l\"ddsos\" -ldl \$(subst lib,-l,\$(sort \$(basename \$(notdir \$(wildcard /usr/lib/librt.so /lib/librt.so))))) -lpthread"
    puts $file_writer "LINK.cc       = \$(LD) \$(LDFLAGS)"
    puts $file_writer "EXPORTFLAGS   ="
    puts $file_writer "endif"

    puts $file_writer "#----------------------------------------------------------------------------"
    puts $file_writer "#       Local targets"
    puts $file_writer "#----------------------------------------------------------------------------"

    puts $file_writer "all: \$(BIN1) \$(BIN2)"

    puts $file_writer ".obj/SAL_[set subsys]\$(OBJEXT): ../src/SAL_[set subsys].cpp"
    puts $file_writer "	@\$(TESTDIRSTART) \".obj/../src\" \$(TESTDIREND) \$(MKDIR) \".obj/../src\""
    puts $file_writer "	\$(COMPILE.cc) \$(EXPORTFLAGS) \$(OUTPUT_OPTION) ../src/SAL_[set subsys].cpp"

    puts $file_writer ".obj/sacpp_[set subsys]_all_sender.o: ../src/sacpp_[set subsys]_all_sender.cpp"
    puts $file_writer "	@\$(TESTDIRSTART) \".obj/../src\" \$(TESTDIREND) \$(MKDIR) \".obj/../src\""
    puts $file_writer "	\$(COMPILE.cc) \$(EXPORTFLAGS) \$(OUTPUT_OPTION) ../src/sacpp_[set subsys]_all_sender.cpp"

    puts $file_writer "\$(BIN1): \$(OBJS1)"
    puts $file_writer "	@\$(TESTDIRSTART) \"\$(BTARGETDIR)\" \$(TESTDIREND) \$(MKDIR) \"\$(BTARGETDIR)\""
    puts $file_writer "	\$(LINK.cc) \$(OBJS1) \$(LDLIBS) \$(OUTPUT_OPTION)"

    puts $file_writer ".obj/sacpp_[set subsys]_all_logger.o: ../src/sacpp_[set subsys]_all_logger.cpp"
    puts $file_writer "	@\$(TESTDIRSTART) \".obj/../src\" \$(TESTDIREND) \$(MKDIR) \".obj/../src\""
    puts $file_writer "	\$(COMPILE.cc) \$(EXPORTFLAGS) \$(OUTPUT_OPTION) ../src/sacpp_[set subsys]_all_logger.cpp"

    puts $file_writer "\$(BIN2): \$(OBJS2)"
    puts $file_writer "	@\$(TESTDIRSTART) \"\$(BTARGETDIR)\" \$(TESTDIREND) \$(MKDIR) \"\$(BTARGETDIR)\""
    puts $file_writer "	\$(LINK.cc) \$(OBJS2) \$(LDLIBS) \$(OUTPUT_OPTION)"

    puts $file_writer "generated: \$(GENERATED_DIRTY)"
    puts $file_writer "	@-:"

    puts $file_writer "clean:"
    puts $file_writer "	-\$(RM) \$(OBJS)"

    puts $file_writer "realclean: clean"
    puts $file_writer "	-\$(RM) \$(BIN)"
    puts $file_writer "	-\$(RM) .obj/"

    puts $file_writer "check-syntax:"
    puts $file_writer "	\$(COMPILE.cc) \$(EXPORTFLAGS) -Wall -Wextra -pedantic -fsyntax-only \$(CHK_SOURCES)"

    puts $file_writer "#----------------------------------------------------------------------------"
    puts $file_writer "#       Dependencies"
    puts $file_writer "#----------------------------------------------------------------------------"

    puts $file_writer "\$(DEPENDENCIES):"
    puts $file_writer "	@\$(TOUCH) \$(DEPENDENCIES)"

    puts $file_writer "depend:"
    puts $file_writer "	-VDIR=.obj/ \$(MPC_ROOT)/depgen.pl  \$(CFLAGS) \$(CCFLAGS) \$(CPPFLAGS) -f \$(DEPENDENCIES) \$(SRC) 2> \$(NUL)"

    puts $file_writer "include \$(DEPENDENCIES)"
}
