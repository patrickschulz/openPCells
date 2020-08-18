#! /bin/sh

mainfile=opc

# write main content
echo   '#! /usr/bin/lua\n'        > $mainfile
echo   'function _get_opc_home()' >> $mainfile
printf '    return "%s"\n' $(pwd) >> $mainfile
echo   'end\n'                    >> $mainfile
cat main.lua                      >> $mainfile

# make executable
chmod 750 $mainfile
