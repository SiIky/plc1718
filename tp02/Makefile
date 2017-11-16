EXEC=srt
HEADER=srt.h vec.h
SRC=srt.c
OBJ=$(EXEC).flex.o \
    srt.o

FICHEIROS=Makefile \
	  harry_potter-fr1.srt \
	  harry_potter-pt1.srt \
	  plc17TP2Gr17.l \
	  $(SRC) \
	  $(HEADER)

$(EXEC): plc17TP2Gr17.l $(SRC) $(HEADER)
	flex -o $(EXEC).flex.c plc17TP2Gr17.l
	cc -Wall -Wextra -g -c $(SRC) $(EXEC).flex.c
	cc -Wall -Wextra -g -o $(EXEC) $(OBJ)

test: $(EXEC)
	./$(EXEC) harry_potter-fr1.srt harry_potter-pt1.srt 2>&1 | less

zip: $(FICHEIROS)
	zip -r -n: -9 plc17TP2Gr17.zip $(FICHEIROS)

clean:
	rm -f $(EXEC) $(EXEC).flex.c plc17TP2Gr17.zip $(OBJ)
