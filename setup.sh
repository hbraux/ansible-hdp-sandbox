#!/bin/bash

opts=""
if [[ $# -eq 0 ]]
then target=localhost
else target=$1
     shift
fi
[[ ${1:0:2} == -- ]] &&  opts=" --tags $1"

cd $(dirname $0)
ansible-playbook deploy.yml $opts -i $target,


