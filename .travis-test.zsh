#!/bin/zsh

source ~/.zshrc

cd test && node server.js &
sleep 1

cd ..
shpec
