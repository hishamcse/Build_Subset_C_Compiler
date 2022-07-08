/*
    ScopeTable implementation
    Created by Hisham on 21-May-22.
*/

#ifndef SYMBOL_TABLE_MANAGER_1805004_SCOPETABLE_H
#define SYMBOL_TABLE_MANAGER_1805004_SCOPETABLE_H

#include<iostream>
#include <utility>
#include "1805004_SymbolInfo.h"
#include "1805004_Utils.h"

using namespace std;

class ScopeTable {
    SymbolInfo **symbols;
    ScopeTable *parentScope;
    string unique_id;
    int buckets;
    int serialId = 1;

    int hashVal(const string &name) const;

public:
    ScopeTable(int buckets, ScopeTable *parentScope);

    bool insertSymbol(const string &symbol, const string &type);

    SymbolInfo *lookUpSymbol(const string &symbol);

    bool deleteSymbol(const string &symbol);

    void printScopeTable() const;

    ScopeTable *getParentScope() const;

    int getSerialId() const;

    void increment_SerialId();

    const string &getUniqueId() const;

    void setUniqueId(const string &uniqueId);

    ~ScopeTable();

    friend OutputUtil &operator<<(OutputUtil &out, const ScopeTable &scopeTable);
};

int ScopeTable::hashVal(const string &name) const {
    return sbdmHash(name) % buckets;
}

ScopeTable::ScopeTable(int buckets, ScopeTable *parentScope) : parentScope(parentScope), buckets(buckets) {
    symbols = new SymbolInfo *[buckets];

    for (int i = 0; i < buckets; i++) {
        symbols[i] = nullptr;
    }
}

bool ScopeTable::insertSymbol(const string &symbol, const string &type) {
    SymbolInfo *foundSymbol = lookUpSymbol(symbol);
    if (foundSymbol) {
        output << "<" << foundSymbol->getName() << "," << foundSymbol->getType() << ">"
               << " already exists in current ScopeTable" << '\n' << '\n';
        return false;
    }

    int hashIndex = hashVal(symbol);
    SymbolInfo *current = symbols[hashIndex];

    auto *newSymbolObj = new SymbolInfo(symbol, type);
    newSymbolObj->setBucketNo(hashIndex);

    int bucket_chain_index = 0;

    if (!current) {
        symbols[hashIndex] = newSymbolObj;
        newSymbolObj->setBucketChainIndex(bucket_chain_index);
    } else {
        bucket_chain_index = 1;
        while (current->getNextPtr()) {
            current = current->getNextPtr();
            bucket_chain_index++;
        }

        newSymbolObj->setBucketChainIndex(bucket_chain_index);
        current->setNextPtr(newSymbolObj);
    }

    output << "Inserted in ScopeTable# " << unique_id << " at position " << newSymbolObj->getBucketPosition() << '\n'
           << '\n';
    return true;
}

SymbolInfo *ScopeTable::lookUpSymbol(const string &symbol) {
    int hashIndex = hashVal(symbol);
    SymbolInfo *current = symbols[hashIndex];

    while (current) {
        if (current->getName() == symbol) {
            return current;
        }
        current = current->getNextPtr();
    }

    return nullptr;
}

bool ScopeTable::deleteSymbol(const string &symbol) {
    SymbolInfo *foundSymbol = lookUpSymbol(symbol);
    if (!foundSymbol) {
        output << "Not found" << '\n';
        output << symbol << " not found" << '\n' << '\n';
        return false;
    }

    output << "Found in ScopeTable# " << unique_id << " at position " << foundSymbol->getBucketPosition() << '\n'
           << '\n';

    int hashIndex = hashVal(symbol);
    SymbolInfo *current = symbols[hashIndex];
    SymbolInfo *previous = nullptr;

    while (current && current->getName() != symbol) {
        previous = current;
        current = current->getNextPtr();
    }

    output << "Deleted Entry " << current->getBucketPosition() << " from current ScopeTable" << '\n' << '\n';

    if (!previous) {
        symbols[hashIndex] = current->getNextPtr();
    } else {
        previous->setNextPtr(current->getNextPtr());
        SymbolInfo *temp = previous->getNextPtr();
        while (temp) {
            temp->setBucketChainIndex(temp->getBucketChainIndex() - 1);
            temp = temp->getNextPtr();
        }
    }

    delete current;

    return true;
}

void ScopeTable::printScopeTable() const {
    output << *this;
}

const string &ScopeTable::getUniqueId() const {
    return unique_id;
}

void ScopeTable::setUniqueId(const string &uniqueId) {
    unique_id = uniqueId;
}

ScopeTable *ScopeTable::getParentScope() const {
    return parentScope;
}

int ScopeTable::getSerialId() const {
    return serialId;
}

void ScopeTable::increment_SerialId() {
    ++serialId;
}

ScopeTable::~ScopeTable() {
    delete[] symbols;
}

OutputUtil &operator<<(OutputUtil &out, const ScopeTable &scopeTable) {
    out << "ScopeTable # " << scopeTable.unique_id << '\n';

    for (int i = 0; i < scopeTable.buckets; i++) {
        out << i << "--> ";
        SymbolInfo *symbolInfo = scopeTable.symbols[i];
        while (symbolInfo) {
            out << *symbolInfo << " ";
            symbolInfo = symbolInfo->getNextPtr();
        }
        out << '\n';
    }

    out << '\n';
    return out;
}

#endif //SYMBOL_TABLE_MANAGER_1805004_SCOPETABLE_H