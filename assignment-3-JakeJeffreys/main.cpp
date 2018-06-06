#include <iostream>
#include <set>
#include "parser.hpp"

extern int yylex();

extern std::string* target_program;
extern std::set<std::string> symbols;
extern ASTnode* rootNode;


int main() {
  if (!yylex()) {

    std::ofstream graphFile;
    graphFile.open ("OUTPUT.gv");
    graphFile << "digraph G {\n";
    graphFile.close();

    rootNode->printTree(0);

    graphFile.open ("OUTPUT.gv", std::ios::app);
    graphFile << "}\n";
    graphFile.close();

    delete rootNode;
    rootNode = NULL;

  }
}
