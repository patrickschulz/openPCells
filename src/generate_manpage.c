#include <stdio.h>

#include "cmdoptions.h"

int main(int argc, const char* const * argv)
{
    int returnvalue = 0;
    struct cmdoptions* cmdoptions = cmdoptions_create();
    #include "cmdoptions_def.c" // yes, I did that
    if(!cmdoptions_parse(cmdoptions, argc, argv))
    {
        returnvalue = 1;
        goto DESTROY_CMDOPTIONS;
    }
    puts(".TH opc 1 \"26 Aug 2021\" \"1.0\" \"opc man page\"");
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

DESTROY_CMDOPTIONS:
    cmdoptions_destroy(cmdoptions);
    return returnvalue;
}

