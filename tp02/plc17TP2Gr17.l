%{
#include <stdio.h>
#include <time.h>

    struct srt_tm {
        struct tm tm;
        int tm_mil;
    };

    struct srt_interval {
        struct srt_tm begin;
        struct srt_tm end;
    };

    struct srt {
        size_t id;
        struct srt_interval interval;
        char * sub;
    };

#define VEC_DATA_TYPE struct srt
#define VEC_PREFIX srt_
#define VEC_DATA_TYPE_EQ(L, R) ((L).id == (R).id)
#include "vec.h"

    size_t ln = 0;
    size_t id = 1; /* ID da legenda seguinte */

    struct srt srt;
    struct srt_Vec * svec = NULL;
%}

%option noyywrap

%x SRT_ID SRT_INT SRT_SUB

Abrev ER

%%

[1-9][0-9]*\s*   { 
       if ((sscanf(yytext, "%llu", &srt.id) != 1) || (id != srt.id))
           exit(1);

       printf("%llu %llu\n", srt.id, id);
       id++;
       BEGIN SRT_INT;
}
\n              { ; }
.               { fprintf(stdout, "ponto\n"); }

<SRT_INT>{
    ([0-9]{2}:){2}[0-9]{2},[0-9]{3}\ -->\ ([0-9]{2}:){2}[0-9]{2},[0-9]{3} {
        struct srt_tm * ints[2] = {
            [0] = &srt.interval.begin,
            [1] = &srt.interval.end,
        };

        for (int i = 0; i < 2; i++) {
            int r = sscanf(yytext + (17 * i),
                           "%02d:%02d:%02d,%03d",
                           &ints[i]->tm.tm_hour,
                           &ints[i]->tm.tm_min,
                           &ints[i]->tm.tm_sec,
                           &ints[i]->tm_mil
                          );

            if (r != 4)
                fprintf(stderr, "could not read interval: %d\n", i);
            else
                fprintf(stdout, "%02d:%02d:%02d,%03d\n",
                           ints[i]->tm.tm_hour,
                           ints[i]->tm.tm_min,
                           ints[i]->tm.tm_sec,
                           ints[i]->tm_mil
                       );
        }

        fprintf(stdout, "outras cenas\n");
        BEGIN SRT_SUB;
    }
}

<SRT_SUB>{
    \n/\n {
        srt_push(svec, srt);
        memset(&srt, 0, sizeof(struct srt));
        srt.sub = malloc(sizeof(char) * 256);
        *srt.sub = '\0';
        BEGIN INITIAL;
    }
    .+\n   {
        strcat(srt.sub, yytext);
    }
}

%%

int main (int argc, char ** argv)
{
    memset(&srt, 0, sizeof(struct srt));
    struct srt_Vec tmp = srt_with_capacity(50);
    svec = &tmp;

    yylex();

    for (size_t i = 0; i < srt_len(svec); i++) {
        printf(svec->ptr[i].sub);
    }
    srt_free(svec);

    return 0;
}
