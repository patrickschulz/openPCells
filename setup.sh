#! /bin/sh

echo "return {" > config.lua
printf '    codepath = "%s"\n' $(pwd) >> config.lua
echo "}" >> config.lua
