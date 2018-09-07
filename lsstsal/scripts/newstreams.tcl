topic tcs.kernel.TrackRefSys 1 3 1
Properties of the geocentric apparent coordinate reference system
Float tdbj
Float amprms 21
Float ae2mt 9
Float hm
Float tlat
Float diurab
Float refa
Float refb
Float temp
Float press
Float humid
Float tlr
Float wavel
Float sst
Float cst
topic tcs.kernel.Target 1 3 1
AzElTarget object represents a topocentric Az,El
String site 128
Float t0
Float az
Float el
Float azdot
Float eldot
Float Wavel                              # effective wavelength (microns)
Float XOffset                            # target offset
Float YOffset
String OffSys 128                        # offset reference frame
Float focalplaneX                        # focal plane position
Float focalplaneY                        # focal plane position
Float Temp                               # temperature (deg K)
Float Press                              # pressure (mbar)
Float Humid                              # relative humidity
Float TLR                                # tropospheric lapse rate
Float Tai                                # TAI of last pointing calculation (MJD)
topic tcs.kernel.DawdleFilter 1 3 1
Dawdle filter parameters
Float TunePar                            # tuning parameter (maximum velocity)
Byte  Bypass                             # bypass flag
Float T                                  # last time filter ran
topic tcs.kernel.FK5Target 1 3 1
FK5Target object represents a fixed position in the FK5 catalog
Float ra
Float dec
Float equinox
Float epoc
Float pmRA
Float pmDec
Float parallax
Float rv
topic tcs.kernel.OpticsVt 1 3 10
OpticsVt object generates an tip/tilt demand 
Float tip
Float tilt
topic tcs.kernel.PointingControl 1 3 10
Pointing control holds pointing corrections from auto-guiders and handsets.
String RollFilter                        # filter for roll axis
String PitchFilter                       # filter for pitch axis
Float AGuide                             # guide correction in roll
Float BGuide                             # guide correction in pitch
Float ALocal                             # local correction in roll
Float BLocal                             # local correction in pitch
topic tcs.kernel.PointingLog 1 3 1
A pointing map measurement
Float Tai                                # TAI (MJD) of obervation
Float Ra                                 # ICRF right ascension of observation (radians)
Float Dec                                # ICRF declination of observation (radians)
Float Wavel                              # wavelength (microns)
Float Roll                               # roll demand at Tai (radians)
Float Pitch                              # pitch demand at Tai (radians)
Float Casspa                             # cass equivalent rotator angle (radians)
Float Xr                                 # pointing origin X coordinate (mm)
Float Yr                                 # pointing origin Y coordinate (mm)
Float Fl                                 # focal length (mm)
Float Temp                               # temperature (deg K)
Float Press                              # pressure (mbar)
Float Humid                              # relative Humidity
Float Tlr                                # tropospheric lapse rate
Float Rcorr                              # correction to rotator angle (radians)
Float Aux 3                              # auxiliary readings
Byte Marked                              # data available flag
topic tcs.kernel.PointingModel 1 3 0.01
PointingModel summerizes the pointing model at a given roll and pitch as index errors in the two axes
Int Model 30                 # term numbers for current model
Float Coeffv 100             # coefficient value
Int Nterml                   # number of local terms
Int Ntermx                   # number of terms implemented explicitly
Int Nterms                   # number of terms available currently
String Coeff1 32             # coefficient names
String Coeff2 32             # coefficient names
String Coeff3 32             # coefficient names
String Coeff4 32             # coefficient names
String Coeff5 32             # coefficient names
String Coeff6 32             # coefficient names
String Coeff7 32             # coefficient names
String Coeff8 32             # coefficient names
String Coeff9 32             # coefficient names
String Cofor1 32             # format of generic term
String Cofor2 32             # format of generic term
String Cofor3 32             # format of generic term
String Cofor4 32             # format of generic term
String Cofor5 32             # format of generic term
String Cofor6 32             # format of generic term
String Cofor7 32             # format of generic term
String Cofor8 32             # format of generic term
String Cofor9 32             # format of generic term
topic tcs.kernel.Site 1 3 0.01
Site defines the location of the telescope
Float tai
Float delat
Float delut
Float ttmtat
Float elongm
Float latm
Float hm
Float xpm
Float ypm
Float Delut                       # UT1 - UTC (days)
Float Delat                       # TAI -UTC (days)
Float Ttmtai                      # TT - TAI (days)
Float Elong                       # corrected east longitude (radians)
Float Lat                         # corrected latitude (radians)
Float Uau                         # distance from spin axis (AU)
Float Vau                         # distance from equator (AU)
Float Ukm                         # distance from spin axis (km)
Float Vkm                         # distance from equator (km)
Float Diurab                      # diurnal aberration (radians)
Float T0                          # reference epoch TAI (MJD)
Float St0                         # reference siderial time (radians)
Float Tt0                         # reference time TT (MJD)
Float Ttj                         # reference time TT (Julian date)
Float Amprms 21                   # apparent to mean parameters
Float Aoprms 15                   # apparent to observed parameters
Float Refa                        # tan refraction constant
Float Refb                        # tan**3 refraction constant
Float Daz                         # daily motion
topic tcs.kernel.TimeKeeper 1 100 1
TimeKeeper object records the instant in time that all the kernel calculations are done.
Float Tai                         # time TAI (MJD)
Float Tt                          # TT time at Tai (MJD)
Float Cst                         # cosine of sidereal time
Float Sst                         # sine of sidereal time
Float Dcst                        # rate of change of Cst per sample interval
Float Dsst                        # rate of change of Sst per sample interval
topic tcs.kernel.TrackingTarget 1 3 0.01
Tracking targets are targets that can be adequately be represented by a position and rate in the tracking frame.
Float PositionX                   # position in tracking frame
Float PositionY                   # position in tracking frame
Float T0                          # reference time
Float VelocityX                   # tracking rate in tracking frame
Float VelocityY                   # tracking rate in tracking frame
