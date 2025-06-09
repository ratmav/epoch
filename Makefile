# Makefile for epoch plugin refactoring

# Directories
LUA_DIR := ./lua
TEST_DIR := ./tests

NVIM_FLAGS := NVIM_INSTALL_MODE=1

# Lua path for script execution
SCRIPT_LUA_PATH := LUA_PATH="$(PWD)/scripts/lib/?.lua;$(PWD)/scripts/lib/?/init.lua;$(PWD)/lua/?.lua;$(PWD)/lua/?/init.lua;$$LUA_PATH"

.PHONY: test data laconic coverage wisp lint help

# Default target shows help
.DEFAULT_GOAL := help

# Run all tests or specific test file
# Usage: make test [SPEC=filename]  (e.g., make test SPEC=ui_logic)

test:
ifdef SPEC
	$(NVIM_FLAGS) nvim --headless \
		-c "lua package.path='$(PWD)/lua/?.lua;'..package.path" \
		-c "lua require('plenary.test_harness').test_directory('$(TEST_DIR)/$(SPEC)_spec.lua', {minimal_init = '$(TEST_DIR)/minimal_init.lua'})" \
		-c "quit"
else
	$(NVIM_FLAGS) nvim --headless \
		-c "lua package.path='$(PWD)/lua/?.lua;'..package.path" \
		-c "lua require('plenary.test_harness').test_directory('$(TEST_DIR)', {minimal_init = '$(TEST_DIR)/minimal_init.lua', sequential = true})" \
		-c "quit"
endif

# Create test data for manual testing
data:
	$(NVIM_FLAGS) nvim --headless \
		-c "lua package.path='$(PWD)/lua/?.lua;'..package.path" \
		-c "lua dofile('$(PWD)/tests/scripts/create_test_data.lua')" \
		-c "quit"

# Helper to check for luarocks and set environment
check-luarocks:
	@command -v luarocks >/dev/null 2>&1 || { echo "Error: luarocks is required for development tools. Install luarocks first." >&2; exit 1; }

# Check laconic compliance (file/function length)
laconic: check-luarocks
	@eval "$$(luarocks path)" && $(SCRIPT_LUA_PATH) lua scripts/laconic.lua lua/epoch

# Check test coverage
coverage: check-luarocks
	@eval "$$(luarocks path)" && $(SCRIPT_LUA_PATH) lua scripts/coverage.lua

# Clean whitespace with wisp tool
wisp: check-luarocks
	@eval "$$(luarocks path)" && $(SCRIPT_LUA_PATH) lua scripts/wisp.lua

# Lint Lua code with luacheck
lint:
	@luacheck . --no-color -q --codes

# Run all tests using the old plenary test_harness (may hang)
test-old:
	$(NVIM_FLAGS) nvim --headless \
		-c "lua package.path='$(PWD)/lua/?.lua;'..package.path" \
		-c "lua require('plenary.test_harness').test_directory('$(TEST_DIR)', {minimal_init = '$(TEST_DIR)/minimal_init.lua'})" \
		-c "quit"



# Show help information
help:
	@echo "Available commands:"
	@echo "  make test            - Run all tests"
	@echo "  make test SPEC=name  - Run specific test (e.g., make test SPEC=ui_logic)"
	@echo "  make laconic         - Check laconic compliance (file/function length)"
	@echo "  make coverage        - Check test coverage"
	@echo "  make wisp            - Clean whitespace (trailing, empty lines)"
	@echo "  make lint            - Lint Lua code with luacheck"
	@echo "  make data            - Create sample timesheet data for manual testing"
