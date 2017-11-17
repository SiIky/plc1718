%{
#include <stdio.h>
#include <string.h>

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

#define VEC_IMPLEMENTATION
#define VEC_DATA_TYPE struct srt
#define VEC_PREFIX srt_
#define VEC_DATA_TYPE_EQ(L, R) ((L).id == (R).id)
#include "vec.h"

struct srt_tm diff2srt_tm (double diff)
{
    int hour = ((int) diff) / 60 / 60;
    int min = (((int) diff) / 60) - (hour * 60);
    int sec = ((int) diff) - (((hour * 60) + min) * 60);
    int mil = (diff - ((int) diff)) * 1000;

    struct srt_tm ret = (struct srt_tm) {
        .tm = (struct tm) {
            .tm_sec = sec,
            .tm_min = min,
            .tm_hour = hour,
        },
        .tm_mil = mil,
    };

    return ret;
}

struct srt_tm srt_tm_add (struct srt_tm a, struct srt_tm b)
{
    struct srt_tm ret;

    int mil_t = a.tm_mil + b.tm_mil;
    int sec_t = a.tm.tm_sec + b.tm.tm_sec;
    int min_t = a.tm.tm_min + b.tm.tm_min;
    int hour_t = a.tm.tm_hour + b.tm.tm_hour;

    ret.tm_mil = mil_t % 1000;
    ret.tm.tm_sec = (sec_t + ((int) (mil_t / 1000))) % 60;
    ret.tm.tm_min = (min_t + ((int) (sec_t / 60))) % 60;
    ret.tm.tm_hour = (hour_t + ((int) (min_t / 60))) % 60;

    return ret;
}

void exe1 (struct srt_Vec a, struct srt_Vec b, int a1, int b1)
{
    struct srt tmp;

    tmp.id = a1;
    size_t ai = srt_find(&a, tmp);

    tmp.id = b1;
    size_t bi = srt_find(&b, tmp);

    /* Caso nao encontre os IDs pedidos */
    if (ai >= srt_len(&a) || bi >= srt_len(&b)) {
        if (ai >= srt_len(&a))
            fprintf(stderr, "ID %d nao encontrado\n", a1);

        if (bi >= srt_len(&b))
            fprintf(stderr, "ID %d nao encontrado\n", b1);

        return;
    }

    struct srt na = srt_get_nth(&a, ai);
    struct srt nb = srt_get_nth(&b, bi);

    time_t ta = mktime((struct tm *)(void *)&na.interval.begin);
    time_t tb = mktime((struct tm *)(void *)&nb.interval.begin);

    struct srt_tm diff_tm = diff2srt_tm(difftime(ta, tb));

    size_t len = srt_len(&b);
    for (size_t i = 0; i < len; i++) {
        b.ptr[i].interval.begin = srt_tm_add(b.ptr[i].interval.begin, diff_tm);
        b.ptr[i].interval.end = srt_tm_add(b.ptr[i].interval.end, diff_tm);
    }

    srt_map(&b, srt_print_sub);
}

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
        srt_push(svec, srt);
        memset(&srt, 0, sizeof(struct srt));
        BEGIN INITIAL;
    }

    . { error("SRT_SUB", "This shouldn't happen"); }
}

%%

int main (int argc, char ** argv)
{
    if (argc < 5) {
        fprintf(stderr, "usage `%s FILENAME`\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    /* Um array com os vectores de cada ficheiro */
    struct srt_Vec tmp[2];

    for (int i = 1; i < 3; i++) {
        yyin = fopen(argv[i], "r");

        if (yyin == NULL) {
            fprintf(stderr, "ERROR<FILE>: could not open `%s`", argv[i]);
            continue;
        }

        id = 1;
        /* Limpar a variavel temporaria */
        memset(&srt, 0, sizeof(struct srt));

        /* Criar um novo vector para o ficheiro que vamos ler */
        tmp[i - 1] = srt_with_capacity(50);

        /* Actualizar `svec`, usada pela `yylex()` */
        svec = tmp + i - 1;

        debug("FILE", argv[i]);
        debug("LEX", "Starting yylex()");

        yylex();

        debug("LEX", "yylex() over");

#ifndef NDEBUG
        printf("srt->cap = %zu\n"
               "srt->len = %zu\n",
               srt_capacity(svec),
               srt_len(svec)
              );
#endif /* NDEBUG */

        fclose(yyin);
    }

    int i3, i4;
    sscanf(argv[3], "%d", &i3);
    sscanf(argv[4], "%d", &i4);
    exe1(tmp[0], tmp[1], i3, i4);

    return EXIT_SUCCESS;
}
