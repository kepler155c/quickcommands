# Quick Commands
Quick Commands for linux terminals. Manage scriptlets and directory locations for quickly saving and executing commands as well as shortcuts to favorite directories.

## Usage
`x help` Display usage - includes 15 standard commands for managing scriptlets and directories

`xls` List saved scriptlets

`xr <name> <command> <arg> <arg>` Remember a scriptlet

	Example: xr catp cat /ect/profile

`xed <name>` Edit a scriptlet

	Example: xed catp

`x <name>` Execute a scriptlet

	Example: x catp

`cr <name>` Save a directory shorcut

	Example: cd ~/tmp; cr tmp

`c <name>` Jump to a saved directory shortcut

	Example: c tmp

## Installation
* Copy files into ~/home/.qc

* Add to .bashrc or .profile:

```bash
if [ "$PS1" ]; then
  export QUICKCMDS=~/.qc
  . $QUICKCMDS/.qc.sh
fi
```
