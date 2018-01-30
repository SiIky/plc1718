EXEC=fl
CFLAGS=-std=c11 -Wall -Wextra -Wpedantic -static -Og -g
SRC=y.tab.c lex.yy.c main.c
OBJ=$(SRC:.c=.o)

$(EXEC): $(OBJ)
	gcc $(CFLAGS) -o $(EXEC) $(OBJ)

y.tab.c: $(EXEC).y
	yacc -dtv -L c --defines $(EXEC).y

lex.yy.h: lex.yy.c

lex.yy.c: $(EXEC).l
	flex --header-file=lex.yy.h $(EXEC).l

y.tab.o: y.tab.c lex.yy.h
	gcc $(CFLAGS) -c y.tab.c

lex.yy.o: lex.yy.c
	gcc $(CFLAGS) -c lex.yy.c

clean:
	rm -f y.tab.[ch] lex.yy.[ch] $(EXEC) $(OBJ)

test: $(EXEC) exemplos
	./$(EXEC) exemplos/exe1.fl
