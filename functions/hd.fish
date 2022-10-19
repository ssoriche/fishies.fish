function hd -d "delete exact command from history" --wraps history
  history delete --case-sensitive --exact "$argv"
end
