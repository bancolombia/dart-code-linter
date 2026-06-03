.PHONY: help install-dev generate-skills generate-skills-all test format lint test-analyzer-compat test-analyzer-compat-full

VENV_PYTHON := .venv/bin/python3
VENV_PIP := .venv/bin/pip
VENV_PYTEST := .venv/bin/pytest
VENV_RUFF := .venv/bin/ruff
TARGETS ?=

help:
	@echo "Targets:"
	@echo "  install-dev     Create .venv and install Python dev deps (pip install -r dependencies-dev.txt)"
	@echo "  generate-skills      Generate assets (default: cursor). Example: make generate-skills TARGETS=all"
	@echo "  generate-skills-all  Generate Cursor + VSCode (same as --targets all)"
	@echo "  test            Run pytest in scripts/tests/"
	@echo "  test-analyzer-compat      Analyze lib/ with analyzer 10.x, 11.x, 12.x, 13.x"
	@echo "  test-analyzer-compat-full Run full dart test with analyzer 10.x, 11.x, 12.x, 13.x"
	@echo "  format          Format scripts/ with ruff"
	@echo "  lint            Lint scripts/ with ruff"

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
	$(VENV_RUFF) format scripts/

lint:
	$(VENV_RUFF) check scripts/

test-analyzer-compat:
	$(VENV_PYTHON) scripts/test_analyzer_compat.py --analyze-only

test-analyzer-compat-full:
	$(VENV_PYTHON) scripts/test_analyzer_compat.py
