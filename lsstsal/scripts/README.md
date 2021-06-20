# Service Abstraction Layer package

Provides tools to turn ts_xml interface description into C++, Python, Java and
LabView interfaces. Turns XMLs with the interface description into Data
Distribution Service (DDS) schemas and language bindings. Without going into
details, it can be said binding for the following primitives are generated:


* **Telemetry** messages that a SAL component writes at regular intervals, e.g.
 to report data that varies continuously or slowly over time. Examples include
 measured temperatures and encoder readings.

* **Events** messages that a SAL component writes when an event occurs, such as
  a change in discrete state. Examples include reporting a new commanded
  telescope target position, and reporting that the dome shutter is open,
  closed or moving. Log messages are also written as events.

* **Commands** messages that a SAL component reads and acts on. Examples
  include command to start shutter opening.

[LSE-70](https://ls.st/LSE-70) provides more details, particularly starting at
chapter 3.2.4.


