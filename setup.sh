#!/bin/bash

opts=""
[[ $# -eq 0 ]] ||  opts="--tags $1"

[[ -n  $http_proxy ]] && opts="$opts -e http_proxy=$http_proxy -e https_proxy=$http_proxy -e no_proxy=$no_proxy"

[[ -f $HOME/.sshuser ]] && opts="$opts -u $(cat $HOME/.sshuser)"

cd $(dirname $0)
ansible-playbook deploy.yml $opts -i hdp.hostonly.com, -e http_proxy=$http_proxy -e no_proxy=$no_proxy -e https_proxy=$http_proxy



