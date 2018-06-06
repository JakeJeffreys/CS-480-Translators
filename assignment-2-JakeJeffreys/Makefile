all: parser scanner parse

parse: main.cpp parser.cpp scanner.cpp
	g++ main.cpp parser.cpp scanner.cpp -o parser

parser: parser.y
	bison -d -o parser.cpp parser.y

scanner: scanner.l
	flex -o scanner.cpp scanner.l

run:
	./parser < testing_code/p1.py

clean:
	rm -f parser scanner.cpp parser.cpp parser.hpp output_file.cpp
