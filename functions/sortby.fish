#!/usr/bin/env fish

# SORTBY - sort by column name: sort tabular output by a specified column name
# from the header row, preserving the header at the top
function sortby
  set -l name $argv[1]
  if test -z "$name"
    echo "Usage: sortby COLUMN_NAME" >&2
    echo 'sortby - sort by column name; sorts tabular data by the specified column' >&2
    return 1
  end

  # Create temporary file
  set -l tmpfile (mktemp)

  # Save all input to temp file
  cat > $tmpfile

  # Find column number
  set -l col_num (head -n 1 $tmpfile | awk -v name=$name '
    {
      for(i=1; i<=NF; i++) {
        if($i==name) {
          print i
          exit
        }
      }
    }
  ')

  if test -z "$col_num"
    echo "Error: Column \"$name\" not found" >&2
    rm $tmpfile
    return 1
  end

  # Print header
  head -n 1 $tmpfile

  # Sort data by column
  tail -n +2 $tmpfile | sort -k $col_num

  # Clean up
  rm $tmpfile
end
