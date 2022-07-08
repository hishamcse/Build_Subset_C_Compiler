%option noyywrap

%x TEMPLATE
%x TEMPLATE2

%{
#include<stdio.h>
#include<stdlib.h>
#include <iostream>
#include <fstream>

using namespace std;

string str="";
string str2="";
string name="";
string name2="";

%}

Letter [a-zA-Z]

%%
[ \t\v\n]+ {}
{Letter}+ {str+=yytext;}

"<" {
    str += yytext;
    BEGIN TEMPLATE;
}

<TEMPLATE>{Letter} {
    str += yytext;
	name += yytext;
}

<TEMPLATE>"<" {
    str2 += yytext;
    BEGIN TEMPLATE2;
}

<TEMPLATE2>{Letter} {
    str2 += yytext;
	name2 += yytext;
}

<TEMPLATE2><<EOF>> {
    cout << "Unfinished Template" <<endl;
    return 0;
}

<TEMPLATE2>">" {
    str2 += yytext;
	name2 += yytext;
	str += str2;
	str2 = "";
	name2 = "";
    BEGIN TEMPLATE;
}

<TEMPLATE><<EOF>> {
    cout << "Unfinished Template" <<endl;
    return 0;
}

<TEMPLATE>">" {
    str += yytext;
	name += yytext;
	cout << "Template "<< str <<" detected" <<endl;
	str = "";
	name = "";
    BEGIN INITIAL;
}

<<EOF>> {
    return 0;
	}
%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	yyin= fin;
	yylex();
	fclose(yyin);
	return 0;
}