#!/bin/bash

# DESC Simple find from current directory
# DESC usage: x f PATTERN
# DESC example: x f file*.sh

[ $# -ne 1 ] && { xu $0; exit 1; }
find . -name "$*" -exec ls -la {} \; 2>/dev/null

