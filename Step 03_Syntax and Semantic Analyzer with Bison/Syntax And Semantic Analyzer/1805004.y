
%{
#ifndef Syntax_Analyzer_1805004_y
#define Syntax_Analyzer_1805004_y

#include "1805004_BisonUtils.h"

#endif //Syntax_Analyzer_1805004_y
%}

%define parse.error verbose

%union {
	SymbolInfo* symbolInfo;
}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE 
%token INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON PRINTLN
%token <symbolInfo> CONST_INT CONST_FLOAT ADDOP MULOP RELOP LOGICOP ID

%type <symbolInfo> start program unit var_declaration func_declaration func_definition
%type <symbolInfo> type_specifier parameter_list compound_statement statements statement declaration_list 
%type <symbolInfo> expression_statement variable expression logic_expression rel_expression simple_expression 
%type <symbolInfo> term unary_expression factor argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%destructor { discard_symbol($$); } <symbolInfo>


%%

start : program
	    {
		    process_start_program();
		    $$ = new SymbolInfo($1 -> getName(), "NON-TERMINAL");
        }
	    ;

program : program unit
        {
		    string str = $1 -> getName() + "" + $2 -> getName();
		    process_program_programUnit(str);
            $$ = new SymbolInfo(str, "NON-TERMINAL");
	    }
	    | unit
	    {
			string str = $1 -> getName();
		    process_unit(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
	    }
		| error
		{
			$$ = new SymbolInfo("", "");
			$$ -> setSpeciesType("");
			$$ -> setReturnType("");
		}
		| program error
		{
			$$ = new SymbolInfo("", "");
			$$ = $1;
			outputLog << $1 -> getName() << '\n' << '\n';
		}
	    ;
	
unit : var_declaration
        {
			string str = $1 -> getName();
            process_unit_var_declaration(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
	    }
        | func_declaration
 	    {
			string str = $1 -> getName();
		    process_unit_func_declaration(str);
			$$ = new SymbolInfo(str, "FUNC-DECLARE");
	    }
        | func_definition
	    {
			string str = $1 -> getName();
		    process_unit_func_definition(str);
			$$ = new SymbolInfo(str, "FUNC-DEFINE");
	    }
        ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN 
        {
			string funcName = $2 -> getName();
			string returnType = $1 -> getName();
            process_func_declaration_with_params(funcName, returnType);

        } SEMICOLON
		{
			string str = $1 -> getName() + " " + $2 -> getName() + "(" + $4 -> getName() +  ");\n";
            process_func_declaration_first(str, $2 -> getName());
			$$ = new SymbolInfo(str, "FUNCTION");
			$$ -> setSpeciesType("FUNCTION");
		}
		| type_specifier ID LPAREN RPAREN
		{
			string funcName = $2 -> getName();
			string returnType = $1 -> getName();
            process_func_declaration_without_params(funcName, returnType);

		} SEMICOLON
		{
			string str = $1 -> getName() + " " + $2 -> getName() + "();\n";
			process_func_declaration_second(str, $2 -> getName());
			$$ = new SymbolInfo(str, "FUNCTION");
			$$ -> setSpeciesType("FUNCTION");
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN
        {
			string funcName = $2 -> getName();
			string returnType = $1 -> getName();
            process_func_definition_with_params(funcName, returnType);

		} compound_statement 
		{
			string str = $1 -> getName() + " " + $2 -> getName() + "(" + $4 -> getName() + ")" + $7 -> getName();
            process_func_definition_first(str);
			$$ = new SymbolInfo(str, "FUNCTION");
			$$ -> setSpeciesType("FUNCTION");
		}
		| type_specifier ID LPAREN RPAREN
		{
            string funcName = $2 -> getName();
			string returnType = $1 -> getName();
            process_func_definition_without_params(funcName, returnType);

		} compound_statement
 		{
			string str = $1 -> getName() + " " + $2 -> getName() + "()" + $6 -> getName();
			process_func_definition_second(str);
			$$ = new SymbolInfo(str, "FUNCTION");
			$$ -> setSpeciesType("FUNCTION");
		}
		;				

parameter_list : parameter_list COMMA type_specifier ID
        {
			string str = $1 -> getName() + "," + $3 -> getName() + " " + $4 -> getName(); 
			process_parameter_list_first(str, $4 -> getName(), $4 -> getType(), $3 -> getName());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
		| parameter_list COMMA type_specifier
		{
			string str = $1 -> getName() + "," + $3 -> getName(); 
			process_parameter_list_second(str, $3 -> getName(), $3 -> getType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
 		| type_specifier ID
		{
			string str = $1 -> getName() + " " + $2 -> getName();
			process_parameter_list_third(str, $2 -> getName(), $2 -> getType(), $1 -> getName());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
		| type_specifier
		{
			string str = $1 -> getName();
			process_parameter_list_fourth(str, $1 -> getName(), $1 -> getType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
		| error
		{
			$$ = new SymbolInfo("", "");
			$$ -> setSpeciesType("");
			$$ -> setReturnType("");
		}
		| parameter_list error
		{
			$$ = new SymbolInfo("", "");
			$$ = $1;
			outputLog << $1 -> getName() << '\n' << '\n';
		}
 		;

compound_statement : LCURL start_scope statements RCURL
        {
			string str = "{\n" + $3 -> getName() + "}\n";
            process_compound_statement_first(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			symbolTable.print_allScopeTables();
			symbolTable.exitScope();
			if(symbolTable.getCurrentScopeId() == "1") funcPointers.clear();
		}
 		| LCURL start_scope RCURL
		{
			string str = "{}\n";
            process_compound_statement_second(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			symbolTable.print_allScopeTables();
			symbolTable.exitScope();
			if(symbolTable.getCurrentScopeId() == "1") funcPointers.clear();
		}
 	    ;

start_scope :
        {
            symbolTable.enterScope();
			process_start_scope();
		}
		;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
 		{
			string str = $1 -> getName() + " " + $2 -> getName() + ";\n"; 
			process_var_declaration(str, $1 -> getName());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
		;
 		 
type_specifier : INT
        {
			process_int();
			$$ = new SymbolInfo("int", "NON-TERMINAL");
		}
 		| FLOAT
		{
			process_float();
			$$ = new SymbolInfo("float", "NON-TERMINAL");
		}
 		| VOID
		{
			process_void();
			$$ = new SymbolInfo("void", "NON-TERMINAL");
		}
 		;
 		
declaration_list : declaration_list COMMA ID
        {
			string str = $1 -> getName() + "," + $3 -> getName();
			process_declaration_list_first(str, $3 -> getName(), $3 -> getType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
 		| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		{
			string str = $1 -> getName() + "," + $3 -> getName() + "[" + $5 -> getName() + "]";
			process_declaration_list_second(str, $3 -> getName(), $3 -> getType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
 	    | ID
		{
			string str = $1 -> getName();
			process_declaration_list_third(str, $1 -> getName(), $1 -> getType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
 		| ID LTHIRD CONST_INT RTHIRD
		{
			string str = $1 -> getName() + "[" + $3 -> getName() + "]";
			process_declaration_list_fourth(str, $1 -> getName(), $1 -> getType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
		| error
		{
			$$=new SymbolInfo("", "");
			$$ -> setSpeciesType("");
			$$ -> setReturnType("");
		}
		| declaration_list error
		{
			$$=new SymbolInfo("", "");
			$$=$1;
			outputLog << $1 -> getName() << '\n' << '\n';
		}
 		;
 		
statements : statement
        {
			if($1 -> getName() != "") {
			   string str = $1 -> getName();
		       process_statements_statement_first(str);
			   $$ = new SymbolInfo(str, "NON-TERMINAL");
			} else {
               $$ = new SymbolInfo("", "");
			}
	    }
	    | statements statement
	    {
			string str = $1 -> getName() + "" + $2 -> getName();
		    process_statements_statement_second(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
	    }
		| statements func_declaration
		{
			string str = $1 -> getName() + "" + $2 -> getName();
			process_statements_statement_third(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
		| statements func_definition
		{
			string str = $1 -> getName() + "" + $2 -> getName();
			process_statements_statement_fourth(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
		| func_declaration
		{
			string str = $1 -> getName();
			process_statements_statement_fifth(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
		}
		| func_definition
		{
			string str = $1 -> getName();
			process_statements_statement_sixth(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
		}
		| error
		{
			$$=new SymbolInfo("", "");
			$$ -> setSpeciesType("");
			$$ -> setReturnType("");
		}
		| statements error
		{
			$$=new SymbolInfo("", "");
			$$=$1;
			outputLog << $1 -> getName() << '\n' << '\n';
		}
	    ;
	   
statement : var_declaration
        {
			string str = $1 -> getName();
            process_statement_var_declaration(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    | expression_statement
		{
			string str = $1 -> getName();
			process_statement_expression_statement(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    | compound_statement
		{
			string str = $1 -> getName();
			process_statement_compound_statement(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	    {
			string expr1 = $3 -> getName();
			string expr2 = $4 -> getName();
			if(expr1.length() != 0 && expr1.back() == '\n') expr1 = expr1.substr(0, expr1.size()-1);
			if(expr2.length() != 0 && expr2.back() == '\n') expr2 = expr2.substr(0, expr2.size()-1);
			string str = "for(" + expr1 + "" + expr2 + "" + $5 -> getName() + ")" + $7 -> getName();
			process_statement_for(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
		| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
		{
			string str = "if (" + $3 -> getName() + ")" + $5 -> getName();
			process_statement_if_first(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    | IF LPAREN expression RPAREN statement ELSE statement
	    {
			string str = "if (" + $3 -> getName() + ")" + $5 -> getName() + "else\n" + $7 -> getName();
			process_statement_if_second(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
		| WHILE LPAREN expression RPAREN statement
		{
			string str = "while (" + $3 -> getName() + ")" + $5 -> getName();
			process_statement_while(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    | PRINTLN LPAREN ID RPAREN SEMICOLON
		{
			string str = "printf(" + $3 -> getName() + ");\n";
			process_statement_println(str, $3 -> getName());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    | RETURN expression SEMICOLON
		{
			string str = "return " + $2 -> getName() + ";\n";
			process_statement_return(str, $2 -> getReturnType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    ;
	  
expression_statement : SEMICOLON
        {
			string str = ";\n";
			process_expression_statement_first(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}			
		| expression SEMICOLON 
		{
			string str = $1 -> getName() + ";\n";
			process_expression_statement_second(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
		;
	  
variable : ID 
    	{
			string str = $1 -> getName();
            process_variable_first();
			SymbolInfo *info = symbolTable.lookUpSymbol(str);
            if(info) {
               if(info -> getSpeciesType() == "ARRAY")  print_array_type_mismatch_error(str);
			   $$ = new SymbolInfo(str, "NON-TERMINAL");
               $$ = info;
            } else {
               print_undec_variable_error(str);
               $$ = new SymbolInfo(str, "NON-TERMINAL");
               $$->setSpeciesType("VARIABLE");
               $$->setReturnType("NOTHING");
			}
			print_code(str);
		}	
	    | ID LTHIRD expression RTHIRD 
		{
			string str = $1 -> getName() + "[" + $3 -> getName() + "]";
			process_variable_second();

			SymbolInfo *info = symbolTable.lookUpSymbol($1 -> getName());
            if(info) {
               if(info -> getSpeciesType() != "ARRAY")  print_not_array_error($1 -> getName());

               $$ = new SymbolInfo(str, "NON-TERMINAL");
			   $$->setSpeciesType("ARRAY");
               $$->setReturnType(info -> getReturnType());

			   if($3->getReturnType()=="float")  print_wrong_array_index_error();
            } else {
               print_undec_variable_error(str);
               $$ = new SymbolInfo($1 -> getName(), "ARRAY");
               $$->setSpeciesType("ARRAY");
               $$->setReturnType("NOTHING");
		    }

			print_code(str);
		}
	    ;
	 
expression : logic_expression	
        {
			string str = $1 -> getName();
			process_expression_logic_expression(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
		}
	    | variable ASSIGNOP logic_expression
		{
			string str = $1 -> getName() + "=" + $3 -> getName();
            process_expression_variable(str, $1 -> getReturnType(), $3 -> getReturnType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    ;
			
logic_expression : rel_expression
        {
			string str = $1 -> getName();
			process_logic_expression_first(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
		}
		| rel_expression LOGICOP rel_expression
		{
			string str = $1 -> getName() + "" + $2 -> getName() + "" + $3 -> getName();
            process_logic_expression_second(str, $1 -> getReturnType(), $3 -> getReturnType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType("int");
		}
	    ;
			
rel_expression : simple_expression
        {
			string str = $1 -> getName();
			process_rel_expression_first(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
		}
		| simple_expression RELOP simple_expression
		{
			string str = $1 -> getName() + "" + $2 -> getName() + "" + $3 -> getName();
            process_rel_expression_second(str, $1 -> getReturnType(), $3 -> getReturnType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType("int");
		}
		;
				
simple_expression : term 
        {
			string str = $1 -> getName();
			process_simple_expression_first(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
		}
		| simple_expression ADDOP term 
		{
			string str = $1 -> getName() + "" + $2 -> getName() + "" + $3 -> getName();
            process_simple_expression_second(str, $1 -> getReturnType(), $3 -> getReturnType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");

			if($1 -> getReturnType() == "float" || $3 -> getReturnType() == "float") {
                $$ -> setReturnType("float");
			} else {
                $$ -> setReturnType("int");
			} 
		}
	    ;
					
term : unary_expression
        {
			string str = $1 -> getName();
			process_term_first(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
		}
        |  term MULOP unary_expression
		{
			string str = $1 -> getName() + "" + $2 -> getName() + "" + $3 -> getName();
            process_term_second(str, $1 -> getReturnType(), $3 -> getName(), $3 -> getReturnType(), $2 -> getName());
			$$ = new SymbolInfo(str, "NON-TERMINAL");

			if($2 -> getName() != "%") {
               if($1 -> getReturnType() == "float" || $3 -> getReturnType() == "float") {
                $$ -> setReturnType("float");
			   } else {
                $$ -> setReturnType("int");
			   }
			} else {
				$$ -> setReturnType("int");
			}
		}
        ;

unary_expression : ADDOP unary_expression
        {
			string str = $1 -> getName() + "" + $2 -> getName();
			process_unary_expression_first(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType($2 -> getReturnType());
		}  
		| NOT unary_expression 
		{
			string str = "!" + $2 -> getName();
			process_unary_expression_second(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType($2 -> getReturnType());
		}
		| factor 
		{
			string str = $1 -> getName();
			process_unary_expression_third(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
		}
		;
	
factor : variable 
        {
			string str = $1 -> getName();
			process_factor_variable(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
		}
	    | ID LPAREN argument_list RPAREN
		{
			string str = $1 -> getName() + "(" + $3 -> getName() + ")";
			string setType = process_factor_ID(str, $1 -> getName());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			if(setType != "") $$ -> setReturnType(setType);
		}
	    | LPAREN expression RPAREN
		{
			string str = "(" + $2 -> getName() + ")";
			process_factor_LPAREN(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType($2 -> getReturnType());
		}
	    | CONST_INT
		{
			string str = $1 -> getName();
			process_factor_CONST_INT(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType("int");
		} 
	    | CONST_FLOAT
		{
			string str = $1 -> getName();
			process_factor_CONST_FLOAT(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType("float");
		}
	    | variable INCOP 
		{
			string str = $1 -> getName() + "++";
			process_factor_INCOP(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    | variable DECOP
		{
			string str = $1 -> getName() + "--";
			process_factor_DECOP(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    ;
	
argument_list : arguments
        {
			string str = $1 -> getName();
            process_argument_list_first(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
		}
		|
		{
			string str = " ";
            process_argument_list_second(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    ;
	
arguments : arguments COMMA logic_expression
        {
			string str = $1 -> getName() + "," + $3 -> getName();
            process_arguments_first(str, $3 -> getName(), $3 -> getType(), $3 -> getSpeciesType(), $3 -> getReturnType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
		}
	    | logic_expression
		{
			string str = $1 -> getName();
            process_arguments_second(str, $1 -> getName(), $1 -> getType(), $1 -> getSpeciesType(), $1 -> getReturnType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
		}
		| error
		{
			$$ = new SymbolInfo("", "");
			$$ -> setSpeciesType("");
			$$ -> setReturnType("");
		}
		| arguments error
		{
			$$ = new SymbolInfo("", "");
			$$ = $1;
			outputLog << $1 -> getName() << '\n' << '\n';
		}
	    ; 

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
    yyparse();

    outputLog << "Total lines: " << line_count << '\n';
    outputLog << "Total errors: " << error_count << '\n';

    fclose(yyin);
    errorOut.close();
    logOut.close();

    return 0;
}