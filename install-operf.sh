#!/usr/bin/env bash
#
# Works with Ubuntu 16.04
#
if ! which operf > /dev/null; then
    sudo apt install -y oprofile
fi
