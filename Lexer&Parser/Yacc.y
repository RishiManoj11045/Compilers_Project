%{
#include <stdio.h>
#include <stdlib.h>

extern FILE* yyin; // Declare an external file pointer for input

FILE* fsread; // Declare file pointers for reading and writing
FILE* fswrite;

int yylex(void); // Declare the lexer function
int yyerror(); // Declare the error handling function
%}

%token ID
%token LPAR
%token RPAR
%token LT
%token GT
%token INT
%token FLOAT
%token CHAR
%token STRING
%token BOOL
%token DOUBLE
%token LONG
%token VOID
%token NODE
%token BTREE
%token BSTREE
%token COMMA
%token LFB
%token RFB
%token SEMICOLON
%token LSB
%token RSB
%token NUMBER
%token EQUAL
%token AND
%token OR
%token LOR
%token LAND
%token LXOR
%token GEQ
%token LEQ
%token NE
%token EQ
%token STRINGC
%token CHARC
%token ADD
%token SUB
%token MUL
%token DIV
%token MOD
%token DECIMAL
%token FLOATING 
%token DOT
%token BREAK
%token CONTINUE
%token RETURN
%token INCR
%token DECR
%token IF
%token ELSE
%token WHILE
%token FOR
%token LNULL
%token NEG
%token LTRUE
%token LFALSE

%right NEG
%right INCR
%right DECR
%left DIV
%left MUL
%left ADD
%left SUB
%left LT
%left LEQ
%left GT
%left GEQ
%left EQ
%left NE
%left AND
%left OR
%left LAND
%left LOR
%left LXOR
%right EQUAL

%%

start: /* */
     | program
     ;

program: global_stmt pr
       | func pr
       ;

pr: global_stmt pr
  | func pr 
  |
  ;
  
global_stmt: declaration_stmt
           | assignment
           | expression
           | func_dec
           ;

func_dec: pt_allowed ID LPAR func_args RPAR SEMICOLON
        | VOID ID LPAR func_args RPAR SEMICOLON
        | np_datatype LT pt_allowed GT ID LPAR func_args RPAR SEMICOLON
        ;

pt_allowed: INT
          | FLOAT
          | CHAR
          | STRING
          | BOOL
          | DOUBLE
          | LONG
          ;

np_datatype: NODE
           | BTREE
           | BSTREE
           ;

func_args: func_arg // Defining function arguments production
         | func_args COMMA func_arg
         ;

func_arg: pt_allowed ID // Defining function argument production
        | np_datatype LT pt_allowed GT ID
        ;

func: pt_allowed ID LPAR func_args RPAR block
    | VOID ID LPAR func_args RPAR block
    | np_datatype LT pt_allowed GT ID LPAR func_args RPAR block
    ;

block: LFB RFB // Defining block production, both with empty block as well as with statements
     | LFB statements RFB
     ;

statements: statement // Defining statements production
          | statements statement
          ;

statement: declaration_stmt // Defining statement production with all types of valid statements
         | intialisation_stmt
         | assignment
         | expression
         | conditional_stmt
         | loop_stmt
         | return_stmt
         | block
         ;

declaration_stmt: declaration SEMICOLON
                ;

declaration: pt_allowed id_list
           | np_datatype LT pt_allowed GT id_list
           | pt_allowed ID LSB NUMBER RSB
           | np_datatype LT pt_allowed GT ID LSB NUMBER RSB
           ;

id_list: ID // Defining identifier list production
       | id_list COMMA ID
       ;

intialisation_stmt: intialisation SEMICOLON
                  ;

intialisation: pt_allowed ID EQUAL inpt_rhs 
             | np_datatype LT pt_allowed GT ID EQUAL innp_rhs
             ;

inpt_rhs: predicate
        ;

predicate: conditions // Defining predicate production
         ;

conditions: NEG conditions // Defining conditions production with possible types of conditions
          | condition cond
          ;
          
cond: AND conditions
    | OR conditions
    | LOR conditions
    | LAND conditions
    | LXOR conditions
    |  
    ;       

condition: con_posm
         ;

con_posm: con_pos
        | con_pos ops con_pos
        | LPAR con_pos ops con_pos RPAR
        | LTRUE
        | LFALSE
        ;

ops: LT // Defining comparison operators production with valid comparison operators allowed
   | GT
   | GEQ
   | LEQ
   | NE
   | EQ
   ;

con_pos: STRINGC
       | CHARC
       | acon_posm
       ;

acon_posm: acon_pos acond
        ;

acond: aops acon_posm
     | 
     ;

aops: ADD // Defining comparison operators production with valid comparison operators allowed
    | SUB
    | MUL
    | DIV
    | MOD
    ;

acon_pos: ID // Defining condition possibilities production
        | DECIMAL
        | FLOATING
        | func_call
        | LPAR acon_posm RPAR
        ;

func_call: ID LPAR call_args RPAR
         | ID DOT ID LPAR call_args RPAR
         ;

call_args: call_args COMMA predicate
         | predicate
         ;

innp_rhs: LFB init_args RFB
        | ID
        ;

init_args: init_args COMMA init_arg
         | init_arg
         ;

init_arg: inpt_rhs
        | LNULL
        ;

assignment: ID EQUAL expr SEMICOLON
          ;

expr: inpt_rhs
    | LFB init_args RFB
    | ID INCR
    | ID DECR
    ;

expression: expr SEMICOLON
          ;

conditional_stmt: IF LPAR predicate RPAR block
                | IF LPAR predicate RPAR block ELSE block
                ;

loop_stmt: while_loop
         | for_loop
         ;

while_loop: WHILE LPAR predicate RPAR loop_block
          ;

for_loop: FOR LPAR for_f SEMICOLON predicate SEMICOLON for_l loop_block
        ;

loop_block: LFB RFB // Defining block production, both with empty block as well as with statements
     | LFB loop_statements RFB
     ;

loop_statements: loop_statement // Defining statements production
          | loop_statements loop_statement
          ;

loop_statement: declaration_stmt // Defining statement production with all types of valid statements
         | intialisation_stmt
         | assignment
         | expression
         | conditional_stmt
         | loop_stmt
         | return_stmt
         | BREAK SEMICOLON
         | CONTINUE SEMICOLON
         | block
         ;

for_f: declaration
     | intialisation
     | ID EQUAL expr
     ;

for_l: ID EQUAL expr
     | predicate
     | ID INCR
     | ID DECR
     ;

return_stmt: RETURN predicate SEMICOLON
           | RETURN SEMICOLON
          ;

%%
int yywrap(){} // Defining yywrap function (no action required)

int main(int argc, char* argv[]) {
    fsread = fopen(argv[1], "r"); // Open the input file
    char s[20];
    sprintf(s, "seq_tokens_%c.txt", argv[1][0]);
    fswrite = fopen(s, "w"); // Open the token output file
    yyin = fsread; // Set the input file for the lexer
    yyparse(); // Start the parsing process
    fclose(fsread); // Close the input file
    fclose(fswrite); // Close the token output file
    return 0;
}

int yyerror() {
        printf("Invalid statement\n"); // Defining error handling for syntax errors
        exit(1);
}
