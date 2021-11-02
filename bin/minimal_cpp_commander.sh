#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Arguments required : index logLevel"
    exit -1
fi

echo "Starting CPP minimal commander"
/opt/lsst/ts_sal/bin/sacpp_TestWithSalobjTarget $1 $2
