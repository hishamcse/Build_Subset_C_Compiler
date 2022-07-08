/*
    Lexical Analyzer Utilities
    Created by Hisham on 10-Jun-22.
    Modified by Hisham on 29-Jun-22
*/

#ifndef Syntax_Analyzer_1805004_LEXUTILS_H
#define Syntax_Analyzer_1805004_LEXUTILS_H

#include<iostream>
#include<fstream>
#include<utility>
#include<algorithm>

#include "1805004_SymbolInfo.h"
#include "y.tab.h"

using namespace std;

extern YYSTYPE yylval;
extern OutputUtil outputLog;
extern OutputUtil outputError;

void yyerror(char *);

int line_count = 1;
int error_count = 0;
int str_line_count, comment_line_count;
string originalStr, modifiedStr, comment;

/*********************************** Helper methods ***************************/

char escape_ASCII(char escape) {
    char actualChar;

    switch (escape) {
        case 'n':
            actualChar = (char) 10;
            break;
        case 't':
            actualChar = (char) 9;
            break;
        case '\\':
            actualChar = (char) 92;
            break;
        case '\'':
            actualChar = (char) 39;
            break;
        case 'a':
            actualChar = (char) 7;
            break;
        case 'f':
            actualChar = (char) 12;
            break;
        case 'r':
            actualChar = (char) 13;
            break;
        case 'b':
            actualChar = (char) 8;
            break;
        case 'v':
            actualChar = (char) 11;
            break;
        case '0':
            actualChar = (char) 0;
            break;
        case '\"':
            actualChar = (char) 34;
            break;
        case '\?':
            actualChar = (char) 63;
        default:
            break;
    }

    return actualChar;
}

void process_integer_literals() {
    SymbolInfo *info = new SymbolInfo(yytext, "CONST_INT");
    yylval.symbolInfo = info;
}

void process_float_literals() {
    SymbolInfo *info = new SymbolInfo(yytext, "CONST_FLOAT");
    yylval.symbolInfo = info;
}

void process_add_sub() {
    SymbolInfo *info = new SymbolInfo(yytext, "ADDOP");
    yylval.symbolInfo = info;
}

void process_mult_div() {
    SymbolInfo *info = new SymbolInfo(yytext, "MULTOP");
    yylval.symbolInfo = info;
}

void process_relop() {
    SymbolInfo *info = new SymbolInfo(yytext, "RELOP");
    yylval.symbolInfo = info;
}

void process_logic() {
    SymbolInfo *info = new SymbolInfo(yytext, "LOGICOP");
    yylval.symbolInfo = info;
}

void process_id() {
    SymbolInfo *info = new SymbolInfo(yytext, "ID");
    yylval.symbolInfo = info;
}

/************************** Processing errors **************************/

void process_decimal_point_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Too many decimal points " << yytext << '\n' << '\n';
    outputError << "Error at line no " << line_count << ": Too many decimal points " << yytext << '\n' << '\n';
}

void process_ill_number_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Ill formed number " << yytext << '\n' << '\n';
    outputError << "Error at line no " << line_count << ": Ill formed number " << yytext << '\n' << '\n';
}

void process_suffix_prefix_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Invalid prefix on ID or invalid suffix on Number " << yytext
              << '\n' << '\n';
    outputError << "Error at line no " << line_count << ": Invalid prefix on ID or invalid suffix on Number " << yytext
              << '\n' << '\n';
}

void process_multi_char_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Multi character constant error " << originalStr << '\n' << '\n';
    outputError << "Error at line no " << line_count << ": Multi character constant error " << originalStr << '\n' << '\n';
}

void process_unfinished_char_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Unterminated character " << originalStr << '\n' << '\n';
    outputError << "Error at line no " << line_count << ": Unterminated character " << originalStr << '\n' << '\n';
}

void process_empty_char_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Empty character constant error " << originalStr << '\n' << '\n';
    outputError << "Error at line no " << line_count << ": Empty character constant error " << originalStr << '\n' << '\n';
}

void process_unfinished_string_error() {
    error_count++;
    outputLog << "Error at line no " << str_line_count << ": Unterminated String " << originalStr << '\n' << '\n';
    outputError << "Error at line no " << str_line_count << ": Unterminated String " << originalStr << '\n' << '\n';
    line_count++;
}

void process_unfinished_comment() {
    error_count++;
    outputLog << "Error at line no " << comment_line_count << ": Unterminated Comment " << comment << '\n' << '\n';
    outputError << "Error at line no " << comment_line_count << ": Unterminated Comment " << comment << '\n' << '\n';
}

void process_unrecognized_char_error() {
    error_count++;
    outputLog << "Error at line " << line_count << ": Unrecognized character " << yytext << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Unrecognized character " << yytext << '\n' << '\n';
}

/************************** Processing characters *************************/

void process_char_start() {
    str_line_count = line_count;
    originalStr = yytext;
    modifiedStr = "";
}

void process_char_slash_quote() {
    string str = yytext;
    originalStr += str;
    modifiedStr += str.substr(yyleng - 2);
}

void process_char_escape() {
    char escape = yytext[yyleng - 1];
    originalStr += yytext;
    modifiedStr += escape_ASCII(escape);
}

void process_char_general() {
    originalStr += yytext;
    modifiedStr += yytext;
}

void process_char_finish() {
    originalStr += yytext;

    switch(modifiedStr.size()) {
        case 1:
            outputLog << "Line no " << line_count << ": Token <CONST_CHAR> Lexeme " << originalStr
                      << " found --> <CHAR_CONST, " << modifiedStr << ">" << '\n' << '\n';
            break;
        case 0:
            process_empty_char_error();
            break;
        default:
            process_multi_char_error();
            break;
    }
}

/************************** Processing strings *************************/

void process_string_start() {
    str_line_count = line_count;
    originalStr = yytext;
    modifiedStr = yytext;
}

void process_string_newline() {
    line_count++;
    originalStr += yytext;
}

void process_string_slash_quote() {
    string str = yytext;
    originalStr += str;
    modifiedStr += str.substr(yyleng - 2);
}

void process_string_escape() {
    char escape = yytext[yyleng - 1];
    originalStr += yytext;
    modifiedStr += escape_ASCII(escape);
}

void process_string_general() {
    originalStr += yytext;
    modifiedStr += yytext;
}

void process_string_finish() {
    originalStr += yytext;
    modifiedStr += yytext;
    outputLog << "Line no " << str_line_count << ": Token <STRING> Lexeme " << originalStr <<
              " found --> <STRING, " << modifiedStr << ">" << '\n' << '\n';
}

/************************** Processing comments **************************/

void process_comment_start() {
    comment_line_count = line_count;
    comment = yytext;
}

void process_multiline_comment() {
    line_count++;
    comment += yytext;
}

void process_comment_general() {
    comment += yytext;
}

void process_single_comment_finish() {
    line_count++;
    outputLog << "Line no " << comment_line_count << ": Token <COMMENT> Lexeme " << comment << " found" << '\n' << '\n';
}

void process_multiline_comment_finish() {
    comment += yytext;
    outputLog << "Line no " << comment_line_count << ": Token <COMMENT> Lexeme " << comment << " found" << '\n' << '\n';
}

#endif //Syntax_Analyzer_1805004_LEXUTILS_H