proc gencommandtestsinglefilescpp { subsys } {
    # Creates multiple files which contains an implementation of all the
    # commands defined within this subsys.

    global SAL_WORK_DIR

    # Create the file writers for the commander, controller and makefile.
    set commander_cpp_file_writer [open $SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_all_commander.cpp w]
    set controller_cpp_file_writer [open $SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_all_controller.cpp w]
    set makefile_file_writer [open $SAL_WORK_DIR/$subsys/cpp/src/Makefile.sacpp_[set subsys]_all_testcommands w]

    # Insert content into the commander.
    insertCommandHeader $subsys $commander_cpp_file_writer
    insertCommanders $subsys $commander_cpp_file_writer

    # Insert content into the controller.
    insertCommandHeader $subsys $controller_cpp_file_writer
    insertControllers $subsys $controller_cpp_file_writer

    # Insert content into the makefile.
    insertMakeFile $subsys $makefile_file_writer

    # Close all the file writers.
    close $commander_cpp_file_writer
    close $controller_cpp_file_writer
    close $makefile_file_writer

    # Execute the makefile. 
    cd $SAL_WORK_DIR/$subsys/cpp/src
    exec make -f $SAL_WORK_DIR/$subsys/cpp/src/Makefile.sacpp_[set subsys]_all_testcommands
    cd $SAL_WORK_DIR
}

proc insertCommandHeader { subsys file_writer } {

    puts $file_writer "/*"
    puts $file_writer "* This file contains an implementation of all the commands defined within the"
    puts $file_writer "* [set subsys] subsystem generated via gencommandtestsinglefilescpp.tcl"
    puts $file_writer "*"
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

proc insertCommanders { subsys file_writer } {

    global SYSDIC CMD_ALIASES 

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

    foreach alias $CMD_ALIASES($subsys) {
        puts $file_writer "  mgr.salCommand(\"[set subsys]_command_[set alias]\");"
    }
    puts $file_writer "  cout << \"===== [set subsys] all commanders ready =====\" << endl;"

    foreach alias $CMD_ALIASES($subsys) {
        puts $file_writer "  \{"
        puts $file_writer "    cout << \"=== [set subsys]_[set alias] start of topic ===\" << endl;"
        puts $file_writer "    int cmdId;"
        puts $file_writer "    int timeout=10;"
        puts $file_writer "    int status=0;"
        puts $file_writer "    [set subsys]_command_[set alias]C myData;"
        
        puts $file_writer "    cmdId = mgr.issueCommand_[set alias](&myData);"
        puts $file_writer "    cout << \"=== [set subsys]_[set alias] end of topic ===\" << endl;"
        puts $file_writer "    status = mgr.waitForCompletion_[set alias](cmdId, timeout);"
        puts $file_writer "    cout << status << endl;"
        puts $file_writer "  \}\n"
    }
    puts $file_writer "  mgr.salShutdown();"
    puts $file_writer "  exit(0);"
    puts $file_writer "\}"
}

proc insertControllers { subsys file_writer } {

    global SYSDIC SAL_WORK_DIR CMD_ALIASES 

    puts $file_writer "/* entry point exported and demangled so symbol can be found in shared library */"
    puts $file_writer "extern \"C\""
    puts $file_writer "\{"
    puts $file_writer "  OS_API_EXPORT"
    puts $file_writer "  int test_[set subsys]_all_controller();"
    puts $file_writer "\}"

    puts $file_writer "int test_[set subsys]_all_controller()"
    puts $file_writer "\{"
    puts $file_writer "  os_time delay_10ms = \{ 0, 10000000 \};"
    puts $file_writer "  int cmdId = -1;"
    puts $file_writer "  int timeout = 1;"

    if { [info exists SYSDIC($subsys,keyedID)] } {
        puts $file_writer "  int [set subsys]ID = 1;"
        puts $file_writer "  if (getenv(\"LSST_[string toupper [set subsys]]_ID\") != NULL) \{"
        puts $file_writer "    sscanf(getenv(\"LSST_[string toupper [set subsys]]_ID\"),\"%d\",&[set subsys]ID);"
        puts $file_writer "  \}"
        puts $file_writer "  SAL_[set subsys] mgr = SAL_[set subsys]([set subsys]ID);\n"
    } else {
        puts $file_writer "  SAL_[set subsys] mgr = SAL_[set subsys]();"
    }

    foreach alias $CMD_ALIASES($subsys) {
        puts $file_writer "  mgr.salProcessor(\"[set subsys]_command_[set alias]\");"
    }
    puts $file_writer "  cout << \"===== [set subsys] all controllers ready =====\" << endl;"

    foreach alias $CMD_ALIASES($subsys) {
        puts $file_writer "  cout << \"=== [set subsys]_[set alias] start of topic ===\" << endl;"
        puts $file_writer "  while (1)" 
        puts $file_writer "  \{"
        puts $file_writer "    [set subsys]_command_[set alias]C SALInstance;"
        puts $file_writer "    cmdId = mgr.acceptCommand_[set alias](&SALInstance);"
        puts $file_writer "    if (cmdId > 0) \{"

        set fragment_reader [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set alias]Csub.tmp r]
        while { [gets $fragment_reader line] > -1 } {
            puts $file_writer "  $line"
        }
        close $fragment_reader

        puts $file_writer "      if (timeout > 0) \{"
        puts $file_writer "        mgr.ackCommand_[set alias](cmdId, SAL__CMD_INPROGRESS, 0, \"Ack : OK\");"
        puts $file_writer "        os_nanoSleep(delay_10ms);"
        puts $file_writer "      \}"
        puts $file_writer "      mgr.ackCommand_[set alias](cmdId, SAL__CMD_COMPLETE, 0, \"Done : OK\");"
        puts $file_writer "      break;"
        puts $file_writer "    \}"
        puts $file_writer "    os_nanoSleep(delay_10ms);"
        puts $file_writer "  \}"
        puts $file_writer "  cout << \"=== [set subsys]_[set alias] end of topic ===\" << endl;"
    }

    puts $file_writer "/* Remove the DataWriters etc */"
    puts $file_writer "  mgr.salShutdown();"
    puts $file_writer "  return 0;"
    puts $file_writer "\}"

    puts $file_writer "int main (int argc, char *argv\[\])\{"
    puts $file_writer "    return test_[set subsys]_all_controller();"
    puts $file_writer "\}"
}

proc insertMakeFile { subsys file_writer } {
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
    puts $file_writer "MAKEFILE      = Makefile.sacpp_[set subsys]_testcommands // may be not needed"
    puts $file_writer "DEPENDENCIES  ="
    puts $file_writer "BTARGETDIR    = ./"

    puts $file_writer "BIN1           = \$(BTARGETDIR)sacpp_[set subsys]_all_commander"
    puts $file_writer "OBJS1          = .obj/SAL_[set subsys].o .obj/sacpp_[set subsys]_all_commander.o"
    puts $file_writer "SRC           = ../src/SAL_[set subsys].cpp    sacpp_[set subsys]_all_commanderc"

    puts $file_writer "BIN2          = \$(BTARGETDIR)sacpp_[set subsys]_all_controller"
    puts $file_writer "OBJS2         = .obj/SAL_[set subsys].o .obj/sacpp_[set subsys]_all_controller.o"
    puts $file_writer "SRC           = ../src/SAL_[set subsys].cpp    sacpp_[set subsys]_all_controllerc"

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

    puts $file_writer ".obj/sacpp_[set subsys]_all_commander.o: ../src/sacpp_[set subsys]_all_commander.cpp"
    puts $file_writer "	@\$(TESTDIRSTART) \".obj/../src\" \$(TESTDIREND) \$(MKDIR) \".obj/../src\""
    puts $file_writer "	\$(COMPILE.cc) \$(EXPORTFLAGS) \$(OUTPUT_OPTION) ../src/sacpp_[set subsys]_all_commander.cpp"

    puts $file_writer "\$(BIN1): \$(OBJS1)"
    puts $file_writer "	@\$(TESTDIRSTART) \"\$(BTARGETDIR)\" \$(TESTDIREND) \$(MKDIR) \"\$(BTARGETDIR)\""
    puts $file_writer "	\$(LINK.cc) \$(OBJS1) \$(LDLIBS) \$(OUTPUT_OPTION)"

    puts $file_writer ".obj/sacpp_[set subsys]_all_controller.o: ../src/sacpp_[set subsys]_all_controller.cpp"
    puts $file_writer "	@\$(TESTDIRSTART) \".obj/../src\" \$(TESTDIREND) \$(MKDIR) \".obj/../src\""
    puts $file_writer "	\$(COMPILE.cc) \$(EXPORTFLAGS) \$(OUTPUT_OPTION) ../src/sacpp_[set subsys]_all_controller.cpp"

    puts $file_writer "\$(BIN2): \$(OBJS2)"
    puts $file_writer "	@\$(TESTDIRSTART) \"\$(BTARGETDIR)\" \$(TESTDIREND) \$(MKDIR) \"\$(BTARGETDIR)\""
    puts $file_writer "	\$(LINK.cc) \$(OBJS2) \$(LDLIBS) \$(OUTPUT_OPTION)"

    puts $file_writer "generated: \$(GENERATED_DIRTY)"
	puts $file_writer "@-:"

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
