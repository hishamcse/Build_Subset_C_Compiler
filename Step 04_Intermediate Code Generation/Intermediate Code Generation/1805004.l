%option noyywrap

%x STATE_CHARACTER
%x STATE_STRING
%x STATE_SINGLE_COMMENT
%x STATE_MULTILINE_COMMENT

%{
#ifndef Syntax_Analyzer_1805004_l
#define Syntax_Analyzer_1805004_l

#include "1805004_LexUtils.h"

#endif //Syntax_Analyzer_1805004_l
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

"if"       { return IF; }
"else"     { return ELSE; }
"for"      { return FOR; }
"while"    { return WHILE; }
"do"       { return DO; }
"break"    { return BREAK; }
"int"      { return INT; }
"char"     { return CHAR; }
"float"    { return FLOAT; }
"double"   { return DOUBLE; }
"void"     { return VOID; }
"return"   { return RETURN; }
"switch"   { return SWITCH; }
"case"     { return CASE; }
"default"  { return DEFAULT; }
"continue" { return CONTINUE; }
"printf" |
"println"  { return PRINTLN; }

{DIGITS} {
    process_integer_literals();
    return CONST_INT;
}

{DIGITS}?(\.{DIGITS})?([Ee][+-]?{DIGITS})?  {
    process_float_literals();
    return CONST_FLOAT;
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
    return 0;
}

<STATE_CHARACTER>. {
    process_char_general();
}

"+"|"-" {
    process_add_sub();
    return ADDOP;
}

"*"|"/"|"%" {
    process_mult_div();
    return MULOP;
}

"++" {
    return INCOP;
}

"--" {
    return DECOP;
}

"<"|"<="|">"|">="|"=="|"!=" {
    process_relop();
    return RELOP;
}

"=" {
    return ASSIGNOP;
}

"&&"|"||" {
    process_logic();
    return LOGICOP;
}

"!" {
    return NOT;
}

"(" {
    return LPAREN;
}

")" {
    return RPAREN;
}

"{" {
    return LCURL;
}

"}" {
    return RCURL;
}

"[" {
    return LTHIRD;
}

"]" {
    return RTHIRD;
}

"," {
    return COMMA;
}

";" {
    return SEMICOLON;
}

({ALPHABET}|{UNDERSCORE})({ALPHABET}|{UNDERSCORE}|{DIGIT})* {
    process_id();
    return ID;
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
    return 0;
} 

. {
    process_unrecognized_char_error();
}

%%