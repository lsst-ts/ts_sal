set GLOSSARY(SAS) "Science Array System"
set GLOSSARY(SDS) "Science Data Acquisition System"
set GLOSSARY(WFS) "Wave-front Sensing System"
set GLOSSARY(WDS) "Wavefront data acquisition system"
set GLOSSARY(GS)  "Guider system"
set GLOSSARY(GAS) "Guider data acquisition system"
set GLOSSARY(FPA) "Focal Plane Array Actuation"
set GLOSSARY(TC)  "Thermal Control"
set GLOSSARY(RAS) "Raft Alignment Subsystem" 
set GLOSSARY(SCU) "Shutter Controller Unit"
set GLOSSARY(FCS) "Filter Controller Subsystem"
set GLOSSARY(VCS) "Vacuum Control Subsystem" 
set GLOSSARY(L2U) "L2 Controller Unit"
set GLOSSARY(BEE) "Back-End Electronic"
set GLOSSARY(FEE) "Front End Electronics"
set GLOSSARY(CCS) "Camera Control System"
set GLOSSARY(CALSYS) "Camera Calibration System"
set GLOSSARY(LASERCAL) "Camera metrology calibration System"
set GLOSSARY(TCM) "Camera Timing control"
set GLOSSARY(WTCM) "Camera wavefront sensors Timing control"
set GLOSSARY(PWR) "Camera Power supply System"
set GLOSSARY(QA) "Camera Quality Assurance measurements"



set DESC(camera.WDS.wfsRaft) "Wavefront System Manager
<P>This subsystem maintains metadata concerning the state of the<BR>wavefront
sensors, and the results of the processing of<BR>images. Items such
as chip voltages, health, per chip temps<BR>bad pixel/line/column
counts, image pair counts, zernike results<BR>and so on. 
The wavefront sensing system will consist of wavefront curvature monitors and/or Shack Hartmann sensors in or around
the science array. Data from these sensors will be used to monitor and improve the quality of the science data by using WF
measurements for feedback compensation. The feedback control of telescope alignment will be handled by the
Telescope Control System.
<P>
Four special purpose rafts, mounted at the corners of the science array, will contain wavefront sensors and guide sensors.
Wavefront measurements are accomplished using curvature sensing, where the spatial intensity distribution of stars is
measured at equal distances on either side of focus. Each curvature sensor will be composed of two CCD detectors, with
one positioned slightly above the focal plane, and the other positioned slightly below the focal plane. The CCD technology
for the curvature sensors will be identical to that used for the science detectors in the focal plane except that the curvature
sensor detectors will be half size so they can be mounted as an in/out defocus pair. Detailed analyses have verified that this
configuration can recover the wavefront to the required accuracy.
"

set DESC(camera.WDS) "The Wave-front Data Acquisition System includes the readout controller for the wavefront sensors and the logic to process, analyze, and reformat the data for the Telescope Control System."

set DESC(camera.GAS) "Guide Sensor Data Acquisition System
<P>This subsystem maintains metadata concerning the state of the<BR>guide
regions, and the results of the processing of<BR>the subimages. Items
such as bax pixel counts, H/V profiles<BR>profile fit results etc. The Guide Sensor System(GSS) produces data that is collected by the Guider Data Acquisition System (GAS) and sent to
the Focal Plane Actuator (FPU) and also, possibly, the Telescope Control System (TCS). "

set DESC(camera.GS) "The Guider system (GS) includes the readout controller for Guide Sensor data and the logic to process, analyze, and reformat the data for the Telescope control system."

set DESC(camera.FPU) "The Focal Plane Array (FPU) Actuation manager software controls translational and rotational actuation of the detector array in the focal plane."

set DESC(camera.TC.control) "The Thermal Control (TCS) manager software controls temperature in multiple thermal zones in the focal plane, cryostat, and camera body.  Feedback control is based on trim heaters for actuation and temperature sensors for readback.<P>
<P>Temperature monitoring  for sensors located in the camera
subsystem.<BR>Raw sensor readings, calibrated temperatures,
timeseries statistics, sensor health.
<P>
The basic requirement of the Camera Thermal Comtrol System is to allow the solidstate
detectors that form the Focal Plane Array (FPA) to operate at ~ 170K to reduce the contribution of thermal noise to the electronic signals while in parallel optimizing
quantum efficiency (QE). The thermal gradient across the sensors must also be adequately
reduced (±0.30K) to maintain uniform quantum efficiency in each pixel. For efficient camera
operation, thermal stability of the FPA is necessary to maintain optical sensor performance as well as to eliminate the growth of mechanical distortions to the FPA, once it is aligned. 
<P>
The additional functions of the thermal control system are to provide a particulate free environment for the sensor surfaces, heat extraction from both the front end and back end electronics systems, and antifog protection for the three optical elements.   The camera is composed of a cryostat containing the FPA and its readout electronics and an outer camera body which houses the cryostat, shutter, L2 optic, and the five filters and filter exchange mechanism. The cryostat is closed by the L3 optic and the outer camera body by the L1 optic. The cryostat is operated at ~10e-6 Torr vacuum while the region between the cryostat and outer body will contain an inert gas (eg: dry nitrogen will be assumed) regulated to be slightly above atmospheric pressure. The temperature of the N2 gas will be controlled to maintain a stable thermal envelope. The other important role of the inert gas is to prevent degradation of the filter coatings.
<P>
Components: 
Off Camera: flex line umbilicals; chillers, auxiliary pumps, reservoirs, purge system, plumbing systems,
sensors and flow meters, local operator's terminal, vacuum system for insulating vacuum, racks, consoles.<P>
Requirements:
<P>
Control temperature to derived requirement below 3oC<BR>
Log temperatures, heater current for all 189 sensor thermal zones<BR>
Monitor temperature stability over time<BR>
Graph temperatures and heater current vs time for trending analysis<BR>
Graphically map temperatures of all Grid bays<BR>
Send caution signal if dTemp/dTime approaches limits<BR>
Send warning signal if dTemp/dTime exceeds limits<BR>
Override of over/undertemp caution and warning alarms<BR>
Change/store/download temp setpoints and limits for all control zones<BR>
Save configurations of heater power for different operating scenarios<BR>
Log temperatures, heater current for all thermal plates<BR>
Graph temperatures and heater current vs time for trending analysis<BR>
Graphically map temperatures and heater current of all Grid bays<BR>
Override of over/undertemp caution and warning alarms<BR>
Change/store/download heater current setpoints for all control zones<BR>
Provide manual realtime adjustment of individual heater currents<BR>
Save configurations of heater current for different operating scenarios <BR>
Log temperatures, heater current for all Cold Plate, BEE boards, cryogen line inlets/outlets<BR>
Graph temperatures and heater current vs time for trending analysis<BR>
Graphically map temperatures and heater current of all BEE module locations<BR>
Override of over/undertemp caution and warning alarms<BR>
Temperatures from Cold Plate thermal zone can be combined with all other thermal data<BR>
Change/store/download heater current setpoints for all control zones<BR>
Provide manual realtime adjustment of individual heater currents<BR>
Save configurations of heater current for different operating scenarios<BR>
"

set DESC(camera.RAS) "The Raft Alignment Subsystem (RAS) manager software controls read-out of the in-situ raft alignment monitoring system that is part of the WBS for the Focal Plane Array and Cryostat."

set DESC(camera.SCS) "The Shutter Controller Unit (SCU) manager software controls and synchronizes shutter operation.
<P>This subsystem maintains shutter positioning and motion information<BR>as
well as lower level shutter mechanism parameters.Deliverables:
     Shutter with mechanisms, actuators, and power supply and controller
<LI>     Shutter life test unit/testbed
<LI>     Shutter storage/transport container
<LI>     Test gantry and sensor array<P>
<P>
A rectangular aperture that moves across the array controls the exposure time for all pixels. Equal exposure time requires the opening edge and the closing edge to have the same motion profile in time. This is achieved by using one long sheet with a central rectangular aperture of constant width. For compact storage, the sheet attaches to and wraps around two rollers to form a scroll. Tthere are two closed positions so the sheet advances in the same direction from closed to open to closed. The sheet reverses direction for the next cycle.  This would be of great benefit if the minimum exposure time were much shorter than currently required. 
<P>
Controlling the exposure time to millisecond precision is equivalent to controlling position of the aperture edges to several tenths of millimeters. Standard feedforward and feedback control techniques  maintain acceptable following error (i.e., the controller component of error) for this well defined motion profile. Placing sensors on the rollers is easy and reliable and the average of the two accounts for the effective roller radius changing as the sheet rolls up on itself. This effect is small for a thin metal sheet. In addition, a metal sheet is opaque, does not outgas, can be processed for high fatigue strength and low wear, and is stable and rigid in plane."


set DESC(camera.FCS) "The Filter Controller Subsystem (FCS) manager software controls and synchronizes operation of the filter changer and carousel.
<P>This subsystem maintains filter positioning and motion information<BR>
as well as lower level filter mechanism parameters.
<P>
Components : Filter Carousel with mechanisms, actuators, and power supply and controller
<P>
The filter carousel stores a set of color filters and the changer inserts any one as needed for the particular observational task. Five color filters fit within the camera housing on a carousel that rotates about the camera axis. The carousel presents the appropriate filter to the lower station where the exchange can be made through the space between the shutter rollers. . A wheeled cart (transporter) conveys the filter along the tracks between the carousel and use position.
<P>
The filter substrates differ from one another in their central thickness, ranging from 13.5 to 22 mm. The convex spherical radius is the same for all filters and is placed the same inside the camera"



set DESC(camera.VCS) "The Vacuum Control Subsystem (VCS) manager software controls and synchronizes operation of the vacuum and purge subsystem in the camera cryostat and utility trunk (either on the mountain or in the lab).  Feedback control is based on vacuum pumps and pressure gauges.
<P>This subsystem maintains application level data for the dewar<BR>vacuum
systems. Target and actual statuses<BR>health , limits, etc.
<P>
The inner cryostat housing contains the focal plane array with its frontend and backend electronics, elements of the thermal management system, and all lectrical, optical, fluid and mechanical feedthroughs. The lens, L3, forms the window on the ront end of the cryostat housing. A rear flange to the inner housing provides primary access to components inside.
<P>
<LI>On Camera vacuum manifolds, valves, pump ports, transfer lines, and plena. Getter and ion holding pumps on
Cryostat, including regeneration heaters and valving. RGA, ion gauge, TQCM, and controllers.
<LI>On Camera purge manifolds, valves, pump ports, and pressure vessel. Metering, temp sensors, reheaters, power
supplies and controllers. Insulated purge flex lines to camera.
<LI>On the ground: Purge reheat controller, chiller, meters, filters, sensors, flow control valves, racks and consoles.
<P>The focal plane array is contained in vacuum to minimize its environmental heat load. While vacuum eliminates natural convection, other modes of heat transfer are still present. Multi layer insulation applied to the cryostat housing all but eliminates radiation heat transfer except where it cannot be such as the vacuum window (L3). Supporting the focal plane array on flexures naturally minimizes conduction through structures."

set DESC(camera.L2U) "The L2 Controller Unit (L2U) manager software controls piston-mode actuation of camera lens L2."



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

set DESC(camera.CALSYS) "The xray calibration subsystem consists of an Fe55 source on wiperblade arm(s) that sweeps across the focal plane for
xray calibration of quantum efficiency, electrical gains and offsets, readout noise, and physical/cosmetic features of the
CCD array."

set DESC(camera.TCM) "Directly beneath each packaged CCD module is a Front End Electronics Module (FEM) containing the following functionality.
<P><UL><LI>Analog signal processing ASIC
<LI>CCD clock drivers, ASIC or hybrid
<LI>Bias voltage dsitribution
</UL>This architecture minimizes the physical distance from CCD output amplifiers to the analog signal processing circuits, thus minimizing power dissipation and risk of noise pickup. The CCD clock drivers are assumed to be simple level translators, with no pattern generation at this point. Beyond generating clock signals, there is no digital activity at this level. All analog signals  are buffered and fully differential for purposes of noise immunity. Similarly, all timing signals comply with the Low Voltage Differential Signaling (LVDS) standard. Both the clock drivers and the bias generators will be programmable by means of a slow serial link."

set DESC(camera.testStand) "The main functions of this test stand are test and evaluation of:<P>
<UL><LI>Signal Processor ASIC prototypes
<LI>Clock Translator circuits (ASIC and Hybrid)
<LI>Sensor prototypes
<LI>Commercial off the shelf (COTs) components
<LI>All performance parameters vs temperature
<LI>Outgassing tests and development of remediation
<LI>Readout strategies and critical performance parameters.
<LI>Prototype CCDs
</UL><P>
The Test Stand architecture closely mimics the architecture of the final readout. Thus, design and development of the Test Stand serves the function of prototyping all aspects of the final Camera readout
"

set DESC(camera.Electrical) "
<P>Electrical monitoring  for devices located in the camera
subsystem.<BR>Raw data, calibrated voltages, calibrated current,
device power status. "

set DESC(camera.LASERCAL) "
<P>Position control  for sensors located in the camera
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set DESC(camera.BEE) "
<P>This subsystem maintains data from each RNA unit. This will
include<BR>performance characteristics, health checks, statuses etc. 
Camera Raft Modules consist of astronomical quality optical imaging sensors and the mechanical structure that holds them
at their precise locations. The mechanical mounting system incorporates interfaces to the structural, thermal, vacuum, and
electronics subsystems of the enclosing cryostat.
<P>
Arrays of 3×3 sensors are mounted to raft structures that in turn mount to the integrating
structure. Raft structure plates are double side lapped all at once to be flat, parallel and the same size to less than 1 µm. Thus, rafts assembled with sensors are flat, parallel and the same height to 6.5 µm peak to valley. The raft structure and the sensor substrate have a well matched coefficient of thermal expansion and good thermal conduction to maintain this flatness performance during operation, since the assembly is subject to large temperature changes (ambient to operating temperature)."

set DESC(camera.SDS.status) "This subsystem comprises the science image sensors (201 CCDs), the front end electronics, the back end electronics, and a collection of electronics boards on a common bus along with the power supplies, cabling, fiber outputs, etc. needed to operate the CCDs in the science array. The 201 CCDs fully populate 21 focal plane rafts with 9 CCDs each and partially populate 4 rafts with 3 CCDs each. A dedicated state machine based controller issues timing and control signals to Camera Electronics. Specifically, it controls all signals required by both Front End Cards and Back End Cards. These include all CCD clocks, Signal Processing ASIC timing/control signals, A to D conversion control signals on the Back End, and so forth. Note that sensor data is normally not returned to the SAC, but is routed out of the camera on multiple Data Fibers. The control module for this subsystem would run on an embedded processor providing an interface between the CCM and the dedicated state machine based controller."


set DESC(camera.BEE.clocks) "This subsystem comprises 25 computers (one per raft, not including spares), each hosting a fiber interface card to receive the image data generated by a raft. These computers would buffer the image data in memory and transfer the data into the Data Management stream. Iitial data quality assessment), may also be carried out on these hosts.
The state of the clocks are monitored in this subsystem."

set DESC(camera.BEE.biases) "This subsystem comprises 25 computers (one per raft, not including spares), each hosting a fiber interface card to receive the image data generated by a raft. These computers would buffer the image data in memory and transfer the data into the Data Management stream. Iitial data quality assessment), may also be carried out on these hosts.
The state of the bias voltages are monitored in this subsystem."

set DESC(camera.BEE.thermal) "This subsystem comprises 25 computers (one per raft, not including spares), each hosting a fiber interface card to receive the image data generated by a raft. These computers would buffer the image data in memory and transfer the data into the Data Management stream. Iitial data quality assessment), may also be carried out on these hosts
The state of the thermal environment is monitored in this subsystem."




set DESC(camera.TC.zone1) "
This subsystem comprises the devices and controllers necessary for monitoring and control of
the temperature of the focal plane sensors and front end electronics. This zone must be
maintained at approximately -100C to high accuracy (to be specified). Its function is to remove heat from the focal plane due to radiation through L1 as well as heat dissipated in the CCDs and Front End Cards"

set DESC(camera.TC.zone2) "This subsystem comprises the devices and controllers necessary for thermal monitoring and control of the Back End Electronics attached to the bottom plate of the Inner Cryostat. The temperature will be in the neighborhood of -20C but does not require high accuracy or stability. Its function is to remove heat generated by the Back End Electronics."

set DESC(camera.TC.zone3) "This unit monitors and controls temperature in the Timing/Control Crate. Specifically, it removes heat generated by electronics residing in the Crate and monitors crate temperature."



set DESC(camera.TC.zone4) "This unit monitors and controls temperature in the Utility trunk. Specifically, it removes heat generated by electronics residing in the Utility trunk and monitors trunk temperature."


set DESC(camera.TC.zone6) "This unit monitors and controls temperature in the External transport. Specifically, it removes heat generated by electronics residing in the transport and monitors  temperature."
 

set DESC(camera.TC.zone5) "This unit monitors and controls temperature in the cooling unit. Specifically, it removes heat generated by electronics residing in the cooling units temperature."


set DESC(camera.PWR) "This unit monitors the power supply demands and statuses for the
various parts of the camera subsystem."


set DESC(camera.QA.measured) "This subsystem monitors the quality assurance feedback
from the downstream processing. It is used to verify low-level operation of
the on-board timing and A/D conversion in the camera."

set DESC(camera.SDS.amplifiers) "This subsystem monitors the performance and physical
operation of all the CCD amplifiers in the focal plane."

set DESC(camera.UTIL) "This subsystem monitors the health and operational
parameters of the hardware in the Utility trunk section of the camera."

set DESC(camera.WTCM) "This subsystem monitors the timing and control
modules for the Wavefront rafts."


