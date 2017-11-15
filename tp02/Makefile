EXEC=srt
FICHEIROS=plc17TP2Gr17.l vec.h Makefile harry_potter-fr1.srt harry_potter-pt1.srt srt.c srt.h


$(EXEC): plc17TP2Gr17.l vec.h srt.h srt.c
	flex -o $(EXEC).flex.c plc17TP2Gr17.l
	cc -Wall -Wextra -g -c $(EXEC).flex.c srt.c
	cc  -g -o $(EXEC) *.o

test: $(EXEC)
	./$(EXEC) harry_potter-fr1.srt harry_potter-pt1.srt 2>&1 | less

zip: $(FICHEIROS)
	zip -r -n: -9 plc17TP2Gr17.zip $(FICHEIROS)

clean:
	rm -f $(EXEC) $(EXEC).flex.c plc17TP2Gr17.zip *.o
