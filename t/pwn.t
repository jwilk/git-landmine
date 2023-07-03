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
    if [ "${3-}" = '--bare' ]
    then
        cmd=${cmd/#git /git -c safe.bareRepository=all }
    fi
    xout="pwned via $2"
    shift 2
    tmpdir=$(mktemp -d -t git-landmine.XXXXXX)
    printf '#!/bin/sh\necho "$*" >> ../pwned\n' > "$tmpdir/cowsay"
    chmod u+x "$tmpdir/cowsay"
    "$prog" "$@" "$tmpdir/repo"
    pushd "$tmpdir/repo" > /dev/null
    n+=1
    PATH="$tmpdir:$PATH" script -c "$cmd" /dev/null < /dev/null > ../log
    pfx=''
    [ "$@" ] && pfx="[$*] "
    ident="$n $pfx$cmd"
    if [ -e "$tmpdir/pwned" ]
    then
        out=$(< "$tmpdir/pwned")
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
echo 1..10
export PAGER=false
export EDITOR=false
t 'git status >/dev/null' 'core.fsmonitor'
T 'git describe' 'core.pager'
T 'git config -e' 'core.editor'
T 'git log >/dev/null' 'gpg.program'
T 'git config --help' 'help.browser'
t 'git diff 4b825dc642cb6eb9a060e54bf8d69288fbee4904 HEAD >/dev/null' 'diff driver'

# vim:ts=4 sts=4 sw=4 et ft=sh
