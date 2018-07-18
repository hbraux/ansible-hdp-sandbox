#!/bin/bash
# This generic script is downloaded and executed by vagrant
# It install ansible, run the included playbook which creates the working user and clone the Git repo, the run setup.sh from the repo is exists
# Input argument:s 
#  $1  github repository (relative path)
#  $2  Unix user to be created
#  $3  password or public SSH key 
#  $4  fqdn or @IP of a CentOS mirror (optional)


if [[ $# -lt 3 ]]
then echo "(vagrant.sh) expecting GITHUB_REPO USERNAME PASSWORD [CENTOS_MIRROR]"; exit 1
fi

if [[ -n $http_proxy ]] 
then echo "(vagrant.sh) using proxy variables http_proxy=$http_proxy https_proxy=$https_proxy no_proxy=$no_proxy"
fi

if [[ -n $4 ]]
then
  grep -q $4 /etc/yum.repos.d/CentOS-Base.repo 
  if [[ $# -ne 0 ]]
  then echo "(vagrant.sh) setting $4 as baseurl in CentOS-Base.repo"
       sed -i -e "s~gpgcheck=1~gpgcheck=0~g;s~^mirrorlist=.*~~g;s~#baseurl=http://mirror.centos.org~baseurl=http://$4~g" /etc/yum.repos.d/CentOS-Base.repo
  fi
fi

set -e

if [[ ! -x /usr/bin/ansible-playbook ]]
then echo "(vagrant.sh) installing Ansible"
     yum install -y -q ansible
fi

cat >vagrant.yml <<EOF
- hosts: 127.0.0.1
  connection: local
  become: yes
  tasks:
    - name: install basic packages
      yum:
        name: "{{ item }}"
      with_items:
        - sudo
        - git
        - emacs-nox

    - name: ensure that wheel group exist
      group:
        name: wheel

    - name: allow passwordless sudo for wheel group
      lineinfile:
        dest: /etc/sudoers
        regexp: '^%wheel'
        line: '%wheel ALL=(ALL) NOPASSWD: ALL'
        validate: 'visudo -cf %s'

    - name: create user {{ username }}
      user:
        name: "{{ username }}"
        group: users
        groups: wheel

    - name: add public key to user {{ username }}
      authorized_key:
        user: "{{ username }}"
        key: "{{ password }}"
      when: password is match ("ssh-rsa .*")

    - name: update password for user {{ username }}
      user:
        name: "{{ username }}"
        password: "{{ password | password_hash('sha512') }}"
        update_password: always
      when: password is not match ("ssh-rsa .*")

    - name: allow PasswordAuthentication
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PasswordAuthentication '
        line: 'PasswordAuthentication yes'
      notify:
        - restart sshd
      when: password is not match ("ssh-rsa .*")

    - name: clone the git repo
      git:
        repo: https://github.com/{{ github_repo }}.git
        dest: /home/{{ username }}/git/{{ github_repo }}

    - name: update the owner
      file:
        path: /home/{{ username }}/git
        owner: "{{ username }}"
        group: users
        recurse: yes

    - name: get uname
      shell: uname -n | sed 's/[a-z0-9]*\.//'
      register: uname_cmd

    - name: update .ssh/config
      blockinfile:
        path: /home/{{ username }}/.ssh/config
        create: yes
        owner: "{{ username }}"
        block: |
          Host *.{{ uname_cmd.stdout }}
            StrictHostKeyChecking no
            UserKnownHostsFile=/dev/null

    - set_fact:
        local_epel: http://{{ centos_mirror }}/fedora/epel/\$releasever/\$basearch/
      when: centos_mirror is defined
      
    - name: Add Epel repo
      yum_repository:
        name: epel
        description: EPEL YUM repo
        baseurl: "{{ local_epel |default('https://download.fedoraproject.org/pub/epel/\$releasever/\$basearch/') }}"
        gpgcheck: no

    - name: check for host rpm files
      find:
        path: /vagrant
        patterns: "*.rpm"
      ignore_errors: yes
      register: rpm_files

    - name: install rpm files
      yum:
        name: "{{ item.path }}"
      with_items: "{{ rpm_files.files }}"
      when: rpm_files.matched > 0

  handlers:
    - name: restart sshd
      service:
        name: sshd
        state: restarted
EOF

echo "(vagrant.sh) executing Playbook vagrant.yml"
ansible-playbook vagrant.yml -e github_repo=$1 -e username=$2 -e "password=\"$3\"" -e centos_mirror="$4" -i localhost,
echo ""

setup=$(find /home/$2/git/$1 -name setup.sh | head -1)
if [[ -x $setup ]]
then echo "(vagrant.sh) executing $setup as user $2"
     su - $2 -c $setup
fi

echo "(vagrant.sh) all done"
