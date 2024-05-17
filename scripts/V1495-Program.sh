#!/bin/bash

if [ -z "${1}" ]
then
    echo "Usage:"
    echo "    cvUpgrade [rbf file]"
    exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PARAMFILE=$SCRIPT_DIR/CVupgrade_params_V1495_USER.txt

cvUpgrade ${1} r  -VMEbaseaddress 32100000 -modelname V1495 -rbf -link 0 -param $PARAMFILE

