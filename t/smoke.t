#!/usr/bin/env bash

# Copyright © 2022 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u
pdir="${0%/*}/.."
prog="$pdir/git-landmine"
echo 1..2
tmpdir=$(mktemp -d -t git-landmine.XXXXXX)
printf '#!/bin/sh\ntouch ../pwned' > "$tmpdir/cowsay"
chmod u+x "$tmpdir/cowsay"
"$prog" "$tmpdir/repo"
cd "$tmpdir/repo"
declare -i n=0
for subcmd in 'status' 'describe'
do
    n+=1
    cmd="git $subcmd"
    PATH="$tmpdir:$PATH" script -c "$cmd" /dev/null > ../log
    if [ -e "$tmpdir/pwned" ]
    then
        echo "ok $n $cmd"
    else
        sed -e 's/^/# /' ../log
        echo "not ok $n $cmd"
    fi
    rm -f "$tmpdir/pwned"
done
rm -rf "$tmpdir"

# vim:ts=4 sts=4 sw=4 et ft=sh