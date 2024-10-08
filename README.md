# Service Abstraction Layer package

Provides tools to turn ts_xml interface description into C++, Java and
LabView interfaces. Turns XMLs with the interface description into Avro schemas and language bindings.
Without going into details, it can be said binding for the following primitives are generated:

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

# Installing on docker image

On lsstts/develop-env container, run the following:

```bash
cd ts_sal
setup -r .
scons
scons install declare
```

# Installing outside of the container

## Dependencies

* **avro-src-1.11.1** for Avro to generate C++, Java and LabView interfaces
* **libcurl4-openssl-devel
* **libavro-devel
* **libjansson-devel
* **cmake
* **g++
* **maven-3.9.2
* **libboost-devel
* **libboost-filesystem-devel
* **libboost-iostreams-devel
* **libboost-program-options-devel
* **libboost-system-devel

**The following works with Kafka compiled for AlmaLinux:8.**

On a almaLinux:8 docker image, run the following as root:

```bash
yum -y update
yum -y install git python3 which make java-1.8.0-openjdk-devel
```

## Usage

To get needed github projects and setup environment variables, do:

```bash
git clone https://github.com/lsst-ts/ts_sal
source ts_sal/setup.env
```

You will need then populate ts_sal/test directory with XML schema:

```bash
git clone https://github.com/lsst-ts/ts_xml
cp ts_xml/python/lsst/ts/xml/data/sal_interfaces/*.xml ts_sal/test
cp ts_xml/python/lsst/ts/xml/data/sal_interfaces/MTMount/*.xml ts_sal/test
```

### C++

For C++ development, install gcc-c++:

```bash
yum install -y gcc-c++
```

To generate C++ interfaces for a SAL component (where `<component_name>` is the name of a SAL component, e.g. `MTMount`):

```bash
cd ts_sal/test
salgenerator <component_name> validate
salgenerator <component_name> sal cpp
```

### Java

To generate Java libraries for a SAL component (where `<component_name>` is the name of a SAL component, e.g. `MTMount`):

```bash
cd  ts_sal/test
salgenerator <component_name> validate
salgenerator <component_name> sal java
salgenerator <component_name> maven
```

To run Java unit tests:

```bash
salgenerator Test validate
salgenerator Test sal java
salgenerator Test maven
salgenerator Script validate
salgenerator Script sal java
salgenerator Script maven
cd ts_sal/java_tests
mvn test
```


### LabView

To generate LabView libraries for a component (where `<component_name>` is the name of a SAL component, e.g. `MTMount`):

```bash
cd  ts_sal/test
salgenerator <component_name> validate
salgenerator <component_name> sal cpp
salgenerator <component_name> labview
```

Then run the LabVIEW GUI and import the 
`$SAL_WORK_DIR/MTMount/labview/SALLV_<component_name>.so` shared library

Then run the ts_SALLabVIEW VI to generate the .lvlib and VI's
