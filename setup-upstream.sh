#!/bin/sh

git remote add upstream https://github.com/rmhaiderali/zint-wasm
git fetch upstream
git checkout -b main-upstream upstream/main
