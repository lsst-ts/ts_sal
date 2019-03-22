#!/bin/bash

# Utility script that will copy files over from your xml directory, then call
# the salgenerator commands to build your SAL libraries. 
XML_WORK_DIR="/home/aheyer/py3-opsim/gitdir/ts_xml" #Update to be the path to your xml repo.

set -e
if [ -z "$1" ]
  then
    echo "Must run with subsystem name (e.g. $ buildPythonTopics Test)"
    exit 1
fi

printf "\nEntering build directory, copying over xml files\n"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

cd ${SAL_WORK_DIR}
cp ${XML_WORK_DIR}/sal_interfaces/SALSubsystems.xml .
cp ${XML_WORK_DIR}/sal_interfaces/SALGenerics.xml .

if [ -s ${XML_WORK_DIR}/sal_interfaces/$1/$1_Telemetry.xml ]
then
	cp ${XML_WORK_DIR}/sal_interfaces/$1/$1_Telemetry.xml .
fi

if [ -s ${XML_WORK_DIR}/sal_interfaces/$1/$1_Commands.xml ]
then
	cp ${XML_WORK_DIR}/sal_interfaces/$1/$1_Commands.xml .
fi

if [ -s ${XML_WORK_DIR}/sal_interfaces/$1/$1_Events.xml ]
then
	cp ${XML_WORK_DIR}/sal_interfaces/$1/$1_Events.xml .
fi

printf "\nAll output redirected. Do tail -f ${SAL_WORK_DIR}/../scripts/salgenerator.out to follow output\n"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

printf "\nExecuting salgenerator $1 validate\n"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
salgenerator $1 validate &>> ${SAL_WORK_DIR}/../scripts/salgenerator.out

printf "\nExecuting salgenerator $1 html\n"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
salgenerator $1 html &>> ${SAL_WORK_DIR}/../scripts/salgenerator.out

printf "\nExecuting salgenerator $1 sal cpp\n"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
salgenerator $1 sal java &>> ${SAL_WORK_DIR}/../scripts/salgenerator.out

printf "\nExecuting salgenerator $1 maven\n"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
salgenerator $1 maven &>> ${SAL_WORK_DIR}/../scripts/salgenerator.out

printf "\nDone building libraries for $1 from %s\n\n" "$SAL_WORK_DIR"
