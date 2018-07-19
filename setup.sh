#!/bin/bash
# HDP installation script
# following optional arguments are accepted
# --tags xxx : ansible tags
# --host xxx : target host, by default localhost

if [[ -n $1 ]]
then host=$(grep $1 /etc/hosts | head -1 |  awk '{print $2}')
     opts="-i $host,"
     echo "executing playbook on $host"
     shift
else opts="--connection=local -i $(uname -n),"
fi

if [[ ${1:0:2} == -- ]] 
then opts="$opts --tags ${1:2}"
fi

[[ -n  $http_proxy ]] && opts="$opts -e http_proxy=$http_proxy -e https_proxy=$http_proxy -e no_proxy=$no_proxy"

[[ -f $HOME/.sshuser ]] && opts="$opts -u $(cat $HOME/.sshuser)"


cd $(dirname $0)
ansible-playbook deploy.yml $opts




