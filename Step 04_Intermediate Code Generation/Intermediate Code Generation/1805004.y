
%{
#ifndef Syntax_Analyzer_1805004_y
#define Syntax_Analyzer_1805004_y

#include "1805004_ICGUtils.h"

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
			$$ -> setAsmCode($$ -> getAsmCode() + $1 -> getAsmCode());
			printAssemblyCode($$ -> getAsmCode());
			printOptimizedAssemblyCode();
        }
	    ;

program : program unit
        {
		    string str = $1 -> getName() + "" + $2 -> getName();
		    process_program_programUnit(str);
            $$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setAsmCode($$ -> getAsmCode() + $1 -> getAsmCode() + $2 -> getAsmCode());
	    }
	    | unit
	    {
			string str = $1 -> getName();
		    process_unit(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setAsmCode($$ -> getAsmCode() + $1 -> getAsmCode());
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
			$$ -> setAsmCode($$ -> getAsmCode() + $1 -> getAsmCode());
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

            int offset = $1 -> getName() == "void" ? 14 : 16;
			string funcName = $2 -> getName();

            asmCode = $$ -> getAsmCode() + funcName + " PROC\n";
			asmCode += "PUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\nPUSH BP\nPUSH SI\nMOV BP, SP\n";

			int available_param_count = available_param_list.size() - 1;
			int c = 0;
			for(int i = available_param_count; i >= 0; i--) {
				string p = available_param_list[i];
                asmCode += "MOV AX, WORD PTR[BP + " + to_string(offset + c*2) + "]\nMOV " + p + ", AX\n";
			    c++;
            }

			asmCode += $7 -> getAsmCode();

            if($1 -> getName() == "void") {
				asmCode += "POP SI\nPOP BP\nPOP DX\nPOP CX\nPOP BX\nPOP AX\nRET 0\n\n";
			}

			asmCode += funcName + " ENDP\n\n";
			$$ -> setAsmCode(asmCode);
			available_param_list.clear();
			available_asm_var_param_list.clear();
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

            string funcName = $2 -> getName();
			asmCode = funcName + " PROC\n";

            if(funcName == "main") {
				asmCode += "\nMOV AX, @DATA\nMOV DS, AX\n";
			} else {
				asmCode += "PUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\nPUSH BP\nPUSH SI\nMOV BP, SP\n";
			}

			int available_param_count = available_param_list.size() - 1;
			int c = 0;
			for(int i = available_param_count; i >= 0; i--) {
				string p = available_param_list[i];
                asmCode += "MOV AX, WORD PTR[BP + " + to_string(14 + c*2) + "]\nMOV " + p + ", AX\n";
			    c++;
            }

			asmCode += $6 -> getAsmCode();

            if(funcName == "main") {
				asmCode += "\nMOV AH, 4CH\nINT 21H\n";
			} else if($1 -> getName() == "void") {
				asmCode += "POP SI\nPOP BP\nPOP DX\nPOP CX\nPOP BX\nPOP AX\nRET 0\n";
			}

			asmCode += funcName + " ENDP\n\n";    
			$$ -> setAsmCode(asmCode);
			available_param_list.clear();
			available_asm_var_param_list.clear();
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
			$$ -> setAsmCode($$ -> getAsmCode() + $3 -> getAsmCode());
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
			arraySegment.insert(make_pair($3 -> getName(), $5 -> getName()));
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
			arraySegment.insert(make_pair($1 -> getName(), $3 -> getName()));
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
			   $$ -> setAsmCode($$ -> getAsmCode() + $1 -> getAsmCode());
			} else {
               $$ = new SymbolInfo("", "");
			}
	    }
	    | statements statement
	    {
			string str = $1 -> getName() + "" + $2 -> getName();
		    process_statements_statement_second(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setAsmCode($$ -> getAsmCode() + $1 -> getAsmCode() + $2 -> getAsmCode());
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
			asmCode = $$ -> getAsmCode() + $1 -> getAsmCode();
			$$ -> setAsmCode(annotateAssembly(str, asmCode));
		}
	    | expression_statement
		{
			string str = $1 -> getName();
			process_statement_expression_statement(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			asmCode = $$ -> getAsmCode() + $1 -> getAsmCode();
			$$ -> setAsmCode(annotateAssembly(str, asmCode));
		}
	    | compound_statement
		{
			string str = $1 -> getName();
			process_statement_compound_statement(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setAsmCode($$ -> getAsmCode() + $1 -> getAsmCode());
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

            string label1 = newLabel();
			string label2 = newLabel();

			asmCode = $$ -> getAsmCode() + $3 -> getAsmCode() + label1 + ":\n";
			asmCode += $4 -> getAsmCode() + "CMP " + $4 -> getTempVarAsm() + ", 0\nJE " + label2 + "\n";
			asmCode += $7 -> getAsmCode() + $5 -> getAsmCode() + "JMP " + label1 + "\n" + label2 + ":\n";
			$$ -> setAsmCode(annotateAssembly(str, asmCode));
		}
		| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
		{
			string str = "if (" + $3 -> getName() + ")" + $5 -> getName();                
			process_statement_if_first(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");

			string label = newLabel();

			asmCode = $$ -> getAsmCode() + $3 -> getAsmCode() + "CMP " + $3 -> getTempVarAsm() + ", 0\nJE " + label + "\n";
			asmCode += $5 -> getAsmCode() + label + ":\n";
			$$ -> setAsmCode(annotateAssembly(str, asmCode));
		}
	    | IF LPAREN expression RPAREN statement ELSE statement
	    {
			string str = "if (" + $3 -> getName() + ")" + $5 -> getName() + "else\n" + $7 -> getName();
			process_statement_if_second(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");

			string label1 = newLabel();
			string label2 = newLabel();

			asmCode = $$ -> getAsmCode() + $3 -> getAsmCode() + "CMP " + $3 -> getTempVarAsm() + ", 0\nJE " + label2 + "\n";
			asmCode += $5 -> getAsmCode() + "JMP " + label1 + "\n" + label2 + ":\n" + $7 -> getAsmCode() + label1 + ":\n";
			$$ -> setAsmCode(annotateAssembly(str, asmCode));
		}
		| WHILE LPAREN expression RPAREN statement
		{
			string str = "while (" + $3 -> getName() + ")" + $5 -> getName();
			process_statement_while(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");

			string label1 = newLabel();
			string label2 = newLabel();

			asmCode = $$ -> getAsmCode() + label1 + ":\n" + $3 -> getAsmCode();
			asmCode += "CMP " + $3 -> getTempVarAsm() + ", 0\nJE " + label2 + "\n";
			asmCode += $5 -> getAsmCode() + "JMP " + label1 + "\n" + label2 + ":\n";
			$$ -> setAsmCode(annotateAssembly(str, asmCode));
		}
	    | PRINTLN LPAREN ID RPAREN SEMICOLON
		{
			string str = "println(" + $3 -> getName() + ");\n";
			process_statement_println(str, $3 -> getName());
			$$ = new SymbolInfo(str, "NON-TERMINAL");

			SymbolInfo *info = symbolTable.lookUpSymbol($3 -> getName());
			if(info) {
                asmCode = $$ -> getAsmCode() + info -> getAsmCode() + "PUSH " + info -> getVarAsm() 
			        + "\nCALL PRINTLN\nPOP " + info -> getVarAsm() + "\n";
			}

			$$ -> setAsmCode(annotateAssembly(str, asmCode));
		}
	    | RETURN expression SEMICOLON
		{
			string str = "return " + $2 -> getName() + ";\n";
			process_statement_return(str, $2 -> getReturnType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");

            asmCode = $$ -> getAsmCode() + $2 -> getAsmCode();
			if(scoped_func != "main") {
				asmCode += "MOV BP, SP\nMOV AX, " + $2 -> getTempVarAsm() + "\nMOV WORD PTR[BP + 14], AX\n";
				asmCode += "POP SI\nPOP BP\nPOP DX\nPOP CX\nPOP BX\nPOP AX\nRET 0\n";
			}
			$$ -> setAsmCode(asmCode);
			delete_temp_for_efficient_code($2 -> getTempVarAsm());
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
			$$ -> setAsmCode($$ -> getAsmCode() + $1 -> getAsmCode());
			$$ -> setTempVarAsm($1 -> getTempVarAsm());
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
			$$ -> setTempVarAsm(info -> getVarAsm());
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

            string data = newTemp();
			asmCode = $$ -> getAsmCode() + $1 -> getAsmCode() + $3 -> getAsmCode();
			asmCode += "LEA SI, " + info -> getVarAsm() + "\nADD SI, " + $3 -> getTempVarAsm() + "\nADD SI, " + $3 -> getTempVarAsm() + "\n";
			asmCode += "MOV AX, [SI]\nMOV " + data + ", AX\n";
			$$ -> setTempVarAsm(data);
			$$ -> setAsmCode(asmCode);
			delete_temp_for_efficient_code($3 -> getTempVarAsm());
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

			asmCode = $$ -> getAsmCode() + $1 -> getAsmCode() + $3 -> getAsmCode();

			SymbolInfo *info = symbolTable.lookUpSymbol($1 -> getName());

			if(info) {
               if($1 -> getSpeciesType() == "ARRAY") {
                 asmCode += "LEA SI, " + info -> getVarAsm() + "\nADD SI, " + $1 -> getTempVarAsm() + "\nADD SI, " + $1 -> getTempVarAsm();
			     asmCode += "\nMOV CX, " + $3 -> getTempVarAsm() + "\nMOV [SI], CX\n";
			     $$ -> setTempVarAsm("[SI]");
			   } else if($1 -> getSpeciesType() == "VARIABLE") {
                 asmCode += "MOV DX, " + $3 -> getTempVarAsm() + "\nMOV " + info -> getVarAsm() + ", DX\n";
			     $$ -> setTempVarAsm(info -> getVarAsm());
			   }

			   $$ -> setAsmCode(asmCode);
			   delete_temp_for_efficient_code($3 -> getTempVarAsm());
			}
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

			string data = newTemp();
            string label = newLabel();

			asmCode = $$ -> getAsmCode() + $1 -> getAsmCode() + $3 -> getAsmCode();
			
			if($2 -> getName() == "&&") {
                asmCode += "MOV " + data + ", 0\n" + "CMP " + $1 -> getTempVarAsm() + ", 0\n" + "JE " + label + "\n";
				asmCode += "CMP " + $3 -> getTempVarAsm() + ", 0\n" + "JE " + label + "\n";
				asmCode += "MOV " + data + ", 1\n" + label + ":\n";
			} else if($2 -> getName() == "||") {
				asmCode += "MOV " + data + ", 1\n" + "CMP " + $1 -> getTempVarAsm() + ", 0\n" + "JNE " + label + "\n";
				asmCode += "CMP " + $3 -> getTempVarAsm() + ", 0\n" + "JNE " + label + "\n";
				asmCode += "MOV " + data + ", 0\n" + label + ":\n";
			}

			$$ -> setTempVarAsm(data);
			$$ -> setAsmCode(asmCode);
			delete_temp_for_efficient_code($1 -> getTempVarAsm(), $3 -> getTempVarAsm());
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

			string data = newTemp();
            string label = newLabel();

			asmCode = $$ -> getAsmCode() + $1 -> getAsmCode() + $3 -> getAsmCode() + "MOV " + data + ", 1\nMOV AX, " 
			        + $3 ->getTempVarAsm() + "\nCMP "+ $1 ->getTempVarAsm() +", AX\n";

			string commonPart = "\nMOV " + data + ", 0\n" + label + ":\n";

			if($2 -> getName() == "<") {
				asmCode += "JL " + label + commonPart;
			} else if($2 -> getName() == "<=") {
				asmCode += "JLE " + label + commonPart;
			} else if($2 -> getName() == ">") {
				asmCode += "JG " + label + commonPart;
			} else if($2 -> getName() == ">=") {
				asmCode += "JGE " + label + commonPart;
			} else if($2 -> getName() == "==") {
				asmCode += "JE " + label + commonPart;
			} else if($2 -> getName() == "!=") {
				asmCode += "JNE " + label + commonPart;
			}

			$$ -> setTempVarAsm(data);
			$$ -> setAsmCode(asmCode);
			delete_temp_for_efficient_code($1 -> getTempVarAsm(), $3 -> getTempVarAsm());
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

            string data = newTemp();
			asmCode = $$ -> getAsmCode() + $1 -> getAsmCode() + $3 -> getAsmCode();
			asmCode +=  "MOV AX, " + $1 -> getTempVarAsm() + "\nMOV " + data + ", AX\n" + "MOV AX, " + $3 -> getTempVarAsm();

			if($2 -> getName() == "+") {
				asmCode += "\nADD " + data + ", AX\n";
			} else if($2 -> getName() == "-") {
				asmCode += "\nSUB " + data + ", AX\n";
			}

			$$ -> setTempVarAsm(data);
			$$ -> setAsmCode(asmCode);
			delete_temp_for_efficient_code($1 -> getTempVarAsm(), $3 -> getTempVarAsm());
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
            
			string data = newTemp();	
			asmCode = $$ -> getAsmCode() + $1 -> getAsmCode() + $3 -> getAsmCode();

			if($2 -> getName() == "*") {
				asmCode += "MOV AX, " + $3 -> getTempVarAsm() + "\nIMUL " + $1 -> getTempVarAsm() + "\nMOV " + data + ", AX\n";
			} else if($2 -> getName() == "/") {
				asmCode += "MOV AX, " + $1 -> getTempVarAsm() + "\nCWD\nIDIV " + $3 -> getTempVarAsm() + "\nMOV " + data + ", AX\n";
			} else if($2 -> getName() == "%") {
				asmCode += "MOV AX, " + $1 -> getTempVarAsm() + "\nCWD\nIDIV " + $3 -> getTempVarAsm() + "\nMOV " + data + ", DX\n";
			}

			// asmCode += "MOV DX, 0\n";

			$$ -> setTempVarAsm(data);
			$$ -> setAsmCode(asmCode);
			delete_temp_for_efficient_code($1 -> getTempVarAsm(), $3 -> getTempVarAsm());
		}
        ;

unary_expression : ADDOP unary_expression
        {
			string str = $1 -> getName() + "" + $2 -> getName();
			process_unary_expression_first(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType($2 -> getReturnType());

			asmCode = $$ -> getAsmCode() + $2 -> getAsmCode();
			string data = newTemp();

			if($1 -> getName() == "+") {
                asmCode += "MOV AX, " + $2 -> getTempVarAsm() + "\nMOV " + data + ", AX\n";
			} else if($1 -> getName() == "-") {
                asmCode += "MOV AX, " + $2 -> getTempVarAsm() + "\nMOV " + data + ", AX\nNEG " + data + "\n";
			}

			$$ -> setAsmCode(asmCode);
			$$ -> setTempVarAsm(data);
			delete_temp_for_efficient_code($2 -> getTempVarAsm());
		}  
		| NOT unary_expression 
		{
			string str = "!" + $2 -> getName();
			process_unary_expression_second(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType($2 -> getReturnType());

			string data = newTemp();
			string label = newLabel();
			asmCode = $$ -> getAsmCode() + $2 -> getAsmCode() + "\nCMP " + $2 -> getTempVarAsm() + ", 0\nMOV "
			        + data + ", 0\nJNE " + label + "\nMOV " + data + ", 1\n" + label + ":\n";
		    $$ -> setAsmCode(asmCode);
			$$ -> setTempVarAsm(data);
			delete_temp_for_efficient_code($2 -> getTempVarAsm());
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

			asmCode = $$ -> getAsmCode() + $3 -> getAsmCode();
			if(setType != "") {
				$$ -> setReturnType(setType);

			    for(string p:available_param_list) {
                  asmCode += "PUSH " + p + "\n";
                } 	
              
			    for(string p:available_asm_var_param_list) {
                  asmCode += "PUSH " + p + "\n";
                } 

				for(auto argument:var_asm_arguments.back()) {
					asmCode += "PUSH " + argument + "\n";
				}

				if(setType != "void") {
					asmCode += "PUSH 0\n";
				}

				asmCode += "CALL " + $1 -> getName() + "\n";
				string data;
				if(setType != "void") {
					data = newTemp();
					asmCode += "POP " + data + "\n";
					$$ -> setTempVarAsm(data);
				}

				asmCode += "ADD SP, " + to_string(var_asm_arguments.back().size() * 2) + "\n";

				for(auto p=available_asm_var_param_list.rbegin();p!=available_asm_var_param_list.rend();p++) {
					if(*p == data) continue;
					asmCode += "POP " + *p + "\n";
				}

				int available_param_count = available_param_list.size() - 1;
			    for(int i = available_param_count; i >= 0; i--) {
				   string p = available_param_list[i];
                   asmCode += "POP " + p + "\n";
                }

                param_list.clear();
				var_asm_arguments.pop_back();
			}

			$$ -> setAsmCode(asmCode);
		}
	    | LPAREN expression RPAREN
		{
			string str = "(" + $2 -> getName() + ")";
			process_factor_LPAREN(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType($2 -> getReturnType());
			$$ -> setAsmCode($$-> getAsmCode() + $2 -> getAsmCode());
		    $$ -> setTempVarAsm($2 -> getTempVarAsm());
		}
	    | CONST_INT
		{
			string str = $1 -> getName();
			process_factor_CONST_INT(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType("int");

			string data = newTemp();
			asmCode = $$ -> getAsmCode() + "MOV " + data + ", "+ $1 -> getName() + "\n";
			$$ -> setAsmCode(asmCode);
			$$ -> setTempVarAsm(data);
		} 
	    | CONST_FLOAT
		{
			string str = $1 -> getName();
			process_factor_CONST_FLOAT(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ -> setReturnType("float");
			$$ -> setTempVarAsm(str);
		}
	    | variable INCOP 
		{
			string str = $1 -> getName() + "++";
			process_factor_INCOP(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");

			string data = newTemp();
			asmCode = $$ -> getAsmCode() + "MOV AX, " + $1 -> getTempVarAsm() 
			        + "\nMOV " + data + ", AX\nINC " + $1 -> getTempVarAsm() + "\n";
			$$ -> setAsmCode(asmCode);
			$$ -> setTempVarAsm(data);
		}
	    | variable DECOP
		{
			string str = $1 -> getName() + "--";
			process_factor_DECOP(str);
			$$ = new SymbolInfo(str, "NON-TERMINAL");

			string data = newTemp();
			asmCode = $$ -> getAsmCode() + "MOV AX, " + $1 -> getTempVarAsm() 
			        + "\nMOV " + data + ", AX\nDEC " + $1 -> getTempVarAsm() + "\n";
			$$ -> setAsmCode(asmCode);
			$$ -> setTempVarAsm(data);
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
			var_asm_arguments.emplace_back();
		}
	    ;
	
arguments : arguments COMMA logic_expression
        {
			string str = $1 -> getName() + "," + $3 -> getName();
            process_arguments_first(str, $3 -> getName(), $3 -> getType(), $3 -> getSpeciesType(), $3 -> getReturnType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			var_asm_arguments.back().push_back($3 -> getTempVarAsm());
			$$ -> setAsmCode($$ -> getAsmCode() + $1 -> getAsmCode() + $3 -> getAsmCode());
		}
	    | logic_expression
		{
			string str = $1 -> getName();
            process_arguments_second(str, $1 -> getName(), $1 -> getType(), $1 -> getSpeciesType(), $1 -> getReturnType());
			$$ = new SymbolInfo(str, "NON-TERMINAL");
			$$ = $1;
			var_asm_arguments.emplace_back();
			var_asm_arguments.back().push_back($1 -> getTempVarAsm());
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

	if(error_count != 0) {
	   ofstream codeOut("code.asm");
	   ofstream optimized_codeOut("optimized_code.asm");
	}

    fclose(yyin);
    errorOut.close();
    logOut.close();
	codeOut.close();
	optimized_codeOut.close();

    return 0;
}