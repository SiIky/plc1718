%{
#include <stdio.h>
#include <string.h>

#include "y.tab.h"
%}

ALPHARE [a-zA-Z]
DIGITRE [0-9]
WHITESPACE [ \t]

%%

\/\/[^\n]*\n { /* C++-style comments */
    ECHO;
}

-?{DIGITRE}+      { ; return LIT_INT; }
\"([^\"]|\\\")*\" { yylval.String = strdup(yytext); return LIT_STR; }

"++"      { ; return FLINC;   }
"--"      { ; return FLDEC;   }

"\=\="    { ; return FLEQ;    }
"!\="     { ; return FLNEQ;   }

"&&"      { ; return FLAND;   }
"||"      { ; return FLOR;    }

"!"       { ; return FLNOT;   }

"\("      { ; return FLLP;    }
"\)"      { ; return FLRP;    }
"\{"      { ; return FLLD;    }
"\}"      { ; return FLRD;    }

"+"       { ; return FLADD;   }
"-"       { ; return FLSUB;   }
"*"       { ; return FLMUL;   }
"/"       { ; return FLDIV;   }

"\="      { ; return FLASGN;  }

"while"   { ; return FLWHILE; }
"if"      { ; return FLIF;    }
"else"    { ; return FLELSE;  }

"readint" { return FLREADINT; }
"print"   { return FLPRITN;   }
"write"   { return FLWRITE;   }

(_|{ALPHARE})(_|{ALPHARE}|{DIGITRE})* { return IDENT; }

{WHITESPACE}* { ; }

. { printf("Unexpected input: `%s`\n", yytext); }
%%

int yywrap (void)
{
    return 1;
}
