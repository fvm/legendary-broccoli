# The name of the executable (default is current directory name)
TARGET := $$(echo $${PWD\#\#*/})
.DEFAULT_GOAL: $(TARGET)

# These will be provided to the target
VERSION := 0.0.0
BUILD := `git rev-parse HEAD`

# Use linker flags to provide version/build settings to the target
LDFLAGS=-ldflags "-X=main.Version=$(VERSION) -X=main.Build=$(BUILD)"

# go source files, ignore vendor directory
SRC = $$(find . -type f -name '*.go' -not -path "./vendor/*")

GOPATH?=$$(go env GOPATH)

$(TARGET): $(SRC)
	@go build $(LDFLAGS) -o $(TARGET)

.PHONY: all build clean install uninstall fmt simplify check run

imports: fmt
	$(GOPATH)/bin/goimports -w $(SRC)

all: check install

build: $(TARGET)
	@true

clean:
	@rm -f $(TARGET)

install:
	@go install $(LDFLAGS)

uninstall: clean
	@rm -f $$(which ${TARGET})

fmt:
	@gofmt -l -w $(SRC)

simplify:
	@gofmt -s -l -w $(SRC)

check:
	@test -z $$(gofmt -l -w $(SRC) | tee /dev/stderr) || echo "[WARN] Fix formatting issues with 'make fmt'"
	@for d in $$(go list ./... | grep -v /vendor/); do golint $${d}; done
	@go vet ./...

run: install
	@$(TARGET)