#!/usr/bin/env tclsh

set csc [lindex $argv 0]

puts stdout "SAL apidoc - Initializing"
set SAL_DIR $env(SAL_DIR)
set TS_SAL_DIR $env(TS_SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)
set OSPL_HOME $env(OSPL_HOME)
set OPTIONS(verbose) 0

exec mkdir -p $SAL_WORK_DIR/docbuild_[set csc]/cmake
exec mkdir -p $SAL_WORK_DIR/docbuild_[set csc]/apiDocumentation
cd $SAL_WORK_DIR/docbuild_[set csc]

source $SAL_DIR/activaterevcodes.tcl
source $SAL_DIR/update_ts_xml_dictionary.tcl
source $SAL_DIR/utilities.tcl
parseSystemDictionary

if { $argv == [lindex $SYSDIC(systems) end] } {
  puts stdout "SAL apidoc - Rebuilding CSC index"
  set fout [open $TS_SAL_DIR/doc/sal-apis.rst w]
  puts $fout ".. _lsst.ts.sal-apis:

##################################
Application Programming Interfaces
##################################
"
  foreach csys [lsort $SYSDIC(systems)] {
    set desc "N/A"
    if { [info exists SYSDIC([set csys],Description)] } {
      set desc $SYSDIC([set csys],Description)
    }
    puts $fout "
  * `[set csys] APIs <apiDocumentation/SAL_[set csys]/index.html>`_ : $desc"
  }
  close $fout
  cd $TS_SAL_DIR
##  exec ltd upload --product ts-sal --git-ref $env(GIT_BRANCH) --dir doc
}


puts stdout "SAL apidoc - Processing $csc"
cd $SAL_WORK_DIR/docbuild_[set csc]
exec rm -fr CMakefiles cmake_install.cmake CMakeDoxyfile.in CMakeDoxygenDefaults.cmake
exec rm -fr doxygen sphinx docs SAL_[set csc] $TS_SAL_DIR/doc/_build/html/apiDocumentation/SAL_[set csc]
exec mkdir -p SAL_[set csc]

set fout [open CMakeLists.txt w]
puts $fout "cmake_minimum_required (VERSION 3.8)

project (\"SAL_[set csc]\")

# Add the cmake folder so the FindSphinx module is found
set(CMAKE_MODULE_PATH \"\$\{PROJECT_SOURCE_DIR\}/cmake\" \$\{CMAKE_MODULE_PATH\})
add_subdirectory (\"docs\")"



if { [info exists SYSDIC($csc,cpp)] } {
  puts $fout "add_subdirectory (\"SAL_[set csc]\")"
}

close $fout

exec tar xvzf $SAL_DIR/SALDocument_docs_req

puts stdout "SAL apidoc - Preparing IDL"
exec mkdir -p SAL_[set csc]/idl
exec cp SAL_idl SAL_[set csc]/idl/.
cd SAL_[set csc]/idl
doxygenateIDL $SAL_WORK_DIR/idl-templates/validated/sal/sal_revCoded_[set csc].idl sal_revCoded_[set csc].idl
set result none ; set bad ""
catch { set result [exec doxygen SAL_idl] } bad
if { $result == "none" } {puts stdout $bad}
cd $SAL_WORK_DIR/docbuild_[set csc]

if { [info exists SYSDIC($csc,cpp)] } {
  puts stdout "SAL apidoc - Preparing C++"
  exec tar xzf $SAL_DIR/SALDocument_cpp_req -C SAL_[set csc]
  exec cp $SAL_DIR/code/templates/SAL_defines.h SAL_[set csc]/.
  exec cp $SAL_WORK_DIR/[set csc]/cpp/src/SAL_[set csc].cpp SAL_[set csc]/.
  exec cp $SAL_WORK_DIR/[set csc]/cpp/src/SAL_[set csc].h SAL_[set csc]/.
  exec cp $SAL_WORK_DIR/[set csc]/cpp/src/SAL_[set csc]C.h SAL_[set csc]/.
  set src [glob $SAL_WORK_DIR/[set csc]/cpp/*.cpp]
  foreach f $src {exec cp $f SAL_[set csc]/.}
  set src [glob $SAL_WORK_DIR/[set csc]/cpp/*.h]
  foreach f $src {exec cp $f SAL_[set csc]/.}
}

if { [info exists SYSDIC($csc,java)] } {
puts stdout "SAL apidoc - Preparing Java"
  exec mkdir SAL_[set csc]/java
  set src [glob $SAL_WORK_DIR/[set csc]/java/src/org/lsst/sal/*.java]
  foreach f $src {exec cp $f SAL_[set csc]/java/.}
  set src [glob $SAL_WORK_DIR/[set csc]/java/[set csc]/*.java]
  foreach f $src {exec cp $f SAL_[set csc]/java/.}
  cd SAL_[set csc]/java
  set allj [glob *.java]
  set doit "javadoc $allj"
  set result none ; set bad ""
  catch {set result [eval $doit] bad}
  if { $result == "none" } {puts stdout $bad}
}

cd $SAL_WORK_DIR/docbuild_[set csc]
if { [info exists SYSDIC($csc,salpy)] } {
  puts stdout "SAL apidoc - Preparing SALPY"
  exec cp $SAL_WORK_DIR/[set csc]/cpp/src/SALPY_[set csc].cpp SAL_[set csc]/.
  set result none
  catch {set result [exec sphinx-autogen SAL_Test/SALPY_Test.cpp] } bad
  if { $result == "none" } {puts stdout $bad}
  set fpy [open docs/SALPY_[set csc].rst w]
  puts $fpy "
===================
SALPY_[set csc] API
===================

.. automodule:: SALPY_[set csc]
"
  close $fpy
}

puts stdout "SAL apidoc - Generating sphinx input"

if { [info exists SYSDIC($csc,cpp)] } {
  set fout [open SAL_[set csc]/CMakeLists.txt w]
  puts $fout "add_library (SAL_[set csc] \"SAL_[set csc].cpp\" \"SAL_[set csc].h\")
target_include_directories(SAL_[set csc] PUBLIC .)

"
  close $fout
}


set fout [open /tmp/sreplace_[set csc] w]
puts $fout "#!/bin/sh
perl -pi -w -e 's/SALDocument/SAL_[set csc]/g;' docs/CMakeLists.txt
perl -pi -w -e 's/SALDocument/SAL_[set csc]/g;' docs/conf.py
perl -pi -w -e 's/SALDocument/SAL_[set csc]/g;' CMakeLists.txt
"
close $fout

exec chmod 755 /tmp/sreplace_[set csc]
exec /tmp/sreplace_[set csc]
set fout [open docs/index.rst w]
puts $fout "
.. SAL_[set csc] documentation master file, created by salgenerator

Welcome to SAL_[set csc]'s API documentation!
==================================================

`IDL [set csc] DDS Topics <idl/annotated.html>`_
"


if  { [info exists SYSDIC($csc,java)] } {
  puts $fout "
`Java [set csc] API <java/index.html>`_
"
}

puts $fout "
.. toctree::
   :maxdepth: 2
   :caption: Contents:

:ref:`genindex`

Docs
====

.. doxygenclass:: SAL_[set csc]
   :members:
"

if { [info exists SYSDIC($csc,cpp)] } {
  set s [lsort [split [exec grep struct SAL_[set csc]/SAL_[set csc]C.h] \n]]
  foreach t $s { 
    puts $fout ".. doxygenstruct:: [lindex $t 1]
   :members:
.. doxygenstruct:: salActor
   :members:"
  }
}
close $fout

puts stdout "SAL apidoc - Building $csc API documentation"

set result none ; set bad ""
catch {set result [exec cmake3 .] } bad
if { $result == "none" } {puts stdout $bad}
set result none
catch {set result [exec make] } bad
if { $result == "none" } {puts stdout $bad}

exec mv SAL_[set csc]/idl/html docs/sphinx/idl
if  { [info exists SYSDIC($csc,java)] } {
  exec mv SAL_[set csc]/java docs/sphinx/.
}

exec mkdir -p $TS_SAL_DIR/doc/_build/html/apiDocumentation
exec mv docs/sphinx $TS_SAL_DIR/doc/_build/html/apiDocumentation/SAL_[set csc]
##cd $TS_SAL_DIR
##exec ltd upload --product ts-sal --git-ref $env(GIT_BRANCH) --dir doc/_build/html/SAL[set csc]
### package-docs build will be done by Jenkins after all CSC's are built


