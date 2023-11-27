        %{
        #include <stdio.h>
        #include <stdlib.h>

        extern FILE* yyin; // Declare an external file pointer for input

        FILE* fsread; // Declare file pointers for reading and writing
        FILE* fswrite;

        extern int yylineno;
        extern char* yytext;
        extern int yylex(void); // Declare the lexer function
        void yyerror(const char* msg); // Declare the error handling function
        %}

        %token ID
        %token NUMBER
        %token STRINGC
        %token CHARC
        %token DECIMAL
        %token FLOATING
        %token INT
        %token FLOAT
        %token CHAR
        %token STRING
        %token BOOL
        %token DOUBLE
        %token LONG
        %token VOID
        %token LPAR
        %token RPAR
        %token LT
        %token GT
        %token NODE
        %token BTREE
        %token BSTREE
        %token COMMA
        %token LFB
        %token RFB
        %token SEMICOLON
        %token LSB
        %token RSB
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
        %token ADD
        %token SUB
        %token MUL
        %token DIV
        %token MOD
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
        %token LL
        %token END
        %token COLON
        %token INPUT
        %token OUTPUT
        %token LEFT
        %token RIGHT
        %token VAL
        %token MAIN

        %right NEG
        %right INCR
        %right DECR
        %left DIV
        %left MUL
        %left ADD SUB
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

        start: marker program main program 
        ;

        marker: 
        ;
        
        main: MAIN LPAR RPAR block
        ;

        program: /* */
        | global_stmt program 
        | func program
        ;

        global_stmt: declaration_stmt 
                | assignment
                | expression
                | func_dec
                | intialisation_stmt
                ;

        func_dec: pt_allowed ID LPAR func_args RPAR SEMICOLON 
                | VOID ID LPAR func_args RPAR SEMICOLON 
                | NODE LT pt_allowed GT ID LPAR func_args RPAR SEMICOLON
                | BTREE LT pt_allowed GT ID LPAR func_args RPAR SEMICOLON
                | BSTREE LT pt_allowed GT ID LPAR func_args RPAR SEMICOLON 
                | pt_allowed ID LPAR RPAR SEMICOLON 
                | VOID ID LPAR RPAR SEMICOLON 
                | NODE LT pt_allowed GT ID LPAR RPAR SEMICOLON 
                | BTREE LT pt_allowed GT ID LPAR RPAR SEMICOLON 
                | BSTREE LT pt_allowed GT ID LPAR RPAR SEMICOLON 
                ;

        pt_allowed: INT
                | FLOAT 
                | CHAR
                | STRING 
                | BOOL 
                | DOUBLE 
                | LONG 
                ;

        func_args: func_arg 
                | func_args COMMA func_arg
                ;


        func_arg: pt_allowed 
                | NODE LT pt_allowed GT 
                | BTREE LT pt_allowed GT 
                | BSTREE LT pt_allowed GT 
                ;


        func: pt_allowed ID LPAR f_args RPAR block 
        | VOID ID LPAR f_args RPAR block 
        | NODE LT pt_allowed GT ID LPAR f_args RPAR block
        | BTREE LT pt_allowed GT ID LPAR f_args RPAR block 
        | BSTREE LT pt_allowed GT ID LPAR f_args RPAR block 
        | pt_allowed ID LPAR RPAR block 
        | VOID ID LPAR RPAR block 
        | NODE LT pt_allowed GT ID LPAR RPAR block 
        | BTREE LT pt_allowed GT ID LPAR RPAR block 
        | BSTREE LT pt_allowed GT ID LPAR RPAR block 
        ;


        f_args: f_arg 
        | f_args COMMA f_arg 
        ;

        f_arg: pt_allowed ID 
                | NODE LT pt_allowed GT ID 
                | BTREE LT pt_allowed GT ID 
                | BSTREE LT pt_allowed GT ID 
                ;

        block: LFB RFB 
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
                | input_stmt
                | output_stmt
                | block
                ;

        declaration_stmt: declaration SEMICOLON
                        ;

        declaration: pt_allowed id_list 
                | NODE LT pt_allowed GT id_list 
                | BTREE LT pt_allowed GT id_list 
                | BSTREE LT pt_allowed GT id_list 
                | pt_allowed ID LSB NUMBER RSB 
                | NODE LT pt_allowed GT ID LSB NUMBER RSB 
                ;

        id_list: ID
        | id_list COMMA ID 
        ;

        intialisation_stmt: intialisation SEMICOLON 
                        ;

        intialisation: pt_allowed ID EQUAL inpt_rhs 
                | NODE LT pt_allowed GT ID EQUAL LFB predicate COMMA n_par COMMA n_par RFB 
                | BTREE LT pt_allowed GT ID EQUAL LFB bt_parm RFB 
                | BSTREE LT pt_allowed GT ID EQUAL LFB bst_parm RFB 
                ;

        bt_parm: bt_par COMMA bt_parm
        | bt_par 
        ;

        bt_par: predicate 
        | LNULL 
        ;

        bst_parm: predicate COMMA bst_parm 
                | predicate 
                ;

        n_par: LNULL
        | ID 
        ;

        inpt_rhs: predicate 
                | ID DOT LEFT 
                | ID DOT RIGHT 
                | ID DOT VAL 
                ;

        predicate: conditions 
                ;

        conditions: NEG conditions 
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

        ops: LT 
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

        aops: ADD 
        | SUB 
        | MUL 
        | DIV 
        | MOD 
        ;

        acon_pos: ID 
                | DECIMAL 
                | FLOATING 
                | NUMBER 
                | func_call 
                | LPAR acon_posm RPAR
                ;

        func_call: ID LPAR call_args RPAR 
                | ID LPAR RPAR 
                | ID DOT ID LPAR call_args RPAR  
                | ID DOT ID LPAR RPAR  
                ;

        call_args: call_args COMMA predicate 
                | predicate 
                ;

        init_args: init_args COMMA init_arg 
                | init_arg 
                ;

        init_arg: inpt_rhs
                | LNULL 
                ;

        assignment: ID EQUAL s_marker 
                | ID DOT LEFT EQUAL ID SEMICOLON 
                | ID DOT LEFT EQUAL LNULL SEMICOLON 
                | ID DOT RIGHT EQUAL ID SEMICOLON 
                | ID DOT RIGHT EQUAL LNULL SEMICOLON
                | ID DOT VAL EQUAL predicate SEMICOLON 
                ;

        s_marker: expr SEMICOLON 
                ;

        expr: inpt_rhs 
        | LFB init_args RFB 
        | ID INCR 
        | ID DECR 
        ;

        expression: exprt SEMICOLON 
                ;

        exprt: inpt_rhs 
        | ID INCR 
        | ID DECR
        ;

        conditional_stmt: f_marker
                        | f_marker ELSE loop_block
                        ;

        f_marker: IF LPAR predicate RPAR loop_block
                ;

        loop_stmt: while_loop
                | for_loop
                ;

        while_loop: while_marker LPAR predicate RPAR loop_block 
                ;

        while_marker: WHILE 
                ;
                
        for_loop: for_marker LPAR for_f SEMICOLON predicate SEMICOLON for_l RPAR loop_block 
                |  for_marker LPAR for_f SEMICOLON predicate SEMICOLON  ID EQUAL t_marker RPAR loop_block
                ;

        for_marker: FOR 
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
                | input_stmt
                | output_stmt
                | loop_block
                ;

        for_f: declaration 
        | intialisation 
        | for_f_marker t_marker 
        ;

        for_f_marker: ID EQUAL 
        ;

        t_marker: expr 
                ;

        for_l: predicate 
        | ID INCR 
        | ID DECR 
        ;

        return_stmt: RETURN predicate SEMICOLON 
                | RETURN SEMICOLON 
                ;

        input_stmt: INPUT LPAR ID RPAR SEMICOLON  
                ;

        output_stmt: OUTPUT COLON print_posm SEMICOLON
                ;

        print_posm: print_pos LL print_posm 
                | print_pos 
                ;

        print_pos: predicate 
                | END 
                ;

        %%

        int main(int argc, char* argv[]) {
        fsread = fopen(argv[1], "r"); // Open the input file
        char str[50];
        char s[100];
        int i=0;
        while(argv[1][i]!='.'){
                str[i]=argv[1][i];
                i++;
        }
        str[i]='\0';
        sprintf(s, "seq_tokens_%s.txt",str);
        fswrite = fopen(s, "w"); // Open the token output file
        yyin = fsread; // Set the input file for the lexer
        yyparse(); // Start the parsing process
        fclose(fsread); // Close the input file
        fclose(fswrite); // Close the token output file
        return 0;
        }

        void yyerror(const char* msg) {
                printf("Syntax Error  at \"%s\", line number : %d \n", yytext, yylineno); // Defining error handling for syntax errors
                exit(1);
        }
