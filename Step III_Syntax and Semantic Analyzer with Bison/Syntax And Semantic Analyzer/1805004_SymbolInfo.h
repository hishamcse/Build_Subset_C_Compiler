/*
    SymbolInfo Implementation
    Created by Hisham on 21-May-22.
*/

#ifndef Syntax_Analyzer_1805004_SYMBOLINFO_H
#define Syntax_Analyzer_1805004_SYMBOLINFO_H

#include<iostream>
#include<fstream>
#include<utility>
#include<vector>
#include "1805004_IOUtils.h"

using namespace std;

class SymbolInfo {
    string name;
    string type;
    SymbolInfo *nextPtr;

    int bucketNo, bucket_Chain_index;

    string speciesType;        // array, func or variable
    string returnType;

    parameter param;

    vector<parameter> func_param_list;

public:

    SymbolInfo(string name, string type)
            : name(move(name)), type(move(type)) {
        this->nextPtr = nullptr;
        bucketNo = -1;
        bucket_Chain_index = -1;
        returnType = "NOTHING";
        speciesType = "";
    }

    SymbolInfo(string name, string type, SymbolInfo *successor)
            : name(move(name)), type(move(type)), nextPtr(successor) {
        bucketNo = -1;
        bucket_Chain_index = -1;
    }

    const string &getName() const {
        return name;
    }

    const string &getType() const {
        return type;
    }

    SymbolInfo *getNextPtr() const {
        return nextPtr;
    }

    void setNextPtr(SymbolInfo *successor) {
        this->nextPtr = successor;
    }

    void setBucketNo(int bucketNumber) {
        this->bucketNo = bucketNumber;
    }

    void setBucketChainIndex(int bucketChainIndex) {
        this->bucket_Chain_index = bucketChainIndex;
    }

    int getBucketChainIndex() const {
        return bucket_Chain_index;
    }

    string getBucketPosition() const {
        return to_string(bucketNo) + ", " + to_string(bucket_Chain_index);
    }

    void setSpeciesType(string str) {
        this -> speciesType = str;
    }

    string getSpeciesType() {
        return this -> speciesType;
    }

    void setReturnType(string str) {
        this -> returnType = str;
    }

    string getReturnType() {
        return this -> returnType;
    }

    void insertParameter(string type, string name, string species, string returnType) {
        param.paramType = type;
        param.paramName = name;
        param.p_speciesType = species;
        param.p_returnType = returnType;

        func_param_list.push_back(param);
    }

    vector<parameter> getFuncParamList() {
        return func_param_list;
    }

    void clear_funcParamList() {
        func_param_list.clear();
    }

    ~SymbolInfo()= default;

    friend OutputUtil &operator<<(OutputUtil &out, const SymbolInfo &symbolInfo) {
        out << "< " << symbolInfo.getName() << " : " << symbolInfo.getType() << ">";
        return out;
    }
};

#endif //Syntax_Analyzer_1805004_SYMBOLINFO_H