#!/usr/bin/env tclsh

# Run runtime-generator.sh first

set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)
source $SAL_DIR/add_system_dictionary.tcl

source $SAL_DIR/sal_version.tcl

set DEST /data/staging/ts_visit_simulator

exec mkdir -p $DEST/test/tcs
exec mkdir -p $DEST/test/bin
exec mkdir -p $DEST/test/lib
exec mkdir -p $DEST/test/include

echo "Modifying hexapod positionSet commander"
cd $SAL_WORK_DIR/hexapod/cpp/src
exec cp $SAL_DIR/sacpp_hexapod_positionSet_commander.cpp .
exec make -f /tmp/Makefile.sacpp_hexapod_testcommands

cd $SAL_WORK_DIR/tcs/tcs/demo
exec make
if { [file exists tpkDemo.so] == 0 } {
   puts stdout "************FAILED TO BUILD tpkDemo.so****************"
   exit
}

exec mv tpkDemo.so ../bin/.

puts stdout "Copying tcs simulator"
exec cp -rv $SAL_WORK_DIR/tcs/tcs $DEST/test/tcs/.

puts stdout "Copying lsstsal baseline"
exec cp -rv /data/gitrepo/ts_visit_simulator/lsstsal $DEST/.
exec cp -rv /data/gitrepo/ts_visit_simulator/README $DEST/.
exec cp -rv /data/gitrepo/ts_visit_simulator/SAL_TCS_Simulator_User_Guide.pdf $DEST/.
exec cp -rv /data/gitrepo/ts_visit_simulator/setup.env $DEST/.

puts stdout "Copying OpenSplice"
exec tar -C $env(LSST_SDK_INSTALL) -cvf - OpenSpliceDDS | tar -C $DEST -xvf -

puts stdout "Updating XML"
set all [glob $SAL_WORK_DIR/*.xml]
foreach i $all {
   exec cp -v $i $DEST/test/.
}

puts stdout "Updating libsacpp"
set all [glob $SAL_WORK_DIR/*/cpp/libsacpp_*.so]
foreach i $all {
puts stdout $i
   exec cp -v $i $DEST/test/lib/.
}

puts stdout "Updating includes"
set all [glob $SAL_WORK_DIR/*/cpp/src/SAL_*.h]
foreach i $all {
puts stdout $i
   exec cp -v $i $DEST/test/include/.
}

puts stdout "Updating libSAL"
set all [glob $SAL_WORK_DIR/lib/libSAL_*.so]
foreach i $all {
   exec cp -v $i $DEST/test/lib/.
}

if {0}
puts stdout "Updating libSALLV"
set all [glob $SAL_WORK_DIR/lib/SALLV_*.so]
foreach i $all {
   exec cp -v $i $DEST/test/lib/.
}
set all [glob $SAL_WORK_DIR/*/labview]
foreach i $all {
   exec cp -rv $i $DEST/test/.
}


puts stdout "Updating libSALPY"
set all [glob $SAL_DIR/../lib/SALPY_*.so]
foreach i $all {
   exec cp -v $i $DEST/test/lib/.
}

puts stdout "Updating saj"
set all [glob $SAL_WORK_DIR/*/java/saj_*.jar]
foreach i $all {
   exec cp -v $i $DEST/test/lib/.
}

puts stdout "Updating sal java"
set all [glob $SAL_WORK_DIR/maven/*_$SALVERSION/target/sal_*$SALVERSION.jar]
foreach i $all {
   exec cp -v $i $DEST/test/lib/.
}

puts stdout "Updating Telemetry tests"
foreach subsys $SYSDIC(systems) {
   catch {
     set all [glob $SAL_WORK_DIR/[set subsys]_*]
     foreach i $all {
      if { [file isdirectory $i] } {
         puts stdout "Processing $i"
         set id [file tail $i]
         exec mkdir -p $DEST/test/[set subsys]/cpp/src/
         exec cp -v $SAL_WORK_DIR/$id/cpp/standalone/sacpp_[set subsys]_pub $DEST/test/[set subsys]/cpp/src/sacpp_[set id]_publisher
         exec cp -v $SAL_WORK_DIR/$id/cpp/standalone/sacpp_[set subsys]_sub $DEST/test/[set subsys]/cpp/src/sacpp_[set id]_subscriber
      }
     }
   }
}

puts stdout "Updating Command tests"
foreach subsys $SYSDIC(systems) {
  catch {
   set all [glob $SAL_WORK_DIR/[set subsys]/cpp/src/*_commander]
   foreach i $all {
      exec cp -v $i $DEST/test/[set subsys]/cpp/src/.
      puts stdout "copied $i"
   }
   set all [glob $SAL_WORK_DIR/[set subsys]/cpp/src/*_controller]
   foreach i $all {
      exec cp -v $i $DEST/test/[set subsys]/cpp/src/.
      puts stdout "copied $i"
   }
  }
}

puts stdout "Updating Event tests"
foreach subsys $SYSDIC(systems) {
  catch {
   set all [glob $SAL_WORK_DIR/[set subsys]/cpp/src/*_log]
   foreach i $all {
      exec cp -v $i $DEST/test/[set subsys]/cpp/src/.
      puts stdout "copied $i"
   }
   set all [glob $SAL_WORK_DIR/[set subsys]/cpp/src/*_send]
   foreach i $all {
      exec cp -v $i $DEST/test/[set subsys]/cpp/src/.
      puts stdout "copied $i"
   }
  }
}
}

puts stdout "Updating commanders and controllers"
exec cp $SAL_WORK_DIR/camera/cpp/src/sacpp_camera_initImage_commander $DEST/test/bin/.
exec cp $SAL_WORK_DIR/camera/cpp/src/sacpp_camera_setFilter_commander $DEST/test/bin/.
exec cp $SAL_WORK_DIR/camera/cpp/src/sacpp_camera_takeImages_commander $DEST/test/bin/.
exec cp $SAL_WORK_DIR/dome/cpp/src/sacpp_dome_Move_commander $DEST/test/bin/.
exec cp $SAL_WORK_DIR/dome/cpp/src/sacpp_dome_Crawl_commander $DEST/test/bin/.
exec cp $SAL_WORK_DIR/hexapod/cpp/src/sacpp_hexapod_positionSet_commander $DEST/test/bin/.
exec cp $SAL_WORK_DIR/m2ms/cpp/src/sacpp_m2ms_ApplyBendingMode_commander $DEST/test/bin/.
exec cp $SAL_WORK_DIR/camera/cpp/src/sacpp_camera_startIntegration_send $DEST/test/bin/.
exec cp $SAL_WORK_DIR/camera/cpp/src/sacpp_camera_startReadout_send $DEST/test/bin/.
exec cp $SAL_WORK_DIR/rotator/cpp/src/sacpp_rotator_track_commander $DEST/test/bin/.
exec cp $SAL_WORK_DIR/MTMount/cpp/src/sacpp_MTMount_trackTarget_commander $DEST/test/bin/.
exec cp $SAL_WORK_DIR/hexapod/cpp/src/sacpp_hexapod_move_commander $DEST/test/bin/.

exec cp $SAL_WORK_DIR/camera/cpp/src/sacpp_camera_initImage_controller $DEST/test/bin/.
exec cp $SAL_WORK_DIR/camera/cpp/src/sacpp_camera_setFilter_controller $DEST/test/bin/.
exec cp $SAL_WORK_DIR/camera/cpp/src/sacpp_camera_takeImages_controller $DEST/test/bin/.
exec cp $SAL_WORK_DIR/dome/cpp/src/sacpp_dome_Move_controller $DEST/test/bin/.
exec cp $SAL_WORK_DIR/dome/cpp/src/sacpp_dome_Crawl_controller $DEST/test/bin/.
exec cp $SAL_WORK_DIR/hexapod/cpp/src/sacpp_hexapod_positionSet_controller $DEST/test/bin/.
exec cp $SAL_WORK_DIR/m2ms/cpp/src/sacpp_m2ms_ApplyBendingMode_controller $DEST/test/bin/.
exec cp $SAL_WORK_DIR/camera/cpp/src/sacpp_camera_startIntegration_log $DEST/test/bin/.
exec cp $SAL_WORK_DIR/camera/cpp/src/sacpp_camera_startReadout_log $DEST/test/bin/.
exec cp $SAL_WORK_DIR/rotator/cpp/src/sacpp_rotator_track_controller $DEST/test/bin/.
exec cp $SAL_WORK_DIR/MTMount/cpp/src/sacpp_MTMount_trackTarget_controller $DEST/test/bin/.
exec cp $SAL_WORK_DIR/hexapod/cpp/src/sacpp_hexapod_move_controller $DEST/test/bin/.
exec cp $SAL_WORK_DIR/hexapod/cpp/src/sacpp_hexapod_move_controller $DEST/test/bin/.

puts stdout "Updating EFD clients"
source $env(SAL_DIR)/gengenericefd.tcl

updateefdschema
foreach subsys "camera dome hexapod MTMount m2ms rotator" {
  catch {
   set all [glob $SAL_WORK_DIR/[set subsys]/cpp/src/sacpp_*_efdwriter]
   foreach i $all {
      exec cp -v $i $DEST/test/[set subsys]/cpp/src/.
      puts stdout "copied $i"
   }
  }
}


puts stdout "Updating sal scripts"
foreach i "command_test_gui hexapod_sim.tcl simulate_controllers simulate-visits.tcl genidlshmem.tcl logevent_test_gui simulate_java_controllers  standardvisit_commands.tcl" {
   exec cp -v $SAL_DIR/$i $DEST/lsstsal/scripts/.
}


puts stdout "*******Remember to delete unused OpenSpliceDDS versions********"






