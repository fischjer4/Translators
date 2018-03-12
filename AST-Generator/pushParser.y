%{
/****
	 Prologue
****/
	#include <iostream>
	#include <string>
	#include <set>
	#include <vector>

	using std::cout;
	using std::endl;
	using std::vector;
	using std::string;
	using std::cerr;
	using std::set;
	using std::vector;
	using std::to_string;

	#include "pushParser.hpp"
	#include "Node.h"

	set<string> symbols;
	bool _error = false;

	Node *rootTree = NULL;

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
	struct Node *nodes;
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

/*Define the types of the Non-terminals */
%type <nodes> 	expression assnStmt ifThenElseStmt whileStmt breakStmt elifStmt elseStmt program stmt masterProgram 

/*Define the precidence and associativty of operators*/
%left 			 PLUS MINUS
%left 			 TIMES DIVIDEDBY

/*Define the start symbol*/
%start 			 masterProgram 
/****
	 Rules Below
****/
%%
	masterProgram : program 	{	
									rootTree = $1;		
									$$ = $1;
								} 
	;
	
	program : 	program stmt	{
									$1->children.push_back($2);
									$$ = $1;
								}
				| stmt			{
									Node *cur = new Node("Block", false);
									cur->children.push_back($1);									
									$$ = cur;
								}
	;

	stmt : 	 ifThenElseStmt 	{$$ = $1;}
			| whileStmt			{$$ = $1;}
			| breakStmt 	  	{$$ = $1;}
			| assnStmt 		 	{$$ = $1; }
			| error NEWLINE {std::cerr << "Error: bad statement on line " << @1.first_line << endl; _error = true; }
	;


	expression : 	  LPAREN expression RPAREN 			{
															$$ = $2;
															delete $1;
															delete $3;
														}
					| expression PLUS expression 		{
															Node *tmp = new Node("PLUS", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| expression MINUS expression		{
															Node *tmp = new Node("MINUS", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| expression TIMES expression 		{
															Node *tmp = new Node("TIMES", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| expression DIVIDEDBY expression	{
															Node *tmp = new Node("DIVIDEDBY", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| expression GT expression			{
															Node *tmp = new Node("GT", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| expression GTE expression			{
															Node *tmp = new Node("GTE", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| expression LT expression			{
															Node *tmp = new Node("LT", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| expression LTE expression			{
															Node *tmp = new Node("LTE", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| expression EQ expression 			{
															Node *tmp = new Node("EQ", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| expression AND expression			{
															Node *tmp = new Node("AND", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| expression OR expression			{
															Node *tmp = new Node("OR", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| expression NEQ expression			{
															Node *tmp = new Node("NEQ", false); 
															tmp->children.push_back($1);
															tmp->children.push_back($3);
															$$ = tmp;
															delete $2;
														}
					| NOT expression					{
															Node *tmp = new Node("NOT", false); 
															tmp->children.push_back($2);
															$$ = tmp;
															delete $1;
														}
					| INTEGER							{
															Node *tmp = new Node("Integer\: " +to_string($1), true); 
															$$ = tmp;
														}
					| FLOAT								{
															Node *tmp = new Node("Float\: " +to_string($1), true); 
															$$ = tmp;
														}
					| BOOLEAN							{
															Node *tmp = new Node("Bool\: " + ($1 == true ? string("true") : string("false")), true); 
															$$ = tmp;
														}
					| IDENTIFIER 						{
															if (symbols.count(*$1)) {
																Node *tmp = new Node("Identifier\: " + *$1, true);
																$$ = tmp;
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
														symbols.insert(*$1); 
														Node *tmp = new Node("Assignment", false);
														Node *id = new Node("Identifier\: "+ *$1, true);
														tmp->children.push_back(id);
														tmp->children.push_back($3); 
														$$ = tmp;
														delete $1;
														delete $2;
														delete $4;
													}
	;

	ifThenElseStmt : IF expression COLON NEWLINE 
						INDENT program DEDENT
						elifStmt 
						elseStmt 					{ 
														Node *tmp = new Node("If", false);
														tmp->children.push_back($2); 
														tmp->children.push_back($6);
														tmp->children.push_back($8);
														tmp->children.push_back($9); 
														$$ = tmp;
														delete $1;
														delete $3;
														delete $4;
														delete $5;
														delete $7;
													}
	;

	elifStmt : elifStmt 
				  ELIF expression COLON NEWLINE 
				  	INDENT program DEDENT 			{ 
					  									Node *tmp = new Node("Elif", false);
														tmp->children.push_back($1); 
														tmp->children.push_back($3); 
														tmp->children.push_back($7); 
														$$ = tmp;
														delete $2;
														delete $4;
														delete $5;
														delete $6;
														delete $8;
													}
				| %empty 							{ 
														$$ = NULL; 
													}
	;

	elseStmt : ELSE COLON NEWLINE 
					INDENT program DEDENT 			{				
														Node *tmp = new Node("Else", false);
														tmp->children.push_back($5); 
														$$ = tmp;
														delete $1;
														delete $2;
														delete $3;
														delete $4;
														delete $6;
													}
				| %empty 							{ 
														$$ = NULL;
													}
				
	;

	whileStmt :  WHILE expression COLON NEWLINE
					INDENT program  DEDENT 			{
														Node *tmp = new Node("While", false);
														tmp->children.push_back($2);
														tmp->children.push_back($6);
														$$ = tmp;
														delete $1;
														delete $3;
														delete $4;
														delete $5;
														delete $7;
													}
	;

	breakStmt : BREAK NEWLINE 						{
														Node *tmp = new Node("Break", false); 
														$$ = tmp;
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