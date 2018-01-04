%{
/* reserved keywords
 * case
 * char
 * int
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
}

%token FLWHILE /* while loop construct */
%token FLIF    /* if construct */
%token FLELSE  /* else construct */

%token IDENT
%token INTEGER
%token STRING

%type <i>  INTEGER
%type <id> IDENT
%type <s>  STRING

%%

PROGRAM : FUN_DEF PROGRAM
        | FUN_DEF /* entry point */
        ;

FUN_DEF : IDENT "::" PARAMS TYPE '{' FUN_BODY '}' ;

PARAMS : PARAM PARAMS
       | /* sem params */
       ;

PARAM : IDENT ':' TYPE "->" ;

/* Funcoes tem de devolver um resultado */
FUN_BODY : FUN_BODY_CONTENT RVAL ;

FUN_BODY_CONTENT : VAR_DECL FUN_BODY_CONTENT
                 | CONSTRUCT FUN_BODY_CONTENT
                 | FUN_CALL FUN_BODY_CONTENT /* funcoes podem ter efeitos secundarios */
                 | VAR_ASSIGN FUN_BODY_CONTENT
                 | /* empty */
                 ;

BODY : BODY_CONTENT BODY ;

BODY_CONTENT : FUN_CALL
             | VAR_ASSIGN
             | CONSTRUCT
             | /* empty */
             ;

CONSTRUCT : CONSTRUCT_WHILE
          | CONSTRUCT_IF
          ;

CONSTRUCT_WHILE : FLWHILE RVAL '{' BODY '}' ;

CONSTRUCT_IF : FLIF RVAL '{' BODY '}'
             | FLIF RVAL '{' BODY '}' FLELSE '{' BODY '}'
             | FLIF RVAL '{' BODY '}' FLELSE CONSTRUCT_IF
             ;

VAR_ASSIGN : '(' '=' LVAL RVAL ')' ;

LVAL : IDENT '[' RVAL ']' /* array access */
     | IDENT
     ;

FUN_CALL : '(' FUN_NAME ARGS ')' ;

FUN_NAME : IDENT
         | OP
         ;

OP : "!=" /* diferente */
   | "&&" /* e logico */
   | "++" /* incrementar */
   | "--" /* decrementar */
   | "<=" /* menor ou igual */
   | "==" /* igual */
   | ">=" /* maior ou igual */
   | "||" /* ou logico */
   | '!'  /* negacao logica */
   | '*'  /* multiplicacao */
   | '+'  /* soma */
   | '-'  /* subtraccao */
   | '/'  /* divisao */
   | '<'  /* menor */
   | '>'  /* maior */
   | '?'  /* condicional ternario (a la C) */
   ;

VAR_DECL : '(' '=' TYPE IDENT RVAL ')'
         | '(' '=' TYPE IDENT ')'
         ;

ARGS : RVAL ARGS
     | /* sem argumentos */
     ;

RVAL : LITERAL
     | FUN_CALL
     | LVAL
     ;

LITERAL : INTEGER
        | STRING
        ;

TYPE : "Int[]"
     | "Int"
     | "Char"
     | "String"
     ;
%%

#include "lex.yy.h"

int yyerror (char * e)
{
    printf("<--codigo ate aqui\n"
           "ERROR: %s\n"
           "with input:`%s`\n",
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

fclose(yyin);

return 0;
}
