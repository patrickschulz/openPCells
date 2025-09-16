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

#define MAX_SCREEN_WIDTH 140
#define MAX_SCREEN_HEIGHT 30
#define SIDE_PANEL_WIDTH 40
#define SIDE_PANEL_GAP 2
#define PROMPT_LINE_OFFSET 0
#define STATUS_LINE_OFFSET 1

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
#define KEY_CODE_ENTER 13

#define ATTRIBUTE_NORMAL    0
#define ATTRIBUTE_BOLD      1

// attribute masks
#define AMASK_BOLD          1

// module-global terminal settings for restoring
static struct termios old_settings;

enum mode {
    NONE,
    GENERAL,
    FEOL,
    SUBSTRATE_WELL,
    METALSTACK,
};

struct state {
    enum mode mode;
    // generic info
    char* techname;
    int ask_layer_name;
    int ask_gds;
    int ask_skill;
    // terminal stuff
    int rows;
    int columns;
    int xstart;
    int xend;
    int ystart;
    int yend;
    int pos;
    int current_attribute;
    int* attributes;
    char* current_content;
    char* next_content;
    // actual technology state
    struct technology_state* techstate;
};

static void _write_to_display(struct state* state)
{
    for(int i = 0; i < state->rows * state->columns; ++i)
    {
        if(state->current_content[i] != state->next_content[i])
        {
            int row = i / state->columns;
            int column = i % state->columns;
            terminal_cursor_set_position(row + 1, column + 1);
            int attribute = state->attributes[i];
            if(attribute & AMASK_BOLD)
            {
                terminal_set_bold();
            }
            else
            {
                terminal_reset_color();
            }
            putchar(state->next_content[i]);
            state->current_content[i] = state->next_content[i];
        }
    }
}

static void _set_position(struct state* state, int row, int column)
{
    state->pos = (row - 1) * state->columns + column - 1;
}

static void _write(struct state* state, const char* str)
{
    size_t len = strlen(str);
    for(size_t i = 0; i < len; ++i)
    {
        state->next_content[state->pos + i] = str[i];
        state->attributes[state->pos + i] = state->current_attribute;
    }
    state->pos += len;
}

static void _write_at(struct state* state, const char* str, int row, int column)
{
    _set_position(state, row, column);
    _write(state, str);
}

static void _set_bold(struct state* state)
{
    state->current_attribute |= ATTRIBUTE_BOLD;
}

static void _set_color_RGB(struct state* state, unsigned char r, unsigned char g, unsigned char b)
{
    //state->color.r = r;
    //state->color.g = g;
    //state->color.b = b;
}

static void _reset_color(struct state* state)
{
    state->current_attribute = ATTRIBUTE_NORMAL;
}

static void _set_to_blank(struct state* state)
{
    for(int i = 0; i < state->rows * state->columns; ++i)
    {
        state->next_content[i] = ' ';
        state->attributes[i] = ATTRIBUTE_NORMAL;
    }
}

static void _save_state(struct state* state)
{
    if(state->techstate) // techstate might not be initialized if an early ctrl-c occurs
    {
        technology_write_definition_files(state->techstate, "_assistant_tech");
    }
}

static void _print(int row, int column, const char* str, size_t len)
{
    terminal_cursor_set_position(row, column);
    for(size_t i = 0; i < len; ++i)
    {
        write(STDOUT_FILENO, str + i, 1);
    }
}

static void _draw_status(struct state* state, const char* text)
{
    _set_color_RGB(state, 255, 0, 0);
    _write_at(state, text, state->yend - STATUS_LINE_OFFSET, state->xstart);
    _reset_color(state);
    _write_to_display(state);
}

static void _clear_character_under_cursor(void)
{
    terminal_cursor_move_left(1);
    putchar('_');
}

static int _getchar(struct state* state)
{
    int ch = getchar();
    if(ch == KEY_CODE_C) // ctrl-c
    {
        terminal_clear_screen();
        terminal_reset_all();
        tcsetattr(STDOUT_FILENO, TCSAFLUSH, &old_settings);
        _save_state(state);
        exit(0);
    }
    return ch;
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
    int column = state->xstart + 3;
    int row = state->yend - PROMPT_LINE_OFFSET;
    int endpos = state->xend - SIDE_PANEL_WIDTH - SIDE_PANEL_GAP - 2;
    for(int i = column; i <= endpos; ++i)
    {
        _write_at(state, "_", row, i);
    }
    _write_at(state, ">", row, state->xstart + 1);
    _write_to_display(state);

    terminal_cursor_visibility(1);
    static char buf[256];
    memset(buf, 0, 256);
    size_t i = 0;
    if(prefill)
    {
        strcpy(buf, prefill);
        i = strlen(prefill);
    }
    _print(row, column, buf, i);
    while(1)
    {
        int ch = _getchar(state);
        if(ch == KEY_CODE_ENTER)
        {
            if(i > 0)
            {
                break;
            }
            else
            {
                _draw_status(state, "given answer must not be empty");
            }
        }
        else if(ch == 127) // backspace
        {
            if(i > 0)
            {
                --i;
                _clear_character_under_cursor();
            }
            buf[i] = 0;
        }
        else
        {
            buf[i] = ch;
            ++i;
        }
        _print(row, column, buf, i);
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
        _write(state, "[x] ");
    }
    else
    {
        _write(state, "[ ] ");
    }
    _write(state, key);
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
        // title
        _set_position(state, state->ystart + 1, xl + (xr - xl + 2 - strlen(title)) / 2);
        _set_bold(state);
        _write(state, title);
        _reset_color(state);
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
    _set_bold(state);
    _write(state, title);
    _reset_color(state);
    _reset_color(state);
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
}

static void _draw_side_panel(struct state* state)
{
    _clear_side_panel(state);
    int startpos = state->xend - SIDE_PANEL_WIDTH;
    _draw_panel(state, startpos, state->xend, state->ystart, state->yend, "Settings");
    int ycurrent = state->ystart + 4; // first entries start at row 4
    // general information
    if(state->mode == GENERAL)
    {
        _draw_panel_section(state, startpos, state->xend, ycurrent, 3, "General Information");
        ++ycurrent;
        _set_position(state, ycurrent, startpos + 3);
        _write_tech_entry_string(state, "Library Name", state->techname);
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

static void _draw_main_text(struct state* state, const char* const* text, const char* section)
{
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

static char* _draw_main_text_single_prompt_string(struct state* state, const char* text, const char* prompt, const char* section)
{
    _draw_main_text_single(state, text, section);
    char* str = util_strdup(_get_string(state, prompt));
    return str;
}

static int _draw_main_text_single_prompt_boolean(struct state* state, const char* text, const char* prompt, const char* section)
{
    _draw_main_text_single(state, text, section);
    _set_position(state, state->yend, 1);
    int endpos = state->xend - SIDE_PANEL_WIDTH - SIDE_PANEL_GAP - 2;
    for(int i = 1; i <= endpos; ++i)
    {
        _write(state, " ");
    }
    _set_position(state, state->yend, 2);
    _write(state, ">");
    char* p = util_strdup(prompt);
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
        _draw_status(state, "given answer must be 'yes' or 'no'");
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
    _set_position(state, state->yend, 2);
    _write(state, ">");
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

static void _clear_main_area(struct state* state)
{
    int xstart = state->xstart;
    int xend = state->xend - SIDE_PANEL_WIDTH - SIDE_PANEL_GAP - 1;
    int ystart = state->ystart;
    int yend = state->yend - 1;
    for(int i = xstart; i <= xend; ++i)
    {
        for(int j = ystart; j <= yend; ++j)
        {
            _write_at(state, " ", j, i);
        }
    }
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
    cfmakeraw(&termios);
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
    terminal_cursor_visibility(1);
    terminal_clear_screen();
    tcsetattr(fd, TCSAFLUSH, &old_settings);
    close(fd);
}

static struct string* _make_metal_question(int i, const char* identifier, const char* what)
{
    struct string* str = string_create();
    string_add_string(str, "What is the ");
    string_add_string(str, identifier);
    string_add_character(str, ' ');
    string_add_string(str, what);
    string_add_string(str, " of metal ");
    strprint_integer(str, i);
    string_add_character(str, '?');
    return str;
}

static void _ask_metal_str(struct state* state, struct generics* layer, int i, const char* exportname, const char* layer_default, const char* purpose_default)
{
    struct string* layerq = _make_metal_question(i, exportname, "layer");
    struct string* purposeq = _make_metal_question(i, exportname, "purpose");
    char* metalnumstr = malloc(sizeof(char) * (5 + util_num_digits(i)) + 1);
    sprintf(metalnumstr, "metal %d", i);
    _clear_main_area(state);
    char* layerstr = _draw_main_text_single_prompt_string(state, string_get(layerq), layer_default, metalnumstr);
    _clear_main_area(state);
    char* purposestr = _draw_main_text_single_prompt_string(state, string_get(purposeq), purpose_default, metalnumstr);
    string_destroy(layerq);
    string_destroy(purposeq);
    generics_set_layer_export_string(layer, exportname, "layer", layerstr);
    generics_set_layer_export_string(layer, exportname, "purpose", purposestr);
    free(metalnumstr);
}

static void _ask_metal_int(struct state* state, struct generics* layer, int i, const char* exportname, const char* layer_default, const char* purpose_default)
{
    struct string* layerq = _make_metal_question(i, exportname, "layer");
    struct string* purposeq = _make_metal_question(i, exportname, "purpose");
    char* metalnumstr = malloc(sizeof(char) * (5 + util_num_digits(i)) + 1);
    sprintf(metalnumstr, "metal %d", i);
    _clear_main_area(state);
    int layerstr = _draw_main_text_single_prompt_integer(state, string_get(layerq), layer_default, metalnumstr);
    _clear_main_area(state);
    int purposestr = _draw_main_text_single_prompt_integer(state, string_get(purposeq), purpose_default, metalnumstr);
    string_destroy(layerq);
    string_destroy(purposeq);
    generics_set_layer_export_integer(layer, exportname, "layer", layerstr);
    generics_set_layer_export_integer(layer, exportname, "purpose", purposestr);
    free(metalnumstr);
}

static void _read_metal_stack(struct state* state)
{
    // metal stack
    state->mode = METALSTACK;
    _draw_all(state);
    unsigned int nummetals = _draw_main_text_single_prompt_integer(state, "How many metals does the stack have?", "", "Number of Metals");
    technology_set_num_metals(state->techstate, nummetals);
    _draw_all(state);
    for(unsigned int i = 1; i <= nummetals; ++i)
    {
        size_t len = 1 + util_num_digits(i);
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "M%d", i);
        struct generics* layer = technology_add_empty_layer(state->techstate, layername);
        free(layername);
        if(state->ask_gds)
        {
            _ask_metal_int(state, layer, i, "gds", "", "0");
            _draw_all(state);
        }
        if(state->ask_skill)
        {
            _ask_metal_str(state, layer, i, "SKILL", "", "drawing");
            _draw_all(state);
        }
    }
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

void main_techfile_assistant(const struct hashmap* config)
{
    // set up
    struct state state = { 0 };
    state.mode = NONE;

    int fd = _setup_terminal(&state);
    if(fd < 1)
    {
        exit(1);
    }

    state.current_content = calloc(state.rows * state.columns, sizeof(char));
    state.next_content = calloc(state.rows * state.columns, sizeof(char));
    state.attributes = calloc(state.rows * state.columns, sizeof(int));

    terminal_clear_screen();
    terminal_cursor_visibility(0);
    _set_to_blank(&state);

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
    _clear_all(&state);
    _draw_full_text(&state, introlines, "Introduction");
    _write_to_display(&state);
    _wait_for_enter(&state);

    // technology files
    const char* techfiles[] = {
        "Technology nodes are defined by a few properties:",
        " * the physical stack-up of the process (e.g. are triple-well offered, is it an SOI process, etc.)",
        " * the layer data (e.g. metal 1 has the GDS layer/purpose pair 24/0)",
        " * rules how via cuts are created (e.g. a via cut between metal 1 and 2 is 100 x 100 nm and required this and that spacing)",
        " * critical layer dimensions (e.g. the minimum metal 1 width is 100 nm)",
        NULL
    };
    _clear_all(&state);
    _draw_full_text(&state, techfiles, "Technology Node Definition");
    _write_to_display(&state);
    _wait_for_enter(&state);

    // general
    state.mode = GENERAL;
    _clear_all(&state);
    _draw_all(&state);
    state.techname = _draw_main_text_single_prompt_string(&state, "What is the name of the technology library?", "", "Technology Name");
    state.techstate = technology_initialize(state.techname);
    const struct vector* techpaths = hashmap_get_const(config, "techpaths");
    int loaded = 0;
    if(technology_exists(techpaths, state.techname))
    {
        _draw_all(&state);
        int load = _draw_main_text_single_prompt_boolean(&state, "This technology definition already exists. Do you want to load it for editing?", "", "Technology Loading");
        if(load)
        {
            state.techstate = main_create_techstate(techpaths, state.techname, NULL); // NULL: ignored layers, not needed

            // FIXME: notify in case of errors
            loaded = 1;
        }
    }
    if(!loaded)
    {
        _draw_all(&state);
        state.ask_layer_name = _draw_main_text_single_prompt_boolean(&state, "Should the assistant ask for layer names (useful for debugging)?", "yes", "Layer Info");
        _draw_all(&state);
        state.ask_gds = _draw_main_text_single_prompt_boolean(&state, "Should the assistant ask for GDS layer data (required for GDS export)?", "yes", "Layer Info");
        _draw_all(&state);
        state.ask_skill = _draw_main_text_single_prompt_boolean(&state, "Should the assistant ask for SKILL layer data (required for SKILL/virtuoso export)?", "yes", "Layer Info");
    }
    
    // main loop (random order)
    int run = 1;
    while(run)
    {
        // menu
        const char* menu[] = {
            "Please select one of the options below to configure the technology node.",
            "The panel on the right indicates which definitions/configurations are lacking.",
            "",
            " 1) Edit Assistant Configuration",
            " 2) View Current Technology State",
            " 3) Front-End-of-Line Configuration",
            " 4) Well Configuration",
            " 5) Metal Stack",
            " 0) Quit",
            NULL
        };
        _draw_all(&state);
        _draw_main_text(&state, menu, "Main Menu");
        int choice = _get_integer(&state, "");
        switch(choice)
        {
            case 0:
                run = 0;
                break;
            case 1: // assistant configuration
                break;
            case 2: // view current technology state
                _draw_all(&state);
                _show_current_state(&state);
                _write_to_display(&state);
                _wait_for_enter(&state);
                break;
            case 3: // FEOL
                break;
            case 4: // wells
                break;
            case 5: // metals
                _read_metal_stack(&state);
                break;
        }
        if(choice == 0)
        {
            break;
        }
    }
    _save_state(&state);
    _reset_terminal(fd);
}

// vim: nowrap

/*
    Special:
    special

    FEOL:
    active
    contactactive
    contactpoly
    contactgate
    contactsourcedrain
    nimplant
    pimplant
    gate
    vthtypep1
    vthtypen1
    soiopen
    oxide1
    oxide2
    silicideblocker
    deeptrenchisolation

    Wells:
    nwell
    pwell
    deepnwell
    deeppwell

    DRC/LVS marker:
    gatemarker1
    mosfetmarker1
    lvsmarker1
    polyresistorlvsmarker1

    metal stack:
    M1
    viacutM1M2
    M2
    viacutM2M3
    M3
*/
