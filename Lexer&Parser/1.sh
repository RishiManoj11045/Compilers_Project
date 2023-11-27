yacc -d Yacc.y 
lex Lex.l
gcc y.tab.c lex.yy.c -ll
