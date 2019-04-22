
PONYC ?= ponyc
PONYC_FLAGS ?=
config ?= release

BUILD_DIR ?= build/$(config)
SRC_DIR ?= lisp
build_binary := $(BUILD_DIR)/lisp
test_binary := $(BUILD_DIR)/test
bench_binary := $(BUILD_DIR)/bench

SOURCE_FILES := $(shell find $(SRC_DIR) -name \*.pony)

ifdef config
  ifeq (,$(filter $(config),debug release))
    $(error Unknown configuration "$(config)")
  endif
endif

ifeq ($(config),debug)
    PONYC_FLAGS += --debug
endif

.PHONY: all build
all: clean test build

build:
	stable env $(PONYC) $(PONYC_FLAGS) $(SRC_DIR) -o $(BUILD_DIR)

test: $(test_binary)
	$(test_binary)

bench: $(bench_binary)
	$(bench_binary)

$(test_binary): $(SOURCE_FILES) | $(BUILD_DIR)
	stable env $(PONYC) $(PONYC_FLAGS) $(SRC_DIR)/test -o $(BUILD_DIR)

$(bench_binary): $(SOURCE_FILES) | $(BUILD_DIR)
	stable env $(PONYC) $(PONYC_FLAGS) $(SRC_DIR)/bench -o $(BUILD_DIR)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.coverage:
	mkdir -p .coverage

clean:
	rm -rf $(BUILD_DIR) .coverage

coverage: .coverage $(test_binary)
	kcov --include-pattern="$(SRC_DIR)" --exclude-pattern="*/test/*.pony,*/_test.pony" .coverage $(test_binary)

docs: PONYC_FLAGS += --pass=docs --docs-public --output=docs-tmp
docs:
	rm -rf docs-tmp
	stable env $(PONYC) $(PONYC_FLAGS) $(SRC_DIR)
	cd docs-tmp/http-docs && mkdocs build
	rm -rf docs
	cp -R docs-tmp/http-docs/site docs
	rm -rf docs-tmp

clean-test: clean test

docker-build:
	docker run -it --rm -v "$(shell pwd):/src/main" ponylang/ponyc make

docker-test:
	docker run -it --rm -v "$(shell pwd):/src/main" ponylang/ponyc make clean-test

docker-run:
	docker run -it --rm -v "$(shell pwd):/src/main" ponylang/ponyc /src/main/$(build_binary)

default: all
