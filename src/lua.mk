LUA_CORE_O= lua/lapi.o lua/lcode.o lua/lctype.o lua/ldebug.o lua/ldo.o lua/ldump.o lua/lfunc.o lua/lgc.o lua/llex.o lua/lmem.o lua/lobject.o lua/lopcodes.o lua/lparser.o lua/lstate.o lua/lstring.o lua/ltable.o lua/ltm.o lua/lundump.o lua/lvm.o lua/lzio.o
LUA_LIB_O=	lua/lauxlib.o lua/lbaselib.o lua/lcorolib.o lua/ldblib.o lua/liolib.o lua/lmathlib.o lua/loadlib.o lua/loslib.o lua/lstrlib.o lua/ltablib.o lua/linit.o
LUA_CORE_RELEASEOBJS = $(addprefix release/, $(LUA_CORE_O))
LUA_CORE_LINTOBJS = $(addprefix lint/, $(LUA_CORE_O))
LUA_CORE_DEBUGOBJS = $(addprefix debug/, $(LUA_CORE_O))
LUA_LIB_RELEASEOBJS = $(addprefix release/, $(LUA_LIB_O))
LUA_LIB_LINTOBJS = $(addprefix lint/, $(LUA_LIB_O))
LUA_LIB_DEBUGOBJS = $(addprefix debug/, $(LUA_LIB_O))

liblua_release.a: $(LUA_CORE_RELEASEOBJS) $(LUA_LIB_RELEASEOBJS)
	ar rcu $@ $(LUA_CORE_RELEASEOBJS) $(LUA_LIB_RELEASEOBJS)
	ranlib $@

liblua_lint.a: $(LUA_CORE_LINTOBJS) $(LUA_LIB_LINTOBJS)
	ar rcu $@ $(LUA_CORE_LINTOBJS) $(LUA_LIB_LINTOBJS)
	ranlib $@

liblua_debug.a: $(LUA_CORE_DEBUGOBJS) $(LUA_LIB_DEBUGOBJS)
	ar rcu $@ $(LUA_CORE_DEBUGOBJS) $(LUA_LIB_DEBUGOBJS)
	ranlib $@
