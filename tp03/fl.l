%{
#include "y.tab.h"
%}

ALPHARE [a-zA-Z]
DIGITRE [0-9]
WHITESPACE [ \r\t\n]
%%

'='  { return AO; }
"::" { return DC; }
':'  { return CS; }
"->" { return PS; }
';'  { return ST; }

'\{' { return LD; }
'\}' { return RD; }
'\(' { return LP; }
'\)' { return RP; }
'\[' { return LS; }
'\]' { return RS; }

\/\*(.|{WHITESPACE})*?\*\/ { /* C-style comment */
    /* BUG: '?' nao funciona? */
    puts("<comment>");
    puts(yytext);
    puts("</comment>");
}

({ALPHARE}|_)({ALPHARE}|{DIGITRE}|_|')* {
    yylval.id = strdup(yytext);
    return IDENT;
}
\'{ALPHARE}\'    { return CHAR; }
-?{DIGITRE}+     { return INTEGER; }
\"([^"]|\\\")*\" { return STRING; }

{WHITESPACE} { ; }

%%

int yywrap (void)
{
    return 1;
}
