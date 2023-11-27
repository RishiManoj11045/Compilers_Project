%{
#include <bits/stdc++.h>
// #include "global.hpp"
#include "funcs.hpp"



extern FILE* yyin; // Declare an external file pointer for input

FILE* fsread; // Declare file pointers for reading and writing
FILE* fswrite;

int scope = 0;
vector<string> vec;
vector<vector<symTabEnt>> symTab_list;
vector<funcTabEnt> funcTab;
bool p=true;
int find_loop = 0;
bool check_return = false;

vector<string> param_list;
vector<string> args_listt;
vector<string> args_listn;
vector<string> init_list;
vector<string> call_list;
string ret_type;
string assn_idtype="";
vector<string> v;
char modulo='@';

int yylex(void); // Declare the lexer function
void yyerror(const char* msg); // Declare the error handling function
%}

%union {
        const char* name;
        const char* type;
}

%token <name> ID
%token NUMBER
%token STRINGC
%token CHARC
%token DECIMAL
%token FLOATING
%token <type> INT
%token <type> FLOAT
%token <type> CHAR
%token <type> STRING
%token <type> BOOL
%token <type> DOUBLE
%token <type> LONG
%token <type> VOID
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

%type <type> pt_allowed 
%type <type> bt_parm
%type <type> bt_par
%type <type> bst_parm
%type <type> n_par
%type <type> inpt_rhs
%type <type> predicate
%type <type> conditions
%type <type> condition
%type <type> expr
%type <type> exprt
%type <type> acon_pos
%type <type> acon_posm
%type <type> con_pos
%type <type> con_posm
%type <type> acond
%type <type> cond
%type <type> func_call

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

start: marker program main program {
                
                        for(auto& i: symTab_list) {
                                for(auto& it: i) {
                                        delete it;
                                }
                                i.clear();
                        }
                        symTab_list.clear();
                        
                        for(auto& it: funcTab) {
                                delete it;
                        }
                        funcTab.clear();
                }
     ;

marker: {
        insert_functab("bfs",1,{},"void");
        insert_functab("dfs",1,{},"void");
        insert_functab("inorder",1,{},"void");
        insert_functab("preorder",1,{},"void");
        insert_functab("postorder",1,{},"void");
        insert_functab("mergeBSTree",1,{"BSTree","BSTree"},"BSTree");
        insert_functab("mergeBTree",1,{"BTree","BTree"},"BTree");
        insert_functab("search",1,{"Node"},"Node");
        insert_functab("insert",1,{"Node"},"bool");
        insert_functab("deleteN",1,{"Node"},"Node");
        create_symtab(scope);
     }
     ;
     
main: MAIN LPAR RPAR {ret_type = "int";} block {
                                if(check_return == false) {
                        cout<<"Semantic Error at line number "<<yylineno<<": No return statement in main scope block\n";
                        exit(1);
                }
                        check_return=false;
                        }
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

func_dec: pt_allowed ID LPAR func_args RPAR SEMICOLON {
                if(search_functab($2,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                insert_functab($2,0,param_list,$1);
                param_list.clear();
        }
        | VOID ID LPAR func_args RPAR SEMICOLON {
                if(search_functab($2,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                insert_functab($2,0,param_list,"void");
                param_list.clear();
        }
        | NODE LT pt_allowed GT ID LPAR func_args RPAR SEMICOLON {
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3;
                string str = "Node<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();

        }
        | BTREE LT pt_allowed GT ID LPAR func_args RPAR SEMICOLON {
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3;
                string str = "BTree<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();
        }
        | BSTREE LT pt_allowed GT ID LPAR func_args RPAR SEMICOLON {
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3;
                string str = "BSTree<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();
        }
        | pt_allowed ID LPAR RPAR SEMICOLON {
                param_list.clear();                
                if(search_functab($2,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                insert_functab($2,0,param_list,$1);
                param_list.clear();
        }
        | VOID ID LPAR RPAR SEMICOLON {
                param_list.clear();
                if(search_functab($2,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                insert_functab($2,0,param_list,"void");
                param_list.clear();
        }
        | NODE LT pt_allowed GT ID LPAR RPAR SEMICOLON {
                param_list.clear();
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3;
                string str = "Node<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();
        } 
        | BTREE LT pt_allowed GT ID LPAR RPAR SEMICOLON {
                param_list.clear();
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3;
                string str = "BTree<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();
        }
        | BSTREE LT pt_allowed GT ID LPAR RPAR SEMICOLON  {
                param_list.clear();
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3;
                string str = "BSTree<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();
        }
        ;

pt_allowed: INT {
               $$ = "int"; 
        }
          | FLOAT {
               $$="float"; 
        }
          | CHAR {
               $$="char"; 
        }
          | STRING {
               $$="string"; 
        }
          | BOOL {
               $$="bool"; 
        }
          | DOUBLE {
               $$="double"; 
        }
          | LONG {
               $$="long"; 
        }
          ;

func_args: func_arg 
         | func_args COMMA func_arg 
         ;


func_arg: pt_allowed {
                param_list.push_back($1);
        }
        | NODE LT pt_allowed GT {
                string stemp = $3;
                param_list.push_back("Node<"+stemp+">");
        }
        | BTREE LT pt_allowed GT {
                string stemp = $3;
                param_list.push_back("BTree<"+stemp+">");
               
        }
        | BSTREE LT pt_allowed GT {
                string stemp = $3;
                param_list.push_back("BSTree<"+stemp+">");
        }
        ;


func: pt_allowed ID LPAR f_args RPAR { 
        for(int i=0;i<args_listn.size();i++){
                for(int j=i+1;j<args_listn.size();j++){
                        if(args_listn[i]==args_listn[j]){
                                cout<<"Semantic Error at line number "<<yylineno<<": Parameters have same variable names\n";
                                exit(1); 
                        }
                }
        }
        funcTabEnt temp= search_functab($2,0,args_listt);
          if(!temp){
                cout<<"Semantic Error at line number "<<yylineno<<": function is not declared\n";
                exit(1);        
        }
        if(temp->ret_type!=$1){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type=$1; 
        args_listn.clear();
        args_listt.clear(); 

        } block {
                if(check_return == false) {
                        cout<<"Semantic Error at line number "<<yylineno<<": No return statement in main scope block\n";
                        exit(1);
                }
                check_return=false;
        }
    | VOID ID LPAR f_args RPAR {
        for(int i=0;i<args_listn.size();i++){
                for(int j=i+1;j<args_listn.size();j++){
                        if(args_listn[i]==args_listn[j]){
                                cout<<"Semantic Error at line number "<<yylineno<<": Parameters have same variable names\n";
                                exit(1); 
                        }
                }
        }
        funcTabEnt temp= search_functab($2,0,args_listt);
          if(!temp){
                cout<<"Semantic Error at line number "<<yylineno<<": function is not declared\n";
                exit(1);        
        }
        if(temp->ret_type!="void"){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type="void";
        args_listn.clear();
        args_listt.clear();

        } block {
                check_return=false;
        }
    | NODE LT pt_allowed GT ID LPAR f_args RPAR {
        for(int i=0;i<args_listn.size();i++){
                for(int j=i+1;j<args_listn.size();j++){
                        if(args_listn[i]==args_listn[j]){
                                cout<<"Semantic Error at line number "<<yylineno<<": Parameters have same variable names\n";
                                exit(1); 
                        }
                }
        }
        funcTabEnt temp= search_functab($5,0,args_listt);
          if(!temp){
                cout<<"Semantic Error at line number "<<yylineno<<": function is not declared\n";
                exit(1);        
        }
        string stemp = $3;
        if(temp->ret_type!=("Node<"+stemp+">")){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type="Node<"+stemp+">";

        args_listn.clear();
        args_listt.clear();

        } block {
                if(check_return == false) {
                        cout<<"Semantic Error at line number "<<yylineno<<": No return statement in main scope block\n";
                        exit(1);
                }
                check_return=false;
        }
    | BTREE LT pt_allowed GT ID LPAR f_args RPAR {
        for(int i=0;i<args_listn.size();i++){
                for(int j=i+1;j<args_listn.size();j++){
                        if(args_listn[i]==args_listn[j]){
                                cout<<"Semantic Error at line number "<<yylineno<<": Parameters have same variable names\n";
                                exit(1); 
                        }
                }
        }
        funcTabEnt temp= search_functab($5,0,args_listt);
          if(!temp){
                cout<<"Semantic Error at line number "<<yylineno<<": function is not declared\n";
                exit(1);        
        }
        string stemp = $3;
        if(temp->ret_type!=("BTree<"+stemp+">")){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type="BTree<"+stemp+">";

        args_listn.clear();
        args_listt.clear();

        } block {
                if(check_return == false) {
                        cout<<"Semantic Error at line number "<<yylineno<<": No return statement in main scope block\n";
                        exit(1);
                }
                check_return=false;
        }
    | BSTREE LT pt_allowed GT ID LPAR f_args RPAR {
        for(int i=0;i<args_listn.size();i++){
                for(int j=i+1;j<args_listn.size();j++){
                        if(args_listn[i]==args_listn[j]){
                                cout<<"Semantic Error at line number "<<yylineno<<": Parameters have same variable names\n";
                                exit(1); 
                        }
                }
        }
        funcTabEnt temp= search_functab($5,0,args_listt);
          if(!temp){
                cout<<"Semantic Error at line number "<<yylineno<<": function is not declared\n";
                exit(1);        
        }
        string stemp = $3;
        if(temp->ret_type!=("BSTree<"+stemp+">")){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type="BSTree<"+stemp+">";

        args_listn.clear();
        args_listt.clear();

        } block {
                if(check_return == false) {
                        cout<<"Semantic Error at line number "<<yylineno<<": No return statement in main scope block\n";
                        exit(1);
                }
                check_return=false;
        }
        | pt_allowed ID LPAR RPAR { 
        args_listn.clear();
        args_listt.clear();
        for(int i=0;i<args_listn.size();i++){
                for(int j=i+1;j<args_listn.size();j++){
                        if(args_listn[i]==args_listn[j]){
                                cout<<"Semantic Error at line number "<<yylineno<<": Parameters have same variable names\n";
                                exit(1); 
                        }
                }
        }
        funcTabEnt temp= search_functab($2,0,args_listt);
          if(!temp){
                cout<<"Semantic Error at line number "<<yylineno<<": function is not declared\n";
                exit(1);        
        }
        string s1=$1;
        if(temp->ret_type!=s1){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type=$1; 
        args_listn.clear();
        args_listt.clear(); 

        } block {
                if(check_return == false) {
                        cout<<"Semantic Error at line number "<<yylineno<<": No return statement in main scope block\n";
                        exit(1);
                }
        check_return=false;
        }

    | VOID ID LPAR RPAR {
        args_listn.clear();
        args_listt.clear();
        for(int i=0;i<args_listn.size();i++){
                for(int j=i+1;j<args_listn.size();j++){
                        if(args_listn[i]==args_listn[j]){
                                cout<<"Semantic Error at line number "<<yylineno<<": Parameters have same variable names\n";
                                exit(1); 
                        }
                }
        }
        funcTabEnt temp= search_functab($2,0,args_listt);
          if(!temp){
                cout<<"Semantic Error at line number "<<yylineno<<": function is not declared\n";
                exit(1);        
        }
        if(temp->ret_type!="void"){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type="void";
        args_listn.clear();
        args_listt.clear();

        } block {
                check_return=false;
        }
    | NODE LT pt_allowed GT ID LPAR RPAR {
        args_listn.clear();
        args_listt.clear();
        for(int i=0;i<args_listn.size();i++){
                for(int j=i+1;j<args_listn.size();j++){
                        if(args_listn[i]==args_listn[j]){
                                cout<<"Semantic Error at line number "<<yylineno<<": Parameters have same variable names\n";
                                exit(1); 
                        }
                }
        }
        funcTabEnt temp= search_functab($5,0,args_listt);
          if(!temp){
                cout<<"Semantic Error at line number "<<yylineno<<": function is not declared\n";
                exit(1);        
        }
        string stemp = $3;
        if(temp->ret_type!=("Node<"+stemp+">")){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type="Node<"+stemp+">";

        args_listn.clear();
        args_listt.clear();

        } block {
                if(check_return == false) {
                        cout<<"Semantic Error at line number "<<yylineno<<": No return statement in main scope block\n";
                        exit(1);
                }
                check_return=false;
        }
    | BTREE LT pt_allowed GT ID LPAR RPAR {
        args_listn.clear();
        args_listt.clear();
        for(int i=0;i<args_listn.size();i++){
                for(int j=i+1;j<args_listn.size();j++){
                        if(args_listn[i]==args_listn[j]){
                                cout<<"Semantic Error at line number "<<yylineno<<": Parameters have same variable names\n";
                                exit(1); 
                        }
                }
        }
        funcTabEnt temp= search_functab($5,0,args_listt);
          if(!temp){
                cout<<"Semantic Error at line number "<<yylineno<<": function is not declared\n";
                exit(1);        
        }
        string stemp = $3;
        if(temp->ret_type!=("BTree<"+stemp+">")){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type="BTree<"+stemp+">";

        args_listn.clear();
        args_listt.clear();

        } block {
                if(check_return == false) {
                        cout<<"Semantic Error at line number "<<yylineno<<": No return statement in main scope block\n";
                        exit(1);
                }
                check_return=false;
        }
    | BSTREE LT pt_allowed GT ID LPAR RPAR {
        args_listn.clear();
        args_listt.clear();
        for(int i=0;i<args_listn.size();i++){
                for(int j=i+1;j<args_listn.size();j++){
                        if(args_listn[i]==args_listn[j]){
                                cout<<"Semantic Error at line number "<<yylineno<<": Parameters have same variable names\n";
                                exit(1); 
                        }
                }
        }
        funcTabEnt temp= search_functab($5,0,args_listt);
          if(!temp){
                cout<<"Semantic Error at line number "<<yylineno<<": function is not declared\n";
                exit(1);        
        }
        string stemp = $3;
        if(temp->ret_type!=("BSTree<"+stemp+">")){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type="BSTree<"+stemp+">";

        args_listn.clear();
        args_listt.clear();

        } block {
                if(check_return == false) {
                        cout<<"Semantic Error at line number "<<yylineno<<": No return statement in main scope block\n";
                        exit(1);
                }
                check_return=false;
        }
        ;


f_args: f_arg 
         | f_args COMMA f_arg 
         ;

f_arg: pt_allowed ID {
                args_listt.push_back($1);
                args_listn.push_back($2);
        }
        | NODE LT pt_allowed GT ID {
                string stemp = $3;
                args_listt.push_back("Node<"+stemp+">");
                args_listn.push_back($5);
        }
        | BTREE LT pt_allowed GT ID {
                string stemp = $3;
                args_listt.push_back("BTree<"+stemp+">");
                args_listn.push_back($5);
        }
        | BSTREE LT pt_allowed GT ID {
                string stemp = $3;
                args_listt.push_back("BSTree<"+stemp+">");
                args_listn.push_back($5);
        }
        ;

block: LFB {
        scope++;
        create_symtab(scope);
        } RFB {
                delete_symEnt(scope);
                scope--;
        } // Defining block production, both with empty block as well as with statements
     | LFB {
        scope++;
        create_symtab(scope);
     } statements RFB {
        delete_symEnt(scope);
        scope--;
     }
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

declaration: pt_allowed id_list {
                    symTabEnt temp = NULL;
                    for(auto &i: vec) {
                        temp = search_symTab_scope(i, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        insert_symTab(i, $1, scope);
                    }
                    vec.clear();  
                }
           | NODE LT pt_allowed GT id_list {
                    symTabEnt temp = NULL;
                    for(auto &i: vec) {
                        temp = search_symTab_scope(i, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        string stemp = $3;
                        string str = "Node<" + stemp + ">";
                        insert_symTab(i, str, scope);
                    }    
                    vec.clear();
                }
           | BTREE LT pt_allowed GT id_list {
                    symTabEnt temp = NULL;
                    for(auto &i: vec) {
                        temp = search_symTab_scope(i, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        string stemp = $3;
                        string str = "BTree<" + stemp + ">";
                        insert_symTab(i, str, scope);
                    }    
                    vec.clear();
                }
           | BSTREE LT pt_allowed GT id_list {
                    symTabEnt temp = NULL;
                    for(auto &i: vec) {
                        temp = search_symTab_scope(i, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        string stemp = $3;
                        string str = "BSTree<" + stemp + ">";
                        insert_symTab(i, str, scope);
                    }    
                    vec.clear();
                }
           | pt_allowed ID LSB NUMBER RSB {
                    symTabEnt temp = NULL;
                    temp = search_symTab_scope($2, scope);
                    if(temp) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                        exit(1);
                    }
                    string stemp = $1;
                    string pqr = stemp + "[]";
                    insert_symTab($2, pqr, scope);
                }
           | NODE LT pt_allowed GT ID LSB NUMBER RSB {
                    symTabEnt temp = NULL;
                    temp = search_symTab_scope($5, scope);
                    if(temp) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                        exit(1);
                    }
                    string stemp = $3;
                    string pqr = "Node<" + stemp + ">[]";
                    insert_symTab($5, pqr, scope);
                }
           ;

id_list: ID { 
                string temp = $1;
                vec.push_back(temp);
        }
       | id_list COMMA ID {
                string temp = $3;
                vec.push_back(temp);
        }
       ;

intialisation_stmt: intialisation SEMICOLON 
                  ;

intialisation: pt_allowed ID EQUAL inpt_rhs {
                        string s1=$4;
                        symTabEnt temp = search_symTab_scope($2, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        if(!compatibility($1,s1)){
                                cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch\n";
                                exit(1);
                        }
                        insert_symTab($2, $1, scope);
                } 
             | NODE LT pt_allowed GT ID EQUAL LFB predicate COMMA n_par COMMA n_par RFB {
                        string q = $10;
                        symTabEnt temp = search_symTab_scope($5, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        if(!np_compat($3,$8)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Type of Node value is not compatible "<<endl;
                                exit(1);
                        }
                        $10 = q.c_str();
                        string str = $10;
                        string stemp = $3;
                        if((str!="null") && (str != ("Node<"+stemp+">") )) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Node value Type Mismatch12"<<endl;
                                exit(1);
                        }
                        str = $12;
                        if((str!="null") && (str != ("Node<"+stemp+">") )) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Node value Type Mismatch34"<<endl;
                                exit(1);
                        }
                        str = "Node<" + stemp + ">";
                        insert_symTab($5, str, scope);
                } 
             | BTREE LT pt_allowed GT ID EQUAL LFB bt_parm RFB {
                        symTabEnt temp = search_symTab_scope($5, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        string s1=$8;
                        if(!np_compat($3,$8) && (s1!="null")){
                                cout<<"Semantic Error at line number "<<yylineno<<": Node value Type Mismatch"<<endl;
                                exit(1);
                        }
                        string stemp = $3;
                        string str = "BTree<" + stemp + ">";
                        insert_symTab($5, str, scope);
                } 
             | BSTREE LT pt_allowed GT ID EQUAL LFB bst_parm RFB {
                        symTabEnt temp = search_symTab_scope($5, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        string s1=$8;
                        if(!np_compat($3,$8) || (s1 == "null")){
                                cout<<"Semantic Error at line number "<<yylineno<<": Node value Type Mismatch"<<endl;
                                exit(1);
                        }
                        string stemp = $3;
                        string str = "BSTree<" + stemp + ">";
                        insert_symTab($5, str, scope);
                } 
             ;

bt_parm: bt_par COMMA bt_parm {
                string s1 = $1;
                string s2 = $3;
                if((s1!="null" && s2!="null") && !compatibility($1, $3)) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch\n";
                        exit(1);
                }
                if(s1!="null" && s2!="null"){
                        string str = bt_final_type(s1,s2);
                        if(str == "") {
                             cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch\n";
                             exit(1);   
                        }
                        $$=str.c_str();
                }
                else if(s1 != "null") {
                        $$ = $1;
                }
                else {
                        $$ = $3;
                }
        }
       | bt_par {
                $$ = $1;
       }
       ;

bt_par: predicate {
                $$ = $1;
        }
      | LNULL {
                $$= "null";
      }
      ;

bst_parm: predicate COMMA bst_parm {
                if(!compatibility($1, $3)) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch\n";
                        exit(1);
                }
                string pqr = bt_final_type($1,$3);
                $$=pqr.c_str();
        }
        | predicate {
                $$ = $1;   
        }
        ;

n_par: LNULL {
                $$ = "null";
        }
     | ID {
                symTabEnt temp = search_symTab($1, scope);
                if(!temp) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }  
                string s1 = temp->type;                              
                $$ = s1.c_str();
     }
     ;

inpt_rhs: predicate {
                $$ = $1;
        }
        | ID DOT LEFT {
                symTabEnt temp = search_symTab($1, scope);
                string pqr;
                if(temp) {
                        pqr = temp->type;
                        if(pqr.substr(0, 4)!="Node") {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS is not compatible"<<endl;
                                exit(1); 
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
                $$=pqr.c_str();
        }
        | ID DOT RIGHT {
                symTabEnt temp = search_symTab($1, scope);
                string pqr;
                if(temp) {
                        pqr = temp->type;
                        if(pqr.substr(0, 4)!="Node") {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS is not compatible"<<endl;
                                exit(1); 
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
                $$=pqr.c_str();
        }
        | ID DOT VAL {
                symTabEnt temp = search_symTab($1, scope);
                string pqr;
                if(temp) {
                        pqr = temp->type;
                        if(pqr.substr(0, 4)!="Node") {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS is not compatible"<<endl;
                                exit(1); 
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
                size_t start = pqr.find('<');
                size_t end = pqr.find('>');
                string s= pqr.substr(start+1,end-start-1);
                $$=s.c_str();
        }
        ;

predicate: conditions {
                $$ = $1;
        }
         ;

conditions: NEG conditions {
                $$ = "bool";
        }// Defining conditions production with possible types of conditions
          | condition cond {
                const char* s1=$2;
                if(s1 == "") {
                        $$ = $1;  
                }
                else {
                        $$ = $2;
                }
          }
          ;
          
cond: AND conditions {
                $$ = "bool";
        }
    | OR conditions {
                $$ = "bool";
        }
    | LOR conditions {
                $$= "bool";
        }
    | LAND conditions {
                $$ = "bool";
        }
    | LXOR conditions {
                $$ = "bool";
        }
    |  {
                $$ = "";
        }
    ;       

condition: con_posm {
                $$ = $1;
        }
         ;

con_posm: con_pos {
                $$ = $1;
        }
        | con_pos ops con_pos {
                string ss1 = $1;
                string ss2 = $3;
                if(!(((ss1=="int")||(ss1=="float")||(ss1=="double")||(ss1=="long")||(ss1=="string")||(ss1=="char"))&&((ss2=="int")||(ss2=="float")||(ss2=="double")||(ss2=="long")||(ss2=="string")||(ss2=="char")))){
                                cout<<"Semantic Error at line number "<<yylineno<<": Invalid type for Relational Operations"<<endl;
                                exit(1); 
                        }
                        if(!compatibility($1, $3)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch"<<endl;
                                exit(1);
                        }
                        $$ ="bool";
        }
        | LPAR con_pos ops con_pos RPAR {
                string ss1 = $2;
                string ss2 = $4;
                   if(!(((ss1=="int")||(ss1=="float")||(ss1=="double")||(ss1=="long")||(ss1=="string")||(ss1=="char"))&&((ss2=="int")||(ss2=="float")||(ss2=="double")||(ss2=="long")||(ss2=="string")||(ss2=="char")))){
                                cout<<"Semantic Error at line number "<<yylineno<<": Invalid type for Relational Operations"<<endl;
                                exit(1); 
                        }
                        if(!compatibility($2, $4)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch"<<endl;
                                exit(1);
                        }
                        $$ ="bool";
        }
        | LTRUE {
                $$ = "bool";
        }
        | LFALSE {
                $$= "bool";
        }
        ;

ops: LT // Defining comparison operators production with valid comparison operators allowed
   | GT 
   | GEQ
   | LEQ
   | NE 
   | EQ 
   ;

con_pos: STRINGC {
                $$= "string";
        }
       | CHARC {
                $$= "char";
       }
       | acon_posm {
        $$=$1;
       }
       ;

acon_posm: acon_pos acond {
                string ss1=$2;
                string ss2=$1;
                if(ss1 == "") {
                        $$ = $1;  

                }
                else { 
                        if(modulo=='%'){
                                if(!((ss1=="int"||ss1=="long")&&(ss2=="int"||ss2=="long"))){
                                       cout<<"Semantic Error at line number "<<yylineno<<": Invalid type for Modulo Operators"<<endl;
                                       exit(1); 
                                }
                                modulo = '@';
                        }
                        if(!((ss2=="int"||ss2=="float"||ss2=="double"||ss2=="long")&&(ss1=="int"||ss1=="float"||ss1=="double"||ss1=="long"))){
                                cout<<"Semantic Error at line number "<<yylineno<<": Invalid type for Arithmetic Operations"<<endl;
                                exit(1); 
                        }
                        if(!compatibility($1, $2)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch"<<endl;
                                exit(1);
                        }
                        $$ = final_type($1, $2).c_str();


                }
        }
        ;

acond: aops acon_posm {
                $$ = $2;
        }
     | {
        $$ = "";
     }
     ;

aops: ADD // Defining comparison operators production with valid comparison operators allowed
    | SUB 
    | MUL 
    | DIV 
    | MOD {
        modulo = '%';
    }
    ;

acon_pos: ID {
        symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        $$=temp->type.c_str();
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
        }
        | DECIMAL {
                $$="long";
        }
        | FLOATING {
                $$="double";
        }
        | NUMBER {
                $$="long";
        } 
        | func_call {
                $$=$1;
        }
        | LPAR acon_posm RPAR {
                $$=$2;
        }
        ;

func_call: ID LPAR call_args RPAR {
                funcTabEnt temp = search_functab_compat($1,0,call_list);
                if(!temp){
                        cout<<"Semantic Error at line number "<<yylineno<<": Function is not declared"<<endl;
                        exit(1);
                }
                $$ = temp->ret_type.c_str();
                }
        | ID LPAR RPAR {
                call_list.clear();
                funcTabEnt temp = search_functab_compat($1,0,call_list);
                if(!temp){
                        cout<<"Semantic Error at line number "<<yylineno<<": Function is not declared"<<endl;
                        exit(1);
                }
                string pqr = temp->ret_type;
                $$ = pqr.c_str();
        }
         | ID DOT ID LPAR call_args RPAR  {
                 symTabEnt temp = search_symTab($1, scope);
                        if(!temp) {
                              cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                              exit(1);  
                        }
                        string str=temp->type;
                        if(str.substr(0,5)!="BTree" && str.substr(0,6)!="BSTree"){
                              cout<<"Semantic Error at line number "<<yylineno<<": Type does not have method functions"<<endl;
                              exit(1); 
                        }
                        else {
                                size_t start = str.find('<');
                                size_t end = str.find('>');
                                string s= str.substr(start+1,end-start-1);
                                funcTabEnt var = search_functab_builtin($3,1,call_list, s);
                                 if(!var) {
                                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undefined built-in method function"<<endl;
                                        exit(1);  
                                }
                                
                                $$ = var->ret_type.c_str();
                                call_list.clear();

                        }
        }
         | ID DOT ID LPAR RPAR  {
                        call_list.clear();
                 symTabEnt temp = search_symTab($1, scope);
                        if(!temp) {
                              cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                              exit(1);  
                        }
                        string str=temp->type;
                        if(str.substr(0,5)!="BTree" && str.substr(0,6)!="BSTree"){
                              cout<<"Semantic Error at line number "<<yylineno<<": Type does not have method functions"<<endl;
                              exit(1); 
                        }
                        else {
                                size_t start = str.find('<');
                                size_t end = str.find('>');
                                string s= str.substr(start+1,end-start-1);
                                funcTabEnt var = search_functab_builtin($3,1,call_list,s);
                                 if(!var) {
                                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undefined built-in method function"<<endl;
                                        exit(1);  
                                }
                                $$ = var->ret_type.c_str();
                                call_list.clear();
                        }
        }
         ;

call_args: call_args COMMA predicate {
                        call_list.push_back($3);
                }
         | predicate {
                        call_list.push_back($1);
                }
         ;

init_args: init_args COMMA init_arg 
         | init_arg 
         ;

init_arg: inpt_rhs {
                    init_list.push_back($1);
                }
        | LNULL {
                    init_list.push_back("null");
                }
        ;

assignment: ID EQUAL {
                        symTabEnt temp = search_symTab($1, scope);
                        if(!temp) {
                              cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                              exit(1);  
                        }
                        assn_idtype = temp->type;
        } s_marker 
          | ID DOT LEFT EQUAL ID SEMICOLON {
                symTabEnt temp1 = search_symTab($1, scope);
                symTabEnt temp2 = search_symTab($5, scope);                
                if(temp1 && temp2) {
                        string str1 = temp1->type;
                        string str2 = temp2->type;
                        if(str1.substr(0, 4)!="Node") {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS is not compatible"<<endl;
                                exit(1); 
                        }
                        if(str2.substr(0, 4)!="Node") {
                                cout<<"Semantic Error at line number "<<yylineno<<": RHS is not compatible"<<endl;
                                exit(1); 
                        }
                        if(!compatibility(temp2->type, temp1->type)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS and RHS types are not compatible"<<endl;
                                exit(1);
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
          }
          | ID DOT LEFT EQUAL LNULL SEMICOLON {
                symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        string str = temp->type;
                        if(str.substr(0, 4)!="Node") {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS is not compatible"<<endl;
                                exit(1); 
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
        }
          | ID DOT RIGHT EQUAL ID SEMICOLON {
                symTabEnt temp1 = search_symTab($1, scope);
                symTabEnt temp2 = search_symTab($5, scope);                
                if(temp1 && temp2) {
                        string str1 = temp1->type;
                        string str2 = temp2->type;
                        if(str1.substr(0, 4)!="Node") {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS is not compatible"<<endl;
                                exit(1); 
                        }
                        if(str2.substr(0, 4)!="Node") {
                                cout<<"Semantic Error at line number "<<yylineno<<": RHS is not compatible"<<endl;
                                exit(1); 
                        }
                        if(!compatibility(temp2->type, temp1->type)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS and RHS types are not compatible"<<endl;
                                exit(1);
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
          }
          | ID DOT RIGHT EQUAL LNULL SEMICOLON {
                symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        string str = temp->type;
                        if(str.substr(0, 4)!="Node") {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS is not compatible"<<endl;
                                exit(1); 
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
        }
          | ID DOT VAL EQUAL predicate SEMICOLON {
                symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        string str = temp->type;
                        if(str.substr(0, 4)!="Node") {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS is not compatible"<<endl;
                                exit(1); 
                        }
                        size_t start = str.find('<');
                        size_t end = str.find('>');
                        string s= str.substr(start+1,end-start-1);
                        if(!np_compat(s,$5)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS is not compatible"<<endl;
                                exit(1);
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
          }
          ;

s_marker: expr SEMICOLON {
                if(!compatibility($1, assn_idtype)) {
                        cout<<"Semantic Error at line number "<<yylineno<<": LHS and RHS types are not compatible"<<endl;
                        exit(1);
                }
                assn_idtype="";
        }

expr: inpt_rhs {
        $$=$1;
    }
    | LFB init_args RFB {
        string stemp = "";
        if(init_list.size() == 3) {
                string str=assn_idtype;
                size_t start = str.find('<');
                size_t end = str.find('>');
                string s= str.substr(start+1,end-start-1);
                const char* f=s.c_str(); 
                if(np_compat(s,init_list[0])) {
                        if(init_list[1]=="null" && init_list[2]=="null") {
                                if(assn_idtype != "") {
                                        if(assn_idtype.substr(0, 4) == "Node") {
                                               $$ = assn_idtype.c_str(); 
                                        }
                                        else {
                                                stemp = "BTree<" + s + ">";
                                                $$ = stemp.c_str(); 
                                        }

                                }
                                else {
                                        stemp = "BTree<" + s + ">";
                                        $$ = stemp.c_str();
                                }
                                }
                        else if(((init_list[1]=="null") || (init_list[1] == ("Node<"+s+">"))) && ((init_list[2]=="null") || (init_list[2] == ("Node<"+s+">")))) {
                                stemp = "Node<" + s + ">";
                                $$ = stemp.c_str();      
                        }
                        else if(np_compat(s, init_list[1]) && np_compat(s, init_list[2])){
                                if(assn_idtype != "") {
                                        if(assn_idtype.substr(0, 6) == "BSTree") {
                                               $$ = assn_idtype.c_str();
                                        }
                                        else {
                                                stemp = "BTree<" + s + ">";
                                                $$ = stemp.c_str(); 
                                        }

                                }
                                else {
                                        stemp = "BTree<" + s + ">";
                                        $$ = stemp.c_str();                              
                                }
                        }
                        else if(((init_list[1]=="null") || np_compat(s, init_list[1])) && ((init_list[2]=="null") || np_compat(s, init_list[2]))) {
                                stemp = "BTree<" + s + ">";
                                $$ = stemp.c_str();
                        }
                        else {
                                cout<<"Semantic Error at line number "<<yylineno<<": Invalid literal"<<endl;
                                exit(1);
                        }
                }
                else {
                      cout<<"Semantic Error at line number "<<yylineno<<": Invalid literal"<<endl;
                      exit(1);  
                }
        }   
        else {
                string str=assn_idtype;
                size_t start = str.find('<');
                size_t end = str.find('>');
                string s = str.substr(start+1,end-start-1);
                bool a = false;
                for(auto i: init_list) {
                        if(i == "null") {
                                a = true;  
                        }
                        else if(!np_compat(s, i)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Increment cannot be done to this type"<<endl;
                                exit(1);
                        }
                }
                if(!a) {
                        if(assn_idtype != "") {
                                if(assn_idtype.substr(0, 6) == "BSTree") {
                                        $$ = assn_idtype.c_str(); 
                                }
                                else {
                                        stemp = "BTree<" + s + ">";
                                        $$ = stemp.c_str();                
                                }
                        }
                        else {
                                stemp = "BTree<" + s + ">";
                                $$ = stemp.c_str();
                        }
                }
                else {
                        stemp = "BTree<" + s + ">";
                        $$ = stemp.c_str();   
                }
        } 
        init_list.clear();
    }
    | ID INCR {
         symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        if(temp->type=="int" || temp->type=="long"||temp->type=="float" || temp->type=="double"){
                                $$=temp->type.c_str();
                        }
                        else{
                             cout<<"Semantic Error at line number "<<yylineno<<": Increment cannot be done to this type"<<endl;
                             exit(1);   
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
    }
    | ID DECR {
         symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        if(temp->type=="int" || temp->type=="long"||temp->type=="float" || temp->type=="double"){
                                $$=temp->type.c_str();
                        }
                        else{
                             cout<<"Semantic Error at line number "<<yylineno<<": Decrement cannot be done to this type"<<endl;
                             exit(1);   
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
    }
    ;

expression: exprt SEMICOLON {
                p=true;
        }
        ;

exprt: inpt_rhs {
            $$=$1;
        }
     | ID INCR {
        symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        if(temp->type=="int" || temp->type=="long"||temp->type=="float" || temp->type=="double"){
                                $$=temp->type.c_str();
                        }
                        else{
                             cout<<"Semantic Error at line number "<<yylineno<<": Increment cannot be done to this type"<<endl;
                             exit(1);   
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
        }
     | ID DECR {
        symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        if(temp->type=="int" || temp->type=="long"||temp->type=="float" || temp->type=="double"){
                                $$=temp->type.c_str();
                        }
                        else{
                             cout<<"Semantic Error at line number "<<yylineno<<": Decrement cannot be done to this type"<<endl;
                             exit(1);   
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
     }
     ;

conditional_stmt: f_marker
                | f_marker ELSE{scope++;
                 create_symtab(scope);
                } loop_block
                ;

f_marker: IF LPAR predicate RPAR {scope++;
                create_symtab(scope);
                } loop_block
        ;

loop_stmt: while_loop
         | for_loop
         ;

while_loop: while_marker LPAR predicate RPAR loop_block {find_loop--;}
          ;

while_marker: WHILE {
           find_loop++;
           scope++;
           create_symtab(scope);
         }
         ;
         
for_loop: for_marker LPAR for_f SEMICOLON predicate SEMICOLON for_l RPAR loop_block {find_loop--;}
        |  for_marker LPAR for_f SEMICOLON predicate SEMICOLON  ID EQUAL t_marker RPAR loop_block {find_loop--;}
        ;

for_marker: FOR {
           find_loop++;
           scope++;
           create_symtab(scope);
         }
         ;
         
loop_block: LFB RFB {
                delete_symEnt(scope);
                scope--;
        } // Defining block production, both with empty block as well as with statements
     | LFB loop_statements RFB {
                delete_symEnt(scope);
                scope--;
        }
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
         | BREAK SEMICOLON {if(find_loop == 0) {
                                 cout<<"Semantic Error at line number "<<yylineno<<": Use of break outside of loops"<<endl;
                                exit(1);       
                                }
         }
         | CONTINUE SEMICOLON {if(find_loop == 0) {
                                 cout<<"Semantic Error at line number "<<yylineno<<": Use of continue outside of loops"<<endl;
                                exit(1);       
                                }
         }
         | input_stmt
         | output_stmt
         | {scope++;
           create_symtab(scope);}loop_block
         ;

for_f: declaration 
     | intialisation 
     | for_f_marker t_marker
     ;

for_f_marker: ID EQUAL {
        symTabEnt temp = search_symTab($1, scope);
        if(!temp) {
        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
        exit(1);  
        }
        assn_idtype = temp->type;
     } 
     ;

t_marker: expr {
        if(!compatibility($1, assn_idtype)) {
                cout<<"Semantic Error at line number "<<yylineno<<": LHS and RHS types are not compatible"<<endl;
                exit(1);
        }
        assn_idtype="";
     }

for_l: predicate 
     | ID INCR {
         symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        if(temp->type=="int" || temp->type=="long"||temp->type=="float" || temp->type=="double"){
                                
                        }
                        else{
                             cout<<"Semantic Error at line number "<<yylineno<<": Increment cannot be done to this type"<<endl;
                             exit(1);   
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
        }
     | ID DECR {
         symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        if(temp->type=="int" || temp->type=="long"||temp->type=="float" || temp->type=="double"){
                                
                        }
                        else{
                             cout<<"Semantic Error at line number "<<yylineno<<": Decrement cannot be done to this type"<<endl;
                             exit(1);   
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
        }
     ;

return_stmt: RETURN predicate SEMICOLON {
                if(scope == 1) {
                        check_return = true;
                }
                if(!compatibility(ret_type,$2)) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Return type mismatch"<<endl;
                        exit(1);
                }
        }
           | RETURN SEMICOLON {
                if(scope == 1) {
                        check_return = true;
                }
                if(ret_type != "void") {
                        cout<<"Semantic Error at line number "<<yylineno<<": Return type mismatch"<<endl;
                        exit(1);
                }
           }
          ;

input_stmt: INPUT LPAR ID RPAR SEMICOLON  { 
        symTabEnt temp = search_symTab($3, scope);
                if(temp) {
                         if(!(temp->type=="int" || temp->type=="long"||temp->type=="float" || temp->type=="double"|| temp->type=="bool"||temp->type=="string" || temp->type=="char")){
                             cout<<"Semantic Error at line number "<<yylineno<<": Input cannot be taken for this type "<<endl;
                             exit(1);  
                        }
                }
                  else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
        }        
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
int yywrap(){
        return 0;
} // Defining yywrap function (no action required)

int main(int argc, char* argv[]){
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
