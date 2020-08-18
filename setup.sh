#! /bin/sh

echo "return {" > config.lua
printf '    home = "%s"\n' $(pwd) >> config.lua
echo "}" >> config.lua

# write main content
echo '#! /usr/bin/lua\n'              > opc
printf 'local path = "%s"\n\n' $(pwd) >> opc
cat main.lua                          >> opc

# make executable
chmod 750 opc
