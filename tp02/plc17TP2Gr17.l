%{
#include <stdio.h>
#include <time.h>

#ifndef NDEBUG
# define debug(ctx, msg) (fprintf(stderr, "DEBUG<%s>: %s\n", (ctx), (msg)))
# define error(ctx, msg) (fprintf(stderr, "ERROR<%s>: %s\n", (ctx), (msg)))
# define warn(ctx, msg)  (fprintf(stderr, "WARNING<%s>: %s\n", (ctx), (msg)))
#else
# define debug(ctx, msg) ((void) 0)
# define error(ctx, msg) ((void) 0)
# define warn(ctx, msg)  ((void) 0)
#endif /* NDEBUG */

    struct srt_tm {
        struct tm tm;
        int tm_mil;
    };

    struct srt_interval {
        struct srt_tm begin;
        struct srt_tm end;
    };

    struct srt {
        int id;
        struct srt_interval interval;
        char sub[256];
    };

struct srt srt_print_sub (struct srt srt)
{
    printf("%s", srt.sub);
    return srt;
}

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

[1-9][0-9]*[ \t]*\n     {
       if ((sscanf(yytext, "%d", &srt.id) != 1) || (id != srt.id))
           warn("INITIAL", "Unexpected ID");

       fprintf(stderr, "DEBUG<INITIAL>: srt.id = %d\tid = %d\n", srt.id, id);
       id++;
       BEGIN SRT_INT;
}

\n                      { ; }
.                       {
    warn("INITIAL", "Non-digit character");
}

<SRT_INT>{
    ([0-9]{2}:){2}[0-9]{2},[0-9]{3}\ -->\ ([0-9]{2}:){2}[0-9]{2},[0-9]{3} {
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

    .       {
        warn("SRT_INT", "Unexpected character on time interval");
    }
}

<SRT_SUB>{
    .+\r?\n    {
        strcat(srt.sub, yytext);
    }

    \r?\n      {
        srt_push(svec, srt);
        memset(&srt, 0, sizeof(struct srt));
        BEGIN INITIAL;
    }
}
%%

int main (int argc, char ** argv)
{
    if (argc < 2) {
        fprintf(stderr, "usage `%s FILENAME`\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    for (int ai = 1; ai < argc; ai++) {
        yyin = fopen(argv[ai], "r");

        if (yyin == NULL) {
            fprintf(stderr, "ERROR: could not open `%s`", argv[ai]);
            continue;
        }

        id = 1;
        memset(&srt, 0, sizeof(struct srt));
        struct srt_Vec tmp = srt_with_capacity(50);
        svec = &tmp;

        debug("FILE", argv[ai]);
        debug("LEX", "Starting yylex()");

        yylex();

        debug("LEX", "yylex() over");
        printf("srt->cap = %zu\n"
               "srt->len = %zu\n",
               srt_capacity(svec),
               srt_len(svec)
              );

        srt_map(svec, srt_print_sub);
        srt_free(svec, NULL);
        fclose(yyin);
    }

    return EXIT_SUCCESS;
}
