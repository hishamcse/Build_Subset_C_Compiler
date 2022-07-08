/*
    SymbolTable implementation
    Created by Hisham on 21-May-22.
*/

#ifndef SYMBOL_TABLE_MANAGER_1805004_SYMBOLTABLE_H
#define SYMBOL_TABLE_MANAGER_1805004_SYMBOLTABLE_H

#include<iostream>
#include <utility>
#include "1805004_ScopeTable.h"

using namespace std;

class SymbolTable {
    ScopeTable *current_scopeTable;
    int buckets;

public:
    explicit SymbolTable(int buckets);

    void enterScope();

    void exitScope();

    bool insertSymbol(const string &symbol, const string &type);

    bool removeSymbol(const string &symbol);

    SymbolInfo *lookUpSymbol(const string &symbol);

    void print_currentScopeTable();

    void print_allScopeTables();

    virtual ~SymbolTable();
};

SymbolTable::SymbolTable(int buckets) {
    current_scopeTable = nullptr;
    this->buckets = buckets;
    this->enterScope();
}

void SymbolTable::enterScope() {
    auto *scopeTable = new ScopeTable(buckets, current_scopeTable);
    current_scopeTable = scopeTable;

    string construct_id;

    if (current_scopeTable->getParentScope()) {
        ScopeTable *parentScope = current_scopeTable->getParentScope();
        construct_id = parentScope->getUniqueId() + "." + to_string(parentScope->getSerialId());
    } else {
        construct_id = to_string(current_scopeTable->getSerialId());
    }

    current_scopeTable->setUniqueId(construct_id);
}

void SymbolTable::exitScope() {
    if (!current_scopeTable) {
        outputToken << "NO CURRENT SCOPE" << '\n' << '\n';
        return;
    }

    ScopeTable *temp_scopeTable = current_scopeTable;

    if (current_scopeTable->getParentScope()) {
        current_scopeTable = current_scopeTable->getParentScope();
        current_scopeTable->increment_SerialId();
    } else {
        current_scopeTable = nullptr;
    }

    delete temp_scopeTable;
}

bool SymbolTable::insertSymbol(const string &symbol, const string &type) {
    if (!current_scopeTable) this->enterScope();
    return current_scopeTable->insertSymbol(symbol, type);
}

bool SymbolTable::removeSymbol(const string &symbol) {
    return current_scopeTable->deleteSymbol(symbol);
}

SymbolInfo *SymbolTable::lookUpSymbol(const string &symbol) {
    if (!current_scopeTable) {
        return nullptr;
    }

    SymbolInfo *symbolObj;
    ScopeTable *tempScopeTable = current_scopeTable;

    while (tempScopeTable) {
        symbolObj = tempScopeTable->lookUpSymbol(symbol);
        if (symbolObj) {
            return symbolObj;
        }
        tempScopeTable = tempScopeTable->getParentScope();
    }

    return symbolObj;
}

void SymbolTable::print_currentScopeTable() {
    if (!current_scopeTable) return;
    current_scopeTable->printScopeTable();
}

void SymbolTable::print_allScopeTables() {
    if (!current_scopeTable) return;
    ScopeTable *tempScopeTable = current_scopeTable;

    while (tempScopeTable) {
        tempScopeTable->printScopeTable();
        tempScopeTable = tempScopeTable->getParentScope();
    }
}

SymbolTable::~SymbolTable() {
    ScopeTable *temp_scopeTable;

    while (current_scopeTable) {
        temp_scopeTable = current_scopeTable->getParentScope();
        delete current_scopeTable;
        current_scopeTable = temp_scopeTable;
    }
}

#endif //SYMBOL_TABLE_MANAGER_1805004_SYMBOLTABLE_H