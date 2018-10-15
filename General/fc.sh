#!/bin/bash

# DESC search jars for a class
# DESC usage: x fc [class]

[ $# -eq 0 ] && { xu $0; exit 1; }

for i in `find . -name "*.jar"`; 
do
   x=$(unzip -l $i 2>/dev/null | grep $1 )
   if [ "$x" != "" ]; then
     echo $i
     echo $x
   fi
done

