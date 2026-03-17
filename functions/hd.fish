function hd -d "delete exact command from all history sources" --wraps history
  if test (count $argv) -eq 0
    echo "Usage: hd <command>" >&2
    return 1
  end

  history delete --case-sensitive --exact "$argv"

  if command -v atuin >/dev/null
    atuin search --delete "'$argv'"
  end
end
