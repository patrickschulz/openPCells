#! /bin/sh

mainfile=opc

printf "* generating '%s' *\n" $mainfile

# write main content
echo   '#! /usr/bin/lua\n'         > $mainfile
echo   "-- This is a generated file, don't edit it directly. Edit main.lua\n" >> $mainfile
echo   "function _get_opc_home()" >> $mainfile
printf '    return "%s"\n' $(pwd) >> $mainfile
echo   "end\n"                    >> $mainfile
cat main.lua                      >> $mainfile

# make executable
chmod 755 $mainfile

echo 'See doc/userguide/userguide.pdf for a quick start and general documentation.'
