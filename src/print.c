#include <ctype.h>
#include <stdio.h>
#include <string.h>

#ifdef TERMOGRAPHY_ENABLE_TERM_WIDTH
#include <sys/ioctl.h>
#include <err.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#endif

unsigned int print_get_screen_width(void)
{
#ifdef TERMOGRAPHY_ENABLE_TERM_WIDTH
    struct winsize ws;
    int fd;

    fd = open("/dev/tty", O_RDWR);
    if(fd < 0 || ioctl(fd, TIOCGWINSZ, &ws) < 0)
    {
        return 80; /* fall back to 80 in case of errors */
    }

    close(fd);

    return ws.ws_col;
#else
    return 80;
#endif
}

static void _print_sep(unsigned int num)
{
    unsigned int i;
    for(i = 0; i < num; ++i)
    {
        putchar(' ');
    }
}

static void _put_line(const char* ch, const char* lastspace)
{
    while(ch < lastspace)
    {
        putchar(*ch);
        ++ch;
    }
}

void print_wrapped_paragraph(const char* text, unsigned int textwidth, unsigned int leftmargin)
{
    if(textwidth == 0) /* auto-width mode */
    {
        textwidth = print_get_screen_width() - leftmargin;
    }
    /* the first line does not indent and does not skip space characters at the beginning */
    int firstline = 1;
    /* non-printed text pointer */
    const char* ch = text;
    while(*ch)
    {
        /* skip to first non-space character (not on the first line) */
        if(!firstline)
        {
            while(*ch && isspace(*ch))
            {
                ++ch;
            }
        }
        /* find last space that fits on a line */
        const char* lastspace = ch;
        const char* ptr = ch;
        while(1)
        {
            /* end of text */
            if(!*ptr)
            {
                lastspace = ptr;
                break;
            }
            /* end of line (line larger than text width) */
            if((ptr - ch) > textwidth)
            {
                break;
            }
            /* possible break point */
            if(isspace(*ptr))
            {
                lastspace = ptr;
            }
            ++ptr;
        }
        /* with long strings without spaces it is possible
         * that no break point was found, fix or this goes
         * into an endless loop */
        if(lastspace == ch)
        {
            lastspace = ptr - 1;
        }
        /* all non-first lines are indented */
        if(!firstline)
        {
            _print_sep(leftmargin);
        }
        /* write line until lastspace */
        _put_line(ch, lastspace);
        putchar('\n');
        firstline = 0;
        ch = lastspace;
    }
}

void print_wrapped_paragraph_with_header(const char* header, const char* text, unsigned int textwidth)
{
    fputs(header, stdout);
    print_wrapped_paragraph(text, textwidth, strlen(header));
}

