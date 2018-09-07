
set DESC(system) "Meta-level telemetry concerning the computer system infrastructure, IPMI data etc."

set SDESC(operations) "Observatory control system Meta-level
telemetry"

set SDESC(system.Computer_status) "
<P>This topic consists of computer system status information.
<BR>Variables such cpu, memory, disk usage, cpu temp, fan
speeds<BR>uptime, logins, process count, etc. Every computer will
generate<BR>such a topic, permitting overall system visualization. "

set SDESC(system.Software_revision_history) "
<P>This topic is used to record software revisions so that the
<BR>current installed complement of any machine will be readily
available. "

set SDESC(system.Hardware_revision_history) "
<P>This topic is used to record hardware updates, repairs, <BR>swap-outs
etc. "

set SDESC(system.Command_history) "
<P>This topic is used to record the complete command history<BR>of
all subsystems in a coherent manner. "

set SDESC(camera.Temps) "
<P>Temperature sensing information for sensors located in the camera
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time-series statistics, sensor health. "

set SDESC(camera.Electrical) "
<P>Electrical parameters for devices located in the camera
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set SDESC(camera.Metrology) "
<P>Position sensing information for sensors located in the camera
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set SDESC(camera.RNA) "
<P>This topic records data from each RNA unit. This will
include<BR>performance characteristics, health checks, statuses etc. "

set SDESC(camera.Science_sensor_metadata) "
<P>This topic records the science ccd metadata. Items such as<BR>chip
voltages, biasaes, health, per-chip temps etc. "

set SDESC(camera.Wavefront_sensors) "
<P>This topic records metadata concerning the state of the<BR>wavefront
sensors, and the results of the processing of<BR>images. Items such
as chip voltages, health, per-chip temps<BR>bad pixel/line/column
counts, image pair counts, zernike results<BR>and so on. "

set SDESC(camera.Guide_sensors) "
<P>This topic records metadata concerning the state of the<BR>guide
regions, and the results of the processing of<BR>the subimages. Items
such as bax pixel counts, H/V profiles<BR>profile fit results etc. "

set SDESC(camera.Dewar_CoolerHeater) "
<P>This topic records application level data for the dewar<BR>heating
and cooling systems. Target and actual statuses<BR>health , limits,
etc. "

set SDESC(camera.Vacuum) "
<P>This topic records application level data for the dewar<BR>vacuum
systems. Target and actual statuses<BR>health , limits, etc. "

set SDESC(camera.Filters) "
<P>This topic records filter positioning and motion information<BR>as
well as lower level filter mechanism parameters. "

set SDESC(camera.Shutter) "
<P>This topic records shutter positioning and motion information<BR>as
well as lower level shutter mechanism parameters. "

set DESC(dm) "Data Management Subsystem"


set SDESC(m1.Temps) "
<P>Temperature sensing information for sensors located in the m1
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time-series statistics, sensor health. "

set SDESC(m1.Electrical) "
<P>Electrical parameters for devices located in the m1 subsystem.<BR>Raw
data, calibrated voltages, calibrated current, device power status. "

set SDESC(m1.Metrology) "
<P>Position sensing information for sensors located in the m1
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set SDESC(m1.Application) "
<P>Application specific information derived from sensors in the m1
subsystem. "

set SDESC(m1.Support) "
<P>This topic records integrated support system condition for<BR>the
m1 support system. "

set SDESC(m1.Actuators) "
<P>This topic records information on a per-actuator basis<BR>persuant
to the low level behaviour of the components of<BR>the m1 support
system. "

set SDESC(m1.Surface) "
<P>This topic records data pertaining to the requested and<BR>measured
surface properties (figure, stresses, temps etc). "

set SDESC(m3.Temps) "
<P>Temperature sensing information for sensors located in the m3
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time-series statistics, sensor health. "

set SDESC(m3.Electrical) "
<P>Electrical parameters for devices located in the m3 subsystem.<BR>Raw
data, calibrated voltages, calibrated current, device power status. "

set SDESC(m3.Metrology) "
<P>Position sensing information for sensors located in the m3
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set SDESC(m3.Application) "
<P>Application specific information derived from sensors in the m3
subsystem. "

set SDESC(m3.Support) "
<P>This topic records integrated support system condition for<BR>the
m3 support system. "

set SDESC(m3.Actuators) "
<P>This topic records information on a per-actuator basis<BR>persuant
to the low level behaviour of the components of<BR>the m3 support
system. "

set SDESC(m3.Surface) "
<P>This topic records data pertaining to the requested and<BR>measured
m3 surface properties (figure, stresses, temps etc). "

set SDESC(m2ms.Temps) "
<P>Temperature sensing information for sensors located in the m2ms
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time-series statistics, sensor health. "

set SDESC(m2ms.Electrical) "
<P>Electrical parameters for devices located in the m2ms subsystem.<BR>Raw
data, calibrated voltages, calibrated current, device power status. "

set SDESC(m2ms.Metrology) "
<P>Position sensing information for sensors located in the m2ms
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set SDESC(m2ms.Application) "
<P>Application specific information derived from sensors in the m2ms
subsystem. "

set SDESC(m2ms.Hexapod) "
<P>This topic records application level data concerning the<BR>requested
and actual state of the haxapod support system. "

set SDESC(m2ms.Actuators) "
<P>This topic records information on a per-actuator basis<BR>persuant
to the low level behaviour of the components of<BR>the m2ms support
system. "

set SDESC(m2ms.Surface) "
<P>This topic records data pertaining to the requested and<BR>measured
m2ms surface properties (figure, stresses, temps etc). "

set SDESC(MTMount.Temps) "
<P>Temperature sensing information for sensors located in the mount
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time-series statistics, sensor health. "

set SDESC(MTMount.Electrical) "
<P>Electrical parameters for devices located in the mount
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set SDESC(MTMount.Metrology) "
<P>Position sensing information for sensors located in the mount
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set SDESC(MTMount.Application) "
<P>Application specific information derived from sensors in the mount
subsystem. "

set SDESC(MTMount.Alt) "
<P>This topic records application level information about
the<BR>Altitude axis requested and actual position and status. "

set SDESC(MTMount.Az) "
<P>This topic records application level information about the<BR>Azimuth
axis requested and actual position and status. "

set SDESC(MTMount.Rotator) "
<P>This topic records application level information about
the<BR>instrument rotator requested and actual position and status." 


set DESC(network) "Meta-level networking infrastructure data"

set SDESC(power.Temps) "
<P>Temperature sensing information for sensors located in the power
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time-series statistics, sensor health. "

set SDESC(power.Electrical) "
<P>Electrical parameters for devices located in the power
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set SDESC(power.UPSs) "
<P>This topic record parameters for devices located in the UPS
subsystems.<BR>Raw data, calibrated voltages, calibrated current,
device power status,<BR>demand, usage, etc. "

set SDESC(calibration.Temps) "
<P>Temperature sensing information for sensors located in the
calibration subsystem.<BR>Raw sensor readings, calibrated
temperatures, time-series statistics, sensor health. "

set SDESC(calibration.Electrical) "
<P>Electrical parameters for devices located in the calibration
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set SDESC(calibration.Metrology) "
<P>Position sensing information for sensors located in the
calibration subsystem.<BR>Raw sensor readings, calibrated positions,
limit switches, status bits. "

set SDESC(calibration.Application) "
<P>Application specific information derived from sensors in the
calibration subsystem. "

set SDESC(domeTHCS) "
<P>Temperature sensing information for sensors located in the
dome subsystem.<BR>Raw sensor readings, calibrated temperatures,
time-series statistics, sensor health. "

set SDESC(domeMONCS) "
<P>Electrical parameters for devices located in the dome
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set SDESC(dome.Metrology) "
<P>Position sensing information for sensors located in the dome
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set SDESC(dome.Application) "
<P>Application specific information derived from sensors in the
dome subsystem. "

set SDESC(domeADB) "
<P>This topic records high level information pertaining to
the<BR>dome positioning demand and performance, wind
loading<BR>etc. "

set SDESC(domeLWS) "
<P>This topic records high level information pertaining to the<BR>dome
wind screen positioning demand and performance, wind loading<BR>etc. "

set SDESC(domeLouvers) "
<P>This topic records high level information pertaining to the<BR>dome
vents positioning demand and performance, wind loading<BR>etc. "

set SDESC(domeAPS) "
<P>This topic records high level information pertaining to the<BR>dome
shutter positioning demand and performance, wind loading<BR>etc. "

set SDESC(scheduler.Application) "
<P>Application specific information produced by the scheduler
subsystem. "

set SDESC(operations.Application) "
<P>Application specific information produced by the operations
subsystem. "

set SDESC(auxscope.Temps) "
<P>Temperature sensing information for sensors located in the
Auxillary Telescope subsystem.<BR>Raw sensor readings, calibrated
temperatures, time-series statistics, sensor health. "

set SDESC(auxscope.Electrical) "
<P>Electrical parameters for devices located in the Auxillary
Telescope subsystem.<BR>Raw data, calibrated voltages, calibrated
current, device power status. "

set SDESC(auxscope.Metrology) "
<P>Position sensing information for sensors located in the Auxillary
Telescope subsystem.<BR>Raw sensor readings, calibrated positions,
limit switches, status bits. "

set SDESC(auxscope.Application) "
<P>Application specific information derived from sensors in the
Auxillary Telescope subsystem. "

set SDESC(auxscope.TCS) "
<P>This topic records high level data pertaining to the state<BR>of
the Auxillary Telescope Control System (May be split into subtopics)."

set SDESC(auxscope.Spectrometer) "
<P>This topic records high level data pertaining to the state<BR>of
the Auxillary Telescope Spectrograph (May be split into subtopics). "

set SDESC(auxscope.Camera) "
<P>This topic records high level data pertaining to the state<BR>of
the Auxillary Telescope camera (May be split into subtopics). "

set SDESC(lasercal.Temps) "
<P>Temperature sensing information for sensors located in the laser
calibration subsystem.<BR>Raw sensor readings, calibrated
temperatures, time-series statistics, sensor health. "

set SDESC(lasercal.Electrical) "
<P>Electrical parameters for devices located in the laser calibration
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set SDESC(lasercal.Application) "
<P>Application specific information derived from sensors in the
laser<BR>calibration subsystem. "

set DESC(scheduler) "OCS observation sheduling subsystem"


set SDESC(seeing_dimm.Temps) "
<P>Temperature sensing information for sensors located in the DIMM
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time-series statistics, sensor health. "

set SDESC(seeing_dimm.Electrical) "
<P>Electrical parameters for devices located in the DIMM
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set SDESC(seeing_dimm.Metrology) "
<P>Position sensing information for sensors located in the DIMM
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set SDESC(seeing_dimm.Application) "
<P>Application specific information derived from sensors in the DIMM
subsystem.<BR>Raw and processed subimages, derived atmospheric
parameters etc. "

set SDESC(seeing_mass.Temps) "
<P>Temperature sensing information for sensors located in the MASS
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time-series statistics, sensor health. "

set SDESC(seeing_mass.Electrical) "
<P>Electrical parameters for devices located in the MASS
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set SDESC(seeing_mass.Metrology) "
<P>Position sensing information for sensors located in the MASS
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set SDESC(seeing_mass.Application) "
<P>Application specific information derived from sensors in the MASS
subsystem.<BR>Raw and processed images, derived atmospheric
parameters etc. "

set SDESC(skycam.Temps) "
<P>Temperature sensing information for sensors located in the
All-sky-cameras subsystem.<BR>Raw sensor readings, calibrated
temperatures, time-series statistics, sensor health. "

set SDESC(skycam.Electrical) "
<P>Electrical parameters for devices located in the All-sky-cameras
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set SDESC(skycam.Metrology) "
<P>Position sensing information for sensors located in the
All-sky-cameras subsystem.<BR>Raw sensor readings, calibrated
positions, limit switches, status bits. "

set SDESC(skycam.Application) "
<P>Application specific information derived from sensors in the
All-sky-cameras subsystem.<BR>Raw and processed images, WCS
derivations, transparency, cloud cover etc. "

set SDESC(environment.Temps) "
<P>Temperature sensing information for sensors located in the
environment subsystem.<BR>Raw sensor readings, calibrated
temperatures, time-series statistics, sensor health. "

set SDESC(environment.Electrical) "
<P>Electrical parameters for devices located in the environment
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set SDESC(environment.Weather) "
<P>This topic records weather data, both current predictions and
actual<BR>measurements. "

set SDESC(environment.Dust_monitor) "
<P>This topic records information from the Dust Monitor
subsystem.<BR>Both low level mechanical status , and calculated
result data<BR>are included. "

set SDESC(environment.Lightning_detector) "
<P>This topic records data from the Lightning detection subsystem<BR>and
current predictive data. "

set SDESC(environment.Seismometer) "
<P>This topic records data from the Siesmometer subsystem.</P>"

set SDESC(environment.Video_cameras) "
<P>This topic records system status for the video monitoring<BR>systems."


set SDESC(network.Application) "
<P>This topic records performance and health data from local<BR>and
remote networking components (switches, gateways, VPN, bulk data
transport etc). "


