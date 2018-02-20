all: pushParser

pushParser.cpp pushParser.hpp: pushParser.y
	bison -d -o pushParser.cpp pushParser.y

pushScanner.cpp: pushScanner.l
	flex -o pushScanner.cpp pushScanner.l

pushParser: main.cpp pushParser.cpp pushScanner.cpp
	g++ -std=c++11 main.cpp pushParser.cpp pushScanner.cpp -o pushParser

clean:
	rm -f pushParser pushParser.cpp pushScanner.cpp pushParser.hpp
