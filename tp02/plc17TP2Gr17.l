%{
#include <stdio.h>
#include <string.h>

#define NDEBUG
#include "debug.h"

#include "srt.h"

#define VEC_IMPLEMENTATION
#define VEC_DATA_TYPE struct srt
#define VEC_PREFIX srt_
#define VEC_DATA_TYPE_EQ(L, R) ((L).id == (R).id)
#include "vec.h"

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
%x SRT_INT SRT_SUB

%%

^[1-9][0-9]*[ \t]*\r?\n {
    int r = sscanf(yytext, "%d", &srt.id);

    if (r != 1)
        error("INITIAL", "Could not read ID");
    else if (id != srt.id)
        warn("INITIAL",
             (id < srt.id) ?
             "ID is higher than expected" :
             "ID is lower than expected"
            );

#ifndef NDEBUG
    fprintf(stderr, "DEBUG<INITIAL>: srt.id = %d\tid = %d\n", srt.id, id);
#endif /* NDEBUG */

    id++;
    BEGIN SRT_INT;
}

\r?\n { ; }
.     { warn("INITIAL", "Non-digit character"); }

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
        BEGIN INITIAL;
    }

    . { error("SRT_SUB", "This shouldn't happen"); }
}

%%
