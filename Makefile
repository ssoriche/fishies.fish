# fishies.fish Makefile
# Provides convenient commands for development and linting

FISH_FILES := $(wildcard functions/*.fish conf.d/*.fish)

.PHONY: help lint format lint-fix clean

# Default target
help: ## Show this help message
	@echo "fishies.fish - Fish shell utility collection"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: ## Check fish syntax and formatting
	@echo "Checking Fish syntax..."
	@for file in $(FISH_FILES); do \
		fish -n "$$file" || exit 1; \
	done
	@echo "All files have valid Fish syntax"
	@echo ""
	@echo "Checking Fish formatting..."
	@for file in $(FISH_FILES); do \
		tmp=$$(mktemp) || exit 1; \
		fish_indent < "$$file" > "$$tmp" 2>/dev/null || { \
			echo "Error formatting $$file"; \
			rm -f "$$tmp"; \
			exit 1; \
		}; \
		if ! diff -u "$$file" "$$tmp" >/dev/null; then \
			echo "$$file is not properly formatted. Run 'make format' to fix."; \
			diff -u "$$file" "$$tmp" || true; \
			rm -f "$$tmp"; \
			exit 1; \
		fi; \
		rm -f "$$tmp"; \
	done
	@echo "All files are properly formatted"

format: ## Format all Fish files using fish_indent
	@echo "Formatting Fish files..."
	@for file in $(FISH_FILES); do \
		echo "  Formatting $$file..."; \
		fish_indent < "$$file" > "$$file.tmp" || { \
			echo "Failed to format $$file"; \
			rm -f "$$file.tmp"; \
			exit 1; \
		}; \
		mv "$$file.tmp" "$$file" || { \
			echo "Failed to write formatted output for $$file"; \
			rm -f "$$file.tmp"; \
			exit 1; \
		}; \
	done
	@echo "All Fish files formatted"

lint-fix: format lint ## Format files then run lint

clean: ## Remove temporary files
	@echo "Cleaning up..."
	@find . -name "*.tmp" -delete
	@find . -name "*.bak" -delete
	@echo "Cleanup complete"
