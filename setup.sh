#!/bin/bash
# HDP installation script
# following optional arguments are accepted
# -i xxx     : inventory host, by default localhost
# -t yyy ..  : any ansible-playbook options likes tags, etc



if [[ $1 == -i ]]
then host=$(grep $2 /etc/hosts | head -1 |  awk '{print $2}')
     echo "executing playbook on $host"
     opts="-i $host,"
     [[ -f $HOME/.sshuser ]] && opts="$opts -u $(cat $HOME/.sshuser)"
     shift; shift
else opts="--connection=local -i $(uname -n),"
fi

opts="$opts $*"

# [[ -n  $http_proxy ]] && opts="$opts -e http_proxy=$http_proxy -e https_proxy=$http_proxy -e no_proxy=$no_proxy"


cd $(dirname $0)
ansible-playbook deploy.yml $opts





