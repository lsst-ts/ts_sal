#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Arguments required : index logLevel"
    exit -1
fi

echo "Starting CPP minimal commander"
$SAL_WORK_DIR/Test/cpp/src/sacpp_TestWithSalobjTarget $1 $2
