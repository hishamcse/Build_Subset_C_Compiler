/*
    Intermediate Code Generation Utilities
    Created by Hisham on 04-AUG-22.
*/

#ifndef INTERMEDIATE_CODE_GENERATION_1805004_ICGUTILS_H
#define INTERMEDIATE_CODE_GENERATION_1805004_ICGUTILS_H

#include "1805004_BisonUtils.h"

ofstream codeOut("code.asm");
ofstream optimized_codeOut("optimized_code.asm");

OutputUtil outputCode(cout, codeOut);
OutputUtil outputOptimized(cout, optimized_codeOut);

string asmCode, optimized_asmCode;
int labelCounter = 0;
vector<vector<string>> var_asm_arguments;
set<string> temps_for_efficient_code;

template<typename ...Strings>
void delete_temp_for_efficient_code(Strings... strings) {
    string args[] { strings... };
    for(auto &temp: args) {
        temps_for_efficient_code.erase(temp);
        available_asm_var_param_list.erase(temp);
    }
}

string newLabel() {
    labelCounter++;
    return "LABEL_" + to_string(labelCounter);
}

string newTemp() {
    int tempCount = 1;
    while (true) {
        string temp = "TEMP_" + to_string(tempCount);
        if(temps_for_efficient_code.find(temp) == temps_for_efficient_code.end()) {
            temps_for_efficient_code.insert(temp);
            available_asm_var_param_list.insert(temp);
            dataSegment.insert(temp);
            return temp;
        }
        tempCount++;
    }
}

string annotateAssembly(string comment, string assembly) {
    for(auto &com: comment) {
        if(com == '\n' || com == ';') {
            com = ' ';
        }
    }
    return "\n;" + comment + "\n" + assembly;
}

string printDataSegment() {
    string segment = "";
    for (auto data : dataSegment) {
        segment += data + " DW '?'\n";
    }
    return segment;
}

string printArraySegment() {
    string segment = "";
    for (auto arr : arraySegment) {
        segment += arr.first + " DW DUP " + arr.second + "(?)\n";
    }
    return segment;
}

string proc_PRINTLN() {
    string print = "";
    ifstream print_util("1805004_Print_Util.asm");
    string str;
    while(getline(print_util, str)) {
        print += str;
    }
    print_util.close();
    return print;
}

void printAssemblyCode(string code) {
    string str = ".MODEL SMALL\n.STACK 1000H\n\n.DATA\n";
    str += printDataSegment() + "\n" + printArraySegment() + "\n.CODE\n" + code;
    str += proc_PRINTLN() + "\n\n\nEND MAIN\n";
    outputCode << str;
}

void peepholeOptimization(string fileName) {
    ifstream read_asm_pass1(fileName);
    string prev_line, current_line;
    int lineCount = 0;
    set<int> lines_to_delete;

    while(getline(read_asm_pass1, current_line)) {
        if(current_line == "\n" || current_line == "" || current_line.find(";") == 0) {
            ;
        } else {
            lineCount++;
        }

        if(current_line.find("MOV") != string::npos && prev_line.find("MOV") != string::npos) {
            string operands_prev = prev_line.substr(prev_line.find(" ") + 1);
            string operands_curr = current_line.substr(current_line.find(" ") + 1);
            if(operands_prev.find(",") != string::npos && operands_curr.find(",") != string::npos) {
                string prev_operand1 = operands_prev.substr(0, operands_prev.find(","));
                string prev_operand2 = operands_prev.substr(operands_prev.find(",") + 2);  // as space here
                string curr_operand1 = operands_curr.substr(0, operands_curr.find(","));
                string curr_operand2 = operands_curr.substr(operands_curr.find(",") + 2);  // as space here
                if((prev_operand1 == curr_operand1 && prev_operand2 == curr_operand2)
                  || (prev_operand1 == curr_operand2 && prev_operand2 == curr_operand1)) {
                    lines_to_delete.insert(lineCount);
                }
            }
        } else if(current_line.find("POP") != string::npos && prev_line.find("PUSH") != string::npos) {
            string prev_operand = prev_line.substr(prev_line.find(" ") + 1);
            string curr_operand = current_line.substr(current_line.find(" ") + 1);
            if(prev_operand == curr_operand) {
                lines_to_delete.insert(lineCount - 1);
                lines_to_delete.insert(lineCount);
            }
        }

        if(current_line == "\n" || current_line == "" || current_line.find(";") == 0) {
            ;
        } else {
            prev_line = current_line;
        }
    }
    read_asm_pass1.close();

    ifstream read_asm_pass2(fileName);
    lineCount = 0;

    while(getline(read_asm_pass2, current_line)) {
        if(current_line == "\n" || current_line == "" || current_line.find(";") == 0) {
            ;
        } else {
            lineCount++;
        }
        if(lines_to_delete.find(lineCount) == lines_to_delete.end()) {
            optimized_asmCode += current_line + "\n";
        } else {
            optimized_asmCode += "; " + current_line + "\tpeephole\n";
        }
    }
    read_asm_pass2.close();

    optimized_codeOut << optimized_asmCode;
}

void return_optimization(string fileName) {
    ifstream read_asm_pass1(fileName);
    string prev_line, current_line;
    int lineCount = 0;
    int retFound = 0;
    set<int> lines_to_delete;

    while(getline(read_asm_pass1, current_line)) {
        if(current_line == "\n" || current_line == "" || current_line.find(";") == 0) {
            ;
        } else {
            lineCount++;
        }

        if(retFound == 0 && current_line.find("RET") != string::npos) {
            retFound = 1;
        } else if(retFound == 1 && current_line.find("PUSH") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && current_line.find("POP") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && current_line.find("MOV") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && current_line.find("CMP") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && current_line.find("JE") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && current_line.find("JMP") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && current_line.find("JNE") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && current_line.find("JL") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && current_line.find("JLE") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && current_line.find("JG") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && current_line.find("JGE") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && current_line.find("RET") != string::npos) {
            lines_to_delete.insert(lineCount);
        } else if(retFound == 1 && (current_line == "" || current_line == "\n" || current_line.find(";") == 0)) {
        } else {
            retFound = 0;
        }

        if(current_line == "\n" || current_line == "" || current_line.find(";") == 0) {
            ;
        } else {
            prev_line = current_line;
        }
    }
    read_asm_pass1.close();

    optimized_asmCode = "";
    ifstream read_asm_pass2(fileName);
    lineCount = 0;

    while(getline(read_asm_pass2, current_line)) {
        if(current_line == "\n" || current_line == "" || current_line.find(";") == 0) {
            ;
        } else {
            lineCount++;
        }
        if(lines_to_delete.find(lineCount) == lines_to_delete.end()) {
            optimized_asmCode += current_line + "\n";
        } else {
            optimized_asmCode += "; " + current_line + "\tret_optimization\n";
        }
    }
    read_asm_pass2.close();

    ofstream optimized_codeOut(fileName);
    optimized_codeOut << optimized_asmCode;
}

void printOptimizedAssemblyCode() {

    //---------------------------------- mandatory : peephole optimization ----------------------------------//
    peepholeOptimization("code.asm");

    //--------------------------------------- extra optimization ---------------------------------//
    return_optimization("optimized_code.asm");
}

#endif //INTERMEDIATE_CODE_GENERATION_1805004_ICGUTILS_H