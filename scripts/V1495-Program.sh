#!/bin/bash

SCRIPTNAME=$(basename ${BASH_SOURCE[0]})
usage()
{
    echo "Usage: $SCRIPTNAME [-m|--method] [-f|--file FILE]"
    echo "                        [-v|--vme VME] [-a|--arg ARGS]"
    echo "                        [-h|--help]"
    echo ""
    echo "  This command programs a CAEN V1495 via the CAEN upgrader or"
    echo "  a USB-Blaster dongle"
    echo ""
    echo "  Options:"
    echo "      -m, --method"
    echo "            Method used to program the V1495. Options are CAEN"
    echo "            or usb-blaster."
    echo "      -f, --file"
    echo "            Name of the bit file to be programmed onto the V1495."
    echo "            CAEN programming requires an 'rbf' file, usb-blaster"
    echo "            required an 'sof' file."
    echo "      -v, --vme"
    echo "            16 most significant bits of the VME address (the value"
    echo "            set by the rotary switches on the board)."
    echo "            Not required for usb-blaster programming."
    echo "      -a, --arg"
    echo "            Arguments for connection. For CAEN programming, use the"
    echo "            USB device number. For usb-blaster, run 'jtagconfig' and"
    echo "            use the text between '[' and ']' for the appropriate device"
    echo "      -h, --help"
    echo "            Print this help"
    echo ""
    #exit 0
}

for arg in "$@"; do
    shift
    case "$arg" in
	"--help")   set -- "$@" "-h" ;;
	"--arg")    set -- "$@" "-a" ;;
	"--method") set -- "$@" "-m" ;;
	"--vme")    set -- "$@" "-v" ;;
	"--file")   set -- "$@" "-f" ;;
	*)          set -- "$@" "$arg"
    esac
done

METHOD=CAEN
ARG=0
VME=3210


# Parse short options
OPTIND=1
while getopts "hm:v:f:a:" opt
do
  case "$opt" in
    "h") usage >&2; exit 0 ;;
    "a") ARG=${OPTARG} ;;
    "m") 
	if [[ ${OPTARG,,} == "caen" ]];   then
	    METHOD=CAEN
	elif [[ ${OPTARG,,} == "usb-blaster" ]]; then
	    METHOD=USB
	else
	    echo "Invalid choice. Choose 'caen' or 'usb-blaster'"
	    exit 2
	fi
	;;
    "v") VME=${OPTARG} ;;
    "f") filename="${OPTARG}" ;;
    "?") usage >&2; exit 1 ;;
  esac
done

# in case user gives only partial option (bullet-proofing)
if [ "$filename" == "" ]; then
  usage >&2
  exit 2
fi

if [[ ${METHOD} == "CAEN" ]]; then        
    if [ "${filename: -4}" != ".rbf" ]; then
	echo >&2 "Provided file must be an rbf file!"
	usage >&2
	exit 2
    fi

    BASE_ADDR=${VME}0000
    
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    PARAMFILE=$SCRIPT_DIR/CVupgrade_params_V1495_USER.txt
    cvUpgrade "${filename}" r  -VMEbaseaddress $BASE_ADDR -modelname V1495 -rbf -link $ARG -param $PARAMFILE

else
    if [ "${filename: -4}" != ".sof" ]; then
	echo >&2 "Provided file must be a sof file!"
	usage >&2
	exit 2
    fi

    tmpfile=temp.cdf
    
    dir=`dirname $filename`
    base=`basename $filename`

    echo "    /* Quartus II 64-Bit Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Full Version */" > ${tmpfile}
    echo "JedecChain;" >> ${tmpfile}
    echo "        FileRevision(JESD32A);" >> ${tmpfile}
    echo "        DefaultMfr(6E);" >> ${tmpfile}
    echo "" >> ${tmpfile}
    echo "        P ActionCode(Cfg)" >> ${tmpfile}
    echo "                Device PartName(EP1C20F400) Path(\"$dir//\") File(\"$base\") MfrSpec(OpMask(1));" >> ${tmpfile}
    echo "" >> ${tmpfile}
    echo "ChainEnd;" >> ${tmpfile}
    echo "" >> ${tmpfile}
    echo "AlteraBegin;" >> ${tmpfile}
    echo "        ChainType(JTAG);" >> ${tmpfile}
    echo "AlteraEnd;" >> ${tmpfile}

    cable="USB-Blaster [$ARG]"
    echo "quartus_pgm -c $cable ${tmpfile} --64bit"
    quartus_pgm -c "$cable" ${tmpfile} --64bit
    err=$?
    # Catch if there was any error actually programming the device
    if [ $err -ne 0 ]; then
	echo >&2 "Unexpected error"
	exit $err
    fi

    rm ${tmpfile}
    

fi



