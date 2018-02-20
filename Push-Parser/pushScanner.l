%{
	#include <iostream>
	#include <vector>
	#include <cstdlib>
	#include <algorithm>

	#include "pushParser.hpp"

	using std::cout;
	using std::cerr;
	using std::endl;
	using std::vector;
	using std::string;


	void printElement(string first, string sec, string spacer);
	int checkIndentation(vector<int> &stack, int yyleng);
	
	YYSTYPE yylval;
	YYLTYPE yylloc;

	yypstate* pstate = yypstate_new();

	#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;	
	#define PUSH_TOKEN(token) do {  \
			int s = yypush_parse(pstate, token, &yylval, &yylloc);  \
			if (s != YYPUSH_MORE) {                                 \
				yypstate_delete(pstate);                              \
				return s;                                             \
			}                                                       \
		} while(0)
%}


%option noyywrap
%option yylineno


%%

%{
	vector<int> stack;
	stack.push_back(1);
%}

^[ \t]*\r?\n   				 { /* Skip blank lines */ }

^[ \t]*#.*\r?\n    			 { /* Skip whole-line comments. */ }

#.*$       					 { /* Skip comments on the same line as a statement. */ }


^([^ \t\n]*)				{
								/* If line isn't indented, make sure there isn't a needed
									DEDENT. This is done by checking the stack. This needs
									to be checked because the regular expression for checking
									INDENT/DEDENT won't catch a dedent to level 1 indentation
								*/
								if(stack.back() > 1){
									checkIndentation(stack, 1);
								}
										
							} REJECT

^[ \t]*						{
								checkIndentation(stack, yyleng);
							}


[ \t]*										/*space in thte middle of expression, ignore*/

\n							{ 	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(NEWLINE);	
							}

True|False					{
								yylval.logic = (yytext[0] == 'T' ? true : false);
								PUSH_TOKEN(BOOLEAN);
							}
and							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(AND);	
							}

break 						{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(BREAK);	
							}

def 						{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(DEF);	
							}

elif 						{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(ELIF);	
							}

else						{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(ELSE);	
							}

for							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(FOR);	
							}

if 							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(IF);	
							}

not 						{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(NOT);	
							}

or 							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(OR);	
							}

return 						{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(RETURN);	
							}

while 						{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(WHILE);	
							}

[_a-zA-Z]+[_a-zA-Z0-9]*		{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(IDENTIFIER);	
							}

-?[0-9]*\.[0-9]+			{
								yylval.flt = atof(yytext);
								PUSH_TOKEN(FLOAT);
							}

-?[0-9]+					{
								yylval.integer = atoi(yytext);
								PUSH_TOKEN(INTEGER);
							}
	
=							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(ASSIGN);	
							}

"+"							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(PLUS);	
							}

-							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(MINUS);	
							}

"*"							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(TIMES);	
							}

"/"							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(DIVIDEDBY);	
							}

==							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(EQ);	
							}

!=							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(NEQ);	
							}

>							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(GT);	
							}

>=							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(GTE);	
							}

"<"							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(LT);	
							}

"<="						{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(LTE);	
							}

"("							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(LPAREN);	
							}

")"							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(RPAREN);	
							}

,							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(COMMA);	
							}

:							{	
								yylval.str = new string(yytext, yyleng);
								PUSH_TOKEN(COLON);	
							}

<<EOF>> 					{
								checkIndentation(stack, yyleng);
								int s = yypush_parse(pstate, 0, NULL, NULL);
								yypstate_delete(pstate);
								return s;
							}

%%
int checkIndentation(vector<int> &stack, int yyleng){
	/*If there's an indentation indicated by the length of
	  preceding spaces being more than currently on the top
	  of the stack, update the stack and print INDENT
	*/
	if(yyleng > stack.back()){
		yylval.str = new string(yytext, yyleng);
		PUSH_TOKEN(INDENT);
		stack.push_back(yyleng);
	}
	/*If the number of preceding spaces is less than the
	  current indentation level (the top of the stack),
	  then check and see if it's possible to pop-off (DEDENT)
	  to the requested indentation level. If not, then end in
	  bad indentation error. If so, then for each pop print
	  DEDENT
	*/ 
	else if(yyleng < stack.back()){
		if(find(stack.begin(), stack.end(), yyleng) == stack.end()){
			cerr << "Invalid symbol on line " << yylineno << ": " << yytext << endl;
			PUSH_TOKEN(yytext[0]);
		}
		else{
			while(stack.back() != yyleng && stack.back() != 0){
				yylval.str = new string(yytext, yyleng);
				PUSH_TOKEN(DEDENT);
				stack.pop_back();
			}
		}
	}
	return 0;
}