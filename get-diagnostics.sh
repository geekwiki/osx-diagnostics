#!/bin/bash

. ./functions.sh

clear 

outdir='./diagnostics'
runtimestamp=$(getdate epoch)
generalLog="./diagnostics-${runtimestamp}.log"

mkdir -vp $outdir/{system/{stats,processes,files,profile},network}

# Crate the general diagnostics outlog log
diaglog "Diagnostics started by the user $(whoami)"
#echo "Diagnostics started at $(date) by the user $(whoami)" > "${generalLog}"

checkbin system_profiler

if [[ $? == 0 ]]
then
  # ----------------------------------------
  # SYSTEM PROFILER
  spDataTypeList="$(system_profiler -listDataTypes | sed 1d)"
  spDataTypeCount=$(rlc "${spDataTypeList}")

  echo -e "Getting System Profile Data Content (${spDataTypeCount} types)\n"

  sysprofileList="system_profiler.list"
  printformat="%-30s %-30s\n"

  # Create the system_profile output text file
  date > "${sysprofileList}"
  echo '' >> "${sysprofileList}"
  printf "${printformat}" "DATATYPE" "LINES" >> "${sysprofileList}"
  printf "${printformat}" "--------------------------" "------" >> "${sysprofileList}"

  # Header output for the data going to STDOUT
  printf "\t%-10s %-30s %-10s\n" "STATUS" "DATA TYPE" "RESULT" 
  printf "\t%-10s %-30s %-10s\n" "-------" "----------" "-------" 

  i=0
  echo "${spDataTypeList}"| while read dataType
  do
    i=$((i+1))
    outFile="${outdir}/system/profile/$dataType.txt"

    printf "\t%-10s %-30s" "[$i/$spDataTypeCount]" "${dataType}"

    system_profiler -detailLevel full $dataType > "${outFile}"

    res=$?

    if [[ $res != 0 ]]
    then
      printf " %-10s %-30s\n" "Failed" "${res}"
    else
      lines=$(cat "${outFile}" | rlc)
      disp=$([[ $lines == 0 ]] && echo "-Empty-" || echo "${lines} lines")
      printf " %-10s %-30s\n" "Success" "${disp}"

      printf "${printformat}" "${dataType}" "${lines}" >> "${sysprofileList}"
    fi
  done
else
  echo "No 'system_profiler' binary found in PATH ${PATH}" >>  "${generalLog}"
fi
