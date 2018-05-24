.PHONY: all
all: build

.PHONY: help
help:  ## show help info
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: build
build: ## (default) build wctl
	@go build  -o _output/wctl main.go
