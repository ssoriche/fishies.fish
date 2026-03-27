# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Fish shell utility collection called "fishies.fish" containing helper functions and abbreviations for Fish shell users. The repository follows Fish shell's standard plugin structure with `functions/` and `conf.d/` directories.

## Repository Structure

- `functions/` - Fish functions that users can call directly
- `conf.d/` - Configuration files loaded automatically when Fish starts (used for abbreviations and auto-setup)

## Architecture

### Function Pattern
Functions follow Fish shell best practices:
- Use `#!/usr/bin/env fish` shebang for standalone scripts; function files loaded by Fish may omit it
- Include `-d` description flags for user-facing functions
- Use `$argv[N]` for argument access
- Provide usage messages to stderr with `>&2`
- Return non-zero exit codes on errors
- Use `set -l` for local variables to avoid polluting global scope

### Abbreviations
Abbreviations are defined in `conf.d/` files and automatically loaded. The `!!` abbreviation (last history command) is implemented via:
- `conf.d/last_history_item.fish` - Sets up the abbreviation using `abbr -a !! --position anywhere --function last_history_item`
- `functions/last_history_item.fish` - Provides the function that returns `$history[1]`

### Utility Functions

#### Text Processing Utilities
- `cbn` (column by name) and `sortby` both use a similar pattern:
  1. Read stdin into a temporary file using `mktemp`
  2. Use `awk` to find the column number by matching the header name
  3. Process the data using the column number
  4. Clean up temporary files

These functions expect whitespace-delimited tabular data with a header row.

#### macOS Keychain Utilities
- `allow-granted-keychain` - Adds the current devbox/nix granted binary to macOS keychain ACLs
  - Auto-detects the granted binary path using `which granted`
  - Resolves symlinks to get the actual binary path (important for nix/devbox paths)
  - Searches for granted-related keychain items by parsing the login keychain dump
  - Interactively prompts user to add the binary to each discovered keychain item's ACL
  - Provides instructions for checking currently trusted applications in Keychain Access.app
  - Uses `security add-generic-password -U` to update items with new trusted applications
  - Requires user's keychain password for modifications
  - Supports Ctrl+C to cancel at any prompt
  - Note: ACL cannot be read from command line; use Keychain Access.app to view trusted applications

## Development Guidelines

### Testing Functions
Test functions manually in a Fish shell:
```fish
# Test cbn
echo -e "NAME AGE\nAlice 30\nBob 25" | cbn AGE

# Test sortby
echo -e "NAME AGE\nAlice 30\nBob 25" | sortby NAME

# Test hd
hd "some command to delete from history"

# Test !!
echo "test" # Then type !! to get "test" again

# Test allow-granted-keychain (requires devbox shell with granted installed)
allow-granted-keychain
```

### Adding New Functions
1. Create the function file in `functions/FUNCTION_NAME.fish`
2. Use the shebang `#!/usr/bin/env fish` for standalone scripts
3. Include a description with `-d` flag
4. Follow the error handling pattern (check arguments, provide usage, return non-zero on error)
5. Use local variables with `set -l`
6. Run `make format` before committing
7. Test manually before committing

### Adding New Abbreviations
1. Create a function in `functions/` if the abbreviation needs logic
2. Set up the abbreviation in `conf.d/` using `abbr -a`
3. Use a versioned global variable (e.g., `set -g __last_history_item_abbr_version 0.0.1`) to track the abbreviation setup

## CI & Development Commands

- `make lint` - Check syntax (`fish -n`) and formatting (`fish_indent`) for all `.fish` files
- `make format` - Auto-format all `.fish` files with `fish_indent`
- `make lint-fix` - Format then lint
- `make clean` - Remove temporary files

CI runs automatically on PRs to `main` via `.github/workflows/lint.yaml`.

## Code Style

- Use `fish_indent` output as the source of truth for Fish indentation/style
- Use 4-space indentation for awk scripts within Fish functions
- Prefer modern tools when implementing utilities
- Always clean up temporary files
- Use `awk` (not `gawk`) for portability
