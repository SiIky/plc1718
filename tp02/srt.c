#include <stdio.h>
#include <time.h>

#include "srt.h"

struct srt srt_print_sub (struct srt srt)
{
    printf(
        "%d\n"
        "%02d:%02d:%02d,%03d"
        " --> "
        "%02d:%02d:%02d,%03d\n"
        "%s\n",
        srt.id,
        srt.interval.begin.tm.tm_hour,
        srt.interval.begin.tm.tm_min,
        srt.interval.begin.tm.tm_sec,
        srt.interval.begin.tm_mil,
        srt.interval.end.tm.tm_hour,
        srt.interval.end.tm.tm_min,
        srt.interval.end.tm.tm_sec,
        srt.interval.end.tm_mil,
        srt.sub
        );
    return srt;
}

struct srt srt_dtor (struct srt srt)
{
    return srt;
}
