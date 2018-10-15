#!/bin/bash

# DESC find-grep 
# DESC usage: x fg [grep string]
#RANGER_OPTS -wp
#[ $# -ne 1 ] && { xu $0; exit 1; }
if [ $# -eq 1 ]; then
grep --color -HIRin $* *
else
find . -name $2 -exec grep --color -HIin $1 {} \;
fi

