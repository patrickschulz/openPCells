#include "../src/version.h"

#include <stdio.h>
#include <sys/stat.h>

int main()
{
    mkdir("includes", S_IRWXU | S_IRWXG | S_IRWXO);
    FILE* file = fopen("includes/footer.html", "w");
	fputs("<div class=\"footerbar\">\n", file);
	fputs("    <hr>\n", file);
	fputs("    <footer>\n", file);
    fprintf(file, "        OpenPCells Documentation &ndash; Version %u.%u.%u\n", OPC_VERSION_MAJOR, OPC_VERSION_MINOR, OPC_VERSION_REVISION);
	fputs("    </footer>\n", file);
	fputs("</div>\n", file);
    fclose(file);
}
