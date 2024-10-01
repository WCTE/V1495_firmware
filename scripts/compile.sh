#! /bin/bash

ROOTDIR=`git rev-parse --show-toplevel`
CURRENTDIR=`pwd`

cd $ROOTDIR
quartus_sh --flow compile HyperK-WCTE-V1495_top
cd $CURRENTDIR
