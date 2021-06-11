SHELL = /bin/sh

.SUFFIXES:
.SUFFIXES: .bats

srcdir ?= src
testdir ?= test

BATS := ./test/bats/bin/bats

TESTS := $(foreach x, $(testdir), $(wildcard $(addprefix $(x)/*,.bats)))

.PHONY: test
test: $(testdir)/*.bats
	$(BATS) $(<D)

.PHONY: docs
docs: semver-release.md

# https://github.com/reconquest/shdoc
semver-release.md: $(srcdir)/semver-release
	shdoc < $< > $@
