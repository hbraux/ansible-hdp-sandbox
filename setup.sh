#!/bin/bash

if [[ -n $1 ]]
then opts="-i $1,"; shift
else opts="--connection=local -i $(uname -n),"
fi

[[ ${1:0:2} == -- ]] ||  opts="$opts --tags ${1:2}"

[[ -n  $http_proxy ]] && opts="$opts -e http_proxy=$http_proxy -e https_proxy=$http_proxy -e no_proxy=$no_proxy"

[[ -f $HOME/.sshuser ]] && opts="$opts -u $(cat $HOME/.sshuser)"


cd $(dirname $0)
ansible-playbook $opts deploy.yml




