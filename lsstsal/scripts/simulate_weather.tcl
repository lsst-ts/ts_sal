#!/usr/bin/env tclsh

set SAL_WORK_DIR $env(SAL_WORK_DIR)
set fin [open ctio-weather.txt r]
set sdate 2017-01-01
if { [info exists env(LSST_WEATHER_DATE)]}  {
   set sdate $env(LSST_WEATHER_DATE)
   set x 0
   catch {set x [exec grep $sdate ctio-weather.txt]}
   if { [llength $x] < 2880 } {
       puts stdout "No weather data for $env(LSST_WEATHER_DATE), limits are 2016-05-18 to 2017-05-17"
       exec sleep 10000
   }
}
set gotit 0
while { $gotit == 0 } {
    gets $fin rec
    if { [lindex $rec 0] == $sdate } {
      set gotit 1
    } 
}

set nrec 0
while { $nrec < 1440 } {
   gets $fin rec
   set temp  [lindex [split $rec ,] 1]
   set humid [lindex [split $rec ,] 2]
   set pres  [lindex [split $rec ,] 3]
   puts stdout "Publishing environment_weather : temp = $temp, humidity = $humid, pressure = $pres"
   catch {exec $SAL_WORK_DIR/environment_weather/cpp/standalone/sacpp_environment_pub $temp $humid $pres}
   after 58000
   incr nrec 1
}

close $fin

