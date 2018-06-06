%{
#include <iostream>
#include <vector>
#include <string>
#include <fstream>

#include "parser.hpp"

std::vector<std::string> state_stack;
std::vector<std::string> var_stack;

bool _error = false;
std::string* statementStr;

void yyerror(YYLTYPE* loc, const char* err);
void save_variable(std::string var);
void save_statement(std::string statement);
void write_program();

extern int yylex();
%}

%union {
  float value;
  std::string* str;
  int token;
}

/* %define api.value.type { std::string* } */

%locations

%define parse.error verbose

%define api.pure full
%define api.push-pull push

%token <str> IDENTIFIER
%token <str> NUMBER
%token <str> EQUALS PLUS MINUS TIMES DIVIDEDBY
%token <str> LT GT EQ NEQ GTE LTE
%token <str> SEMICOLON LPAREN RPAREN NEWLINE COLON INDENT DEDENT COMMA
%token <str> BREAK WHILE IF ELIF ELSE AND DEF FOR NOT OR BOOL RETURN DONE

%type <str> program
%type <str> statement
%type <str> expression
%type <str> if_contents
%type <str> while_contents
%type <str> contents_inner
%type <str> condition
%type <str> compare
%type <str> item

%left LT GT EQ NEQ GTE LTE
%left PLUS MINUS
%left TIMES DIVIDEDBY

%start program

%%

program
  : program statement {
      statementStr = new std::string(*$2);
      save_statement(*statementStr); }
  | statement {
      statementStr = new std::string(*$1);
      save_statement(*statementStr); }
  ;

statement
  : IDENTIFIER EQUALS expression NEWLINE {
      $$ = new std::string(*$1 + " = " + *$3 + ";\n");
      save_variable(*$1); }
  | IF condition COLON NEWLINE INDENT if_contents DEDENT{
      $$ = new std::string("if (" + *$2 + ") {\n" + *$6 + "\n}\n"); }
  | WHILE condition COLON NEWLINE INDENT while_contents DEDENT {
      $$ = new std::string("while (" + *$2 + ") {\n" + *$6 + "}\n"); }
  | error NEWLINE {
      std::cerr << "Error: bad statement on line " << @1.first_line << std::endl;
      _error = true; }
  | DONE {
    if (!_error)
      write_program(); }
  ;

if_contents:
  | IDENTIFIER EQUALS expression NEWLINE if_contents {
      $$ = new std::string(*$1 + " = " + *$3 + ";\n" + *$5);
      save_variable(*$1);
      *$5 = "";
      }
  | IF condition COLON NEWLINE INDENT contents_inner DEDENT if_contents {
      $$ = new std::string("if (" + *$2 + ") {\n" + *$6 + "} " + *$8); }
  | ELSE COLON NEWLINE INDENT contents_inner DEDENT {
      $$ = new std::string("else {\n" + *$5 + "}"); }
  ;

while_contents:
  | IDENTIFIER EQUALS expression NEWLINE while_contents {
      $$ = new std::string(*$1 + " = " + *$3 + ";\n" + *$5);
      save_variable(*$1); }
  | IF condition COLON NEWLINE INDENT contents_inner DEDENT {
        $$ = new std::string("if (" + *$2 + ") {\n" + *$6 + "}\n"); }
  ;

contents_inner:
  | IDENTIFIER EQUALS expression NEWLINE {
      $$ = new std::string(*$1 + " = " + *$3 + ";\n");
      save_variable(*$1); }
  | BREAK NEWLINE { $$ = new std::string("break;\n"); }
  ;




expression
  : LPAREN expression RPAREN { $$ = new std::string("(" + *$2 + ")"); }
  | expression PLUS expression { $$ = new std::string(*$1 + " + " + *$3); }
  | expression MINUS expression { $$ = new std::string(*$1 + " - " + *$3); }
  | expression TIMES expression { $$ = new std::string(*$1 + " * " + *$3); }
  | expression DIVIDEDBY expression { $$ = new std::string(*$1 + " / " + *$3); }
  | NUMBER { $$ = new std::string(*$1); }
  | IDENTIFIER { $$ = new std::string(*$1); }
  | BOOL { $$ = new std::string(*$1); }
  ;

condition
  : IDENTIFIER { $$ = new std::string(*$1); }
  | IDENTIFIER compare item { $$ = new std::string(*$1 + *$2 + *$3); }
  | BOOL { $$ = new std::string(*$1); }
  ;

compare
  : LT { $$ = new std::string(" < "); }
  | LTE { $$ = new std::string(" <= "); }
  | GT { $$ = new std::string(" > "); }
  | GTE { $$ = new std::string(" >= "); }
  | EQ { $$ = new std::string(" == "); }
  | NEQ { $$ = new std::string(" != "); }
  ;

item
  : IDENTIFIER { $$ = new std::string(*$1); }
  | NUMBER { $$ = new std::string(*$1); }
  ;


%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error: " << err << std::endl;
}

void save_statement(std::string statement) {
  state_stack.push_back(statement);
}

void save_variable(std::string var) {
  std::vector<std::string>::iterator itr_v;
  for ( itr_v = var_stack.begin(); itr_v < var_stack.end(); ++itr_v )
  {
    if (*itr_v == var){
      return;
    }
  }
  var_stack.push_back(var);
}

void write_program(){
  std::cout << "Writing to file." << std::endl;
  // Open file
  std::ofstream myfile;
  myfile.open ("output_file.cpp");

  // Write header
  myfile << "#include <iostream>\n" ;
  myfile << "int main() {\n";

  // Write variables
  std::vector<std::string>::iterator itr_v;
  for ( itr_v = var_stack.begin(); itr_v < var_stack.end(); ++itr_v )
  {
    myfile << "double " + *itr_v + ";\n";
  }
  myfile << "\n";

  // Write statements
  std::vector<std::string>::iterator itr_s;
	for ( itr_s = state_stack.begin(); itr_s < state_stack.end(); ++itr_s )
	{
    myfile << *itr_s;
	}
  myfile << "\n\n";

  // Write prints
  std::vector<std::string>::iterator itr_p;
  for ( itr_p = var_stack.begin(); itr_p < var_stack.end(); ++itr_p )
  {
    myfile << "std::cout << \"" + *itr_p + ": \" << " + *itr_p + " << std::endl;\n";
  }
  myfile << "}";

  // Close file
  myfile.close();
}
