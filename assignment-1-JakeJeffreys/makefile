all: ass1

ass1:
	flex -o scanner.cpp scanner.l
	g++ scanner.cpp -o scan

run:
	./scan < testing_code/p4.py

clean:
	-rm scanner.cpp scan
