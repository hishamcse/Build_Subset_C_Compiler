# Build_Subset_C_Compiler
This repository contains a step by step code implementation for the construction of a compiler for a subset of C language
<br /><br />

## Step 01_Symbol Table Manager<a name="symbol"></a>
   A symbol-table is a data structure maintained by the compilers in order to store information about the occurrence of various entities such as identifiers, objects,      function names etc. Information of different entities may include type, value, scope etc. At the starting phase of constructing a compiler, we will construct a        symbol-table which maintains a list of hash tables where each hash table contains information of symbols encountered in a scope of the source program
   
* [Specification](https://github.com/hishamcse/Build_Subset_C_Compiler/blob/master/Step%2001_%20Symbol%20Table%20Manager/Assignment%201%20Specification.pdf)
* [Solution](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2001_%20Symbol%20Table%20Manager/Symbol%20Table%20Manager)
* [Test Cases](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2001_%20Symbol%20Table%20Manager/test%20cases)
<br />

## Step 02_Lexical Analyzer<a name="lex"></a>
  Lexical analysis is the process of scanning the source program as a sequence of characters and converting them into sequences of tokens. A program that performs this     task is called a lexical analyzer or a lexer or a scanner. For example, if a portion of the source program contains int x=5; the scanner would convert in a sequence     tokens like &lt;INT&gt;&lt;ID,x&gt;&lt;ASSIGNOP,=&gt;&lt;COST_NUM,5&gt;&lt;SEMICOLON&gt;. The task will be performed using a tool named flex (Fast Lexical Analyzer Generator) which is a popular tool for generating scanners
   
* [Specification](https://github.com/hishamcse/Build_Subset_C_Compiler/blob/master/Step%2002_Lexical%20Analyzer%20with%20Flex/Assignment%202%20Specification.pdf)
* [Resources](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2002_Lexical%20Analyzer%20with%20Flex/Resources)
* [Solution](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2002_Lexical%20Analyzer%20with%20Flex/Lexical%20Analyzer)
* [Test Cases](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2002_Lexical%20Analyzer%20with%20Flex/test%20cases)
<br />

## Step 03_Syntax & Semantic Analyzer<a name="bison"></a>
  In this step, we will construct the last part of the front end of a compiler for a subset of the C language. That means we will perform syntax analysis and semantic analysis with a grammar rule containing function implementation in this step. To do so, we will build a parser with the help of Lex (Flex) and Yacc (Bison)
   
* [Specification](https://github.com/hishamcse/Build_Subset_C_Compiler/blob/master/Step%2003_Syntax%20and%20Semantic%20Analyzer%20with%20Bison/CSE310_January_2022_YACC_Assignment_Spec.pdf)
* [Grammar](https://github.com/hishamcse/Build_Subset_C_Compiler/blob/master/Step%2003_Syntax%20and%20Semantic%20Analyzer%20with%20Bison/BisonAssignmentGrammar.PDF)
* [Resources](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2003_Syntax%20and%20Semantic%20Analyzer%20with%20Bison/resources)
* [Solution](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2003_Syntax%20and%20Semantic%20Analyzer%20with%20Bison/Syntax%20And%20Semantic%20Analyzer)
* [Test Cases](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2003_Syntax%20and%20Semantic%20Analyzer%20with%20Bison/test%20cases)
<br />

## Step 04_Intermediate Code Generation<a name="icg"></a>
  In this step, we will generate intermediate code for a source program having no error. That means if our source code does not contain any error, which was to be detected in the previous offline, we will generate intermediate code for the source code. We have picked 8086 assembly language as our intermediate representation.
   
* [Specification](https://github.com/hishamcse/Build_Subset_C_Compiler/blob/master/Step%2004_Intermediate%20Code%20Generation/CSE_310_January_2022_ICG_Spec.pdf)
* [Grammar](https://github.com/hishamcse/Build_Subset_C_Compiler/blob/master/Step%2004_Intermediate%20Code%20Generation/BisonAssignmentGrammar.PDF)
* [Resources](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2004_Intermediate%20Code%20Generation/Resources)
* [Solution](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2004_Intermediate%20Code%20Generation/Intermediate%20Code%20Generation)
* [Test Cases](https://github.com/hishamcse/Build_Subset_C_Compiler/tree/master/Step%2004_Intermediate%20Code%20Generation/test%20cases)
<br />

