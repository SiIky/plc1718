EXEC=exe
HEADER=srt.h vec.h debug.h srt_vec.h
SRC=exe1.c exe2.c
OBJ=$(EXEC).flex.o

FICHEIROS=Makefile \
	  plc17TP2Gr17.tex \
	  harry_potter-fr1.srt \
	  harry_potter-pt1.srt \
	  plc17TP2Gr17.l \
	  $(SRC) \
	  $(HEADER)

$(EXEC): exe1 exe2

flex: plc17TP2Gr17.l
	flex --header-file=flex.h -o $(EXEC).flex.c plc17TP2Gr17.l

obj: flex $(SRC) $(HEADER)
	cc -static -Wall -Wextra -pedantic -g -c $(EXEC).flex.c $(SRC)

exe1: obj
	cc -static -Wall -Wextra -pedantic -g -o $(EXEC)1 $(OBJ) exe1.o

exe2: obj
	cc -static -Wall -Wextra -pedantic -g -o $(EXEC)2 $(OBJ) exe2.o

test1: $(EXEC)
	./$(EXEC)1 harry_potter-fr1.srt harry_potter-pt1.srt 1 1 2>&1 | less

test2: $(EXEC)
	./$(EXEC)2 harry_potter-pt1.srt 2>&1 | less

tex:
	pdflatex plc17TP2Gr17.tex

zip: $(FICHEIROS)
	zip -r -n: -9 plc17TP2Gr17.zip $(FICHEIROS)

clean:
	rm -f $(EXEC)1 $(EXEC)2 $(EXEC).flex.c plc17TP2Gr17.zip $(OBJ) flex.h $(EXEC)1.o $(EXEC)2.o
