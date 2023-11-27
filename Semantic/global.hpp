#ifndef GLOBAL_HEADER
#define GLOBAL_HEADER 1
#include <bits/stdc++.h>
using namespace::std;

struct symbol_table_entry
{
    string name;
    string type;
    int level;
};

typedef struct symbol_table_entry symTabE;

typedef struct symbol_table_entry* symTabEnt;

struct func_table_entry
{
    string name;
    vector<string> param_list;
    string ret_type;
    bool built_in;
};

typedef struct func_table_entry funcTabE;

typedef struct func_table_entry* funcTabEnt;

extern int scope;
extern vector<string> vec;
extern vector<vector<symTabEnt>> symTab_list;
extern vector<funcTabEnt> funcTab;

#endif
