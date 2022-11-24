#include "terminal_colors.h"

#include <stdio.h>

void terminal_set_color_RGB(unsigned char R, unsigned char G, unsigned char B)
{
    fprintf(stdout, "\033[38;2;%hhu;%hhu;%hhum", R, G, B);
}

void terminal_set_bold(void)
{
    fputs("\033[1m", stdout);
}

void terminal_reset_color(void)
{
    fputs(COLOR_NORMAL, stdout);
}

