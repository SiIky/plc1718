EXEC=exe
HEADER=srt.h vec.h debug.h
SRC=srt.c exe1.c exe2.c
OBJ=$(EXEC).flex.o \
    srt.o

FICHEIROS=Makefile \
	  harry_potter-fr1.srt \
	  harry_potter-pt1.srt \
	  plc17TP2Gr17.l \
	  $(SRC) \
	  $(HEADER)

$(EXEC): exe1 exe2

flex: plc17TP2Gr17.l
	flex --header-file=flex.h -o $(EXEC).flex.c plc17TP2Gr17.l

obj: flex $(SRC) $(HEADER)
	cc -Wall -Wextra -pedantic -g -c $(EXEC).flex.c $(SRC)

exe1: obj
	cc -Wall -Wextra -pedantic -g -o $(EXEC)1 $(OBJ) exe1.o

exe2: obj
	cc -Wall -Wextra -pedantic -g -o $(EXEC)2 $(OBJ) exe2.o

test: $(EXEC)
	./$(EXEC)1 harry_potter-fr1.srt harry_potter-pt1.srt 1 4 2>&1 | less

zip: $(FICHEIROS)
	zip -r -n: -9 plc17TP2Gr17.zip $(FICHEIROS)

clean:
	rm -f $(EXEC)1 $(EXEC)2 $(EXEC).flex.c plc17TP2Gr17.zip $(OBJ) flex.h $(EXEC)1.o $(EXEC)2.o
