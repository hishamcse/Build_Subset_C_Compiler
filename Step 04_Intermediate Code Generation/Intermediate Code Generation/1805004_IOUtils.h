/*
    Input Output Utilities
    Created by Hisham on 21-May-22.
*/

#ifndef Syntax_Analyzer_1805004_IOUTILS_H
#define Syntax_Analyzer_1805004_IOUTILS_H

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

struct parameter {
    string paramType;
    string paramName;
    string p_speciesType;
    string p_returnType;
};

#endif //Syntax_Analyzer_1805004_IOUTILS_H