#include "y.tab.h"
#include "lex.yy.h"

int main (int argc, char ** argv)
{
    yyin = (argc < 2) ?
        stdin :
        fopen(argv[1], "r") ;

    if (yyin == NULL)
        return 1;

    int ret = yyparse();

    if (argc >= 2)
        fclose(yyin);

    return ret;
}
