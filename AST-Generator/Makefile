all: pushParser

pushParser.cpp pushParser.hpp: pushParser.y
	bison -d -o pushParser.cpp pushParser.y

pushScanner.cpp: pushScanner.l
	flex -o pushScanner.cpp pushScanner.l

pushParser: main.cpp pushParser.cpp pushScanner.cpp
	g++ -std=c++11 -w main.cpp pushParser.cpp pushScanner.cpp -o pushParser

clean:
	rm -rf output.gv pushParser pushParser.dSYM pushParser.cpp pushScanner.cpp pushParser.hpp
