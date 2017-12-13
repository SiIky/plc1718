%{
#include <stdio.h>

int yyerror (char * e);
int yylex (void);
%}

%union {
    char * id;
    char * s;
    char c;
    int i;
}

%token AO  /* assignment operator */
%token CS  /* colon separator */
%token DC  /* double colon */
%token PS  /* param separator */
%token ST  /* statement terminator */

%token LD /* left body delimiter */
%token RD /* right body delimiter */
%token LP /* left paren */
%token RP /* right paren */
%token LS /* left square bracket */
%token RS /* right square bracket */

%token CHAR
%token IDENT
%token INTEGER
%token STRING

%type <c> CHAR
%type <i> INTEGER
%type <id> IDENT
%type <s> STRING

%%

PROGRAM : FUN_DEF /* entry point */
        | FUN_DEF PROGRAM
        ;

FUN_DEF : IDENT DC PARAMS TYPE LD BODY RD ;

BODY : BODY_CONTENT BODY
     | BODY_CONTENT
     ;

BODY_CONTENT : VAR_DECL
             | VAR_ASSIGN
             | RET
             ;

VAR_ASSIGN : LVAL AO RVAL ST ;

RET : "ret" RVAL ST ;

FUN_CALL : LP FUN_NAME ARGS RP ;

FUN_NAME : IDENT
         | OP
         ;

OP : '+'
   | '*'
   | '-'
   | '/'
   | '<'
   | '>'
   | "=="
   | ">="
   | "<="
   ;

PARAMS : /* sem params */
       | PARAM PARAMS
       ;

PARAM : VAR_TYPE PS ;

VAR_TYPE : IDENT CS TYPE ;

VAR_DECL : VAR_TYPE AO RVAL ST
         | VAR_TYPE ST
         ;

ARGS : /* sem argumentos */
     | RVAL ARGS
     ;

RVAL : CONSTANT
     | FUN_CALL
     | VAR
     ;

CONSTANT : CHAR
         | INTEGER
         | STRING
         ;

LVAL : VAR
     | ARR_ACC
     ;

ARR_ACC : VAR LS RVAL RS

VAR : IDENT ;

TYPE : CHAR
     | INTEGER
     | STRING
     ;
%%

#include "lex.yy.h"

int yyerror (char * e)
{
    printf("ERROR: %s\n"
           "with input:%s\n",
           e,
           yytext);
    return 0;
}

int main (int argc, char ** argv)
{
    yyin = (argc < 2) ?
        stdin :
        fopen(argv[1], "r") ;

    if (yyin == NULL)
        return 1;

    yyparse();
    return 0;
}
