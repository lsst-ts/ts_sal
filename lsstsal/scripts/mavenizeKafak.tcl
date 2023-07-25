#!/usr/bin/env tclsh
## \file mavenize.tcl
# \brief This contains procedures to create and build a Maven
# project for a SAL Java API
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code


#
## Documented proc \c mavenize .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Create the POM file and directory structure for a Maven project
#
proc mavenize { subsys } {
global env SAL_WORK_DIR SAL_DIR OSPL_VERSION XMLVERSION RELVERSION SALVERSION TS_SAL_DIR
  set mvnrelease [set XMLVERSION]_[set SALVERSION][set RELVERSION]
  exec mkdir -p $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/main/java/org/lsst/sal/[set subsys]
  exec mkdir -p $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/test/java
  exec mkdir -p $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/main/resources/xml
  catch {
    set all [glob $env(TS_XML_DIR)/python/lsst/ts/xml/data/sal_interfaces/$subsys/[set subsys]_*.xml]
    foreach xml $all { exec cp $xml $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/main/resources/xml/. }
  }
  exec cp $SAL_WORK_DIR/[set subsys]_Generics.xml  $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/main/resources/xml/.
  exec ln -sf $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease] $SAL_WORK_DIR/maven/[set subsys]
  set fout [open $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/pom.xml w]
  puts $fout "
<project xmlns=\"https://maven.apache.org/POM/4.0.0\" xmlns:xsi=\"https://www.w3.org/2001/XMLSchema-instance\"
  xsi:schemaLocation=\"https://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd\">
  <modelVersion>4.0.0</modelVersion>

  <groupId>org.lsst.lsst-tsvm</groupId>
  <artifactId>sal_[set subsys]</artifactId>
  <packaging>jar</packaging>
  <name>sal_[set subsys]</name>
  <version>$mvnrelease</version>

  <url>https://lsst-tsvm.lsst.org</url>
  <licenses>
   <license>
    <name>LSST GPL</name>
    <url>https://lsst-tsvm.lsst.org/LICENSE/</url>
    <distribution>repo</distribution>
    <comments>A business-friendly OSS license</comments>
   </license>
  </licenses>
  <organization>
      <name>LSST</name>
         <url>https://lsst-tsvm.lsst.org</url>
  </organization>
  <developers>
   <developer>
    <id>dmills</id>
    <name>Dave Mills</name>
    <email>dmills@lsst.org</email>
    <url>https://www.lsstcorp.org</url>
    <organization>LSST</organization>
    <roles>
      <role>developer</role>
    </roles>
    <timezone>-7</timezone>
   </developer>
  </developers>
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.source>1.8</maven.compiler.source> 
    <maven.compiler.target>1.8</maven.compiler.target>
    <kafka.version>2.2.0</kafka.version>
    <confluent.version>4.0.0</confluent.version>
    <avro.version>1.8.2</avro.version>
  </properties>
    <reporting>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-javadoc-plugin</artifactId>
                <version>2.9</version>
                <configuration>
                    <doclet>org.umlgraph.doclet.UmlGraphDoc</doclet>
                    <docletArtifact>
                        <groupId>org.umlgraph</groupId>
                        <artifactId>umlgraph</artifactId>
                        <version>5.6</version>
                    </docletArtifact>
                    <additionalparam>-views -all</additionalparam>
                    <useStandardDocletOptions>true</useStandardDocletOptions>
                </configuration>
            </plugin>
        </plugins>
    </reporting>
    <build>
     <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-plugin</artifactId>
        <version>1.11.1</version>
        <configuration>
          <source>1.8</source>
          <target>1.8</target>
        </configuration>
      </plugin>
      <plugin>
	  <groupId>org.apache.avro</groupId>
	  <artifactId>avro-maven-plugin</artifactId>
	  <version>1.9.2</version>
	  <executions>
	    <execution>
	    <phase>generate-sources</phase>
	      <goals>
	        <goal>schema</goal>
	      </goals>
	     	 <configuration>
	        <sourceDirectory>src/main/avro</sourceDirectory>
	        <outputDirectory>${project.build.directory}/generated-sources</outputDirectory>
	        <stringType>String</stringType>
	      </configuration>
	      </execution>
	  </executions>
    </plugin>
    </plugins>
    </build>
    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>3.8.1</version>
            <scope>test</scope>
        </dependency>
       <dependency>
            <groupId>org.apache.kafka</groupId>
            <artifactId>kafka-clients</artifactId>
            <version>3.1.0</version>
            <!--<scope>provided</scope> -->
        </dependency>
        <dependency>
            <groupId>org.testng</groupId>
            <artifactId>testng</artifactId>
            <version>7.5</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>1.7.5</version>
        </dependency>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-log4j12</artifactId>
            <version>1.7.5</version>
        </dependency>
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-api</artifactId>
            <version>[2.17.1,)</version>
        </dependency>
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-core</artifactId>
            <version>[2.17.1,)</version>
        </dependency>
        <dependency>
            <groupId>com.googlecode.json-simple</groupId>
            <artifactId>json-simple</artifactId>
            <version>1.1.1</version>
        </dependency>
        <dependency>
            <groupId>org.apache.avro</groupId>
            <artifactId>avro-maven-plugin</artifactId>
            <version>${avro.version}</version>
        </dependency>
        <dependency>
            <groupId>io.confluent</groupId>
            <artifactId>kafka-avro-serializer</artifactId>
            <version>${confluent.version}</version>
            <exclusions>
                <exclusion>
                    <groupId>log4j</groupId>
                    <artifactId>log4j</artifactId>
                </exclusion>
                <exclusion>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-log4j12</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.apache.kafka</groupId>
            <artifactId>kafka-clients</artifactId>
            <version>${kafka.version}</version>
        </dependency>
    </dependencies>
    <repositories>
        <repository>
            <id>ocs-maven2-public</id>
            <name>OCS Maven 2 central repository</name>
            <url>https://repo-nexus.lsst.org/nexus/content/groups/ocs-maven2/</url>
        </repository>
    </repositories>
    <distributionManagement>
        <repository>
            <id>ocs-maven2</id>
            <name>OCS Maven2 Release repository</name>
            <url>https://repo-nexus.lsst.org/nexus/content/repositories/ocs-maven2/</url>
        </repository>
        <snapshotRepository>
            <id>ocs-maven2-snapshots</id>
            <name>OCS Maven2 SNAPSHOTS repository</name>
            <url>https://repo-nexus.lsst.org/nexus/content/repositories/ocs-maven2-snapshots/</url>
        </snapshotRepository>
        <site>
            <id>ocs-maven2-site</id>
            <name>OCS Maven2 site repository</name>
            <url>dav:https://repo-nexus.lsst.org/nexus/content/sites/ocs-site/</url>
        </site>
    </distributionManagement>
  </project>
"
  close $fout
  foreach i [glob $SAL_WORK_DIR/idl-templates/validated/[set subsys]_*.idl] {
     set id [join [lrange [split [file tail [file rootname $i]] _] 1 end] _]
     set type [lindex [split $id _] 0]
     if { $type != "command" && $type != "logevent" && $type != "ackcmd"} {
       exec cp $SAL_WORK_DIR/[set subsys]_[set id]/java/src/[set subsys]_[set id]DataPublisher.java $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/test/java/.
       exec cp $SAL_WORK_DIR/[set subsys]_[set id]/java/src/[set subsys]_[set id]DataSubscriber.java $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/test/java/.
       puts stdout "Processed $id"
     }
  }
  set allj [glob $SAL_WORK_DIR/$subsys/java/src/*.java]
  foreach fj $allj {
     exec cp $fj $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/test/java/.
     puts stdout "Processed $fj"
  }
  exec cp $SAL_WORK_DIR/$subsys/java/src/org/lsst/sal/SAL_[set subsys].java $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/main/java/org/lsst/sal/.
  exec cp $SAL_WORK_DIR/$subsys/java/src/org/lsst/sal/salActor.java $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/main/java/org/lsst/sal/.
  exec cp $SAL_WORK_DIR/$subsys/java/src/org/lsst/sal/salUtils.java $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/main/java/org/lsst/sal/.
  exec cp -r $SAL_WORK_DIR/$subsys/java/$subsys $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/main/java/.
  exec mkdir -p $SAL_WORK_DIR/maven/libs
  exec cp $env(OSPL_HOME)/jar/dcpssaj.jar $SAL_WORK_DIR/maven/libs/.
  exec cp $SAL_DIR/../lib/junit.jar $SAL_WORK_DIR/maven/libs/.
  if { $subsys == "Test" } {
    exec cp $SAL_DIR/code/templates/TestWithSalobjTest.java $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/test/java/.
    exec cp $SAL_DIR/code/templates/TestWithSalobjTargetTest.java $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/test/java/.
  }
}


#
## Documented proc \c mavenunittests .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Create the Java unit tests for a Subsystem/CSC
#
proc mavenunittests { subsys } {
global env SAL_WORK_DIR SAL_DIR CMD_ALIASES CMDS SYSDIC XMLVERSION SALVERSION RELVERSION TS_SAL_DIR
   set mvnrelease [set XMLVERSION]_[set SALVERSION][set RELVERSION]
   if { [info exists SYSDIC($subsys,keyedID)] } {
       set initializer "( (short) 1)"
   } else {
       set initializer "()"
   }
  set fout [open $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/test/java/[set subsys]CommanderTest.java w]
  puts $fout "
package org.lsst.sal.junit.[set subsys];

import junit.framework.TestCase;
import [set subsys].*;
import org.lsst.sal.SAL_[set subsys];

public class [set subsys]CommanderTest extends TestCase \{

   public [set subsys]CommanderTest(String name) \{
      super(name);
   \}

"
  set cmds [split [exec grep "pragma keylist command_" $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl] \n]
  foreach i $cmds {
     set alias [join [lrange [split [lindex $i 2] _] 1 end] _]
     set revcode [getRevCode [set subsys]_command_[set alias] short]
     puts $fout "
  public void test[set subsys]Commander_[set alias]() \{
	    SAL_[set subsys] mgr = new SAL_[set subsys][set initializer];

	    // Issue command
            int cmdId=0;
            int status=0;
            int timeout=1;

  	    mgr.salCommand(\"[set subsys]_command_[set alias]\");
	    [set subsys].command_[set alias] command  = new [set subsys].command_[set alias]();

	    command.private_revCode = \"[string trim $revcode _]\";
"
     if { $alias == "setAuthList" } {
       puts $fout "
            String pname = System.getenv(\"LSST_AUTHLIST_USERS\");
            if (pname != null) \{
               command.authorizedUsers=pname;
            \}
            String cname = System.getenv(\"LSST_AUTHLIST_CSCS\");
            if (cname != null) \{
               command.nonAuthorizedCSCs=cname;
            \}
"
     }
     puts $fout "
	    cmdId = mgr.issueCommand_[set alias](command);

	    try \{Thread.sleep(1000);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}
	    status = mgr.waitForCompletion_[set alias](cmdId, timeout);

	    /* Remove the DataWriters etc */
	    mgr.salShutdown();

  \}
"
  }
  puts $fout "
\}"
  close $fout
  set fout [open $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease]/src/test/java/[set subsys]ControllerTest.java w]
  puts $fout "
package org.lsst.sal.junit.[set subsys];

import junit.framework.TestCase;
import [set subsys].*;
import org.lsst.sal.SAL_[set subsys];

public class [set subsys]ControllerTest extends TestCase \{

   public [set subsys]ControllerTest(String name) \{
      super(name);
   \}

"
  foreach i $cmds {
     set alias [lindex [split [lindex $i 2] _] 1]
     puts $fout "
public class [set subsys]Controller_[set alias]Test extends TestCase \{

   	public [set subsys]Controller_[set alias]Test(String name) \{
   	   super(name);
   	\}

	public void test[set subsys]Controller_[set alias]() \{
          short aKey   = 1;
	  int status   = SAL_[set subsys].SAL__OK;
	  int cmdId    = 0;
          int timeout  = 3;
          boolean finished=false;

	  // Initialize
	  SAL_[set subsys] cmd = new SAL_[set subsys][set initializer];

	  cmd.salProcessor(\"[set subsys]_command_[set alias]\");
	  [set subsys].command_[set alias] command = new [set subsys].command_[set alias]();
          System.out.println(\"[set subsys]_[set alias] controller ready \");

	  while (!finished) \{

	     cmdId = cmd.acceptCommand_[set alias](command);
	     if (cmdId > 0) \{
	       if (timeout > 0) \{
	          cmd.ackCommand_[set alias](cmdId, SAL_[set subsys].SAL__CMD_INPROGRESS, 0, \"Ack : OK\");
 	          try \{Thread.sleep(timeout);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}
	       \}
	       cmd.ackCommand_[set alias](cmdId, SAL_[set subsys].SAL__CMD_COMPLETE, 0, \"Done : OK\");
	     \}
             timeout = timeout-1;
             if (timeout == 0) \{
               finished = true;
             \}
 	     try \{Thread.sleep(1000);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}
	  \}

	  /* Remove the DataWriters etc */
	  cmd.salShutdown();
       \}
\}
"
  }
  puts $fout "
\}"
  close $fout
}

source $env(SAL_DIR)/activaterevcodes.tcl
source $env(SAL_DIR)/ospl_version.tcl
