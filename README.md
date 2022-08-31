# Build_Subset_C_Compiler
This repository contains a step by step code implementation for the construction of a compiler for a subset of C language
<br />

## Step 01_Symbol Table Manager<a name="symbol"></a>
   A symbol-table is a data structure maintained by the compilers in order to store information about the occurrence of various entities such as identifiers, objects,      function names etc. Information of different entities may include type, value, scope etc. At the starting phase of constructing a compiler, we will construct a        symbol-table which maintains a list of hash tables where each hash table contains information of symbols encountered in a scope of the source program
   
* [Specification](https://github.com/hishamcse/Build_Subset_C_Compiler/blob/master/Step%2001_%20Symbol%20Table%20Manager/Assignment%201%20Specification.pdf)
* [Solution](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2001_%20Symbol%20Table%20Manager/Symbol%20Table%20Manager)
* [Test Cases](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2001_%20Symbol%20Table%20Manager/test%20cases)
<br />

## Step 02_Lexical Analyzer<a name="lex"></a>
  Lexical analysis is the process of scanning the source program as a sequence of characters and converting them into sequences of tokens. A program that performs this    task is called a lexical analyzer or a lexer or a scanner. For example, if a portion of the source program contains int x=5; the scanner would convert in a sequence of tokens like <INT><ID,x><ASSIGNOP,=><COST_NUM,5><SEMICOLON>. The task will be performed using a tool named flex (Fast Lexical Analyzer Generator) which is a popular    tool for generating scanners
   
* [Specification] (https://github.com/hishamcse/Build_Subset_C_Compiler/blob/master/Step%2001_%20Symbol%20Table%20Manager/Assignment%201%20Specification.pdf)
* [Resources] (https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2002_Lexical%20Analyzer%20with%20Flex/Resources)
* [Solution] (https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2002_Lexical%20Analyzer%20with%20Flex/Lexical%20Analyzer)
* [Test Cases] (https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2002_Lexical%20Analyzer%20with%20Flex/test%20cases)
<br />
