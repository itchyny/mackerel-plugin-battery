BIN := mackerel-plugin-battery
VERSION := $$(make -s show-version)
GIT_DIFF := $$(git diff --name-only)
BUILD_LDFLAGS = "-s -w"
GOBIN ?= $(shell go env GOPATH)/bin

.PHONY: all
all: build

.PHONY: build
build:
	go build -ldflags=$(BUILD_LDFLAGS) -o $(BIN) .

.PHONY: install
install:
	go install -ldflags=$(BUILD_LDFLAGS) .

.PHONY: show-version
show-version:
	@cat VERSION

.PHONY: cross
cross: $(GOBIN)/goxz CREDITS
	goxz -n $(BIN) -pv=v$(VERSION) -build-ldflags=$(BUILD_LDFLAGS) .

$(GOBIN)/goxz:
	go install github.com/Songmu/goxz/cmd/goxz@latest

CREDITS: $(GOBIN)/gocredits go.sum
	go mod tidy
	gocredits -w .

$(GOBIN)/gocredits:
	go install github.com/Songmu/gocredits/cmd/gocredits@latest

.PHONY: test
test: build
	go test -v -race ./...

.PHONY: lint
lint: $(GOBIN)/staticcheck
	go vet ./...
	staticcheck -checks all ./...

$(GOBIN)/staticcheck:
	go install honnef.co/go/tools/cmd/staticcheck@latest

.PHONY: clean
clean:
	rm -rf $(BIN) goxz CREDITS
	go clean

.PHONY: bump
bump:
	test -z "$$(git status --porcelain || echo .)"
	test "$$(git branch --show-current)" = "main"
	@printf "Bump up version in VERSION. Press Enter to proceed: "
	@read -n1
	@[ "$(GIT_DIFF)" == "VERSION" ] || { \
		echo "Version is not updated or unrelated file is updated:"; \
		[ -z "$(GIT_DIFF)" ] || printf "  %s\n" $(GIT_DIFF); \
		exit 1; \
	}
	git commit -am "bump up version to $(VERSION)"
	git tag "v$(VERSION)"
	git push --atomic origin main tag "v$(VERSION)"
