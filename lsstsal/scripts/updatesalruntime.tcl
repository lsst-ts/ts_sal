#!/usr/bin/env tclsh

# Run runtime-generator.sh and then update_visitsim.tcl firsts

set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)
source $SAL_DIR/add_system_dictionary.tcl

source $SAL_DIR/sal_version.tcl

set DEST /data/gitrepo/ts_sal_runtime
exec mkdir -p $DEST/tcs

puts stdout "Copying visit simulator"
exec cp -rv $SAL_WORK_DIR/visitSimulator $DEST/test/.

puts stdout "Updating XML"
set all [glob $SAL_WORK_DIR/*.xml]
foreach i $all {
   exec cp -v $i $DEST/test/.
}

puts stdout "Updating libraries"
exec cp -r lib $DEST/.


puts stdout "Updating executable tests"
foreach subsys $SYSDIC(systems) {
      if { [file isdirectory $subsys] } {
         puts stdout "Processing $subsys"
         exec cp -vr $SAL_WORK_DIR/$subsys $DEST/.
      }
}

exec mkdir -p $DEST/sql
puts stdout "Updating sql"
foreach subsys $SYSDIC(systems) {
  exec cp -r sql/[set subsys].sqldef $DEST/sql/.
  exec cp -r sql/[set subsys]_items.sql $DEST/sql/.
}

#
#  recipe to rebuild tma software
#
# unzip /data/repozips/[date]/lsst_master.zip
# cd lsst-master/tma_management
# mkdir build
# cd build
# make
#
puts stdout "Updating mcs simulator"
exec cp -r lsst-master/tma_management/build $DEST/MTMount/.
exec mv $DEST/MTMount/build $DEST/MTMount/mcs_simulator
exec cp -r lsst-master/tma_management/doc/doc/html $DEST/MTMount/mcs_simulator/.

puts stdout "Updating rotator simulator"

#
#  recipe to rebuild rotator software
#
# 
# cd rotator
# unzip /data/repozips/[date]/ts_lsst_rotator_simulator-master.zip
# cd rotator_simulator
# make
#
puts stdout "Updating rotator simulator"
exec cp -r rotator/cpp/rotator_simulator $DEST/rotator/cpp/.

#
#  recipe to rebuild ccs software
#
# cd camera/java
# unzip /data/repozips/[date]/ToyOCSBridge-master.zip
# cd ToyOCSBridge-master
# mvn install
puts stdout "Updating ccs-ocs bridge simulator"
exec cp -r camera/java $DEST/camera/.

puts stdout "Update scripts"
exex cp -r /data/gitrepo/ts_visit_simulator/lsstsal/scripts $DEST/lsstsal/.



