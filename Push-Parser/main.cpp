#include <iostream>
#include <map>
#include <vector>
#include <algorithm>

using std::cout;
using std::endl;
using std::string;
using std::map;
using std::vector;
using std::find_if;

#include <iostream>

extern int yylex();
extern bool _error;
extern string entireProg;
extern map<string, string> symbols;
extern vector<string*> dels;

void delMap(){
    vector<string*>::iterator vecIT;
    for (vecIT = dels.begin(); vecIT != dels.end(); vecIT++) {
        if(*vecIT != NULL){
            delete *vecIT;
        }
    }
}

int main(int argc, char const *argv[]) {
    yylex();
    if (!_error){
        string result = "\n#include <iostream>\nusing namespace std;\n\nint main(){\n";
        map<string, string>::iterator it;
        result.append("\n\n/*Defintions*/\n");        
        
        for (it = symbols.begin(); it != symbols.end(); it++) {
            result.append("double " + it->first + ";\n");
        }
        result.append("\n/*Beginning of Program*/\n");
        result.append(entireProg);
        result.append("\n\n/*End of Program*/\n");
        
        for (it = symbols.begin(); it != symbols.end(); it++) {
            result.append("cout << \"" + it->first + ": \" << " + it->first + " << endl;\n");
        }
        result.append("return 0;\n}");
        
        cout << result; 
        delMap();      
        return 0;
    } 
    delMap();          
    return 1;
}  