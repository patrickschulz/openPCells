#include "lutil.h"

#include "lua/lauxlib.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <err.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>

int _get_screen_width(lua_State* L)
{
    struct winsize ws;
    int fd;

    fd = open("/dev/tty", O_RDWR);
    if(fd < 0 || ioctl(fd, TIOCGWINSZ, &ws) < 0) err(8, "/dev/tty");

    close(fd);

    lua_pushinteger(L, ws.ws_col);

    return 1;
}

int open_lutil_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "get_terminal_width",   _get_screen_width   },
        { NULL,     NULL        }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "termutil");
    return 0;
}
