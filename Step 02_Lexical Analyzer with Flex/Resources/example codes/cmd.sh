flex scanner.l
g++ lex.yy.c -lfl -o output
./output "$1"
