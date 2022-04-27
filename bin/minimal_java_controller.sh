#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Arguments required : index logLevel"
    exit -1
fi

echo "Starting Java minimal controller"
cd $SAL_WORK_DIR/maven/Test
mvn --no-transfer-progress -Dindex=$1 -DlogLevel=$2 -Dtest=TestWithSalobjTest test
