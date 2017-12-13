EXEC=fl

$(EXEC): y.tab.c lex.yy.c
	gcc -o $(EXEC) y.tab.c lex.yy.c

y.tab.c: $(EXEC).y
	yacc --defines $(EXEC).y

lex.yy.c: $(EXEC).l
	flex --header-file=lex.yy.h $(EXEC).l

clean:
	rm -f y.tab.[ch] lex.yy.[ch] $(EXEC)

test: $(EXEC) exemplo.fl
	./$(EXEC) exemplo.fl
