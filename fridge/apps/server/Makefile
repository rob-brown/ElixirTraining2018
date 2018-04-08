# Variales

SOURCE_DIR=elm
SOURCES=$(SOURCE_DIR)/Main.elm
DEPS=$(wildcard elm/src/*.elm) 
BUILD_DIR=priv/static/js
JS=$(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.elm=.js)))
RM=rm -f
EM=elm-make

# Special targets

.DEFAULT: all

# Top-level Targets

all: build done

build: $(JS)

clean: clean_all

# Helper Targets

$(JS): $(DEPS)

$(BUILD_DIR)/%.js: $(SOURCE_DIR)/%.elm
	@echo "Compiling $< to $@"
	@$(EM) $< --output=$@ --yes

clean_all:
	@echo "Cleaning Elm JS files"
	@$(RM) $(JS)

done:
	@echo "Done"

# For debugging, ex. `make print-SOURCES`.
# See http://blog.jgc.org/2015/04/the-one-line-you-should-add-to-every.html
print-%: ; @echo $*=$($*)

