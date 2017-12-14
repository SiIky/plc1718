%{
/* reserved keywords
 * case
 * char
 * int
 * return
 * while
 */

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

%token FLWHILE /* while loop construct */
%token FLCASE  /* case construct */

%token FLCHAR   /* char type */
%token FLINT    /* int type */
%token FLSTRING /* string type */

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

FUN_DEF : IDENT DC PARAMS TYPE LD FUN_BODY RD ;

FUN_BODY : FUN_BODY_CONTENT RET
         | RET
         ;

FUN_BODY_CONTENT : VAR_DECL
                 | BODY_CONTENT
                 ;

BODY : BODY_CONTENT BODY ;

BODY_CONTENT : /* empty */
     | VAR_ASSIGN
     | CONSTRUCT
     ;

CONSTRUCT : CONSTRUCT_WHILE
          | CONSTRUCT_CASE
          ;

CONSTRUCT_WHILE : FLWHILE RVAL LD BODY RD ;

CONSTRUCT_CASE : FLCASE RVAL LD MATCHES RD ;

MATCHES : MATCH
        | MATCH MATCHES
        ;

MATCH : LITERAL LD BODY RD ;

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
   | "!="
   | "++"
   | "--"
   | "<="
   | "=="
   | ">="
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

RVAL : LITERAL
     | FUN_CALL
     | VAR
     ;

LITERAL : CHAR
        | INTEGER
        | STRING
        ;

LVAL : VAR
     | ARR_ACC
     ;

VAR : IDENT ;

ARR_ACC : VAR LS RVAL RS

TYPE : FLCHAR
     | FLINT
     | FLSTRING
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
