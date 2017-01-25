#!/bin/bash

# Trim lines from string
#
# Examples
#   $ echo "    Hello    World   "
#       Hello    World
#   $ echo "    Hello    World   " | trim
#   Hello    World
#   $ trim "$(echo '    Hello    World   ')"
#   Hello    World
function trim {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  data="${data#"${data%%[![:space:]]*}"}"
  data="${data%"${data##*[![:space:]]}"}"

  echo -n "$data"
}

# Right trim
function rtrim {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  data="${data%"${data##*[![:space:]]}"}"

  echo -n "$data"
}

# Left trim
function ltrim {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  data="${data#"${data%%[![:space:]]*}"}"

  echo -n "$data"
}

# Strip all empty lines and comments
#
# Examples
#   $ echo -e "foo\n#bar\n\nbaz\n#bang\n\t# idk"
#   foo
#   #bar
# 
#   baz
#   #bang
#     # idk
#   $ echo -e "foo\n#bar\n\nbaz\n#bang\n\t# idk" | realdata
#   foo
#   baz
#   $ realdata "$(echo -e 'foo\n#bar\n\nbaz\n#bang\n\t# idk')"
#   foo
#   baz
function realdata {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  echo "$data" | grep -Ev '^($|\s*#)'
}


# Line Count
#   $ echo -e "foo\n#bar\n\nbaz\n#bang\n\t# idk"
#   foo
#   #bar
#   
#   baz
#     #bang
#   $ echo -e "foo\n#bar\n\nbaz\n#bang\n\t# idk" | wc -l
#        6
#   $ echo -e "foo\n#bar\n\nbaz\n#bang\n\t# idk" | lc
#   6
function lc {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  echo "$data" | wc -l | trim
}

# REAL Line Count
#
#   $ echo -e "foo\n#bar\n\nbaz\n#bang\n\t# idk"
#   foo
#   #bar
#   
#   baz
#     #bang
#   $ echo -e "foo\n#bar\n\nbaz\n#bang\n\t# idk" | wc -l
#        6
#   $ echo -e "foo\n#bar\n\nbaz\n#bang\n\t# idk" | lc
#   6
#   $ echo -e "foo\n#bar\n\nbaz\n#bang\n\t# idk" | realdata | wc -l
#        2
#   $ echo -e "foo\n#bar\n\nbaz\n#bang\n\t# idk" | rlc
#   2
function rlc {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  echo "$data" | realdata |  wc -l | trim
}

# Upper case alphabetical characters in string
function upper {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  echo "$data" | tr '[a-z]' '[A-Z]'
}

# Lower case alphabetical characters in string
function lower {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  echo "$data" | tr '[A-Z]' '[a-z]'
}

# Redirect specified content to STDERR 
function tostderr {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  echo "${data}" 1>&2
}

# Redirect specified content to STDOUT
function tostdout {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  echo "${data}" 2>&1
}

# Verify that a binary exists and is in the $PATH
function checkbin {
  which "${1}" &>/dev/null
}

# Get the date in a specific format
#
# Examples
#   $ getdate epoch
#   1485287542
#   $ getdate time
#   12:52:25 PM
#   $ getdate time12
#   12:52:26 PM
#   $ getdate time24
#   12:52:31
#   $ getdate day
#   2017-01-24
#   $ getdate daytime
#   2017-01-24 12:52:37 PM
#   $ getdate daytime24
#   2017-01-24 12:52:39
#   $ getdate daytime12
#   2017-01-24 12:52:44 PM
#   $ getdate timeday
#   12:52:49 PM 2017-01-24
#   $ getdate time12day
#   12:52:52 PM 2017-01-24
#   $ getdate time24day
#   12:52:54 2017-01-24
function getdate {
  if [[ $# -eq 0 ]]
  then
    req="daytime24"
  else
    req="$(lower $1)"
  fi

  fmtDay="%Y-%m-%d"
  fmtTime24="%H:%M:%S"
  fmtTime12="%I:%M:%S %p"
  fmtEpoch="%a %b %d %T %Z %Y"

  #date "+%Y-%m-%d %H:%M:%S"

  if [[ $req == 'epoch' ]]
  then
    date -j -f "${fmtEpoch}" "$(date)" "+%s"
  elif [[ $req == 'time' ]] || [[ $req == 'time12' ]]
  then
    date "+${fmtTime12}"
  elif [[ $req == 'time24' ]]
  then
    date "+${fmtTime24}"
  elif [[ $req == 'day' ]]
  then
    date "+${fmtDay}"
  elif [[ $req == 'daytime' ]] || [[ $req == 'daytime12' ]]
  then
    date "+${fmtDay} ${fmtTime12}"
  elif [[ $req == 'daytime24' ]]
  then
    date "+${fmtDay} ${fmtTime24}"
  elif [[ $req == 'timeday' ]] || [[ $req == 'time12day' ]]
  then
    date "+${fmtTime12} ${fmtDay}"
  elif [[ $req == 'time24day' ]]
  then
    date "+${fmtTime24} ${fmtDay}"
  else
    tostderr "Invalid or illegal date format '${req}'"
    date "+${fmtTime24} ${fmtDay}"
  fi
}

# date "+%m%d%H%M%Y.%S"

function diaglog {
  levels=("DEBUG" "GENERAL" "INFO" "WARN" "ERROR")  

  function istype {
    inarray "${1}" "${levels[@]}"
  }

  if [[ $# -eq 0 ]]
  then
    tostderr "the diaglog function was called with no parameters"
    return
  fi

  loglvldef="GENERAL"
  loglvl="${loglvldef}"
  logto="${generalLog}"

  # If only ONE arguments was provided..
  if [[ $# -eq 1 ]]
  then
    data="${1}"

  # If TWO (or more) arguments were provided..
  elif [[ $# -gt 1 ]]
  then

    if [[ $(istype "$(upper ${1})"; echo $?) -eq 0 ]]
    then
      loglvl="$(upper ${1})"
      data="${2}"
    elif [[ $(istype "$(upper ${2})"; echo $?) -eq 0 ]]
    then
      loglvl="$(upper ${2})"
      data="${1}"
    else
      data="${1}"
      loglvl="${2}"
    fi
    logto='./test'
  fi

  printf "%-10s | %-19s | %-7s | %s\n" "$(getdate epoch)" "$(getdate daytime24)" "${loglvl}" "${data}"  >> "${logto}"
}

function biggeststr {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  echo "${data}" | xargs -I {} bash -c "echo {} | wc -m" | sort -n | tail -n 1
}

function smalleststr {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  echo "${data}" | xargs -I {} bash -c "echo {} | wc -m" | sort -n | head -n 1
}

function inarray {
  local e

  for e in "${@:2}"
  do 
    [[ "$e" == "$1" ]] && return 0
  done

  return 1
}

function charlen {
  echo -e '$#:\t'"$# "
  echo -e '$*:\t'"$*"
  echo -e '$@:\t'"$@"

  args=("${@}")
  nouns=("biggest" "smallest")
  noun="${args[0]}"

  if [[ -z "${noun}" ]]
  then
    noun="biggest"
  elif [[ $(inarray "${noun}" "${nouns[@]}"; echo $?) -ne 0 ]]; then
    noun="biggest"
  #else
  #  echo "Noun is '${noun}'"
  fi

  if [[ -t 0 ]]; then     
    echo "No STDIN data"
    return 1
  fi

  data_in="$(cat)"

  data_wc=$(echo "${data_in} | xargs -I {} bash -c "echo {} | wc -m" | sort -n") 

  if [[ $noun == 'biggest' ]]
  then
    echo "${data_wc}" | tail -n 1
  elif [[ $noun == 'smallest' ]]
  then
    echo "${data_wc}" | head -n 1
  fi

}