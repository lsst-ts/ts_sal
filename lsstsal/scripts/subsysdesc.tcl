set DESC(tcs) "The main purpose of the Telescope Control System (TCS) software is to accept the target position of a celestial object, which can be given in a variety of coordinate systems, and calculate mount, rotator and optical surface positions, so that the target is imaged perfectly at a given point in the focal plane. Furthermore, the TCS is characterized by the need to integrate a number of heterogeneous subsystems, which exhibit complex interactions. These interactions, although not hard realtime bounded, need a high level of synchronization.
<P>
The Telescope Control System (TCS) is the central coordination facility for the delivery of high quality field images to the camera. It is responsible for the precise pointing and tracking calculations necessary to observe a certain field. The TCS does not itself operate any mechanical component; rather it delegates this responsibility to the various telescope subsystems and manages them according to the observation requests.
<P>
The TCS design is based on a distributed system model. Under this model, the components
interact through well defined interfaces, to accomplish the desired system behavior. The maincomponents in the proposed implementation, are tied together by the use of an Ethernet Bus, thus permitting the efficient exchange of commands and status among them.
<P>
The distributed nature of the TCS is complemented by the control model based on a
supervisory control strategy. Under this model, a supervisor agent computes the “setpoint” to be applied to a controllable device. The time critical loops are closed locally at the device level, and the device makes status information available for monitoring purposes.
<P>
The TCS itself will be controlled either directly by a telescope operator, or by commands
initiated by the Observatory Control System (OCS). Its role therefore, is to act as intermediary between the observer(s) and the telescope hardware, translating high level user commands into low level subsystem commands. Consistent with our control model, the TCS will return status information to be distributed system wide."


set DESC(activeOptics) "
<P>Optical Reconstructor. The optical reconstructor component computes optics aberrations,
normally in the form of zernike coefficients, from the images, or image segments, that will be provided by the CCS at a rate to be determined. The reconstructor will generate surface and position corrections, to be applied to the active optics components. Even though the final details of the interactions between optics, WFS and CCS are as yet to be determined, the present control model should apply as well, in that setpoints will be generated for the optics, CCS and mount components."





set DESC(camera) "The camera is one of the three primary LSST technical subsystems (along with the Telescope/Site Subsystem and the
Data Management Subsystem). It contains a 3.2 Gigapixel focal plane array, comprised of roughly 200 4K x 4K CCD
sensors, with 10 micron pixels. 
<P>The sensors are deep depleted, back illuminated devices with a highly segmented
architecture that enables the entire array to be read out in 2 s or less. These detectors are grouped into 3 x 3 arrays called
rafts. Each raft contains its own dedicated front end and back end electronics boards, which fit within the footprint of its
sensors, thus serving as a 144 Megapixel camera on its own. 
<P>All of the rafts, with their associated electronics, are mounted
on a silicon carbide grid inside a vacuum cryostat, with an intricate thermal control system that maintains the CCDs at an
operating temperature of roughly minus 90 degrees centigrade.
<P>The grid also contains sets of guide sensors and wavefront
sensors at the edge of the field. The entire grid, with the sensors, is actuated at a rate ~ 30 Hz in a fast guiding mode to
maintain a very narrow psf (0.7 arcseconds median), which is limited mainly by seeing fluctuations in the overlying
atmosphere.
<P>The entrance window to the cryostat is the third of the three refractive lenses. The other two lenses are mounted in an optics
structure at the front of the camera body. The camera body also contains a mechanical shutter, and a carrousel assembly
that holds five large optical filters, any of which can be inserted into the camera field of view for a given exposure. A sixth
optical filter will also be fabricated which can replace any of the five via an automated procedure accomplished during
daylight hours.
<P>
The camera system consists of multiple subsystems that include utilities, the camera body vessel and mechanisms for
shuttering and optical filtering, the imaging sensors, optical lenses and filters, a computerized data acquisition and control
system, the cryostat holding the detector array, readout and control electronics, wavefront sensors, and guide sensors."

set DESC(camera.xraycalib) "The xray calibration subsystem consists of an Fe55 source on wiperblade arm(s) that sweeps across the focal plane for
xray calibration of quantum efficiency, electrical gains and offsets, readout noise, and physical/cosmetic features of the
CCD array."


set DESC(ocs) " The Observatory Control System (OCS) is the master control system that schedules, coordinates, commands and monitors the observatory. 
Through the OCS the system can be started, adjusted during operations, monitored and stopped, both locally and remotely. 
The OCS provides the means to support safe observatory operations day and night.
"

set DESC(camera.FEM) "Directly beneath each packaged CCD module is a Front End Electronics Module (FEM) containing the following functionality.
<P><UL><LI>Analog signal processing ASIC
<LI>CCD clock drivers, ASIC or hybrid
<LI>Bias voltage dsitribution
</UL>This architecture minimizes the physical distance from CCD output amplifiers to the analog signal processing circuits, thus minimizing power dissipation and risk of noise pickup. The CCD clock drivers are assumed to be simple level translators, with no pattern generation at this point. Beyond generating clock signals, there is no digital activity at this level. All analog signals  are buffered and fully differential for purposes of noise immunity. Similarly, all timing signals comply with the Low Voltage Differential Signaling (LVDS) standard. Both the clock drivers and the bias generators will be programmable by means of a slow serial link."






set DESC(m1.TC) "
<P>Temperature monitoring  for sensors located in the m1
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time series statistics, sensor health.
  

 "

set DESC(m1.Electrical) "
<P>Electrical monitoring  for devices located in the m1 subsystem.<BR>Raw
data, calibrated voltages, calibrated current, device power status. "

set DESC(m1.Metrology) "
<P>Position control  for sensors located in the m1
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "


set DESC(m1.Support) "
<P>This subsystem maintains integrated support system condition for<BR>the
m1 support system. "

set DESC(m1.Actuators) "
<P>This subsystem maintains information on a per actuator basis<BR>persuant
to the low level behaviour of the components of<BR>the m1 support
system. "

set DESC(m1.Surface) "
<P>This subsystem maintains data pertaining to the requested and<BR>measured
surface properties (figure, stresses, temps etc). "

set DESC(m1m3.TC) "
<P>Temperature monitoring  for sensors located in the m3
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time series statistics, sensor health. "

set DESC(m1m3.Electrical) "
<P>Electrical monitoring  for devices located in the m3 subsystem.<BR>Raw
data, calibrated voltages, calibrated current, device power status. "

set DESC(m1m3.Metrology) "
<P>Position control  for sensors located in the m3
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "


set DESC(m1m3.Support) "
<P>This subsystem maintains integrated support system condition for<BR>the
m3 support system. "

set DESC(m1m3.Actuators) "
<P>This subsystem maintains information on a per actuator basis<BR>persuant
to the low level behaviour of the components of<BR>the m3 support
system. "

set DESC(m1m3.Surface) "
<P>This subsystem maintains data pertaining to the requested and<BR>measured
m3 surface properties (figure, stresses, temps etc). "

set DESC(m2ms.TC) "
<P>Temperature monitoring  for sensors located in the m2ms
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time series statistics, sensor health. "

set DESC(m2ms.Electrical) "
<P>Electrical monitoring  for devices located in the m2ms subsystem.<BR>Raw
data, calibrated voltages, calibrated current, device power status. "

set DESC(m2ms.Metrology) "
<P>Position control  for sensors located in the m2ms
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set DESC(hexapod.TC) "
<P>Temperature monitoring  for sensors located in the hexapod
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time series statistics, sensor health. "

set DESC(hexapod.Electrical) "
<P>Electrical monitoring  for devices located in the hexapod subsystem.<BR>Raw
data, calibrated voltages, calibrated current, device power status. "

set DESC(hexapod.Metrology) "
<P>Position control  for sensors located in the hexapod
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set DESC(hexapod.Actuators) "
<P>This subsystem maintains information on a per actuator basis<BR>persuant
to the low level behaviour of the components of<BR>the hexapod support
system. "

set DESC(hexapod.LimitSensors) "
<P>This subsystem maintains information on the state of Limit sensors"

set DESC(hexapod.Application) "
<P>This subsystem maintains application level data concerning the<BR>requested
and actual state of the hexapod support system. "

set DESC(m2ms.Actuators) "
<P>This subsystem maintains information on a per actuator basis<BR>persuant
to the low level behaviour of the components of<BR>the m2ms support
system. "

set DESC(m2ms.Surface) "
<P>This subsystem maintains data pertaining to the requested and<BR>measured
m2ms surface properties (figure, stresses, temps etc). "




set DESC(MTMount.TC) "
<P>Temperature monitoring  for sensors located in the mount
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time series statistics, sensor health. "

set DESC(MTMount.Electrical) "
<P>Electrical monitoring  for devices located in the mount
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set DESC(MTMount.Metrology) "
<P>Position control  for sensors located in the mount
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "


set DESC(MTMount.Alt) "
<P>This subsystem maintains application level information about
the<BR>Altitude axis requested and actual position and status. "

set DESC(MTMount.Az) "
<P>This subsystem maintains application level information about the<BR>Azimuth
axis requested and actual position and status. "

set DESC(MTMount.Rotator) "
<P>This subsystem maintains application level information about
the<BR>instrument rotator requested and actual position and status." 


set DESC(MTMount.az.track) ""
set DESC(MTMount.az.platform) ""
set DESC(MTMount.az.drives) ""
set DESC(MTMount.el.drives) ""
set DESC(MTMount.az.encoder) ""
set DESC(MTMount.el.encoder) ""
set DESC(MTMount.az.brakes) ""
set DESC(MTMount.el.brakes) ""
set DESC(MTMount.az.cablewrap) ""
set DESC(MTMount.el.cablewrap) ""
set DESC(MTMount.az.hsb) ""
set DESC(MTMount.el.hsb) ""
set DESC(MTMount.az.limits) ""
set DESC(MTMount.el.limits) ""
set DESC(MTMount.oss.pumps) ""
set DESC(MTMount.oss.thermal) ""
set DESC(MTMount.cs.control) ""
set DESC(MTMount.cs.power) ""
set DESC(MTMount.power.main) ""
set DESC(MTMount.az.power) ""
set DESC(MTMount.el.power) ""
set DESC(MTMount.capbanks) ""
set DESC(MTMount.balance) ""
set DESC(MTMount.util.air) ""
set DESC(MTMount.util.cooling) ""
set DESC(MTMount.util.oil) ""
set DESC(MTMount.cam.cablewrap) ""
set DESC(MTMount.mirrorcover) ""


set DESC(power.TC) "
<P>Temperature monitoring  for sensors located in the power
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time series statistics, sensor health. "

set DESC(power.Electrical) "
<P>Electrical monitoring  for devices located in the power
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set DESC(power.UPSs) "
<P>This topic record parameters for devices located in the UPS
subsystems.<BR>Raw data, calibrated voltages, calibrated current,
device power status,<BR>demand, usage, etc. "

set DESC(calibration.TC) "
<P>Temperature monitoring  for sensors located in the
calibration subsystem.<BR>Raw sensor readings, calibrated
temperatures, time series statistics, sensor health. "

set DESC(calibration.Electrical) "
<P>Electrical monitoring  for devices located in the calibration
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set DESC(calibration.Metrology) "
<P>Position control  for sensors located in the
calibration subsystem.<BR>Raw sensor readings, calibrated positions,
limit switches, status bits. "


set DESC(domeTHCS) "
<P>Temperature monitoring  for sensors located in the
dome subsystem.<BR>Raw sensor readings, calibrated temperatures,
time series statistics, sensor health. "

set DESC(domeMONCS) "
<P>Electrical monitoring  for devices located in the dome
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "


set DESC(domeADB) "
<P>This subsystem maintains high level information pertaining to
the<BR>dome positioning demand and performance, wind
loading<BR>etc. "

set DESC(domeLWS) "
<P>This subsystem maintains high level information pertaining to the<BR>dome
shutter positioning demand and performance, wind loading<BR>etc. "

set DESC(domeLouvers) "
<P>This subsystem maintains high level information pertaining to the<BR>dome
vents positioning demand and performance, wind loading<BR>etc. "

set DESC(domeAPS) "
<P>This subsystem controls the main shutter mechanism"



set DESC(auxscope.TC) "
<P>Temperature monitoring  for sensors located in the
Auxillary Telescope subsystem.<BR>Raw sensor readings, calibrated
temperatures, time series statistics, sensor health. "

set DESC(auxscope.Electrical) "
<P>Electrical monitoring  for devices located in the Auxillary
Telescope subsystem.<BR>Raw data, calibrated voltages, calibrated
current, device power status. "

set DESC(auxscope.Metrology) "
<P>Position control  for sensors located in the Auxillary
Telescope subsystem.<BR>Raw sensor readings, calibrated positions,
limit switches, status bits. "


set DESC(auxscope.TCS) "
<P>This subsystem maintains high level data pertaining to the state<BR>of
the Auxillary Telescope Control System (May be split into subtopics)."

set DESC(auxscope.Spectrometer) "
<P>This subsystem maintains high level data pertaining to the state<BR>of
the Auxillary Telescope Spectrograph (May be split into subtopics). "

set DESC(auxscope.Camera) "
<P>This subsystem maintains high level data pertaining to the state<BR>of
the Auxillary Telescope camera (May be split into subtopics). "

set DESC(lasercal.TC) "
<P>Temperature monitoring  for sensors located in the laser
calibration subsystem.<BR>Raw sensor readings, calibrated
temperatures, time series statistics, sensor health. "

set DESC(lasercal.Electrical) "
<P>Electrical monitoring  for devices located in the laser calibration
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set DESC(seeing_dimm) "The MASS/DIMM is a robotic instrument that continually tracks reference stars to measure the Star Scintillation and image
motion to evaluate the current atmospheric conditions."


set DESC(seeing_dimm.TC) "
<P>Temperature monitoring  for sensors located in the DIMM
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time series statistics, sensor health. "

set DESC(seeing_dimm.Electrical) "
<P>Electrical monitoring  for devices located in the DIMM
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set DESC(seeing_dimm.Metrology) "
<P>Position control  for sensors located in the DIMM
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "


set DESC(seeing_mass.TC) "
<P>Temperature monitoring  for sensors located in the MASS
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time series statistics, sensor health. "

set DESC(seeing_mass.Electrical) "
<P>Electrical monitoring  for devices located in the MASS
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set DESC(seeing_mass.Metrology) "
<P>Position control  for sensors located in the MASS
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set DESC(skycam) "The visible and IR all sky cameras operated on the summit to assess the conditions of the night sky and the transparency
as a function of sky position."


set DESC(skycam.TC) "
<P>Temperature monitoring  for sensors located in the
All sky cameras subsystem.<BR>Raw sensor readings, calibrated
temperatures, time series statistics, sensor health. "

set DESC(skycam.Electrical) "
<P>Electrical monitoring  for devices located in the All sky cameras
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set DESC(skycam.Metrology) "
<P>Position control  for sensors located in the
All sky cameras subsystem.<BR>Raw sensor readings, calibrated
positions, limit switches, status bits. "


set DESC(environment.TC) "
<P>Temperature monitoring  for sensors located in the
environment subsystem.<BR>Raw sensor readings, calibrated
temperatures, time series statistics, sensor health. "

set DESC(environment.Electrical) "
<P>Electrical monitoring  for devices located in the environment
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set DESC(environment.Weather) "
<P>This subsystem maintains weather data, both current predictions and
actual<BR>measurements. "

set DESC(environment.Dust_monitor) "
<P>This subsystem maintains information from the Dust Monitor
subsystem.<BR>Both low level mechanical status , and calculated
result data<BR>are included. "

set DESC(environment.Lightning_detector) "
<P>This subsystem maintains data from the Lightning detection subsystem<BR>and
current predictive data. "

set DESC(environment.Seismometer) "
<P>This subsystem maintains data from the Siesmometer subsystem.</P>"

set DESC(environment.Video_cameras) "
<P>This subsystem maintains system status for the video monitoring<BR>systems. The video system is a distributed network of addressable cameras located throughout the facility to give the operators
visual feedback of activity in and around the facility.
"

set DESC(OCS) "
<P>Observatory Control System is reponsible for issuing command and 
monitoring the performance of all telescope subsystems"

set DESC(eec) "Enclosure Environment Conditioning"

set DESC(atSpectrometer) "Auxillary telescope spectrometer"
set DESC(atWhiteLight) "Auxillary telescope spectrometer calibration source"

set DESC(calibrationSpectrometer) "Calibration screen Spectrometer"
set DESC(calibrationElectrometer) "Calibration screen Electormeter"

set DESC(camera.Dewar_Cooler) ""
set DESC(seeing_dimm.TC) ""
set DESC(seeing_dimm.Electrical) ""
set DESC(seeing_dimm.Metrology) ""
set DESC(seeing_mass.TC) ""
set DESC(seeing_mass.Electrical) ""
set DESC(seeing_mass.Metrology) ""

set SID(OCS) 1.0
set SID(camera) 15

set SID(camera.TC) 15.1
set SID(camera.Electrical) 15.2
set SID(camera.Metrology) 15.3
set SID(camera.RNA) 15.4
set SID(camera.Science_sensor_metadata) 15.5
set SID(camera.Wavefront_sensors) 15.6
set SID(camera.Guide_sensors) 15.7
set SID(camera.Dewar_CoolerHeater) 15.8
set SID(camera.Vacuum) 15.9
set SID(camera.Filters) 15.10
set SID(camera.Shutter) 15.11

set SID(m1m3) 2
set SID(m1m3.TC) 2.1
set SID(m1m3.Electrical) 2.2
set SID(m1m3.Metrology) 2.3
set SID(m1m3.Support) 2.4
set SID(m1m3.Actuators) 2.5
set SID(m1m3.Surface) 2.6

set SID(m2ms) 4
set SID(m2ms.TC) 4.1
set SID(m2ms.Electrical) 4.2
set SID(m2ms.Metrology) 4.3
set SID(m2ms.Hexapod) 4.4
set SID(m2ms.Actuators) 4.5
set SID(m2ms.Surface) 4.6

set SID(MTMount) 5
set SID(MTMount.TC) 5.1
set SID(MTMount.Electrical) 5.2
set SID(MTMount.Metrology) 5.3
set SID(MTMount.Alt) 5.4
set SID(MTMount.Az) 5.5

set SID(power) 6
set SID(MTMount.Rotator) 5.6
set SID(power.TC) 6.1
set SID(power.Electrical) 6.2
set SID(power.UPSs) 6.3

set SID(calibration) 7
set SID(calibration.TC) 7.1
set SID(calibration.Electrical) 7.2
set SID(calibration.Metrology) 7.3

set SID(dome) 8
set SID(domeTHCS) 8.1
set SID(domeMONCS) 8.2
set SID(domeADB) 8.2
set SID(domeAPS) 8.3
set SID(domeLouvers) 8.4
set SID(domeTHCS) 8.5

set SID(auxscope) 9
set SID(auxscope.TC) 9.1
set SID(auxscope.Electrical) 9.2
set SID(auxscope.Metrology) 9.3
set SID(auxscope.TCS) 9.4
set SID(auxscope.Spectrometer) 9.5
set SID(auxscope.Camera) 9.6

set SID(lasercal) 10
set SID(lasercal.TC) 10.1
set SID(lasercal.Electrical) 10.2

set SID(seeing_dimm) 11
set SID(seeing_dimm.TC) 11.1
set SID(seeing_dimm.Electrical) 11.2
set SID(seeing_dimm.Metrology) 11.3

set SID(seeing_mass) 12
set SID(seeing_mass.TC) 12.1
set SID(seeing_mass.Electrical) 12.2
set SID(seeing_mass.Metrology) 12.3

set SID(skycam) 13
set SID(skycam.TC) 13.1
set SID(skycam.Electrical) 13.2
set SID(skycam.Metrology) 13.3

set SID(environment) 14
set SID(environment.TC) 14.1
set SID(environment.Electrical) 14.2
set SID(environment.Weather) 14.3
set SID(environment.Dust_monitor) 14.4
set SID(environment.Lightning_detector) 14.5
set SID(environment.Seismometer) 14.6
set SID(environment.Video_cameras) 14.7

set SID(camera.Dewar_Cooler) ""
set SID(seeing_dimm) 11
set SID(seeing_dimm.TC) 11.1
set SID(seeing_dimm.Electrical) 11.2
set SID(seeing_dimm.Metrology) 11.3

set SID(seeing_mass) 12
set SID(seeing_mass.TC) 12.1
set SID(seeing_mass.Electrical) 12.2
set SID(seeing_mass.Metrology) 12.3

set SID(tcs) 13

set SID(heaxpod) 15
set SID(heaxpod.Actuators) 15.1
set SID(heaxpod.Application) 15.2
set SID(heaxpod.Electrical) 15.3
set SID(heaxpod.LimitSensors) 15.4
set SID(heaxpod.Metrology) 15.5
set SID(heaxpod.TC) 15.6

set SID(eec) 16



set DOCO(ocs) Document-869
set DOCO(standards-sw) "ESA 1991, Software Engineering Standards, ESA PSS-05-0, Issue 2, European Space Agency"
set DOCO(m1) Document-3167
set DOCO(m2ms) Document-3167
set DOCO(m3) Document-3167
set DOCO(dome) Document-341,Document-342,Document-2389
set DOCO(eec) TSS-1797


set DESC(auxscope) "Auxiallary telescope, 1.5 m photometric telescope with LSST TCS"

set DESC(calibration) "Calibration equipment"

set DESC(dome) "Dome and dome<BR>
1.1.Basic Functions: The purpose of the dome is to protect the telescope and camera from adverse environmental conditions both during observing and when not in operation.  The clear optical path provided by the dome, the contribution of dome seeing to the overall error budget, and the operational parameters of the dome will be consistent with the Telescope Requirements Document (Doc # 2389)
<P>Thermally Benign: A fundamental objective in the dome design will be maintaining a beneficial thermal environment for the seeing performance of the telescope.  Preconditioning of the telescope environment, passive ventilation, the use of materials with low thermal inertia, and other strategies will be employed for that purpose.
<P>Special LSST Survey Requirements: As a telescope dedicated to a demanding survey program, LSST has some special characteristics that are reflected in the dome requirements:
A critical need to shield the telescope from stray light due to the wide 3.5º telescope observing angle
A higher than normal requirement for dome reliability imposed by the continuous nature of the survey observing regime. 
A faster than normal dome tracking speed required by the rapid paced, robotic observing cadence.
<P>
Maintenance: In addition to its operational characteristics, the dome provides adequate enclosed space and appropriate facilities for engineering and maintenance work on the telescope, camera, and on the dome itself.
<P>
Coordination with Telescope, Optics and Instrument Design: Designs for the telescope mount, optics, and camera are ongoing.  The baseline dimensions and operational characteristics of these elements are, however, well enough understood to allow development of an appropriate dome to enclose and service these systems.  Further refinements in telescope and camera design will be incorporated into future versions of this document, and later reflected in the detailed design of the dome.
<P>
Coordination with the Lower dome: The lower dome that supports the dome is a fixed building with requirements described in the Support Facility Design Requirements Document (Doc # 342). The dimensional and structural criteria for the lower dome are dictated by the dome.
<P>
Code Compliance and Structural Loads:  All aspects of the LSST dome will comply with current editions of the International Building Code, OSHA regulations, and other applicable design and construction standards as specified by LSST.  Wind and seismic loads for dome design will be developed based on the latest available historical and regional data.
<P>
Site: The LSST observatory will be located at the El Peñón peak on Cerro Pachón in Chile.  This is a mountaintop location at an elevation of approximately 2650m (8692 ft.) above sea level, and is subject to severe weather conditions.  This site is also subject to relatively high earthquake risk, with correspondingly high design factors for seismic acceleration.   The dome will be designed to withstand these and other specific environmental conditions of the site."

set DESC(environment) "Internal and external environmental monitoring systems"


set DESC(lasercal) "LSST Focal plane Laser Spot Alignment Pattern Projection System<BR>
 An array of laser spots generated by shining a laser 
  through a diffraction grating is projected onto the focal 
  plane imaging sensors as a fixed reference pattern
<P>
 The CCDs are read out and the locations of these laser 
  spots are stored
<P>
 Displacements of the apparent spot locations on 
  subsequent read outs can be used to infer shifts in the 
  positions of the CCD sensors
<P>
Spot generation using an optimized micromachined 2D array of apertures
A diffraction grating where the dimensions of the open apertures are on the order of the wavelength of the laser will generate a projected array of spots with relatively uniform amplitudes"

set DESC(m1) "Primary mirror system<P>
The primary is made from spun cast borosilicate blanks cast at the University
of Arizona’s Mirror Laboratory. These mirrors will use the standard hex cell pattern so the existing load spreader
designs can be used without modification. The arrangement of actuators and load spreaders has been adjusted near the
ID of the primary to adapt to the large center hole and the arrangement on the tertiary is adjusted as required at the OD.
Since we assume the use of the same support actuators as are in service on the LBT 8.4 m primary, the test data from
this set of actuators is relevant to the evaluation of support force errors.
<P>
Weight of the primary is 12,526 kg.
This includes the weight of the bonded on
load spreaders. Primary results are based on frequent
system corrections for focus, coma and astigmatism. The
primary benefits from this due to a relatively soft
astigmatic bending mode attributable to the large center
hole. This correction, while desirable, is not necessary."

set DESC(m2ms) "Secondary mirror system
<P>This mirror is
designed to be made from an existing 350 mm thick Zerodur blank. It is a bit thinner than would be needed to provide a
completely passive support (one that would never need to have the surface figure measured and corrected by adjusting
the actuator forces). The secondary has a back sheet thickness of 3.81 cm (1.5 inches), and a face sheet of similar
thickness except near the OD where the fabrication process requires that the internal surface of the face sheet be
parallel to the back surface resulting in an increase in the average face sheet thickness toward the OD. . It is approximately 63% lightweighted.
The LSST secondary is axially supported through load spreaders and pucks bonded to the back of the mirror . Fourteen three puck load spreaders are used along with 62 single puck actuator interfaces. A single axial
actuator loads the six inner three puck load spreaders. Two axial actuators load four of the three puck load spreaders
and three axial actuators load the remaining four. The three puck loadspreaders loaded by multiple actuators are
provided where static supports are used since these require the three puck frame to carry lateral loads. All load
spreaders are similar to the loadspreaders already in use on 6.5 and 8.4 m primary mirrors and consist of an Invar 36
frame bolted to puck assemblies that are bonded to the mirror with a 4 mm layer of silicone adhesive (GE RTV630).
The silicone adhesive layer is perforated with 2 mm diameter holes spaced 20 mm apart to reduce the axial stiffness of
the bond to approximately 120 kN/mm. Lateral support is provided at twenty of the pockets at two different depths.
The six innermost laterals support 46% of the weight 60.2 mm (2.37”) in front of the CG (center of gravity) plane. The
remaining 14 lateral supports carry 54% of the weight 82.6 mm (2.03”) behind the CG plane.
<P>
The axial support force actuators are counterweight mechanisms. 
They are equipped with load cells and an active
force capability for the compensation of thermal distortion due to
thermal expansion inhomogeneity and to provide axial correction
forces proportional to the lateral gravity component. Additionally,
forces will be adjusted to obtain the desired reactions at the position
constraints (hardpoints). Tapered roller bearings are used at all
rotating joints including the two universal joints in the connecting
rods."

set DESC(m3) "Tertiary mirror control
These mirrors will use the standard hex cell pattern so the existing load spreader
designs can be used without modification. The arrangement of actuators and load spreaders has been adjusted near the
ID of the primary to adapt to the large center hole and the arrangement on the tertiary is adjusted as required at the OD.
Since we assume the use of the same support actuators as are in service on the LBT 8.4 m Weight of the tertiary component is 6105 kg. This includes the weight of the bonded on
load spreaders. Primary results are based on frequent
system corrections for focus, coma and astigmatism. The
primary benefits from this due to a relatively soft
astigmatic bending mode attributable to the large center
hole. This correction, while desirable, is not necessary.
<P>
Tertiary performance is dominated by residual
gravitational distortion so the performance is not
significantly improved by correcting astigmatism and
coma. "


set DESC(MTMount) "Telescope mount and axes<BR>
Optically the LSST telescope has a unique 3 mirror system. The primary mirror circumscribes
the tertiary mirror such that both surfaces can be made into a single monolithic substrate 
The camera assembly is also circumscribed within the secondary mirror
assembly, forming a convenient package at the telescope top end.
Although the LSST optical design is unique, it can be supported by a conventional telescope
structural arrangement. A stiff mirror cell is used to support the primary and tertiary mirrors, and the top end assembly supports both the secondary mirror assembly and the camera assembly. Both the elevation axis and the azimuth axis are expected to utilize hydrostatic bearings, which are common on large telescopes.
<P>The LSSTs structural arrangement facilitates maintainability. The primary/tertiary mirror cell is connected to the rest of the elevation assembly at four flange locations. This facilitates convenient removal and reinstallation of the mirror cell for recoating and any significant maintenance needs. The top end assembly is also only attached at four flange locations to facilitate removal. The hydrostatic bearing surfaces are enclosed to reduce contamination and susceptibility to damage.
<P>The mount design also incorporates many essential auxiliary components.
Among these are the baffle system, balancing system, damping system, mirror cover, cable wraps and motor drives. The mirror cell is a 2 m deep sandwich with access to the complex systems required for mounting and thermal control of the primary and tertiary mirrors.
<P>Preliminary analysis determined that the lowest natural frequencies of the telescope assembly should be 10 Hz or greater to meet the slew and settling requirements. The telescope mount assembly was designed and analyzed with FEA, with the goal of meeting this 10 Hz requirement. The top end assembly supports the mass of the secondary mirror assembly and camera assembly through the use of 16 hollow rectangular spiders. 
<P>
These hollow spiders are structurally efficient, and the interior provides a convenient location to route the many cables required by the camera and the secondary mirror. These spiders have exterior dimensions of 300 mm x 50 mm and interior dimensions of 210 mm x 36 mm.
<P>The spiders are arranged to minimize the image degradation. All the spiders are arranged in axially aligned pairs. Consequently, the focal plane only sees eight spiders. The eight spider pairs are in a parallel/perpendicular arrangement, which only produces 2 diffraction spikes.
<P>
The instrument assembly includes the camera, rotator, hexapod, cable wrap, integrating
structure and electronics assemblies. The rotator is located between the hexapod and the camera to provide rotation about the optical axis during tracking. The hexapod resides between the rotator and integrating structure, and is used to provide alignment and positioning. 
The electronics assemblies mount to the interior of the integrating structure. The cable wrap resides on the top of the integrating structure.
<P>
The entire instrument assembly can be installed and removed as a single unit. This allows the entire instrument assembly to be put together and tested before integration into the telescope. It also provides for the removal for service and repairs. This installation feature requires that all cabling for the camera be routed from the camera’s top surface, through the hexapod and the cable wrap and to the integrating structures top surface.
<P>
The secondary mirror assembly is a 100 mm thick glass meniscus supported by 120 axial actuators and 6 tangent actuators and a structural cell for
support. The entire secondary mirror assembly is attached to the top end spider spindle by 6
positioning actuators. The mounting system includes an interface plate to allow removal of the secondary mirror assembly without disconnecting the position actuators. 
The secondary mirror assembly also incorporates a large baffle."

set DESC(MTMount.secondary) ""

set DESC(MTMount.instrumentAssembly) ""


set DESC(power) "Power supply and distribution systems"

set DESC(seeing_dimm) "Seeing canmera, differential image motion monitor<P>
The first DIMM was developed by M. Sarazin and F. Roddier (Sarazin, M., Roddier, F., The ESO differential image motion monitor, 1990, Astron. Astrophy. 227, 294). Refer to this paper for more complete information, especially on the theory.
<P>
Image quality through a telescope is directly related to the statistics of the perturbations of the incoming wavefront. The DIMM method consists of measuring wavefront slope differences over 2 small pupils some distance apart. Because it is a differential method, the technique is inherently insensitive to tracking errors and wind shake. In practice, starlight goes through 2 small circular subapertures, cut in a mask placed at the entrance of a small telescope. One of the subapertures contains a prism in order to create a second image of the star on the detector. The dual star images obtained exhibit a relative motion in the image plane that represents the local wavefront tilts, which can be expressed in terms of an absolute seeing scale 
<P>Sources of error:<BR>
Pixel scale: the FWHM varies as the 6/5 power of the standard deviation of the motion, which is measured in fractions of pixels. The pixel angular scale is determined typically with a 1% accuracy, leading to a 1.2% error in the FWHM.
<P>
Instrumental noise: the accuracy of the centroid algorithm, measured in laboratory on 2 fixed spots, corresponds to an equivalent random error of about 0.03 arcsec rms.
<P>
Statistical errors: it decreases with the square root of the sampling (number of images used). In our case, the variance of image motion is obtained from typically 250 short exposures per minute in each direction (i.e.. 500 in total), which leads to an accuracy of 3.8% in the image size.
<P>
Exposure time: the error caused by the finite exposure time is minimized by using very short exposures that can freeze the motion of the atmosphere in most conditions. We implemented the 5ms to 10ms (the minimum CCD frame transfer time is 1ms) interleaving technique and calculate (and log) the extrapolated seeing for a virtual integration time of 0ms (we know from ESO that 5ms is freezing the image motion 99% of the time in Chilean sites)."


set DESC(seeing_mass) "Seeing camera, Multi aperture turbulence measurement<BR>
Multi Aperture Scintillation Sensing (MASS). By correlating scintillation patterns in different annular pupils in a telescope the altitude and strength of turbulent motions in the atmosphere, where the scintillation originates, can be deduced. 
<P>
When stellar light passes through a turbulent layer and propagates down, its intensity fluctuates. Spatial scale of these variations depends on the distance to the layer. This dependence is used to separate the contributions from different layers by means of four concentric ring apertures that work as a matched spatial filter. Turbulence profile is derived from the statistical processing of the series of photon counts with 1 ms sampling.
<P>
Intensity of light falling into each of the ring apertures A, B, C, and D (see below) is measured by photon counters.  Scintillation index  in each aperture is computed as the variance (dispersion) of intensity normalized by the average intensity squared (or, equivalently, variance of the natural logarithm). In this way the scintillation index does not depend on the brightness of the star and reflects only the strength of atmospheric scintillation. Contribution of photon noise is carefully subtracted in the calculation.
<P>
Similarly, differential scintillation index for a pair of apertures (e.g. A and B) is defined as the variance of the ratio of intensities in A and B normalized by the square of the average intensity ratio A/B (or, equivalently, the variance of the natural logarithm of the intensity ratio).
<P>
Both normal and differential scintillation indices produced by a given turbulent layer are computed as product of the turbulence intensity in this layer (integral of Cn2 measured in m^1/3) by some weighting function which depends on the distance to the layer as well as on the shape and size of the apertures."

set DESC(skycam) "Sky cameras<BR>
The primary goal is to provide qualitative assessment of cloud patterns (detection, layout and motion).  Thick clouds on large spatial scales can be detected by almost any camera, but as they can also be readily seen by eye, this is not a very interesting case  ...except for remote users.  The primary goal of this project is to detect diffuse Cirrus which is more common and very difficult or impossible to see by eye in the moonless sky.    Side benefits (which I will discuss later) are aircraft detection (for laser safety), sky brightness monitoring (light pollution versus cloud cover and time of day), monitoring of OH emissions and auroras, and monitoring of clouds under moonlight or even daylight for remote observers.  Finally, the impact of high quality images of the skies over Tololo on the public, particularly the astronomical community, should not be overlooked, particularly if they are superior in quality to those offered in the North (e.g.  Mauna Kea, and Kitt Peak)
<P>
Since the dark sky is almost invariant from night to night it is possible to subtract a reference frame formed from the median of previous (dark) nights so that a nominally flat image can be displayed at sufficient contrast to allow extinction and scattering to be perceived down to the limit imposed by the photon shot noise.   This has been demonstrated crudely by derotating clear frames taken on the same night.  Much better results will be obtained when the camera remains in a fixed position from night to night so that no derotation is needed.
<P>
Pixels can be binned together to improve the noise statistics, but only until the typical spatial scale of the clouds is reached.   Unfortunately a comparison of the angular scale of daytime Cirrus with that of the the moon or an outstretched thumb will quickly confirm that  the proposed resolution of 0.18 degrees (960 pixels across the sky) is not excessive, and that only slight binning can be used if at all.  This fine angular scale and the high winds found at altitude combine to require exposure times shorter than ~3 seconds to maintain acceptable contrast for Cirrus."




