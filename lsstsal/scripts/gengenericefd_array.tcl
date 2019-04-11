#
#  yum install tk_devel mariadb mariadb-devel mariadb-libs mariadb-server
#
#  systemctl disable firewalld
#  disable selinux in /etc/selinux/config
#
#  set SAL_WORK_DIR $env(SAL_WORK_DIR)
#  creategenericefds camera
#
#  Remember to delete anonymous users
#  Give efduser all permissions
#  .my.cnf for auto pass
#
#  after schema change, run validate, sal html, and sal cpp steps
#
#  rules : field names exclusions : dec limit
#
#  Using mysqltcl interface:
#
#  load /usr/lib64/tcl8.5/mysqltcl-3.052/libmysqltcl3.052.so
#  set efd [mysqlconnect -host localhost -user efduser -password lssttest -db EFD]
#  mysqlinfo $efd tables
#  set x [mysqlsel $efd "SELECT * FROM archiver_commandLog" -list]
#  set y [mysqlsel $efd "SELECT * FROM archiver_commandLog ORDER BY date_time LIMIT 10" -list]
#  mysqlclose $efd
# 
#   mysqlsel $db {select lname, fname, area, phone from friends order by lname, fname}
#
#       mysqlmap $db {ln fn - phone} {    #behaves like foreach over queried records
#
#               if {$phone == {}} continue
#
#               puts [format "%16s %-8s %s" $ln $fn $phone]
#
#       }
#
#  sudo systemctl stop mariadb
#
#

proc writetoefd { topic } {
global SQLREC TYPEFORMAT
  set flds [split $SQLREC($topic) ,]
  set record "sprintf(thequery,\"INSERT INTO [set topic] VALUES (NOW(6)"
  set rformat ""
  set rvars ""
  set ldata "myData_[join [lrange [split $topic _] 1 end] _]"
  while { [llength $flds] != 0 } {
      set i [lindex $flds 0]
      set flds [lrange $flds 1 end]
      set type [lindex [split $i .] 0]
      set name [lindex [split $i .] 1]
      set isarray [lindex [split $i .] 2]
      if { $type == "char" } {
             set name "[set name].m_ptr"
             set isarray ""
      } 
###puts stdout "$i $type $name $isarray"
      if { $isarray == "" } {
              set value "[set ldata]\[iloop\].[set name]"
              set vform $TYPEFORMAT($type)
              if { $type == "char" } {
                 set vform "'$TYPEFORMAT($type)'"
              }
      } else {
         set value "[set ldata]\[iloop\].[set name]\[0\]"
             set vform "$TYPEFORMAT($type)"
         if { $isarray > 32 } {
             set vform "'$TYPEFORMAT($type)"
             set j 1
             while { $j <= [expr $isarray -1] } {
                set value "$value,[set ldata]\[iloop\].[set name]\[$j\]"
                set vform "$vform $TYPEFORMAT($type)"
                incr j 1
             }
             set value [string trim $value ","]
             set vform "$vform'"
         } else {
             set vform "$TYPEFORMAT($type)"
             set j 1
             while { $j <= [expr $isarray -1] } {
                set value "$value,[set ldata]\[iloop\].[set name]\[$j\]"
                set vform "$vform, $TYPEFORMAT($type)"
                incr j 1
             }
             set value [string trim $value ","]
         }
      }
      set rvars "$rvars , $value"
      set rformat "$rformat , $vform"
###puts stdout $rvars
###puts stdout $rformat
  }
  set record "$record [set rformat])\" $rvars );"
  return $record
}


proc readfromefd { topic irow } {
global SQLREC TYPEFORMAT
  set flds [split $SQLREC($topic) ,]
  set record "sscanf(row\[irow-1\],\""
  set rformat ""
  set rvars ""
  set ldata "myData_[join [lrange [split $topic _] 1 end] _]"
  while { [llength $flds] != 0 } {
      set i [lindex $flds 0]
      set flds [lrange $flds 1 end]
      set type [lindex [split $i .] 0]
      set name [lindex [split $i .] 1]
      set isarray [lindex [split $i .] 2]
      if { $type == "char" } {
             set name "[set name].m_ptr"
             set isarray ""
      } 
###puts stdout "$i $type $name $isarray"
      if { $isarray == "" } {
              set value "[set ldata]->[set name]"
              set vform $TYPEFORMAT($type)
              if { $type == "char" } {
                 set vform "'$TYPEFORMAT($type)'"
              }
      } else {
             set value "[set ldata]->[set name]\[0\]"
             set vform "$TYPEFORMAT($type)"
             set j 1
             while { $j <= [expr $isarray -1] } {
                set value "$value,[set ldata]->[set name]\[$j\]"
                set vform "$vform, $TYPEFORMAT($type)"
                incr j 1
             }
             set value [string trim $value ","]
      }
      set rvars "$rvars , $value"
      set rformat "$rformat , $vform"
###puts stdout $rvars
###puts stdout $rformat
  }
  set record "$record [set rformat]\", $rvars );"
  return $record
}


proc genSALefdqueries { base } {
global SAL_WORK_DIR
   set fout [open $SAL_WORK_DIR/[set base]/cpp/src/SAL_[set base]_efdqueries.cpp w]
   set idlfile $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set base].idl
   set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
   foreach j $ptypes {
     set topic [lindex $j 2]
     set type [lindex [split $topic _] 0]
     if { $topic != "ackcmd" && $topic != "command" && $topic != "logevent"} {
        genqueryefd $fout $base $topic last
     }
   }
   close $fout
}


proc genericefdfragment { fout base ttype ctype } {
global ACTORTYPE SAL_WORK_DIR BLACKLIST SYSDIC
   if { $ctype == "connect" } {
       puts $fout "
  MYSQL *con = mysql_init(NULL);
  if (con == NULL) \{
      fprintf(stderr,\"MYSQL init error %s\\n\",mysql_error(con));
      exit(1);
  \}

  char *efdb_host = getenv(\"LSST_EFD_HOST\");
  if (efdb_host == NULL) \{
      fprintf(stderr,\"MYSQL : LSST_EFD_HOST not defined\\n\");
      exit(1);
  \}

  char *efdb_log = getenv(\"LSST_EFD_SYSLOG\");
  if (efdb_log == NULL) \{
     isyslog = 0;
  \}

  char *efdb_delay = getenv(\"LSST_EFD_CYCLEDELAY\");
  if (efdb_delay != NULL) \{
     sscanf(efdb_delay,\"%d\",&idelay);
  \}

  if (mysql_real_connect(con, efdb_host, \"efduser\" , \"lssttest\", \"EFD\", 0 , NULL, 0) == NULL) \{
      fprintf(stderr,\"MYSQL Failed to connect %s\\n\",mysql_error(con));
      exit(1);
  \}
  mysql_autocommit(con,0);
  cout << \"EFD client for [set base] ready\" << endl;
"
       return 
   }
   set idlfile $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set base].idl
   set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
   foreach j $ptypes {
     set topic [lindex $j 2]
     set revcode [getRevCode [set base]_[set topic] short]
     set type [lindex [split $topic _] 0]
     set doit 0
     set trail  [string range $topic [expr [string bytelength $topic]-9] end]
     set trail2 [string range $topic [expr [string bytelength $topic]-15] end]
     if { $ttype == "command" && $type == "command" || $topic == "ackcmd"} {set doit 1}
     if { $ttype == "logevent" && $type == "logevent" && $topic != "ackcmd"} {set doit 1}
     if { $ttype == "telemetry" && $type != "command" && $type != "logevent" && $topic != "ackcmd" } {set doit 1}
     if { $trail == "Heartbeat" || $trail2 == "InternalCommand" } {set doit 0}
     if { $ttype != "command" && $topic == "ackcmd" } {set doit 0}
     if { [info exists BLACKLIST([set topic])] } {set doit 0}
     if { $doit } {
#      if { $ctype == "init" } {
#       puts $fout "  [set base]::[set topic][set revcode]Seq myData_[set topic][set revcode];
#  SampleInfoSeq_var [set topic][set revcode]_info = new SampleInfoSeq;"
#      }
      if { $ctype == "subscriber" } {
       puts $fout "  mgr.salTelemetrySub(\"[set base]_[set topic]\");
  actorIdx = SAL__[set base]_[set topic]_ACTOR;
  DataReader_var [set topic][set revcode]_dreader = mgr.getReader(actorIdx);
  [set base]::[set topic][set revcode]DataReader_var [set topic]_SALReader = [set base]::[set topic][set revcode]DataReader::_narrow([set topic][set revcode]_dreader.in());
  mgr.checkHandle([set topic]_SALReader.in(), \"[set base]::[set topic][set revcode]DataReader::_narrow\");
"
      }
      if { $ctype == "getsamples" } {
        if { $topic != "command" && $topic != "logevent" } {
        puts $fout "  
       [set base]::[set topic][set revcode]Seq myData_[set topic];
       SampleInfoSeq_var [set topic]_info = new SampleInfoSeq;
       status = [set topic]_SALReader->take(myData_[set topic], [set topic]_info, 100, ANY_SAMPLE_STATE, ANY_VIEW_STATE, ANY_INSTANCE_STATE);
       mgr.checkStatus(status,\"[set base]::[set topic][set revcode]DataReader::take\");
       numsamp = myData_[set topic].length();
       if (status == SAL__OK && numsamp > 0) \{
        if (igotdata == 0) \{
           mstatus = mysql_query(con,\"START TRANSACTION\");
           igotdata = 1;
        \}
        printf(\"%lf [set topic] %d samples received\\n\",mgr.getCurrentTime(), numsamp);
        for (iloop=0;iloop<numsamp;iloop++) \{
         if (myData_[set topic]\[iloop\].private_origin != 0) \{
          myData_[set topic]\[iloop\].private_rcvStamp = mgr.getCurrentTime();"
       if { $topic != "ackcmd" } {
         puts $fout "
          [writetoefd [set base]_[set topic]]
          mstatus = mysql_query(con,thequery);
//          cout << thequery << endl;
          if (mstatus) \{
             fprintf(stderr,\"MYSQL INSERT ERROR : %d : %s\\n\",mstatus,thequery);
          \}
          if (myData_[set topic]\[iloop\].private_origin > 0) \{
            if (isyslog > 0) \{
               syslog(NULL,\"%s\",thequery);
            \}
          \}"
         }
###         puts $fout "       \}"
           if { $base != "EFD" } {
             checkLFO $fout $topic
           }
         }
         if { $type == "command" && $ttype == "command" && $topic != "ackcmd" } {
           set alias "'[join [lrange [split $topic _] 1 end] _]'"
           if { $alias != "''" } {
            if { [info exists SYSDIC($base,keyedID)] } {
              set alias "'[join [lrange [split $topic _] 1 end] _] ID=%d'"
               puts $fout "
          sprintf(thequery,\"INSERT INTO [set base]_commandLog VALUES (NOW(6),'%s', %lf, %d, $alias, 0, 0 )\" , 
                    myData_[set topic]\[iloop\].private_revCode.m_ptr, myData_[set topic]\[iloop\].private_sndStamp, myData_[set topic]\[iloop\].private_seqNum,myData_[set topic]\[iloop\].[set base]ID);"
            } else {
               puts $fout "
          sprintf(thequery,\"INSERT INTO [set base]_commandLog VALUES (NOW(6),'%s', %lf, %d, $alias, 0, 0 )\" , 
                    myData_[set topic]\[iloop\].private_revCode.m_ptr, myData_[set topic]\[iloop\].private_sndStamp, myData_[set topic]\[iloop\].private_seqNum);"
            }
            puts $fout "
          mstatus = mysql_query(con,thequery);
//          cout << thequery << endl;
          if (mstatus) \{
             fprintf(stderr,\"MYSQL INSERT ERROR : %d : %s\\n\",mstatus,thequery);
          \}"
          }
         }
         if { $ttype == "command" && $topic == "ackcmd" } {
           set alias "'ackcmd'"
            if { [info exists SYSDIC($base,keyedID)] } {
              set alias "'ackcmd ID=%d'"
              puts $fout "
          sprintf(thequery,\"INSERT INTO [set base]_commandLog VALUES (NOW(6), '%s', %lf, %d, $alias, %d, %d )\" , 
                    myData_[set topic]\[iloop\].private_revCode.m_ptr, myData_[set topic]\[iloop\].private_sndStamp, myData_[set topic]\[iloop\].private_seqNum,myData_[set topic]\[iloop\].[set base]ID,myData_[set topic]\[iloop\].ack, myData_[set topic]\[iloop\].error);"
            } else {
              puts $fout "
          sprintf(thequery,\"INSERT INTO [set base]_commandLog VALUES (NOW(6), '%s', %lf, %d, $alias, %d, %d )\" , 
                    myData_[set topic]\[iloop\].private_revCode.m_ptr, myData_[set topic]\[iloop\].private_sndStamp, myData_[set topic]\[iloop\].private_seqNum,myData_[set topic]\[iloop\].ack,myData_[set topic]\[iloop\].error);"
            }
            puts $fout "
          mstatus = mysql_query(con,thequery);
//          cout << thequery << endl;
          if (mstatus) \{
             fprintf(stderr,\"MYSQL INSERT ERROR : %d : %s\\n\",mstatus,thequery);
          \}"
         }
         if { $topic != "command" && $topic != "logevent" } {
           puts $fout "         \}
        \}
       \}
       status = [set topic]_SALReader->return_loan(myData_[set topic], [set topic]_info);
"
         }
      }
    }
   }
}


proc genqueryefd { fout base topic key } {
   if { $key == "last" } {
      puts $fout "
#include <sys/time.h>
#include <time.h>
#include \"SAL_[set base].h\"
using namespace [set base];

int SAL_[set base]::getLastSample_[set topic] ([set base]_[set topic]C *mydata) \{

      int num_fields=0;
      int mstatus=0;
      char *thequery = (char *) malloc(sizeof(char)*4000);
      MYSQL_RES *result;
      MYSQL_ROW *row;

      if ( getSample_[set topic] ([set base]_[set topic]C *mydata) == SAL__NO_UPDATES) \{
        sprintf(thequery,\"SELECT * FROM [set base]_[set topic] LIMIT 1;\");
        mstatus = mysql_query(efdConnection,thequery);
        if (mstatus != 0) \{
             return SAL__NO_UPDATES;
        \}
        result = mysql_store_result(efdConnection);
        int num_fields = mysql_num_fields(result);
        row = mysql_fetch_row(result);
        [readfromefd [set base]_[set topic] 1]
"
      puts $fout "
        mysql_free_result(result);
      \}
      return SAL__OK;
\}
"
   }
}



proc checkLFO { fout topic } {
  set alias [join [lrange [split $topic _] 1 end] _]
  if { $alias == "largeFileObjectAvailable" } {
     set alias "'[join [lrange [split $topic _] 1 end] _]'"
     puts $fout "
       if (status == SAL__OK && numsamp > 0) \{
           printf(\"EFD TBD : Large File Object Announcement Event $topic received\\n\");
           sprintf(thequery,\"process_LFO_logevent  %d '%s' '%s' '%s' '%s' %f '%s'\"  ,  myData_[set topic]\[iloop\].byteSize , myData_[set topic]\[iloop\].checkSum.m_ptr , myData_[set topic]\[iloop\].generator.m_ptr , myData_[set topic]\[iloop\].mimeType.m_ptr , myData_[set topic]\[iloop\].url.m_ptr , myData_[set topic]\[iloop\].version, myData_[set topic]\[iloop\].id.m_ptr);
          mstatus = system(thequery);
          if (mstatus < 0) \{
             fprintf(stderr,\"LFO Processor ERROR : %d\\n\",mstatus);
          \}
      \}
"
  }
}


proc genefdwritermake { base } {
global SAL_DIR SAL_WORK_DIR env
  set frep [open /tmp/sreplace5.sal w]
  puts $frep "#!/bin/sh"
  exec touch $SAL_WORK_DIR/[set base]/cpp/src/.depend.Makefile.sacpp_SALData_efdwriter
  exec cp  $SAL_DIR/code/templates/Makefile.sacpp_SAL_efdwriter.template $SAL_WORK_DIR/[set base]/cpp/src/Makefile.sacpp_[set base]_efdwriter
  puts $frep "perl -pi -w -e 's/_SAL_/_[set base]_/g;' $SAL_WORK_DIR/[set base]/cpp/src/Makefile.sacpp_[set base]_efdwriter"
  puts $frep "perl -pi -w -e 's/SALSubsys/[set base]/g;' $SAL_WORK_DIR/[set base]/cpp/src/Makefile.sacpp_[set base]_efdwriter"
  puts $frep "perl -pi -w -e 's/SALData/[set base]/g;' $SAL_WORK_DIR/[set base]/cpp/src/Makefile.sacpp_[set base]_efdwriter"
  close $frep
  exec chmod 755 /tmp/sreplace5.sal
  catch { set result [exec /tmp/sreplace5.sal] } bad
  if { $bad != "" } {puts stdout $bad}
}


proc gentelemetryreader { base } {
global SAL_WORK_DIR SYSDIC
   set fout [open $SAL_WORK_DIR/[set base]/cpp/src/sacpp_[set base]_telemetry_efdwriter.cpp w]
   puts $fout "
/*
 * This file contains the implementation for the [set base] generic Telemetry reader.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include <stdlib.h>
#include <mysql.h>
#include <syslog.h>
#include \"SAL_[set base].h\"
#include \"SAL_actors.h\"
#include \"ccpp_sal_[set base].h\"
#include \"os.h\"
using namespace DDS;
using namespace [set base];

/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  OS_API_EXPORT
  int test_[set base]_telemetry_efdwriter();
\}

int test_[set base]_telemetry_efdwriter()
\{   

  char *thequery = (char *) malloc(sizeof(char)*1000000);
  SAL_[set base] mgr = SAL_[set base]();
"
  genericefdfragment $fout $base telemetry init
  puts $fout "
  int numsamp = 0;
  int actorIdx = 0;
  int isyslog = 1;
  int idelay = 10000;
  int iloop = 0;
  int igotdata = 0;
  int mstatus = 0;
  int status = 0;"
  genericefdfragment $fout $base telemetry subscriber
  genericefdfragment $fout $base telemetry connect
  puts $fout "
       os_time delay_us = \{ 0, idelay \};
       while (1) \{
        igotdata = 0;"
  genericefdfragment $fout $base telemetry getsamples
   puts $fout "
        if (igotdata) mstatus = mysql_query(con,\"COMMIT\");
           os_nanoSleep(delay_us);
      \}

  /* Remove the DataWriters etc */
      mysql_close(con);
      mgr.salShutdown();

      return 0;
\}

int main (int argc, char **argv[])
\{
  return test_[set base]_telemetry_efdwriter();
\}
"
   close $fout
}



proc geneventreader { base } {
global SAL_WORK_DIR SYSDIC
   set fout [open $SAL_WORK_DIR/[set base]/cpp/src/sacpp_[set base]_event_efdwriter.cpp w]
   puts $fout "
/*
 * This file contains the implementation for the [set base] generic event efdwriter.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include <stdlib.h>
#include <mysql.h>
#include <syslog.h>
#include \"SAL_[set base].h\"
#include \"SAL_actors.h\"
#include \"ccpp_sal_[set base].h\"
#include \"os.h\"
using namespace DDS;
using namespace [set base];

/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  OS_API_EXPORT
  int test_[set base]_event_efdwriter();
\}

int test_[set base]_event_efdwriter()
\{

  char *thequery = (char *) malloc(sizeof(char)*1000000);
  SAL_[set base] mgr = SAL_[set base]();
"
  genericefdfragment $fout $base logevent init

  puts $fout "
  int numsamp = 0;
  int actorIdx = 0;
  int isyslog = 1;
  int iloop = 0;
  int idelay = 10000;
  int mstatus = 0;
  int igotdata = 0;
  int status=0;"
  genericefdfragment $fout $base logevent subscriber
  genericefdfragment $fout $base logevent connect
  puts $fout "
  os_time delay_us = \{ 0, idelay \};
  while (1) \{
     igotdata = 0;"
  genericefdfragment $fout $base logevent getsamples
   puts $fout "
     if (igotdata) mstatus = mysql_query(con,\"COMMIT\");
     os_nanoSleep(delay_us);
  \}

  /* Remove the DataWriters etc */
  mysql_close(con);
  mgr.salShutdown();

  return 0;
\}

int main (int argc, char **argv[])
\{
  return test_[set base]_event_efdwriter();
\}
"
   close $fout
}


proc gencommandreader { base } {
global SAL_WORK_DIR SYSDIC
   set fout [open $SAL_WORK_DIR/[set base]/cpp/src/sacpp_[set base]_command_efdwriter.cpp w]
   puts $fout "
/*
 * This file contains the implementation for the [set base] generic command efdwriter.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include <stdlib.h>
#include <mysql.h>
#include <syslog.h>
#include \"SAL_[set base].h\"
#include \"SAL_actors.h\"
#include \"ccpp_sal_[set base].h\"
#include \"os.h\"
using namespace DDS;
using namespace [set base];

/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  OS_API_EXPORT
  int test_[set base]_command_efdwriter();
\}

int test_[set base]_command_efdwriter()
\{ 

  char *thequery = (char *)malloc(sizeof(char)*1000000);
  SAL_[set base] mgr = SAL_[set base]();
"
  genericefdfragment $fout $base command init
  puts $fout "
  int numsamp = 0;
  int actorIdx = 0;
  int isyslog = 1;
  int iloop = 0;
  int idelay = 10000;
  int mstatus = 0;
  int igotdata = 0;
  int status=0;"
  genericefdfragment $fout $base command subscriber
  genericefdfragment $fout $base command connect
  puts $fout "
  os_time delay_us = \{ 0, idelay \};
  while (1) \{
     igotdata = 0;"
  genericefdfragment $fout $base command getsamples
   puts $fout "
     if (igotdata) mstatus = mysql_query(con,\"COMMIT\");
     os_nanoSleep(delay_us);
  \}

  /* Remove the DataWriters etc */
  mysql_close(con);
  mgr.salShutdown();

  return 0;
\}

int main (int argc, char **argv[])
\{
  return test_[set base]_command_efdwriter();
\}
"
   close $fout
}


proc updateefdtables { } {
global SAL_WORK_DIR SYSDIC BLACKLIST
   cd $SAL_WORK_DIR
   foreach i [array names BLACKLIST] {
     catch {
      set blk [glob sql/*$i*]
      foreach blkn $blk {
        exec rm $blkn
      }
     }
   }
   foreach subsys $SYSDIC(systems) {
      if { [file exists $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl] } {
        puts stdout "Updating schema for $subsys"
        makesummarytables $subsys
        set all [glob sql/[set subsys]_*.sqldef]
        set cmd "exec cat $all > sql/create-tables-[set subsys]"
        set docat [eval $cmd]
##        exec mysql EFD < sql/create-tables-[set base]
      }
   }
}


proc createdatabase { dbname } {
   if { [file exists $env(HOME)/.my.cnf] == 0 } {
      set open [$env(HOME)/.my.cnf w]
      puts $fout "
[mysql]
user=efduser
password=lssttest
"
      close $fout
      chmod 600 $env(HOME)/.my.cnf
   }
   set fout [open /tmp/cdb.sql w]
   puts $fout "CREATE DATABASE EFD;"
   close $fout
   exec mysql < /tmp/cdb.sql
}

proc updateefdschema { } {
global SYSDIC SAL_WORK_DIR
   set bad 0
   foreach subsys $SYSDIC(systems) {
      if { [file exists $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl] } {
        puts stdout "Updating schema for $subsys"
        set bad [catch {genefdwriters $subsys} res]
        if { $bad } {puts stdout $res}
      } else {
        puts stdout "WARNING : No IDL for $subsys available"
      }
   }
}

proc updateSALqueries { } {
global SYSDIC SAL_WORK_DIR
   set bad 0
   foreach subsys $SYSDIC(systems) {
      if { [file exists $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl] } {
        puts stdout "Updating SAL queries for $subsys"
        set bad [catch {genSALefdqueries $subsys} res]
        if { $bad } {puts stdout $res}
      } else {
        puts stdout "WARNING : No IDL for $subsys available"
      }
   }
}


proc makesummarytables { subsys } {
global SAL_WORK_DIR
   set fout [open $SAL_WORK_DIR/sql/[set subsys]_logeventLFO.sqldef w]
   puts $fout "DROP TABLE IF EXISTS [set subsys]_logeventLFO;
CREATE TABLE [set subsys]_logeventLFO (
  date_time DATETIME(6),
  private_revCode char(8),
  private_sndStamp double precision,
  private_seqNum int,
  url varchar(128),
  generator varchar(128),
  version varchar(32),
  checkSum char(32),
  mimeType varchar(64),
  id varchar(32),
  byteSize long,
  PRIMARY KEY (date_time)
);
"
   close $fout
   set fout [open $SAL_WORK_DIR/sql/[set subsys]_commandLog.sqldef w]
   puts $fout "DROP TABLE IF EXISTS [set subsys]_commandLog;
CREATE TABLE [set subsys]_commandLog (
  date_time DATETIME(6),
  private_revCode char(8),
  private_sndStamp double precision,
  private_seqNum int,
  name varchar(128),
  ack int,
  error int,
  PRIMARY KEY (date_time)
);
"
   close $fout
}


proc genefdwriters { base } {
global SQLREC SAL_WORK_DIR
   set SQLREC([set base]_ackcmd)  "char.private_revCode,double.private_sndStamp,double.private_rcvStamp,int.private_seqNum,int.private_origin,int.private_host,int.ack,int.error,char.result"
   set SQLREC([set base]_commandLog)  "char.private_revCode,double.private_sndStamp,int.private_seqNum,char.name,int.ack,int.error"
####   set SQLREC([set base]_logevent_largeFileObjectAvailable)  "char.private_revCode,double.private_sndStamp,int.private_seqNum,char.url,char.generator,float.version,char.checkSum,char.mimeType,char.id,int.byteSize"
   makesummarytables  $base
   gentelemetryreader $base
   gencommandreader   $base
   geneventreader     $base
   genefdwritermake   $base
   updateRevCodes     $base
   cd $SAL_WORK_DIR/[set base]/cpp/src
   exec make -f Makefile.sacpp_[set base]_efdwriter
}

proc startefdwriters { subsys } { 
global SAL_WORK_DIR
   foreach s $subsys {
      if { [file exists $SAL_WORK_DIR/[set s]/cpp/src/sacpp_[set s]_telemetry_efdwriter] == 0 } {
         puts sdout "ERROR : No telemetry writer available for $s"
         exit
      }
      if { [file exists $SAL_WORK_DIR/[set s]/cpp/src/sacpp_[set s]_command_efdwriter] == 0 } {
         puts sdout "ERROR : No command writer available for $s"
         exit
      }
      if { [file exists $SAL_WORK_DIR/[set s]/cpp/src/sacpp_[set s]_telemetry_efdwriter] == 0 } {
         puts sdout "ERROR : No event writer available for $s"
         exit
      }
      set tid($s) [exec $SAL_WORK_DIR/[set s]/cpp/src/sacpp_[set s]_telemetry_efdwriter >& efd_[set s]_telemetry_[clock seconds].log &]
      set cid($s) [exec $SAL_WORK_DIR/[set s]/cpp/src/sacpp_[set s]_command_efdwriter >& efd_[set s]_command_[clock seconds].log &]
      set eid($s) [exec $SAL_WORK_DIR/[set s]/cpp/src/sacpp_[set s]_event_efdwriter >& efd_[set s]_event_[clock seconds].log &]
   }
   while { 1 } {
     foreach s $subsys {
       set bad [catch {exec ps -F --pid $tid($s)} res]
       if { $bad } {
          set tid($s) [exec $SAL_WORK_DIR/[set s]/cpp/src/sacpp_[set s]_telemetry_efdwriter >& efd_[set s]_telemetry_[clock seconds].log &]
       }
       set bad [catch {exec ps -F --pid $cid($s)} res]
       if { $bad } {
          set cid($s) [exec $SAL_WORK_DIR/[set s]/cpp/src/sacpp_[set s]_command_efdwriter >& efd_[set s]_command_[clock seconds].log &]
       }
       set bad [catch {exec ps -F --pid $eid($s)} res]
       if { $bad } {
          set eid($s) [exec $SAL_WORK_DIR/[set s]/cpp/src/sacpp_[set s]_event_efdwriter >& efd_[set s]_event_[clock seconds].log &]
       }
     }
   }
}


set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)

set recdef [glob $SAL_WORK_DIR/sql/*.sqlwrt]
foreach i $recdef { 
   source $i
}

set BLACKLIST(Cluster_Encoder) 1
set BLACKLIST(sequencePropConfig) 1
set BLACKLIST(blockPusher) 1
set BLACKLIST(Surface) 1


source $SAL_DIR/add_system_dictionary.tcl
source $SAL_WORK_DIR/.salwork/revCodes.tcl
source $SAL_DIR/managetypes.tcl
source $SAL_DIR/activaterevcodes.tcl


