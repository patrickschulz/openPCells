#ifndef OPC_TERMINAL_COLORS_H
#define OPC_TERMINAL_COLORS_H

/* 256 colors:
 * ESC[ 38;2;⟨r⟩;⟨g⟩;⟨b⟩ m Select RGB foreground color
 * ESC[ 48;2;⟨r⟩;⟨g⟩;⟨b⟩ m Select RGB background color
 */

#define TERMINAL_ESCAPE                 "\033"
#define TERMINAL_CSI                    "\033["
#define TERMINAL_CLEAR_SCREEN           "2J"
#define TERMINAL_CURSOR_UP              "A"
#define TERMINAL_CURSOR_DOWN            "B"
#define TERMINAL_CURSOR_RIGHT           "D"
#define TERMINAL_CURSOR_LEFT            "D"
#define TERMINAL_CURSOR_FIRST_COLUMN    "G"
#define TERMINAL_CURSOR_MOVE            "H"
#define TERMINAL_CURSOR_0               "1;1H"
#define TERMINAL_COLOR_END              "m"

#define COLOR_RGB(r, g, b)      "\033[38;2;" #r ";" #g ";" #b "m"
#define COLOR_BOLD              "\033[1m"
#define COLOR_NORMAL            "\033[0m"

void terminal_get_screen_size(int* rows, int* columns);
void terminal_cursor_visibility(int visible);
void terminal_set_reverse_color(void);
void terminal_set_foreground_color_RGB(unsigned char R, unsigned char G, unsigned char B);
void terminal_set_background_color_RGB(unsigned char R, unsigned char G, unsigned char B);
void terminal_set_bold(void);
void terminal_reset_color(void);
void terminal_reset_all(void);
void terminal_clear_screen(void);
void terminal_cursor_set_position(unsigned int row, unsigned int column);
void terminal_cursor_line_up(unsigned int lines);
void terminal_cursor_line_down(unsigned int lines);
void terminal_cursor_move_left(unsigned int columns);
void terminal_cursor_move_first_column(void);

#endif /* OPC_TERMINAL_COLORS_H */
