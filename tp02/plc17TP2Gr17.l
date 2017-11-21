%{
#include <stdio.h>
#include <string.h>

#define NDEBUG
#include "debug.h"
#undef NDEBUG

#include "srt.h"

#define VEC_IMPLEMENTATION
#include "srt_vec.h"

    int id = 1; /* ID da legenda seguinte */

    /* Variavel temporaria para conter um bloco SRT */
    struct srt srt;

    /*
     * Apontador para o vector actual, onde vamos guardar
     * todos os blocos SRT de cada ficheiro
     */
    struct srt_Vec * svec = NULL;
%}

%option noyywrap
%x SRT_ID SRT_INT SRT_SUB

%%
    { BEGIN SRT_ID; }

<SRT_ID>{
^[1-9][0-9]*[ \t]*\r?\n {
    int r = sscanf(yytext, "%d", &srt.id);

    if (r != 1)
        error("SRT_ID", "Could not read ID");
    else if (id != srt.id)
        warn("SRT_ID",
             (id < srt.id) ?
             "ID is higher than expected" :
             "ID is lower than expected"
            );

#if 0 //ndef NDEBUG
    fprintf(stderr, "DEBUG<SRT_ID>: srt.id = %d\tid = %d\n", srt.id, id);
#endif /* NDEBUG */

    id++;
    BEGIN SRT_INT;
}

\r?\n { ; }
.     { warn("SRT_ID", "Non-digit character"); }
}

<SRT_INT>{
    ^([0-9]{2}:){2}[0-9]{2},[0-9]{3}\ -->\ ([0-9]{2}:){2}[0-9]{2},[0-9]{3}\s*\r?\n {
            int r = sscanf(yytext,
                           "%02d:%02d:%02d,%03d"
                           " --> "
                           "%02d:%02d:%02d,%03d",
                           &(srt.interval.begin.tm.tm_hour),
                           &(srt.interval.begin.tm.tm_min),
                           &(srt.interval.begin.tm.tm_sec),
                           &(srt.interval.begin.tm_mil),
                           &(srt.interval.end.tm.tm_hour),
                           &(srt.interval.end.tm.tm_min),
                           &(srt.interval.end.tm.tm_sec),
                           &(srt.interval.end.tm_mil)
                          );

            if (r != 8)
                error("SRT_INT", "Could not read interval");
            else
                debug("SRT_INT", "Interval successfully read");
        BEGIN SRT_SUB;
    }

    .   { warn("SRT_INT", "Unexpected character"); }
}

<SRT_SUB>{
    ^.+\r?\n    {
        debug("SRT_SUB", yytext);
        strcat(srt.sub, yytext);
    }

    \r?\n       {
        if (!srt_push(svec, srt))
            error("SRT_SUB", "Could not save SRT block");

        memset(&srt, 0, sizeof(struct srt));
        BEGIN SRT_ID;
    }

    . { error("SRT_SUB", "This shouldn't happen"); }
}
%%
