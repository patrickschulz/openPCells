.PHONY: all
all: object.test polygon.test
	@echo '# API Function Tests #'
	@./object.test
	@./polygon.test

PPFLAGS=-DLUA_USE_LINUX
CC=gcc
LIBS = -lm -ldl

SRC_PATH = ../../src
LUA_FILES = $(SRC_PATH)/lua/lapi.c $(SRC_PATH)/lua/lauxlib.c $(SRC_PATH)/lua/lbaselib.c $(SRC_PATH)/lua/lcode.c $(SRC_PATH)/lua/lcorolib.c $(SRC_PATH)/lua/lctype.c $(SRC_PATH)/lua/ldblib.c $(SRC_PATH)/lua/ldebug.c $(SRC_PATH)/lua/ldo.c $(SRC_PATH)/lua/ldump.c $(SRC_PATH)/lua/lfunc.c $(SRC_PATH)/lua/lgc.c $(SRC_PATH)/lua/linit.c $(SRC_PATH)/lua/liolib.c $(SRC_PATH)/lua/llex.c $(SRC_PATH)/lua/lmathlib.c $(SRC_PATH)/lua/lmem.c $(SRC_PATH)/lua/loadlib.c $(SRC_PATH)/lua/lobject.c $(SRC_PATH)/lua/lopcodes.c $(SRC_PATH)/lua/loslib.c $(SRC_PATH)/lua/lparser.c $(SRC_PATH)/lua/lstate.c $(SRC_PATH)/lua/lstring.c $(SRC_PATH)/lua/lstrlib.c $(SRC_PATH)/lua/ltable.c $(SRC_PATH)/lua/ltablib.c $(SRC_PATH)/lua/ltm.c $(SRC_PATH)/lua/lundump.c $(SRC_PATH)/lua/lvm.c $(SRC_PATH)/lua/lzio.c
HELPER_FILES = helper.c $(SRC_PATH)/error.c $(SRC_PATH)/filesystem.c $(SRC_PATH)/hashmap.c $(SRC_PATH)/lua_util.c $(SRC_PATH)/string.c $(SRC_PATH)/strprint.c $(SRC_PATH)/tagged_value.c $(SRC_PATH)/util.c $(SRC_PATH)/vector.c $(SRC_PATH)/technology.c $(LUA_FILES)

object.test: object.c helper.h helper.c check.h check.c
	$(CC) $(PPFLAGS) -g -Wall -Wextra -I ../../ $(HELPER_FILES) object.c check.c ../../src/object.c ../../src/shape.c ../../src/bltrshape.c ../../src/polygon.c ../../src/transformationmatrix.c ../../src/geometry.c ../../src/geometry_triangulate.c ../../src/point.c ../../src/graphics.c ../../src/tuple.c -o object.test $(LIBS)

polygon.test: polygon.c helper.h helper.c check.h check.c
	$(CC) $(PPFLAGS) -Wall -Wextra -I ../../ $(HELPER_FILES) polygon.c check.c ../../src/polygon.c ../../src/point.c -o polygon.test $(LIBS)
