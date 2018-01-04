EXEC=fl
SRC=y.tab.c lex.yy.c
OBJ=$(SRC:.c=.o)

$(EXEC): $(OBJ)
	gcc -g -Wall -Wextra -o $(EXEC) $(OBJ)

y.tab.c: $(EXEC).y
	yacc -d --defines $(EXEC).y

lex.yy.h: lex.yy.c

lex.yy.c: $(EXEC).l
	flex --header-file=lex.yy.h $(EXEC).l

y.tab.o: y.tab.c lex.yy.h
	gcc -g -Wall -Wextra -c y.tab.c

lex.yy.o: lex.yy.c
	gcc -g -Wall -Wextra -c lex.yy.c

clean:
	rm -f y.tab.[ch] lex.yy.[ch] $(EXEC) $(OBJ)

test: $(EXEC) exemplo.fl
	./$(EXEC) exemplo.fl
