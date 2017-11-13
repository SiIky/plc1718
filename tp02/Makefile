EXEC=srt

$(EXEC): plc17TP2Gr17.l vec.h
	flex -o $(EXEC).c plc17TP2Gr17.l
	cc -Wall -Wextra -o $(EXEC) $(EXEC).c

test: $(EXEC)
	./$(EXEC) harry_potter-fr1.srt harry_potter-pt1.srt 2>&1 | less

clean:
	rm -f $(EXEC) $(EXEC).c
