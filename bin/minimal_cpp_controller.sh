#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Arguments required : index logLevel"
    exit -1
fi

echo "Starting CPP minimal controller"
/opt/lsst/ts_sal/bin/sacpp_TestWithSalobj $1 $2
