# DESC recursive grep 
# DESC usage: x g [grep string]

[ $# -ne 1 ] && { xu $0; exit 1; }

grep --color -HIRin "$*" *
