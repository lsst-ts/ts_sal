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






set DESC(m1m3.TC) "
<P>Temperature monitoring  for sensors located in the m1
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time series statistics, sensor health.
  

 "

set DESC(m1m3.Electrical) "
<P>Electrical monitoring  for devices located in the m1 subsystem.<BR>Raw
data, calibrated voltages, calibrated current, device power status. "

set DESC(m1m3.Metrology) "
<P>Position control  for sensors located in the m1
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "


set DESC(m1m3.Support) "
<P>This subsystem maintains integrated support system condition for<BR>the
m1 support system. "

set DESC(m1m3.Actuators) "
<P>This subsystem maintains information on a per actuator basis<BR>persuant
to the low level behaviour of the components of<BR>the m1 support
system. "

set DESC(m1m3.Surface) "
<P>This subsystem maintains data pertaining to the requested and<BR>measured
surface properties (figure, stresses, temps etc). "


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


set DESC(m2ms.Hexapod) "
<P>This subsystem maintains application level data concerning the<BR>requested
and actual state of the haxapod support system. "

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

set DESC(domeAPS) "
<P>This subsystem maintains high level information pertaining to the<BR>dome
shutter positioning demand and performance, wind loading<BR>etc. "

set DESC(domeLouvers) "
<P>This subsystem maintains high level information pertaining to the<BR>dome
vents positioning demand and performance, wind loading<BR>etc. "




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

set DESC(camera.Dewar_Cooler) ""
set DESC(seeing_dimm.TC) ""
set DESC(seeing_dimm.Electrical) ""
set DESC(seeing_dimm.Metrology) ""
set DESC(seeing_mass.TC) ""
set DESC(seeing_mass.Electrical) ""
set DESC(seeing_mass.Metrology) ""


set DOCO(ocs) Document-869
set DOCO(standards-sw) "ESA 1991, Software Engineering Standards, ESA PSS-05-0, Issue 2, European Space Agency"
set DOCO(m1) Document-3167
set DOCO(m2ms) Document-3167
set DOCO(m3) Document-3167
set DOCO(dome) Document-341,Document-342,Document-2389

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

set DESC(m1m3) "Primary mirror system<P>
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

set SDESC(camera.TC) "
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

set DESC(camera.CCS) "The camera control system is responsible for overall 
integration of camera subsystem operations, safety interlocks, and 
inter-subsystem interactions"

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

set SDESC(m1m3.TC) "
<P>Temperature sensing information for sensors located in the m1
subsystem.<BR>Raw sensor readings, calibrated temperatures,
time-series statistics, sensor health. "

set SDESC(m1m3.Electrical) "
<P>Electrical parameters for devices located in the m1 subsystem.<BR>Raw
data, calibrated voltages, calibrated current, device power status. "

set SDESC(m1m3.Metrology) "
<P>Position sensing information for sensors located in the m1
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set SDESC(m1m3.Application) "
<P>Application specific information derived from sensors in the m1
subsystem. "

set SDESC(m1m3.Support) "
<P>This topic records integrated support system condition for<BR>the
m1 support system. "

set SDESC(m1m3.Actuators) "
<P>This topic records information on a per-actuator basis<BR>persuant
to the low level behaviour of the components of<BR>the m1 support
system. "

set SDESC(m1m3.Surface) "
<P>This topic records data pertaining to the requested and<BR>measured
surface properties (figure, stresses, temps etc). "

set SDESC(m3.TC) "
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

set SDESC(m2ms.TC) "
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

set SDESC(MTMount.TC) "
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

set SDESC(power.TC) "
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

set SDESC(calibration.TC) "
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


set SDESC(domeADB) "
<P>This topic records high level information pertaining to
the<BR>dome positioning demand and performance, wind
loading<BR>etc. "

set SDESC(domeAPS) "
<P>This topic records high level information pertaining to the<BR>dome
shutter positioning demand and performance, wind loading<BR>etc. "

set SDESC(domeLouvers) "
<P>This topic records high level information pertaining to the<BR>dome
vents positioning demand and performance, wind loading<BR>etc. "

set SDESC(scheduler.Application) "
<P>Application specific information produced by the scheduler
subsystem. "

set SDESC(operations.Application) "
<P>Application specific information produced by the operations
subsystem. "

set SDESC(auxscope.TC) "
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

set SDESC(lasercal.TC) "
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

set SDESC(seeing_dimm.TC) "
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

set SDESC(seeing_mass.TC) "
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

set SDESC(skycam.TC) "
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

set SDESC(environment.TC) "
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


set SDESC(camera.Dewar_Cooler) ""
set SDESC(seeing_dimm.TC) ""
set SDESC(seeing_dimm.Electrical) ""
set SDESC(seeing_dimm.Metrology) ""
set SDESC(seeing_dimm.Application) "" 
set SDESC(seeing_mass.TC) ""
set SDESC(seeing_mass.Electrical) ""
set SDESC(seeing_mass.Metrology) ""
set SDESC(seeing_mass.Application) "" 
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



set DESC(camera.WFS) "Wavefront System Manager
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

set DESC(camera.GS) "Guide Sensor System Manager
<P>This subsystem maintains metadata concerning the state of the<BR>guide
regions, and the results of the processing of<BR>the subimages. Items
such as bax pixel counts, H/V profiles<BR>profile fit results etc. The Guide Sensor System(GSS) produces data that is collected by the Guider Data Acquisition System (GAS) and sent to
the Focal Plane Actuator (FPU) and also, possibly, the Telescope Control System (TCS). "

set DESC(camera.GAS) "The Guider data acquisition system (GAS) includes the readout controller for Guide Sensor data and the logic to process, analyze, and reformat the data for the Telescope control system."

set DESC(camera.FPU) "The Focal Plane Array (FPU) Actuation manager software controls translational and rotational actuation of the detector array in the focal plane."

set DESC(camera.TC) "The Thermal Control (TCS) manager software controls temperature in multiple thermal zones in the focal plane, cryostat, and camera body.  Feedback control is based on trim heaters for actuation and temperature sensors for readback.<P>
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

set DESC(camera.SCU) "The Shutter Controller Unit (SCU) manager software controls and synchronizes shutter operation.
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

set DESC(camera.xraycalib) "The xray calibration subsystem consists of an Fe55 source on wiperblade arm(s) that sweeps across the focal plane for
xray calibration of quantum efficiency, electrical gains and offsets, readout noise, and physical/cosmetic features of the
CCD array."

set DESC(camera.FEE) "Directly beneath each packaged CCD module is a Front End Electronics Module containing the following functionality.
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

set DESC(camera.Metrology) "
<P>Position control  for sensors located in the camera
subsystem.<BR>Raw sensor readings, calibrated positions, limit
switches, status bits. "

set DESC(camera.RNA) "
<P>This subsystem maintains data from each RNA unit. This will
include<BR>performance characteristics, health checks, statuses etc. 
Camera Raft Modules consist of astronomical quality optical imaging sensors and the mechanical structure that holds them
at their precise locations. The mechanical mounting system incorporates interfaces to the structural, thermal, vacuum, and
electronics subsystems of the enclosing cryostat.
<P>
Arrays of 3×3 sensors are mounted to raft structures that in turn mount to the integrating
structure. Raft structure plates are double side lapped all at once to be flat, parallel and the same size to less than 1 µm. Thus, rafts assembled with sensors are flat, parallel and the same height to 6.5 µm peak to valley. The raft structure and the sensor substrate have a well matched coefficient of thermal expansion and good thermal conduction to maintain this flatness performance during operation, since the assembly is subject to large temperature changes (ambient to operating temperature)."

set DESC(camera.SAS) "This subsystem comprises the science image sensors (201 CCDs), the front end electronics, the back end electronics, and a collection of electronics boards on a common bus along with the power supplies, cabling, fiber outputs, etc. needed to operate the CCDs in the science array. The 201 CCDs fully populate 21 focal plane rafts with 9 CCDs each and partially populate 4 rafts with 3 CCDs each. A dedicated state machine based controller issues timing and control signals to Camera Electronics. Specifically, it controls all signals required by both Front End Cards and Back End Cards. These include all CCD clocks, Signal Processing ASIC timing/control signals, A to D conversion control signals on the Back End, and so forth. Note that sensor data is normally not returned to the SAC, but is routed out of the camera on multiple Data Fibers. The control module for this subsystem would run on an embedded processor providing an interface between the CCM and the dedicated state machine based controller."


set DESC(camera.SDS) "This subsystem comprises 25 computers (one per raft, not including spares), each hosting a fiber interface card to receive the image data generated by a raft. These computers would buffer the image data in memory and transfer the data into the Data Management stream. Iitial data quality assessment), may also be carried out on these hosts."

set DESC(camera.TC.T1S) "
This subsystem comprises the devices and controllers necessary for monitoring and control of
the temperature of the focal plane sensors and front end electronics. This zone must be
maintained at approximately -100C to high accuracy (to be specified). Its function is to remove heat from the focal plane due to radiation through L1 as well as heat dissipated in the CCDs and Front End Cards"

set DESC(camera.TC.T2S) "This subsystem comprises the devices and controllers necessary for thermal monitoring and control of the Back End Electronics attached to the bottom plate of the Inner Cryostat. The temperature will be in the neighborhood of -20C but does not require high accuracy or stability. Its function is to remove heat generated by the Back End Electronics."

set DESC(camera.TC.T3U) "This unit monitors and controls temperature in the Timing/Control Crate. Specifically, it removes heat generated by electronics residing in the Crate and monitors crate temperature."



set DESC(camera.TC.T4U) "This unit monitors and controls temperature in the External Services Crate. Specifically, it removes heat generated by electronics residing in the Crate and monitors crate temperature."

set DESC(camera.BEE) "The camera Back-End Electronics module"

set DESC(system.Computer_status) "This subsystem records the status of
every computer hardware item"

set DESC(system.Software_revision_history) "This item records all software revisions
made to items inthe system"

set DESC(system.Hardware_revision_history) "This item records all hardware revisions made to items in the system"

set DESC(system.Command_history) "This item records all commands and their
responses."

set DESC(m1m3.Application) "This subsystem generates application level items calculated from subsystem raw data"
set DESC(m2ms.Application) "This subsystem generates application level items calculated from subsystem raw data"
set DESC(MTMount.Application) "This subsystem generates application level items calculated from subsystem raw data"
set DESC(calibration.Application) "This subsystem generates application level items calculated from subsystem raw data"
set DESC(scheduler.Application) "This subsystem generates application level items calculated from subsystem raw data"
set DESC(operations.Application) "This subsystem generates application level items calculated from subsystem raw data"
set DESC(auxscope.Application) "This subsystem generates application level items calculated from subsystem raw data"
set DESC(lasercal.Application) "This subsystem generates application level items calculated from subsystem raw data"
set DESC(seeing_dimm.Application) "This subsystem generates application level items calculated from subsystem raw data"
set DESC(seeing_mass.Application) "This subsystem generates application level items calculated from subsystem raw data"
set DESC(skycam.Application) "This subsystem generates application level items calculated from subsystem raw data"
set DESC(network.Application) "This subsystem generates application level items calculated from subsystem raw data"

set DESC(tcs.kernel.TrackRefSys) "This subsystem is internal to the tcs pointing kernel"
set DESC(tcs.kernel.Target) "This subsystem is internal to the tcs pointing kernel"
set DESC(tcs.kernel.DawdleFilter) "This subsystem is internal to the tcs pointing kernel"
set DESC(tcs.kernel.FK5Target) "This subsystem is internal to the tcs pointing kernel"
set DESC(tcs.kernel.OpticsVt) "This subsystem is internal to the tcs pointing kernel"
set DESC(tcs.kernel.PointingControl) "This subsystem is internal to the tcs pointing kernel"
set DESC(tcs.kernel.PointingLog) "This subsystem is internal to the tcs pointing kernel"
set DESC(tcs.kernel.PointingModel) "This subsystem is internal to the tcs pointing kernel"
set DESC(tcs.kernel.Site) "This subsystem is internal to the tcs pointing kernel"
set DESC(tcs.kernel.TimeKeeper) "This subsystem is internal to the tcs pointing kernel"
set DESC(tcs.kernel.TrackingTarget) "This subsystem is internal to the tcs pointing kernel"

set DESC(vms) "The Vibration Monitoring Subsystem consists of a set of accellerometers, some fixed
and some mobile which are attached to the major telescope components, plus computer hardware to 
collect the vibration data and publish it as Telemetry"

set BLOBS(camera.WDS.wfsRaft) "100x100x8 32bit analysis images"
set BLOBS(camera.GAS)  "64x64x8 16bit images"
#deprecated , these go to the DAQ
#set BLOBS(auxscope.Spectrometer) "4096x2048x1 16bit images"
#set BLOBS(auxscope.Camera) "4096x4096x1 16bit images"
set BLOBS(seeing_dimm.Application) "64x64x4 16bit images"
#deprecated, no longer have MASS
###set BLOBS(seeing_mass.Application) "64x64x4 16bit images"
set BLOBS(skycam.Application) "1024x1024x4 16bit images"
set BLOBS(environment.Lightning_detector) "1024x1024x1 8bit history image"
set BLOBS(environment.Video_cameras) "640x480x16 8bit images"



