/*
    SymbolInfo Implementation
    Created by Hisham on 21-May-22.
*/

#ifndef SYMBOL_TABLE_MANAGER_1805004_SYMBOLINFO_H
#define SYMBOL_TABLE_MANAGER_1805004_SYMBOLINFO_H

#include<iostream>
#include<fstream>
#include<utility>
#include "1805004_IOUtils.h"

using namespace std;

class SymbolInfo {
    string name;
    string type;
    SymbolInfo *nextPtr;

    int bucketNo, bucket_Chain_index;

public:
    SymbolInfo(string name, string type);

    SymbolInfo(string name, string type, SymbolInfo *successor);

    const string &getName() const;

    const string &getType() const;

    SymbolInfo *getNextPtr() const;

    void setNextPtr(SymbolInfo *successor);

    void setBucketNo(int bucketNumber);

    void setBucketChainIndex(int bucketChainIndex);

    int getBucketChainIndex() const;

    string getBucketPosition() const;

    ~SymbolInfo();

    friend OutputUtil &operator<<(OutputUtil &out, const SymbolInfo &symbolInfo);
};

SymbolInfo::SymbolInfo(string name, string type)
        : name(move(name)), type(move(type)) {
    this->nextPtr = nullptr;
    bucketNo = -1;
    bucket_Chain_index = -1;
}

SymbolInfo::SymbolInfo(string name, string type, SymbolInfo *successor)
        : name(move(name)), type(move(type)), nextPtr(successor) {
    bucketNo = -1;
    bucket_Chain_index = -1;
}

const string &SymbolInfo::getName() const {
    return name;
}

const string &SymbolInfo::getType() const {
    return type;
}

SymbolInfo *SymbolInfo::getNextPtr() const {
    return nextPtr;
}

void SymbolInfo::setNextPtr(SymbolInfo *successor) {
    this->nextPtr = successor;
}

void SymbolInfo::setBucketNo(int bucketNumber) {
    this->bucketNo = bucketNumber;
}

int SymbolInfo::getBucketChainIndex() const {
    return bucket_Chain_index;
}

string SymbolInfo::getBucketPosition() const {
    return to_string(bucketNo) + ", " + to_string(bucket_Chain_index);
}

void SymbolInfo::setBucketChainIndex(int bucketChainIndex) {
    this->bucket_Chain_index = bucketChainIndex;
}

OutputUtil &operator<<(OutputUtil &out, const SymbolInfo &symbolInfo) {
    out << "< " << symbolInfo.getName() << " : " << symbolInfo.getType() << ">";
    return out;
}

SymbolInfo::~SymbolInfo() = default;

#endif //SYMBOL_TABLE_MANAGER_1805004_SYMBOLINFO_H