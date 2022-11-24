#ifndef OPC_TERMINAL_COLORS_H
#define OPC_TERMINAL_COLORS_H

/* 256 colors:
 * ESC[ 38;2;⟨r⟩;⟨g⟩;⟨b⟩ m Select RGB foreground color
 * ESC[ 48;2;⟨r⟩;⟨g⟩;⟨b⟩ m Select RGB background color
 */

#define COLOR_RGB(r, g, b) "\033[38;2;" #r ";" #g ";" #b "m"

#define COLOR_BOLD         "\033[1m"

#define COLOR_BLACK        "\033[0;30m"
#define COLOR_BLACK_BOLD   "\033[1;30m"
#define COLOR_RED          "\033[0;31m"
#define COLOR_RED_BOLD     "\033[1;31m"
#define COLOR_GREEN        "\033[0;32m"
#define COLOR_GREEN_BOLD   "\033[1;32m"
#define COLOR_YELLOW       "\033[0;33m"
#define COLOR_YELLOW_BOLD  "\033[1;33m"
#define COLOR_BLUE         "\033[0;34m"
#define COLOR_BLUE_BOLD    "\033[1;34m"
#define COLOR_PURPLE       "\033[0;35m"
#define COLOR_PURPLE_BOLD  "\033[1;35m"
#define COLOR_CYAN         "\033[0;36m"
#define COLOR_CYAN_BOLD    "\033[1;36m"
#define COLOR_WHITE        "\033[0;37m"
#define COLOR_WHITE_BOLD   "\033[1;37m"
#define COLOR_NORMAL       "\033[0m"

void terminal_set_color_RGB(unsigned char R, unsigned char G, unsigned char B);
void terminal_set_bold(void);
void terminal_reset_color(void);

#endif /* OPC_TERMINAL_COLORS_H */
