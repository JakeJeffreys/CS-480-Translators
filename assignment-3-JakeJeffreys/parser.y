%{
#include <iostream>
#include <set>
#include <vector>
#include <sstream>
#include <string>

#include "parser.hpp"

extern int yylex();
void yyerror(YYLTYPE* loc, const char* err);
std::string* translate_boolean_str(std::string* boolean_str);
ASTnode* rootNode = new ASTnode(new std::string("Block"));

/*
 * Here, target_program is a string that will hold the target program being
 * generated, and symbols is a simple symbol table.
 */
std::string* target_program;
std::set<std::string> symbols;

std::vector<int> currentName (1, 0);
std::vector<int> gLabelIndex (15, 0);
int previousLevel = 0;


%}

%code requires{
  #include "AST.hpp"
}


/* Enable location tracking. */
%locations

/*
 * All program constructs will be represented as strings, specifically as
 * their corresponding C/C++ translation.
 */
/* %define api.value.type { ASTnode* } */

/*
 * Because the lexer can generate more than one token at a time (i.e. DEDENT
 * tokens), we'll use a push parser.
 */
%define api.pure full
%define api.push-pull push

/*
 * These are all of the terminals in our grammar, i.e. the syntactic
 * categories that can be recognized by the lexer.
 */
 %union {
   std::string* str;
   ASTnode* ast;
 }

 %token <str> IDENTIFIER
 %token <str> FLOAT INTEGER BOOLEAN
 %token <str> INDENT DEDENT NEWLINE
 %token <str> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
 %token <str> ASSIGN PLUS MINUS TIMES DIVIDEDBY
 %token <str> EQ NEQ GT GTE LT LTE
 %token <str> LPAREN RPAREN COMMA COLON
 %type <ast> program statements statement primary_expression negated_expression expression assign_statement
 %type <ast> block condition if_statement elif_blocks else_block while_statement break_statement

/*
 * Here, we're defining the precedence of the operators.  The ones that appear
 * later have higher precedence.  All of the operators are left-associative
 * except the "not" operator, which is right-associative.
 */
%left OR
%left AND
%left PLUS MINUS
%left TIMES DIVIDEDBY
%left EQ NEQ GT GTE LT LTE
%right NOT

/* This is our goal/start symbol. */
%start program

%%

/*
 * Each of the CFG rules below recognizes a particular program construct in
 * Python and creates a new string containing the corresponding C/C++
 * translation.  Since we're allocating strings as we go, we also free them
 * as we no longer need them.  Specifically, each string is freed after it is
 * combined into a larger string.
 */
program
  : statements { rootNode->addMultiNodes($1->nodes); }
  ;

statements
  : statement { $$ = new ASTnode(new std::string("Temp")); $$->addNode($1); }
  | statements statement { $$ = new ASTnode(new std::string("Temp")); $$->addMultiNodes($1->nodes); $$->addNode($2); }
  ;

statement
  : assign_statement { $$ = $1; }
  | if_statement { $$ = $1; }
  | while_statement { $$ = $1; }
  | break_statement { $$ = $1; }
  ;

primary_expression
  : IDENTIFIER {
      std::stringstream ss;
      std::string * temp = new std::string("Identifier: ");
      ss << *temp << *$1;
      std::string * s = new std::string(ss.str());
      $$ = new ASTnode(s);
    }
  | FLOAT {
      std::stringstream ss;
      std::string * temp = new std::string("Float: ");
      ss << *temp << *$1;
      std::string * s = new std::string(ss.str());
      $$ = new ASTnode(s);
    }
  | INTEGER {
      std::stringstream ss;
      std::string * temp = new std::string("Integer: ");
      ss << *temp << *$1;
      std::string * s = new std::string(ss.str());
      $$ = new ASTnode(s);
    }
  | BOOLEAN {
      std::stringstream ss;
      std::string * temp = new std::string("Boolean: ");
      ss << *temp << *translate_boolean_str($1);
      std::string * s = new std::string(ss.str());
      $$ = new ASTnode(s);
     }
  | LPAREN expression RPAREN { $$ =  $2; }
  ;

negated_expression
  : NOT primary_expression { /* Not used */ }
  ;

expression
  : primary_expression { $$ = $1; }
  | negated_expression { $$ = $1; }
  | expression PLUS expression { $$ = new ASTnode(new std::string("PLUS")); $$->addNode($1); $$->addNode($3); }
  | expression MINUS expression { $$ = new ASTnode(new std::string("MINUS")); $$->addNode($1); $$->addNode($3); }
  | expression TIMES expression { $$ = new ASTnode(new std::string("TIMES")); $$->addNode($1); $$->addNode($3); }
  | expression DIVIDEDBY expression { $$ = new ASTnode(new std::string("DIVIDEBY")); $$->addNode($1); $$->addNode($3); }
  | expression EQ expression { $$ = new ASTnode(new std::string("EQ")); $$->addNode($1); $$->addNode($3); }
  | expression NEQ expression { $$ = new ASTnode(new std::string("NEQ")); $$->addNode($1); $$->addNode($3); }
  | expression GT expression { $$ = new ASTnode(new std::string("GT")); $$->addNode($1); $$->addNode($3); }
  | expression GTE expression { $$ = new ASTnode(new std::string("GTE")); $$->addNode($1); $$->addNode($3); }
  | expression LT expression { $$ = new ASTnode(new std::string("LT")); $$->addNode($1); $$->addNode($3); }
  | expression LTE expression { $$ = new ASTnode(new std::string("LTE")); $$->addNode($1); $$->addNode($3); }
  ;

assign_statement
  : IDENTIFIER ASSIGN expression NEWLINE {
    $$ = new ASTnode(new std::string("Assignment"));

    std::stringstream ss;
    std::string * temp = new std::string("Identifier: ");
    ss << *temp << *$1;
    std::string * s = new std::string(ss.str());
    ASTnode* tempNode = new ASTnode(s);

    $$->addNode(tempNode); $$->addNode($3); }
  ;

block
  : INDENT statements DEDENT { $$ = new ASTnode(new std::string("Block")); $$->addMultiNodes($2->nodes); }
  ;

condition
  : expression { $$ = $1; }
  | condition AND condition { $$ = new ASTnode(new std::string("AND")); $$->addNode($1); $$->addNode($3); }
  | condition OR condition { $$ = new ASTnode(new std::string("OR")); $$->addNode($1); $$->addNode($3); }
  ;

if_statement
  : IF condition COLON NEWLINE block elif_blocks else_block { $$ = new ASTnode(new std::string("If")); $$->addNode($2); $$->addNode($5);
  if($6){ $$->addNode($6); }; if($7){ $$->addNode($7); }; }
  ;

elif_blocks
  : %empty { $$ = NULL; }
  | elif_blocks ELIF condition COLON NEWLINE block { $$ = new ASTnode(new std::string("Elif")); $$->addNode($1); $$->addNode($3); $$->addNode($6); }
  ;

else_block
  : %empty { $$ = NULL; }
  | ELSE COLON NEWLINE block { $$ = $4;}


while_statement
  : WHILE condition COLON NEWLINE block { $$ = new ASTnode(new std::string("While")); $$->addNode($2); $$->addNode($5); }
  ;

break_statement
  : BREAK NEWLINE { $$ = new ASTnode(new std::string("Break")); }
  ;

%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error (line " << loc->first_line << "): " << err << std::endl;
}

/*
 * This function translates a Python boolean value into the corresponding
 * C++ boolean value.
 */
std::string* translate_boolean_str(std::string* boolean_str) {
  if (*boolean_str == "True") {
    return new std::string("1");
  } else {
    return new std::string("0");
  }
}
