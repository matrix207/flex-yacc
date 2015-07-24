mdbsql: parser_yacc.o parser_lex.o
	gcc -o $@ parser_yacc.o parser_lex.o  -lfl

parser_yacc.c parser_yacc.h: parser_yacc.y
	yacc -vdt parser_yacc.y
	mv y.tab.h parser_yacc.h
	mv y.tab.c parser_yacc.c
	mv y.output parser_yacc.out

parser_lex.o: parser_yacc.h parser_lex.c

parser_lex.c: parser_lex.l
	flex $<
	mv lex.yy.c $*.c
