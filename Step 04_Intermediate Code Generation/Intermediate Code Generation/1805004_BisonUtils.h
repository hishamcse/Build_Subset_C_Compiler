/*
    Syntax and semantic Analyzer Utilities
    Created by Hisham on 20-Jun-22.
    Modified by Hisham on 4-Aug-22.
*/

#ifndef Syntax_Analyzer_1805004_BISONUTILS_H
#define Syntax_Analyzer_1805004_BISONUTILS_H

#include<iostream>
#include<fstream>
#include<utility>
#include<string>
#include<cstdlib>
#include<vector>
#include<set>
#include<algorithm>

#include "1805004_SymbolInfo.h"
#include "1805004_SymbolTable.h"

#define SYMBOL_TABLE_BUCKETS 7

using namespace std;

SymbolTable symbolTable(SYMBOL_TABLE_BUCKETS);

int yyparse(void);
int yylex(void);

extern FILE *yyin;
extern int line_count;
extern int error_count;

FILE *fileIn;
ofstream logOut("log.txt");
ofstream errorOut("error.txt");

OutputUtil outputLog(cout, logOut);
OutputUtil outputError(cout, errorOut);

parameter param;
vector <parameter> param_list;
vector <parameter> asm_var_param_list;
vector <string> available_param_list;
set <string> available_asm_var_param_list;
vector <string> processed_functions;
vector <string> funcPointers;
string typePointer, varType;
string scoped_func;

set<string> dataSegment;
set<pair<string, string>> arraySegment;

void yyerror(const char *str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": syntax error" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": syntax error" << '\n' << '\n';
}

void discard_symbol(SymbolInfo *info) {
    if(info) free(info);
}

void print_rule(string str) {
    outputLog << "Line " << line_count << ": " << str << '\n' << '\n';
}

void print_code(string str) {
    outputLog << str << '\n' << '\n';
}

/*------------------------------------------------- Error Print ---------------------------------------------------*/

void print_multiple_dec_error(string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": Multiple declaration of " << str << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Multiple declaration of " << str << '\n' << '\n';
}

void print_multiple_dec_param_error(string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": Multiple declaration of " << str << " in parameter" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Multiple declaration of " << str << " in parameter" << '\n' << '\n';
}

void print_param_length_mismatch_error(string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": Total number of arguments mismatch with declaration in function " << str << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Total number of arguments mismatch with declaration in function " << str << '\n' << '\n';
}

void print_returnType_mismatch_error(string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": Return type mismatch with function declaration in function " << str << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Return type mismatch with function declaration in function " << str << '\n' << '\n';
}

void print_param_type_mismatch_error(string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": parameter type mismatch with function declaration in function " << str << '\n' << '\n';
    outputError << "Error at line " << line_count << ": parameter type mismatch with function declaration in function " << str << '\n' << '\n';
}

void print_variable_type_error() {
    error_count++;
    outputLog << "Error at line " << line_count << ": Variable type cannot be void" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Variable type cannot be void" << '\n' << '\n';
}

void print_undec_variable_error(string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": Undeclared variable " << str << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Undeclared variable " << str << '\n' << '\n';
}

void print_void_return_error() {
    error_count++;
    outputLog << "Error at line " << line_count << ": Void function used in expression" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Void function used in expression" << '\n' << '\n';
}

void print_expr_returnType_mismatch_error() {
    error_count++;
    outputLog << "Error at line " << line_count << ": Return type of function mismatch " << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Return type of function mismatch " << '\n' << '\n';
}

void print_array_type_mismatch_error(string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": Type mismatch, " << str << " is an array" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Type mismatch, " << str << " is an array" << '\n' << '\n';
}

void print_not_array_error(string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": " << str << " not an array" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": " << str << " not an array" << '\n' << '\n';
}

void print_wrong_array_index_error() {
    error_count++;
    outputLog << "Error at line " << line_count << ": Expression inside third brackets not an integer" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Expression inside third brackets not an integer" << '\n' << '\n';
}

void print_type_mismatch_error() {
    error_count++;
    outputLog << "Error at line " << line_count << ": Type Mismatch" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Type Mismatch" << '\n' << '\n';
}

void print_invalid_operand_modulus_error() {
    error_count++;
    outputLog << "Error at line " << line_count << ": Non-Integer operand on modulus operator" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Non-Integer operand on modulus operator" << '\n' << '\n';
}

void print_modulus_by_zero_error() {
    error_count++;
    outputLog << "Error at line " << line_count << ": Modulus by Zero" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Modulus by Zero" << '\n' << '\n';
}

void print_undec_function_error(string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": Undeclared function " << str << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Undeclared function " << str << '\n' << '\n';
}

void print_argument_length_mismatch_error(string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": Total number of arguments mismatch in function " << str << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Total number of arguments mismatch in function " << str << '\n' << '\n';
}

void print_th_argument_mismatch_error(int th, string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": " << th << "th argument mismatch in function " << str << '\n' << '\n';
    outputError << "Error at line " << line_count << ": " << th << "th argument mismatch in function " << str << '\n' << '\n';
}

void print_invalid_scope_error(string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": Invalid scoping of function " << str << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Invalid scoping of function " << str << '\n' << '\n';
}

void print_th_param_missing_error(int th, string str) {
    error_count++;
    outputLog << "Error at line " << line_count << ": " << th << "th parameter's name not given in function definition of " << str << '\n' << '\n';
    outputError << "Error at line " << line_count << ": " << th << "th parameter's name not given in function definition of " << str << '\n' << '\n';
}

void print_inconsistent_func_call_error() {
    error_count++;
    outputLog << "Error at line " << line_count << ": Inconsistent function definition and declaration parameter list" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Inconsistent function definition and declaration parameter list" << '\n' << '\n';
}

void print_invalid_operand_LOGICOP_error() {
    error_count++;
    outputLog << "Error at line " << line_count << ": Non-Integer operand on Logic operator" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Non-Integer operand on Logic operator" << '\n' << '\n';
}

void print_invalid_operand_RELOP_error() {
    error_count++;
    outputLog << "Error at line " << line_count << ": Non-Integer operand on Relational operator" << '\n' << '\n';
    outputError << "Error at line " << line_count << ": Non-Integer operand on Relational operator" << '\n' << '\n';
}

/*-------------------------------------------------- Utility Functions ----------------------------------------------*/

void addToParamListWithID(string idName, string idType, string typeSpecifier) {
    param.paramName = idName;
    param.paramType = idType;
    param.p_speciesType = "VARIABLE";
    param.p_returnType = typeSpecifier;
    param_list.push_back(param);
}

void addToParamListWithoutID(string typeSpecifierName, string typeSpecifierType) {
    param.paramName = typeSpecifierName;
    param.paramType = typeSpecifierType;
    param.p_speciesType = "VARIABLE";
    param.p_returnType = typeSpecifierName;
    param_list.push_back(param);
}

int param_equal(parameter p1, parameter p2) {
    if(p1.paramType == p2.paramType && p1.p_speciesType == p2.p_speciesType && p1.p_returnType == p2.p_returnType) {
        return 1;
    }
    return 0;
}

/*------------------------------------------ All Processing for .y file grammar rules ----------------------------------*/

void process_start_program() {
    print_rule("start : program");
    symbolTable.print_allScopeTables();
}

void process_program_programUnit(string str) {
    print_rule("program : program unit");
    print_code(str);
}

void process_unit(string str) {
    print_rule("program : unit");
    print_code(str);
}

void process_unit_var_declaration(string str) {
    print_rule("unit : var_declaration");
    print_code(str);
}

void process_unit_func_declaration(string str) {
    print_rule("unit : func_declaration");
    print_code(str);
}

void process_unit_func_definition(string str) {
    print_rule("unit : func_definition");
    print_code(str);
}

void process_func_declaration_with_params(string func_name, string returnType) {
    funcPointers.push_back(func_name);
    if (symbolTable.lookUpSymbol(func_name)) {
        print_multiple_dec_error(func_name);
        return;
    }

    SymbolInfo *info = new SymbolInfo(func_name, "ID");
    info->setSpeciesType("FUNCTION");
    info->setReturnType(returnType);

    for (parameter p: param_list) {
        info->insertParameter(p.paramType, p.paramName, p.p_speciesType, p.p_returnType);
    }

    symbolTable.insertSymbol(*info);
    param_list.clear();
}

void process_func_declaration_first(string str, string funcName) {
    print_rule("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
    print_code(str);
    if(symbolTable.getCurrentScopeId() != "1") print_invalid_scope_error(funcName);
}

void process_func_declaration_without_params(string func_name, string returnType) {
    funcPointers.push_back(func_name);
    if (symbolTable.lookUpSymbol(func_name)) {
        print_multiple_dec_error(func_name);
        return;
    }

    SymbolInfo *info = new SymbolInfo(func_name, "ID");
    info->setSpeciesType("FUNCTION");
    info->setReturnType(returnType);
    symbolTable.insertSymbol(*info);
//    if(info -> getName() != "main") dataSegment.insert(info -> getVarAsm());
}

void process_func_declaration_second(string str, string funcName) {
    print_rule("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
    print_code(str);
    if(symbolTable.getCurrentScopeId() != "1") print_invalid_scope_error(funcName);
}

void process_func_definition_with_params(string func_name, string returnType) {
    funcPointers.push_back(func_name);
    scoped_func = func_name;
    if(symbolTable.getCurrentScopeId() != "1") print_invalid_scope_error(func_name);
    SymbolInfo *found = symbolTable.lookUpSymbol(func_name);

    if (found) {
        if (find(processed_functions.begin(), processed_functions.end(), func_name) != processed_functions.end()) {
            print_multiple_dec_error(func_name);
        }

        if (found->getSpeciesType() == "FUNCTION") {
            vector <parameter> found_params = found->getFuncParamList();
            if (found_params.size() != param_list.size()) print_param_length_mismatch_error(func_name);
            else {
                for (int i = 0; i < min(found_params.size(), param_list.size()); i++) {
                    if (param_equal(found_params[i], param_list[i]) == 0) {
                        print_inconsistent_func_call_error();
                    }
                }
            }

            if (returnType != found->getReturnType()) print_returnType_mismatch_error(func_name);

            for (int i = 0; i < min(found_params.size(), param_list.size()); i++) {
                if (found_params[i].p_returnType != param_list[i].p_returnType) {
                    print_param_type_mismatch_error(func_name);
                }
                if (param_list[i].paramName == param_list[i].p_returnType) {
                    print_th_param_missing_error(i + 1, func_name);
                }
            }
        } else {
            print_multiple_dec_error(func_name);
        }

        return;
    }

    SymbolInfo *info = new SymbolInfo(func_name, "ID");
    info->setSpeciesType("FUNCTION");
    info->setReturnType(returnType);

    int i = 1;
    for (parameter p: param_list) {
        if(p.paramName == p.p_returnType) print_th_param_missing_error(i, func_name);
        info->insertParameter(p.paramType, p.paramName, p.p_speciesType, p.p_returnType);
        i++;
    }

    symbolTable.insertSymbol(*info);
//    dataSegment.insert(info -> getVarAsm());
//    param_list.clear();
}

void process_func_definition_first(string str) {
    print_rule("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
    print_code(str);
    processed_functions.push_back(funcPointers.back());
}

void process_func_definition_without_params(string func_name, string returnType) {
    funcPointers.push_back(func_name);
    scoped_func = func_name;
    if(symbolTable.getCurrentScopeId() != "1") print_invalid_scope_error(func_name);
    SymbolInfo *found = symbolTable.lookUpSymbol(func_name);
    if (found) {
        if (found->getSpeciesType() != "FUNCTION") {
            print_multiple_dec_error(func_name);
        }

        int i = 1;
        for (parameter p: param_list) {
            if(p.paramName == p.p_returnType) print_th_param_missing_error(i, func_name);
            i++;
        }
        return;
    }

    int i = 1;
    for (parameter p: param_list) {
        if(p.paramName == p.p_returnType) print_th_param_missing_error(i, func_name);
        i++;
    }

    SymbolInfo *info = new SymbolInfo(func_name, "ID");
    info->setSpeciesType("FUNCTION");
    info->setReturnType(returnType);
    symbolTable.insertSymbol(*info);
    //    if(info -> getName() != "main") dataSegment.insert(info -> getVarAsm());
    available_param_list.clear();
//    param_list.clear();
}

void process_func_definition_second(string str) {
    print_rule("func_definition : type_specifier ID LPAREN RPAREN compound_statement");
    print_code(str);
    processed_functions.push_back(funcPointers.back());
}

void process_parameter_list_first(string str, string idName, string idType, string typeSpecifier) {
    print_rule("parameter_list : parameter_list COMMA type_specifier ID");

    for(parameter p: param_list) {
        if(p.paramName == idName) {
            print_multiple_dec_param_error(idName);
            print_code(str);
            return;
        }
    }

    addToParamListWithID(idName, idType, typeSpecifier);
    print_code(str);
}

void process_parameter_list_second(string str, string typeSpecifierName, string typeSpecifierType) {
    print_rule("parameter_list : parameter_list COMMA type_specifier");
    print_code(str);
    addToParamListWithoutID(typeSpecifierName, typeSpecifierType);
}

void process_parameter_list_third(string str, string idName, string idType, string typeSpecifier) {
    print_rule("parameter_list : type_specifier ID");
    print_code(str);
    addToParamListWithID(idName, idType, typeSpecifier);
}

void process_parameter_list_fourth(string str, string typeSpecifierName, string typeSpecifierType) {
    print_rule("parameter_list : type_specifier");
    print_code(str);
    addToParamListWithoutID(typeSpecifierName, typeSpecifierType);
}

void process_compound_statement_first(string str) {
    print_rule("compound_statement : LCURL statements RCURL");
    print_code(str);
    if(funcPointers.size() != 0) funcPointers.pop_back();
}

void process_compound_statement_second(string str) {
    print_rule("compound_statement : LCURL RCURL");
    print_code(str);
    if(funcPointers.size() != 0) funcPointers.pop_back();
}

void process_start_scope() {
    if(param_list.size() == 0) return;

    string u_id = symbolTable.getCurrentScopeId();
    replace(u_id.begin(), u_id.end(), '.', '_');
    for(parameter p:param_list) {
        SymbolInfo *info = new SymbolInfo(p.paramName, p.paramType);
        info ->setReturnType(p.p_returnType);
        info ->setSpeciesType(p.p_speciesType);
        symbolTable.insertSymbol(*info);
        available_param_list.push_back(p.paramName + "" + u_id);
        dataSegment.insert(info -> getVarAsm());
    }

    param_list.clear();
}

void process_var_declaration(string str, string varType) {
    print_rule("var_declaration : type_specifier declaration_list SEMICOLON");
    if(varType == "void") print_variable_type_error();
    else {
        string u_id = symbolTable.getCurrentScopeId();
        replace(u_id.begin(), u_id.end(), '.', '_');
        for(parameter p:asm_var_param_list) {
            available_asm_var_param_list.insert(p.paramName + "" + u_id);
        }
    }
    asm_var_param_list.clear();
    print_code(str);
}

void process_int() {
    print_rule("type_specifier : INT");
    print_code("int");
    typePointer = "int";
}

void process_float() {
    print_rule("type_specifier : FLOAT");
    print_code("float");
    typePointer = "float";
}

void process_void() {
    print_rule("type_specifier : VOID");
    print_code("void");
    typePointer = "void";
}

void process_declaration_list_first(string str, string idName, string idType) {
    print_rule("declaration_list : declaration_list COMMA ID");

    SymbolInfo *info = new SymbolInfo(idName, idType);
    info->setSpeciesType("VARIABLE");
    info->setReturnType(typePointer);

    if(symbolTable.lookUpCurrentScope(idName)) print_multiple_dec_error(idName);
    else {
        parameter p;
        p.paramName = idName;
        p.paramType = idType;
        asm_var_param_list.push_back(p);
    }

    if(varType != "void") {
        symbolTable.insertSymbol(*info);
        dataSegment.insert(info -> getVarAsm());
    }
    print_code(str);
}

void process_declaration_list_second(string str, string idName, string idType) {
    print_rule("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");

    SymbolInfo *info = new SymbolInfo(idName, idType);
    info->setSpeciesType("ARRAY");
    info->setReturnType(typePointer);

    if(symbolTable.lookUpCurrentScope(idName)) print_multiple_dec_error(idName);
    else {
        parameter p;
        p.paramName = idName;
        p.paramType = idType;
        asm_var_param_list.push_back(p);
    }

    if(varType != "void") {
        symbolTable.insertSymbol(*info);
        dataSegment.insert(info -> getVarAsm());
    }
    print_code(str);
}

void process_declaration_list_third(string str, string idName, string idType) {
    print_rule("declaration_list : ID");

    SymbolInfo *info = new SymbolInfo(idName, idType);
    info->setSpeciesType("VARIABLE");
    info->setReturnType(typePointer);

    if(symbolTable.lookUpCurrentScope(idName)) print_multiple_dec_error(idName);
    else {
        parameter p;
        p.paramName = idName;
        p.paramType = idType;
        asm_var_param_list.push_back(p);
    }

    if(varType != "void") {
        symbolTable.insertSymbol(*info);
        dataSegment.insert(info -> getVarAsm());
    }
    print_code(str);
}

void process_declaration_list_fourth(string str, string idName, string idType) {
    print_rule("declaration_list : ID LTHIRD CONST_INT RTHIRD");

    SymbolInfo *info = new SymbolInfo(idName, idType);
    info->setSpeciesType("ARRAY");
    info->setReturnType(typePointer);

    if(symbolTable.lookUpCurrentScope(idName)) print_multiple_dec_error(idName);
    else {
        parameter p;
        p.paramName = idName;
        p.paramType = idType;
        asm_var_param_list.push_back(p);
    }

    if(varType != "void") {
        symbolTable.insertSymbol(*info);
        dataSegment.insert(info -> getVarAsm());
    }
    print_code(str);
}

void process_statements_statement_first(string str) {
    print_rule("statements : statement");
    print_code(str);
}

void process_statements_statement_second(string str) {
    print_rule("statements : statements statement");
    print_code(str);
}

void process_statements_statement_third(string str) {
    print_rule("statements : statements func_declaration");
    print_code(str);
}

void process_statements_statement_fourth(string str) {
    print_rule("statements : statements func_definition");
    print_code(str);
}

void process_statements_statement_fifth(string str) {
    print_rule("statements : func_declaration");
    print_code(str);
}

void process_statements_statement_sixth(string str) {
    print_rule("statements : func_definition");
    print_code(str);
}

void process_statement_var_declaration(string str) {
    print_rule("statement : var_declaration");
    print_code(str);
}

void process_statement_expression_statement(string str) {
    print_rule("statement : expression_statement");
    print_code(str);
}

void process_statement_compound_statement(string str) {
    print_rule("statement : compound_statement");
    print_code(str);
}

void process_statement_for(string str) {
    print_rule("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");
    print_code(str);
}

void process_statement_if_first(string str) {
    print_rule("statement : IF LPAREN expression RPAREN statement");
    print_code(str);
}

void process_statement_if_second(string str) {
    print_rule("statement : IF LPAREN expression RPAREN statement ELSE statement");
    print_code(str);
}

void process_statement_while(string str) {
    print_rule("statement : WHILE LPAREN expression RPAREN statement");
    print_code(str);
}

void process_statement_println(string str, string idName) {
    print_rule("statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
    if(!symbolTable.lookUpSymbol(idName))  print_undec_variable_error(idName);
    print_code(str);
}

void process_statement_return(string str, string expr_type) {
    print_rule("statement : RETURN expression SEMICOLON");

    SymbolInfo *info = symbolTable.lookUpSymbol(funcPointers.back());
    if(info) {
        if (info->getReturnType() == "void") {
            print_void_return_error();
            print_code(str);
            return;
        }

        if (info->getReturnType() != "float" && expr_type != info->getReturnType())
            print_expr_returnType_mismatch_error();
    }

    print_code(str);
}

void process_expression_statement_first(string str) {
    print_rule("expression_statement : SEMICOLON");
    print_code(str);
}

void process_expression_statement_second(string str) {
    print_rule("expression_statement : expression SEMICOLON");
    print_code(str);
}

void process_variable_first() {
    print_rule("variable : ID");
}

void process_variable_second() {
    print_rule("variable : ID LTHIRD expression RTHIRD");
}

void process_expression_logic_expression(string str) {
    print_rule("expression : logic_expression");
    print_code(str);
}

void process_expression_variable(string str, string var_type, string logic_exp_type) {
    print_rule("expression : variable ASSIGNOP logic_expression");

    if(var_type == "NOTHING" || logic_exp_type == "NOTHING") {
        print_code(str);
        return;
    }
    if(var_type == "void" || logic_exp_type == "void") print_void_return_error();
    else if(var_type != logic_exp_type && var_type != "float") print_type_mismatch_error();

    print_code(str);
}

void process_logic_expression_first(string str) {
    print_rule("logic_expression : rel_expression");
    print_code(str);
}

void process_logic_expression_second(string str, string rel_expr_type1, string rel_expr_type2) {
    print_rule("logic_expression : rel_expression LOGICOP rel_expression");
    if(rel_expr_type1 == "void" || rel_expr_type2 == "void") print_void_return_error();
//    else if(rel_expr_type1 != "int" || rel_expr_type2 != "int") print_invalid_operand_LOGICOP_error();
    print_code(str);
}

void process_rel_expression_first(string str) {
    print_rule("rel_expression : simple_expression");
    print_code(str);
}

void process_rel_expression_second(string str, string simple_expr_type1, string simple_expr_type2) {
    print_rule("rel_expression : simple_expression RELOP simple_expression");
    if(simple_expr_type1 == "void" || simple_expr_type2 == "void") print_void_return_error();
//    else if(simple_expr_type1 != "int" || simple_expr_type2 != "int") print_invalid_operand_RELOP_error();
    print_code(str);
}

void process_simple_expression_first(string str) {
    print_rule("simple_expression : term");
    print_code(str);
}

void process_simple_expression_second(string str, string simple_expr_type, string term_type) {
    print_rule("simple_expression : simple_expression ADDOP term");
    if(simple_expr_type == "void" || term_type == "void") print_void_return_error();
    print_code(str);
}

void process_term_first(string str) {
    print_rule("term : unary_expression");
    print_code(str);
}

void process_term_second(string str, string term_type, string unary_name, string unary_type, string operatorName) {
    print_rule("term : term MULOP unary_expression");

    if(term_type == "void" || unary_type == "void") print_void_return_error();

    if(operatorName == "%") {
        if(term_type != "int" || unary_type != "int")  print_invalid_operand_modulus_error();
        if(unary_name == "0")  print_modulus_by_zero_error();
    }

    print_code(str);
}

void process_unary_expression_first(string str) {
    print_rule("unary_expression : ADDOP unary_expression");
    print_code(str);
}

void process_unary_expression_second(string str) {
    print_rule("unary_expression : NOT unary_expression");
    print_code(str);
}

void process_unary_expression_third(string str) {
    print_rule("unary_expression : factor");
    print_code(str);
}

void process_factor_variable(string str) {
    print_rule("factor : variable");
    print_code(str);
}

string process_factor_ID(string str, string idName) {
    print_rule("factor : ID LPAREN argument_list RPAREN");

    SymbolInfo *found = symbolTable.lookUpSymbol(idName);
    if(!found) {
        print_undec_function_error(idName);
        param_list.clear();
        print_code(str);
        return "";
    }

    vector <parameter> found_params = found->getFuncParamList();
    if (found_params.size() != param_list.size()) print_argument_length_mismatch_error(idName);

    for (int i = 0; i < min(found_params.size(), param_list.size()); i++) {
        if ((found_params[i].p_returnType != param_list[i].p_returnType) &&
            (found_params[i].p_returnType != "float" || param_list[i].p_returnType != "int")) {
            print_th_argument_mismatch_error(i+1, idName);
            break;
        }
    }

    print_code(str);
    param_list.clear();
    return found -> getReturnType();
}

void process_factor_LPAREN(string str) {
    print_rule("factor : LPAREN expression RPAREN");
    print_code(str);
}

void process_factor_CONST_INT(string str) {
    print_rule("factor : CONST_INT");
    print_code(str);
}

void process_factor_CONST_FLOAT(string str) {
    print_rule("factor : CONST_FLOAT");
    print_code(str);
}

void process_factor_INCOP(string str) {
    print_rule("factor : variable INCOP");
    print_code(str);
}

void process_factor_DECOP(string str) {
    print_rule("factor : variable DECOP");
    print_code(str);
}

void process_argument_list_first(string str) {
    print_rule("argument_list : arguments");
    print_code(str);
}

void process_argument_list_second(string str) {
    print_rule("argument_list : ");
    print_code(str);
}

void process_arguments_first(string str, string name, string type, string species, string ret_type) {
    print_rule("arguments : arguments COMMA logic_expression");
    print_code(str);

    param.paramName = name;
    param.paramType = type;
    param.p_speciesType = species;
    param.p_returnType = ret_type;
    param_list.push_back(param);
}

void process_arguments_second(string str, string name, string type, string species, string ret_type) {
    print_rule("arguments : logic_expression");
    print_code(str);

    param.paramName = name;
    param.paramType = type;
    param.p_speciesType = species;
    param.p_returnType = ret_type;
    param_list.push_back(param);
}

#endif //Syntax_Analyzer_1805004_BISONUTILS_H