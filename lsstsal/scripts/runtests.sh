#!/bin/sh

export LSST_SDK_INSTALL=$HOME/sal
export SAL_HOME=$LSST_SDK_INSTALL/lsstsal
export SAL_WORK_DIR=$LSST_SDK_INSTALL/test
export SAL_CPPFLAGS=-m64
source $SAL_HOME/salenv.sh
export JAVA_HOME=/etc/alternatives/java_sdk_openjdk
export OSPL_HOME=$LSST_SDK_INSTALL/OpenSpliceDDS/V6.4.1/HDE/x86_64.linux
export M2_HOME=$LSST_SDK_INSTALL/apache-maven-3.3.1
export OSPL_GATEWAY=$LSST_SDK_INSTALL/OpenSpliceGateway-1.0.3
export M2=$M2_HOME/bin
export LD_LIBRARY_PATH=${SAL_HOME}/lib
export TCL_LIBRARY=${SAL_HOME}/lib/tcl8.5
export TK_LIBRARY=${SAL_HOME}/lib/tk8.5
export LD_PRELOAD=/etc/alternatives/java_sdk_openjdk/jre/lib/amd64/libjsig.so
export PATH=$JAVA_HOME/bin:${M2}:${SAL_HOME}/bin:${PATH}
export PYTHONPATH=$PYTHONPATH:${SAL_WORK_DIR}/lib
export RLM_HOME=$SAL_HOME/.m2/repository/org/opensplice/gateway/rlm/9.1.3
source $OSPL_HOME/release.com
###source $OSPL_GATEWAY/release.com
mkdir -p $LSST_SDK_INSTALL/lsstsal/lib
mkdir $SAL_WORK_DIR
echo "LSST testing middleware toolset environment is configured"

yum install tk tk-devel swig java_sdk_openjdk
salgenerator

