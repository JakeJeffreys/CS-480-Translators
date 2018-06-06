all: parse

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parse: main.cpp parser.cpp scanner.cpp
	g++ main.cpp parser.cpp scanner.cpp -o parse

run:
	./parse < testing_code/p1.py
	dot -Tpng -o tree1.png OUTPUT.gv
	./parse < testing_code/p2.py
	dot -Tpng -o tree2.png OUTPUT.gv
	./parse < testing_code/p3.py
	dot -Tpng -o tree3.png OUTPUT.gv


clean:
	rm -f parse scanner.cpp parser.cpp parser.hpp
