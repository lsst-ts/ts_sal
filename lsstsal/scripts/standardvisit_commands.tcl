#!/usr/bin/env tclsh
#
#  This script is intended to be executed from the simulate-visits.tcl 
#  script.  It checks the input arguments and then uses the SAL
#  test programs to send the appropriate commands to the subsystems
#
# args : az alt [filter]
#

source $env(SAL_DIR)/hexapod_sim.tcl 

proc cmdok { result } {
    set i 0
    catch {set i [lsearch $result completed]}
    if { $i > 0 } {
      puts stdout "result = $result"
      if { [lindex $result [expr $i+1]] == "ok" } {
        return "Command completed OK"
      }
    }
    catch { puts stdout $result }
    return "Simulated"
}

set az  [lindex $argv 0]
set alt [lindex $argv 1]
set cameraCommander_initImage   $env(SAL_WORK_DIR)/bin/sacpp_camera_initImage_commander
set cameraCommander_setFilter   $env(SAL_WORK_DIR)/bin/sacpp_camera_setFilter_commander
set cameraCommander_takeImages  $env(SAL_WORK_DIR)/bin/sacpp_camera_takeImages_commander
set domeCommander     		$env(SAL_WORK_DIR)/bin/sacpp_dome_Move_commander
set domeCrawlCommander     	$env(SAL_WORK_DIR)/bin/sacpp_dome_Crawl_commander
set hexapodCommander 		$env(SAL_WORK_DIR)/bin/sacpp_hexapod_positionSet_commander
set m2msCommander     		$env(SAL_WORK_DIR)/bin/sacpp_m2ms_ApplyBendingMode_commander
set hexapodCommander_move 	$env(SAL_WORK_DIR)/bin/sacpp_hexapod_move_commander
set startIntegration 		$env(SAL_WORK_DIR)/bin/sacpp_camera_startIntegration_send
set startReadout		$env(SAL_WORK_DIR)/bin/sacpp_camera_startReadout_send

puts stdout "----- Start of visit -----------------------------------------"
if { $argc > 2 } {
   set filter [lindex $argv 2]
   puts stdout "Filter change required"
   puts stdout "Selecting $filter : filter position set $filter name=$filter"
   set status [catch {exec $cameraCommander_setFilter $filter} result]
   puts stdout [cmdok $result]
   after 1000
}

set camhex [hexcalc camera [lindex [split $alt :] 0]]
set m2hex  [hexcalc m2     [lindex [split $alt :] 0]]
set ax1 [lindex $camhex 0]
set ax2 [lindex $camhex 1]
set ax3 [lindex $camhex 2]
set ax4 [lindex $camhex 3]
set ax5 [lindex $camhex 4]
set ax6 [lindex $camhex 5]
set bx1 [lindex $m2hex 0]
set bx2 [lindex $m2hex 1]
set bx3 [lindex $m2hex 2]
set bx4 [lindex $m2hex 3]
set bx5 [lindex $m2hex 4]
set bx6 [lindex $m2hex 5]

# Observers constant k in degress per second
set k [expr 15.04106858 * cos(-30.7494/180.*3.14159365) / 86400.]
set rotrate [expr $k * cos($az) / cos($alt)]

puts stdout "Moving dome : target position set altaz azimuth=$az elevation=$alt"

set status [catch {exec $domeCommander $az $alt} result]
puts stdout [cmdok $result]
###set status [domeCrawl $azvel $altvel]

###puts stdout "Moving m2   : target position azimuth=$az elevation=$alt"
###set status [catch {exec $m2msCommander 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0} result]
###puts stdout [cmdok $result]

puts stdout "Adjusting camera hexapod : actuators position absolute coords x=$ax1 y=$ax2 z=$ax3 v=$ax4 w=$ax5 z=$ax6"
set status [catch {exec /usr/bin/env LSST_HEXAPOD_ID=1 $hexapodCommander $ax1 $ax2 $ax3 $ax4 $ax5 $ax6 1} result]
puts stdout [cmdok $result]
puts stdout "Adjusting m2 hexapod : actuators position absolute coords x=$bx1 y=$bx2 z=$bx3 v=$bx4 w=$bx5 z=$bx6"
set status [catch {exec /usr/bin/env LSST_HEXAPOD_ID=2 $hexapodCommander $bx1 $bx2 $bx3 $bx4 $bx5 $bx6 1} result]
puts stdout [cmdok $result]
set status [catch {exec /usr/bin/env LSST_HEXAPOD_ID=1 $hexapodCommander_move 1} result]
set status [catch {exec /usr/bin/env LSST_HEXAPOD_ID=2 $hexapodCommander_move 1} result]

#puts stdout "Sending guide star ROI's : guiders roi set position xpos=1,1,1,1,1,1,1,1 ypos=2,2,2,2,2,2,2,2 roiSize=32,32,32,32,32,32,32,32"
#set status [catch {exec $cameraCommander   1 guiders roi set position "xpos=1,1,1,1,1,1,1,1 ypos=2,2,2,2,2,2,2,2 roiSize=32,32,32,32,32,32,32,32"} result]
###puts stdout [cmdok $result]

after 4000
set status [catch {exec $cameraCommander_initImage 2.0} result]
puts stdout [cmdok $result]
after 1000
puts stdout "Starting science exposures : imager expose observe science numimages=2 expTime=15 shutter=true guide=true wfs=true"
set status [catch {exec $startIntegration} result]
set status [catch {exec $cameraCommander_takeImages 2 15.0 1 1 1 1 testImageName_[clock seconds]} result]
puts stdout [cmdok $result]
after 20000
set status [catch {exec $startReadout} result]
puts stdout "----- End of visit -------------------------------------------"
after 2000



