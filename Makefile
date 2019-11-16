BIN := mackerel-plugin-battery
VERSION := $$(make -s show-version)
GOBIN ?= $(shell go env GOPATH)/bin
export GO111MODULE=on

.PHONY: all
all: clean build

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
	cd ~ && go get github.com/Songmu/goxz/cmd/goxz

.PHONY: test
test: build
	go test -v ./...

.PHONY: lint
lint: $(GOBIN)/golint
	golint -set_exit_status ./...

$(GOBIN)/golint:
	cd ~ && go get golang.org/x/lint/golint

.PHONY: clean
clean:
	go clean

.PHONY: crossdocker
crossdocker:
	docker run --rm -v ${PWD}:"/$${PWD##*/}" -w "/$${PWD##*/}" golang make cross

.PHONY: upload
upload: $(GOBIN)/ghr
	ghr "v$(VERSION)" goxz

$(GOBIN)/ghr:
	cd ~ && go get github.com/tcnksm/ghr
