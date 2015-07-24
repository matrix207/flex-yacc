TARGET=count

$(TARGET): lex.yy.c
	gcc -g lex.yy.c -o $@

lex.yy.c: count.l
	flex $<

.PHONY:clean
clean:
	rm -f $(TARGET) lex.yy.c

