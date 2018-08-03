# Helper Bash function for Kerberos tickets
# Also set the current Principal primary in Linux prompt 
# Author: Harold Braux
#
# ASSUMPTIONS
#  1. Default realm is defined by Unix variables SITE_REALM (file site.env)
#  2. Users realm is defined by Unix variables SITE_LDAP (optional)
#  3. Users' accounts start by an uppercase
#  4. Keytab file(s) is in $HOME or in $HOME/keytabs with name <primary>.keytab
#     If no keytab file is found, Kerberos password is requested
#
# VERSION: 1.6

# Current Kerberos Primary
_KRBPRIM=""
# krb location
_KRBTOOL=$BASH_SOURCE

# prompt function : update the Linux prompt with the Kerberos Primary
# also change prompt color if this is a Production environment
# TODO: smart prompt enhancement (user an keep custom PS1)
function prompt {
  if [ $(echo "$SITE_DESC" | grep -ci "prod") -eq 1 ] 
  then col="\[\e[1;31m\]" # red = prod
  else col="\[\e[1;32m\]" # blue = other
  fi
  export PS1="${col}\u@\h \[\e[1;35m\][${_KRBPRIM}]\[\e[1;34m\]:\w$\[\e[m\] "
}


# main function
function krb {
  realm=""
  case "~$1" in
      ~-u) primary=$USER;;
      ~-v) echo 'krb 1.6'; return;;
      ~-k) shift; _krb_keytab $USER $1; return;;
      ~-d) _krb_destroy; return;;
      ~-K) shift; _krb_keytab $1 $2; return;;
      ~-*) _krb_usage;  return;;
      ~)   primary="";;
      ~*@*) primary=${1%@*}; realm=${1#*@};;
      *)   primary=$1;;
  esac
  keytabfile=""
  # a keytab file can be given
  if [[ -f $1 && ${1#*.} == keytab ]] 
  then keytabfile=$1
       primary=${keytabfile%.*}
       primary=${primary##*/}
  fi

  # check current cache
  principal=$(/usr/bin/klist -c 2>/dev/null | sed -n 's/^.*principal: \(.*\)$/\1/p')
  current=${principal%@*}
  
  # there's already a ticket
  if [[ -n $current ]]
  then
    # with same primary as input argument
    if [ "$primary" == "" -o "$primary" == "$current" ]
    then 
      expdt=$(/usr/bin/klist -c | grep "krbtgt/" | head -1 | awk '{ print $3 $4}')
      # for RH7
      [[ ${#expdt} -eq 18 ]] && expdt=${expdt:0:6}${expdt:8}
      hours=${expdt:6:2}${expdt:0:2}${expdt:3:2}${expdt:8:2}
      now=$(date +%y%m%d%H)
      hours=$((hours - now))
      # check if renewal is needed 
      if [ $hours -ge 3 ]
      then echo "Ticket for '$principal' is valid until ${expdt:8:5} (${expdt:3:2}/${expdt:0:2})"
      else
	 echo "# kinit -R"
         /usr/bin/kinit -R 
	 kstatus=$?
	 # can't renew: destroy ticket
         if [ $kstatus -ne 0 ] 
         then /usr/bin/kdestroy 2>/dev/null
	      current=""
	      _KRBPRIM=""
	 else expdt=$(/usr/bin/klist -c | grep "krbtgt/" | head -1 | awk '{ print $3 $4}')
	      [[ ${#expdt} -eq 18 ]] && expdt=${expdt:0:6}${expdt:8}
              echo "Ticket for '$current' renewed until ${expdt:8:5} (${expdt:3:2}/${expdt:0:2})"
         fi
      fi
      # ticket is still valid
      if [[ -n $current ]]
      then # refresh the prompt if needed
        if [ "$_KRBPRIM" != "$current" ] 
	then _KRBPRIM=$current
             prompt
        fi
	# just return
        return
      fi
    fi
    # no ticket, clear _KRBPRIM
  else _KRBPRIM=""
  fi
  checkauth=0
  [[ -n $primary ]] || primary=$USER
  # 1st lookup for a keytab file either in $HOME or in $HOME/keytabs/ 
  [[ -n $keytabfile ]] || keytabfile=$HOME/$primary.keytab
  [[ -r $keytabfile ]] || keytabfile=$HOME/keytabs/$primary.keytab
  if [[ -r $keytabfile ]]
  then 
    # make the file read-user for security purpose
    [ $(/bin/ls -l $keytabfile | awk '{print $1}') == "-r--------" ] \
	|| chmod 400 $keytabfile 
    # if no realm, get the realm from keytab
    [[ -n $realm ]] || realm=$(/usr/bin/klist -k $keytabfile \
	| sed -n 's/.*@\(.*\) *$/\1/p' | head -1)
    if [[ -z $realm ]]
    then echo "ERROR: cannot find primary '$primary' in $keytabfile"; return
    else
      # call kinit with keytab
      echo "# kinit $primary@$realm -k -t $keytabfile"
      /usr/bin/kinit $primary@$realm -k -t $keytabfile
      kstatus=$?
      # logging
      if [ $? -eq 0 -a $primary != $USER -a -f "$_KRBTOOL" ]
      then logf=$(dirname $_KRBTOOL)/.krb.log
	   [ -w $logf ] && echo $(date +%FT%T)";$USER;$primary@$realm;$keytabfile" >>$logf 
      fi
    fi
  else 
    # no keytab file found
    checkauth=0
    # try to find the realm from primary
    if [[ -z $realm ]]
    then 
      if [[ -z $SITE_REALM ]]
      then echo "ERROR: variable \$SITE_REALM is not defined"; return
      fi
      [[ -z $SITE_LDAP ]] && SITE_LDAP=$SITE_REALM 
      LC_ALL=C
      shopt -u nocasematch
      case $primary in
	  [A-Z0-9]*) realm=$SITE_LDAP;;
	  *)  realm=$SITE_REALM; checkauth=1;;
      esac
    fi
    # check authentication: applicative accounts cannot use any ticket
    case $USER in
	[A-Z0-9]*) checkauth=0;;
    esac 
    if [ $checkauth -eq 1 -a $USER != $primary ]
    then echo "ERROR: user $USER is not allowed to request a ticket for $primary@$realm"
        prompt
	return
    fi
    # call kinit for user to provide password
    echo "# kinit $primary@$realm" 
    /usr/bin/kinit $primary@$realm
    kstatus=$?
  fi
  if [ $kstatus -eq 0 ] 
  then _KRBPRIM=$primary
       expdt=$(/usr/bin/klist -c | grep "krbtgt/" | head -1 | awk '{ print $3 $4}')
       [[ ${#expdt} -eq 18 ]] && expdt=${expdt:0:6}${expdt:8}
       echo "Ticket for '$primary' granted until ${expdt:8:5} (${expdt:3:2}/${expdt:0:2})"
  fi
  prompt
}

# usage (private function)
function _krb_usage {
 echo "USAGE 
  krb : check if ticket exists, renew it if needed, otherwise get a ticket
  krb <primary>         : get a ticket for a primary
  krb <primary>@<realm> : get a ticket for a principal
  krb <user.keytab>     : get a ticket from a keytab file
  krb -u                : get a ticket for current user (= krb \$USER)
  krb -v                : krb version 
  krb -d                : kdestroy
  krb -k <pass>         : create keytab file for current user
  krb -h                : help (print this message)
"
}

# create keytab file (private function)
function _krb_keytab {
  # only works with SITE_LDAP!
  [[ -n $SITE_LDAP ]] || return
  realm=$SITE_LDAP
  if [[ $# -lt 2 ]]
  then _krb_usage; return
  fi
  primary=$1
  password=$2
  mkdir -p $HOME/keytabs
  keytabfile=$HOME/keytabs/$primary.keytab
  [[ -f $keytabfile ]] && rm -f $keytabfile
  {
    echo "addent -password -p $primary@$realm -k 1 -e rc4-hmac"
    sleep 2
    echo "$password"
    echo "addent -password -p $primary@$realm -k 1 -e aes256-cts"
    sleep 2
    echo "$password"
    echo "wkt $keytabfile"
  } | /usr/bin/ktutil >/dev/null
  /usr/bin/kinit $primary@$realm -k -t $keytabfile
  if [[ $? -ne 0 ]]
  then rm -f $keytabfile
       return 1
  fi
  if [[ $primary != $USER ]]
  then /usr/bin/hdfs dfs -put -f $keytabfile /user/$primary
       echo  "Keytab file: hdfs:/user/$primary/$primary.keytab"
       rm -f $keytabfile
       /usr/bin/kdestroy
       _KRBPRIM=""
       prompt
  else echo "Keytab file: $keytabfile"
  fi
}

# destroy keytab
function _krb_destroy {
  /usr/bin/kdestroy
  _KRBPRIM=""
  prompt
}

