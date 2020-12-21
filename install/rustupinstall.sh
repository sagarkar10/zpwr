#!/usr/bin/env bash
#{{{                    MARK:Header
#**************************************************************
##### Author: WIZARD
##### Date: Fri Apr 19 20:33:51 EDT 2019
##### Purpose: bash script to install bat,fd and exa
##### Notes:
#}}}***********************************************************
if ! test -f common.sh; then
    echo "Must be in $ZPWR/install directory" >&2
    exit 1
fi

source common.sh


while true; do
    if commandExists curl;then
        break
    fi
    sleep 5
done

commandExists bat || {
    zpwrPrettyPrintBox "Installing Rustup if cargo does not exist"
    commandExists cargo || curl https://sh.rustup.rs -sSf | sh -s -- -y
    zpwrPrettyPrintBox "Updating rustup"
    "$HOME/.cargo/bin/rustup" update
    zpwrPrettyPrintBox "Installing Bat (cat replacement) with Cargo"
    "$HOME/.cargo/bin/cargo" install bat
}

commandExists fd || {
    zpwrPrettyPrintBox "Installing rustup if cargo does not exist"
    commandExists cargo || curl https://sh.rustup.rs -sSf | sh -s -- -y
    zpwrPrettyPrintBox "Updating rustup"
    "$HOME/.cargo/bin/rustup" update
    zpwrPrettyPrintBox "Installing Fd (find replacement) with Cargo"
    "$HOME/.cargo/bin/cargo" install fd-find
}

commandExists exa || {
    zpwrPrettyPrintBox "Installing rustup if cargo does not exist"
    commandExists cargo || curl https://sh.rustup.rs -sSf | sh -s -- -y
    zpwrPrettyPrintBox "Updating rustup"
    "$HOME/.cargo/bin/rustup" update
    zpwrPrettyPrintBox "Installing Exa with Cargo"
    "$HOME/.cargo/bin/cargo" install exa
}

commandExists rg || {
    zpwrPrettyPrintBox "Installing rustup if cargo does not exist"
    commandExists cargo || curl https://sh.rustup.rs -sSf | sh -s -- -y
    zpwrPrettyPrintBox "Updating rustup"
    "$HOME/.cargo/bin/rustup" update
    zpwrPrettyPrintBox "Installing ripgrep with Cargo"
    "$HOME/.cargo/bin/cargo" install ripgrep
}


zpwrPrettyPrintBox "Installing Rustup if cargo does not exist"
commandExists cargo || curl https://sh.rustup.rs -sSf | sh -s -- -y
zpwrPrettyPrintBox "Updating rustup"
"$HOME/.cargo/bin/rustup" update
zpwrPrettyPrintBox "Installing cargo-update with Cargo"
"$HOME/.cargo/bin/cargo" install cargo-update
