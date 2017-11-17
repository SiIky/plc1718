#ifndef _DEBUG_H
#define _DEBUG_H

#ifndef NDEBUG
# define debug(ctx, msg) (fprintf(stderr, "DEBUG<%s>: %s\n", (ctx), (msg)))
# define error(ctx, msg) (fprintf(stderr, "ERROR<%s>: %s\n", (ctx), (msg)))
# define warn(ctx, msg)  (fprintf(stderr, "WARNING<%s>: %s\n", (ctx), (msg)))
#else
# define debug(ctx, msg) ((void) 0)
# define error(ctx, msg) ((void) 0)
# define warn(ctx, msg)  ((void) 0)
#endif /* NDEBUG */

#endif /* _DEBUG_H */
