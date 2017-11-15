%{
#define _GNU_SOURCE
#include <stdio.h>
#include <time.h>

#define NDEBUG
#ifndef NDEBUG
# define debug(ctx, msg) (fprintf(stderr, "DEBUG<%s>: %s\n", (ctx), (msg)))
# define error(ctx, msg) (fprintf(stderr, "ERROR<%s>: %s\n", (ctx), (msg)))
# define warn(ctx, msg)  (fprintf(stderr, "WARNING<%s>: %s\n", (ctx), (msg)))
#else
# define debug(ctx, msg) ((void) 0)
# define error(ctx, msg) ((void) 0)
# define warn(ctx, msg)  ((void) 0)
#endif /* NDEBUG */

#include "srt.h"

#define VEC_DATA_TYPE struct srt
#define VEC_PREFIX srt_
#define VEC_DATA_TYPE_EQ(L, R) ((L).id == (R).id)
#include "vec.h"

    int id = 1; /* ID da legenda seguinte */

    struct srt srt;
    struct srt_Vec * svec = NULL;
%}

%option noyywrap
%x SRT_INT SRT_SUB

%%

^[1-9][0-9]*[ \t]*\r?\n {
       if ((sscanf(yytext, "%d", &srt.id) != 1) || (id != srt.id))
           warn("INITIAL", "Unexpected ID");

#ifndef NDEBUG
       fprintf(stderr, "DEBUG<INITIAL>: srt.id = %d\tid = %d\n", srt.id, id);
#endif /* NDEBUG */
       id++;
       BEGIN SRT_INT;
}

(\r)?\n                 { ; }
.                       { warn("INITIAL", "Non-digit character"); }

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
    ^.+(\r)?\n    {
        debug("SRT_SUB", yytext);
        strcat(srt.sub, yytext);
    }

    ((\r)?\n)+      {
        debug("SRT_SUB", srt.sub);
        srt_push(svec, srt);
        memset(&srt, 0, sizeof(struct srt));
        BEGIN INITIAL;
    }

    . { error("SRT_SUB", "This shouldn't happen"); }
}

%%

int main (int argc, char ** argv)
{
    if (argc < 2) {
        fprintf(stderr, "usage `%s FILENAME`\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    for (int i = 1; i < argc; i++) {
        yyin = fopen(argv[i], "r");

        if (yyin == NULL) {
            fprintf(stderr, "ERROR<FILE>: could not open `%s`", argv[i]);
            continue;
        }

        id = 1;
        memset(&srt, 0, sizeof(struct srt));
        struct srt_Vec tmp = srt_with_capacity(50);
        svec = &tmp;

        debug("FILE", argv[i]);
        debug("LEX", "Starting yylex()");

        yylex();

        debug("LEX", "yylex() over");
        printf("srt->cap = %zu\n"
               "srt->len = %zu\n",
               srt_capacity(svec),
               srt_len(svec)
              );

        size_t len = srt_len(svec);
        for (size_t j = 0; j < len; j++)
            puts(svec->ptr[j].sub);

        srt_free(svec, srt_dtor);
        fclose(yyin);
    }

    return EXIT_SUCCESS;
}
