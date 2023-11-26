#ifndef FUNC_HEADER
#define FUNC_HEADER 1

#include "global.hpp"

// extern int scope;
// extern vector<string> vec;
// extern vector<vector<symTabEnt>> symTab_list;
// extern vector<funcTabEnt> funcTab;
extern int yylineno;
extern char* yytext;

void create_symtab(int scope);

symTabEnt search_symTab_scope(string name ,int scope);

void insert_symTab(string name,string type ,int scope);

symTabEnt search_symTab(string name,int scope);

void delete_symEnt(int scope);

void insert_functab(string name,bool built_in, vector<string> param_list,string ret_type);

funcTabEnt search_functab(string name,bool built_in, vector<string> param_list);

funcTabEnt search_functab_builtin(string name,bool built_in,vector<string> param_list,string pt_allowed);

funcTabEnt search_functab_compat(string name,bool built_in,vector<string> param_list);

bool compatibility(string a,string b);

string final_type(string a ,string b);

bool np_compat(string a,string b);

string bt_final_type(string a,string b);

#endif