#ifndef PRINT_H
#define PRINT_H

unsigned int print_get_screen_width(void);
void print_wrapped_paragraph(const char* text, unsigned int textwidth, unsigned int leftmargin);
void print_wrapped_paragraph_with_header(const char* header, const char* text, unsigned int textwidth);

#endif /* PRINT_H */
