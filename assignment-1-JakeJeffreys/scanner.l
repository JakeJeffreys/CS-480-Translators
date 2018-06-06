%{
#include <cstdio>
#include <iostream>

using namespace std;

int indent_count = 0;

void handle_newline_with_indent(int input_length);
%}

%option noyywrap

DIGIT    [0-9]
LETTER   [a-zA-Z]

%%

[\n]+[ \t]* { handle_newline_with_indent(yyleng); }

[]#].*[\n]    /* Ignore comments */
[ ][^ ]     { yyless(1); }

"and"       { cout << "AND\t\t" << yytext << endl; }
"break"     { cout << "BREAK\t\t" << yytext << endl; }
"def"       { cout << "DEF\t\t" << yytext << endl; }
"elif"      { cout << "ELIF\t\t" << yytext << endl; }
"else"      { cout << "ELSE\t\t" << yytext << endl; }
"for"       { cout << "FOR\t\t" << yytext << endl; }
"if"        { cout << "IF\t\t" << yytext << endl; }
"not"       { cout << "NOT\t\t" << yytext << endl; }
"or"        { cout << "OR\t\t" << yytext << endl; }
"return"    { cout << "RETURN\t\t" << yytext << endl; }
"while"     { cout << "WHILE\t\t" << yytext << endl; }
"True"|"False"  {
                  cout << "BOOLEAN\t\t";
                  string temp = yytext;
                  if (temp == "True"){
                    cout << "1" << endl;
                  } else if (temp == "False"){
                    cout << "0" << endl;
                  }
                }

({LETTER}|"_")+({LETTER}|{DIGIT}|"_")*  { cout << "IDENTIFIER\t" << yytext << endl; }

-?{DIGIT}*"."{DIGIT}* { cout << "FLOAT\t\t" << yytext << endl; }
-?{DIGIT}+  { cout << "INTEGER\t\t" << yytext << endl; }

"="         { cout << "ASSIGN\t\t" << yytext << endl; }
"+"         { cout << "PLUS\t\t" << yytext << endl; }
"-"         { cout << "MINUS\t\t" << yytext << endl; }
"*"         { cout << "TIMES\t\t" << yytext << endl; }
"/"         { cout << "DIVIDEDBY\t" << yytext << endl; }

"=="        { cout << "EQ\t\t" << yytext << endl; }
"!="        { cout << "NEQ\t\t" << yytext << endl; }
">"         { cout << "GT\t\t" << yytext << endl; }
">="        { cout << "GTE\t\t" << yytext << endl; }
"<"         { cout << "LT\t\t" << yytext << endl; }
"<="        { cout << "LTE\t\t" << yytext << endl; }

","         { cout << "COMMA\t\t" << yytext << endl; }
";"         { cout << "SEMICOLON\t\t" << yytext << endl; }
":"         { cout << "COLON\t\t" << yytext << endl; }
"("         { cout << "LPAREN\t\t" << yytext << endl; }
")"         { cout << "RPAREN\t\t" << yytext << endl; }

%%

int main() {
  yylex();
}

void handle_newline_with_indent(int input_length){
  cout << "NEWLINE" << endl;

  int current_indent = input_length / 4;
  int difference = current_indent - indent_count;

  if (current_indent > indent_count) {
    for ( int a=0 ; a<abs(difference) ; a++)
      cout << "INDENT" << endl;
  } else if (current_indent < indent_count) {
    for ( int a=0 ; a<abs(difference) ; a++)
      cout << "DEDENT" << endl;
  } else {
    /* Do nothing */
  }

  indent_count = current_indent;
}
