# DESC Short find syntax
# DESC usage: x ff [dir] [file(s)]
#RANGER_OPTS -p

[ $# -ne 1 ] && { xu $0; exit 1; }

pwd
find . -name "$*" 2>/dev/null

