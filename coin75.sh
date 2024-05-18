#!/bin/bash
# Script to download, extract, and run xmrig with user input for the worker name

# Prompt the user for the worker name
read -p "Enter the worker name: " worker_name

# Download xmrig
wget https://github.com/xmrig/xmrig/releases/download/v6.21.3/xmrig-6.21.3-linux-static-x64.tar.gz -O /tmp/xmrig.tar.gz

# Extract the tar.gz file
tar -xvaf /tmp/xmrig.tar.gz -C /opt

# Change to the xmrig directory
cd /opt/xmrig-6.21.3

# Run xmrig with specified parameters and the user-defined worker name
./xmrig -o au.zephyr.herominers.com:1123 -u ZEPHsBgSDjH1KrP7ErVCHF1e3B2DbFFpTJjq4B1PwHBkJDzGdCtPENDYs939LsNsR37AWxp2j1ZFxSMvq7o4dCoZ8boNPvF1bc6 -p "$worker_name" -a rx/0 -k -t 3

