config ?= release

PACKAGE := ponylisp
COMPILE_WITH := corral run -- ponyc

BUILD_DIR ?= build/$(config)
SRC_DIR := $(PACKAGE)
EXAMPLES_DIR := examples
tests_binary := $(BUILD_DIR)/$(PACKAGE)
docs_dir := build/$(PACKAGE)-docs

ifdef config
	ifeq (,$(filter $(config),debug release))
		$(error Unknown configuration "$(config)")
	endif
endif

ifeq ($(config),release)
	PONYC = $(COMPILE_WITH)
else
	PONYC = $(COMPILE_WITH) --debug
endif

SOURCE_FILES := $(shell find $(SRC_DIR) -name \*.pony)
EXAMPLE_SOURCE_FILES := $(shell find $(EXAMPLES_DIR) -name \*.pony)

test: unit-tests build-examples

unit-tests: $(tests_binary)
	$^ --exclude=integration --sequential

$(tests_binary): $(SOURCE_FILES) | $(BUILD_DIR)
	$(PONYC) -o ${BUILD_DIR} $(SRC_DIR)

build-examples: $(SOURCE_FILES) $(EXAMPLES_SOURCE_FILES) | $(BUILD_DIR)
	find examples/*/* -name '*.pony' -print | xargs -n 1 dirname  | sort -u | grep -v ffi- | xargs -n 1 -I {} $(PONYC) -s --checktree -o $(BUILD_DIR) {}

clean:
	rm -rf $(BUILD_DIR)

realclean:
	rm -rf build

$(docs_dir): $(SOURCE_FILES)
	rm -rf $(docs_dir)
	$(PONYC) --docs-public --pass=docs --output build $(SRC_DIR)

docs: $(docs_dir)

TAGS:
	ctags -R -f .tags
	# ctags --recurse=yes $(SRC_DIR)

test-mal:
	# python runtest.py tests/step0_repl.mal build/release/ponylisp
	# python runtest.py tests/step1_read_print.mal build/release/ponylisp
	# python runtest.py tests/step2_eval.mal build/release/ponylisp
	# python runtest.py tests/step3_env.mal build/release/ponylisp
	# python runtest.py tests/step4_if_fn_do.mal build/release/ponylisp
	# python runtest.py tests/step5_tco.mal build/release/ponylisp
	# python runtest.py --rundir tests tests/step6_file.mal build/release/ponylisp
	# python runtest.py tests/step6_file.mal build/release/ponylisp
	python runtest.py tests/step7_quote.mal build/release/ponylisp
	# python runtest.py tests/step8_macros.mal build/release/ponylisp
	# python runtest.py tests/step9_try.mal build/release/ponylisp
	# python runtest.py tests/stepA_mal.mal build/release/ponylisp

all: clean test

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: all clean realclean TAGS test
