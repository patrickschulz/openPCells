#ifndef OPC_TERMINAL_COLORS_H
#define OPC_TERMINAL_COLORS_H

/* 256 colors:
 * ESC[ 38;2;⟨r⟩;⟨g⟩;⟨b⟩ m Select RGB foreground color
 * ESC[ 48;2;⟨r⟩;⟨g⟩;⟨b⟩ m Select RGB background color
 */

#define TERMINAL_ESCAPE         "\033"
#define TERMINAL_CSI            "\033["
#define TERMINAL_CLEAR_SCREEN   "2J"
#define TERMINAL_CURSOR_0       "1;1H"
#define TERMINAL_COLOR_END      "m"

#define COLOR_RGB(r, g, b)      "\033[38;2;" #r ";" #g ";" #b "m"
#define COLOR_BOLD              "\033[1m"
#define COLOR_NORMAL            "\033[0m"

void terminal_set_foreground_color_RGB(unsigned char R, unsigned char G, unsigned char B);
void terminal_set_background_color_RGB(unsigned char R, unsigned char G, unsigned char B);
void terminal_set_bold(void);
void terminal_reset_color(void);
void terminal_clear_screen(void);

#endif /* OPC_TERMINAL_COLORS_H */
