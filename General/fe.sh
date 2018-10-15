# DESC Find-edit
# DESC usage: x fe [file(s)]

[ $# -eq 0 ] && { xu $0; exit 1; }

find . -name "$*" -exec vi {} \;

