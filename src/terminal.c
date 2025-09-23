#include "terminal.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static void _puts(const char* str)
{
    write(STDOUT_FILENO, str, strlen(str));
}

int terminal_get_screen_size(int* rows, int* columns)
{
    _puts(TERMINAL_CSI "999B" TERMINAL_CSI "999C");
    _puts(TERMINAL_CSI "6n");
    int rownum = 0;
    int colnum = 0;
    char buf[32];
    memset(buf, 0, 32);
    size_t i = 0;
    while(1)
    {
        // \x1b [ <rr> ; <cc> R
        char ch;
        if(read(STDIN_FILENO, &ch, 1) == -1)
        {
            return 0;
        }
        if(ch == '[')
        {
            rownum = 1;
        }
        else if(ch == ';')
        {
            *rows = atoi(buf);
            memset(buf, 0, 32);
            i = 0;
            rownum = 0;
            colnum = 1;
        }
        else if(ch == 'R')
        {
            *columns = atoi(buf);
            rownum = 0;
            colnum = 0;
            break;
        }
        else if(rownum || colnum)
        {
            buf[i] = ch;
            ++i;
        }
    }
    return 1;
}

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
    _puts(str);
}

void terminal_save_cursor_position(void)
{
    const char* str = TERMINAL_CSI "s";
    _puts(str);
}

void terminal_restore_cursor_position(void)
{
    const char* str = TERMINAL_CSI "u";
    _puts(str);
}

void terminal_set_reverse_color(void)
{
    const char* str = TERMINAL_CSI "7" TERMINAL_CSI_END;
    _puts(str);
}

void terminal_set_non_reverse_color(void)
{
    const char* str = TERMINAL_CSI "27" TERMINAL_CSI_END;
    _puts(str);
}

void terminal_set_non_bold(void)
{
    const char* str = TERMINAL_CSI "22" TERMINAL_CSI_END;
    _puts(str);
}

void terminal_set_foreground_color_RGB(unsigned char R, unsigned char G, unsigned char B)
{
    const char* str = TERMINAL_CSI "38;2;%hhu;%hhu;%hhu" TERMINAL_CSI_END;
    fprintf(stdout, str, R, G, B);
    fflush(stdout);
}

void terminal_set_background_color_RGB(unsigned char R, unsigned char G, unsigned char B)
{
    const char* str = TERMINAL_CSI "48;2;%hhu;%hhu;%hhu" TERMINAL_CSI_END;
    fprintf(stdout, str, R, G, B);
    fflush(stdout);
}

void terminal_set_bold(void)
{
    const char* str = TERMINAL_CSI "1" TERMINAL_CSI_END;
    _puts(str);
}

void terminal_set_half_bright(void)
{
    const char* str = TERMINAL_CSI "2" TERMINAL_CSI_END;
    _puts(str);
}

void terminal_reset_color(void)
{
    _puts(COLOR_NORMAL);
}

void terminal_reset_foreground_color(void)
{
    _puts(FOREGROUND_COLOR_NORMAL);
}

void terminal_reset_background_color(void)
{
    _puts(BACKGROUND_COLOR_NORMAL);
}

void terminal_reset_all(void)
{
    // make cursor visible
    const char* str = TERMINAL_CSI "?25h";
    _puts(str);
    // reset color
    terminal_reset_color();
}

void terminal_clear_screen(void)
{
    const char* str = TERMINAL_CSI TERMINAL_CLEAR_SCREEN TERMINAL_CSI TERMINAL_CURSOR_0;
    _puts(str);
}

void terminal_cursor_set_position(unsigned int row, unsigned int columns)
{
    fprintf(stdout, TERMINAL_CSI "%d;%d" TERMINAL_CURSOR_MOVE, row, columns);
    fflush(stdout);
}

void terminal_cursor_line_up(unsigned int lines)
{
    _puts(TERMINAL_CSI);
    fprintf(stdout, "%u", lines);
    fflush(stdout);
    _puts(TERMINAL_CURSOR_UP);
}

void terminal_cursor_line_down(unsigned int lines)
{
    _puts(TERMINAL_CSI);
    fprintf(stdout, "%u", lines);
    fflush(stdout);
    _puts(TERMINAL_CURSOR_DOWN);
}

void terminal_cursor_move_left(unsigned int columns)
{
    _puts(TERMINAL_CSI);
    fprintf(stdout, "%u", columns);
    fflush(stdout);
    _puts(TERMINAL_CURSOR_LEFT);
}

void terminal_cursor_move_first_column(void)
{
    _puts(TERMINAL_CSI TERMINAL_CURSOR_FIRST_COLUMN);
}
