%%

([a-zA-Z]|_)([a-zA-Z]|[0-9]|_|')* { return IDENT; }
[0-9] { return DIGIT; }
[a-zA-Z] { return ALPHA; }
-?[0-9]+(.[0-9]*)?([eE]([+-])?[0-9]+)?
-?[0-9]+ { return INTEGER; }
\"([^"]|\\\")*\" { return STRING; }

%%
