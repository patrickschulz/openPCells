#include "terminal.h"

#include <stdio.h>

void terminal_set_color_RGB(unsigned char R, unsigned char G, unsigned char B)
{
    const char* str = TERMINAL_CSI "38;2;%hhu;%hhu;%hhu" TERMINAL_COLOR_END;
    fprintf(stdout, str, R, G, B);
}

void terminal_set_bold(void)
{
    fputs("\033[1m", stdout);
}

void terminal_reset_color(void)
{
    fputs(COLOR_NORMAL, stdout);
}

void terminal_clear_screen(void)
{
    const char* str = TERMINAL_CSI TERMINAL_CLEAR_SCREEN TERMINAL_CSI TERMINAL_CURSOR_0;
    fputs(str, stdout);
}
