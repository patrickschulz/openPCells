#! /bin/sh

mainfile=opc
if [ -z "$1" ]; then
    mainfile=opc
else
    mainfile=$1
fi

printf "* generating '%s' *\n" $mainfile

# write main content
echo   -e '#! /usr/bin/lua\n'         > $mainfile
echo   -e "-- This is a generated file, don't edit it directly. Edit main.lua\n" >> $mainfile
echo   -e "function _get_opc_home()" >> $mainfile
printf '    return "%s"\n' $(pwd)    >> $mainfile
echo   -e "end\n"                    >> $mainfile
cat main.lua                         >> $mainfile

# make executable
chmod 755 $mainfile

echo 'See doc/userguide/userguide.pdf for a quick start and general documentation.'
