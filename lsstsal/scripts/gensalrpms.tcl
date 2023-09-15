#!/usr/bin/env tclsh
## \file gensalrpms.tcl
# \brief This contains procedures to create the runtime RPM assets
# for SAL APIs
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#   NOTE ~/.rpmmacros sets the rpmbuild root directory
#
#   On yum server do   createrepo --update /path-to-repo
#   On clients do      yum makecache fast
#
#\code
#
set SAL_WORK_DIR $env(SAL_WORK_DIR)
set OSPL_HOME $env(OSPL_HOME)
set SAL_DIR $env(SAL_DIR)

source $SAL_DIR/add_system_dictionary.tcl
source $SAL_DIR/ospl_version.tcl
source $SAL_DIR/sal_version.tcl


#
## Documented proc \c copyasset .
# \param[in] asset Path a file to include in the RPM
# \param[in] dest Destination directory for copy
#
proc copyasset { asset dest } {
global OPTIONS
    if { $OPTIONS(verbose) } {puts stdout "###TRACE copyasset for $asset $dest"}
    if { [file exists $asset] } {
       exec cp $asset $dest
    }
}


#
## Documented proc \c updatetests .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] rpmname Name of the rpm base directory
#
#  Copies the test programs into the rpm base directory
#
proc updatetests { subsys rpmname } {
global SAL_WORK_DIR XMLVERSION RELVERSION
   if { $RELVERSION != "" } {
     set rpmversion [set XMLVERSION]~[set RELVERSION]
     if { [string range $RELVERSION 0 0] == "_" } {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     } else {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     }
   } else {
     set rpmversion $XMLVERSION
   }
   catch {
    copyasset $SAL_WORK_DIR/lib/libSAL_[set subsys].so [set rpmname]-$rpmversion/opt/lsst/ts_sal/lib/.
    copyasset $SAL_WORK_DIR/lib/libSAL_[set subsys].a [set rpmname]-$rpmversion/opt/lsst/ts_sal/lib/.
    set all ""
    catch {set all [glob [set subsys]_*/cpp]}
    foreach i $all {
       set tlm [lindex [split $i "/"] 0]
       set top [join [lrange [split $tlm "_"] 1 end] "_"]
       copyasset $i/standalone/sacpp_[set subsys]_pub [set rpmname]-$rpmversion/opt/lsst/ts_sal/bin/sacpp_[set subsys]_[set top]_publisher
       copyasset $i/standalone/sacpp_[set subsys]_sub [set rpmname]-$rpmversion/opt/lsst/ts_sal/bin/sacpp_[set subsys]_[set top]_subscriber
       puts stdout "Done $subsys $top"
    }
    foreach ttype "commander controller send log logger sender publisher subscriber" {
      set all [glob [set subsys]/cpp/src/*_[set ttype]]
      foreach i $all {
         copyasset $i [set rpmname]-$rpmversion/opt/lsst/ts_sal/bin/.
         puts stdout "Done $subsys $i"
      }
    }
  }
}


#
## Documented proc \c updateruntime .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] withtest Optional specifier to include test programs
#
#  Copies the necessary files into rpm base directory
#
proc updateruntime { subsys {withtest 0} } {
global SAL_WORK_DIR XMLVERSION RELVERSION SAL_DIR SYSDIC SALVERSION env
  set rpmname $subsys
  if { $RELVERSION != "" } {
    set rpmversion [set XMLVERSION]~[set RELVERSION]
    if { [string range $RELVERSION 0 0] == "_" } {
      set rpmversion [set XMLVERSION]~[set RELVERSION]
    } else {
      set rpmversion [set XMLVERSION]~[set RELVERSION]
    }
  } else {
    set rpmversion $XMLVERSION
  }
  if { $withtest } {set rpmname [set subsys]_test}
  exec rm -fr [set rpmname]-$rpmversion
  exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_sal
  exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_sal/bin
  exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_sal/lib
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/BUILD
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/BUILDROOT
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/RPMS
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/SOURCES
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/SPECS
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/SRPMS
  if { $withtest == 0 } {
    exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_sal/include
    exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_sal/scripts
    exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_sal/idl
    exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_sal/lib
    exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_sal/doc
    if { [info exists SYSDIC([set subsys],labview)] } {
      exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_sal/labview
      exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_sal/labview/lib
      copyasset $SAL_WORK_DIR/lib/SALLV_[set subsys].so [set rpmname]-$rpmversion/opt/lsst/ts_sal/labview/lib/.
      copyasset $SAL_WORK_DIR/[set subsys]/labview/SALLV_[set subsys]_Monitor [set rpmname]-$rpmversion/opt/lsst/ts_sal/bin/.
      copyasset $SAL_WORK_DIR/[set subsys]/labview/SAL_[set subsys]_shmem.h [set rpmname]-$rpmversion/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/labview/sal_[set subsys].idl [set rpmname]-$rpmversion/opt/lsst/ts_sal/labview/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]LV.h [set rpmname]-$rpmversion/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/lib/libsacpp_[set subsys]_types.so [set rpmname]-$rpmversion/opt/lsst/ts_sal/lib/.
    }
    if { [info exists SYSDIC([set subsys],java)] } {
      exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_sal/jar
      copyasset $SAL_WORK_DIR/lib/saj_[set subsys]_types.jar [set rpmname]-$rpmversion/opt/lsst/ts_sal/jar/.
      copyasset $SAL_WORK_DIR/maven/[set rpmname]-[set rpmversion]_$SALVERSION/target/sal_[set subsys]-[set rpmversion]_$SALVERSION.jar [set rpmname]-$rpmversion/opt/lsst/ts_sal/jar/.
    }
    exec mkdir -p [set rpmname]-$rpmversion/opt/lsst/ts_xml/python/lsst/ts/xml/data/sal_interfaces/[set subsys]
    if { [info exists SYSDIC([set subsys],cpp)] } {
      copyasset $SAL_WORK_DIR/lib/libSAL_[set subsys].so [set rpmname]-$rpmversion/opt/lsst/ts_sal/lib/.
      copyasset $SAL_WORK_DIR/lib/libSAL_[set subsys].a [set rpmname]-$rpmversion/opt/lsst/ts_sal/lib/.
      copyasset $SAL_WORK_DIR/lib/libsacpp_[set subsys]_types.so [set rpmname]-$rpmversion/opt/lsst/ts_sal/lib/.
    }
    copyasset $SAL_WORK_DIR/idl-templates/validated/[set subsys]_revCodes.tcl [set rpmname]-$rpmversion/opt/lsst/ts_sal/scripts/.
    copyasset $SAL_WORK_DIR/idl-templates/validated/sal/sal_revCoded_[set subsys].idl [set rpmname]-$rpmversion/opt/lsst/ts_sal/idl/.
    if { [info exists SYSDIC([set subsys],cpp)] } {
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys].h [set rpmname]-$rpmversion/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]_actors.h [set rpmname]-$rpmversion/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]C.h [set rpmname]-$rpmversion/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/sal_[set subsys]Dcps.h [set rpmname]-$rpmversion/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/sal_[set subsys]Dcps_impl.h [set rpmname]-$rpmversion/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/sal_[set subsys].h [set rpmname]-$rpmversion/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/ccpp_sal_[set subsys].h [set rpmname]-$rpmversion/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/sal_[set subsys]SplDcps.h [set rpmname]-$rpmversion/opt/lsst/ts_sal/include/.
      copyasset $SAL_DIR/code/templates/SAL_defines.h [set rpmname]-$rpmversion/opt/lsst/ts_sal/include/.
    }
    foreach dtype "Commands Events Telemetry" {
      if { [file exists $env(TS_XML_DIR)/python/lsst/ts/xml/data/sal_interfaces/$subsys/[set subsys]_[set dtype].xml] } {
        exec cp $env(TS_XML_DIR)/python/lsst/ts/xml/data/sal_interfaces/$subsys/[set subsys]_[set dtype].xml [set rpmname]-$rpmversion/opt/lsst/ts_xml/python/lsst/ts/xml/data/sal_interfaces/[set subsys]/.
      }
    }
    exec cp $SAL_WORK_DIR/[set subsys]_Generics.xml [set rpmname]-$rpmversion/opt/lsst/ts_xml/python/lsst/ts/xml/data/sal_interfaces/[set subsys]/.
    foreach dtype "Commands Events Telemetry" {
      if { [file exists $SAL_WORK_DIR/html/[set subsys]/[set subsys]_[set dtype].html] } {
        exec cp $SAL_WORK_DIR/html/[set subsys]/[set subsys]_[set dtype].html [set rpmname]-$rpmversion/opt/lsst/ts_xml/python/lsst/ts/xml/data/sal_interfaces/[set subsys]/.
      }
    }
  }
  if { $withtest } { updatetests $subsys $rpmname }
  exec tar cvzf $SAL_WORK_DIR/rpmbuild/SOURCES/[set rpmname]-$rpmversion.tgz [set rpmname]-$rpmversion
  exec rm -fr $SAL_WORK_DIR/rpmbuild/BUILD/[set rpmname]-[set rpmversion]
  exec cp -r [set rpmname]-$rpmversion $SAL_WORK_DIR/rpmbuild/BUILD/[set rpmname]-[set rpmversion]
  listfilesforrpm $rpmname
  if { $withtest } {
    puts [pwd]
    generatetestrpm $subsys
    set frpm [open /tmp/makerpm-runtime-[set subsys] w]
    puts $frpm "#!/bin/sh
export QA_RPATHS=0x001F
rpmbuild -bi -bl -v $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_[set subsys]_test.spec
rpmbuild -bb -bl -v $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_[set subsys]_test.spec
"
    close $frpm
    exec chmod 755 /tmp/makerpm-runtime-[set subsys]
    exec /tmp/makerpm-runtime-[set subsys]  >& /tmp/makerpm_[set subsys]_test.log
    exec cat /tmp/makerpm_[set subsys]_test.log
  } else {
    generaterpm $subsys
    set frpm [open /tmp/makerpm-runtime-[set subsys] w]
    puts $frpm "#!/bin/sh
export QA_RPATHS=0x001F
rpmbuild -bi -bl -v $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_[set subsys].spec
rpmbuild -bb -bl -v $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_[set subsys].spec
"
    close $frpm
    exec chmod 755 /tmp/makerpm-runtime-[set subsys]
    exec /tmp/makerpm-runtime-[set subsys]  >& /tmp/makerpm_[set subsys].log
    exec cat /tmp/makerpm_[set subsys].log
  }
  cd $SAL_WORK_DIR
  updatesingletons ts_sal_utils
  updatesingletons ts_sal_runtime
  updatesingletons ts_sal_ATruntime
}

#
## Documented proc \c updatesingletons .
# \param[in] name Name of asset (ts_sal_utils, ts_sal_runtime,ts_sal_ATruntime)
#
proc updatesingletons { name } {
global SAL_WORK_DIR XMLVERSION SALVERSION
  set found ""
  catch {
    set found [glob $SAL_WORK_DIR/rpmbuild/RPMS/x86_64/[set name]-$XMLVERSION-$SALVERSION*]
  }
  if { $found == "" } {
     switch $name  {
        ts_sal_utils     { generateUtilsrpm }
        ts_sal_runtime   { generatemetarpm }
        ts_sal_ATruntime { generateATmetarpm }
     }
  }
}


#
## Documented proc \c updateddsruntime .
# \param[in] version DDS version specifier
#
proc updateddsruntime { version } {
  exec rm -fr /opt/lsst/ts_opensplice
  exec mkdir -p /opt/lsst/ts_opensplice/OpenSpliceDDS
  exec cp -r /data/gitrepo/ts_opensplice/OpenSpliceDDS/[set version] /opt/lsst/ts_opensplice/OpenSpliceDDS/.
}


#
## Documented proc \c listfilesforrpm .
# \param[in] rpmname Name of RPM file
#
#  Generate a list of files for inclusion in the RPM
#  This is an RPM which Requires all the Main telescope RPMs
#
proc listfilesforrpm { rpmname } {
global XMLVERSION RELVERSION env RPMFILES SAL_WORK_DIR
   set RPMFILES ""
   if { $RELVERSION != "" } {
     set rpmversion [set XMLVERSION]~[set RELVERSION]
     if { [string range $RELVERSION 0 0] == "_" } {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     } else {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     }
   } else {
     set rpmversion $XMLVERSION
   }
   cd $SAL_WORK_DIR/rpmbuild/BUILD/[set rpmname]-[set rpmversion]
   set fl [split [exec find . -type f  -print] \n]
   foreach f $fl {
       if { [string range $f 0 4] == "./opt" } {
          lappend RPMFILES [string range $f 1 end]
       }
   }
}


#
## Documented proc \c generatemetarpm .
#
#  Generate the SPEC file for the ts_sal_runtime RPM
#
proc generatemetarpm { } {
global SYSDIC SALRELEASE SALVERSION SAL_WORK_DIR OSPL_VERSION RELVERSION env XMLVERSION
   if { $RELVERSION != "" } {
     set rpmversion [set XMLVERSION]~[set RELVERSION]
     if { [string range $RELVERSION 0 0] == "_" } {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     } else {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     }
   } else {
     set rpmversion $XMLVERSION
   }
   set fout [open $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_runtime.spec w]
   set rpmversion [join [split $rpmversion "-"] "~"]
   set release $SALVERSION
   puts $fout "
%global __os_install_post %{nil}
%define debug_package %{nil}
%define name			ts_sal_runtime
%define summary			SAL runtime meta package
%define license			GPL
%define group			LSST Telescope and Site
%define vendor			LSST
%define packager		dmills@lsst.org

Name:      %{name}
Version: [set rpmversion]
Release: [set release]%\{?dist\}
Packager:  %{packager}
Vendor:    %{vendor}
License:   %{license}
Summary:   %{summary}
Group:     %{group}
AutoReqProv: no
#Source:    %{source}
URL:       %{url}
Prefix:    %{_prefix}
Buildroot: %{buildroot}
Requires: OpenSpliceDDS = $OSPL_VERSION
Requires: ts_sal_utils
"
   foreach subsys $SYSDIC(systems) {
      puts $fout "Requires: $subsys = $rpmversion"
   }
   puts $fout "
%description
This metapackage is used to install all the SAL runtime packages at once

%setup -c -T

%install

%files
"
   close $fout
  set frpm [open /tmp/makerpm-meta w]
  puts $frpm "#!/bin/sh
rpmbuild -ba -v $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_runtime.spec
"
  close $frpm
  exec chmod 755 /tmp/makerpm-meta
  exec /tmp/makerpm-meta  >& /tmp/makerpm-meta.log
  exec cat /tmp/makerpm-meta.log
}

#
## Documented proc \c generateATmetarpm .
#
#  Generate the SPEC file for the ts_sal_ATruntime RPM
#  This is an RPM which Requires all the Auxtel RPMs
#
proc generateATmetarpm { } {
global SYSDIC SALRELEASE SALVERSION SAL_WORK_DIR OSPL_VERSION RELVERSION env XMLVERSION
   if { $RELVERSION != "" } {
     set rpmversion [set XMLVERSION]~[set RELVERSION]
     if { [string range $RELVERSION 0 0] == "_" } {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     } else {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     }
   } else {
     set rpmversion $XMLVERSION
   }
   set fout [open $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_ATruntime.spec w]
   set rpmversion [join [split $rpmversion "-"] "~"]
   set release $SALVERSION
   puts $fout "
%global __os_install_post %{nil}
%define debug_package %{nil}
%define name			ts_sal_ATruntime
%define summary			SAL Aux Telescope runtime meta package
%define license			GPL
%define group			LSST Telescope and Site
%define vendor			LSST
%define packager		dmills@lsst.org

Name:      %{name}
Version: [set rpmversion]
Release: [set release]%\{?dist\}
Packager:  %{packager}
Vendor:    %{vendor}
License:   %{license}
Summary:   %{summary}
Group:     %{group}
AutoReqProv: no
#Source:    %{source}
URL:       %{url}
Prefix:    %{_prefix}
Buildroot: %{buildroot}
Requires: OpenSpliceDDS = $OSPL_VERSION
Requires: ts_sal_utils
"
   foreach subsys $SYSDIC(systems) {
      if { [string range $subsys 0 1] == "AT" } {
        puts $fout "Requires: $subsys = $rpmversion"
      }
   }
   puts $fout "
%description
This metapackage is used to install all the SAL Aux telescope related runtime packages at once

%setup -c -T

%install

%files
"
   close $fout
  set frpm [open /tmp/makerpm-atmeta w]
  puts $frpm "#!/bin/sh
rpmbuild -ba -v $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_ATruntime.spec
"
  close $frpm
  exec chmod 755 /tmp/makerpm-atmeta
  exec /tmp/makerpm-atmeta  >& /tmp/makerpm-atmeta.log
  exec cat /tmp/makerpm-atmeta.log
}

#
## Documented proc \c generaterpm .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate the SPEC file for the specified Subsystem/CSC
#
proc generaterpm { subsys } {
global SAL_WORK_DIR SALVERSION SALRELEASE RPMFILES OSPL_VERSION RELVERSION XMLVERSION env
  exec rm -fr $SAL_WORK_DIR/rpm_[set subsys]
  exec mkdir -p $SAL_WORK_DIR/rpm_[set subsys]
  set fout [open $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_[set subsys].spec w]
  if { $RELVERSION != "" } {
     set rpmversion [set XMLVERSION]~[set RELVERSION]
     if { [string range $RELVERSION 0 0] == "_" } {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     } else {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     }
  } else {
     set rpmversion $XMLVERSION
  }
  set rpmversion [join [split $rpmversion "-"] "~"]
  set release $SALVERSION
  puts $fout "Name: $subsys
Version: [set rpmversion]
Release: [set release]%\{?dist\}
Summary: SAL runtime for $subsys Subsystem
Vendor: LSST
License: GPL
URL: http://project.lsst.org/ts
Group: Telescope and Site SAL
AutoReqProv: no
Source0: [set subsys]-$rpmversion.tgz
Prefix: /opt
BuildRoot: $SAL_WORK_DIR/rpmbuild/%\{name\}-%\{version\}-[set release]
Packager: dmills@lsst.org
Requires: OpenSpliceDDS = $OSPL_VERSION
Requires: ts_sal_utils
%global __os_install_post %{nil}
%define debug_package %{nil}

%description
This is a SAL runtime and build environment for the LSST $subsys subsystem.
It provides shared libraries , jar files , include files and documentation
for the middleware interface.

%prep

%setup

%build

%install
cp -fr * %{buildroot}/.

%files"
  foreach f $RPMFILES {
     puts $fout $f
  }
  puts $fout "

%clean
rm -fr \$RPM_BUILD_ROOT

%post
%postun
%changelog
"
  close $fout
  cd $SAL_WORK_DIR
}


#
## Documented proc \c generatetestrpm .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate the SPEC file for the specified Subsystem/CSC tests
#
proc generatetestrpm { subsys } {
global SAL_WORK_DIR SALVERSION SALRELEASE RPMFILES OSPL_VERSION RELVERSION XMLVERSION env
  exec rm -fr $SAL_WORK_DIR/rpm_[set subsys]
  exec mkdir -p $SAL_WORK_DIR/rpm_[set subsys]
  set fout [open $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_[set subsys]_test.spec w]
  if { $RELVERSION != "" } {
     set rpmversion [set XMLVERSION]~[set RELVERSION]
     if { [string range $RELVERSION 0 0] == "_" } {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     } else {
       set rpmversion [set XMLVERSION]~[set RELVERSION]
     }
  } else {
     set rpmversion $XMLVERSION
  }
  set rpmversion [join [split $rpmversion "-"] "~"]
  set release $SALVERSION
  puts $fout "Name: [set subsys]_test
Version: [set rpmversion]
Release: [set release]%\{?dist\}
Summary: SAL runtime for $subsys Subsystem with tests
Vendor: LSST
License: GPL
URL: http://project.lsst.org/ts
Group: Telescope and Site SAL
AutoReqProv: no
Source0: [set subsys]_test-$rpmversion.tgz
Prefix: /opt
BuildRoot: $SAL_WORK_DIR/rpmbuild/%\{name\}-%\{version\}_[set release]
Packager: dmills@lsst.org
Requires: OpenSpliceDDS = $OSPL_VERSION
Requires : [set subsys] = $rpmversion
Requires: ts_sal_utils
%global __os_install_post %{nil}
%define debug_package %{nil}

%description
This is a SAL runtime test environment for the LSST $subsys subsystem.
It includes precompiled test programs for each message type.

%prep

%setup

%build

%install
cp -fr * %{buildroot}/.

%files"
  foreach f $RPMFILES {
     puts $fout $f
  }
  puts $fout "

%clean
rm -fr \$RPM_BUILD_ROOT

%post
%postun
%changelog
"
  close $fout
  cd $SAL_WORK_DIR
#  set fxml [glob [set subsys]_*.xml]
#  set ctar "exec tar czf $SAL_WORK_DIR/rpmbuild/SOURCES/[set subsys]-$SALVERSION.tgz [set fxml] SALSubsystems.xml SALGenerics.xml"
#  eval $ctar
}


#
## Documented proc \c generateUtilsrpm .
#
#  Generate the SPEC file for ts_sal_utils
#
proc generateUtilsrpm { } {
global SYSDIC SALVERSION SAL_WORK_DIR OSPL_VERSION SAL_DIR env
   set fout [open $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_utils.spec w]
   puts $fout "
%global __os_install_post %{nil}
%define debug_package %{nil}

%define name			ts_sal_utils
%define summary			SAL runtime utilities package
%define version			$SALVERSION
%define release			1

Name:      %{name}
Vendor: LSST
License: GPL
URL: http://project.lsst.org/ts
Group: Telescope and Site SAL
Source0: ts_sal_utils-[set SALVERSION].tgz
BuildRoot: $SAL_WORK_DIR/rpmbuild/%\{name\}-%\{version\}
Packager: dmills@lsst.org
Version:   %{version}
Release:   %{release}
Summary:   %{summary}
AutoReqProv: no
Requires: linuxptp

%description
This package provides utilities supporting the ts_sal_runtime packages

%setup

%install
cp -fr %\{name\}-%\{version\}/* %{buildroot}/.

%files
/etc/systemd/system/ts_sal_settai.service
/opt/lsst/ts_sal/bin/set-tai
/opt/lsst/ts_sal/bin/update_leapseconds
/opt/lsst/ts_sal/lib/libsalUtils.so
/opt/lsst/ts_sal/etc/leap-seconds.list
/opt/lsst/ts_sal/setup.env
"
  close $fout
  exec mkdir -p ts_sal_utils-$SALVERSION/etc/systemd/system
  exec mkdir -p ts_sal_utils-$SALVERSION/opt/lsst/ts_sal/bin
  exec mkdir -p ts_sal_utils-$SALVERSION/opt/lsst/ts_sal/lib
  exec mkdir -p ts_sal_utils-$SALVERSION/opt/lsst/ts_sal/etc
  set fser [open ts_sal_utils-$SALVERSION/etc/systemd/system/ts_sal_settai.service w]
     puts $fser "
\[Unit\]
Description=SAL set TAI time offset
Wants=network-online.target

\[Service\]
Type=simple
WorkingDirectory=/opt/lsst/ts_sal/bin
ExecStart=/opt/lsst/ts_sal/bin/update_leapseconds
Restart=on-failure
User=root

\[Install\]
WantedBy=ts_sal_settai.service
"
  close $fser
  exec make_salUtils
  copyasset $SAL_WORK_DIR/salUtils/set-tai ts_sal_utils-$SALVERSION/opt/lsst/ts_sal/bin/.
  copyasset $env(TS_SAL_DIR)/bin/update_leapseconds ts_sal_utils-$SALVERSION/opt/lsst/ts_sal/bin/.
  copyasset $SAL_WORK_DIR/lib/libsalUtils.so ts_sal_utils-$SALVERSION/opt/lsst/ts_sal/lib/.
  copyasset $SAL_DIR/leap-seconds.list ts_sal_utils-$SALVERSION/opt/lsst/ts_sal/etc/.
  copyasset $env(TS_SAL_DIR)/setup.env ts_sal_utils-$SALVERSION/opt/lsst/ts_sal/.
  exec tar cvzf $SAL_WORK_DIR/rpmbuild/SOURCES/ts_sal_utils-$SALVERSION.tgz ts_sal_utils-$SALVERSION
  exec rm -fr $SAL_WORK_DIR/rpmbuild/BUILD/ts_sal_utils-$SALVERSION/*
  exec cp -r ts_sal_utils-$SALVERSION $SAL_WORK_DIR/rpmbuild/BUILD/.
  set frpm [open /tmp/makerpm-utils w]
  puts $frpm "#!/bin/sh
export QA_RPATHS=0x001F
rpmbuild -bi -bl -v $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_utils.spec
rpmbuild -bb -bl -v $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_utils.spec
"
  close $frpm
  exec chmod 755 /tmp/makerpm-utils
  exec /tmp/makerpm-utils  >& /tmp/makerpm-utils.log
  exec cat /tmp/makerpm-utils.log
}

#
## Documented proc \c generaterddsrpm .
#
#  Generate the SPEC file for ts_opensplice
#
proc generaterddsrpm { } {
global SAL_WORK_DIR OSPL_HOME OSPL_VERSION
  exec rm -fr $SAL_WORK_DIR/rpm_opensplice
  exec mkdir -p $SAL_WORK_DIR/rpm_opensplice
  set version [string trim [lindex [split [exec grep "PACKAGE_VERSION=" $OSPL_HOME/etc/RELEASEINFO] =] 1] "VS"]
  set fout [open $SAL_WORK_DIR/rpmbuild/BUILD/ts_opensplice.spec w]
  puts $fout "Name: ts_opensplice
Version: $OSPL_VERSION
Release: 1%\{?dist\}
Summary: DDS runtime for OpenSplice
Vendor: LSST
License: GPL
URL: http://project.lsst.org/ts
Group: Telescope and Site SAL
Source: opensplice_[set OSPL_VERSION].tgz
BuildRoot: $SAL_WORK_DIR/rpmbuild/%\{name\}-%\{$OSPL_VERSION\}
Packager: dmills@lsst.org
%global __os_install_post %{nil}
%define debug_package %{nil}

%description
This is a OpenSplice DDS runtime and build environment for the LSST subsystems.
It provides shared libraries , jar files , include files and documentation
for the DDS interface.

%prep

%install
mkdir -p /opt/.
cp -fR * /opt/.

%files
/opt/lsst/ts_opensplice

%clean

%post
systemctl enable ts_sal_settai
systemctl start ts_sal_settai
%postun
%changelog
"
  close $fout

}
