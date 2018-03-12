#ifndef NODE_H
#define NODE_H

#include <vector>
#include <string>

struct Node{
	std::string name;
	bool terminal;
	std::vector<Node*> children;

	Node(std::string nm, bool term) : name(nm), terminal(term), children(std::vector<Node*>()) {}
};

#endif