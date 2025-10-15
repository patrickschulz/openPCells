#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "cmdoptions.h"

int main(void)
{
    struct cmdoptions* cmdoptions = cmdoptions_create();
    #include "cmdoptions_def.c" // yes, I did that
    time_t t = time(NULL);
    char strtime[100];
    strftime(strtime, 100, "%Y-%m-%d", localtime(&t));
    printf(".TH opc 1 \"%s\" \"1.0\" \"opc man page\"\n", strtime);
    puts(".SH NAME");
    puts("opc \\- parametric and technology-independent IC layout generator");
    puts(".SH SYNOPSIS");
    puts("opc [--cell cellname] [--technology technology] [--export export]");
    puts(".SH DESCRIPTION");
    puts(".B opc ");
    puts("is a technology-independent layout generator for integrated circuits with support for parametric cells.");
    cmdoptions_export_manpage(cmdoptions);
    puts(".SH AUTHOR");
    puts("Patrick Kurth <p.kurth@posteo.de>");

    cmdoptions_destroy(cmdoptions);
    return 0;
}

