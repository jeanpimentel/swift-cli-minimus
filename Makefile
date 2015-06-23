MODULE_NAME = Minimus
SDK         = macosx

CONFIG     ?= debug

ROOT_DIR    = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SRC_DIR     = $(ROOT_DIR)/src
TEST_DIR    = $(ROOT_DIR)/test
TEST_FILE   = $(ROOT_DIR)/tests.o
 
ifneq ($(strip $(shell which xcpretty)),)
    XCPRETTY_TEST = 2>&1 >/dev/null | xcpretty --test --color --simple
endif

ifeq ($(CONFIG), debug)
    CFLAGS=-Onone -g
else
    CFLAGS=-O3
endif

SWIFTC            = $(shell xcrun -f swiftc)
CLANG             = $(shell xcrun -f clang)
SDK_PATH          = $(shell xcrun --show-sdk-path --sdk $(SDK))
SWIFT_FILES       = $(wildcard $(SRC_DIR)/*.swift)
SWIFT_TEST_FILES  = $(wildcard $(TEST_DIR)/*.swift)

build:
    @$(SWIFTC) -sdk $(SDK_PATH) -emit-library -module-name $(MODULE_NAME) -emit-module $(SWIFT_FILES) 

build-tests:
    @$(SWIFTC) -sdk $(SDK_PATH) -F/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -Xlinker -rpath -Xlinker /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks -lswiftCore $(SWIFT_TEST_FILES) -I "." -L "." -l$(MODULE_NAME) -module-link-name $(MODULE_NAME) -o $(TEST_FILE)

test: build-tests
    @xcrun xctest $(TEST_FILE) $(XCPRETTY_TEST)

clean:
    @rm -rf *.swiftdoc *.swiftmodule *.dylib $(TEST_FILE)

watch:
ifeq ($(strip $(shell which fswatch)),)
    @echo "fswatch is not installed. Aborting.
else
    @echo "Watching for changes..."
    @fswatch -r $(SWIFT_FILES) $(SWIFT_TEST_FILES) | xargs -n1 -I{} make clean build test
endif