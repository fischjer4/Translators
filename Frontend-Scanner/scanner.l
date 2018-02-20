%{
	#include <iostream>
	#include <vector>
	#include <algorithm>

	using std::cout;
	using std::cin;
	using std::endl;
	using std::vector;
	using std::string;

	void printElement(string first, string sec, string spacer);
	int checkIndentation(vector<int> &stack, int yyleng);
%}


%option noyywrap
%option yylineno


%%

%{
	vector<int> stack;
	stack.push_back(1);
%}

#(.*)\n										/*single line comment, ignore*/

^(\n)						{/*Do Nothing...empty line*/}

^([^ \t\n]*)				{
								/* If line isn't indented, make sure there isn't a needed
									DEDENT. This is done by checking the stack. This needs
									to be checked because the regular expression for checking
									INDENT/DEDENT won't catch a dedent to level 1 indentation
								*/
								if(stack.back() > 1){
									if(checkIndentation(stack, 1))
										return 1;
								}
										
							} REJECT

^[ \t]*						{
								if(checkIndentation(stack, yyleng))
									return 1;
							}


[ \t]*										/*space in thte middle of expression, ignore*/

\n							{cout << "NEWLINE" << endl;}

True|False					{printElement("BOOLEAN", (yytext[0] == 'T' ? "1" : "0"), "\t\t"); }

and							{printElement("AND", yytext, "\t\t");}

break 						{printElement("BREAK", yytext, "\t\t");}

def 						{printElement("DEF", yytext, "\t\t");}

elif 						{printElement("ELIF", yytext, "\t\t");}

else						{printElement("ELSE", yytext, "\t\t");}

for							{printElement("FOR", yytext, "\t\t");}

if 							{printElement("IF", yytext, "\t\t");}

not 						{printElement("NOT", yytext, "\t\t");}

or 							{printElement("OR", yytext, "\t\t");}

return 						{printElement("RETURN", yytext, "\t\t");}

while 						{printElement("WHILE", yytext, "\t\t");}

[_a-zA-Z]+[_a-zA-Z0-9]*		{printElement("IDENTIFIER", yytext, "\t");}

-?[0-9]*\.[0-9]+			{cout << "FLOAT" << "\t\t" << atof(yytext) << endl;}

-?[0-9]+					{printElement("INTEGER", std::to_string(atoi(yytext)), "\t\t");}

=							{printElement("ASSIGN", yytext, "\t\t");}

"+"							{printElement("PLUS", yytext, "\t\t");}

-							{printElement("MINUS", yytext, "\t\t");}

"*"							{printElement("TIMES", yytext, "\t\t");}

"/"							{printElement("DIVIDEDBY", yytext, "\t");}

==							{printElement("EQ", yytext, "\t\t");}

!=							{printElement("NEQ", yytext, "\t\t");}

>							{printElement("GT", yytext, "\t\t");}

>=							{printElement("GTE", yytext, "\t\t");}

"<"							{printElement("LT", yytext, "\t\t");}

"<="						{printElement("LTE", yytext, "\t\t");}

"("							{printElement("LPAREN", yytext, "\t\t");}

")"							{printElement("RPAREN", yytext, "\t\t");}

,							{printElement("COMMA", yytext, "\t\t");}

:							{printElement("COLON", yytext, "\t\t");}

<<EOF>> 					{
								return checkIndentation(stack, yyleng);
							}

%%
int checkIndentation(vector<int> &stack, int yyleng){
	/*If there's an indentation indicated by the length of
	  preceding spaces being more than currently on the top
	  of the stack, update the stack and print INDENT
	*/
	if(yyleng > stack.back()){
		cout << "INDENT" << endl;
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
			cout << "Bad Intentation on line: " << yylineno << endl;
			return 1;
		}
		else{
			while(stack.back() != yyleng && stack.back() != 0){
				cout << "DEDENT" << endl;
				stack.pop_back();
			}
		}
	}
	return 0;
}
void printElement(string first, string sec, string spacer){
	cout << first << spacer << sec << endl;
}

int main(){
	yylex();

	return 0;
}