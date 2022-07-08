/*
    Input Output Utilities
    Created by Hisham on 21-May-22.
*/

#ifndef SYMBOL_TABLE_MANAGER_1805004_IOUTILS_H
#define SYMBOL_TABLE_MANAGER_1805004_IOUTILS_H

#include<iostream>

using namespace std;

class OutputUtil {
    ostream &os;
    ofstream &ofs;

public:
    OutputUtil(ostream &os, ofstream &ofs) : os(os), ofs(ofs) {}

    template<typename T>
    OutputUtil &operator<<(const T &output) {
        os << output;
        ofs << output;
        return *this;
    }
};

FILE *fileIn;
ofstream tokenOut("1805004_token.txt");
ofstream logOut("1805004_log.txt");

OutputUtil outputToken(cout, tokenOut);
OutputUtil outputLog(cout, logOut);

#endif //SYMBOL_TABLE_MANAGER_1805004_IOUTILS_H