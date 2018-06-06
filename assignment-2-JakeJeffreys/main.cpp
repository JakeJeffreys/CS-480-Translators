#include <iostream>
#include <map>
#include <vector>
#include <fstream>

extern int yylex();

extern std::vector<std::string> saved_program;
extern bool _error;
extern std::string statementStr;

int main(int argc, char const *argv[]) {

  yylex();

  if (!_error) {
    std::cout << "No Errors." << std::endl;
    return 0;
  } else {
    std::cout << "Error! Will not create file." << std::endl;
    return 1;
  }
}
