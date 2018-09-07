#!/usr/bin/env tclsh
#
set schema(ObsHistory) "obsHistID INTEGER PRIMARY KEY,Session_sessionID INTEGER,filter TEXT,expDate INTEGER,expMJD REAL, night INTEGER, visitTime REAL, visitExpTime REAL, finRank REAL, finSeeing REAL, transparency REAL, airmass REAL, vSkyBright REAL, filtSkyBrightness REAL, rotSkyPos REAL, lst REAL, altitude REAL, azimuth REAL, dist2Moon REAL, solarElong REAL, moonRA REAL, moonDec REAL, moonAlt REAL, moonAZ REAL, moonPhase REAL, sunAlt REAL, sunAZ REAL, phaseAngle REAL, rScatter REAL, mieScatter REAL, moonIllum REAL, moonBright REAL, darkBright REAL, rawSeeing REAL, wind REAL, humidity REAL, fiveSigmaDepth REAL, ditheredRA REAL, ditheredDec REAL, Field_fieldID INTEGER"
set s2 [split $schema(ObsHistory) ,]
set i 0
foreach f $s2 {
   set idx([lindex $f 0]) $i
   incr i 1
}


load  /usr/lib/sqlite3.22.0/libsqlite3.22.0.so Sqlite3
sqlite3 db1 /data/minion_1016_sqlite.db
set vid 24
set visit [db1 eval {select * from obsaa where obsHistID=$vid}]
puts stdout "Visit $vid : Altitude = [lindex $visit $idx(altitude)] Azimuth = [lindex $visit $idx(azimuth)]"


