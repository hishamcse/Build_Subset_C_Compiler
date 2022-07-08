/*
    Lexical Analyzer Utilities
    Created by Hisham on 21-May-22.
*/

#ifndef LEXICAL_ANALYZER_1805004_LEXUTILS_H
#define LEXICAL_ANALYZER_1805004_LEXUTILS_H

#define SYMBOL_TABLE_BUCKETS 7

#include<iostream>
#include <fstream>
#include<utility>
#include<algorithm>

#include "1805004_SymbolTable.h"
#include "1805004_IOUtils.h"

using namespace std;

SymbolTable symbolTable(SYMBOL_TABLE_BUCKETS);

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

// conversion to uppercase and writing to file
void process_keyword() {
    string str = yytext;
    transform(str.begin(), str.end(), str.begin(), ::toupper);
    outputToken << "<" << str << "> ";
    outputLog << "Line no " << line_count << ": Token <" << str << "> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_integer_literals() {
    string str = yytext;
    outputToken << "<CONST_INT, " << str << "> ";
    outputLog << "Line no " << line_count << ": Token <CONST_INT> Lexeme " << yytext << " found" << '\n' << '\n';

    if (!symbolTable.insertSymbol(str, "CONST_INT")) return;
    symbolTable.print_allScopeTables();
}

void process_float_literals() {
    string str = yytext;
    outputToken << "<CONST_FLOAT, " << str << "> ";
    outputLog << "Line no " << line_count << ": Token <CONST_FLOAT> Lexeme " << yytext << " found" << '\n' << '\n';

    if (!symbolTable.insertSymbol(str, "CONST_FLOAT")) return;
    symbolTable.print_allScopeTables();
}

void process_add_sub() {
    outputToken << "<ADDOP, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <ADDOP> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_mult_div() {
    outputToken << "<MULOP, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <MULOP> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_increment_decrement() {
    outputToken << "<INCOP, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <INCOP> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_relop() {
    outputToken << "<RELOP, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <RELOP> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_assign() {
    outputToken << "<ASSIGNOP, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <ASSIGNOP> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_logic() {
    outputToken << "<LOGICOP, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <LOGICOP> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_not() {
    outputToken << "<NOT, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <NOT> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_left_parenthesis() {
    outputToken << "<LPAREN, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <LPAREN> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_right_parenthesis() {
    outputToken << "<RPAREN, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <RPAREN> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_left_curl() {
    symbolTable.enterScope();
    outputToken << "<LCURL, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <LCURL> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_right_curl() {
    symbolTable.exitScope();
    outputToken << "<RCURL, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <RCURL> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_left_third() {
    outputToken << "<LTHIRD, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <LTHIRD> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_right_third() {
    outputToken << "<RTHIRD, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <RTHIRD> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_comma() {
    outputToken << "<COMMA, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <COMMA> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_semicolon() {
    outputToken << "<SEMICOLON, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <SEMICOLON> Lexeme " << yytext << " found" << '\n' << '\n';
}

void process_id() {
    outputToken << "<ID, " << yytext << "> ";
    outputLog << "Line no " << line_count << ": Token <ID> Lexeme " << yytext << " found" << '\n' << '\n';

    if (!symbolTable.insertSymbol(yytext, "ID")) return;
    symbolTable.print_allScopeTables();
}

/************************** Processing errors **************************/

void process_decimal_point_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Too many decimal points " << yytext << '\n' << '\n';
}

void process_ill_number_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Ill formed number " << yytext << '\n' << '\n';
}

void process_suffix_prefix_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Invalid prefix on ID or invalid suffix on Number " << yytext
              << '\n' << '\n';
}

void process_multi_char_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Multi character constant error " << originalStr << '\n' << '\n';
}

void process_unfinished_char_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Unterminated character " << originalStr << '\n' << '\n';
}

void process_empty_char_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Empty character constant error " << originalStr << '\n' << '\n';
}

void process_unfinished_string_error() {
    error_count++;
    outputLog << "Error at line no " << str_line_count << ": Unterminated String " << originalStr << '\n' << '\n';
    line_count++;
}

void process_unfinished_comment() {
    error_count++;
    outputLog << "Error at line no " << comment_line_count << ": Unterminated Comment " << comment << '\n' << '\n';
}

void process_unrecognized_char_error() {
    error_count++;
    outputLog << "Error at line no " << line_count << ": Unrecognized character " << yytext << '\n' << '\n';
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
            outputToken << "<CHAR_CONST, " << modifiedStr << "> ";
            outputLog << "Line no " << line_count << ": Token <CONST_CHAR> Lexeme " << originalStr
                      << " found --> <CHAR_CONST, " << modifiedStr << ">" << '\n' << '\n';

            if (!symbolTable.insertSymbol(originalStr, "CONST_CHAR")) return;
            symbolTable.print_allScopeTables();
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
    outputToken << "<STRING, " << modifiedStr << "> ";
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

void finish_analysis() {
    symbolTable.print_allScopeTables();
    outputLog << "Total Lines : " << line_count << '\n';
    outputLog << "Total Errors : " << error_count << '\n';
}

#endif //LEXICAL_ANALYZER_1805004_LEXUTILS_H