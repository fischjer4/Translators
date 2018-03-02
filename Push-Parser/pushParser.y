%{
/****
	 Prologue
****/
	#include <iostream>
	#include <string>
	#include <map>
	#include <vector>

	using std::cout;
	using std::endl;
	using std::vector;
	using std::string;
	using std::cerr;
	using std::map;
	using std::vector;
	using std::to_string;

	#include "pushParser.hpp"
	
	map<string, string> symbols;
	vector<string*> dels;
	bool _error = false;
	string entireProg = "";

	void yyerror(YYLTYPE* loc, const char* err);
	extern int yylex();
%}
/****
	 Declarations
****/
%union {
	float flt;
	std::string* str;
	int integer;
	bool logic;
}

%locations

%define parse.error verbose
%define api.pure full
%define api.push-pull push

/*Define the types of the terminals */
/*type*/
%token <logic> 	 BOOLEAN
%token <integer> INTEGER
%token <flt>	 FLOAT

/*constructs*/
%token <str> 	 BREAK DEF ELIF ELSE FOR IF RETURN WHILE
/*operand*/
%token <str> 	 IDENTIFIER	
/*math operators*/
%token <str> 	 PLUS MINUS TIMES DIVIDEDBY ASSIGN
/*logic operators*/
%token <str> 	 EQ AND OR NEQ NOT GT GTE LT LTE
/*symbols*/
%token <str> 	 LPAREN RPAREN COMMA COLON NEWLINE DEDENT INDENT

%type <str> 	expression assnStmt ifThenElseStmt whileStmt breakStmt elifStmt program stmt masterProgram
/*Define the types of the Non-terminals */

/*Define the precidence and associativty of operators*/
%left 			 PLUS MINUS
%left 			 TIMES DIVIDEDBY

/*Define the start symbol*/
%start 			 masterProgram 
/****
	 Rules Below
****/
%%
	masterProgram 		: program {entireProg.append(*$1);} 
	;
	
	program : 	program stmt	{
									string *toPrint = new string(*$1 + *$2);
									dels.push_back(toPrint);
									$$ = toPrint;
								}
				| stmt
	;

	stmt : 	 ifThenElseStmt 	
			| whileStmt			
			| breakStmt 	  
			| assnStmt 		 	
			| error NEWLINE {std::cerr << "Error: bad statement on line " << @1.first_line << endl; _error = true; }
	;


	expression : 	  LPAREN expression RPAREN 			{
															string *toPrint = new string("(" + *$2 + ")"); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $1;
															delete $3;
														}
					| expression PLUS expression 		{
															string *toPrint = new string(*$1 + " + " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| expression MINUS expression		{
															string *toPrint = new string(*$1 + " - " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| expression TIMES expression 		{
															string *toPrint = new string(*$1 + " * " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| expression DIVIDEDBY expression	{
															string *toPrint = new string(*$1 + " / " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| expression GT expression			{
															string *toPrint = new string(*$1 + " > " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| expression GTE expression			{
															string *toPrint = new string(*$1 + " >= " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| expression LT expression			{
															string *toPrint = new string(*$1 + " < " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| expression LTE expression			{
															string *toPrint = new string(*$1 + " <= " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| expression EQ expression 			{
															string *toPrint = new string(*$1 + " == " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| expression AND expression			{
															string *toPrint = new string(*$1 + " && " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| expression OR expression			{
															string *toPrint = new string(*$1 + " || " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| expression NEQ expression			{
															string *toPrint = new string(*$1 + " != " + *$3); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $2;
														}
					| NOT expression					{
															string *toPrint = new string("!" + *$2); 
															dels.push_back(toPrint); 
															$$ = toPrint;
															delete $1;
														}
					| INTEGER							{
															string *t = new string(to_string($1)); 
															dels.push_back(t); 
															$$ = t;
														}
					| FLOAT								{
															string *t = new string(to_string($1)); 
															dels.push_back(t); 
															$$ = t;
														}
					| BOOLEAN							{
															string *toPrint = new string(($1 == true ? "true" : "false")); 
															dels.push_back(toPrint); 
															$$ = toPrint;
														}
					| IDENTIFIER 						{
															if (symbols.count(*$1)) {
																string *toPrint = new string(*$1);
																dels.push_back(toPrint);
																$$ = toPrint;
															}
															else {
																std::cerr << "Error: unknown symbol " << *$1 << " at line " << @1.first_line << endl;
																_error = true;
																YYERROR;
															}
															delete $1;
														}
					;						


	assnStmt : IDENTIFIER ASSIGN expression NEWLINE {
														symbols[*$1] = *$3; 
														string *toPrint = new string(*$1 + " = " + symbols[*$1] + ";\n"); 
														dels.push_back(toPrint); 
														$$ = toPrint;
														delete $1;
														delete $2;
														delete $4;
													}
	;

	ifThenElseStmt :    IF expression COLON NEWLINE
						  INDENT program DEDENT		{
							  							string *toPrint = new string("if(" + *$2 + "){\n" + *$6 + "}\n"); 
														dels.push_back(toPrint); 
														$$ = toPrint;
														delete $1;
														delete $3;
														delete $4;
														delete $5;
														delete $7;
													}

					 |  IF expression COLON NEWLINE 
					 	  INDENT program  DEDENT 
					   ELSE COLON NEWLINE 
					   	  INDENT program  DEDENT	{
														string *toPrint = new string("if(" + *$2 + "){\n" + *$6 + "}\nelse{\n" + *$12 + "}\n"); 
														dels.push_back(toPrint);
														$$ = toPrint;
														delete $1;
														delete $3;
														delete $4;
														delete $5;
														delete $7;
														delete $8;
														delete $9;
														delete $10;
														delete $11;
														delete $13;
													}
					 |  IF expression COLON NEWLINE
					 	 INDENT program  DEDENT 
					   elifStmt 					{
														string *toPrint = new string("if(" + *$2 + "){\n" + *$6 + "}\n" + *$8); 
														dels.push_back(toPrint); 
														$$ = toPrint;
														delete $1;
														delete $3;
														delete $4;
														delete $5;
														delete $7;
													}
					 |  IF expression COLON NEWLINE
					 	 INDENT program  DEDENT 
					   elifStmt 
					   ELSE INDENT program  DEDENT 	{
														string *toPrint = new string("if(" + *$2 + "){\n" + *$6 + "}\n" + *$8 + "\nelse{\n" + *$11 + "}\n"); 
														dels.push_back(toPrint); 
														$$ = toPrint;
														delete $1;
														delete $3;
														delete $4;
														delete $5;
														delete $7;
														delete $9;
														delete $10;
														delete $12;
													}
	;

	elifStmt : 	  ELIF expression COLON NEWLINE 
					INDENT program DEDENT elifStmt	{
														string *toPrint = new string("elif(" + *$2 + "){\n" + *$6 + "}\n"); 
														dels.push_back(toPrint); 
														$$ = toPrint;
														delete $1;
														delete $3;
														delete $4;
														delete $5;
														delete $7;
													}
				| ELIF expression COLON NEWLINE 	
					INDENT program DEDENT 			{
														string *toPrint = new string("elif(" + *$2 + "){\n" + *$6 + "}\n"); 
														dels.push_back(toPrint); 
														$$ = toPrint;
														delete $1;
														delete $3;
														delete $4;
														delete $5;
														delete $7;
													}
	;

	whileStmt :  WHILE expression COLON NEWLINE
					INDENT program  DEDENT 			{
														string *toPrint = new string("while(" + *$2 + "){\n" + *$6 + "}\n"); 
														dels.push_back(toPrint); 
														$$ = toPrint;
														delete $1;
														delete $3;
														delete $4;
														delete $5;
														delete $7;
													}
	;

	breakStmt : BREAK NEWLINE 						{
														string *toPrint = new string("break;\n"); 
														dels.push_back(toPrint); 
														$$ = toPrint;
														delete $1;
														delete $2;
													}
	;

%%
/****
	 Epilogue
****/
	void yyerror(YYLTYPE* loc, const char* err) {
		cerr << "Error: " << err << endl;
	}