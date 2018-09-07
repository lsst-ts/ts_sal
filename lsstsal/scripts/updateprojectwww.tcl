#!/usr/bin/env tclsh

if { $argv == "schema" } {
      puts stdout "Updating project website ts/sal_objects/schema"
      exec scp -r /data/gitrepo/ts_xml/schema project.lsst.org:/var/www/project/project.lsst.org/ts/sal_objects/.
} else {
  source $env(SAL_DIR)/add_system_dictionary.tcl
  foreach subsys $SYSDIC(systems) {
   if { [file exists $env(SAL_WORK_DIR)/html/[set subsys]] } {
      puts stdout "Updating project website ts/sal_objects/$subsys"
      exec scp -r $env(SAL_WORK_DIR)/html/[set subsys] project.lsst.org:/var/www/project/project.lsst.org/ts/sal_objects/.
   } else {
      puts stdout "WARNING : No documentation for $subsys"
   }
  }
}

