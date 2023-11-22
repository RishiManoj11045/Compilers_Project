#include "funcs.hpp"

// extern int scope;
// extern vector<string> vec;
// extern vector<vector<symTabEnt>> symTab_list;
// extern vector<funcTabEnt> funcTab;

using namespace std;

void create_symtab(int scope) {
    if(symTab_list.size() < scope+1) {
        vector<symTabEnt> temp_Tab;
        symTab_list.push_back(temp_Tab);
    }
}

void insert_symTab(string name,string type ,int scope){
    if(symTab_list.size() < scope+1) {
        vector<symTabEnt> temp_Tab;
        symTab_list.push_back(temp_Tab);
    }
    symTabEnt temp = new symTabE;
    temp->name = name;
    temp->type = type;
    temp->level = scope;
    symTab_list[scope].push_back(temp);
}

symTabEnt search_symTab(string name,int scope){
    cout<<name<<" "<<scope<<endl;
    cout<<"sumtab size"<<symTab_list.size()<<endl;
    // if(scope >= symTab_list.size()) {
    //     scope--;
    // }
    for(int i=scope; i>=0; i--) {
        for(auto j: symTab_list[i]) {
            if(name == j->name) {
                return j;
            }
        }
    }
    cout<<"sumtab size"<<symTab_list.size()<<endl;
    return NULL;
}

symTabEnt search_symTab_scope(string name,int scope){
    cout<<name<<" "<<scope<<endl;
    cout<<"sumtab size"<<symTab_list.size()<<endl;
    // if(scope >= symTab_list.size()) {
    //     scope--;
    // }
    for(auto j: symTab_list[scope]) {
        if(name == j->name) {
            return j;
        }
    }
    cout<<"sumtab size"<<symTab_list.size()<<endl;
    return NULL;
}
void delete_symEnt(int scope){
    if(scope < symTab_list.size()) {
        for(auto i: symTab_list[scope]) {
            delete i;
        }
    }
    if(scope < symTab_list.size() && symTab_list.size() != 0) {
        symTab_list.pop_back();
    }
}


void insert_functab(string name,bool built_in,vector<string> param_list,string ret_type){
    funcTabEnt temp = new funcTabE;
    temp->name = name;
    temp->param_list = param_list;
    temp->ret_type = ret_type;
    temp->built_in = built_in;
    funcTab.push_back(temp);
}

funcTabEnt search_functab(string name,bool built_in,vector<string> param_list){
    for(auto i: funcTab) {
        if(i->name == name) {
            if(i->built_in == built_in){
                if(i->param_list == param_list) {
                    return i;
                }
            }
        }
    }
    return NULL;
}


funcTabEnt search_functab_compat(string name,bool built_in,vector<string> param_list){
    for(auto i: funcTab) {
        if(i->name == name) {
            if(i->built_in == built_in){
                bool a = true;
                for(int j=0; j<param_list.size(); j++) {
                    if(!compatibility(i->param_list[j], param_list[j])) {
                        a = false;
                        break;
                }
                }if(a) {
                    return i;
            }
            }
        }
    }
    return NULL;
}

funcTabEnt search_functab_builtin(string name,bool built_in,vector<string> param_list, string pt_allowed){
    for(auto i: funcTab) {
        if(i->name == name) {
            if(i->built_in == 1){
                if((i->name == "bfs") || (i->name == "dfs") || (i->name == "inorder") || (i->name == "preorder") || (i->name == "postorder")) {
                    if(i->param_list.size() == 0) {
                        return i;
                    }
                }
                else if((i->name == "mergeBTree") || (i->name == "mergeBSTree")) {
                    if(param_list.size() == 2 && param_list[0]==param_list[1]) {

                        funcTabEnt temp = new funcTabE;
                        temp->name = i->name;
                        temp->built_in = i->built_in;
                        temp->param_list = i->param_list;
                        temp->ret_type = param_list[0];
                        return temp;
                    }
                }
                else if(i-> name == "search") {
                    if(param_list.size()==1 && param_list[0].substr(0, 4)=="Node" ) {
                        size_t start = param_list[0].find('<');
                        size_t end = param_list[0].find('>');
                        string s= param_list[0].substr(start+1,end-start-1);
                        if(s != pt_allowed) {
                            cout<<"Semantic Error at line number "<<yylineno<<": Argument and Caller value types mismatch"<<endl;
                            exit(1);
                        }
                        funcTabEnt temp = new funcTabE;
                        temp->name = i->name;
                        temp->built_in = i->built_in;
                        temp->param_list = i->param_list;
                        temp->ret_type = param_list[0];
                        return temp;
                    }
                    
                }
                else if(i-> name == "insert") {
                    if(param_list.size()==1 && param_list[0].substr(0, 4)=="Node") {
                        size_t start = param_list[0].find('<');
                        size_t end = param_list[0].find('>');
                        string s= param_list[0].substr(start+1,end-start-1);
                        if(s != pt_allowed) {
                            cout<<"Semantic Error at line number "<<yylineno<<": Argument and Caller value types mismatch"<<endl;
                            exit(1);
                        }
                        return i;
                    }
                }
                else if(i-> name == "delete") {
                    if(param_list.size()==1 && param_list[0].substr(0, 4)=="Node") {
                        size_t start = param_list[0].find('<');
                        size_t end = param_list[0].find('>');
                        string s= param_list[0].substr(start+1,end-start-1);
                        if(s != pt_allowed) {
                            cout<<"Semantic Error at line number "<<yylineno<<": Argument and Caller value types mismatch"<<endl;
                            exit(1);
                        }
                        funcTabEnt temp = new funcTabE;
                        temp->name = i->name;
                        temp->built_in = i->built_in;
                        temp->param_list = i->param_list;
                        temp->ret_type = param_list[0];
                        return temp;
                    }
                }
            }
            }
        }
    return NULL;
}

bool compatibility(string a,string b){
    if(a == b) {
        return true;
    }
    if(( a=="int" || a=="float" || a=="bool" || a == "long" || a=="double" ) && ( b=="int" || b=="float" || b=="bool" || b == "long" || b=="double" ) ){
        return true;
    }
    return false;
}

string final_type(string a ,string b){
    if(a==b) return a;
    string temp ;
    if(( a == "double" || b == "double")){
        temp="double";
    }
    else if(( a == "float" || b == "float" )){
        temp="float";
    }
    else if(( a == "long" || b == "long")){
        temp="long";
    }
    else if (( a == "int" || b == "int")){
        temp="int";
    }
    else temp="bool";
    return temp;
} 

bool np_compat(string a,string b){
    if(a==b ) return true;
    if(b.substr(0,4) == "Node" || b.substr(0,5) == "BTree" ||  b.substr(0,6) == "BSTree" ){
        return false;
    }
    if(a == "double" && !( b == "char" || b == "string" )) {
        if(b!="bool") return true;
    }
    
    if(a == "float" && !( b == "char" || b == "string" )) {
        if(b=="int" || b=="long" || b=="double") return true;
        else return false;
    }
    if(a=="long" && !( b == "char" || b == "string" )) {
        if(b=="int") return true;
        else return false;
    }
    if(a=="int" && !( b == "char" || b == "string" )) {
        if(b=="long") return true;
    }
    if(a=="bool" && !( b == "char" || b == "string" )){
        if(b!="bool") return false;
    }
    if(a=="char") {
        if(b!="char") return false;
    }
    if(a=="string"){
        if(b!="string") return false;
    }
    return false;
}


string bt_final_type(string a,string b){
    if(a==b ) return a;
    
    if(a == "double" && !( b == "char" || b == "string" )) {
        return a;
    }
    
    if(a == "float" && !( b == "char" || b == "string" )) {
       if(b == "double") {
        return b;
       }
       else if(b=="int" || b=="long"){
        return a;
       }
    }
    if(a=="long" && !( b == "char" || b == "string" )) {
        if(b=="double" || b=="float") {
            return b;
        }
        else if(b == "int") {
            return a;
        }
    }
    if(a=="int" && !( b == "char" || b == "string" )) {
        if(b=="double" || b=="float" || b=="long") {
            return b;
        }
    }
    string s = "";
    return s;
}




