#include <stdio.h>
#include <string.h>

#include "flex.h"

#define NDEBUG
#include "debug.h"

#include "srt.h"

#define VEC_DATA_TYPE struct srt
#define VEC_PREFIX srt_
#define VEC_DATA_TYPE_EQ(L, R) ((L).id == (R).id)
#include "vec.h"

extern int id;
extern struct srt srt;
extern struct srt_Vec * svec;

int exe2 (size_t n, struct srt_Vec * vec, char ** fnames)
{
    int ret = 0;
    char newfname[256] = "";

    for (size_t i = 0; i < n; i++) {
        if (fnames != NULL) {
            if (strlen(fnames[i]) < 254) { /* 1 para '_' e 1 para '\0' */
                sprintf(newfname, "_%s", fnames[i]);
            } else {
                fprintf(stderr, "ERROR: filename is too big: `%s`", fnames[i]);
                ret++;
                continue;
            }
        }

        FILE * f = (fnames == NULL) ?
            stdout :
            fopen(newfname, "w");

        if (f == NULL) {
            fprintf(stderr, "ERROR: Could not open file: `%s`", fnames[i]);
            ret++;
            continue;
        }

        /* processar cenas lidas */

        if (f != stdout) fclose(f);
    }

    return ret;
}

int main (int argc, char ** argv)
{
#define COND (argc <= 1)
    int ret = EXIT_SUCCESS;
    int over = 0;
    size_t nvec = (COND) ? 1 : argc - 1;
    struct srt_Vec * tmp = calloc(nvec, sizeof(struct srt_Vec));

    if (tmp == NULL) {
        ret = EXIT_FAILURE;
        goto out;
    }

    for (int i = 1; i < argc || !over; i++) {
        if (COND) {
            yyin = stdin;
            over = !0;
        } else {
            yyin = fopen(argv[i], "r");
            if (yyin == NULL) {
                fprintf(stderr, "ERROR<FILE>: could not open `%s`", argv[i]);
                continue;
            }
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
    }

    exe2(nvec, tmp, (COND) ? NULL : argv);

out:
    for (size_t i = 0; i < nvec; i++)
        srt_free(tmp + i, NULL);

    if (tmp != NULL) free(tmp);

    return ret;
#undef COND
}
