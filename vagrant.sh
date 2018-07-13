#!/bin/bash
# This generic script is downloaded and executed by vagrant
# It make system ready to run the ansible playbook install.yml 
# Warning: vagrant provision will not re-download the script

if [[ $# -lt 3 ]]
then echo "(vagrant.sh) expecting GITHUB_REPO USERNAME USERKEY [CENTOS_MIRROR]"; exit 1
fi

if [[ -n $http_proxy ]] 
then echo "(vagrant.sh) Using proxy variables http_proxy=$http_proxy https_proxy=$https_proxy no_proxy=$no_proxy"
fi

if [[ -n $4 ]]
then
  grep -q $4 /etc/yum.repos.d/CentOS-Base.repo 
  if [[ $# -ne 0 ]]
  then echo "(vagrant.sh) Setting $4 as baseurl in CentOS-Base.repo"
       sed -i -e "s~gpgcheck=1~gpgcheck=0~g;s~^mirrorlist=.*~~g;s~#baseurl=http://mirror.centos.org~baseurl=http://$4~g" /etc/yum.repos.d/CentOS-Base.repo
  fi
fi

set -e

if [[ ! -x /usr/bin/ansible-playbook ]]
then echo "(vagrant.sh) installing Ansible"
     yum install -y -q ansible
fi

if [[ ! -d .git ]]
then
  echo "(vagrant.sh) downloading install.yml"
  curl -s -o install.yml "https://raw.githubusercontent.com/$1/master/install.yml?$(date +%s)"
fi

echo "(vagrant.sh) executing Playbook install.yml"
ansible-playbook install.yml -e github_repo=$1 -e username=$2 -e "userkey=\"$3\"" -e centos_mirror="$4"
