#include "lload.h"
#include "config.h"
#include <string.h>
#include <errno.h>

#include "lua/lauxlib.h"

typedef struct LoadF {
    int n;  /* number of pre-read characters */
    FILE *f;  /* file being read */
    char buff[BUFSIZ];  /* area for reading file */
} LoadF;

static const char *getF (lua_State *L, void *ud, size_t *size) {
    LoadF *lf = (LoadF *)ud;
    (void)L;  /* not used */
    if (lf->n > 0) {  /* are there pre-read characters to be read? */
        *size = lf->n;  /* return them (chars already in buffer) */
        lf->n = 0;  /* no more pre-read characters */
    }
    else {  /* read a block from file */
        /* 'fread' can return > 0 *and* set the EOF flag. If next call to
           'getF' called 'fread', it might still wait for user input.
           The next check avoids this problem. */
        if (feof(lf->f)) return NULL;
        *size = fread(lf->buff, 1, sizeof(lf->buff), lf->f);  /* read block */
    }
    return lf->buff;
}

static int errfile (lua_State *L, const char *what, int fnameindex) {
    const char *serr = strerror(errno);
    const char *filename = lua_tostring(L, fnameindex) + 1;
    lua_pushfstring(L, "cannot %s %s: %s", what, filename, serr);
    lua_remove(L, fnameindex);
    return LUA_ERRFILE;
}

static int skipBOM (LoadF *lf) {
    const char *p = "\xEF\xBB\xBF";  /* UTF-8 BOM mark */
    int c;
    lf->n = 0;
    do {
        c = getc(lf->f);
        if (c == EOF || c != *(const unsigned char *)p++) return c;
        lf->buff[lf->n++] = c;  /* to be read by the parser */
    } while (*p != '\0');
    lf->n = 0;  /* prefix matched; discard it */
    return getc(lf->f);  /* return next character */
}

/*
 ** reads the first character of file 'f' and skips an optional BOM mark
 ** in its beginning plus its first line if it starts with '#'. Returns
 ** true if it skipped the first line.  In any case, '*cp' has the
 ** first "valid" character of the file (after the optional BOM and
 ** a first-line comment).
 */
static int skipcomment (LoadF *lf, int *cp) {
    int c = *cp = skipBOM(lf);
    if (c == '#') {  /* first line is a comment (Unix exec. file)? */
        do {  /* skip first line */
            c = getc(lf->f);
        } while (c != EOF && c != '\n');
        *cp = getc(lf->f);  /* skip end-of-line, if present */
        return 1;  /* there was a comment */
    }
    else return 0;  /* no comment */
}

static int _loadfile(lua_State *L, const char *filename, const char* chunkname)
{
    LoadF lf;
    int status, readstatus;
    int c;
    int fnameindex = lua_gettop(L) + 1;  /* index of filename on the stack */
    lua_pushfstring(L, "@%s", filename);
    lf.f = fopen(filename, "r");
    if (lf.f == NULL) return errfile(L, "open", fnameindex);
    if (skipcomment(&lf, &c))  /* read initial portion */
        lf.buff[lf.n++] = '\n';  /* add line to correct line numbers */
    if (c == LUA_SIGNATURE[0] && filename) {  /* binary file? */
        lf.f = freopen(filename, "rb", lf.f);  /* reopen in binary mode */
        if (lf.f == NULL) return errfile(L, "reopen", fnameindex);
        skipcomment(&lf, &c);  /* re-read initial portion */
    }
    if (c != EOF)
        lf.buff[lf.n++] = c;  /* 'c' is the first character of the stream */
    status = lua_load(L, getF, &lf, chunkname, NULL);
    readstatus = ferror(lf.f);
    if (filename) fclose(lf.f);  /* close file (even in case of errors) */
    if (readstatus) {
        lua_settop(L, fnameindex);  /* ignore results from 'lua_load' */
        return errfile(L, "read", fnameindex);
    }
    lua_remove(L, fnameindex);
    return status;
}

static int opc_get_home(lua_State* L)
{
    lua_pushstring(L, OPC_HOME);
    return 1;
}

int open_lload_lib(lua_State* L)
{
    lua_pushcfunction(L, opc_get_home);
    lua_setglobal(L, "_get_opc_home");
    // _load_module is written in lua
    // no error checks, we know what we are doing
    // that means, don't fuck up load.lua
    (void) (_loadfile(L, OPC_HOME "/" "load.lua", "@load") || lua_pcall(L, 0, LUA_MULTRET, 0));
    return 0;
}
