flex -o tmp.c "$1"
g++ tmp.c -lfl -o tmp.out
./tmp.out "$2"
