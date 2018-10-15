# DESC General help

( cat $QUICKCMDS/.qc.sh | grep '^# DESC' | sed 's/# DESC //' ) | column -t -s :
