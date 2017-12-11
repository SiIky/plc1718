%x ALPHA
%x DIGIT
%x IDENT

%%

AO  : "="  ; /* assignment operator */
CS  : ":"  ; /* colon separator */
DC  : "::" ; /* double colon */
LBD : "{"  ; /* left body delimiter */
LP  : "("  ; /* left paren */
PS  : "->" ; /* param separator */
RBD : "}"  ; /* right body delimiter */
RP  : ")"  ; /* right paren */
ST  : ";"  ; /* statement terminator */

/* entry point is necessary */
PROGRAM : FUN_DEF
        | FUN_DEF PROGRAM
        ;

FUN_DEF : IDENT DC PARAMS TYPE LBD BODY RBD
        | IDENT DC TYPE LBD BODY RBD
        ;

BODY : BODY_CONTENT BODY
     | BODY_CONTENT
     ;

BODY_CONTENT : VAR_DECL
             | VAR_ASSIGN
             | RET
             ;

VAR_ASSIGN : LVAL AO RVAL ST ;

RET : "ret" RVAL ST ;

FUN_CALL : LP IDENT ARGS RP
         | LP IDENT RP
         ;

PARAMS : PARAM PARAMS
       | PARAM
       ;

PARAM : VAR_TYPE PS ;

VAR_TYPE : IDENT CS TYPE ;

VAR_DECL : VAR_TYPE AO RVAL ST
         | VAR_TYPE ST
         ;

ARGS : RVAL ARGS
     | RVAL
     ;

%%
