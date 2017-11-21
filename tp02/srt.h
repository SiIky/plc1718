#ifndef _SRT_H
#define _SRT_H

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
    int id;
    struct srt_interval interval;
    char sub[512];
};

struct srt srt_print_sub (struct srt srt);

#endif /* _SRT_H */
