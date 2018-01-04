%{
#include "y.tab.h"
%}

ALPHARE [a-zA-Z]
DIGITRE [0-9]
WHITESPACE [ \r\t]
%%

while { return FLWHILE; }
if  { return FLIF; }
else { return FLELSE; }

\/\/({WHITESPACE}|.)* { /* C++-style comments */
    printf("%s", yytext);
}

({ALPHARE}|_)({ALPHARE}|{DIGITRE}|_|')* {
    yylval.id = strdup(yytext);
    printf("%s", yylval.id);
    return IDENT;
}

-?{DIGITRE}+     {
    return INTEGER;
}

\"([^"]|\\\")*\" {
    if (yylval.s != NULL)
        free(yylval.s);
    yylval.s = strdup(yytext);
    return STRING;
}

{WHITESPACE} { ; }

%%

int yywrap (void)
{
    return 1;
}
