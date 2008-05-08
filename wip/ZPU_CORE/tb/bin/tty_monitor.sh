#!/bin/sh
echo start monitoring on file msim/tty_zpu.txt .....
# sleep 2
clear
rm -f msim/tty_zpu.txt
touch msim/tty_zpu.txt
tail -f msim/tty_zpu.txt
