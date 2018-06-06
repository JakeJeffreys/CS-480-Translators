#include <vector>
#include <iostream>
#include <fstream>

extern std::vector<int> currentName;
extern std::vector<int> gLabelIndex;
extern int previousLevel;

class ASTnode {
  public:
    std::string* value;
    std::vector <ASTnode*> nodes;
    std::vector <int> labelIndex;

    ASTnode(std::string* n){ value = n; }
    void addNode(ASTnode* node){ nodes.push_back(node); }
    void addMultiNodes(std::vector<ASTnode*> children){
      for ( int i = 0 ; i < children.size() ; i++ ){
        nodes.push_back(children[i]);
      }
    }
    void printTree(int level) {

      for (int i = 1; i < level; i++) {
          std::cout << "\t";
      }


      std::cout << *value << " | (" << level << ") ";

      if (level > previousLevel){
        currentName.push_back(0);
        gLabelIndex[currentName.size()-1]++;
      } else if (level < previousLevel) {
        while (currentName.size() != level+1){
          gLabelIndex[currentName.size()-1] = 0;
          currentName.pop_back();
        }
        gLabelIndex[level]++;
      } else {
        currentName[level]++;
        gLabelIndex[level]++;
      }

      // Save index to node instance
      labelIndex = gLabelIndex;
      while (labelIndex[labelIndex.size()] <= 0 || labelIndex[labelIndex.size()]> 100){
        labelIndex.pop_back();
      }

      // Create graph file
      std::ofstream graphFile;
      graphFile.open ("OUTPUT.gv", std::ios::app);

      // Initialize nodes
      graphFile << "\tn";
      for(int a = 0 ; a <= labelIndex.size() ; a++){
        graphFile << labelIndex[a] << "_";
      }
      graphFile << " [label=\"" << *value << "\"];\n";

      // Initialize arrows
      if(labelIndex[1] != 0){
        graphFile << "\tn";
        for(int a = 0 ; a <= labelIndex.size()-1 ; a++){
          graphFile << labelIndex[a] << "_";
        }
        graphFile << " -> n";
        for(int a = 0 ; a <= labelIndex.size() ; a++){
          graphFile << labelIndex[a] << "_";
        }
        graphFile << ";\n";
      }

      graphFile.close();

      // Print labelindex
      for (int l=0 ; l<=labelIndex.size() ; l++){
        std::cout << labelIndex[l] << ",";
      }
      std::cout << "\n";

      // Save previous level
      previousLevel = level;

      // Recursion
      for (int j = 0 ; j < nodes.size() ; j++ ){
          nodes[j]->printTree(level + 1);
      }


    }

  ~ASTnode(){};
};
