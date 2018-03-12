#include <iostream>
#include <set>
#include <vector>
#include <queue>
#include <utility>
#include <algorithm>

using std::cout;
using std::endl;
using std::queue;
using std::string;
using std::set;
using std::to_string;
using std::vector;
using std::ios;
using std::make_pair;
using std::pair;
using std::find_if;
using std::ofstream;

#include <iostream>
#include "Node.h"
#include <fstream>

extern int yylex();
extern bool _error;
extern Node *rootTree;
extern set<string> symbols;
extern vector<Node*> dels;

//used for generating unique names for graphviz
int branch = 0;

/*
    * Return a string nx where x is the new branch number
*/
string getUID(){
    branch++;
    return ("n" + to_string(branch) + " ");
}

/*
    * If the node is a terminal, then make its shape a box
    * If the node is a non-termial, keep the shape a circle
*/
string getDeclaration(Node *cur, string name){
    if(cur->terminal){
        string tmp = " [shape=box,label=\"" + cur->name + "\"]\n";
        name.append(tmp);
    }
    else{
        string tmp = " [label=\"" + cur->name + "\"]\n";
        name.append(tmp);
    }
    return name;
}

/*
    * Breadth First Search through the parse tree.
    * At each level, create the new node's graphviz label
      and then generate name for the children and create connections
      to them. Finally, explore the children
*/
void bfs(Node *root, ofstream &gv){
    queue< pair<Node*, string> > que;
    que.push(make_pair(root, "n0 ") );
    set<Node*> visited;

    while(!que.empty()){
        pair<Node*, string> cur = que.front();
        que.pop();
        if(cur.first != NULL){
            visited.insert(cur.first);
            //set the label like n0 [label="Block"];
            gv << getDeclaration(cur.first, cur.second); 
            for(int i = 0; i < cur.first->children.size(); i++){
                //Go through all children and develop n0 -> n1 connections
                if(visited.find(cur.first->children[i]) == visited.end()){
                    if(cur.first->children[i] != NULL){
                        string newName = getUID();
                        gv << cur.second << " -> " << newName << "\n";
                        //push children and their names onto the queue
                        que.push(make_pair(cur.first->children[i], newName));
                    }
                }
            }
            //delete the node;
            delete cur.first;
        }
    }
}

/*
    * Post order traversal to delete all Nodes
    * This is used if there is an error, if no error,
      then nodes are deleted in bfs() above
*/
void postOrderDelete(Node *root){
    if(root){
        for(int i = 0; i < root->children.size(); i++){
            postOrderDelete(root->children[i]);
        }
        delete root;
    }
}

int main(int argc, char const *argv[]) {
    yylex();
    if (!_error){
        ofstream gv;
        gv.open ("output.gv", ios::out | ios::trunc);
        if(gv.is_open()){
            gv << "digraph G {\n";
            bfs(rootTree, gv);
            gv << "}";
            gv.close();
        }
        return 0;
    }
    //error, but still need to clean up Heap
    postOrderDelete(rootTree);
    return 1;
}  