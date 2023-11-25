%{
#include <bits/stdc++.h>
// #include "global.hpp"
#include "funcs.hpp"



extern FILE* yyin; // Declare an external file pointer for input

FILE* fsread; // Declare file pointers for reading and writing
FILE* fswrite;
FILE* fir;

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

int yylex(void); // Declare the lexer function
void yyerror(const char* msg); // Declare the error handling function
%}

%union {
        const char* name;
        const char* text;
        const char* type;
        struct atr{
                const char* type;
                const char* text;
        } str;
}

%token <name> ID
%token <text> NUMBER
%token <text> STRINGC
%token <text> CHARC
%token <text> DECIMAL
%token <text> FLOATING
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

%type <str> expression
%type <str> pt_allowed 
%type <str> func_args
%type <str> func_arg
%type <str> f_args
%type <str> f_arg
%type <str> id_list
%type <str> bt_parm
%type <str> bt_par
%type <str> bst_parm
%type <str> n_par
%type <str> inpt_rhs
%type <str> predicate
%type <str> conditions
%type <str> condition
%type <str> expr
%type <str> exprt
%type <str> acon_pos
%type <str> acon_posm
%type <str> con_pos
%type <str> con_posm
%type <str> acond
%type <str> cond
%type <str> aops
%type <str> init_args
%type <str> init_arg
%type <str> func_call
%type <str> call_args
%type <str> ops
%type <str> declaration
%type <str> intialisation
%type <str> t_marker
%type <str> for_l
%type <str> for_f
%type <str> print_posm
%type <str> print_pos
%type <str> for_loop
%type <str> while_loop
%type <str> for_f_marker

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
        insert_functab("delete",1,{"Node"},"Node");
        create_symtab(scope);
     }
     ;
     
main: MAIN LPAR RPAR {fprintf(fir, "int main()");
                        ret_type = "int";} block {
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
                insert_functab($2,0,param_list,$1.type);
                param_list.clear();
                fprintf(fir,"%s %s(%s);\n",$1.text,$2,$4.text);
        }
        | VOID ID LPAR func_args RPAR SEMICOLON {
                if(search_functab($2,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                insert_functab($2,0,param_list,"void");
                param_list.clear();
                fprintf(fir,"void %s(%s);\n",$2,$4.text);                
        }
        | NODE LT pt_allowed GT ID LPAR func_args RPAR SEMICOLON {
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3.type;
                string str = "Node<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();
                fprintf(fir,"Node<%s> %s(%s);\n",$3.text,$5,$7.text);

        }
        | BTREE LT pt_allowed GT ID LPAR func_args RPAR SEMICOLON {
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3.type;
                string str = "BTree<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();
                fprintf(fir,"BTree<%s> %s(%s);\n",$3.text,$5,$7.text);
        }
        | BSTREE LT pt_allowed GT ID LPAR func_args RPAR SEMICOLON {
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3.type;
                string str = "BSTree<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();
                fprintf(fir,"BSTree<%s> %s(%s);\n",$3.text,$5,$7.text);
        }
        | pt_allowed ID LPAR RPAR SEMICOLON {
                param_list.clear();                
                if(search_functab($2,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                insert_functab($2,0,param_list,$1.type);
                param_list.clear();
                fprintf(fir,"%s %s();\n",$1.text,$2);
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
                fprintf(fir,"void %s();\n",$2);
        }
        | NODE LT pt_allowed GT ID LPAR RPAR SEMICOLON {
                param_list.clear();
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3.type;
                string str = "Node<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();
                fprintf(fir,"Node<%s> %s();\n",$3.text,$5);
        } 
        | BTREE LT pt_allowed GT ID LPAR RPAR SEMICOLON {
                param_list.clear();
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3.type;
                string str = "BTree<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();
                fprintf(fir,"BTree<%s> %s();\n",$3.text,$5);
        }
        | BSTREE LT pt_allowed GT ID LPAR RPAR SEMICOLON  {
                param_list.clear();
                if(search_functab($5,0,param_list))
                {
                        cout<<"Semantic Error at line number "<<yylineno<<": function already declared\n";
                        exit(1);
                }
                string stemp = $3.type;
                string str = "BSTree<"+stemp+">";
                insert_functab($5,0,param_list,str);
                param_list.clear();
                fprintf(fir,"BSTree<%s> %s();\n",$3.text,$5);
        }
        ;

pt_allowed: INT {
               $$.type = "int"; 
               $$.text = "int"; 
        }
          | FLOAT {
               $$.type="float"; 
               $$.text="float"; 
        }
          | CHAR {
               $$.type="char"; 
               $$.text="char"; 
        }
          | STRING {
               $$.type="string"; 
               $$.text="string"; 
        }
          | BOOL {
               $$.type="bool"; 
               $$.text="bool"; 
        }
          | DOUBLE {
               $$.type="double"; 
               $$.text="double"; 
        }
          | LONG {
               $$.type="long"; 
               $$.text="long"; 
        }
          ;

func_args: func_arg {$$.text=$1.text;}// Defining function arguments production
         | func_args COMMA func_arg {
                char* str = (char*)malloc(strlen($1.text)+strlen($3.text)+strlen(", ")+1);
                strcpy(str, $1.text);
                strcat(str,", ");
                strcat(str, $3.text);
                $$.text = str;
         }
         ;


func_arg: pt_allowed {
                param_list.push_back($1.type);
                $$.text=$1.text;
        }
        | NODE LT pt_allowed GT {
                string stemp = $3.type;
                param_list.push_back("Node<"+stemp+">");

                char* str = (char*)malloc(strlen("Node<>")+strlen($3.text)+1);
                strcpy(str, "Node<");
                strcat(str, $3.text);
                strcat(str, ">");
                $$.text = str;
        }
        | BTREE LT pt_allowed GT {
                string stemp = $3.type;
                param_list.push_back("BTree<"+stemp+">");
                string str="BTree<";
                str=str+$3.text+">";
                $$.text=str.c_str();
        }
        | BSTREE LT pt_allowed GT {
                string stemp = $3.type;
                param_list.push_back("BSTree<"+stemp+">");
                string str="BSTree<";
                str=str+$3.text+">";
                $$.text=str.c_str();
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
        if(temp->ret_type!=$1.type){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type=$1.type; 
        args_listn.clear();
        args_listt.clear(); 

        fprintf(fir,"%s %s(%s)",$1.text,$2,$4.text);
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

        fprintf(fir,"void %s(%s)",$2,$4.text);
        } block 
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
        string stemp = $3.type;
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

        fprintf(fir,"Node<%s> %s(%s)\n",$3.text,$5,$7.text);
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
        string stemp = $3.type;
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

        fprintf(fir,"BTree<%s> %s(%s);\n",$3.text,$5,$7.text);
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
        string stemp = $3.type;
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

        fprintf(fir,"BSTree<%s> %s(%s);\n",$3.text,$5,$7.text);
        } block 
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
        string s1=$1.type;
        if(temp->ret_type!=s1){
                cout<<"Semantic Error at line number "<<yylineno<<": Function cannot be overloaded with different return type\n";
                exit(1);
        }
        for(int i=0;i<args_listt.size();i++){
                insert_symTab(args_listn[i],args_listt[i],scope+1);
        }
        ret_type=$1.type; 
        args_listn.clear();
        args_listt.clear(); 

        fprintf(fir,"%s %s()",$1.text,$2);
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

        fprintf(fir,"void %s()",$2);
        } block 
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
        string stemp = $3.type;
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

        fprintf(fir,"Node<%s> %s();\n",$3.text,$5);
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
        string stemp = $3.type;
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

        fprintf(fir,"BTree<%s> %s();\n",$3.text,$5);
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
        string stemp = $3.type;
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

        fprintf(fir,"BTree<%s> %s();\n",$3.text,$5);
        } block {
                if(check_return == false) {
                        cout<<"Semantic Error at line number "<<yylineno<<": No return statement in main scope block\n";
                        exit(1);
                }
                check_return=false;
        }
        ;


f_args: f_arg {$$.text=$1.text;}
         | f_args COMMA f_arg {
                char* str = (char*)malloc(strlen($1.text)+strlen($3.text)+strlen(", ")+1);
                strcpy(str, $1.text);
                strcat(str, ", ");
                strcat(str, $3.text);
                $$.text = str;
         }
         ;

f_arg: pt_allowed ID {
                args_listt.push_back($1.type);
                args_listn.push_back($2);

                char* str = (char*)malloc(strlen($1.text)+strlen($2)+strlen(" ")+1);
                strcpy(str, $1.text);
                strcat(str, " ");
                strcat(str, $2);
                $$.text = str;
        }
        | NODE LT pt_allowed GT ID {
                string stemp = $3.type;
                args_listt.push_back("Node<"+stemp+">");
                args_listn.push_back($5);

                char* str = (char*)malloc(strlen($3.text)+strlen($5)+strlen("Node<> ")+1);
                strcpy(str,"Node<" );
                strcat(str,$3.text);
                strcat(str,"> " );
                strcat(str, $5);
                $$.text = str;
        }
        | BTREE LT pt_allowed GT ID {
                string stemp = $3.type;
                args_listt.push_back("BTree<"+stemp+">");
                args_listn.push_back($5);

                char* str = (char*)malloc(strlen($3.text)+strlen($5)+strlen("BTree<> ")+1);
                strcpy(str,"BTree<" );
                strcat(str,$3.text);
                strcat(str,"> " );
                strcat(str, $5);
                $$.text = str;  
        }
        | BSTREE LT pt_allowed GT ID {
                string stemp = $3.type;
                args_listt.push_back("BSTree<"+stemp+">");
                args_listn.push_back($5);

                char* str = (char*)malloc(strlen($3.text)+strlen($5)+strlen("BSTree<> ")+1);
                strcpy(str,"BSTree<" );
                strcat(str,$3.text);
                strcat(str,"> " );
                strcat(str, $5);
                $$.text = str;  
        }
        ;

block: LFB {
        scope++;
        create_symtab(scope);
        fprintf(fir,"{\n");
        } RFB {
                delete_symEnt(scope);
                scope--;
                fprintf(fir,"}\n");
        } // Defining block production, both with empty block as well as with statements
     | LFB {
        scope++;
        create_symtab(scope);
        fprintf(fir,"{\n");
     } statements RFB {
        delete_symEnt(scope);
        scope--;
        fprintf(fir,"}\n");
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

declaration_stmt: declaration SEMICOLON {
                        fprintf(fir,"%s;\n", $1.text);
                }
                ;

declaration: pt_allowed id_list {
                    symTabEnt temp = NULL;
                    for(auto &i: vec) {
                        temp = search_symTab_scope(i, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        insert_symTab(i, $1.type, scope);
                    }
                    vec.clear();  
                    char* str = (char*)malloc(strlen($1.text)+strlen($2.text)+strlen(" ")+1);
                        strcpy(str, $1.text);
                        strcat(str, " ");
                        strcat(str, $2.text);
                        $$.text = str;
                }
           | NODE LT pt_allowed GT id_list {
                    symTabEnt temp = NULL;
                    for(auto &i: vec) {
                        temp = search_symTab_scope(i, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        string stemp = $3.type;
                        string str = "Node<" + stemp + ">";
                        insert_symTab(i, str, scope);
                    }    
                    vec.clear();

                    char* str = (char*)malloc(strlen("Node<> ")+strlen($3.text)+strlen($5.text)+1);
                        strcpy(str, "Node<");
                        strcat(str, $3.text);
                        strcat(str, "> ");
                        strcat(str, $5.text);
                        $$.text = str;
                }
           | BTREE LT pt_allowed GT id_list {
                    symTabEnt temp = NULL;
                    for(auto &i: vec) {
                        temp = search_symTab_scope(i, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        string stemp = $3.type;
                        string str = "BTree<" + stemp + ">";
                        insert_symTab(i, str, scope);
                    }    
                    vec.clear();
                        char* str = (char*)malloc(strlen("BTree<> ")+strlen($3.text)+strlen($5.text)+1);
                        strcpy(str, "BTree<");
                        strcat(str, $3.text);
                        strcat(str, "> ");
                        strcat(str, $5.text);
                        $$.text = str;
                }
           | BSTREE LT pt_allowed GT id_list {
                    symTabEnt temp = NULL;
                    for(auto &i: vec) {
                        temp = search_symTab_scope(i, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        string stemp = $3.type;
                        string str = "BSTree<" + stemp + ">";
                        insert_symTab(i, str, scope);
                    }    
                    vec.clear();

                    char* str = (char*)malloc(strlen("BSTree<> ")+strlen($3.text)+strlen($5.text)+1);
                        strcpy(str, "BSTree<");
                        strcat(str, $3.text);
                        strcat(str, "> ");
                        strcat(str, $5.text);
                        $$.text = str;
                }
           | pt_allowed ID LSB NUMBER RSB {
                    symTabEnt temp = NULL;
                    temp = search_symTab_scope($2, scope);
                    if(temp) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                        exit(1);
                    }
                    string stemp = $1.type;
                    string pqr = stemp + "[]";
                    insert_symTab($2, pqr, scope);
                    
                    char* str = (char*)malloc(strlen($1.text)+strlen($2)+strlen($4)+strlen("[] ")+1);
                        strcpy(str, $1.text);
                        strcat(str, " ");
                        strcat(str, $2);
                        strcat(str, "[");
                        strcat(str, $4);
                        strcat(str, "]");
                        $$.text = str;
                }
           | NODE LT pt_allowed GT ID LSB NUMBER RSB {
                    symTabEnt temp = NULL;
                    temp = search_symTab_scope($5, scope);
                    if(temp) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                        exit(1);
                    }
                    string stemp = $3.type;
                    string pqr = "Node<" + stemp + ">[]";
                    insert_symTab($5, pqr, scope);

                        char* str = (char*)malloc(strlen($3.text)+strlen($5)+strlen($7)+strlen("Node[<>] ")+1);
                        strcpy(str, "Node<");
                        strcat(str, $3.text);
                        strcat(str, "> ");
                        strcat(str, $5);
                        strcat(str, "[");
                        strcat(str, $7);
                        strcat(str, "]");
                        $$.text = str;
                }
           ;

id_list: ID { 
                string temp = $1;
                vec.push_back(temp);

                $$.text=$1;
        }
       | id_list COMMA ID {
                string temp = $3;
                vec.push_back(temp); 

                 char* str = (char*)malloc(strlen(", ")+strlen($1.text)+strlen($3)+1);
                        strcpy(str, $1.text);
                        strcat(str, ", ");
                        strcat(str, $3);
                        $$.text = str;
       }
       ;

intialisation_stmt: intialisation SEMICOLON {
                        fprintf(fir,"%s;\n",$1.text);
                }
        ;

intialisation: pt_allowed ID EQUAL inpt_rhs {
                        symTabEnt temp = search_symTab_scope($2, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        if(!compatibility($1.type,$4.type)){
                                cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch\n";
                                exit(1);
                        }
                        insert_symTab($2, $1.type, scope);

                        char* str = (char*)malloc(strlen("=   ")+strlen($1.text)+strlen($2)+strlen($4.text)+1);
                        strcpy(str, $1.text);
                        strcat(str, " ");
                        strcat(str, $2);
                        strcat(str, " = ");
                        strcat(str, $4.text);
                        $$.text = str;
                } 
             | NODE LT pt_allowed GT ID EQUAL LFB predicate COMMA n_par COMMA n_par RFB {
                        string q = $10.type;
                        symTabEnt temp = search_symTab_scope($5, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        if(!np_compat($3.type,$8.type)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Type of Node value is not compatible "<<endl;
                                exit(1);
                        }
                        $10.type = q.c_str();
                        string str = $10.type;
                        string stemp = $3.type;
                        if((str!="null") && (str != ("Node<"+stemp+">") )) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Node value Type Mismatch12"<<endl;
                                exit(1);
                        }
                        str = $12.type;
                        if((str!="null") && (str != ("Node<"+stemp+">") )) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Node value Type Mismatch34"<<endl;
                                exit(1);
                        }
                        str = "Node<" + stemp + ">";
                        insert_symTab($5, str, scope);

                        char* sqr = (char*)malloc(strlen("Node<>  = new node<>{, , }")+strlen($3.text)+strlen($3.text)+strlen($10.text)+strlen($12.text)+strlen($5)+strlen($8.text)+1);
                        strcpy(sqr, "Node<");
                        strcat(sqr, $3.text);
                        strcat(sqr, "> ");
                        strcat(sqr, $5);
                        strcat(sqr, " = new node<");
                        strcat(sqr, $3.text);
                        strcat(sqr, ">{");
                        strcat(sqr, $8.text);
                        strcat(sqr, ", ");
                        strcat(sqr, $10.text);
                        strcat(sqr, ", ");
                        strcat(sqr, $12.text);
                        strcat(sqr, "}");
                        $$.text = sqr;
                } 
             | BTREE LT pt_allowed GT ID EQUAL LFB bt_parm RFB {
                        symTabEnt temp = search_symTab_scope($5, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        string s1=$8.type;
                        if(!np_compat($3.type,$8.type) && (s1!="null")){
                                cout<<"Semantic Error at line number "<<yylineno<<": Node value Type Mismatch"<<endl;
                                exit(1);
                        }
                        string stemp = $3.type;
                        string str = "BTree<" + stemp + ">";
                        insert_symTab($5, str, scope);

                        char* sqr = (char*)malloc(strlen("BTree<>  = new btree<>{}")+strlen($3.text)+strlen($3.text)+strlen($5)+strlen($8.text)+1);
                        strcpy(sqr, "BTree<");
                        strcat(sqr, $3.text);
                        strcat(sqr, "> ");
                        strcat(sqr, $5);
                        strcat(sqr, " = new btree<");
                        strcat(sqr, $3.text);
                        strcat(sqr, ">{");
                        strcat(sqr, $8.text);
                        strcat(sqr, "}");
                        $$.text = sqr;
                } 
             | BSTREE LT pt_allowed GT ID EQUAL LFB bst_parm RFB {
                        symTabEnt temp = search_symTab_scope($5, scope);
                        if(temp) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Variable has already been declared"<<endl;
                                exit(1);
                        }
                        string s1=$8.type;
                        if(!np_compat($3.type,$8.type) || (s1 == "null")){
                                cout<<"Semantic Error at line number "<<yylineno<<": Node value Type Mismatch"<<endl;
                                exit(1);
                        }
                        string stemp = $3.type;
                        string str = "BSTree<" + stemp + ">";
                        insert_symTab($5, str, scope);

                        char* sqr = (char*)malloc(strlen("BSTree<>  = new bstree<>{}")+strlen($3.text)+strlen($3.text)+strlen($5)+strlen($8.text)+1);
                        strcpy(sqr, "BSTree<");
                        strcat(sqr, $3.text);
                        strcat(sqr, "> ");
                        strcat(sqr, $5);
                        strcat(sqr, " = new bstree<");
                        strcat(sqr, $3.text);
                        strcat(sqr, ">{");
                        strcat(sqr, $8.text);
                        strcat(sqr, "}");
                        $$.text = sqr;
                } 
             ;

bt_parm: bt_par COMMA bt_parm {
                string s1 = $1.type;
                string s2 = $3.type;
                if((s1!="null" && s2!="null") && !compatibility($1.type, $3.type)) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch\n";
                        exit(1);
                }
                if(s1!="null" && s2!="null"){
                        string str = bt_final_type(s1,s2);
                        if(str == "") {
                             cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch\n";
                             exit(1);   
                        }
                        $$.type=str.c_str();
                }
                else if(s1 != "null") {
                        $$.type = $1.type;
                }
                else {
                        $$.type = $3.type;
                }

                char* str = (char*)malloc(strlen(", ")+strlen($1.text)+strlen($3.text)+1);
                strcpy(str, $1.text);
                strcat(str, ", ");
                strcat(str, $3.text);
                $$.text = str;
        }
       | bt_par {
                $$.type = $1.type;
                $$.text= $1.text;
       }
       ;

bt_par: predicate {
                $$.type = $1.type;
                $$.text=$1.text;
        }
      | LNULL {
                $$.type= "null";
                $$.text="NULL";
      }
      ;

bst_parm: predicate COMMA bst_parm {
                if(!compatibility($1.type, $3.type)) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch\n";
                        exit(1);
                }
                string pqr = bt_final_type($1.type,$3.type);
                $$.type=pqr.c_str();

                char* str = (char*)malloc(strlen(", ")+strlen($1.text)+strlen($3.text)+1);
                strcpy(str, $1.text);
                strcat(str, ", ");
                strcat(str, $3.text);
                $$.text = str;
        }
        | predicate {
                $$.type = $1.type;   
                $$.text=$1.text;     
        }
        ;

n_par: LNULL {
                $$.type = "null";
                $$.text="NULL";
        }
     | ID {
                symTabEnt temp = search_symTab($1, scope);
                if(!temp) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }  
                string s1 = temp->type;                              
                $$.type = s1.c_str();
                $$.text= $1;
     }
     ;

inpt_rhs: predicate {
                $$.type = $1.type;
                $$.text=$1.text;
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
                $$.type=pqr.c_str();
                char* str = (char*)malloc(strlen($1)+strlen("->left")+1);
                strcpy(str, $1);
                strcat(str, "->left");
                $$.text = str;
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
                $$.type=pqr.c_str();
                char* str = (char*)malloc(strlen($1)+strlen("->right")+1);
                strcpy(str, $1);
                strcat(str, "->right");
                $$.text = str;
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
                $$.type=s.c_str();

                char* str = (char*)malloc(strlen($1)+strlen("->val")+1);
                strcpy(str, $1);
                strcat(str, "->val");
                $$.text = str;
        }
        ;

predicate: conditions {
                $$.type = $1.type;
                $$.text=$1.text;
        }
         ;

conditions: NEG conditions {
                $$.type = "bool";
                string str= "!(";
                str=str+$2.text+")";
                $$.text= str.c_str();
        }// Defining conditions production with possible types of conditions
          | condition cond {
                string s1=$2.type;
                if(s1 == "") {
                        $$.type = $1.type;        
                }
                else {
                        $$.type = $2.type;
                }
                char* str = (char*)malloc(strlen($1.text)+strlen($2.text)+1);
                strcpy(str, $1.text);
                strcat(str, $2.text);
                $$.text = str;
          }
          ;
          
cond: AND conditions {
                $$.type = "bool";
                string str = " && ";
                str=str+ $2.text;
                $$.text= str.c_str();
        }
    | OR conditions {
                $$.type = "bool";
                string str = " || ";
                str=str+ $2.text;
                $$.text= str.c_str();
        }
    | LOR conditions {
                $$.type= "bool";
                string str = " | ";
                str=str+ $2.text;
                $$.text= str.c_str();
        }
    | LAND conditions {
                $$.type = "bool";
                string str = " & ";
                str=str+ $2.text;
                $$.text= str.c_str();
        }
    | LXOR conditions {
                $$.type = "bool";
                string str = " ^ ";
                str=str+ $2.text;
                $$.text= str.c_str();
        }
    |  {
                $$.type = "";
                $$.text="";
        }
    ;       

condition: con_posm {
                $$.type = $1.type;
                $$.text=$1.text;
        }
         ;

con_posm: con_pos {

                $$.type = $1.type;
                $$.text=$1.text;
        }
        | con_pos ops con_pos {
                string ss1 = $1.type;
                string ss2 = $3.type;
                if(!(((ss1=="int")||(ss1=="float")||(ss1=="double")||(ss1=="long")||(ss1=="string")||(ss1=="char"))&&((ss2=="int")||(ss2=="float")||(ss2=="double")||(ss2=="long")||(ss2=="string")||(ss2=="char")))){
                                cout<<"Semantic Error at line number "<<yylineno<<": Invalid type for Relational Operations"<<endl;
                                exit(1); 
                        }
                        if(!compatibility($1.type, $3.type)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch"<<endl;
                                exit(1);
                        }
                        $$.type ="bool";
                        char* str = (char*)malloc(strlen($1.text)+strlen($3.text)+strlen($2.text)+strlen("  ")+1);
                        strcpy(str, $1.text);
                        strcat(str, " ");
                        strcat(str, $2.text);
                        strcat(str, " ");
                        strcat(str, $3.text);
                        $$.text = str;
        }
        | LPAR con_pos ops con_pos RPAR {
                string ss1 = $2.type;
                string ss2 = $4.type;
                   if(!(((ss1=="int")||(ss1=="float")||(ss1=="double")||(ss1=="long")||(ss1=="string")||(ss1=="char"))&&((ss2=="int")||(ss2=="float")||(ss2=="double")||(ss2=="long")||(ss2=="string")||(ss2=="char")))){
                                cout<<"Semantic Error at line number "<<yylineno<<": Invalid type for Relational Operations"<<endl;
                                exit(1); 
                        }
                        if(!compatibility($2.type, $4.type)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch"<<endl;
                                exit(1);
                        }
                        $$.type ="bool";

                        char* str = (char*)malloc(strlen($2.text)+strlen($3.text)+strlen($4.text)+strlen("  ()")+1);
                        strcat(str, "(");
                        strcpy(str, $2.text);
                        strcat(str, " ");
                        strcat(str, $3.text);
                        strcat(str, " ");
                        strcat(str, $4.text);
                        strcat(str, ")");
                        $$.text = str;
        }
        | LTRUE {
                $$.type = "bool";
                $$.text="true";
        }
        | LFALSE {
                $$.type= "bool";
                $$.text="false";
        }
        ;

ops: LT {
        $$.text="<";
        }// Defining comparison operators production with valid comparison operators allowed
   | GT {
        $$.text=">";
   }
   | GEQ {
         $$.text=">=";
   }
   | LEQ {
        $$.text="<=";
   }
   | NE {
        $$.text="!=";
   }
   | EQ {
        $$.text="==";
   }
   ;

con_pos: STRINGC {
                $$.type= "string";
                $$.text = $1;
        }
       | CHARC {
                $$.type= "char";
                $$.text = $1;
       }
       | acon_posm {
        $$.type=$1.type;
        $$.text=$1.text;
       }
       ;

acon_posm: acon_pos acond {
                string ss1=$2.type;
                string ss2=$1.type;
                if(ss1 == "") {
                        $$.type = $1.type;  

                }
                else {
                        if(!((ss2=="int"||ss2=="float"||ss2=="double"||ss2=="long")&&(ss1=="int"||ss1=="float"||ss1=="double"||ss1=="long"))){
                                cout<<"Semantic Error at line number "<<yylineno<<": Invalid type for Arithmetic Operations"<<endl;
                                exit(1); 
                        }
                        if(!compatibility($1.type, $2.type)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": Type Mismatch"<<endl;
                                exit(1);
                        }
                        $$.type = final_type($1.type, $2.type).c_str();
                }
                char* str = (char*)malloc(strlen($2.text)+strlen($1.text)+1);
                strcpy(str, $1.text);
                strcat(str, $2.text);
                $$.text = str;
        }
        ;

acond: aops acon_posm {
                $$.type = $2.type;

                char* str = (char*)malloc(strlen($2.text)+strlen($1.text)+strlen("  ")+1);
                strcpy(str, $1.text);
                 strcat(str, " ");
                strcat(str, $2.text);
                strcat(str, " ");
                $$.text = str;
        }
     | {
        $$.type = "";
        $$.text="";
     }
     ;

aops: ADD {
        $$.text="+";

        }// Defining comparison operators production with valid comparison operators allowed
    | SUB {
         $$.text="-";
    }
    | MUL {
        $$.text="*";
    }
    | DIV {
        $$.text="/";
    }
    | MOD {
        $$.text="%";
    }
    ;

acon_pos: ID {
        symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        $$.type=temp->type.c_str();
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
                $$.text=$1;
        }
        | DECIMAL {
                $$.type="long";
                $$.text=$1;
        }
        | FLOATING {
                $$.type="double";
                $$.text=$1;
        }
        | NUMBER {
                $$.type="long";
                $$.text=$1;
        } 
        | func_call {
                // string s1=$1.type;
                // if(s1 == "void"){
                //         cout<<"Semantic Error at line number "<<yylineno<<": Cannot do operations on void datatype"<<endl;
                //         exit(1);
                // }
                $$.type=$1.type;

                $$.text=$1.text;
        }
        | LPAR acon_posm RPAR {
                $$.type=$2.type;

                char* str = (char*)malloc(strlen($2.text)+strlen("()")+1);
                strcpy(str, "(");
                strcat(str, $2.text);
                strcat(str, ")");
                $$.text = str;
        }
        ;

func_call: ID LPAR call_args RPAR {
                funcTabEnt temp = search_functab_compat($1,0,call_list);
                if(!temp){
                        cout<<"Semantic Error at line number "<<yylineno<<": Function is not declared"<<endl;
                        exit(1);
                }
                $$.type = temp->ret_type.c_str();
                
                char* str = (char*)malloc(strlen($3.text)+strlen($1)+strlen("()")+1);
                strcpy(str, $1);
                strcat(str, "(");
                strcat(str, $3.text);
                strcat(str, ")");
                $$.text = str;
        }
        | ID LPAR RPAR {
                call_list.clear();
                funcTabEnt temp = search_functab_compat($1,0,call_list);
                if(!temp){
                        cout<<"Semantic Error at line number "<<yylineno<<": Function is not declared"<<endl;
                        exit(1);
                }
                string pqr = temp->ret_type;
                $$.type = pqr.c_str();
                
                char* str = (char*)malloc(strlen($1)+strlen("()")+1);
                strcpy(str, $1);
                strcat(str, "(");
                strcat(str, ")");
                $$.text = str;
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
                                
                                $$.type = var->ret_type.c_str();
                                call_list.clear();

                        }

                        char* sqr = (char*)malloc(strlen($1)+strlen($3)+strlen($5.text)+strlen("->()")+1);
                        strcpy(sqr, $1);
                        strcat(sqr, "->");
                        strcat(sqr, $3);
                        strcat(sqr, "(");
                        strcat(sqr, $5.text);
                        strcat(sqr, ")");
                        $$.text = sqr;
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
                                $$.type = var->ret_type.c_str();
                                call_list.clear();
                        }

                        char* sqr = (char*)malloc(strlen($1)+strlen($3)+strlen("->()")+1);
                        strcpy(sqr, $1);
                        strcat(sqr, "->");
                        strcat(sqr, $3);
                        strcat(sqr, "(");
                        strcat(sqr, ")");
                        $$.text = sqr;
         }
         ;

call_args: call_args COMMA predicate {
                        call_list.push_back($3.type);

                        char* sqr = (char*)malloc(strlen($1.text)+strlen($3.text)+strlen(", ")+1);
                        strcpy(sqr, $1.text);
                        strcat(sqr, ", ");
                        strcat(sqr, $3.text);
                        $$.text = sqr;
                }
         | predicate {
                        call_list.push_back($1.type);
                        $$.text=$1.text;
                }
         ;

init_args: init_args COMMA init_arg {
                char* sqr = (char*)malloc(strlen($1.text)+strlen($3.text)+strlen(", ")+1);
                strcpy(sqr, $1.text);
                strcat(sqr, ", ");
                strcat(sqr, $3.text);
                $$.text = sqr;
        }
         | init_arg {
                $$.text=$1.text;
         }
         ;

init_arg: inpt_rhs {init_list.push_back($1.type);
                        $$.text=$1.text;
                }
        | LNULL {init_list.push_back("null");
                        $$.text="NULL";
                }
        ;

assignment: ID EQUAL {
                        symTabEnt temp = search_symTab($1, scope);
                        if(!temp) {
                              cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                              exit(1);  
                        }
                        assn_idtype = temp->type;
                        fprintf(fir,"%s = ",$1);
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
                fprintf(fir,"%s->left = %s;\n",$1,$5);
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
                fprintf(fir,"%s->left = NULL;\n",$1);

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
                fprintf(fir,"%s->right = %s;\n",$1,$5);
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
                fprintf(fir,"%s->right = NULL;\n",$1);
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
                        if(!np_compat(s,$5.type)) {
                                cout<<"Semantic Error at line number "<<yylineno<<": LHS is not compatible"<<endl;
                                exit(1);
                        }
                }
                else {
                        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
                        exit(1);
                }
                fprintf(fir,"%s->val = %s;\n",$1,$5.text);
          }
          ;

s_marker: expr SEMICOLON {
                if(!compatibility($1.type, assn_idtype)) {
                        cout<<"Semantic Error at line number "<<yylineno<<": LHS and RHS types are not compatible"<<endl;
                        exit(1);
                }
                assn_idtype="";
                fprintf(fir,"%s;\n",$1.text);
        }

expr: inpt_rhs {
        $$.type=$1.type;
        $$.text=$1.text;
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
                                               $$.type = assn_idtype.c_str(); 
                                               
                                               char* sqr = (char*)malloc(strlen($2.text)+strlen(s.c_str())+strlen("new node<>{}")+1);
                                                strcpy(sqr,"new node<");
                                                strcat(sqr,f);
                                                strcat(sqr,">{");
                                                strcat(sqr, $2.text);
                                                strcat(sqr,"}");
                                                $$.text = sqr;
                                        }
                                        else {
                                                stemp = "BTree<" + s + ">";
                                                $$.type = stemp.c_str(); 

                                                char* sqr = (char*)malloc(strlen($2.text)+strlen(s.c_str())+strlen("new btree<>{}")+1);
                                                strcpy(sqr,"new btree<");
                                                strcat(sqr,f);
                                                strcat(sqr,">{");
                                                strcat(sqr, $2.text);
                                                strcat(sqr,"}");
                                                $$.text = sqr;
                                        }

                                }
                                else {
                                        stemp = "BTree<" + s + ">";
                                        $$.type = stemp.c_str();

                                        string pqr="{}";
                                        $$.text=pqr.c_str();
                                }
                                }
                        else if(((init_list[1]=="null") || (init_list[1] == ("Node<"+s+">"))) && ((init_list[2]=="null") || (init_list[2] == ("Node<"+s+">")))) {
                                stemp = "Node<" + s + ">";
                                $$.type = stemp.c_str();       

                                char* sqr = (char*)malloc(strlen($2.text)+strlen(s.c_str())+strlen("new node<>{}")+1);
                                strcpy(sqr,"new node<");
                                strcat(sqr,f);
                                strcat(sqr,">{");
                                strcat(sqr, $2.text);
                                strcat(sqr,"}");
                                $$.text = sqr;
                        }
                        else if(np_compat(s, init_list[1]) && np_compat(s, init_list[2])){
                                if(assn_idtype != "") {
                                        if(assn_idtype.substr(0, 6) == "BSTree") {
                                               $$.type = assn_idtype.c_str();

                                               char* sqr = (char*)malloc(strlen($2.text)+strlen(s.c_str())+strlen("new bstree<>{}")+1);
                                                strcpy(sqr,"new bstree<");
                                                strcat(sqr,s.c_str());
                                                strcat(sqr,">{");
                                                strcat(sqr, $2.text);
                                                strcat(sqr,"}");
                                                $$.text = sqr;
                                        }
                                        else {
                                                stemp = "BTree<" + s + ">";
                                                $$.type = stemp.c_str(); 

                                                char* sqr = (char*)malloc(strlen($2.text)+strlen(s.c_str())+strlen("new btree<>{}")+1);
                                                strcpy(sqr,"new btree<");
                                                strcat(sqr,s.c_str());
                                                strcat(sqr,">{");
                                                strcat(sqr, $2.text);
                                                strcat(sqr,"}");
                                                $$.text = sqr;
                                        }

                                }
                                else {
                                        stemp = "BTree<" + s + ">";
                                        $$.type = stemp.c_str();

                                        string pqr="{}";
                                        $$.text=pqr.c_str();                                     
                                }
                        }
                        else if(((init_list[1]=="null") || np_compat(s, init_list[1])) && ((init_list[2]=="null") || np_compat(s, init_list[2]))) {
                                stemp = "BTree<" + s + ">";
                                $$.type = stemp.c_str();
                                
                                char* sqr = (char*)malloc(strlen($2.text)+strlen(s.c_str())+strlen("new btree<>{}")+1);
                                strcpy(sqr,"new btree<");
                                strcat(sqr,s.c_str());
                                strcat(sqr,">{");
                                strcat(sqr, $2.text);
                                strcat(sqr,"}");
                                $$.text = sqr;
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
                                        $$.type = assn_idtype.c_str(); 

                                        char* sqr = (char*)malloc(strlen($2.text)+strlen(s.c_str())+strlen("new bstree<>{}")+1);
                                        strcpy(sqr,"new bstree<");
                                        strcat(sqr,s.c_str());
                                        strcat(sqr,">{");
                                        strcat(sqr, $2.text);
                                        strcat(sqr,"}");
                                        $$.text = sqr;
                                }
                                else {
                                        stemp = "BTree<" + s + ">";
                                        $$.type = stemp.c_str(); 

                                        char* sqr = (char*)malloc(strlen($2.text)+strlen(s.c_str())+strlen("new btree<>{}")+1);
                                        strcpy(sqr,"new btree<");
                                        strcat(sqr,s.c_str());
                                        strcat(sqr,">{");
                                        strcat(sqr, $2.text);
                                        strcat(sqr,"}");
                                        $$.text = sqr;                                 
                                }

                        }
                        else {
                                stemp = "BTree<" + s + ">";
                                $$.type = stemp.c_str();

                                string pqr="{}";
                                $$.text=pqr.c_str();
                        }
                }
                else {
                        stemp = "BTree<" + s + ">";
                        $$.type = stemp.c_str();   

                        char* sqr = (char*)malloc(strlen($2.text)+strlen(s.c_str())+strlen("new btree<>{}")+1);
                        strcpy(sqr,"new btree<");
                        strcat(sqr,s.c_str());
                        strcat(sqr,">{");
                        strcat(sqr, $2.text);
                        strcat(sqr,"}");
                        $$.text = sqr;
                }
        } 
        init_list.clear();
    }
    | ID INCR {
         symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        if(temp->type=="int" || temp->type=="long"||temp->type=="float" || temp->type=="double"){
                                $$.type=temp->type.c_str();
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

                char* sqr = (char*)malloc(strlen($1)+strlen("++")+1);
                strcpy(sqr,$1);
                strcat(sqr,"++");
                $$.text = sqr;
    }
    | ID DECR {
         symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        if(temp->type=="int" || temp->type=="long"||temp->type=="float" || temp->type=="double"){
                                $$.type=temp->type.c_str();
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
                char* sqr = (char*)malloc(strlen($1)+strlen("--")+1);
                strcpy(sqr,$1);
                strcat(sqr,"--");
                $$.text = sqr;
    }
    ;

expression: exprt SEMICOLON {
                fprintf(fir,"%s;\n",$1.text);
                p=true;
        }
        ;

exprt: inpt_rhs {$$.type=$1.type;
                $$.text=$1.text;
        }
     | ID INCR {
        symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        if(temp->type=="int" || temp->type=="long"||temp->type=="float" || temp->type=="double"){
                                $$.type=temp->type.c_str();
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
               char* sqr = (char*)malloc(strlen($1)+strlen("++")+1);
                strcpy(sqr,$1);
                strcat(sqr,"++");
                $$.text = sqr;
                
     }
     | ID DECR {
        symTabEnt temp = search_symTab($1, scope);
                if(temp) {
                        if(temp->type=="int" || temp->type=="long"||temp->type=="float" || temp->type=="double"){
                                $$.type=temp->type.c_str();
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
                char* sqr = (char*)malloc(strlen($1)+strlen("--")+1);
                strcpy(sqr,$1);
                strcat(sqr,"--");
                $$.text = sqr;
     }
     ;

conditional_stmt: f_marker
                | f_marker ELSE{scope++;
                 create_symtab(scope);
                 fprintf(fir,"else");} loop_block
                ;

f_marker: IF LPAR predicate RPAR {scope++;
                create_symtab(scope);
                fprintf(fir,"if(%s)",$3.text); } loop_block
        ;

loop_stmt: while_loop
         | for_loop
         ;

while_loop: while_marker LPAR predicate RPAR {fprintf(fir,"(%s)",$3.text);
        }loop_block {find_loop--;}
          ;

while_marker: WHILE {
           find_loop++;
           scope++;
           create_symtab(scope);
           fprintf(fir,"while");
         }
         ;
         
for_loop: for_marker LPAR for_f SEMICOLON predicate SEMICOLON for_l RPAR {fprintf(fir,"(%s;%s;%s)",$3.text,$5.text,$7.text);} loop_block {find_loop--;}
        |  for_marker LPAR for_f SEMICOLON predicate SEMICOLON  ID EQUAL t_marker RPAR {fprintf(fir,"(%s;%s;%s = %s)",$3.text,$5.text,$7,$9.text);} loop_block {find_loop--;}
        ;

for_marker: FOR {
           find_loop++;
           scope++;
           create_symtab(scope);
           fprintf(fir,"for");
         }
         ;
         
loop_block: LFB RFB {
                fprintf(fir,"{}\n");
                delete_symEnt(scope);
                scope--;
        } // Defining block production, both with empty block as well as with statements
     | LFB {fprintf(fir,"{\n");} loop_statements RFB {
                fprintf(fir,"}\n");
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
                                fprintf(fir,"break;\n");
         }
         | CONTINUE SEMICOLON {if(find_loop == 0) {
                                 cout<<"Semantic Error at line number "<<yylineno<<": Use of continue outside of loops"<<endl;
                                exit(1);       
                                }
                                fprintf(fir,"continue;\n");
         }
         | input_stmt
         | output_stmt
         | {scope++;
           create_symtab(scope);}loop_block
         ;

for_f: declaration {$$.text = $1.text;}
     | intialisation {$$.text = $1.text;}
     | for_f_marker t_marker {
        char* sqr = (char*)malloc(strlen($1.text)+strlen($2.text)+1);
        strcpy(sqr,$1.text);
        strcat(sqr,$2.text);
        $$.text = sqr;
     }
     ;

for_f_marker: ID EQUAL {
        symTabEnt temp = search_symTab($1, scope);
        if(!temp) {
        cout<<"Semantic Error at line number "<<yylineno<<": Use of undeclared variable"<<endl;
        exit(1);  
        }
        assn_idtype = temp->type;

        char* sqr = (char*)malloc(strlen($1)+strlen("  =")+1);
        strcpy(sqr,$1);
        strcat(sqr," = ");
        $$.text = sqr;
     } 
     ;

t_marker: expr {
        if(!compatibility($1.type, assn_idtype)) {
                cout<<"Semantic Error at line number "<<yylineno<<": LHS and RHS types are not compatible"<<endl;
                exit(1);
        }
        assn_idtype="";
        $$.text=$1.text;
     }

for_l: predicate {$$.text=$1.text;}
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
                char* sqr = (char*)malloc(strlen($1)+strlen("++")+1);
                strcpy(sqr,$1);
                strcat(sqr,"++");
                $$.text = sqr;
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
                char* sqr = (char*)malloc(strlen($1)+strlen("--")+1);
                strcpy(sqr,$1);
                strcat(sqr,"--");
                $$.text = sqr;
        }
     ;

return_stmt: RETURN predicate SEMICOLON {
                if(scope == 1) {
                        check_return = true;
                }
                if(!compatibility(ret_type,$2.type)) {
                        cout<<"Semantic Error at line number "<<yylineno<<": Return type mismatch"<<endl;
                        exit(1);
                }
                fprintf(fir,"return %s;\n",$2.text);
        }
           | RETURN SEMICOLON {
                if(scope == 1) {
                        check_return = true;
                }
                if(ret_type != "void") {
                        cout<<"Semantic Error at line number "<<yylineno<<": Return type mismatch"<<endl;
                        exit(1);
                }
                fprintf(fir,"return ;\n");
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
                fprintf(fir,"cin>>%s;\n",$3);
        }        
        ;

output_stmt: OUTPUT COLON print_posm SEMICOLON {
                fprintf(fir,"cout<<%s;\n",$3.text);
        }
           ;

print_posm: print_pos LL print_posm {
                char* sqr = (char*)malloc(strlen($1.text)+strlen($3.text)+strlen("<<")+1);
                strcpy(sqr,$1.text);
                strcat(sqr,"<<");
                strcat(sqr,$3.text);
                $$.text = sqr;
        }
          | print_pos {
                $$.text=$1.text;
          }
          ;

print_pos: predicate {
                $$.text=$1.text;
                }
         | END {
                $$.text="endl";
         }
         ;

%%
int yywrap(){
        return 0;
} // Defining yywrap function (no action required)

int main(int argc, char* argv[]) {
    fsread = fopen(argv[1], "r"); // Open the input file
    char s[20];
    sprintf(s, "seq_tokens_%c.txt", argv[1][0]);
    fswrite = fopen(s, "w"); // Open the token output file
    sprintf(s, "IR_%c.cpp", argv[1][0]);
    fir = fopen(s, "w");
    fprintf(fir,"#include <bits/stdc++.h>\n#include \"global_ir.hpp\"\n\nusing namespace ::std;\n\n");
    yyin = fsread; // Set the input file for the lexer
    yyparse(); // Start the parsing process
    fclose(fsread); // Close the input file
    fclose(fswrite); // Close the token output file
    fclose(fir);
    return 0;
}

void yyerror(const char* msg) {
        printf("Syntax Error  at \"%s\", line number : %d \n", yytext, yylineno); // Defining error handling for syntax errors
        exit(1);
}
