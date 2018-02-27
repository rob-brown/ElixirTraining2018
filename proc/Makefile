# Variables

CC ?= $(CROSSCOMPILER)gcc
CFLAGS = -g -Wall
SOURCES = $(wildcard src/*.c)
HEADER_DIR = src
OBJECTS = $(SOURCES:.c=.o)
EXECUTABLE = priv/stack
LDFLAGS = -I $(HEADER_DIR)
RM = rm -f

# Top-level Targets

all: build clean_intermediate_files done

build: priv $(EXECUTABLE)

clean: clean_all done

# Helper targets

%.o: %.c
	@echo "Compiling $@"
	@$(CC) -c $(CFLAGS) -o $@ $<

$(EXECUTABLE): $(OBJECTS)
	@echo "Building executable"
	@$(CC) $^ $(LDFLAGS) -o $@

priv:
	mkdir -p priv

clean_all:
	@echo "Cleaning Build"
	@$(RM) priv/*

clean_intermediate_files:
	@echo "Cleaning build artifacts"
	@$(RM) $(OBJECTS)

done:
	@echo "Done"

# For debugging, ex. `make print-SOURCES`.
# See http://blog.jgc.org/2015/04/the-one-line-you-should-add-to-every.html
print-%: ; @echo $*=$($*)

