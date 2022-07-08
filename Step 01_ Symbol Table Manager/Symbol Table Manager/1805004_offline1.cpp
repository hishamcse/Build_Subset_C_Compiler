/*
   Topic : Symbol Table Manager
   Name : Syed Jarullah Hisham
   Roll : 1805004
   CSE'18 SECTION A1
 */

#include <iostream>
#include <fstream>
#include "1805004_Utils.h"
#include "1805004_IOUtils.h"
#include "1805004_SymbolTable.h"

using namespace std;

int main() {

    if (fileIn.is_open()) {
        int total_buckets;
        string operation, name, type, symbol, print_type;

        fileIn >> total_buckets;

        SymbolTable symbolTable(total_buckets);

        while (fileIn >> operation) {
            switch (getOperation(operation)) {
                case I:
                    fileIn >> name >> type;
                    output << "I " << name << " " << type << '\n' << '\n';
                    symbolTable.insertSymbol(name, type);
                    break;
                case L:
                    fileIn >> symbol;
                    output << "L " << symbol << '\n' << '\n';
                    symbolTable.lookUpSymbol(symbol);
                    break;
                case D:
                    fileIn >> symbol;
                    output << "D " << symbol << '\n' << '\n';
                    symbolTable.removeSymbol(symbol);
                    break;
                case P:
                    fileIn >> print_type;
                    output << "P " << print_type << '\n' << '\n';
                    if (print_type == "C") symbolTable.print_currentScopeTable();
                    if (print_type == "A") symbolTable.print_allScopeTables();
                    break;
                case S:
                    output << "S" << '\n' << '\n';
                    symbolTable.enterScope(true);
                    break;
                case E:
                    output << "E" << '\n' << '\n';
                    symbolTable.exitScope();
                    break;
                default:
                    exit(1);
            }
        }
    } else {
        output << "Can't open file" << '\n';
    }

    fileIn.close();
    fileOut.close();

    return 0;
}