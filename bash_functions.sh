#!/usr/bin/env bash

# Golang install or upgrade
function getgolang () {
    sudo rm -rf /usr/local/go
    wget -q -P tmp/ https://dl.google.com/go/go"$@".linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf tmp/go"$@".linux-amd64.tar.gz
    rm -rf tmp/
    go version
}

# GHCLI install or upgrade
function getghcli () {
    wget -q -P tmp/ https://github.com/cli/cli/releases/download/v"$@"/gh_"$@"_linux_amd64.deb
    cd tmp/ && sudo dpkg -i gh_"$@"_linux_amd64.deb
    cd .. && rm -rf tmp/
    gh --version
}

# Hugo install or upgrade
function gethugo () {
    wget -q -P tmp/ https://github.com/gohugoio/hugo/releases/download/v"$@"/hugo_extended_"$@"_Linux-64bit.tar.gz
    tar xf tmp/hugo_extended_"$@"_Linux-64bit.tar.gz -C tmp/
    sudo mv -f tmp/hugo /usr/local/bin/
    rm -rf tmp/
    hugo version
}

# Hugo site from exampleSite in themes/
function hugotheme () {
    HUGO_THEME="$1" hugo "${@:2}" --themesDir ../.. -v
}

# Add GitLab remote to cwd git
function glab () {
    git remote set-url origin --add git@gitlab.com:victoriadrake/"${PWD##*/}".git
    git remote -v
}

# Markdown link check in a folder, recursive
function mlc () {
    find $1 -name \*.md -exec markdown-link-check -p {} \;
}

