EXEC=exe

HEADERS=\
       debug.h \
       srt.h \
       srt_vec.h \
       vec.h \

SRC=\
    exe1.c \
    exe2.c

OBJ=$(EXEC).flex.o

LATEXOUT=\
	 plc17TP2Gr17.aux \
	 plc17TP2Gr17.log \
	 plc17TP2Gr17.pdf \
	 plc17TP2Gr17.toc \

FICHEIROS_ENTREGA=\
	  $(HEADERS) \
	  $(SRC) \
	  Makefile \
	  harry_potter-fr1.srt \
	  harry_potter-pt1.srt \
	  plc17TP2Gr17.l \
	  plc17TP2Gr17.tex

all: exe1 exe2

flex: plc17TP2Gr17.l
	flex --header-file=flex.h -o $(EXEC).flex.c plc17TP2Gr17.l

obj: flex $(SRC) $(HEADERS)
	cc -static -Wall -Wextra -pedantic -g -c $(EXEC).flex.c $(SRC)

exe1: obj
	cc -static -Wall -Wextra -pedantic -g -o $(EXEC)1 $(OBJ) $(EXEC)1.o

exe2: obj
	cc -static -Wall -Wextra -pedantic -g -o $(EXEC)2 $(OBJ) $(EXEC)2.o

test1: all
	./$(EXEC)1 harry_potter-fr1.srt harry_potter-pt1.srt 1 1 2>&1 | less

test2: all
	./$(EXEC)2 harry_potter-pt1.srt 2>&1 | less

tex:
	pdflatex plc17TP2Gr17.tex

zip: $(FICHEIROS_ENTREGA)
	zip -r -n: -9 plc17TP2Gr17.zip $(FICHEIROS_ENTREGA)

clean:
	rm -f $(EXEC)1 $(EXEC)2 $(EXEC).flex.c plc17TP2Gr17.zip $(LATEXOUT) $(OBJ) flex.h $(EXEC)1.o $(EXEC)2.o
