#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Arguments required : index logLevel"
    exit -1
fi

echo "Starting Java minimal commander"
cd /opt/lsst/ts_sal/maven/Test
mvn -Dindex=$1 -DlogLevel=$2 -Dtest=TestWithSalobjTargetTest test
