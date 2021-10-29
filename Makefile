BIN := mackerel-plugin-battery
VERSION := $$(make -s show-version)
GOBIN ?= $(shell go env GOPATH)/bin

.PHONY: all
all: build

.PHONY: build
build:
	go build -o $(BIN) .

.PHONY: install
install:
	go install ./...

.PHONY: show-version
show-version:
	@cat VERSION

.PHONY: cross
cross: $(GOBIN)/goxz
	goxz -n $(BIN) -pv=v$(VERSION)

$(GOBIN)/goxz:
	go install github.com/Songmu/goxz/cmd/goxz@latest

.PHONY: test
test: build
	go test -v -race ./...

.PHONY: lint
lint: $(GOBIN)/staticcheck
	go vet ./...
	staticcheck ./...

$(GOBIN)/staticcheck:
	go install honnef.co/go/tools/cmd/staticcheck@latest

.PHONY: clean
clean:
	rm -rf $(BIN) goxz
	go clean

.PHONY: upload
upload: $(GOBIN)/ghr
	ghr "v$(VERSION)" goxz

$(GOBIN)/ghr:
	go install github.com/tcnksm/ghr@latest
