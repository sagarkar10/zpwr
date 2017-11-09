#!/usr/bin/env bash
#{{{                    MARK:Header
#**************************************************************
#####   Author: JACOBMENKE
#####   Date: Wed Nov  8 23:57:19 EST 2017
#####   Purpose: bash script to 
#####   Notes: 
#}}}***********************************************************

trap 'rm "$file"' INT

(( $# < 2 )) && echo "Need a regex and filter.." >&2 && exit 1


function usage ()
{
    echo -e "\e[34mUsage :  $0 [options] [--]

    Options:
    -i|inverse    set filter to after regex
    -h|help       Display this message
    -v|version    Display script version\e[0m"

}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

__ScriptVersion=1.0.0

while getopts "hvi" opt
do
  case $opt in

    h|help     )  usage; exit 0   ;;

    v|version  )  echo "$0 -- Version $__ScriptVersion"; exit 0   ;;

    i|inverse )  inverse=true ;;

    * )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))

file=/tmp/temp$$
regex="$1"
filter="$2"
cat > "$file"
output=`cat /tmp/temp$$` 
delim=$(echo "$output" | grep -n -- "$regex" | cut -d: -f1)

[[ $delim -ne 0 ]] && {

    if [[ -z "$inverse" ]]; then
        sed -n "1,$delim"p "$file" | "$filter"
        ((delim++))
        sed -n "$delim,$"p "$file"
    else
        sed -n "1,$delim"p "$file"
        ((delim++))
        sed -n "$delim,$"p "$file" | "$filter"
    fi
} || sed -n '1,$p' "$file"

rm "$file"
