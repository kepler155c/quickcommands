# DESC Add context
# DESC usage: x ac [context1, context2, ...]

[ $# -eq 0 ] && { xu $0; exit 1; }

for i in $*
do
  echo $i >> ~/.qccontexts
done
