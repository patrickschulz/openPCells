#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <termios.h>
#include <unistd.h>

#include "_config.h"
#include "main.functions.h"
#include "print.h"
#include "string.h"
#include "strprint.h"
#include "tagged_value.h"
#include "technology.h"
#include "terminal.h"
#include "util.h"

#define MAX_SCREEN_WIDTH 120
#define MAX_SCREEN_HEIGHT 28
#define SIDE_PANEL_WIDTH 40
#define SIDE_PANEL_GAP 2
#define PROMPT_LINE_OFFSET 0
#define STATUS_LINE_OFFSET 1
#define DRAW_PANEL_LINES 1

#define KEY_CODE_A 1
#define KEY_CODE_B 2
#define KEY_CODE_C 3
#define KEY_CODE_D 4
#define KEY_CODE_E 5
#define KEY_CODE_F 6
#define KEY_CODE_G 7
#define KEY_CODE_H 8
#define KEY_CODE_I 9
#define KEY_CODE_J 10
#define KEY_CODE_K 11
#define KEY_CODE_L 12
#define KEY_CODE_M 13
#define KEY_CODE_N 14
#define KEY_CODE_O 15
#define KEY_CODE_P 16
#define KEY_CODE_Q 17
#define KEY_CODE_R 18
#define KEY_CODE_S 19
#define KEY_CODE_T 20
#define KEY_CODE_U 21
#define KEY_CODE_V 22
#define KEY_CODE_W 23
#define KEY_CODE_X 24
#define KEY_CODE_Y 25
#define KEY_CODE_Z 26
#define KEY_CODE_ESC 27
#define KEY_CODE_ENTER 13
#define KEY_CODE_UP 28
#define KEY_CODE_DOWN 29
#define KEY_CODE_LEFT 30
#define KEY_CODE_RIGHT 31

#define ATTRIBUTE_NORMAL    0
#define ATTRIBUTE_BOLD      1
#define ATTRIBUTE_REVERSE   2
#define ATTRIBUTE_COLOR     4

// module-global terminal settings for restoring
static struct termios old_settings;

enum mode {
    NONE,
    SETTINGS,
    GENERAL,
    FEOL,
    SUBSTRATE_WELL,
    METALSTACK,
};

struct rchar {
    unsigned char r;
    unsigned char g;
    unsigned char b;
    int attribute;
    char character;
};

struct state {
    enum mode mode;
    // generic info
    char* techname;
    int ask_layer_name;
    int ask_gds;
    int ask_skill;
    // status
    int finished_primary_FEOL;
    int finished_secondary_FEOL;
    int finished_wells;
    int finished_BEOL;
    int finished_metal_stack;
    int finished_vias;
    int finished_lvsdrc;
    int finished_constraints;
    int finished_auxiliary;
    // terminal stuff
    int rows;
    int columns;
    int xstart;
    int xend;
    int ystart;
    int yend;
    int pos;
    int attribute;
    unsigned char r;
    unsigned char g;
    unsigned char b;
    struct rchar* current_content;
    struct rchar* next_content;
    // actual technology state
    struct technology_state* techstate;
};

static void _set_attributes(struct state* state, int index)
{
    struct rchar* rch = state->next_content + index;
    int attribute = rch->attribute;
    if(attribute & ATTRIBUTE_BOLD)
    {
        terminal_set_bold();
    }
    else
    {
        terminal_set_non_bold();
    }
    if(attribute & ATTRIBUTE_REVERSE)
    {
        terminal_set_reverse_color();
    }
    else
    {
        terminal_set_non_reverse_color();
    }
    if(attribute & ATTRIBUTE_COLOR)
    {
        terminal_set_foreground_color_RGB(rch->r, rch->g, rch->b);
    }
    else
    {
        terminal_reset_foreground_color();
    }
}

static int _is_equal(struct rchar* current, struct rchar* next, int i)
{
    return (current + i)->character == (next + i)->character &&
           (current + i)->attribute == (next + i)->attribute &&
           (current + i)->r == (next + i)->r &&
           (current + i)->g == (next + i)->g &&
           (current + i)->b == (next + i)->b;
}

static void _write_to_display(struct state* state)
{
    for(int i = 0; i < state->rows * state->columns; ++i)
    {
        if(!_is_equal(state->current_content, state->next_content, i))
        {
            int row = i / state->columns;
            int column = i % state->columns;
            terminal_cursor_set_position(row + 1, column + 1);
            _set_attributes(state, i);
            write(STDOUT_FILENO, &(state->next_content + i)->character, 1);
            state->current_content[i] = state->next_content[i];
        }
    }
}

static void _set_position(struct state* state, int row, int column)
{
    state->pos = (row - 1) * state->columns + column - 1;
}

static void _write_len(struct state* state, const char* str, size_t len)
{
    for(size_t i = 0; i < len; ++i)
    {
        struct rchar* rch = state->next_content + state->pos + i;
        rch->character = str[i];
        rch->attribute = state->attribute;
        rch->r = state->r;
        rch->g = state->g;
        rch->b = state->b;
    }
    state->pos += len;
}

static void _write(struct state* state, const char* str)
{
    size_t len = strlen(str);
    _write_len(state, str, len);
}

static void _write_at(struct state* state, const char* str, int row, int column)
{
    _set_position(state, row, column);
    _write(state, str);
}

static void _write_len_at(struct state* state, const char* str, size_t len, int row, int column)
{
    _set_position(state, row, column);
    _write_len(state, str, len);
}

static void _set_bold(struct state* state)
{
    state->attribute |= ATTRIBUTE_BOLD;
}

static void _reset_bold(struct state* state)
{
    state->attribute &= ~ATTRIBUTE_BOLD;
}

/*
static void _set_reverse(struct state* state)
{
    state->attribute |= ATTRIBUTE_REVERSE;
}

static void _reset_reverse(struct state* state)
{
    state->attribute &= ~ATTRIBUTE_REVERSE;
}
*/

static void _set_color_RGB(struct state* state, unsigned char r, unsigned char g, unsigned char b)
{
    state->r = r;
    state->g = g;
    state->b = b;
    state->attribute |= ATTRIBUTE_COLOR;
}

static void _reset_color(struct state* state)
{
    state->attribute &= ~ATTRIBUTE_COLOR;
}

static void _set_to_blank(struct state* state)
{
    for(int i = 0; i < state->rows * state->columns; ++i)
    {
        struct rchar* rch = state->next_content + i;
        rch->character = ' ';
        rch->attribute = ATTRIBUTE_NORMAL;
    }
}

static void _save_state(struct state* state)
{
    if(state->techstate) // techstate might not be initialized if an early ctrl-c occurs
    {
        technology_write_definition_files(state->techstate, "_assistant_tech");
    }
}

static void _print(struct state* state, int row, int column, const char* str, size_t len)
{
    _write_len_at(state, str, len, row, column);
    _write_to_display(state);
}

static void _draw_status(struct state* state, const char* text)
{
    terminal_save_cursor_position();
    _set_color_RGB(state, 255, 0, 0);
    _write_at(state, text, state->yend - STATUS_LINE_OFFSET, state->xstart);
    _reset_color(state);
    _write_to_display(state);
    terminal_restore_cursor_position();
}

static void _clear_status(struct state* state)
{
    for(int i = state->xstart; i < state->xend - SIDE_PANEL_WIDTH; ++i)
    {
        _write_at(state, " ", state->yend - STATUS_LINE_OFFSET, i);
    }
    _write_to_display(state);
}

static int _getchar(struct state* state)
{
    char ch;
    while(1)
    {
        int num = read(STDIN_FILENO, &ch, 1);
        if(num == -1)
        {
            terminal_clear_screen();
            terminal_reset_all();
            tcsetattr(STDOUT_FILENO, TCSAFLUSH, &old_settings);
            exit(1);
        }
        if(num > 0)
        {
            break;
        }
    }
    if(ch == KEY_CODE_C) // ctrl-c
    {
        terminal_clear_screen();
        terminal_reset_all();
        tcsetattr(STDOUT_FILENO, TCSAFLUSH, &old_settings);
        _save_state(state);
        exit(0);
    }
    if(ch == KEY_CODE_ESC)
    {
        char buf[2];
        if(read(STDIN_FILENO, buf, 1) == 0)
        {
            return KEY_CODE_ESC;
        }
        if(read(STDIN_FILENO, buf + 1, 1) == 0)
        {
            return KEY_CODE_ESC;
        }
        if(buf[0] == '[') // escape sequency with '['
        {
            switch(buf[1])
            {
                case 'A': return KEY_CODE_UP;
                case 'B': return KEY_CODE_DOWN;
                case 'C': return KEY_CODE_RIGHT;
                case 'D': return KEY_CODE_LEFT;
            }
            return KEY_CODE_ESC;
        }
        else
        {
            return KEY_CODE_ESC;
        }
    }
    else
    {
        return ch;
    }
}

static void _clear_prompt(struct state* state)
{
    int endpos = state->xend - SIDE_PANEL_WIDTH - SIDE_PANEL_GAP - 2;
    for(int i = state->xstart; i <= endpos; ++i)
    {
        _write_at(state, " ", state->yend - PROMPT_LINE_OFFSET, i);
    }
}

static const char* _get_string(struct state* state, const char* prefill)
{
    terminal_reset_color();
    terminal_set_non_bold();
    terminal_set_non_reverse_color();
    _reset_color(state);
    _reset_bold(state);
    int column = state->xstart + 3;
    int row = state->yend - PROMPT_LINE_OFFSET;
    int endpos = state->xend - SIDE_PANEL_WIDTH - SIDE_PANEL_GAP - 2;
    for(int i = column; i <= endpos; ++i)
    {
        _write_at(state, "_", row, i);
    }
    _write_at(state, ">", row, state->xstart + 1);
    _write_to_display(state);

    terminal_cursor_set_position(row, state->xstart + 3);
    terminal_cursor_visibility(1);
    static char buf[256];
    memset(buf, 0, 256);
    size_t i = 0;
    if(prefill)
    {
        strcpy(buf, prefill);
        i = strlen(prefill);
    }
    _print(state, row, column, buf, i);
    while(1)
    {
        int ch = _getchar(state);
        terminal_cursor_visibility(0);
        _clear_status(state);
        terminal_cursor_visibility(1);
        if(ch == KEY_CODE_ENTER)
        {
            if(i > 0)
            {
                break;
            }
            else
            {
                terminal_cursor_visibility(0);
                _draw_status(state, "given answer must not be empty");
                terminal_cursor_set_position(row, state->xstart + 3 + i);
                terminal_cursor_visibility(1);
            }
        }
        else if(ch == 127) // backspace
        {
            if(i > 0)
            {
                --i;
                _write_at(state, "_", row, state->xstart + 3 + i);
                _write_to_display(state);
                terminal_cursor_set_position(row, state->xstart + 3 + i);
            }
            buf[i] = 0;
        }
        else
        {
            buf[i] = ch;
            ++i;
        }
        _print(state, row, column, buf, i);
    }
    terminal_cursor_visibility(0);
    _clear_prompt(state);
    _write_to_display(state);
    return buf;
}

static void _write_tech_entry_boolean(struct state* state, const char* key, int value)
{
    if(value)
    {
        _set_color_RGB(state, 0, 180, 0);
        _write(state, "[x] ");
    }
    else
    {
        _set_color_RGB(state, 255, 0, 0);
        _write(state, "[ ] ");
    }
    _write(state, key);
    _reset_color(state);
}

static void _write_tech_entry_string(struct state* state, const char* key, const char* value)
{
    _write(state, key);
    _write(state, ": ");
    if(value)
    {
        _write(state, value);
    }
}

static void _write_tech_entry_integer(struct state* state, const char* key, int value)
{
    struct string* str = string_create();
    string_add_string(str, key);
    string_add_string(str, ": ");
    if(value > 0)
    {
        strprint_integer(str, value);
    }
    _write(state, string_get(str));
    string_destroy(str);
}

static void _draw_panel(struct state* state, int xl, int xr, int yt, int yb, const char* title)
{
    if(DRAW_PANEL_LINES)
    {
        // corners
        //_write(state, "┌");
        _write_at(state, "+", yt, xl);
        //_write(state, "└");
        _write_at(state, "+", yb, xl);
        //_write(state, "┐");
        _write_at(state, "+", yt, xr);
        //_write(state, "┘");
        _write_at(state, "+", yb, xr);
        // left/right line
        for(int i = yt + 1; i <= yb - 1; ++i)
        {
            //_write(state, "│");
            _write_at(state, "|", i, xl);
            //_write(state, "│");
            _write_at(state, "|", i, xr);
        }
        // top/bottom line
        for(int i = xl + 1; i <= xr - 1; ++i)
        {
            //_write(state, "─");
            _write_at(state, "-", yt, i);
            //_write(state, "─");
            _write_at(state, "-", yb, i);
        }
        if(title)
        {
            // title line
            for(int i = xl + 1; i <= xr - 1; ++i)
            {
                //_write(state, "─");
                _write_at(state, "-", yt + 2, i);
            }
            // title line "corners" (purposely overwrites the previously characters)
            //_write(state, "├");
            _write_at(state, "*", yt + 2, xl);
            //_write(state, "┤");
            _write_at(state, "*", yt + 2, xr);
        }
    }
    // title
    if(title)
    {
        _set_position(state, state->ystart + 1, xl + (xr - xl + 2 - strlen(title)) / 2);
        _set_bold(state);
        _write(state, title);
        _reset_bold(state);
    }
}

static void _draw_panel_line(struct state* state, int startpos, int endpos, int row)
{
    for(int i = startpos + 2; i <= endpos - 2; ++i)
    {
        //_write(state, "─");
        _write_at(state, "-", row, i);
    }
}

static void _draw_panel_section(struct state* state, int startpos, int endpos, int row, int numrows, const char* title)
{
    // top line
    _draw_panel_line(state, startpos, endpos, row);
    // bottom line
    (void)numrows;
    //_draw_panel_line(startpos, endpos, row + numrows);
    _set_position(state, row, startpos + (endpos - startpos + 2 - strlen(title)) / 2);
    _set_bold(state);
    _write(state, title);
    _reset_bold(state);
}

static void _clear_side_panel(struct state* state)
{
    int xstart = state->xend - SIDE_PANEL_WIDTH;
    int xend = state->xend;
    int ystart = state->ystart;
    int yend = state->yend - 1;
    for(int i = xstart; i <= xend; ++i)
    {
        for(int j = ystart; j <= yend; ++j)
        {
            _set_position(state, j, i);
            _write(state, " ");
        }
    }
}

static void _show_metal(struct state* state, unsigned int i, int* ycurrent, int startpos)
{
    // write metal %d:
    struct string* str = string_create();
    string_add_string(str, "Metal ");
    strprint_integer(str, i);
    string_add_character(str, ':');
    char* metal = string_dissolve(str);
    _write_at(state, metal, *ycurrent, startpos + 3);

    size_t len = 1 + util_num_digits(i);
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "M%d", i);
    const struct generics* layer = technology_get_layer(state->techstate, layername);
    free(layername);
    if(state->ask_gds)
    {
        _write_at(state, "  GDS: ", *ycurrent + 1, startpos + 3);
        if(layer)
        {
            const struct hashmap* layerdata = generics_get_layer_data(layer, "gds");
            if(layerdata)
            {
                const struct tagged_value* vl = hashmap_get_const(layerdata, "layer");
                const struct tagged_value* vp = hashmap_get_const(layerdata, "purpose");
                if(vl)
                {
                    int layernum = tagged_value_get_integer(vl);
                    int purposenum = tagged_value_get_integer(vp);
                    str = string_create();
                    strprint_integer(str, layernum);
                    string_add_character(str, '/');
                    strprint_integer(str, purposenum);
                    char* gds = string_dissolve(str);
                    _write(state, gds);
                }
            }
        }
        ++(*ycurrent);
    }
    if(state->ask_skill)
    {
        _write_at(state, "  SKILL: ", *ycurrent + 1, startpos + 3);
        if(layer)
        {
            const struct hashmap* layerdata = generics_get_layer_data(layer, "SKILL");
            if(layerdata)
            {
                const struct tagged_value* vl = hashmap_get_const(layerdata, "layer");
                const struct tagged_value* vp = hashmap_get_const(layerdata, "purpose");
                if(vl)
                {
                    const char* layerstr = tagged_value_get_const_string(vl);
                    const char* purposestr = tagged_value_get_const_string(vp);
                    str = string_create();
                    string_add_string(str, layerstr);
                    string_add_character(str, '/');
                    string_add_string(str, purposestr);
                    char* skill = string_dissolve(str);
                    _write(state, skill);
                }
            }
        }
        ++(*ycurrent);
    }
    if(state->ask_layer_name)
    {
        _write_at(state, "  name: ", *ycurrent + 1, startpos + 3);
        if(layer)
        {
            const char* prettyname = generics_get_layer_pretty_name(layer);
            if(prettyname)
            {
                _write(state, prettyname);
            }
        }
        ++(*ycurrent);
    }
}

static void _draw_side_panel(struct state* state)
{
    _clear_side_panel(state);
    int startpos = state->xend - SIDE_PANEL_WIDTH;
    _draw_panel(state, startpos, state->xend, state->ystart, state->yend, "Information");
    _set_position(state, state->ystart + 3, startpos + 3);
    _write_tech_entry_string(state, "Library Name", state->techname);
    int ycurrent = state->ystart + 4; // first entries start at row 4
    if(state->mode == GENERAL)
    {
        _draw_panel_section(state, startpos, state->xend, ycurrent, 3, "Technology Status");
        ++ycurrent;
        _write_at(state, "Layers: 0 / 42", ycurrent, startpos + 3);
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "Primary FEOL", state->finished_primary_FEOL);
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "Secondary FEOL", state->finished_secondary_FEOL);
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "Wells", state->finished_wells);
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "BEOL", state->finished_BEOL);
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "Metal Stack", state->finished_metal_stack);
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "Via Geometries", state->finished_vias);
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "LVS/DRC Layers", state->finished_lvsdrc);
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "Auxiliary Layers", state->finished_auxiliary);
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "Size Constraints", state->finished_constraints);
        ++ycurrent;
    }
    // settings information
    if(state->mode == SETTINGS)
    {
        _draw_panel_section(state, startpos, state->xend, ycurrent, 3, "Assistant Settings");
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "Ask Layer Name", state->ask_layer_name);
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "Ask GDS", state->ask_gds);
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_boolean(state, "Ask SKILL", state->ask_skill);
        ++ycurrent;
    }
    // general FEOL handling
    if(state->mode == FEOL)
    {
        _draw_panel_section(state, startpos, state->xend, ycurrent, 3, "FEOL");
        ++ycurrent;
    }
    // substrate and wells
    if(state->mode == SUBSTRATE_WELL)
    {
        _draw_panel_section(state, startpos, state->xend, ycurrent, 3, "Substrate/Wells");
        ++ycurrent;
    }
    // metal stack
    if(state->mode == METALSTACK)
    {
        // metals
        _draw_panel_section(state, startpos, state->xend, ycurrent, 3, "Metal Stack");
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        unsigned int nummetals = technology_get_num_metals(state->techstate);
        _write_tech_entry_integer(state, "Number of Metal Layers", nummetals);
        ++ycurrent;
        if(nummetals > 0)
        {
            for(unsigned int i = 1; i <= nummetals; ++i)
            {
                _show_metal(state, i, &ycurrent, startpos);
                ++ycurrent;
            }
        }
        // vias
        //_draw_panel_section(state, startpos, state->xend, ycurrent, 3, "Via Geometries");
        ++ycurrent;
    }
    // control info
    //_set_position(state, state->yend - 2, startpos + 2);
    //fputs("CTRL-S: Save Current State", stdout);
    //_set_position(state, state->yend - 1, startpos + 2);
    //fputs("CTRL-C: Abort Program", stdout);
    //fflush(stdout);
}
        
static void _draw_lines(struct state* state, const char* const* lines)
{
    int xstart = state->xstart;
    int ystart = state->ystart;
    int lineindex = 0;
    while(*lines)
    {
        const char* line = *lines;
        _set_position(state, ystart + lineindex, xstart + 2);
        _write(state, line);
        ++lineindex;
        ++lines;
    }
}

static void _draw_full_text(struct state* state, const char* const* text, const char* section)
{
    int xstart = state->xstart;
    int xend = state->xend;
    int textwidth = xend - xstart - 4;
    const char* const* lines = text;
    // set up panel
    size_t totallines = 2; // 2 lines for the title
    while(*lines)
    {
        if(**lines == 0) // empty string, skip a physical line
        {
            ++totallines;
        }
        else
        {
            char** wrapped = print_split_in_wrapped_lines(*lines, textwidth);
            // count wrapped lines
            char** line = wrapped;
            while(*line)
            {
                ++totallines;
                ++line;
            }
        }
        ++lines;
    }
    // draw panel
    int ystart = state->ystart;
    int yend = ystart + totallines + 1;
    _draw_panel(state, xstart, xend, ystart, yend, section);
    // draw text
    int ystarttext = ystart + 2; // 2 lines for the title
    size_t lineindex = 0;
    lines = text;
    while(*lines)
    {
        if(**lines == 0) // empty line, skip one physical line
        {
            ++lineindex;
        }
        else
        {
            char** wrapped = print_split_in_wrapped_lines(*lines, textwidth);
            // count wrapped lines
            int numlines = 0;
            char** line = wrapped;
            while(*line)
            {
                ++numlines;
                ++line;
            }
            // write out lines
            line = wrapped;
            size_t i = 0;
            while(*line)
            {
                _set_position(state, ystarttext + lineindex + 1 + i, xstart + 2);
                _write(state, *line);
                ++i;
                ++line;
            }
            lineindex += numlines;
        }
        ++lines;
    }
}

static void _clear_main_area(struct state* state)
{
    int xstart = state->xstart;
    int xend = state->xend - SIDE_PANEL_WIDTH - SIDE_PANEL_GAP - 1;
    int ystart = state->ystart;
    int yend = state->yend;
    for(int i = xstart; i <= xend; ++i)
    {
        for(int j = ystart; j <= yend; ++j)
        {
            _write_at(state, " ", j, i);
        }
    }
}

static void _draw_main_text(struct state* state, const char* const* text, const char* section)
{
    _clear_main_area(state);
    int xstart = state->xstart;
    int xend = state->xend - SIDE_PANEL_WIDTH - SIDE_PANEL_GAP - 1;
    int textwidth = xend - xstart - 4;
    const char* const* lines = text;
    // set up panel
    size_t totallines = 2; // 2 lines for the title
    while(*lines)
    {
        if(**lines == 0) // empty string, skip a physical line
        {
            ++totallines;
        }
        else
        {
            char** wrapped = print_split_in_wrapped_lines(*lines, textwidth);
            // count wrapped lines
            char** line = wrapped;
            while(*line)
            {
                ++totallines;
                ++line;
            }
        }
        ++lines;
    }
    // draw panel
    int ystart = state->ystart;
    int yend = ystart + totallines + 1;
    _draw_panel(state, xstart, xend, ystart, yend, section);
    // draw text
    int ystarttext = ystart + 2; // 2 lines for the title
    size_t lineindex = 0;
    lines = text;
    while(*lines)
    {
        if(**lines == 0) // empty line, skip one physical line
        {
            ++lineindex;
        }
        else
        {
            char** wrapped = print_split_in_wrapped_lines(*lines, textwidth);
            // count wrapped lines
            int numlines = 0;
            char** line = wrapped;
            while(*line)
            {
                ++numlines;
                ++line;
            }
            // write out lines
            line = wrapped;
            size_t i = 0;
            while(*line)
            {
                _set_position(state, ystarttext + lineindex + 1 + i, xstart + 2);
                _write(state, *line);
                ++i;
                ++line;
            }
            lineindex += numlines;
        }
        ++lines;
    }
}

static void _draw_main_text_single(struct state* state, const char* text, const char* section)
{
    static const char* lines[] = {
        NULL,
        NULL
    };
    lines[0] = text;
    _draw_main_text(state, lines, section);
}

static int _menu(struct state* state, int row, int column, const char** choices, size_t len)
{
    size_t index = 0;
    while(1)
    {
        for(size_t i = 0; i < len; ++i)
        {
            if(i == index)
            {
                _write_at(state, "* ", row - len + i + 1, column);
            }
            else
            {
                _write_at(state, "  ", row - len + i + 1, column);
            }
            _write_at(state, choices[i], row - len + i + 1, column + 2);
        }
        _write_to_display(state);
        int ch = _getchar(state);
        if(ch == KEY_CODE_ENTER)
        {
            return index;
        }
        if(ch == KEY_CODE_UP)
        {
            if(index > 0)
            {
                index -= 1;
            }
        }
        if(ch == KEY_CODE_DOWN)
        {
            index += 1;
            if(index >= len)
            {
                index = len - 1;
            }
        }
    }
}

static int _draw_main_text_single_prompt_menu(struct state* state, const char* text, const char** choices, size_t len, const char* section)
{
    _draw_main_text_single(state, text, section);
    int row = state->yend;
    int column = state->xstart;
    int selection = _menu(state, row, column, choices, len);
    return selection;
}

static char* _draw_main_text_single_prompt_string(struct state* state, const char* text, const char* prompt, const char* section)
{
    _draw_main_text_single(state, text, section);
    char* str = util_strdup(_get_string(state, prompt));
    return str;
}

static int _draw_main_text_single_prompt_boolean_yes(struct state* state, const char* text, const char* section)
{
    const char* choices[] = {
        "yes",
        "no",
    };
    size_t len = sizeof(choices) / sizeof(choices[0]);
    int choice = _draw_main_text_single_prompt_menu(state, text, choices, len, section);
    return choice == 0;
}

static int _draw_main_text_single_prompt_boolean_no(struct state* state, const char* text, const char* section)
{
    const char* choices[] = {
        "yes",
        "no",
    };
    size_t len = sizeof(choices) / sizeof(choices[0]);
    int choice = _draw_main_text_single_prompt_menu(state, text, choices, len, section);
    return choice == 0;
}

static int _draw_main_text_single_prompt_boolean(struct state* state, const char* text, const char* section)
{
    _draw_main_text_single(state, text, section);
    _set_position(state, state->yend, 1);
    int endpos = state->xend - SIDE_PANEL_WIDTH - SIDE_PANEL_GAP - 2;
    for(int i = 1; i <= endpos; ++i)
    {
        _write(state, " ");
    }
    char* p = util_strdup("");
    const char* str;
    while(1)
    {
        str = _get_string(state, p);
        free(p);
        p = util_strdup(str);
        if((strcmp(str, "yes") == 0) || (strcmp(str, "no") == 0))
        {
            break;
        }
        terminal_cursor_visibility(0);
        _draw_status(state, "given answer must be 'yes' or 'no'");
        terminal_cursor_visibility(1);
    }
    return strcmp(str, "yes") == 0;
}

static int _get_integer(struct state* state, const char* prompt)
{
    _set_position(state, state->yend, 1);
    int endpos = state->xend - SIDE_PANEL_WIDTH - SIDE_PANEL_GAP - 2;
    for(int i = 1; i <= endpos; ++i)
    {
        _write(state, " ");
    }
    char* p = util_strdup(prompt);
    const char* str;
    int number;
    while(1)
    {
        str = _get_string(state, p);
        free(p);
        p = util_strdup(str);
        char* endptr;
        number = strtoul(str, &endptr, 10);
        if(*endptr == 0) // entire string valid
        {
            break;
        }
        _draw_status(state, "given answer must be a number (without any extra characters)");
    }
    return number;
}

static int _get_character(struct state* state, const char* prompt)
{
    _set_position(state, state->yend, 1);
    int endpos = state->xend - SIDE_PANEL_WIDTH - SIDE_PANEL_GAP - 2;
    for(int i = 1; i <= endpos; ++i)
    {
        _write(state, " ");
    }
    char* p = util_strdup(prompt);
    const char* str;
    while(1)
    {
        str = _get_string(state, p);
        free(p);
        p = util_strdup(str);
        if(strlen(str) == 1) // only one character
        {
            break;
        }
        _draw_status(state, "given answer must be a only one character");
    }
    return str[0];
}

static int _draw_main_text_single_prompt_integer(struct state* state, const char* text, const char* prompt, const char* section)
{
    _draw_main_text_single(state, text, section);
    int number = _get_integer(state, prompt);
    return number;
}

static void _clear_all(struct state* state)
{
    _set_to_blank(state);
}

static void _wait_for_enter(struct state* state)
{
    while(1)
    {
        int ch = _getchar(state);
        if(ch == KEY_CODE_ENTER)
        {
            break;
        }
    }
}

// forward declaration for different compiler versions
void cfmakeraw(struct termios*);

static void _draw_all(struct state* state)
{
    _clear_main_area(state);
    _draw_side_panel(state);
    _write_to_display(state);
}

static int _setup_terminal(struct state* state)
{
    // set up terminal
    int fd;
    fd = open("/dev/tty", O_RDWR);
    if(fd < 1)
    {
        return -1;
        puts("could not open file descriptor");
    }
    struct termios termios;
    int ret = tcgetattr(fd, &termios);
    old_settings = termios; // copy for restoring the old state
    if(ret != 0)
    {
        puts("could not retrieve terminal state");
        exit(1);
    }
    // make raw, with time-out
    cfmakeraw(&termios);
    termios.c_cc[VMIN] = 0;
    termios.c_cc[VTIME] = 1;
    tcsetattr(fd, TCSAFLUSH, &termios);
    terminal_cursor_visibility(0);
    terminal_get_screen_size(&state->rows, &state->columns);
    int xpadding = (state->columns - MAX_SCREEN_WIDTH) / 2;
    if(xpadding < 0)
    {
        xpadding = 0;
    }
    state->xstart = 1 + xpadding;
    state->xend = state->columns - xpadding;
    int ypadding = (state->rows - MAX_SCREEN_HEIGHT) / 2;
    if(ypadding < 0)
    {
        ypadding = 0;
    }
    state->ystart = 1 + ypadding;
    state->yend = state->rows - ypadding;
    return fd;
}

static void _reset_terminal(int fd)
{
    terminal_clear_screen();
    terminal_cursor_visibility(1);
    tcsetattr(fd, TCSAFLUSH, &old_settings);
    close(fd);
}

static char* _make_layer_question(const char* layer, const char* identifier, const char* what)
{
    struct string* str = string_create();
    string_add_strings(str, 7, "What is the ", identifier, " ", what, " of ", layer, "?");
    return string_dissolve(str);
}

#define _gen_fun_ask_layer_property(what, type) \
static void _ask_layer_property_ ##what(struct state* state, struct generics* layer, const char* exportname, const char* title, const char* prettyname, const char* what, const char* defvalue) \
{ \
    char* str = _make_layer_question(prettyname, exportname, what); \
    type value = _draw_main_text_single_prompt_ ##what(state, str, defvalue, title); \
    generics_set_layer_export_ ##what(layer, exportname, what, value); \
    free(str); \
}

#define _gen_fun_ask_layer(what) \
static void _ask_layer_ ##what(struct state* state, struct generics* layer, const char* exportname, const char* title, const char* prettyname, const char* layer_default, const char* purpose_default) \
{ \
    _ask_layer_property_ ##what(state, layer, exportname, title, prettyname, "layer", layer_default); \
    _ask_layer_property_ ##what(state, layer, exportname, title, prettyname, "purpose", purpose_default); \
}

_gen_fun_ask_layer_property(integer, int)
_gen_fun_ask_layer_property(string, char*)
_gen_fun_ask_layer(integer)
_gen_fun_ask_layer(string)

struct layerset {
    char* layername;
    char* prettyname;
    char* title;
    char* info;
};

struct layerset* _create_layerset(char* layername, char* prettyname, char* title, char* info)
{
    struct layerset* layerset = malloc(sizeof(*layerset));
    layerset->layername = layername;
    layerset->prettyname = prettyname;
    layerset->title = title;
    layerset->info = info;
    return layerset;
}

struct layerset* _create_layerset_copy(const char* layername, const char* prettyname, const char* title, const char* info)
{
    struct layerset* layerset = malloc(sizeof(*layerset));
    layerset->layername = util_strdup(layername);
    layerset->prettyname = util_strdup(prettyname);
    layerset->title = util_strdup(title);
    if(info)
    {
        layerset->info = util_strdup(info);
    }
    else
    {
        layerset->info = NULL;
    }
    return layerset;
}

void _destroy_layerset(void* v)
{
    if(v) // layersets can be NULL because they are NULL-terminated
    {
        struct layerset* layerset = v;
        free(layerset->layername);
        free(layerset->prettyname);
        free(layerset->title);
        free(layerset->info);
        free(layerset);
    }
}

static void _ask_layer(struct state* state, const char* layername, const char* prettyname, const char* title, const char* info)
{
    _clear_main_area(state);
    if(info)
    {
        const char* const lines[] = {
            info, NULL
        };
        _draw_main_text(state, lines, title);
        _write_to_display(state);
        _wait_for_enter(state);
        _clear_main_area(state);
    }
    struct generics* layer = technology_add_empty_layer(state->techstate, layername);
    if(state->ask_gds)
    {
        _ask_layer_integer(state, layer, "gds", title, prettyname, "", "0");
        _draw_side_panel(state);
        _write_to_display(state);
    }
    if(state->ask_skill)
    {
        _ask_layer_string(state, layer, "SKILL", title, prettyname, "", "drawing");
        _draw_side_panel(state);
        _write_to_display(state);
    }
    if(state->ask_layer_name)
    {
        struct string* str = string_create();
        string_add_strings(str, 3, "What is the layer name of ", prettyname, "?");
        char* question = string_dissolve(str);
        char* name = _draw_main_text_single_prompt_string(state, question, "", title);
        generics_set_pretty_name(layer, name);
        free(name);
        _draw_side_panel(state);
        _write_to_display(state);
    }
}

static void _ask_constraint(struct state* state, const char* name, const char* info)
{
    _clear_main_area(state);
    if(info)
    {
        const char* const lines[] = {
            info, NULL
        };
        _draw_main_text(state, lines, name);
        _write_to_display(state);
        _wait_for_enter(state);
        _clear_main_area(state);
    }
    struct string* str = string_create();
    string_add_strings(str, 3, "What is the value of ", name, "?");
    int value = _draw_main_text_single_prompt_integer(state, string_get(str), "", name);
    string_destroy(str);
    technology_set_constraint_integer(state->techstate, name, value);
}

static void _copy_layer_to_layer(struct state* state, const char* sourcename, const char* targetname)
{
    const struct generics* source = technology_get_layer(state->techstate, sourcename);
    struct generics* target = technology_add_empty_layer(state->techstate, targetname);
    generics_copy_properties(source, target);
}

static void _ask_layer_set(struct state* state, struct layerset** layerset, const char* commoninfo)
{
    if(commoninfo)
    {
        const char* const lines[] = {
            commoninfo, NULL
        };
        _draw_main_text(state, lines, "");
    }
    struct layerset** p = layerset;
    while(*p)
    {
        struct layerset* ls = *p;
        _ask_layer(state, ls->layername, ls->prettyname, ls->title, ls->info);
        ++p;
    }
}

static void _ask_vthtype(struct state* state, int numvthtype, char type)
{
    for(int i = 0; i < numvthtype; ++i)
    {
        int numdigits = util_num_digits(i);
        char* layername = malloc(strlen("vthtypex") + numdigits + 1);
        sprintf(layername, "vthtype%c%d", type, numdigits);
        char* prettyname = malloc(strlen("Vth X-Type #") + numdigits + 1);
        sprintf(prettyname, "Vth %c-Type #%d", type, numdigits);
        char* title = malloc(strlen("Vth X-Type") + 1);
        sprintf(title, "Vth %c-Type", type);
        _ask_layer(state, layername, prettyname, title, NULL);
        free(layername);
        free(prettyname);
        free(title);
    }
}

static void _ask_oxide(struct state* state, int numoxide, int startindex)
{
    for(int i = startindex; i < numoxide; ++i)
    {
        int numdigits = util_num_digits(i);
        char* layername = malloc(strlen("oxide") + numdigits + 1);
        sprintf(layername, "oxide%d", numdigits);
        char* prettyname = malloc(strlen("Oxide Type #") + numdigits + 1);
        sprintf(prettyname, "Oxide Type #%d", numdigits);
        _ask_layer(state, layername, prettyname, "Oxide Type", NULL);
        free(layername);
        free(prettyname);
    }
}

static void _read_primary_FEOL(struct state* state)
{
    _draw_all(state);

    /* active + implant layers */
    const char* text = "In some process nodes, there is a generic 'active' region turned into n-plus or p-plus by additional marking layers ('active_plus_implant', three layers in total). In other processes, there are dedicated n-plus and p-plus active layers ('dedicated_active', two layers in total). Lastly, there are also processes where only n- or p-implants are marked and active regions without markings are the opposite ('asymmetric_active', two layers in total).";
    const char* choices[] = {
        "active_plus_implant",
        "dedicated_active",
        "asymmetric_active",
    };
    size_t len = sizeof(choices) / sizeof(choices[0]);
    int choice = _draw_main_text_single_prompt_menu(state, text, choices, len, "FEOL Method");
    switch(choice)
    {
        case 0:
        {
            // layers: active, p-plus, n-plus
            struct layerset* layerset[] = {
                _create_layerset_copy("active", "active diffusion", "Active Diffusion", "Let's start with the active diffusion layer. The active diffusion layer defines regions where, for instance, source/drain regions of MOSFETs are formed. They come in a p- and n-doped version (marked my an implant layer) and are often called DIFF, diffusion, active, ACT or similar."),
                _create_layerset_copy("pimplant", "p-implant", "P-Implant", "After the active diffusion, we now talk about the p-implant layer. The P-Implant changes the polarity/majority charge carrier of an active diffusion into a p-type."),
                _create_layerset_copy("nimplant", "n-implant", "N-Implant", "Just like the P-Implant layer, the N-Implant changes the polarity/majority charge carrier of an active diffusion into a n-type."),
                NULL
            };
            _ask_layer_set(state, layerset, NULL);
            break;
        }
        case 1:
        {
            // layers: p-active, n-active
            struct layerset* layerset[] = {
                _create_layerset_copy("pactive", "active p-doped diffusion", "Active P-Diffusion", "Let's start with the active p-doped diffusion layer. The active diffusion layer defines p+-doped regions where, for instance, source/drain regions of MOSFETs are formed."),
                _create_layerset_copy("nactive", "active n-doped diffusion", "Active N-Diffusion", "Now let's move to the active n-doped diffusion layer, which is the opposite of the p-doped diffusion and defines n+-doped regions."),
                NULL
            };
            _ask_layer_set(state, layerset, NULL);
            break;
        }
        case 2:
        {
            // layers: active, n-plus or p-plus
            const char* implanttext = "Are drawn active diffusion regions per default (without any additional implant layers) p-doped or n-doped?";
            const char* implantchoices[] = {
                "Active is p-default",
                "Active is n-default",
            };
            int implantchoice = _draw_main_text_single_prompt_menu(state, implanttext, implantchoices, 2, "Default Active Polarity");
            if(implantchoice == 0)
            {
                struct layerset* layerset[] = {
                    _create_layerset_copy("active", "active diffusion", "Active Diffusion", "Let's start with the active diffusion layer. The active diffusion layer defines regions where, for instance, source/drain regions of MOSFETs are formed. They come in a p- and n-doped version (one marked by an additional implant layer) and are often called DIFF, diffusion, active, ACT or similar. The active diffusion layer is n-doped per default and can be changed into a p-doped region by using an additional p-implant layer."),
                    _create_layerset_copy("pimplant", "p-implant", "P-Implant", "After the active diffusion, we now talk about the p-implant layer. The P-Implant changes the polarity/majority charge carrier of an active diffusion into a p-type."),
                    NULL
                };
                _ask_layer_set(state, layerset, NULL);
            }
            else
            {
                struct layerset* layerset[] = {
                    _create_layerset_copy("active", "active diffusion", "Active Diffusion", "Let's start with the active diffusion layer. The active diffusion layer defines regions where, for instance, source/drain regions of MOSFETs are formed. They come in a p- and n-doped version (one marked by an additional implant layer) and are often called DIFF, diffusion, active, ACT or similar. The active diffusion layer is p-doped per default and can be changed into a n-doped region by using an additional n-implant layer."),
                    _create_layerset_copy("nimplant", "n-implant", "N-Implant", "After the active diffusion, we now talk about the n-implant layer. The N-Implant changes the polarity/majority charge carrier of an active diffusion into a n-type."),
                    NULL
                };
                _ask_layer_set(state, layerset, NULL);
            }
            break;
        }
    }

    /* gate layer */
    _ask_layer(state, "gate", "Gate", "Gate", "MOSFET gates are drawn in the 'gate' layer. Typically this is polysilicon or a metal and called 'POLY' or 'PC' or similar.");

    /* contacts */
    int separate_contacts = _draw_main_text_single_prompt_boolean(state, "Connections between the active regions and gates are done by contacts. Some technology nodes differentiate between contacts to active regions, contacts to source/drain regions, contacts to gates and generic poly contacts (at least some of these). Other nodes only have one contact layer, where all these four options are mapped to the same layer. Does this process node distinguish between different contact types?", "Separate Contact Layers");
    if(separate_contacts)
    {
        _ask_layer(state, "contactactive", "active contact layer (not MOSFET source/drain contacts)", "Active Contacts", NULL);
        _ask_layer(state, "contactpoly", "poly contact layer (not MOSFET gate contacts)", "Poly Contacts", NULL);
        _ask_layer(state, "contactgate", "MOSFET gate contact layer", "MOSFET Gate Contacts", NULL);
        _ask_layer(state, "contactsourcedrain", "MOSFET source/drain contact layer", "MOSFET Source/Drain Contacts", NULL);
    }
    else
    {
        _ask_layer(state, "contactactive", "gate/active contact layer (all contact types)", "Gate/Active Contacts", NULL);
        _copy_layer_to_layer(state, "contactactive", "contactpoly");
        _copy_layer_to_layer(state, "contactactive", "contactgate");
        _copy_layer_to_layer(state, "contactactive", "contactsourcedrain");
    }

    /* vthtype */
    int numnvthtype = _draw_main_text_single_prompt_integer(state, "The threshold voltage of MOSFETs can be changed by channel implants. Typically technology nodes provide layers to mark devices with different threshold voltages (e.g. low vth, high vth). Additionally, these might be seperated into p- and n-types. How many different layers (n-type) exist in this node? (can be 0)", "", "Number of n-type Vth Types");
    int numpvthtype = _draw_main_text_single_prompt_integer(state, "And how many different layers exists for p-type channel implants? (can be 0)", "", "Number of p-type Vth Types");
    if(numnvthtype > 0)
    {
        _ask_vthtype(state, numnvthtype, 'n');
    }
    else
    {
        technology_add_empty_layer(state->techstate, "vthtypen1");
    }
    if(numpvthtype > 0)
    {
        _ask_vthtype(state, numpvthtype, 'p');
    }
    else
    {
        technology_add_empty_layer(state->techstate, "vthtypep1");
    }

    /* oxide */
    int numoxide = _draw_main_text_single_prompt_integer(state, "The gate thickness and voltage rating of MOSFET gates and other structures can take varying values. Typically there are layers that defines the oxide thickness class of drawn gate layer regions. Most often, if no layer is drawn the default thickness is used with one layer for defining thicker oxides. How many different oxide thicknesses are there?", "", "Number of Oxide Thicknesses");
    if(numoxide > 1)
    {
        int has_default_oxide = _draw_main_text_single_prompt_integer(state, "Usually, the default oxide thickness does not require any layer to mark it. Is this the case? If yes, then the number of required oxide thickness definition layers is one less than the number of oxide thicknesses (this is typically the case).", "yes", "Number of Oxide Definition Layers");
        if(has_default_oxide)
        {
            technology_add_empty_layer(state->techstate, "oxide1");
            _ask_oxide(state, numoxide, 1); // start at oxide2
        }
        else
        {
            _ask_oxide(state, numoxide, 0); // start at oxide1
        }
    }
    state->finished_primary_FEOL = 1;
}

static void _read_secondary_FEOL(struct state* state)
{
    _draw_all(state);

    /* gatecut */
    int has_gatecut = _draw_main_text_single_prompt_boolean(state, "Some process nodes (especially more modern ones), there is a 'gate cut' layer, which marks regions where existing polysilicon (gate) is removed. Does this technology node feature such a layer?", "Gate Cut Layer");
    technology_set_feature(state->techstate, "has_gatecut", has_gatecut);
    if(has_gatecut)
    {
        _ask_layer(state, "gatecut", "Gate Cut Layer", "Gate Cut Layer", NULL);
    }
    else
    {
        technology_add_empty_layer(state->techstate, "gatecut");
    }

    /* silicideblocker */
    int has_silicideblocker = _draw_main_text_single_prompt_boolean(state, "Typical process nodes use silicided polysilicon to reduce the resistance of MOSFET gates. However, for resistors (as deliberate devices) on the polysilicon layer, this silicide is often removed/blocken. For this a layer exists, a silicideblocker. Does this node support this layer?", "Polysilicon Silicide Blocker");
    if(has_silicideblocker)
    {
        _ask_layer(state, "silicideblocker", "polysilicon silicide blocker", "Polysilicon Silicide Blocker", NULL);
    }
    else
    {
        technology_add_empty_layer(state->techstate, "silicideblocker");
    }

    /* soiopen */
    int is_soi = _draw_main_text_single_prompt_boolean(state, "Silicon-on-insulator (SOI) technology nodes require additional masks and hence design layers. Is this an SOI process?", "Silicon-on-Insulator Process Node");
    technology_set_feature(state->techstate, "is_soi", is_soi);
    if(is_soi)
    {
        int has_soiopen = _draw_main_text_single_prompt_boolean(state, "Some SOI process nodes allow physical access (contacts) to the underlying wafer (sometimes called handle wafer) under the buried oxide (BOX). Does this process node provide such access?", "Silicon-on-Insulator Process Node");
        if(has_soiopen)
        {
            _ask_layer(state, "soiopen", "SOI opening layer", "Handle Wafer Access (SOI Opening)", NULL);
        }
        else
        {
            technology_add_empty_layer(state->techstate, "soiopen");
        }
    }
    else
    {
        technology_add_empty_layer(state->techstate, "soiopen");
    }

    /* subblock */
    int has_subblock = _draw_main_text_single_prompt_boolean(state, "Normally, the bulk wafer of any process is lightly doped (p- or n-type). For some devices such as inductors or to mitigate noise coupling reducing the conductivity of the substrate can be helpful, which is why some process nodes offer a layer that turns the substrate into a high-ohmic region. Does this node offer such functionality?", "Substracte Doping Blocker");
    if(has_subblock)
    {
        _ask_layer(state, "subblock", "polysilicon silicide blocker", "Polysilicon Silicide Blocker", NULL);
    }
    else
    {
        technology_add_empty_layer(state->techstate, "subblock");
    }
    state->finished_secondary_FEOL = 1;
}

static void _read_wells(struct state* state)
{
    const char* text = "The bulk wafer is typically lightly doped (p or n). The majority of technology nodes use a p-doped base wafer, which one does this node use?";
    const char* choices[] = {
        "p-doped",
        "n-doped"
    };
    size_t len = sizeof(choices) / sizeof(choices[0]);
    int is_ndoped = _draw_main_text_single_prompt_menu(state, text, choices, len, "Base Wafer Majority Charge Carrier Type");

    // regular wells
    int has_pwell = 0;
    int has_nwell = 0;
    if(is_ndoped == 0) // p-doped
    {
        has_nwell = 1;
        has_pwell = _draw_main_text_single_prompt_boolean_no(state, "Does this technology node have a dedicated p-well layer?", "P-Well in P-Doped Wafer");
    }
    else
    {
        has_pwell = 1;
        has_nwell = _draw_main_text_single_prompt_boolean_no(state, "Does this technology node have a dedicated n-well layer?", "N-Well in N-Doped Wafer");
    }
    if(has_pwell)
    {
        _ask_layer(state, "pwell", "P-Well", "P-Well Layer", NULL);
    }
    else
    {
        technology_add_empty_layer(state->techstate, "pwell");
    }
    if(has_nwell)
    {
        _ask_layer(state, "nwell", "N-Well", "N-Well Layer", NULL);
    }
    else
    {
        technology_add_empty_layer(state->techstate, "nwell");
    }

    // deep wells
    int has_deeppwell = _draw_main_text_single_prompt_boolean(state, "Does this technology node have a dedicated layer for a deep p-well?", "Deep P-Well");
    if(has_deeppwell)
    {
        _ask_layer(state, "deeppwell", "Deep P-Well", "Deep P-Well Layer", NULL);
    }
    else
    {
        technology_add_empty_layer(state->techstate, "deeppwell");
    }
    int has_deepnwell = _draw_main_text_single_prompt_boolean(state, "Does this technology node have a dedicated layer for a deep n-well?", "Deep N-Well");
    if(has_deepnwell)
    {
        _ask_layer(state, "deepnwell", "Deep N-Well", "Deep N-Well Layer", NULL);
    }
    else
    {
        technology_add_empty_layer(state->techstate, "deepnwell");
    }
    state->finished_wells = 1;
}

static void _read_beol(struct state* state)
{
    /* padopening */
    const char* text = "During manufacture of an integrated circuit, the final step involves adding passivation to seal to die from accidental connections. However, in order to connect signals to pads, the passivation needs to be opened. For this a dedicated layer should be present.";
    _ask_layer(state, "padopening", "the passivation opening layer for pads", "Pad Passivation Opening Layer", text);
    state->finished_BEOL = 1;
}

static void _show_metal_summary(struct state* state)
{
    struct vector* lines = vector_create(8, free);
    unsigned int nummetals = technology_get_num_metals(state->techstate);
    vector_append(lines, strprintf("Number of Metals: %d", nummetals));
    for(unsigned int i = 1; i <= nummetals; ++i)
    {
        // get metal
        size_t len = 1 + util_num_digits(i);
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "M%d", i);
        const struct generics* layer = technology_get_layer(state->techstate, layername);
        free(layername);
        // write status
        struct string* str = string_create();
        string_add_string(str, "Metal ");
        strprint_integer(str, i);
        string_add_character(str, ':');
        char* metal = string_dissolve(str); // free'd by vector
        vector_append(lines, metal);
    }
    vector_append(lines, NULL);
    _draw_main_text(state, vector_content(lines), "Metal Stack");
    _write_to_display(state);
    vector_destroy(lines);
}

static void _read_metal_stack(struct state* state)
{
    int read = 1;
    if(state->finished_metal_stack)
    {
        read = 0;
        _show_metal_summary(state);
        _wait_for_enter(state);
        read = _draw_main_text_single_prompt_boolean_no(state, "Do you want to overwrite the metal stack configuration?", "Override Metal Stack");
    }
    if(read)
    {
        state->mode = METALSTACK;
        _draw_all(state);
        unsigned int nummetals = _draw_main_text_single_prompt_integer(state, "How many metals does the stack have?", "", "Number of Metals");
        technology_set_num_metals(state->techstate, nummetals);
        _draw_all(state);
        // metals
        struct vector* metals = vector_create(nummetals + 1, _destroy_layerset);
        for(unsigned int i = 1; i <= nummetals; ++i)
        {
            char* layername = strprintf("M%d", i);
            char* prettyname = strprintf("metal %d", i);
            char* title = strprintf("Metal %d", i);
            // the strings are free'd when the layerset is created
            struct layerset* layerset = _create_layerset(layername, prettyname, title, NULL);
            vector_append(metals, layerset);
        }
        vector_append(metals, NULL); // sentinel for char* array
        struct layerset** metalcontent = vector_content(metals);
        _ask_layer_set(state, metalcontent, NULL);
        vector_destroy(metals);
        state->finished_metal_stack = 1;
        // vias
        _draw_all(state);
        _draw_main_text_single(state, "For connections between the metal layers, vias are used. These are drawn in so-called via cut layers. For N metals, there are N - 1 via cut layers.", "Via Cut Layers");
        _write_to_display(state);
        _wait_for_enter(state);
        struct vector* vias = vector_create(nummetals, _destroy_layerset);
        for(unsigned int i = 1; i <= nummetals - 1; ++i)
        {
            char* layername = strprintf("viacutM%dM%d", i, i + 1);
            char* prettyname = strprintf("via cut layer from metal %d to metal %d", i, i + 1);
            char* title = strprintf("Via Cut %d -> %d", i, i + 1);
            // the strings are free'd when the layerset is created
            struct layerset* layerset = _create_layerset(layername, prettyname, title, NULL);
            vector_append(vias, layerset);
        }
        vector_append(vias, NULL); // sentinel for char* array
        struct layerset** viacontent = vector_content(vias);
        _ask_layer_set(state, viacontent, NULL);
        vector_destroy(vias);
        state->finished_vias = 1;
    }
}

static int _ask_via_definition_property(struct state* state, const char* what, unsigned int vianum)
{
    struct string* str = string_create();
    string_add_string(str, "What is the ");
    string_add_string(str, what);
    string_add_string(str, " of the via cut for the transition from metal ");
    strprint_integer(str, vianum);
    string_add_string(str, " to metal ");
    strprint_integer(str, vianum + 1);
    string_add_character(str, '?');
    char* info = string_dissolve(str);
    str = string_create();
    string_add_string(str, "Via Definition: Metal ");
    strprint_integer(str, vianum);
    string_add_string(str, "-> Metal ");
    strprint_integer(str, vianum + 1);
    char* title = string_dissolve(str);
    _draw_main_text_single(state, info, title);
    int dimension = _get_integer(state, "");
    return dimension;
}

static void _ask_via_definition(struct state* state, unsigned int vianum)
{

    int width = _ask_via_definition_property(state, "width", vianum);
    int height = _ask_via_definition_property(state, "height", vianum);
    int xspace = _ask_via_definition_property(state, "x-space", vianum);
    int yspace = _ask_via_definition_property(state, "y-space", vianum);
    int xenclosure = _ask_via_definition_property(state, "x-enclosure", vianum);
    int yenclosure = _ask_via_definition_property(state, "y-enclosure", vianum);
    technology_add_via_definition(state->techstate, vianum, width, height, xspace, yspace, xenclosure, yenclosure, 0, 0);
    technology_set_fallback_via(state->techstate, vianum, width, height);
}

static void _read_via_definitions(struct state* state)
{
    const char* lines[] = {
        "Layout descriptions in openPCells are technology-independent. Vias (connections between layers such as metals or gates) on the other hand typically require exact dimensions, which can not be expressed easily in a generic way. Therefore, part of exporting layouts from openPCells involves so-called via arrayzation. For this, a set of rules have to be known. At least one rule per via layer is required, more can help tailor to more stringent design rules.",
        "",
        "Via arrayzation rules are defined by the size (width and height) of the cuts, their spacing in x- and y-direction as well as their enclosure at the ends of an array.",
        "",
        "While multiple rules can be given per transition, this assistant will only ask for one each. If more are needed, please edit the files manually.",
        NULL
    };
    _draw_main_text(state, lines, "Via Definitions");
    _write_to_display(state);
    _wait_for_enter(state);
    unsigned int nummetals = technology_get_num_metals(state->techstate);
    for(unsigned int i = 0; i < nummetals - 1; ++i)
    {
        _ask_via_definition(state, i + 1);
    }
}

static void _read_constraints(struct state* state)
{
    _ask_constraint(state, "Minimum Active Width", NULL);
    _ask_constraint(state, "Minimum Active Space", NULL);
    _ask_constraint(state, "Minimum Contact Target Width", NULL);
    _ask_constraint(state, "Minimum Well Extension", NULL);
    _ask_constraint(state, "Minimum Implant Extension", NULL);
    _ask_constraint(state, "Minimum Gate Extension", NULL);
    _ask_constraint(state, "Minimum Gate Length", NULL);
    _ask_constraint(state, "Minimum Gate Width", NULL);
    _ask_constraint(state, "Minimum Gate Space", NULL);
    _ask_constraint(state, "Minimum Gate Contact Region Size", NULL);
    _ask_constraint(state, "Minimum Source/Drain Contact Region Size", NULL);
    _ask_constraint(state, "Minimum Active Contact Region Size", NULL);
    unsigned int nummetals = technology_get_num_metals(state->techstate);
    for(unsigned int i = 1; i <= nummetals; ++i)
    {
        struct string* str = string_create();
        string_add_string(str, "Minimum M");
        strprint_integer(str, i);
        string_add_string(str, " Width");
        _ask_constraint(state, string_get(str), NULL);
        string_destroy(str);
        str = string_create();
        string_add_string(str, "Minimum M");
        strprint_integer(str, i);
        string_add_string(str, " Space");
        _ask_constraint(state, string_get(str), NULL);
        string_destroy(str);
    }
    state->finished_constraints = 1;
}

static void _read_auxiliary(struct state* state)
{
    const char* special_text = 
        "The 'special' layer is a non-physical non-process-related layer, that is used for marking opc structures (e.g. area anchors). "
        "As process nodes don't have a layer like this it should be mapped to a generics layer from the EDA tool or something unused. "
        "Do you want to provide this extra layer?";
    int has_special = _draw_main_text_single_prompt_boolean(state, special_text, "Special Layer");
    if(has_special)
    {
        _ask_layer(state, "special", "Special", "Special", NULL);
    }
    else
    {
        technology_add_empty_layer(state->techstate, "special");
    }
    const char* outline_text = 
        "The outline layer marks the outline of blocks. "
        "Most often, it is not required but can help with the placement of filling, aligning blocks and other purposes. "
        "(Note: not every node defines this layer)";
    int has_outline = _draw_main_text_single_prompt_boolean(state, outline_text, "Outline Layer");
    if(has_outline)
    {
        _ask_layer(state, "outline", "Outline", "Outline", NULL);
    }
    else
    {
        technology_add_empty_layer(state->techstate, "outline");
    }
    state->finished_auxiliary = 1;
}

static void _show_stackup_model(struct state* state)
{
    _clear_main_area(state);
    const char* lines[] = {
        "      ---------------------------------                                        ",
        "      |    Metal 2                    |                                        ",
        "      ---------------------------------                                        ",
        "        |  | Via 1                                                             ",
        "   --------------------------                                                  ",
        "           Metal 1          |                                                  ",
        "   --------------------------                                                  ",
        "                      |  | contact                                             ",
        "                 --------------                                                ",
        "                 |    Gate    |                                                ",
        "===========================================================                    ",
        "     |     **************************      |                                   ",
        "     |     ********  Active *********      |                                   ",
        "     |                                     |                                   ",
        "     \\              N-Well                 /                                  ",
        "      +--------------------------------------------------------------------+   ",
        "      |                                                                    |   ",
        "      \\                           Deep N-Well                              /",
        "       --------------------------------------------------------------------    ",
        NULL
    };
    _draw_lines(state, lines);
    _write_to_display(state);
    _wait_for_enter(state);
}

static void _show_current_state(struct state* state)
{
    // container for lines
    struct vector* vlines = vector_create(8, NULL); // memory is freed for the primitive char* array
    // string for assembly of lines
    struct string* str;

    // number of layers
    unsigned int numlayer = technology_get_number_of_layers(state->techstate);
    str = string_create();
    string_add_string(str, " * number of layers: ");
    strprint_integer(str, numlayer);
    vector_append(vlines, string_dissolve(str));

    // number of metal layers
    unsigned int nummetals = technology_get_num_metals(state->techstate);
    str = string_create();
    string_add_string(str, " * number of metals: ");
    strprint_integer(str, nummetals);
    vector_append(vlines, string_dissolve(str));

    // print lines, convert vector to char* array with NULL sentinel
    vector_append(vlines, NULL);
    char** lines = vector_disown_content(vlines);
    _draw_main_text(state, (const char* const*) lines, "Current Technology State");
    free(lines);
}

static void _show_error(struct state* state, const char* msg)
{
    _set_color_RGB(state, 255, 0, 0);
    _draw_main_text_single(state, msg, "Error");
    _write_to_display(state);
    _reset_color(state);
}

void main_techfile_assistant(const struct hashmap* config)
{
    // set up
    struct state S = { 0 };
    struct state* state = &S; // I didn't want to type &state any more
    state->mode = NONE;

    int fd = _setup_terminal(state);
    if(fd < 1)
    {
        exit(1);
    }

    state->current_content = calloc(state->rows * state->columns, sizeof(struct rchar));
    state->next_content = calloc(state->rows * state->columns, sizeof(struct rchar));

    terminal_clear_screen();
    _set_to_blank(state);

    // introduction
    const char* introlines[] = {
        "Hello, this is the openPCells technology file assistant.",
        "",
        "I will ask you questions to help you create the technology files.",
        "Additionally, the assistant can also be used to check/edit existing technology files.",
        "",
        "All questions will prompt you for an answer, you can enter some characters and give the answer by hitting return.",
        "There are boolean questions (yes/no) and questions where a full string is expected.",
        "If a default is available, it will be already given in the prompt.",
        "",
        "The assistant can be stopped at any time by typing ctrl-c (that is, c with the control modifier).",
        "Unsaved data will be stored on the disk in the current directoy.",
        "",
        "(hit <enter> to continue)",
        NULL
    };
    _clear_all(state);
    _draw_full_text(state, introlines, "Introduction");
    _write_to_display(state);
    _wait_for_enter(state);

    // technology files
    const char* techfiles[] = {
        "Technology nodes are defined by a few properties:",
        " * the physical stack-up of the process (e.g. are triple-well offered, is it an SOI process, etc.)",
        " * the layer data (e.g. metal 1 has the GDS layer/purpose pair 24/0)",
        " * rules how via cuts are created (e.g. a via cut between metal 1 and 2 is 100 x 100 nm and required this and that spacing)",
        " * critical layer dimensions (e.g. the minimum metal 1 width is 100 nm)",
        NULL
    };
    _clear_all(state);
    _draw_full_text(state, techfiles, "Technology Node Definition");
    _write_to_display(state);
    _wait_for_enter(state);

    // general
    state->mode = SETTINGS;
    _clear_all(state);
    _draw_all(state);
    state->techname = _draw_main_text_single_prompt_string(state, "What is the name of the technology library?", "", "Technology Name");
    state->techstate = technology_initialize(state->techname);
    const struct vector* techpaths = hashmap_get_const(config, "techpaths");
    int loaded = 0;
    if(technology_exists(techpaths, state->techname))
    {
        _draw_all(state);
        int load = _draw_main_text_single_prompt_boolean(state, "This technology definition already exists. Do you want to load it for editing?", "Technology Loading");
        if(load)
        {
            state->techstate = main_create_techstate(techpaths, state->techname, NULL); // NULL: ignored layers, not needed

            // FIXME: notify in case of errors
            loaded = 1;
        }
    }
    if(!loaded)
    {
        _draw_all(state);
        state->ask_layer_name = _draw_main_text_single_prompt_boolean_yes(state, "Should the assistant ask for layer names (useful for debugging)?", "Layer Info");
        _draw_all(state);
        state->ask_gds = _draw_main_text_single_prompt_boolean_yes(state, "Should the assistant ask for GDS layer data (required for GDS export)?", "Layer Info");
        _draw_all(state);
        state->ask_skill = _draw_main_text_single_prompt_boolean_yes(state, "Should the assistant ask for SKILL layer data (required for SKILL/virtuoso export)?", "Layer Info");
    }
    
    state->mode = GENERAL;
    // main loop (random order)
    int run = 1;
    while(run)
    {
        // menu
        const char* menu[] = {
            "Please select one of the options below to configure the technology node.",
            "Some options can be chosen in arbitrary order, but for via definitions and size constraints the metal stack needs to be defined.",
            "It is recommended to go through the options in their numeric order.",
            "",
            "Technology Configuration:",
            " 0) Show openPCells Stack-Up Model",
            " 1) Front-End-of-Line Primary Configuration",
            " 2) Front-End-of-Line Secondary Configuration",
            " 3) Well Configuration",
            " 4) Back-End-of-Line",
            " 5) Metal Stack Layers",
            " 6) Via Definitions",
            " 7) Size Constraints",
            " 8) Auxiliary Layers",
            "",
            "Additional Actions:",
            " e) Edit Assistant Configuration",
            " s) View Current Technology State",
            " c) Check Technology State with Standard PCells",
            "",
            " q) Quit (will save status)",
            NULL
        };
        state->mode = GENERAL;
        _draw_all(state);
        _draw_main_text(state, menu, "Main Menu");
        char choice = _get_character(state, "");
        switch(choice)
        {
            case 'q':
                run = 0;
                break;
            case 'e': // assistant configuration
                break;
            case 's': // view current technology state
                _draw_all(state);
                _show_current_state(state);
                _write_to_display(state);
                _wait_for_enter(state);
                break;
            case 'c': // check technology state
                break;
            case '0': // show stack-up model
                _show_stackup_model(state);
                break;
            case '1': // primary FEOL
                _read_primary_FEOL(state);
                break;
            case '2': // secondary FEOL
                _read_secondary_FEOL(state);
                break;
            case '3': // wells
                _read_wells(state);
                break;
            case '4': // BEOL
                _read_beol(state);
                break;
            case '5': // metals
                _read_metal_stack(state);
                break;
            case '6': // vias
            {
                unsigned int nummetals = technology_get_num_metals(state->techstate);
                if(nummetals > 1)
                {
                    _read_via_definitions(state);
                }
                else if(nummetals == 1)
                {
                    _draw_main_text_single(state, "No vias need to be defined, as there is only one metal layer.", "Via Definitions");
                    _wait_for_enter(state);
                }
                else
                {
                    _show_error(state, "You must define the metal stack before via definitions can be assigned.");
                    _wait_for_enter(state);
                }
                break;
            }
            case '7': // constraints
            {
                unsigned int nummetals = technology_get_num_metals(state->techstate);
                if(nummetals > 0)
                {
                    _read_constraints(state);
                }
                else
                {
                    _show_error(state, "You must define the metal stack before constraints can be assigned.");
                    _wait_for_enter(state);
                }
                break;
            }
            case '8':
            {
                _read_auxiliary(state);
                break;
            }
            default:
                _show_error(state, "Not a valid action");
                _wait_for_enter(state);
                break;
        }
        if(choice == 0)
        {
            break;
        }
    }
    _save_state(state);
    _reset_terminal(fd);
}

/*
Required:
[x] generics.active()
[x] generics.contact("active")
[x] generics.gate()
[x] generics.implant("n")
[x] generics.implant("p")
[x] generics.vthtype(_P.channeltype, _P.vthtype)
[x] generics.oxide(_P.oxidetype)

[x] generics.well("n")
[x] generics.well("p")
[x] generics.well("p", "deep")
[x] generics.well("n", "deep")

[x] generics.metal(1)
[x] generics.viacut(8, 9)

[x] generics.feol("gatecut")
[x] generics.feol("silicideblocker")
[x] generics.feol("soiopen")
[x] generics.feol("subblock")

[x] generics.beol("padopening")
-> check for multiple patterning

Optional:
[x] generics.special()
[x] generics.outline()
[ ] generics.feol("deeptrenchisolation")
[ ] generics.feol("diffusionbreakgate")
[ ] generics.marker(string.format("M%dlvsresistor", technology.resolve_metal(_P.metalnum))),
[ ] generics.marker("lvs", 2)
[ ] generics.marker("polyresistorlvs", _P.resistortype)
[ ] generics.marker("mosfet", _P.mosfetmarker)
[ ] generics.marker("floatinggate")
[ ] generics.marker("gate", _P.gatemarker)
[ ] generics.marker("inductor")
[ ] generics.marker("inductorlvs")
[ ] generics.marker("analog")
[ ] generics.marker("bjt")
[ ] generics.marker("rotation")
[ ] generics.exclude("active")
[ ] generics.exclude("gate")
[ ] generics.fill("active")
[ ] generics.fill("pimplant")
[ ] generics.fill("poly")
[ ] generics.metalexclude(-1)
[ ] generics.metalport(1)
[ ] generics.mptmetal or generics.mptmetalfill
*/

// vim: nowrap
