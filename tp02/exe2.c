#include <stdio.h>
#include <string.h>

#include "flex.h"

#define NDEBUG
#include "debug.h"
#undef NDEBUG

#include "srt.h"

#include "srt_vec.h"

extern int id;
extern struct srt srt;
extern struct srt_Vec * svec;

int gcharsub (char * str, char s, char r)
{
    int ret = 0;
    char * f = str;

    for (; (f = strchr(f, s)) != NULL; ret++)
        *f = r;

    return ret;
}

struct srt srt_sub_nl (struct srt e)
{
    gcharsub(e.sub, '\n', '|');

    char * f = strrchr(e.sub, '|');
    if (f != NULL && *f == '|' && f[1] == '\0')
        *f = '\0';

    return e;
}

struct srt srt_print (struct srt ret)
{
    printf(
        "%02d:%02d:%02d,%03d"
        " --> "
        "%02d:%02d:%02d,%03d "
        "%s\n",
        ret.interval.begin.tm.tm_hour,
        ret.interval.begin.tm.tm_min,
        ret.interval.begin.tm.tm_sec,
        ret.interval.begin.tm_mil,
        ret.interval.end.tm.tm_hour,
        ret.interval.end.tm.tm_min,
        ret.interval.end.tm.tm_sec,
        ret.interval.end.tm_mil,
        ret.sub
        );
    return ret;
}

double tm_difftime (struct tm a, struct tm b)
{
    double ret = 0;

    time_t ta = mktime(&a);
    time_t tb = mktime(&b);

    /* tb - ta */
    ret = difftime(tb, ta);

    return ret;
}

bool exe2 (struct srt_Vec * vec)
{
    bool ret = srt_map(vec, srt_sub_nl);

    size_t len = srt_len(vec);

    for (size_t i = 1; i < len; i++) {
        struct srt sa = srt_get_nth(vec, i - 1);
        struct srt sb = srt_get_nth(vec, i);

        srt_print(sa);

        { /* Imprimir '='s se diff for > 2s */
            time_t ta = mktime(&sa.interval.end.tm);
            time_t tb = mktime(&sb.interval.begin.tm);

            /* tb - ta */
            double diff = difftime(tb, ta);
            if (diff >= 2.0f) {
                struct srt tmp;
                /* 50 */
                strcpy(tmp.sub, "==================================================");
                tmp.interval.begin = sa.interval.end;
                tmp.interval.end = sb.interval.begin;

                srt_print(tmp);
            }
        }
    }

    srt_print(srt_get_nth(vec, len - 1));

    return ret;
}

int main (int argc, char ** argv)
{
#define COND (argc <= 1)
    int ret = EXIT_SUCCESS;
    struct srt_Vec tmp = srt_new();

    if (argc != 2) {
        fprintf(stderr, "Usage: `%s FILENAME`\n", argv[0]);
        ret = EXIT_FAILURE;
        goto out;
    }

    if ((yyin = fopen(argv[1], "r")) == NULL) {
        ret = EXIT_FAILURE;
        goto out;
    }

    id = 1;

    tmp = srt_with_capacity(50);
    svec = &tmp;

    debug("FILE", argv[1]);
    debug("LEX", "Starting yylex()");

    yylex();

    debug("LEX", "yylex() over");

    ret = (exe2(&tmp)) ? EXIT_SUCCESS : EXIT_FAILURE;

out:
    srt_free(&tmp, NULL);

    return ret;
#undef COND
}
