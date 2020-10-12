#!/usr/bin/env tclsh

#
#   NOTE ~/.rpmmacros sets the rpmbuild root directory
#
#   On yum server do   createrepo --update /path-to-repo
#   On clients do      yum makecache fast
#
set SAL_WORK_DIR $env(SAL_WORK_DIR)
set OSPL_HOME $env(OSPL_HOME)
set SAL_DIR $env(SAL_DIR)

source $SAL_DIR/add_system_dictionary.tcl
source $SAL_DIR/ospl_version.tcl
source $SAL_DIR/sal_version.tcl


proc copyasset { asset dest } {
    if { [file exists $asset] } {
       exec cp $asset $dest
    }
}

proc updatetests { subsys rpmname } {
global SAL_WORK_DIR XMLVERSION
   catch {
    copyasset $SAL_WORK_DIR/lib/libSAL_[set subsys].so [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/lib/.
    set all [glob [set subsys]_*/cpp]
    foreach i $all {
       set tlm [lindex [split $i "/"] 0]
       set top [join [lrange [split $tlm "_"] 1 end] "_"]
       copyasset $i/standalone/sacpp_[set subsys]_pub [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/bin/sacpp_[set subsys]_[set top]_publisher
       copyasset $i/standalone/sacpp_[set subsys]_sub [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/bin/sacpp_[set subsys]_[set top]_subscriber
       puts stdout "Done $subsys $top"
    }
    foreach ttype "commander controller send log logger sender publisher subscriber" {
      set all [glob [set subsys]/cpp/src/*_[set ttype]]
      foreach i $all {
         copyasset $i [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/bin/.
         puts stdout "Done $subsys $i"
      }
    }
  }
}


proc updateruntime { subsys {withtest 0} } {
global SAL_WORK_DIR XMLVERSION SAL_DIR SYSDIC
  set rpmname $subsys
  if { $withtest } {set rpmname [set subsys]_test}
  exec rm -fr [set rpmname]-$XMLVERSION
  exec mkdir -p [set rpmname]-$XMLVERSION/opt/lsst/ts_sal
  exec mkdir -p [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/bin
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/BUILD
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/BUILDROOT
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/RPMS
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/SOURCES
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/SPECS
  exec mkdir -p $SAL_WORK_DIR/rpmbuild/SRPMS
  if { $withtest == 0 } {
    exec mkdir [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/include
    exec mkdir [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/scripts
    exec mkdir [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/idl
    exec mkdir [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/lib
    exec mkdir [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/doc
    if { [info exists SYSDIC([set subsys],labview)] } {
      exec mkdir [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/labview
      exec mkdir [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/labview/lib
      copyasset $SAL_WORK_DIR/lib/SALLV_[set subsys].so [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/labview/lib/.
      copyasset $SAL_WORK_DIR/[set subsys]/labview/SALLV_[set subsys]_Monitor [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/bin/.
      copyasset $SAL_WORK_DIR/[set subsys]/labview/SAL_[set subsys]_shmem.h [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/labview/sal_[set subsys].idl [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/labview/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]LV.h [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/include/.
    }
    if { [info exists SYSDIC([set subsys],java)] } {
      exec mkdir [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/jar
    }
    exec mkdir -p [set rpmname]-$XMLVERSION/opt/lsst/ts_xml/sal_interfaces/[set subsys]
    if { [info exists SYSDIC([set subsys],cpp)] } {
      copyasset $SAL_WORK_DIR/lib/libSAL_[set subsys].so [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/lib/.
    }
    if { [info exists SYSDIC([set subsys],python)] } {
      copyasset $SAL_WORK_DIR/lib/SALPY_[set subsys].so [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/lib/.
    }
    copyasset $SAL_WORK_DIR/idl-templates/validated/[set subsys]_revCodes.tcl [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/scripts/.
    copyasset $SAL_WORK_DIR/idl-templates/validated/sal/sal_revCoded_[set subsys].idl [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/idl/.
    if { [info exists SYSDIC([set subsys],cpp)] } {
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys].h [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/src/SAL_[set subsys]C.h [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/sal_[set subsys]Dcps.h [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/sal_[set subsys]Dcps_impl.h [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/sal_[set subsys].h [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/ccpp_sal_[set subsys].h [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/include/.
      copyasset $SAL_WORK_DIR/[set subsys]/cpp/sal_[set subsys]SplDcps.h [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/include/.
      copyasset $SAL_DIR/code/templates/SAL_defines.h [set rpmname]-$XMLVERSION/opt/lsst/ts_sal/include/.
    }
    foreach dtype "Commands Events Generics Telemetry" {
      if { [file exists $SAL_WORK_DIR/[set subsys]_[set dtype].xml] } {
        exec cp $SAL_WORK_DIR/[set subsys]_[set dtype].xml [set rpmname]-$XMLVERSION/opt/lsst/ts_xml/sal_interfaces/[set subsys]/.
      }
    }
    foreach dtype "Commands Events Telemetry" {
      if { [file exists $SAL_WORK_DIR/html/[set subsys]/[set subsys]_[set dtype].html] } {
        exec cp $SAL_WORK_DIR/html/[set subsys]/[set subsys]_[set dtype].html [set rpmname]-$XMLVERSION/opt/lsst/ts_xml/sal_interfaces/[set subsys]/.
      }
    }
  }
  if { $withtest } { updatetests $subsys $rpmname }
  exec tar cvzf $SAL_WORK_DIR/rpmbuild/SOURCES/[set rpmname]-$XMLVERSION.tgz [set rpmname]-$XMLVERSION
  exec rm -fr $SAL_WORK_DIR/rpmbuild/BUILD/[set rpmname]-$XMLVERSION
  exec cp -r [set rpmname]-$XMLVERSION $SAL_WORK_DIR/rpmbuild/BUILD/.
  listfilesforrpm $rpmname
  if { $withtest } {
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
  updatesingletons ts_sal_utils generateUtilsrpm
  updatesingletons ts_sal_runtime generatemetarpm
  updatesingletons ts_sal_ATruntime generateATmetarpm
}


proc updatesingletons { name process } {
global XMLVERSION
  set found ""
  catch {
    set found [glob $SAL_WORK_DIR/rpmbuild/RPMS/x86_64/[set name]-$XMLVERSION*]
  }
  if { $found == "" } {
     switch $name  {
        ts_sal_utils     { generateUtilsrpm }
        ts_sal_runtime   { generatemetarpm }
        ts_sal_ATruntime { generateATmetarpm } 
     }
  }
}


proc updateddsruntime { version } {
  exec rm -fr /opt/lsst/ts_opensplice
  exec mkdir -p /opt/lsst/ts_opensplice/OpenSpliceDDS
  exec cp -r /data/gitrepo/ts_opensplice/OpenSpliceDDS/[set version] /opt/lsst/ts_opensplice/OpenSpliceDDS/.
}


proc listfilesforrpm { rpmname } {
global XMLVERSION env RPMFILES SAL_WORK_DIR
   set RPMFILES ""
   cd $SAL_WORK_DIR/rpmbuild/BUILD/[set rpmname]-$XMLVERSION
   set fl [split [exec find . -type f  -print] \n]
   foreach f $fl { 
       if { [string range $f 0 4] == "./opt" } {
          lappend RPMFILES [string range $f 1 end]
       }
   }
}


proc generatemetarpm { } {
global SYSDIC SALRELEASE SALVERSION SAL_WORK_DIR OSPL_VERSION RELVERSION env
   if { $RELVERSION != "" } {
     set release [set SALVERSION].[set RELVERSION]
     if { [string range $RELVERSION 0 0] == "_" } {
       set release [set SALVERSION][set RELVERSION]
     } else {
       set release [set SALVERSION].[set RELVERSION]
     }
   } else {
     set release $SALVERSION
   }
   set xmldist [string trim [exec cat $env(SAL_WORK_DIR)/VERSION]]
   set fout [open $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_runtime.spec w]
   set rpmversion [exec cat $env(TS_XML_DIR)/VERSION]
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

proc generateATmetarpm { } {
global SYSDIC SALRELEASE SALVERSION SAL_WORK_DIR OSPL_VERSION RELVERSION env
   if { $RELVERSION != "" } {
     set release [set SALVERSION].[set RELVERSION]
     if { [string range $RELVERSION 0 0] == "_" } {
       set release [set SALVERSION][set RELVERSION]
     } else {
       set release [set SALVERSION].[set RELVERSION]
     }
   } else {
     set release $SALVERSION
   }
   set xmldist [string trim [exec cat $env(SAL_WORK_DIR)/VERSION]]
   set fout [open $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_ATruntime.spec w]
   set rpmversion [exec cat $env(TS_XML_DIR)/VERSION]
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

proc generaterpm { subsys } {
global SAL_WORK_DIR SALVERSION SALRELEASE RPMFILES OSPL_VERSION RELVERSION XMLVERSION env
  exec rm -fr $SAL_WORK_DIR/rpm_[set subsys]
  exec mkdir -p $SAL_WORK_DIR/rpm_[set subsys]
  set xmldist [string trim [exec cat $env(SAL_WORK_DIR)/VERSION]]
  set fout [open $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_[set subsys].spec w]
  if { $RELVERSION != "" } {
     if { [string range $RELVERSION 0 0] == "_" } {
       set release [set SALVERSION][set RELVERSION]
     } else {
       set release [set SALVERSION].[set RELVERSION]
     }
  } else {
     set release $SALVERSION
  }
  puts $fout "Name: $subsys
Version: [exec cat $env(TS_XML_DIR)/VERSION]
Release: [set release]%\{?dist\}
Summary: SAL runtime for $subsys Subsystem
Vendor: LSST
License: GPL
URL: http://project.lsst.org/ts
Group: Telescope and Site SAL
AutoReqProv: no
Source0: [set subsys]-$XMLVERSION.tgz
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


proc generatetestrpm { subsys } {
global SAL_WORK_DIR SALVERSION SALRELEASE RPMFILES OSPL_VERSION RELVERSION XMLVERSION env
  exec rm -fr $SAL_WORK_DIR/rpm_[set subsys]
  exec mkdir -p $SAL_WORK_DIR/rpm_[set subsys]
  set xmldist [string trim [exec cat $env(SAL_WORK_DIR)/VERSION]]
  set fout [open $SAL_WORK_DIR/rpmbuild/SPECS/ts_sal_[set subsys]_test.spec w]
  if { $RELVERSION != "" } {
     set release [set SALVERSION].[set RELVERSION]
     if { [string range $RELVERSION 0 0] == "_" } {
       set release [set SALVERSION][set RELVERSION]
     } else {
       set release [set SALVERSION].[set RELVERSION]
     }
  } else {
     set release $SALVERSION
  }
   set rpmversion [exec cat $env(TS_XML_DIR)/VERSION]
  puts $fout "Name: [set subsys]_test
Version: [set rpmversion]
Release: [set release]%\{?dist\}
Summary: SAL runtime for $subsys Subsystem with tests
Vendor: LSST
License: GPL
URL: http://project.lsst.org/ts
Group: Telescope and Site SAL
AutoReqProv: no
Source0: [set subsys]_test-$XMLVERSION.tgz
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


###
### sudo mv /usr/local /usr/local.save
### sudo mkdir /usr/local
### ./configure --prefix=/usr/local ; make ; sudo make install ; cd /usr/local ; sudo sh
### rm ./lib/python3.7/site-packages/setuptools/script\ \(dev\).tmpl
### rm ./lib/python3.7/site-packages/setuptools/command/launcher\ manifest.xml
### tar cvzf /tmp/py3runtime.tgz bin include lib share
### cd $SAL_WORK_DIR/rpmbuild/BUILDROOT/python-3.7.3-1.el7.centos.x86_64
### rm -fr * ; mkdir -p usr/local ; cd usr/local
### tar xvzf /tmp/py3runtime.tgz
### cd $SAL_WORK_DIR
### rpmbuild --nodeps --short-circuit -bb -bl -v ./rpmbuild/SPECS/ts_python.spec
### rm -fr /usr/local
### mv /usr/local.save /usr/local
###
proc generatePythonspec { } {
global SAL_WORK_DIR SALVERSION RPMFILES OSPL_VERSION env
  set fout [open $SAL_WORK_DIR/rpmbuild/SPECS/ts_python.spec w]
  puts $fout "Name: python
Version: 3.7.3
Release: 1%\{?dist\}
Summary: Python runtime for LSST TS
Vendor: LSST
License: PSF
URL: http://project.lsst.org/ts
Group: Telescope and Site SAL
AutoReqProv: no
Source0: Python3.7.3.tar.xz
BuildRoot: $SAL_WORK_DIR/rpmbuild/%\{name\}-%\{version\}
Packager: dmills@lsst.org

%global __os_install_post %{nil}
%define debug_package %{nil}

%description
This is a Python runtime and environment for the LSST Telescope and Site subsystems.

%prep

%setup
 
%build
#source /opt/lsst/ts_sal/setup.env

%install
cp -fr * %{buildroot}/.

%files"
set fin [open /home/dmills/python37/Python-3.7.3/lslr r]
while { [gets $fin rec] > -1 } {
   puts $fout $rec
}
close $fin
puts $fout "
%clean

%post
%postun
%changelog
"
  close $fout
}

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
/opt/lsst/ts_sal/VERSION
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
  copyasset $SAL_DIR/../../VERSION ts_sal_utils-$SALVERSION/opt/lsst/ts_sal/.
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

proc generaterddsrpm { version } {
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


