%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h" // Include the parser's header file

extern FILE* fsread;
extern FILE* fswrite; // Declare external file pointers for writing

int HandleConst(char* str);
int HandleOps(char* str);
int HandlePunc(char* str);
int HandleDatatypes(char* str);
int HandleKeyWords(char* str);
void HandleComments(char* str);

%}

/*Definitions for common patterns (Regular expressions*/

/*Matches one or more spaces or tabs*/
space [ \t]+ 

/*Matches one or more spaces, tabs, or newline characters*/
blank [ \t\n]+

single_line_comments #.* 

multiline_comments #\*([^*]|[*][^#]|\n)*\*#

comments ({multiline_comments}|{single_line_comments})

/*Matches identifiers that can start with an optional special character followed by alphanumeric characters*/
identifier [A-Za-z_][A-Za-z0-9_]*

na_id   [0-9]+[A-Za-z0-9_]+

/*Matches reserved keywords*/
reserved_key ("main"|"if"|"else"|"return"|"break"|"continue"|"null"|"for"|"while"|"true"|"false"|"and"|"or"|"end"|"input"|"output"|"left"|"right"|"val")

/*Matches data types like "integer_", "character_", "string", or "null"*/
p_datatype ("int"|"float"|"char"|"string"|"bool"|"void"|"double"|"long")

np_datatype ("Node"|"BSTree"|"BTree")

datatype   ({p_datatype}|{np_datatype})

/*Matches punctuation characters*/
punctuation [:,;"'.\(\)\[\]\{\}]

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
operator ("+"|"-"|"*"|"/"|"%"|"++"|"--"|"="|"=="|"!="|"!"|"<="|"<"|">="|">"|"&"|"|"|"^"|"<<")

%%

\n                 {yylineno++;
                    } // Handle newline character

{comments}         {
                    HandleComments(yytext);}

{space}            {/* */;} // Handle spaces and tabs

{operator}         {fprintf(fswrite, "operator: %s\n", yytext);
                    return HandleOps(yytext);}

{punctuation}      {fprintf(fswrite, "punctuation: %s\n", yytext);
                    return HandlePunc(yytext);}

{datatype}         {fprintf(fswrite, "datatype: %s\n", yytext);
                    return HandleDatatypes(yytext);} // Call HandleDatatypes function for data types handling

{reserved_key}     {fprintf(fswrite, "reserved keyword: %s\n", yytext);
                    return HandleKeyWords(yytext);} // Call HandleKeyWords function for reserved keywords

{constant}         {return HandleConst(yytext);} // Call HandleConst function for constants

{identifier}       {fprintf(fswrite, "ID: %s\n", yytext);
                        return ID;} // Return token type ID for identifiers

.|{na_id}           {printf("Lexical Error for %s at line number: %d\n", yytext, yylineno);
                    fclose(fsread);
                    fclose(fswrite);
                    exit(1);} // Handle lexical errors
%%

int yywrap() {
    return 1;
}

int HandleConst(char* str) {
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
        return STRINGC;
    }
    else if(str[0] == '\'') {
        fprintf(fswrite, "punctuation: %c\n", str[0]);
        fprintf(fswrite, "constant: %c\n", str[1]);
        fprintf(fswrite, "punctuation: %c\n", str[2]);
        return CHARC;
    }
    else {
        fprintf(fswrite, "constant: %s\n", str);
        for(int i=0; i<strlen(str); i++) {
            if(str[i] == '.') {
                return FLOATING;
            }
        }
        if(str[0] != '-') {
            return NUMBER;
        }
        else {
            return DECIMAL;
        }
    }
    return 1;
}

int HandleOps(char* str) {
    if(strcmp(str, "+") == 0) {
        return ADD;
    }
    else if(strcmp(str, "-") == 0) {
        return SUB;
    }
    else if(strcmp(str, "*") == 0) {
        return MUL;
    }
    else if(strcmp(str, "/") == 0) {
        return DIV;
    }
    else if(strcmp(str, "%") == 0) {
        return MOD;
    }
    else if(strcmp(str, "++") == 0) {
        return INCR;
    }
    else if(strcmp(str, "--") == 0) {
        return DECR;
    }
    else if(strcmp(str, "=") == 0) {
        return EQUAL;
    }
    else if(strcmp(str, "==") == 0) {
        return EQ;
    }
    else if(strcmp(str, "!=") == 0) {
        return NE;
    }
    else if(strcmp(str, "!") == 0) {
        return NEG;
    }
    else if(strcmp(str, "<=") == 0) {
        return LEQ;
    }
    else if(strcmp(str, "<") == 0) {
        return LT;
    }
    else if(strcmp(str, ">=") == 0) {
        return GEQ;
    }
    else if(strcmp(str, ">") == 0) {
        return GT;
    }
    else if(strcmp(str, "&") == 0) {
        return LAND;
    }
    else if(strcmp(str, "|") == 0) {
        return LOR;
    }
    else if(strcmp(str, "^") == 0) {
        return LXOR;
    }
    else if(strcmp(str, "<<") == 0) {
        return LL;
    }
    return 1;
}

int HandlePunc(char* str) {
    if(strcmp(str, ",") == 0) {
        return COMMA;
    }
    else if(strcmp(str, ";") == 0) {
        return SEMICOLON;
    }
    else if(strcmp(str, ".") == 0) {
        return DOT;
    }
    else if(strcmp(str, "(") == 0) {
        return LPAR;
    }
    else if(strcmp(str, ")") == 0) {
        return RPAR;
    }
    else if(strcmp(str, "[") == 0) {
        return LSB;
    }
    else if(strcmp(str, "]") == 0) {
        return RSB;
    }
    else if(strcmp(str, "{") == 0) {
        return LFB;
    }
    else if(strcmp(str, "}") == 0) {
        return RFB;
    }
    else if(strcmp(str, ":") == 0) {
        return COLON;
    }
    return 1;
}

int HandleDatatypes(char* str) {
    if(strcmp(str, "int") == 0) {
        return INT;
    }
    else if(strcmp(str, "float") == 0) {
        return FLOAT;
    }
    else if(strcmp(str, "char") == 0) {
        return CHAR;
    }
    else if(strcmp(str, "string") == 0) {
        return STRING;
    }
    else if(strcmp(str, "bool") == 0) {
        return BOOL;
    }
    else if(strcmp(str, "long") == 0) {
        return LONG;
    }
    else if(strcmp(str, "double") == 0) {
        return DOUBLE;
    }
    else if(strcmp(str, "void") == 0) {
        return VOID;
    }
    else if(strcmp(str, "Node") == 0) {
        return NODE;
    }
    else if(strcmp(str, "BTree") == 0) {
        return BTREE;
    }
    else if(strcmp(str, "BSTree") == 0) {
        return BSTREE;
    }
    return 1;
}

int HandleKeyWords(char* str) {
    if(strcmp(str, "if") == 0) {
        return IF;
    }
    else if(strcmp(str, "else") == 0) {
        return ELSE;
    }
    else if(strcmp(str, "return") == 0) {
        return RETURN;
    }
    else if(strcmp(str, "break") == 0) {
        return BREAK;
    }
    else if(strcmp(str, "continue") == 0) {
        return CONTINUE;
    }
    else if(strcmp(str, "null") == 0) {
        return LNULL;
    }
    else if(strcmp(str, "for") == 0) {
        return FOR;
    }
    else if(strcmp(str, "while") == 0) {
        return WHILE;
    }
    else if(strcmp(str, "true") == 0) {
        return LTRUE;
    }
    else if(strcmp(str, "false") == 0) {
        return LFALSE;
    }
    else if(strcmp(str, "and") == 0) {
        return AND;
    }
    else if(strcmp(str, "or") == 0) {
        return OR;
    }
    else if(strcmp(str, "end") == 0) {
        return END;
    }
    else if(strcmp(str, "input") == 0) {
        return INPUT;
    }
    else if(strcmp(str, "output") == 0) {
        return OUTPUT;
    }
    else if(strcmp(str, "left") == 0) {
        return LEFT;
    }
    else if(strcmp(str, "right") == 0) {
        return RIGHT;
    }
    else if(strcmp(str, "val") == 0) {
        return VAL;
    }
    else if(strcmp(str, "main") == 0) {
        return MAIN;
    }
    return 1;
}

void HandleComments(char* str){
    int i=0;
    char* s = str;
    while(str[i]!='\0'){
        if(str[i]=='\n'){
            yylineno++;
            }
        i++;
    }
}
