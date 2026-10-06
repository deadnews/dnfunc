.PHONY: alpha bumped check install lint pc release test up update

default: check

check: pc lint test
pc:
	prek run -a
lint:
	uv run ruff check .
	uv run ruff format .
	uv run ty check .
test:
	uv run pytest

install:
	uv sync

update: up up-ci
up:
	uv sync --upgrade
up-ci:
	prek update
	pinact run --update

bumped:
	git cliff --bumped-version

# make alpha TAG=$(git cliff --bumped-version)-alpha.0
alpha: check
	git tag -a $(TAG) -m "chore(release): $(TAG)"
	git push origin $(TAG)

# make release TAG=v1.2.3
release: TAG ?= $(shell git cliff --bumped-version)
release: check
	git cliff -o CHANGELOG.md --tag $(TAG)
	prek run --files CHANGELOG.md || prek run --files CHANGELOG.md
	git add CHANGELOG.md
	git commit -m "chore(release): prepare for $(TAG)"
	git push
	git tag -a $(TAG) -m "chore(release): $(TAG)"
	git push origin $(TAG)
