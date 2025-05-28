# Makefile for epoch plugin refactoring

# Directories
LUA_DIR := ./lua
TEST_DIR := ./tests

# TODO: Change 'NVIM_INSTALL_MODE' to 'NVIM_HEADLESS_MODE' in your dotfiles
# for better semantics
NVIM_FLAGS := NVIM_INSTALL_MODE=1

.PHONY: test clean data check help

# Default target shows help
.DEFAULT_GOAL := help

# Run all tests
test:
	$(NVIM_FLAGS) nvim --headless \
		-c "lua package.path='$(PWD)/lua/?.lua;'..package.path" \
		-c "PlenaryBustedDirectory $(TEST_DIR) {minimal_init = '$(TEST_DIR)/minimal_init.lua'}" \
		-c "quit"

# Create test data for manual testing
data:
	$(NVIM_FLAGS) nvim --headless \
		-c "lua package.path='$(PWD)/lua/?.lua;'..package.path" \
		-c "lua dofile('$(PWD)/tests/scripts/create_test_data.lua')" \
		-c "quit"

# Check file and function length compliance
check:
	@lua scripts/laconic.lua

# Clean generated files and timesheet data
clean:
	find . -name "*.bak" -delete
	@echo "WARNING: This will also delete ALL timesheet data."
	@read -p "Continue? [y/N] " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		nvim --headless \
			-c "lua package.path='$(PWD)/lua/?.lua;'..package.path" \
			-c "require('epoch.storage').delete_all_timesheets()" \
			-c "print('All timesheet data deleted')" \
			-c "quit"; \
	else \
		echo "Timesheet data NOT deleted"; \
	fi

# Show help information
help:
	@echo "Available commands:"
	@echo "  make test   - Run all tests"
	@echo "  make check  - Check file and function length compliance"
	@echo "  make data   - Create sample timesheet data for manual testing"
	@echo "  make clean  - Clean temporary files and timesheet data"