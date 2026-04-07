LUA_CORE_O= lua/lapi.o lua/lcode.o lua/lctype.o lua/ldebug.o lua/ldo.o lua/ldump.o lua/lfunc.o lua/lgc.o lua/llex.o lua/lmem.o lua/lobject.o lua/lopcodes.o lua/lparser.o lua/lstate.o lua/lstring.o lua/ltable.o lua/ltm.o lua/lundump.o lua/lvm.o lua/lzio.o
LUA_LIB_O=	lua/lauxlib.o lua/lbaselib.o lua/lcorolib.o lua/ldblib.o lua/liolib.o lua/lmathlib.o lua/loadlib.o lua/loslib.o lua/lstrlib.o lua/ltablib.o lua/linit.o
LUA_CORE_RELEASEOBJS = $(addprefix release/, $(LUA_CORE_O))
LUA_CORE_LINTOBJS = $(addprefix lint/, $(LUA_CORE_O))
LUA_CORE_DEBUGOBJS = $(addprefix debug/, $(LUA_CORE_O))
LUA_LIB_RELEASEOBJS = $(addprefix release/, $(LUA_LIB_O))
LUA_LIB_LINTOBJS = $(addprefix lint/, $(LUA_LIB_O))
LUA_LIB_DEBUGOBJS = $(addprefix debug/, $(LUA_LIB_O))

liblua_release.a: release $(LUA_CORE_RELEASEOBJS) $(LUA_LIB_RELEASEOBJS)
	ar rcu $@ $(LUA_CORE_RELEASEOBJS) $(LUA_LIB_RELEASEOBJS)
	ranlib $@

liblua_lint.a: lint $(LUA_CORE_LINTOBJS) $(LUA_LIB_LINTOBJS)
	ar rcu $@ $(LUA_CORE_LINTOBJS) $(LUA_LIB_LINTOBJS)
	ranlib $@

liblua_debug.a: debug $(LUA_CORE_DEBUGOBJS) $(LUA_LIB_DEBUGOBJS)
	ar rcu $@ $(LUA_CORE_DEBUGOBJS) $(LUA_LIB_DEBUGOBJS)
	ranlib $@

# lua object files rules
# these are copied from the original lua makefile
# the paths are hard-coded, there is probably a better and
# more automated way to do this, but this works well and
# this will also not change
release/lua/lapi.o: lua/lapi.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
release/lua/lauxlib.o: lua/lauxlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h
release/lua/lbaselib.o: lua/lbaselib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/lcode.o: lua/lcode.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
release/lua/lcorolib.o: lua/lcorolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/lctype.o: lua/lctype.c lua/lprefix.h lua/lctype.h lua/lua.h lua/luaconf.h lua/llimits.h
release/lua/ldblib.o: lua/ldblib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/ldebug.o: lua/ldebug.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lcode.h lua/llex.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h lua/lvm.h
release/lua/ldo.o: lua/ldo.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lparser.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
release/lua/ldump.o: lua/ldump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lobject.h lua/llimits.h lua/lstate.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lundump.h
release/lua/lfunc.o: lua/lfunc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h
release/lua/lgc.o: lua/lgc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h
release/lua/linit.o: lua/linit.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lualib.h lua/lauxlib.h
release/lua/liolib.o: lua/liolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/llex.o: lua/llex.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/llex.h lua/lparser.h lua/lstring.h lua/ltable.h
release/lua/lmathlib.o: lua/lmathlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/lmem.o: lua/lmem.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h
release/lua/loadlib.o: lua/loadlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/lobject.o: lua/lobject.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h lua/lvm.h
release/lua/lopcodes.o: lua/lopcodes.c lua/lprefix.h lua/lopcodes.h lua/llimits.h lua/lua.h lua/luaconf.h
release/lua/loslib.o: lua/loslib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/lparser.o: lua/lparser.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h
release/lua/lstate.o: lua/lstate.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/llex.h lua/lstring.h lua/ltable.h
release/lua/lstring.o: lua/lstring.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h
release/lua/lstrlib.o: lua/lstrlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/ltable.o: lua/ltable.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
release/lua/ltablib.o: lua/ltablib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/ltm.o: lua/ltm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
release/lua/lua.o: lua/lua.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/luac.o: lua/luac.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lopnames.h lua/lundump.h
release/lua/lundump.o: lua/lundump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/lundump.h
release/lua/lvm.o: lua/lvm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lstring.h lua/ltable.h lua/lvm.h lua/ljumptab.h
release/lua/lzio.o: lua/lzio.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/llimits.h lua/lmem.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h

lint/lua/lapi.o: lua/lapi.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
lint/lua/lauxlib.o: lua/lauxlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h
lint/lua/lbaselib.o: lua/lbaselib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/lcode.o: lua/lcode.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
lint/lua/lcorolib.o: lua/lcorolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/lctype.o: lua/lctype.c lua/lprefix.h lua/lctype.h lua/lua.h lua/luaconf.h lua/llimits.h
lint/lua/ldblib.o: lua/ldblib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/ldebug.o: lua/ldebug.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lcode.h lua/llex.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h lua/lvm.h
lint/lua/ldo.o: lua/ldo.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lparser.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
lint/lua/ldump.o: lua/ldump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lobject.h lua/llimits.h lua/lstate.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lundump.h
lint/lua/lfunc.o: lua/lfunc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h
lint/lua/lgc.o: lua/lgc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h
lint/lua/linit.o: lua/linit.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lualib.h lua/lauxlib.h
lint/lua/liolib.o: lua/liolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/llex.o: lua/llex.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/llex.h lua/lparser.h lua/lstring.h lua/ltable.h
lint/lua/lmathlib.o: lua/lmathlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/lmem.o: lua/lmem.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h
lint/lua/loadlib.o: lua/loadlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/lobject.o: lua/lobject.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h lua/lvm.h
lint/lua/lopcodes.o: lua/lopcodes.c lua/lprefix.h lua/lopcodes.h lua/llimits.h lua/lua.h lua/luaconf.h
lint/lua/loslib.o: lua/loslib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/lparser.o: lua/lparser.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h
lint/lua/lstate.o: lua/lstate.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/llex.h lua/lstring.h lua/ltable.h
lint/lua/lstring.o: lua/lstring.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h
lint/lua/lstrlib.o: lua/lstrlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/ltable.o: lua/ltable.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
lint/lua/ltablib.o: lua/ltablib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/ltm.o: lua/ltm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
lint/lua/lua.o: lua/lua.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/luac.o: lua/luac.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lopnames.h lua/lundump.h
lint/lua/lundump.o: lua/lundump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/lundump.h
lint/lua/lvm.o: lua/lvm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lstring.h lua/ltable.h lua/lvm.h lua/ljumptab.h
lint/lua/lzio.o: lua/lzio.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/llimits.h lua/lmem.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h

debug/lua/lapi.o: lua/lapi.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
debug/lua/lauxlib.o: lua/lauxlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h
debug/lua/lbaselib.o: lua/lbaselib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/lcode.o: lua/lcode.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
debug/lua/lcorolib.o: lua/lcorolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/lctype.o: lua/lctype.c lua/lprefix.h lua/lctype.h lua/lua.h lua/luaconf.h lua/llimits.h
debug/lua/ldblib.o: lua/ldblib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/ldebug.o: lua/ldebug.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lcode.h lua/llex.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h lua/lvm.h
debug/lua/ldo.o: lua/ldo.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lparser.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
debug/lua/ldump.o: lua/ldump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lobject.h lua/llimits.h lua/lstate.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lundump.h
debug/lua/lfunc.o: lua/lfunc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h
debug/lua/lgc.o: lua/lgc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h
debug/lua/linit.o: lua/linit.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lualib.h lua/lauxlib.h
debug/lua/liolib.o: lua/liolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/llex.o: lua/llex.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/llex.h lua/lparser.h lua/lstring.h lua/ltable.h
debug/lua/lmathlib.o: lua/lmathlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/lmem.o: lua/lmem.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h
debug/lua/loadlib.o: lua/loadlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/lobject.o: lua/lobject.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h lua/lvm.h
debug/lua/lopcodes.o: lua/lopcodes.c lua/lprefix.h lua/lopcodes.h lua/llimits.h lua/lua.h lua/luaconf.h
debug/lua/loslib.o: lua/loslib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/lparser.o: lua/lparser.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h
debug/lua/lstate.o: lua/lstate.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/llex.h lua/lstring.h lua/ltable.h
debug/lua/lstring.o: lua/lstring.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h
debug/lua/lstrlib.o: lua/lstrlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/ltable.o: lua/ltable.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
debug/lua/ltablib.o: lua/ltablib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/ltm.o: lua/ltm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
debug/lua/lua.o: lua/lua.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/luac.o: lua/luac.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lopnames.h lua/lundump.h
debug/lua/lundump.o: lua/lundump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/lundump.h
debug/lua/lvm.o: lua/lvm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lstring.h lua/ltable.h lua/lvm.h lua/ljumptab.h
debug/lua/lzio.o: lua/lzio.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/llimits.h lua/lmem.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h
