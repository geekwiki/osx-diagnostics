- Date
- Time
- Executing user account data 
  - whoami
  - last
  - id
  - groups
  - $PATH
    - List contents of each PATH (Maybe save binary files)
      find $(echo $PATH | tr ':' ' ') -maxdepth 1 -type f -exec file -I --separator ' ' '{}' \; | column -t
  - User Accounts
    - Size of home dir for each suer
    - Logon history for users
    - bash_history for each user
    - Contents of home directory, documents and downloads for each user
    - When each user was created
- System
  - Resources
    - Mounted drives
    - 
  - system_profiler
  - free -m
  - uptime
  - Processes
    - 15 Longest running
    - 15 Highest CPU hogs (or any over N%)
    - 15 Highest Memory hogs (or any over N%)
  - Logs
    - dmesg
    - /var/log/*
    - syslog
  - sw_vers

Extra
- lsappinfo
- lsvfs
- sysdiagnose
- systemstats
- system_profiler
- footprint
- Find anything owned by a deleted uid or gid
- jobs (check for anything running in background)
- /etc/pam.d/login
- /etc/hosts
- /etc/hosts.equiv
- $HOME/.rhosts
- dmesg
- printenv
- cron jobs
- sc_usage
- fs_usage
- /etc/nfs.conf
- syslog -k Sender sudo
- compgen -c
  - List all commands: compgen -A command | grep -E '^[a-zA-Z0-9-]+$' | sort -u 

Extra
sysdiagnosef
systemstats
system_profiler
ls* (lsappinfo, lsvfs, etc)
footprint
Find anything owned by a deleted uid or gid
jobs (check for anything running in background)
dmesg
printenv
cron jobs
sc_usage
fs_usage
syslog -k Sender sudo
compgen -c

function trim {
  if [ $# -eq 0 ]; then
    data=$(cat)
  else
    data="$*"
  fi

  data="${data#"${data%%[![:space:]]*}"}"
  data="${data%"${data##*[![:space:]]}"}"

  echo -n "$data"
}

for action in alias builtin command export function group hostname job running service stopped user variable
do 
  echo -n "Compgen ${action}... "
  compgen -A $action | sort -u > ./$action.txt
  wc -l ./$action.txt | trim
done


for action in alias arrayvar binding builtin command directory disabled enabled export file function group helptopic hostname job keyword running service setopt shopt signal stopped user variable; do compgen -A $action > compgen-$action.txt; done


dscacheutil -q user

dsmemberutil checkmembership -u 504 -g 80


find /var/log -maxdepth 1 -type f -name '*.log' | awk -F. '{print $1}' |  xargs -I {} bash -c "fn=\$(basename {}); echo -e \"\n\nGathering \$fn logs...\"; tar cvfzP logs/\$fn.tar.gz /var/log/\$fn.*"



syslog -s -k Facility com.apple.console \
             Level Error \
             Sender MyScript \
             Message "script says hello"

syslog -C -k Level Error


function lower {
  if [ $# -eq 0 ]
  then
    data=$(cat)
  else
    data="$*"
  fi

  echo "$data" | tr '[A-Z]' '[a-z]'
}
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
mkdir ./syslog

for lvl in Emergency Alert Critical Error Warning Notice Informational Debug
do
  lowerlvl=$(lower ${lvl})
  out="./syslog/${lowerlvl}.log"
  echo -n "Saving log level ${lvl} to ${out}..."
  syslog -C -k Level $lvl > "${out}"
  lines=$(wc -l "${out}" | trim)
  echo "Done (${lines} lines)"
done