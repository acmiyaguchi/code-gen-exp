#!/bin/bash

# Install busted if not already installed
if ! command -v busted &> /dev/null; then
    echo "Busted testing framework not found. Installing..."
    luarocks install --local busted
fi

# Add luarocks bin directory to PATH
export PATH="$HOME/.luarocks/bin:$PATH"

# Run all tests
cd tests
busted -v ./*_spec.lua
