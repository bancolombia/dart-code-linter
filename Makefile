.PHONY: help install-dev generate-skills generate-skills-all test format lint

VENV_PYTHON := .venv/bin/python3
VENV_PIP := .venv/bin/pip
VENV_PYTEST := .venv/bin/pytest
VENV_BLACK := .venv/bin/black
VENV_FLAKE8 := .venv/bin/flake8
TARGETS ?=

help:
	@echo "Targets:"
	@echo "  install-dev     Create .venv and install Python dev deps (pip install -r dependencies-dev.txt)"
	@echo "  generate-skills      Generate assets (default: cursor). Example: make generate-skills TARGETS=all"
	@echo "  generate-skills-all  Generate Cursor + VSCode (same as --targets all)"
	@echo "  test            Run pytest in scripts/tests/"
	@echo "  format          Format scripts/ with black"
	@echo "  lint            Lint scripts/ with flake8"

install-dev:
	python3 -m venv .venv
	$(VENV_PIP) install -r dependencies-dev.txt

generate-skills:
	$(VENV_PYTHON) scripts/generate_cursor_skills.py $(if $(TARGETS),--targets $(TARGETS))

generate-skills-all:
	$(VENV_PYTHON) scripts/generate_cursor_skills.py --targets all

test:
	$(VENV_PYTEST) scripts/tests/ -v

format:
	$(VENV_BLACK) scripts/

lint:
	$(VENV_FLAKE8) scripts/ --exclude=scripts/tests/fixtures
