%{
#include <stdio.h>

FILE* fsread;
FILE* fswrite;
//HI
void HandleConst(char* str);

%}

/*Definitions for common patterns (Regular expressions*/

/*Matches one or more spaces or tabs*/
space [ \t]+ 

/*Matches one or more spaces, tabs, or newline characters*/
blank [ \t\n]+

single_line_comments #.* 

multiline_comments #\*([^*]|[*][^#]|\n)*\*#

comments ({multiline_comments}|{single_line_comments})

sp_char_id ("$"|"_"|"~")

/*Matches identifiers that can start with an optional special character followed by alphanumeric characters*/
identifier [A-Za-z$_~][A-Za-z0-9$_~]*

na_id   [0-9]+[A-Za-z0-9$_~]+

/*Matches reserved keywords*/
reserved_key ("if"|"else"|"return"|"switch"|"case"|"break"|"print"|"continue"|"null"|"for"|"while"|"true"|"false"|"and"|"or")

/*Matches data types like "integer_", "character_", "string", or "null"*/
p_datatype ("int"|"float"|"char"|"string"|"bool"|"void"|"double"|"long")

np_datatype ("Node"|"BSTree"|"BTree")

datatype   ({p_datatype}|{np_datatype})

/*Matches punctuation characters*/
punctuation [,;"'.\(\)\[\]\{\}]

/*Matches a string enclosed in double quotes*/
string  \"[^"]*\"

/*Matches a character enclosed in single quotes*/
character ['][^']*[']

/*Matches a single digit*/
digit   [0-9]

floating_point (-?[0-9]*\.[0-9]+)

/*Matches one or more digits*/
decimal_number  (-?[0-9]+)

/*Matches constants which can be numbers, characters, or strings*/
constant     ({decimal_number}|{character}|{string}|{floating_point})

/*Matches operators containing spaces, followed by one of {-, =, +, *, /, _} and then more spaces*/
operator ("+"|"-"|"*"|"/"|"%"|"++"|"--"|"="|"=="|"!="|"!"|"<="|"<"|">="|">"|"&"|"|"|"^")

%%

\n                 {yylineno++;} // Handle newline character

{comments}         {}

{operator}         {fprintf(fswrite, "operator: %s\n", yytext);}

{punctuation}      {fprintf(fswrite, "punctuation: %s\n", yytext);}

{datatype}         {fprintf(fswrite, "datatype: %s\n", yytext);} // Call HandleDatatypes function for data types handling

{reserved_key}     {fprintf(fswrite, "reserved keyword: %s\n", yytext);} // Call HandleKeyWords function for reserved keywords

{constant}         {HandleConst(yytext);} // Call HandleConst function for constants

{identifier}       {fprintf(fswrite, "ID: %s\n", yytext);} // Return token type ID for identifiers

{space}            {} // Handle spaces and tabs

.|{na_id}           {fprintf(fswrite, "Lexical Error for %s at line number: %d\n", yytext, yylineno);
                    fclose(fsread);
                    fclose(fswrite);
                    exit(1);} // Handle lexical errors
%%

int yywrap(){}

void HandleConst(char* str) {
    if(str[0] == '"') {
        fprintf(fswrite, "punctuation: \"\n");
        char s[strlen(str)+3];
        int i = 0;
        for(i=1; i<(strlen(str)-1); i++) {
            s[i-1] = str[i];
        }
        s[i-1] = '\0';
        fprintf(fswrite, "constant: %s\n", s);
        fprintf(fswrite, "punctuation: \"\n");
    }
    else if(str[0] == '\'') {
        fprintf(fswrite, "punctuation: %c\n", str[0]);
        fprintf(fswrite, "constant: %c\n", str[1]);
        fprintf(fswrite, "punctuation: %c\n", str[2]);
    }
    else {
        fprintf(fswrite, "constant: %s\n", str);
    }
}

int main(int argc, char *argv[]) {
    //Opening input file for reading
    fsread = fopen(argv[1], "r");
    //Opening output file for writing tokens
    fswrite = fopen("seq_tokens.txt", "w");
    //Setting input to the opened file
    yyin = fsread;
    //Starting lexical analysis
    yylex();
    //Closing opened file streams
    fclose(fsread);
    fclose(fswrite);
    return 0;
}
