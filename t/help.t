#!/usr/bin/env bash

# Copyright © 2022 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u
pdir="${0%/*}/.."
prog="$pdir/git-landmine"
echo 1..2
xout='Usage: git-landmine DIR'
declare -i n=0
for opt in '-h' '--help'
do
    n+=1
    out=$("$prog" "$opt")
    if [[ "$out" = "$xout" ]]
    then
        echo "ok $n git-landmine $opt"
    else
        diff -u <(cat <<< "$xout") <(cat <<< "$out") | sed -e 's/^/# /'
        echo "not ok $n git-landmine $opt"
    fi
done

# vim:ts=4 sts=4 sw=4 et ft=sh
