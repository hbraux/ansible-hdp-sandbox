#!/bin/bash
# HDP installation script
# following optional arguments are accepted
# --host xxx : target host, by default localhost
# --tags xxx : ansible tags


if [[ $1 == --host ]]
then host=$(grep $2 /etc/hosts | head -1 |  awk '{print $2}')
     echo "executing playbook on $host"
     opts="-i $host,"
     [[ -f $HOME/.sshuser ]] && opts="$opts -u $(cat $HOME/.sshuser)"
     shift; shift
else opts="--connection=local -i $(uname -n),"
fi

[[ $1 == --tags ]] && opts="$opts $1 $2"

# [[ -n  $http_proxy ]] && opts="$opts -e http_proxy=$http_proxy -e https_proxy=$http_proxy -e no_proxy=$no_proxy"


cd $(dirname $0)
ansible-playbook deploy.yml $opts





