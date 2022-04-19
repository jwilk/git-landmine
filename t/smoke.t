#!/usr/bin/env bash

# Copyright © 2022 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u
pdir="${0%/*}/.."
prog="$pdir/git-landmine"
declare -i n=0
t()
{
    cmd="$1"
    xout="pwned via $2"
    shift 2
    tmpdir=$(mktemp -d -t git-landmine.XXXXXX)
    printf '#!/bin/sh\necho "$*" >> ../pwned\n' > "$tmpdir/cowsay"
    chmod u+x "$tmpdir/cowsay"
    "$prog" "$@" "$tmpdir/repo"
    pushd "$tmpdir/repo" > /dev/null
    n+=1
    PATH="$tmpdir:$PATH" script -c "$cmd" /dev/null > ../log
    pfx=''
    [ "$@" ] && pfx="[$*] "
    ident="$n $pfx$cmd"
    if [ -e "$tmpdir/pwned" ]
    then
        out=$(cat "$tmpdir/pwned")
        if [ "$out" = "$xout" ]
        then
            echo "ok $ident"
        else
            diff -u <(cat <<< "$xout") <(cat <<< "$out") | sed -e 's/^/# /'
            echo "not ok $ident"
        fi
    else
        sed -e 's/^/# /' ../log
        echo "not ok $ident"
    fi
    popd > /dev/null
    rm -rf "$tmpdir"
}
T()
{
    t "$@"
    t "$@" --bare
}
echo 1..3
t 'git status >/dev/null' 'core.fsmonitor'
T 'git describe' 'core.pager'

# vim:ts=4 sts=4 sw=4 et ft=sh
