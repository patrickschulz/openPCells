#include "terminal.h"

#include <stdio.h>

void terminal_cursor_visibility(int visible)
{
    const char* str;
    if(visible)
    {
        str = TERMINAL_CSI "?25h";
    }
    else
    {
        str = TERMINAL_CSI "?25l";
    }
    fputs(str, stdout);
}

void terminal_set_foreground_color_RGB(unsigned char R, unsigned char G, unsigned char B)
{
    const char* str = TERMINAL_CSI "38;2;%hhu;%hhu;%hhu" TERMINAL_COLOR_END;
    fprintf(stdout, str, R, G, B);
}

void terminal_set_background_color_RGB(unsigned char R, unsigned char G, unsigned char B)
{
    const char* str = TERMINAL_CSI "48;2;%hhu;%hhu;%hhu" TERMINAL_COLOR_END;
    fprintf(stdout, str, R, G, B);
}

void terminal_set_bold(void)
{
    const char* str = TERMINAL_CSI "1m";
    fputs(str, stdout);
}

void terminal_reset_color(void)
{
    fputs(COLOR_NORMAL, stdout);
}

void terminal_reset_all(void)
{
    // make cursor visible
    const char* str = TERMINAL_CSI "?25h";
    fputs(str, stdout);
    // reset color
    terminal_reset_color();
}

void terminal_clear_screen(void)
{
    const char* str = TERMINAL_CSI TERMINAL_CLEAR_SCREEN TERMINAL_CSI TERMINAL_CURSOR_0;
    fputs(str, stdout);
}

void terminal_cursor_line_up(unsigned int lines)
{
    fputs(TERMINAL_CSI, stdout);
    fprintf(stdout, "%u", lines);
    fputs(TERMINAL_CURSOR_UP, stdout);
}
