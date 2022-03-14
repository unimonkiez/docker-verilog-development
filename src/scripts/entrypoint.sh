#!/bin/sh
$SRC/scripts/entrypoint-ssh.sh
$SRC/scripts/entrypoint-vnc.sh

tail -f /dev/null