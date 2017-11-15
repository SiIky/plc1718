#include <stdio.h>
#include <time.h>

#include "srt.h"

struct srt srt_print_sub (struct srt srt)
{
    printf("%s", srt.sub);
    return srt;
}

struct srt srt_dtor (struct srt srt)
{
    /*
    if (srt.sub != NULL) {
        free(srt.sub);
        srt.sub = NULL;
    }
    */
    return srt;
}
