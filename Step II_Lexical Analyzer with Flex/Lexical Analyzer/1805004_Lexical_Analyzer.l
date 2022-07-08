%option noyywrap

%x STATE_CHARACTER
%x STATE_STRING
%x STATE_SINGLE_COMMENT
%x STATE_MULTILINE_COMMENT

%{
#include <iostream>
#include <fstream>
#include "1805004_Utils.h"
#include "1805004_IOUtils.h"
#include "1805004_SymbolTable.h"
#include "1805004_LexUtils.h"

using namespace std;
%}

NEWLINE \n|\r\n
UNDERSCORE _
WHITESPACE [ \f\r\t\v]+
DIGIT [0-9]
DIGITS {DIGIT}+
ALPHABET [a-zA-Z]

%%

{NEWLINE}       {line_count++;}

{WHITESPACE}    {}

"if"|"else"|"for"|"while"|"do"|"break"|"int"|"char"|"float"|"double"|"void"|"return"|"switch"|"case"|"default"|"continue"  {
    process_keyword();
}

{DIGITS} {
    process_integer_literals();
}

{DIGITS}?(\.{DIGITS})?([Ee][+-]?{DIGITS})?  {
    process_float_literals();
}

\' {
    process_char_start();
    BEGIN STATE_CHARACTER;
}

<STATE_CHARACTER>\\[\\\'\"] {
    process_char_slash_quote();
}

<STATE_CHARACTER>\\. {
    process_char_escape();
}

<STATE_CHARACTER>\' {
    process_char_finish();
    BEGIN INITIAL;
}

<STATE_CHARACTER>{NEWLINE} {
    process_unfinished_char_error();
    line_count++;
    BEGIN INITIAL;
}

<STATE_CHARACTER><<EOF>> {
    process_unfinished_char_error();
    finish_analysis();
    return 0;
}

<STATE_CHARACTER>. {
    process_char_general();
}

"+"|"-" {
    process_add_sub();
}

"*"|"/"|"%" {
    process_mult_div();
}

"++"|"--" {
    process_increment_decrement();
}

"<"|"<="|">"|">="|"=="|"!=" {
    process_relop();
}

"=" {
    process_assign();
}

"&&"|"||" {
    process_logic();
}

"!" {
    process_not();
}

"(" {
    process_left_parenthesis();
}

")" {
    process_right_parenthesis();
}

"{" {
    process_left_curl();
}

"}" {
    process_right_curl();
}

"[" {
    process_left_third();
}

"]" {
    process_right_third();
}

"," {
    process_comma();
}

";" {
    process_semicolon();
}

({ALPHABET}|{UNDERSCORE})({ALPHABET}|{UNDERSCORE}|{DIGIT})* {
    process_id();
}

\" {
    process_string_start();
    BEGIN STATE_STRING;
}

<STATE_STRING>\\{NEWLINE} {
    process_string_newline();
}

<STATE_STRING>\\[\\\'\"] {
    process_string_slash_quote();
}

<STATE_STRING>\\. {
    process_string_escape();
}

<STATE_STRING>\" {
    process_string_finish();
    BEGIN INITIAL;
}

<STATE_STRING>{NEWLINE} {
    process_unfinished_string_error();
    BEGIN INITIAL;
}

<STATE_STRING><<EOF>> {
    process_unfinished_string_error();
    finish_analysis();
    return 0;
}

<STATE_STRING>. {
    process_string_general();
}

\/\/ {
    process_comment_start();
    BEGIN STATE_SINGLE_COMMENT;
}

<STATE_SINGLE_COMMENT>{NEWLINE} {
    process_single_comment_finish();
    BEGIN INITIAL;
}

<STATE_SINGLE_COMMENT>\\{NEWLINE} {
    process_multiline_comment();
}

<STATE_SINGLE_COMMENT>. {
    process_comment_general();
}

\/\* {
    process_comment_start();
    BEGIN STATE_MULTILINE_COMMENT;
}

<STATE_MULTILINE_COMMENT>\*\/ {
    process_multiline_comment_finish();
    BEGIN INITIAL;
}

<STATE_MULTILINE_COMMENT>{NEWLINE} {
    process_multiline_comment();
}

<STATE_MULTILINE_COMMENT><<EOF>> {
    process_unfinished_comment();
    finish_analysis();
    return 0;
}

<STATE_MULTILINE_COMMENT>. {
    process_comment_general();
}

{DIGIT}*\.{DIGITS}\.({DIGIT}|\.|E|e|\+|\-)*  {
    process_decimal_point_error();
}

{DIGIT}*(\.{DIGITS})?[Ee][+-]?{DIGIT}*({DIGIT}|\.|E|e|\+|\-)*  {
    process_ill_number_error();
}

{DIGITS}\. {
    process_ill_number_error();
}

{DIGITS}({ALPHABET}|{UNDERSCORE})({ALPHABET}|{DIGIT}|{UNDERSCORE})* {
    process_suffix_prefix_error();
}

<<EOF>> {
    finish_analysis();
    return 0;
}

. {
    process_unrecognized_char_error();
}

%%

int main(int argc, char *argv[]) {

    if (argc != 2) {
        cout << "Please provide input file name and try again" << endl;
        return 0;
    }

    fileIn = fopen(argv[1], "r");

    if (fileIn == NULL) {
        cout << "Can't open specified file" << endl;
        return 0;
    }

    yyin = fileIn;
    yylex();

    fclose(yyin);
    tokenOut.close();
    logOut.close();

    return 0;
}