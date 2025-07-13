CXX := g++
CXXFLAGS := -Ofast -std=c++11

TARGET := build/s3pir
INCLUDE := src/include
SRC := src/client.cpp src/server.cpp src/main.cpp src/utils.cpp
DEPS := src/include/client.h src/include/server.h src/include/utils.h 

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin) # Mac OS X
    BREW_PREFIX := $(shell brew --prefix)
    INCLUDES := -I$(BREW_PREFIX)/include -I$(BREW_PREFIX)/include/cryptopp
    LDFLAGS := -L$(BREW_PREFIX)/lib
else # Linux
    INCLUDES := -I/usr/include -I/usr/include/cryptopp -I/usr/local/include -I/usr/local/include/cryptopp
    LDFLAGS := -L/usr/lib -L/usr/local/lib
endif

LDLIBS := -lcryptopp


all: $(TARGET) $(TARGET)_simlargeserver 

debug: $(TARGET)_debug

clean: 
	rm -f build/*

.PHONY: all clean debug

$(TARGET): $(SRC) $(DEPS)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $(TARGET) $(SRC) $(LDFLAGS) $(LDLIBS)

$(TARGET)_debug: $(SRC) $(DEPS)
	$(CXX) -DDEBUG $(CXXFLAGS) $(INCLUDES) -o $(TARGET)_debug $(SRC) $(LDFLAGS) $(LDLIBS)

$(TARGET)_simlargeserver: $(SRC) $(DEPS)
	$(CXX) -DSimLargeServer $(CXXFLAGS) $(INCLUDES) -o $(TARGET)_simlargeserver $(SRC) $(LDFLAGS) $(LDLIBS)
