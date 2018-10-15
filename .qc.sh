#!/bin/bash
#
# To enable, add the following 2 lines to .bashrc or .profile
#
# export QUICKCMDS=<dir>
# . $QUICKCMDS/.qc.sh

function findQC {
  qcmd="$QUICKCMDS/$1"
  local cxt
  for cxt in . QC `cat $QUICKCMDS/.qccontexts`
  do
    local tcmd="$QUICKCMDS/$cxt/$1"
    if [ -f $tcmd ]; then
      qcmd=$tcmd
      break
    fi
  done
}

# DESC x NAME [ARGS] : Execute a saved script
function x {
  findQC $1.sh
  [ $# == 0 ]    && { echo usage: x NAME [ARGS]; return 1; }
  [ ! -f $qcmd ] && { echo $1: command not found; return 1; }
  shift
  $qcmd "$@"
}

# exec mode. no need to load entire script
[ "$1" == "-x" ] && { shift; x $*; exit 0; }

# DESC xmv NAME CONTEXT : Move a script to a context
function xmv {
  [ $# -ne 2 ] && { echo usage: xm NAME CONTEXT; return 1; }
  _moveToContext $1.sh $2
}

# DESC xls [NAME] : List saved scripts
function xls {
  echo Generating listing...
  ( local cxt
  for cxt in . `cat $QUICKCMDS/.qccontexts` QC
  do
    local qcfiles=`ls $QUICKCMDS/${cxt}/*.sh 2>/dev/null`
    if [ "$qcfiles" != "" ]; then
      test "$cxt" != "." && echo ${cxt}
      local qci
      for qci in $qcfiles
      do
        echo "__"`basename $qci .sh` `grep '^# DESC' $qci | head -1 | sed 's/# DESC/ : /'`
      done
    fi
  done ) | $colcmd | while read LINE
  do
     test "`echo "$LINE" | grep '^__'`" != "$LINE" && echo
     echo "$LINE" | sed 's/__/  /'
  done
}

# DESC xcat [NAME] : Display script
function xcat {
  [ $# == 0 ] && { echo usage: xcat NAME ; return 1; }
  findQC $1.sh
  if [ -f $qcmd ]; then
    echo -e '\nFile: '${qcmd}'\n'
    cat ${qcmd}
  else
    echo Command not found
  fi
}

# DESC xu [NAME] : Display command usage
function xu {
  findQC `basename $1 .sh`.sh
  [ $# == 0 ]      && { echo usage: xu NAME ; return 1; }
  [ ! -f ${qcmd} ] && { echo Command not found ; return 1; }
  echo -e '\nFile: '${qcmd}'\n'
  grep '^# DESC' $qcmd | sed 's/# DESC //' | sed 's/# DESC//'
}

# DESC xed NAME : Edit a script
function xed {
  [ $# == 0 ] && { echo usage: xed NAME; return 1; }
  findQC $1.sh
  eval $qceditor $qcmd
  test -f $qcmd && chmod 777 $qcmd
}

# DESC xp NAME : Edit a profile
function xp {
  [ $# -ne 1 ] && { echo usage: xp CONTEXT; return 1; }
  eval $qceditor $QUICKCMDS/${1}/profile
}

# DESC xr NAME COMMAND [ARGS] : Remember a script
function xr {
  [ $# -lt 2 ] && { echo usage: xr NAME COMMAND [ARGS]; return 1; }
  findQC $1.sh
  local qcorig=$1
  shift
  echo $* > ${qcmd}
  chmod 777 ${qcmd}
  echo Saved: $qcorig
  xcat ${qcorig}
}

# DESC xrm NAME : Remove a script
function xrm {
  findQC $1.sh
  [ $# == 0 ]    && { echo usage: xrm NAME; return 1; }
  [ ! -f $qcmd ] && { echo $1 not found; return 1; }
  mv $qcmd ~/.local/share/Trash/files/ && echo Removed $qcmd
}

# DESC c NAME : Change to directory
function c {
  findQC $1.cd
  [ $# == 0 ]  && { eval cd ; return; }
#echo usage: c NAME; return 1; }
  [ -f $qcmd ] && { eval cd `cat $qcmd`; return; }
  cd $*
}

# DESC ced NAME : Edit a directory
function ced {
  findQC $1.cd
  [ $# == 0 ]    && { echo usage: c NAME; return 1; }
  [ ! -f $qcmd ] && { echo $1 not found; return 1; }
  eval $qceditor $qcmd
}

# DESC cr NAME : Remember a directory
function cr {
  [ $# -ne 1 ] && { echo usage: cr NAME; return 1; }
  findQC $1.cd
  echo `pwd` > $qcmd  && echo Remembered $1 : `pwd`
}

# DESC cmv NAME CONTEXT : Move a directory to a context
function cmv {
  [ $# -ne 2 ] && { echo usage: xm NAME CONTEXT; return 1; }
  _moveToContext $1.cd $2
}

# DESC crm NAME : Remove a directory
function crm {
  findQC $1.cd
  [ $# -ne 1 ]   && { echo usage: crm NAME; return 1; }
  [ ! -f $qcmd ] && { echo Directory not found; return 1; }
  rm $qcmd && echo Removed $qcmd
}

# DESC cs : List directories
function cs {
  ( local cxt
  for cxt in . `cat $QUICKCMDS/.qccontexts`
  do
    local qcfiles=`ls $QUICKCMDS/${cxt}/*.cd 2>/dev/null`
    if [ "$qcfiles" != "" ]; then
      test "$cxt" != "." && echo ${cxt}
      local qci
      for qci in $qcfiles
      do
        echo "__"`basename $qci .cd` : `cat $qci`
      done
    fi
  done ) | $colcmd -t -s : | while read LINE
  do
     test "`echo "$LINE" | grep '^__'`" != "$LINE" && echo
     echo "$LINE" | sed 's/__/  /'
  done
}

# internal functions
function _moveToContext {
  findQC $1
  local cdir=$QUICKCMDS/$2
  [ ! -f $qcmd ] && { echo $1: command not found; return 1; }
  [ ! -d $cdir ] && { echo Context not found; return 1; }
  mv $qcmd $cdir && echo `basename $1 .sh` moved to $2
}

function _loadProfiles {
  local cxt
  for cxt in `cat $QUICKCMDS/.qccontexts`
  do
    local profile=$QUICKCMDS/$cxt/profile
    if [ -f $profile ]; then
      # echo sourcing $cxt/profile
      . $profile
    fi
  done
}

function _getEditor {
  qceditor=$EDITOR
  if [ "$qceditor" == "" ]; then
     qceditor=vi
  fi
}

# Bash completion
_x_completion() 
{
    local cur prev opts=""
    cur="${COMP_WORDS[COMP_CWORD]}"

    local cxt 
    for cxt in . `cat $QUICKCMDS/.qccontexts` QC
    do  
      local qcfiles=`ls $QUICKCMDS/${cxt}/*.sh 2>/dev/null`
      if [ "$qcfiles" != "" ]; then
        test "$cxt" != "."
        local qci 
        for qci in $qcfiles
        do  
          opts="$opts `basename $qci .sh`"
        done
      fi  
    done

    COMPREPLY=()
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ ${cur} == * ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}
complete -F _x_completion x xed xrm xcat xmv xu

_c_completion() 
{
    local cxt opts=""

    for cxt in . `cat $QUICKCMDS/.qccontexts`
    do  
      local qcfiles=`ls $QUICKCMDS/${cxt}/*.cd 2>/dev/null`
      if [ "$qcfiles" != "" ]; then
        local qci 
        for qci in $qcfiles
        do  
          opts="$opts `basename $qci .cd`"
        done
      fi  
    done

    COMPREPLY=( $(compgen -W "${opts}" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _c_completion c ced cr cmv crm

#echo Loading Quick Commands

colcmd="column -t -s :"
type -P column > /dev/null
[ $? -ne 0 ] && {
  echo -e '\ncolumn command not found'
  echo install for best display \(util-linux package in Cygwin\)
  colcmd="cat"
}

#QUICKCMDS=`dirname ${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}`
#UICKCMDS=`realpath $QUICKCMDS`

if [ ! -d $QUICKCMDS ]; then
  echo Creating directory $QUICKCMDS
  mkdir $QUICKCMDS
fi

if [ ! -f $QUICKCMDS/.qccontexts ]; then
  echo -e '\nContext file does not exist'
  echo Creating $QUICKCMDS/.qccontexts
  touch $QUICKCMDS/.qccontexts
  echo Quick Commands loaded. For help type \'x help\'
fi

_getEditor

export -f x xmv xls xcat xu xed xr xrm c ced cr cmv crm cs findQC _moveToContext
export colcmd qceditor

_loadProfiles

