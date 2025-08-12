#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

#include "lua_util.h"
#include "print.h"
#include "terminal.h"

#define SIDE_PANEL_FACTOR 0.25

struct state {
    char* libname;
    int FEOL;
    int BEOL;
};

static void _load_state(const char* filename, struct state* state)
{

}

static void _write_boolean(FILE* file, const char* identifier, int value)
{
    fprintf(file, "    %s = %s,\n", identifier, value ? "true" : "false");
}

static void _save_state(const char* filename, struct state* state)
{
    FILE* config = fopen(filename, "w");
    fputs("return {\n", config);
    _write_boolean(config, "FEOL", state->FEOL);
    _write_boolean(config, "BEOL", state->BEOL);
    fputs("}\n", config);
    fclose(config);
}

static void _print(int row, int column, const char* str, size_t len)
{
    terminal_cursor_set_position(row, column);
    for(size_t i = 0; i < len; ++i)
    {
        write(STDOUT_FILENO, str + i, 1);
    }
}

static void _clear_character_under_cursor(void)
{
    terminal_cursor_move_left(1);
    putchar(' ');
}

static const char* _get_string(int row, int column, const char* prefill)
{
    terminal_cursor_visibility(1);
    char buf[256];
    strcpy(buf, prefill);
    size_t i = strlen(prefill);
    _print(row, column, buf, i);
    while(1)
    {
        int ch = getchar();
        if(ch == 13)
        {
            break;
        }
        if(ch == 127) // backspace
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
    return buf;
}

static void _write_tech_entry_boolean(const char* key, int value)
{
    if(value)
    {
        write(STDOUT_FILENO, "[x] ", 4);
    }
    else
    {
        write(STDOUT_FILENO, "[ ] ", 4);
    }
    write(STDOUT_FILENO, key, strlen(key));
}

static void _write_tech_entry_string(const char* key, const char* value)
{
    write(STDOUT_FILENO, key, strlen(key));
    write(STDOUT_FILENO, ": ", 2);
    if(value)
    {
        write(STDOUT_FILENO, value, strlen(value));
    }
}

static void _draw_panel(int xl, int xr, int yt, int yb, const char* title)
{
    // corners
    terminal_cursor_set_position(yt, xl);
    write(STDOUT_FILENO, "┌", 4);
    terminal_cursor_set_position(yb, xl);
    write(STDOUT_FILENO, "└", 4);
    terminal_cursor_set_position(yt, xr);
    write(STDOUT_FILENO, "┐", 4);
    terminal_cursor_set_position(yb, xr);
    write(STDOUT_FILENO, "┘", 4);
    // left/right line
    for(int i = yt + 1; i <= yb - 1; ++i)
    {
        terminal_cursor_set_position(i, xl);
        write(STDOUT_FILENO, "│", 4);
        terminal_cursor_set_position(i, xr);
        write(STDOUT_FILENO, "│", 4);
    }
    // top/bottom line
    for(int i = xl + 1; i <= xr - 1; ++i)
    {
        terminal_cursor_set_position(yt, i);
        write(STDOUT_FILENO, "─", 4);
        terminal_cursor_set_position(yb, i);
        write(STDOUT_FILENO, "─", 4);
    }
    if(title)
    {
        // title line
        for(int i = xl + 1; i <= xr - 1; ++i)
        {
            terminal_cursor_set_position(yt + 2, i);
            write(STDOUT_FILENO, "─", 4);
        }
        // title line "corners" (purposely overwrites two previously characters)
        terminal_cursor_set_position(yt + 2, xl);
        write(STDOUT_FILENO, "├", 4);
        terminal_cursor_set_position(yt + 2, xr);
        write(STDOUT_FILENO, "┤", 4);
        // title
        terminal_cursor_set_position(2, xl + (xr - xl + 2 - strlen(title)) / 2);
        write(STDOUT_FILENO, title, strlen(title));
    }
}

static void _draw_side_panel(struct state* state, int rows, int columns)
{
    int startpos = (1 - SIDE_PANEL_FACTOR) * columns;
    _draw_panel(startpos, columns, 1, rows, "settings");
    terminal_cursor_set_position(4, startpos + 3);
    _write_tech_entry_string("Library Name", state->libname);
    terminal_cursor_set_position(5, startpos + 3);
    _write_tech_entry_boolean("FEOL", state->FEOL);
    terminal_cursor_set_position(6, startpos + 3);
    _write_tech_entry_boolean("BEOL", state->BEOL);
}

/*
static void _draw_prompt_line(int rows, int columns)
{
    terminal_set_reverse_color();
    terminal_cursor_set_position(rows - NUM_PROMPT_LINES + 1, 1);
    for(int i = 0; i < columns; ++i)
    {
        write(STDOUT_FILENO, " ", 1);
    }
    terminal_cursor_set_position(rows - NUM_PROMPT_LINES + 1, 2);
    //write(STDOUT_FILENO, ">", 1);
    terminal_reset_color();
}
*/

static void _draw_main_text(const char* const* text, int rows, int columns)
{
    int xstart = 20;
    int xend = 80;
    int textwidth = xend - xstart - 4;
    const char* const* lines = text;
    // set up panel
    size_t totallines = 0;
    while(*lines)
    {
        char** wrapped = print_split_in_wrapped_lines(*lines, textwidth);
        // count wrapped lines
        char** line = wrapped;
        while(*line)
        {
            ++totallines;
            ++line;
        }
        totallines += 1;
        ++lines;
    }
    totallines -= 1;
    // draw panel
    int ystart = 10;
    int yend = ystart + totallines + 1;
    _draw_panel(xstart, xend, ystart, yend, NULL);
    // draw text
    size_t lineindex = 0;
    lines = text;
    while(*lines)
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
        line = wrapped;
        size_t i = 0;
        while(*line)
        {
            terminal_cursor_set_position(ystart + lineindex + 1 + i, xstart + 2);
            write(STDOUT_FILENO, *line, strlen(*line));
            ++i;
            ++line;
        }
        lineindex += numlines;
        lineindex += 1;
        ++lines;
    }
}

static void _draw_main_text_single(const char* text, int rows, int columns)
{
    static const char* lines[] = {
        NULL,
        NULL
    };
    lines[0] = text;
    _draw_main_text(lines, rows, columns);
}

static void _draw_main_text_single_prompt(const char* text, const char* prompt, int rows, int columns)
{
    _draw_main_text_single(text, rows, columns);
    terminal_cursor_set_position(rows - 5, 8);
    write(STDOUT_FILENO, "> ", 2);
    const char* libname = _get_string(rows - 5, 10, "<technology>");
}

static void _clear_main_area(int rows, int columns)
{
    int xstart = 1;
    int xend = (1 - SIDE_PANEL_FACTOR) * columns - 1;
    int ystart = 1;
    int yend = rows - 1;
    for(int i = xstart; i <= xend; ++i)
    {
        for(int j = ystart; j <= yend; ++j)
        {
            terminal_cursor_set_position(j, i);
            write(STDOUT_FILENO, " ", 1);
        }
    }
}

static void _wait_for_enter(void)
{
    while(1)
    {
        int ch = getchar();
        if(ch == 13)
        {
            break;
        }
    }
}

// forward declaration for different compiler versions
void cfmakeraw(struct termios*);

void main_techfile_assistant(void)
{
    int fd;
    fd = open("/dev/tty", O_RDWR);
    if(fd < 1)
    {
        puts("could not open file descriptor");
        exit(1);
    }
    struct termios termios;
    int ret = tcgetattr(fd, &termios);
    struct termios old_settings = termios; // copy for restoring the old state
    if(ret != 0)
    {
        puts("could not retrieve terminal state");
        exit(1);
    }
    cfmakeraw(&termios);
    tcsetattr(fd, TCSAFLUSH, &termios);
    terminal_cursor_visibility(0);
    int rows, columns;
    terminal_get_screen_size(&rows, &columns);

    struct state state = { 0 };
    while(1)
    {
        terminal_clear_screen();
        terminal_cursor_set_position(rows / 2, columns / 2);
        //_draw_prompt_line(rows, columns);
        _draw_side_panel(&state, rows, columns);
        const char* introlines[] = {
            "Hello, this is the technology file assistant.",
            "I will ask you a few questions to help you create the technology file.",
            "All questions will prompt you for an answer, you can enter some characters and give the answer by hitting return. Some questions will be yes/no, where the default will be marked like this: (Yes/no) -> yes is the default. This can be affirmed by hitting return on an empty line Some questions on the other hand will require a full answer. If a default is available, it will be shown in braces (like this).",
            "(hit <enter> to continue)",
            NULL
        };
        _draw_main_text(introlines, rows, columns);
        _wait_for_enter();
        _clear_main_area(rows, columns);
        _draw_main_text_single_prompt("What is the name of the technology library?", "<technology>", rows, columns);
        break;
        /*
        int ch = getchar();
        if(ch == 'q')
        {
            break;
        }
        if(ch == 'f')
        {
            state.FEOL = 1;
        }
        if(ch == 'b')
        {
            state.BEOL = 1;
        }
        */
    }
    terminal_cursor_visibility(1);
    terminal_clear_screen();
    tcsetattr(fd, TCSAFLUSH, &old_settings);
    _save_state("_assistant_config.lua", &state);
    close(fd);
}

/*
print("Hello, this is the technology file assistant.")
print("I will ask you a few questions to help you create the technology file.")
print("All questions will prompt you for an answer, you can enter some characters and give the answer by hitting return.")
print("Some questions will be yes/no, where the default will be marked like this: (Yes/no) -> yes is the default. This can be affirmed by hitting return on an empty line")
print("Some questions on the other hand will require a full answer. If a default is available, it will be shown in braces (like this).")
print()
_set_color("red")
io.write("Currently, no auto-saving mechanisms are implemented. If you need to save your progress at any time, you can type ")
_set_bold()
io.write("'!save'")
_reset_color()
_set_color("red")
print(" as an answer to any question.")
_reset_color()
print()
print("Let's get started:")

-- data state
local state = {
    entries = {},
}

-- assistant options
local options = {}

state.libname = question(state, "What is the name of the library")
if filesystem.exists(string.format("tech/%s", state.libname)) then
    print()
    print("this library already exists, reading content")
    load(state, options)
    print()
    state.already_defined = true
end
print("Usually it is helpful to set up at least the GDSII (and perhaps virtuoso) information.")

local askoptions
if state.already_defined then
    print("the following assistant questions were detected while loading the previous tech state:")
    print(string.format("ask GDS layer information:    %s", options.askGDS and "true" or "false"))
    print(string.format("ask SKILL layer information:  %s", options.askSKILL and "true" or "false"))
    print(string.format("ask layer name:               %s", options.askname and "true" or "false"))
    askoptions = not yesno(state, "Are these options correct?")
else
    askoptions = true
end

if askoptions then
    options.askGDS = yesno(state, "Do you want to specify GDS layer information for the layers?")
    options.askSKILL = yesno(state, "Do you want to specify SKILL layer information for the layers?")
    options.askname = yesno(state, "For debugging purposes, it can be useful to assign a name for every layer. Do you want to be asked for layer names?")
end

if not options.askGDS and not options.askSKILL then
    _set_color("red")
    _set_bold()
    print("the current options don't ask for any actual layer data. This is an error, exiting.")
    _reset_color()
    return 1
end

-- SOI
if not state.ignore_SOI then
    state.is_SOI = noyes(state, "Is this process a silicon-on-insulator (SOI) process?")
    if state.is_SOI then
        state.contact_wells_in_handle_wafer = noyes(state, "SOI processes have a handle wafer under the buried oxide (BOX). Those this handle wafer need to be contacted for regular wells transistors reside in?")
        state.handle_wafer_access = noyes(state, "Additionally, for special purpose there still might be a way to contact the handle wafer. Does this technology node provide such access?")
    end
    if state.is_SOI and (state.contact_wells_in_handle_wafer or state.handle_wafer_access) then
        ask_layer(
            state,
            "soiopen", 
            "SOI processes have a layer to cut the oxide between both silicon sheets.",
            options
        )
    end
    print()
end

-- wells
print("Let's discuss substrate dopings and wells")
if not state.substrate_dopand then
    state.substrate_dopand = choice(state, "What is the dopand type of the substrate?", { "p-substrate", "n-substrate" })
else
    print(string.format("substrate dopand type is already defined: '%s'", state.substrate_dopand))
end
if not state.ignore_triple_well then
    state.has_triple_well = yesno(state, "Is this node a triple-well process?")
else
    print(string.format("the process's support of triple-wells is already defined as '%s'", state.has_triple_well))
end
-- main wells
if state.substrate_dopand == "p-substrate" then
    if not has_layer(state, "nwell") then
        ask_layer(
            state,
            "nwell", 
            "The n-well layer is used to form n-doped areas",
            options
        )
    end
else
    if not has_layer(state, "pwell") then
        ask_layer(
            state,
            "pwell", 
            "The p-well layer is used to form p-doped areas",
            options
        )
    end
end
-- deep wells
if state.has_triple_well then
    if state.substrate_dopand == "p-substrate" then
        if not has_layer(state, "deepnwell") then
            ask_layer(
                state,
                "deepnwell", 
                "The deep-n-well layer is used to form isolated p-wells",
                options
            )
        end
    else
        if not has_layer(state, "deeppwell") then
            ask_layer(
                state,
                "deeppwell", 
                "The deep-p-wells layer is used to form isolated n-wells",
                options
            )
        end
    end
end
print("wells configuration is completed.")
print()

-- active
if not state.FEOL_method then
    print()
    print("Let's discuss active transistor regions. In some process, there is a generic 'active' region turned into n-plus or p-plus by additional marking layers (three layers in total) ('active_plus_implant'). In other processes, there are dedicated n-plus and p-plus active layers (two layers) ('dedicated_active'). Lastly, there are also processes where only n- or p-implants are marked and active regions without markings are the opposite (also two layers) ('asymmetric_active').")
    state.FEOL_method = choice(state, "Which active/implant method does this technology use?", { "active_plus_implant", "dedicated_active", "asymmetric_active" })
else
    print(string.format("the FEOL method for specifying MOSFET source/drain regions and other active areas is already defined as '%s'", state.FEOL_method))
end

if not state.ignore_FEOL_method then
    if state.FEOL_method == "active_plus_implant" then
        ask_layer(
            state,
            "active", 
            "Let's talk about the active layer.",
            options
        )
        ask_layer(
            state,
            "pimplant", 
            "Let's talk about the p-plus implant marking layer.",
            options
        )
        ask_layer(
            state,
            "nimplant", 
            "Let's talk about the n-plus implant marking layer.",
            options
        )
    elseif state.FEOL_method == "dedicated_active" then
    elseif state.FEOL_method == "asymmetric_active" then
    else
        -- error, can't happen
    end
end

-- gate layer
if not has_layer(state, "gate") then
    ask_layer(
        state,
        "gate", 
        "Let's talk about the gate layer (e.g. polysilicon)",
        options
    )
end

-- gate cut layer
if not state.ignore_gatecut then
    state.has_gatecut = noyes(state, "Does this process have a mask layer to cut gates?")
    if state.has_gatecut then
        ask_layer(
            state,
            "gatecut", 
            "Let's talk about the gate cut layer",
            options
        )
    else
        add_empty_entry(
            state,
            "gatecut"
        )
    end
end

print()
print("Let us move on to the metal stack")

-- FIXME: vias
if not state.nummetals then
    state.nummetals = number(state, "How many metals does this metal stack have (ALL metals, including top-level layers for pads etc. as well as common interconnect layers above gates and active regions)?")
    for i = 1, state.nummetals do
        ask_layer(
            state,
            string.format("M%d", i),
            string.format("Metal %d", i),
            options
        )
    end
    print("Now let's capture the via layers")
    for i = 1, state.nummetals - 1 do
        ask_layer(
            state,
            string.format("viacutM%dM%d", i, i + 1),
            string.format("Via %d (between metal %d and %d)", i, i, i + 1),
            options
        )
    end
end
*/
