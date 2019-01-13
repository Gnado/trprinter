#! /bin/bash

#PARAMETERS
VERSION="0.1"
WORKDIR="~/tmp"


#CONFIG


#Load config printer
. trprint.cfg

#Printer command
PC_TP='\x12\x54' #Printing test page                - DC2 T [Name]
PC_SC='\x1B\x37' #Setting Control Parameter Command - ESC 7 n1 n2 n3


version()
{
  echo "TRPrinter version: $VERSION"
}

usage()
{
    echo "Usage: trprint [[[-f file ] [-i]] | [-h]]"
    echo "-v, --version             trprint version"
    echo "-f, --file                file for print"
    echo "-u, --url                 url webpage for print"
    echo "-s, --send                send text to printer"
    echo "-i, --init                initialization printer"
    echo "-t, --test                printing test page"
}


init()
{
  echo "Initialization printer"

  echo "uart_port        : $uart_port"
  echo "baud_rate        : $baud_rate"
  echo "heating_dots     : $heating_dots"
  echo "heating_time     : $heating_time"
  echo "heating_interval : $heating_interval"
  echo ""

  PC_SEND="$PC_SC"
  PC_SEND+="\x"
  PC_SEND+=`echo "obase=16; $heating_dots" | bc`
  PC_SEND+="\x"
  PC_SEND+=`echo "obase=16; $heating_time" | bc`
  PC_SEND+="\x"
  PC_SEND+=`echo "obase=16; $heating_interval" | bc`

  # echo -n -e $PC_SEND
  # echo '\n'
  #ESC 7 7 160 40
  # echo -n -e '\x1B\x37\x7\xC8\x28'
  # echo '\n'
  echo -n -e "$PC_SEND" > /dev/$uart

}

test()
{
  echo "Print test page"
  echo -n -e "$PC_TP" > /dev/$uart
}

print()
{
  if [ ! -z "$SEND" ]; then
    echo "Send to printer '$SEND'"
    echo "$SEND" > /dev/$uart
    exit 0
  fi

  if [ ! -z "$URL" ]; then
  	echo "Save page from url '$URL'"
    FILE="$WORKDIR/tmpfile/webpage.png"
  fi

  if [ ! -z "$FILE" ]; then
    echo "Print file: $FILE"
    if [ ! -f $FILE ]; then
        echo "File not found!"
        exit 1
    fi
    # lp -o media=$lp_media $FILE
    eval $cmd_printfile $FILE
    exit 0
  fi
}

cancel(){
  echo "Cancels a print job"
  eval "cancel"
}

while [ "$1" != "" ]; do
    case $1 in
      -v | --version )    version
                          exit
                          ;;
      -h | --help )       usage
                          exit
                          ;;
      -f | --file )       shift
                          FILE=$1
                          ;;
      -u | --url )        shift
                          URL=$1
                          ;;
      -s | --send )       shift
                          SEND=$1
                          ;;
      -i | --init )       init
                          exit
                          ;;
      -t | --test )       test
                          exit
                          ;;
      -c | --cancel )     cancel
                          exit
                          ;;
      * )                 usage
                          exit 1
    esac
    shift
done
print

echo "Error bash"
