%{
#include "lex.yy.h"
int yyerror (char *);
%}

%union {
    char * String;
    char * ident;
    int    Int;
}

%token FLASGN /* assignment operator */

/* identifier */
%token <ident> IDENT

/* literals */
%token <Int>    LIT_INT /* integer */
%token <String> LIT_STR /* string */

/* std functions */
%token FLREADINT
%token FLPRITN
%token FLWRITE

/* constructs */
%token FLWHILE
%token FLIF
%token FLELSE

/* delimiters */
%token FLLP /* left expression operator */
%token FLRP /* right expression operator */
%token FLLD /* left body delimiter */
%token FLRD /* right body delimiter */

/* unary arithmetic operators */
%token FLINC /* increment */
%token FLDEC /* decrement */

/* compare operators */
%token FLEQ  /* equal */
%token FLNEQ /* not equal */

/* logical operators */
%token FLAND /* and */
%token FLOR  /* or */
%token FLNOT /* not */

/* arithmetic operators */
%token FLADD /* add */
%token FLSUB /* subtract */
%token FLMUL /* multiply */
%token FLDIV /* divide */
%%

program : FLWHILE { printf("while\n"); }
        | FLASGN  { printf("=\n"); }
        | FLIF    { printf("if\n"); }
        | FLELSE  { printf("else\n"); }
        | LIT_INT { printf("Int\n"); }
        | LIT_STR { printf("String:\"%s\"\n", yylval.String); }
        | FLLP    { printf("(\n"); }
        | FLRP    { printf(")\n"); }
        | FLLD    { printf("{\n"); }
        | FLRD    { printf("}\n"); }
        | FLINC   { printf("++\n"); }
        | FLDEC   { printf("--\n"); }
        | FLEQ    { printf("==\n"); }
        | FLNEQ   { printf("!=\n"); }
        | FLAND   { printf("&&\n"); }
        | FLOR    { printf("||\n"); }
        | FLNOT   { printf("!\n"); }
        | FLADD   { printf("+\n"); }
        | FLSUB   { printf("-\n"); }
        | FLMUL   { printf("*\n"); }
        | FLDIV   { printf("/\n"); }
        | IDENT   { printf("%s\n", yytext); }
        ;

%%

int yyerror (char * e)
{
    return printf("ERROR: `%s` with input `%s`\n",
           e,
           yytext);
}
