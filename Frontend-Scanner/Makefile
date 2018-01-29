all:
	flex -o scanner.cpp scanner.l
	g++ -std=c++11 -w scanner.cpp -o scan
test:
	make;
	./scan < testing_code/p1.py > out1.txt && diff -E -b out1.txt example_output/p1.out 
	./scan < testing_code/p2.py > out2.txt && diff -E -b out2.txt example_output/p2.out 
	./scan < testing_code/p3.py > out3.txt && diff -E -b out3.txt example_output/p3.out 
	./scan < testing_code/p4.py > out4.txt && diff -E -b out4.txt example_output/p4.out
clean:
	rm out1.txt out2.txt out3.txt out4.txt scan scanner.cpp